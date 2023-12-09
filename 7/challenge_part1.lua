-- Advent of Code day 7
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
local card_strengths = { ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5, ["6"] = 6,
                         ["7"] = 7, ["8"] = 8, ["9"] = 9, ["T"] = 10,
                         ["J"] = 11, ["Q"] = 12, ["K"] = 13, ["A"] = 14 }
local scores = { ["five_of_a_kind"] = 9, ["four_of_a_kind"] = 8,
                 ["full_house"] = 7, ["three_of_a_kind"] = 6,
                 ["two_pairs"] = 5, ["pair"] = 4, ["distinct"] = 3 }

-- return a table that tallies the number of each card type in the hand                    
local tally_results = {}
setmetatable(tally_results, { __mode = "kv" })
local function tally(list)
  if tally_results[list] then
    return tally_results[list]
  end
  local tally = {}
  for _, card in ipairs(list) do
    if not tally[card] then
      tally[card] = 1
    else
      tally[card] = tally[card] + 1
    end
  end
  tally_results[list] = tally
  return tally
end

-- return true if the hand is a five of a kind
local function five_of_a_kind(hand)
  local tally = tally(hand)
  for _, count in pairs(tally) do
    if count == 5 then
      return scores["five_of_a_kind"]
    end
  end
  return 0
end

-- return true if the hand is a four of a kind
local function four_of_a_kind(hand)
  local tally = tally(hand)
  for _, count in pairs(tally) do
    if count == 4 then
      return scores["four_of_a_kind"]
    end
  end
  return 0
end

-- return true if the hand is a full house
local function full_house(hand)
  local tally = tally(hand)
  local has_three = false
  local has_two = false
  for _, count in pairs(tally) do
    if count == 3 then
      has_three = true
    elseif count == 2 then
      has_two = true
    end
  end
  return has_three and has_two and scores["full_house"] or 0
end

-- return true if the hand is a three of a kind
local function three_of_a_kind(hand)
  local tally = tally(hand)
  for _, count in pairs(tally) do
    if count == 3 then
      return scores["three_of_a_kind"]
    end
  end
  return 0
end

-- return true if the hand is two pairs
local function two_pairs(hand)
  local pairs_count = 0
  for _, count in pairs(tally(hand)) do
    if count == 2 then
      pairs_count = pairs_count + 1
    end
  end
  return pairs_count == 2 and scores["two_pairs"] or 0
end

-- return true if the hand is a pair
local function pair(hand)
  local tally = tally(hand)
  for _, count in pairs(tally) do
    if count == 2 then
      return scores["pair"]
    end
  end
  return 0
end

-- return true if the hand is all distinct cards
local function distinct(hand)
  local tally = tally(hand)
  for _, count in pairs(tally) do
    if count > 1 then
      return 0
    end
  end
  return scores["distinct"]
end

-- return the hand score for a hand
local function hand_strength(hand)
  local score = five_of_a_kind(hand)
  if score > 0 then
    return score
  end
  score = four_of_a_kind(hand)
  if score > 0 then
    return score
  end
  score = full_house(hand)
  if score > 0 then
    return score
  end
  score = three_of_a_kind(hand)
  if score > 0 then
    return score
  end
  score = two_pairs(hand)
  if score > 0 then
    return score
  end
  score = pair(hand)
  if score > 0 then
    return score
  end
  return distinct(hand)
end

-- compare two "equal" hands and return the one with the leftmost higher card.
-- return -1 if hand1 is stronger, 1 if hand2 is stronger, and 0 if they are
-- equal.
local function compare_equal(hand1, hand2)
  for i = 1, 5 do
    local card1 = card_strengths[hand1[i]]
    local card2 = card_strengths[hand2[i]]
    if card1 > card2 then
      return 1
    elseif card2 > card1 then
      return -1
    end
  end
  return 0 -- both hands are the same
end

local function compare_hands(hand1, hand2)
  local score1 = hand_strength(hand1)
  local score2 = hand_strength(hand2)
  if score1 > score2 then
    return 1
  elseif score2 > score1 then
    return -1
  else
    return compare_equal(hand1, hand2)
  end
end

-- iterate over the lines table and split each hand into two parts: the cards
-- and the bid.
local hands = {}
for _, line in ipairs(lines) do
  local cards = {}
  local bid = ""
  for card in line:gmatch("%S") do
    if #cards < 5 then
      table.insert(cards, card)
    else
      bid = bid .. card
    end
  end
  table.insert(hands, { cards = cards, bid = tonumber(bid) })
end
-- now sort the hands by strength
table.sort(hands, function(a, b) return compare_hands(a.cards, b.cards) == -1 end)
-- print the strength of each hand
for i, hand in pairs(hands) do
  print("Hand "..i..": "..inspect(hand.cards).." strength: "..hand_strength(hand.cards))
end
print("Sorted hands:"..inspect(hands))
-- now multiply each hand's bid by its rank
local total = 0
for i = 1, #hands do
  total = total + (hands[i].bid * i)
end
print("Total: "..total)

