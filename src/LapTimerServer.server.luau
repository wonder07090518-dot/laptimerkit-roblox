--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local kit = script.Parent
local LapLogic = require(kit.LapLogic)
local gates = kit.Gates
local startFinish = gates.StartFinish :: BasePart
local lapCompleted = kit.LapCompleted :: BindableEvent
local raceFinished = kit.RaceFinished :: BindableEvent

local function numberAttribute(name: string, default: number): number
	local value = kit:GetAttribute(name)
	if typeof(value) == "number" and value >= 0 and value < math.huge then
		return value
	end
	return default
end

local checkpoints = {}
for _, child in gates:GetChildren() do
	local suffix = child.Name:match("^Checkpoint([1-9]%d*)$")
	if suffix and child:IsA("BasePart") then
		table.insert(checkpoints, { part = child, number = tonumber(suffix) :: number })
	end
end
table.sort(checkpoints, function(a, b)
	return a.number < b.number
end)

local config: LapLogic.Config = {
	laps = math.floor(numberAttribute("Laps", 3)),
	gateCount = #checkpoints,
	minLapSeconds = numberAttribute("MinLapSeconds", 5),
}
local margin = numberAttribute("GateMargin", 2)

type Sample = { part: BasePart, position: Vector3, time: number }
type Runner = {
	state: LapLogic.State,
	sample: Sample?,
	spawnConnection: RBXScriptConnection?,
}
local runners: { [Player]: Runner } = {}

local function publish(player: Player, state: LapLogic.State)
	player:SetAttribute("LapTimerKit_Lap", state.lap)
	player:SetAttribute("LapTimerKit_LapTotal", config.laps)
	player:SetAttribute("LapTimerKit_LapStart", state.lapStart)
	player:SetAttribute("LapTimerKit_LastLap", state.lastLap)
	player:SetAttribute("LapTimerKit_BestLap", state.bestLap)
	player:SetAttribute("LapTimerKit_NextGate", state.nextGate)
	player:SetAttribute("LapTimerKit_GateCount", config.gateCount)
	player:SetAttribute("LapTimerKit_Finished", state.finished)
end

local function addPlayer(player: Player)
	if runners[player] then
		return
	end
	local runner: Runner = { state = LapLogic.newState() }
	runners[player] = runner
	runner.spawnConnection = player.CharacterAdded:Connect(function()
		runner.sample = nil
		runner.state = LapLogic.newState()
		publish(player, runner.state)
	end)
	publish(player, runner.state)
end

local function trackingPart(player: Player): BasePart?
	local character = player.Character
	if not character then
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.SeatPart then
		local seat = humanoid.SeatPart
		return seat.AssemblyRootPart or seat
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root else nil
end

local function localPoint(frame: CFrame, position: Vector3): LapLogic.Point
	local point = frame:PointToObjectSpace(position)
	return { x = point.X, y = point.Y, z = point.Z }
end

local function checkMovement(player: Player, runner: Runner, previous: Sample, current: Sample)
	local hits = {}
	local function checkGate(gate: BasePart, index: number)
		local frame = gate.CFrame
		local fraction = LapLogic.crossing(
			localPoint(frame, previous.position), localPoint(frame, current.position),
			gate.Size.X / 2, gate.Size.Y / 2, margin
		)
		if fraction then
			table.insert(hits, { gate = index, fraction = fraction })
		end
	end

	checkGate(startFinish, 0)
	for index, checkpoint in checkpoints do
		checkGate(checkpoint.part, index)
	end
	if #hits > 1 then
		table.sort(hits, function(a, b)
			if a.fraction == b.fraction then
				return a.gate < b.gate
			end
			return a.fraction < b.fraction
		end)
	end

	for _, hit in hits do
		local time = previous.time + (current.time - previous.time) * hit.fraction
		local before = runner.state
		local after = LapLogic.advance(before, { gate = hit.gate, time = time }, config)
		if after ~= before then
			runner.state = after
			publish(player, after)
			if before.lap > 0 and hit.gate == 0 then
				lapCompleted:Fire(player, after.lastLap, before.lap)
				if after.finished then
					raceFinished:Fire(player, time - (after.raceStart :: number), after.bestLap)
				end
			end
		end
	end
end

Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(function(player)
	local runner = runners[player]
	if runner and runner.spawnConnection then
		runner.spawnConnection:Disconnect()
	end
	runners[player] = nil
end)
for _, player in Players:GetPlayers() do
	addPlayer(player)
end

RunService.Heartbeat:Connect(function()
	local now = workspace:GetServerTimeNow()
	for player, runner in runners do
		local part = trackingPart(player)
		local previous = runner.sample
		local current = if part then { part = part, position = part.Position, time = now } else nil
		runner.sample = current
		-- A new tracked part can jump when a player sits down or stands up.
		if previous and current and previous.part == current.part and not runner.state.finished
			and (current.position - previous.position).Magnitude <= 200 then
			checkMovement(player, runner, previous, current)
		end
	end
end)
