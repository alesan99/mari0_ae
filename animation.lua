animation = class:new()

--[[ TRIGGERS:
mapload								when the map is loaded
timepassed:time						when <time> ms have passed
playerxgreater:x					when a player's x is greater than x
playerxless:x						when a player's x is less than x
playerygreater:x					when a player's y is greater than y
playeryless:x						when a player's y is less than y
animationtrigger:i					when animationtrigger with ID i is triggered
mariotimeless:i						when mariotime is less than i
buttonpressed:button				when player presses button
buttonreleased:button				when player releases button
pswitchtrigger:on/off				when p switch is pressed or done
switchblocktrigger:i				when switch block is used
playerlandsonground:i				when player lands on ground
playerhurt:i						when player gets hurt
whennumber:i:>/</=:v				when a variable turns something
--]]

--[[ CONDITIONS:
noprevsublevel					doesn't if the level was changed from another sublevel (Mario goes through pipe, lands in 1-1_1, prevsublevel was _0, no trigger.)
worldequals:i					only triggers if current world is i
levelequals:i					only triggers if current level is i
sublevelequals:i				only triggers if current sublevel is i
requirecoins:i					requires i coins to trigger (will not remove coins)

playersize[:player]:size			requires a player to be size
requirecollectables:i				requires i collectables to trigger (will not remove coins)
requirepoints:i					requires i points
buttonhelddown:button				only if button is held down
requirekeys[:player]:i				requires i keys
ifnumber:i:>/</=:v				if a variable is equal/greater than something
ifcoins:>/</=:v					if coin count is equal/greater than v
ifcollectables:>/</=:v:i			if collectable count of a type is equal/greater than v
ifpoints:>/</=:v				if points is equal/greater than v
requireplayers:i				requires i players to trigger
--]]

--[[ ACTIONS:
disablecontrols[:player]			disables player input and hides the portal line
enablecontrols[:player]				enables player input and shows portal line
sleep:time							waits for <time> secs
setcamerax:x						sets the camera xscroll to <x>
setcameray:y						sets the camera yscroll to <y>
pancameratox:x:time					pans the camera horizontally over <time> secs to <x>
pancameratoy:y:time					pans the camera vertically over <time> secs to <y>
pancamera:x:y:time					pans the camera relative to current position over <time>
disablescroll						disables autoscroll
enablescroll						enables autoscroll
setx[:player]:x						sets the x-position of player(s)
sety[:player]:y						sets the y-position of player(s)
playerwalk[:player]:direction:speed	makes players walk into the given <direction>
playeranimationstop[:player]		stops whatever animation the player is in
disableanimation					disables this animation from triggering
enableanimation						enables this animation to trigger
playerjump[:player]					makes players jump (as high as possible)
playerstopjump[:player]				makes players abort the jump (for small jumps)
dialogbox:text[:speaker][:color]	creates a dialogbox with <text> and <speaker> and <color> (from textcolors in variables.lua)
removedialogbox						removes the dialogbox
playmusic:i							plays music <i>
screenshake:power					makes the screen shake with <power>
addcoins:coins						adds <coins> coins
addpoints:points					adds <points> points
changebackgroundcolor:r:g:b			changes background color to rgb
killplayer[:player]					hurts player(s)
changetime:time						changes the time left to <time>
loadlevel:world:level:sublevel:exit	starts level <world>-<level>_<sublevel> pipeexitid:<exit>
nextlevel							goes to next level
disableplayeraim:player				disables mouse or joystick aiming for <player>
enableplayeraim:player				enables mouse or joystick aiming for <player>
closeportals[:player]				closes portals for <player>
makeplayerlook:player:angle			makes players aim in direction of <angle>, starting at right and going CCW, should probably be used in connection with "disableplayeraim" because it's just once
makeplayerfireportal:player:i		makes a player shoot one of their portal
enableportalgun:player				enable portal gun of player
disableportalgun:player				disable portal gun of player
repeat								repeats animation
instantkillplayer[:player]			kills player(s)
disablejumping						disable jumping
enablejumping						enables jumping

autosave							saves mappack progress
changebackground:background			changes background
changeforeground:background	 	    changes foreground
removecoins:amount					removes coins
removepoints:points					removes <points> points
removecollectables:amount:i			removes collectables
resetcollectables:amount:i			resets collected collectables
disablehorscroll					disables horizontal scrolling
nextlevel							goes to next level
setautoscrolling					sets autoscrolling to <speedx> and <speedy>
stopautoscrolling					stops autoscrolling
playsound							plays <sound>
stopsound							stops <sound>
stopsounds							stops all sounds
togglewind							toggle wind
togglelightsout						toggle lights out
togglelowgravity					toggle low gravity
animationoutput:i:signal			triggers animationoutput with ID i
transformenemy:i					transforms enemy with "transformtrigger": "animation" and "transformanimation": i
killallenemies						kills all enemies
triggeranimation:i					preforms animation trigger
addkeys[:player]:amount				adds keys
removekeys[:player]:amount			removes keys
setnumber:name:=/+:v				change number by something
resetnumbers						resets all animation numbers
launchplayer[:player]:x:y			launches player at defined speed
launchplayerx[:player]:x			launches player at defined speed in the x axis
launchplayery[:player]:y			launches player at defined speed in the y axis
addtime:time						adds <seconds> time
removetime:time						removes <seconds> time
settime:time						sets time
setplayerlight:blocks				sets player's light in lights out mode
waitforinput                        waits until a spesific/any player presses a button
waitfrotrigger                      waits until a spesific animation is triggered
makeinvincible:i					makes player invincible/give star for i or default seconds
changeswitchstate:i					trigger switchblocks
--]]

