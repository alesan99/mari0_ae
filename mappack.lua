function loadmappacksettings(suspended)
	if not love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/settings.txt") then
		return false
	end
	local s = love.filesystem.read( mappackfolder .. "/" .. mappack .. "/settings.txt" )
	local s1 = s:split("\n")
	for j = 1, #s1 do
		local s2 = s1[j]:split("=")
		if s2[1] == "lives" then
			if not suspended then
				mariolivecount = tonumber(s2[2])
			end
		elseif s2[1] == "physics" then
			currentphysics = tonumber(s2[2]) or 1
			setphysics(currentphysics)
		elseif s2[1] == "camera" then
			camerasetting = tonumber(s2[2]) or 1
			setcamerasetting(camerasetting)
		elseif s2[1] == "dropshadow" then
			dropshadow = true
		elseif s2[1] == "realtime" then
			realtime = true
		elseif s2[1] == "nocoinlimit" then
			nocoinlimit = true
		elseif s2[1] == "continuesublevelmusic" then
			continuesublevelmusic = true
		elseif s2[1] == "nolowtime" then
			nolowtime = true
		elseif s2[1] == "character" then
			for i = 1, players do
				setcustomplayer(s2[2], i)
			end
		end
	end
end

function updatemappacksettings(suspended)
	--after settings are loaded, changes may have to be made
	if CenterCamera and not editormode then
		camerasetting = 2
	end
	if ForceDropShadow and not editormode then
		dropshadow = true
	end
	
	if mariolivecount == 0 or dcplaying then
		mariolivecount = false
	end
	
	if InfiniteLivesMultiplayer and (not (SERVER or CLIENT)) and players > 1 then
		infinitelives = true
	end
	
	if not suspended then
		mariolives = {}
		for i = 1, players do
			mariolives[i] = mariolivecount
		end
		
		mariosizes = {}
		for i = 1, players do
			mariosizes[i] = 1
		end
	end
	
	updateplayerproperties()
end

function loadcustomtext()
	if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/endingmusic.ogg") then
		endingmusic = love.audio.newSource(mappackfolder .. "/" .. mappack .. "/endingmusic.ogg", "stream");endingmusic:play();endingmusic:stop()
	elseif love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/endingmusic.mp3") then
		endingmusic = love.audio.newSource(mappackfolder .. "/" .. mappack .. "/endingmusic.mp3", "stream");endingmusic:play();endingmusic:stop()
	else
		endingmusic = konamisound
	end
	if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/text.txt") then
		local s = love.filesystem.read(mappackfolder .. "/" .. mappack .. "/text.txt")
		
		defaultcustomtext()
		
		--read .txt
		local lines
		if string.find(s, "\r\n") then
			lines = s:split("\r\n")
		else
			lines = s:split("\n")
		end
		
		for i = 1, #lines do
			local s2 = lines[i]:split("=")
			local s3
			if string.find(s2[1], ":") then
				s3 = s2[1]:split(":")
			else
				s3 = {s2[1]}
			end
			if s3[1] == "endingtextcolor" then
				local s4 = s2[2]:split(",")
				
				for j = 1, 3 do
					endingtextcolor[j] = tonumber(s4[j])
				end
			elseif s3[1] == "endingtext" then
				local s4 = s2[2]:split(",")
				
				for j = 1, #s4 do
					endingtext[j] = s4[j]
				end
			elseif s3[1] == "endingcolorname" then
				endingtextcolorname = s2[2]
			elseif s3[1] == "playername" then
				if s2[2] ~= "mario" then --for custom characters
					playername = s2[2]
				end
			elseif s3[1] == "hudtextcolor" then
				local s4 = s2[2]:split(",")
				
				for j = 1, 3 do
					hudtextcolor[j] = tonumber(s4[j])
				end
			elseif s3[1] == "hudcolorname" then
				hudtextcolorname = s2[2]
			elseif s3[1] == "hudvisible" then
				hudvisible = (s2[2] == "true")
			elseif s3[1] == "hudworldletter" then
				hudworldletter = (s2[2] == "true")
			elseif s3[1] == "hudoutline" then
				hudoutline = (s2[2] == "true")
			elseif s3[1] == "hudsimple" then
				hudsimple = (s2[2] == "true")
			elseif s3[1] == "toadtext" then
				local s4 = s2[2]:split(",")
				
				for j = 1, 3 do
					toadtext[j] = s4[j]
				end
			elseif s3[1] == "peachtext" then
				local s4 = s2[2]:split(",")
				
				for j = 1, 5 do
					peachtext[j] = s4[j]
				end
			elseif s3[1] == "steve" then
				pressbtosteve = (s2[2] == "true")
			elseif s3[1] == "levelscreen" then
				local s4 = s2[2]:split(",")
				if #s4 == 0 then
					s4 = {s2[2]}
				end
				for n = 1, #s4 do
					local s5 = s4[n]:split("|")
					levelscreentext[s5[1] .. "-" .. s5[2]] = s5[3]
				end
			elseif s3[1] == "hudhidecollectables" then
				local s4 = s2[2]:split(",")
				
				for j = 1, #s4 do
					hudhidecollectables[j] = (s4[j] == "t")
				end
			end
		end
	else
		defaultcustomtext()
	end
