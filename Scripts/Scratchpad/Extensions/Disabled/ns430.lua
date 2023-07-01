-- Degree Decimal formatted to be used in NS430 navaid.dat file for flight planning purposes. Just edit the %PlaceHolderName
addCoordinateListener(function(text, lat, lon, alt)
  text:insertBelow(
    "FIX;" .. formatCoord("DD", true, lon) .. ";" .. formatCoord("DD", false, lat)  .. ";%PlaceHolderName\n"
  )
end)