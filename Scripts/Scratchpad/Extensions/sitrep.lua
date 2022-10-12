-- A button to copy the current mission's situation to the top of the current page

addButton(0, 0, 80, 30, "+ SITREP", function(text)
  text:insertTop(DCS.getMissionDescription())
end)