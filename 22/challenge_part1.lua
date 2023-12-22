-- Advent of Code day 22 part 1
local inspect = require("inspect")

local input_file = "example1.txt"
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

local function Brick(end_one, end_two)
  local self = {end_one = end_one, end_two = end_two}

  function self.length()
    return math.abs(self.end_one.x - self.end_two.x) + 1
  end

  function self.width()
    return math.abs(self.end_one.z - self.end_two.z) + 1
  end

  function self.height()
    return math.abs(self.end_one.y - self.end_two.y) + 1
  end

  function self.left_x()
    return math.min(self.end_one.x, self.end_two.x)
  end

  function self.right_x()
    return math.max(self.end_one.x, self.end_two.x)
  end

  function self.top_y()
    return math.min(self.end_one.y, self.end_two.y)
  end

  function self.bottom_y()
    return math.max(self.end_one.y, self.end_two.y)
  end

  -- return true if this brick is underneath the other brick
  -- example stacks:
  -- aaa
  --   bbb     (supported)
  -- a
  -- bbb       (supported)
  --
  -- a
  --    bbb    (not supported)
  --
  --    aaa
  -- bbb       (not supported)
  function self.supports(other_brick)
    -- if neither end of this brick has a coordinate in the range of the other
    -- brick's coordinates, it cannot support the other brick.
    if self.left_x() > other_brick.right_x() or
       self.right_x() < other_brick.left_x() then
      return false
    end
    if self.top_y() > other_brick.bottom_y() or
       self.bottom_y() < other_brick.top_y() then
      return false
    end
    if self.top_y() - 1 ~= other_brick.bottom_y() then
      return false
    end
    return true
  end
  return self
end

local function parse_lines(lines)
  local bricks = {}
  for _, line in ipairs(lines) do
    -- lines look like "1,0,1~1,2,1", where each three-number group is an end
    -- of the brick
    local coordinates = {}
    for num in line:gmatch("%d+") do
      table.insert(coordinates, tonumber(num))
    end
    local end_one = {x = coordinates[1], y = coordinates[2], z = coordinates[3]}
    local end_two = {x = coordinates[4], y = coordinates[5], z = coordinates[6]}
    table.insert(bricks, Brick(end_one, end_two))
  end
  return bricks
end

local brick_pile = parse_lines(readFile(input_file))
