function enemies_load()
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
	local fl2 = love.filesystem.getDirectoryItems(mappackfolder .. "/" .. mappack .. "/enemies/")
	
	local realfl = {}
	
	for i = 1, #fl do
		table.insert(realfl, "customenemies/" .. fl[i]) --STANDARD ENEMIES
	end
	
	for i = 1, #fl2 do
		local mpepath = mappackfolder .. "/" .. mappack .. "/enemies/" .. fl2[i]
		if love.filesystem.getInfo(mpepath, "directory") then
			--load enemies from folder
			local fl3 = love.filesystem.getDirectoryItems(mpepath)
			for i2 = 1, #fl3 do
				table.insert(realfl, mpepath .. "/" .. fl3[i2])
			end
		else
			table.insert(realfl, mpepath) --MAPPACK ENEMIES
		end
	end

	--load enemies for custom characters
	local characterenemiesloaded = {} --don't load the same enemy multiple times
	for i = 1, #mariocharacter do
		if mariocharacter[i] and (not characterenemiesloaded[mariocharacter[i]]) and love.filesystem.getInfo("alesans_entities/characters/" .. mariocharacter[i] .. "/enemies/") then
			local fl3 = love.filesystem.getDirectoryItems("alesans_entities/characters/" .. mariocharacter[i] .. "/enemies/")
			for i2 = 1, #fl3 do
				local cepath = "alesans_entities/characters/" .. mariocharacter[i] .. "/enemies/" .. fl3[i2]
				if love.filesystem.getInfo(cepath, "directory") then
					--load enemies from folder
					local fl4 = love.filesystem.getDirectoryItems(cepath)
					for i3 = 1, #fl4 do
						table.insert(realfl, cepath .. "/" .. fl4[i3])
					end
				else
					table.insert(realfl, cepath) --CHARACTER ENEMIES
				end
			end
			characterenemiesloaded[mariocharacter[i]] = true
		end
	end
	
	JSONcrashgame = false
	for i = 1, #realfl do
		if string.sub(realfl[i], -4) == "json" then
			loadenemy(realfl[i])
		end
	end
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
end

