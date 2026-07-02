import '../../../Data/core/api_error_model.dart';

abstract class ApiResult<T> {
  const ApiResult();
}

class Success<T> extends ApiResult<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends ApiResult<T> {
  final ApiErrorModel error;
  const Failure(this.error);
}
