-- Advent of Code day 2
-- local inspect = require("inspect")

-- local input_file = "example1.txt"
local input_file = "input.txt"
local max_red = 12
local max_green = 13
local max_blue = 14

-- Open the file in read mode
local file = io.open(input_file, "r")
if not file then
  print("Error opening the file.")
  return
end
-- Create a table to store the lines
local lines = {}

-- Iterate over each line in the file and append it to the table
for line in file:lines() do
  table.insert(lines, line)
end

-- Close the file
file:close()

local function splitString(inputString, delimiter)
  local result = {}
  for part in inputString:gmatch("[^" .. delimiter .. "]+") do
    table.insert(result, part)
  end
  return result
end

-- now iterate over the lines and create a table that looks like this:
-- id = { red=x, blue=y, green=z }
local cubes = {}
for _, line in ipairs(lines) do
  local _, _, id, games = line:find("^Game (%d+): (.*)")
  id = tonumber(id)
  cubes[id] = {red=0, green=0, blue=0}
  -- games looks like "red=1, green=2, blue=3; blue=5, red=6, green=7..."
  -- now parse the games string into handfuls (sets)
  local handfuls = splitString(games, ";")
  -- iterate over the handfuls and get cubes by color
  for _, cubes_s in ipairs(handfuls) do
    -- cubes_s looks like "red=1, green=2, blue=3"
    local cubeset = splitString(cubes_s, ",")
    -- now cubeset looks like { 1="3 blue", 2="4 red" }
    for _, cubestring in ipairs(cubeset) do
      -- cubestring looks like "3 blue"
      local _, _, count, color = cubestring:find("(%d+) (%a+)")
      -- set cubes[id][color] to the max of count or cubes[id][color]
      count = tonumber(count)
      if cubes[id][color] < count then
        cubes[id][color] = count
      end
    end
  end
end

-- which games would have been possible if the bag contained only 12 red cubes,
-- 13 green cubes, and 14 blue cubes?
local game_id_sum = 0
for game_id, colors in ipairs(cubes) do
  if not (colors.red > max_red or
          colors.green > max_green or
          colors.blue > max_blue) then
    game_id_sum = game_id_sum + game_id
  end
end

print("Part 1 sum: " .. game_id_sum)

-- Part 2
-- what is the power set of the minimums?
game_id_sum = 0
for game_id, colors in ipairs(cubes) do
  local power = colors.red * colors.green * colors.blue
  game_id_sum = game_id_sum + power
end

print("Part 2 sum: " .. game_id_sum)
