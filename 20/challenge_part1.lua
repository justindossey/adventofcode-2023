-- Advent of Code day 20 part 1
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
local low_pulse_count = 0
local high_pulse_count = 0
local function inc_high_pulse_count()
  high_pulse_count = high_pulse_count + 1
end
local function inc_low_pulse_count()
  low_pulse_count = low_pulse_count + 1
end
local message_queue = {}

local function DummyModule(name)
  local self = { name=name }
  function self.add_input(input)
  end

  function self.add_output(output)
  end

  function self.receive(pulse, input_obj)
  end
  return self
end

local function FlipFlop(name)
  local self = { name=name, state = "off", outputs = {}, input = nil }

  function self.add_output(output)
    table.insert(self.outputs, output)
    output.add_input(self)
  end

  function self.add_input(input)
    self.input = input
  end

  function self.receive(pulse, input_obj)
    if pulse == "low" then
      if self.state == "off" then
        self.state = "on"
        for _, output in ipairs(self.outputs) do
          logd(self.name.." -high-> "..output.name)
          inc_high_pulse_count()
          table.insert(message_queue,
            {output=output.name, pulse="high", sender=self.name})
        end
      else
        self.state = "off"
        for _, output in ipairs(self.outputs) do
          logd(self.name.." -low-> "..output.name)
          inc_low_pulse_count()
          table.insert(message_queue,
            {output=output.name, pulse="low", sender=self.name})
        end
      end
    end
  end
  return self
end

local function Conjunction(name)
  local self = { name=name, inputs = {}, outputs = {} }

  function self.all_inputs_high()
    for _, input in pairs(self.inputs) do
      if input.state == "low" then
        return false
      end
    end
    return true
  end

  function self.receive(pulse, input_obj)
    local input = self.inputs[input_obj.name]
    input.state = pulse
    if self.all_inputs_high() then
      for _, output in ipairs(self.outputs) do
        logd(self.name.." -low-> "..output.name)
        inc_low_pulse_count()
        table.insert(message_queue,
          {output=output.name, pulse="low", sender=self.name})
      end
    else
      for _, output in ipairs(self.outputs) do
        logd(self.name.." -high-> "..output.name)
        inc_high_pulse_count()
        table.insert(message_queue,
          {output=output.name, pulse="high", sender=self.name})
      end
    end
  end

  function self.add_input(input)
    self.inputs[input.name] = {input=input, state="low"}
  end

  function self.add_output(output)
    table.insert(self.outputs, output)
    output.add_input(self)
  end
  return self
end

local function Broadcast(name)
  local self = {name=name, outputs = {}, input = nil}

  function self.receive(pulse, input_obj)
    for _, output in pairs(self.outputs) do
      logd(self.name.." -"..pulse.."-> "..output.name)
      if pulse == "low" then
        inc_low_pulse_count()
      else
        inc_high_pulse_count()
      end
      table.insert(message_queue,
        {output=output.name, pulse=pulse, sender=self.name})
    end
  end

  function self.add_output(output)
    table.insert(self.outputs, output)
    output.add_input(self)
  end

  return self
end

local modules = {}
local function parse_input(lines)
  for _, line in ipairs(lines) do
    local first_word = line:match("%S+")
    local first_char = first_word:sub(1, 1)
    if first_char == "%" then
      local module_name = first_word:sub(2)
      -- we have a flip-flop module
      modules[module_name] = FlipFlop(module_name)
    elseif first_char == "&" then
      local module_name = first_word:sub(2)
      -- we have a conjunction module
      modules[module_name] = Conjunction(module_name)
    elseif first_word == "broadcaster" then
      -- we have a broadcaster module
      modules[first_word] = Broadcast(first_word)
    end
  end
  -- now process the input again and make the connections
  for _, line in ipairs(lines) do
    local first_word = line:match("%S+")
    local first_char = first_word:sub(1, 1)
    if first_word == "broadcaster" then
      for output in line:gmatch("%s([%a,]+)") do
        if output:find(",") then
          output = output:sub(1, -2) -- trim the trailing comma
        end
        if not modules[output] then -- we have a new module
          modules[output] = DummyModule(output)
        end
        modules[first_word].add_output(modules[output])
      end
    elseif first_char == "%" or first_char == "&" then
      local module_name = first_word:sub(2)
      for output in line:gmatch("%s([%a,]+)") do
        if output:find(",") then
          output = output:sub(1, -2) -- trim the trailing comma
        end
        if not modules[output] then -- we have a new module
          modules[output] = DummyModule(output)
        end
        modules[module_name].add_output(modules[output])
      end
    end
  end
end
parse_input(readFile(input_file))
local pulses = {high=0,low=0}
local function process_queue()
  while #message_queue > 0 do
    -- logd("Message queue: "..inspect(message_queue))
    local message = table.remove(message_queue, 1)
    local module = modules[message.output]
    pulses[message.pulse] = pulses[message.pulse] + 1
    module.receive(message.pulse, modules[message.sender])
  end
end
-- logd(inspect(modules))
for i = 1, 1000 do
  logd("button -low-> broadcaster")
  inc_low_pulse_count() -- for the button press
  modules["broadcaster"].receive("low")
  process_queue()
end
logd("Pulses: "..inspect(pulses))
print("Part 1 answer: "..(low_pulse_count * high_pulse_count))
