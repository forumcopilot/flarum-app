/// One entry of a Flarum JSON:API `errors[]` array.
class FlarumApiError {
  const FlarumApiError({this.status, this.code, this.detail, this.pointer, this.parameter});

  factory FlarumApiError.fromJson(Map<String, dynamic> json) {
    final source = json['source'];
    return FlarumApiError(
      status: json['status']?.toString(),
      code: json['code']?.toString(),
      detail: json['detail']?.toString(),
      pointer: source is Map ? source['pointer']?.toString() : null,
      parameter: source is Map ? source['parameter']?.toString() : null,
    );
  }

  final String? status;

  /// Flarum's error code, e.g. `validation_error`, `not_authenticated`,
  /// `permission_denied`, `not_found`, `route_not_found`.
  final String? code;
  final String? detail;

  /// For validation errors, the JSON pointer of the offending field, e.g.
  /// `/data/attributes/title`. 1.x reports only the first failed rule; 2.0
  /// reports every invalid field, one error each.
  final String? pointer;

  /// For a rejected query parameter (2.0's HTTP 400), its name.
  final String? parameter;
}

/// A failed Flarum request. [statusCode] is null when no response arrived.
class FlarumApiException implements Exception {
  FlarumApiException(this.statusCode, this.errors, {this.method, this.path, this.cause});

  /// Builds the exception from a response body, reading `errors[]` when the
  /// body is a JSON:API error document.
  factory FlarumApiException.fromResponse(
    int? statusCode,
    Object? body, {
    String? method,
    String? path,
    Object? cause,
  }) {
    final rawErrors = body is Map ? body['errors'] : null;
    final errors = rawErrors is List
        ? [
            for (final error in rawErrors)
              if (error is Map) FlarumApiError.fromJson(error.cast<String, dynamic>()),
          ]
        : const <FlarumApiError>[];
    return FlarumApiException(statusCode, errors, method: method, path: path, cause: cause);
  }

  final int? statusCode;
  final List<FlarumApiError> errors;
  final String? method;
  final String? path;
  final Object? cause;

  bool get isNetworkError => statusCode == null;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidationError => statusCode == 422;

  /// The first error's detail or code, for logs and fallback messages.
  String get message {
    for (final error in errors) {
      final text = error.detail ?? error.code;
      if (text != null && text.isNotEmpty) return text;
    }
    return statusCode == null ? 'No response: $cause' : 'HTTP $statusCode';
  }

  @override
  String toString() => 'FlarumApiException(${method ?? ''} ${path ?? ''} → ${statusCode ?? 'no response'}: $message)';
}
