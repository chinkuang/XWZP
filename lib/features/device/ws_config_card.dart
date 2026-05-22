// ws_config_card.dart — 设备页 WebSocket 连接配置卡片
//
// 默认 ws://lrp-s3.local:81/ws，安装时自动连接；
// 用户可以改 host/port，「测试连接」按钮会重连。

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/connection/channel.dart';
import '../../core/providers/device_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../shared/widgets/lrp_card.dart';
import '../../theme.dart';

class WsConfigCard extends ConsumerStatefulWidget {
  const WsConfigCard({super.key});
  @override
  ConsumerState<WsConfigCard> createState() => _WsConfigCardState();
}

class _WsConfigCardState extends ConsumerState<WsConfigCard> {
  late TextEditingController hostCtl;
  late TextEditingController portCtl;
  bool testing = false;
  ChannelState? testResult;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    hostCtl = TextEditingController(text: s.wsHost);
    portCtl = TextEditingController(text: s.wsPort.toString());
  }

  @override
  void dispose() {
    hostCtl.dispose();
    portCtl.dispose();
    super.dispose();
  }

  Future<void> _test() async {
    setState(() => testing = true);
    final host = hostCtl.text.trim();
    final port = int.tryParse(portCtl.text.trim()) ?? 81;
    final settingsN = ref.read(settingsProvider.notifier);
    settingsN.update(ref.read(settingsProvider).copyWith(wsHost: host, wsPort: port));
    await ref.read(connectionManagerProvider).reconnectWs(host: host, port: port);
    if (!mounted) return;
    setState(() {
      testing = false;
      testResult = ref.read(connectionManagerProvider).channel.toString().contains('lan')
          ? ChannelState.connected
          : ChannelState.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mgr = ref.watch(connectionManagerProvider);
    final wsConnected = mgr.channel.toString().contains('lan');
    Color stateColor;
    String stateLabel;
    if (testing) {
      stateColor = AppColors.warning;
      stateLabel = '连接中…';
    } else if (wsConnected) {
      stateColor = AppColors.success;
      stateLabel = '已连接';
    } else {
      stateColor = AppColors.textFaint;
      stateLabel = '未连接';
    }

    return LrpCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('WebSocket 直连', style: TextStyle(fontSize: 12, color: AppColors.textDim)),
            const SizedBox(height: 4),
            Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: stateColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(stateLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ]),
          ]),
          const Spacer(),
          FilledButton(
            onPressed: testing ? null : _test,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(testing ? '测试中…' : '测试连接', style: const TextStyle(fontSize: 13)),
          ),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.stroke, width: 0.5),
          ),
          child: Row(children: [
            const Text('ws://', style: TextStyle(fontSize: 13, color: AppColors.textFaint)),
            Expanded(child: TextField(
              controller: hostCtl,
              style: const TextStyle(fontSize: 13, color: AppColors.text),
              decoration: const InputDecoration(
                hintText: 'lrp-s3.local 或 192.168.x.x',
                hintStyle: TextStyle(color: AppColors.textFaint),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            )),
            const Text(':', style: TextStyle(fontSize: 13, color: AppColors.textFaint)),
            SizedBox(width: 50, child: TextField(
              controller: portCtl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, color: AppColors.text),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            )),
            const Text(' /ws', style: TextStyle(fontSize: 13, color: AppColors.textFaint)),
          ]),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('首次安装自动连接 · 默认通过 mDNS 发现',
              style: TextStyle(fontSize: 11, color: AppColors.textFaint)),
          TextButton(
            onPressed: () {
              setState(() {
                hostCtl.text = 'lrp-s3.local';
                portCtl.text = '81';
              });
            },
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('恢复默认', style: TextStyle(fontSize: 11, color: AppColors.accent)),
          ),
        ]),
      ]),
    );
  }
}
