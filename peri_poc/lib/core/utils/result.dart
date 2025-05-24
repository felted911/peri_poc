/// A type-safe utility class that represents a result which can be either a success or a failure.
///
/// The Result class is designed to handle operations that might fail in a type-safe way,
/// providing a cleaner alternative to throwing exceptions or returning nullable values.
class Result<T> {
  /// The success value, if this is a success result
  final T? _value;

  /// The error message, if this is a failure result
  final String? _error;

  /// Whether this result represents a success
  final bool isSuccess;

  /// Private constructor for success result
  Result.success(T value) : _value = value, _error = null, isSuccess = true;

  /// Private constructor for failure result
  Result.failure(String error)
    : _value = null,
      _error = error,
      isSuccess = false;

  /// Whether this result represents a failure
  bool get isFailure => !isSuccess;

  /// Get the success value
  ///
  /// Throws a [StateError] if called on a failure result
  T get value {
    if (isFailure) {
      throw StateError('Cannot get value from a failure result: $_error');
    }
    return _value as T;
  }

  /// Get the error message
  ///
  /// Throws a [StateError] if called on a success result
  String get error {
    if (isSuccess) {
      throw StateError('Cannot get error from a success result');
    }
    return _error!;
  }

  /// Transforms a success value using the given mapping function
  ///
  /// If this is a failure result, returns a new failure result with the same error
  Result<R> map<R>(R Function(T) mapper) {
    if (isSuccess) {
      return Result.success(mapper(value));
    } else {
      return Result.failure(error);
    }
  }

  /// Executes one of the provided functions based on whether this result is a success or failure
  R fold<R>(R Function(T) onSuccess, R Function(String) onFailure) {
    if (isSuccess) {
      return onSuccess(value);
    } else {
      return onFailure(error);
    }
  }

  /// Executes a callback if this is a success result
  void onSuccess(void Function(T) callback) {
    if (isSuccess) {
      callback(value);
    }
  }

  /// Executes a callback if this is a failure result
  void onFailure(void Function(String) callback) {
    if (isFailure) {
      callback(error);
    }
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'Success: $value';
    } else {
      return 'Failure: $error';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Result<T>) return false;

    if (isSuccess != other.isSuccess) return false;
    if (isSuccess) {
      return value == other.value;
    } else {
      return error == other.error;
    }
  }

  @override
  int get hashCode {
    if (isSuccess) {
      return value.hashCode;
    } else {
      return error.hashCode;
    }
  }
}
