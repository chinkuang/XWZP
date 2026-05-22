// appearance_card.dart — App 外观设置（夜间/白天/跟随系统/自定义）

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/settings_provider.dart';
import '../../shared/widgets/lrp_card.dart';
import '../../theme.dart';

class AppearanceCard extends ConsumerWidget {
  const AppearanceCard({super.key});

  static const _modes = [
    (ThemeMode.dark,   '夜间', CupertinoIcons.moon_fill),
    (ThemeMode.light,  '白天', CupertinoIcons.sun_max_fill),
    (ThemeMode.auto,   '跟随系统', CupertinoIcons.circle_lefthalf_fill),
    (ThemeMode.custom, '自定义', CupertinoIcons.paintbrush_fill),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);

    return LrpCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('外观', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
            const SizedBox(height: 2),
            Text(_label(s.themeMode), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ]),
        ]),
        const SizedBox(height: 14),

        // 主题模式选择
        Row(children: _modes.map((m) {
          final on = m.$1 == s.themeMode;
          return Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => n.update(s.copyWith(themeMode: m.$1)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: on ? AppColors.surface2 : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: on ? AppColors.strokeStrong : AppColors.stroke, width: 0.5),
                ),
                child: Column(children: [
                  Icon(m.$3, size: 18, color: on ? AppColors.text : AppColors.textDim),
                  const SizedBox(height: 5),
                  Text(m.$2, style: TextStyle(fontSize: 11,
                      color: on ? AppColors.text : AppColors.textDim)),
                ]),
              ),
            ),
          ));
        }).toList()),

        // 自定义参数（仅自定义模式下显示）
        if (s.themeMode == ThemeMode.custom) ...[
          const SizedBox(height: 16),
          const Divider(color: AppColors.stroke, thickness: 0.5, height: 0),
          const SizedBox(height: 16),
          _slider('色相', s.customHue.toDouble(), 0, 360, '${s.customHue}°',
              (v) => n.update(s.copyWith(customHue: v.toInt()))),
          const SizedBox(height: 12),
          _slider('饱和度', s.customSat, 0, 0.25, (s.customSat * 100).toStringAsFixed(1) + '%',
              (v) => n.update(s.copyWith(customSat: v))),
          const SizedBox(height: 12),
          _slider('亮度', s.customLight, 0.04, 0.96, '${(s.customLight * 100).round()}%',
              (v) => n.update(s.copyWith(customLight: v))),
          const SizedBox(height: 12),
          _slider('透明度', s.customOpacity, 0.3, 1, '${(s.customOpacity * 100).round()}%',
              (v) => n.update(s.copyWith(customOpacity: v))),
          const SizedBox(height: 12),
          _slider('磨砂', s.customFrost, 0, 30, '${s.customFrost.round()}px',
              (v) => n.update(s.copyWith(customFrost: v))),
        ],
      ]),
    );
  }

  Widget _slider(String label, double value, double min, double max, String fmt, ValueChanged<double> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textDim)),
        Text(fmt, style: const TextStyle(fontSize: 13, fontFeatures: [FontFeature.tabularFigures()])),
      ]),
      Slider(value: value, min: min, max: max, onChanged: onChanged),
    ]);
  }

  String _label(ThemeMode m) {
    switch (m) {
      case ThemeMode.dark:   return '夜间模式';
      case ThemeMode.light:  return '白天模式';
      case ThemeMode.auto:   return '跟随系统';
      case ThemeMode.custom: return '自定义';
    }
  }
}
