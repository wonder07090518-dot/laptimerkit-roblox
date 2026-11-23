--!strict
local LapLogic = {}

export type Point = { x: number, y: number, z: number }
export type State = {
	lap: number,
	lapStart: number?,
	raceStart: number?,
	lastLap: number?,
	bestLap: number?,
	nextGate: number,
	finished: boolean,
}
export type Config = { laps: number, gateCount: number, minLapSeconds: number }
export type Crossing = { gate: number, time: number }

-- Return the fraction along the movement segment at the gate plane.
function LapLogic.crossing(from: Point, to: Point, halfWidth: number, halfHeight: number, margin: number): number?
	if from.z <= 0 or to.z > 0 then
		return nil
	end

	local fraction = from.z / (from.z - to.z)
	local x = from.x + (to.x - from.x) * fraction
	local y = from.y + (to.y - from.y) * fraction
	if math.abs(x) <= halfWidth + margin and math.abs(y) <= halfHeight then
		return fraction
	end
	return nil
end

function LapLogic.newState(): State
	return { lap = 0, nextGate = 0, finished = false }
end

function LapLogic.advance(state: State, event: Crossing, config: Config): State
	if state.finished or event.gate ~= state.nextGate then
		return state
	end

	local nextState = table.clone(state)
	if event.gate > 0 then
		nextState.nextGate = if event.gate < config.gateCount then event.gate + 1 else 0
		return nextState
	end

	local started = state.lapStart
	if started then
		local seconds = event.time - started
		if seconds < config.minLapSeconds then
			return state
		end

		nextState.lastLap = seconds
		nextState.bestLap = math.min(state.bestLap or seconds, seconds)
		if config.laps > 0 and state.lap >= config.laps then
			nextState.finished = true
			nextState.lapStart = nil
			return nextState
		end
	else
		nextState.raceStart = event.time
	end

	nextState.lap = state.lap + 1
	nextState.lapStart = event.time
	nextState.nextGate = if config.gateCount > 0 then 1 else 0
	return nextState
end

function LapLogic.formatTime(seconds: number): string
	local centiseconds = math.round(math.max(seconds, 0) * 100)
	return string.format("%d:%02d.%02d", math.floor(centiseconds / 6000), math.floor(centiseconds / 100) % 60, centiseconds % 100)
end

return LapLogic
