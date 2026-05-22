import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../theme.dart';
import '../../core/models/device_state.dart';

/// 通讯通道彩色徽标 (LAN / MQTT / 离线)
class ChannelBadge extends StatelessWidget {
  final ConnectionChannel channel;
  final int? rttMs;
  final bool compact;

  const ChannelBadge({
    super.key,
    required this.channel,
    this.rttMs,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final info = _info(channel);
    final rtt = rttMs != null ? '${rttMs}ms' : '—';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.stroke, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: 11, color: info.color),
          const SizedBox(width: 4),
          Text('${info.short}${compact ? "" : " · $rtt"}',
              style: TextStyle(fontSize: 11, color: info.color)),
        ],
      ),
    );
  }
}

class _ChannelInfo {
  final String label;
  final String short;
  final IconData icon;
  final Color color;
  const _ChannelInfo(this.label, this.short, this.icon, this.color);
}

_ChannelInfo _info(ConnectionChannel ch) {
  switch (ch) {
    case ConnectionChannel.lan:
      return const _ChannelInfo('本地直连', 'LAN', CupertinoIcons.link, AppColors.accent);
    case ConnectionChannel.mqtt:
      return const _ChannelInfo('云端 MQTT', 'MQTT', CupertinoIcons.cloud, AppColors.success);
    case ConnectionChannel.offline:
      return const _ChannelInfo('离线', '—', CupertinoIcons.wifi_slash, AppColors.textFaint);
  }
}

String channelLabel(ConnectionChannel ch) => _info(ch).label;
IconData channelIcon(ConnectionChannel ch) => _info(ch).icon;
Color channelColor(ConnectionChannel ch) => _info(ch).color;
