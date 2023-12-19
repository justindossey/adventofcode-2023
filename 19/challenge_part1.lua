-- Advent of Code day 19 part 1
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

-- input is a list of workflows, followed by a blank line, followed by a list
-- of part ratings.
local workflows = {}
local parts = {}
local part_ratings = {}
      local function greater_than(left, right)
        return left > right
      end
      local function less_than(left, right)
        return left < right
      end

local function parseInput(input)
  local function parse_workflow(str)
    -- parse a workflow into a table of actions. Actions may be a reference to
    -- another workflow.
    -- The grammar:
    -- VALUE = NUMBER
    -- COMPARISON = "<" | ">"
    -- WORKFLOW_NAME = "[a-z]+"
    -- ACTION = WORKFLOW | WORKFLOW_NAME | "A" | "R"
    -- VARIABLE = "x" | "m" | "a" | "s"
    -- CONDITION = VARIABLE COMPARISON VALUE
    -- WORKFLOW = CONDITION ":" ACTION "," ACTION
    local function condition_to_function(condition)
      local variable, comparison, value = condition:match("^(%a+)([<>])(%d+)$")
      local condition_function
      if not variable then
        print("Error parsing condition: " .. condition)
        return
      end
      if comparison == ">" then
        condition_function = greater_than
      elseif comparison == "<" then
        condition_function = less_than
      else
        print("Error parsing condition: " .. condition)
        return
      end
      return { comparision=condition_function, variable=variable, value=tonumber(value) }
    end
    local workflow = {}
    local condition, action1, action2 = str:match("^([^:]+):([^,]+),(%S+)")
    workflow.condition = condition_to_function(condition)
    workflow.action1 = action1
    if action2:find(":") then
      workflow.action2 = parse_workflow(action2)
    else
      workflow.action2 = action2
    end
    return workflow
  end
  local workflow_section = true
  repeat
    local line = table.remove(input, 1) -- remove the first line
    if workflow_section then
      if line == "" then
        workflow_section = false
      else
        local part, workflow = line:match("^(%a+)%{(%S+)%}")
        workflows[part] = parse_workflow(workflow)
      end
    else
      -- part ratings look like "{x=123,m=456,a=789,s=101112}"
      -- Convert them to a table with x, m, a, and s keys
      part_ratings = {}
      for key, value in line:gmatch("(%a)=(%d+)") do
        part_ratings[key] = tonumber(value)
      end
      table.insert(parts, part_ratings)
    end
  until #input == 0
end

-- process a single part through a single workflow. Return R or A.
local function process_workflow(part, workflow)
  part_ratings = part
  if workflow.condition.comparision(part[workflow.condition.variable], workflow.condition.value) then
    if type(workflow.action1) == "table" then
      return process_workflow(part, workflow.action1)
    else
      return workflow.action1
    end
  else
    if type(workflow.action2) == "table" then
      return process_workflow(part, workflow.action2)
    else
      return workflow.action2
    end
  end
end

-- read my input into tables
parseInput(readFile(input_file))

-- add up the x, m, a, s values of a part
local function part_sum(ratings)
  local sum = 0
  for _, value in pairs(ratings) do
    sum = sum + value
  end
  return sum
end

-- process each of the parts through the workflow and count accepts
local sum = 0
for _, part in pairs(parts) do
  local done = false
  local workflow_name = "in"
  repeat
    local workflow = workflows[workflow_name]
    local result = process_workflow(part, workflow)
    logd("Workflow " .. workflow_name .. " returned " .. result)
    if result == "A" then
      done = true
      sum = sum + part_sum(part)
    elseif result == "R" then
      done = true
    else
      workflow_name = result
    end
  until done
end

print("Sum of parts that are accepted: " .. sum)
