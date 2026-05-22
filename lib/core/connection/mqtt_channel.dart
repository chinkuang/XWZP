// mqtt_channel.dart — ThingsCloud MQTT 兜底通道
//
// 用于不同网络下的状态同步和指令下发，延迟 100-500ms，不适合游戏。

import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'channel.dart';

class MqttChannel implements Channel {
  // 与固件 include/config.h 保持一致
  static const _host = 'sh-3-mqtt.iot-api.com';
  static const _port = 1883;
  static const _user = '29le7p1woltrsop4';  // AccessToken
  static const _pass = 'Jdv8zcTWFL';        // ProjectKey
  static const _topicStatus = 'attributes';
  static const _topicCmd    = 'attributes/push';

  final _incoming = StreamController<IncomingMessage>.broadcast();
  final _stateCtl = StreamController<ChannelState>.broadcast();
  ChannelState _state = ChannelState.idle;
  MqttServerClient? _client;

  @override
  String get kind => 'mqtt';

  @override
  ChannelState get state => _state;

  @override
  Stream<ChannelState> get stateStream => _stateCtl.stream;

  @override
  int? get rttMs => null; // MQTT 不测 RTT

  @override
  Stream<IncomingMessage> get incoming => _incoming.stream;

  void _setState(ChannelState s) {
    if (_state == s) return;
    _state = s;
    _stateCtl.add(s);
  }

  @override
  Future<bool> connect() async {
    _setState(ChannelState.connecting);
    final clientId = 'xiwei-app-${DateTime.now().millisecondsSinceEpoch}';
    final c = MqttServerClient(_host, clientId);
    c.port = _port;
    c.keepAlivePeriod = 30;
    c.logging(on: false);
    c.onDisconnected = () => _setState(ChannelState.disconnected);
    c.onConnected = () => _setState(ChannelState.connected);

    final connMsg = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(_user, _pass)
        .startClean();
    c.connectionMessage = connMsg;

    try {
      await c.connect(_user, _pass).timeout(const Duration(seconds: 5));
    } catch (e) {
      _setState(ChannelState.error);
      c.disconnect();
      return false;
    }

    if (c.connectionStatus?.state != MqttConnectionState.connected) {
      _setState(ChannelState.error);
      return false;
    }

    // 订阅 attributes/push（设备主动推送）
    c.subscribe(_topicCmd, MqttQos.atMostOnce);
    c.updates?.listen(_onMqttPacket);
    _client = c;
    return true;
  }

  void _onMqttPacket(List<MqttReceivedMessage<MqttMessage>> events) {
    for (final ev in events) {
      final pubMsg = ev.payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(
          pubMsg.payload.message);
      try {
        final json = jsonDecode(payload);
        if (json is Map) {
          final map = json.cast<String, dynamic>();
          // 设备的 MQTT payload 没有 "t" 字段，给它套一个 "state"
          map['t'] ??= 'state';
          _incoming.add(map);
        }
      } catch (_) {}
    }
  }

  @override
  void send(Map<String, dynamic> json) {
    final c = _client;
    if (c == null || c.connectionStatus?.state != MqttConnectionState.connected) return;
    final builder = MqttClientPayloadBuilder()..addString(jsonEncode(json));
    c.publishMessage(_topicStatus, MqttQos.atMostOnce, builder.payload!);
  }

  @override
  Future<void> close() async {
    _client?.disconnect();
    _client = null;
    _setState(ChannelState.disconnected);
  }
}
