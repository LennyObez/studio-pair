import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'config/app_config.dart';
import 'config/database.dart';
import 'middleware/auth_middleware.dart';
import 'middleware/rate_limiter.dart';
import 'middleware/space_middleware.dart';
import 'modules/activities/activities_controller.dart';
import 'modules/activities/activities_repository.dart';
import 'modules/activities/activities_service.dart';
import 'modules/auth/auth_controller.dart';
import 'modules/auth/auth_repository.dart';
import 'modules/auth/auth_service.dart';
import 'modules/calendar/calendar_controller.dart';
import 'modules/calendar/calendar_repository.dart';
import 'modules/calendar/calendar_service.dart';
import 'modules/cards/cards_controller.dart';
import 'modules/cards/cards_repository.dart';
import 'modules/cards/cards_service.dart';
import 'modules/charter/charter_controller.dart';
import 'modules/charter/charter_repository.dart';
import 'modules/charter/charter_service.dart';
import 'modules/entitlements/entitlements_controller.dart';
import 'modules/entitlements/entitlements_repository.dart';
import 'modules/entitlements/entitlements_service.dart';
import 'modules/export/export_controller.dart';
import 'modules/export/export_repository.dart';
import 'modules/export/export_service.dart';
import 'modules/files/files_controller.dart';
import 'modules/files/files_repository.dart';
import 'modules/files/files_service.dart';
import 'modules/finances/finances_controller.dart';
import 'modules/finances/finances_repository.dart';
import 'modules/finances/finances_service.dart';
import 'modules/grocery/grocery_controller.dart';
import 'modules/grocery/grocery_repository.dart';
import 'modules/grocery/grocery_service.dart';
import 'modules/health/health_controller.dart';
import 'modules/health/health_repository.dart';
import 'modules/health/health_service.dart';
import 'modules/location/location_controller.dart';
import 'modules/location/location_repository.dart';
import 'modules/location/location_service.dart';
import 'modules/memories/memories_controller.dart';
import 'modules/memories/memories_repository.dart';
import 'modules/memories/memories_service.dart';
import 'modules/messaging/messaging_controller.dart';
import 'modules/messaging/messaging_repository.dart';
import 'modules/messaging/messaging_service.dart';
import 'modules/notifications/notifications_controller.dart';
import 'modules/notifications/notifications_repository.dart';
import 'modules/notifications/notifications_service.dart';
import 'modules/polls/polls_controller.dart';
import 'modules/polls/polls_repository.dart';
import 'modules/polls/polls_service.dart';
import 'modules/reminders/reminders_controller.dart';
import 'modules/reminders/reminders_repository.dart';
import 'modules/reminders/reminders_service.dart';
import 'modules/spaces/spaces_controller.dart';
import 'modules/spaces/spaces_repository.dart';
import 'modules/spaces/spaces_service.dart';
import 'modules/tasks/tasks_controller.dart';
import 'modules/tasks/tasks_repository.dart';
import 'modules/tasks/tasks_service.dart';
import 'modules/vault/vault_controller.dart';
import 'modules/vault/vault_repository.dart';
import 'modules/vault/vault_service.dart';
import 'modules/websocket/websocket_handler.dart';
import 'services/enrichment_service.dart';
import 'services/entitlement_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/websocket_service.dart';
import 'utils/jwt_utils.dart';
import 'utils/response_utils.dart';

/// Main application class that wires together all components.
///
/// Creates database connections, repositories, services, controllers,
/// and builds the router with all API routes.
class Application {
  final AppConfig config;
  final Database _db;
  final JwtUtils _jwtUtils;
  final RateLimiter _rateLimiter;
  final SpaceMiddleware _spaceMiddleware;

  // Services
  final NotificationService notificationService;
  final StorageService storageService;
  final EntitlementService entitlementService;
  final WebSocketService webSocketService;

  // Controllers
  final AuthController _authController;
  final SpacesController _spacesController;
  final NotificationsController _notificationsController;
  final ActivitiesController _activitiesController;
  final CalendarController _calendarController;
  final CardsController _cardsController;
  final VaultController _vaultController;
  final FinancesController _financesController;
  final MessagingController _messagingController;
  final HealthController _healthController;
  final TasksController _tasksController;
  final RemindersController _remindersController;
  final FilesController _filesController;
  final MemoriesController _memoriesController;
  final CharterController _charterController;
  final GroceryController _groceryController;
  final PollsController _pollsController;
  final LocationController _locationController;
  final ExportController _exportController;
  final EntitlementsController _entitlementsController;

