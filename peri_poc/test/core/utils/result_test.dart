import 'package:flutter_test/flutter_test.dart';
import 'package:peri_poc/core/utils/result.dart';

void main() {
  group('Result', () {
    test('success result should have correct properties', () {
      const testValue = 'test_value';
      final result = Result<String>.success(testValue);

      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.value, testValue);
      expect(() => result.error, throwsStateError);
    });

    test('failure result should have correct properties', () {
      const testError = 'test_error';
      final result = Result<String>.failure(testError);

      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(() => result.value, throwsStateError);
      expect(result.error, testError);
    });

    test('map should transform success value', () {
      final result = Result<int>.success(5);
      final mappedResult = result.map((value) => value * 2);

      expect(mappedResult.isSuccess, true);
      expect(mappedResult.value, 10);
    });

    test('map should preserve failure', () {
      const testError = 'test_error';
      final result = Result<int>.failure(testError);
      final mappedResult = result.map((value) => value * 2);

      expect(mappedResult.isSuccess, false);
      expect(mappedResult.error, testError);
    });

    test('fold should call onSuccess for success result', () {
      final result = Result<int>.success(5);
      final folded = result.fold(
        (value) => 'Success: $value',
        (error) => 'Failure: $error',
      );

      expect(folded, 'Success: 5');
    });

    test('fold should call onFailure for failure result', () {
      final result = Result<int>.failure('Something went wrong');
      final folded = result.fold(
        (value) => 'Success: $value',
        (error) => 'Failure: $error',
      );

      expect(folded, 'Failure: Something went wrong');
    });

    test('onSuccess should call callback for success result', () {
      final result = Result<int>.success(5);
      var callbackCalled = false;
      var callbackValue = 0;

      result.onSuccess((value) {
        callbackCalled = true;
        callbackValue = value;
      });

      expect(callbackCalled, true);
      expect(callbackValue, 5);
    });

    test('onSuccess should not call callback for failure result', () {
      final result = Result<int>.failure('Something went wrong');
      var callbackCalled = false;

      result.onSuccess((value) {
        callbackCalled = true;
      });

      expect(callbackCalled, false);
    });

    test('onFailure should call callback for failure result', () {
      final result = Result<int>.failure('Something went wrong');
      var callbackCalled = false;
      var callbackError = '';

      result.onFailure((error) {
        callbackCalled = true;
        callbackError = error;
      });

      expect(callbackCalled, true);
      expect(callbackError, 'Something went wrong');
    });

    test('onFailure should not call callback for success result', () {
      final result = Result<int>.success(5);
      var callbackCalled = false;

      result.onFailure((error) {
        callbackCalled = true;
      });

      expect(callbackCalled, false);
    });

    test('toString should return formatted string for success result', () {
      final result = Result<int>.success(5);
      expect(result.toString(), 'Success: 5');
    });

    test('toString should return formatted string for failure result', () {
      final result = Result<int>.failure('Something went wrong');
      expect(result.toString(), 'Failure: Something went wrong');
    });

    test('equality should work for identical success results', () {
      final result1 = Result<int>.success(5);
      final result2 = Result<int>.success(5);

      expect(result1 == result2, true);
      expect(result1.hashCode == result2.hashCode, true);
    });

    test('equality should work for identical failure results', () {
      final result1 = Result<int>.failure('Something went wrong');
      final result2 = Result<int>.failure('Something went wrong');

      expect(result1 == result2, true);
      expect(result1.hashCode == result2.hashCode, true);
    });

    test('equality should fail for different success results', () {
      final result1 = Result<int>.success(5);
      final result2 = Result<int>.success(6);

      expect(result1 == result2, false);
    });

    test('equality should fail for different failure results', () {
      final result1 = Result<int>.failure('Something went wrong');
      final result2 = Result<int>.failure('Different error');

      expect(result1 == result2, false);
    });

    test('equality should fail for success vs failure results', () {
      final result1 = Result<int>.success(5);
      final result2 = Result<int>.failure('Something went wrong');

      expect(result1 == result2, false);
    });
  });
}