function animation:init(path, name)
	self.filepath = path
	self.name = name
	self.raw = love.filesystem.read(self.filepath)
	
	self:decode(self.raw)
	
	self.queue = {}
	self.firstupdate = true
	self.running = false
	self.sleep = 0
	self.waiting = false
	self.enabled = true
end

function animation:decode(s)
	self.triggers = {}
	self.conditions = {}
	self.actions = {}
	
	local animationjson
	if s then
		animationjson = JSON:decode(s)
	else
		animationjson = {}
		notice.new("Could not read animation", notice.red, 2)
	end

	for i, v in pairs(animationjson.triggers) do
		self:addtrigger(v)
	end
	
	for i, v in pairs(animationjson.conditions) do
		self:addcondition(v)
	end
	
	for i, v in pairs(animationjson.actions) do
		self:addaction(v)
	end
end

function animation:addtrigger(v)
	table.insert(self.triggers, {unpack(v)})
	if v[1] == "mapload" then
		
	elseif v[1] == "timepassed" then
		self.timer = 0
	elseif v[1] == "playerx" then
	
	elseif v[1] == "animationtrigger" then
		if not animationtriggerfuncs[v[2] ] then
			animationtriggerfuncs[v[2] ] = {}
		end
		table.insert(animationtriggerfuncs[v[2] ], self)

	elseif v[1] == "buttonpressed" then
		local name = v[2]
		if name:find("player ") then
			name = tonumber(string.sub(v[2], -1))
		end
		if not animationbuttontriggerfuncs[v[2]] then --player
			animationbuttontriggerfuncs[v[2]] = {}
		end
		table.insert(animationbuttontriggerfuncs[v[2]], {self, v[3]})
	elseif v[1] == "buttonreleased" then
		local name = v[2]
		if name:find("player ") then
			name = tonumber(string.sub(v[2], -1))
		end
		if not animationbuttonreleasetriggerfuncs[v[2]] then --player
			animationbuttonreleasetriggerfuncs[v[2]] = {}
		end
		table.insert(animationbuttonreleasetriggerfuncs[v[2]], {self, v[3]})
	
	elseif v[1] == "switchblocktrigger" then
		table.insert(animationswitchtriggerfuncs, {self, v[2]})
	elseif v[1] == "pswitchtrigger" then
		table.insert(animationswitchtriggerfuncs, {self, "pswitch-" .. v[2]})
	elseif v[1] == "playerlandsonground" then
		local name = v[2]
		if name:find("player ") then
			name = tonumber(string.sub(v[2], -1))
		end
		if not animationplayerlandtriggerfuncs[name] then --player
			animationplayerlandtriggerfuncs[name] = {}
		end
		table.insert(animationplayerlandtriggerfuncs[name], self)
	elseif v[1] == "playerhurt" then
		local name = v[2]
		if name:find("player ") then
			name = tonumber(string.sub(v[2], -1))
		end
		if not animationplayerhurttriggerfuncs[name] then --player
			animationplayerhurttriggerfuncs[name] = {}
		end
		table.insert(animationplayerhurttriggerfuncs[name], self)
	end
end

function animation:addcondition(v)
	table.insert(self.conditions, {unpack(v)})
end

function animation:addaction(v)
	table.insert(self.actions, {unpack(v)})
end