  final Logger _log = Logger('Application');

  Application._({
    required this.config,
    required Database db,
    required JwtUtils jwtUtils,
    required RateLimiter rateLimiter,
    required SpaceMiddleware spaceMiddleware,
    required this.notificationService,
    required this.storageService,
    required this.entitlementService,
    required this.webSocketService,
    required AuthController authController,
    required SpacesController spacesController,
    required NotificationsController notificationsController,
    required ActivitiesController activitiesController,
    required CalendarController calendarController,
    required CardsController cardsController,
    required VaultController vaultController,
    required FinancesController financesController,
    required MessagingController messagingController,
    required HealthController healthController,
    required TasksController tasksController,
    required RemindersController remindersController,
    required FilesController filesController,
    required MemoriesController memoriesController,
    required CharterController charterController,
    required GroceryController groceryController,
    required PollsController pollsController,
    required LocationController locationController,
    required ExportController exportController,
    required EntitlementsController entitlementsController,
  }) : _db = db,
       _jwtUtils = jwtUtils,
       _rateLimiter = rateLimiter,
       _spaceMiddleware = spaceMiddleware,
       _authController = authController,
       _spacesController = spacesController,
       _notificationsController = notificationsController,
       _activitiesController = activitiesController,
       _calendarController = calendarController,
       _cardsController = cardsController,
       _vaultController = vaultController,
       _financesController = financesController,
       _messagingController = messagingController,
       _healthController = healthController,
       _tasksController = tasksController,
       _remindersController = remindersController,
       _filesController = filesController,
       _memoriesController = memoriesController,
       _charterController = charterController,
       _groceryController = groceryController,
       _pollsController = pollsController,
       _locationController = locationController,
       _exportController = exportController,
       _entitlementsController = entitlementsController;

