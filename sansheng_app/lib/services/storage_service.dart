import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService instance = StorageService._init();
  static SharedPreferences? _prefs;

  StorageService._init();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // 保存用户问题
  Future<void> saveQuestion(String question) async {
    await _prefs?.setString('question', question);
  }

  // 获取用户问题
  String? getQuestion() {
    return _prefs?.getString('question');
  }

  // 保存提醒时间（存储为JSON字符串数组）
  Future<void> saveReminderTimes(List<String> times) async {
    await _prefs?.setStringList('reminderTimes', times);
  }

  // 获取提醒时间
  List<String> getReminderTimes() {
    return _prefs?.getStringList('reminderTimes') ?? ['09:00', '12:00', '19:00'];
  }

  // 保存提醒开关状态
  Future<void> setRemindersEnabled(bool enabled) async {
    await _prefs?.setBool('remindersEnabled', enabled);
  }

  // 获取提醒开关状态
  bool getRemindersEnabled() {
    return _prefs?.getBool('remindersEnabled') ?? true;
  }

  // 检查是否已初始化（是否设置了问题）
  bool isInitialized() {
    return getQuestion() != null && getQuestion()!.isNotEmpty;
  }

  // 清空所有数据
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
