# Dota 2 英雄消消乐

基于 Dota 2 Workshop Tools 开发的消消乐游廊自定义游戏。使用英雄头像作为消除元素，10x10 棋盘，经典交换消除玩法。

## 游戏特性

- 10x10 棋盘，8 种英雄头像作为消除元素
- 经典交换模式：选中两个相邻格子交换，3 个及以上相同英雄连成一线即可消除
- 级联连击：消除后上方格子下落，触发新的消除可累计 combo 加分
- 死局自动检测与棋盘重置

## 技术栈

- **服务端**: Lua (VScript)
- **客户端 UI**: Panorama (XML + CSS + TypeScript)
- **类型定义**: [panorama-types](https://github.com/aspect-ux/panorama-types)

## 项目结构

```
scripts/vscripts/              # 服务端 Lua 脚本
├── addon_game_mode.lua        # 游戏模式入口
└── match3_game.lua            # 消消乐核心逻辑
src/panorama/                  # TypeScript 源码
└── match3_ui.ts               # UI 交互逻辑
panorama/                      # Panorama UI 资源
├── layout/custom_game/        # XML 布局
├── styles/custom_game/        # CSS 样式
└── scripts/custom_game/       # JS（编译产物，勿手动编辑）
docs/                          # 项目文档
├── architecture.md            # 架构设计
├── development.md             # 开发指南
└── panorama-guide.md          # Panorama UI 参考
```

## 快速开始

### 环境要求

- [Dota 2 Workshop Tools](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools)
- Node.js (用于 TypeScript 编译)

### 安装

```bash
git clone https://github.com/zqwxmao/dota2_erase_with_fun.git
cd dota2_erase_with_fun
npm install
```

### 构建

```bash
npm run build          # 单次编译
npm run watch          # 监听模式，修改后自动编译
```

### 运行

1. 将项目目录链接或复制到 Dota 2 Addon 目录：`dota 2 beta/game/dota_addons/`
2. 打开 Dota 2 Workshop Tools
3. 选择本 Addon 启动游戏

## 文档

- [架构设计](docs/architecture.md) — 加载流程、服务端-客户端通信、核心游戏逻辑
- [开发指南](docs/development.md) — 构建配置、开发工作流、注意事项
- [Panorama UI 参考](docs/panorama-guide.md) — Panorama 与 Web 前端对比

## 许可证

ISC
