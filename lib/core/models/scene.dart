import 'effect_modes.dart';

/// 用户保存的参数预设（只保存与控制相关的字段，不含连接 / 状态字段）
class Scene {
  final String id;
  final String name;
  final String icon;          // emoji
  final int? effect;
  final int? dynEffect;
  final int? ambEffect;
  final int? vol;
  final int? brightnessMain;
  final int? brightnessSub;
  final int? speed;
  final bool? speaker;

  const Scene({
    required this.id,
    required this.name,
    required this.icon,
    this.effect,
    this.dynEffect,
    this.ambEffect,
    this.vol,
    this.brightnessMain,
    this.brightnessSub,
    this.speed,
    this.speaker,
  });

  Scene copyWith({
    String? name,
    String? icon,
    int? effect,
    int? dynEffect,
    int? ambEffect,
    int? vol,
    int? brightnessMain,
    int? brightnessSub,
    int? speed,
    bool? speaker,
  }) {
    return Scene(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      effect: effect ?? this.effect,
      dynEffect: dynEffect ?? this.dynEffect,
      ambEffect: ambEffect ?? this.ambEffect,
      vol: vol ?? this.vol,
      brightnessMain: brightnessMain ?? this.brightnessMain,
      brightnessSub: brightnessSub ?? this.brightnessSub,
      speed: speed ?? this.speed,
      speaker: speaker ?? this.speaker,
    );
  }

  /// 把场景的参数转成一组 set 指令的 (key, val) 对
  /// 与 ConnectionManager.setKey 配合下发到设备
  Map<String, num> toSetCommands() {
    final m = <String, num>{};
    if (effect != null) m['effect'] = effect!;
    if (dynEffect != null) m['dyn_effect'] = dynEffect!;
    if (ambEffect != null) m['amb_effect'] = ambEffect!;
    if (vol != null) m['vol'] = vol!;
    if (brightnessMain != null) m['brightness_main'] = brightnessMain!;
    if (brightnessSub != null) m['brightness_sub'] = brightnessSub!;
    if (speed != null) m['speed'] = speed!;
    if (speaker != null) m['speaker'] = speaker! ? 1 : 0;
    return m;
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'icon': icon,
    if (effect != null) 'effect': effect,
    if (dynEffect != null) 'dynEffect': dynEffect,
    if (ambEffect != null) 'ambEffect': ambEffect,
    if (vol != null) 'vol': vol,
    if (brightnessMain != null) 'brightnessMain': brightnessMain,
    if (brightnessSub != null) 'brightnessSub': brightnessSub,
    if (speed != null) 'speed': speed,
    if (speaker != null) 'speaker': speaker,
  };

  factory Scene.fromJson(Map<String, dynamic> j) => Scene(
    id: j['id'] as String,
    name: j['name'] as String,
    icon: j['icon'] as String? ?? '✨',
    effect: j['effect'] as int?,
    dynEffect: j['dynEffect'] as int?,
    ambEffect: j['ambEffect'] as int?,
    vol: j['vol'] as int?,
    brightnessMain: j['brightnessMain'] as int?,
    brightnessSub: j['brightnessSub'] as int?,
    speed: j['speed'] as int?,
    speaker: j['speaker'] as bool?,
  );
}

const kDefaultScenes = <Scene>[
  Scene(id: '1', name: '电影夜', icon: '🎬',
    effect: 1, ambEffect: 2, brightnessMain: 30, brightnessSub: 60, vol: 90, speaker: true),
  Scene(id: '2', name: '派对',   icon: '🎉',
    effect: 0, dynEffect: 2,  brightnessMain: 220, brightnessSub: 240, vol: 95, speaker: true, speed: 9),
  Scene(id: '3', name: '阅读',   icon: '📖',
    effect: 1, ambEffect: 5,  brightnessMain: 180, brightnessSub: 200, vol: 30, speaker: false),
  Scene(id: '4', name: '睡眠',   icon: '🌙',
    effect: 1, ambEffect: 2,  brightnessMain: 30,  brightnessSub: 20,  vol: 10, speaker: false),
];
