import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/format.dart';
import '../../domain/entities/worker.dart';
import '../providers/workers_providers.dart';

/// Add a worker, or edit one when [worker] is given.
class WorkerFormScreen extends ConsumerStatefulWidget {
  const WorkerFormScreen({super.key, this.worker});
  final Worker? worker;

  @override
  ConsumerState<WorkerFormScreen> createState() => _WorkerFormScreenState();
}

class _WorkerFormScreenState extends ConsumerState<WorkerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.worker?.name);
  late final _salary = TextEditingController(
    text: widget.worker?.monthlySalary.toString(),
  );
  bool _saving = false;

  bool get _isEdit => widget.worker != null;

  @override
  void dispose() {
    _name.dispose();
    _salary.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final name = _name.text.trim();
    final salary = int.parse(_salary.text.trim());
    final notifier = ref.read(workersProvider.notifier);

    try {
      if (_isEdit) {
        final old = widget.worker!;
        await notifier.edit(
          Worker(
            id: old.id,
            name: name,
            monthlySalary: salary,
            createdAt: old.createdAt,
          ),
        );
      } else {
        await notifier.add(name: name, monthlySalary: salary);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save. Please try again.')),
      );
    }
  }

  Future<void> _delete() async {
    final worker = widget.worker!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${worker.name}?'),
        content: const Text(
          'This also deletes all attendance and payment records for this '
          'worker. It cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(workersProvider.notifier).remove(worker.id!);
    // Back to the workers list, skipping the attendance screen of the
    // deleted worker.
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  String? _validateName(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Enter a name' : null;

  String? _validateSalary(String? value) {
    final amount = int.tryParse((value ?? '').trim());
    return (amount == null || amount <= 0)
        ? 'Enter a salary greater than 0'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit worker' : 'Add worker'),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: 'Delete worker',
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('nameField'),
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: _validateName,
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const Key('salaryField'),
              controller: _salary,
              decoration: const InputDecoration(
                labelText: 'Monthly salary (Rs)',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              textInputAction: TextInputAction.done,
              validator: _validateSalary,
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: _salary,
              builder: (context, _) {
                final salary = int.tryParse(_salary.text.trim());
                final text = (salary == null || salary == 0)
                    ? 'Daily rate = monthly salary ÷ 30'
                    : 'Daily rate: ${salary % 30 == 0 ? '' : '≈ '}'
                          '${formatRs((salary / 30).round())} (salary ÷ 30)';
                return Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_isEdit ? 'Save changes' : 'Save worker'),
            ),
          ],
        ),
      ),
    );
  }
}
