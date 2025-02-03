import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magicscreen/types/global_state.dart';
import 'package:magicscreen/views/BootView.dart';
import 'package:magicscreen/views/HomeView.dart';
import 'package:magicscreen/views/SnapshotView.dart';
import 'package:magicscreen/views/StyleSelectView.dart';
import 'package:window_manager/window_manager.dart';

import '../utils/config.dart' as config;

void main() async {
  // 设置windows 窗口样式
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.setSize(
      const Size(config.designWidth, config.designWidth * 16 / 9)); // 设置窗口大小
  // await windowManager.setFullScreen(true); // 设置全屏
  await windowManager.setResizable(false); // 设置窗口是否可缩放
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);

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

    print('initState');
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);

  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyUpEvent) return false;
    if (HardwareKeyboard.instance.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      print('navigate to back');
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
      initialRoute: '/',
      navigatorKey: _navigatorKey,
      routes: {
        '/': (context) => BootView(),
        '/home': (context) => HomeView(),
        '/snapshot': (context) => SnapshotView(),
        '/styleSelect': (context) => StyleSelectView(),
      },
    );
  }
}
