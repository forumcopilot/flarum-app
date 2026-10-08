/// A resource's `{type, id}`, as JSON:API relationships link them.
typedef ResourceId = ({String type, String id});

/// One JSON:API resource object.
class JsonApiResource {
  JsonApiResource({
    required this.type,
    required this.id,
    this.attributes = const {},
    this.relationships = const {},
  });

  factory JsonApiResource.fromJson(Map<String, dynamic> json) => JsonApiResource(
        type: json['type'] as String,
        id: '${json['id']}',
        attributes: _asMap(json['attributes']),
        relationships: _asMap(json['relationships']),
      );

  final String type;
  final String id;
  final Map<String, dynamic> attributes;
  final Map<String, dynamic> relationships;

  ResourceId get ref => (type: type, id: id);

  /// The linkage of a to-one relationship, or null when it is absent or empty.
  ResourceId? toOne(String name) {
    final data = _asMap(relationships[name])['data'];
    return data is Map ? _linkage(data) : null;
  }

  /// The linkage of a to-many relationship; empty when absent.
  List<ResourceId> toMany(String name) {
    final data = _asMap(relationships[name])['data'];
    if (data is! List) return const [];
    return [
      for (final item in data)
        if (item is Map) _linkage(item),
    ];
  }
}

/// A JSON:API response: its primary data plus an index of everything in
/// `included`, so relationships can be resolved.
class JsonApiDocument {
  JsonApiDocument._(this.data, this.isCollection, this._index, this.links, this.meta);

  factory JsonApiDocument.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final data = switch (raw) {
      List() => [for (final item in raw) JsonApiResource.fromJson(_asMap(item))],
      Map() => [JsonApiResource.fromJson(_asMap(raw))],
      _ => <JsonApiResource>[],
    };
    final included = [
      for (final item in json['included'] as List? ?? const []) JsonApiResource.fromJson(_asMap(item)),
    ];
    return JsonApiDocument._(
      data,
      raw is List,
      {for (final resource in [...included, ...data]) _key(resource.type, resource.id): resource},
      _asMap(json['links']),
      _asMap(json['meta']),
    );
  }

  final List<JsonApiResource> data;
  final bool isCollection;
  final Map<String, JsonApiResource> _index;
  final Map<String, dynamic> links;
  final Map<String, dynamic> meta;

  /// The primary resource of a single-resource response.
  JsonApiResource get single {
    if (data.length != 1) {
      throw FormatException('Expected one resource in the response, got ${data.length}');
    }
    return data.first;
  }

  /// Whether the server says there is another page. Only the presence of
  /// `links.next` is used: on 2.0 its URL drops the `/api` prefix, so it is
  /// never followed; callers page with `page[offset]` instead.
  bool get hasNext => links['next'] != null;

  /// The resource [ref] points at, from `included` or the primary data.
  JsonApiResource? find(ResourceId? ref) => ref == null ? null : _index[_key(ref.type, ref.id)];

  /// The resources [refs] point at, skipping any the response didn't include.
  List<JsonApiResource> findAll(Iterable<ResourceId> refs) => [
        for (final ref in refs)
          if (find(ref) case final resource?) resource,
      ];
}

String _key(String type, String id) => '$type:$id';

ResourceId _linkage(Map<dynamic, dynamic> json) => (type: json['type'] as String, id: '${json['id']}');

Map<String, dynamic> _asMap(Object? value) => value is Map ? value.cast<String, dynamic>() : const {};
