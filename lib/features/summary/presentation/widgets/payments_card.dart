import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/format.dart';
import '../../../payments/domain/entities/payment.dart';
import 'amount_row.dart';
import 'section_card.dart';

class PaymentsCard extends StatelessWidget {
  const PaymentsCard({
    super.key,
    required this.payments,
    required this.total,
    required this.onDelete,
  });

  final List<Payment> payments;
  final int total;
  final void Function(Payment payment) onDelete;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Payments made',
      child: payments.isEmpty
          ? const Text(
              'No payments this month.',
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            )
          : Column(
              children: [
                for (final payment in payments)
                  _PaymentRow(payment: payment, onDelete: onDelete),
                const SizedBox(height: 4),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 8),
                AmountRow(
                  label: 'Total paid',
                  value: formatRs(total),
                  bold: true,
                ),
              ],
            ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment, required this.onDelete});

  final Payment payment;
  final void Function(Payment payment) onDelete;

  @override
  Widget build(BuildContext context) {
    final note = payment.note;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                shortDateLabel(payment.date),
                style: const TextStyle(fontSize: 15, color: AppColors.text),
              ),
              if (note != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          formatRs(payment.amount),
          style: const TextStyle(fontSize: 15, color: AppColors.text),
        ),
        IconButton(
          tooltip: 'Delete payment',
          visualDensity: VisualDensity.compact,
          iconSize: 18,
          color: AppColors.textSecondary,
          icon: const Icon(Icons.close),
          onPressed: () => onDelete(payment),
        ),
      ],
    );
  }
}