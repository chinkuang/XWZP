// color_screen.dart — 颜色面板（占位实现）
//
// 设备 effect 1 (氛围灯) 下，用户可挑选一个静态颜色作为氛围色。
// 完整 HSL 色轮可以后续替换。这里先用预设色块 + RGB slider。

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/device_provider.dart';
import '../../shared/widgets/lrp_card.dart';
import '../../theme.dart';

class ColorScreen extends ConsumerStatefulWidget {
  const ColorScreen({super.key});
  @override
  ConsumerState<ColorScreen> createState() => _ColorScreenState();
}

class _ColorScreenState extends ConsumerState<ColorScreen> {
  Color _color = const Color(0xFF00CFFF);

  static const _presets = <_Preset>[
    _Preset('暖黄', Color(0xFFFFB347)),
    _Preset('桃桃', Color(0xFFFFD986)),
    _Preset('柠黄', Color(0xFFE5FF7A)),
    _Preset('青青', Color(0xFF00CFFF)),
    _Preset('青空', Color(0xFF3D8EFF)),
    _Preset('蔷薇', Color(0xFFFF7AB6)),
    _Preset('外珠', Color(0xFFFF5252)),
    _Preset('薄雪', Color(0xFFFFFFFF)),
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deviceStateProvider);
    final n = ref.read(deviceStateProvider.notifier);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
          children: [
            const Text('颜色', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('氛围灯静态色', style: TextStyle(fontSize: 13, color: AppColors.textDim)),
            const SizedBox(height: 16),

            LrpCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: _color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Hex', style: const TextStyle(fontSize: 11, color: AppColors.textFaint)),
                    Text('#${_color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                        style: const TextStyle(fontSize: 18, fontFeatures: [FontFeature.tabularFigures()])),
                  ]),
                  const SizedBox(height: 10),
                  _RgbBar('R', _color.red, (v) => setState(() => _color = Color.fromARGB(255, v, _color.green, _color.blue))),
                  _RgbBar('G', _color.green, (v) => setState(() => _color = Color.fromARGB(255, _color.red, v, _color.blue))),
                  _RgbBar('B', _color.blue, (v) => setState(() => _color = Color.fromARGB(255, _color.red, _color.green, v))),
                ],
              ),
            ),

            const SizedBox(height: 12),
            LrpCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('常用颜色', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1,
                  children: _presets.map((p) => GestureDetector(
                    onTap: () => setState(() => _color = p.color),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 26, height: 26, decoration: BoxDecoration(color: p.color, shape: BoxShape.circle)),
                      const SizedBox(height: 6),
                      Text(p.name, style: const TextStyle(fontSize: 11, color: AppColors.textDim)),
                    ]),
                  )).toList(),
                ),
              ]),
            ),

            const SizedBox(height: 12),
            LrpCard(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('应用到氛围灯', style: TextStyle(fontSize: 14)),
                    Text(state.effect == 1 ? '氛围灯已启用' : '需切换',
                        style: const TextStyle(fontSize: 11, color: AppColors.textFaint)),
                  ]),
                ),
                FilledButton(
                  onPressed: () {
                    // TODO: 协议未定义颜色字段，需要固件端补充 set "color"
                    // 这里暂时仅切到 effect 1
                    n.setEffect(1);
                  },
                  style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
                  child: const Text('应用'),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _Preset {
  final String name;
  final Color color;
  const _Preset(this.name, this.color);
}

class _RgbBar extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _RgbBar(this.label, this.value, this.onChanged);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 18, child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textFaint))),
      Expanded(child: Slider(value: value.toDouble(), max: 255, onChanged: (v) => onChanged(v.toInt()))),
      SizedBox(width: 30, child: Text('$value', textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 11, color: AppColors.textDim, fontFeatures: [FontFeature.tabularFigures()]))),
    ]);
  }
}
