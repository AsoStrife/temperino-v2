/// A calendar date without time and without time zone (fix B11).
///
/// The backend sends `date` as `YYYY-MM-DD`. Parsing it with `DateTime.parse`
/// would create a UTC/local instant and could shift the day; this type keeps
/// the three numbers as they are.
class DateOnly implements Comparable<DateOnly> {
  const DateOnly(this.year, this.month, this.day);

  factory DateOnly.fromDateTime(DateTime dt) =>
      DateOnly(dt.year, dt.month, dt.day);

  factory DateOnly.today() => DateOnly.fromDateTime(DateTime.now());

  /// Parses `YYYY-MM-DD` (extra characters after the day, e.g. a time part,
  /// are ignored). Throws [FormatException] on invalid input.
  factory DateOnly.parse(String value) {
    final match = _pattern.firstMatch(value.trim());
    if (match == null) {
      throw FormatException('Data non valida, atteso AAAA-MM-GG', value);
    }
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      throw FormatException('Data non valida', value);
    }
    return DateOnly(year, month, day);
  }

  static final _pattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})');

  final int year;
  final int month;
  final int day;

  /// Local midnight of this date. Use only for UI widgets (DatePicker).
  DateTime toDateTime() => DateTime(year, month, day);

  /// `YYYY-MM-DD`
  String toJson() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  bool isAfter(DateOnly other) => compareTo(other) > 0;
  bool isBefore(DateOnly other) => compareTo(other) < 0;

  @override
  int compareTo(DateOnly other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is DateOnly &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toJson();
}