end

function defaultcustomtext(initial)
	endingtextcolor = {255, 255, 255}
	endingtextcolorname = "white"
	endingtext = {"congratulations!", "you have finished this mappack!"}
	toadtext = {"thank you mario!", "but our princess is in", "another castle!"}
	peachtext = {"thank you mario!", "your quest is over.", "we present you a new quest.", "push button b", "to play as steve"}
	levelscreentext = {}
	pressbtosteve = true
	if not initial then
		if mariocharacter[1] and characters.data[mariocharacter[1]] then
			playername = characters.data[mariocharacter[1]].name
		else
			playername = "mario"
		end
	end
	hudtextcolor = {255, 255, 255}
	hudtextcolorname = "white"
	hudvisible = true
	hudworldletter = false
	hudoutline = false
	hudsimple = false
	hudhidecollectables = {false, false, false, false, false, false, false, false, false, false}
end

function savecustomtext()
	local s = ""
	local color = textcolors[textcolorl]
	s = s .. string.format("endingtextcolor=%s, %s, %s", unpack(color))
	s = s .. "\r\nendingcolorname=" .. textcolorl
	s = s .. "\r\nendingtext=" .. guielements["editendingtext1"].value .. "," .. guielements["editendingtext2"].value
	s = s .. "\r\nplayername=" .. guielements["editplayername"].value
	s = s .. "\r\n"
	color = textcolors[textcolorp]
	s = s .. string.format("hudtextcolor=%s, %s, %s", unpack(color))
	s = s .. "\r\nhudcolorname=" .. textcolorp
	s = s .. "\r\nhudvisible=" .. tostring(hudvisible)
	s = s .. "\r\nhudworldletter=" .. tostring(hudworldletter)
	s = s .. "\r\nhudoutline=" .. tostring(hudoutline)
	s = s .. "\r\nhudsimple=" .. tostring(hudsimple)
	s = s .. "\r\ntoadtext=" .. guielements["edittoadtext1"].value .. "," .. guielements["edittoadtext2"].value .. "," .. guielements["edittoadtext3"].value
	s = s .. "\r\npeachtext=" .. guielements["editpeachtext1"].value .. "," .. guielements["editpeachtext2"].value .. "," .. guielements["editpeachtext3"].value .. "," .. guielements["editpeachtext4"].value .. "," .. guielements["editpeachtext5"].value
	s = s .. "\r\nsteve=" .. tostring(pressbtosteve)
	if guielements["editlevelscreentext"].value ~= "" then
		levelscreentext[marioworld .. "-" .. mariolevel] = guielements["editlevelscreentext"].value
	end
	s = s .. "\r\nlevelscreen="
	local amount = false
	for t, text in pairs(levelscreentext) do
		s = s .. t:gsub("-", "|") .. "|" .. text .. ","
		amount = true
	end
	if not amount then
		s = s .. "1|1|"
	else
		s = s:sub(1, -2)
	end

	s = s .. "\r\nhudhidecollectables="
	for i = 1, #hudhidecollectables do
		if hudhidecollectables[i] then
			s = s .. "t,"
		else
			s = s .. "f,"
		end
	end
	s = s:sub(1, -2)
	
	love.filesystem.write(mappackfolder .. "/" .. mappack .. "/text.txt", s)
	loadcustomtext()
	notice.new("Saved custom text!", notice.white, 2)
