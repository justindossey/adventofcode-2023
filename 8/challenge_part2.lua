-- Advent of Code day 8 part 2
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

local input_file = "input.txt"
local lines = readFile(input_file)
local instructions = {}
local nodes = {}

-- read instructions from line 1
for direction in lines[1]:gmatch("%a") do
  table.insert(instructions, direction)
end
logd("Instructions: " .. inspect(instructions))

-- read nodes from line 3 through the end
for i = 3, #lines do
  local name, left, right = lines[i]:match("(%S+) = %((%S+), (%S+)%)")
  if nodes[name] then
    print("Node already exists: " .. name)
  end
  nodes[name] = { left=left, right=right }
end
logd("Nodes: " .. inspect(nodes))

-- evaluate instructions against the map
local starting_nodes = {}
for name, _ in pairs(nodes) do
  if name:match("A$") then
    table.insert(starting_nodes, name)
  end
end

local steps_by_node = {}
logd("Starting nodes: " .. inspect(starting_nodes))
for _, nodename in ipairs(starting_nodes) do
  -- see how many steps it takes to get to a node that ends in Z
  local steps = 0
  local current_node = nodename
  repeat
    for _, turn in ipairs(instructions) do
      if turn == "L" then
        logd("Turning left from " .. current_node .. " to " .. nodes[current_node].left)
        current_node = nodes[current_node].left
      elseif turn == "R" then
        logd("Turning right from " .. current_node .. " to " .. nodes[current_node].right)
        current_node = nodes[current_node].right
      end
      steps = steps + 1
      if current_node:match("Z$") then
        break
      end
    end
  until current_node:match("Z$")
  steps_by_node[nodename] = steps
end
print("Steps: " .. inspect(steps_by_node))
-- find the LCM of the values in steps_by_node
-- Function to calculate the Greatest Common Divisor (GCD) of two numbers
local function gcd(a, b)
  while b ~= 0 do
    a, b = b, a % b
  end
  return a
end

-- Function to calculate the LCM of two numbers
local function lcm(a, b)
  local result = a * b
  local gcdValue = gcd(a, b)

  if gcdValue ~= 0 then
    result = result / gcdValue
  end

  return math.floor(result)
end

local part2_answer = 1
for _, count in pairs(steps_by_node) do
  part2_answer = lcm(part2_answer, count)
end
print("Part 2 answer: " .. part2_answer)
