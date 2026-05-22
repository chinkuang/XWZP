// tetris_screen.dart — 俄罗斯方块横屏控制器

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/effect_modes.dart';
import '../../core/providers/device_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../theme.dart';
import 'game_pad_widgets.dart';

class TetrisScreen extends ConsumerStatefulWidget {
  const TetrisScreen({super.key});
  @override
  ConsumerState<TetrisScreen> createState() => _TetrisScreenState();
}

class _TetrisScreenState extends ConsumerState<TetrisScreen> {
  bool editMode = false;
  String? pressed;
  bool paused = false;
  int score = 0;
  int lines = 0;
  int level = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(connectionManagerProvider).gameStart('tetris'));
    ref.listenManual<AsyncValue<GameEvent>>(gameEventProvider, (prev, next) {
      next.whenData((ev) {
        if (ev.evt == 'score') setState(() => score = ev.val);
      });
    });
  }

  @override
  void dispose() {
    ref.read(connectionManagerProvider).gameQuit();
    super.dispose();
  }

  void _press(String key, GameDir? dir) {
    setState(() => pressed = key);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => pressed = null);
    });
    if (dir != null) {
      ref.read(connectionManagerProvider).gameInput(dir.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsN = ref.read(settingsProvider.notifier);
    final layout = settings.tetrisLayout;

    Widget btn(String key, IconData icon, String caption, GameDir? dir, {bool primary = false}) {
      return GamePadButton(
        pos: layout[key]!,
        icon: icon,
        caption: caption,
        primary: primary,
        editMode: editMode,
        showCaption: settings.gameShowLabels,
        pressed: key == 'pause' ? paused : pressed == key,
        onTap: () {
          if (key == 'pause') {
            setState(() => paused = !paused);
          } else if (key == 'hard') {
            _press('hard', null);
            setState(() => score += 10);
          } else {
            _press(key, dir);
          }
        },
        onDrag: (d) => settingsN.setTetrisLayout(key, _clamp(layout[key]! + d)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(children: [
          GameTopBar(
            title: '俄罗斯方块',
            center: Row(mainAxisSize: MainAxisSize.min, children: [
              InlineStat(label: '分数', value: '$score', accent: true),
              _div(),
              InlineStat(label: '行数', value: '$lines'),
              _div(),
              InlineStat(label: '级别', value: '$level'),
            ]),
            editMode: editMode,
            showLabels: settings.gameShowLabels,
            onBack: () => Navigator.of(context).pop(),
            onToggleEdit: () => setState(() => editMode = !editMode),
            onToggleLabels: () => settingsN.update(settings.copyWith(gameShowLabels: !settings.gameShowLabels)),
          ),
          Expanded(
            child: Stack(children: [
              btn('left',  CupertinoIcons.arrow_left,  '左移', GameDir.left),
              btn('right', CupertinoIcons.arrow_right, '右移', GameDir.right),
              btn('soft',  CupertinoIcons.arrow_down,  '软降', GameDir.down),
              btn('rotL',  CupertinoIcons.arrow_counterclockwise, '左旋', GameDir.up),
              btn('rotR',  CupertinoIcons.arrow_clockwise, '右旋', GameDir.up),
              btn('hard',  CupertinoIcons.square_arrow_down_fill, '直落', null, primary: true),
              btn('pause', paused ? CupertinoIcons.play_fill : CupertinoIcons.pause_fill,
                  paused ? '继续' : '暂停', null, primary: true),
              if (editMode)
                const Positioned(
                  left: 0, right: 0, bottom: 6,
                  child: Center(child: Text(
                    '长按拖动按键到喜欢的位置 · 完成后点击右上角「完成」保存',
                    style: TextStyle(fontSize: 11, color: AppColors.textFaint),
                  )),
                ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _div() => Container(width: 0.5, height: 20, color: AppColors.stroke, margin: const EdgeInsets.symmetric(horizontal: 12));

  Offset _clamp(Offset o) => Offset(
    o.dx.clamp(8.0, MediaQuery.of(context).size.width - GamePadButton.size - 8),
    o.dy.clamp(8.0, MediaQuery.of(context).size.height - GamePadButton.size - 8 - 56),
  );
}
