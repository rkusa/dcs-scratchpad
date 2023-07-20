-- Degree Decimal formatted to be used in NS430 navaid.dat file for flight planning purposes. Just
-- edit the %PlaceHolderName.
-- With this extension active, hitting the `+L/L` button inserts a line that looks like:
-- `FIX;-88.245167;36.117167;%PlaceholderName`.
-- The `%PlaceholderName` must be changed to a 1-5 character long alpha-numeric string (e.g. `1A`,
-- `1B`, `2`, `3`, `WILLO`). This can then be added into the `navaids.dat` in the main DCS folder
-- (`DCS World OpenBeta\Mods\aircraft\NS430\Cockpit\Scripts\avionics\terrain\navaids.dat`). You need
-- to respawn for the `navaids.dat` changes to take effect. The waypoint can then be loaded into the
-- NS430 via the Flight Plan Page or Direct-To page.

addCoordinateListener(function(text, lat, lon, alt)
  text:insertBelow(
    "FIX;" .. formatCoord("DD", true, lon) .. ";" .. formatCoord("DD", false, lat)  .. ";%PlaceHolderName\n"
  )
end)
