/// 每日反馈记录
class DailyRecord {
  final int? id;
  final String date; // 格式: yyyy-MM-dd
  final int reminderIndex; // 第几次提醒: 0, 1, 2
  final String time; // 提醒时间: HH:mm
  final FeedbackStatus status;
  final String? note; // 可选备注

  DailyRecord({
    this.id,
    required this.date,
    required this.reminderIndex,
    required this.time,
    required this.status,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'reminderIndex': reminderIndex,
      'time': time,
      'status': status.toString(),
      'note': note,
    };
  }

  factory DailyRecord.fromMap(Map<String, dynamic> map) {
    return DailyRecord(
      id: map['id'],
      date: map['date'],
      reminderIndex: map['reminderIndex'],
      time: map['time'],
      status: FeedbackStatus.fromString(map['status']),
      note: map['note'],
    );
  }
}

/// 反馈状态
enum FeedbackStatus {
  done('做到了', 'done'),
  notDone('没做到', 'notDone'),
  skipped('跳过', 'skipped');

  final String label;
  final String value;

  const FeedbackStatus(this.label, this.value);

  @override
  String toString() => value;

  static FeedbackStatus fromString(String value) {
    return FeedbackStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => FeedbackStatus.skipped,
    );
  }
}
