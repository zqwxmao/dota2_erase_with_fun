# 项目架构文档

## Dota 2 自定义游戏加载流程

Dota 2 Workshop Tools 按以下顺序加载本 Addon：

```
1. addoninfo.txt           ← Dota 2 识别此目录为合法 Addon
2. scripts/npc/*.txt       ← 加载 KV 配置（英雄/技能/物品定义）
3. resource/addon_*.txt    ← 加载本地化文本
4. Precache(context)       ← addon_game_mode.lua 中的预缓存函数（加载界面阶段）
5. Activate()              ← addon_game_mode.lua 中的激活函数（游戏开始）
   ├─ 创建 CMatch3GameMode 实例
   ├─ InitGameMode() 锁定游戏设置（1人、隐藏HUD、无金币等）
   └─ 注册自定义事件监听器
6. custom_ui_manifest.xml  ← 客户端加载 Panorama UI
   ├─ match3_ui.xml        ← 面板结构
   ├─ match3_ui.css        ← 样式
   └─ match3_ui.js         ← 脚本（由 TS 编译生成）
7. npc_spawned 事件触发     ← 英雄出生后创建 Match3Game 实例
```

### 关键入口点

| 入口 | 文件 | 触发时机 |
|------|------|----------|
| `Precache()` | `addon_game_mode.lua` | 加载界面，预缓存资源 |
| `Activate()` | `addon_game_mode.lua` | 游戏开始，初始化游戏模式 |
| `custom_ui_manifest.xml` | `panorama/layout/custom_game/` | 客户端加载自定义 HUD |
| IIFE `Init()` | `match3_ui.ts` 底部 | JS 加载后立即执行 |

## 服务端-客户端通信架构

Dota 2 通过 `CustomGameEventManager` 实现服务端(Lua) ↔ 客户端(Panorama JS) 双向通信，无共享内存，所有游戏状态存储在服务端。

### 事件协议

```
┌─────────────────────────────────────────────────────────┐
│  客户端 (Panorama/TypeScript)                            │
│                                                         │
│  match3_swap_request  ──────────→  服务端 (Lua)          │
│  { row1, col1, row2, col2 }       TrySwap() 验证交换     │
│                                                         │
│  match3_request_board ──────────→  服务端 (Lua)          │
│  {}                                SyncBoardToClient()   │
│                                                         │
│  服务端 (Lua) ──────────→  match3_board_update           │
│  FindMatches/Gravity/Fill    { board, score, combo,      │
│                                no_moves }                │
│                                                         │
│  服务端 (Lua) ──────────→  match3_swap_rejected          │
│  交换无效时发送               {}                          │
└─────────────────────────────────────────────────────────┘
```

### 棋盘序列化

- 服务端将 10x10 棋盘序列化为 100 字符的字符串（每个字符 1-8 表示英雄类型，0 表示空格）
- 客户端解析: `row = Math.floor(i / 10)`, `col = i % 10`

### 索引偏移

- Lua 使用 **1-based** 索引，JavaScript 使用 **0-based** 索引
- 转换发生在客户端 `RequestSwap()` 中: `row1 + 1, col1 + 1`

### isProcessing 锁

- 客户端在发送交换请求时设置 `isProcessing = true`，防止重复提交
- 收到 `match3_board_update` 或 `match3_swap_rejected` 后重置为 `false`

## 核心游戏逻辑流程

### 消除循环（服务端 match3_game.lua）

```
TrySwap(row1, col1, row2, col2)
  ├─ 验证: 是否相邻？是否越界？
  ├─ 临时交换两个格子
  ├─ FindMatches() 检查是否形成 3 连
  │   ├─ 无匹配 → 撤销交换 + 发送 match3_swap_rejected
  │   └─ 有匹配 → 进入 ResolveMatches()
  │
  └─ ResolveMatches()（递归级联）
      ├─ 清除匹配格子，计算得分: cells × 10 × combo
      ├─ ApplyGravity() 上方格子下落
      ├─ FillEmpty() 用随机英雄填充空格
      ├─ FindMatches() 再次检查
      │   ├─ 有新匹配 → combo++ → 递归 ResolveMatches()
      │   └─ 无匹配 → 结束级联
      └─ SyncBoardToClient() 发送最终状态
```

### 死局检测

- `HasValidMoves()` 暴力遍历所有可能交换，检查是否有合法操作
- 无可用操作时自动重新生成棋盘

### UI 交互流程（客户端 match3_ui.ts）

```
点击格子 A → SelectCell(A) 高亮显示
  ├─ 点击相邻格子 B → RequestSwap(A, B)
  ├─ 点击非相邻格子 C → DeselectCell(A) + SelectCell(C)
  └─ 再次点击 A → DeselectCell(A) 取消选择
```
