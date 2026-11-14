import 'package:flarum_core/flarum_core.dart';
import 'package:flarum_core/testing.dart';
import 'package:flutter_test/flutter_test.dart';

/// alice asks to have her account erased (flarum/gdpr), replayed from the erasure_* fixtures: her
/// own user with no request is the forum's real answer; the request, its states, the wrong password
/// and the cancellation are written from the extension's source (each fixture's `note`).
void main() {
  for (final version in FlarumVersion.values) {
    group('Flarum ${version.name}:', () {
      test('the forum says what erasing does: anonymize, not delete, as by default', () async {
        final fixtures = FixtureForum(version);
        final forum = fixtures.forum();
        final info = await forum.refresh();
        expect(forum.extensions.gdpr, isTrue);
        expect(info.erasureAnonymizes, isTrue);
        expect(info.erasureDeletes, isFalse);
        expect(info.passwordlessSignUp, isFalse, reason: "2.0 sends it as \"\"");
      });

      test("a member with no request has none; their own user, read with the include, says so", () async {
        final fixtures = FixtureForum(version);
        expect(await fixtures.api().erasureRequest(fixtures.userId('alice')), isNull);
        final sent = fixtures.requests.single;
        expect(sent.path, '/users/${fixtures.userId('alice')}');
        expect(sent.queryParameters, {'include': 'erasureRequest'});
      });

      test('asking sends the password, and the request waits for its email', () async {
        final fixtures = FixtureForum(version);
        final request = await fixtures.api().requestErasure(password: 'secret');
        expect(request.status, FlarumErasureStatus.awaitingConfirmation);
        expect(request.reason, isNull);
        expect(request.createdAt, DateTime.utc(2026, 11, 14, 3, 40));
        expect(request.confirmedAt, isNull);
        expect(request.isOpen, isTrue);
        final body = fixtures.requests.single.data as Map;
        expect(body['meta'], {'password': 'secret'});
        expect(body['data']['type'], 'user-erasure-requests');
        expect(body['data']['attributes'], isEmpty, reason: 'no reason given, none sent');
      });

      test('a wrong password is a validation error on password', () async {
        final fixtures = FixtureForum(version, states: {'wrongPassword'});
        try {
          await fixtures.api().requestErasure(password: 'wrong');
          fail('Expected the forum to refuse');
        } on FlarumApiException catch (e) {
          expect(e.isValidationError, isTrue);
          expect(e.errors.single.pointer, '/data/attributes/password');
        }
      });

      test('a confirmed request is due 30 days after the confirmation', () async {
        final fixtures = FixtureForum(version, states: {'erasureConfirmed'});
        final request = (await fixtures.api().erasureRequest(fixtures.userId('alice')))!;
        expect(request.status, FlarumErasureStatus.confirmed);
        expect(request.confirmedAt, DateTime.utc(2026, 11, 14, 4, 5));
        expect(request.dueBy, DateTime.utc(2026, 12, 14, 4, 5));
      });

      test('cancelling uses each version\'s route', () async {
        final fixtures = FixtureForum(version, states: {'erasureAwaiting'});
        final api = fixtures.api();
        await api.forumInfo();
        final request = (await api.erasureRequest(fixtures.userId('alice')))!;
        expect(request.status, FlarumErasureStatus.awaitingConfirmation);
        await api.cancelErasure(request.id);
        final cancel = fixtures.requests.last;
        if (version == FlarumVersion.v2) {
          expect((cancel.method, cancel.path), ('POST', '/user-erasure-requests/${request.id}/cancel'));
        } else {
          expect((cancel.method, cancel.path), ('DELETE', '/user-erasure-requests/${request.id}'));
        }
      });
    });
  }

  test('statuses as flarum/gdpr names them', () {
    expect(FlarumErasureStatus.parse('awaiting_user_confirmation'), FlarumErasureStatus.awaitingConfirmation);
    expect(FlarumErasureStatus.parse('user_confirmed'), FlarumErasureStatus.confirmed);
    expect(FlarumErasureStatus.parse('cancelled'), FlarumErasureStatus.cancelled);
    expect(FlarumErasureStatus.parse('processed'), FlarumErasureStatus.processed);
    expect(FlarumErasureStatus.parse('manual'), FlarumErasureStatus.processed, reason: 'erased by an admin');
    expect(FlarumErasureStatus.parse('something new'), FlarumErasureStatus.unknown);
  });
}
