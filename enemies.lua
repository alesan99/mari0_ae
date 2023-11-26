local getname
local loadfile
local rebase
local loadenemy
local usebase
local loadenemyimage
local loadenemysound

function enemies_load()
	local ltime = love.timer.getTime()
	defaultvalues = {quadcount=1, quadno=1}

	enemiesdata = {}
	customenemies = {}

	--HATS (for custom powerups)
	if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/hats/") then
		local files = love.filesystem.getDirectoryItems(mappackfolder .. "/" .. mappack .. "/hats/")
		for i, v in pairs(files) do
			if string.sub(v, -5, -1) == ".json" then
				loadhat(mappackfolder .. "/" .. mappack .. "/hats/" .. v, mappackfolder .. "/" .. mappack)
			end
		end
	end
	
	--ENEMIIIIEEES
	loaddelayed = {}
	loaddelayedbases = {}
	
	local enemiesexist = love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/enemies/")
	if (not enemiesexist) and (not editormode) then
		for i = 1, #mariocharacter do
			if mariocharacter[i] and love.filesystem.getInfo("alesans_entities/characters/" .. mariocharacter[i] .. "/enemies/") then
				enemiesexist = true
				break
			end
		end
	end
	local fl = {}
	if enemiesexist then --only load defaults if custom enemies are used
		fl = love.filesystem.getDirectoryItems("customenemies/")
	end
	
	local realfl = {}
	
	for i = 1, #fl do
		table.insert(realfl, "customenemies/" .. fl[i]) --STANDARD ENEMIES
	end
	
	local mpenemiespath = mappackfolder .. "/" .. mappack .. "/enemies/"
	local fl2 = love.filesystem.getDirectoryItems(mpenemiespath)
	for i = 1, #fl2 do
		if love.filesystem.getInfo(mpenemiespath .. fl2[i],"directory") then
			--load enemies from folder
			local fl3 = love.filesystem.getDirectoryItems(mpenemiespath .. fl2[i])
			for i2 = 1, #fl3 do
				table.insert(realfl, mpenemiespath .. fl2[i] .. "/" .. fl3[i2])
			end
		else
			table.insert(realfl, mpenemiespath .. fl2[i]) --MAPPACK ENEMIES
		end
	end

	--load enemies for custom characters
	local characterenemiesloaded = {} --don't load the same enemy multiple times
	for i = 1, #mariocharacter do
		local charenemiespath = "alesans_entities/characters/" .. mariocharacter[i] .. "/enemies/"
		if mariocharacter[i] and (not characterenemiesloaded[mariocharacter[i]]) and love.filesystem.getInfo(charenemiespath) then
			local fl3 = love.filesystem.getDirectoryItems(charenemiespath)
			for i2 = 1, #fl3 do
				if love.filesystem.getInfo(charenemiespath .. fl3[i2],"directory") then
					--load enemies from folder
					local fl4 = love.filesystem.getDirectoryItems(charenemiespath .. fl3[i2])
					for i3 = 1, #fl4 do
						table.insert(realfl, charenemiespath .. fl3[i2] .. "/" .. fl4[i3])
					end
				else
					table.insert(realfl, charenemiespath .. fl3[i2]) --CHARACTER ENEMIES
				end
			end
			characterenemiesloaded[mariocharacter[i]] = true
		end
	end
	
	JSONcrashgame = false
	olds = nil
	for i = 1, #realfl do
		local newname = getname(realfl[i])
		if newname then
			if olds and newname ~= olds then
				rebase(olds)
				olds = nil
			end
			local succ = loadfile(realfl[i], newname)
			if succ then
				olds = newname
			end
		end
	end
	--print("loop done")
	rebase(olds)
	loaddelayed = nil
	loaddelayedbases = nil
	olds = nil
	JSONcrashgame = true

	--ADD CUSTOM ENEMIES TO ENTITY LIST
	for i = #entitiesform[#entitiesform], 1, -1 do
		entitiesform[#entitiesform][i] = nil
	end
	local defaultenemies = {} --check for replaced default enemies
	for _, filename in pairs(fl) do
		if string.sub(filename, -4) == "json" then
			defaultenemies[string.sub(filename, 1, -6)] = 0
		end
	end
	for j, w in pairs(customenemies) do
		if (not enemiesdata[w].hidden) and ((not defaultenemies[w]) or defaultenemies[w] == 0) then
			table.insert(entitiesform[#entitiesform], w)
			if defaultenemies[w] then
				defaultenemies[w] = defaultenemies[w] + 1
			end
		end
	end
	if not entitiesform[#entitiesform].hidden then
		entitiesform[#entitiesform].h = 17*(math.ceil(#entitiesform[#entitiesform]/22))
	end
	for i = 1, #customenemies do
		entityquads[customenemies[i]] = entityquads[2]
	end

	print("Custom enemies loaded in: " .. love.timer.getTime()-ltime)
	--print("Total of " .. #customenemies .. " enemies")
	--print(basedelays .. " based delayed")
end

function getname(filename)
	if string.sub(filename, -4) == "json" then
		return filename:match("^.+/(.*)%.json$"):lower()
	elseif string.sub(filename, -3):lower() == "png" then
		return filename:match("^.+/([^%-%.]*)"):lower()
	elseif string.sub(filename, -3) == "ogg" then
		return filename:match("^.+/(.*)%.ogg$"):lower()
	end
end

function loadfile(filename, s)
	if string.sub(filename, -4) == "json" then
		--print(filename)
			--print(s)
		local succ = loadenemy(filename, s)
		if not succ then return false end
	elseif string.sub(filename, -3):lower() == "png" then
		--print(filename)
			--print(s)
		if enemiesdata[s] then
			loadenemyimage(filename, s)
		else
			--print("delayedimg")
			if loaddelayedbases[s] then
				table.insert(loaddelayed[loaddelayedbases[s]], filename)
			else
				if not loaddelayed[s] then
					loaddelayed[s] = {}
				end
				table.insert(loaddelayed[s], filename)
				--print("iconned at", s)
			end
			return false
		end
	elseif string.sub(filename, -3) == "ogg" then
		--print(filename)
		if enemiesdata[s] then
			loadenemysound(filename, s)
		else
			--print("delayedsound")
			if loaddelayedbases[s] then
				table.insert(loaddelayed[loaddelayedbases[s]], filename)
			else
				if not loaddelayed[s] then
					loaddelayed[s] = {}
				end
				table.insert(loaddelayed[s], filename)
				--print("iconned at", s)
			end
			return false
		end
	else
		return false
	end
	return true
end

function rebase(base)
	if not base then return end
	local lolds
	local ldb = loaddelayed[base]
	loaddelayed[base] = nil
	if ldb and #ldb > 0 then
		--print("rebasing", base)
		for j = 1, #ldb do
			local newname = getname(ldb[j])
			if newname then
				if lolds and newname ~= lolds then
					rebase(lolds)
				end
				local succ = loadfile(ldb[j], newname)
				if succ then
					lolds = newname
				end
			end
		end
		rebase(lolds)
	else
		--print("notpending", base)
		return
	end
end

function loadenemy(filename, s)
	local s = s or filename:match("^.+/(.*)%.json$"):lower()

	
	--CHECK FOR - , ; * AND WHATEVER ELSE WOULD BREAK MAPS
	local skip = false
	local badlist = {",", ";", "-", "*", "~"} --badlist sounds like a movie
	for i = 1, #badlist do
		if s:find(badlist[i]) then
			return
		end
	end
	
	local data = love.filesystem.read(filename)
	if not data then
		print("COULD NOT READ FILE " .. filename)
		return
	end
	--local datalen = #data
	data = data:gsub("\r", "")

	if string.sub(data, 1, 4) == "base" then
		local base = string.match(data, '^[^\n]*', 6)
		if enemiesdata[base] then
			local newdata = string.sub(data, #base+6, #data)
				
			enemiesdata[s] = usebase(enemiesdata[base])
				
			local temp
			local suc, err = pcall(function() return JSON:decode(newdata) end)
			if suc then
				temp = err
			else
				jsonerrorwindow:open("JSON ERROR! (" .. s .. ".json)", JSONerror[2], function() enemies_load() end)
				return false
			end
				
			if temp then
				for i, v in pairs(temp) do
					enemiesdata[s][i] = v
				end
				if (temp.animationstart or temp.quadno) then --fix dc bugs
					loadenemyquad(s)
				end
			end
		else
			--Put enemy for later loading because base hasn't been loaded yet
			if not loaddelayed[base] then
				loaddelayed[base] = {}
			end
			table.insert(loaddelayed[base], filename)
			loaddelayedbases[s] = base
			--print("delayedjson", base)

			--print("DON'T HAVE BASE ", base, s, datalen)
			--basedelays = basedelays + 1
			--basestable[base] = (basestable[base] or 0) + 1
			--if editormode then
				--notice.new("don't have base " .. base .. " for " .. s)
			--end
			return false
		end
	else
		local suc, err = pcall(function() return JSON:decode(data) end)
		if suc then
			enemiesdata[s] = err
		else
			jsonerrorwindow:open("JSON ERROR! (" .. s .. ".json)", JSONerror[2], function() enemies_load() end)
			return false
		end
	end

	if type(enemiesdata[s]) == "string" then
		--I have no idea why this happens
		print("ENEMY DATA FOR " .. s .. " IS CORRUPT:", enemiesdata[s])
		notice.new("enemy data for " .. s .. "\nis corrupted\n" .. enemiesdata[s], notice.red, 5)
		return false
	end
		
	--CASE INSENSITVE THING
	local offsetchangetable = {}
	for i, v in pairs(enemiesdata[s]) do
		local a = i:lower()
		if a == "offsetx" then
			offsetchangetable["offsetX"] = v
		elseif a == "offsety" then
			offsetchangetable["offsetY"] = v
		elseif a == "quadcenterx" then
			offsetchangetable["quadcenterX"] = v
		elseif a == "quadcentery" then
			offsetchangetable["quadcenterY"] = v
		else
			if type(v) == "string" then
				enemiesdata[s][a] = v:lower()
			else
				enemiesdata[s][a] = v
			end
		end
	end
		
	for i, v in pairs(offsetchangetable) do
		--doing it up there messed up the order or something
		enemiesdata[s][i] = v
	end
		
	for i, v in pairs(defaultvalues) do
		if enemiesdata[s][i] == nil then
			enemiesdata[s][i] = v
		end
	end


	--fix offsetY
	if enemiesdata[s].offsetyadjust then
		--automatically shifts sprite up 8 pixels and un-reverses offset number
		local fixtable = {"offsetY", "upsidedownoffsety", "upsidedownwiggleoffsety", "smalloffsety"}
		for i, v in pairs(fixtable) do
			if enemiesdata[s][v] then
				enemiesdata[s][v] = (-enemiesdata[s][v])+8
			end
		end
	end

	table.insert(customenemies, s)

	return true
end

function usebase(t)
	local r = {}
	
	for i, v in pairs(t) do
		r[i] = v
	end
	
	return r
end

function loadenemyimage(filename, s)
	--Load graphics
	local img = love.graphics.newImage(filename)
	if string.sub(filename, -9):lower() == "-icon.png" then
		enemiesdata[s].icongraphic = img
	elseif string.sub(filename, -12):lower() == "-tooltip.png" then
		enemiesdata[s].tooltipgraphic = img
	else
		enemiesdata[s].graphic = img

		if enemiesdata[s].quadcount then
			local imgwidth, imgheight = img:getWidth(), img:getHeight()
			local quadwidth = imgwidth/enemiesdata[s].quadcount
			local quadheight = imgheight/4
			
			if math.floor(quadwidth) == quadwidth and (math.floor(quadheight) == quadheight or enemiesdata[s].nospritesets) then
				enemiesdata[s].drawable = true
				enemiesdata[s].quadbase = {}
				local qb = enemiesdata[s].quadbase
				if enemiesdata[s].nospritesets then
					qb[1] = {}
					for x = 1, enemiesdata[s].quadcount do
						qb[1][x] = love.graphics.newQuad((x-1)*quadwidth, 0, quadwidth, imgheight, imgwidth, imgheight)
					end
					qb[2] = qb[1]
					qb[3] = qb[1]
					qb[4] = qb[1]
				else
					for y = 1, 4 do
						qb[y] = {}
						for x = 1, enemiesdata[s].quadcount do
							qb[y][x] = love.graphics.newQuad((x-1)*quadwidth, (y-1)*quadheight, quadwidth, quadheight, imgwidth, imgheight)
						end
					end
				end
				loadenemyquad(s)
			elseif math.floor(quadwidth) ~= quadwidth then
				print("IMAGE FOR " .. s .. " NOT DIVISIBLE BY QUADCOUNT")
				notice.new("image width for " .. s .. "\nnot divisible by quadcount", notice.red, 5)
			elseif math.floor(quadheight) ~= quadheight then
				print("IMAGE FOR " .. s .. " NOT DIVISIBLE BY 4")
				notice.new("image height for " .. s .. "\nnot divisible by 4 spritesets", notice.red, 5)
			end
		end
	end
end

function loadenemysound(filename, s)
	enemiesdata[s].sound = love.audio.newSource(filename, "static")
end

function loadenemyquad(s, no_notices)
	--make sure enemy is using the up-to-date spriteset

	local data = enemiesdata[s]
	if data.quadbase then --check if quads for enemy exists
		data.quadgroup = data.quadbase[spriteset]
		if data.animationtype == "frames" or data.animationtype == "character" then
			if not no_notices then
				if not data.animationstart then
					print(s .. " IS MISSING ANIMATIONSTART")
					notice.new(s .. " is missing\nanimationstart frame", notice.red, 5)
				end
			end
			data.quad = data.quadgroup[data.animationstart]
		else
			data.quad = data.quadgroup[data.quadno]
		end
	end
end
