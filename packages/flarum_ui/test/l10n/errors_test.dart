import 'package:dio/dio.dart';
import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_ui/flarum_ui.dart';
import 'package:flarum_ui/l10n/flarum_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a failure is said in words the reader can act on, never as the exception', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: FlarumLocalizations.localizationsDelegates,
      home: Builder(builder: (c) {
        context = c;
        return const SizedBox();
      }),
    ));
    DioException dio(DioExceptionType type) => DioException(requestOptions: RequestOptions(path: '/api'), type: type);
    FlarumApiException refused(int status, [List<FlarumApiError> errors = const []]) => FlarumApiException(status, errors);

    expect(describeError(context, FlarumApiException(null, const [], cause: dio(DioExceptionType.connectionError))),
        "Couldn't reach the forum. Check your connection and try again.");
    expect(describeError(context, FlarumApiException(null, const [], cause: dio(DioExceptionType.receiveTimeout))),
        'The forum took too long to answer. Please try again.');
    expect(describeError(context, refused(403)), startsWith("The forum's firewall blocked the app."),
        reason: "a 403 without Flarum's errors is a firewall's page");
    expect(describeError(context, refused(403, const [FlarumApiError(code: 'permission_denied')])),
        "You don't have permission to do that.");
    expect(describeError(context, refused(422, const [FlarumApiError(code: 'validation_error', detail: 'The title must be at least 3 characters.')])),
        'The title must be at least 3 characters.');
    expect(describeError(context, refused(404, const [FlarumApiError(code: 'not_found')])), "This doesn't exist, or it was removed.");
    expect(describeError(context, refused(500)), "The forum isn't responding right now. Please try again later.");
    expect(describeError(context, StateError('boom')), 'Something went wrong. Please try again.');
  });
}
