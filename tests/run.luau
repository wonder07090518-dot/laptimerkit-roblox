--!strict
local logic = require("../src/LapLogic")

local function point(x: number, y: number, z: number): logic.Point
	return { x = x, y = y, z = z }
end

local function hit(a: logic.Point, b: logic.Point): number?
	return logic.crossing(a, b, 4, 3, 2)
end

assert(hit(point(0, 0, 3), point(0, 0, -1)) == 0.75)
assert(hit(point(0, 0, -1), point(0, 0, 3)) == nil)
assert(hit(point(0, 0, 1), point(0, 0, 2)) == nil)
assert(hit(point(0, 0, 0), point(0, 0, -1)) == nil)
assert(hit(point(0, 0, 1), point(0, 0, 0)) == 1)
assert(hit(point(10, 3, 1), point(2, 3, -1)) == 0.5)
assert(hit(point(6.01, 0, 1), point(6.01, 0, -1)) == nil)
assert(hit(point(0, 3.01, 1), point(0, 3.01, -1)) == nil)
print("Crossing: 8 assertions for direction, plane, interpolation and bounds")

local config = { laps = 2, gateCount = 2, minLapSeconds = 5 }
local function crossing(state: logic.State, gate: number, time: number): logic.State
	return logic.advance(state, { gate = gate, time = time }, config)
end

local initial = logic.newState()
assert(initial.lap == 0 and initial.nextGate == 0 and initial.lapStart == nil)
assert(crossing(initial, 1, 9) == initial)
local started = crossing(initial, 0, 10)
assert(started.lap == 1 and started.lapStart == 10 and started.raceStart == 10 and started.nextGate == 1)
assert(initial.lap == 0 and logic.newState().lapStart == nil)
assert(crossing(started, 2, 11) == started)
assert(crossing(started, 0, 20) == started)
local first = crossing(started, 1, 11)
assert(first.nextGate == 2 and crossing(first, 1, 12) == first)
local second = crossing(first, 2, 12)
assert(second.nextGate == 0 and crossing(second, 0, 14.99) == second)
local nextLap = crossing(second, 0, 16)
assert(nextLap.lap == 2 and nextLap.lastLap == 6 and nextLap.bestLap == 6 and nextLap.nextGate == 1)
assert(nextLap.lapStart == 16 and nextLap.raceStart == 10 and not nextLap.finished)
local finished = crossing(crossing(crossing(nextLap, 1, 18), 2, 19), 0, 21)
assert(finished.lap == 2 and finished.finished and finished.lapStart == nil)
assert(finished.lastLap == 5 and finished.bestLap == 5 and finished.raceStart == 10)
assert(crossing(finished, 0, 35) == finished)
print("Finite race: 13 assertions for start, order, minimum, best lap and finish")

local unlimited = { laps = 0, gateCount = 0, minLapSeconds = 0 }
local state = logic.newState()
for lap = 1, 8 do
	state = logic.advance(state, { gate = 0, time = lap * lap }, unlimited)
	assert(state.lap == lap and state.nextGate == 0 and not state.finished)
end
assert(state.lastLap == 15 and state.bestLap == 3 and state.raceStart == 1)

local single = { laps = 1, gateCount = 0, minLapSeconds = 0 }
local oneLap = logic.advance(logic.newState(), { gate = 0, time = 0 }, single)
oneLap = logic.advance(oneLap, { gate = 0, time = 1 }, single)
assert(oneLap.lap == 1 and oneLap.finished and oneLap.bestLap == 1)
print("No-checkpoint races: 10 assertions for unlimited and single-lap runs")

assert(logic.formatTime(-1) == "0:00.00")
assert(logic.formatTime(0) == "0:00.00")
assert(logic.formatTime(9.126) == "0:09.13")
assert(logic.formatTime(59.999) == "1:00.00")
assert(logic.formatTime(600.1) == "10:00.10")
print("Time formatting: 5 assertions for rounding and minute rollover")
