import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current date. Tests override it with a fixed date.
final todayProvider = Provider<DateTime>((ref) => DateTime.now());