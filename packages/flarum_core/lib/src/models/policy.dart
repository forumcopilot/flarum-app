import '../attributes.dart';
import '../json_api.dart';

/// A policy the forum asks its members to accept (fof/terms): its terms of service, say. Until a
/// member accepts a policy that isn't optional, the forum gives them a guest's permissions.
class FlarumPolicy {
  const FlarumPolicy({
    required this.id,
    required this.name,
    this.url,
    this.updateMessage,
    this.updatedAt,
    this.optional = false,
  });

  factory FlarumPolicy.fromResource(JsonApiResource resource) {
    final a = resource.attributes;
    return FlarumPolicy(
      id: resource.id,
      name: a.string('name') ?? '',
      url: a.nonEmptyString('url'),
      // 2.0 names the fields in camelCase; 1.x sends the table's columns.
      updateMessage: a.nonEmptyString('updateMessage') ?? a.nonEmptyString('update_message'),
      updatedAt: a.date('termsUpdatedAt') ?? a.date('terms_updated_at'),
      optional: a.boolean('optional') ?? false,
    );
  }

  final String id;
  final String name;

  /// Where the policy itself is: fof/terms keeps only a link.
  final String? url;

  /// What changed, when the forum says.
  final String? updateMessage;

  /// When its terms last changed; a member accepts again after that.
  final DateTime? updatedAt;

  /// A member may decline it and keep their permissions.
  final bool optional;
}

/// Where the reader stands with one policy (`fofTermsPoliciesState` on their account).
class FlarumPolicyState {
  const FlarumPolicyState({this.acceptedAt, this.hasUpdate = false, this.mustAccept = false, this.isAccepted = false});

  factory FlarumPolicyState.fromJson(Map<String, dynamic> json) => FlarumPolicyState(
        acceptedAt: json.date('accepted_at'),
        hasUpdate: json.boolean('has_update') ?? false,
        mustAccept: json.boolean('must_accept') ?? false,
        isAccepted: json.boolean('is_accepted') ?? false,
      );

  final DateTime? acceptedAt;

  /// Not accepted since its terms last changed.
  final bool hasUpdate;

  /// Needed before the reader may post again: not optional, and not one the forum lets them put off.
  final bool mustAccept;
  final bool isAccepted;
}
