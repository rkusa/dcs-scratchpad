addCoordinateListener(
  function (text, lat, lon, alt, mgrs, types)
    
    --==================================================================================    
    function formatCoord2(isLat, value)
      local DDM = {precision = 3, lonDegreesWidth = 3}
      local DMS = {precision = 0}

      local ret = ''
      local dm = ''
      local get = false
      local ac = DCS.getPlayerUnitType()
      if ac == "FA-18C_hornet" then   
        DDM.precision = 4
        DMS = {precision = 2}
      end  

      local ddm = formatCoord("DDM", isLat, value, DDM)
      local dms = formatCoord("DMS", isLat, value, DMS)    
      for i = 1,string.len(ddm) do
        if string.sub(ddm,i,i) == '.' then
          get = true
        end
        if string.sub(ddm,i,i) == "'" then
          get = false
        end     
        if get then
          dm = dm .. string.sub(ddm,i,i) 
        end
      end
      
      for i = 1,string.len(dms) do 
        if string.sub(dms,i,i) == "'" then
          ret = ret..'('..dm..')'
        end    
        ret = ret..string.sub(dms,i,i) 
      end
      return ret
    end    
--==================================================================================   
     local result = "\n"

      result = result .. formatCoord2(true, lat) .. ", " .. formatCoord2(false, lon) .. "\n"  .. mgrs .. " / " 
      result = result .. string.format("%.0f", alt) .. "m, ".. string.format("%.0f", alt*3.28084) .. "ft"
      text:insertBelow(result)

  end -- function
) --addCoordinateListener
