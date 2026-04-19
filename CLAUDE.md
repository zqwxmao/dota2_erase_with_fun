# Dota 2 英雄消消乐 - 游廊自定义游戏

## 项目概述
基于 Dota 2 Workshop Tools 开发的消消乐游戏，使用英雄头像作为消除元素，10x10 经典交换模式，单人玩法。

## 技术栈
- **服务端逻辑**: Lua (`scripts/vscripts/`)
- **客户端 UI**: Panorama (XML + CSS + **TypeScript**) 
  - TS 源码: `src/panorama/` → 编译输出到 `content/panorama/scripts/custom_game/`
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
├── content/panorama/          # Panorama UI（XML/CSS 手写，JS 由 TS 编译生成）
│   ├── layout/custom_game/    # XML 布局
│   ├── styles/custom_game/    # CSS 样式
│   └── scripts/custom_game/   # JS（编译产物，不要手动编辑）
├── scripts/npc/               # KV 配置文件
├── resource/                  # 本地化文本
├── devlog/                    # 开发日志（日报/周报/月报）
│   ├── daily/                 # 日报: YYYY-MM-DD.md
│   ├── weekly/                # 周报: YYYY-WXX.md
│   └── monthly/               # 月报: YYYY-MM.md
└── devplan/                   # 游戏计划（按角色维度）
    ├── product/               # 产品计划与记录
    ├── dev/                   # 研发计划与记录
    └── test/                  # 测试计划与记录
```

## 开发日志规范（强制）

**每次对项目进行任何操作都必须记录开发日志，无例外。**

### 日志触发规则
- 新增/修改/删除任何代码文件 → 记录
- 新增/调整游戏功能设计 → 记录
- 修复 bug → 记录
- 调整配置/参数 → 记录
- 讨论并确定方案 → 记录
- 测试并发现问题 → 记录

### 使用方式
每次完成任务后，运行 `/devlog` 自动生成或追加当日日志。

## 游戏计划规范

### 三个角色维度
| 角色 | 目录 | 关注点 |
|------|------|--------|
| **产品** (Product) | `devplan/product/` | 需求定义、功能规划、优先级、用户体验 |
| **研发** (Dev) | `devplan/dev/` | 技术方案、架构设计、实现细节、技术债务 |
| **测试** (Test) | `devplan/test/` | 测试用例、测试结果、bug 跟踪、回归验证 |

### 计划文件命名
- 产品: `devplan/product/feature-xxx.md`
- 研发: `devplan/dev/tech-xxx.md`
- 测试: `devplan/test/test-xxx.md`
