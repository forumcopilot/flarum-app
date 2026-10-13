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

  /// The forum's posting throttle refused it: one post every 10 seconds by default.
  bool get isThrottled => statusCode == 429;

  /// An upload the forum refused as too big. fof/upload's own limit (2048 kB by default) is a 422
  /// naming it ("Uploads over 2048 kb are not accepted."); a request past PHP's `post_max_size`
  /// arrives with no files, a 400 that names it too; past PHP's `upload_max_filesize` it is a 413
  /// `max_upload_file_size_ini`, and past the web server's limit a 413 page of HTML.
  bool get isTooLarge =>
      statusCode == 413 ||
      errors.any((e) => e.code == 'fof-upload.no_files_made_it_to_upload') ||
      (isValidationError && _namedLimit != null);

  /// For a refusal that [isTooLarge], the most the forum takes, in bytes: the limit it names, else
  /// the default of whatever refused it (2 MB for PHP's, 1 MB for nginx's). Null otherwise.
  int? get uploadLimit {
    if (!isTooLarge) return null;
    if (_namedLimit case final limit?) return limit;
    return errors.any((e) => e.code == 'fof-upload.max_upload_file_size_ini') ? 2 << 20 : 1 << 20;
  }

  int? get _namedLimit {
    for (final error in errors) {
      final kb = RegExp(r'(\d+)\s*kb\b', caseSensitive: false).firstMatch(error.detail ?? '');
      if (kb != null) return int.parse(kb.group(1)!) * 1024;
    }
    return null;
  }

  /// Every reason the forum gave, one a line: 2.0 names each invalid field, 1.x the first rule
  /// that failed. [message] when it gave none.
  String get reasons {
    final details = [for (final error in errors) if (error.detail?.isNotEmpty ?? false) error.detail!];
    return details.isEmpty ? message : details.join('\n');
  }

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
