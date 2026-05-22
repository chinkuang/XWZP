import 'package:flutter/material.dart';
import '../../theme.dart';

/// 列表行：左图标 + 主标题 + 副标题 + 右尾控件
class LrpSwitchTile extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String? sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  const LrpSwitchTile({
    super.key,
    this.icon,
    required this.label,
    this.sub,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 18,
                  color: value ? AppColors.text : AppColors.textFaint),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 15)),
                  if (sub != null && sub!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(sub!,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textFaint)),
                    ),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class LrpDivider extends StatelessWidget {
  final double indent;
  const LrpDivider({super.key, this.indent = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      color: AppColors.stroke,
      margin: EdgeInsets.only(left: indent),
    );
  }
}
