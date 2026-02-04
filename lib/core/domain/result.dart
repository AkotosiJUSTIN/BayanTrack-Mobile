import 'failures.dart';

/// Result type for explicit error handling.
///
/// Use instead of throwing exceptions. Allows pattern matching on success/failure.
///
/// Example:
/// ```dart
/// Future<Result<User>> login(String email, String password) async {
///   try {
///     final user = await api.login(email, password);
///     return Success(user);
///   } catch (e) {
///     return Failure(ErrorMapper.mapException(e));
///   }
/// }
///
/// // Usage
/// final result = await loginUseCase(email, password);
/// result.when(
///   success: (user) => print('Hello ${user.name}'),
///   failure: (error) => showError(error.message),
/// );
/// ```
sealed class Result<T> {
  const Result();

  /// Pattern match on result
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  });

  /// Map success value to another type
  Result<R> map<R>(R Function(T data) mapper);

  /// Map success value to another Result (flatMap)
  Result<R> flatMap<R>(Result<R> Function(T data) mapper);

  /// Get data or null
  T? get dataOrNull;

  /// Get failure or null
  Failure? get failureOrNull;

  /// Check if success
  bool get isSuccess;

  /// Check if failure
  bool get isFailure;
}

/// Success result containing data
class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) => success(data);

  @override
  Result<R> map<R>(R Function(T data) mapper) => Success(mapper(data));

  @override
  Result<R> flatMap<R>(Result<R> Function(T data) mapper) => mapper(data);

  @override
  T? get dataOrNull => data;

  @override
  Failure? get failureOrNull => null;

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;

  @override
  String toString() => 'Success($data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// Failure result containing error
class Err<T> extends Result<T> {
  final Failure failure;

  const Err(this.failure);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) => failure(this.failure);

  @override
  Result<R> map<R>(R Function(T data) mapper) => Err(failure);

  @override
  Result<R> flatMap<R>(Result<R> Function(T data) mapper) => Err(failure);

  @override
  T? get dataOrNull => null;

  @override
  Failure? get failureOrNull => failure;

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;

  @override
  String toString() => 'Err($failure)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Err<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}

/// Extension for async Result operations
extension ResultFuture<T> on Future<Result<T>> {
  /// Map success value asynchronously
  Future<Result<R>> mapAsync<R>(R Function(T data) mapper) async {
    final result = await this;
    return result.map(mapper);
  }

  /// FlatMap asynchronously
  Future<Result<R>> flatMapAsync<R>(
    Future<Result<R>> Function(T data) mapper,
  ) async {
    final result = await this;
    return result.when(
      success: (data) => mapper(data),
      failure: (f) => Future.value(Err(f)),
    );
  }
}
