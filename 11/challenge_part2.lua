-- Advent of Code day 11 part 1
local inspect = require("inspect")

local input_file = "input.txt"
-- debug function
local debug = false
local function logd(...)
  if debug then
    print(...)
  end
end

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

local lines = readFile(input_file)

local galaxies = {}
local max_y = 0
local max_x = 0
local to_add = 999999
-- load the lines into a table. Only track galaxy coordinates
for y, line in ipairs(lines) do
  for x = 1, #line do
    local c = line:sub(x, x)
    if c == "#" then
      table.insert(galaxies, {x = x, y = y})
      max_y = math.max(max_y, y)
      max_x = math.max(max_x, x)
    end
  end
end

local function getGalaxyFromX(x)
  for _, galaxy in ipairs(galaxies) do
    if galaxy.x == x then
      return true
    end
  end
  return false
end

local function getGalaxyFromY(y)
  for _, galaxy in ipairs(galaxies) do
    if galaxy.y == y then
      return true
    end
  end
  return false
end

-- check each row for a galaxy. If none found, shift all the ones below down by
-- one.
local y = 1
max_y = #lines
while y <= max_y do
  local row_galaxies = getGalaxyFromY(y)
  if not row_galaxies then
    -- shift all the galaxies below this row down by one
    for _, galaxy in ipairs(galaxies) do
      if galaxy.y > y then
        galaxy.y = galaxy.y + to_add
      end
    end
    y = y + to_add
    max_y = max_y + to_add
  end
  y = y + 1
end
-- check each column for a galaxy. If none found, shift all the ones to the
-- right by one.
local x = 1
max_x = #lines[1]
while x <= max_x do
  local col_galaxies = getGalaxyFromX(x)
  if not col_galaxies then
    -- shift all the galaxies to the right of this column by one
    for _, galaxy in ipairs(galaxies) do
      if galaxy.x > x then
        galaxy.x = galaxy.x + to_add
      end
    end
    x = x + to_add
    max_x = max_x + to_add
  end
  x = x + 1
end
logd("There are "..#galaxies.." galaxies")
logd("The galaxies are: "..inspect(galaxies))
-- generate the 2-combinations of the galaxies table
-- Function to generate all 2-size combinations from a table
local function generateCombinations(inputTable)
  local n = #inputTable
  local combinations = {}

  for i = 1, n - 1 do
    for j = i + 1, n do
      table.insert(combinations, {inputTable[i], inputTable[j]})
    end
  end

  return combinations
end

local result = generateCombinations(galaxies)
logd("There are "..#result.." combinations")
logd("The combinations are:")

-- function to calculate the manhattan distance between two galaxies
local function manhattanDistance(galaxy1, galaxy2)
  return math.abs(galaxy1.x - galaxy2.x) + math.abs(galaxy1.y - galaxy2.y)
end

-- now sum the manhattan distance between the galaxy pairs in result
local total = 0
for _, pair in ipairs(result) do
  local dist = manhattanDistance(pair[1], pair[2])
  total = total + dist
end
print("Part 1: " .. total)
