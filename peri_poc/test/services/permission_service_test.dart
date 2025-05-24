import 'package:flutter_test/flutter_test.dart';
import 'package:peri_poc/services/permission_service.dart';

void main() {
  group('PermissionService', () {
    test('PermissionService should be creatable', () {
      final service = PermissionService();
      expect(service, isA<PermissionService>());
    });

    test('should have correct initial state', () {
      final service = PermissionService();
      expect(service.hasMicrophonePermission(), false);
      expect(service.getPermissionStatus(), PermissionStatus.denied);
    });
  });
}