  /// Creates and initializes the application.
  static Future<Application> create(AppConfig config) async {
    final log = Logger('Application');

    // Database
    log.info('Initializing database...');
    final db = Database(
      connectionUrl: config.databaseUrl,
      poolSize: config.databasePoolSize,
    );
    await db.initialize();

    // Utilities
    final jwtUtils = JwtUtils(config);

    // Middleware
    final rateLimiter = RateLimiter();
    final spaceMiddleware = SpaceMiddleware(db);

    // Services
    final notificationService = NotificationService(db, config);
    final storageService = StorageService(config);
    await storageService.initialize();
    final entitlementService = EntitlementService(db);
    final webSocketService = WebSocketService();
    final enrichmentService = EnrichmentService(config);

    // Repositories
    final authRepo = AuthRepository(db);
    final spacesRepo = SpacesRepository(db);
    final tasksRepo = TasksRepository(db);
    final activitiesRepo = ActivitiesRepository(db);
    final groceryRepo = GroceryRepository(db);
    final remindersRepo = RemindersRepository(db);
    final locationRepo = LocationRepository(db);
    final calendarRepo = CalendarRepository(db);
    final messagingRepo = MessagingRepository(db);
    final financesRepo = FinancesRepository(db);
    final cardsRepo = CardsRepository(db);
    final vaultRepo = VaultRepository(db);
    final filesRepo = FilesRepository(db);
    final memoriesRepo = MemoriesRepository(db);
    final charterRepo = CharterRepository(db);
    final pollsRepo = PollsRepository(db);
    final healthRepo = HealthRepository(db);
    final notificationsRepo = NotificationsRepository(db);

    // Services (business logic)
    final authService = AuthService(
      authRepo,
      jwtUtils,
      config,
      notificationService,
    );
    final spacesService = SpacesService(
      spacesRepo,
      entitlementService,
      notificationService,
    );
    final calendarService = CalendarService(
      calendarRepo,
      spacesRepo,
      notificationService,
    );
    final tasksService = TasksService(
      tasksRepo,
      spacesRepo,
      notificationService,
      calendarService,
    );
    final activitiesService = ActivitiesService(
      activitiesRepo,
      notificationService,
      calendarService: calendarService,
      tasksRepo: tasksRepo,
    );
    final groceryService = GroceryService(groceryRepo, notificationService);
    final remindersService = RemindersService(
      remindersRepo,
      notificationService,
    );
    final locationService = LocationService(
      locationRepo,
      spacesRepo,
      notificationService,
    );
    final messagingService = MessagingService(
      messagingRepo,
      spacesRepo,
      notificationService,
      webSocketService: webSocketService,
    );
    final financesService = FinancesService(
      financesRepo,
      spacesRepo,
      calendarService,
      notificationService,
    );
    final cardsService = CardsService(
      cardsRepo,
      spacesRepo,
      notificationService,
    );
    final vaultService = VaultService(
      vaultRepo,
      spacesRepo,
      notificationService,
    );
    final filesService = FilesService(filesRepo, spacesRepo);
    final memoriesService = MemoriesService(memoriesRepo, spacesRepo);
    final charterService = CharterService(
      charterRepo,
      spacesRepo,
      notificationService,
    );
    final pollsService = PollsService(pollsRepo, spacesRepo);
    final healthService = HealthService(healthRepo, spacesRepo);

    final notificationsModuleService = NotificationsModuleService(
      notificationsRepo,
    );

    // Export
    final exportRepo = ExportRepository(db);
    final exportService = ExportService(exportRepo);

    // Entitlements
    final entitlementsRepo = EntitlementsRepository(db);
    final entitlementsSubscriptionService = EntitlementsSubscriptionService(
      entitlementsRepo,
      config,
    );

    // Controllers
    final authController = AuthController(authService);
    final spacesController = SpacesController(spacesService);
    final notificationsController = NotificationsController(
      notificationsModuleService,
      notificationService,
      config,
    );
    final activitiesController = ActivitiesController(
      activitiesService,
      enrichmentService: enrichmentService,
    );
    final calendarController = CalendarController(calendarService);
    final cardsController = CardsController(cardsService);
    final vaultController = VaultController(vaultService);
    final financesController = FinancesController(financesService);
    final messagingController = MessagingController(messagingService);
    final healthController = HealthController(healthService);
    final tasksController = TasksController(tasksService);
    final remindersController = RemindersController(remindersService);
    final filesController = FilesController(filesService);
    final memoriesController = MemoriesController(memoriesService);
    final charterController = CharterController(charterService);
    final groceryController = GroceryController(groceryService);
    final pollsController = PollsController(pollsService);
    final locationController = LocationController(locationService);
    final exportController = ExportController(exportService);
    final entitlementsController = EntitlementsController(
      entitlementsRepo,
      entitlementsSubscriptionService,
      entitlementService,
    );

    log.info('Application initialized successfully');

    return Application._(
      config: config,
      db: db,
      jwtUtils: jwtUtils,
      rateLimiter: rateLimiter,
      spaceMiddleware: spaceMiddleware,
      notificationService: notificationService,
      storageService: storageService,
      entitlementService: entitlementService,
      webSocketService: webSocketService,
      authController: authController,
      spacesController: spacesController,
      notificationsController: notificationsController,
      activitiesController: activitiesController,
      calendarController: calendarController,
      cardsController: cardsController,
      vaultController: vaultController,
      financesController: financesController,
      messagingController: messagingController,
      healthController: healthController,
      tasksController: tasksController,
      remindersController: remindersController,
      filesController: filesController,
      memoriesController: memoriesController,
      charterController: charterController,
      groceryController: groceryController,
      pollsController: pollsController,
      locationController: locationController,
      exportController: exportController,
      entitlementsController: entitlementsController,
    );
  }

  /// The authentication middleware.
  Middleware get authMiddleware => createAuthMiddleware(_jwtUtils);

  /// The rate limiter middleware.
  Middleware get rateLimiterMiddleware => _rateLimiter.middleware;

