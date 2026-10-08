/// Typed reads of JSON:API attributes whose JSON type varies between Flarum
/// versions and settings: 2.0 sends some booleans as `"1"` or `""`, and both
/// versions send the tag limits (`minPrimaryTags`…) as strings.
extension FlarumAttributes on Map<String, dynamic> {
  String? string(String key) {
    final value = this[key];
    if (value == null) return null;
    return value is String ? value : '$value';
  }

  /// [string], with `""` read as absent (unset settings come back empty).
  String? nonEmptyString(String key) {
    final value = string(key);
    return value == null || value.isEmpty ? null : value;
  }

  int? integer(String key) {
    final value = this[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  bool? boolean(String key) {
    final value = this[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      if (value == '1' || value == 'true') return true;
      if (value.isEmpty || value == '0' || value == 'false') return false;
    }
    return null;
  }

  DateTime? date(String key) {
    final value = this[key];
    return value is String ? DateTime.tryParse(value) : null;
  }
}
