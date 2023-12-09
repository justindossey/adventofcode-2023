-- Advent of Code day 1

local rex = require "rex_pcre2"

local input_file = 'input.txt'
local numberWords = { one="1", two="2", three="3", four="4", five="5",
                      six="6", seven="7", eight="8", nine="9" }

local function sum_values(tabl)
  local sum = 0
  for _, value in ipairs(tabl) do
    sum = sum + value
  end
  return sum
end

-- Open the file in read mode
local file = io.open(input_file, "r")

local calibration_values = {}

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

-- Now 'lines' table contains all lines from the file
for i, line in ipairs(lines) do
  -- the calibration values are the first and last digit in the line
  local _, _, left, right = string.find(line, "^%a*(%d).*(%d)%a*")
  -- if there is only one number in the string, left = right
  if not left then
    _, _, left = string.find(line, "^%a*(%d).*")
    right = left
  end
  calibration_values[i] = left .. right
end

print("part 1 sum is " .. sum_values(calibration_values))

-- part 2. Count spelled-out digits as their numeric equivalents.
-- return the first number (spelled out or not) from the string
local function firstNumber(input)
  local pattern = "([123456789]|one|two|three|four|five|six|seven|eight|nine)"
  local _, _, result = rex.find(input, pattern, 1)
  return numberWords[result] or result
end

-- return the last number (spelled out or not) from the string
local function lastNumber(input)
  local pattern = ".*([123456789]|one|two|three|four|five|six|seven|eight|nine)"
  local _, _, result = rex.find(input, pattern)
  return numberWords[result] or result
end

for i, line in ipairs(lines) do
  local left = firstNumber(line)
  local right = lastNumber(line)
  calibration_values[i] = left .. right
  -- print(line .. " => " .. calibration_values[i])
end

print("part 2 sum is " .. sum_values(calibration_values))
