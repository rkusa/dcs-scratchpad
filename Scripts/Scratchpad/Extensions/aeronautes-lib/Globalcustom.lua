--[[
    presetwp - used on Grayflag servers given an objective name,
    produces additions to route tool preset file. DCS only reads
    'Saved Game\DCS\Config\RouteToolPresets' after the mission loads
    when joining server. This means any update wont show up in game
    until the next server join. The script will merge it's additions
    but you may choose to backup your presets if you value any of the
    previous settings. Alternatively you can delete the file in the
    RouteToolPresets directory to quickly initialize settings or use
    the RouteTools F10 menu to delete individual routes. No gaurantees
    are made with the use of this software.
    
    To use, highlight the name of the objective in scratchpad then
    click the presetwp button. Information messages will be posted in
    game chat window. Do as many objectives as you want then leave and
    rejoin server and you should see the new presets in the drop down
    list. This extension has the capability to pass the entire line as
    input objective name if you dont highlight anything. For presetwp
    that means you need a line with only the name of the objective,
    place the cursor anywhere on that line and click the
    button. Otherwise, on Grayflag servers, if you make an F10 'update'
    label and click on the aeronautes-msg extension's trigger button
    you can highlight the objective names.
--]]


local ft = {}
ft.order = {'presetwp'}

local function copytable(src)
    dst = {}
    for i, j in pairs(src) do
        dst[i] = j
    end
    return dst
end

local function bsearch(tbl, len, value, cmpf)
    local left = 1
    local right = len+1
    local mid

    while(left < right) do
        mid = left + math.floor((right - left)/2)
--                loglocal('BSEARCH: '..value..' left: '..left..', '..mid..', '..right..net.lua2json(tbl[mid]))
        if (cmpf(tbl[mid], value)) then
            left = mid + 1
        else
            right = mid
        end
    end
    return mid
end                         -- end bsearch

local function boundingbox(verts)
    local bbox = {}
    bbox = {minx = math.huge, miny = math.huge, maxx = -math.huge, maxy = -math.huge}

    for i,v in pairs(verts) do
        bbox.minx = math.min(bbox.minx, v.x)
        bbox.maxx = math.max(bbox.maxx, v.x)

        bbox.miny = math.min(bbox.miny, v.y)
        bbox.maxy = math.max(bbox.maxy, v.y)
    end
    return bbox
end

local function umsg(str)
    loglocal('Globalcustom: '..str)
    net.recv_chat(str)
end

function trim(s)                -- https://lua-users.org/wiki/StringTrim
   return s:match'^%s*(.*%S)' or ''
end

--#################################
-- presetwp v0.1
-- creates presets for route tool using objectives and cap zones as
-- implmented on Grayflag server missions. This means missions using
-- zones with 'property' 'type' 'obj' or 'qrf' and zones with
-- 'property' 'str' 'CAP...'. This may work on other missions that
-- follow this convention.

