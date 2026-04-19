# Dota 2 Panorama UI 参考

## 与 Web 前端的对比

| Web | Panorama | 说明 |
|-----|----------|------|
| HTML | XML | 面板结构，但标签名不同（`Panel`, `Label`, `Image`） |
| CSS | CSS | 语法相似但属性名不同（如 `flow-children` 代替 `flex-direction`） |
| DOM API | `$` / `Panel` API | `$.FindChildInContext()` 类似 `document.getElementById()` |
| `addEventListener` | `GameEvents.Subscribe` | 监听自定义游戏事件 |
| `fetch` | `GameEvents.SendCustomGameEventToServer` | 向服务端发送请求 |

## Panorama 特有概念

- **`{resources}`**: 解析为 Addon 的 `panorama/` 目录
- **`{images}`**: 解析为 Dota 2 内置图片资源路径
- **`hittest`**: 类似 `pointer-events`，控制面板是否响应鼠标
- **`flow-children`**: 类似 `flex-direction + flex-wrap`，控制子面板排列
- **`wash-color`**: Panorama 特有，对图片叠加颜色滤镜
