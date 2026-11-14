import '../attributes.dart';
import '../json_api.dart';

/// Where a member's request to erase their account stands (flarum/gdpr, formerly fof/gdpr).
enum FlarumErasureStatus {
  /// Asked for; the forum has emailed a link that confirms it, and nothing happens until it's used.
  awaitingConfirmation,

  /// Confirmed from that email: the forum's staff erase the account within 30 days.
  confirmed,

  /// Taken back by the member (or staff). A new request may be made.
  cancelled,

  /// Done: the account was anonymized or deleted (`processed`), or erased by an admin (`manual`).
  processed,

  /// A status this app doesn't know.
  unknown;

  static FlarumErasureStatus parse(String? status) => switch (status) {
        'awaiting_user_confirmation' => awaitingConfirmation,
        'user_confirmed' => confirmed,
        'cancelled' => cancelled,
        'processed' || 'manual' => processed,
        _ => unknown,
      };
}

/// A member's request to erase their account, as flarum/gdpr keeps it (`user-erasure-requests`):
/// one per member, made again in place after a cancellation. The extension's flow, the same on
/// Flarum 1.8 and 2.0: the member asks, with their password; the forum emails them a link
/// (`/gdpr/erasure/confirm/{token}`); once they open it, someone with the `processErasure`
/// permission (admins, by default) anonymizes or deletes the account, or the forum's daily
/// scheduled task does, 30 days after the confirmation, when the forum runs Flarum's scheduler.
class FlarumErasureRequest {
  const FlarumErasureRequest({
    required this.id,
    required this.status,
    this.reason,
    this.createdAt,
    this.confirmedAt,
    this.processedAt,
    this.processedMode,
  });

  factory FlarumErasureRequest.fromResource(JsonApiResource resource) {
    final a = resource.attributes;
    return FlarumErasureRequest(
      id: resource.id,
      status: FlarumErasureStatus.parse(a.string('status')),
      reason: a.nonEmptyString('reason'),
      createdAt: a.date('createdAt'),
      confirmedAt: a.date('userConfirmedAt'),
      processedAt: a.date('processedAt'),
      processedMode: a.nonEmptyString('processedMode'),
    );
  }

  /// How long after the confirmation the extension promises action (its own wording: "within 30
  /// days, as required by the GDPR"), and when its scheduled task processes a request no one has.
  static const processingTime = Duration(days: 30);

  final String id;
  final FlarumErasureStatus status;

  /// What the member wrote when asking, if anything.
  final String? reason;
  final DateTime? createdAt;
  final DateTime? confirmedAt;
  final DateTime? processedAt;

  /// `anonymization` or `deletion`, once processed.
  final String? processedMode;

  /// Asked for or confirmed, and not yet done: it can still be cancelled.
  bool get isOpen => status == FlarumErasureStatus.awaitingConfirmation || status == FlarumErasureStatus.confirmed;

  /// When the account is erased at the latest, once confirmed.
  DateTime? get dueBy => confirmedAt?.add(processingTime);
}
