import 'package:intl/intl.dart';

import 'date_only.dart';

/// Italian formatting helpers. `initializeDateFormatting('it_IT')` is called
/// in `main.dart` before these are used.
abstract final class Formatters {
  static const locale = 'it_IT';

  static final _date = DateFormat('dd-MM-yyyy', locale);
  static final _dayMonth = DateFormat('d MMMM', locale);
  static final _weekdayShort = DateFormat('EEE', locale);
  static final _weekdayLong = DateFormat('EEEE', locale);
  static final _monthLong = DateFormat('MMMM', locale);
  static final _monthShort = DateFormat('MMM', locale);
  static final _ratio = NumberFormat('0.00', locale);
  static final _axis = NumberFormat('#,##0.#', locale);

  /// `dd-MM-yyyy`
  static String date(DateOnly d) => _date.format(d.toDateTime());

  /// `12 marzo`
  static String dayMonth(DateOnly d) => _dayMonth.format(d.toDateTime());

  /// `Lun`
  static String weekdayShort(DateOnly d) =>
      _capitalize(_weekdayShort.format(d.toDateTime()));

  /// `Domenica`
  static String weekdayLong(DateOnly d) =>
      _capitalize(_weekdayLong.format(d.toDateTime()));

  /// `Novembre`
  static String monthLong(int month) =>
      _capitalize(_monthLong.format(DateTime(2000, month)));

  /// `Nov`
  static String monthShort(int month) =>
      _capitalize(_monthShort.format(DateTime(2000, month)));

  /// `Novembre 2026`
  static String monthYear(int year, int month) => '${monthLong(month)} $year';

  /// Ratio with two decimals, or "—" when undefined (fix B1).
  static String ratio(double? value) =>
      value == null || !value.isFinite ? '—' : _ratio.format(value);

  /// Axis label: `1,5`, `10`.
  static String axis(num value) => _axis.format(value);

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).replaceAll('.', '');
}
