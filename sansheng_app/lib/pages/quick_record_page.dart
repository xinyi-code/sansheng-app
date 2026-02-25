import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/database_service.dart';
import '../models/daily_record.dart';

class QuickRecordPage extends StatefulWidget {
  final DateTime date;

  const QuickRecordPage({
    super.key,
    required this.date,
  });

  @override
  State<QuickRecordPage> createState() => _QuickRecordPageState();
}

class _QuickRecordPageState extends State<QuickRecordPage> {
  final _noteController = TextEditingController();
  int? _selectedReminderIndex;
  bool _isSaving = false;

  String get question => StorageService.instance.getQuestion() ?? '未设置问题';

  String get dateStr =>
      '${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}';

  String get currentTime =>
      '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}';

  final List<Map<String, dynamic>> _reminderOptions = [
    {'index': 0, 'label': '早晨提醒', 'icon': Icons.wb_sunny, 'color': Colors.orange},
    {'index': 1, 'label': '中午提醒', 'icon': Icons.light_mode, 'color': Colors.amber},
    {'index': 2, 'label': '晚上提醒', 'icon': Icons.nights_stay, 'color': Colors.indigo},
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveFeedback(FeedbackStatus status) async {
    if (_selectedReminderIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先选择一个提醒时段'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final record = DailyRecord(
      date: dateStr,
      reminderIndex: _selectedReminderIndex!,
      time: currentTime,
      status: status,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    await DatabaseService.instance.insertRecord(record);

    setState(() => _isSaving = false);

    if (mounted) {
      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == FeedbackStatus.skipped ? '已跳过' : '已记录'),
          duration: const Duration(seconds: 2),
          backgroundColor: status == FeedbackStatus.done
              ? Colors.green
              : status == FeedbackStatus.notDone
                  ? Colors.red
                  : Colors.grey,
        ),
      );

      // 延迟关闭页面
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).pop(true); // 返回 true 表示需要刷新
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('快速打卡'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.edit_note,
                        size: 48,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '记录此刻状态',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // 问题展示
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.deepPurple[200]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '我的观察目标',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              question,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 选择提醒时段
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '选择时段',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildReminderOption(_reminderOptions[index]),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 添加提示文本
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '可以多次打卡，每次都会保存为新记录',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 提示文本
                      Text(
                        '这次提醒后，你做得怎么样？',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // 反馈按钮
                      _buildFeedbackButton(
                        label: '做到了',
                        icon: Icons.check_circle,
                        color: Colors.green,
                        onPressed: _saveFeedback,
                      ),
                      const SizedBox(height: 12),
                      _buildFeedbackButton(
                        label: '没做到',
                        icon: Icons.cancel,
                        color: Colors.red,
                        onPressed: _saveFeedback,
                      ),
                      const SizedBox(height: 12),
                      _buildFeedbackButton(
                        label: '跳过',
                        icon: Icons.skip_next,
                        color: Colors.grey,
                        onPressed: _saveFeedback,
                      ),
                      const SizedBox(height: 20),

                      // 备注输入框
                      TextField(
                        controller: _noteController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: '今日感悟（可选）',
                          hintText: '记录当下的想法或情境...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderOption(Map<String, dynamic> option) {
    final index = option['index'] as int;
    final label = option['label'] as String;
    final icon = option['icon'] as IconData;
    final color = option['color'] as Color;
    final isSelected = _selectedReminderIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedReminderIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey[50],
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
              size: 28,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey[800],
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackButton({
    required String label,
    required IconData icon,
    required Color color,
    required Future<void> Function(FeedbackStatus) onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : () => onPressed(_getFeedbackStatus(label)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  FeedbackStatus _getFeedbackStatus(String label) {
    switch (label) {
      case '做到了':
        return FeedbackStatus.done;
      case '没做到':
        return FeedbackStatus.notDone;
      case '跳过':
        return FeedbackStatus.skipped;
      default:
        return FeedbackStatus.skipped;
    }
  }
}