end

function loadcustombackground(filename)
	local i = 1
	custombackgroundimg = {}
	custombackgroundwidth = {}
	custombackgroundheight = {}
	custombackgroundquad = {}
	custombackgroundanim = {}

	-- first tries to get BG from level.
	local levelstring = marioworld .. "-" .. mariolevel
	local actualsublevel = actualsublevel or mariosublevel
	if actualsublevel ~= 0 then --changed mariosublevel to actualsublevel because mariosublevel isn't accurate (edit: changed back, revert if anyone complains) (edit: reverted because someone complained)
		levelstring = levelstring .. "_" .. actualsublevel
	end
	local levelbgname = levelstring .. "background"
	if (not filename) or type(filename) ~= "string" then
		filename = false
	end

	-- load background folder BG's
	local realfl = {}
	local realflnames = {}
	local fl = love.filesystem.getDirectoryItems(mappackfolder .. "/" .. mappack .. "/backgrounds/")
	for b = 1, #fl do
		if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/backgrounds/" .. fl[b], "directory") then
			-- load BG's from folder
			local fl2 = love.filesystem.getDirectoryItems(mappackfolder .. "/" .. mappack .. "/backgrounds/" .. fl[b])
			for b2 = 1, #fl2 do
				if string.sub(fl2[b2], -4) == ".png" then
					local name = string.sub(fl2[b2],1,-5)
					table.insert(realfl, mappackfolder .. "/" .. mappack .. "/backgrounds/" .. fl[b] .. "/" .. name)
					table.insert(realflnames, name)
				end
			end
		else
			-- load normal BG's
			if string.sub(fl[b], -4) == ".png" then
				local name = string.sub(fl[b],1,-5)
				table.insert(realfl, mappackfolder .. "/" .. mappack .. "/backgrounds/" .. name)
				table.insert(realflnames, name)
			end
		end
	end
	--print(realflnames)

	-- function for making BG's
	local loadbg = function(i, path, path2)
		custombackgroundimg[i] = love.graphics.newImage(path .. ".png")
		custombackgroundwidth[i] = custombackgroundimg[i]:getWidth()/16
		custombackgroundheight[i] = custombackgroundimg[i]:getHeight()/16
		if love.filesystem.getInfo(path .. ".json") or (path2 and love.filesystem.getInfo(path2 .. ".json")) then -- load animation
			local data
			if love.filesystem.getInfo(path .. ".json") then
				data = love.filesystem.read(path .. ".json")
			else
				data = love.filesystem.read(path2 .. ".json")
			end
			if not data then return	end
			data = data:gsub("\r", "")
			loadcustombackgroundanim(custombackgroundimg, custombackgroundwidth, custombackgroundheight, custombackgroundanim, i, data)
		elseif not SlowBackgrounds then
			custombackgroundimg[i]:setWrap("repeat","repeat")
			custombackgroundquad[i] = love.graphics.newQuad(0,0,width*16,height*16,custombackgroundimg[i]:getWidth(),custombackgroundimg[i]:getHeight())
		end
	end

	-- loads BG from level
	while love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/" .. levelbgname .. i .. ".png") do
		loadbg(i, mappackfolder .. "/" .. mappack .. "/" .. levelbgname .. i, mappackfolder .. "/" .. mappack .. "/" .. levelbgname)
		i = i+1
	end
	if #custombackgroundimg == 0 then
		if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/" .. levelbgname .. ".png") then
			loadbg(i, mappackfolder .. "/" .. mappack .. "/" .. levelbgname)
			return
		end
	end

	-- loads BG from folders
	if #custombackgroundimg == 0 and filename then
		while tablecontainsi(realflnames, filename .. i) do
			local path = tablecontainsi(realflnames, filename .. i)
			loadbg(i, realfl[path], string.sub(realfl[path], 1, -2))
			i = i+1
		end
		if #custombackgroundimg == 0 then
			if tablecontainsi(realflnames, filename) then
				local path = tablecontainsi(realflnames, filename)
				loadbg(i, realfl[path])
				return
			end
		end
	end

	-- was no background loaded? Lets try a "global" background from the mappack folder
	if #custombackgroundimg == 0 then
		while love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/background" .. i .. ".png") do
			loadbg(i, mappackfolder .. "/" .. mappack .. "/background" .. i)
			i = i+1
		end
	end
	-- was no background loaded STILL? It must be from ye olde days, load portal background.
	if #custombackgroundimg == 0 then
		loadbg(i, "graphics/SMB/portalbackground")
	end
