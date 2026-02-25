import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/storage_service.dart';
import '../services/database_service.dart';
import '../models/daily_record.dart';
import '../widgets/today_status_card.dart';
import 'feedback_detail_page.dart';
import 'settings_page.dart';
import 'quick_record_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<DailyRecord>> _records = {};
  List<DailyRecord> _todayRecords = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadData();
  }

  Future<void> _loadData() async {
    final records = await DatabaseService.instance.getRecordsInRange(
      DateTime(_focusedDay.year, _focusedDay.month - 1, 1),
      DateTime(_focusedDay.year, _focusedDay.month + 2, 0),
    );

    final Map<String, List<DailyRecord>> grouped = {};
    for (var record in records) {
      grouped.putIfAbsent(record.date, () => []).add(record);
    }

    // 获取今天的记录
    final todayStr = _formatDate(DateTime.now());
    final todayRecs = await DatabaseService.instance.getRecordsByDate(todayStr);

    setState(() {
      _records = grouped;
      _todayRecords = todayRecs;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color? _getDayColor(DateTime day) {
    final dateStr = _formatDate(day);
    final dayRecords = _records[dateStr];

    if (dayRecords == null || dayRecords.isEmpty) return null;

    final hasNotDone = dayRecords.any((r) => r.status == FeedbackStatus.notDone);
    final hasDone = dayRecords.any((r) => r.status == FeedbackStatus.done);

    if (hasNotDone) return Colors.orange;
    if (hasDone) return Colors.green;
    return Colors.grey;
  }

  void _showRecordsForDay(DateTime day) async {
    final dateStr = _formatDate(day);
    final dayRecords = await DatabaseService.instance.getRecordsByDate(dateStr);

    if (!mounted) return;

    // 直接跳转到详情页，无论是否有记录都可以补打卡
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeedbackDetailPage(
          date: day,
          records: dayRecords,
        ),
      ),
    );

    if (result == true && mounted) {
      _loadData();
    }
  }

  Future<void> _navigateToQuickRecord() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuickRecordPage(date: DateTime.now()),
      ),
    );
    if (result == true && mounted) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = StorageService.instance.getQuestion() ?? '未设置问题';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('三省吾身'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              ).then((_) => _loadData());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 问题卡片
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.deepPurple[50],
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.self_improvement,
                        size: 40,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '我的观察目标',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              question,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 今日状态卡片
              TodayStatusCard(
                todayRecords: _todayRecords,
                onRecordNow: _navigateToQuickRecord,
              ),
              const SizedBox(height: 24),

              // 日历卡片
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TableCalendar(
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                      weekendStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.deepPurple[200],
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 1,
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        final color = _getDayColor(day);
                        if (color == null) return null;

                        return Positioned(
                          bottom: 4,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    eventLoader: (day) {
                      final color = _getDayColor(day);
                      if (color == null) return [];
                      return ['marker'];
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _showRecordsForDay(selectedDay);
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                      _loadData();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 图例说明
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '图例说明',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildLegendItem(Colors.green, '全部做到了'),
                      _buildLegendItem(Colors.orange, '有没做到'),
                      _buildLegendItem(Colors.grey, '全部跳过'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
