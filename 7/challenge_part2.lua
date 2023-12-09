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
                         ["J"] = 1, ["Q"] = 12, ["K"] = 13, ["A"] = 14 }
local scores = { ["five_of_a_kind"] = 9, ["four_of_a_kind"] = 8,
                 ["full_house"] = 7, ["three_of_a_kind"] = 6,
                 ["two_pairs"] = 5, ["pair"] = 4, ["distinct"] = 3 }

-- return a table that tallies the number of each card type in the hand
-- memoize the results so we don't have to tally the same hand multiple times
local tally_results = {}
setmetatable(tally_results, { __mode = "kv" })
local function tally(list)
  if tally_results[list] then
    return tally_results[list]
  end
  local t = {}
  for _, card in ipairs(list) do
    t[card] = (t[card] or 0) + 1
  end
  tally_results[list] = t
  return t
end

-- return true if the hand is a five of a kind
local function five_of_a_kind(hand)
  local jokers = 0
  local highest_count = 0
  for card, count in pairs(tally(hand)) do
    if card == "J" then
      jokers = jokers + count
    elseif count > highest_count then
      highest_count = count
    end
  end
  if highest_count + jokers == 5 then
    return scores["five_of_a_kind"]
  end
  return 0
end

-- return true if the hand is a four of a kind
local function four_of_a_kind(hand)
  local jokers = 0
  local highest_count = 0
  for card, count in pairs(tally(hand)) do
    if card == "J" then
      jokers = jokers + count
    elseif count > highest_count then
      highest_count = count
    end
  end
  if highest_count + jokers == 4 then
    return scores["four_of_a_kind"]
  end
  return 0
end

-- return true if the hand is a full house
local function full_house(hand)
  local has_three = false
  local pair_count = 0
  local jokers = 0
  for card, count in pairs(tally(hand)) do
    if card == "J" then
      jokers = jokers + count
    elseif count == 3 then
      has_three = true
    elseif count == 2 then
      pair_count = pair_count + 1
    end
  end
  -- (3, 2) -> full house
  if has_three and pair_count == 1 then
    return scores["full_house"]
  end
  -- (2, 2, J) -> full house
  if pair_count == 2 and jokers == 1 then
    return scores["full_house"]
  end
  return 0
end

-- return true if the hand is a three of a kind
local function three_of_a_kind(hand)
  local jokers = 0
  local highest_count = 0
  for card, count in pairs(tally(hand)) do
    if card == "J" then
      jokers = jokers + count
    elseif count > highest_count then
      highest_count = count
    end
  end
  if highest_count + jokers == 3 then
    return scores["three_of_a_kind"]
  end

  return 0
end

-- return true if the hand is two pairs. A joker would make this a different hand.
local function two_pairs(hand)
  local pairs_count = 0
  for _, count in pairs(tally(hand)) do
    if count == 2 then
      pairs_count = pairs_count + 1
    end
  end
  if pairs_count == 2 then -- two pairs
    return scores["two_pairs"]
  end
  return 0
end

-- return true if the hand has one pair. Jokers don't help here, because
-- if we have one pair and a joker, we have three of a kind.
local function pair(hand)
  for card, count in pairs(tally(hand)) do
    if card == "J" or count == 2 then
      return scores["pair"]
    end
  end
  return 0
end

-- return true if the hand is all distinct cards
local function distinct(hand)
  return scores["distinct"]
end

-- debug function
local debug = false
local function logd(...)
  if debug then
    print(...)
  end
end

-- return the hand score for a hand
local function hand_strength(hand)
  local ordered_hand_functions = { five_of_a_kind, four_of_a_kind, full_house,
                                   three_of_a_kind, two_pairs, pair, distinct }

  -- iterate over the hand functions in order of strength and return the first
  -- one that matches
  for _, hand_function in ipairs(ordered_hand_functions) do
    local score = hand_function(hand)
    if score > 0 then
      return score
    end
  end
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
  logd("Hand "..i..": "..inspect(hand.cards).." strength: "..hand_strength(hand.cards))
end
logd("Sorted hands:"..inspect(hands))

-- now multiply each hand's bid by its rank
local total = 0
for i = 1, #hands do
  total = total + (hands[i].bid * i)
end
print("Total: "..total)
