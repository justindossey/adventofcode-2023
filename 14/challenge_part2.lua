-- Advent of Code day 14 part 2
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
  -- logd("Transpose: " .. inspect(map) .. " -> " .. inspect(transposed))
  return transposed
end

local lines = readFile(input_file)

-- don't bother with rows. We need columns
local columns = transpose(lines)
local total_rows = #lines

-- On a string, remove leading periods before an O, and remove periods between
-- Os. Also, if a # is followed by a series of periods before an O, remove the
-- periods.
local function collapse_north(cols)
  local function collapse_north_one(str)
    local count
    repeat
      str, count = str:gsub("(%.+)(O+)", "%2%1")
    until count == 0
    return str
  end

  local out = {}
  for _, str in ipairs(cols) do
    table.insert(out, collapse_north_one(str))
  end
  return out
end

local function collapse_south(cols)
  local function collapse_south_one(str)
    local count
    repeat
      str, count = str:gsub("(O+)(%.+)", "%2%1")
    until count == 0
    return str
  end

  local out = {}
  for _, str in ipairs(cols) do
    table.insert(out, collapse_south_one(str))
  end
  return out
end

-- cycle order: north, west, south, east
local function collapse_west(cols)
  local rows = transpose(cols)
  return transpose(collapse_north(rows))
end

local function collapse_east(cols)
  local rows = transpose(cols)
  return transpose(collapse_south(rows))
end

-- join all the rows in a table into a single string for an easy memoization key
-- We could just as easily have done some kind of hash, but we don't have
-- constraints that would require that.
local function join_rows(rows)
  local str = ""
  for _, row in ipairs(rows) do
    str = str .. row
  end
  return str
end

local cycle_results = {}
local function cycle(cols, idx)
  local key = join_rows(cols)
  local result = collapse_north(cols)
  result = collapse_west(result)
  result = collapse_south(result)
  result = collapse_east(result)
  cycle_results[key] = {cols=result, idx=idx}
  return result
end

logd(inspect(lines))

-- To avoid running cycle() a billion times, we look for a loop: a point where
-- the cycle repeats itself. Subsequent cycles then loop in that interval
-- forever. So I know what the result is at one billion with a bit of
-- arithmetic:
-- ======<START>======<END>
--         ^            |
--         L============J
-- (END - START) = CYCLE_SIZE
-- (1000000000 - START) % CYCLE_SIZE = CYCLE_POSITION
-- CYCLE_POSITION + START = CYCLE_RESULT
local has_cycle = false
local i=1
local iterations = 1000000000
local iteration_number
while not has_cycle do -- look for the cycle
  columns = cycle(columns, i)
  i = i + 1
  local cycle_check = cycle_results[join_rows(columns)]
  if cycle_check then -- found it
    logd("Cycle detected at " .. i)
    local cycle_size = i - cycle_check.idx
    iteration_number = ((iterations - cycle_check.idx) % cycle_size) + cycle_check.idx
    has_cycle = true
  end
end

-- find the cycle result at iteration number so we don't have do do
-- CYCLE_POSITION iterations again
for k, v in pairs(cycle_results) do
  if v.idx == iteration_number then
    columns = v.cols
    break
  end
end

-- now weight the result. We just use a regex to count Os in each row, and
-- multiply that count by the row weight (1 = 10, 2 = 9, 3 = 8, etc).
local rows = transpose(columns)
local weight = 0
for r, row in ipairs(rows) do
  local _, count = row:gsub("O", "O")
  local additional_weight = ((1 + total_rows - r) * count)
  weight = weight + additional_weight
end

print("Part 2 result: " .. weight)
