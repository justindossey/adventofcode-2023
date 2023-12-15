-- Advent of Code day 15 part 2
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

local boxes = {}
-- populate the boxes table with 256 empty tables
for i = 1, 256 do
  boxes[i] = {}
end
  local function index_of_lens_with_label(box_id, label)
    for i, lens in ipairs(boxes[box_id + 1]) do
      if lens.label == label then
        return i
      end
    end
  end

local function process_delete(label)
  logd("Deleting label: "..label)
  local box_id = hash_string(label)
  local index = index_of_lens_with_label(box_id, label)
  if index then
    table.remove(boxes[box_id + 1], index)
    return index
  end
  return nil
end

local function process_upsert(label, focal_length)
  local box_id = hash_string(label)
  logd("Upserting label: "..label.." into box: "..box_id)
  local index = index_of_lens_with_label(box_id, label)
  if index then -- replace
    boxes[box_id + 1][index].focal_length = focal_length
  else
    table.insert(boxes[box_id + 1], {label = label, focal_length = focal_length})
  end
end

local function boxes_string()
  local out = ""
  for i, box in ipairs(boxes) do
    if #box > 0 then
      out = out .. "Box "..i..":"
      for _, lens in ipairs(box) do
        out = out .. " ["..lens.label.." "..lens.focal_length.."]"
      end
      out = out .. "\n"
    end
  end
  return out
end

local result = 0
local input = readFile(input_file)[1]
for _, str in ipairs(split_string(input, ",")) do
  local label
  local op_data
  if str:find("-$") then
    label = str:sub(1, #str - 1)
    process_delete(label)
  else
    op_data = split_string(str, "=")
    process_upsert(op_data[1], tonumber(op_data[2]))
  end
  logd("After "..inspect(str)..":")
  logd(boxes_string())
end
-- calculate the result. Here's how we do this:
-- Box number (1-indexed) * (slot number of the lens in the box) * focal length
for box_id, box in ipairs(boxes) do
  if #box > 0 then
    for slot, lens in ipairs(box) do
      result = result + box_id * slot * lens.focal_length
    end
  end
end
print("Part 2 result: "..result)
