--[[ working functions: presetwp, presetfix

    ## presetfix - This function will set the correct altitude for the
       waypoints of the currently loaded theater. It will only change
       altitudes set at 2000m as that is the DCS default. This will
       prevent the function from changing any altitudes the user has
       changed manually using the altitude edit box. This is not
       needed for routes created with presetwp

    ## presetwp - used on Grayflag servers given an objective name
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
    button. Otherwise, on Grayflag servers, if you make an F10
    'update' label and click on the aeronautes-msg extension's trigger
    button you can highlight the objective names.

    ## globalfile - shows the contents of Globalcustom.lua.
--]]

local ft = {}
ft.order = {'presetwp', 'presetfix', 'globalfile'}
local presetfn = lfs.writedir()..[[Config\RouteToolPresets\]].._current_mission.mission.theatre..'.lua'

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

local function hypot(a, b)
    return math.sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end                     -- end hypot

local function umsg(str)
    loglocal('Globalcustom: '..str)
    net.recv_chat(str)
end

local function trim(s)                -- https://lua-users.org/wiki/StringTrim
   return s:match'^%s*(.*%S)' or ''
end

local pfile
function writepresets(presets)
    pfile, err = io.open(presetfn, 'w+')
    if err then
        umsg('Error opening file, err: '..err)
        return
    end

    function fout(str)
        --        loglocal(str)
        pfile:write(str)
    end

    -- order routes alphabetically in the theaters preset
    -- file. Currently DCS does not honor this ordering in the
    -- dropdown list
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
    pfile:flush()
    pfile:close()

    umsg('DCS only reads presets file on mission load. You must leave/rejoin server for new presets')
end                         -- writepresets

