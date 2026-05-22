// effect_modes.dart — 设备的灯光模式枚举
// 与 ESP32 协议保持一致：effect 0..4 / dyn_effect 0..14 / amb_effect 0..13

class TopEffect {
  final int value;
  final String name;
  final String en;
  final String desc;
  const TopEffect(this.value, this.name, this.en, this.desc);
}

const kTopEffects = <TopEffect>[
  TopEffect(0, '音乐律动', 'Dynamic', '随音乐频谱实时变化'),
  TopEffect(1, '氛围灯',   'Ambient', '环境氛围动画'),
  TopEffect(2, '时钟',     'Clock',   '副屏显示当前时间'),
  TopEffect(3, '表情',     'Emoji',   '可爱表情动画'),
  TopEffect(4, 'AI 对话',  'AI Chat', '语音对话视觉反馈'),
];

const kDynEffects = <String>[
  '频谱专业版', '瀑布', '节拍粒子', '音频火焰', '脉冲波',
  '圆形', '示波器', '雷达', '频段', '节拍柱',
  '万花筒', '频率流', '音频噪声', '脉冲网格', '音乐雨',
];

const kAmbEffects = <String>[
  '柏林噪声', '星空', '呼吸灯', '熔岩', '矩阵雨',
  '彩虹', '霓虹追踪', '渐变扫描', '色轮', '生命游戏',
  '等离子', '波浪', '螺旋', '扩散',
];

/// 游戏方向输入
enum GameDir {
  /// 贪吃蛇：上移 / 俄罗斯方块：旋转
  up(0),
  /// 贪吃蛇：下移 / 俄罗斯方块：软落
  down(1),
  left(2),
  right(3);

  final int value;
  const GameDir(this.value);
}
