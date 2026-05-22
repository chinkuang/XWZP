import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/device_provider.dart';
import '../../core/models/effect_modes.dart';
import '../../shared/widgets/lrp_card.dart';
import '../../shared/widgets/lrp_slider.dart';
import '../../theme.dart';

class LightScreen extends ConsumerStatefulWidget {
  const LightScreen({super.key});
  @override
  ConsumerState<LightScreen> createState() => _LightScreenState();
}

class _LightScreenState extends ConsumerState<LightScreen> {
  String brightnessTarget = 'main'; // 'main' | 'sub'

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deviceStateProvider);
    final n = ref.read(deviceStateProvider.notifier);
    final isMain = brightnessTarget == 'main';
    final value = (isMain ? state.brightnessMain : state.brightnessSub).toDouble();
    final min = isMain ? 10.0 : 0.0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
          children: [
            const Text('灯光', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.text)),
            const SizedBox(height: 4),
            const Text('模式与亮度', style: TextStyle(fontSize: 13, color: AppColors.textDim)),
            const SizedBox(height: 16),

            const SectionHeader('屏幕亮度'),
            LrpCard(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _ScreenSeg(value: brightnessTarget, onChanged: (v) => setState(() => brightnessTarget = v)),
                const SizedBox(height: 16),
                LrpSlider(
                  label: '亮度',
                  value: value,
                  min: min, max: 255,
                  divisions: ((255 - min) / 5).round(),
                  fmt: (v) => state.autoBrightness ? 'AUTO' : '${((v - min) / (255 - min) * 100).round()}%',
                  disabled: state.autoBrightness,
                  valueColor: state.autoBrightness ? AppColors.warning : AppColors.text,
                  onChanged: (v) {
                    if (isMain) {
                      n.setBrightnessMain(v.toInt());
                    } else {
                      n.setBrightnessSub(v.toInt());
                    }
                  },
                ),
                const Divider(color: AppColors.stroke, thickness: 0.5, height: 28),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('自动亮度', style: TextStyle(fontSize: 14)),
                  Switch(value: state.autoBrightness, onChanged: n.setAutoBrightness),
                ]),
              ]),
            ),

            const SizedBox(height: 12),
            LrpCard(
              child: LrpSlider(
                label: '速度',
                value: state.speed.toDouble(),
                min: 1, max: 10, divisions: 9,
                fmt: (v) => '${v.round()} / 10',
                onChanged: (v) => n.setSpeed(v.round()),
              ),
            ),

            const SizedBox(height: 16),
            const SectionHeader('模式'),
            for (final m in kTopEffects) ...[
              _ModeTile(
                effect: m,
                on: m.value == state.effect,
                onTap: () => n.setEffect(m.value),
              ),
              const SizedBox(height: 8),
            ],

            if (state.effect == 0) ...[
              const SizedBox(height: 4),
              const SectionHeader('音乐效果'),
              _SubEffectGrid(items: kDynEffects, current: state.dynEffect, onChange: n.setDynEffect),
            ],
            if (state.effect == 1) ...[
              const SizedBox(height: 4),
              const SectionHeader('氛围效果'),
              _SubEffectGrid(items: kAmbEffects, current: state.ambEffect, onChange: n.setAmbEffect),
            ],

            const SizedBox(height: 12),
            const Center(
              child: Text(
                '切换模式将实时通过 WebSocket 下发到设备',
                style: TextStyle(fontSize: 11, color: AppColors.textFaint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenSeg extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _ScreenSeg({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final options = [('main', '主屏'), ('sub', '副屏')];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: options.map((opt) {
          final on = opt.$1 == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(opt.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: on ? AppColors.surface3 : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(opt.$2,
                  style: TextStyle(
                    fontSize: 13,
                    color: on ? AppColors.text : AppColors.textDim,
                    fontWeight: on ? FontWeight.w500 : FontWeight.normal,
                  )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  final TopEffect effect;
  final bool on;
  final VoidCallback onTap;
  const _ModeTile({required this.effect, required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LrpCard(
        background: on ? AppColors.surface2 : AppColors.surface,
        borderColor: on ? AppColors.strokeStrong : AppColors.stroke,
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: on ? AppColors.accentSoft : AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(CupertinoIcons.waveform, size: 18, color: AppColors.text),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(effect.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  Text(effect.en, style: const TextStyle(fontSize: 11, color: AppColors.textFaint)),
                ]),
                const SizedBox(height: 3),
                Text(effect.desc, style: const TextStyle(fontSize: 12, color: AppColors.textDim)),
              ]),
            ),
            if (on) const Icon(CupertinoIcons.checkmark, size: 16, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}

class _SubEffectGrid extends StatelessWidget {
  final List<String> items;
  final int current;
  final ValueChanged<int> onChange;
  const _SubEffectGrid({required this.items, required this.current, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 3.2,
      children: List.generate(items.length, (i) {
        final on = i == current;
        return GestureDetector(
          onTap: () => onChange(i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: on ? AppColors.accentSoft : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: on ? AppColors.accent : AppColors.stroke, width: 0.5),
            ),
            child: Row(children: [
              Expanded(child: Text(items[i],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: on ? AppColors.accent : AppColors.text,
                    fontWeight: on ? FontWeight.w500 : FontWeight.normal,
                  ))),
              Text(i.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 10,
                    color: on ? AppColors.accent : AppColors.textFaint,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  )),
            ]),
          ),
        );
      }),
    );
  }
}
