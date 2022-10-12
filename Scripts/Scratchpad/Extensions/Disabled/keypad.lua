-- A minimal keypad meant for coordinate input

local keyMatrix = {
  { "7", "8", "9", "N", "S" },
  { "4", "5", "6", "W", "O" },
  { "1", "2", "3", "'", "\"" },
  { "⌫", "0", {["↩"] = "\n"}, ".", {["␣"] = " "} },
}
local width = 30
local height = 30

local y = 0
for _, r in pairs(keyMatrix) do
  local x = 0
  for k, v in pairs(r) do
    local title = v
    local char = v
    if type(v) == "table" then
      title, char = pairs(v)(v)
    end

    local onClick = function(text)
      text:insert(char)
    end
    if v == "⌫" then
      onClick = function(text)
        text:deleteBackward()
      end
    end

    addButton(x, y, width, height, title, onClick)
    x = x + width
  end
  y = y + width
end