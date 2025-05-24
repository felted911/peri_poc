import 'dart:async';

import 'package:flutter/foundation.dart';
// import 'package:voice_to_text/voice_to_text.dart';

import 'package:peri_poc/core/utils/result.dart';

/// Service to handle permission requests and status for the app
class PermissionService {
  /// Flag indicating if microphone permission has been granted
  bool _hasMicrophonePermission = false;

  /// Flag indicating if the service has been initialized
  bool _isInitialized = false;

  /// Stream controller for permission status changes
  final StreamController<PermissionStatus> _permissionStatusController =
      StreamController<PermissionStatus>.broadcast();

  /// Stream of permission status changes
  Stream<PermissionStatus> get permissionStatusStream =>
      _permissionStatusController.stream;

  /// Creates a new PermissionService instance
  PermissionService();

  /// Initialize the permission service
  ///
  /// This should be called before any other methods to set up
  /// the permission service and check initial permission status.
  ///
  /// Returns a [Result] indicating success or failure with an error message
  Future<Result<void>> initialize() async {
    if (_isInitialized) {
      return Result.success(null);
    }

    try {
      // TODO: Implement actual permission checking when voice functionality is restored
      _hasMicrophonePermission = true; // Temporary: assume permission granted

      _updatePermissionStatus(PermissionStatus.granted);

      _isInitialized = true;
      return Result.success(null);
    } catch (e) {
      debugPrint('Permission service initialization error: $e');
      _updatePermissionStatus(PermissionStatus.denied);
      return Result.failure('Permission service initialization failed: $e');
    }
  }

  /// Request microphone permission from the user
  ///
  /// Returns a [Result] indicating success or failure with an error message,
  /// and a boolean indicating if permission was granted
  Future<Result<bool>> requestMicrophonePermission() async {
    if (!_isInitialized) {
      return Result.failure('Permission service not initialized');
    }

    try {
      // TODO: Implement actual permission request when voice functionality is restored
      _hasMicrophonePermission = true; // Temporary: assume permission granted

      _updatePermissionStatus(PermissionStatus.granted);

      return Result.success(_hasMicrophonePermission);
    } catch (e) {
      debugPrint('Request microphone permission error: $e');
      _updatePermissionStatus(PermissionStatus.denied);
      return Result.failure('Request microphone permission failed: $e');
    }
  }

  /// Check if microphone permission has been granted
  ///
  /// Returns true if permission is granted, false otherwise
  bool hasMicrophonePermission() {
    return _hasMicrophonePermission;
  }

  /// Get the current overall permission status
  ///
  /// Currently only tracks microphone permission, but could be
  /// expanded to include other permissions in the future
  PermissionStatus getPermissionStatus() {
    return _hasMicrophonePermission
        ? PermissionStatus.granted
        : PermissionStatus.denied;
  }

  /// Updates the permission status and notifies listeners
  void _updatePermissionStatus(PermissionStatus status) {
    _permissionStatusController.add(status);
  }

  /// Dispose of any resources used by the permission service
  ///
  /// This should be called when the permission service is no longer needed
  /// to release any held resources.
  Future<void> dispose() async {
    await _permissionStatusController.close();
  }
}

/// Permission status enum
enum PermissionStatus {
  /// Permission has been granted
  granted,

  /// Permission has been denied
  denied,

  /// Permission is in a restricted state (e.g., parental controls)
  restricted,

  /// Permission status is unknown (e.g., not yet requested)
  unknown,
}