end

function loadcustomforeground(filename)
	-- I could have just combined the functions but i'm tired. TODO?
	local i = 1
	customforegroundimg = {}
	customforegroundwidth = {}
	customforegroundheight = {}
	customforegroundanim = {}

	-- first tries to get BG from level.
	local levelstring = marioworld .. "-" .. mariolevel
	local actualsublevel = actualsublevel or mariosublevel
	if actualsublevel ~= 0 then --changed mariosublevel to actualsublevel because mariosublevel isn't accurate (edit: changed back, revert if anyone complains) (edit: reverted because someone complained)
		levelstring = levelstring .. "_" .. actualsublevel
	end
	local levelbgname = levelstring .. "foreground"
	if (not filename) or type(filename) ~= "string" then
		filename = false
	end

	-- load background folder BG's
	local realfl = {}
	local realflnames = {}
	local fl = love.filesystem.getDirectoryItems(mappackfolder .. "/" .. mappack .. "/backgrounds/")
	for b = 1, #fl do
		if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/backgrounds/" .. fl[b], "directory") then
			-- load BG's from folder
			local fl2 = love.filesystem.getDirectoryItems(mappackfolder .. "/" .. mappack .. "/backgrounds/" .. fl[b])
			for b2 = 1, #fl2 do
				if string.sub(fl2[b2], -4) == ".png" then
					local name = string.sub(fl2[b2],1,-5)
					table.insert(realfl, mappackfolder .. "/" .. mappack .. "/backgrounds/" .. fl[b] .. "/" .. name)
					table.insert(realflnames, name)
				end
			end
		else
			-- load normal BG's
			if string.sub(fl[b], -4) == ".png" then
				local name = string.sub(fl[b],1,-5)
				table.insert(realfl, mappackfolder .. "/" .. mappack .. "/backgrounds/" .. name)
				table.insert(realflnames, name)
			end
		end
	end

	-- function for making BG's
	local loadbg = function(i, path, path2)
		customforegroundimg[i] = love.graphics.newImage(path .. ".png")
		customforegroundwidth[i] = customforegroundimg[i]:getWidth()/16
		customforegroundheight[i] = customforegroundimg[i]:getHeight()/16
		if love.filesystem.getInfo(path .. ".json") or (path2 and love.filesystem.getInfo(path2 .. ".json")) then -- load animation
			local data
			if love.filesystem.getInfo(path .. ".json") then
				data = love.filesystem.read(path .. ".json")
			else
				data = love.filesystem.read(path2 .. ".json")
			end
			if not data then return	end
			data = data:gsub("\r", "")
			loadcustombackgroundanim(customforegroundimg, customforegroundwidth, customforegroundheight, customforegroundanim, i, data)
		end
	end

	-- loads BG from level
	while love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/" .. levelbgname .. i .. ".png") do
		loadbg(i, mappackfolder .. "/" .. mappack .. "/" .. levelbgname .. i, mappackfolder .. "/" .. mappack .. "/" .. levelbgname)
		i = i+1
	end
	if #customforegroundimg == 0 then
		if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/" .. levelbgname .. ".png") then
			loadbg(i, mappackfolder .. "/" .. mappack .. "/" .. levelbgname)
			return
		end
	end

	-- loads BG from folders
	if #customforegroundimg == 0 and filename then
		while tablecontainsi(realflnames, filename .. i) do
			local path = tablecontainsi(realflnames, filename .. i)
			loadbg(i, realfl[path], string.sub(realfl[path], 1, -2))
			i = i+1
		end
		if #customforegroundimg == 0 then
			if tablecontainsi(realflnames, filename) then
				local path = tablecontainsi(realflnames, filename)
				loadbg(i, realfl[path])
				return
			end
		end
	end

	-- was no background loaded? Lets try a "global" background from the mappack folder
	if #customforegroundimg == 0 then
		while love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/foreground" .. i .. ".png") do
			loadbg(i, mappackfolder .. "/" .. mappack .. "/foreground" .. i)
			i = i+1
		end
	end
	-- was no background loaded STILL? It must be from ye olde days, load portal background.
	if #customforegroundimg == 0 then
		loadbg(i, "graphics/SMB/portalforeground")
	end
