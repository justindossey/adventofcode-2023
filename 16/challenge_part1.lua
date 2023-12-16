-- Advent of Code day 16 part 1
local inspect = require("inspect")

local input_file = "input.txt"
-- debug function
local debug = true
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

local grid = {}
local TYPE_SPACE = 0
local TYPE_MIRROR_RIGHT = 1
local TYPE_MIRROR_LEFT = 2
local TYPE_VERTICAL = 3
local TYPE_HORIZONTAL = 4
local function parse_input(lines)
  for i, line in ipairs(lines) do
    local row = {}
    for j = 1, #line do
      local c = line:sub(j, j)
      if c == "." then
        table.insert(row, { device=TYPE_SPACE })
      elseif c == "/" then
        table.insert(row, { device=TYPE_MIRROR_RIGHT })
      elseif c == "\\" then
        table.insert(row, { device=TYPE_MIRROR_LEFT })
      elseif c == "|" then
        table.insert(row, { device=TYPE_VERTICAL })
      elseif c == "-" then
        table.insert(row, { device=TYPE_HORIZONTAL })
      end
    end
    table.insert(grid, row)
  end
end
parse_input(readFile(input_file))
local visited = {}
-- function to print the visited grid (for debugging)
local function visited_grid()
  for i=1, #grid do
    for j=1, #grid[i] do
      if visited[i] and visited[i][j] then
        io.write("#")
      else
        io.write(".")
      end
    end
    print()
  end
end
local moves = {{y=1, x=1, dir="right"}}
-- walk through the grid from 1,1 heading "right" and mark each coordinate
-- visited.
repeat
  local move = table.remove(moves)
  local y = move.y
  local x = move.x
  local dir = move.dir
  local oob = false
  if y < 1 or y > #grid or x < 1 or x > #grid[y] then
    -- out of bounds
    oob = true
  end
  if visited[y] and visited[y][x] and visited[y][x][dir] then
    -- we have already visited this coordinate going this direction
    oob = true
  end
  if not oob then
    if not visited[y] then
      visited[y] = {}
    end
    if not visited[y][x] then
      visited[y][x] = {}
    end
    visited[y][x][dir] = true
    local device = grid[y][x].device
    if device == TYPE_SPACE then
      if dir == "right" then
        table.insert(moves, {y=y, x=x+1, dir=dir})
      elseif dir == "left" then
        table.insert(moves, {y=y, x=x-1, dir=dir})
      elseif dir == "up" then
        table.insert(moves, {y=y-1, x=x, dir=dir})
      elseif dir == "down" then
        table.insert(moves, {y=y+1, x=x, dir=dir})
      end
    elseif device == TYPE_MIRROR_RIGHT then
      if dir == "right" then
        table.insert(moves, {y=y-1, x=x, dir="up"})
      elseif dir == "left" then
        table.insert(moves, {y=y+1, x=x, dir="down"})
      elseif dir == "up" then
        table.insert(moves, {y=y, x=x+1, dir="right"})
      elseif dir == "down" then
        table.insert(moves, {y=y, x=x-1, dir="left"})
      end
    elseif device == TYPE_MIRROR_LEFT then
      if dir == "right" then
        table.insert(moves, {y=y+1, x=x, dir="down"})
      elseif dir == "left" then
        table.insert(moves, {y=y-1, x=x, dir="up"})
      elseif dir == "up" then
        table.insert(moves, {y=y, x=x-1, dir="left"})
      elseif dir == "down" then
        table.insert(moves, {y=y, x=x+1, dir="right"})
      end
    elseif device == TYPE_VERTICAL then
      if dir == "right" or dir == "left" then
        table.insert(moves, {y=y-1, x=x, dir="up"})
        table.insert(moves, {y=y+1, x=x, dir="down"})
      elseif dir == "up" then
        table.insert(moves, {y=y-1, x=x, dir=dir})
      elseif dir == "down" then
        table.insert(moves, {y=y+1, x=x, dir=dir})
      end
    elseif device == TYPE_HORIZONTAL then
      if dir == "up" or dir == "down" then
        table.insert(moves, {y=y, x=x-1, dir="left"})
        table.insert(moves, {y=y, x=x+1, dir="right"})
      elseif dir == "left" then
        table.insert(moves, {y=y, x=x-1, dir=dir})
      elseif dir == "right" then
        table.insert(moves, {y=y, x=x+1, dir=dir})
      end
    end
  end
until #moves == 0
-- we have completed moves. Now we just have to sum up the number of visited.
local count = 0
for y, row in ipairs(visited) do
  for x, _ in pairs(row) do
    count = count + 1
  end
end
visited_grid()
print("Number of visited coordinates: " .. count)
