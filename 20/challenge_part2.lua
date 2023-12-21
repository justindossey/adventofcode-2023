-- Advent of Code day 20 part 2
-- local inspect = require("inspect")

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
local button_presses = 0
local function inc_high_pulse_count()
  high_pulse_count = high_pulse_count + 1
end
local function inc_low_pulse_count()
  low_pulse_count = low_pulse_count + 1
end
local message_queue = {}
local cycles = {}
local stop_pressing_button = false
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

  function self.all_inputs_have_cycled()
    for _, input in pairs(self.inputs) do
      if not cycles[input.input.name] then
        return false
      end
    end
    return true
  end

  function self.receive(pulse, input_obj)
    local input = self.inputs[input_obj.name]
    -- if this conjunction is connected to the RX output, we need to track
    -- how many cycles it takes for an input to go to high. After they all
    -- have gone high once, we can calculate how many button presses it will
    -- take before they are all high at the same time.
    -- so this next statement means "If we are the rx conjunction, and the
    -- pulse is high, and we haven't already set the cycle for this input,
    -- then set the cycle for this input to the current button press count."
    -- Also, once all my inputs have been recorded once, we can stop pressing
    -- buttons (hence "stop_pressing_button = true").
    if self.is_rx_conjunction and pulse == "high"
      and not cycles[input_obj.name] then
      cycles[input_obj.name] = button_presses
      logd("Setting "..input_obj.name.." to high at "..button_presses)
      if self.all_inputs_have_cycled() then
        logd("All inputs have cycled")
        stop_pressing_button = true
      end
    end

    -- "normal" conjunction logic
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
    if output.name == "rx" then
      self.is_rx_conjunction = true
    end
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

local function process_queue()
  while #message_queue > 0 do
    local message = table.remove(message_queue, 1)
    local module = modules[message.output]
    module.receive(message.pulse, modules[message.sender])
  end
end

local function gcd(a, b)
  while b ~= 0 do
    a, b = b, a % b
  end
  return a
end

-- Function to calculate the LCM of two numbers
local function lcm(a, b)
  local result = a * b
  local gcdValue = gcd(a, b)

  if gcdValue ~= 0 then
    result = result / gcdValue
  end

  return math.floor(result)
end

local function find_cycle_length()
  local cycle_length = 1
  for _, cycle in pairs(cycles) do
    cycle_length = lcm(cycle_length, cycle)
  end
  return cycle_length
end

local function press_button()
  logd("button -low-> broadcaster")
  button_presses = button_presses + 1
  inc_low_pulse_count() -- for the button press
  modules["broadcaster"].receive("low")
end

-- logd(inspect(modules))
while not stop_pressing_button do
  press_button()
  process_queue()
end
print("Cycle length: "..find_cycle_length())
