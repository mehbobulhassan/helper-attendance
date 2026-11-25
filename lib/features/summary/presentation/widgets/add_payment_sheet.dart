import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/month_query.dart';
import '../../../payments/presentation/providers/payment_providers.dart';

/// Bottom sheet to record a payment or advance for the month in [query].
/// The date can only be a day of that month, because payments are counted
/// per month.
class AddPaymentSheet extends ConsumerStatefulWidget {
  const AddPaymentSheet({
    super.key,
    required this.query,
    required this.initialDate,
  });

  final MonthQuery query;
  final DateTime initialDate;

  @override
  ConsumerState<AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends ConsumerState<AddPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  late DateTime _date = widget.initialDate;
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(widget.query.year, widget.query.month, 1),
      lastDate: DateTime(widget.query.year, widget.query.month + 1, 0),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await ref.read(paymentControllerProvider).add(
            widget.query,
            amount: int.parse(_amount.text.trim()),
            date: _date,
            note: _note.text,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save. Please try again.')),
      );
    }
  }

  String? _validateAmount(String? value) {
    final amount = int.tryParse((value ?? '').trim());
    return (amount == null || amount <= 0)
        ? 'Enter an amount greater than 0'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Lifts the sheet above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add payment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('amountField'),
                  controller: _amount,
                  decoration: const InputDecoration(labelText: 'Amount (Rs)'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  textInputAction: TextInputAction.next,
                  validator: _validateAmount,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  // A new key each time the date changes, so the field
                  // shows the new initialValue.
                  key: ValueKey(_date),
                  initialValue: fullDateLabel(_date),
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _note,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    hintText: 'e.g. Advance',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: const Text('Save payment'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}