// connection_manager.dart — 双通道自动切换
//
// 策略：
//   1. App 启动时尝试 WS 直连（先 lastHost，再 mDNS 发现）
//   2. WS 连上 → 走 WS（低延迟，支持游戏 / 频谱推送）
//   3. WS 连不上 → 回落 MQTT（用于不同网络下的状态同步和简单控制）
//   4. WS 断开时自动降级 MQTT；探测到 WS 可用时自动升级回 WS

import 'dart:async';

import '../models/device_state.dart';
import 'channel.dart';
import 'mqtt_channel.dart';
import 'ws_channel.dart';

class ConnectionManager {
  // 用户配置的 WS 地址，可被设备页修改
  String wsHost;
  int wsPort;
  final Duration probeTimeout;

  Channel? _active;
  final _stateCtl = StreamController<ConnectionChannel>.broadcast();
  final _incoming = StreamController<IncomingMessage>.broadcast();
  Timer? _upgradeTimer;
  StreamSubscription? _activeSub;
  StreamSubscription? _activeStateSub;

  ConnectionManager({
    this.wsHost = 'lrp-s3.local',
    this.wsPort = 81,
    this.probeTimeout = const Duration(milliseconds: 800),
  });

  /// 当前激活的通讯通道
  ConnectionChannel get channel {
    final a = _active;
    if (a == null || a.state != ChannelState.connected) {
      return ConnectionChannel.offline;
    }
    return a.kind == 'ws' ? ConnectionChannel.lan : ConnectionChannel.mqtt;
  }

  Stream<ConnectionChannel> get channelStream => _stateCtl.stream;

  /// 入站消息流（已合并 WS / MQTT）
  Stream<IncomingMessage> get incoming => _incoming.stream;

  int? get rttMs => _active?.rttMs;

  /// 启动 — 先 WS 后 MQTT
  Future<void> start() async {
    final ws = WsChannel(host: wsHost, port: wsPort, connectTimeout: probeTimeout);
    final ok = await ws.connect();
    if (ok) {
      _bind(ws);
    } else {
      await ws.close();
      await _fallbackToMqtt();
    }
    _scheduleUpgradeCheck();
  }

  /// 用户修改 WS 地址后重连
  Future<void> reconnectWs({String? host, int? port}) async {
    if (host != null) wsHost = host;
    if (port != null) wsPort = port;
    await _active?.close();
    _active = null;
    await start();
  }

  Future<void> _fallbackToMqtt() async {
    final mq = MqttChannel();
    final ok = await mq.connect();
    if (ok) {
      _bind(mq);
    } else {
      await mq.close();
      _stateCtl.add(ConnectionChannel.offline);
    }
  }

  void _bind(Channel c) {
    _active = c;
    _activeSub?.cancel();
    _activeStateSub?.cancel();
    _activeSub = c.incoming.listen(_incoming.add);
    _activeStateSub = c.stateStream.listen((_) {
      _stateCtl.add(channel);
      if (c.state == ChannelState.disconnected || c.state == ChannelState.error) {
        _onDrop();
      }
    });
    _stateCtl.add(channel);
  }

  Future<void> _onDrop() async {
    // 当前通道掉线
    if (_active?.kind == 'ws') {
      await _active?.close();
      _active = null;
      await _fallbackToMqtt();
    }
  }

  /// 定期尝试升级回 WS（每 30s）
  void _scheduleUpgradeCheck() {
    _upgradeTimer?.cancel();
    _upgradeTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (_active?.kind == 'ws') return;
      final ws = WsChannel(host: wsHost, port: wsPort, connectTimeout: probeTimeout);
      final ok = await ws.connect();
      if (ok) {
        final old = _active;
        _bind(ws);
        await old?.close();
      } else {
        await ws.close();
      }
    });
  }

  /// 发送 set 指令
  void setKey(String key, num val) {
    _active?.send({'t': 'set', 'key': key, 'val': val});
  }

  /// 发送 set 多个键（逐条发出）
  void setMany(Map<String, num> kv) {
    kv.forEach(setKey);
  }

  /// 拉取完整状态
  void getState() {
    _active?.send({'t': 'get_state'});
  }

  // ─── 游戏 ──────────────────────────
  void gameStart(String game) {
    _active?.send({'t': 'game', 'action': 'start', 'game': game});
  }

  void gameInput(int dir) {
    _active?.send({'t': 'game', 'action': 'input', 'dir': dir});
  }

  void gameQuit() {
    _active?.send({'t': 'game', 'action': 'quit'});
  }

  Future<void> dispose() async {
    _upgradeTimer?.cancel();
    await _activeSub?.cancel();
    await _activeStateSub?.cancel();
    await _active?.close();
    await _stateCtl.close();
    await _incoming.close();
  }
}
