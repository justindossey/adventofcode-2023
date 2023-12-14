-- Advent of Code day 14 part 1
local inspect = require("inspect")

local input_file = "input.txt"
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

-- transpose the rows and columns in an array of strings. For example,
-- { "abc", "def", "ghi" } becomes { "adg", "beh", "cfi" }
local function transpose(map)
  local transposed = {}
  for i = 1, #map[1] do
    local row = ""
    for j = 1, #map do
      row = row .. map[j]:sub(i, i)
    end
    table.insert(transposed, row)
  end
  return transposed
end

local lines = readFile(input_file)

-- don't bother with rows. We need columns
local columns = transpose(lines)
local total_rows = #lines

-- On a string, remove leading periods before an O, and remove periods between Os.
-- Also, if a # is followed by a series of periods before an O, remove the periods.
local function collapse(str)
  local count
  repeat
    str, count = str:gsub("(%.+)(O+)", "%2%1")
  until count == 0
  return str
end
logd("Lines")
logd(inspect(lines))

for i = 1, #columns do
  local col = columns[i]
  columns[i] = collapse(col)
end

local rows = transpose(columns)
local weight = 0
for i, row in ipairs(rows) do
  local _, count = row:gsub("O", "O")
  weight = weight + ((1 + total_rows - i) * count)
end
print("Part 1 result: " .. weight)