  /// Builds and returns the main router with all API routes mounted.
  Router get router {
    final router = Router();

    // Health check endpoints (no auth required)
    router.get('/api/v1/health', _healthCheck);
    router.get('/api/v1/health/ready', _readinessCheck);

    // WebSocket endpoint (token in query param)
    router.get(
      '/api/v1/ws',
      createAuthenticatedWebSocketHandler(_jwtUtils, webSocketService),
    );

    // Auth routes (mostly public)
    router.mount('/api/v1/auth/', _authController.router.call);

    // Space routes
    router.mount('/api/v1/spaces/', _spacesController.router.call);

    // Notification routes
    router.mount(
      '/api/v1/notifications/',
      _notificationsController.router.call,
    );

    // Space-scoped routes (these require space membership)
    // Activities
    router.mount(
      '/api/v1/spaces/<spaceId>/activities/',
      _withSpaceMiddleware(_activitiesController.router),
    );

    // Calendar
    router.mount(
      '/api/v1/spaces/<spaceId>/calendar/',
      _withSpaceMiddleware(_calendarController.router),
    );

    // Cards (personal, but shareable within spaces)
    router.mount('/api/v1/cards/', _cardsController.router.call);

    // Vault
    router.mount(
      '/api/v1/spaces/<spaceId>/vault/',
      _withSpaceMiddleware(_vaultController.router),
    );

    // Finances
    router.mount(
      '/api/v1/spaces/<spaceId>/finances/',
      _withSpaceMiddleware(_financesController.router),
    );

    // Messaging
    router.mount(
      '/api/v1/spaces/<spaceId>/messaging/',
      _withSpaceMiddleware(_messagingController.router),
    );

    // Health & Wellness
    router.mount('/api/v1/health-wellness/', _healthController.router.call);

    // Tasks
    router.mount(
      '/api/v1/spaces/<spaceId>/tasks/',
      _withSpaceMiddleware(_tasksController.router),
    );

    // Reminders
    router.mount('/api/v1/reminders/', _remindersController.router.call);

    // Files
    router.mount(
      '/api/v1/spaces/<spaceId>/files/',
      _withSpaceMiddleware(_filesController.router),
    );

    // Memories
    router.mount(
      '/api/v1/spaces/<spaceId>/memories/',
      _withSpaceMiddleware(_memoriesController.router),
    );

    // Charter
    router.mount(
      '/api/v1/spaces/<spaceId>/charter/',
      _withSpaceMiddleware(_charterController.router),
    );

    // Grocery
    router.mount(
      '/api/v1/spaces/<spaceId>/grocery/',
      _withSpaceMiddleware(_groceryController.router),
    );

    // Polls
    router.mount(
      '/api/v1/spaces/<spaceId>/polls/',
      _withSpaceMiddleware(_pollsController.router),
    );

    // Location
    router.mount(
      '/api/v1/spaces/<spaceId>/location/',
      _withSpaceMiddleware(_locationController.router),
    );

    // Entitlements (space-scoped)
    router.mount(
      '/api/v1/spaces/<spaceId>/entitlements/',
      _withSpaceMiddleware(_entitlementsController.router),
    );

    // Webhooks (public, no auth)
    router.mount(
      '/api/v1/webhooks/',
      _entitlementsController.webhookRouter.call,
    );

    // Data Export (GDPR)
    router.mount('/api/v1/export/', _exportController.router.call);

    // Catch-all for unmatched routes
    router.all('/<ignored|.*>', _notFound);

    return router;
  }

  /// Wraps a router with space authorization middleware.
  Handler _withSpaceMiddleware(Router innerRouter) {
    return const Pipeline()
        .addMiddleware(_spaceMiddleware.middleware)
        .addHandler(innerRouter.call);
  }

  /// GET /api/v1/health
  ///
  /// Basic health check.
  Future<Response> _healthCheck(Request request) async {
    return jsonResponse({
      'status': 'ok',
      'version': '0.1.0',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// GET /api/v1/health/ready
  ///
  /// Readiness check that verifies database connectivity.
  Future<Response> _readinessCheck(Request request) async {
    final dbHealthy = await _db.healthCheck();

    if (!dbHealthy) {
      return errorResponse(
        'Database is not available',
        statusCode: 503,
        code: 'SERVICE_UNAVAILABLE',
      );
    }

    return jsonResponse({
      'status': 'ready',
      'checks': {'database': 'ok'},
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// Catch-all handler for unmatched routes.
  Future<Response> _notFound(Request request) async {
    return notFoundResponse(
      'No route found for ${request.method} /${request.url.path}',
    );
  }

  /// Disposes all resources held by the application.
  Future<void> dispose() async {
    _log.info('Disposing application resources...');
    webSocketService.dispose();
    _rateLimiter.dispose();
    await _db.dispose();
    _log.info('Application disposed.');
  }
}
