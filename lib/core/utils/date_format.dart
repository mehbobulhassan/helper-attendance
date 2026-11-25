const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// DateTime(2026, 11) -> 'November 2026'
String monthYearLabel(DateTime d) => '${_months[d.month - 1]} ${d.year}';

/// DateTime(2026, 11, 25) -> 'Wednesday, 25 November'
String fullDateLabel(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

/// DateTime(2026, 11, 5) -> '5 Nov'
String shortDateLabel(DateTime d) =>
    '${d.day} ${_months[d.month - 1].substring(0, 3)}';
