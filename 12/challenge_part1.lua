-- Advent of Code day 11 part 1
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
local function table_after(t, index)
  local out = {}
  for i = index, #t do
    table.insert(out, t[i])
  end
  return out
end

local springs = {}
local groups = {}
local calculate_results={}

local function calculate(record, group)
  local key = record .. inspect(group) -- key for memoization
  if calculate_results[key] then
    return calculate_results[key]
  end
  -- did we run out of groups? Maybe ok
  if not next(group) then
    -- if no more damaged springs, then we're ok
    if not record:find("#") then
      return 1
    else
      -- we can't handle more damaged springs
      return 0
    end
  end
  -- do we have groups but no more record?
  if record == "" then
    -- can't fit
    return 0
  end

  -- the first character in the record and the first item in the group is where
  -- we want to start
  local next_character = record:sub(1, 1)
  local next_group = group[1]

  local function pound()
    local this_group = record:sub(1, next_group)
    this_group = this_group:gsub("%?", "#")

    -- if this group can't fit all the damaged strings, bail
    if this_group ~= string.rep("#", (next_group or 0)) then
      return 0
    end

    if #record == next_group then
      if #group == 1 then
        return 1
      else
        return 0
      end
    end
    next_character = record:sub(next_group + 1, next_group + 1)
    if next_character == "?" or next_character == "." then
      local substr = record:sub(next_group + 2, #record)
      logd("recursing with ".. substr .. " and " .. inspect(table_after(group, 2)))
      return calculate(substr, table_after(group, 2))
    end
    return 0
  end

  local function dot()
    return calculate(record:sub(2, #record), group)
  end

  local out
  if next_character == "#" then
    out = pound()
  elseif next_character == "." then
    out = dot()
  elseif next_character == "?" then
    out = dot() + pound()
  else
    print("Error: unknown character " .. next_character)
    return
  end

  calculate_results[key] = out
  return out
end

for i, line in ipairs(lines) do
  local spring_str = line:match("^[^%s]+")
  local group_str = line:match("[^%s]+$")
  table.insert(springs, spring_str)
  -- split the group_str on , to get the groups
  local line_groups = {}
  for group in string.gmatch(group_str, "[^,]+") do
    table.insert(line_groups, tonumber(group))
  end
  table.insert(groups, line_groups)
end

logd(inspect(springs))
logd(inspect(groups))

local output = 0
for i=1, #springs do
  local record = springs[i]
  local group = groups[i]
  output = output + calculate(record, group)
  logd(string.rep("-", 20))
end
print("Part 1: " .. output)

