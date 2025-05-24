import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:peri_poc/core/dependency_injection.dart';
import 'package:peri_poc/interfaces/i_voice_service.dart';
import 'package:peri_poc/services/permission_service.dart';
import 'package:peri_poc/interfaces/i_storage_service.dart';

// Create mock classes
class MockVoiceService extends Mock implements IVoiceService {}

class MockPermissionService extends Mock implements PermissionService {}

class MockStorageService extends Mock implements IStorageService {}

// Setup test dependencies
void setupTestDependencies() {
  final GetIt sl = serviceLocator;

  // Clear any existing registrations
  if (sl.isRegistered<IVoiceService>()) {
    sl.unregister<IVoiceService>();
  }

  if (sl.isRegistered<PermissionService>()) {
    sl.unregister<PermissionService>();
  }

  if (sl.isRegistered<IStorageService>()) {
    sl.unregister<IStorageService>();
  }

  // Register mock services
  sl.registerSingleton<IVoiceService>(MockVoiceService());
  sl.registerSingleton<PermissionService>(MockPermissionService());
  sl.registerSingleton<IStorageService>(MockStorageService());

  // Mark initialization as complete
  if (!sl.isRegistered<bool>(instanceName: 'initialized')) {
    sl.registerSingleton<bool>(true, instanceName: 'initialized');
  } else {
    sl.unregister<bool>(instanceName: 'initialized');
    sl.registerSingleton<bool>(true, instanceName: 'initialized');
  }
}
