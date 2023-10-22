-- A minimal keypad meant for coordinate input

local keypadMatrix = {
  { "7", "8", "9", "N", "S"},
  { "4", "5", "6", "W", "E"},
  { "1", "2", "3", "'", "\""},
  { "⌫", "0", {["↩"] = "\n"}, ".", {["␣"] = " "}},
}

local keyBMatrix = {
  {"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"},
  {"A", "S", "D", "F", "G", "H", "J", "K" ,"L", "⌫"},
  {"Z", "X", "C", "V", "B", "N", "M", {["␣"] = " "}, ".", ","},
} 


--local width = 30
--local height = 30

local function create_pad(padType, matrix, y, width, height)

	--local y = 0
	for _, r in pairs(matrix) do
	
	--local x = 0
	
	if padType == 1 then --keypad
	  x = 525 
	elseif padType == 2 then --keyboard
	  x = 0
	end
	
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
	  y = y + height
	end
end

create_pad(1, keypadMatrix, 0, 30, 30)
create_pad(2, keyBMatrix, 0, 50, 40)