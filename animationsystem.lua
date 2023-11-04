function animationsystem_load()
	animationtriggerfuncs = {}
	animationbuttontriggerfuncs = {}
	animationbuttonreleasetriggerfuncs = {}
	animationswitchtriggerfuncs = {}
	animationplayerlandtriggerfuncs = {}
	animationplayerhurttriggerfuncs = {}
	animations = {}
	animationschar = {}
	
	if not dcplaying then
		local fl = love.filesystem.getDirectoryItems(mappackfolder .. "/" .. mappack .. "/animations")
		for i = 1, #fl do
			if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/animations/" .. fl[i], "directory") then
				--load animations from folder
				local fl2 = love.filesystem.getDirectoryItems(mappackfolder .. "/" .. mappack .. "/animations/" .. fl[i])
				for i2 = 1, #fl2 do
					if string.sub(fl2[i2], -4) == "json" then
						table.insert(animations, animation:new(mappackfolder .. "/" .. mappack .. "/animations/" .. fl[i] .. "/" .. fl2[i2], fl2[i2]))
					end
				end
			elseif string.sub(fl[i], -4) == "json" then
				table.insert(animations, animation:new(mappackfolder .. "/" .. mappack .. "/animations/" .. fl[i], fl[i]))
			end
		end
	end

	--custom chracters animations
	local characterenemiesloaded = {} --don't load the same enemy multiple times
	for i = 1, #mariocharacter do
		if mariocharacter[i] and (not characterenemiesloaded[mariocharacter[i]]) and love.filesystem.getInfo("alesans_entities/characters/" .. mariocharacter[i] .. "/animations/") then
			local dir = love.filesystem.getDirectoryItems("alesans_entities/characters/" .. mariocharacter[i] .. "/animations/")
			for i2 = 1, #dir do
				if dir[i2] and string.sub(dir[i2], -4) == "json" then
					local t = animationschar
					if editormode and (characters.data[mariocharacter[i]] and not characters.data[mariocharacter[i]].hideanimations) then
						t = animations
					end
					table.insert(t, animation:new("alesans_entities/characters/" .. mariocharacter[i] .. "/animations/" .. dir[i2], dir[i2]))
				end
			end
			characterenemiesloaded[mariocharacter[i]] = true
		end
	end
end

function animationsystem_update(dt)
	if not editormode then
		for i, v in pairs(animations) do
			v:update(dt)
		end
		for i, v in pairs(animationschar) do
			v:update(dt)
		end
	end
end

function animationsystem_draw()
	if not editormode then
		for i, v in pairs(animations) do
			v:draw()
		end
		for i, v in pairs(animationschar) do
			v:draw()
		end
	end
end

function animationsystem_buttontrigger(i, button)
	if editormode then
		--if the player is frozen make them not static
		--this doesn't have anything to do with animations but this is an easy place to put this
		if i == 1 and objects["player"][1] and objects["player"][1].static then
			objects["player"][1].static = false
		end
		return
	end

	if not animationbuttontriggerfuncs[button] then
		return
	end

	if objects and objects["player"][i] and objects["player"][i].dead then
		return
	end

	for id = 1, #animationbuttontriggerfuncs[button] do
		if animationbuttontriggerfuncs[button][id][2] == "everyone" or ("player " .. i) == animationbuttontriggerfuncs[button][id][2] then
			animationbuttontriggerfuncs[button][id][1]:trigger()
		end
	end
end

function animationsystem_buttonreleasetrigger(i, button)
	if editormode then
		return
	end
	
	if not animationbuttonreleasetriggerfuncs[button] then
		return
	end

	if objects and objects["player"][i] and objects["player"][i].dead then
		return
	end

	for id = 1, #animationbuttonreleasetriggerfuncs[button] do
		if animationbuttonreleasetriggerfuncs[button][id][2] == "everyone" or ("player " .. i) == animationbuttonreleasetriggerfuncs[button][id][2] then
			animationbuttonreleasetriggerfuncs[button][id][1]:trigger()
		end
	end
end

function animationsystem_playerlandtrigger(i)
	if editormode then
		return
	end
	if objects and objects["player"][i] and objects["player"][i].dead then
		return
	end
	if animationplayerlandtriggerfuncs[i] then
		for id = 1, #animationplayerlandtriggerfuncs[i] do
			animationplayerlandtriggerfuncs[i][id]:trigger()
		end
	end
	if animationplayerlandtriggerfuncs["everyone"] then
		for id = 1, #animationplayerlandtriggerfuncs["everyone"] do
			animationplayerlandtriggerfuncs["everyone"][id]:trigger()
		end
	end
end

function animationsystem_playerhurttrigger(i)
	if editormode then
		return
	end
	if objects and objects["player"][i] and objects["player"][i].dead then
		return
	end
	if animationplayerhurttriggerfuncs[i] then
		for id = 1, #animationplayerhurttriggerfuncs[i] do
			animationplayerhurttriggerfuncs[i][id]:trigger()
		end
	end
	if animationplayerhurttriggerfuncs["everyone"] then
		for id = 1, #animationplayerhurttriggerfuncs["everyone"] do
			animationplayerhurttriggerfuncs["everyone"][id]:trigger()
		end
	end
end
