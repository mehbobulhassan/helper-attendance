/// Identifies one worker in one month. Used as the argument of the
/// `.family` providers. Dart records compare by value, so two queries with
/// the same numbers hit the same provider instance.
typedef MonthQuery = ({int workerId, int year, int month});
