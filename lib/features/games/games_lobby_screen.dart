// games_lobby_screen.dart — 游戏选择入口
//
// MQTT 通道下显示 RTT 较高的警告，但仍允许进入。

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../core/models/device_state.dart';
import '../../core/providers/device_provider.dart';
import '../../shared/widgets/lrp_card.dart';
import '../../shared/widgets/channel_badge.dart';
import '../../theme.dart';
import 'snake_screen.dart';
import 'tetris_screen.dart';

class GamesLobbyScreen extends ConsumerWidget {
  const GamesLobbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceStateProvider);
    final lowLatency = state.channel == ConnectionChannel.lan;
    final rtt = state.rttMs ?? (state.channel == ConnectionChannel.mqtt ? 280 : null);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
          children: [
            const Text('游戏', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('副屏小游戏', style: TextStyle(fontSize: 13, color: AppColors.textDim)),
            const SizedBox(height: 16),

            LrpCard(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('当前延迟', style: TextStyle(fontSize: 11, color: AppColors.textFaint)),
                  const SizedBox(height: 4),
                  Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                    Text(rtt != null ? '$rtt' : '—',
                        style: TextStyle(fontSize: 22,
                          color: lowLatency ? AppColors.success : (rtt != null ? AppColors.warning : AppColors.danger))),
                    const SizedBox(width: 4),
                    const Text('ms RTT', style: TextStyle(fontSize: 12, color: AppColors.textFaint)),
                  ]),
                ]),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('通道', style: TextStyle(fontSize: 11, color: AppColors.textFaint)),
                  const SizedBox(height: 4),
                  Text(channelLabel(state.channel),
                      style: TextStyle(fontSize: 14, color: channelColor(state.channel))),
                ]),
              ]),
            ),

            if (!lowLatency) ...[
              const SizedBox(height: 12),
              LrpCard(
                background: const Color(0x14FF9F0A),
                borderColor: const Color(0x4DFF9F0A),
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: const [
                    Icon(CupertinoIcons.exclamationmark_triangle, size: 16, color: AppColors.warning),
                    SizedBox(width: 8),
                    Text('延迟较高', style: TextStyle(fontSize: 13, color: AppColors.warning, fontWeight: FontWeight.w500)),
                  ]),
                  const SizedBox(height: 6),
                  const Text(
                    '当前通过 MQTT 转发，响应不灵敏。\n建议与设备在同一 WiFi 下游玩获得最佳体验。',
                    style: TextStyle(fontSize: 12, color: AppColors.textDim, height: 1.5),
                  ),
                ]),
              ),
            ],

            const SizedBox(height: 12),
            _GameCard(
              title: '贪吃蛇',
              en: 'Snake',
              desc: '经典像素蛇 · 副屏 16×16',
              onPlay: () => _enterGame(context, 'snake'),
            ),

            const SizedBox(height: 12),
            _GameCard(
              title: '俄罗斯方块',
              en: 'Tetris',
              desc: '经典消除游戏 · 副屏 16×16',
              onPlay: () => _enterGame(context, 'tetris'),
            ),

            const SizedBox(height: 16),
            const Center(child: Text('游戏运行在 ESP32 副屏上，手机仅作为遥控器',
                style: TextStyle(fontSize: 11, color: AppColors.textFaint))),
          ],
        ),
      ),
    );
  }

  void _enterGame(BuildContext context, String game) {
    // 强制横屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => game == 'snake' ? const SnakeScreen() : const TetrisScreen(),
    )).then((_) {
      // 退出后恢复竖屏
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    });
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String en;
  final String desc;
  final VoidCallback onPlay;
  const _GameCard({required this.title, required this.en, required this.desc, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return LrpCard(
      padding: const EdgeInsets.all(18),
      child: Row(children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.stroke, width: 0.5),
          ),
          alignment: Alignment.center,
          child: Icon(
            title == '贪吃蛇' ? CupertinoIcons.circle_grid_hex_fill : CupertinoIcons.square_grid_2x2,
            size: 28, color: AppColors.textDim,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Text(en, style: const TextStyle(fontSize: 11, color: AppColors.textFaint)),
          ]),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textDim)),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onPlay,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('开始游戏', style: TextStyle(fontSize: 13)),
          ),
        ])),
      ]),
    );
  }
}
