class Worker {
  final int? id;
  final String name;
  final int monthlySalary; // whole PKR
  final DateTime createdAt;

  const Worker({
    this.id,
    required this.name,
    required this.monthlySalary,
    required this.createdAt,
  });
}
