import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// One line: label (with optional small detail) on the left, amount on the right.
class AmountRow extends StatelessWidget {
  const AmountRow({
    super.key,
    required this.label,
    required this.value,
    this.detail,
    this.bold = false,
  });

  final String label;
  final String value;
  final String? detail;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final weight = bold ? FontWeight.w700 : FontWeight.w400;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              text: label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: weight,
                color: AppColors.text,
              ),
              children: [
                if (detail != null)
                  TextSpan(
                    text: ' $detail',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: weight,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}