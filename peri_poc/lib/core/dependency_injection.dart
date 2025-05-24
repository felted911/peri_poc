import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:peri_poc/interfaces/i_voice_service.dart';
import 'package:peri_poc/interfaces/i_storage_service.dart';
import 'package:peri_poc/interfaces/i_template_service.dart';
import 'package:peri_poc/services/permission_service.dart';
import 'package:peri_poc/services/voice_service_impl.dart';
import 'package:peri_poc/services/storage_service_impl.dart';
import 'package:peri_poc/services/template_service_impl.dart';
import 'package:peri_poc/services/voice_interaction_coordinator.dart';
import 'package:peri_poc/services/voice_command_parser.dart';

/// Global service locator instance
final GetIt serviceLocator = GetIt.instance;

/// Initializes all dependencies for the application
///
/// This function must be called before the app starts to ensure
/// all required services are properly registered and initialized.
Future<void> initializeDependencies() async {
  // Initialize SharedPreferences instance
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register services
  serviceLocator.registerSingleton<PermissionService>(PermissionService());
  serviceLocator.registerSingleton<IVoiceService>(VoiceServiceImpl());
  
  // Register storage service
  final storageService = StorageServiceImpl();
  await storageService.initialize();
  serviceLocator.registerSingleton<IStorageService>(storageService);
  
  // Register template service
  final templateService = TemplateServiceImpl();
  await templateService.initialize();
  serviceLocator.registerSingleton<ITemplateService>(templateService);
  
  // Register voice command parser
  serviceLocator.registerSingleton<VoiceCommandParser>(VoiceCommandParser());
  
  // Register voice interaction coordinator
  serviceLocator.registerSingleton<VoiceInteractionCoordinator>(
    VoiceInteractionCoordinator(
      voiceService: serviceLocator<IVoiceService>(),
      storageService: serviceLocator<IStorageService>(),
      templateService: serviceLocator<ITemplateService>(),
      commandParser: serviceLocator<VoiceCommandParser>(),
    ),
  );

  // Mark initialization as complete
  serviceLocator.registerSingleton<bool>(true, instanceName: 'initialized');
}

/// Checks if dependency injection has been initialized
bool isDependencyInjectionInitialized() {
  try {
    return serviceLocator.get<bool>(instanceName: 'initialized');
  } catch (_) {
    return false;
  }
}

/// Convenience getters for commonly used services
extension ServiceLocatorExtensions on GetIt {
  IVoiceService get voiceService => get<IVoiceService>();
  IStorageService get storageService => get<IStorageService>();
  ITemplateService get templateService => get<ITemplateService>();
  PermissionService get permissionService => get<PermissionService>();
  SharedPreferences get sharedPreferences => get<SharedPreferences>();
  VoiceInteractionCoordinator get voiceInteractionCoordinator => get<VoiceInteractionCoordinator>();
  VoiceCommandParser get voiceCommandParser => get<VoiceCommandParser>();
}
