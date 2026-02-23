import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:studio_pair_backend/studio_pair_backend.dart';

void main(List<String> args) async {
  // Setup logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    final error = record.error != null ? ' | Error: ${record.error}' : '';
    final stack = record.stackTrace != null ? '\n${record.stackTrace}' : '';
    stdout.writeln(
      '${record.level.name}: ${record.time}: ${record.loggerName}: '
      '${record.message}$error$stack',
    );
  });

  final log = Logger('Server');

  try {
    // Load environment
    final env = DotEnv(includePlatformEnvironment: true)..load(['.env']);

    final config = AppConfig.fromEnv(env);

    log.info('Starting Studio Pair backend in ${config.env} mode...');

    // Create application
    final app = await Application.create(config);

    // Create handler pipeline
    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(corsMiddleware())
        .addMiddleware(app.rateLimiterMiddleware)
        .addMiddleware(app.authMiddleware)
        .addHandler(app.router.call);

    // Start server
    final server = await shelf_io.serve(handler, config.host, config.port);

    server.autoCompress = true;

    log.info('Server running on http://${server.address.host}:${server.port}');
    log.info('Press Ctrl+C to stop.');

    // Graceful shutdown
    ProcessSignal.sigint.watch().listen((_) async {
      log.info('Received SIGINT. Shutting down gracefully...');
      await app.dispose();
      await server.close();
      log.info('Server stopped.');
      exit(0);
    });

    // Also handle SIGTERM for container deployments
    if (!Platform.isWindows) {
      ProcessSignal.sigterm.watch().listen((_) async {
        log.info('Received SIGTERM. Shutting down gracefully...');
        await app.dispose();
        await server.close();
        log.info('Server stopped.');
        exit(0);
      });
    }
  } catch (e, stackTrace) {
    log.severe('Failed to start server', e, stackTrace);
    exit(1);
  }
}