end

function loadcustombackgrounds()
	custombackgrounds = {"default"}
	local fl = love.filesystem.getDirectoryItems(mappackfolder .. "/" .. mappack .. "/backgrounds")
	for i = 1, #fl do
		if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/backgrounds/" .. fl[i], "directory") then
			-- load BG from folder
			local fl2 = love.filesystem.getDirectoryItems(mappackfolder .. "/" .. mappack .. "/backgrounds/" .. fl[i])
			for i2 = 1, #fl2 do
				local v = mappackfolder .. "/" .. mappack .. "/backgrounds/" .. fl2[i2]
				local extension = string.sub(v, -4, -1)
				local number = string.sub(v, -5, -5)
				if extension == ".png" and (number == "1" or (not tonumber(number))) then
					local name = string.sub(fl2[i2], 1, -6)
					if not tonumber(number) then
						name = string.sub(fl2[i2], 1, -5)
					end
					local bg = string.sub(v, 1, -6)
					local i = 1
					table.insert(custombackgrounds, name)
				end
			end
		else
			-- load normal BG
			local v = mappackfolder .. "/" .. mappack .. "/backgrounds/" .. fl[i]
			local extension = string.sub(v, -4, -1)
			local number = string.sub(v, -5, -5)
			if extension == ".png" and (number == "1" or (not tonumber(number))) then
				local name = string.sub(fl[i], 1, -6)
				if not tonumber(number) then
					name = string.sub(fl[i], 1, -5)
				end
				local bg = string.sub(v, 1, -6)
				local i = 1
				table.insert(custombackgrounds, name)
			end
		end
	end
end

