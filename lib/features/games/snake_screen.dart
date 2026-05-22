// snake_screen.dart — 贪吃蛇横屏控制器

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/effect_modes.dart';
import '../../core/providers/device_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../theme.dart';
import 'game_pad_widgets.dart';

class SnakeScreen extends ConsumerStatefulWidget {
  const SnakeScreen({super.key});
  @override
  ConsumerState<SnakeScreen> createState() => _SnakeScreenState();
}

class _SnakeScreenState extends ConsumerState<SnakeScreen> {
  bool editMode = false;
  String? pressed;
  bool paused = false;
  int score = 0;
  int high = 0;

  @override
  void initState() {
    super.initState();
    // 启动游戏
    Future.microtask(() => ref.read(connectionManagerProvider).gameStart('snake'));
    // 监听游戏事件
    ref.listenManual<AsyncValue<GameEvent>>(gameEventProvider, (prev, next) {
      next.whenData((ev) {
        if (ev.evt == 'score') setState(() => score = ev.val);
        if (ev.evt == 'game_over') setState(() => high = ev.val > high ? ev.val : high);
      });
    });
  }

  @override
  void dispose() {
    // 退出时通知设备退出
    ref.read(connectionManagerProvider).gameQuit();
    super.dispose();
  }

  void _press(String key, GameDir dir) {
    setState(() => pressed = key);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => pressed = null);
    });
    ref.read(connectionManagerProvider).gameInput(dir.value);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsN = ref.read(settingsProvider.notifier);
    final layout = settings.snakeLayout;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(children: [
          GameTopBar(
            title: '贪吃蛇',
            center: Row(mainAxisSize: MainAxisSize.min, children: [
              InlineStat(label: '分数', value: '$score', accent: true),
              Container(width: 0.5, height: 20, color: AppColors.stroke, margin: const EdgeInsets.symmetric(horizontal: 12)),
              InlineStat(label: '最高', value: '$high'),
            ]),
            editMode: editMode,
            showLabels: settings.gameShowLabels,
            onBack: () => Navigator.of(context).pop(),
            onToggleEdit: () => setState(() => editMode = !editMode),
            onToggleLabels: () => settingsN.update(settings.copyWith(gameShowLabels: !settings.gameShowLabels)),
          ),
          Expanded(
            child: Stack(children: [
              if (editMode)
                Positioned.fill(
                  child: CustomPaint(painter: _DragGridPainter()),
                ),
              GamePadButton(
                pos: layout['up']!,
                icon: CupertinoIcons.arrow_up,
                caption: '上',
                editMode: editMode,
                showCaption: settings.gameShowLabels,
                pressed: pressed == 'up',
                onTap: () => _press('up', GameDir.up),
                onDrag: (d) => settingsN.setSnakeLayout('up', _clamp(layout['up']! + d)),
              ),
              GamePadButton(
                pos: layout['down']!,
                icon: CupertinoIcons.arrow_down,
                caption: '下',
                editMode: editMode,
                showCaption: settings.gameShowLabels,
                pressed: pressed == 'down',
                onTap: () => _press('down', GameDir.down),
                onDrag: (d) => settingsN.setSnakeLayout('down', _clamp(layout['down']! + d)),
              ),
              GamePadButton(
                pos: layout['left']!,
                icon: CupertinoIcons.arrow_left,
                caption: '左',
                editMode: editMode,
                showCaption: settings.gameShowLabels,
                pressed: pressed == 'left',
                onTap: () => _press('left', GameDir.left),
                onDrag: (d) => settingsN.setSnakeLayout('left', _clamp(layout['left']! + d)),
              ),
              GamePadButton(
                pos: layout['right']!,
                icon: CupertinoIcons.arrow_right,
                caption: '右',
                editMode: editMode,
                showCaption: settings.gameShowLabels,
                pressed: pressed == 'right',
                onTap: () => _press('right', GameDir.right),
                onDrag: (d) => settingsN.setSnakeLayout('right', _clamp(layout['right']! + d)),
              ),
              GamePadButton(
                pos: layout['pause']!,
                icon: paused ? CupertinoIcons.play_fill : CupertinoIcons.pause_fill,
                caption: paused ? '继续' : '暂停',
                primary: true,
                editMode: editMode,
                showCaption: settings.gameShowLabels,
                pressed: paused,
                onTap: () => setState(() => paused = !paused),
                onDrag: (d) => settingsN.setSnakeLayout('pause', _clamp(layout['pause']! + d)),
              ),
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

  Offset _clamp(Offset o) => Offset(
    o.dx.clamp(8.0, MediaQuery.of(context).size.width - GamePadButton.size - 8),
    o.dy.clamp(8.0, MediaQuery.of(context).size.height - GamePadButton.size - 8 - 56),
  );
}

class _DragGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x05FFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);
  }
  @override
  bool shouldRepaint(_) => false;
}
