/// One payment or advance given to a worker. The optional note says which.
class Payment {
  final int? id;
  final int workerId;
  final int amount; // whole PKR
  final DateTime date;
  final String? note;

  const Payment({
    this.id,
    required this.workerId,
    required this.amount,
    required this.date,
    this.note,
  });
}
