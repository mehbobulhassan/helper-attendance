/// Dates are stored in SQLite as 'YYYY-MM-DD' text.
/// This format sorts correctly as a string, so month queries stay simple.
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime parseDateKey(String s) => DateTime.parse(s);

/// Number of days in the given month (month 1-12).
int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// First day of the month (inclusive) and first day of the next month
/// (exclusive), as date keys. DateTime rolls month 13 over to January.
(String, String) monthRangeKeys(int year, int month) =>
    (dateKey(DateTime(year, month, 1)), dateKey(DateTime(year, month + 1, 1)));
