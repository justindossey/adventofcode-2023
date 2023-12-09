-- Advent of Code day 5
local inspect = require("inspect")

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

-- Part 1
local in_map = false
local map_name
local maps = {}
local seeds = {}

-- parse the input into seeds and maps
for _, line in ipairs(lines) do
  if in_map then
    if line == "" then
      in_map = false
    elseif line:find("^%d+") then
      -- source_id...source_id+range size => target_id...target_id+range_size
      local _, _, target_id, source_id, range_size = line:find("(%d+) (%d+) (%d+)")
      -- the seed IDs are too large to create a 1:1 mapping. We have to map ranges
      if not maps[map_name] then
        maps[map_name] = {}
      end
      table.insert(maps[map_name],
        { source = tonumber(source_id),
          target = tonumber(target_id),
          size = tonumber(range_size) })
    end
  elseif line:find("^seeds:") then
    local seed_ids = line:match("^seeds: ([%d%s]+)")
    for seed_id in seed_ids:gmatch("%d+") do
      table.insert(seeds, tonumber(seed_id))
    end
  elseif line:find("^.+ map:") then
    _, _, map_name = line:find("^(.+) map:")
    in_map = true
  end
end

-- print(inspect(maps))
-- print(inspect(seeds))

-- now transform seed_id into soil number
local function transform(source_id, map_name)
  if not maps[map_name] then
    print("Error: no map named "..map_name)
    return -1000
  end
  for _, map_data in ipairs(maps[map_name]) do
    if source_id >= map_data.source and
      source_id < map_data.source + map_data.size then
      return map_data.target + (source_id - map_data.source)
    end
  end
  -- default: seed_id is the soil_id
  return source_id
end
local locations = {}
for _, seed_id in ipairs(seeds) do
  local soil_id = transform(seed_id, "seed-to-soil")
  local fertilizer_id = transform(soil_id, "soil-to-fertilizer")
  local water_id = transform(fertilizer_id, "fertilizer-to-water")
  local light_id = transform(water_id, "water-to-light")
  local temperature_id = transform(light_id, "light-to-temperature")
  local humidity_id = transform(temperature_id, "temperature-to-humidity")
  local location_id = transform(humidity_id, "humidity-to-location")
  table.insert(locations, location_id)
end
-- find the minimum location id in location_ids
local min
for _, location_id in ipairs(locations) do
  if not min or location_id < min then
    min = location_id
  end
end
print("Part 1: "..min)

-- Part 2
