import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_record.dart';
import 'quick_record_page.dart';

class FeedbackDetailPage extends StatelessWidget {
  final DateTime date;
  final List<DailyRecord> records;

  const FeedbackDetailPage({
    super.key,
    required this.date,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(DateFormat('yyyy年MM月dd日').format(date)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 提示信息
            if (!isToday)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.blue[50],
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '可以多次补打卡，记录不同时刻的状态',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // 记录列表
            Expanded(
              child: records.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _getReminderLabel(record.reminderIndex),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      record.time,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildStatusChip(record.status),
                                if (record.note != null &&
                                    record.note!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    record.note!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuickRecordPage(date: date),
            ),
          );
          if (context.mounted && result == true) {
            Navigator.pop(context, true);
          }
        },
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text(
          '再次打卡',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '这一天还没有记录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮开始补打卡',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(FeedbackStatus status) {
    Color color;
    IconData icon;

    switch (status) {
      case FeedbackStatus.done:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case FeedbackStatus.notDone:
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case FeedbackStatus.skipped:
        color = Colors.grey;
        icon = Icons.skip_next;
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 20, color: Colors.white),
      label: Text(
        status.label,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  String _getReminderLabel(int index) {
    switch (index) {
      case 0:
        return '早晨提醒';
      case 1:
        return '中午提醒';
      case 2:
        return '晚上提醒';
      default:
        return '提醒';
    }
  }
}
