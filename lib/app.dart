import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme.dart';
import 'features/home/home_screen.dart';
import 'features/light/light_screen.dart';
import 'features/color/color_screen.dart';
import 'features/scenes/scenes_screen.dart';
import 'features/games/games_lobby_screen.dart';
import 'features/device/device_screen.dart';

class XiweiApp extends ConsumerWidget {
  const XiweiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: '熹微之萍',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const RootScaffold(),
    );
  }
}

class RootScaffold extends ConsumerStatefulWidget {
  const RootScaffold({super.key});
  @override
  ConsumerState<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends ConsumerState<RootScaffold> {
  int _tab = 0;

  static const _pages = <Widget>[
    HomeScreen(),
    LightScreen(),
    ColorScreen(),
    ScenesScreen(),
    GamesLobbyScreen(),
    DeviceScreen(),
  ];

  static const _tabs = <_TabDef>[
    _TabDef('首页', CupertinoIcons.house_fill),
    _TabDef('灯光', CupertinoIcons.waveform_path_ecg),
    _TabDef('颜色', CupertinoIcons.drop_fill),
    _TabDef('场景', CupertinoIcons.shield_lefthalf_fill),
    _TabDef('游戏', CupertinoIcons.game_controller_solid),
    _TabDef('设备', CupertinoIcons.device_phone_portrait),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.bg,
            border: Border(top: BorderSide(color: AppColors.stroke, width: 0.5)),
          ),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final on = i == _tab;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _tab = i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_tabs[i].icon,
                          size: 22,
                          color: on ? AppColors.accent : AppColors.textFaint),
                      const SizedBox(height: 3),
                      Text(_tabs[i].label,
                          style: TextStyle(
                            fontSize: 10,
                            color: on ? AppColors.accent : AppColors.textFaint,
                          )),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabDef {
  final String label;
  final IconData icon;
  const _TabDef(this.label, this.icon);
}
