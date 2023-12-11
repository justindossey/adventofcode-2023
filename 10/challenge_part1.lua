-- Advent of Code day 10 part 1
local inspect = require("inspect")

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

local input_file = "example2.txt"
local lines = readFile(input_file)
-- grid tile types:
-- | = connects North and South
-- - = connects East and West
-- L = connects North and East
-- J = connects North and West
-- 7 = connects South and West
-- F = connects South and East
-- . = empty space
-- S = start

-- function to print the grid to the screen (for debugging)
local function printGrid(grid)
  io.write("\n")
  for i, row in ipairs(grid) do
    for j, c in ipairs(row) do
      io.write(c)
    end
    io.write("\n")
  end
  io.write("\n")
end
-- iterate over the lines and create a grid. If a pipe would connect something
-- off-grid, ignore it. If we get an "S", that's our starting point.
local grid = {}
local start = {}
for i, line in ipairs(lines) do
  local row = {}
  for j = 1, #line do
    local c = line:sub(j, j)
    if c == "S" then
      start = {i, j}
    end
    -- ignore pipes that would connect off-grid
    if (i == 1 and (c == "|" or c == "L" or c == "J")) or
       (i == #lines and (c == "|" or c == "F" or c == "7")) or
       (j == 1 and (c == "-" or c == "J" or c == "7")) or
       (j == #line and (c == "-" or c == "L" or c == "F")) then
      c = "."
    end
    table.insert(row, c)
  end
  table.insert(grid, row)
end
local connection_types = {
  ["|"] = {north = true, south = true},
  ["-"] = {east = true, west = true},
  ["L"] = {north = true, east = true},
  ["J"] = {north = true, west = true},
  ["7"] = {south = true, west = true},
  ["F"] = {south = true, east = true},
  ["S"] = {north = true, south = true, east = true, west = true},
  ["."] = {north = false, south = false, east = false, west = false}
}
-- return true if the pipe "A" connects to the pipe "B" in the northward
-- direction.
local function connects_north(a, b)
  local top_tile_type = connection_types[b]
  local bottom_tile_type = connection_types[a]
  if not (a and b) then
    return false
  end
  if top_tile_type.south and bottom_tile_type.north then
    return true
  end
  return false
end

local function connects_south(a, b)
  return connects_north(b, a)
end

local function connects_east(a, b)
  local top_tile_type = connection_types[b]
  local bottom_tile_type = connection_types[a]
  if not top_tile_type or not bottom_tile_type then
    return false
  end
  if top_tile_type.west and bottom_tile_type.east then
    return true
  end
  return false
end

local function connects_west(a, b)
  return connects_east(b, a)
end

printGrid(grid)
-- now iterate over the grid and remove all the pipes that don't connect to two
-- other pipes
for i, row in ipairs(grid) do
  for j, c in ipairs(row) do
    local count = 0
    local north = grid[i - 1] and grid[i - 1][j] or nil
    local south = grid[i + 1] and grid[i + 1][j] or nil
    local east = row[j + 1] or nil
    local west = row[j - 1] or nil
    if north and connects_north(c, north) then
      count = count + 1
    end
    if south and connects_south(c, south) then
      count = count + 1
    end
    if east and connects_east(c, east) then
      count = count + 1
    end
    if west and connects_west(c, west) then
      count = count + 1
    end
    if count < 2 then
      grid[i][j] = "."
    end
  end
end
printGrid(grid)
logd(inspect(start))

-- convert the "S" to its correct pipe type
local north_neighbor = grid[start[1] - 1][start[2]]
local south_neighbor = grid[start[1] + 1][start[2]]
local east_neighbor = grid[start[1]][start[2] + 1]
local west_neighbor = grid[start[1]][start[2] - 1]
local correct_type
local starting_direction
if connects_north("S", north_neighbor) and connects_south("S", south_neighbor) then
  correct_type = "|"
  starting_direction = "S"
elseif connects_east("S", east_neighbor) and connects_west("S", west_neighbor) then
  correct_type = "-"
  starting_direction = "W"
elseif connects_north("S", north_neighbor) and connects_east("S", east_neighbor) then
  correct_type = "L"
  starting_direction = "N"
elseif connects_north("S", north_neighbor) and connects_west("S", west_neighbor) then
  correct_type = "J"
  starting_direction = "W"
elseif connects_south("S", south_neighbor) and connects_west("S", west_neighbor) then
  correct_type = "7"
  starting_direction = "W"
elseif connects_south("S", south_neighbor) and connects_east("S", east_neighbor) then
  correct_type = "F"
  starting_direction = "S"
end
logd("S is a "..correct_type)
grid[start[1]][start[2]] = correct_type
printGrid(grid)

-- now walk the grid and find the path from S to S. Each tile exits the other
-- way from the way we came in.
local function next_tile_coords(starting_coords, entry_direction)
  local tile_type = grid[starting_coords[1]][starting_coords[2]]
  -- if we came down from the north...
  if entry_direction == "N" then
    if tile_type == "|" then
      return {starting_coords[1] + 1, starting_coords[2]}, 'N'
    elseif tile_type == "L" then
      return {starting_coords[1], starting_coords[2] + 1}, 'W'
    elseif tile_type == "J" then
      return {starting_coords[1], starting_coords[2] - 1}, 'E'
    end
  elseif entry_direction == "S" then
    if tile_type == "|" then
      return {starting_coords[1] - 1, starting_coords[2]}, 'S'
    elseif tile_type == "F" then
      return {starting_coords[1], starting_coords[2] + 1}, 'W'
    elseif tile_type == "7" then
      return {starting_coords[1], starting_coords[2] - 1}, 'E'
    end
  elseif entry_direction == "E" then
    if tile_type == "-" then
      return {starting_coords[1], starting_coords[2] - 1}, 'E'
    elseif tile_type == "L" then
      return {starting_coords[1] - 1, starting_coords[2]}, 'S'
    elseif tile_type == "F" then
      return {starting_coords[1] + 1, starting_coords[2]}, 'N'
    end
  elseif entry_direction == "W" then
    if tile_type == "-" then
      return {starting_coords[1], starting_coords[2] + 1}, 'W'
    elseif tile_type == "J" then
      return {starting_coords[1] - 1, starting_coords[2]}, 'S'
    elseif tile_type == "7" then
      return {starting_coords[1] + 1, starting_coords[2]}, 'N'
    end
  end
end
local current_position = {}
for i=1,#start do
  current_position[i] = start[i]
end
local steps = 0
repeat
  -- print("Current position: "..inspect(current_position) .. " Current direction: "..starting_direction)
  current_position, starting_direction = next_tile_coords(current_position, starting_direction)
  steps = steps + 1
until current_position[1] == start[1] and current_position[2] == start[2]
print("Answer: "..steps / 2.0)
