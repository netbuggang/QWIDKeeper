# save_page_info.sh - Android 页面信息抓取工具

一个用于从 Android 设备获取当前页面 UI 布局信息的 Bash 脚本，支持自定义文件名、多种输出模式和详细的分析统计。

## 📋 功能特性

- ✅ 自动获取 Android 设备当前屏幕的 UI 布局
- ✅ 支持自定义文件名和保存目录
- ✅ 可选添加/不添加时间戳
- ✅ 提取并统计所有控件 ID
- ✅ 统计各类控件数量（按钮、输入框、文本等）
- ✅ 支持多设备环境
- ✅ 彩色终端输出
- ✅ 静默模式（适合脚本调用）
- ✅ 仅列出控件 ID 模式（不保存文件）

## 🔧 环境要求

- Android Debug Bridge (ADB) 已安装并配置
- Android 设备已开启 USB 调试并授权
- Bash 环境 (Linux/macOS/Windows WSL/Cygwin)

## 📦 安装

```bash
# 下载脚本
wget https://your-repo/save_page_info.sh

# 或创建文件并粘贴脚本内容
vim save_page_info.sh

# 添加执行权限
chmod +x save_page_info.sh

# 可选：移动到系统路径
sudo mv save_page_info.sh /usr/local/bin/
```

## 🚀 使用方法

### 基本用法

```bash
# 使用默认文件名（带时间戳）
./save_page_info.sh

# 指定文件名（自动添加时间戳）
./save_page_info.sh my_screen.xml

# 指定文件名（不带时间戳）
./save_page_info.sh -c login.xml

# 指定保存目录
./save_page_info.sh -c -d ../../page/5.0.6 -o 手机号登录
```

### 命令行选项

| 选项 | 长选项 | 说明 |
|------|--------|------|
| `-h` | `--help` | 显示帮助信息 |
| `-l` | `--list` | 只列出控件ID，不保存文件 |
| `-o` | `--output FILE` | 指定输出文件名 |
| `-t` | `--timestamp` | 自动添加时间戳（默认启用） |
| `-c` | `--no-timestamp` | 不添加时间戳 |
| `-d DIR` | `--dir DIR` | 指定保存目录（默认当前目录） |
| `-s` | `--silent` | 静默模式，只输出结果 |

### 使用示例

#### 1. 基本文件保存

```bash
# 默认文件名：page_info_20240115_143022.xml
./save_page_info.sh

# 自定义文件名：home_20240115_143022.xml
./save_page_info.sh home.xml

# 不带时间戳：login.xml
./save_page_info.sh -c login.xml
```

#### 2. 指定保存位置

```bash
# 保存到 screens 目录
./save_page_info.sh -d ./screens screen.xml

# 使用绝对路径
./save_page_info.sh -d /home/user/dumps app_page.xml
```

#### 3. 仅查看控件ID

```bash
# 列出当前页面所有控件ID（不保存文件）
./save_page_info.sh --list

# 静默模式，只输出ID列表（适合脚本调用）
./save_page_info.sh --list --silent
```

#### 4. 组合使用

```bash
# 保存到指定目录，不带时间戳
./save_page_info.sh -d /path/to/save -c custom_name.xml

# 指定输出文件并添加时间戳
./save_page_info.sh -o debug_page.xml -t

# 静默模式保存文件
./save_page_info.sh -s -c silent_dump.xml
```

## 📤 输出示例

### 正常模式输出

```bash
$ ./save_page_info.sh login.xml

正在获取当前页面信息...
✓ 页面信息已保存到: ./login_20240115_143022.xml

📱 页面分析结果:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
发现 5 个控件ID:
  • com.example.app:id/btn_login
  • com.example.app:id/et_username
  • com.example.app:id/et_password
  • com.example.app:id/tv_forgot
  • com.example.app:id/btn_register

其他统计信息:
  • 可点击元素: 3
  • 输入框: 2
  • 按钮: 2
  • 文本标签: 4
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
文件大小: 24K
```

### 静默模式输出

```bash
$ ./save_page_info.sh --list --silent
com.example.app:id/btn_login
com.example.app:id/et_username
com.example.app:id/et_password
com.example.app:id/tv_forgot
com.example.app:id/btn_register
```

## 🔍 生成的文件内容

保存的 XML 文件包含完整的 UI 层级结构：

```xml
<?xml version='1.0' encoding='UTF-8' standalone='yes' ?>
<hierarchy rotation="0">
  <node 
    index="0" 
    text="登录" 
    resource-id="com.example.app:id/btn_login"
    class="android.widget.Button"
    bounds="[120,800][960,1200]"
    clickable="true"
    enabled="true"
    ... />
  <!-- 更多控件... -->
</hierarchy>
```

## ⚠️ 常见问题

### 1. ADB 未找到

```bash
错误: adb 命令未找到，请安装 Android SDK
```

**解决**: 安装 Android SDK 或单独安装 ADB：
```bash
# macOS
brew install android-platform-tools

# Ubuntu
sudo apt install adb

# Windows
下载 platform-tools 并添加到 PATH
```

### 2. 没有连接的设备

```bash
错误: 没有连接到任何 Android 设备
```

**解决**: 
- 连接 Android 设备并开启 USB 调试
- 检查 `adb devices` 是否显示设备
- 确认设备已授权

### 3. 多设备连接

```bash
警告: 连接了多个设备，将使用第一个设备
```

**解决**: 脚本会自动使用第一个设备，或断开不需要的设备。

### 4. 权限问题

如果无法保存到 `/sdcard/`：
- 确保应用有存储权限
- 某些 Android 版本可能需要特殊处理

## 📝 高级用法

### 在脚本中调用

```bash
#!/bin/bash
# 自动化测试脚本示例

# 获取登录页控件ID
IDS=$(./save_page_info.sh --list --silent)

# 检查是否包含登录按钮
if echo "$IDS" | grep -q "btn_login"; then
    echo "登录按钮存在"
    
    # 保存完整布局供后续分析
    ./save_page_info.sh -c login_page.xml
fi
```

### 批量抓取多个页面

```bash
#!/bin/bash
# 批量抓取脚本

PAGES=("home" "login" "profile" "settings")

for page in "${PAGES[@]}"; do
    echo "正在抓取 $page 页面..."
    ./save_page_info.sh -c "${page}.xml"
    sleep 2  # 等待页面切换
    adb shell input keyevent 4  # 返回键
    sleep 1
done
```

### 与 adb 命令结合

```bash
# 先点击某个按钮，然后抓取新页面
adb shell input tap 500 1000
sleep 1
./save_page_info.sh after_click.xml

# 对比两个页面的控件差异
diff <(./save_page_info.sh --list --silent) <(./save_page_info.sh --list --silent)
```

## 🔄 版本历史

- **v1.0.0** (2024-01-15)
  - 初始版本
  - 基本抓取功能
  - 控件ID提取

- **v1.1.0** (2024-01-16)
  - 添加自定义文件名支持
  - 添加时间戳选项
  - 添加静默模式
  - 添加控件统计功能

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request 来改进这个脚本。

## 📄 许可证

MIT License

## ✨ 致谢

- 感谢 Android 开发者社区
- 感谢所有提供反馈的用户

---

**提示**: 如果发现 bug 或有功能建议，请提交 Issue。
