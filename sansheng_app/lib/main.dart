import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'pages/question_setup_page.dart';
import 'pages/home_page.dart';
import 'pages/feedback_record_page.dart';

void main() async {
  developer.log('=== 应用启动 ===');

  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  developer.log('WidgetsFlutterBinding 已初始化');

  // 初始化服务
  await StorageService.instance.init();
  developer.log('StorageService 已初始化');

  await NotificationService.instance.init();
  developer.log('NotificationService 已初始化');

  // 请求通知权限
  await NotificationService.instance.requestPermissions();
  developer.log('通知权限已请求');

  runApp(const MyApp());
  developer.log('runApp 已调用');
}

// 全局导航key，用于从通知点击时跳转页面
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    developer.log('MyApp.build 被调用');

    return MaterialApp(
      title: '三省吾身',
      debugShowCheckedModeBanner: false,

      // 设置全局导航key
      navigatorKey: navigatorKey,

      // 主题设置
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // 首页路由：根据是否已设置问题决定
      home: const AppStartPage(),
    );
  }
}

/// 应用启动页：决定进入设置页还是首页
class AppStartPage extends StatefulWidget {
  const AppStartPage({super.key});

  @override
  State<AppStartPage> createState() => _AppStartPageState();
}

class _AppStartPageState extends State<AppStartPage> {
  bool _isChecking = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkInitialization();

    // 监听通知点击
    NotificationService.instance.setOnNotificationTap(_onNotificationTap);
  }

  /// 检查是否已完成初始化设置
  Future<void> _checkInitialization() async {
    final isInitialized = StorageService.instance.isInitialized();

    developer.log('初始化检查结果: $isInitialized');

    setState(() {
      _isInitialized = isInitialized;
      _isChecking = false;
    });
  }

  /// 处理通知点击
  void _onNotificationTap(Map<String, dynamic> payload) {
    developer.log('收到通知点击: $payload');

    final context = navigatorKey.currentContext;
    if (context == null) {
      developer.log('无法获取 context，跳转失败');
      return;
    }

    // 跳转到反馈记录页
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackRecordPage(
          date: DateTime.now(),
          reminderIndex: 0, // 默认为第一次提醒
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 显示加载页
    if (_isChecking) {
      return _buildLoadingPage();
    }

    // 如果未初始化，进入问题设置页
    if (!_isInitialized) {
      developer.log('跳转到问题设置页');
      return const QuestionSetupPage();
    }

    // 如果已初始化，进入首页
    developer.log('跳转到首页');
    return const HomePage();
  }

  /// 构建加载页面
  Scaffold _buildLoadingPage() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.self_improvement,
              size: 80,
              color: Colors.deepPurple[300],
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 16),
            Text(
              '三省吾身',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
