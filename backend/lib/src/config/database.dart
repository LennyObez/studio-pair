import 'package:logging/logging.dart';
import 'package:postgres/postgres.dart';

/// Database wrapper providing connection pool management and query helpers.
class Database {
  final String connectionUrl;
  final int poolSize;
  final Logger _log = Logger('Database');

  late final Pool<dynamic> _pool;
  bool _initialized = false;

  Database({required this.connectionUrl, this.poolSize = 10});

  /// Initializes the connection pool.
  Future<void> initialize() async {
    if (_initialized) return;

    _log.info('Connecting to database...');

    final endpoint = _parseConnectionUrl(connectionUrl);

    _pool = Pool.withEndpoints(
      [endpoint],
      settings: PoolSettings(
        maxConnectionCount: poolSize,
        // TODO: Configure SSL properly per environment (require/verifyFull for production)
        sslMode: SslMode.disable,
      ),
    );

    // Test the connection
    await healthCheck();

    _initialized = true;
    _log.info('Database connected (pool size: $poolSize)');
  }

  /// Parses a postgres:// connection URL into an Endpoint.
  Endpoint _parseConnectionUrl(String url) {
    final uri = Uri.parse(url);
    return Endpoint(
      host: uri.host,
      port: uri.port != 0 ? uri.port : 5432,
      database: uri.path.replaceFirst('/', ''),
      username: uri.userInfo.split(':').first,
      password: uri.userInfo.contains(':')
          ? uri.userInfo.split(':').last
          : null,
    );
  }

  /// Executes a query and returns all result rows.
  Future<Result> query(String sql, {Map<String, dynamic>? parameters}) async {
    return _pool.execute(Sql.named(sql), parameters: parameters ?? {});
  }

  /// Executes a query and returns the first row, or null if empty.
  Future<ResultRow?> queryOne(
    String sql, {
    Map<String, dynamic>? parameters,
  }) async {
    final result = await query(sql, parameters: parameters);
    return result.isEmpty ? null : result.first;
  }

  /// Executes a statement (INSERT, UPDATE, DELETE) and returns affected rows.
  Future<int> execute(String sql, {Map<String, dynamic>? parameters}) async {
    final result = await query(sql, parameters: parameters);
    return result.affectedRows;
  }

  /// Runs a function within a database transaction.
  Future<T> transaction<T>(Future<T> Function(TxSession session) fn) async {
    return _pool.runTx(fn);
  }

  /// Checks if the database connection is healthy.
  Future<bool> healthCheck() async {
    try {
      final result = await _pool.execute(Sql.named('SELECT 1 AS ok'));
      return result.isNotEmpty;
    } catch (e) {
      _log.severe('Database health check failed', e);
      return false;
    }
  }

  /// Closes all connections in the pool.
  Future<void> dispose() async {
    if (!_initialized) return;
    _log.info('Closing database connections...');
    await _pool.close();
    _initialized = false;
    _log.info('Database connections closed.');
  }
}

/// Extension on [TxSession] to provide named-parameter query helpers.
extension TxSessionExtension on TxSession {
  /// Executes a query within this transaction and returns all rows.
  Future<Result> query(String sql, {Map<String, dynamic>? parameters}) {
    return execute(Sql.named(sql), parameters: parameters ?? {});
  }

  /// Executes a query within this transaction and returns the first row, or null.
  Future<ResultRow?> queryOne(
    String sql, {
    Map<String, dynamic>? parameters,
  }) async {
    final result = await query(sql, parameters: parameters);
    return result.isEmpty ? null : result.first;
  }
}
