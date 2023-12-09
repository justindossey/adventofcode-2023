-- Advent of Code day 5
-- local inspect = require("inspect")

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

local input_file = arg[1]
local lines = readFile(input_file)

-- Part 2
local in_map = false
local map_name
local maps = {}
local seeds = {}

-- parse the input into seeds and maps
print("Parsing input...")
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
    for seed_pair in seed_ids:gmatch("%d+ %d+") do
      local _, _, seed_start, seed_end = seed_pair:find("(%d+) (%d+)")
      table.insert(seeds, {min=tonumber(seed_start),
                           max=tonumber(seed_start)+tonumber(seed_end)})
    end
  elseif line:find("^.+ map:") then
    _, _, map_name = line:find("^(.+) map:")
    in_map = true
  end
end

-- print(inspect(maps))
-- print(inspect(seeds))
-- transform location_id into seed_id
local function reverse_transform(target_id, map_name)
  if not maps[map_name] then
    print("Error: no map named "..map_name)
    return -1000
  end
  for _, map_data in ipairs(maps[map_name]) do
    if target_id >= map_data.target and
       target_id < map_data.target + map_data.size then
      return map_data.source + (target_id - map_data.target)
    end
  end
  -- default: target_id is the source_id
  return target_id
end

print("Transforming seeds...")
-- running 100,000 locations at a time, find the lowest location that has a
-- seed. Why 100,000? It's fast and it works. Bigger numbers miss seeds. Smaller
-- numbers take too long.
local found=false
local location_id = 0
while not found do
  -- transform location to humidity
  local humidity_id = reverse_transform(location_id, 'humidity-to-location')
  local temperature_id = reverse_transform(humidity_id, 'temperature-to-humidity')
  local light_id = reverse_transform(temperature_id, 'light-to-temperature')
  local water_id = reverse_transform(light_id, 'water-to-light')
  local fertilizer_id = reverse_transform(water_id, 'fertilizer-to-water')
  local soil_id = reverse_transform(fertilizer_id, 'soil-to-fertilizer')
  local seed_id = reverse_transform(soil_id, 'seed-to-soil')
  for _, seed_data in ipairs(seeds) do
    if seed_id >= seed_data.min and seed_id < seed_data.max then
      found = true
      break
    end
  end
  if not found then
    location_id = location_id + 100000
  end
end
-- now that we have a location with a seed, find the lowest location that has
-- a seed, starting with the location we found above minus 100,000
found=false
location_id = location_id - 100000
print("Starting with location "..location_id)
while not found do
  -- transform location to humidity
  local humidity_id = reverse_transform(location_id, 'humidity-to-location')
  local temperature_id = reverse_transform(humidity_id, 'temperature-to-humidity')
  local light_id = reverse_transform(temperature_id, 'light-to-temperature')
  local water_id = reverse_transform(light_id, 'water-to-light')
  local fertilizer_id = reverse_transform(water_id, 'fertilizer-to-water')
  local soil_id = reverse_transform(fertilizer_id, 'soil-to-fertilizer')
  local seed_id = reverse_transform(soil_id, 'seed-to-soil')
  for _, seed_data in ipairs(seeds) do
    if seed_id >= seed_data.min and seed_id < seed_data.max then
      found = true
      break
    end
  end
  if not found then
    location_id = location_id + 1
  end
end

print("Part 2: "..location_id)
