// settings_provider.dart — App 端设置（外观、WS 地址、游戏布局等）
//
// 与设备状态无关，本地持久化到 SharedPreferences。

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeMode { dark, light, auto, custom }

class AppSettings {
  final ThemeMode themeMode;
  final int customHue;        // 0-360
  final double customSat;     // 0-0.25
  final double customLight;   // 0-1
  final double customOpacity; // 0-1
  final double customFrost;   // 0-30
  final String wsHost;
  final int wsPort;
  final bool gameShowLabels;
  // 游戏控制器按键位置（landscape 坐标 844x390）
  final Map<String, Offset> snakeLayout;
  final Map<String, Offset> tetrisLayout;

  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.customHue = 240,
    this.customSat = 0.08,
    this.customLight = 0.13,
    this.customOpacity = 0.88,
    this.customFrost = 0,
    this.wsHost = 'lrp-s3.local',
    this.wsPort = 81,
    this.gameShowLabels = true,
    this.snakeLayout = const {
      'up':    Offset(142, 96),
      'left':  Offset(62, 188),
      'right': Offset(222, 188),
      'down':  Offset(142, 280),
      'pause': Offset(722, 188),
    },
    this.tetrisLayout = const {
      'left':  Offset(62, 230),
      'right': Offset(142, 230),
      'soft':  Offset(222, 230),
      'rotL':  Offset(552, 230),
      'rotR':  Offset(632, 230),
      'hard':  Offset(722, 230),
      'pause': Offset(782, 96),
    },
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    int? customHue,
    double? customSat,
    double? customLight,
    double? customOpacity,
    double? customFrost,
    String? wsHost,
    int? wsPort,
    bool? gameShowLabels,
    Map<String, Offset>? snakeLayout,
    Map<String, Offset>? tetrisLayout,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    customHue: customHue ?? this.customHue,
    customSat: customSat ?? this.customSat,
    customLight: customLight ?? this.customLight,
    customOpacity: customOpacity ?? this.customOpacity,
    customFrost: customFrost ?? this.customFrost,
    wsHost: wsHost ?? this.wsHost,
    wsPort: wsPort ?? this.wsPort,
    gameShowLabels: gameShowLabels ?? this.gameShowLabels,
    snakeLayout: snakeLayout ?? this.snakeLayout,
    tetrisLayout: tetrisLayout ?? this.tetrisLayout,
  );

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'customHue': customHue,
    'customSat': customSat,
    'customLight': customLight,
    'customOpacity': customOpacity,
    'customFrost': customFrost,
    'wsHost': wsHost,
    'wsPort': wsPort,
    'gameShowLabels': gameShowLabels,
    'snakeLayout': _layoutToJson(snakeLayout),
    'tetrisLayout': _layoutToJson(tetrisLayout),
  };

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
    themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == (j['themeMode'] as String? ?? 'dark'),
        orElse: () => ThemeMode.dark),
    customHue: j['customHue'] as int? ?? 240,
    customSat: (j['customSat'] as num?)?.toDouble() ?? 0.08,
    customLight: (j['customLight'] as num?)?.toDouble() ?? 0.13,
    customOpacity: (j['customOpacity'] as num?)?.toDouble() ?? 0.88,
    customFrost: (j['customFrost'] as num?)?.toDouble() ?? 0,
    wsHost: j['wsHost'] as String? ?? 'lrp-s3.local',
    wsPort: j['wsPort'] as int? ?? 81,
    gameShowLabels: j['gameShowLabels'] as bool? ?? true,
    snakeLayout: _layoutFromJson(j['snakeLayout']),
    tetrisLayout: _layoutFromJson(j['tetrisLayout']),
  );

  static Map<String, dynamic> _layoutToJson(Map<String, Offset> m) =>
      m.map((k, v) => MapEntry(k, [v.dx, v.dy]));
  static Map<String, Offset> _layoutFromJson(dynamic j) {
    if (j is! Map) return const AppSettings().snakeLayout; // fallback
    return j.map((k, v) {
      final list = v as List;
      return MapEntry(k.toString(),
          Offset((list[0] as num).toDouble(), (list[1] as num).toDouble()));
    });
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString('settings');
    if (raw == null) return;
    try {
      state = AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {}
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    sp.setString('settings', jsonEncode(state.toJson()));
  }

  void update(AppSettings s) {
    state = s;
    _save();
  }

  void setSnakeLayout(String key, Offset pos) {
    final m = Map<String, Offset>.from(state.snakeLayout);
    m[key] = pos;
    update(state.copyWith(snakeLayout: m));
  }

  void setTetrisLayout(String key, Offset pos) {
    final m = Map<String, Offset>.from(state.tetrisLayout);
    m[key] = pos;
    update(state.copyWith(tetrisLayout: m));
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) => SettingsNotifier());
