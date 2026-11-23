# LapTimerKit · Roblox lap timer (free, MIT)

**English** · [中文](#laptimerkit-计圈计时套件)

A free, standalone lap timer model for Roblox racing games, obbies and courses. Drop one model into your place, move its gates onto your route, and press Play.

Download: [Releases](../../releases) → `LapTimerKit.rbxm` (the model) and `LapTimerKitDemo.rbxl` (a small demo place).

## Features

- **Ordered checkpoints.** A lap only counts after the player crosses every checkpoint in order and then the start/finish line. Shortcuts that skip a checkpoint do not count, and crossing a gate the wrong way does not count.
- **Server-side timing.** The server samples each player's position every heartbeat and decides crossings; the client only draws the panel.
- **On foot or driving.** It tracks the avatar root, or the vehicle's assembly when the player sits in any `VehicleSeat` / `Seat`.
- **Chinese / English timer panel.** Current lap time, lap count, last lap and best lap, in large text. Language and corner position are settings.
- **Hooks for your own code.** Player attributes plus `LapCompleted` and `RaceFinished` events.
- No paid items, no `HttpService`, no `require(<number id>)`, no remote code loading, no obfuscation. All source is in `src/`.

## Install

1. Download `LapTimerKit.rbxm` from the Release.
2. In Roblox Studio, open your place and insert the file into **Workspace** (right-click `Workspace` in Explorer → **Insert from File…**, or drag the file into the viewport). Keep it as one model named `LapTimerKit` directly under Workspace, and use one copy per place. The scripts inside run from the model; do not move them to ServerScriptService or StarterPlayerScripts.
3. Place your gates:
   - `LapTimerKit/Gates/StartFinish` is the start/finish line. Checkpoints are parts named `Checkpoint1`, `Checkpoint2`, … directly inside `Gates`; they are crossed in numeric order. Add or delete checkpoints as you like (zero checkpoints also works).
   - Move and rotate each gate across your track. A gate counts movement towards its local front (−Z, the part's `LookVector`), so point that along the driving direction. `Size.X` × `Size.Y` is the opening; make it cover the track width and the height of the player or car.
   - Gates are invisible (`Transparency = 1`). Lower the transparency while placing them, then set it back to 1.
   - The included `DemoTrack` and the checkered `FinishStripe` tiles are only visual. Delete them when you use your own track.
4. Settings: select the `LapTimerKit` model, then edit its **Attributes** in Properties:

| Attribute | Default | Meaning |
| --- | --- | --- |
| `Laps` | `3` | Laps to finish; `0` = unlimited |
| `Language` | `"zh"` | `"zh"` Chinese or `"en"` English panel |
| `ShowHud` | `true` | Show the built-in panel (timing continues when hidden) |
| `HudPosition` | `TopLeft` | `TopLeft`, `TopRight`, `BottomLeft`, `BottomRight` |
| `MinLapSeconds` | `5` | Shortest lap the server accepts |
| `GateMargin` | `2` | Extra width (studs) on each side of every gate |

Full attribute, player-attribute and event reference: [CONFIG.md](CONFIG.md).

## Try the demo

Open `LapTimerKitDemo.rbxl` in Studio and press Play. Walk from the green spawn pad to the checkered line, then go round the loop turning right. Checkpoints are in the middle of the north, east and south straights. With the default `Laps = 3`, the panel is designed to show the finish message after the third lap.

## Build from source

With [Rojo](https://rojo.space) 7.7 and `luau`:

```sh
rojo build default.project.json -o build/LapTimerKit.rbxm
rojo build demo.project.json -o build/LapTimerKitDemo.rbxl
luau tests/run.luau
```

The Release files were built this way with Rojo 7.7.1. `tests/run.luau` runs 36 assertions on the lap logic (crossing direction, order, minimum lap time, finish, time formatting).

## Known limitations

- **Tested in Roblox Studio (v0.1.1, 2026-11-23) with the demo place, using scripted movement:** a walked lap counts; a shortcut through the infield and a full wrong-way loop do not; after a respawn the run restarts and the next lap counts; a lap counts while seated on a `Seat` and on a `VehicleSeat` (the seat was moved along the track by a script, not driven with player controls); 3 laps finish and fire `LapCompleted` ×3 and `RaceFinished`; in a local 2-player server test, one player's lap counted while the other player's shortcut did not, each with their own panel.
- **Small screens:** v0.1.0's panel was clipped on a 560×192 screen. v0.1.1 shrinks it to fit (about 75% size at 560×192, all four `HudPosition` values). This was checked in Studio by running the panel code inside a 560×192 frame, not on a real phone or the device emulator. On narrow screens the text gets smaller.
- Not yet tested on real phones or tablets, with real vehicle chassis driven by players, or with more than 2 players. Please open an issue if something breaks.
- Settings and the checkpoint list are read when the server script starts. Change them before pressing Play.
- One kit per place. If `Gates` or `StartFinish` is deleted, the server script errors.
- Movement of more than 200 studs in one heartbeat (teleports) or switching between walking and a seat skips the crossing check for that step. Respawning starts a fresh run.
- Times are kept for the current session only. Nothing is saved between sessions.
- `thumbnail-1280x720.png` is a hand-drawn illustration; the real panel looks slightly different.
- Not yet listed on the Roblox Creator Store; for now, get it here.

## License

[MIT](LICENSE) © 2026 Deng Wang. Made by Mini Formula (迷你赛车), miniformula.com.

---

# LapTimerKit 计圈计时套件

[English](#laptimerkit--roblox-lap-timer-free-mit) · **中文**

免费、独立的 Roblox 计圈计时模型，赛车、跑酷、障碍赛都能用。把模型放进场景，把门挪到你的路线上，点运行就能计时。

下载：[Releases](../../releases) 里的 `LapTimerKit.rbxm`（模型）和 `LapTimerKitDemo.rbxl`（小演示场景）。

## 功能

- **按顺序过检查点计圈。** 必须依次通过所有检查点，再过起终点线，才算一圈。抄近路漏掉检查点不算，倒着穿门也不算。
- **服务器判定。** 服务器每帧读取玩家位置并判断是否穿门，客户端只负责显示面板。
- **走路、开车都能计时。** 走路时追踪角色，坐在任意 `VehicleSeat` / `Seat` 上时追踪整辆车。
- **中文 / 英文计时面板。** 大字显示当前圈时间、第几圈、上一圈和最好成绩，语言和摆放角落都能设置。
- **方便接自己的逻辑。** 提供玩家属性和 `LapCompleted`、`RaceFinished` 事件。
- 没有付费项，不用 `HttpService`，没有 `require(数字id)`，不远程加载代码，不混淆。全部源码在 `src/`。

## 安装

1. 从 Release 下载 `LapTimerKit.rbxm`。
2. 在 Roblox Studio 打开你的场景，把文件插入 **Workspace**（在 Explorer 里右键 `Workspace` → **Insert from File…**，或把文件拖进视口）。保持它是 Workspace 下面一个叫 `LapTimerKit` 的模型，每个场景放一份。里面的脚本就在模型里运行，不要挪到 ServerScriptService 或 StarterPlayerScripts。
3. 摆门：
   - `LapTimerKit/Gates/StartFinish` 是起终点线。检查点是放在 `Gates` 里、名字为 `Checkpoint1`、`Checkpoint2`……的部件，按数字顺序通过。可以随意增删检查点（一个都没有也行）。
   - 把每道门移动、旋转到横跨赛道。朝门的本地前方（−Z，也就是部件的 `LookVector`）穿过才算，所以让它指向前进方向。`Size.X` × `Size.Y` 是门洞大小，要盖住赛道宽度和人或车的高度。
   - 门默认看不见（`Transparency = 1`）。摆的时候可以先调低透明度，摆好再改回 1。
   - 自带的 `DemoTrack` 和黑白格 `FinishStripe` 只是装饰，换成自己的赛道后可以删掉。
4. 设置：选中 `LapTimerKit` 模型，在属性面板的 **Attributes** 里修改：

| 属性 | 默认值 | 含义 |
| --- | --- | --- |
| `Laps` | `3` | 完成需要的圈数，`0` 为不限圈 |
| `Language` | `"zh"` | `"zh"` 中文，`"en"` 英文 |
| `ShowHud` | `true` | 是否显示自带面板（隐藏时照常计时） |
| `HudPosition` | `TopLeft` | `TopLeft`、`TopRight`、`BottomLeft`、`BottomRight` |
| `MinLapSeconds` | `5` | 服务器接受的最短圈时（秒） |
| `GateMargin` | `2` | 每道门左右各放宽多少 stud |

完整的属性、玩家属性和事件说明见 [CONFIG.md](CONFIG.md)。

## 试跑演示

在 Studio 打开 `LapTimerKitDemo.rbxl`，点 Play。从绿色出生点走到黑白格起点线，然后一路右转绕圈。检查点在北、东、南三条直道的中间。默认 `Laps = 3`，按设计跑满 3 圈后面板显示「完成啦！」。

## 从源码构建

需要 [Rojo](https://rojo.space) 7.7 和 `luau`，命令见英文部分。Release 里的文件就是用 Rojo 7.7.1 这样构建的。`tests/run.luau` 对计圈逻辑跑 36 项断言（穿门方向、顺序、最短圈时、完赛、时间格式）。

## 已知限制

- **已在 Roblox Studio 用演示场景实测（v0.1.1，2026-11-23，用脚本控制移动）：** 走路跑一圈能计圈；从内场抄近路、整圈倒着跑都不算；重生后重新计时，下一圈照常计；坐在 `Seat` 和 `VehicleSeat` 上都能计圈（座椅由脚本沿赛道移动，不是玩家操控驾驶）；跑满 3 圈会完赛，并触发 3 次 `LapCompleted` 和 1 次 `RaceFinished`；本地双人服务器测试里，一人的圈计上了，另一人抄近路没算，两人面板各自独立。
- **小屏幕：** v0.1.0 的面板在 560×192 的屏幕上会被裁切。v0.1.1 会自动缩小到放得下（560×192 时约 75%，四个 `HudPosition` 都不裁切）。这是在 Studio 里把面板代码放进 560×192 的框里检查的，不是真机，也不是设备模拟器。窄屏上字会变小。
- 还没在真实手机、平板上测过，没测过玩家亲手驾驶的真实车辆底盘，也没测过 2 人以上。遇到问题欢迎提 issue。
- 配置和检查点列表在服务器脚本启动时读取，请在点 Play 之前改好。
- 每个场景只放一份。删掉 `Gates` 或 `StartFinish` 会让服务器脚本报错。
- 一帧内移动超过 200 stud（比如传送），或在走路和坐车之间切换时，这一段不判定穿门。重生后重新计时。
- 成绩只保留在本局，不存档。
- `thumbnail-1280x720.png` 是手绘示意图，和实际面板略有不同。
- 目前还没有上架 Roblox Creator Store，请先在这里下载。

## 许可

[MIT](LICENSE) © 2026 Deng Wang。由迷你赛车 Mini Formula 制作，miniformula.com。
