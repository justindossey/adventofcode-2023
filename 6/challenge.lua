-- Advent of Code day 6
local inspect = require("inspect")

local function readFile(filename)
  local file = io.open(filename, "r")
  if not file then
    print("Error opening the file.")
    return
  end

  local lines = {}
  -- Iterate over each line in the file and append it to the table
  for line in file:lines() do
    table.insert(lines, line)
  end

  -- Close the file
  file:close()
  return lines
end

local input_file = "input.txt"
local lines = readFile(input_file)

-- Part 1
local times = {}
local distances = {}
for t in lines[1]:gmatch("%d+") do
  table.insert(times, tonumber(t))
end
for d in lines[2]:gmatch("%d+") do
  table.insert(distances, tonumber(d))
end

local races = {}
for id, t in ipairs(times) do
  table.insert(races, {time_limit = t, record = distances[id]})
end

local function win(time, limit, record)
  return(time < limit and time > ((record + time^2)/limit))
end

-- this function counts the number of ways to win. It takes advantage of the
-- fact that the winning times are in the center of the interval (so holding
-- the button for no time or 100% of the time are equally likely to lose).
-- It _should_ use a simple quadratic formula to find the winning times, but
-- this is how I implemented it first, and it works, so I'm not going to change
-- it. It's not the most efficient, but it's not too bad.
-- So, it checks from the middle of the interval toward 0, until we get false,
-- then it checks from the middle of the interval toward the end. It was tempting
-- to double the first half to get the second half, but that doesn't work when
-- the interval has an odd number of seconds. Instead of fiddling with the
-- number, I just count twice.
local function count_win_ways()
  local ways
  for id, race in ipairs(races) do
    local race_win_ways = 0
    local hold_time = (race.time_limit // 2)
    -- check from the middle of the interval toward 0, until we get false
    while win(hold_time, race.time_limit, race.record) do
      -- print(id..": Win at "..hold_time)
      race_win_ways = race_win_ways + 1
      hold_time = hold_time - 1
    end
    -- check from the middle of the interval toward the end, until we get false
    hold_time = (race.time_limit // 2) + 1
    while win(hold_time, race.time_limit, race.record) do
      -- print(id..": Win at "..hold_time)
      race_win_ways = race_win_ways + 1
      hold_time = hold_time + 1
    end
    ways = ways and race_win_ways * ways or race_win_ways
  end
  return ways
end

print("Part 1 answer: "..count_win_ways())

-- remove the spaces from lines
for line_id, line in ipairs(lines) do
  lines[line_id] = line:gsub("%s+", "")
end
times = {}
distances = {}
for t in lines[1]:gmatch("%d+") do
  table.insert(times, tonumber(t))
end
for d in lines[2]:gmatch("%d+") do
  table.insert(distances, tonumber(d))
end

races = {}
for id, t in ipairs(times) do
  table.insert(races, {time_limit = t, record = distances[id]})
end

print("Part 2 answer: "..count_win_ways())
