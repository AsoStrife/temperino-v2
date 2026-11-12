/// Tolerant readers for Strapi attributes. Old records may contain `null`,
/// `0`/`1` instead of booleans, or numbers encoded as strings.
abstract final class JsonReaders {
  /// `null` -> 0 (fix B13).
  static int readInt(Object? value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Accepts true/false, 0/1, "true"/"false"/"0"/"1". `null` -> false.
  static bool readBool(Object? value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value == 'true' || value == '1';
    return false;
  }

  /// Strapi v4 wraps fields in `attributes`; Strapi v5 does not. Support both.
  static Map<String, dynamic> attributes(Map<String, dynamic> item) {
    final attrs = item['attributes'];
    return attrs is Map<String, dynamic> ? attrs : item;
  }

  static int? readId(Map<String, dynamic> item) {
    final id = item['id'];
    if (id is int) return id;
    if (id is num) return id.toInt();
    if (id is String) return int.tryParse(id);
    return null;
  }
}
