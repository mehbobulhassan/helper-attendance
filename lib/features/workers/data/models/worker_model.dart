import '../../domain/entities/worker.dart';

class WorkerModel extends Worker {
  const WorkerModel({
    super.id,
    required super.name,
    required super.monthlySalary,
    required super.createdAt,
  });

  factory WorkerModel.fromEntity(Worker w) => WorkerModel(
        id: w.id,
        name: w.name,
        monthlySalary: w.monthlySalary,
        createdAt: w.createdAt,
      );

  factory WorkerModel.fromMap(Map<String, Object?> m) => WorkerModel(
        id: m['id'] as int?,
        name: m['name'] as String,
        monthlySalary: m['monthly_salary'] as int,
        createdAt: DateTime.parse(m['created_at'] as String),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'monthly_salary': monthlySalary,
        'created_at': createdAt.toIso8601String(),
      };
}
