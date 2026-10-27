/// A link to one of the forum's own pages, which the app opens itself.
sealed class ForumLink {
  const ForumLink();

  /// [url] as a link to the forum at [baseUrl], or null for anything else:
  /// another site, or a page of the forum the app doesn't open. Flarum's
  /// paths: `/d/{id}[-{slug}][/{number}]`, `/u/{username}`, `/t/{slug}`.
  static ForumLink? parse(String url, String baseUrl) {
    final target = Uri.tryParse(url.trim());
    final base = Uri.tryParse(baseUrl.trim());
    if (target == null || base == null || !target.hasAuthority) return null;
    if (target.scheme != base.scheme || target.host != base.host || target.port != base.port) return null;
    var prefix = base.path;
    while (prefix.endsWith('/')) {
      prefix = prefix.substring(0, prefix.length - 1);
    }
    if (prefix.isNotEmpty && !target.path.startsWith('$prefix/')) return null;
    final segments = target.path.substring(prefix.length).split('/').where((s) => s.isNotEmpty).toList();
    if (segments.length < 2) return null;
    switch (segments[0]) {
      case 'd':
        final id = RegExp(r'^\d+').stringMatch(segments[1]);
        if (id == null) return null;
        return DiscussionLink(id, segments.length > 2 ? int.tryParse(segments[2]) : null);
      case 'u':
        return UserLink(Uri.decodeComponent(segments[1]));
      case 't':
        return TagLink(Uri.decodeComponent(segments[1]));
    }
    return null;
  }

  /// What a push from the Flapp extension opens, from its data (strings, as Firebase delivers
  /// them): a discussion at a post, a conversation (Flarum 2.0's messages) or a user. Null for a
  /// push that names none.
  static ForumLink? fromPush(Map<String, Object?> data) {
    String? id(String key) => switch (data[key]) {
          final String value when RegExp(r'^[1-9][0-9]*$').hasMatch(value) => value,
          _ => null,
        };
    if (id('discussion_id') case final discussion?) {
      return DiscussionLink(discussion, int.tryParse(id('post_number') ?? ''));
    }
    if (id('dialog_id') case final dialog?) return DialogLink(dialog);
    if (id('user_id') case final user?) return UserIdLink(user);
    return null;
  }
}

/// A discussion, at post [number] when the link names one.
class DiscussionLink extends ForumLink {
  const DiscussionLink(this.id, [this.number]);

  final String id;
  final int? number;

  @override
  bool operator ==(Object other) => other is DiscussionLink && other.id == id && other.number == number;

  @override
  int get hashCode => Object.hash(id, number);

  @override
  String toString() => 'DiscussionLink($id, $number)';
}

class UserLink extends ForumLink {
  const UserLink(this.slug);

  /// The user's slug, from `/u/{slug}`: their username, or their id on forums that use ID slugs.
  final String slug;

  @override
  bool operator ==(Object other) => other is UserLink && other.slug == slug;

  @override
  int get hashCode => slug.hashCode;
}

/// A user by id, as a push names them (the profile a suspension opens).
class UserIdLink extends ForumLink {
  const UserIdLink(this.id);

  final String id;

  @override
  bool operator ==(Object other) => other is UserIdLink && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// A conversation of flarum/messages (Flarum 2.0), as a push names it.
class DialogLink extends ForumLink {
  const DialogLink(this.id);

  final String id;

  @override
  bool operator ==(Object other) => other is DialogLink && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class TagLink extends ForumLink {
  const TagLink(this.slug);

  final String slug;

  @override
  bool operator ==(Object other) => other is TagLink && other.slug == slug;

  @override
  int get hashCode => slug.hashCode;
}