function loadcustombackgroundanim(img, width, height, anim, i, data)
 	--timer, x, y, x speed, y speed, quad, frame, frames, quadi, quadcountx, quadcounty, delay
	anim[i] = JSON:decode(data)
	anim[i].x = 0
	anim[i].y = 0
	for id, v in pairs(anim[i]) do
		local a = id:lower()
		if type(v) == "string" then
			anim[i][a] = v:lower()
		else
			anim[i][a] = v
		end
	end

	--animation quads
	local b = anim[i]
	if b.quadcountx or b.quadcounty then
		b.quad = {}
		b.quadi = 1
		b.frame = 1
		local setframes = false
		if b.delay and tonumber(b.delay) then
			b.delay = {b.delay}
		end
		if not b.frames then
			b.frames = {}
			setframes = true
		end
		b.timer = b.delay[1]

		local x2 = b.quadcountx or 1 --frames hor
		local y2 = b.quadcounty or 1 --frames ver
		local w = width[i]*16
		local h = height[i]*16
		width[i] = width[i]/x2
		height[i] = height[i]/y2
		local c = 1 --count
		for y = 1, y2 do
			for x = 1, x2 do
				table.insert(b.quad, love.graphics.newQuad((x-1)*(w/x2), (y-1)*(h/y2), w/x2, h/y2, w, h))
				if setframes then
					table.insert(b.frames, #b.quad)
				end
				c = c + 1
			end
		end
	end
end

function loadanimatedtiles() --animated
	--Taken directly from SE
	if animatedtilecount then
		for i = 1, animatedtilecount do
			tilequads[i+90000] = nil
		end
	end
	
	animatedtiles = {}
	animatedrgblist = {}
	animatedtilesframe = {}
			
	local fl = love.filesystem.getDirectoryItems(mappackfolder .. "/" .. mappack .. "/animated")
	animatedtilecount = 0
	
	local i = 1
	while love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/animated/" .. i .. ".png") do
		local v = mappackfolder .. "/" .. mappack .. "/animated/" .. i .. ".png"
		if love.filesystem.getInfo(v) and string.sub(v, -4) == ".png" then
			if love.filesystem.getInfo(string.sub(v, 1, -5) .. ".txt") then
				animatedtilecount = animatedtilecount + 1
				local t = animatedquad:new(v, love.filesystem.read(string.sub(v, 1, -5) .. ".txt"), animatedtilecount+90000)
				tilequads[animatedtilecount+90000] = t
				table.insert(animatedtiles, t)
				local image = love.image.newImageData(mappackfolder .. "/" .. mappack .. "/animated/" .. i .. ".png")
				animatedrgblist[animatedtilecount+90000] = {}
				local tilewidth = 16
				if image:getHeight() > 16 then --SE Tiles
					tilewidth = 17
				end
				for x = 1, math.floor(image:getWidth()/tilewidth) do
					local r, g, b = getaveragecolor2(image, x, 1)
					animatedrgblist[animatedtilecount+90000][x] = {r, g, b}
				end
				animatedtilesframe[animatedtilecount+90000] = 1
			end
		end
		i = i + 1
	end
end

function loadcustomsounds()
	local starmusicexists = love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/sounds/starmusic.ogg")
	local starmusicfastexists = love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/sounds/starmusic-fast.ogg")
	if starmusicexists and starmusicfastexists then
		music:preload(mappackfolder .. "/" .. mappack .. "/sounds/starmusic.ogg", "starmusic")
		music:preload(mappackfolder .. "/" .. mappack .. "/sounds/starmusic-fast.ogg", "starmusic-fast")
		customstarmusic = true
	else
		if starmusicexists then
			notice.new("can't load custom starmusic.ogg\nstarmusic-fast.ogg is missing!", notice.red, 6)
		elseif starmusicfastexists then
			notice.new("can't load custom starmusic-fast.ogg\nstarmusic.ogg is missing!", notice.red, 6)
		end
		if customstarmusic then
			music:preload("sounds/starmusic.ogg", "starmusic")
			music:preload("sounds/starmusic-fast.ogg", "starmusic-fast")
		end
		customstarmusic = false
	end
	if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/sounds/princessmusic.ogg") then
		music:preload(mappackfolder .. "/" .. mappack .. "/sounds/princessmusic.ogg", "princessmusic")
		customprincessmusic = true
	else
		if customprincessmusic then
			music:preload("sounds/princessmusic.ogg", "princessmusic")
		end
		customprincessmusic = false
	end
	
	if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/sounds", "directory") or customsounds then
		for i, j in pairs(soundliststring) do
			if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/sounds/" .. j .. ".ogg") then
				local method = "static"
				if j == "pbutton" or j == "megamushroom" or j == "glados1" then
					method = "stream"
				end
				_G[j .. "sound"] = love.audio.newSource(mappackfolder .. "/" .. mappack .. "/sounds/" .. j .. ".ogg", method);_G[j .. "sound"]:setVolume(0);_G[j .. "sound"]:play();_G[j .. "sound"]:stop();_G[j .. "sound"]:setVolume(1)
				if j == "scorering" or j == "raccoonplane" or j == "wind" or j == "pbutton" or j == "megamushroom" then
					_G[j .. "sound"]:setLooping(true)
				end
				if not customsounds then
					customsounds = {}
				end
				customsounds[i] = true
			elseif customsounds then
				if customsounds[i] then
					local method = "static"
					if j == "pbutton" or j == "megamushroom" or j == "glados1" then
						method = "stream"
					end
					_G[j .. "sound"] = love.audio.newSource("sounds/" .. j .. ".ogg", method);_G[j .. "sound"]:setVolume(0);_G[j .. "sound"]:play();_G[j .. "sound"]:stop();_G[j .. "sound"]:setVolume(1)
					if j == "scorering" or j == "raccoonplane" or j == "wind" or j == "pbutton" or j == "megamushroom" then
						_G[j .. "sound"]:setLooping(true)
					end
				end
				customsounds[i] = nil
			end
		end
		updatesoundlist()
	end
end

function loadcustommusic()
	custommusiclist = {}
	local files = love.filesystem.getDirectoryItems(mappackfolder .. "/" .. mappack .. "/music")
	for i, s in pairs(files) do
		if s:sub(-4) == ".mp3" or s:sub(-4) == ".ogg" then
			if not (s:sub(-9, -5) == "-fast" or s:sub(-10, -5) == "-intro") then
				table.insert(custommusiclist, "music/" .. s)
			end
		end
	end

	custommusics = {}
	musictable = {"none", "overworld", "underground", "castle", "underwater", "star", "custom"}
	editormusictable = {"none", "overworld", "underground", "castle", "underwater", "star", "custom"}
	for i = 0, 99 do
		custommusics[i] = false
		if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/music" .. tostring(i) .. ".ogg") then
			custommusics[i] = mappackfolder .. "/" .. mappack .. "/music" .. tostring(i) .. ".ogg"
			music:load(custommusics[i])
		elseif love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/music" .. tostring(i) .. ".mp3") then
			custommusics[i] = mappackfolder .. "/" .. mappack .. "/music" .. tostring(i) .. ".mp3"
			music:load(custommusics[i])
		elseif i > 9 then
			break --stop counting music if one is missing
		end
	end
	for i, s in pairs(custommusiclist) do
		custommusics[s] = mappackfolder .. "/" .. mappack .. "/" .. s
		music:load(custommusics[s])
		table.insert(musictable, s)
		table.insert(editormusictable, s:sub(7, -5):lower())
	end
	if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/music.ogg") then
		custommusics[1] = mappackfolder .. "/" .. mappack .. "/music.ogg"
		music:load(custommusics[1])
	elseif love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/music.mp3") then
		custommusics[1] = mappackfolder .. "/" .. mappack .. "/music.mp3"
		music:load(custommusics[1])
	end
end

function getmappacklevels()
	local levels = {}
	mappacklevels = {}
	minusworld = false
	local worlds = defaultworlds
	
	local files = love.filesystem.getDirectoryItems(mappackfolder .. "/" .. mappack)
	for i, s in pairs(files) do
		local f1 = s:find("-")
		if s:sub(-4) == ".txt" and f1 then --check if level file (false positives can't hurt though)
			s = s:sub(1, -5)
			local w = s:sub(1, f1-1) --world
			local f2 = (s:find("_")) or math.huge --find underscore between level and sublevel
			local l = s:sub(f1+1, math.min(#s, f2-1))--level
			local sl
			if w == "M" then --check if minus world
				minusworld = true
			else
				--count worlds
				w = tonumber(w)
				if not w then
					--nothing??
				elseif w > maxworlds then --might miss minus world but who cares
					w = maxworlds
					--break (unquote this to speed up (will not properly count levels though))
				elseif w > worlds then
					worlds = w
				end

				--sub level
				sl = 0
				if f2 ~= math.huge then
					sl = s:sub(f2+1, -1)
					sl = tonumber(sl)
					if not sl then
						sl = 0
					end
				end
				
				--count levels
				l = tonumber(l)
				if w and l then
					local number_of_levels = math.max(defaultlevels, math.min(l, maxlevels))
					if not levels[w] then
						levels[w] = {} --where levels are stored
					end
					
					while number_of_levels > #levels[w] do
						table.insert(levels[w], defaultsublevels) --where number of sublevels are stored
					end

					--get highest sublevel
					if levels[w][l] and sl > levels[w][l] then
						levels[w][l] = math.max(defaultsublevels, math.min(maxsublevels, sl))
					end
				end
			end
		end
	end
	
	for i = 1, worlds do
		local levelcount = {defaultsublevels,defaultsublevels,defaultsublevels,defaultsublevels}
		if levels[i] then
			levelcount = levels[i]
		end
		--print("world: ", i, " levels: ", #levelcount, " sublevels: ", unpack(levelcount))
		table.insert(mappacklevels, levelcount)
	end
end
