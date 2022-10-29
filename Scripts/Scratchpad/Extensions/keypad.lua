-- A minimal keypad meant for coordinate input

local x = 0
local function advance(w)
  local before = x
	x = x + w
	return before
end

local row1 = addRow()
for i, c in pairs({"N", "S", "W", "E", ".", "'", "\"", "␣"}) do
  if i == 5 then
    advance(3) -- spacing between NSWE and the remaining symbols
  end
  local w = 18
  local t = c
  if i == 8 then
    t = " "
  end
  row1:addButton(advance(w), 0, w, 25, c, function(text)
    text:insertAtCursor(t)
  end)
end

x = 0
local row2 = addRow()
for i = 0, 4 do
  local w = 30
  row2:addButton(advance(w), 0, w, 30, tostring(i), function(text)
    text:insertAtCursor(tostring(i))
  end)
end

x = 0
local row3 = addRow()
for i = 5, 9 do
  local w = 30
  row3:addButton(advance(w), 0, w, 30, tostring(i), function(text)
    text:insertAtCursor(tostring(i))
  end)
end