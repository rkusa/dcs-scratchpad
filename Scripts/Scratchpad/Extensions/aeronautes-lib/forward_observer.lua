--[[ working functions: all of these are in development
    HH - heading hold mode

    NAV - drive to coord
--]]

local ft = {}

--#################################
-- NAV v0.0
-- 
local fn='NAV'
ft[fn] = function()
    
    function bearing(here, there)
        deltaL = math.abs(there.Long - here.Long)
        x = math.cos(there.Lat) * math.sin(deltaL)
        y = math.cos(here.Lat) * math.sin(there.Lat) - math.sin(here.Lat) * math.cos(there.Lat) * math.cos(deltaL)
        --loglocal('bearing() x: '..x..' y: '..y..' deltaL: '..deltaL)
        B = math.atan2(x,y)
        --loglocal('bearing(): B '..B)
        return B
    end
    local sd = Export.LoGetSelfData()
    --loglocal(net.lua2json(Export.LoGetSelfData()))

    --loglocal(fn..' Lat: '..a.LatLongAlt.Lat..' Long: '..a.LatLongAlt.Long)
    goal={}
    goal.Lat = 42.873935576143
    goal.Long = 41.333509159828
    goal.Alt = 144.11176018344

    local ber = math.deg(bearing(sd.LatLongAlt, goal))
    local berd = 0
    if ber < 0 then
        berd = 360 + ber
    else
        berd = ber
    end
    loglocal(fn..' ber: '..berd.. ' hdg: '..math.deg(sd.Heading))

    --[[
    loglocal(type(a))
    for i,j in pairs(a.Heading) do
        loglocal(i)
        if type(j) == 'number' or type(j) == 'string' then
            loglocal('   '..j)
        else
            loglocal('    '..type(j))
        end
    end
    --]]

    --197 steer left, 193 accel
    --Export.LoSetCommand(195)
end                             -- end of HH

--#################################
-- HH v0.0
-- heading hold
fn='HH'
ft[fn] = function()
    local sd = Export.LoGetSelfData()
    local hdg = 90

    net.recv_chat('Hdg: '..math.deg(sd.Heading), 0)
    loglocal(fn..' Hdg: '..math.deg(sd.Heading) ..' Lat: '..sd.LatLongAlt.Lat..' Long: '..sd.LatLongAlt.Long)
end

return ft
