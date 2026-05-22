// channel.dart — 通道抽象接口
// WebSocket / MQTT 通道实现此接口，ConnectionManager 持有当前激活的 Channel。

import 'dart:async';

enum ChannelState { idle, connecting, connected, error, disconnected }

/// 入站消息（已 JSON 解析）
typedef IncomingMessage = Map<String, dynamic>;

abstract class Channel {
  /// 通道类型标识
  String get kind;

  /// 当前连接状态
  ChannelState get state;
  Stream<ChannelState> get stateStream;

  /// 估算 RTT 毫秒数（直连可测，MQTT 通常为 null）
  int? get rttMs;

  /// 入站消息流（设备 → App）
  Stream<IncomingMessage> get incoming;

  /// 连接（超时由实现内决定，连不上 throws/return false）
  Future<bool> connect();

  /// 发送 JSON 消息（App → 设备）
  void send(Map<String, dynamic> json);

  /// 关闭通道
  Future<void> close();
}
