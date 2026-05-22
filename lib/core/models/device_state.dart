// device_state.dart — 设备完整状态 + 协议 JSON 映射
//
// 与 ESP32 WebSocket 协议字段一一对应：
//   {"t":"state","wifi_ssid":...,"wifi_conn":...,"bt_conn":...,
//    "vol":...,"brightness_main":...,"brightness_sub":...,
//    "effect":...,"dyn_effect":...,"amb_effect":...,
//    "speaker":...,"screen_sub":...,"speed":...,
//    "voice_ai":...,"auto_brightness":...}

enum ConnectionChannel { lan, mqtt, offline }

class DeviceState {
  // 连接信息（来自固件）
  final String wifiSsid;
  final bool wifiConn;
  final bool btConn;
  final String btDevice; // 蓝牙连接的对端名（可能由其他来源提供）

  // 音频
  final int vol;       // 0-100
  final bool speaker;  // 蓝牙音箱开关

  // 屏幕亮度
  final int brightnessMain; // 10-255
  final int brightnessSub;  // 0-255
  final bool autoBrightness;
  final bool screenSub;     // 副屏开关

  // 灯光模式
  final int effect;     // 0..4
  final int dynEffect;  // 0..14
  final int ambEffect;  // 0..13
  final int speed;      // 1..10

  // AI
  final bool voiceAi;

  // App 端通讯通道（不来自固件，由 ConnectionManager 维护）
  final ConnectionChannel channel;
  final int? rttMs;

  const DeviceState({
    this.wifiSsid = '',
    this.wifiConn = false,
    this.btConn = false,
    this.btDevice = '',
    this.vol = 50,
    this.speaker = true,
    this.brightnessMain = 128,
    this.brightnessSub = 128,
    this.autoBrightness = false,
    this.screenSub = true,
    this.effect = 0,
    this.dynEffect = 0,
    this.ambEffect = 0,
    this.speed = 5,
    this.voiceAi = false,
    this.channel = ConnectionChannel.offline,
    this.rttMs,
  });

  DeviceState copyWith({
    String? wifiSsid,
    bool? wifiConn,
    bool? btConn,
    String? btDevice,
    int? vol,
    bool? speaker,
    int? brightnessMain,
    int? brightnessSub,
    bool? autoBrightness,
    bool? screenSub,
    int? effect,
    int? dynEffect,
    int? ambEffect,
    int? speed,
    bool? voiceAi,
    ConnectionChannel? channel,
    int? rttMs,
  }) {
    return DeviceState(
      wifiSsid: wifiSsid ?? this.wifiSsid,
      wifiConn: wifiConn ?? this.wifiConn,
      btConn: btConn ?? this.btConn,
      btDevice: btDevice ?? this.btDevice,
      vol: vol ?? this.vol,
      speaker: speaker ?? this.speaker,
      brightnessMain: brightnessMain ?? this.brightnessMain,
      brightnessSub: brightnessSub ?? this.brightnessSub,
      autoBrightness: autoBrightness ?? this.autoBrightness,
      screenSub: screenSub ?? this.screenSub,
      effect: effect ?? this.effect,
      dynEffect: dynEffect ?? this.dynEffect,
      ambEffect: ambEffect ?? this.ambEffect,
      speed: speed ?? this.speed,
      voiceAi: voiceAi ?? this.voiceAi,
      channel: channel ?? this.channel,
      rttMs: rttMs ?? this.rttMs,
    );
  }

  /// 从 {"t":"state",...} JSON 应用增量
  DeviceState mergeStateJson(Map<String, dynamic> j) {
    return copyWith(
      wifiSsid: j['wifi_ssid'] as String?,
      wifiConn: _asBool(j['wifi_conn']),
      btConn:   _asBool(j['bt_conn']),
      vol:      (j['vol'] as num?)?.toInt(),
      speaker:  _asBool(j['speaker']),
      brightnessMain:  (j['brightness_main'] as num?)?.toInt(),
      brightnessSub:   (j['brightness_sub'] as num?)?.toInt(),
      autoBrightness:  _asBool(j['auto_brightness']),
      screenSub:       _asBool(j['screen_sub']),
      effect:    (j['effect'] as num?)?.toInt(),
      dynEffect: (j['dyn_effect'] as num?)?.toInt(),
      ambEffect: (j['amb_effect'] as num?)?.toInt(),
      speed:     (j['speed'] as num?)?.toInt(),
      voiceAi:   _asBool(j['voice_ai']),
    );
  }
}

bool? _asBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  return null;
}
