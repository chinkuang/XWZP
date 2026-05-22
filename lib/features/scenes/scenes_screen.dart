// scenes_screen.dart — 场景列表 + 应用 + 编辑入口

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/effect_modes.dart';
import '../../core/models/scene.dart';
import '../../core/providers/device_provider.dart';
import '../../shared/widgets/lrp_card.dart';
import '../../theme.dart';
import 'scene_editor_screen.dart';

class ScenesScreen extends ConsumerWidget {
  const ScenesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenes = ref.watch(scenesProvider);
    final state = ref.watch(deviceStateProvider);
    final n = ref.read(deviceStateProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
          children: [
            const Text('场景', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('一键切换常用配置', style: TextStyle(fontSize: 13, color: AppColors.textDim)),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                for (final sc in scenes)
                  _SceneCard(
                    scene: sc,
                    onApply: () => n.applyScene(sc),
                    onEdit: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => SceneEditorScreen(scene: sc),
                    )),
                  ),
                _AddSceneCard(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SceneEditorScreen(
                      scene: Scene(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: '新场景',
                        icon: '✨',
                        effect: state.effect,
                        dynEffect: state.dynEffect,
                        ambEffect: state.ambEffect,
                        brightnessMain: state.brightnessMain,
                        brightnessSub: state.brightnessSub,
                        vol: state.vol,
                        speed: state.speed,
                        speaker: state.speaker,
                      ),
                      isNew: true,
                    ),
                  )),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Center(
              child: Text('点击场景应用 · 右下角齿轮调整或删除',
                  style: TextStyle(fontSize: 11, color: AppColors.textFaint)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SceneCard extends StatelessWidget {
  final Scene scene;
  final VoidCallback onApply;
  final VoidCallback onEdit;
  const _SceneCard({required this.scene, required this.onApply, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GestureDetector(
        onTap: onApply,
        child: LrpCard(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(scene.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(scene.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 2, children: [
              if (scene.effect != null) Text(kTopEffects[scene.effect!.clamp(0, kTopEffects.length - 1)].name,
                  style: const TextStyle(fontSize: 11, color: AppColors.textFaint)),
              if (scene.brightnessMain != null) Text('亮度 ${((scene.brightnessMain! - 10) / 245 * 100).round()}%',
                  style: const TextStyle(fontSize: 11, color: AppColors.textFaint)),
              if (scene.vol != null) Text('音量 ${scene.vol}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textFaint)),
            ]),
          ]),
        ),
      ),
      Positioned(
        right: 8, bottom: 8,
        child: GestureDetector(
          onTap: onEdit,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: AppColors.surface2,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.stroke, width: 0.5),
            ),
            child: const Icon(CupertinoIcons.gear_alt, size: 13, color: AppColors.textDim),
          ),
        ),
      ),
    ]);
  }
}

class _AddSceneCard extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddSceneCard({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.l),
          border: Border.all(color: AppColors.strokeStrong, width: 1, style: BorderStyle.solid),
        ),
        child: const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(CupertinoIcons.add, size: 22, color: AppColors.textDim),
            SizedBox(height: 6),
            Text('新建场景', style: TextStyle(fontSize: 13, color: AppColors.textDim)),
          ]),
        ),
      ),
    );
  }
}
