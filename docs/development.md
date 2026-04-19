# 开发指南

## TypeScript 构建流程

```
src/panorama/match3_ui.ts    ← 编辑此文件
        │
        ▼  tsc (npm run build / npm run watch)
        │
panorama/scripts/custom_game/match3_ui.js  ← 编译输出（不要手动编辑，已 gitignore）
```

### 关键 tsconfig 配置

| 配置项 | 值 | 说明 |
|--------|-----|------|
| `target` | `ES2017` | Dota 2 Panorama V8 引擎支持 |
| `module` | `none` | Panorama 无模块系统，全局作用域 |
| `lib` | `["ES2017"]` | 无浏览器 DOM API |
| `types` | `["panorama-types"]` | Dota 2 Panorama API 类型定义 |
| `strict` | `true` | 严格类型检查 |

### 常用命令

```bash
npm run build    # 单次编译
npm run watch    # 监听模式，修改后自动编译
```

## 日常开发步骤

```
1. 修改服务端逻辑  → scripts/vscripts/*.lua         （无需构建）
2. 修改 UI 逻辑    → src/panorama/match3_ui.ts      （需要 npm run build）
3. 修改 UI 布局    → panorama/layout/custom_game/    （无需构建）
4. 修改 UI 样式    → panorama/styles/custom_game/    （无需构建）
5. 测试游戏        → Dota 2 Workshop Tools 启动器
6. 记录开发日志    → /devlog
7. 管理开发计划    → /devplan
```

## 开发注意事项

- **永远不要手动编辑** `panorama/scripts/custom_game/*.js`，这些是编译产物
- 英雄头像使用 Dota 2 内置资源: `file://{images}/heroes/<name>.png`，无需自定义美术资源
- 玩家英雄实体是不可见的（`AddNoDraw()`），仅用作玩家句柄触发游戏初始化
- 当前为单人模式（最多 1 名 GOODGUYS 玩家，0 名 BADGUYS 玩家）
- 英雄类型 1-8 映射表定义在 `match3_ui.ts` 的 `HERO_IMAGES` 数组中
