import 'package:flutter/material.dart';
import 'package:nawasena/app/theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsets padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 4),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
