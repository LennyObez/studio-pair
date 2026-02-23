import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_pair/src/i18n/app_localizations.dart';
import 'package:studio_pair/src/providers/cards_provider.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/widgets/common/sp_app_bar.dart';
import 'package:studio_pair/src/widgets/common/sp_empty_state.dart';
import 'package:studio_pair/src/widgets/common/sp_error_widget.dart';
import 'package:studio_pair/src/widgets/common/sp_loading.dart';

/// Cards screen with carousel of card previews.
class CardsScreen extends ConsumerStatefulWidget {
  const CardsScreen({super.key});

  @override
  ConsumerState<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends ConsumerState<CardsScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    ref.read(cardsProvider.notifier).loadCards();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color _parseCardColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return AppColors.cardVisa;
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.cardVisa;
    }
  }

  String _formatExpiry(int? month, int? year) {
    if (month == null || year == null) return '';
    final m = month.toString().padLeft(2, '0');
    final y = (year % 100).toString().padLeft(2, '0');
    return '$m/$y';
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label copied to clipboard')));
  }

  void _showCardDetailSheet(BuildContext context, CardItem card) {
    final theme = Theme.of(context);
    final isLoyalty = card.cardType == 'loyalty';

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
              ),
              Text(
                isLoyalty
                    ? (card.loyaltyStoreName ?? card.displayName)
                    : '${card.provider ?? card.cardType.toUpperCase()} Card',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Chip(
                label: Text(card.cardType.toUpperCase()),
                avatar: Icon(
                  isLoyalty ? Icons.loyalty : Icons.credit_card,
                  size: 16,
                ),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Column(
                  children: [
                    if (isLoyalty) ...[
                      ListTile(
                        leading: const Icon(Icons.store),
                        title: Text(context.l10n.translate('store')),
                        subtitle: Text(
                          card.loyaltyStoreName ?? card.displayName,
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.confirmation_number),
                        title: Text(context.l10n.translate('loyaltyNumber')),
                        subtitle: Text(card.loyaltyNumber ?? 'N/A'),
                        trailing: card.loyaltyNumber != null
                            ? IconButton(
                                icon: const Icon(Icons.copy),
                                tooltip: 'Copy loyalty number',
                                onPressed: () {
                                  _copyToClipboard(
                                    context,
                                    card.loyaltyNumber!,
                                    'Loyalty number',
                                  );
                                },
                              )
                            : null,
                      ),
                    ] else ...[
                      ListTile(
                        leading: const Icon(Icons.credit_card),
                        title: Text(context.l10n.translate('cardNumber')),
                        subtitle: Text(
                          card.lastFour != null
                              ? '**** **** **** ${card.lastFour}'
                              : 'N/A',
                        ),
                        trailing: card.lastFour != null
                            ? IconButton(
                                icon: const Icon(Icons.copy),
                                tooltip: 'Copy last 4 digits',
                                onPressed: () {
                                  _copyToClipboard(
                                    context,
                                    card.lastFour!,
                                    'Last 4 digits',
                                  );
                                },
                              )
                            : null,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(context.l10n.translate('cardholder')),
                        subtitle: Text(card.displayName),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copy cardholder name',
                          onPressed: () {
                            _copyToClipboard(
                              context,
                              card.displayName,
                              'Cardholder name',
                            );
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(context.l10n.translate('expiryDate')),
                        subtitle: Text(
                          _formatExpiry(card.expiryMonth, card.expiryYear),
                        ),
                      ),
                      if (card.provider != null) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.account_balance),
                          title: Text(context.l10n.translate('cardProvider')),
                          subtitle: Text(card.provider!),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      final navigator = Navigator.of(ctx);
                      final messenger = ScaffoldMessenger.of(context);

                      final confirmed = await showDialog<bool>(
                        context: ctx,
                        builder: (dCtx) => AlertDialog(
                          title: Text(context.l10n.translate('delete')),
                          content: Text(
                            'Are you sure you want to delete "${card.displayName}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dCtx).pop(false),
                              child: Text(context.l10n.translate('cancel')),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(dCtx).pop(true),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              child: Text(context.l10n.translate('delete')),
                            ),
                          ],
                        ),
                      );

                      if (confirmed != true) return;

                      final success = await ref
                          .read(cardsProvider.notifier)
                          .deleteCard(card.id);

                      if (!ctx.mounted) return;
                      navigator.pop();

                      if (success) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              context.l10n.translate('cardDeleted'),
                            ),
                          ),
                        );
                      } else {
                        final error = ref.read(cardsProvider).error;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(error ?? 'Failed to delete card'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                    label: Text(context.l10n.translate('delete')),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cardsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: SpAppBar(
        title: context.l10n.translate('cards'),
        showBackButton: true,
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by card type',
            onSelected: (type) {
              ref.read(cardsProvider.notifier).setTypeFilter(type);
            },
            itemBuilder: (context) => [
              PopupMenuItem(child: Text(context.l10n.translate('all'))),
              PopupMenuItem(
                value: 'debit',
                child: Text(context.l10n.translate('debit')),
              ),
              PopupMenuItem(
                value: 'credit',
                child: Text(context.l10n.translate('credit')),
              ),
              PopupMenuItem(
                value: 'loyalty',
                child: Text(context.l10n.translate('loyalty')),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(state, theme),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCardDialog(context),
        tooltip: 'Add card',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCardDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    var cardType = 'debit';
    var displayName = '';
    String? provider;
    String? lastFour;
    int? expiryMonth;
    int? expiryYear;
    String? cardColor;
    String? loyaltyNumber;
    String? loyaltyStoreName;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isLoyalty = cardType == 'loyalty';
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.md,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.md,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.translate('newCard'),
                        style: Theme.of(ctx).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Card type selector
                      DropdownButtonFormField<String>(
                        initialValue: cardType,
                        decoration: const InputDecoration(
                          labelText: 'Card type',
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'debit',
                            child: Text(context.l10n.translate('debit')),
                          ),
                          DropdownMenuItem(
                            value: 'credit',
                            child: Text(context.l10n.translate('credit')),
                          ),
                          DropdownMenuItem(
                            value: 'loyalty',
                            child: Text(context.l10n.translate('loyalty')),
                          ),
                        ],
                        onChanged: (value) {
                          setModalState(() => cardType = value ?? 'debit');
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Display name / cardholder
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: context.l10n.translate('cardHolderName'),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                        onSaved: (v) => displayName = v?.trim() ?? '',
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      if (isLoyalty) ...[
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Store name',
                          ),
                          onSaved: (v) => loyaltyStoreName = v?.trim(),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Loyalty number',
                          ),
                          onSaved: (v) => loyaltyNumber = v?.trim(),
                        ),
                      ] else ...[
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Provider (e.g. Visa, Mastercard)',
                          ),
                          onSaved: (v) => provider = v?.trim(),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Last 4 digits',
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          validator: (v) {
                            if (v != null && v.isNotEmpty && v.length != 4) {
                              return 'Must be exactly 4 digits';
                            }
                            return null;
                          },
                          onSaved: (v) => lastFour = v?.trim(),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Expiry month (MM)',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v != null && v.isNotEmpty) {
                                    final m = int.tryParse(v);
                                    if (m == null || m < 1 || m > 12) {
                                      return '1-12';
                                    }
                                  }
                                  return null;
                                },
                                onSaved: (v) =>
                                    expiryMonth = int.tryParse(v ?? ''),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Expiry year (YYYY)',
                                ),
                                keyboardType: TextInputType.number,
                                onSaved: (v) =>
                                    expiryYear = int.tryParse(v ?? ''),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),

                      // Card color picker
                      Text(
                        'Card color',
                        style: Theme.of(ctx).textTheme.labelMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final preset in const [
                            '#1A237E',
                            '#283593',
                            '#1565C0',
                            '#0277BD',
                            '#00695C',
                            '#2E7D32',
                            '#E65100',
                            '#BF360C',
                            '#4E342E',
                            '#37474F',
                            '#AD1457',
                            '#6A1B9A',
                            '#880E4F',
                            '#311B92',
                            '#004D40',
                            '#1B5E20',
                          ])
                            GestureDetector(
                              onTap: () {
                                setModalState(() => cardColor = preset);
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Color(
                                    int.parse(
                                      'FF${preset.replaceFirst('#', '')}',
                                      radix: 16,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: cardColor == preset
                                      ? Border.all(
                                          color: Theme.of(
                                            ctx,
                                          ).colorScheme.primary,
                                          width: 2.5,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        initialValue: cardColor,
                        decoration: const InputDecoration(
                          labelText: 'Or enter hex code (e.g. #1A237E)',
                          prefixIcon: Icon(Icons.palette_outlined),
                        ),
                        onChanged: (v) {
                          final hex = v.trim();
                          if (hex.startsWith('#') && hex.length == 7) {
                            setModalState(() => cardColor = hex);
                          }
                        },
                        onSaved: (v) {
                          if (v != null && v.trim().isNotEmpty) {
                            cardColor = v.trim();
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState?.validate() ?? false) {
                              formKey.currentState?.save();
                              final success = await ref
                                  .read(cardsProvider.notifier)
                                  .createCard(
                                    cardType: cardType,
                                    displayName: displayName,
                                    provider: provider,
                                    lastFour: lastFour,
                                    expiryMonth: expiryMonth,
                                    expiryYear: expiryYear,
                                    cardColor: cardColor,
                                    loyaltyNumber: loyaltyNumber,
                                    loyaltyStoreName: loyaltyStoreName,
                                  );
                              if (success && ctx.mounted) {
                                Navigator.of(ctx).pop();
                              }
                            }
                          },
                          child: Text(context.l10n.translate('add')),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(CardsState state, ThemeData theme) {
    if (state.isLoading && state.cards.isEmpty) {
      return const Center(child: SpLoading());
    }

    if (state.error != null) {
      return SpErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(cardsProvider.notifier).loadCards(),
      );
    }

    final filteredCards = ref.watch(cardListProvider);

    if (filteredCards.isEmpty) {
      return SpEmptyState(
        icon: Icons.credit_card_outlined,
        title: context.l10n.translate('noCards'),
        description: context.l10n.translate('addCardDescription'),
      );
    }

    // Clamp selected index in case filter changed
    if (_selectedIndex >= filteredCards.length) {
      _selectedIndex = 0;
    }

    final selectedCard = filteredCards[_selectedIndex];

    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),

        // Card carousel
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: filteredCards.length,
            onPageChanged: (index) {
              setState(() => _selectedIndex = index);
            },
            itemBuilder: (context, index) {
              final card = filteredCards[index];
              return GestureDetector(
                onTap: () => _showCardDetailSheet(context, card),
                child: _CreditCardWidget(
                  card: card,
                  theme: theme,
                  cardColor: _parseCardColor(card.cardColor),
                  formatExpiry: _formatExpiry,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Card details
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Card details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: Column(
                    children: [
                      if (selectedCard.cardType == 'loyalty') ...[
                        ListTile(
                          leading: const Icon(Icons.loyalty),
                          title: Text(context.l10n.translate('store')),
                          subtitle: Text(
                            selectedCard.loyaltyStoreName ??
                                selectedCard.displayName,
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.confirmation_number),
                          title: Text(context.l10n.translate('loyaltyNumber')),
                          subtitle: Text(selectedCard.loyaltyNumber ?? 'N/A'),
                          trailing: selectedCard.loyaltyNumber != null
                              ? IconButton(
                                  icon: const Icon(Icons.copy),
                                  tooltip: 'Copy loyalty number',
                                  onPressed: () {
                                    _copyToClipboard(
                                      context,
                                      selectedCard.loyaltyNumber!,
                                      'Loyalty number',
                                    );
                                  },
                                )
                              : null,
                        ),
                      ] else ...[
                        ListTile(
                          leading: const Icon(Icons.credit_card),
                          title: Text(context.l10n.translate('cardNumber')),
                          subtitle: Text(
                            selectedCard.lastFour != null
                                ? '**** **** **** ${selectedCard.lastFour}'
                                : 'N/A',
                          ),
                          trailing: selectedCard.lastFour != null
                              ? IconButton(
                                  icon: const Icon(Icons.copy),
                                  tooltip: 'Copy card number',
                                  onPressed: () {
                                    _copyToClipboard(
                                      context,
                                      selectedCard.lastFour!,
                                      'Last 4 digits',
                                    );
                                  },
                                )
                              : null,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(context.l10n.translate('cardholder')),
                          subtitle: Text(selectedCard.displayName),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(context.l10n.translate('expiryDate')),
                          subtitle: Text(
                            _formatExpiry(
                              selectedCard.expiryMonth,
                              selectedCard.expiryYear,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CreditCardWidget extends StatelessWidget {
  const _CreditCardWidget({
    required this.card,
    required this.theme,
    required this.cardColor,
    required this.formatExpiry,
  });

  final CardItem card;
  final ThemeData theme;
  final Color cardColor;
  final String Function(int?, int?) formatExpiry;

  @override
  Widget build(BuildContext context) {
    final isLoyalty = card.cardType == 'loyalty';

    return Semantics(
      label: isLoyalty
          ? '${card.loyaltyStoreName ?? card.displayName} loyalty card'
          : '${card.provider ?? card.cardType} card ending in ${card.lastFour ?? "unknown"}',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cardColor, cardColor.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            boxShadow: [
              BoxShadow(
                color: cardColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isLoyalty
                        ? (card.loyaltyStoreName ?? card.displayName)
                        : (card.provider ?? card.cardType.toUpperCase()),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    isLoyalty ? Icons.loyalty : Icons.wifi,
                    color: Colors.white70,
                    semanticLabel: isLoyalty ? 'Loyalty card' : 'Contactless',
                  ),
                ],
              ),
              if (!isLoyalty)
                const Icon(Icons.sim_card, color: Colors.amber, size: 36)
              else
                Icon(
                  Icons.card_giftcard,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 36,
                ),
              Text(
                isLoyalty
                    ? (card.loyaltyNumber ?? '')
                    : '**** **** **** ${card.lastFour ?? '----'}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoyalty ? 'MEMBER' : 'CARD HOLDER',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white60,
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        card.displayName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (!isLoyalty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'EXPIRES',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white60,
                            fontSize: 9,
                          ),
                        ),
                        Text(
                          formatExpiry(card.expiryMonth, card.expiryYear),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
