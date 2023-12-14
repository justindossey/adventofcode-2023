-- Advent of Code day 13 part 2
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

-- compare two strings. If the strings differ by only one character, return true.
-- Otherwise, return false.
local function matchesWithSmudge(s1, s2)
  if not (s1 and s2) then return false end

  local differences = 0
  for i = 1, #s1 do
    if s1:sub(i, i) ~= s2:sub(i, i) then
      differences = differences + 1
    end
  end
  return differences == 1
end
-- make a stack. For each map, push each row onto the stack. If the row I'm
-- about to push is the same as the row at the top of the stack, return the row
-- index minus one.
local function findDuplicateRow(map)
  local stack = {}
  local maybe_match = false
  local smudge = false
  for i = 1, #map do
    local row = map[i]
    logd("Comparing " .. row .. " to stack " .. inspect(stack[#stack]))
    if stack[#stack] == row then
      -- if we have an exact match, look for a match with a smudge
      maybe_match = true
      -- walk through the rest of the rows and see if they all match the stack.
      -- If we run out of stack or rows to compare, then we have a match.
      local j = i
      local k = #stack
      while j <= #map and k > 0 do
        if not smudge and matchesWithSmudge(map[j], stack[k]) then
          logd("A: Found smudge match at " .. map[j] .. " and " .. map[k])
          smudge = true
          j = j + 1
          k = k - 1
        end
        if map[j] and map[k] and map[j] ~= stack[k] then
          logd("Map " .. j .. "("..map[j]..") and stack " .. k .. "("..stack[k]..") don't match")
          smudge = false
          maybe_match = false
          break
        end
        j = j + 1
        k = k - 1
      end
    elseif matchesWithSmudge(stack[#stack], row) then
      logd("B: Found smudge match at " .. row .. " and " .. stack[#stack])
      -- if we have a smudge match, look for a smudge-free match
      maybe_match = true
      smudge = true
      -- now look for a smudge-free match
      local j = i + 1
      local k = #stack - 1
      while j <= #map and k > 0 do
        if map[j] ~= stack[k] then
          logd("Map " .. j .. "("..map[j]..") and stack " .. k .. "("..stack[k]..") don't match")
          smudge = false
          maybe_match = false
          break
        end
        j = j + 1
        k = k - 1
      end
    end
    -- we can only have a match if there is a smudge
    if maybe_match and smudge then
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
  local found = false
  if row then
    logd("Duplicate row found at " .. row .. " in map " .. n)
    found = true
    duplicate_rows = duplicate_rows + (100 * row)
  else
    local transposed_map = transpose(map)
    row = findDuplicateRow(transposed_map)
    if row then
      found = true
      logd("Duplicate column found at " .. row .. " in map " .. n)
      duplicate_columns = duplicate_columns + row
    end
  end
  if not found then
    print("Error: no mirror point found in map " .. n)
    os.exit(1)
  end
end
print("Part 2 answer: " .. duplicate_rows + duplicate_columns)
