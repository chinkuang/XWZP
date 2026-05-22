import 'package:flutter/material.dart';
import '../../theme.dart';

/// 标准滑块组件（含 label + value 文字）
class LrpSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double) fmt;
  final ValueChanged<double> onChanged;
  final bool disabled;
  final Color? valueColor;

  const LrpSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.fmt,
    required this.onChanged,
    this.disabled = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, color: AppColors.text)),
            Text(fmt(value),
                style: TextStyle(
                  fontSize: 13,
                  color: valueColor ?? AppColors.text,
                  fontFeatures: const [FontFeature.tabularFigures()],
                )),
          ],
        ),
        Opacity(
          opacity: disabled ? 0.4 : 1,
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: disabled ? null : onChanged,
          ),
        ),
      ],
    );
  }
}
