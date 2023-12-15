-- Advent of Code day 15 part 1
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

local function split_string(str, split_char)
  local sep, fields = split_char or ",", {}
  local pattern = string.format("([^%s]+)", sep)
  str:gsub(
    pattern,
    function(c)
      table.insert(fields, c)
    end
  )
  return fields
end


local function hash_string(str)
  local hash = 0
  local multiplier = 17
  local divisor = 256
  for i = 1, #str do
    hash = (hash + string.byte(str, i)) * multiplier % divisor
  end
  return hash
end
local result = 0
local input = readFile(input_file)[1]
for _, str in ipairs(split_string(input, ",")) do
  local hash = hash_string(str)
  result = result + hash
end

print("Part 1 result: "..result)
