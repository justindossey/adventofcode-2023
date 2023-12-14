-- Advent of Code day 13 part 1
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

local lines = readFile(input_file)

local maps = {}

local function loadMaps()
  local i = 1
  while i < #lines do
    local line = lines[i]
    local map = {}
    while line and line ~= "" do
      logd("Adding line: " .. inspect(line))
      table.insert(map, line)
      i = i + 1
      line = lines[i]
    end
    table.insert(maps, map)
    i = i + 1
  end
end
loadMaps()
logd(inspect(maps))

-- make a stack. For each map, push each row onto the stack. If the row I'm
-- about to push is the same as the row at the top of the stack, return the row
-- index minus one.
local function findDuplicateRow(map)
  local stack = {}
  local maybe_match = false
  for i = 1, #map do
    local row = map[i]
    if stack[#stack] == row then
      maybe_match = true
      -- walk through the rest of the rows and see if they all match the stack.
      -- If we run out of stack or rows to compare, then we have a match.
      local j = i
      local k = #stack
      while j <= #map and k > 0 do
        if map[j] ~= stack[k] then
          maybe_match = false
          break
        end
        j = j + 1
        k = k - 1
      end
    end
    if maybe_match then
      return i - 1
    end
    table.insert(stack, row)
  end
  return nil
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
local duplicate_rows = 0
local duplicate_columns = 0
for n, map in ipairs(maps) do
  local row = findDuplicateRow(map)
  if row then
    logd("Duplicate row found at " .. row .. " in map " .. n)
    duplicate_rows = duplicate_rows + (100 * row)
  else
    local transposed_map = transpose(map)
    row = findDuplicateRow(transposed_map)
    if row then
      logd("Duplicate column found at " .. row .. " in map " .. n)
      duplicate_columns = duplicate_columns + row
    else
      logd("No duplicate column found in transposed map " .. n)
    end
  end
end
print("Part 1 answer: " .. duplicate_rows + duplicate_columns)
