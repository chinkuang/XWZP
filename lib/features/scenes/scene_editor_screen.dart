// scene_editor_screen.dart — 编辑 / 新建场景

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/effect_modes.dart';
import '../../core/models/scene.dart';
import '../../core/providers/device_provider.dart';
import '../../shared/widgets/lrp_card.dart';
import '../../shared/widgets/lrp_slider.dart';
import '../../theme.dart';

const _sceneEmojis = ['🎬','🎉','📖','🌙','🌅','☕','🎵','💼','🌿','🎨','🎮','✨','🌸','🍿','🛋️'];

class SceneEditorScreen extends ConsumerStatefulWidget {
  final Scene scene;
  final bool isNew;
  const SceneEditorScreen({super.key, required this.scene, this.isNew = false});
  @override
  ConsumerState<SceneEditorScreen> createState() => _SceneEditorScreenState();
}

class _SceneEditorScreenState extends ConsumerState<SceneEditorScreen> {
  late Scene draft;
  late TextEditingController nameCtl;
  bool confirmDelete = false;

  @override
  void initState() {
    super.initState();
    draft = widget.scene;
    nameCtl = TextEditingController(text: draft.name);
  }

  void _cycleEmoji() {
    final i = (_sceneEmojis.indexOf(draft.icon) + 1) % _sceneEmojis.length;
    setState(() => draft = draft.copyWith(icon: _sceneEmojis[i]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text('编辑场景', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              final updated = draft.copyWith(name: nameCtl.text);
              if (widget.isNew) {
                ref.read(scenesProvider.notifier).add(updated);
              } else {
                ref.read(scenesProvider.notifier).update(updated);
              }
              Navigator.of(context).pop();
            },
            child: const Text('保存', style: TextStyle(color: AppColors.accent, fontSize: 15)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 6, 22, 24),
        children: [
          LrpCard(
            child: Row(children: [
              GestureDetector(
                onTap: _cycleEmoji,
                child: Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.stroke, width: 0.5),
                  ),
                  child: Center(child: Text(draft.icon, style: const TextStyle(fontSize: 28))),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('场景名称', style: TextStyle(fontSize: 11, color: AppColors.textFaint)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: nameCtl,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.text),
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                  ),
                ]),
              ),
            ]),
          ),

          const SizedBox(height: 12),
          const SectionHeader('灯光模式'),
          LrpCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              for (int i = 0; i < kTopEffects.length; i++) ...[
                _modeRow(kTopEffects[i]),
                if (i < kTopEffects.length - 1)
                  Container(height: 0.5, color: AppColors.stroke, margin: const EdgeInsets.only(left: 44)),
              ]
            ]),
          ),

          const SizedBox(height: 12),
          const SectionHeader('参数'),
          LrpCard(
            child: Column(children: [
              LrpSlider(label: '主屏亮度',
                value: (draft.brightnessMain ?? 200).toDouble(),
                min: 10, max: 255, fmt: (v) => '${((v - 10) / 245 * 100).round()}%',
                onChanged: (v) => setState(() => draft = draft.copyWith(brightnessMain: v.toInt()))),
              const SizedBox(height: 16),
              LrpSlider(label: '副屏亮度',
                value: (draft.brightnessSub ?? 180).toDouble(),
                min: 0, max: 255, fmt: (v) => '${(v / 255 * 100).round()}%',
                onChanged: (v) => setState(() => draft = draft.copyWith(brightnessSub: v.toInt()))),
              const SizedBox(height: 16),
              LrpSlider(label: '音量',
                value: (draft.vol ?? 75).toDouble(),
                min: 0, max: 100, fmt: (v) => '${v.round()}%',
                onChanged: (v) => setState(() => draft = draft.copyWith(vol: v.toInt()))),
              const SizedBox(height: 16),
              LrpSlider(label: '动画速度',
                value: (draft.speed ?? 5).toDouble(),
                min: 1, max: 10, divisions: 9, fmt: (v) => '${v.round()}/10',
                onChanged: (v) => setState(() => draft = draft.copyWith(speed: v.toInt()))),
            ]),
          ),

          const SizedBox(height: 16),
          if (!widget.isNew) ...[
            if (!confirmDelete)
              OutlinedButton(
                onPressed: () => setState(() => confirmDelete = true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.stroke, width: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('删除此场景'),
              )
            else
              LrpCard(
                borderColor: AppColors.danger,
                child: Column(children: [
                  Text('确定删除「${draft.name}」？', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: OutlinedButton(
                      onPressed: () => setState(() => confirmDelete = false),
                      child: const Text('取消'),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: FilledButton(
                      onPressed: () {
                        ref.read(scenesProvider.notifier).remove(draft.id);
                        Navigator.of(context).pop();
                      },
                      style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
                      child: const Text('删除'),
                    )),
                  ]),
                ]),
              ),
          ],
        ],
      ),
    );
  }

  Widget _modeRow(TopEffect e) {
    final on = draft.effect == e.value;
    return InkWell(
      onTap: () => setState(() => draft = draft.copyWith(effect: e.value)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Icon(CupertinoIcons.waveform, size: 16, color: on ? AppColors.accent : AppColors.textDim),
          const SizedBox(width: 12),
          Expanded(child: Text(e.name, style: TextStyle(fontSize: 15, color: on ? AppColors.accent : AppColors.text))),
          if (on) const Icon(CupertinoIcons.checkmark, size: 14, color: AppColors.accent),
        ]),
      ),
    );
  }
}
