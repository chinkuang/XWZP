import 'package:flutter/material.dart';
import '../../theme.dart';

/// 通用卡片：暗色背景 + 0.5px 描边 + 14px 圆角
class LrpCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? background;
  final Color? borderColor;

  const LrpCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.background,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(
          color: borderColor ?? AppColors.stroke,
          width: 0.5,
        ),
      ),
      padding: padding,
      child: child,
    );
  }
}

/// 灰色小标题（section header）
class SectionHeader extends StatelessWidget {
  final String text;
  const SectionHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6, top: 4, bottom: 4),
      child: Text(text,
          style: const TextStyle(fontSize: 12, color: AppColors.textFaint)),
    );
  }
}
