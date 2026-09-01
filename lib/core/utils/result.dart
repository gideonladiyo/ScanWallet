import '../error/failures.dart';

/// Generic Result type for all async boundaries (ARCHITECTURE.md §6.4).
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

class Failure<T> extends Result<T> {
  const Failure(this.failure);

  final AppFailure failure;
}

extension ResultX<T> on Result<T> {
  R fold<R>(
    R Function(AppFailure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    return switch (this) {
      Success(:final data) => onSuccess(data),
      Failure(:final failure) => onFailure(failure),
    };
  }
}
