// device_screen.dart — 设备信息、连接配置、外观、协议日志

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/device_state.dart';
import '../../core/providers/device_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../shared/widgets/lrp_card.dart';
import '../../shared/widgets/channel_badge.dart';
import '../../theme.dart';
import 'ws_config_card.dart';
import 'appearance_card.dart';

class DeviceScreen extends ConsumerWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceStateProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
          children: [
            const Text('设备', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('状态、连接与配置', style: TextStyle(fontSize: 13, color: AppColors.textDim)),
            const SizedBox(height: 16),

            // 当前通讯通道
            LrpCard(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('当前通道', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(channelIcon(state.channel), size: 16, color: channelColor(state.channel)),
                    const SizedBox(width: 8),
                    Text(channelLabel(state.channel),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ]),
                  if (state.rttMs != null) ...[
                    const SizedBox(height: 4),
                    Text('RTT ${state.rttMs}ms',
                        style: const TextStyle(fontSize: 11, color: AppColors.textFaint)),
                  ],
                ]),
              ]),
            ),

            const SizedBox(height: 12),
            const WsConfigCard(),

            const SizedBox(height: 12),
            // 连接信息
            LrpCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                _row(CupertinoIcons.wifi, 'WiFi', '仅 2.4GHz', state.wifiSsid.isEmpty ? '未连接' : state.wifiSsid),
                _divider(),
                _row(CupertinoIcons.bluetooth, '蓝牙', 'A2DP 音频接收',
                    state.btConn ? (state.btDevice.isEmpty ? '已连接' : state.btDevice) : '未连接'),
                _divider(),
                _row(CupertinoIcons.speaker_2_fill, '当前音量', null, '${state.vol}%'),
              ]),
            ),

            const SizedBox(height: 12),
            const AppearanceCard(),

            const SizedBox(height: 12),
            // 副屏频谱预览（仅 LAN 推送）
            if (state.channel == ConnectionChannel.lan)
              const _SpectrumPreview(),

            const SizedBox(height: 12),
            // MQTT 信息
            LrpCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                _row(CupertinoIcons.cloud, 'MQTT', 'ThingsCloud · attributes',
                    state.channel == ConnectionChannel.mqtt ? '在线' : '兜底通道'),
                _divider(),
                _row(null, '上报频率', '5 秒一次', '5 s'),
              ]),
            ),

            const SizedBox(height: 12),
            // 本地按钮速查
            LrpCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('本地按钮', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
                const SizedBox(height: 10),
                _btnRow('GPIO26', '长按 3 秒', 'AP 配网', warn: true),
                _btnRow('GPIO13', '菜单', '循环切换'),
                _btnRow('GPIO14', '加 +', '调大数值'),
                _btnRow('GPIO27', '减 -', '调小数值'),
              ]),
            ),

            const SizedBox(height: 16),
            const Center(child: Text('固件 2.1.0 · ESP32-S3 · FFT 1024@44.1kHz',
                style: TextStyle(fontSize: 11, color: AppColors.textFaint))),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData? icon, String label, String? sub, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        if (icon != null) ...[
          Icon(icon, size: 17, color: AppColors.textDim),
          const SizedBox(width: 12),
        ],
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          if (sub != null) Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textFaint)),
          ),
        ])),
        Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textDim)),
      ]),
    );
  }

  Widget _divider() => Container(height: 0.5, color: AppColors.stroke, margin: const EdgeInsets.only(left: 48));

  Widget _btnRow(String pin, String action, String desc, {bool warn = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: warn ? const Color(0x1AFF9F0A) : AppColors.surface2,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: warn ? const Color(0x4DFF9F0A) : AppColors.stroke, width: 0.5),
          ),
          child: Text(pin, style: TextStyle(fontSize: 11,
              color: warn ? AppColors.warning : AppColors.text,
              fontFeatures: const [FontFeature.tabularFigures()])),
        ),
        const SizedBox(width: 12),
        SizedBox(width: 70, child: Text(action, style: const TextStyle(fontSize: 13, color: AppColors.textDim))),
        Text(desc, style: const TextStyle(fontSize: 13)),
      ]),
    );
  }
}

class _SpectrumPreview extends ConsumerWidget {
  const _SpectrumPreview();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spec = ref.watch(spectrumProvider);
    final bands = spec.maybeWhen(
      data: (f) => f.bands,
      orElse: () => const <int>[],
    );
    return LrpCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('主屏实时镜像', style: TextStyle(fontSize: 11, color: AppColors.textFaint)),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: bands.isEmpty
              ? const Center(child: Text('等待频谱数据...',
                  style: TextStyle(fontSize: 11, color: AppColors.textFaint)))
              : Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  for (final b in bands) Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Container(
                      height: (b / 100) * 60,
                      decoration: BoxDecoration(
                        color: AppColors.text,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
                ]),
        ),
      ]),
    );
  }
}
