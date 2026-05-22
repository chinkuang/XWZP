import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/device_provider.dart';
import '../../core/models/device_state.dart';
import '../../shared/widgets/lrp_card.dart';
import '../../shared/widgets/lrp_switch_tile.dart';
import '../../shared/widgets/channel_badge.dart';
import '../../theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceStateProvider);
    final ch = state.channel;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
              sliver: SliverList.list(children: [
                _NavTitle(title: '律动灯', subtitle: '${channelLabel(ch)} · ${state.wifiSsid.isNotEmpty ? state.wifiSsid : "未连接"}'),
                const SizedBox(height: 16),
                _StatusStrip(state: state),
                const SizedBox(height: 12),
                _ReadingsRow(state: state),
                const SizedBox(height: 12),
                _QuickGrid(),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const _NavTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.text)),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textDim)),
      ],
    );
  }
}

class _StatusStrip extends StatelessWidget {
  final DeviceState state;
  const _StatusStrip({required this.state});
  @override
  Widget build(BuildContext context) {
    return LrpCard(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatusDot(icon: CupertinoIcons.wifi, label: 'WiFi', on: state.wifiConn),
          _div(),
          _StatusDot(icon: CupertinoIcons.bluetooth, label: '蓝牙', on: state.btConn),
          _div(),
          _StatusDot(
            icon: state.channel == ConnectionChannel.offline ? CupertinoIcons.wifi_slash : CupertinoIcons.cloud,
            label: state.channel == ConnectionChannel.lan ? 'LAN' : state.channel == ConnectionChannel.mqtt ? 'MQTT' : '离线',
            on: state.channel != ConnectionChannel.offline,
            accent: true,
          ),
        ],
      ),
    );
  }

  Widget _div() => Container(width: 0.5, height: 28, color: AppColors.stroke);
}

class _StatusDot extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool on;
  final bool accent;
  const _StatusDot({required this.icon, required this.label, required this.on, this.accent = false});

  @override
  Widget build(BuildContext context) {
    final color = on ? (accent ? AppColors.accent : AppColors.text) : AppColors.textFaint;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(clipBehavior: Clip.none, children: [
          Icon(icon, size: 18, color: color),
          Positioned(
            right: -3, bottom: -2,
            child: Container(
              width: 7, height: 7,
              decoration: BoxDecoration(
                color: on ? AppColors.success : AppColors.danger,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 1.5),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textDim)),
      ],
    );
  }
}

class _ReadingsRow extends StatelessWidget {
  final DeviceState state;
  const _ReadingsRow({required this.state});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Tile(label: '灯光', value: _pct(state.brightnessSub, 0, 255), unit: '%')),
        const SizedBox(width: 8),
        Expanded(child: _Tile(label: '主屏', value: _pct(state.brightnessMain, 10, 255), unit: '%')),
        const SizedBox(width: 8),
        Expanded(child: _Tile(label: '音量', value: state.vol, unit: '%')),
      ],
    );
  }
  int _pct(int v, int min, int max) => ((v - min) / (max - min) * 100).round();
}

class _Tile extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  const _Tile({required this.label, required this.value, required this.unit});
  @override
  Widget build(BuildContext context) {
    return LrpCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textDim)),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text('$value', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.text)),
            const SizedBox(width: 1),
            Text(unit, style: const TextStyle(fontSize: 12, color: AppColors.textFaint)),
          ]),
        ],
      ),
    );
  }
}

class _QuickGrid extends ConsumerWidget {
  const _QuickGrid();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceStateProvider);
    final n = ref.read(deviceStateProvider.notifier);
    return LrpCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          LrpSwitchTile(
            icon: CupertinoIcons.rectangle_grid_2x2,
            label: '主屏幕',
            sub: '16×16 矩阵屏',
            value: true, // 主屏没有独立开关，可挂接到 effect 是否非 OFF
            onChanged: (_) {},
          ),
          const LrpDivider(),
          LrpSwitchTile(
            icon: CupertinoIcons.tv,
            label: '副屏幕',
            sub: '',
            value: state.screenSub,
            onChanged: n.setScreenSub,
          ),
          const LrpDivider(),
          LrpSwitchTile(
            icon: CupertinoIcons.speaker_2_fill,
            label: '音响',
            sub: '蓝牙音频外放',
            value: state.speaker,
            onChanged: n.setSpeaker,
          ),
          const LrpDivider(),
          LrpSwitchTile(
            icon: CupertinoIcons.mic,
            label: '语音功能',
            sub: 'AI 对话与指令',
            value: state.voiceAi,
            onChanged: n.setVoiceAi,
          ),
        ],
      ),
    );
  }
}
