// device_provider.dart — Riverpod 全局状态
//
// 关键 provider：
//   connectionManagerProvider  - 单例，App 启动时自动 start()
//   deviceStateProvider        - 设备完整状态（DeviceState）
//   spectrumProvider           - 实时频谱帧（仅 WS 下推送）
//   gameEventProvider          - 游戏事件流

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../connection/channel.dart';
import '../connection/connection_manager.dart';
import '../models/device_state.dart';
import '../models/scene.dart';

// ─── ConnectionManager 单例 ──────────────────────────────────
final connectionManagerProvider = Provider<ConnectionManager>((ref) {
  final mgr = ConnectionManager();
  // 在后台启动连接（不阻塞 build）
  Future.microtask(mgr.start);
  ref.onDispose(mgr.dispose);
  return mgr;
});

// ─── DeviceState ─────────────────────────────────────────────
class DeviceStateNotifier extends StateNotifier<DeviceState> {
  final ConnectionManager mgr;
  StreamSubscription? _subIncoming;
  StreamSubscription? _subChannel;

  DeviceStateNotifier(this.mgr) : super(const DeviceState()) {
    _subIncoming = mgr.incoming.listen(_onMessage);
    _subChannel = mgr.channelStream.listen((ch) {
      state = state.copyWith(channel: ch, rttMs: mgr.rttMs);
    });
  }

  void _onMessage(Map<String, dynamic> msg) {
    final t = msg['t'];
    if (t == 'state') {
      state = state.mergeStateJson(msg);
    }
    // spec / game_evt 由其他 provider 监听
  }

  // ─── 操作 API ──────────────────────────────
  void setVol(int v)          { state = state.copyWith(vol: v); mgr.setKey('vol', v); }
  void setBrightnessMain(int v){state = state.copyWith(brightnessMain: v); mgr.setKey('brightness_main', v); }
  void setBrightnessSub(int v) {state = state.copyWith(brightnessSub: v); mgr.setKey('brightness_sub', v); }
  void setSpeed(int v)         {state = state.copyWith(speed: v); mgr.setKey('speed', v); }
  void setEffect(int v)        {state = state.copyWith(effect: v); mgr.setKey('effect', v); }
  void setDynEffect(int v)     {state = state.copyWith(dynEffect: v); mgr.setKey('dyn_effect', v); }
  void setAmbEffect(int v)     {state = state.copyWith(ambEffect: v); mgr.setKey('amb_effect', v); }
  void setSpeaker(bool v)      {state = state.copyWith(speaker: v); mgr.setKey('speaker', v ? 1 : 0); }
  void setScreenSub(bool v)    {state = state.copyWith(screenSub: v); mgr.setKey('screen_sub', v ? 1 : 0); }
  void setVoiceAi(bool v)      {state = state.copyWith(voiceAi: v); mgr.setKey('voice_ai', v ? 1 : 0); }
  void setAutoBrightness(bool v){state = state.copyWith(autoBrightness: v); mgr.setKey('auto_brightness', v ? 1 : 0); }

  void applyScene(Scene s) {
    final cmds = s.toSetCommands();
    // 本地先更新
    state = state.copyWith(
      effect: s.effect ?? state.effect,
      dynEffect: s.dynEffect ?? state.dynEffect,
      ambEffect: s.ambEffect ?? state.ambEffect,
      vol: s.vol ?? state.vol,
      brightnessMain: s.brightnessMain ?? state.brightnessMain,
      brightnessSub: s.brightnessSub ?? state.brightnessSub,
      speed: s.speed ?? state.speed,
      speaker: s.speaker ?? state.speaker,
    );
    mgr.setMany(cmds);
  }

  @override
  void dispose() {
    _subIncoming?.cancel();
    _subChannel?.cancel();
    super.dispose();
  }
}

final deviceStateProvider =
    StateNotifierProvider<DeviceStateNotifier, DeviceState>((ref) {
  return DeviceStateNotifier(ref.watch(connectionManagerProvider));
});

// ─── 实时频谱（仅 WS 下推送）─────────────────────────────────
class SpectrumFrame {
  final List<int> bands; // 16 bands, 0-100
  final int total;       // 0-100
  const SpectrumFrame(this.bands, this.total);
}

final spectrumProvider = StreamProvider<SpectrumFrame>((ref) {
  final mgr = ref.watch(connectionManagerProvider);
  return mgr.incoming
      .where((m) => m['t'] == 'spec')
      .map((m) {
        final b = (m['b'] as List?)?.map((e) => (e as num).toInt()).toList() ?? const <int>[];
        final v = (m['v'] as num?)?.toInt() ?? 0;
        return SpectrumFrame(b, v);
      });
});

// ─── 游戏事件流 ──────────────────────────────────────────────
class GameEvent {
  final String evt;  // "score" | "game_over" | "started"
  final int val;
  const GameEvent(this.evt, this.val);
}

final gameEventProvider = StreamProvider<GameEvent>((ref) {
  final mgr = ref.watch(connectionManagerProvider);
  return mgr.incoming
      .where((m) => m['t'] == 'game_evt')
      .map((m) => GameEvent(
            (m['evt'] as String?) ?? '',
            (m['val'] as num?)?.toInt() ?? 0,
          ));
});

// ─── 场景持久化 ──────────────────────────────────────────────
class ScenesNotifier extends StateNotifier<List<Scene>> {
  ScenesNotifier() : super(kDefaultScenes) {
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('scenes');
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => Scene.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    } catch (_) {}
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    sp.setString('scenes', jsonEncode(state.map((s) => s.toJson()).toList()));
  }

  void add(Scene s) {
    state = [...state, s];
    _save();
  }

  void update(Scene s) {
    state = [for (final x in state) if (x.id == s.id) s else x];
    _save();
  }

  void remove(String id) {
    state = state.where((x) => x.id != id).toList();
    _save();
  }
}

final scenesProvider =
    StateNotifierProvider<ScenesNotifier, List<Scene>>((ref) => ScenesNotifier());
