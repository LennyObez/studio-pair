import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../config/app_config.dart';
import '../config/database.dart';

// =============================================================================
// Abstract AI Provider
// =============================================================================

/// Abstract interface for AI model providers.
///
/// Each provider (Anthropic, OpenAI) implements this contract to send
/// completion requests and return generated text.
abstract class AiProvider {
  /// Sends a prompt to the AI model and returns the generated text.
  Future<String> complete(
    String prompt, {
    int maxTokens = 1024,
    double temperature = 0.7,
  });
}

// =============================================================================
// Anthropic Provider
// =============================================================================

/// Anthropic Claude API implementation of [AiProvider].
///
/// Uses the Messages API at https://api.anthropic.com/v1/messages.
class AnthropicProvider implements AiProvider {
  final String apiKey;
  final String model;
  final http.Client _httpClient;
  final Logger _log = Logger('AnthropicProvider');

  /// Anthropic Messages API endpoint.
  static const _apiUrl = 'https://api.anthropic.com/v1/messages';

  AnthropicProvider({
    required this.apiKey,
    required this.model,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  @override
  Future<String> complete(
    String prompt, {
    int maxTokens = 1024,
    double temperature = 0.7,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(_apiUrl),
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'max_tokens': maxTokens,
          'temperature': temperature,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode != 200) {
        _log.warning(
          'Anthropic API request failed: '
          '${response.statusCode} ${response.body}',
        );
        throw AiServiceException('Anthropic API error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content = data['content'] as List<dynamic>?;

      if (content == null || content.isEmpty) {
        throw const AiServiceException('Anthropic API returned empty content');
      }

      final firstBlock = content[0] as Map<String, dynamic>;
      return firstBlock['text'] as String? ?? '';
    } catch (e) {
      if (e is AiServiceException) rethrow;
      _log.severe('Anthropic API error', e);
      throw AiServiceException('Anthropic API call failed: $e');
    }
  }
}

// =============================================================================
// OpenAI Provider
// =============================================================================

/// OpenAI Chat Completions API implementation of [AiProvider].
///
/// Uses the Chat Completions API at https://api.openai.com/v1/chat/completions.
class OpenAiProvider implements AiProvider {
  final String apiKey;
  final String model;
  final http.Client _httpClient;
  final Logger _log = Logger('OpenAiProvider');

  /// OpenAI Chat Completions API endpoint.
  static const _apiUrl = 'https://api.openai.com/v1/chat/completions';

  OpenAiProvider({
    required this.apiKey,
    required this.model,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  @override
  Future<String> complete(
    String prompt, {
    int maxTokens = 1024,
    double temperature = 0.7,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'max_tokens': maxTokens,
          'temperature': temperature,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode != 200) {
        _log.warning(
          'OpenAI API request failed: '
          '${response.statusCode} ${response.body}',
        );
        throw AiServiceException('OpenAI API error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;

      if (choices == null || choices.isEmpty) {
        throw const AiServiceException('OpenAI API returned empty choices');
      }

      final firstChoice = choices[0] as Map<String, dynamic>;
      final message = firstChoice['message'] as Map<String, dynamic>?;
      return message?['content'] as String? ?? '';
    } catch (e) {
      if (e is AiServiceException) rethrow;
      _log.severe('OpenAI API error', e);
      throw AiServiceException('OpenAI API call failed: $e');
    }
  }
}

// =============================================================================
// AI Service
// =============================================================================

/// High-level AI service for generating suggestions, summaries, and analysis.
///
/// Wraps an [AiProvider] (Anthropic or OpenAI) selected via [AppConfig],
/// enforces entitlement-based credit limits, and logs usage to ai_usage_log.
class AiService {
  final AppConfig _config;
  final Database _db;
  final AiProvider? _provider;
  final Logger _log = Logger('AiService');
  final Uuid _uuid = const Uuid();

  /// Whether AI functionality is configured and available.
  bool get isConfigured => _config.aiApiKey.isNotEmpty;

  /// Fallback message returned when AI is not configured.
  static const _fallbackMessage =
      'AI features are not currently configured. Please set up an AI provider '
      'in your environment configuration to enable smart suggestions, '
      'summaries, and content analysis.';

  AiService(this._config, this._db) : _provider = _createProvider(_config);

  /// Creates the appropriate AI provider based on configuration.
  static AiProvider? _createProvider(AppConfig config) {
    if (config.aiApiKey.isEmpty) return null;

    switch (config.aiProvider) {
      case 'openai':
        return OpenAiProvider(apiKey: config.aiApiKey, model: config.aiModel);
      case 'anthropic':
      default:
        return AnthropicProvider(
          apiKey: config.aiApiKey,
          model: config.aiModel,
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Generates a suggestion based on the given context.
  ///
  /// Useful for recommending activities, tasks, or calendar events based on
  /// the group's patterns and preferences.
  Future<String> generateSuggestion(
    String context, {
    required String spaceId,
    required String userId,
  }) async {
    if (!isConfigured) return _fallbackMessage;

    await _checkCredits(spaceId, userId);

    final prompt =
        'You are a helpful assistant for a collaborative life-management app '
        'called Studio Pair. Based on the following context, provide a brief, '
        'actionable suggestion.\n\nContext:\n$context\n\nSuggestion:';

    final result = await _provider!.complete(prompt);
    await _logUsage(
      spaceId: spaceId,
      userId: userId,
      feature: 'suggestion',
      inputTokens: _estimateTokens(prompt),
      outputTokens: _estimateTokens(result),
    );

    return result;
  }

  /// Summarizes the given text into a concise overview.
  ///
  /// Useful for summarizing long chat threads, meeting notes, or charter
  /// discussions.
  Future<String> summarizeText(
    String text, {
    required String spaceId,
    required String userId,
  }) async {
    if (!isConfigured) return _fallbackMessage;

    await _checkCredits(spaceId, userId);

    final prompt =
        'Please provide a concise summary of the following text. Focus on the '
        'key points and actionable items.\n\nText:\n$text\n\nSummary:';

    final result = await _provider!.complete(prompt);
    await _logUsage(
      spaceId: spaceId,
      userId: userId,
      feature: 'summarize',
      inputTokens: _estimateTokens(prompt),
      outputTokens: _estimateTokens(result),
    );

    return result;
  }

  /// Analyzes content according to a specific instruction.
  ///
  /// Flexible method for content analysis tasks like sentiment analysis,
  /// categorization, or extracting structured data.
  Future<String> analyzeContent(
    String content,
    String instruction, {
    required String spaceId,
    required String userId,
  }) async {
    if (!isConfigured) return _fallbackMessage;

    await _checkCredits(spaceId, userId);

    final prompt =
        'Instruction: $instruction\n\nContent:\n$content\n\nAnalysis:';

    final result = await _provider!.complete(prompt);
    await _logUsage(
      spaceId: spaceId,
      userId: userId,
      feature: 'analyze',
      inputTokens: _estimateTokens(prompt),
      outputTokens: _estimateTokens(result),
    );

    return result;
  }

  // ---------------------------------------------------------------------------
  // Credit & Usage Management
  // ---------------------------------------------------------------------------

  /// Checks whether the space has available AI credits for the current month.
  ///
  /// Throws [AiServiceException] if the monthly credit limit is exhausted.
  Future<void> _checkCredits(String spaceId, String userId) async {
    final row = await _db.queryOne(
      '''
      SELECT COALESCE(SUM(credits_used), 0) AS total_credits
      FROM ai_usage_log
      WHERE space_id = @spaceId
        AND created_at >= date_trunc('month', NOW())
      ''',
      parameters: {'spaceId': spaceId},
    );

    final usedCredits = (row?[0] as int?) ?? 0;

    // Check entitlements for the space's tier
    final tierRow = await _db.queryOne(
      '''
      SELECT ss.tier
      FROM space_subscriptions ss
      WHERE ss.space_id = @spaceId
        AND ss.status = 'active'
      ORDER BY ss.created_at DESC
      LIMIT 1
      ''',
      parameters: {'spaceId': spaceId},
    );

    final tier = (tierRow?[0] as String?) ?? 'free';
    final maxCredits = tier == 'premium' ? 500 : 10;

    if (maxCredits != -1 && usedCredits >= maxCredits) {
      _log.info(
        'AI credit limit reached for space $spaceId '
        '($usedCredits/$maxCredits)',
      );
      throw AiServiceException(
        'AI credits exhausted for this month. '
        'Used $usedCredits of $maxCredits credits. '
        'Upgrade to Premium for more AI credits.',
      );
    }
  }

  /// Logs an AI usage record to the ai_usage_log table.
  Future<void> _logUsage({
    required String spaceId,
    required String userId,
    required String feature,
    required int inputTokens,
    required int outputTokens,
  }) async {
    final creditsUsed = _calculateCredits(inputTokens + outputTokens);

    try {
      await _db.execute(
        '''
        INSERT INTO ai_usage_log
          (id, space_id, user_id, feature, model, credits_used,
           input_tokens, output_tokens, created_at)
        VALUES
          (@id, @spaceId, @userId, @feature, @model, @creditsUsed,
           @inputTokens, @outputTokens, NOW())
        ''',
        parameters: {
          'id': _uuid.v4(),
          'spaceId': spaceId,
          'userId': userId,
          'feature': feature,
          'model': _config.aiModel,
          'creditsUsed': creditsUsed,
          'inputTokens': inputTokens,
          'outputTokens': outputTokens,
        },
      );
    } catch (e) {
      _log.warning('Failed to log AI usage', e);
      // Non-fatal: don't prevent the AI response from being returned
    }
  }

  /// Estimates token count from text using a simple heuristic.
  ///
  /// Approximation: ~4 characters per token on average for English text.
  int _estimateTokens(String text) {
    return (text.length / 4).ceil();
  }

  /// Calculates credits consumed based on total token count.
  ///
  /// 1 credit per 1000 tokens (rounded up), minimum 1 credit.
  int _calculateCredits(int totalTokens) {
    final credits = (totalTokens / 1000).ceil();
    return credits < 1 ? 1 : credits;
  }
}

// =============================================================================
// Exceptions
// =============================================================================

/// Exception thrown when an AI service operation fails.
class AiServiceException implements Exception {
  final String message;

  const AiServiceException(this.message);

  @override
  String toString() => 'AiServiceException: $message';
}