ft['presetwp'] = function(input)
    input = trim(input)
    if not input then
        umsg('No objective name supplied. You must highlight the objective name in scratchpad. "'..input..'"')
        return
    end

    local presetfn = lfs.writedir()..[[Config\RouteToolPresets\]].._current_mission.mission.theatre..'.lua'
    local objs = {}
    local caps = {}
    local qrfsup = {}
    
    for _,i in pairs(_current_mission.mission.triggers.zones) do
        local zone = {}
        zone = {name = i.name, x = i.x, y = i.y, zoneid = i.zoneId}
        if i.properties and i.properties[1] and i.properties[1]['key'] then
            for _,j in pairs(i.properties) do
                zone[j.key] = j.value
            end
        end
        if i.verticies then
            zone['verticies'] = copytable(i.verticies)
        end

        if zone.type == 'obj' then
            table.insert(objs, zone)
        elseif zone.type == 'qrf' or zone.type == 'supply' then
            table.insert(qrfsup, zone)
        elseif string.sub(zone.name, 1, 3) == 'CAP' then
            table.insert(caps, zone)
        end
    end
    table.sort(caps, function(a,b) return a.x < b.x end)
    loglocal('caps:'..#caps.. ' objs: '..#objs.. ' qrfsup: '..#qrfsup, 4)

    local objlist = {}
    loglocal('input: #'..input..'#', 4)
    for i,j in pairs(objs) do
        if j.str == input then
            table.insert(objlist, j)
        end
    end

    if #objlist == 0 then
        umsg('Objective not found: #'..input..'# '..#objlist)
        return
    end
    if #objlist > 1 then
        umsg('Multiple objectives found: '..input..' ('..#objlist..')')
    end
    
    for i,obtgt in pairs(objlist) do
--        loglocal('OBJ: '..net.lua2json(obtgt))
        local bb = boundingbox(obtgt.verticies)
--        loglocal('BB: '..net.lua2json(bb))

        -- DCS x axis is vertical, y horizontal
        local minx = bsearch(caps, #caps, bb.minx, function(a,b) return a.x < b end)
        local maxx = bsearch(caps, #caps, bb.maxx, function(a,b) return a.x < b end)
        loglocal('RESX: '..minx .. ' , '..maxx, 4)
        local xrng = {}

        for i=minx,maxx do
            table.insert(xrng, caps[i])
--            loglocal('Xrng(x): '..i..' ; '..net.lua2json(caps[i]))
        end
        table.sort(xrng, function(a,b) return a.y < b.y end)
        
        local miny = bsearch(xrng, #xrng, bb.miny, function(a,b) return a.y < b end)
        local maxy = bsearch(xrng, #xrng, bb.maxy, function(a,b) return a.y < b end)
        loglocal('RESY: '..miny .. ' , '..maxy, 4)
        for i=miny, maxy do
            loglocal(i..' BBOXED result: '..net.lua2json(xrng[i]), 4)
        end

        -- caps in obj test
        local objwp = {}
        for i=miny, maxy do
            local intcount = 0

            function intersect(P1, y2, P3, P4)
                -- Line1
                local x1 = P1.y; local y1 = P1.x
                --local y2 = y2

                -- Line2
                local x3 = P3.y; local y3 = P3.x
                local x4 = P4.y; local y4 = P4.x

                denom = ((y1 - y2)*(x3 - x4))
                t = ((x1 - x3)*(y3 - y4)-(y1 - y3)*(x3 - x4)) / denom
                u =                       -((y1-y2)*(x1 - x3)) / denom

                --            loglocal(P1.name..' P1: '..P1.x..','..P1.y..' my: '..y2..' v1: '..net.lua2json(P3)..' v2: '..net.lua2json(P4))
                --            loglocal('poly: denom: '..denom..' t: '..t..' u: '..u)
                if 0 <= t and t <= 1.0 and 0 <= u and u <= 1.0 then
                    return 1
                else
                    return 0
                end
            end

            for j=1,3 do
                intcount = intcount + intersect(xrng[i], bb.maxy, obtgt.verticies[j], obtgt.verticies[j+1])
--                loglocal(j..' INTERSECT: '..intcount)
            end
            intcount = intcount + intersect(xrng[i], bb.maxy, obtgt.verticies[4], obtgt.verticies[1])
--            loglocal('4 INTERSECT: '..intcount)

            if math.mod(intcount, 2) == 0 then
                loglocal('OUTSIDE POLY, passing '..net.lua2json(xrng[i]), 4)
            else
                loglocal('Inside poly inserting '..net.lua2json(xrng[i]), 4)
                table.insert(objwp, xrng[i])
            end
        end                         -- end i=miny, maxy

        if #objwp == 0 then
            umsg('Objective waypoints size zero, no presets designated, '..input..' ('..obtgt.name..')')
            return
        end
        table.sort(objwp, function(a,b) return a.x < b.x end) -- sort wp from south increasing to north

        -- create and merge new presets with current presets file
        if not presets then
            local atr = lfs.attributes(presetfn)
            if atr and atr.mode == 'file' then
                dofile(presetfn)
            end
            if not presets then
                presets = {}
            end
        end
        local rt = DCS.getMissionName()..'-v'.._current_mission.mission.version..'-'
        if obtgt.lat then
            rt = rt..'Lat'..obtgt.lat..'-'
        end
        rt = rt .. obtgt.str
        if #objlist > 1 then    -- add objective name if there are multiple obj with same str
            rt = rt .. '-'..obtgt.name
        end
        
        local etatot = 900
        presets[rt] = {}
        local pretmp = {
            alt = 2000,
            type =  "Turning Point",
            ETA = etatot,
            ETA_locked = true,
            y = 0,
            x = 0,
            name = "",
            speed_locked = false,
            alt_type = "BARO",
            action = "Turning Point",
        }

        for wp=1,#objwp do
--            loglocal('OH: '..wp..' ; '..net.lua2json(objwp[wp]))
            presets[rt][wp] = copytable(pretmp)
            presets[rt][wp].name = objwp[wp].str
            presets[rt][wp].x = objwp[wp].x
            presets[rt][wp].y = objwp[wp].y
            if wp > 1 then        -- formula from Scripts\UI\RouteTool.lua
                presets[rt][wp].ETA = etatot + math.sqrt((objwp[wp-1].x - objwp[wp].x)^2 + (objwp[wp-1].y - objwp[wp].y)^2) / 70 --250km/h
                etatot = presets[rt][wp].ETA
--                loglocal('ETA: '..presets[rt][wp].ETA)
            end
        end                         -- end pairs(objwp)
        umsg(#objwp..' wps created for '..rt)
    end -- obtgt in pairs(objlist)
    
    -- write new presets
    local file, err = io.open(presetfn, 'w+')
    if err then
        umsg("Error writing file: " .. presetfn)
        return
    end
    function fout(str)
        --        loglocal(str)
        file:write(str)
    end

    local presort = {}
    for i,j in pairs(presets) do
        table.insert(presort, i)
    end
    table.sort(presort)
    
    fout('presets =\n{\n')
    for i=1, #presort do
        loglocal(i..' SORT: '..presort[i], 4)
        local rtname = presort[i]
        local rtnode = presets[rtname]
        fout('    ["'..rtname..'"] =\n    {\n') -- route
        for wpnum=1,#rtnode do
            fout('        ['..wpnum..'] =\n        {\n') --wp
            for key,value in pairs(rtnode[wpnum]) do
                if type(value) == 'string' then
                    fout('            ["'..key..'"] = "'..value..'",\n')
                else
                    fout('            ["'..key..'"] = '..tostring(value)..',\n')
                end
            end
            fout('        }, -- end of ['..wpnum..']\n')
        end
        fout('    }, -- end of ["'..rtname..'"]\n')
    end
    fout('} -- end of presets')
    file:flush()
    file:close()

    umsg('DCS only reads presets file on mission load. You must leave/rejoin server for new presets')
end                             -- end ft[a]

return ft
