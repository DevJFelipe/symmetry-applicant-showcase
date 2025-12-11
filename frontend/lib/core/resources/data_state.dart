import 'package:news_app_clean_architecture/core/error/app_exception.dart';

/// Represents the state of data operations.
/// Uses [AppException] for errors to maintain Clean Architecture principles
/// by not exposing implementation details (like Dio) to domain/presentation layers.
sealed class DataState<T> {
  final T? data;
  final AppException? error;

  const DataState({this.data, this.error});
  
  /// Returns true if the state is successful with data
  bool get isSuccess => this is DataSuccess<T>;
  
  /// Returns true if the state is a failure with an error
  bool get isFailure => this is DataFailed<T>;
  
  /// Transforms the data if successful, returns failure unchanged
  DataState<R> map<R>(R Function(T data) transform) {
    if (this is DataSuccess<T> && data != null) {
      return DataSuccess(transform(data as T));
    }
    return DataFailed(error ?? const UnknownException());
  }
  
  /// Executes appropriate callback based on state
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) {
    if (this is DataSuccess<T> && data != null) {
      return success(data as T);
    }
    return failure(error ?? const UnknownException());
  }
}

/// Successful data state with data
final class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

/// Failed data state with error
final class DataFailed<T> extends DataState<T> {
  const DataFailed(AppException error) : super(error: error);
}