function animation:update(dt)
	--check my triggers for triggering, yo
	for i, v in pairs(self.triggers) do
		if v[1] == "mapload" then
			if self.firstupdate then
				self:trigger()
			end
		elseif v[1] == "timepassed" then
			self.timer = self.timer + dt
			if tonumber(v[2]) and self.timer >= tonumber(v[2]) and self.timer - dt < tonumber(v[2]) then
				self:trigger()
			end
		elseif v[1] == "mariotimeless" then
			if mariotime <= tonumber(v[2]) and not levelfinished then
				self:trigger()
			end
		elseif v[1] == "playerxgreater" then
			local trig = false
			for i = 1, players do
				if objects["player"][i].x+objects["player"][i].width/2 > tonumber(v[2]) then
					trig = true
				end
			end
			
			if trig then
				self:trigger()
			end
		elseif v[1] == "playerxless" then
			local trig = false
			for i = 1, players do
				if objects["player"][i].x+objects["player"][i].width/2 < tonumber(v[2]) then
					trig = true
				end
			end
			
			if trig then
				self:trigger()
			end
			
		elseif v[1] == "playerygreater" then
			local trig = false
			for i = 1, players do
				if objects["player"][i].y+objects["player"][i].height/2 > tonumber(v[2]) then
					trig = true
				end
			end
			
			if trig then
				self:trigger()
			end
		elseif v[1] == "playeryless" then
			local trig = false
			for i = 1, players do
				if objects["player"][i].y+objects["player"][i].height/2 < tonumber(v[2]) then
					trig = true
				end
			end
			
			if trig then
				self:trigger()
			end
		elseif v[1] == "whennumber" then
			local trig = false
			local name = tostring(v[2])
			local operation = v[3]
			local value = tonumber(v[4])
			if name then
				if (not animationnumbers[name]) or (not value) then
					trig = false
				else
					if operation == "=" then
						if animationnumbers[name] == value then
							trig = true
						end
					elseif operation == ">" then
						if animationnumbers[name] > value then
							trig = true
						end
					elseif operation == "<" then
						if animationnumbers[name] < value then
							trig = true
						end
					end
				end
			end
			if trig then
				self:trigger()
			end
		end
	end
	
	self.firstupdate = false
	
	if self.running then
		if self.sleep > 0 then
			self.sleep = math.max(0, self.sleep - dt)
		elseif self.waiting then
			if self.waiting.t == "input" then
				local pstart, pend = 1, players
				local button = self.waiting.button
				if self.waiting.player ~= "everyone" then
					local p = tonumber(string.sub(self.waiting.player, -1))
					pstart, pend = p, p
				end

				local press = false
				for i = pstart, pend do
					if button == "jump" and jumpkey(i) then
						press = true
					elseif button == "left" and leftkey(i) then
						press = true
					elseif button == "right" and rightkey(i) then
						press = true
					elseif button == "up" and upkey(i) then
						press = true
					elseif button == "down" and downkey(i) then
						press = true
					elseif button == "run" and runkey(i) then
						press = true
					elseif button == "use" and usekey(i) then
						press = true
					elseif button == "reload" and reloadkey(i) then
						press = true
					end
					if press then
						self.waiting = false
					end
				end
			elseif self.waiting.t == "trigger" then
				if animationtriggerfuncs[self.waiting.name] and animationtriggerfuncs[self.waiting.name].triggered then
					animationtriggerfuncs[self.waiting.name].triggered = nil
					self.waiting = false
				end
			end
		end
		
		while self.sleep == 0 and (not self.waiting) and self.currentaction <= #self.actions do
			local v = self.actions[self.currentaction]

			if v[1] == "disablecontrols" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].controlsenabled = false
					end
				else
					local p = objects["player"][tonumber(string.sub(v[2], -1))]
					if p then
						p.controlsenabled = false
					end
				end
			elseif v[1] == "enablecontrols" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].controlsenabled = true
					end
				else
					local p = objects["player"][tonumber(string.sub(v[2], -1))]
					if p then
						p.controlsenabled = true
					end
				end
			elseif v[1] == "sleep" then
				self.sleep = tonumber(v[2])
			elseif v[1] == "waitforinput" then
				self.waiting = {t="input", button=v[2], player=v[3]}
			elseif v[1] == "waitfortrigger" then
				self.waiting = {t="trigger", name=v[2]}
			elseif v[1] == "setcamerax" then
				xscroll = tonumber(v[2])
			elseif v[1] == "setcameray" then
				yscroll = tonumber(v[2])
			elseif v[1] == "pancameratox" then
				autoscrollx = false
				if tonumber(v[3]) == 0 then
					camerasnap(tonumber(v[2]), yscroll, "animation")
					generatespritebatch()
				else
					cameraxpan(tonumber(v[2]), tonumber(v[3]))
				end
			elseif v[1] == "pancameratoy" then
				autoscrolly = false
				if tonumber(v[3]) == 0 then
					camerasnap(xscroll, tonumber(v[2]), "animation")
					generatespritebatch()
				else
					cameraypan(tonumber(v[2]), tonumber(v[3]))
				end
			elseif v[1] == "pancamera" then
				local hor, ver = tonumber(v[2]), tonumber(v[3])
				if hor ~= 0 then
					autoscrollx = false
				end
				if ver ~= 0 then
					autoscrolly = false
				end
				if tonumber(v[4]) == 0 then
					camerasnap(xscroll+hor, yscroll+ver, "animation")
					generatespritebatch()
				else
					cameraxpan(xscroll+hor, tonumber(v[4]))
					cameraypan(yscroll+ver, tonumber(v[4]))
				end
			elseif v[1] == "disablescroll" then
				autoscroll = false
				autoscrolly = false
				autoscrollx = false
			elseif v[1] == "disableverscroll" then
				autoscrolly = false
			elseif v[1] == "disablehorscroll" then
				autoscrollx = false
			elseif v[1] == "enablescroll" then
				autoscroll = true
				autoscrolly = true
				autoscrollx = true
			elseif v[1] == "enableverscroll" then
				autoscrolly = true
			elseif v[1] == "enablehorscroll" then
				autoscrollx = true
			elseif v[1] == "setx" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].x = tonumber(v[3])
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] then
						objects["player"][tonumber(string.sub(v[2], -1))].x = tonumber(v[3])
					end
				end
			elseif v[1] == "sety" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].y = tonumber(v[3])
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] then
						objects["player"][tonumber(string.sub(v[2], -1))].y = tonumber(v[3])
					end
				end
			elseif v[1] == "playerwalk" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i]:animationwalk(v[3], tonumber(v[4]))
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] then
						objects["player"][tonumber(string.sub(v[2], -1))]:animationwalk(v[3], tonumber(v[4]))
					end
				end
			elseif v[1] == "playeranimationstop" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i]:stopanimation()
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] then
						objects["player"][tonumber(string.sub(v[2], -1))]:stopanimation()
					end
				end
			elseif v[1] == "disableanimation" then
				self.enabled = false
			elseif v[1] == "enableanimation" then
				self.enabled = true
			elseif v[1] == "playerjump" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i]:jump(true)
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] then
						objects["player"][tonumber(string.sub(v[2], -1))]:jump(true)
					end
				end
			elseif v[1] == "playerstopjump" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i]:stopjump(true)
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] then
						objects["player"][tonumber(string.sub(v[2], -1))]:stopjump()
					end
				end
			elseif v[1] == "dialogbox" then
				createdialogbox(v[2], v[3], v[4])
			elseif v[1] == "removedialogbox" then
				dialogboxes = {}
			elseif v[1] == "playmusic" then
				love.audio.stop()
				if v[2] then
					--if musicname then
					--	music:stop(musicname)
					--end
					stopmusic()
					musicname = v[2]
					if v[2] == "star" then
						musicname = "starmusic"
					end
					for i, m in pairs(music.list) do
						if m == musicname then
							musici = i + 1 -- plus one because of the none music being number 1
						end
					end
					for i, m in pairs(custommusics) do
						if m == mappackfolder .. "/" .. mappack .. "/" .. musicname then
							musicname = m
							musici = 7
							custommusic = musicname
						end
					end
					music:play(musicname)
					--playmusic()
				end
			elseif v[1] == "playsound" then
				if v[2] then
					for i, s in pairs(soundliststring) do
						if s == v[2] then
							if customsounds and customsounds[i] then
								playsound(_G[soundliststring[i] .. "sound"])
							else
								playsound(soundlist[i])
							end
						end
					end
				end
			elseif v[1] == "stopsound" then
				if v[2] then
					for i, s in pairs(soundliststring) do
						if s == v[2] then
							if customsounds and customsounds[i] then
								_G[soundliststring[i] .. "sound"]:stop()
							else
								soundlist[i]:stop()
							end
						end
					end
				end
			elseif v[1] == "stopsounds" then
				if v[2] then
					for i, s in pairs(soundliststring) do
						if customsounds and customsounds[i] then
							_G[soundliststring[i] .. "sound"]:stop()
						else
							soundlist[i]:stop()
						end
					end
				end
			elseif v[1] == "screenshake" then
				earthquake = tonumber(v[2]) or 1
			elseif v[1] == "addcoins" then
				collectcoin(nil, nil, tonumber(v[2]) or 1)
			elseif v[1] == "addpoints" then
				addpoints(tonumber(v[2]) or 1)
			elseif v[1] == "removepoints" then
				marioscore = math.max(0, marioscore - (tonumber(v[2]) or 1))
			elseif v[1] == "addtime" then
				local oldtime = mariotime
				mariotime = mariotime + (tonumber(v[2]) or 0)
				if oldtime < 100 and mariotime > 100 and not lowtimesound:isPlaying() then
					music:stopall()
					playmusic()
				end
			elseif v[1] == "removetime" then
				local oldtime = mariotime
				mariotime = math.max(0.01, mariotime - (tonumber(v[2]) or 0))
				if oldtime > 100 and mariotime < 100 then
					startlowtime()
				end
			elseif v[1] == "settime" then
				local oldtime = mariotime
				mariotime = math.max(0.01, tonumber(v[2]) or mariotime)
				if oldtime > 100 and mariotime < 100 then
					startlowtime()
				elseif oldtime < 100 and mariotime > 100 and not lowtimesound:isPlaying() then
					music:stopall()
					playmusic()
				end
			elseif v[1] == "changebackgroundcolor" then
				love.graphics.setBackgroundColor(tonumber(v[2]) or 255, tonumber(v[3]) or 255, tonumber(v[4]) or 255)
			elseif v[1] == "killplayer" then
				if v[2] == "everyone" then
					for i = 1, players do
						if not objects["player"][i].dead then
							objects["player"][i]:die("script")
						end
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] and not objects["player"][tonumber(string.sub(v[2], -1))].dead then
						objects["player"][tonumber(string.sub(v[2], -1))]:die("script")
					end
				end
			elseif v[1] == "instantkillplayer" then
				if v[2] == "everyone" then
					for i = 1, players do
						if not objects["player"][i].dead then
							objects["player"][i]:die("killscript")
						end
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] and not objects["player"][tonumber(string.sub(v[2], -1))].dead then
						objects["player"][tonumber(string.sub(v[2], -1))]:die("killscript")
					end
				end
			elseif v[1] == "changetime" then
				mariotime = (tonumber(v[2]) or 400)
			elseif v[1] == "loadlevel" or v[1] == "loadlevelinstant" then
				love.audio.stop()
				
				--why do sublevels suck so much
				local oldsub = mariosublevel
				marioworld = tonumber(v[2]) or marioworld
				mariolevel = tonumber(v[3]) or mariolevel
				mariosublevel = tonumber(v[4]) or mariosublevel
				testlevelworld = marioworld
				testlevellevel = mariolevel
				actualsublevel = mariosublevel
				respawnsublevel = mariosublevel
				levelscreen_load("animation")
				if v[5] then --Edit ID
					pipeexitid = tonumber(v[5])
					animationprevsublevel = oldsub --dumb work around
				end
				mariosublevel = tonumber(v[4]) or mariosublevel
				actualsublevel = mariosublevel
				respawnsublevel = mariosublevel
				if v[1] == "loadlevelinstant" then
					levelscreentimer = blacktime
				end
			elseif v[1] == "nextlevel" then
				nextlevel()
			elseif v[1] == "disableplayeraim" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].disableaiming = true
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] then
						objects["player"][tonumber(string.sub(v[2], -1))].disableaiming = true
					end
				end
			elseif v[1] == "enableplayeraim" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].disableaiming = false
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] then
						objects["player"][tonumber(string.sub(v[2], -1))].disableaiming = false
					end
				end
			
			elseif v[1] == "closeportals" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i]:removeportals()
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] then
						objects["player"][tonumber(string.sub(v[2], -1))]:removeportals()
					end
				end
				
			elseif v[1] == "makeplayerlook" then
				local ang = math.fmod(math.fmod(tonumber(v[3]), 360)+360, 360)
				
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].pointingangle = math.rad(ang)-math.pi/2
					end
				else
					if objects["player"][tonumber(string.sub(v[2], -1))] then
						objects["player"][tonumber(string.sub(v[2], -1))].pointingangle = math.rad(ang)-math.pi/2
					end
				end
			
			elseif v[1] == "makeplayerfireportal" then
				if tonumber(v[3]) == 1 or tonumber(v[3]) == 2 then
					if v[2] == "everyone" then
						for i = 1, players do
							local sourcex = objects["player"][i].x+6/16
							local sourcey = objects["player"][i].y+6/16
							local direction = objects["player"][i].pointingangle
							
							shootportal(i, 1, sourcex, sourcey, direction)
						end
					else
						local i = tonumber(string.sub(v[2], -1))
						
						if objects["player"][i] then
							local sourcex = objects["player"][i].x+6/16
							local sourcey = objects["player"][i].y+6/16
							local direction = objects["player"][i].pointingangle
							
							shootportal(i, 1, sourcex, sourcey, direction)
						end
					end
				end
				
			elseif v[1] == "disableportalgun" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].portalgundisabled = true
					end
				else
					local i = tonumber(string.sub(v[2], -1))
					if objects["player"][i] then
						objects["player"][i].portalgundisabled = true
					end
				end
				
			elseif v[1] == "enableportalgun" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].portalgundisabled = false
					end
				else
					local i = tonumber(string.sub(v[2], -1))
					if objects["player"][i] then
						objects["player"][i].portalgundisabled = false
					end
				end
			elseif v[1] == "launchplayer" then
				local sx, sy = v[3]:gsub("B","-"), v[4]:gsub("B","-")
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].speedx = tonumber(sx) or 0
						objects["player"][i].speedy = tonumber(sy) or 0
					end
				else
					local i = tonumber(string.sub(v[2], -1))
					if objects["player"][i] then
						objects["player"][i].speedx = tonumber(sx) or 0
						objects["player"][i].speedy = tonumber(sy) or 0
					end
				end
			elseif v[1] == "launchplayerx" then
				local sx = v[3]:gsub("B","-")
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].speedx = tonumber(sx) or 0
					end
				else
					local i = tonumber(string.sub(v[2], -1))
					if objects["player"][i] then
						objects["player"][i].speedx = tonumber(sx) or 0
					end
				end
			elseif v[1] == "launchplayery" then
				local sy = v[3]:gsub("B","-")
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].speedy = tonumber(sy) or 0
					end
				else
					local i = tonumber(string.sub(v[2], -1))
					if objects["player"][i] then
						objects["player"][i].speedy = tonumber(sy) or 0
					end
				end
			elseif v[1] == "autosave" then
				-- only save if the game is being played offline
				if not (CLIENT or SERVER or dcplaying) then
					-- don't save if the game is being played in the editor
					if not testlevel then
						writesuspendfile()
					end
					-- show notice regardless of whether player is in editor or not, to prove the function works while testing
					if v[2] == true then
						notice.new(TEXT["game saved!"], notice.white, 3)
					end
				end
			elseif v[1] == "changebackground" then
				if v[2] then
					loadcustombackground(v[2])
				end
				custombackground = v[2]
			elseif v[1] == "changeforeground" then
				if v[2] then
					loadcustomforeground(v[2])
				end
				customforeground = v[2]
			elseif v[1] == "removecoins" then
				mariocoincount = math.max(0, mariocoincount-(tonumber(v[2]) or 0))
			elseif v[1] == "removecollectables" then
				collectablescount[tonumber(v[3]) or 1] = math.max(0, collectablescount[tonumber(v[3]) or 1]-(tonumber(v[2]) or 1))
				for i, o in pairs(objects["collectablelock"]) do
					o:removecheck()
				end
			elseif v[1] == "addcollectables" then
				local t = tonumber(v[3]) or 1
				collectablescount[t] = collectablescount[t]+(tonumber(v[2]) or 1)
				playsound(_G["collectable" .. t .. "sound"])
			elseif v[1] == "resetcollectables" then
				local i = tonumber(v[2]) or 1
				--iterate through collected collectable list and remove any saved locations
				local w, l, s = tostring(marioworld), tostring(mariolevel), tostring(actualsublevel)
				local level = w .. "-" .. l .. "-" .. s
				for n, t in pairs(collectableslist[i]) do
					collectables[t[1]][t[2]] = nil
					if level == t[1] then
						--respawn collectable
						local s = t[2]:split("-") --find coords
						local x, y = tonumber(s[1]), tonumber(s[2])
						local coinblock = (ismaptile(x, y) and tilequads[map[x][y][1]].collision and tilequads[map[x][y][1]].coinblock)
						objects["collectable"][tilemap(x,y)] = collectable:new(x, y, map[x][y], false, coinblock)
					end
				end
				collectableslist[i] = {}
				--finally, reset the amount and update locks
				collectablescount[i] = 0
				for i, o in pairs(objects["collectablelock"]) do
					o:removecheck()
				end
			elseif v[1] == "setautoscrolling" then
				local sx, sy = v[2]:gsub("B","-"), v[3]:gsub("B","-")
				autoscrolling = true
				autoscrollingx = tonumber(sx) or autoscrollingdefaultspeed
				if autoscrollingx == 0 then
					autoscrollingx = false
				end
				autoscrollingy = tonumber(sy) or autoscrollingdefaultspeed
				if autoscrollingy == 0 then
					autoscrollingy = false
				end
			elseif v[1] == "stopautoscrolling" then
				autoscrolling = false
				autoscrollingx = false
				autoscrollingy = false
			elseif v[1] == "togglewind" then
				if v[2] then
					local speed = tonumber(v[2])
					if speed == 0 then
						windstarted = false
					else
						windentityspeed = speed
					end
				else
					windstarted = not windstarted
				end
			elseif v[1] == "togglelowgravity" then
				lowgravity = not lowgravity
				setphysics(currentphysics)
			elseif v[1] == "togglelightsout" then
				lightsout = not lightsout
			elseif v[1] == "centercamera" then
				setcamerasetting(2)
			elseif v[1] == "removeshoe" then
				if v[2] == "everyone" then
					for i = 1, players do
						if objects["player"][i].shoe then
							objects["player"][i].yoshi = false
							objects["player"][i]:shoed(false)
						end
					end
				else
					local i = tonumber(string.sub(v[2], -1))
					if objects["player"][i] then
						if objects["player"][i].shoe then
							objects["player"][i].yoshi = false
							objects["player"][i]:shoed(false)
						end
					end
				end
			elseif v[1] == "removehelmet" then
				if v[2] == "everyone" then
					for i = 1, players do
						if objects["player"][i].helmet then
							objects["player"][i]:helmeted(false)
						end
					end
				else
					local i = tonumber(string.sub(v[2], -1))
					if objects["player"][i] then
						if objects["player"][i].helmet then
							objects["player"][i]:helmeted(false)
						end
					end
				end
			elseif v[1] == "animationoutput" then
				for name, obj in pairs(objects["animationoutput"]) do
					if obj.id == v[2] then
						obj:trigger(v[3])
					end
				end
			elseif v[1] == "transformenemy" then
				transformenemyanimation(v[2])
			elseif v[1] == "killallenemies" then
				for i2, v2 in kpairs(objects, objectskeys) do
					if i2 ~= "tile" and i2 ~= "buttonblock" then
						for i3, v3 in pairs(objects[i2]) do
							if v3.active and v3.shotted and (not v3.resistseverything) then
								local dir = "right"
								if math.random(1,2) == 1 then
									dir = "left"
								end
								v3:shotted(dir)
							end
						end
					end
				end
			elseif v[1] == "setplayersize" then
				if v[3] == "everyone" then
					for i = 1, players do
						objects["player"][i]:setsize(tonumber(v[2]))
						objects["player"][i].size = tonumber(v[2])
						playsound(mushroomeatsound)
					end
				else
					local i = tonumber(string.sub(v[3], -1))
					if objects["player"][i] then
						objects["player"][i]:setsize(tonumber(v[2]))
						objects["player"][i].size = tonumber(v[2])
						playsound(mushroomeatsound)
					end
				end
			elseif v[1] == "disablejumping" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].disablejumping = true
					end
				else
					local p = objects["player"][tonumber(string.sub(v[2], -1))]
					if p then
						p.disablejumping = true
					end
				end
			elseif v[1] == "enablejumping" then
				if v[2] == "everyone" then
					for i = 1, players do
						objects["player"][i].disablejumping = false
					end
				else
					local p = objects["player"][tonumber(string.sub(v[2], -1))]
					if p then
						p.disablejumping = false
					end
				end
			elseif v[1] == "changeportal" then
				local pstart, pend = 1, players
				if v[2] ~= "everyone" then
					pstart, pend = tonumber(string.sub(v[2], -1)), tonumber(string.sub(v[2], -1))
				end
				for i = pstart, pend do
					if objects["player"][i] then
						local p = objects["player"][i]
						p.portalgun = (v[3] ~= "none")
						if p.portalgun and (not p.characterdata.noportalgun) and playertype ~= "classic" and playertype ~= "cappy" then
							p.portals = v[3]
							p:updateportalsavailable()
						end
					end
				end
			elseif v[1] == "triggeranimation" then
				if animationtriggerfuncs[v[2]] then
					for i = 1, #animationtriggerfuncs[v[2]] do
						animationtriggerfuncs[v[2]][i]:trigger()
					end
					animationtriggerfuncs[v[2]].triggered = true
				end
				
			elseif v[1] == "addkeys" then
				if v[3] == "everyone" then
					for i = 1, players do
						if objects["player"][i].key then
							objects["player"][i].key = objects["player"][i].key + tonumber(v[2])
						else
							objects["player"][i].key = tonumber(v[2])
						end
					end
					playsound(keysound)
				else
					local i = tonumber(string.sub(v[3], -1))
					if objects["player"][i] then
						if objects["player"][i].key then
							objects["player"][i].key = objects["player"][i].key + tonumber(v[2])
						else
							objects["player"][i].key = tonumber(v[2])
						end
						playsound(keysound)
					end
				end
			elseif v[1] == "removekeys" then
				if v[3] == "everyone" then
					for i = 1, players do
						if objects["player"][i].key then
							objects["player"][i].key = math.max(0, objects["player"][i].key - tonumber(v[2]))
						end
					end
				else
					local i = tonumber(string.sub(v[3], -1))
					if objects["player"][i] then
						if objects["player"][i].key then
							objects["player"][i].key = math.max(0, objects["player"][i].key - tonumber(v[2]))
						end
					end
				end
			elseif v[1] == "setplayerlight" then
				for i = 1, players do
					objects["player"][i].light = tonumber(v[2])
				end
			elseif v[1] == "makeinvincible" then
				local time = mariostarduration
				if v[2] ~= "" and tonumber(v[2]) and tonumber(v[2]) > 0 then
					time = tonumber(v[2])
				end
				if v[3] == "everyone" then
					for i = 1, players do
						if objects["player"][i].animation ~= "grow1" and objects["player"][i].animation ~= "grow2" and objects["player"][i].animation ~= "shrink" then
							objects["player"][i]:star()
							objects["player"][i].startimer = (mariostarduration-time)
						end
					end
				else
					local i = tonumber(string.sub(v[3], -1))
					if objects["player"][i] then
						if objects["player"][i].animation ~= "grow1" and objects["player"][i].animation ~= "grow2" and objects["player"][i].animation ~= "shrink" then
							objects["player"][i]:star()
							objects["player"][i].startimer = (mariostarduration-time)
						end
					end
				end
			elseif v[1] == "changeswitchstate" then
				if tonumber(v[2]) and tonumber(v[2]) <= 4 then
					changeswitchstate(tonumber(v[2]), (v[3] == "on"), true)
				end
			elseif v[1] == "setnumber" then
				local name = tostring(v[2])
				local operation = v[3]
				local value = tonumber(v[4]) or 0
				if name then
					if not animationnumbers[name] then
						animationnumbers[name] = 0
					end
					if operation == "=" then
						animationnumbers[name] = value
					elseif operation == "+" then
						animationnumbers[name] = animationnumbers[name] + value
					elseif operation == "-" then
						animationnumbers[name] = animationnumbers[name] - value
					end
				end
			elseif v[1] == "resetnumbers" then
				animationnumbers = {}
			elseif v[1] == "repeat" then
				self.currentaction = 1
				break
			end
			
			self.currentaction = self.currentaction + 1
		end
		
		if self.currentaction > #self.actions then
			self.running = false
			if #self.queue > 0 then
				self:trigger()
				table.remove(self.queue, 1)
			end
		end
	end
