import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_record.dart';

class TodayStatusCard extends StatelessWidget {
  final List<DailyRecord> todayRecords;
  final VoidCallback onRecordNow;

  const TodayStatusCard({
    super.key,
    required this.todayRecords,
    required this.onRecordNow,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '今日状态',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('yyyy年MM月dd日').format(now),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: onRecordNow,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('立即打卡'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 添加提示文本
            Text(
              '可以多次打卡记录不同时刻的状态',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            if (todayRecords.isEmpty)
              _buildEmptyState()
            else
              _buildRecordsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.event_available, size: 32, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '今天还没有记录',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '点击"立即打卡"记录当前状态',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    // 记录已按时间降序排列（最新的在前）
    return Column(
      children: todayRecords.map((record) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildRecordItem(record),
        );
      }).toList(),
    );
  }

  Widget _buildRecordItem(DailyRecord record) {
    final reminderLabel = _getReminderLabel(record.reminderIndex);
    final statusConfig = _getStatusConfig(record.status);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusConfig.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusConfig.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            statusConfig.icon,
            color: statusConfig.color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminderLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (record.note != null && record.note!.isNotEmpty)
                  const SizedBox(height: 4),
                if (record.note != null && record.note!.isNotEmpty)
                  Text(
                    record.note!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                record.time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                record.status.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusConfig.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ({IconData icon, Color color}) _getStatusConfig(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.done:
        return (icon: Icons.check_circle, color: Colors.green);
      case FeedbackStatus.notDone:
        return (icon: Icons.cancel, color: Colors.red);
      case FeedbackStatus.skipped:
        return (icon: Icons.skip_next, color: Colors.grey);
    }
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
