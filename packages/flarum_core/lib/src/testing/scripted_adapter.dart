import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

typedef ScriptedReply = (int status, Object? body);

/// Answers requests with [replies], in order, and keeps what was asked.
class ScriptedAdapter implements HttpClientAdapter {
  ScriptedAdapter(this.replies);

  final List<ScriptedReply> replies;
  final requests = <RequestOptions>[];

  Dio dio() => Dio()..httpClientAdapter = this;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final (status, body) = replies[requests.length];
    requests.add(options);
    return ResponseBody.fromString(body == null ? '' : jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: ['application/vnd.api+json'],
    });
  }

  @override
  void close({bool force = false}) {}
}

/// A JSON:API error document.
Map<String, Object> errors(String status, String code, {String? pointer}) => {
      'errors': [
        {
          'status': status,
          'code': code,
          if (pointer != null) 'source': {'pointer': pointer},
        },
      ],
    };