--#################################
-- presetwp v0.3
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

    local objs = {}
    local caps = {}
    local qrfsup = {}
    local forcewplimit = 9
    
    for _,i in pairs(_current_mission.mission.triggers.zones) do
        local zone = {}
        zone = {name = i.name, x = i.x, y = i.y, zoneid = i.zoneId}
        loglocal('Zone read: '..net.lua2json(zone), 7)
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
        loglocal('Obj.str #'..j.str..'# name: '..j.name, 7)
        if j.str == input then
            table.insert(objlist, j)
        end
    end
    loglocal('objlist: '..net.lua2json(objlist), 4)

    if #objlist == 0 then
        umsg('Objective not found: #'..input..'# '..#objlist)
        return
    end
    if #objlist > 1 then
        umsg('Multiple objectives found: '..input..' ('..#objlist..')')
    end
    
    for i,obtgt in pairs(objlist) do
        loglocal('OBJ: '..net.lua2json(obtgt), 4)
        local bb = boundingbox(obtgt.verticies)
        loglocal('BB: '..net.lua2json(bb), 4)

        -- DCS x axis is vertical, y horizontal
        local minx = bsearch(caps, #caps, bb.minx, function(a,b) return a.x < b end)
        local maxx = bsearch(caps, #caps, bb.maxx, function(a,b) return a.x < b end)
        loglocal('RESX: '..minx .. ' , '..maxx, 4)
        local xrng = {}

        for i=minx,maxx do
            table.insert(xrng, caps[i])
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
                if P1.x < math.min(P3.x, P4.x) or P1.x > math.max(P3.x, P4.x) then
                    loglocal('point BB P1.x:'..P1.x..' P3.x:'..P3.x..' P4.x:'..P4.x, 6)
                    return 0
                end
                t = ((P1.y-P3.y)*(P3.x-P4.x)-(P1.x-P3.x)*(P3.y-P4.y)) / ((P1.y-y2)*(P3.x-P4.x))
                loglocal(P1.name..' P1: '..net.lua2json(P1)..' my: '..y2..' v1: '..net.lua2json(P3)..' v2: '..net.lua2json(P4), 6)
                loglocal('poly test: t: '..t, 6)
                if 0 <= t and t <=1.0 then
                    return 1
                else
                    return 0
                end
            end

            for j=1,3 do
                intcount = intcount + intersect(xrng[i], bb.maxy, obtgt.verticies[j], obtgt.verticies[j+1])
                loglocal(j..' INTERSECT: '..intcount, 7)
            end
            intcount = intcount + intersect(xrng[i], bb.maxy, obtgt.verticies[4], obtgt.verticies[1])
            loglocal('4 INTERSECT: '..intcount, 7)

            if math.mod(intcount, 2) == 0 then
                loglocal(intcount..' OUTSIDE POLY, passing '..net.lua2json(xrng[i]), 4)
            else
                loglocal(intcount..' Inside poly inserting '..net.lua2json(xrng[i]), 4)
                table.insert(objwp, xrng[i])
            end
        end                         -- end i=miny, maxy

        if #objwp == 0 then
            umsg('Objective waypoints size zero, no presets designated, '..input..' ('..obtgt.name..')')
            return
        end

        local route = {}
        for i=1,#objwp do
            route[i] = i
        end
        local minrt = {r = {}, d = math.huge}

        local dtab = {}         -- distance b/w waypoints
        local dC = {}
        for i=1, #objwp do
            dtab[i] = {}
            dC[i] = {}
            for j=1, #objwp do
                dtab[i][j] = hypot(objwp[i], objwp[j])
--[[                if j ~= i then
                    table.insert(dC[i],{v = j, cost = dtab[i][j]})
                end
            end
            table.sort(dC[i], function(a,b) return a.cost < b.cost end)
    loglocal('BUB: '..net.lua2json(dC[i]))
--]]
            end
        end
        for i=1, #dtab do
            loglocal('dtab: '..i..': '..net.lua2json(dtab[i]), 4)
        end
        forcewplimit = 0--NC
        local selfdata = Export.LoGetSelfData()
        local selfpos = {x = selfdata.Position.x, y = selfdata.Position.z}
        loglocal('selfdata: '..net.lua2json(selfdata.Position), 4)
        local basedist = {}
        for i=1, #route do
            basedist[i] = hypot(selfpos, objwp[i])
        end

        function routedist(r)
            local dist = 0
            local tot = 1
            for i=1, #r-1 do
                dist = dist + dtab[r[i]][r[i+1]]
                loglocal('routedist: '..r[i]..'->'..r[i+1]..': '..dtab[r[i]][r[i+1]], 6)
            end
            loglocal(tot..' route: '..net.lua2json(r).. ' dist: '..dist, 6)
            tot = tot + 1
            return dist
        end

        if #objwp < forcewplimit then
            -- brute force search min route if less then 9 waypoints

            function permgen(a, n)  -- https://www.lua.org/pil/9.3.html
                if n == 0 then
                    coroutine.yield(a)
                else
                    for i=1, n do
                        a[n], a[i] = a[i], a[n]
                        permgen(a, n-1)
                        a[n], a[i] = a[i], a[n]
                    end
                end
            end                     -- permgen

            function perm(a)
                loglocal('perm: '..net.lua2json(a), 6)
                return coroutine.wrap(function() permgen(a, #a) end)
            end

            for p in perm(route) do
                local rtd
--                rtd = routedist(p) + basedist[p[1]] + basedist[p[#route]] -- for shortest roundtrip
                rtd = routedist(p) + basedist[p[1]] -- for closest first zone

                --enabling the following log for wp>7 or more may take a long time
                loglocal('presetwp check route: '..net.lua2json(p)..' dist: '..rtd, 8) 
                if rtd < minrt.d then
                    minrt.d = rtd
                    minrt.r = copytable(p)
                    loglocal('presetwp set min: '..net.lua2json(minrt), 6)
                end
            end
        else                    -- #wp > 8 do nearest neighbor
--            table.sort(objwp, function(a,b) return a.x < b.x end) -- sort wp from south increasing to north
--            minrt.r = route
--            umsg('presetwp: #wp >= '..forcewplimit..', route order South to North')

            function NN(route)  -- nearest neighbor
                local Q = {}
                for i=1, #route do
                    Q[i] = {}
                    for j=1, #route do
                        if j ~= i then
                            table.insert(Q[i],{v = j, cost = dtab[i][j]})
                        end
                    end
                    table.sort(Q[i], function(a,b) return a.cost < b.cost end)
                    loglocal('Q['..i..']: '..net.lua2json(Q[i]), 4)
                end

                local closestcap = 0
                local dist = math.huge
                for i=1, #basedist do
                    if basedist[i] < dist then
                        closestcap = i
                        dist = basedist[i]
--                        loglocal('closest: '..closestcap..' basedist: '..net.lua2json(basedist))
                    end
                end
                loglocal('FIN closest: '..closestcap..' basedist: '..net.lua2json(basedist), 4)

                local rt = {closestcap}
                local tour = {d = math.huge, rt = {}}
                for h=1, #route do
                    rt = {h}
                    dist = 0
                    local Qn = copytable(Q)
                    for i=1, #route-1 do
                        for j=1, #Qn[rt[i]] do
                            local shortest = Qn[rt[i]][j]
  --                          loglocal('shortest: '..net.lua2json(shortest))
                            if Qn[shortest.v] then
                                rt[i+1] = shortest.v
                                dist = dist + shortest.cost
                                Qn[rt[i]] = nil
                                break
                            end
                        end
                    end
                    loglocal(h..' Tour: '..dist..' rt: '..net.lua2json(rt),4)
                    --dist = dist + dtab[rt[1]][rt[#rt]]
                    --dist = dist + basedist[h]
                    loglocal('Complete route: '..dist,4)
                    if dist < tour.d then
                        tour = {d = dist, rt = rt}
                        loglocal('Found smaller: '..h..' + '..basedist[h]..' = '..dist+basedist[h], 4)
                    end
                end
                return tour.d, tour.rt
            end
            minrt.d, minrt.r = NN(route)
            loglocal('NN: '..net.lua2json(minrt),4)

            function mst(route)      -- Prim's
                local C = {}
                local E = {}
                local F = {}
                local Q = {}
                for i=1,#route do
                    C[i] = math.huge
                    E[i] = 0
                    Q[i] = {}
                    for j=1, #route do
                        if j ~= i then
                            table.insert(Q[i],{v = j, cost = dtab[i][j]})
                        end
                    end
                    table.sort(Q[i], function(a,b) return a.cost < b.cost end)
                    loglocal('Q['..i..']: '..net.lua2json(Q[i]))
                end

                local v = 1
                local Fidx = 1
--                while #Q > 0 do
                    F[Fidx] = v
                    local tmp = Q[v]
                    table.remove(Q[v])
                    for w=1, #tmp do
                        if tmp[w].cost < C[v] then
                            C[w] = tmp[w].cost
                            E[w] = {v, w}
                        end
                    end
  --              end
                loglocal(net.lua2json({C, E, F, Q}))
            end
--            mst(route)
        end                     -- #objwp < 9
        loglocal('presetfix minrt: '..net.lua2json(minrt), 6)

        -- create and merge new presets with current presets file
        local atr = lfs.attributes(presetfn)
        if atr and atr.mode == 'file' then
            dofile(presetfn)
        end
        if not presets then
            presets = {}
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
            alt = 0,
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

        for idx=1, #minrt.r do
            local wp = minrt.r[idx]
            loglocal('route wp: '..wp..' ; '..net.lua2json(objwp[wp]), 6)
            presets[rt][idx] = copytable(pretmp)
            presets[rt][idx].name = objwp[wp].str
            presets[rt][idx].x = objwp[wp].x
            presets[rt][idx].y = objwp[wp].y
            presets[rt][idx].alt = Export.LoGetAltitude(objwp[wp].x, objwp[wp].y)
            if idx > 1 then        -- formula from Scripts\UI\RouteTool.lua
                local prevwp = minrt.r[idx-1]
                presets[rt][idx].ETA = etatot + math.sqrt((objwp[prevwp].x - objwp[wp].x)^2 + (objwp[prevwp].y - objwp[wp].y)^2) / 70 --250km/h
                etatot = presets[rt][idx].ETA
                loglocal('ETA: '..presets[rt][idx].ETA, 6)
            end
        end                         -- end pairs(objwp)
        umsg(#objwp..' wps created for '..rt)
        loglocal('presetwp: preset created '..net.lua2json(presets[rt]), 6)
    end -- obtgt in pairs(objlist)
    
    -- write new presets
    writepresets(presets)
end                             -- end presetwp

--#################################
-- presetfix v0.1
-- Currently routes created using DCS RouteTool will set all altitudes
-- to 2000m. This script will update the preset file for the current
-- theater to the actual ground height for any altitudes set at
-- 2000. This means if you set your own value in the altitude edit
-- box, presetfix will not alter it.
ft['presetfix'] = function(input)
    loglocal('presetfix call', 2)

    local atr = lfs.attributes(presetfn)
    if atr and atr.mode == 'file' then
        dofile(presetfn)
    end
    if not presets then
        loglocal('presetfix file not found '..presetfn)
        return 0
    end

    for rtname,rtnode in pairs(presets) do
        loglocal('presetfix rt: '..rtname, 6)
        for wpnum, wp in pairs(rtnode) do
            loglocal('presetfix current wp: '..wp.name..' alt: '..wp.alt, 6)
            if wp.alt == 2000 then
                wp.alt = Export.LoGetAltitude(wp.x, wp.y)
                loglocal('presetfix New alt: '..wp.alt, 6)
            end
        end
    end
    writepresets(presets)
end                         -- presetfix

--#################################
-- globalfile v0.1
-- show this file in scratchpad
ft['globalfile'] = function(input)
    loglocal('globalfile call', 2)
    if switchPage(Scratchdir..Scratchpadfn) then
        local txt = ''
        local readtxt = ''
        if not TA then
            TA = getTextarea()
        end

        local infn = Apitlibdir..'Globalcustom.lua'
        local infile, res
        infile, res = io.open(infn,'r')
        if not infile then
            txt = txt .. '\nGlobalcustom.lua file not found in '..Apitlibsubdir
            loglocal('aeronautespit Globalcustom.lua open file fail; non critical' .. res)
            return
        else
            readtxt = infile:read('*all')
            infile:close()
            if not readtxt then
                loglocal('aeronautespit Globalcustom.lua read error; ' .. infn)
            else
                txt = txt .. '-- COPY of '..Apitlibsubdir..'Globalcustom.lua\n'..readtxt
            end
        end

        TA:setText('')
        -- hardcoded 1MB file limit from scratchpad
        local buflen = string.len(txt)
        if buflen > (1024 * 1024) then
            txt = string.sub(txt, 0, (1024*1024)-80) --limit 1 MB worth
            txt = txt ..'<<< File too big for scratchpad. Displaying truncated to 1MB >>>'
            loglocal('apit mod buflen > 1MB: '..buflen)
        end

        TA:setText(txt)
    end
end                             -- globalfile


return ft
