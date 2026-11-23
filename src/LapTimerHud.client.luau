--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local kit = script.Parent
local LapLogic = require(kit:WaitForChild("LapLogic") :: ModuleScript)
local Words = require(kit:WaitForChild("Words") :: ModuleScript)
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
if playerGui:FindFirstChild("LapTimerKitHud") then
	return
end

local gui = Instance.new("ScreenGui")
gui.Name = "LapTimerKitHud"
gui.ResetOnSpawn = false
gui.AutoLocalize = false
gui.Enabled = kit:GetAttribute("ShowHud") ~= false
gui.Parent = playerGui

local panelWidth, panelHeight = 270, 153
local margin, normalTop = 10, 60
local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(panelWidth, panelHeight)
panel.BackgroundColor3 = Color3.fromRGB(19, 29, 39)
panel.Parent = gui

local scale = Instance.new("UIScale")
scale.Parent = panel

local function positionPanel()
	local position = kit:GetAttribute("HudPosition")
	local right = position == "TopRight" or position == "BottomRight"
	local bottom = position == "BottomLeft" or position == "BottomRight"
	local size = gui.AbsoluteSize
	local availableWidth = size.X - 2 * margin
	local top = if not bottom and availableWidth >= panelWidth
		and size.Y >= normalTop + panelHeight + margin then normalTop else margin
	local availableHeight = size.Y - top - margin
	if availableWidth <= 0 or availableHeight <= 0 then
		return
	end
	local factor = math.min(1, availableWidth / panelWidth, availableHeight / panelHeight)
	scale.Scale = factor

	-- Keep the anchor at the top-left. Subtract the scaled extent on right/bottom
	-- so adding it back puts the far edge exactly one margin from the GUI edge.
	panel.Position = UDim2.fromOffset(
		if right then size.X - margin - panelWidth * factor else margin,
		if bottom then size.Y - margin - panelHeight * factor else top)
end

gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(positionPanel)
kit:GetAttributeChangedSignal("HudPosition"):Connect(positionPanel)
positionPanel()

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local textSize = if UserInputService.TouchEnabled then 22 else 24
local function row(y: number, height: number, size: number, color: Color3): TextLabel
	local label = Instance.new("TextLabel")
	label.Position = UDim2.fromOffset(12, y)
	label.Size = UDim2.new(1, -24, 0, height)
	label.BackgroundTransparency = 1
	label.TextColor3 = color
	label.Font = Enum.Font.GothamBold
	label.TextSize = size
	label.TextScaled = false
	label.TextWrapped = false
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Text = ""
	label.Parent = panel
	return label
end

local white = Color3.fromRGB(248, 250, 254)
local mint = Color3.fromRGB(161, 250, 217)
local clockLabel = row(7, 32, textSize + 3, mint)
local lapLabel = row(40, 26, textSize, white)
local lastLabel = row(66, 26, textSize, white)
local bestLabel = row(92, 26, textSize, white)
local gateLabel = row(118, 27, textSize, mint)

local function numberAttribute(name: string): number?
	local value = player:GetAttribute("LapTimerKit_" .. name)
	return if typeof(value) == "number" then value else nil
end

local function timeText(seconds: number?): string
	return if seconds then LapLogic.formatTime(seconds) else "—"
end

local function update()
	gui.Enabled = kit:GetAttribute("ShowHud") ~= false
	if not gui.Enabled then
		return
	end

	local words = if kit:GetAttribute("Language") == "en" then Words.en else Words.zh
	local start = numberAttribute("LapStart")
	local lap = numberAttribute("Lap") or 0
	local total = numberAttribute("LapTotal") or 0
	local nextGate = numberAttribute("NextGate") or 0
	local count = numberAttribute("GateCount") or 0
	local finished = player:GetAttribute("LapTimerKit_Finished") == true

	clockLabel.Text = if finished then words.finished
		elseif start then LapLogic.formatTime(workspace:GetServerTimeNow() - start)
		else words.ready
	lapLabel.Text = if total == 0 then string.format(words.lap, lap) else string.format(words.lapTotal, lap, total)
	lastLabel.Text = words.last .. "  " .. timeText(numberAttribute("LastLap"))
	bestLabel.Text = words.best .. "  " .. timeText(numberAttribute("BestLap"))
	gateLabel.Text = if finished then ""
		elseif nextGate > 0 then string.format(words.checkpoint, nextGate, count)
		else words.startFinish
end

update()
RunService.PreRender:Connect(update)