end

function animation:trigger()
	if self.enabled then
		--check conditions
		local pass = true

		for i, v in pairs(self.conditions) do
			if v[1] == "noprevsublevel" then
				if prevsublevel then
					pass = false
					break
				end
			elseif v[1] == "sublevelequals" then
				if (v[2] == "main" and (tonumber(actualsublevel) ~= 0)) or (v[2] ~= "main" and tonumber(v[2]) ~= tonumber(actualsublevel)) then
					pass = false
					break
				end
			elseif v[1] == "levelequals" then
				if tonumber(v[2]) ~= tonumber(mariolevel) then
					pass = false
					break
				end
			elseif v[1] == "worldequals" then
				if tonumber(v[2]) ~= tonumber(marioworld) then
					pass = false
					break
				end
			elseif v[1] == "requirecoins" then
				if mariocoincount < tonumber(v[2]) then
					pass = false
					break
				end
			elseif v[1] == "requirecollectables" then
				if (not collectablescount[tonumber(v[3])]) or collectablescount[tonumber(v[3])] < tonumber(v[2]) then
					pass = false
					break
				end
			elseif v[1] == "requirepoints" then
				if marioscore < tonumber(v[2]) then
					pass = false
					break
				end
			elseif v[1] == "ifcoins" then
				local value = tonumber(v[3])
				if v[2] == "=" and mariocoincount ~= value then
					pass = false
				elseif v[2] == ">" and mariocoincount <= value then
					pass = false
				elseif v[2] == "<" and mariocoincount >= value then
					pass = false
				end
			elseif v[1] == "ifcollectables" then
				local value = tonumber(v[3])
				local typ = tonumber(v[4])
				if not collectablescount[typ] then
					pass = false
				elseif v[2] == "=" and collectablescount[typ] ~= value then
					pass = false
				elseif v[2] == ">" and collectablescount[typ] <= value then
					pass = false
				elseif v[2] == "<" and collectablescount[typ] >= value then
					pass = false
				end
			elseif v[1] == "ifpoints" then
				local value = tonumber(v[3])
				if v[2] == "=" and marioscore ~= value then
					pass = false
				elseif v[2] == ">" and marioscore <= value then
					pass = false
				elseif v[2] == "<" and marioscore >= value then
					pass = false
				end
			elseif v[1] == "requirekeys" then
				if v[3] == "everyone" then
					for i = 1, players do
						local p = objects["player"][i]
						local key = p.key or 0
						if key < tonumber(v[2]) then
							pass = false
							break
						end
					end
				else
					local i = tonumber(string.sub(v[3], -1))
					local p = objects["player"][i]
					local key = p.key or 0
					if key < tonumber(v[2]) then
						pass = false
						break
					end
				end
			elseif v[1] == "playerissize" then
				if v[3] == "everyone" then
					for i = 1, players do
						local p = objects["player"][i]
						if (not p) or p.size ~= tonumber(v[2]) then
							pass = false
							break
						end
					end
				else
					local i = tonumber(string.sub(v[3], -1))
					local p = objects["player"][i]
					if (not p) or p.size ~= tonumber(v[2]) then
						pass = false
						break
					end
				end
			elseif v[1] == "buttonhelddown" then
				local playercheckstart, playercheckend = tonumber(string.sub(v[3], -1)), tonumber(string.sub(v[3], -1))
				local button = v[2]
				local held = false
				if v[3] == "everyone" then
					playercheckstart, playercheckend = 1, players
				end
				for i = playercheckstart, playercheckend do
					if button == "jump" and jumpkey(i) then
						held = true
					elseif button == "left" and leftkey(i) then
						held = true
					elseif button == "right" and rightkey(i) then
						held = true
					elseif button == "up" and upkey(i) then
						held = true
					elseif button == "down" and downkey(i) then
						held = true
					elseif button == "run" and runkey(i) then
						held = true
					elseif button == "use" and usekey(i) then
						held = true
					elseif button == "reload" and reloadkey(i) then
						held = true
					end
				end
				if not held then
					pass = false
					break
				end
			elseif v[1] == "ifnumber" then
				local name = tostring(v[2])
				local operation = v[3]
				local value = tonumber(v[4])
				if name then
					if (not animationnumbers[name]) and (not value) and operation == "=" then
						--if variable doesn't exist and isn't being compared to anything let it pass
					elseif (not animationnumbers[name]) or (not value) then
						pass = false
					else
						if operation == "=" then
							if not (animationnumbers[name] == value) then
								pass = false
							end
						elseif operation == ">" then
							if not (animationnumbers[name] > value) then
								pass = false
							end
						elseif operation == "<" then
							if not (animationnumbers[name] < value) then
								pass = false
							end
						end
					end
				end
			elseif v[1] == "requireplayers" then
				if players < tonumber(v[2]) then
					pass = false
					break
				end	
			end
		end
		
		if pass then
			self.running = true
			self.currentaction = 1
			self.sleep = 0
		end
	end
end

function animation:draw()
	
end

function transformenemyanimation(name)
	for objname, obj in pairs(objects["enemy"]) do
		if obj.transforms and obj:gettransformtrigger("animation") and not obj.justspawned then
			if obj.transformanimation == nil then
				if name == "" then
					--no specified animation id
					obj:transform(obj:gettransformsinto("animation"))
				end
			elseif type(obj.transformanimation) == "table" and type(obj.transformtrigger) == "table" then
				--mutliple animation triggers
				for i, s in pairs(obj.transformtrigger) do
					if s == "animation" and obj.transformanimation[i] == name then
						if type(obj.transformsinto) == "table" then
							obj:transform(obj.transformsinto[i])
						else
							obj:transform(obj:gettransformsinto("animation"))
						end
						break
					end
				end
			elseif obj.transformanimation == name then
				--single animation trigger
				obj:transform(obj:gettransformsinto("animation"))
			end
		end
	end
end
