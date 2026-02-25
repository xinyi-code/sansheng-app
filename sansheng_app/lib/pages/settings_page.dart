import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import 'question_setup_page.dart';
import 'time_setup_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _remindersEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _remindersEnabled = StorageService.instance.getRemindersEnabled();
    });
  }

  Future<void> _toggleReminders(bool value) async {
    setState(() => _isLoading = true);

    await StorageService.instance.setRemindersEnabled(value);

    if (!value) {
      await NotificationService.instance.cancelAll();
    } else {
      final times = StorageService.instance.getReminderTimes();
      final question = StorageService.instance.getQuestion() ?? '';
      await NotificationService.instance.scheduleDailyReminders(times, question);
    }

    setState(() {
      _remindersEnabled = value;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = StorageService.instance.getQuestion() ?? '未设置';
    final times = StorageService.instance.getReminderTimes();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 当前设置卡片
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '当前设置',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.self_improvement, color: Colors.deepPurple),
                    title: const Text('我的问题'),
                    subtitle: Text(
                      question,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const QuestionSetupPage()),
                      );
                      if (result != null || mounted) {
                        setState(() {});
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.schedule, color: Colors.deepPurple),
                    title: const Text('提醒时间'),
                    subtitle: Text(times.join('、')),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TimeSetupPage()),
                      );
                      if (mounted) setState(() {});
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications, color: Colors.deepPurple),
                    title: const Text('开启提醒'),
                    subtitle: Text(_remindersEnabled ? '已开启' : '已关闭'),
                    value: _remindersEnabled,
                    onChanged: _isLoading ? null : _toggleReminders,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 提示信息卡片
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          '温馨提示',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• 修改问题或提醒时间后，通知会自动更新\n'
                      '• 关闭提醒后，将不再收到任何通知\n'
                      '• 所有数据均存储在本地，请注意备份',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[900],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 关于信息
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.self_improvement, size: 40, color: Colors.deepPurple),
                    const SizedBox(height: 8),
                    const Text(
                      '三省吾身',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
