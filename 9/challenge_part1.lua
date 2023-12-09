-- Advent of Code day 9 part 1
local inspect = require("inspect")

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

local input_file = "input.txt"
local lines = readFile(input_file)
local rows = {}

local function parseLine(line)
  local numbers = {}
  for number in string.gmatch(line, "-?%d+") do
    table.insert(numbers, tonumber(number))
  end
  return numbers
end

logd("Lines", inspect(lines))
for _, line in ipairs(lines) do
  local numbers = parseLine(line)
  table.insert(rows, numbers)
end
logd("Rows", inspect(rows))
-- Recursively left-fold subtraction into the numbers in a row until the
-- difference between each number is 0. Example:
--  [1, 2, 3, 4, 5] -> [1, 1, 1, 1, 1] -> 1
local function reduce(row)
  local new_numbers = {}
  local number_counts = {}
  for i = 1, #row - 1 do
    local diff = row[i + 1] - row[i]
    number_counts[diff] = (number_counts[diff] or 0) + 1
    table.insert(new_numbers, diff)
  end
  local num = next(number_counts)
  -- if all the differences in this row are the same, return that number
  if number_counts[num] == #row - 1 then
    return num
  else
    logd("Recursing with "..inspect(new_numbers))
    local val = reduce(new_numbers)
    table.insert(new_numbers, val + new_numbers[#new_numbers])
    logd("New numbers "..inspect(new_numbers))
    return new_numbers[#new_numbers]
  end
end

logd("Row 1 reduction")
local sum = 0
for i = 1, #rows do
  local val = reduce(rows[i])
  sum = sum + val + rows[i][#rows[i]]
end
print("Part 1 Sum: "..sum)
