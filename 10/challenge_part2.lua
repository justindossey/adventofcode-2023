-- Advent of Code day 10 part 2
-- local inspect = require("inspect")

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

local input_file = "input.txt"
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
  if not top_tile_type or not bottom_tile_type then
    print("Error: "..a.." or "..b.." is not a valid tile type.")
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

-- convert the "S" to its correct pipe type
local north_neighbor = grid[start[1] - 1][start[2]]
local south_neighbor = grid[start[1] + 1][start[2]]
local east_neighbor = grid[start[1]][start[2] + 1]
local west_neighbor = grid[start[1]][start[2] - 1]
local correct_type
local direction
if connects_north("S", north_neighbor) and connects_south("S", south_neighbor) then
  correct_type = "|"
  direction = "S"
elseif connects_east("S", east_neighbor) and connects_west("S", west_neighbor) then
  correct_type = "-"
  direction = "W"
elseif connects_north("S", north_neighbor) and connects_east("S", east_neighbor) then
  correct_type = "L"
  direction = "N"
elseif connects_north("S", north_neighbor) and connects_west("S", west_neighbor) then
  correct_type = "J"
  direction = "W"
elseif connects_south("S", south_neighbor) and connects_west("S", west_neighbor) then
  correct_type = "7"
  direction = "W"
elseif connects_south("S", south_neighbor) and connects_east("S", east_neighbor) then
  correct_type = "F"
  direction = "S"
end
logd("S is a "..correct_type)
grid[start[1]][start[2]] = correct_type

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
-- copy the start position into the current position
for i=1,#start do
  current_position[i] = start[i]
end
local route_points = {}
local steps = 0
-- follow the route until we get back to the start
repeat
  table.insert(route_points, {current_position[1], current_position[2]})
  current_position, direction = next_tile_coords(current_position, direction)
  steps = steps + 1
until current_position[1] == start[1] and current_position[2] == start[2]

-- use the shoelace formula to calculate the area of the loop
local function shoelaceFormula(vertices)
  local n = #vertices
  local sum = 0

  for i = 1, n - 1 do
    sum = sum + (vertices[i][1] * vertices[i + 1][2] - vertices[i + 1][1] * vertices[i][2])
  end

  sum = sum + (vertices[n][1] * vertices[1][2] - vertices[1][1] * vertices[n][2])

  return 0.5 * math.abs(sum)
end

local area = shoelaceFormula(route_points)
print("Inner tiles: "..math.floor(1+(area - steps / 2)))

os.exit()
