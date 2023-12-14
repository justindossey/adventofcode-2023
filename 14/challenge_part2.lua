-- Advent of Code day 14 part 2
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

-- join all the rows in a table into a single string
local function join_rows(rows)
  local str = ""
  for _, row in ipairs(rows) do
    str = str .. row
  end
  return str
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

local cycle_results = {}
local function cycle(cols, idx)
  local key = join_rows(cols)
  if cycle_results[key] then
    logd("Cycle detected at " .. idx .. " (previous " .. cycle_results[key].idx .. ")")
    return cycle_results[key].cols
  end
  local result = collapse_north(cols)
  result = collapse_west(result)
  result = collapse_south(result)
  result = collapse_east(result)
  cycle_results[key] = {cols=result, idx=idx}
  return result
end

logd(inspect(lines))

-- convert columns to a row-grid string
local function stringify(cols)
  local str = ""
  for _, row in ipairs(transpose(cols)) do
    str = str .. row .. "\n"
  end
  return str
end

-- from testing, I know that the input I was given cycles at index 117, which
-- matches index 82. Subsequent cycles then loop in that 82..117 interval
-- forever. So I know what the result is at one billion with a bit of
-- arithmetic:
-- ======<82>======<116>
--         ^         |
--         L=========J
-- (117 - 82) = 35
-- (1000000000 - 82) % 35 = 8
-- 8 + 82 = 90
for i=1, 90 do
  columns = cycle(columns, i)
end

local rows = transpose(columns)
local weight = 0
for i, row in ipairs(rows) do
  local _, count = row:gsub("O", "O")
  weight = weight + ((1 + total_rows - i) * count)
end
print("Part 2 result: " .. weight)
