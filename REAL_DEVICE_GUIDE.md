# 在真实iPhone设备上运行应用

## 方法一：使用Xcode配置（推荐，步骤最简单）

### 步骤1：打开Xcode项目

```bash
cd sansheng_app
open ios/Runner.xcworkspace
```

### 步骤2：配置Team和签名

1. 在Xcode中，选择左侧项目导航器中的 **Runner** 项目
2. 选择 **Runner** target
3. 点击 **Signing & Capabilities** 标签
4. 在 **Team** 下拉菜单中：
   - 如果已有Apple ID：选择你的账号
   - 如果没有：点击"Add Account..."添加你的Apple ID
5. **Bundle Identifier** 会自动设置为唯一ID（如：com.sansheng.sanshengApp）
6. Xcode会自动处理 Provisioning Profile

### 步骤3：连接iPhone

1. 使用USB线连接iPhone到Mac
2. 在iPhone上信任此电脑：
   - iPhone会弹出"要信任此电脑吗？"
   - 点击"信任"
   - 输入iPhone锁屏密码

### 步骤4：在Xcode中选择你的iPhone

1. 点击Xcode顶部的设备选择器（靠近播放按钮）
2. 选择你连接的iPhone设备

### 步骤5：运行应用

1. 点击Xcode左上角的▶️播放按钮
2. 首次运行需要：
   - 在iPhone上**安装开发者应用**：设置 → 通用 → VPN与设备管理 → 开发者App → 信任你的Apple ID
   - 输入iPhone密码确认

### 步骤6：以后使用Flutter运行

配置完成后，可以直接用Flutter命令运行：

```bash
# 查看可用设备
flutter devices

# 运行到真机
flutter run -d <你的设备ID>
```

---

## 方法二：免费Apple ID配置（无需开发者账号）

### 准备工作

1. **注册免费Apple ID**（如果没有）
   - 访问 https://appleid.apple.com/
   - 创建一个Apple ID（免费）

2. **在Xcode中登录Apple ID**
   ```bash
   # 打开Xcode
   open -a Xcode

   # 在Xcode菜单：Xcode → Settings (或Preferences) → Accounts
   # 点击左下角"+"号添加Apple ID
   ```

### 配置步骤（与方法一相同）

按照上面的步骤1-5操作即可。免费Apple ID可以：
- ✅ 在自己的iPhone上运行应用
- ✅ 应用有效期7天（7天后需要重新安装）
- ❌ 无法发布到App Store
- ❌ 无法在其他人的设备上安装

---

## 方法三：Apple Developer Program（$99/年）

### 适合情况
- 需要长期使用应用（超过7天）
- 需要在多个设备上测试
- 计划发布到App Store

### 注册步骤
1. 访问 https://developer.apple.com/programs/
2. 注册 Apple Developer Program（$99/年）
3. 在Xcode中选择你的开发者账号作为Team

---

## 常见问题解决

### 问题1：Xcode显示"Could not launch app"

**解决方案**：
```bash
# 在iPhone上：设置 → 通用 → VPN与设备管理 → 信任应用
```

### 问题2：提示"Failed to register bundle identifier"

**解决方案**：
1. 在Xcode中修改Bundle Identifier
2. 改成唯一ID（如：com.yourname.sanshengApp）
3. Runner → General → Bundle Identifier

### 问题3：设备未显示在Xcode中

**解决方案**：
```bash
# 1. 确保iPhone已解锁
# 2. 重新连接USB
# 3. 在Finder中确认iPhone已连接
# 4. 重启Xcode
```

### 问题4：应用安装后闪退

**解决方案**：
1. 确保iOS版本 >= 13.0
2. 在Xcode中查看设备日志：
   - Window → Devices and Simulators
   - 选择你的设备
   - View Device Logs

---

## 使用Flutter命令直接部署（Xcode配置完成后）

### 查看连接的设备

```bash
cd sansheng_app
flutter devices
```

输出示例：
```
2 connected devices:
iPhone 15 Pro • xxx-xxx-xxx • ios        • iOS 17.0
iPhone 16e    • xxx-xxx-xxx • ios        • iOS 18.2
```

### 运行到指定设备

```bash
# 方式1：通过设备ID
flutter run -d xxx-xxx-xxx

# 方式2：通过设备名称
flutter run -d "iPhone 15 Pro"

# 方式3：如果有多个设备，Flutter会让你选择
flutter run
```

### 发布版本安装（更稳定）

```bash
# 构建release版本（需要配置签名）
flutter build ios --release

# 然后在Xcode中：
# ios/Runner.xcworkspace
# Product → Scheme → Run
```

---

## 推荐工作流程

### 第一次配置
1. 使用Xcode配置签名（只需一次）
2. 首次安装到iPhone（需要信任证书）

### 日常开发
```bash
# 1. 连接iPhone
# 2. 直接运行
flutter run

# 3. 修改代码后热重载
# 在终端按 'r' 键
```

### 快速调试技巧
```bash
# 查看实时日志
flutter logs

# 查看特定设备日志
flutter logs -d <设备ID>

# 清理后重新安装
flutter clean
flutter run
```

---

## 应用更新流程

当代码修改后，重新运行：

```bash
# 简单修改（UI调整）
flutter run

# 重大修改（添加依赖）
flutter clean
flutter pub get
flutter run
```

如果Xcode提示签名问题，重新打开Xcode项目检查：
```bash
open ios/Runner.xcworkspace
```

---

## 注意事项

1. **免费Apple ID限制**：
   - 应用每7天需要重新安装
   - 只能在自己的设备上运行

2. **数据保存**：
   - 卸载应用会清除所有数据
   - 更新应用会保留数据

3. **通知权限**：
   - 首次启动时需要允许通知
   - 设置 → 隐私 → 通知 → 三省吾身

4. **iOS版本要求**：
   - 最低iOS 13.0
   - 推荐iOS 15.0+
