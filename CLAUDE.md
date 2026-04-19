# Dota 2 英雄消消乐 - 游廊自定义游戏

## 项目概述
基于 Dota 2 Workshop Tools 开发的消消乐游戏，使用英雄头像作为消除元素，10x10 经典交换模式，单人玩法。

## 技术栈
- **服务端逻辑**: Lua (`scripts/vscripts/`)
- **客户端 UI**: Panorama (XML + CSS + **TypeScript**) 
  - TS 源码: `src/panorama/` → 编译输出到 `panorama/scripts/custom_game/`
  - 使用 `panorama-types` 提供 Dota 2 Panorama API 类型定义
- **配置文件**: KeyValues (`scripts/npc/`)
- **本地化**: 资源文件 (`resource/`)
- **构建工具**: TypeScript + tsconfig.json

## 项目结构
```
├── scripts/vscripts/          # 服务端 Lua 脚本
│   ├── addon_game_mode.lua    # 游戏模式入口
│   └── match3_game.lua        # 消消乐核心逻辑
├── src/panorama/              # TypeScript 源码（开发时编辑这里）
│   └── match3_ui.ts           # 消消乐 UI 交互逻辑
├── panorama/                  # Panorama UI（Dota 2 标准路径）
│   ├── layout/custom_game/    # XML 布局（手写）
│   ├── styles/custom_game/    # CSS 样式（手写）
│   └── scripts/custom_game/   # JS（由 TS 编译生成，不要手动编辑）
├── scripts/npc/               # KV 配置文件
├── resource/                  # 本地化文本
├── docs/                      # 项目文档
│   ├── architecture.md        # 架构：加载流程、通信协议、游戏逻辑
│   ├── development.md         # 开发：构建流程、工作流、注意事项
│   └── panorama-guide.md     # 参考：Panorama UI 概念与 Web 对比
├── devlog/                    # 开发日志（日报/周报/月报）
│   ├── daily/                 # 日报: YYYY-MM-DD.md
│   ├── weekly/                # 周报: YYYY-WXX.md
│   └── monthly/               # 月报: YYYY-MM.md
└── devplan/                   # 游戏计划（按角色维度）
    ├── product/               # 产品计划与记录
    ├── dev/                   # 研发计划与记录
    └── test/                  # 测试计划与记录
```

## Skills（斜杠命令）

| 命令 | 用途 |
|------|------|
| `/devlog` | 记录开发日志 — 自动生成/追加日报，汇总周报月报。**每次操作后必须调用** |
| `/devplan` | 管理开发计划 — 按产品/研发/测试角色维度创建、更新、查看计划 |

## 文档索引

| 文档 | 内容 |
|------|------|
| [`docs/architecture.md`](docs/architecture.md) | Dota 2 加载流程、服务端-客户端通信架构、核心消除逻辑流程 |
| [`docs/development.md`](docs/development.md) | TypeScript 构建配置、日常开发步骤、开发注意事项 |
| [`docs/panorama-guide.md`](docs/panorama-guide.md) | Panorama UI 与 Web 前端对比、Panorama 特有概念 |
