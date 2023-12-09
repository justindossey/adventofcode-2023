-- Advent of Code day 8 part 1
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

local steps = 0
-- evaluate instructions against the map
local current_node = "AAA"
while current_node ~= "ZZZ" do
  for _, turn in ipairs(instructions) do
    if turn == "L" then
      current_node = nodes[current_node].left
    elseif turn == "R" then
      current_node = nodes[current_node].right
    else
      print("Invalid instruction: " .. turn)
    end
    steps = steps + 1
    if current_node == "ZZZ" then
      break
    end
  end
end
print("Steps: " .. steps)