function loadenemy(filename)
	local ss = filename:split("/")
	local folder = ""
	for i = 1, #ss-1 do
		folder = folder .. ss[i] .. "/"
	end
	
	local s = string.sub(ss[#ss], 1, -6):lower()
	
	--CHECK FOR - , ; * AND WHATEVER ELSE WOULD BREAK MAPS
	local skip = false
	local badlist = {",", ";", "-", "*", "~"} --badlist sounds like a movie
	for i = 1, #badlist do
		if s:find(badlist[i]) then
			skip = true
		end
	end
	
	if not skip then --bad letter
		local data = love.filesystem.read(filename)
		if not data then
			print("COULD NOT READ FILE " .. filename)
			return
		end
		data = data:gsub("\r", "")
		
		if string.sub(data, 1, 4) == "base" then
			local split = data:split("\n")
			local base = string.sub(split[1], 6)
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
				end
			else
				--Put enemy for later loading because base hasn't been loaded yet
				if not success then
					if not loaddelayed[base] then
						loaddelayed[base] = {}
					end
					table.insert(loaddelayed[base], filename)
				end
				--print("DON'T HAVE BASE " .. base .. " FOR " .. s)
				if editormode then
					--notice.new("don't have base " .. base .. " for " .. s)
				end
				return
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

		if enemiesdata[s].fireenemy then
			for i, v in pairs(enemiesdata[s].fireenemy) do
				local a = i:lower()
				if type(v) == "string" then
					enemiesdata[s].fireenemy[a] = v:lower()
				else
					enemiesdata[s].fireenemy[a] = v
				end
			end
		end
		
		for i, v in pairs(defaultvalues) do
			if enemiesdata[s][i] == nil then
				enemiesdata[s][i] = v
			end
		end
		
		--Load graphics if it exists
		if love.filesystem.getInfo(folder .. s .. ".png") then
			enemiesdata[s].graphic = love.graphics.newImage(folder .. s .. ".png")
		elseif love.filesystem.getInfo(folder .. s .. ".PNG") then --case sensitivity FTW
			enemiesdata[s].graphic = love.graphics.newImage(folder .. s .. ".PNG")
			if editormode then
				notice.new("graphic for " .. s .. " needs\na lowercase file extension!", notice.red, 4)
			end
		end
		
		--Load icon if it exists
		if love.filesystem.getInfo(folder .. s .. "-icon.png") then
			enemiesdata[s].icongraphic = love.graphics.newImage(folder .. s .. "-icon.png")
		end

		--Load tooltop if it exists
		if love.filesystem.getInfo(folder .. s .. "-tooltip.png") then
			enemiesdata[s].tooltipgraphic = love.graphics.newImage(folder .. s .. "-tooltip.png")
		end

		--Load sound if it exists
		if love.filesystem.getInfo(folder .. s .. ".ogg") then
			enemiesdata[s].sound = love.audio.newSource(folder .. s .. ".ogg", "static")
		end
		
		--Set up quads if given
		if enemiesdata[s].graphic and enemiesdata[s].quadcount then
			local imgwidth, imgheight = enemiesdata[s].graphic:getWidth(), enemiesdata[s].graphic:getHeight()
			local quadwidth = imgwidth/enemiesdata[s].quadcount
			local quadheight = imgheight/4
			
			if math.floor(quadwidth) == quadwidth and (math.floor(quadheight) == quadheight or enemiesdata[s].nospritesets) then
				if enemiesdata[s].nospritesets then
					quadheight = quadheight*4
				end
				
				enemiesdata[s].quadbase = {}
				for y = 1, 4 do
					enemiesdata[s].quadbase[y] = {}
					for x = 1, enemiesdata[s].quadcount do
						local realy = (y-1)*quadheight
						if enemiesdata[s].nospritesets then
							realy = 0
						end
						enemiesdata[s].quadbase[y][x] = love.graphics.newQuad((x-1)*quadwidth, realy, quadwidth, quadheight, imgwidth, imgheight)
					end
				end
			elseif math.floor(quadwidth) ~= quadwidth then
				print("IMAGE FOR " .. s .. " NOT DIVISIBLE BY QUADCOUNT")
				notice.new("image width for " .. s .. "\nnot divisible by quadcount", notice.red, 5)
			elseif math.floor(quadheight) ~= quadheight then
				print("IMAGE FOR " .. s .. " NOT DIVISIBLE BY 4")
				notice.new("image height for " .. s .. "\nnot divisible by 4 spritesets", notice.red, 5)
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
		
		--check if graphic for enemy exists
		loadenemyquad(s)
		
		table.insert(customenemies, s)
		
		
		if loaddelayed[s] and #loaddelayed[s] > 0 then
			for j = #loaddelayed[s], 1, -1 do
				loadenemy(loaddelayed[s][j]) --RECURSIVE PROGRAMMING AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH
				table.remove(loaddelayed, j)
			end
		end
	else
		--Bad.
	end
end

function usebase(t)
	local r = {}
	
	for i, v in pairs(t) do
		r[i] = v
	end
	
	return r
end

function loadenemyquad(s, no_notices)
	--make sure enemy is using the up-to-date spriteset

	--check if graphic for enemy exists
	if enemiesdata[s].quadbase and enemiesdata[s].graphic then
		enemiesdata[s].drawable = true
		enemiesdata[s].quadgroup = enemiesdata[s].quadbase[spriteset]
		if enemiesdata[s].animationtype == "frames" or enemiesdata[s].animationtype == "character" then
			if not no_notices then
				if not enemiesdata[s].animationstart then
					print(s .. " IS MISSING ANIMATIONSTART")
					notice.new(s .. " is missing\nanimationstart frame", notice.red, 5)
				end
			end
			enemiesdata[s].quad = enemiesdata[s].quadbase[spriteset][enemiesdata[s].animationstart]
		else
			enemiesdata[s].quad = enemiesdata[s].quadbase[spriteset][enemiesdata[s].quadno]
		end
	end
end
