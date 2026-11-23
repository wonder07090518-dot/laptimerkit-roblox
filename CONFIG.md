# Configuration and API

## Model attributes

| Attribute | Type | Default | Effect |
| --- | --- | --- | --- |
| `Laps` | number | `3` | Whole laps required to finish. Use `0` for unlimited laps. Use a nonnegative integer. |
| `Language` | string | `"zh"` | HUD language. Use `"zh"` for Chinese or `"en"` for English. |
| `ShowHud` | boolean | `true` | Shows or hides the built-in HUD. Server timing continues when hidden. |
| `HudPosition` | string | `TopLeft` | Accepts `TopLeft`, `TopRight`, `BottomLeft` or `BottomRight`. Missing or invalid values use `TopLeft`. Top positions leave about 60 px of space above the HUD for Roblox controls. |
| `MinLapSeconds` | number | `5` | Minimum accepted lap duration in seconds. |
| `GateMargin` | number | `2` | Extra width in studs on each side of a gate. Height is unchanged. |

The server reads timing settings and the checkpoint list when its script starts. Edit these before starting Play. The HUD reads its visibility and language during play.

## Gates and timing

- Place `StartFinish` and the optional checkpoint parts directly inside `Gates`. Name checkpoints `Checkpoint1`, `Checkpoint2` and so on. The server sorts by numeric suffix. `NextGate` is the 1-based position in that sorted list.
- `Size.X` and `Size.Y` define the gate opening. Center the opening on the height of the tracked part. The gate uses its center plane and counts movement towards local −Z.
- The first forward crossing of `StartFinish` starts lap 1. Out-of-order crossings are ignored. A finish crossing earlier than the minimum keeps the current timer and checkpoint progress.
- On each server heartbeat, the kit samples the seated assembly root or the avatar root. It skips segments longer than 200 studs and segments whose tracked part changed. Respawning starts a fresh run.

## Player attributes

Read these on the `Player` instance. Times are in seconds.

| Attribute | Meaning |
| --- | --- |
| `LapTimerKit_Lap` | Current lap, initially `0`. Holds the final lap number when finished. |
| `LapTimerKit_LapTotal` | Configured lap count, or `0` for unlimited. |
| `LapTimerKit_LapStart` | Current lap's synchronized server timestamp, or `nil` before start and after finish. Use `workspace:GetServerTimeNow()` to compute elapsed time. |
| `LapTimerKit_LastLap` | Most recent completed lap's duration, or `nil` until a lap is recorded. |
| `LapTimerKit_BestLap` | Shortest recorded lap in the current run, or `nil` until a lap is recorded. |
| `LapTimerKit_NextGate` | Next expected gate. `0` means start/finish. |
| `LapTimerKit_GateCount` | Number of checkpoints, excluding start/finish. |
| `LapTimerKit_Finished` | Whether the player completed all configured laps. |

## Server events

Connect to the `BindableEvent.Event` signals on the model from your own server script. Player attributes are updated before the events fire.

- `LapCompleted(player, lapSeconds, lapNumber)` fires for each accepted lap, including the last one.
- `RaceFinished(player, totalSeconds, bestLapSeconds)` fires once per completed run with a finite lap count. Total time is measured from the first start crossing.

```lua
local kit = workspace:WaitForChild("LapTimerKit")
kit.LapCompleted.Event:Connect(function(player, seconds, lap)
    print(player.Name, lap, seconds)
end)
```

---

# 配置与 API

## 模型属性

| 属性 | 类型 | 默认值 | 用途 |
| --- | --- | --- | --- |
| `Laps` | number | `3` | 完成所需圈数。使用非负整数，`0` 表示不限圈。 |
| `Language` | string | `"zh"` | HUD 语言。`"zh"` 为中文，`"en"` 为英文。 |
| `ShowHud` | boolean | `true` | 显示或隐藏内置面板。隐藏时服务器继续计时。 |
| `HudPosition` | string | `TopLeft` | 可选 `TopLeft`、`TopRight`、`BottomLeft`、`BottomRight`。缺失或无效时使用 `TopLeft`。顶部位置为 Roblox 控件留出约 60 像素的空隙。 |
| `MinLapSeconds` | number | `5` | 一圈至少需要的秒数。 |
| `GateMargin` | number | `2` | 门的左右各放宽多少 stud，仅作用于宽度。 |

服务器在脚本启动时读取计时配置和检查点列表，请在进入 Play 前调整。面板的显示和语言可在运行中切换。

## 门和计时

- 将 `StartFinish` 和可选检查点放在 `Gates` 下，检查点命名为 `Checkpoint1`、`Checkpoint2` 等。服务器按数字后缀排序。`NextGate` 是排序后从 1 开始的序号。
- `Size.X` 和 `Size.Y` 定义门的宽和高。让开口覆盖被追踪部件的高度。穿门按门的中心平面判定，方向为本地 −Z。
- 第一次正向通过 `StartFinish` 开始第 1 圈。未按顺序通过的门会被忽略。圈时不足时通过终点会保留当前计时和检查点进度。
- 服务器每帧取得座椅组件的根部件或角色根部件的位置。单帧移动超过 200 stud 或切换追踪部件时，跳过该段的穿门判定。重生后重新计时。

## 玩家属性

在 `Player` 实例上读取，时间单位均为秒。

| 属性 | 含义 |
| --- | --- |
| `LapTimerKit_Lap` | 当前圈数，初始为 `0`，完成后保留最后一圈的编号。 |
| `LapTimerKit_LapTotal` | 设定的总圈数，`0` 为不限圈。 |
| `LapTimerKit_LapStart` | 当前圈的服务器同步时间戳，未开始或已完成时为 `nil`。可用 `workspace:GetServerTimeNow()` 计算已用时间。 |
| `LapTimerKit_LastLap` | 最近完成一圈的用时，首圈完成前为 `nil`。 |
| `LapTimerKit_BestLap` | 本轮最短圈时，首圈完成前为 `nil`。 |
| `LapTimerKit_NextGate` | 下一道门的序号，`0` 为起终点。 |
| `LapTimerKit_GateCount` | 检查点的数量，起终点单独计算。 |
| `LapTimerKit_Finished` | 玩家是否已完成设定圈数。 |

## 服务器事件

用自己的服务器脚本连接模型中的 `BindableEvent.Event`，示例见英文部分。事件触发前会先更新玩家属性。

- `LapCompleted(player, lapSeconds, lapNumber)` 在每个有效圈完成后触发，包括最后一圈。
- `RaceFinished(player, totalSeconds, bestLapSeconds)` 在有限圈模式完成时每轮触发一次。总用时从第一次穿过起点开始计算。
