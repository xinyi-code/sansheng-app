# 三省吾身

> 每日提醒，自我觉察，持续改进

一个简洁的iOS个人习惯提醒应用，帮助您每天通过三次提醒来持续关注和改进自己的行为模式。

## 功能特性

### 核心功能
- **问题设定**：输入想要提醒自己的"毛病"或习惯描述
- **每日提醒**：每天三个自定义时间点的系统通知
- **快速反馈**：通过通知快速记录"做到了"、"没做到"或"跳过"
- **日历回顾**：可视化查看历史记录和进度
- **灵活设置**：随时修改问题、调整提醒时间或开关提醒

### 主要模块

#### 模块一：核心设置
- 问题设定页面
- 提醒时间设置（三个时间点）

#### 模块二：提醒与反馈
- 系统通知推送（支持后台/锁屏）
- 三按钮快速反馈：做到了 / 没做到 / 跳过
- 可选的今日感悟记录

#### 模块三：数据回顾
- 日历视图展示历史记录
- 颜色标记：绿色（全部做到） / 橙色（有没做到） / 灰色（全部跳过）
- 历史记录详情查看与补打卡

#### 模块四：基础设置
- 修改问题描述
- 调整提醒时间
- 全局提醒开关

## 技术栈

- **框架**：Flutter 3.38.6
- **语言**：Dart 3.10.7
- **平台**：iOS
- **本地存储**：SQLite (sqflite) + SharedPreferences
- **通知**：flutter_local_notifications
- **UI组件**：table_calendar

## 项目结构

```
sansheng_app/
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── models/
│   │   └── daily_record.dart     # 数据模型
│   ├── pages/
│   │   ├── home_page.dart        # 首页/日历视图
│   │   ├── question_setup_page.dart  # 问题设置页
│   │   ├── time_setup_page.dart  # 时间设置页
│   │   ├── feedback_record_page.dart # 反馈记录页
│   │   ├── feedback_detail_page.dart  # 反馈详情页
│   │   ├── quick_record_page.dart     # 快速记录页
│   │   └── settings_page.dart    # 设置页
│   ├── services/
│   │   ├── database_service.dart # 数据库服务
│   │   ├── notification_service.dart # 通知服务
│   │   └── storage_service.dart  # 本地存储服务
│   └── widgets/
│       └── today_status_card.dart # 今日状态卡片
```

## 开发环境

- Flutter 3.38.6 (stable channel)
- Dart 3.10.7
- iOS 12.0+

## 安装与运行

1. 克隆仓库
```bash
git clone https://github.com/xinyi-code/sansheng-app.git
cd sansheng-app/sansheng_app
```

2. 安装依赖
```bash
flutter pub get
```

3. 运行应用
```bash
flutter run
```

## 构建发布版

```bash
# iOS Release
flutter build ios

# 使用Xcode打开iOS项目进行进一步配置和发布
open ios/Runner.xcworkspace
```

## 版本历史

- **v1.0.0** - MVP版本
  - 基础提醒功能
  - 反馈记录系统
  - 日历视图

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 作者

xinyi-code

## 致谢

"吾日三省吾身" - 《论语》

---

**三省吾身** - 让每天的自我觉察成为习惯
