// ws_channel.dart — WebSocket 直连（ws://<host>:81/ws）

import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import 'channel.dart';

class WsChannel implements Channel {
  final String host;
  final int port;
  final Duration connectTimeout;
  final Duration pingInterval;

  WebSocketChannel? _ws;
  StreamSubscription? _sub;
  final _incoming = StreamController<IncomingMessage>.broadcast();
  final _stateCtl = StreamController<ChannelState>.broadcast();
  ChannelState _state = ChannelState.idle;
  int? _rttMs;
  Timer? _pingTimer;
  DateTime? _pingSentAt;

  WsChannel({
    required this.host,
    this.port = 81,
    this.connectTimeout = const Duration(milliseconds: 800),
    this.pingInterval = const Duration(seconds: 5),
  });

  @override
  String get kind => 'ws';

  @override
  ChannelState get state => _state;

  @override
  Stream<ChannelState> get stateStream => _stateCtl.stream;

  @override
  int? get rttMs => _rttMs;

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
    final uri = Uri.parse('ws://$host:$port/ws');
    try {
      final ws = WebSocketChannel.connect(uri);
      // 在 timeout 内必须至少完成 handshake；用 ready future 判断
      await ws.ready.timeout(connectTimeout);
      _ws = ws;
      _sub = ws.stream.listen(_onMessage,
          onError: _onError, onDone: _onDone, cancelOnError: false);
      _setState(ChannelState.connected);
      // 连接后立即发 get_state
      send({'t': 'get_state'});
      _startPing();
      return true;
    } catch (e) {
      _setState(ChannelState.error);
      _ws = null;
      return false;
    }
  }

  void _onMessage(dynamic data) {
    if (data is! String) return;
    try {
      final json = jsonDecode(data);
      if (json is! Map) return;
      final map = json.cast<String, dynamic>();
      // pong 用于测 RTT
      if (map['t'] == 'pong' && _pingSentAt != null) {
        _rttMs = DateTime.now().difference(_pingSentAt!).inMilliseconds;
      }
      _incoming.add(map);
    } catch (_) {
      // ignore bad frames
    }
  }

  void _onError(Object err) {
    _setState(ChannelState.error);
  }

  void _onDone() {
    _setState(ChannelState.disconnected);
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(pingInterval, (_) {
      if (_state != ChannelState.connected) return;
      _pingSentAt = DateTime.now();
      // 固件可定义 ping/pong；如未实现则 RTT 估算降级为 null。
      // 这里也可用 get_state 当心跳。
      send({'t': 'ping'});
    });
  }

  @override
  void send(Map<String, dynamic> json) {
    final ws = _ws;
    if (ws == null || _state != ChannelState.connected) return;
    try {
      ws.sink.add(jsonEncode(json));
    } catch (_) {
      _setState(ChannelState.error);
    }
  }

  @override
  Future<void> close() async {
    _pingTimer?.cancel();
    await _sub?.cancel();
    try {
      await _ws?.sink.close(ws_status.normalClosure);
    } catch (_) {}
    _ws = null;
    _setState(ChannelState.disconnected);
  }
}
