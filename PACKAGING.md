# Build

## Build locally

Run these commands from the LapTimerKit directory with Rojo 7.7.

```sh
mkdir -p build work
rojo build default.project.json -o build/LapTimerKit.rbxm
rojo build demo.project.json -o build/LapTimerKitDemo.rbxl
rojo build default.project.json -o work/LapTimerKit.rbxmx
rojo build demo.project.json -o work/LapTimerKitDemo.rbxmx
luau tests/run.luau
```

Both projects set `emitLegacyScripts` to `false`. In the XML builds, locate the `LapTimerHud` item. Its class should be `Script` with `<token name="RunContext">2</token>` (Client). `LapTimerServer` uses token `1` (Server).

The Roblox Creator Store listing is not done yet (it needs an age-checked or ID-verified account).

---

# 构建

## 本地构建

在 LapTimerKit 工作目录运行上方命令，使用 Rojo 7.7 构建模型、演示场景和 XML 检查件。纯逻辑测试使用 `luau tests/run.luau`。

两个项目都将 `emitLegacyScripts` 设为 `false`。在两份 XML 内定位 `LapTimerHud`，确认其类别为 `Script`，且 `<token name="RunContext">2</token>` 对应 Client。`LapTimerServer` 的值为 `1`，对应 Server。

目前还没有上架 Roblox Creator Store（需要通过年龄检查或身份证验证的账号）。
