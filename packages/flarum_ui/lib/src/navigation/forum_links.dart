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
  const UserLink(this.username);

  final String username;

  @override
  bool operator ==(Object other) => other is UserLink && other.username == username;

  @override
  int get hashCode => username.hashCode;
}

class TagLink extends ForumLink {
  const TagLink(this.slug);

  final String slug;

  @override
  bool operator ==(Object other) => other is TagLink && other.slug == slug;

  @override
  int get hashCode => slug.hashCode;
}
