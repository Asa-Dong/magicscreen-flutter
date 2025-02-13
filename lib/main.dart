import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:magicscreen/views/get_user_media_sample.dart';
import 'package:magicscreen/views/boot_view.dart';
import 'package:magicscreen/views/home_view.dart';
import 'package:magicscreen/views/snapshot_view.dart';
import 'package:magicscreen/views/style_select_view.dart';
import 'package:magicscreen/widgets/camera_widget.dart';
import 'package:window_manager/window_manager.dart';

import '../utils/config.dart' as config;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置windows 窗口样式
  await windowManager.ensureInitialized();
  // await windowManager.setSize(
  //     const Size(config.designWidth, config.designWidth * 16 / 9)); // 设置窗口大小
  await windowManager
      .setSize(const Size(600, config.designWidth * 16 / 9));

  // await windowManager.setFullScreen(true); // 设置全屏
  await windowManager.setResizable(false); // 设置窗口是否可缩放
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);

  // 获取屏幕大小
  config.screenSize = await windowManager.getSize();
  print('screenSize: ${config.screenSize}');

  // if (WebRTC.platformIsDesktop) {
  //   debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  // } else if (WebRTC.platformIsAndroid) {
  //   //startForegroundService();
  // }

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyUpEvent) return false;
    if (HardwareKeyboard.instance.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_navigatorKey.currentState?.canPop() == true) {
        _navigatorKey.currentState?.pop();
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // init config screenSize
    config.screenSize = MediaQuery.of(context).size;

    return MaterialApp(
      initialRoute: '/FaceCameraWidget',
      navigatorKey: _navigatorKey,
      routes: {
        '/FaceCameraWidget': (context) => FaceCameraWidget(),
        '/': (context) => BootView(),
        '/userMedia': (context) => GetUserMediaSample(),
        '/home': (context) => HomeView(),
        '/snapshot': (context) => SnapshotView(),
        '/styleSelect': (context) => StyleSelectView(),
      },
    );
  }
}
