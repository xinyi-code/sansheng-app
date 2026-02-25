import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../services/database_service.dart';
import '../models/daily_record.dart';

class FeedbackRecordPage extends StatefulWidget {
  final DateTime date;
  final int reminderIndex;

  const FeedbackRecordPage({
    super.key,
    required this.date,
    required this.reminderIndex,
  });

  @override
  State<FeedbackRecordPage> createState() => _FeedbackRecordPageState();
}

class _FeedbackRecordPageState extends State<FeedbackRecordPage> {
  final _noteController = TextEditingController();
  bool _isSaving = false;

  String get question => StorageService.instance.getQuestion() ?? '未设置问题';

  String get dateStr =>
      '${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}';

  String get currentTime =>
      '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveFeedback(FeedbackStatus status) async {
    setState(() => _isSaving = true);

    final record = DailyRecord(
      date: dateStr,
      reminderIndex: widget.reminderIndex,
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

      // 延迟关闭页面，让用户看到提示
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(DateFormat('yyyy年MM月dd日').format(widget.date)),
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
                        Icons.notifications_active,
                        size: 48,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '自我观察时间到',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // 问题展示卡片
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
                      const SizedBox(height: 32),

                      // 提示文本
                      Text(
                        '这次提醒后，你做得怎么样？',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // 反馈按钮
                      _buildFeedbackButton(
                        label: '做到了',
                        icon: Icons.check_circle,
                        color: Colors.green,
                        onPressed: () => _saveFeedback(FeedbackStatus.done),
                      ),
                      const SizedBox(height: 12),
                      _buildFeedbackButton(
                        label: '没做到',
                        icon: Icons.cancel,
                        color: Colors.red,
                        onPressed: () => _saveFeedback(FeedbackStatus.notDone),
                      ),
                      const SizedBox(height: 12),
                      _buildFeedbackButton(
                        label: '跳过',
                        icon: Icons.skip_next,
                        color: Colors.grey,
                        onPressed: () => _saveFeedback(FeedbackStatus.skipped),
                      ),
                      const SizedBox(height: 24),

                      // 备注输入框
                      TextField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: '今日感悟（可选）',
                          hintText: '记录当下的想法或情境...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 完成按钮
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('稍后再说'),
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

  Widget _buildFeedbackButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isSaving ? null : onPressed,
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
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
