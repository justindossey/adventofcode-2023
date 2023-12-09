-- Advent of Code day 3
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

-- Part 1: pull all the number positions and symbol positions from the input
local number_positions = {}
local symbol_positions = {}
for lineno, line in ipairs(lines) do
  -- find all the numbers on the line and record {digits=z, start=x, finish=y}
  -- Note that the numbers can repeat, even on a single line
  local finish = 0
  while true do
    local start
    start, finish = line:find("%d+", finish + 1)
    if not start then
      break
    end
    local digits = tonumber(line:sub(start, finish))
    if not number_positions[lineno] then
      number_positions[lineno] = {}
    end
    table.insert(number_positions[lineno], {digits=digits, start=start, finish=finish})
  end

  -- find all the symbols on the line and record them with their positions
  local pos = 0
  while true do
    local _
    pos, _ = line:find("[%*%$/=%+@%-%%&#]", pos + 1)
    if not pos then
      break
    end
    local symbol = line:sub(pos, pos)
    if not symbol_positions[lineno] then
      symbol_positions[lineno] = {}
    end
    table.insert(symbol_positions[lineno], {symbol=symbol, pos=pos})
  end
end
-- now I have number_positions and symbol_positions populated. Iterate over
-- symbol positions and see if any numbers are adjacent to the recorded
-- locations, even diagonally.
local adjacent_numbers = {}
for lineno, symbol_list in pairs(symbol_positions) do
  for _, symbol_data in pairs(symbol_list) do
    local prev_line_candidates = number_positions[lineno - 1]
    if prev_line_candidates then
      -- loop over our candidates and see if any are adjacent, even diagonally
      -- handle top left, top right, or number spanning symbol
      -- top left means the number ends up and to the left
      -- top right means the number begins up and to the right
      -- directly above means the number's (start..finish) include pos
      for _, candidate in pairs(prev_line_candidates) do
        if candidate.finish == symbol_data.pos - 1 or
          candidate.start == symbol_data.pos + 1 or
          (candidate.start <= symbol_data.pos and
            candidate.finish >= symbol_data.pos) then
          table.insert(adjacent_numbers, candidate.digits)
        end
      end
    end
    -- current line is easier because we only have to check left and right
    local cur_line_candidates = number_positions[lineno]
    if cur_line_candidates then
      for _, candidate in pairs(cur_line_candidates) do
        if candidate.finish == symbol_data.pos - 1 or
          candidate.start == symbol_data.pos + 1 then
          table.insert(adjacent_numbers, candidate.digits)
        end
      end
    end
    -- next line: check bottom left, bottom, bottom right
    local next_line_candidates = number_positions[lineno + 1]
    if next_line_candidates then
      for _, candidate in pairs(next_line_candidates) do
        if candidate.finish == symbol_data.pos - 1 or
          candidate.start == symbol_data.pos + 1 or
          (candidate.start <= symbol_data.pos and
            candidate.finish >= symbol_data.pos) then
          table.insert(adjacent_numbers, candidate.digits)
        end
      end
    end
  end
end

-- now I have a list of all the adjacent numbers. Sum them up.
local part1_sum = 0
for _, number in ipairs(adjacent_numbers) do
  part1_sum = part1_sum + number
end
print("Part 1: " .. part1_sum)

-- Part 2: find only the symbols which are gears ("*") and if it is adjacent
-- to exactly two parts, multiply the part numbers and add to the part 2 sum.
adjacent_numbers = {}
for lineno, symbol_list in pairs(symbol_positions) do
  for _, symbol_data in pairs(symbol_list) do
    if symbol_data.symbol == "*" then
      local adjacent_candidates = {}
      local prev_line_candidates = number_positions[lineno - 1]
      if prev_line_candidates then
        -- loop over our candidates and see if any are adjacent, even diagonally
        -- handle top left, top right, or number spanning symbol
        -- top left means the number ends up and to the left
        -- top right means the number begins up and to the right
        -- directly above means the number's (start..finish) include pos
        for _, candidate in pairs(prev_line_candidates) do
          if candidate.finish == symbol_data.pos - 1 or
            candidate.start == symbol_data.pos + 1 or
            (candidate.start <= symbol_data.pos and
              candidate.finish >= symbol_data.pos) then
            table.insert(adjacent_candidates, candidate.digits)
          end
        end
      end
      -- current line is easier because we only have to check left and right
      local cur_line_candidates = number_positions[lineno]
      if cur_line_candidates then
        for _, candidate in pairs(cur_line_candidates) do
          if candidate.finish == symbol_data.pos - 1 or
            candidate.start == symbol_data.pos + 1 then
            table.insert(adjacent_candidates, candidate.digits)
          end
        end
      end
      -- next line: check bottom left, bottom, bottom right
      local next_line_candidates = number_positions[lineno + 1]
      if next_line_candidates then
        for _, candidate in pairs(next_line_candidates) do
          if candidate.finish == symbol_data.pos - 1 or
            candidate.start == symbol_data.pos + 1 or
            (candidate.start <= symbol_data.pos and
              candidate.finish >= symbol_data.pos) then
            table.insert(adjacent_candidates, candidate.digits)
          end
        end
      end
      if #adjacent_candidates == 2 then
        local multiple = 1
        for _, number in pairs(adjacent_candidates) do
          multiple = multiple * number
        end
        table.insert(adjacent_numbers, multiple)
      end
    end
  end
end

local part2_sum = 0
for _, number in ipairs(adjacent_numbers) do
  part2_sum = part2_sum + number
end
print("Part 2: " .. part2_sum)
