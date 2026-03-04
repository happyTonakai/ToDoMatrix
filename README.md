# TodoMatrix

macOS 上的艾森豪威尔矩阵任务管理应用。

## 功能

- 📋 **四象限管理**: 重要且紧急、不重要但紧急、重要不紧急、不重要不紧急
- ✅ **任务管理**: 创建、编辑、完成、删除任务
- 📝 **子任务**: 支持子任务，可展开/折叠
- 🔄 **拖拽移动**: 跨象限拖拽移动任务
- 💾 **数据持久化**: 自动保存到本地 JSON 文件

## 截图

四个象限的艾森豪威尔矩阵布局，任务可拖拽移动。

## 安装

```bash
# 构建
xcodebuild -project TodoMatrix.xcodeproj -scheme TodoMatrix -configuration Debug build

# 运行
open ~/Library/Developer/Xcode/DerivedData/TodoMatrix-*/Build/Products/Debug/TodoMatrix.app
```

或直接在 Xcode 中打开 `TodoMatrix.xcodeproj` 运行。

## 数据存储

任务数据保存在 `~/Library/Application Support/TodoMatrix/tasks.json`

## 快捷操作

- **创建任务**: 点击象限空白区域，输入任务标题，回车确认
- **编辑任务**: 双击任务卡片，或右键菜单选择"编辑"
- **完成任务**: 点击任务左侧的圆形按钮
- **添加子任务**: 在任务下方点击"添加子任务"
- **拖动任务**: 长按任务卡片拖动到其他象限

## 开发

```bash
# 生成 Xcode 项目
xcodegen generate

# 测试
xcodebuild test -project TodoMatrix.xcodeproj -scheme TodoMatrix
```

## 技术栈

- SwiftUI
- macOS 15+
