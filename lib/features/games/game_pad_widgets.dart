// game_pad_widgets.dart — 横屏游戏控制器共用组件
// 可拖拽按键 + 编辑模式

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';

class GamePadButton extends StatelessWidget {
  final Offset pos;
  final IconData icon;
  final String? caption;
  final bool primary;
  final bool pressed;
  final bool editMode;
  final bool showCaption;
  final VoidCallback onTap;
  final void Function(Offset delta) onDrag;

  static const size = 64.0;

  const GamePadButton({
    super.key,
    required this.pos,
    required this.icon,
    this.caption,
    this.primary = false,
    this.pressed = false,
    this.editMode = false,
    this.showCaption = true,
    required this.onTap,
    required this.onDrag,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        onPanUpdate: editMode ? (d) => onDrag(d.delta) : null,
        onTap: editMode ? null : onTap,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            color: pressed
                ? AppColors.accent
                : (primary ? AppColors.accentSoft : AppColors.surface),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: editMode
                  ? AppColors.accent
                  : (primary ? AppColors.accent : AppColors.stroke),
              width: editMode ? 1 : 0.5,
              style: editMode ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 24,
                color: pressed ? Colors.white : (primary ? AppColors.accent : AppColors.text)),
            if (caption != null && showCaption) ...[
              const SizedBox(height: 2),
              Text(caption!, style: TextStyle(
                fontSize: 10,
                color: pressed ? Colors.white : (primary ? AppColors.accent : AppColors.text),
              )),
            ]
          ]),
        ),
      ),
    );
  }
}

class GameTopBar extends StatelessWidget {
  final String title;
  final Widget? center;
  final bool editMode;
  final bool showLabels;
  final VoidCallback onBack;
  final VoidCallback onToggleEdit;
  final VoidCallback onToggleLabels;

  const GameTopBar({
    super.key,
    required this.title,
    this.center,
    required this.editMode,
    required this.showLabels,
    required this.onBack,
    required this.onToggleEdit,
    required this.onToggleLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(bottom: BorderSide(color: AppColors.stroke, width: 0.5)),
      ),
      child: Row(children: [
        _RoundBtn(icon: CupertinoIcons.back, onTap: onBack),
        const Spacer(),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(width: 12),
        if (center != null) center!,
        const Spacer(),
        _RoundBtn(
          icon: showLabels ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
          accent: !showLabels,
          onTap: onToggleLabels,
        ),
        const SizedBox(width: 8),
        editMode
            ? TextButton(
                onPressed: onToggleEdit,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                ),
                child: const Text('完成'),
              )
            : _RoundBtn(icon: CupertinoIcons.gear_alt, onTap: onToggleEdit),
      ]),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool accent;
  const _RoundBtn({required this.icon, required this.onTap, this.accent = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.stroke, width: 0.5),
        ),
        child: Icon(icon, size: 15, color: accent ? AppColors.accent : AppColors.textDim),
      ),
    );
  }
}

class InlineStat extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;
  const InlineStat({super.key, required this.label, required this.value, this.accent = false});
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textFaint)),
      const SizedBox(height: 1),
      Text(value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: accent ? FontWeight.w500 : FontWeight.normal,
            color: accent ? AppColors.accent : AppColors.text,
            fontFeatures: const [FontFeature.tabularFigures()],
          )),
    ]);
  }
}
