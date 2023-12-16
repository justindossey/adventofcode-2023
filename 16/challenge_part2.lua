-- Advent of Code day 15 part 2
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
-- use constants to make comparisons faster (assuming string comparisons are
-- slower than integer comparisons)
local TYPE_SPACE = 0
local TYPE_MIRROR_RIGHT = 1
local TYPE_MIRROR_LEFT = 2
local TYPE_VERTICAL = 3
local TYPE_HORIZONTAL = 4
local DIRECTION_RIGHT = 10
local DIRECTION_LEFT = 11
local DIRECTION_UP = 12
local DIRECTION_DOWN = 13

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

-- for each coordinate in the border, we need to record the number of visited
-- coordinates
local starting_moves = {}
-- we only need two loops because the grid is rectangular
for i = 1, #grid[1] do
  table.insert(starting_moves, {y=1, x=i, dir=DIRECTION_DOWN})
  table.insert(starting_moves, {y=#grid, x=i, dir=DIRECTION_UP})
end
for i = 1, #grid do
  table.insert(starting_moves, {y=i, x=1, dir=DIRECTION_RIGHT})
  table.insert(starting_moves, {y=i, x=#grid[i], dir=DIRECTION_LEFT})
end

local best_count = 0
-- now try each start point/direction until we have tried them all
while next(starting_moves) do
  local visited = {}
  local starting_move = table.remove(starting_moves)
  local moves = {starting_move}
  -- walk through the grid from the start heading DIRECTION_RIGHT and mark each
  -- coordinate visited.
  while next(moves) do
    local move = table.remove(moves)
    local y = move.y
    local x = move.x
    local dir = move.dir
    local oob = false
    if y < 1 or y > #grid or x < 1 or x > #grid[y] then
      -- out of bounds
      oob = true
    end
    -- beware, there are loops! If we have already been here, going this way,
    -- don't enqueue any more moves.
    if visited[y] and visited[y][x] and visited[y][x][dir] then
      -- we have already visited this coordinate going this direction
      oob = true
    end
    if not oob then
      -- remember that we have visited this coordinate going this direction
      if not visited[y] then
        visited[y] = {}
      end
      if not visited[y][x] then
        visited[y][x] = {}
      end
      visited[y][x][dir] = true

      local device = grid[y][x].device
      -- enqueue the next moves based on device type.
      if device == TYPE_SPACE then
        if dir == DIRECTION_RIGHT then
          table.insert(moves, {y=y, x=x+1, dir=dir})
        elseif dir == DIRECTION_LEFT then
          table.insert(moves, {y=y, x=x-1, dir=dir})
        elseif dir == DIRECTION_UP then
          table.insert(moves, {y=y-1, x=x, dir=dir})
        elseif dir == DIRECTION_DOWN then
          table.insert(moves, {y=y+1, x=x, dir=dir})
        end
      elseif device == TYPE_MIRROR_RIGHT then
        if dir == DIRECTION_RIGHT then
          table.insert(moves, {y=y-1, x=x, dir=DIRECTION_UP})
        elseif dir == DIRECTION_LEFT then
          table.insert(moves, {y=y+1, x=x, dir=DIRECTION_DOWN})
        elseif dir == DIRECTION_UP then
          table.insert(moves, {y=y, x=x+1, dir=DIRECTION_RIGHT})
        elseif dir == DIRECTION_DOWN then
          table.insert(moves, {y=y, x=x-1, dir=DIRECTION_LEFT})
        end
      elseif device == TYPE_MIRROR_LEFT then
        if dir == DIRECTION_RIGHT then
          table.insert(moves, {y=y+1, x=x, dir=DIRECTION_DOWN})
        elseif dir == DIRECTION_LEFT then
          table.insert(moves, {y=y-1, x=x, dir=DIRECTION_UP})
        elseif dir == DIRECTION_UP then
          table.insert(moves, {y=y, x=x-1, dir=DIRECTION_LEFT})
        elseif dir == DIRECTION_DOWN then
          table.insert(moves, {y=y, x=x+1, dir=DIRECTION_RIGHT})
        end
      elseif device == TYPE_VERTICAL then
        if dir == DIRECTION_RIGHT or dir == DIRECTION_LEFT then
          table.insert(moves, {y=y-1, x=x, dir=DIRECTION_UP})
          table.insert(moves, {y=y+1, x=x, dir=DIRECTION_DOWN})
        elseif dir == DIRECTION_UP then
          table.insert(moves, {y=y-1, x=x, dir=dir})
        elseif dir == DIRECTION_DOWN then
          table.insert(moves, {y=y+1, x=x, dir=dir})
        end
      elseif device == TYPE_HORIZONTAL then
        if dir == DIRECTION_UP or dir == DIRECTION_DOWN then
          table.insert(moves, {y=y, x=x-1, dir=DIRECTION_LEFT})
          table.insert(moves, {y=y, x=x+1, dir=DIRECTION_RIGHT})
        elseif dir == DIRECTION_LEFT then
          table.insert(moves, {y=y, x=x-1, dir=dir})
        elseif dir == DIRECTION_RIGHT then
          table.insert(moves, {y=y, x=x+1, dir=dir})
        end
      end
    end
  end
  -- we have completed moves. Now we just have to sum up the number of visited.
  local count = 0
  for y, row in ipairs(visited) do
    for x, _ in pairs(row) do
      count = count + 1
    end
  end
  if count > best_count then
    best_count = count
  end
end
print("Best number of visited coordinates: " .. best_count)
