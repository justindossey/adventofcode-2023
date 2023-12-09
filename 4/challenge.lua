-- Advent of Code day 4
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

local input_file = "input.txt"
local lines = readFile(input_file)

-- Part 1
local function tally_points(wins)
  local sum = 0
  for _, value in pairs(wins) do
    sum = sum == 0 and 1 or sum * 2
  end
  return sum
end

local total_points = 0
for card_no, line in ipairs(lines) do
  local winning_numbers = {}
  local my_numbers = {}
  local matched_numbers = {}
  -- print("Card "..card_no)
  for values in line:gmatch(":([%s%d]+)|") do
    for num in values:gmatch("(%d+)") do
      winning_numbers[tonumber(num)] = true
    end
  end
  -- print("Winning numbers: "..inspect(winning_numbers))
  for values in line:gmatch("|([%s%d]+)$") do
    for num in values:gmatch("(%d+)") do
      local numeric_val = tonumber(num)
      table.insert(my_numbers, numeric_val)
      if winning_numbers[numeric_val] then
        table.insert(matched_numbers, numeric_val)
      end
    end
  end
  -- print("My numbers: "..inspect(my_numbers))
  -- print("Matched numbers: "..inspect(matched_numbers))
  -- tally up the points for matching numbers
  local new_points = tally_points(matched_numbers)
  -- print("New points: "..new_points)
  total_points = total_points + new_points
end
print("Part 1 sum: "..total_points)

-- Part 2
local cards = {}
for card_no, line in ipairs(lines) do
  local winning_numbers = {}
  local wins = 0
  for values in line:gmatch(":([%s%d]+)|") do
    for num in values:gmatch("(%d+)") do
      winning_numbers[tonumber(num)] = true
    end
  end
  for values in line:gmatch("|([%s%d]+)$") do
    for num in values:gmatch("(%d+)") do
      local numeric_val = tonumber(num)
      if winning_numbers[numeric_val] then
        wins = wins + 1
      end
    end
  end
  table.insert(cards, {wins=wins, copies=1})
end
-- print("Cards: "..inspect(cards))

for card_no, card in ipairs(cards) do
  if card.wins > 0 then
    for i=card_no + 1, card_no + card.wins do
      cards[i].copies = cards[i].copies + card.copies
    end
  end
end

-- print("Cards post-win calc: "..inspect(cards))

-- now sum up the total number of copies
local part2_sum = 0
for _, card in ipairs(cards) do
  part2_sum = part2_sum + card.copies
end
print("Part 2 sum: "..part2_sum)

