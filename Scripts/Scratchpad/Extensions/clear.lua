-- A single button to clear the current page

addRow():addButton(0, 0, 50, 30, "CLR", function(text)
  text:setText("")
end)
