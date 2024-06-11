local queuespritebatchupdate = false

function game_load(suspended)
	scrollfactor = 0
	scrollfactory = 0
	scrollfactor2 = 0
	scrollfactor2y = 0
	love.graphics.setBackgroundColor(backgroundcolor[1])
	backgroundrgbon = false
	backgroundrgb = {0, 0, 0}
	backgroundcolor[4] = backgroundrgb

	scrollingstart = scrollingstartv --when the scrolling begins to set in (Both of these take the player who is the farthest on the left)
	scrollingcomplete = scrollingcompletev --when the scrolling will be as fast as mario can run
	scrollingleftstart = scrollingleftstartv --See above, but for scrolling left, and it takes the player on the right-estest.
	scrollingleftcomplete = scrollingleftcompletev
	superscroll = 100

	if nofunallowed then
		disablecheats()
	end

	--Daily Challenge
	if suspended == "dailychallenge" then
		suspended = false
		dcplaying = true
		disablecheats()
		--[[for i = 1, players do
			setcustomplayer("mario", i)
		end]]
	else
		dcplaying = false
	end
	
	oldjoystick = {}
	
	--LINK STUFF
	
	mariocoincount = 0
	marioscore = 0
	
	--get mariolives and physics
	mariolivecount = 3
	currentphysics = 1
	camerasetting = 1
	dropshadow = false
	realtime = false
	continuesublevelmusic = false
	nolowtime = false
	nocoinlimit = false
	setphysics(1)
	if not dcplaying then
		loadmappacksettings()
	end

	updatemappacksettings()
	
	autoscroll = true
	autoscrollx = true
	autoscrolly = true
	
	inputs = { "door", "groundlight", "wallindicator", "cubedispenser", "walltimer", "notgate", "laser", "lightbridge", "delayer", "funnel", "portal1", "portal2", "text", "geldispenser", "tiletool", "enemytool", "randomizer", "musicchanger", "rocketturret", "checkpoint", "emancipationgrill", "belt", "animationtrigger", "faithplate", "animatedtiletrigger", "orgate", "andgate", "rsflipflop", "kingbill", "platform", "collectable", "skewer", "energylauncher", "camerastop", "laserfields", "track", "animationtrigger", "snakeblock", "risingwater", "trackswitch" }
	inputsi = {28, 29, 30, 43, 44, 45, 46, 47, 48, 67, 74, 84, 49, 50, 51, 52, 53, 54, 55, 36, 37, 38, 39, 186, 198, 197, 199, 61, 62, 63, 64, 65, 66, 71, 72, 73, 181, 182, 183, 201, 205, 206, 210, 194, 225, 226, 227, 229, 230, 231, 232, 100, 26, 27, 266, 271, 273, 274, 272, 105, 163, 248, 249, 18, 19, 259, 166, 167, 168, 169, 304, 309, 311, 306, 270, 317, 290, 285}
	
	outputs = { "button", "laserdetector", "box", "pushbutton", "walltimer", "notgate", "energycatcher", "squarewave", "delayer", "regiontrigger", "randomizer", "tiletool", "orgate", "andgate", "rsflipflop", "flipblock", "doorsprite", "collectablelock", "collectable", "animationoutput" }
	outputsi = {40, 56, 57, 58, 59, 20, 68, 69, 74, 84, 165, 170, 171, 172, 173, 185, 186, 200, 206, 201, 222, 267, 268, 273, 274, 272, 275, 163, 248, 249, 277, 276, 291}
	
	--purpose of enemies table:

	--carried by platforms and such
	--killed by blocks below
	--granted despawning immunity when mario goes through doors
	--killed by rainboom
	--deep copied by regiontrigger
	enemies = { "goomba", "koopa", "hammerbro", "plant", "lakito", "bowser", "cheep", "squid", "flyingfish", "cheepwhite", "cheepred", "beetle", "spikey",
		"sidestepper", "barrel", "icicle", "angrysun", "splunkin", "firebro", "fishbone", "drybones", "muncher", "bigbeetle", "meteor",
		"boomerangbro", "ninji", "boo", "mole", "bigmole", "bomb", "bombhalf", "torpedoted", "parabeetle", "parabeetleright", "boomboom",
		"pinksquid", "shell", "shyguy", "beetleshell", "spiketop",  "pokey", "snowpokey", "fighterfly", "chainchomp", "rockywrench", "tinygoomba", "koopaling", "bowser3", "icebro",
		"squidnanny", "goombashoe", "wiggler", "magikoopa", "spike", "spikeball", "plantcreeper"}
	--aren't spawned when player at checkpoint
	checkpointignoreenemies = { "goomba", "koopa", "hammerbro", "plant", "lakito", "bowser", "cheep", "squid", "flyingfish", "goombahalf", "koopahalf", "cheepwhite", "cheepred", "koopared", "kooparedhalf", "kooparedflying", "beetle", "beetlehalf", "spikey", "spikeyhalf", "downplant", "paragoomba", "sidestepper", "barrel", "icicle", "angrysun", "splunkin", "biggoomba", "firebro", "redplant", "reddownplant", "fishbone", "drybones", "muncher", "dryboneshalf", "bigbeetle", "meteor", "drygoomba", "dryplant", "drydownplant", "boomerangbro", "ninji", "boo", "mole", "bigmole", "bomb", "bombhalf", "fireplant", "downfireplant", "torpedoted", "parabeetle", "parabeetleright", "boomboom", "koopablue", "koopabluehalf", "pinksquid", "shell", "shyguy", "shyguyhalf", "beetleshell", "spiketop", "spiketophalf", "pokey", "snowpokey", "fighterfly", "chainchomp", "bighammerbro", "rockywrench", "tinygoomba", "koopaling", "bowser3", "icebro", "squidnanny", "goombashoe", "wiggler", "magikoopa", "spike", "spikeball", "plantcreeper"}
	
	jumpitems = { "mushroom", "oneup", "poisonmush" , "threeup"}
	
	marioworld = 1
	mariolevel = 1	
	mariosublevel = 0
	respawnsublevel = 0
	checkpointsublevel = false
	
	objects = nil
	if suspended == true then
		continuegame()
		loadmappacksettings()
		updatemappacksettings()
	elseif suspended then
		marioworld = suspended
	end
	
	--remove custom sprites
	for i = smbtilecount+portaltilecount+1, #tilequads do
		tilequads[i] = nil
	end
	
	for i = smbtilecount+portaltilecount+1, #rgblist do
		rgblist[i] = nil
	end
	
	--add custom tiles
	local bla = love.timer.getTime()
	if not dcplaying and love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/tiles.png") then
		loadtiles("custom")
		customtiles = true
	else
		customtiles = false
		customtilecount = 0
	end
	print("Custom tileset loaded in: " .. round(love.timer.getTime()-bla, 5))
	
	smbspritebatch = {}
	portalspritebatch = {}
	customspritebatch = {}
	spritebatchX = {}
	spritebatchY = {}
	for i = 1, 2 do
		smbspritebatch[i] = love.graphics.newSpriteBatch( smbtilesimg, maxtilespritebatchsprites )
		portalspritebatch[i] = love.graphics.newSpriteBatch( portaltilesimg, maxtilespritebatchsprites )
		if customtiles then
			customspritebatch[i] = {}
			for i2 = 1, #customtilesimg do
				customspritebatch[i][i2] = love.graphics.newSpriteBatch( customtilesimg[i2], maxtilespritebatchsprites )
			end
		end
		
		spritebatchX[i] = 0
		spritebatchY[i] = 0
	end
	
	portaldotspritebatch = love.graphics.newSpriteBatch(portaldotimg, 1000, "dynamic" )
	portalprojectilespritebatch = love.graphics.newSpriteBatch(portalprojectileparticleimg, 1000, "dynamic" )
	
	custommusic = false

	--hide android controls
	if android and not androidHIDE then
		local hide = true
		for i = 1, players do
			if controls[i] then
				for j, w in pairs(controls[i]) do
					if not (w[1] and w[1] == "joy") then
						hide = false
						break
					end
				end
			end
		end
		if hide then
			androidHIDE = true
		end
	end
	
	--send chat ingame
	if SERVER or CLIENT then
		guielements = {}
		guielements.chatentry = guielement:new("input", 4, 207, 43+7/8, sendchat, "", 43)
		guielements.sendbutton = guielement:new("button", 359, 207, "send", sendchat, 1)
		guielements.chatentry.active = false
		guielements.sendbutton.active = false
		chatentrytoggle = false
	end
	
	--FINALLY LOAD THE DAMN LEVEL
	enemies_load()
	if dcplaying then
		levelscreen_load("dc")
	else
		levelscreen_load("initial")
	end
end

function game_update(dt)
	--------
	--GAME--
	--------
	
	--pausemenu
	if pausemenuopen and not (SERVER or CLIENT) then
		--joystick navigation
		local s1 = controls[1]["right"]
		local s2 = controls[1]["left"]
		local s3 = controls[1]["down"]
		local s4 = controls[1]["up"]
		if s1[1] == "joy" then
			if checkkey(s1,1,"right") then
				if not oldjoystick[1] then
					game_keypressed("right")
					oldjoystick[1] = true
				end
			else
				oldjoystick[1] = false
			end
		end
		if s2[1] == "joy" then
			if checkkey(s2,1,"left") then
				if not oldjoystick[2] then
					game_keypressed("left")
					oldjoystick[2] = true
				end
			else
				oldjoystick[2] = false
			end
		end
		if s3[1] == "joy" then
			if checkkey(s3,1,"down") then
				if not oldjoystick[3] then
					game_keypressed("down")
					oldjoystick[3] = true
				end
			else
				oldjoystick[3] = false
			end
		end
		if s4[1] == "joy" then
			if checkkey(s4,1,"up") then
				if not oldjoystick[4] then
					game_keypressed("up")
					oldjoystick[4] = true
				end
			else
				oldjoystick[4] = false
			end
		end
		return
	end
	
	--animationS
	animationsystem_update(dt)
	
	--earthquake reset
	if earthquake > 0 then
		earthquake = math.max(0, earthquake-dt*earthquake*2-0.001)
		sunrot = sunrot + dt
	end
	
	--animate animated tiles because I say so
	for i = 1, #animatedtiles do
		animatedtiles[i]:update(dt)
	end

	for i = 1, #animatedtimerlist do
		animatedtimerlist[i]:update(dt)
	end

	updatecustombackgrounds(dt)
	
	--coinanimation
	coinanimation = coinanimation + dt*6.75
	while coinanimation >= 6 do
		coinanimation = coinanimation - 5
	end	
	
	coinframe = math.max(1, math.floor(coinanimation))

	flaganimation = ((flaganimation-1 + dt*8)%4)+1
	
	--SCROLLING SCORES
	local delete
	for i, v in pairs(scrollingscores) do
		if scrollingscores[i]:update(dt) == true then
			if not delete then delete = {} end
			table.insert(delete, i)
		end
	end
	if delete then
		table.sort(delete, function(a,b) return a>b end)
		for i, v in pairs(delete) do
			table.remove(scrollingscores, v) --remove
		end
	end
	
	--If everyone's dead, just update the players and coinblock timer.
	if everyonedead then
		for i, v in pairs(objects["player"]) do
			v:update(dt)
		end
		
		return
	end
	
	--check if updates are blocked for whatever reason
	if noupdate then
		for i, v in pairs(objects["checkpointflag"]) do
			v:update(dt)
		end
		for i, v in pairs(objects["player"]) do
			v:update(dt)
		end
		return
	end
	
	--timer	
	if editormode == false then
		--get if any player has their controls disabled
		local notime = false
		for i = 1, players do
			if (objects["player"][i].controlsenabled == false and objects["player"][i].dead == false and objects["player"][i].groundfreeze == false) then
				notime = true
			end
		end
		
		if (notime == false or breakoutmode) and infinitetime == false and mariotime ~= 0 then
			if realtime then --mario maker time
				mariotime = mariotime - dt --mario maker purists rejoice
			else
				mariotime = mariotime - 2.5*dt
			end
			
			if queuelowtime then
				queuelowtime = queuelowtime - 2.5*dt
			end
			if mariotime > 0 and mariotime + 2.5*dt >= 99 and mariotime < 99 and (not dcplaying) and (not levelfinished) and not nolowtime then
				startlowtime()
			end
			
			if queuelowtime and queuelowtime < 0 and (not levelfinished) then
				local star = false
				for i = 1, players do
					if objects["player"][i].starred then
						star = true
					end
				end
				
				if pbuttonsound:isPlaying() then
					pbuttonsound:setVolume(1)
				else
					if not star then
						playmusic()
					else
						music:play("starmusic")
					end
				end
				queuelowtime = false
			end
			
			if mariotime <= 0 then
				mariotime = 0
				for i, v in pairs(objects["player"]) do
					v:die("time")
				end
			end
		end
	end

	--Portaldots
	portaldotstimer = portaldotstimer + dt
	while portaldotstimer > portaldotstime do
		portaldotstimer = portaldotstimer - portaldotstime
	end
	
	--portalgundelay
	for i = 1, players do
		if portaldelay[i] > 0 then
			portaldelay[i] = math.max(0, portaldelay[i] - dt/speed)
		end
	end
	
	--coinblockanimation
	local delete
	for i, v in pairs(coinblockanimations) do
		if coinblockanimations[i]:update(dt) == true then
			if not delete then delete = {} end
			table.insert(delete, i)
		end
	end
	if delete then
		table.sort(delete, function(a,b) return a>b end)
		for i, v in pairs(delete) do
			table.remove(coinblockanimations, v) --remove
		end
	end
	
	--nothing to see here
	local delete
	for i, v in pairs(rainbooms) do
		if v:update(dt) == true then
			if not delete then delete = {} end
			table.insert(delete, i)
		end
	end
	if delete then
		table.sort(delete, function(a,b) return a>b end)
		for i, v in pairs(delete) do
			table.remove(rainbooms, v) --remove
		end
	end
	
	--userects
	local delete
	for i, v in pairs(userects) do
		if v.delete == true then
			if not delete then delete = {} end
			table.insert(delete, i)
		end
	end
	if delete then
		table.sort(delete, function(a,b) return a>b end)
		for i, v in pairs(delete) do
			table.remove(userects, v) --remove
		end
	end
	
	--blockbounce
	local delete
	for i, v in pairs(blockbounce) do
		if v.timer < 0 then
			if v.timer > -blockbouncetime then
				v.timer = v.timer - dt
				if v.timer < -blockbouncetime then
					v.timer = -blockbouncetime
					if v.content then
						item(v.content, v.x, v.y, v.content2)
					end
					if not delete then delete = {} end
					table.insert(delete, i)
				end
			end
		else
			if v.timer < blockbouncetime then
				v.timer = v.timer + dt
				if v.timer > blockbouncetime then
					v.timer = blockbouncetime
					if v.content then
						item(v.content, v.x, v.y, v.content2)
					end
					if not delete then delete = {} end
					table.insert(delete, i)
				end
			end
		end
	end
	if delete then
		for i, v in pairs(delete) do
			blockbounce[v] = nil
		end
		if #delete >= 1 then
			generatespritebatch()
		end
	end
	
	--coinblocktimer things
	for i, v in pairs(coinblocktimers) do
		if v[3] > 0 then
			v[3] = v[3] - dt
		end
	end
	
	--blockdebris
	local delete
	for i, v in pairs(blockdebristable) do
		if v:update(dt) == true then
			if not delete then delete = {} end
			table.insert(delete, i)
		end
	end
	if delete then
		table.sort(delete, function(a,b) return a>b end)
		for i, v in pairs(delete) do
			table.remove(blockdebristable, v) --remove
		end
	end
	
	--gelcannon
	if not editormode then
		if objects["player"][mouseowner] and (playertype == "gelcannon" or objects["player"][mouseowner].portals == "gel") and objects["player"][mouseowner].controlsenabled then
			if gelcannontimer > 0 then
				gelcannontimer = gelcannontimer - dt
				if gelcannontimer < 0 then
					gelcannontimer = 0
				end
			else
				if love.mouse.isDown("l") then
					gelcannontimer = gelcannondelay
					objects["player"][mouseowner]:shootgel(1)
				elseif love.mouse.isDown("r") then
					gelcannontimer = gelcannondelay
					objects["player"][mouseowner]:shootgel(2)
				elseif love.mouse.isDown("m") or love.mouse.isDown("wd") or love.mouse.isDown("wu") or love.mouse.isDown("x1") then
					gelcannontimer = gelcannondelay
					objects["player"][mouseowner]:shootgel(4)
				elseif love.mouse.isDown("x2") then
					gelcannontimer = gelcannondelay
					objects["player"][mouseowner]:shootgel(3)
				end
			end
		end
	end

	--make lights have a slight wave
	if lightsout then
		lightsoutwave = (lightsoutwave + dt)%0.2
	end
	
	--dialog boxes
	for i, v in pairs(dialogboxes) do
		v:update(dt)
	end
	
	--seesaws
	for i, v in pairs(seesaws) do
		v:update(dt)
	end
	
	--platformspawners
	for i, v in pairs(platformspawners) do
		v:update(dt)
	end
	
	--Bubbles
	local delete
	for i, v in pairs(bubbles) do
		if v:update(dt) == true then
			if not delete then delete = {} end
			table.insert(delete, i)
		end
	end
	if delete then
		table.sort(delete, function(a,b) return a>b end)
		for i, v in pairs(delete) do
			table.remove(bubbles, v) --remove
		end
	end
	
	--Poofs
	local delete
	for i, v in pairs(poofs) do
		if v:update(dt) == true then
			if not delete then delete = {} end
			table.insert(delete, i)
		end
	end
	if delete then
		table.sort(delete, function(a,b) return a>b end)
		for i, v in pairs(delete) do
			table.remove(poofs, v) --remove
		end
	end
	
	--Miniblocks
	local delete
	for i, v in pairs(miniblocks) do
		if v:update(dt) == true then
			if not delete then delete = {} end
			table.insert(delete, i)
		end
	end
	if delete then
		table.sort(delete, function(a,b) return a>b end)
		for i, v in pairs(delete) do
			table.remove(miniblocks, v) --remove
		end
	end
	
	--Emancipation Fizzle
	local delete
	for i, v in pairs(emancipationfizzles) do
		if v:update(dt) == true then
			if not delete then delete = {} end
			table.insert(delete, i)
		end
	end
	if delete then
		table.sort(delete, function(a,b) return a>b end)
		for i, v in pairs(delete) do
			table.remove(emancipationfizzles, v) --remove
		end
	end
	
	--Emancipation Animations
	local delete
	for i, v in pairs(emancipateanimations) do
		if v:update(dt) == true then
			if not delete then delete = {} end
			table.insert(delete, i)
		end
	end
	if delete then
		table.sort(delete, function(a,b) return a>b end)
		for i, v in pairs(delete) do
			table.remove(emancipateanimations, v) --remove
		end
	end
	
	--Fireworks
	local delete = {}
	
	for i, v in pairs(fireworks) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(fireworks, v) --remove
	end
	
	--EMANCIPATION GRILLS
	local delete = {}
	for i, v in pairs(emancipationgrills) do
		if v:update(dt) then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(emancipationgrills, v)
	end

	--LASER FIELDS
	local delete = {}
	for i, v in pairs(laserfields) do
		if v:update(dt) then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(laserfields, v)
	end
	
	--BULLET BILL LAUNCHERS
	local delete = {}
	for i, v in pairs(rocketlaunchers) do
		if v:update(dt) then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(rocketlaunchers, v)
	end
	
	--BIG BILL LAUNCHERS
	local delete = {}
	for i, v in pairs(bigbilllaunchers) do
		if v:update(dt) then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(bigbilllaunchers, v)
	end
	
	--KING BILL LAUNCHERS
	local delete = {}
	for i, v in pairs(kingbilllaunchers) do
		if v:update(dt) then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(kingbilllaunchers, v)
	end
	
	--CANNON LAUNCHERS
	local delete = {}
	for i, v in pairs(cannonballlaunchers) do
		if v:update(dt) then
			table.insert(delete, i)
		end
	end
	table.sort(delete, function(a,b) return a>b end)
	for i, v in pairs(delete) do
		table.remove(cannonballlaunchers, v)
	end
	
	--item animations
	local delete = {}
	for i, v in pairs(itemanimations) do
		if v:update(dt) or v.instantdelete then
			table.insert(delete, i)
		end
	end
	table.sort(delete, function(a,b) return a>b end)
	for i, v in pairs(delete) do
		table.remove(itemanimations, v)
	end

	--snake blocks
	local delete = {}
	for i, v in pairs(snakeblocks) do
		if v:update(dt) then
			table.insert(delete, i)
		end
	end
	table.sort(delete, function(a,b) return a>b end)
	for i, v in pairs(delete) do
		table.remove(snakeblocks, v)
	end
	--UPDATE OBJECTS
	local delete
	for i, v in pairs(objects) do
		if i ~= "tile" and i ~= "portalwall" and i ~= "screenboundary" and i ~= "coin" and i ~= "risingwater" and i ~= "clearpipesegment" and i ~= "tracksegment" and i ~= "funnel" and i ~= "clearpipe" then
			delete = nil
			for j, w in pairs(v) do
				if dropshadow and w.shot and w.rotation then
					if not w.dropshadowrotation then
						w.dropshadowrotation = w.rotation
					end
					w.dropshadowrotation = w.dropshadowrotation + w.speedx*2*dt
					w.rotation = w.dropshadowrotation
				end
				if w.instantdelete or (w.update and w:update(dt)) then
					w.delete = true
					if not delete then delete = {} end
					table.insert(delete, j)
				elseif w.autodelete then
					if (((w.x < xscroll - width) or (w.x > xscroll + width*4)) and not w.horautodeleteimmunity) or w.y > mapheight+1 or math.abs(w.y-yscroll) > height*5 then
						w.delete = true
						if w.autodeleted then
							w:autodeleted()
						end
						if not delete then delete = {} end
						table.insert(delete,j)
					end
				elseif w.extremeautodelete then
					if w.x > mapwidth+(w.extremeautodeletedist or 3) or w.x+w.width < -(w.extremeautodeletedist or 3) or w.y > mapheight+(w.extremeautodeletedist or 3) then
						w.delete = true
						if w.autodeleted then
							w:autodeleted()
						end
						if not delete then delete = {} end
						table.insert(delete,j)
					end
				end

				if stoptestinglevelsafe then
					--stop testing level without crashing
					--when an entity makes you go to a different level (glados)
					stoptestinglevelsafe = nil
					return
				end
			end
			
			if delete and #delete > 0 then
				table.sort(delete, function(a,b) return a>b end)
				
				for j, w in pairs(delete) do
					table.remove(v, w)
				end
			end
		end
	end
	--risingwater
	for i, v in pairs(objects["risingwater"]) do
		v:update(dt)
	end
	--funnel
	for i, v in pairs(objects["funnel"]) do
		v:update(dt)
	end
	--tracks
	for i, v in pairs(tracks) do
		v:update(dt)
	end

	--clear pipes
	local delete = {}
	for i, v in pairs(clearpipes) do
		if v:update(dt) then
			table.insert(delete, i)
		end
	end
	table.sort(delete, function(a,b) return a>b end)
	for i, v in pairs(delete) do
		table.remove(clearpipes, v)
	end

	--player custom enemy riding
	for i, v in pairs(objects["player"]) do
		if v.fireenemyride then
			local obj = v.fireenemyride
			if obj.delete then
				v.fireenemyride = nil
				v.fireenemyoffsetx = nil
				v.fireenemyoffsety = nil
				v.animationstate = "jumping"
				v.active = true
				v.speedx = obj.speedx or 0
				v.speedy = obj.speedy or 0
				v.fireenemydrawable = nil
				v.fireenemyanim = false
			else
				if obj.x and obj.y then
					v.x = obj.x + (v.fireenemyoffsetx or 0)
					v.y = obj.y + (v.fireenemyoffsety or 0)
					if v.ducking then
						if v.fireenemyduckingoffsetx then
							v.x = v.x + (v.fireenemyduckingoffsetx or 0)
						end
						if v.fireenemyduckingoffsety then
							v.y = v.y + (v.fireenemyduckingoffsety or 0)
						end
					end
					v.active = v.fireenemyactive
					if v.active then
						v.speedx = obj.speedx or 0
						v.speedy = obj.speedy or 0
						v.falling = obj.falling or true
					end
					if v.fireenemycopyquadi then
						v.fireenemyquadi = obj.quadi
					end
				end
			end
		end
	end

	--spawn animations
	local delete = {}
	for i, v in pairs(spawnanimations) do
		if v:update(dt) then
			v.delete = true
			table.insert(delete, i)
		end
	end
	table.sort(delete, function(a,b) return a>b end)
	for i, v in pairs(delete) do
		table.remove(spawnanimations, v)
	end
	
	--SCROLLING
	

	--HORIZONTAL
	
	local oldscroll = splitxscroll[1]
	
	if autoscroll and autoscrollx ~= false and not minimapdragging then
		local splitwidth = width/#splitscreen
		for split = 1, #splitscreen do
			local oldscroll = splitxscroll[split]
			--scrolling
			--LEFT
			local i = 1
			while i <= players and objects["player"][i].dead do
				i = i + 1
			end
			local fastestplayer = objects["player"][i]
			
			
			if fastestplayer then
				if not CLIENT and not SERVER then
					for i = 1, players do
						if not objects["player"][i].dead and objects["player"][i].x > fastestplayer.x then
							fastestplayer = objects["player"][i]
						end
					end
				end
				
				local oldscroll = splitxscroll[split]
				
				--LEFT

				if (not (autoscrollingx and not editormode)) and (camerasetting ~= 3 or editormode) then
					if fastestplayer.x < splitxscroll[split] + scrollingleftstart*screenzoom2 and splitxscroll[split] > 0 then
						if fastestplayer.x < splitxscroll[split] + scrollingleftstart*screenzoom2 and fastestplayer.speedx < 0 then
							if fastestplayer.speedx < -scrollrate then
								splitxscroll[split] = splitxscroll[split] - scrollrate*dt
							else
								splitxscroll[split] = splitxscroll[split] + fastestplayer.speedx*dt
							end
						end
					
						if fastestplayer.x < splitxscroll[split] + scrollingleftcomplete*screenzoom2 then
							splitxscroll[split] = splitxscroll[split] - scrollrate*dt
							if fastestplayer.x > splitxscroll[split] + scrollingleftcomplete*screenzoom2 then
								splitxscroll[split] = fastestplayer.x - scrollingleftcomplete*screenzoom2
							end
						end
					end
				end
				if autoscrollingx and not editormode then
					splitxscroll[split] = math.max(0, math.min(mapwidth-width*screenzoom2, splitxscroll[split] + autoscrollingx*dt))
				end
				
				--RIGHT
				
				if not (autoscrollingx and not editormode) then
					if fastestplayer.x > splitxscroll[split] + width*screenzoom2 - scrollingstart*screenzoom2 and splitxscroll[split] < mapwidth - width*screenzoom2 then
						if fastestplayer.x > splitxscroll[split] + width*screenzoom2 - scrollingstart*screenzoom2 and fastestplayer.speedx > 0.3 then
							if fastestplayer.speedx > scrollrate then
								splitxscroll[split] = splitxscroll[split] + scrollrate*dt
							else
								splitxscroll[split] = splitxscroll[split] + fastestplayer.speedx*dt
							end
						end
					
						if fastestplayer.x > splitxscroll[split] + width*screenzoom2 - scrollingcomplete*screenzoom2 then
							splitxscroll[split] = splitxscroll[split] + scrollrate*dt
							if splitxscroll[split] > fastestplayer.x - (width*screenzoom2 - scrollingcomplete*screenzoom2) then
								splitxscroll[split] = fastestplayer.x - (width*screenzoom2 - scrollingcomplete*screenzoom2)
							end
						end
					end
					if camerasetting == 3 then
						objects["screenboundary"]["left"].x = xscroll
					end
				end

				--just force that shit
				if not levelfinished and not (autoscrollingx and not editormode) then
					if fastestplayer.x > splitxscroll[split] + width*screenzoom2 - scrollingcomplete*screenzoom2 then
						splitxscroll[split] = splitxscroll[split] + superscroll*dt
						if fastestplayer.x < splitxscroll[split] + width*screenzoom2 - scrollingcomplete*screenzoom2 then
							splitxscroll[split] = fastestplayer.x - width*screenzoom2 + scrollingcomplete*screenzoom2
						end
					elseif fastestplayer.x < splitxscroll[split] + scrollingleftcomplete*screenzoom2 and (camerasetting ~= 3 or editormode) then
						splitxscroll[split] = splitxscroll[split] - superscroll*dt
						if fastestplayer.x > splitxscroll[split] + scrollingleftcomplete*screenzoom2 then
							splitxscroll[split] = fastestplayer.x - scrollingleftcomplete*screenzoom2
						end
					end
				end

				--CLAMP
				if splitxscroll[split] > mapwidth-width then
					splitxscroll[split] = math.max(0, mapwidth-width)
					hitrightside()
				end

				if (axex and splitxscroll[split] > axex-width and axex >= width) then
					splitxscroll[split] = axex-width
					hitrightside()
				end
				if splitxscroll[split] < 0 then
					splitxscroll[split] = 0
				end
			end
		end
		
	end
	
	
	--VERTICAL SCROLLING
	local oldscrolly = splityscroll[1]
	if autoscroll and autoscrolly ~= false and not minimapdragging then
		for split = 1, #splitscreen do
			local fastestplayer = 1
			while fastestplayer <= players and objects["player"][fastestplayer].dead do
				fastestplayer = fastestplayer + 1
			end
			if not CLIENT and not SERVER and objects["player"][fastestplayer] then
				if mapwidth <= width then
					for i = 1, players do
						if not objects["player"][i].dead and math.abs(starty-objects["player"][i].y) > math.abs(starty-objects["player"][fastestplayer].y) then
							fastestplayer = i
						end
					end
				else
					for i = 1, players do
						if not objects["player"][i].dead and objects["player"][i].x > objects["player"][fastestplayer].x then
							fastestplayer = i
						end
					end
				end
			end
			if mapheight > 15*screenzoom2 and objects["player"][fastestplayer] then
				if not (autoscrollingy and not editormode) then
					local px, py = objects["player"][fastestplayer].x, objects["player"][fastestplayer].y
					if objects["player"][fastestplayer].height > 2 then
						py = objects["player"][fastestplayer].y+objects["player"][fastestplayer].height/2
					end
					local pspeed = objects["player"][1].speedy
					if objects["player"][fastestplayer].oldy and pspeed == 0 and math.abs(objects["player"][fastestplayer].y-objects["player"][fastestplayer].oldy) < 3 then
						pspeed = (objects["player"][fastestplayer].y-objects["player"][fastestplayer].oldy)/dt
					end
					objects["player"][fastestplayer].oldy = objects["player"][fastestplayer].y
					
					local sx, sy = px-xscroll, py-yscroll--position on screen
					yscrolltarget = yscrolltarget or splityscroll[split]

					local upbound = 9*screenzoom2
					local downbound = 4*screenzoom2
					if camerasetting == 2 then
						upbound = 8*screenzoom2
						downbound = 6*screenzoom2
					end
					if speed == 0 then
						yscrolltarget = math.min(py-downbound, math.max(py-upbound, yscrolltarget))--(objects["player"][fastestplayer].y+objects["player"][fastestplayer].width/2)-(height/2)
					elseif sy > upbound then
						yscrolltarget = py-upbound
					elseif sy < downbound then
						yscrolltarget = py-downbound
					end

					local seeking = false
					local yscrolltarget = math.min(math.max(0, mapheight-height*screenzoom2-1), math.max(0, yscrolltarget))
					if objects["player"][fastestplayer].animationstate == "idle" then
						if objects["player"][fastestplayer].upkeytimer > seektime then
							yscrolltarget = yscrolltarget - seekrange
							yscrolltarget = math.min(math.max(0, mapheight-height*screenzoom2-1), math.max(0, yscrolltarget))
							seeking = true
						elseif objects["player"][fastestplayer].downkeytimer > seektime then
							yscrolltarget = yscrolltarget + seekrange
							yscrolltarget = math.min(math.max(0, mapheight-height*screenzoom2-1), math.max(0, yscrolltarget))
							seeking = true
						end
					end
					
					local diff = math.abs(splityscroll[split]-yscrolltarget)
					local speed = math.abs(pspeed)--scrollrate*(diff/1.5)+0.5 --math.min(superscrollrate)?
					if seeking then	
						speed = seekspeed
					elseif speed == 0 then--not objects["player"][fastestplayer].jumping and not objects["player"][fastestplayer].falling then
						if diff > 2.5 then
							speed = superscrollrate
						else
							speed = scrollrate
						end
					end
					if yscrolltarget > splityscroll[split] then
						splityscroll[split] = math.min(yscrolltarget, splityscroll[split] + speed*dt)
					elseif yscrolltarget < splityscroll[split] then
						splityscroll[split] = math.max(yscrolltarget, splityscroll[split] - speed*dt)
					end

					if splityscroll[split] > mapheight-height*screenzoom2-1 then
						splityscroll[split] = math.max(0, mapheight-height*screenzoom2-1)
					end
					
					if splityscroll[split] < 0 then
						splityscroll[split] = 0
					end
				elseif not editormode then
					--vertical autoscrolling
					splityscroll[split] = math.max(0, math.min(mapheight-height*screenzoom2-1, splityscroll[split] + autoscrollingy*dt))
				end
			end
		end
	end
	
	if players == 2 then
		--updatesplitscreen()
	end

	--camera pan x
	if xpan then
		xpantimer = xpantimer + dt
		if xpantimer >= xpantime then
			xpan = false
			xpantimer = xpantime
		end
		
		local i = xpantimer/xpantime
		
		xscroll = math.min(mapwidth-width, xpanstart + xpandiff*i)
		splitxscroll[1] = xscroll
	end
	
	--camera pan y
	if ypan then
		ypantimer = ypantimer + dt
		if ypantimer >= ypantime then
			ypan = false
			ypantimer = ypantime
		end
		
		local i = ypantimer/ypantime
		
		yscroll = math.min(mapheight-height, ypanstart + ypandiff*i)
		splityscroll[1] = yscroll
	end

	for j, w in pairs(objects["camerastop"]) do
		w:collide(oldscroll, oldscrolly)
	end
	
	--SPRITEBATCH UPDATE and CASTLEREPEATS
	if math.floor(splitxscroll[1]) ~= spritebatchX[1] then
		if not editormode then
			for currentx = lastrepeat+1, math.floor(splitxscroll[1])+2 do
				lastrepeat = math.floor(currentx)
				--castlerepeat?
				--get mazei
				local mazei = 0
				
				for j = 1, #mazeends do
					if mazeends[j] < currentx+width then
						mazei = j
					end
				end
				
				--check if maze was solved!
				for i = 1, players do
					if objects["player"][i].mazevar == mazegates[mazei] then
						local actualmaze = 0
						for j = 1, #mazestarts do
							if objects["player"][i].x > mazestarts[j] then
								actualmaze = j
							end
						end
						mazesolved[actualmaze] = true
						for j = 1, players do
							objects["player"][j].mazevar = 0
						end
						break
					end
				end
				
				if not mazesolved[mazei] or mazeinprogress then --get if inside maze
					if not mazesolved[mazei] then
						mazeinprogress = true
					end
					
					local x = math.ceil(currentx)+width
					
					if repeatX == 0 then
						repeatX = mazestarts[mazei]
					end
					
					if repeatX and map[repeatX] then
						local t = {}
						for y = 1, mapheight do
							table.insert(t, {1})
						end
						table.insert(map, x, t)
						for y = 1, mapheight do
							for j = 1, #map[repeatX][y] do
								map[x][y][j] = map[repeatX][y][j]
							end
							--map[x][y"]["gels""] = {}
							map[x][y]["gels"] = map[repeatX][y]["gels"]
							map[x][y]["portaloverride"] = nil
							
							for cox = mapwidth, x, -1 do
								--move objects
								if objects["tile"][tilemap(cox, y)] then
									objects["tile"][tilemap(cox + 1, y)] = tile:new(cox, y-1, 1, 1, true)
									objects["tile"][tilemap(cox, y)] = nil
								end
							end
							
							--create object for block
							if tilequads[map[repeatX][y][1]].collision == true then
								objects["tile"][tilemap(x, y)] = tile:new(x-1, y-1, 1, 1, true)
							end

							--create pipe objects again
							if map[x][y][2] then
								local t = entityquads[map[x][y][2]].t
								if t == "warppipe" or t == "pipe" or t == "pipe2" or t == "pipespawn" or t == "pipespawndown" or t == "pipespawnhor" then
									loadentity(t, x, y, map[x][y], map[x][y][2])
								end
							end
						end
						mapwidth = mapwidth + 1
						repeatX = repeatX + 1
						if flagx then
							flagx = flagx + 1
							flagimgx = flagimgx + 1
							objects["screenboundary"]["flag"].x = objects["screenboundary"]["flag"].x + 1
						end
						
						if axex then
							axex = axex + 1
							objects["screenboundary"]["axe"].x = objects["screenboundary"]["axe"].x + 1
						end
						
						if firestartx then
							firestartx = firestartx + 1
						end
						
						objects["screenboundary"]["right"].x = objects["screenboundary"]["right"].x + 1
						
						--move mazestarts and ends
						for i = 1, #mazestarts do
							mazestarts[i] = mazestarts[i]+1
							mazeends[i] = mazeends[i]+1
						end
						
						--check for endblock
						local x = math.ceil(currentx)+width
						for y = 1, mapheight do
							if map[x][y][2] and entityquads[map[x][y][2]].t == "mazeend" then
								if mazesolved[mazei] then
									repeatX = mazestarts[mazei+1]
								end
								mazeinprogress = false
							end
						end
					end
					
					--reset thingie
					
					local x = math.ceil(currentx)+width-1
					for y = 1, mapheight do
						if map[x] and map[x][y] and map[x][y][2] and entityquads[map[x][y][2]].t == "mazeend" then
							for j = 1, players do
								objects["player"][j].mazevar = 0
							end
						end
					end
				end
			end
		end
		
		generatespritebatch()
		spritebatchX[1] = math.floor(splitxscroll[1])
		
		if editormode == false and splitxscroll[1] < mapwidth-width then
			local x1, x2 = math.ceil(prevxscroll)+math.ceil(width*screenzoom2)+1, math.floor(splitxscroll[1])+math.ceil(width*screenzoom2)+1
			if prevxscroll > splitxscroll[1] then --spawn enemies in both directions
				x1, x2 = math.floor(splitxscroll[1])+1, math.floor(prevxscroll)+1
			end
			for x = math.max(1, x1), math.min(mapwidth, x2) do
				for y = math.max(1, math.floor(splityscroll[1])+1), math.min(mapheight, math.ceil(splityscroll[1])+math.ceil(height*screenzoom2)+1+2) do
					spawnenemyentity(x, y)
				end
				if goombaattack then
					local randomtable = {}
					for y = 1, mapheight do
						table.insert(randomtable, y)
					end
					while #randomtable > 0 do
						local rand = math.random(#randomtable)
						if tilequads[map[x][randomtable[rand]][1]].collision then
							table.remove(randomtable, rand)
						else
							local n = math.random(1, 58)
							if n <= 40 then
								table.insert(objects["goomba"], goomba:new(x-.5, math.random(13)))
							elseif n <= 46 then
								table.insert(objects["goomba"], goomba:new(x-.5, math.random(13), "goombrat"))
							elseif n <= 50 then
								table.insert(objects["goomba"], goomba:new(x-.5, math.random(13), "biggoomba"))
							elseif n <= 51 then
								table.insert(objects["goomba"], goomba:new(x-.5, math.random(13), "drygoomba"))
							elseif n <= 54 then
								table.insert(objects["goomba"], goomba:new(x-.5, math.random(13), "paragoomba"))
							elseif n <= 58 then
								table.insert(objects["goomba"], goomba:new(x-.5, math.random(13), "tinygoomba"))
							end
							break
						end
					end
				end
			end
		end
	end
	if math.floor(splityscroll[1]) ~= spritebatchY[1] then
		generatespritebatch()
		spritebatchY[1] = math.floor(splityscroll[1])
		if editormode == false then
			for x = math.max(1, math.floor(splitxscroll[1])+1), math.min(mapwidth, math.ceil(splitxscroll[1])+math.ceil(width*screenzoom2)+1) do
				local y1, y2 = math.floor(splityscroll[1])+1, math.floor(prevyscroll)+1
				if prevyscroll < splityscroll[1] then
					y1, y2 = math.floor(prevyscroll)+1+math.ceil(height*screenzoom2)+2, math.floor(splityscroll[1])+1+math.ceil(height*screenzoom2)+2
				end
				for y = math.max(1, y1), math.min(mapheight, y2) do
					spawnenemyentity(x, y)
				end
			end
		end
	end
	prevxscroll = splitxscroll[1]
	prevyscroll = splityscroll[1]

	--portal update
	for i, v in pairs(portals) do
		v:update(dt)
	end
	
	--portal particles
	portalparticletimer = portalparticletimer + dt
	while portalparticletimer > portalparticletime do
		portalparticletimer = portalparticletimer - portalparticletime
		
		for i, v in pairs(portals) do
			if v.facing1 and v.x1 and v.y1 then
				local x1, y1
				
				if v.facing1 == "up" then
					x1 = v.x1 + math.random(1, 30)/16-1
					y1 = v.y1-1
				elseif v.facing1 == "down" then
					x1 = v.x1 + math.random(1, 30)/16-2
					y1 = v.y1
				elseif v.facing1 == "left" then
					x1 = v.x1-1
					y1 = v.y1 + math.random(1, 30)/16-2
				elseif v.facing1 == "right" then
					x1 = v.x1
					y1 = v.y1 + math.random(1, 30)/16-1
				end
				
				table.insert(portalparticles, portalparticle:new(x1, y1, v.portal1color, v.facing1))
			end
			
			if v.facing2 ~= nil and v.x2 and v.y2 then
				local x2, y2
				
				if v.facing2 == "up" then
					x2 = v.x2 + math.random(1, 30)/16-1
					y2 = v.y2-1
				elseif v.facing2 == "down" then
					x2 = v.x2 + math.random(1, 30)/16-2
					y2 = v.y2
				elseif v.facing2 == "left" then
					x2 = v.x2-1
					y2 = v.y2 + math.random(1, 30)/16-2
				elseif v.facing2 == "right" then
					x2 = v.x2
					y2 = v.y2 + math.random(1, 30)/16-1
				end
				
				table.insert(portalparticles, portalparticle:new(x2, y2, v.portal2color, v.facing2))
			end
		end
	end
	
	delete = {}
	
	for i, v in pairs(portalparticles) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(portalparticles, v) --remove
	end
	
	--PORTAL PROJECTILES
	delete = {}
	
	for i, v in pairs(portalprojectiles) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(portalprojectiles, v) --remove
	end
	
	--FIRE SPAWNING
	if not levelfinished and firestarted and (not objects["bowser"]["boss"] or (objects["bowser"]["boss"].backwards == false and objects["bowser"]["boss"].shot == false and objects["bowser"]["boss"].fall == false 
		and objects["bowser"]["boss"].frozen == false)) then
		firetimer = firetimer + dt
		while firetimer > firedelay do
			firetimer = firetimer - firedelay
			firedelay = math.random(4)
			local obj = fire:new(splitxscroll[1] + width, math.random(3)+7)
			if objects["bowser"]["boss"] and objects["bowser"]["boss"].supersized then
				supersizeentity(obj)
			end
			table.insert(objects["fire"], obj)
		end
	end
	
	--FLYING FISH
	if not levelfinished and flyingfishstarted then
		flyingfishtimer = flyingfishtimer + dt
		while flyingfishtimer > flyingfishdelay do
			flyingfishtimer = flyingfishtimer - flyingfishdelay
			flyingfishdelay = math.random(6, 20)/10
			table.insert(objects["flyingfish"], flyingfish:new())
		end
	end
	
	--METEORS
	if not levelfinished and meteorstarted then
		meteortimer = meteortimer + dt
		while meteortimer > meteordelay do
			meteortimer = meteortimer - meteordelay
			meteordelay = meteordelays[math.random(1,#meteordelays)]
			if #objects["meteor"] > maxmeteors then
				break
			else
				table.insert(objects["meteor"], meteor:new())
			end
		end
	end
	
	--BULLET BILL
	if not levelfinished and bulletbillstarted then
		bulletbilltimer = bulletbilltimer + dt
		while bulletbilltimer > bulletbilldelay do
			bulletbilltimer = bulletbilltimer - bulletbilldelay
			bulletbilldelay = math.random(5, 40)/10
			table.insert(objects["bulletbill"], bulletbill:new(splitxscroll[1]+width+2, yscroll+math.random(4, 12), "left"))
		end
	end
	
	--NEUROTOXIN
	if not levelfinished and neurotoxin then
		toxintime = toxintime - dt
		if toxintime <= 0 then
			for i, v in pairs(objects["player"]) do
				v:die("time")
			end
			toxintime = 0
		end
	end
	
	--WIND
	if windstarted and (not levelfinished) then
		if not windsound:isPlaying() then --couldn't find a wind sound!!! 11/14/2015 went to the level myself and got the sound (with a beat on it but oh well)
			playsound(windsound)
		end
		local dist = windentityspeed*dt
		for i = 1, players do
			local p = objects["player"][i]
			if (not p.static) and p.active and (not (p.x < 0.1 and p.speedx > 0)) and (not (p.x > mapwidth-p.width-0.1 and p.speedx < 0)) and (not p.vine) and (not p.fence) then
				if not checkintile(p.x+dist, p.y, p.width, p.height, tileentitieswind, p, "ignorehorplatforms") then
					p.x = p.x + dist
				end
			end
		end
		--make leafs apear
		windleaftimer = windleaftimer + dt
		while windleaftimer > 0.03 do
			windleaftimer = windleaftimer - 0.03
			for i = 1, math.random(1, 2) do
				local startx = 0
				if windentityspeed < 0 then
					startx = width
				end
				local addx, addy = (math.random()*width), 0
				if math.random(1, 2) == 1 then
					addx, addy = startx, (math.random()*height)
				end
				table.insert(objects["windleaf"], windleaf:new(xscroll+addx-1, yscroll+addy-1))
			end
		end
	elseif #objects["windleaf"] > 0 then
		for j, w in pairs(objects["windleaf"]) do
			w.delete = true
		end
		windsound:stop()
	end
	
	--minecraft stuff
	if breakingblockX then
		if not objects["tile"][tilemap(breakingblockX, breakingblockY)] then
			breakingblockprogress = breakingblockprogress + dt*0.2
		else
			breakingblockprogress = breakingblockprogress + dt
		end
		if breakingblockprogress > minecraftbreaktime then
			breakblock(breakingblockX, breakingblockY)
			breakingblockX = nil
		end
	end
	
	--daily challenge win check
	if dcplaying then
		if checkdcwin(dt) then
			return
		end
	end
	
	--Editor
	if editormode then
		editor_update(dt)
	end
	
	--PHYSICS
	physicsupdate(dt)

	if queuespritebatchupdate then
		updatespritebatch()
	end
end

--the sole local variable
local clearpipesegmentdrawqueue = {}

function game_draw()
	for split = 1, #splitscreen do
		love.graphics.push()
		love.graphics.translate((split-1)*width*16*scale/#splitscreen, yoffset*scale)
		love.graphics.scale(screenzoom,screenzoom)
		
		--This is just silly
		if earthquake > 0 and sonicrainboom and #objects["glados"] == 0 then
			local colortable = {{242/255, 111/255, 51/255}, {251/255, 244/255, 174/255}, {95/255, 186/255, 76/255}, {29/255, 151/255, 212/255}, {101/255, 45/255, 135/255}, {238/255, 64/255, 68/255}}
			for i = 1, backgroundstripes do
				local r, g, b = unpack(colortable[math.fmod(i-1, 6)+1])
				local a = earthquake/rainboomearthquake
				
				love.graphics.setColor(r, g, b, a)
				
				local alpha = math.rad((i/backgroundstripes + math.fmod(sunrot/5, 1)) * 360)
				local point1 = {width*8*scale+300*scale*math.cos(alpha), 112*scale+300*scale*math.sin(alpha)}
				
				alpha = math.rad(((i+1)/backgroundstripes + math.fmod(sunrot/5, 1)) * 360)
				local point2 = {width*8*scale+300*scale*math.cos(alpha), 112*scale+300*scale*math.sin(alpha)}
				
				love.graphics.polygon("fill", width*8*scale, 112*scale, point1[1], point1[2], point2[1], point2[2])
			end
		end
		
		love.graphics.setColor(1, 1, 1, 1)
		--tremoooor!
		if earthquake > 0 and not pausemenuopen then
			tremorx = (math.random()-.5)*2*earthquake*scale
			tremory = (math.random()-.5)*2*earthquake*scale
			
			love.graphics.translate(round(tremorx), round(tremory))
		end
		
		--[[local currentscissor = {(split-1)*width*16*scale/#splitscreen, 0, width*16*scale/#splitscreen, height*16*scale}
		love.graphics.setScissor(unpack(currentscissor))]]
		currentscissor = {}
		xscroll = splitxscroll[split]
		yscroll = splityscroll[split]
		if screenzoom ~= 1 then
			xscroll = math.floor(xscroll*16)/16
			yscroll = math.floor(yscroll*16)/16
		end
	
		love.graphics.setColor(1, 1, 1, 1)
		
		local xfromdraw,xtodraw, yfromdraw,ytodraw, xoff,yoff = getdrawrange(xscroll,yscroll)
		
		--custom background
		rendercustombackground(xscroll, yscroll, scrollfactor, scrollfactory)

		--BACKGROUND TILES
		if bmap_on then
			if editormode then
				love.graphics.setColor(1,1,1,100/255)
			else
				love.graphics.setColor(1,1,1,1)
			end
			love.graphics.draw(smbspritebatch[2], math.floor((-(xoff-math.floor(xscroll))*16)*scale), math.floor((-(yoff-math.floor(yscroll))*16)*scale))
			love.graphics.draw(portalspritebatch[2], math.floor((-(xoff-math.floor(xscroll))*16)*scale), math.floor((-(yoff-math.floor(yscroll))*16)*scale))
			if customtiles then
				for i = 1, #customspritebatch[2] do
					love.graphics.draw(customspritebatch[2][i], math.floor((-(xoff-math.floor(xscroll))*16)*scale), math.floor((-(yoff-math.floor(yscroll))*16)*scale))
				end
			end
			if animatedtilecount and animatedtilecount > 0 then
				for y = 1, ytodraw do
					for x = 1, xtodraw do
						local backgroundtile = bmapt(math.floor(xscroll)+x, math.floor(yscroll)+y, 1)
						if backgroundtile and backgroundtile > 90000 and tilequads[backgroundtile] and not tilequads[backgroundtile].invisible then
							love.graphics.draw(tilequads[backgroundtile].image, tilequads[backgroundtile].quad, math.floor((x-1-math.fmod(xscroll, 1))*16*scale), math.floor(((y-1-math.fmod(yscroll, 1))*16-8)*scale), 0, scale, scale)
						end
					end
				end
			end
			love.graphics.setColor(1,1,1,1)
		end

		--DROP SHADOW
		if dropshadow and not _3DMODE then
			love.graphics.push()
			love.graphics.translate(3*scale, 3*scale)
			love.graphics.setColor(dropshadowcolor)
			love.graphics.draw(smbspritebatch[1], math.floor((-(xoff-math.floor(xscroll))*16)*scale), math.floor((-(yoff-math.floor(yscroll))*16)*scale))
			love.graphics.draw(portalspritebatch[1], math.floor((-(xoff-math.floor(xscroll))*16)*scale), math.floor((-(yoff-math.floor(yscroll))*16)*scale))
			if customtiles then
				for i = 1, #customspritebatch[1] do
					love.graphics.draw(customspritebatch[1][i], math.floor((-(xoff-math.floor(xscroll))*16)*scale), math.floor((-(yoff-math.floor(yscroll))*16)*scale))
				end
			end
			drawmaptiles("dropshadow", xscroll, yscroll)
			
			--OBJECTS
			for j, w in pairs(objects["tilemoving"]) do
				w:draw()
			end
			for j, w in pairs(objects["checkpointflag"]) do
				w:draw("drop")
			end
			for j, w in pairs(objects["spring"]) do
				w:draw()
			end
			for j, w in pairs(objects["smallspring"]) do
				w:draw()
			end
			for j, w in pairs(objects["door"]) do
				w:draw()
			end
			for j, w in pairs(objects["platform"]) do
				w:draw("drop")
			end
			for j, w in pairs(objects["belt"]) do
				w:draw()
			end
			for j, w in pairs(objects["collectable"]) do
				w:draw()
			end
			for j, w in pairs(objects["yoshi"]) do
				w:draw()
			end
			--[[for j, w in pairs(objects["redseesaw"]) do --has overlapping shadows
				w:draw()
			end]]
			for j, w in pairs(objects) do	
				if j ~= "tile" then
					for i, v in pairs(w) do
						if v.drawable and (not v.nodropshadow) then--and not v.drawback then
							love.graphics.setColor(dropshadowcolor)
							if j == "player" then
								drawplayer(v.playernumber, nil, nil, nil, nil, "dropshadow")
							else
								drawentity(j,w,i,v,currentscissor,true)
							end
						end
					end
				end
			end
			love.graphics.pop()
			love.graphics.setColor(1,1,1,1)
		end
		
		--Mushroom under tiles
		for j, w in pairs(objects["mushroom"]) do
			w:draw()
		end
		
		--Flowers under tiles
		for j, w in pairs(objects["flower"]) do
			w:draw()
		end
		
		--Oneup under tiles
		for j, w in pairs(objects["oneup"]) do
			w:draw()
		end
		
		--star tiles
		for j, w in pairs(objects["star"]) do
			w:draw()
		end

		--Poisonmush under tiles
		for j, w in pairs(objects["poisonmush"]) do
			w:draw()
		end

		--Threeupunder tiles
		for j, w in pairs(objects["threeup"]) do
			w:draw()
		end
		
		-- + Clock under tiles
		for j, w in pairs(objects["smbsitem"]) do
			w:draw()
		end
		
		--Hammersuit under tiles
		for j, w in pairs(objects["hammersuit"]) do
			w:draw()
		end
		
		--Frogsuit under tiles
		for j, w in pairs(objects["frogsuit"]) do
			w:draw()
		end
		
		--Yoshi egg under tiles
		for j, w in pairs(objects["yoshiegg"]) do
			w:draw()
		end
		
		--pbutton thing under tiles
		for j, w in pairs(objects["pbutton"]) do
			if w.inblock then
				w:draw()
			end
		end
		
		--castleflag
		if levelfinished and levelfinishtype == "flag" and showcastleflag then
			love.graphics.draw(castleflagimg, math.floor((flagx+6-xscroll)*16*scale), (flagy-7+10/16)*16*scale+(castleflagy-yscroll)*16*scale, 0, scale, scale) 
		end
		
		--itemanimations (custom enemies coming out of blocks)
		for j, w in pairs(itemanimations) do
			w:draw()
		end

		--risingwater under
		for j, w in pairs(objects["risingwater"]) do
			if not w.drawover then
				w:draw()
			end
		end
		
		--TILES
		if not _3DMODE then
			love.graphics.draw(smbspritebatch[1], math.floor((-(xoff-math.floor(xscroll))*16)*scale), math.floor((-(yoff-math.floor(yscroll))*16)*scale))
			love.graphics.draw(portalspritebatch[1], math.floor((-(xoff-math.floor(xscroll))*16)*scale), math.floor((-(yoff-math.floor(yscroll))*16)*scale))
			if customtiles then
				for i = 1, #customspritebatch[1] do
					love.graphics.draw(customspritebatch[1][i], math.floor((-(xoff-math.floor(xscroll))*16)*scale), math.floor((-(yoff-math.floor(yscroll))*16)*scale))
				end
			end

			local lmap = map
			drawmaptiles("main", xscroll, yscroll)
		end

		--Moving Tiles (tilemoving)
		for j, w in pairs(objects["tilemoving"]) do
			w:draw()
		end

		--OBJECTS
		for i, v in pairs(objects["enemy"]) do	
			if v.drawback and v.drawable then
				love.graphics.setColor(1, 1, 1)
				drawentity("enemy",nil,i,v,currentscissor)
			end
		end
		
		--conveyor belt
		love.graphics.setColor(1, 1, 1)
		for j, w in pairs(objects["belt"]) do
			w:draw()
		end
		
		--collectable
		love.graphics.setColor(1, 1, 1)
		for j, w in pairs(objects["collectable"]) do
			w:draw()
		end

		--[[frozen coin
		for j, w in pairs(objects["frozencoin"]) do
			w:draw()
		end]]
		
		--door sprites
		for j, w in pairs(objects["doorsprite"]) do
			w:draw()
		end

		--track switches
		for j, w in pairs(tracks) do
			w:draw()
		end

		--checkpoint flag
		for j, w in pairs(objects["checkpointflag"]) do
			w:draw()
		end

		--pow block
		for j, w in pairs(objects["powblock"]) do
			w:draw()
		end

		--snakeblock
		love.graphics.setColor(1, 1, 1)
		for j, w in pairs(objects["snakeblock"]) do
			w:draw()
		end

		--switch blocks
		--[[for j, w in pairs(objects["buttonblock"]) do
			w:draw()
		end]]

		--plantcreeper
		for j, w in pairs(objects["plantcreeper"]) do
			w:draw()
		end

		love.graphics.setColor(1, 1, 1)
		--Groundlights
		for j, w in pairs(objects["groundlight"]) do
			w:draw()
		end
		
		---UI
		if ((not darkmode and not lightsout) or editormode) and not hudsimple then
			love.graphics.scale(1/screenzoom,1/screenzoom)
			if hudvisible then
				drawHUD()
			end
			love.graphics.scale(screenzoom,screenzoom)
		end
		
		love.graphics.setColor(1, 1, 1)
		
		if players > 1 then
			drawmultiHUD()
		end
		
		love.graphics.setColor(1, 1, 1)
		--text
		for j, w in pairs(objects["text"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--vines
		for j, w in pairs(objects["vine"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--warpzonetext
		if displaywarpzonetext then
			properprint("welcome to warp zone!", (mapwidth-14-1/16-xscroll)*16*scale, (5.5-yscroll)*16*scale)
			for i, v in pairs(warpzonenumbers) do
				properprint(v[3], math.floor((v[1]-xscroll-1-9/16)*16*scale), (v[2]-3-yscroll)*16*scale)
			end
		end
		
		love.graphics.setColor(1, 1, 1)
		--platforms
		for j, w in pairs(objects["platform"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--platforms
		for j, w in pairs(objects["seesawplatform"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--seesaws
		for j, w in pairs(seesaws) do
			w:draw()
		end

		--red seesaws (these are the actual seesaws)
		for j, w in pairs(objects["redseesaw"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--springs
		for j, w in pairs(objects["spring"]) do
			w:draw()
		end

		--small spring
		for j, w in pairs(objects["smallspring"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)

		--rocket turret laser
		for j, w in pairs(objects["rocketturret"]) do
			w:draw()
		end
		
		--flag
		if flagx then
			if flagimg:getHeight() == 16 then
				love.graphics.draw(flagimg, math.floor((flagimgx-1-xscroll)*16*scale), ((flagimgy-yscroll)*16-8)*scale, 0, scale, scale)
			else
				love.graphics.draw(flagimg, flagquad[spriteset][math.floor(flaganimation)], math.floor((flagimgx-1-xscroll)*16*scale), ((flagimgy-yscroll)*16-8)*scale, 0, scale, scale)
			end
			if levelfinishtype == "flag" then
				properprint2(flagscore, math.floor((flagimgx+4/16-xscroll)*16*scale), ((14-flagimgy-yscroll+(flagy-13)*2)*16-8)*scale, 0, scale, scale)
			end
		end
		
		love.graphics.setColor(1, 1, 1)
		--axe
		if axex then
			love.graphics.draw(axeimg, axequads[spriteset][coinframe], math.floor((axex-1-xscroll)*16*scale), (axey-1.5-yscroll)*16*scale, 0, scale, scale)
			
			if showtoad then--marioworld ~= 8
				love.graphics.draw(toadimg, math.floor((mapwidth-7-xscroll)*16*scale), (11.0625-yscroll)*16*scale, 0, scale, scale)
			else
				love.graphics.draw(peachimg, math.floor((mapwidth-7-xscroll)*16*scale), (11.0625-yscroll)*16*scale, 0, scale, scale)
			end
		end
		
		love.graphics.setColor(1, 1, 1)
		--levelfinish text and toad
		if levelfinished and levelfinishtype == "castle" then
			if levelfinishedmisc2 == 1 then
				if levelfinishedmisc >= 1 then
					properprint(toadtext[1], math.floor(((mapwidth-8-xscroll-math.floor(#toadtext[1]/2)/2)*16-1)*scale), (4.5-yscroll)*16*scale)
				end
				if levelfinishedmisc == 2 then
					properprint(toadtext[2], math.floor(((mapwidth-8-xscroll-math.floor(#toadtext[2]/2)/2)*16-1)*scale), (6.5-yscroll)*16*scale) --say what
					properprint(toadtext[3], math.floor(((mapwidth-8-xscroll-math.floor(#toadtext[2]/2)/2)*16-1)*scale), (7.5-yscroll)*16*scale) --bummer.
				end
			else
				if levelfinishedmisc >= 1 then
					properprint(peachtext[1], math.floor(((mapwidth-8-xscroll-math.floor(#peachtext[1]/2)/2)*16-1)*scale), (4.5-yscroll)*16*scale)
				end
				if levelfinishedmisc >= 2 then
					properprint(peachtext[2], math.floor(((mapwidth-8-xscroll-math.floor(#peachtext[2]/2)/2)*16-1)*scale), (6-yscroll)*16*scale)
				end
				if levelfinishedmisc >= 3 then
					properprint(peachtext[3], math.floor(((mapwidth-8-xscroll-math.floor(#peachtext[3]/2)/2)*16-1)*scale), (7-yscroll)*16*scale)
				end
				if levelfinishedmisc >= 4 then
					properprint(peachtext[4], math.floor(((mapwidth-8-xscroll-math.floor(#peachtext[4]/2)/2)*16-1)*scale), (8.5-yscroll)*16*scale)
				end
				if levelfinishedmisc == 5 then
					properprint(peachtext[5], math.floor(((mapwidth-8-xscroll-math.floor(#peachtext[5]/2)/2)*16-1)*scale), (9.5-yscroll)*16*scale)
				end
			end
			
			if showtoad then--marioworld ~= 8
				love.graphics.draw(toadimg, math.floor((mapwidth-7-xscroll)*16*scale), (11.0625-yscroll)*16*scale, 0, scale, scale)
			else
				love.graphics.draw(peachimg, math.floor((mapwidth-7-xscroll)*16*scale), (11.0625-yscroll)*16*scale, 0, scale, scale)
			end
		end
		
		love.graphics.setColor(1, 1, 1)
		--Fireworks
		for j, w in pairs(fireworks) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--Buttons
		for j, w in pairs(objects["button"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--Pushbuttons
		for j, w in pairs(objects["pushbutton"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--portal gun pedestal
		for j, w in pairs(objects["pedestal"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--hardlight bridges
		for j, w in pairs(objects["lightbridgebody"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--laser
		for j, w in pairs(objects["laser"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--laserdetector
		for j, w in pairs(objects["laserdetector"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)

		--lightbridge
		for j, w in pairs(objects["lightbridge"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--Faithplates
		for j, w in pairs(objects["faithplate"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--turrets
		for j, w in pairs(objects["turret"]) do
			w:draw()
		end
		for j, w in pairs(objects["turretshot"]) do
			w:draw()
		end
		
		--yoshi
		love.graphics.setColor(1, 1, 1)
		for j, w in pairs(objects["yoshi"]) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--Bubbles
		for j, w in pairs(bubbles) do
			w:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		--miniblocks
		for i, v in pairs(miniblocks) do
			v:draw()
		end
		
		--emancipateanimations
		for i, v in pairs(emancipateanimations) do
			v:draw()
		end
		
		--emancipationfizzles
		for i, v in pairs(emancipationfizzles) do
			v:draw()
		end
		
		--chainchomp
		for j, w in pairs(objects["chainchomp"]) do
			w:draw()
		end

		--spikeball
		for j, w in pairs(objects["spikeball"]) do
			w:draw()
		end
		
		--skewer
		for j, w in pairs(objects["skewer"]) do
			w:draw()
		end
		
		--OBJECTS
		for j, w in pairs(objects) do	
			if j ~= "tile" then
				for i, v in pairs(w) do
					if v.drawable and not v.drawback then
						love.graphics.setColor(1, 1, 1)
						drawentity(j,w,i,v,currentscissor)
					end
				end
			end
		end
		
		love.graphics.setColor(1, 1, 1)
		
		--mario dk hammer
		for j, w in pairs(objects["player"]) do
			if w.drawable and w.dkhammer then
				local dir = 1
				if w.animationdirection == "left" then
					dir = -1
				end
				if w.dkhammerframe == 1 then
					love.graphics.draw(dkhammerimg, math.floor((w.x+(w.width/2)-xscroll)*16*scale), math.floor((w.y-1-(11/16)-yscroll)*16*scale), 0, dir*scale, scale, 8, 0)
				else
					if dir == 1 then
						love.graphics.draw(dkhammerimg, math.floor((w.x+w.width+.5-xscroll)*16*scale), math.floor((w.y+w.height-1-yscroll)*16*scale), math.pi/2, dir*scale, scale, 8, 8)
					else
						love.graphics.draw(dkhammerimg, math.floor((w.x-.5-xscroll)*16*scale), math.floor((w.y+w.height-1-yscroll)*16*scale), math.pi*1.5, dir*scale, scale, 8, 8)
					end
				end
			end
		end
		
		love.graphics.setColor(1, 1, 1)
		
		--[[regiontrigger
		for j, w in pairs(objects["regiontrigger"]) do
			w:draw()
		end]]

		
		--pipes
		--[[for j, w in pairs(pipes) do
			w:draw()
		end
		for j, w in pairs(exitpipes) do
			w:draw()
		end]]

		--Cannon ball cannon
		for j, w in pairs(objects["cannonballcannon"]) do
			w:draw()
		end
		
		--bowser
		for j, w in pairs(objects["bowser"]) do
			w:draw()
		end

		--clearpipes
		if #clearpipesegmentdrawqueue > 0 then
			--these used to be drawn on the foreground layer, but they would draw ontop of stuff they shouldn't
			for j, w in pairs(clearpipesegmentdrawqueue) do
				if objects["clearpipesegment"][w] then
					objects["clearpipesegment"][w]:draw()
				end
			end
			clearpipesegmentdrawqueue = {}
		end
		
		--Clear Pipe Debug
		for j, w in pairs(clearpipes) do
			w:draw()
		end
		love.graphics.setColor(1, 1, 1)

		--3D Mode
		if _3DMODE then
			for i = 16, -8, -1 do
				love.graphics.push()
				local color = {1, 1, 1, 1}--255-((i-1)*16)}
				love.graphics.translate(i*scale, i*scale)
				love.graphics.scale(1-(((2*scale)/(width*16*scale))*(i)), 1-(((2*scale)/(height*16*scale))*(i)))
				love.graphics.setColor(color)
				love.graphics.draw(smbspritebatch[1], math.floor((-math.fmod(xscroll, 1)*16)*scale), math.floor((-math.fmod(yscroll, 1)*16)*scale))
				love.graphics.draw(portalspritebatch[1], math.floor((-math.fmod(xscroll, 1)*16)*scale), math.floor((-math.fmod(yscroll, 1)*16)*scale))
				if customtiles then
					for i = 1, #customspritebatch[1] do
						love.graphics.draw(customspritebatch[1][i], math.floor((-math.fmod(xscroll, 1)*16)*scale), math.floor((-math.fmod(yscroll, 1)*16)*scale))
					end
				end
				if i > 8 then
					drawmaptiles("dropshadow", xscroll, yscroll)
				else
					drawmaptiles("collision", xscroll, yscroll)
				end
				
				--OBJECTS
				if i > 0 and i < 8 then
					for j, w in pairs(objects["tilemoving"]) do
						w:draw()
					end
					for j, w in pairs(objects) do	
						if j ~= "tile" then
							for i, v in pairs(w) do
								if v.drawable and (not v.nodropshadow) then--and not v.drawback then
									love.graphics.setColor(color)
									if j == "player" then
										drawplayer(v.playernumber, nil, nil, nil, nil)--, "dropshadow")
									else
										drawentity(j,w,i,v,currentscissor)
									end
								end
							end
						end
					end
				end
				love.graphics.pop()
			end
			love.graphics.setColor(1,1,1,1)
		end
		
		--lakito
		--[[for j, w in pairs(objects["lakito"]) do
			w:draw()
		end]]
		
		--angrysun
		for j, w in pairs(objects["angrysun"]) do
			w:draw()
		end

		--ice block
		for j, w in pairs(objects["ice"]) do
			w:draw()
		end

		
		--[[for j, w in pairs(objects["trackcontroller"]) do
			w:draw()
		end]]
		
		--torpedo ted launcher
		for j, w in pairs(objects["torpedolauncher"]) do
			w:draw()
		end
		
		--kingbill
		for j, w in pairs(objects["kingbill"]) do
			w:draw()
		end
		
		--excursion funnel
		for j, w in pairs(objects["funnel"]) do
			w:draw()
		end
		
		--Geldispensers
		for j, w in pairs(objects["geldispenser"]) do
			w:draw()
		end
		
		--Cubedispensers
		for j, w in pairs(objects["cubedispenser"]) do
			w:draw()
		end
		
		--Emancipationgrills
		for j, w in pairs(emancipationgrills) do
			w:draw()
		end

		--Laserfields
		for j, w in pairs(laserfields) do
			w:draw()
		end
		
		--Doors
		for j, w in pairs(objects["door"]) do
			w:draw()
		end

		--risingwater over
		for j, w in pairs(objects["risingwater"]) do
			if w.drawover then
				w:draw()
			end
		end
		
		--Wallindicators
		for j, w in pairs(objects["wallindicator"]) do
			w:draw()
		end
		
		--Walltimers
		for j, w in pairs(objects["walltimer"]) do
			w:draw()
		end
		
		--Notgates
		for j, w in pairs(objects["notgate"]) do
			w:draw()
		end
		
		--Orgates
		for j, w in pairs(objects["orgate"]) do
			w:draw()
		end
		
		--Andgates
		for j, w in pairs(objects["andgate"]) do
			w:draw()
		end

		--Animatedtiletrigger
		for j, w in pairs(objects["animatedtiletrigger"]) do
			w:draw()
		end

		--Gucci Flipflop
		for j, w in pairs(objects["rsflipflop"]) do
			w:draw()
		end
		
		--Squarewave
		for j, w in pairs(objects["squarewave"]) do
			w:draw()
		end
		
		--Delayers
		for j, w in pairs(objects["delayer"]) do
			w:draw()
		end
		
		--Randomizer
		for j, w in pairs(objects["randomizer"]) do
			w:draw()
		end
		
		--Musicchanger
		for j, w in pairs(objects["musicchanger"]) do
			w:draw()
		end
		
		--particles
		for j, w in pairs(portalparticles) do
			w:draw()
		end

		love.graphics.setColor(1, 1, 255)
		
		--portals
		for i, v in pairs(portals) do
			v:draw()
		end		
		
		
		--cappy
		for j, w in pairs(objects["cappy"]) do
			w:draw()
		end
		
		--draw collision (debug)
		if HITBOXDEBUG and (editormode or testlevel) then
			local lw = love.graphics.getLineWidth()
			love.graphics.setLineWidth(.5*scale)
			for i, v in pairs(objects) do
				for j, k in pairs(v) do
					if k.width then
						if xscroll >= k.x-width and k.x+k.width > xscroll then
							if k.active and not k.red then
								love.graphics.setColor(1, 1, 1)
							else
								love.graphics.setColor(1, 0, 0)
							end
							
							if k.SLOPE then
								local points = {0,k.y1, 1,k.y2, 1,1.05, 0,1.05}
								if k.UPSIDEDOWNSLOPE then
									points[5], points[6] = 1,-0.05
									points[7], points[8] = 0,-0.05
								end
								for i = 1, #points, 2 do
									points[i] = math.floor((points[i]+k.x-xscroll)*16*scale)+.5
									points[i+1] = math.floor((points[i+1]+k.y-yscroll-.5)*16*scale)+.5
								end
								love.graphics.polygon("line", unpack(points))
							elseif k.width <= 1/16 then
								love.graphics.rectangle("fill", math.floor((k.x-xscroll)*16*scale), math.floor((k.y-yscroll-.5)*16*scale), k.width*16*scale, k.height*16*scale)
							elseif incognito then
								love.graphics.rectangle("fill", math.floor((k.x-xscroll)*16*scale)+.5, math.floor((k.y-yscroll-.5)*16*scale)+.5, k.width*16*scale-1, k.height*16*scale-1)
							else
								love.graphics.rectangle("line", math.floor((k.x-xscroll)*16*scale)+.5, math.floor((k.y-yscroll-.5)*16*scale)+.5, k.width*16*scale-1, k.height*16*scale-1)
							end
							if k.killzonex then
								love.graphics.circle("line", math.floor((k.x+k.killzonex-xscroll)*16*scale)+.5, math.floor((k.y+k.killzoney-yscroll-.5)*16*scale)+.5, (math.sqrt(k.killzoner))*16*scale)
							end
							if k.playerneardist and type(k.playerneardist) == "table" and #k.playerneardist == 4 then
								love.graphics.setColor(0, 1, 1)
								love.graphics.rectangle("line", math.floor((k.x+k.playerneardist[1]-xscroll)*16*scale)+.5, math.floor((k.y+k.playerneardist[2]-yscroll-.5)*16*scale)+.5, k.playerneardist[3]*16*scale-1, k.playerneardist[4]*16*scale-1)
							end
							if k.movementpath then
								love.graphics.setColor(0, 1, 33/255)
								local t = {}
								for i = 1, #k.movementpath do
									table.insert(t, math.floor((k.startx+k.movementpath[i][1]-xscroll)*16*scale)+.5)
									table.insert(t, math.floor((k.starty+k.movementpath[i][2]-yscroll-.5)*16*scale)+.5)
								end
								if not k.movementpathturnaround then
									table.insert(t, math.floor((k.startx+k.movementpath[1][1]-xscroll)*16*scale)+.5)
									table.insert(t, math.floor((k.starty+k.movementpath[1][2]-yscroll-.5)*16*scale)+.5)
								end
								love.graphics.line(t)
							end
							if k.carryrange then
								love.graphics.setColor(0, 1, 1)
								love.graphics.rectangle("line", math.floor((k.x+k.carryrange[1]-xscroll)*16*scale)+.5, math.floor((k.y+k.carryrange[2]-yscroll-.5)*16*scale)+.5, k.carryrange[3]*16*scale-1, k.carryrange[4]*16*scale-1)
							end
							if k.blowrange then
								love.graphics.setColor(100/255, 1, 1)
								love.graphics.rectangle("line", math.floor((k.x+k.blowrange[1]-xscroll)*16*scale)+.5, math.floor((k.y+k.blowrange[2]-yscroll-.5)*16*scale)+.5, k.blowrange[3]*16*scale-1, k.blowrange[4]*16*scale-1)
							end

							--[[if k.pointingangle then
								local xcenter = k.x + 6/16 - math.sin(k.pointingangle)*userange
								local ycenter = k.y + 6/16 - math.cos(k.pointingangle)*userange
							
								love.graphics.setColor(0, 1, 1)
								love.graphics.rectangle("line", math.floor((xcenter-usesquaresize/2-xscroll)*16*scale)+.5, math.floor((ycenter-usesquaresize/2-yscroll-.5)*16*scale)+.5, usesquaresize*16*scale-1, usesquaresize*16*scale-1)
							end]]
						end
					end
				end
			end
			
			love.graphics.setColor(234/255, 160/255, 45/255, 155/255)
			for j, w in pairs(objects["regiontrigger"]) do
				love.graphics.rectangle("fill", math.floor((w.rx-xscroll)*16*scale)+.5, math.floor((w.ry-yscroll-.5)*16*scale)+.5, w.rw*16*scale-1, w.rh*16*scale-1)
			end

			for j, w in pairs(userects) do
				love.graphics.setColor(0, 1, 1, 150/255)
				love.graphics.rectangle("line", math.floor((w.x-xscroll)*16*scale)+.5, math.floor((w.y-yscroll-.5)*16*scale)+.5, w.width*16*scale-1, w.height*16*scale-1)
			end
			love.graphics.setLineWidth(lw)

			--animation numbers
			if HITBOXDEBUGANIMS then
				love.graphics.setColor(1, 1, 1, 225/255)
				local x, y, max = 0, 2, 0
				for i, n in pairs(animationnumbers) do
					local text = i .. ": " .. n
					if #text > max then
						max = #text
					end
					properprint(text, x*scale, y*scale)
					y = y + 10
					if y >= (height*16)-10 then
						x, y = x + 8*(max+1), 2
					end
				end
			end
		end

		--portalwalldebug
		--[[if portalwalldebug then
			for j, v in pairs(portals) do
				for k = 1, 2 do
					for i = 1, 6 do
						if objects["portalwall"][v.number .. "-" .. k .. "-" .. i] then
							objects["portalwall"][v.number .. "-" .. k .. "-" .. i]:draw()
						end
					end
				end
			end
		end]]
		
		love.graphics.setColor(1, 1, 1)
		
		--COINBLOCKANIMATION
		for i, v in pairs(coinblockanimations) do
			if v.t and v.t == "collectable" then
				love.graphics.draw(collectableimg, collectablequad[spriteset][v.i][v.frame], math.floor((v.x - xscroll + 1/16)*16*scale), math.floor(((v.y + v.offsety - 8/16 - yscroll)*16-8)*scale), 0, scale, scale, 16, 16)
			else
				love.graphics.draw(coinblockanimationimage, coinblockanimationquads[v.frame], math.floor((v.x - xscroll)*16*scale), math.floor(((v.y - yscroll)*16-8)*scale), 0, scale, scale, 4, 54)
			end
		end
		
		--SCROLLING SCORE
		for i, v in pairs(scrollingscores) do
			if type(scrollingscores[i].i) == "number" then
				properprint2(scrollingscores[i].i, math.floor((scrollingscores[i].x-0.4)*16*scale), math.floor((scrollingscores[i].y-1.5-scrollingscoreheight*(scrollingscores[i].timer/scrollingscoretime))*16*scale))
			elseif scrollingscores[i].i == "1up" then
				love.graphics.draw(oneuptextimage, math.floor((scrollingscores[i].x)*16*scale), math.floor((scrollingscores[i].y-1.5-scrollingscoreheight*(scrollingscores[i].timer/scrollingscoretime))*16*scale), 0, scale, scale)
			elseif scrollingscores[i].i == "3up" then
				love.graphics.draw(threeuptextimage, math.floor((scrollingscores[i].x)*16*scale), math.floor((scrollingscores[i].y-1.5-scrollingscoreheight*(scrollingscores[i].timer/scrollingscoretime))*16*scale), 0, scale, scale)
			end
		end
		
		--BLOCK DEBRIS
		for i, v in pairs(blockdebristable) do
			v:draw()
		end
		
		local minex, miney, minecox, minecoy
		
		--PORTAL UI STUFF
		if levelfinished == false then
			for pl = 1, players do
				player = objects["player"][pl]
				if player.controlsenabled and player.t == "portal" and player.vine == false and player.fence == false and player.portalgun then
					local sourcex, sourcey = player.x+player.portalsourcex, player.y+player.portalsourcey
					local cox, coy, side, tend, x, y = traceline(sourcex, sourcey, player.pointingangle)
					
					local portalpossible = true
					if cox == false or getportalposition(1, cox, coy, side, tend) == false then
						portalpossible = false
					end
					
					love.graphics.setColor(1, 1, 1, 1)
					
					local dist = math.sqrt(((x-xscroll)*16*scale - (sourcex-xscroll)*16*scale)^2 + ((y-yscroll-.5)*16*scale - (sourcey-yscroll-.5)*16*scale)^2)/16/scale
					
					portaldotspritebatch:clear()
					for i = 1, dist/portaldotsdistance+1 do
						if((i-1+portaldotstimer/portaldotstime)/(dist/portaldotsdistance)) < 1 then
							local xplus = ((x-xscroll)*16*scale - (sourcex-xscroll)*16*scale)*((i-1+portaldotstimer/portaldotstime)/(dist/portaldotsdistance))
							local yplus = ((y-.5-yscroll)*16*scale - (sourcey-.5-yscroll)*16*scale)*((i-1+portaldotstimer/portaldotstime)/(dist/portaldotsdistance))
						
							local dotx = (sourcex-xscroll)*16*scale + xplus
							local doty = (sourcey-.5-yscroll)*16*scale + yplus
						
							local radius = math.sqrt(xplus^2 + yplus^2)/scale
							
							
							local alpha = 1
							if radius < portaldotsouter then
								alpha = (radius-portaldotsinner) * (portaldotsouter-portaldotsinner)
								if alpha < 0 then
									alpha = 0
								end
							end
							if portalpossible == false then
								portaldotspritebatch:setColor(1, 0, 0, alpha)
							else
								portaldotspritebatch:setColor(0, 1, 0, alpha)
							end
							portaldotspritebatch:add(math.floor(dotx-0.25*scale), math.floor(doty-0.25*scale), 0, scale, scale)
						end
					end
					
					love.graphics.draw(portaldotspritebatch, 0,0)
				
					love.graphics.setColor(1, 1, 1, 1)
					
					if cox ~= false then
						if portalpossible == false then
							love.graphics.setColor(1, 0, 0)
						else
							love.graphics.setColor(0, 1, 0)
						end
						
						local rotation = 0
						if side == "right" then
							rotation = math.pi/2
						elseif side == "down" then
							rotation = math.pi
						elseif side == "left" then
							rotation = math.pi/2*3
						end
						love.graphics.draw(portalcrosshairimg, math.floor((x-xscroll)*16*scale), math.floor((y-.5-yscroll)*16*scale), rotation, scale, scale, 4, 8)
					end
				end
			end
		end
		
		--Portal projectile
		portalprojectilespritebatch:clear()
		for i, v in pairs(portalprojectiles) do
			v:particledraw()
		end
		love.graphics.setColor(1,1,1)
		love.graphics.draw(portalprojectilespritebatch,0,0)
		for i, v in pairs(portalprojectiles) do
			v:draw()
		end
		
		love.graphics.setColor(1, 1, 1)
		
		--nothing to see here
		for i, v in pairs(rainbooms) do
			v:draw()
		end
		
		--Foreground tiles
		drawmaptiles("foreground", xscroll, yscroll)
		
		love.graphics.setColor(1, 1, 1)
		--Poofs
		for j, w in pairs(poofs) do
			w:draw()
		end
		
		--custom foreground
		rendercustomforeground(xscroll, yscroll, scrollfactor2, scrollfactor2y)
		
		--UI over everything
		love.graphics.scale(1/screenzoom,1/screenzoom)
		if hudsimple and ((not darkmode and not lightsout) or editormode) then
			if hudvisible then
				drawHUD()
			end
		end

		--Player markers
		if players > 1 then--playermarkers then
			for i = 1, players do
				local v = objects["player"][i]
				if not v.dead and v.drawable and v.y < mapheight-.5 then
					--get if player offscreen
					local right, left, up, down = false, false, false, false
					if v.x > xscroll+width then
						right = true
					end
					
					if v.x+v.width < xscroll then
						left = true
					end
					
					if v.y > yscroll + .5 + height then
						down = true
					end
					
					if v.y+v.height < yscroll +.5 then
						up = true
					end
					
					if up or left or down or right then
						local x, y
						local angx, angy = 0, 0
						if right then
							x = width
							angx = 1
						elseif left then
							x = 0
							angx = -1
						end
						if up then
							y = 0
							angy = -1
						elseif down then
							y = height
							angy = 1
						end
						if not x then
							x = v.x-xscroll+v.width/2
						end
						if not y then
							y = v.y-yscroll-3/16
						end
						local r = -math.atan2(angx, angy)-math.pi/2
						--limit x or y if right angle
						if math.fmod(r, math.pi/2) == 0 then
							if up or down then
								x = math.max(x, 15/16)
								x = math.min(x, width-15/16)
							else
								y = math.max(y, 15/16)
								y = math.min(y, height-15/16)
							end
						end
						
						love.graphics.setColor(backgroundcolor[background])
						love.graphics.draw(markbaseimg, math.floor(x*16*scale), math.floor(y*16*scale), r, scale, scale, 0, 15)
						
						local dist = 21.5
						
						local xadd = math.cos(r)*dist
						local yadd = math.sin(r)*dist
						
						love.graphics.setColor(1, 1, 1)
						local func = function() love.graphics.circle("fill", math.floor((x*16+xadd)*scale), math.floor((y*16+yadd-.5)*scale), 13.5*scale) end
						love.graphics.stencil(func)
						love.graphics.setStencilTest("greater", 0)
						
						local playerx, playery = x*16+xadd, y*16+yadd+3
						
						--draw map
						for x = math.floor(v.x), math.floor(v.x)+3 do
							for y = math.floor(v.y), math.floor(v.y)+3 do
								if inmap(x, y) then
									local t = map[x][y]
									if t then
										local tilenumber = tonumber(t[1])
										if tilequads[tilenumber].coinblock and tilequads[tilenumber].invisible == false then --coinblock
											love.graphics.draw(coinblockimage, coinblockquads[spriteset][coinframe], math.floor((x-1-v.x-6/16)*16*scale+playerx*scale), math.floor((y-1.5-v.y)*16*scale+playery*scale), 0, scale, scale)
										elseif tilenumber ~= 0 and not tilequads[tilenumber].invisible then
											love.graphics.draw(tilequads[tilenumber].image, tilequads[tilenumber].quad, math.floor((x-1-v.x-6/16)*16*scale+playerx*scale), math.floor((y-1.5-v.y)*16*scale+playery*scale), 0, scale, scale)
										end
									end
								end
							end
						end
						
						drawplayer(i, (playerx/16)+xscroll-(6/16), (playery/16)+yscroll)
						
						love.graphics.setStencilTest()
						
						love.graphics.setColor(v.colors[1] or {1, 1, 1})
						love.graphics.draw(markoverlayimg, math.floor(x*16*scale), math.floor(y*16*scale), r, scale, scale, 0, 15)
					end
				end
				love.graphics.setScissor()
			end
		end
		
		--Minecraft
		--black border
		if objects["player"][mouseowner] and playertype == "minecraft" and not levelfinished then
			local v = objects["player"][mouseowner]
			local sourcex, sourcey = v.x+v.portalsourcex, v.y+v.portalsourcey
			local cox, coy, side, tend, x, y = traceline(sourcex, sourcey, v.pointingangle)
			
			if cox then
				local dist = math.sqrt((v.x+v.width/2 - x)^2 + (v.y+v.height/2 - y)^2)
				if dist <= minecraftrange then
					love.graphics.setColor(0, 0, 0, 170/255)
					love.graphics.rectangle("line", math.floor((cox-1-xscroll)*16*scale)-.5, (coy-1-.5-yscroll)*16*scale-.5, 16*scale, 16*scale)
				
					if breakingblockX and (cox ~= breakingblockX or coy ~= breakingblockY) then
						breakingblockX = cox
						breakingblockY = coy
						breakingblockprogress = 0
					elseif not breakingblockX and love.mouse.isDown("l") then
						breakingblockX = cox
						breakingblockY = coy
						breakingblockprogress = 0
					end
				elseif love.mouse.isDown("l") then
					breakingblockX = cox
					breakingblockY = coy
					breakingblockprogress = 0
				end
			else
				breakingblockX = nil
			end
			--break animation
			if breakingblockX then
				love.graphics.setColor(1, 1, 1, 1)
				local frame = math.ceil((breakingblockprogress/minecraftbreaktime)*10)
				if frame ~= 0 then
					love.graphics.draw(minecraftbreakimg, minecraftbreakquad[frame], (breakingblockX-1-xscroll)*16*scale, (breakingblockY-1.5-yscroll)*16*scale, 0, scale, scale)
				end
			end
			love.graphics.setColor(1, 1, 1, 1)
			
			--gui
			love.graphics.draw(minecraftgui, (width*8-91)*scale, 202*scale, 0, scale, scale)
			
			love.graphics.setColor(1, 1, 1, 200/255)
			for i = 1, 9 do
				local t = inventory[i].t
				
				if t ~= nil then
					love.graphics.draw(tilequads[t].image, tilequads[t].quad, (width*8-88+(i-1)*20)*scale, 205*scale, 0, scale, scale)
				end
			end
			
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.draw(minecraftselected, (width*8-92+(mccurrentblock-1)*20)*scale, 201*scale, 0, scale, scale)
			
			for i = 1, 9 do
				if inventory[i].t ~= nil then
					local count = inventory[i].count
					properprint(count, (width*8-72+(i-1)*20-string.len(count)*8)*scale, 205*scale)
				end
			end
		end
		
		love.graphics.pop()
	end
	love.graphics.setScissor()
	if lightsout and not editormode then
		local pass = true
		for j, w in pairs(objects["player"]) do
			if w.starred then
				pass = false
				break
			end
		end
		if pass then
			love.graphics.setColor(0, 0, 0)
			love.graphics.stencil(lightsoutstencil)
			love.graphics.setStencilTest("less", 1)
			love.graphics.setColor(0, 0, 0, 1)
			if objects["player"][1] then
				--stencils not supported
				local v = objects["player"][1]
				local x, y = v.x+v.width/2-xscroll, v.y+v.height/2-.5-yscroll
				local lightscale = v.light/3.5
				local iw, ih = mariolightimg:getWidth()*lightscale, mariolightimg:getHeight()*lightscale
				love.graphics.draw(mariolightimg, (x*16-iw/2)*scale, (y*16-ih/2)*scale, 0, lightscale*scale, lightscale*scale)
				--fill in the blanks
				love.graphics.rectangle("fill", 0, 0, width*16*scale, ((y*16)-ih/2)*scale) --top
				love.graphics.rectangle("fill", 0, ((y*16)+ih/2)*scale, width*16*scale, ((height-y)*16-ih/2)*scale) --bottom
				love.graphics.rectangle("fill", 0, ((y*16)-ih/2)*scale, ((x*16)-ih/2)*scale, ih*scale) --left
				love.graphics.rectangle("fill", ((x*16)+ih/2)*scale, ((y*16)-ih/2)*scale, (((width-x)*16)-iw/2)*scale, ih*scale) --right
			else
				--whatever let's hope the device supports stencils
				love.graphics.rectangle("fill", 0, 0, width*16*scale, height*16*scale)
			end
			love.graphics.setStencilTest()
		end
	elseif darkmode and not editormode then
		--dark mode has fancy layers
		love.graphics.setColor(0, 0, 0)
		local stencil = function()
			for j, w in pairs(objects["player"]) do
				love.graphics.circle("fill", ((w.x+(w.width/2)-xscroll)*16)*scale, ((w.y+(w.height/2)-yscroll)*16-8)*scale, 70*scale, 18)
			end
		end
		local stencil2 = function()
			for j, w in pairs(objects["player"]) do
				love.graphics.circle("fill", ((w.x+(w.width/2)-xscroll)*16)*scale, ((w.y+(w.height/2)-yscroll)*16-8)*scale, 60*scale, 18)
			end
		end
		local stencil3 = function()
			for j, w in pairs(objects["player"]) do
				love.graphics.circle("fill", ((w.x+(w.width/2)-xscroll)*16)*scale, ((w.y+(w.height/2)-yscroll)*16-8)*scale, 50*scale, 18)
			end
		end
		local stencil4 = function()
			for j, w in pairs(objects["player"]) do
				love.graphics.circle("fill", ((w.x+(w.width/2)-xscroll)*16)*scale, ((w.y+(w.height/2)-yscroll)*16-8)*scale, 40*scale, 18)
			end
		end
		love.graphics.stencil(stencil4)
		love.graphics.setStencilTest("less", 1)
		love.graphics.setColor(0, 0, 0, 1/4)
		love.graphics.rectangle("fill", 0, 0, width*16*scale, 224*scale)
		love.graphics.setStencilTest()
		love.graphics.stencil(stencil3)
		love.graphics.setStencilTest("less", 1)
		love.graphics.setColor(0, 0, 0, 1/3)
		love.graphics.rectangle("fill", 0, 0, width*16*scale, 224*scale)
		love.graphics.setStencilTest()
		love.graphics.stencil(stencil2)
		love.graphics.setStencilTest("less", 1)
		love.graphics.setColor(0, 0, 0, 1/2)
		love.graphics.rectangle("fill", 0, 0, width*16*scale, 224*scale)
		love.graphics.setStencilTest()
		love.graphics.stencil(stencil)
		love.graphics.setStencilTest("less", 1)
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", 0, 0, width*16*scale, 224*scale)
		love.graphics.setColor(1, 1, 1)
		love.graphics.setStencilTest()
		if hudvisible then
			drawHUD()
		end
	end

	--UI over everything in darkmode
	if ((darkmode or lightsout) and not editormode) then
		if hudvisible then
			drawHUD()
		end
	end
	
	if dcplaying then
		love.graphics.setColor(1, 1, 1)
		properprintbackground(DCchalobjective, width*8*scale-string.len(DCchalobjective)*4*scale, 35*scale)
		properprint(DCchalobjective, width*8*scale-string.len(DCchalobjective)*4*scale, 35*scale)
	end
	
	for i, v in pairs(dialogboxes) do
		v:draw()
	end
	
	if earthquake > 0 and not pausemenuopen then
		love.graphics.translate(-round(tremorx), -round(tremory))
	end
	
	for i = 2, #splitscreen do
		love.graphics.line((i-1)*width*16*scale/#splitscreen, 0, (i-1)*width*16*scale/#splitscreen, mapheight*16*scale)
	end
	
	if editormode then
		editor_draw()
	end
	
	--speed gradient
	if speed < 1 then
		love.graphics.setColor(1, 1, 1, 1-speed)
		love.graphics.draw(gradientimg, 0, 0, 0, scale, scale)
	end
	
	if yoffset < 0 then
		love.graphics.translate(0, -yoffset*scale)
	end
	love.graphics.translate(0, yoffset*scale)
	
	if testlevel then
		love.graphics.setColor(1, 0, 0, .5)
		properprintfast("TESTING LEVEL - PRESS ESC TO RETURN TO EDITOR", 16*scale, 0)
	end
	
	--pause menu
	if pausemenuopen then
		love.graphics.setColor(0, 0, 0, 100/255)
		love.graphics.rectangle("fill", 0, 0, width*16*scale, height*16*scale)
		
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", (width*8*scale)-50*scale, (112*scale)-75*scale, 100*scale, 150*scale)
		love.graphics.setColor(1, 1, 1)
		drawrectangle(width*8-49, 112-74, 98, 148)
		
		for i = 1, #pausemenuoptions do
			love.graphics.setColor(100/255, 100/255, 100/255, 1)
			if pausemenuselected == i and not menuprompt and not desktopprompt then
				love.graphics.setColor(1, 1, 1, 1)
				properprint(">", (width*8*scale)-45*scale, (112*scale)-60*scale+(i-1)*25*scale)
			end
			if dcplaying and pausemenuoptions[i] == "suspend" then --restart instead of suspend
				properprintF(TEXT["restart"], (width*8*scale)-35*scale, (112*scale)-60*scale+(i-1)*25*scale)
			elseif (collectablescount[1] > 0 or collectablescount[2] > 0 or collectablescount[3] > 0 or collectablescount[4] > 0 or
			collectablescount[5] > 0 or collectablescount[6] > 0 or collectablescount[7] > 0 or collectablescount[8] > 0 or
			collectablescount[9] > 0 or collectablescount[10] > 0)
				and pausemenuoptions[i] == "suspend" then --make it more obvious that you can save your progress
				properprintF(TEXT["save game"], (width*8*scale)-35*scale, (112*scale)-60*scale+(i-1)*25*scale)
			else
				properprintF(TEXT[pausemenuoptions[i]], (width*8*scale)-35*scale, (112*scale)-60*scale+(i-1)*25*scale)
			end
			properprintF(TEXT[pausemenuoptions2[i]], (width*8*scale)-35*scale, (112*scale)-50*scale+(i-1)*25*scale)
			
			if pausemenuoptions[i] == "volume" then
				drawrectangle((width*8)-34, 68+(i-1)*25, 74, 1)
				drawrectangle((width*8)-34, 65+(i-1)*25, 1, 7)
				drawrectangle((width*8)+40, 65+(i-1)*25, 1, 7)
				love.graphics.draw(volumesliderimg, math.floor(((width*8)-35+74*volume)*scale), (112*scale)-47*scale+(i-1)*25*scale, 0, scale, scale)
			end
		end
		
		if menuprompt then
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.rectangle("fill", (width*8*scale)-100*scale, (112*scale)-25*scale, 200*scale, 50*scale)
			love.graphics.setColor(1, 1, 1, 1)
			drawrectangle((width*8)-99, 112-24, 198, 48)
			properprintF(TEXT["quit to menu?"], (width*8*scale)-utf8.len(TEXT["quit to menu?"])*4*scale, (112*scale)-10*scale)
			if pausemenuselected2 == 1 then
				properprintF(">", (width*8*scale)-51*scale, (112*scale)+4*scale)
				love.graphics.setColor(1, 1, 1, 1)
				properprintF(TEXT["yes"], (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(100/255, 100/255, 100/255, 1)
				properprintF(TEXT["no"], (width*8*scale)+28*scale, (112*scale)+4*scale) 
			else
				properprintF(">", (width*8*scale)+20*scale, (112*scale)+4*scale)
				love.graphics.setColor(100/255, 100/255, 100/255, 1)
				properprintF(TEXT["yes"], (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(1, 1, 1, 1)
				properprintF(TEXT["no"], (width*8*scale)+28*scale, (112*scale)+4*scale)
			end
		end
		
		if desktopprompt then
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.rectangle("fill", (width*8*scale)-100*scale, (112*scale)-25*scale, 200*scale, 50*scale)
			love.graphics.setColor(1, 1, 1, 1)
			drawrectangle((width*8)-99, 112-24, 198, 48)
			properprintF(TEXT["quit to desktop?"], (width*8*scale)-utf8.len(TEXT["quit to desktop?"])*4*scale, (112*scale)-10*scale)
			if pausemenuselected2 == 1 then
				properprintF(">", (width*8*scale)-51*scale, (112*scale)+4*scale)
				love.graphics.setColor(1, 1, 1, 1)
				properprintF(TEXT["yes"], (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(100/255, 100/255, 100/255, 1)
				properprintF(TEXT["no"], (width*8*scale)+28*scale, (112*scale)+4*scale)
			else
				properprintF(">", (width*8*scale)+20*scale, (112*scale)+4*scale)
				love.graphics.setColor(100/255, 100/255, 100/255, 1)
				properprintF(TEXT["yes"], (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(1, 1, 1, 1)
				properprintF(TEXT["no"], (width*8*scale)+28*scale, (112*scale)+4*scale)
			end
		end
		
		if suspendprompt then
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.rectangle("fill", (width*8*scale)-100*scale, (112*scale)-25*scale, 200*scale, 50*scale)
			love.graphics.setColor(1, 1, 1, 1)
			drawrectangle((width*8)-99, 112-24, 198, 48)
			if (collectablescount[1] > 0 or collectablescount[2] > 0 or collectablescount[3] > 0 or collectablescount[4] > 0 or
			collectablescount[5] > 0 or collectablescount[6] > 0 or collectablescount[7] > 0 or collectablescount[8] > 0 or
			collectablescount[9] > 0 or collectablescount[10] > 0) then --make it more obvious that you can save your progress
				properprintF(TEXT["save game? this will"], (width*8*scale)-utf8.len(TEXT["save game? this will"])*4*scale, (112*scale)-20*scale)
				properprintF(TEXT["overwrite last save."], (width*8*scale)-utf8.len(TEXT["overwrite last save."])*4*scale, (112*scale)-10*scale)
			else
				properprintF(TEXT["suspend game? this can"], (width*8*scale)-utf8.len(TEXT["suspend game? this can"])*4*scale, (112*scale)-20*scale)
				properprintF(TEXT["only be loaded once!"], (width*8*scale)-utf8.len(TEXT["only be loaded once!"])*4*scale, (112*scale)-10*scale)
			end
			if pausemenuselected2 == 1 then
				properprintF(">", (width*8*scale)-51*scale, (112*scale)+4*scale)
				love.graphics.setColor(1, 1, 1, 1)
				properprintF(TEXT["yes"], (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(100/255, 100/255, 100/255, 1)
				properprintF(TEXT["no"], (width*8*scale)+28*scale, (112*scale)+4*scale)
			else
				properprintF(">", (width*8*scale)+20*scale, (112*scale)+4*scale)
				love.graphics.setColor(100/255, 100/255, 100/255, 1)
				properprintF(TEXT["yes"], (width*8*scale)-44*scale, (112*scale)+4*scale)
				love.graphics.setColor(1, 1, 1, 1)
				properprintF(TEXT["no"], (width*8*scale)+28*scale, (112*scale)+4*scale)
			end
		end
	end
	
	--chat
	if chatentrytoggle then
		lobby_drawchat()
	end
end

function drawentity(j, w, i, v, currentscissor, drop)
	local dirscale
	
	if v.animationdirection == "left" then
		dirscale = -scale
	else
		dirscale = scale
	end
	if v.animationscalex then
		dirscale = dirscale*v.animationscalex
	end
	
	local horscale = scale
	if v.shot or v.flipped or v.upsidedown then
		horscale = -scale
	end
	
	if v.animationscaley then
		horscale = horscale*v.animationscaley
	end
	if v.customscale then
		horscale = horscale * v.customscale
		dirscale = dirscale * v.customscale
	end
	
	local oldoffsetx, oldoffsety
	if v.supersized then
		oldoffsetx, oldoffsety = v.offsetX, v.offsetY
		v.offsetX = v.offsetX*v.supersized
		v.offsetY = (v.offsetY-8)*v.supersized+8
	end
	
	local portal, portaly = insideportal(v.x, v.y, v.width, v.height)
	local entryX, entryY, entryfacing, exitX, exitY, exitfacing
	
	--SCISSOR FOR ENTRY
	if v.customscissor and (v.invertedscissor or (v.t and enemiesdata[v.t])) and v.portalable ~= false then --portable custom enemies
		love.graphics.stencil(function() love.graphics.rectangle("fill", math.floor((v.customscissor[1]-xscroll)*16*scale), math.floor((v.customscissor[2]-.5-yscroll)*16*scale), v.customscissor[3]*16*scale, v.customscissor[4]*16*scale) end, "increment")
		if v.invertedscissor then
			love.graphics.setStencilTest("less", 1)
		else
			love.graphics.setStencilTest("greater", 0)
		end
	elseif v.static or (v.portalable == false) then --static or non portable entities
		if v.invertedscissor then
			love.graphics.stencil(function() love.graphics.rectangle("fill", math.floor((v.customscissor[1]-xscroll)*16*scale), math.floor((v.customscissor[2]-.5-yscroll)*16*scale), v.customscissor[3]*16*scale, v.customscissor[4]*16*scale) end, "increment")
			love.graphics.setStencilTest("less", 1)
		elseif v.customscissor then
			love.graphics.setScissor(math.floor((v.customscissor[1]-xscroll)*16*screenzoom*scale), math.floor((v.customscissor[2]-.5-yscroll)*16*screenzoom*scale), v.customscissor[3]*16*screenzoom*scale, v.customscissor[4]*16*screenzoom*scale)
		end
	end
		
	if v.static == false and v.portalable ~= false then --not static and portable entities
		if v.customscissor then
			if v.invertedscissor then
			
			else
				love.graphics.setScissor(math.floor((v.customscissor[1]-xscroll)*16*screenzoom*scale), math.floor((v.customscissor[2]-.5-yscroll)*16*screenzoom*scale), v.customscissor[3]*16*screenzoom*scale, v.customscissor[4]*16*screenzoom*scale)
			end
		elseif portal ~= false and (v.active or v.portaloverride) then
			if portaly == 1 then
				entryX, entryY, entryfacing = portal.x1, portal.y1, portal.facing1
				exitX, exitY, exitfacing = portal.x2, portal.y2, portal.facing2
			else
				entryX, entryY, entryfacing = portal.x2, portal.y2, portal.facing2
				exitX, exitY, exitfacing = portal.x1, portal.y1, portal.facing1
			end
			
			if entryfacing == "right" then
				love.graphics.setScissor(math.floor((entryX-xscroll)*16*screenzoom*scale), math.floor(((entryY-3.5-yscroll)*16*screenzoom)*scale), 64*screenzoom*scale, 96*screenzoom*scale)
			elseif entryfacing == "left" then
				love.graphics.setScissor(math.floor((entryX-xscroll-5)*16*screenzoom*scale), math.floor(((entryY-4.5-yscroll)*16*screenzoom)*scale), 64*screenzoom*scale, 96*screenzoom*scale)
			elseif entryfacing == "up" then
				love.graphics.setScissor(math.floor((entryX-xscroll-3)*16*screenzoom*scale), math.floor(((entryY-5.5-yscroll)*16*screenzoom)*scale), 96*screenzoom*scale, 64*screenzoom*scale)
			elseif entryfacing == "down" then
				love.graphics.setScissor(math.floor((entryX-xscroll-4)*16*screenzoom*scale), math.floor(((entryY-0.5-yscroll)*16*screenzoom)*scale), 96*screenzoom*scale, 64*screenzoom*scale)
			end
		end
	end
	
	if v.customscissor2 then
		love.graphics.setScissor(math.floor((v.customscissor2[1]-xscroll)*16*screenzoom*scale), math.floor((v.customscissor2[2]-.5-yscroll)*16*screenzoom*scale), v.customscissor2[3]*16*screenzoom*scale, v.customscissor2[4]*16*screenzoom*scale)
	end
	
	if type(v.graphic) == "table" then
		drawplayer(v.playernumber)
	else
		if v.graphic and v.quad then
			if v.graphiccolor and (not drop) then
				local graphiccolor = {}
				for gci = 1, #v.graphiccolor do
					local color = tonumber(v.graphiccolor[gci])
					graphiccolor[gci] = color and color/255
				end
				love.graphics.setColor(graphiccolor)
			end
			love.graphics.draw(v.graphic, v.quad, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
			if v.overlaygraphic then
				love.graphics.draw(v.overlaygraphic, v.overlayquad, math.floor(((v.x-xscroll)*16+v.offsetX)*scale), math.floor(((v.y-yscroll)*16-v.offsetY)*scale), v.rotation, dirscale, horscale, v.quadcenterX, v.quadcenterY)
			end
		end
	end
	
	--portal duplication
	
	if v.static == false and (v.active or v.portaloverride) and v.portalable ~= false then
		if v.customscissor then
			
		elseif portal ~= false then
			love.graphics.setScissor(unpack(currentscissor))
			love.graphics.setScissor()
			local px, py, pw, ph, pr, pad = v.x, v.y, v.width, v.height, v.rotation, v.animationdirection
			px, py, d, d, pr, pad = portalcoords(px, py, 0, 0, pw, ph, pr, pad, entryX, entryY, entryfacing, exitX, exitY, exitfacing)
			
			if pad ~= v.animationdirection then
				dirscale = -dirscale
			end
			
			horscale = scale
			if v.shot or v.flipped then
				horscale = -scale
			end
			if v.animationscaley then
				horscale = horscale*v.animationscaley
			end
			
			if exitfacing == "right" then
				love.graphics.setScissor(math.floor((exitX-xscroll)*16*screenzoom*scale), math.floor(((exitY-3.5-yscroll)*16*screenzoom)*scale), 64*screenzoom*scale, 96*screenzoom*scale)
			elseif exitfacing == "left" then
				love.graphics.setScissor(math.floor((exitX-xscroll-5)*16*screenzoom*scale), math.floor(((exitY-4.5-yscroll)*16*screenzoom)*scale), 64*screenzoom*scale, 96*screenzoom*scale)
			elseif exitfacing == "up" then
				love.graphics.setScissor(math.floor((exitX-xscroll-3)*16*screenzoom*scale), math.floor(((exitY-5.5-yscroll)*16*screenzoom)*scale), 96*screenzoom*scale, 64*screenzoom*scale)
			elseif exitfacing == "down" then
				love.graphics.setScissor(math.floor((exitX-xscroll-4)*16*screenzoom*scale), math.floor(((exitY-0.5-yscroll)*16*screenzoom)*scale), 96*screenzoom*scale, 64*screenzoom*scale)
			end
			
			if type(v.graphic) == "table" then
				--yoshi
				drawplayer(i, px, py, pr, pad)
			else
				if v.graphic and v.quad then
					if v.graphiccolor and (not drop) then
						local graphiccolor = {}
						for gci = 1, #v.graphiccolor do
							graphiccolor[gci] = tonumber(v.graphiccolor[i])/255
						end
						love.graphics.setColor(graphiccolor)
					end
					love.graphics.draw(v.graphic, v.quad, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
					if v.overlaygraphic then
						love.graphics.draw(v.overlaygraphic, v.overlayquad, math.floor(((px-xscroll)*16+v.offsetX)*scale), math.floor(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
					end
				end
				--love.graphics.draw(v.graphic, v.quad, math.ceil(((px-xscroll)*16+v.offsetX)*scale), math.ceil(((py-yscroll)*16-v.offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
			end
		end
	end
	love.graphics.setScissor(unpack(currentscissor))
	love.graphics.setScissor()
	love.graphics.setStencilTest()

	if oldoffsetx and oldoffsety then
		v.offsetX = oldoffsetx
		v.offsetY = oldoffsety
	end

	--draw ice block on top
	if v.frozen and v.iceblock then
		v.iceblock:draw("enemylayer")
	end
end

function drawplayer(i, x, y, r, pad, drop)
	local v = objects["player"][i]
	local px, py = x or v.x, y or v.y
	local pr = r or v.rotation
	local a = 1 --alpha
	if drop then
		a = 0
	end

	if v.fireenemydrawable ~= nil and v.fireenemydrawable ~= true then
		return false
	end

	local dirscale
	--scale
	if (v.portalgun and v.pointingangle > 0) or (not v.portalgun and v.animationdirection == "left") then
		dirscale = -scale
	else
		dirscale = scale
	end

	if bigmario then
		dirscale = dirscale * scalefactor
	end
	if v.animationscalex then
		dirscale = dirscale*v.animationscalex
	end
	
	local horscale = scale
	if v.shot or v.flipped or v.upsidedown or v.gravitydir == "up" then
		horscale = -scale
	end

	if bigmario then
		horscale = horscale * scalefactor
	end
	if v.animationscaley then
		horscale = horscale*v.animationscaley
	end

	if v.customscale then
		horscale = horscale * v.customscale
		dirscale = dirscale * v.customscale
	end

	--portal mirroring
	if pad and pad ~= v.animationdirection then
		dirscale = -dirscale
	end

	local offsetX = v.offsetX
	local offsetY = v.offsetY

	if v.shoeoffsetY and (not v.ducking) and (not v.clearpipe) then
		offsetY = offsetY + v.shoeoffsetY
	end

	--gravity offsets
	if v.gravitydir == "left" then
		offsetX = (offsetX - v.quadcenterY -v.offsetX) + v.height*16 - 8 + v.offsetY + v.quadcenterY--offsetX + (v.offsetX - v.quadcenterX) + (v.offsetY + v.quadcenterY)
	elseif v.gravitydir == "right" then
		offsetX = (offsetX + v.width*16 + v.quadcenterY -v.offsetX) - v.height*16 + 8 - v.offsetY -v.quadcenterY--offsetX + (v.offsetX - v.quadcenterX) + (v.offsetY + v.quadcenterY)
	elseif v.gravitydir == "up" then
		local qx, qy, qw, qh = v.quad:getViewport()
		offsetY = (offsetY - (qh-v.quadcenterY) -v.offsetY + 8 + qh) - v.height*16 - (v.quadcenterY) + 8 -v.offsetY
	end

	--yoshi
	if v.shoe == "yoshi" then
		local dirscale
		if v.animationdirection == "left" then
			dirscale = -scale
		else
			dirscale = scale
		end
		if pad and pad ~= v.animationdirection then --portal duplication
			dirscale = -dirscale
		end
		local y = -offsetY - (v.height*16) + v.characterdata.yoshiimgoffsetY
		if v.animationscaley then
			y = -offsetY - (v.height*16) + v.characterdata.yoshiimghugeoffsetY
		end
		if v.yoshitounge then
			local xoffset, yoffset = 12/16, -22/16
			if v.yoshiquad == yoshiquad[v.yoshi.color][1] then
				xoffset = 7/16
			end
			--toungeenemy
			if v.yoshitoungeenemy then
				local x, y = math.floor((px+(v.width/2)+xoffset-xscroll)*16*scale)+(v.yoshitoungewidth*16*scale), math.floor((py+v.height+yoffset-yscroll)*16*scale)
				if dirscale < 0 then
					x = math.floor((px+(v.width/2)-xoffset-xscroll)*16*scale)-(v.yoshitoungewidth*16*scale)
				end
				if drop then
					love.graphics.setColor(dropshadowcolor)
				else
					love.graphics.setColor(1, 1, 1, a)
				end
				local e = v.yoshitoungeenemy
				local size = math.min(.2, v.yoshitoungewidth)/.2
				local esx, esy = e.animationscalex or 1, e.animationscaley or 1
				love.graphics.draw(e.graphic, e.quad, x+(((-(e.width/2))*16+e.offsetX)*scale), y+((-(e.height/2))*16-e.offsetY+8)*scale, 0, size*esx*scale, size*esy*scale, e.quadcenterX, e.quadcenterY)
			end
			--tounge
			if drop then
				love.graphics.setColor(dropshadowcolor)
			else
				love.graphics.setColor(216/255, 40/255, 0, a)
			end
			if dirscale > 0 then
				local x, y = math.floor((px+(v.width/2)+xoffset-xscroll)*16*scale), math.floor((py+v.height+yoffset-yscroll)*16*scale)
				love.graphics.rectangle("fill", x, y, (v.yoshitoungewidth)*16*scale, (2/16)*16*scale)
				if drop then
					love.graphics.setColor(dropshadowcolor)
				else
					love.graphics.setColor(1, 1, 1, a)
				end
				love.graphics.draw(yoshiimage, yoshiquad[v.yoshi.color][19], x+(v.yoshitoungewidth*16*scale), y, 0, scale, scale, 2, 1)
			else
				local x, y = math.floor((px+(v.width/2)-xoffset-xscroll)*16*scale), math.floor((py+v.height+yoffset-yscroll)*16*scale)
				love.graphics.rectangle("fill", x, y, (-v.yoshitoungewidth)*16*scale, (2/16)*16*scale)
				if drop then
					love.graphics.setColor(dropshadowcolor)
				else
					love.graphics.setColor(1, 1, 1, a)
				end
				love.graphics.draw(yoshiimage, yoshiquad[v.yoshi.color][19], x-(v.yoshitoungewidth*16*scale), y, 0, -scale, scale, 2, 1)
			end
		end
		
		if drop then
			love.graphics.setColor(dropshadowcolor)
		else
			love.graphics.setColor(1, 1, 1, a)
		end
		love.graphics.draw(yoshiimage, v.yoshiquad, math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, 11, y)

		if v.size == 12 then --skinny mario needs to be lower
			offsetY = offsetY + v.characterdata.yoshiskinnyoffsetY
		elseif v.size == -1 then
			offsetY = offsetY + v.characterdata.yoshitinyoffsetY
		end

		if v.animationstate == "running" and (not v.yoshitounge) and v.characterdata.yoshiwalkoffsets[v.runframe] then
			offsetY = offsetY + v.characterdata.yoshiwalkoffsets[v.runframe]
		end
	end

	local draw = true
	if v.shoe == "drybonesshell" and v.ducking then
		draw = false
	end

	if draw then
		--cape
		if (v.graphic == v.capegraphic or (v.fireenemy and v.fireenemy.cape)) and (not v.capefly) then
			local frame = v.capeframe or 1
			if frame ~= 18 then
				local offx, offy = v.characterdata.capeimgoffsetX, v.characterdata.capeimgoffsetY
				if (v.fireenemy and v.fireenemy.cape) then
					offx = v.characterdata.capeimgfireenemyoffsetX
				end
				if v.ducking then
					offy = offy + v.characterdata.capeimgduckingoffsetY
				end
				local dirscale = dirscale
				if v.spinanimationtimer < 0.2 then
					if v.spinframez == 1 then
						frame = 14
						dirscale = -dirscale
					elseif v.spinframez == 2 then
						frame = 15
						dirscale = -dirscale
					else
						frame = 15
					end
				end
				love.graphics.setColor(1, 1, 1, a)
				local img = capeimg
				if v.character and v.characterdata and v.characterdata.capeimg then
					img = v.characterdata.capeimg
				end
				love.graphics.draw(img, capequad[frame], math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, v.quadcenterX + offx, v.quadcenterY + offy)
			end
		end
		
		if not v.graphic then
			print("missing player graphics! fuck this game!")
			return false
		end
		for k = 1, #v.graphic do
			if drop then
				love.graphics.setColor(dropshadowcolor)
			elseif v.colors[k] then
				love.graphics.setColor(v.colors[k])
			elseif mariocolors[v.playernumber] and mariocolors[v.playernumber][k] then --default character colors
				love.graphics.setColor(mariocolors[v.playernumber][k])
			else
				love.graphics.setColor(1, 1, 1, a)
			end
			love.graphics.draw(v.graphic[k], v.quad, math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
		end

		if v.character and v.characterdata and v.characterdata.portalgununderhat then
			if v.graphic[0] then
				if drop then
					love.graphics.setColor(dropshadowcolor)
				else
					love.graphics.setColor(1, 1, 1, a)
				end
				love.graphics.draw(v.graphic[0], v.quad, math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
			end
		end
		
		if v.drawhat and (hatoffsets[v.animationstate] or v.animationstate == "floating" or (v.animationstate == "dead" and v.size == 1 and hat[v.hats[i]] and hat[v.hats[i]].dead)) then
			local offsets = {0,0}
			local drawhats = true
			local char = v.character
			if v.graphic == v.biggraphic or v.graphic == v.capegraphic or v.animationstate == "grow" or v.graphic == v.raccoongraphic or v.graphic == v.hammergraphic or v.graphic == v.froggraphic or v.graphic == v.tinygraphic or v.graphic == v.tanookigraphic or v.graphic == v.shellgraphic or v.graphic == v.boomeranggraphic then
				if v.quadanim == "grow" then
					offsets = customplayerhatoffsets(char, "hatoffsets", "grow") or hatoffsets["grow"]
				elseif v.graphic == v.capegraphic and v.quadanim == "fly" then
					offsets = customplayerhatoffsets(char, "bighatoffsets", "capefly", v.quadframe) or bighatoffsets["idle"]
				elseif v.graphic == v.capegraphic and v.quadanim == "fire" then
					offsets = customplayerhatoffsets(char, "bighatoffsets", "flyjump", v.quadframe) or bighatoffsets["idle"]
				else
					offsets = customplayerhatoffsets(char, "bighatoffsets", v.quadanimi, v.quadframe) or bighatoffsets["idle"]
				end
				if v.graphic == v.shellgraphic and v.ducking then
					drawhats = false
				end
				if v.graphic == v.hammergraphic or v.graphic == v.froggraphic or v.graphic == v.tinygraphic or v.graphic == v.tanookigraphic or v.graphic == v.boomeranggraphic then
					drawhats = false
				end
			elseif v.graphic == v.skinnygraphic then
				if v.quadanim == "grow" then
					offsets = customplayerhatoffsets(char, "hatoffsets", "grow") or hatoffsets["grow"]
				else
					offsets = customplayerhatoffsets(char, "skinnyhatoffsets", v.quadanimi, v.quadframe) or skinnyhatoffsets["idle"]
				end
			else
				if v.quadanim == "grow" then
					offsets = customplayerhatoffsets(char, "hatoffsets", "grow") or hatoffsets["grow"]
				else
					offsets = customplayerhatoffsets(char, "hatoffsets", v.quadanimi, v.quadframe) or hatoffsets[v.quadanimi] or hatoffsets["idle"]
				end
			end
			if v.helmet then
				drawhats = false
			end
			--SE characters using different hatoffset format
			if (offsets and offsets[1] and type(offsets[1]) ~= "number") or (not offsets) then
				offsets = {0,0}
				drawhats = false
			end

			if #v.hats > 0 and offsets and drawhats then
				local yadd = 0
				local xadd = 0
				if v.graphic == v.capegraphic then
					xadd = v.characterdata.capehatoffsetX
				end
				for i = 1, #v.hats do
					local currenthat = v.hats[i]
					if v.fireenemy and v.fireenemy.hat then
						currenthat = v.fireenemy.hat
					end
					local raccoonhat = false
					local dirscale = dirscale
					if currenthat == 1 then
						if drop then
							love.graphics.setColor(dropshadowcolor)
						else
							love.graphics.setColor(v.colors[1])
						end
						if v.graphic == v.raccoongraphic and not (v.character and v.characterdata and v.characterdata.noraccoonhat) then
							--hat?
							raccoonhat = true
							xadd = v.characterdata.raccoonhatoffsetX
						end
						if v.spinanimationtimer < raccoonspintime and v.spinframez == 2 and (not v.shoe) then
							--flipped hat during spin
							dirscale = -dirscale
							if raccoonhat then
								xadd = xadd + v.characterdata.raccoonhatspinoffsetX
							end
						end
					else
						if drop then
							love.graphics.setColor(dropshadowcolor)
						else
							love.graphics.setColor(1, 1, 1, a)
						end
					end
					if v.graphic == v.raccoongraphic and not raccoonhat then
						--don't show hat in raccoon mode!
						break
					end
					if v.graphic == v.biggraphic or v.graphic == v.capegraphic or v.graphic == v.shellgraphic or v.animationstate == "grow" or raccoonhat then
						if bighat[currenthat].sliding and bighat[currenthat].slidingemblem and v.animationstate == "sliding" and (not v.ducking) and not v.yoshi then --tilt hat when sliding
							if raccoonhat then
								love.graphics.draw(bighat[currenthat].raccoonsliding, bighat[currenthat].quad[1], math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - bighat[currenthat].x + offsets[1] + xadd, v.quadcenterY - bighat[currenthat].y + offsets[2] + yadd)
							else
								love.graphics.draw(bighat[currenthat].sliding, bighat[currenthat].quad[1], math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - bighat[currenthat].x + offsets[1] + xadd, v.quadcenterY - bighat[currenthat].y + offsets[2] + yadd)
							end
							if drop then
								love.graphics.setColor(dropshadowcolor)
							else
								love.graphics.setColor(v.colors[3])
							end
							love.graphics.draw(bighat[currenthat].slidingemblem, bighat[currenthat].quad[1], math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - bighat[currenthat].x + offsets[1] + xadd, v.quadcenterY - bighat[currenthat].y + offsets[2] + yadd)
						else
							if bighat[currenthat].directions and v.spinanimationtimer < raccoonspintime and (v.spinframez == 1 or v.spinframez == 3) and (not v.shoe) then
								--front of hat
								love.graphics.draw(bighat[currenthat].graphic, bighat[currenthat].quad[2], math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - bighat[currenthat].x + offsets[1] + xadd, v.quadcenterY - bighat[currenthat].y + offsets[2] + yadd)
							else
								local q = 1
								if v.fence then
									q = 3
								end
								if raccoonhat and bighat[currenthat].raccoon then
									love.graphics.draw(bighat[currenthat].raccoon, bighat[currenthat].quad[q], math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - bighat[currenthat].x + offsets[1] + xadd, v.quadcenterY - bighat[currenthat].y + offsets[2] + yadd)
								else
									love.graphics.draw(bighat[currenthat].graphic, bighat[currenthat].quad[q], math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - bighat[currenthat].x + offsets[1] + xadd, v.quadcenterY - bighat[currenthat].y + offsets[2] + yadd)
								end
							end
						end
							
						if bighat[currenthat].emblem and (v.animationstate ~= "jumping" or v.water or v.ducking or v.yoshi) and (v.animationstate ~= "sliding" or v.ducking or v.yoshi) and v.animationstate ~= "floating" then --draw an emblem on hat
							if drop then
								love.graphics.setColor(dropshadowcolor)
							else
								love.graphics.setColor(v.colors[3])
							end
							if v.spinanimationtimer < raccoonspintime and (not v.shoe) then
								--front of hat
								if ((raccoonhat and v.spinframez == 3) or ((not raccoonhat) and v.spinframez == 1)) and bighat[currenthat].emblem then
									love.graphics.draw(bighat[currenthat].emblem, bighat[currenthat].quad[2], math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - bighat[currenthat].x + offsets[1] + xadd, v.quadcenterY - bighat[currenthat].y + offsets[2] + yadd)
								end
							else
								local q = 1
								if v.fence then
									q = 3
								end
								love.graphics.draw(bighat[currenthat].emblem, bighat[currenthat].quad[q], math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - bighat[currenthat].x + offsets[1] + xadd, v.quadcenterY - bighat[currenthat].y + offsets[2] + yadd)
							end
						end
						yadd = yadd + bighat[currenthat].height
					else
						if hat[currenthat].sliding and v.animationstate == "sliding" and not v.yoshi then --tilt hat when sliding
							love.graphics.draw(hat[currenthat].sliding, hat[currenthat].quad[1], math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - hat[currenthat].x + offsets[1], v.quadcenterY - hat[currenthat].y + offsets[2] + yadd)
						elseif v.animationstate == "dead" then
							if hat[currenthat].directions then
								local graphic = hat[currenthat].graphic
								if hat[currenthat].death then
									graphic = hat[currenthat].death
								end
								love.graphics.draw(graphic, hat[currenthat].quad[2], math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - hat[currenthat].x + offsets[1], v.quadcenterY - hat[currenthat].y + offsets[2] + yadd)
							end
						elseif v.fence then
							love.graphics.draw(hat[currenthat].graphic, hat[currenthat].quad[3], math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - hat[currenthat].x + offsets[1], v.quadcenterY - hat[currenthat].y + offsets[2] + yadd)
						else
							love.graphics.draw(hat[currenthat].graphic, hat[currenthat].quad[1], math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, v.quadcenterX - hat[currenthat].x + offsets[1], v.quadcenterY - hat[currenthat].y + offsets[2] + yadd)
						end
						yadd = yadd + hat[currenthat].height
					end
				end
			end
		
			--bunny mario
			if (v.size == 11 or (v.fireenemy and v.fireenemy.bunnyears)) then
				local frame = 1
				if v.float then
					frame = (math.floor(v.floattimer*20-1)%2)+1
				elseif v.animationstate == "running" and v.runframe == 3 then
					frame = 2
				end
				if v.starred or v.animation == "grow2" then
					love.graphics.setColor(v.colors[3])
				else
					love.graphics.setColor(1, 1, 1, a)
				end
				local img = bunnyearsimg
				if v.character and v.characterdata and v.characterdata.bunnyears then
					img = v.characterdata.bunnyears
				end
				love.graphics.draw(img, bunnyearsquad[frame], math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, v.quadcenterX + offsets[1] + 3, v.quadcenterY + offsets[2] + 6)
			end

			--helmet
			if v.helmet and not v.statue then
				love.graphics.setColor(1, 1, 1, a)
				local img, q = koopaimage, koopaquad[spriteset][3]
				local ox, oy = v.characterdata.helmetoffsetX, v.characterdata.helmetoffsetY
				if v.graphic == v.capegraphic then
					ox = v.characterdata.helmetcapeoffsetX
				elseif v.graphic == v.tanookigraphic or v.graphic == v.raccoongraphic then
					ox = v.characterdata.helmetraccoonoffsetX
				elseif v.graphic == v.froggraphic then --frog
					oy = v.characterdata.helmetfrogoffsetX
					ox = v.characterdata.helmetfrogoffsetX
				elseif v.graphic == v.skinnygraphic then
					ox = v.characterdata.helmetskinnyoffsetX
					oy = v.characterdata.helmetskinnyoffsetY
				elseif v.size > 1 then
					if v.graphic == v.smallgraphic and v.animationstate ~= "grow" then
					else
						ox = v.characterdata.helmetbigoffsetX
					end
				elseif v.graphic == v.tinygraphic then --tiny
					oy = v.characterdata.helmettinyoffsetX
					ox = v.characterdata.helmettinyoffsetX
				end
				if v.helmet == "beetle" then
					img = helmetshellimg
					q = helmetshellquad[spriteset][1][1]
					if not (v.ducking or v.yoshi) then --tilt hat when sliding
						if v.fence then
							q = helmetshellquad[spriteset][1][2]
							--ox = ox -2
						elseif (v.spinanimationtimer < raccoonspintime and (v.spinframez == 1 or v.spinframez == 3) and (not v.shoe)) then
							q = helmetshellquad[spriteset][1][2]
							ox = ox + v.characterdata.helmetspinoffsetX
						end
					end
				elseif v.helmet == "spikey" then
					img = helmetshellimg
					q = helmetshellquad[spriteset][2][1]
					if not (v.ducking or v.yoshi) then --tilt hat when sliding
						if v.fence then
							q = helmetshellquad[spriteset][2][2]
							--ox = ox -2
						elseif (v.spinanimationtimer < raccoonspintime and (v.spinframez == 1 or v.spinframez == 3) and (not v.shoe)) then
							q = helmetshellquad[spriteset][2][2]
							ox = ox + v.characterdata.helmetspinoffsetX
						end
					end
				elseif v.helmet == "propellerbox" then
					img = helmetpropellerimg
					q = helmetpropellerquad[math.floor(v.helmetanimtimer)]
					ox = ox + v.characterdata.propellerhelmetoffsetX
					oy = oy + v.characterdata.propellerhelmetoffsetY
				elseif v.helmet == "cannonbox" then
					img = helmetcannonimg
					q = helmetcannonquad[math.floor(v.helmetanimtimer)]
					ox = ox + v.characterdata.cannonhelmetoffsetX
					oy = oy + v.characterdata.cannonhelmetoffsetY
				end
				if img and q then
					love.graphics.draw(img, q, math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, v.quadcenterX + offsets[1] + ox, v.quadcenterY + offsets[2] + oy)
				end
			end
		end

		if not (v.character and v.characterdata and v.characterdata.portalgununderhat) then
			if v.graphic[0] then
				if drop then
					love.graphics.setColor(dropshadowcolor)
				else
					love.graphics.setColor(1, 1, 1, a)
				end
				love.graphics.draw(v.graphic[0], v.quad, math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, v.quadcenterX, v.quadcenterY)
			end
		end
		
		--cape on top (fence climbing)
		if (v.graphic == v.capegraphic or (v.fireenemy and v.fireenemy.cape)) and (not v.capefly) then
			local frame = v.capeframe or 1
			if frame == 18 then
				local offx, offy = v.characterdata.capeimgfenceoffsetX, 0
				love.graphics.setColor(1, 1, 1, a)
				local img = capeimg
				if v.character and v.characterdata and v.characterdata.capeimg then
					img = v.characterdata.capeimg
				end
				love.graphics.draw(img, capequad[frame], math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, dirscale, horscale, v.quadcenterX + offx, v.quadcenterY + offy)
			end
		end
	end

	--minecraft pickaxe
	if playertype == "minecraft" then
		love.graphics.setColor(1, 1, 1, a)
		local angleframe = getAngleFrame(v.pointingangle+v.rotation, v)
		love.graphics.draw(minecraftpickaxeimg, minecraftpickaxequad[angleframe], math.floor(((px+v.width/2-xscroll)*16)*scale), math.floor(((py+v.height/2-yscroll-.5)*16)*scale), pr, dirscale, horscale, 10, 10)
	elseif v.portalgun and v.characterdata.nopointing and v.characterdata.portalgunoverlay then
		love.graphics.setColor(1, 1, 1, a)
		local angleframe = getAngleFrame(v.pointingangle+v.rotation, v)
		love.graphics.draw(portalgunimg, minecraftpickaxequad[angleframe], math.floor(((px+v.width/2-xscroll)*16)*scale), math.floor(((py+v.height/2-yscroll-.5)*16)*scale), pr, dirscale, horscale, 10, 10)
	end
	
	--goomba shoe & cloud
	if v.shoe == "cloud" then
		local y = -offsetY - (v.height*16) + v.characterdata.cloudimgoffsetY
		if v.animationscaley == 3 then
			y = -offsetY - (v.height*16) + v.characterdata.cloudimghugeoffsetY
		elseif v.animationscaley == 2 then
			y = -offsetY - (v.height*16) + v.characterdata.cloudimghugeclassicoffsetY
		end
		if v.cloudtimer > 1 or (math.floor(v.cloudtimer*20)%2 == 0) then
			love.graphics.draw(bigcloudimg, bigcloudquad[spriteset], math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), pr, -dirscale, horscale, 10, y)
		end
	elseif v.shoe == "drybonesshell" then
		local frame = 1
		local y = -offsetY - (v.height*16) + v.characterdata.drybonesshellimgoffsetY
		if v.animationscaley == 3 then
			y = -offsetY - (v.height*16) + v.characterdata.drybonesshellimghugeoffsetY
		elseif v.animationscaley == 2 then
			y = -offsetY - (v.height*16) + v.characterdata.drybonesshellimghugeclassicoffsetY
		end
		if v.lavasurfing then
			--it's a season pass, haha get it?
			--...
			--does anyone read these?

			--i changed some stuff around so this joke no longer makes any sense but imma just leave it
			frame = ((math.floor(coinanimation*(5/6)-1))%4)+1
			if not drop then
				v.lavasurfing = false
			end
		end
		if v.ducking then
			local shakex = 0
			frame = 4
			if v.drybonesshelltimer > drybonesshelltime-0.2 or v.drybonesshelltimer < 0.2 then
				frame = 3
			elseif v.drybonesshelltimer < 1 then
				shakex = math.floor((v.drybonesshelltimer*10)%3)-1
			end
			y = y + v.characterdata.drybonesshellimgduckingoffsetY
			if v.animationscaley == 3 then
				y = y + v.characterdata.drybonesshellimghugeduckingoffsetY
			elseif v.animationscaley == 2 then
				y = y + v.characterdata.drybonesshellimghugeclassicduckingoffsetY
			end
			love.graphics.draw(drybonesimage, drybonesquad[spriteset][frame], math.floor(((px-xscroll)*16+offsetX+shakex)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), v.rotation, -dirscale, horscale, 8, y)
		else
			love.graphics.draw(drybonesshellimg, starquad[spriteset][frame], math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), v.rotation, -dirscale, horscale, 8, y)
		end
	elseif v.shoe and v.shoe ~= "yoshi" then
		local frame = ((math.floor(coinanimation*(5/6)-4))%2)+4
		if v.shoe == "heel" then
			frame = 6
		end
		local y = -offsetY - (v.height*16) + v.characterdata.shoeimgoffsetY
		if v.animationscaley == 3 then
			y = -offsetY - (v.height*16) + v.characterdata.shoeimghugeoffsetY
		elseif v.animationscaley == 2 then
			y = -offsetY - (v.height*16) + v.characterdata.shoeimghugeclassicoffsetY
		end
		love.graphics.draw(goombashoeimg, goombashoequad[spriteset][frame], math.floor(((px-xscroll)*16+offsetX)*scale), math.floor(((py-yscroll)*16-offsetY)*scale), v.rotation, -dirscale, horscale, 8, y)
	end

	--ice block
	if v.frozen then
		love.graphics.setColor(1, 1, 1, a)
		local w, h = math.ceil(v.width)*2+1, math.ceil(v.height)*2+1
		for x = 1, w do
			for y = 1, h do
				local q = 5
				if x == 1 and y == 1 then
					q = 1
				elseif x == w and y == 1 then
					q = 3
				elseif x == 1 and y == h then
					q = 7
				elseif x == w and y == h then
					q = 9
				elseif y == 1 then
					q = 2
				elseif x == 1 then
					q = 4
				elseif y == h then
					q = 8
				elseif x == w then
					q = 6
				end
				love.graphics.draw(iceimg, icequad[q], math.floor(((v.x+v.width/2-xscroll)*16+8*(x-1)-(w/2)*8)*scale),
					math.floor(((v.y+v.height/2-yscroll)*16-12+8*(y-1)-(h/2)*8)*scale), 0, scale, scale)
			end
		end
	end
	
	--sledge bro freeze
	if v.groundfreeze and not v.frozen then
		local num = v.groundfreeze*100
		local shake = math.floor(num-math.floor(num/2)*2)*2
		love.graphics.draw(shockimg, shockquad[1], math.floor(((px-xscroll)*16-8+shake)*scale), math.floor(((py-yscroll)*16-13)*scale), 0, scale, scale)
		love.graphics.draw(shockimg, shockquad[2], math.floor(((px+v.width-xscroll)*16+4-shake)*scale), math.floor(((py-yscroll)*16-13)*scale), 0, scale, scale)
	end
	
	if (CLIENT or SERVER) and playerlist[v.playernumber] and (not drop) and (not NoOnlineMultiplayerNames) then --display nickname
		local nick = playerlist[v.playernumber].nick
		
		--[[local background = {1, 1, 1, .5}
		
		local adds = 0
		for i = 1, #playerlist[v.playernumber].colors[1] do
			adds = adds + playerlist[v.playernumber].colors[1][i]
		end
		
		if adds/3 > 40 then
			background = {0, 0, 0}
		end]]

		love.graphics.setColor(playerlist[v.playernumber].colors[1][1], playerlist[v.playernumber].colors[1][2], playerlist[v.playernumber].colors[1][3], .5)
		properprintbackground(nick, math.floor(((px-xscroll+v.width/2)*16-((#nick*8)/2))*scale), math.floor(((py-yscroll)*16-28)*scale), true)--, background)
	end
end

function drawHUD()
	if HITBOXDEBUG and HITBOXDEBUGANIMS then
		return
	end
	local properprintfunc = properprintF
	if hudoutline then
		properprintfunc = properprintFbackground
	end
	love.graphics.setColor(hudtextcolor)
	love.graphics.translate(0, -yoffset*scale)
	if yoffset < 0 then
		love.graphics.translate(0, yoffset*scale)
	end

	local cy = 32 --collectable coin ui y
		
	if hudsimple then
		cy = 22

		--properprintfunc(playername .. " * " .. tostring(mariolives[1]), 16*scale, 8*scale)
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(coinanimationimage, coinanimationquads[spriteset or 1][coinframe or 1], 16*scale, 12*scale, 0, scale, scale)
		love.graphics.setColor(hudtextcolor)
		properprintfunc("*" .. addzeros((mariocoincount or 0), 2), 24*scale, 12*scale)
		
		properprintfunc(addzeros((marioscore or 0), 9), (width*16-56-(9*8))*scale, 12*scale)
		
		love.graphics.draw(hudclockimg, hudclockquad[hudoutline], (width*16-49)*scale, 11*scale, 0, scale, scale)
		if gamestate == "game" then
			properprintfunc(addzeros(math.ceil(mariotime), 3), (width*16-40)*scale, 12*scale)
		else
			properprintfunc("000", (width*16-40)*scale, 12*scale)
		end
	else
		properprintfunc(playername, uispace*.5 - 24*scale, 8*scale)
		properprintfunc(addzeros((marioscore or 0), 6), uispace*0.5-24*scale, 16*scale)
		
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(coinanimationimage, coinanimationquads[spriteset or 1][coinframe or 1], uispace*1.5-16*scale, 16*scale, 0, scale, scale)
		love.graphics.setColor(hudtextcolor)
		properprintfunc("*" .. addzeros((mariocoincount or 0), 2), uispace*1.5-8*scale, 16*scale)
		
		properprintfunc(TEXT["world"], uispace*2.5 - 20*scale, 8*scale)
		local world = marioworld
		if hudworldletter and tonumber(world) and world > 9 and world <= 9+#alphabet then
			world = alphabet:sub(world-9, world-9)
		elseif world == "M" then
			world = " "
		end
		properprintfunc((world or 1) .. "-" .. (mariolevel or 1), uispace*2.5 - 12*scale, 16*scale)
		
		properprintfunc(TEXT["time"], uispace*3.5 - 16*scale, 8*scale)
		if editormode then
			if editorstate == "linktool" then
				properprintfunc(TEXT["link"], uispace*3.5 - 16*scale, 16*scale)
			else
				properprintfunc(TEXT["edit"], uispace*3.5 - 16*scale, 16*scale)
			end
		elseif gamestate == "game" then
			properprintfunc(addzeros(math.ceil(mariotime), 3), uispace*3.5-8*scale, 16*scale)
		end
	end

	if gamestate == "game" then
		if neurotoxin then
			if not hudoutline then
				love.graphics.setColor(0, 0, 0)
				properprintfunc(TEXT["neurotoxin time: "] .. math.floor(toxintime), uispace*.5 - 24*scale, 35*scale)
			end
			love.graphics.setColor(32/255, 56/255, 236/255)
			properprintfunc(TEXT["neurotoxin time: "] .. math.floor(toxintime), uispace*.5 - 24*scale, 34*scale)
		end

		for i = 1, #collectablescount do
			if collectablescount[i] > 0 and (not hudhidecollectables[i]) then
				love.graphics.setColor(1, 1, 1)
				love.graphics.draw(collectableuiimg, collectableuiquad[spriteset or 1][i][coinframe or 1], 16*scale, cy*scale, 0, scale, scale)
				love.graphics.setColor(hudtextcolor)
				properprintfunc("*" .. collectablescount[i], 24*scale, cy*scale)
				cy = cy + 10
			end
		end

		if players == 1 and objects["player"][1].key and objects["player"][1].key > 0 then
			love.graphics.setColor(1, 1, 1)
			love.graphics.draw(keyuiimg, keyuiquad[spriteset or 1][coinframe or 1], 16*scale, cy*scale, 0, scale, scale)
			love.graphics.setColor(hudtextcolor)
			properprintfunc("*" .. objects["player"][1].key, 24*scale, cy*scale)
			cy = cy + 10
		end

		if players == 1 and objects["player"][1].health and objects["player"][1].characterdata.healthimg then
			local c = objects["player"][1].characterdata
			local p = objects["player"][1]
			local health = p.health
			local maxhealth = c.health
			love.graphics.setColor(1, 1, 1)
			for y = 1, maxhealth do
				local qi = 1
				if y > health then
					qi = 2
				end
				love.graphics.draw(c.healthimg, c.healthquad[qi], 16*scale, (cy+(c.healthimg:getHeight()/2)*(y-1))*scale, 0, scale, scale)
			end
			cy = cy + c.healthimg:getHeight()
		end
	end
end

function drawmultiHUD()
	--multiplayer hud
	local properprintfunc = properprintF
	if hudoutline then
		properprintfunc = properprintFbackground
	end
	
	local livesdisplay = (mariolivecount ~= false)
	if (not livesdisplay) and objects and objects["player"] then
		--should the lives counter be displayed?
		for i = 1, players do
			local p = objects["player"][i]
			if p and ((p.key and p.key > 0) or (p.health and p.characterdata.healthimg)) then
				livesdisplay = true
				break
			end
		end
	end

	if livesdisplay then
		for i = 1, players do
			--lives
			local s
			if (mariolivecount ~= false) then
				s = "p" .. i .. " * " .. mariolives[i]
			else
				s = "p" .. i
			end

			local x = (width*16)/players/2 + (width*16)/players*(i-1)
			local cx = x-string.len(s)*4-4
			local cy = 25 --offset y

			--display lives
			love.graphics.setColor(1, 1, 1, 1)
			properprintfunc(s, (cx+8)*scale, cy*scale)
			if hudoutline then
				love.graphics.setColor(0, 0, 0)
				love.graphics.rectangle("fill", (cx-1)*scale, (cy-1)*scale, 9*scale, 9*scale)
			end
			love.graphics.setColor(mariocolors[i][1])
			love.graphics.rectangle("fill", (cx)*scale, cy*scale, 7*scale, 7*scale)
			love.graphics.setColor(1, 1, 1, 1)
			cy = cy + 10

			if objects and objects["player"] and objects["player"][i] then
				local p = objects["player"][i]
				--health
				if p.health and p.characterdata.healthimg then
					love.graphics.setColor(1, 1, 1)
					local s = "hp: " .. p.health
					properprintfunc(s, cx*scale, cy*scale)
					cy = cy + 10
				end
				--keys
				if p.key and p.key > 0 then
					love.graphics.setColor(1, 1, 1)
					local s = "*" .. p.key
					love.graphics.draw(keyuiimg, keyuiquad[spriteset or 1][coinframe or 1], cx*scale, cy*scale, 0, scale, scale)
					properprintfunc(s, (cx+9)*scale, cy*scale)
					cy = cy + 10
				end
			end
		end
	end
end

function updatesplitscreen()
	if players == 2 then
		if #splitscreen == 1 then
			if math.abs(objects["player"][1].x - objects["player"][2].x) > width - scrollingstart - scrollingleftstart then
				if objects["player"][1].x < objects["player"][2].x then
					splitscreen = {{1}, {2}}
				else
					splitscreen = {{2}, {1}}
				end
				
				splitxscroll = {xscroll, xscroll+width/2}
				generatespritebatch()
			end
		else
			if splitxscroll[2] <= splitxscroll[1]+width/2 then
				splitscreen = {{1, 2}}
				
				xscroll = splitxscroll[1]
				generatespritebatch()
			end
		end
	end
end

function startlevel(level, reason)
	skipupdate = true
	love.keyboard.setKeyRepeat(false)
	local oldmusici, oldcustommusic
	if continuesublevelmusic and reason and reason == "sublevel" then
		if pbuttonsound:isPlaying() then
			love.audio.stop()
		else
			for i, v in pairs(soundlist) do
				v:stop()
			end
			oldmusici, oldcustommusic = musici, custommusic
		end
	else
		love.audio.stop()
	end
	animationsystem_load()

	local sublevel = false
	if type(level) == "number" then
		sublevel = true
	end
	
	if level and level == "dc" then --daily challenge skip
		dcplaying = true
	else
		if sublevel then
			--print("previoussublevel set to ", mariosublevel)
			prevsublevel = mariosublevel
			mariosublevel = level
			if level ~= 0 then
				level = marioworld .. "-" .. mariolevel .. "_" .. level
			else
				level = marioworld .. "-" .. mariolevel
			end
		else
			mariosublevel = 0
			prevsublevel = false
			mariotime = 400
		end
		dcplaying = false
	end
	--dumb stupid work around
	if animationprevsublevel then
		prevsublevel = animationprevsublevel
		animationprevsublevel = false
	end
	
	--MISC VARS
	everyonedead = false
	levelfinished = false
	coinanimation = 1
	flaganimation = 1
	flagx = false
	flagborder = true
	showcastleflag = true
	levelfinishtype = nil
	firestartx = false
	firestarted = false
	firedelay = math.random(4)
	flyingfishdelay = 1
	flyingfishstarted = false
	flyingfishstartx = false
	flyingfishendx = false
	meteordelay = 1
	meteorstarted = false
	meteorstartx = false
	meteorendx = false
	bulletbilldelay = 1
	bulletbillstarted = false
	bulletbillstartx = false
	bulletbillendx = false
	bigbilldelay = 1
	bigbillstarted = false
	bigbillstartx = false
	bigbillendx = false
	windstarted = false
	windstartx = false
	windentityspeed = windspeed
	windendx = false
	firetimer = firedelay
	flyingfishtimer = flyingfishdelay
	meteortimer = meteordelay
	bulletbilltimer = bulletbilldelay
	bigbilltimer = bigbilldelay
	windleaftimer = 0.1
	axex = false
	axey = false
	lakitoendx = false
	lakitoend = false
	angrysunendx = false
	angrysunend = false
	noupdate = false
	xscroll = 0
	yscroll = 0
	prevxscroll = 0
	prevyscroll = 0
	xpan = false
	ypan = false
	splitscreen = {{}}
	checkpoints = {}
	checkpointpoints = {}
	repeatX = 0
	lastrepeat = 0
	displaywarpzonetext = false
	for i = 1, players do
		table.insert(splitscreen[1], i)
	end
	checkpointi = 0
	mazesfuck = true
	mazestarts = {}
	mazeends = {}
	mazesolved = {}
	mazesolved[0] = true
	mazeinprogress = false
	earthquake = 0
	sunrot = 0
	gelcannontimer = 0
	pausemenuselected = 1
	coinblocktimers = {}
	autoscroll = true
	autoscrollx = true
	autoscrolly = true
	
	portaldelay = {}
	for i = 1, players do
		portaldelay[i] = 0
	end
	
	--Minecraft
	breakingblockX = false
	breakingblockY = false
	breakingblockprogress = 0
	
	--class tables
	coinblockanimations = {}
	scrollingscores = {}
	portalparticles = {}
	portalprojectiles = {}
	emancipationgrills = {}
	laserfields = {}
	platformspawners = {}
	rocketlaunchers = {}
	bigbilllaunchers = {}
	kingbilllaunchers = {}
	cannonballlaunchers = {}
	userects = {}
	blockdebristable = {}
	fireworks = {}
	seesaws = {}
	bubbles = {}
	poofs = {}
	dialogboxes = {}
	rainbooms = {}
	emancipateanimations = {}
	emancipationfizzles = {}
	miniblocks = {}
	inventory = {}
	for i = 1, 9 do
		inventory[i] = {}
	end
	mccurrentblock = 1
	itemanimations = {}
	snakeblocks = {}
	clearpipes = {}
	tracks = {}
	spawnanimations = {}
	pipes = {}
	exitpipes = {}
	
	blockbounce = {}
	warpzonenumbers = {}
	
	portals = {}
	blockedportaltiles = {}
	
	objects = {}
	objects["player"] = {}
	objects["portalwall"] = {}
	objects["tile"] = {}
	objects["tilemoving"] = {}
	objects["enemy"] = {}
	objects["goomba"] = {}
	objects["koopa"] = {}
	objects["mushroom"] = {}
	objects["flower"] = {}
	objects["oneup"] = {}
	objects["star"] = {}
	objects["vine"] = {}
	objects["box"] = {}
	objects["door"] = {}
	objects["button"] = {}
	objects["groundlight"] = {}
	objects["wallindicator"] = {}
	objects["walltimer"] = {}
	objects["notgate"] = {}
	objects["lightbridge"] = {}
	objects["lightbridgebody"] = {}
	objects["faithplate"] = {}
	objects["laser"] = {}
	objects["laserdetector"] = {}
	objects["gel"] = {}
	objects["geldispenser"] = {}
	objects["cubedispenser"] = {}
	objects["pushbutton"] = {}
	objects["bulletbill"] = {}
	objects["hammerbro"] = {}
	objects["hammer"] = {}
	objects["fireball"] = {}
	objects["platform"] = {}
	objects["platformspawner"] = {}
	objects["plant"] = {}
	objects["castlefire"] = {}
	objects["castlefirefire"] = {}
	objects["fire"] = {}
	objects["bowser"] = {}
	objects["spring"] = {}
	objects["cheep"] = {}
	objects["flyingfish"] = {}
	objects["upfire"] = {}
	objects["seesawplatform"] = {}
	objects["ceilblocker"] = {}
	objects["lakito"] = {}
	objects["squid"] = {}
	objects["poisonmush"] = {}
	objects["bigbill"] = {}
	objects["kingbill"] = {}
	objects["sidestepper"] = {}
	objects["barrel"] = {}
	objects["icicle"] = {}
	objects["angrysun"] = {}
	objects["splunkin"] = {}
	objects["threeup"] = {}
	objects["brofireball"] = {}
	objects["smbsitem"] = {}
	objects["thwomp"] = {}
	objects["fishbone"] = {}
	objects["drybones"] = {}
	objects["muncher"] = {}
	objects["meteor"] = {}
	objects["donut"] = {}
	objects["boomerang"] = {}
	objects["parabeetle"] = {}
	objects["ninji"] = {}
	objects["hammersuit"] = {}
	objects["mariohammer"] = {}
	objects["boo"] = {}
	objects["mole"] = {}
	objects["bigmole"] = {}
	objects["bomb"] = {}
	objects["plantfire"] = {}
	objects["flipblock"] = {}
	objects["torpedoted"] = {}
	objects["torpedolauncher"] = {}
	objects["frogsuit"] = {}
	objects["boomboom"] = {}
	objects["levelball"] = {}
	objects["leaf"] = {}
	objects["mariotail"] = {}
	objects["windleaf"] = {}
	objects["energylauncher"] = {}
	objects["energyball"] = {}
	objects["energycatcher"] = {}
	objects["turret"] = {}
	objects["turretshot"] = {}
	objects["blocktogglebutton"] = {}
	objects["buttonblock"] = {}
	objects["squarewave"] = {}
	objects["delayer"] = {}
	objects["coin"] = {}
	objects["frozencoin"] = {}
	objects["amp"] = {}
	objects["fuzzy"] = {}
	objects["funnel"] = {}
	objects["longfire"] = {}
	objects["cannonball"] = {}
	objects["cannonballcannon"] = {}
	objects["rocketturret"] = {}
	objects["turretrocket"] = {}
	objects["glados"] = {}
	objects["core"] = {}
	objects["pedestal"] = {}
	objects["portalent"] = {}
	objects["text"] = {}
	objects["regiontrigger"] = {}
	objects["tiletool"] = {}
	objects["iceball"] = {}
	objects["enemytool"] = {}
	objects["randomizer"] = {}
	objects["yoshiegg"] = {}
	objects["yoshi"] = {}
	objects["musicchanger"] = {}
	objects["pbutton"] = {}
	objects["pokey"] = {}
	objects["chainchomp"] = {}
	objects["rockywrench"] = {}
	objects["wrench"] = {}
	objects["koopaling"] = {}
	objects["checkpoint"] = {}
	objects["doorsprite"] = {}
	objects["magikoopa"] = {}
	objects["skewer"] = {}
	objects["belt"] = {}
	objects["animationtrigger"] = {}
	objects["animationoutput"] = {}
	objects["animatedtiletrigger"] = {}
	objects["rsflipflop"] = {}
	objects["orgate"] = {}
	objects["andgate"] = {}
	objects["collectable"] = {}
	objects["collectablelock"] = {}
	objects["powblock"] = {}
	objects["smallspring"] = {}
	objects["risingwater"] = {}
	objects["redseesaw"] = {}
	objects["snakeblock"] = {}
	objects["spike"] = {}
	objects["spikeball"] = {}
	objects["camerastop"] = {}
	objects["clearpipesegment"] = {}
	objects["plantcreeper"] = {}
	objects["plantcreepersegment"] = {}
	objects["tracksegment"] = {}
	objects["trackcontroller"] = {}
	objects["checkpointflag"] = {}
	objects["ice"] = {}
	objects["grinder"] = {}
	
	objects["cappy"] = {}
	
	objects["screenboundary"] = {}
	objects["screenboundary"]["left"] = screenboundary:new(0)
	
	splitxscroll = {0}
	splityscroll = {0}
	setscreenzoom(1)
	
	startx = 3
	starty = 13
	pipestartx = nil
	pipestarty = nil
	pipestartdir = nil
	local animation = nil
	
	enemiesspawned = {}
	
	for i = 1, #animatedtiles do
		animatedtiles[i].timer = 0
		animatedtiles[i].quadi = 1
	end
	
	intermission = false
	haswarpzone = false
	underwater = false
	bonusstage = false
	custombackground = false
	customforeground = false
	autoscrolling = false
	autoscrollingspeed = autoscrollingdefaultspeed
	autoscrollingx = false
	autoscrollingy = false
	edgewrapping = false
	lightsout = false
	lightsoutwave = 0
	lowgravity = false
	portalgun = true
	portalguni = 1
	musici = 1
	custommusici = 1
	mariotimelimit = 400
	spriteset = 1
	backgroundrgb = {0, 0, 0}
	breakoutmode = nil
	queuelowtime = false
	
	--GLaDOS
	neurotoxin = false
	toxintime = 150

	setphysics(currentphysics)
	setcamerasetting(camerasetting)
	
	--LOAD THE MAP
	if level == "dc" then --create daily challenge
		createdailychallenge()
	elseif loadmap(level) == false then --make one up
		mapwidth = width
		originalmapwidth = mapwidth
		mapheight = 15
		map = {}
		bmap_on = false --enabled?
		for x = 1, width do
			map[x] = {}
			for y = 1, mapheight do
				if y > 13 then
					map[x][y] = {2}
					objects["tile"][tilemap(x, y)] = tile:new(x-1, y-1, 1, 1, true)
					map[x][y]["gels"] = {}
					map[x][y]["portaloverride"] = nil
				else
					map[x][y] = {1}
					map[x][y]["gels"] = {}
					map[x][y]["portaloverride"] = nil
				end
			end
		end
		
		background = 1
		backgroundrgbon = false
	else
		if sublevel == false and mariosublevel ~= 0 then
			level = marioworld .. "-" .. mariolevel
			mariosublevel = 0
			loadmap(level)
		end
	end
	originalmapwidth = mapwidth
	
	if musici > 7 then
		custommusic = mappackfolder .. "/" .. mappack .. "/" .. musictable[musici]
	else
		custommusic = custommusics[custommusici]
	end
	
	objects["screenboundary"]["right"] = screenboundary:new(mapwidth)
	
	if flagx then
		if not flagborder then
			objects["screenboundary"]["flag"] = screenboundary:new(mapwidth)
		else
			objects["screenboundary"]["flag"] = screenboundary:new(flagx+6/16)
		end
	end
	
	if axex then
		objects["screenboundary"]["axe"] = screenboundary:new(axex+1)
	end
	
	if intermission then
		animation = "intermission"
	end
	
	if (not sublevel) or (editormode and not testlevel) then
		mariotime = mariotimelimit
	--[[elseif subleveltest then --i dont know what this is but it makes the time reset update: apparently for the editor?
		mariotime = mariotimelimit]]
	end
	
	--Maze setup
	--check every block between every start/end pair to see how many gates it contains
	if #mazestarts == #mazeends then
		mazegates = {}
		for i = 1, #mazestarts do
			local maxgate = 1
			for x = mazestarts[i], mazeends[i] do
				for y = 1, mapheight do
					if map[x][y][2] and entityquads[map[x][y][2]].t == "mazegate" then
						if tonumber(map[x][y][3]) > maxgate then
							maxgate = tonumber(map[x][y][3])
						end
					end
				end
			end
			mazegates[i] = maxgate
		end
	else
		print("Mazenumber doesn't fit!")
	end
	
	--background
	if backgroundrgbon == true then
		love.graphics.setBackgroundColor(unpack(backgroundrgb))
	else
		love.graphics.setBackgroundColor(backgroundcolor[background])
	end

	--portalgun (NOT NEEDED)
	portalsavailable = {true, true}
	
	--check if it's a bonusstage (boooooooonus!)
	if bonusstage then
		animation = "vinestart"
	end
	
	--set startx to checkpoint
	if checkpointx and checkcheckpoint then
		startx = checkpointx
		starty = checkpointpoints[checkpointx] or mapheight - 2
		
		--clear enemies from spawning near
		for y = starty-15, starty+15 do
			for x = startx-8, startx+8 do
				if inmap(x, y) and #map[x][y] > 1 then
					if tablecontains(checkpointignoreenemies, entityquads[map[x][y][2]].t) 
						or (tablecontains(customenemies, entityquads[map[x][y][2]].t)
						and enemiesdata[map[x][y][2]] and
						enemiesdata[map[x][y][2]].dontspawnnearcheckpoint) then
						table.insert(enemiesspawned, {x, y})
					end
				end
			end
		end
		
		--find which i it is
		for i = 1, #checkpoints do
			if checkpointx == checkpoints[i] then
				checkpointi = i
			end
		end
		--was the checkpoint a flag?
		if objects["checkpointflag"][checkpointx] then
			startx = checkpointx - .5 
			objects["checkpointflag"][checkpointx]:activate(1)
		end
	end
	
	--set startx to pipestart
	if pipestartx then
		startx = pipestartx-1
		starty = pipestarty
		if pipestartdir == "right" or pipestartdir == "left" then
			startx = pipestartx
		end
		--check if startpos is a colliding block
		if ismaptile(pipestartx, pipestarty) and tilequads[map[pipestartx][pipestarty][1]].collision then
			local p = exitpipes[tilemap(pipestartx,pipestarty)]
			if p then
				if p.dir == "down" then
					animation = "pipedownexit"
					startx = p.x
				elseif p.dir == "right" then
					animation = "piperightexit"
					startx = pipestartx-1
				elseif p.dir == "left" then
					animation = "pipeleftexit"
					startx = pipestartx-1
				else
					animation = "pipeupexit"
					startx = p.x
				end
			else
				print("no exit pipe entity found! ", pipestartx, " ", pipestarty)
			end
		end
	end
	--reset pipe exit id
	pipeexitid = false
	
	if autoscrollingx then
		--start further left
		splitxscroll = {startx-scrollingleftcomplete-5}
	else
		splitxscroll = {startx-scrollingleftcomplete-2}
	end
	if splitxscroll[1] > mapwidth - width then
		splitxscroll[1] = mapwidth - width
	end
	
	if splitxscroll[1] < 0 then
		splitxscroll[1] = 0
	end
	
	splityscroll = {starty-height/2}
	
	if splityscroll[1] > mapheight-height-1 then
		splityscroll[1] = math.max(0, mapheight-height-1)
	end
	
	if splityscroll[1] < 0 then
		splityscroll[1] = 0
	end
	yscrolltarget = splityscroll[1]
	
	--add the players
	local mul = 0.5
	if mariosublevel ~= 0 or prevsublevel ~= false then
		mul = 2/16
	end

	if editormode then
		for i = 1, players do
			mariosizes[i] = 1
		end
	end

	objects["player"] = {}
	for i = 1, players do
		if pipestartx then
			mul = 2/16
			objects["player"][i] = mario:new(startx+(i-1)*mul, starty-1, i, animation, mariosizes[i], playertype, marioproperties[i])
		elseif startx then
			objects["player"][i] = mario:new(startx + (i-1)*mul-6/16, starty-1, i, animation, mariosizes[i], playertype, marioproperties[i])
		else
			objects["player"][i] = mario:new(1.5 + (i-1)*mul-6/16+1.5, 13, i, animation, mariosizes[i], playertype, marioproperties[i])
		end
	end
	
	if player_position and player_position[1] then
		--test from position
		objects["player"][1].x = player_position[1]
		objects["player"][1].y = player_position[2]
		camerasnap(player_position[3], player_position[4])
	end
	
	if camerasetting ~= 2 then --not 2 because its centered
		if startx and mapwidth > width*2 and startx > mapwidth-scrollingcompletev then
			scrollingstart = scrollingleftstartv
			scrollingcomplete = scrollingleftcompletev
			scrollingleftstart = scrollingstartv
			scrollingleftcomplete = scrollingcompletev

			if autoscrollingx then
				autoscrollingx = -autoscrollingx
			end
		else
			scrollingstart = scrollingstartv
			scrollingcomplete = scrollingcompletev
			scrollingleftstart = scrollingleftstartv
			scrollingleftcomplete = scrollingleftcompletev
		end
	end
		
	--ADD ENEMIES ON START SCREEN
	if editormode == false then
		local xtodo = width*screenzoom2+1
		if mapwidth < width*screenzoom2+1 then
			xtodo = mapwidth
		end
		for x = math.floor(splitxscroll[1]), math.floor(splitxscroll[1])+xtodo do
			for y = math.floor(splityscroll[1]), math.floor(splityscroll[1])+height*screenzoom2+2 do
				spawnenemyentity(x, y)
			end
		end
	end
	
	--PLAY BGM
	local doplaymusic = true
	if continuesublevelmusic then
		if (not intermission) and musici == oldmusici and custommusic == oldcustommusic then
			local playing, source = music:getPlaying()
			if (not (musici ~= 6 and playing == "starmusic")) then
				doplaymusic = false
			end
		end
		if doplaymusic then
			music:disableintromusic()
			music:stopall()
			stopmusic()
		end
	else
		stopmusic()
	end
	if doplaymusic and not NoMusic then
		if intermission == false then
			playmusic()
		else
			if musici == 7 and custommusic then
				playmusic()
			else
				playsound(intermissionsound)
			end
		end
	end
	
	--load editor
	if editormode then
		editor_load(player_position)
	end
	
	--Do stuff
	updateranges()

	--Activate Swtich block animations
	for anim = 1, #animationswitchtriggerfuncs do
		local t = animationswitchtriggerfuncs[anim]
		if tonumber((t[2] or 0)) then
			local color = tonumber((t[2] or 0))
			if solidblockperma[color] then
				t[1]:trigger()
			end
		end
	end

	--is it toad or no
	showtoad = not (tonumber(marioworld) and marioworld >= 8 and not love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/" .. marioworld+1 .. "-1.txt"))
	
	updatespritebatch()

	prevxscroll = splitxscroll[1]
	prevyscroll = splityscroll[1]
end

function loadmap(filename)
	print("Loading " .. mappackfolder .. "/" .. mappack .. "/" .. filename .. ".txt")
	
	if not love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/" .. filename .. ".txt") then
		print(mappackfolder .. "/" .. mappack .. "/" .. filename .. ".txt not found!")
		return false
	end
	local s = love.filesystem.read( mappackfolder .. "/" .. mappack .. "/" .. filename .. ".txt" )
	local s2 = s:split(";")
	
	if s2[2] and s2[2]:sub(1,7) == "height=" then
		mapheight = tonumber(s2[2]:sub(8,-1)) or 15
	elseif love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/heights/" .. marioworld .. "-" .. mariolevel .. "_" .. actualsublevel .. ".txt") then
		local s11 = love.filesystem.read(mappackfolder .. "/" .. mappack .. "/heights/" .. marioworld .. "-" .. mariolevel .. "_" .. actualsublevel .. ".txt")
		mapheight = tonumber(s11)
	else
		mapheight = 15
	end
	
	--MAP ITSELF
	local t = s2[1]:split(",")
	
	if math.fmod(#t, mapheight) ~= 0 then
		print("Incorrect number of entries: " .. #t)
		return false
	end
	
	mapwidth = #t/mapheight
	originalmapwidth = mapwidth
	
	map = {} --foreground map
	bmap_on = false --background map on?
	local nr, nr2 --map[x][y][1], map[x][y][2]

	for x = 1, mapwidth do
		map[x] = {}
		for y = 1, mapheight do
			map[x][y] = {}
			map[x][y]["gels"] = {}
			map[x][y]["portaloverride"] = nil
			
			local r = tostring(t[(y-1)*(#t/mapheight)+x]):split("-")
			
			nr = tonumber(r[1])
			if not nr then
				--background tile
				if not bmap_on then
					bmap_on = true
				end
				local tiles = r[1]:split("~")
				r[1] = tiles[1]
				nr = tonumber(r[1])
				map[x][y]["back"] = tonumber(tiles[2])
			elseif (nr > smbtilecount+portaltilecount+customtilecount and nr <= 90000) or nr > 90000+animatedtilecount then
				--tile doesn't exist
				r[1] = 1
			end

			--entity argument
			if r[2] and (not tonumber(r[2])) and r[2]:find(":") then
				local values = r[2]:split(":")
				r[2] = tonumber(values[1]) or values[1] --enemy
				map[x][y]["argument"] = values[2]
			end
			
			for i = 1, #r do
				if tonumber(r[i]) ~= nil then
					map[x][y][i] = tonumber(r[i])
				else
					map[x][y][i] = r[i]
					--check if custom enemy doesn't exist
					if editormode and i == 2 and not tablecontains(customenemies, r[i]) then
						print("custom enemy " .. r[i] .. " does not exist")
						map[x][y][i] = 1
					end
				end
			end
			
			--create object for block
			if tilequads[tonumber(r[1])].collision == true then
				objects["tile"][tilemap(x, y)] = tile:new(x-1, y-1, 1, 1, true)
			end
		end
	end
	
	
	--MORE STUFF
	for i = 2, #s2 do
		s3 = s2[i]:split("=")
		if s3[1] == "background" then
			if tonumber(s3[2]) ~= nil then
				background = tonumber(s3[2])
				backgroundrgbon = false
			else
				local s4 = s3[2]:split(",")
				background = 4
				backgroundrgbon = true
				backgroundrgb = {tonumber(s4[1])/255, tonumber(s4[2])/255, tonumber(s4[3])/255}
				backgroundcolor[4] = backgroundrgb
			end
		elseif s3[1] == "spriteset" then
			spriteset = tonumber(s3[2])
		elseif s3[1] == "intermission" then
			intermission = true
		elseif s3[1] == "haswarpzone" then
			haswarpzone = true
		elseif s3[1] == "underwater" then
			underwater = true
		elseif s3[1] == "music" then
			if tonumber(s3[2]) then
				musici = tonumber(s3[2])
			else
				musici = 2
				local name = s3[2]
				for i, m in pairs(musictable) do
					if m == name then
						musici = i
					end
				end
			end
		elseif s3[1] == "bonusstage" then
			bonusstage = true
		elseif s3[1] == "custombackground" or s3[1] == "portalbackground" then
			custombackground = (s3[2] or true)
		elseif s3[1] == "timelimit" then
			mariotimelimit = tonumber(s3[2])
		elseif s3[1] == "scrollfactor" then
			scrollfactor = tonumber(s3[2])
			scrollfactory = scrollfactor
		elseif s3[1] == "scrollfactory" then
			scrollfactory = tonumber(s3[2])
		elseif s3[1] == "scrollfactor2" then
			scrollfactor2 = tonumber(s3[2])
			scrollfactor2y = scrollfactor2
		elseif s3[1] == "scrollfactor2y" then
			scrollfactor2y = tonumber(s3[2])
		elseif s3[1] == "autoscrolling" then
			autoscrolling = true
			autoscrollingspeed = tonumber(s3[2]) or autoscrollingdefaultspeed
			if (mapheight > mapwidth) or (mapwidth == 25) then --vertical autoscrolling
				autoscrollingy = autoscrollingspeed
				autoscrollingx = false
			else --horizontal autoscrolling
				autoscrollingy = false
				autoscrollingx = autoscrollingspeed
			end
			
			if autoscrollingy and starty > mapheight/2 then
				autoscrollingy = -autoscrollingy
			end
		elseif s3[1] == "edgewrapping" then
			edgewrapping = true
		elseif s3[1] == "lightsout" then
			lightsout = true
			lightsoutwave = 0
		elseif s3[1] == "lowgravity" then
			lowgravity = true
			maxyspeed = lowgravitymaxyspeed
		elseif s3[1] == "customforeground" then
			customforeground = (s3[2] or true)
		elseif s3[1] == "noportalgun" then
			portalgun = false
			portalguni = 2
		elseif s3[1] == "portalguni" then
			portalguni = tonumber(s3[2])
			if portalguni == 2 then
				portalgun = false
			else
				portalgun = true
			end
		elseif s3[1] == "custommusic" then
			if tonumber(s3[2]) ~= nil then
				custommusici = tonumber(s3[2])
			end
		end
	end

	--ANIMATED TILES make lists of every tile in level
	for i = 1, #animatedtiles do
		if animatedtiles[i].cache then
			animatedtiles[i].cache = {}
			tilequads[i+90000].cache = {}
		end
	end

	--CUSTOM ENEMIES
	if editormode or testlevel then
		--reload custom enemies everytime level is loaded
		enemies_load()
	else
		--just update spritesets
		for name, t in pairs(enemiesdata) do
			loadenemyquad(name, "no notices")
		end
	end

	--ANIMATED TIMERS
	animatedtimers = {}
	animatedtimerlist = {}
	for x = 1, mapwidth do
		animatedtimers[x] = {}
	end

	for y = 1, mapheight do
		for x = 1, mapwidth do
			local r = map[x][y]
			
			if r[1] > 90000 then
				if tilequads[r[1]].triggered then
					animatedtimers[x][y] = animatedtimer:new(x, y, r[1])
				end
				if tilequads[r[1]].cache then
					table.insert(tilequads[r[1]].cache, {x=x,y=y})
				end
			end
			
			if #r > 1 and entityquads[r[2]] then
				local t = entityquads[r[2]].t
				if t == "spawn" then
					startx = x
					starty = y
					if r[3] and r[3] == "true" then
						startx = x-.5 --spawn exactly in the tile
					end
				elseif not editormode then
					--load non-enemy entities
					loadentity(t, x, y, r, r[2])
				elseif PipesInEditor and editormode then
					if t == "warppipe" or t == "pipe" or t == "pipe2" or t == "pipespawn" or t == "pipespawndown" or t == "pipespawnhor" then
						loadentity(t, x, y, r, r[2])
					end
				end
			elseif r[1] == 1 and (not editormode) then
				--save memory
				if (not r["back"]) and (not r["track"]) then
					map[x][y] = nil
					map[x][y] = emptytile
				end
			end
		end
	end

	--Add tracks
	for j, w in pairs(objects["platform"]) do
		if w.linked then
			trackobject(w.cox, w.coy, w, "platform")
		end
	end
	for j, w in pairs(objects["redseesaw"]) do
		trackobject(w.cox, w.coy, w, "redseesaw")
	end
	for j, w in pairs(objects["grinder"]) do
		trackobject(w.cox, w.coy, w, "grinder")
	end


	--sort checkpoints
	table.sort(checkpoints)
	
	--Add links
	for i, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.link then
				w:link()
			end
		end
	end
	--emancipation links
	for i, v in pairs(emancipationgrills) do
		v:link()
	end
	for i, v in pairs(laserfields) do
		v:link()
	end
	for i, v in pairs(kingbilllaunchers) do
		v:link()
	end
	for i, v in pairs(snakeblocks) do
		v:link()
	end
	for i, v in pairs(tracks) do
		v:link()
	end

	--create clear pipe intersections
	for i, v in pairs(clearpipes) do
		v:createintersection()
	end

	if flagx then
		flagimgx = flagx+8/16
		flagimgy = flagy-10+1/16
	end

	--not sure what this is? delete maybe?
	--[[for x = 0, -30, -1 do
		map[x] = {}
		for y = 1, 13 do
			map[x][y] = {1}
		end

		for y = 14, mapheight do
			map[x][y] = {2}
			objects["tile"][tilemap(x, y)] = tile:new(x-1, y-1, 1, 1, true)
		end
	end]]
	
	if custombackground then
		loadcustombackground(custombackground)
	end
	if customforeground then
		loadcustomforeground(customforeground)
	end
	
	return true
end

function bmapt(x, y, i) --get backgruond map tile TODO: Delete this?
	if bmap_on then
		if i == 1 and map[x] and map[x][y] and map[x][y]["back"] then
			return map[x][y]["back"]
		end
	end
	return false
end

function changemapwidth(width)
	if width > mapwidth then
		for x = mapwidth+1, width do
			map[x] = {}
			for y = 1, mapheight-2 do
				map[x][y] = {1}
				map[x][y]["gels"] = {}
				map[x][y]["portaloverride"] = nil
			end
		
			for y = mapheight-1, mapheight do
				map[x][y] = {2}
				objects["tile"][tilemap(x, y)] = tile:new(x-1, y-1, 1, 1, true)
				map[x][y]["gels"] = {}
				map[x][y]["portaloverride"] = nil
			end
		end
	end

	mapwidth = width
	objects["screenboundary"]["right"].x = mapwidth
	
	if objects["player"][1].x > mapwidth then
		objects["player"][1].x = mapwidth-1
	end
end

function changemapheight(height)
	if height > mapheight then
		for x = 1, mapwidth do
			for y = mapheight+1, height do
				map[x][y] = {1}
				map[x][y]["gels"] = {}
				map[x][y]["portaloverride"] = nil
			end
		end
	end
	mapheight = height
	if objects["player"][1].y > mapheight then
		objects["player"][1].y = mapheight-1
	end
end

--re-implement this. the only issue was a single frame of blank when starting the game
--EDIT: implemented again. Undo if there are errors
function generatespritebatch()
	queuespritebatchupdate = true
end

function updatespritebatch()
	local split = 1

	local smbmsb = smbspritebatch[1]
	local portalmsb = portalspritebatch[1]
	local custommsb
	if customtiles then
		custommsb = customspritebatch[1]
	end
	smbmsb:clear()
	portalmsb:clear()
	if customtiles then
		for i = 1, #custommsb do
			custommsb[i]:clear()
		end
	end
	
	local smbmbacksb = smbspritebatch[2]
	local portalmbacksb = portalspritebatch[2]
	local custommbacksb
	if customtiles then
		custommbacksb = customspritebatch[2]
	end
	smbmbacksb:clear()
	portalmbacksb:clear()
	if customtiles then
		for i = 1, #custommbacksb do
			custommbacksb[i]:clear()
		end
	end
	
	local xscroll, yscroll = splitxscroll[split], splityscroll[split]

	local xfromdraw,xtodraw, yfromdraw,ytodraw, xoff,yoff = getdrawrange(xscroll,yscroll,"spritebatch")
	
	local lmap = map
	
	for y = yfromdraw, ytodraw do
		for x = xfromdraw, xtodraw do
			local bounceyoffset = 0
			
			local draw = true
			if getblockbounce(x, y) then
				draw = false
			end
			if draw == true then
				if (not lmap[x]) then
					print("spritebatch tile doesnt exist " .. x)
				else
					local t = lmap[x][y]
					
					if t then
						local tilenumber = t[1]
						if tilenumber ~= 0 and tilequads[tilenumber].invisible == false and tilequads[tilenumber].coinblock == false and tilequads[tilenumber].coin == false 
							and (not tilequads[tilenumber].foreground) and ((not _3DMODE) or tilequads[tilenumber].collision) then
							if math.floor(tilenumber) <= smbtilecount then
								smbmsb:add( tilequads[tilenumber].quad, (x-1-xoff)*16*scale, ((y-1-yoff)*16-8)*scale, 0, scale, scale )
							elseif tilenumber <= smbtilecount+portaltilecount then
								portalmsb:add( tilequads[tilenumber].quad, (x-1-xoff)*16*scale, ((y-1-yoff)*16-8)*scale, 0, scale, scale )
							elseif tilenumber <= smbtilecount+portaltilecount+customtilecount then
								custommsb[tilequads[tilenumber].ts]:add( tilequads[tilenumber].quad, (x-1-xoff)*16*scale, ((y-1-yoff)*16-8)*scale, 0, scale, scale )
							end
						end
					end
				end
			end
			

			if bmap_on then
				if lmap[x] and lmap[x][y] then
					local backgroundtile = bmapt(x, y, 1)
					if backgroundtile and tilequads[backgroundtile] and not tilequads[backgroundtile].invisible then
						if math.floor(backgroundtile) <= smbtilecount then
							smbmbacksb:add( tilequads[backgroundtile].quad, (x-1-xoff)*16*scale, ((y-1-yoff)*16-8)*scale, 0, scale, scale )
						elseif backgroundtile <= smbtilecount+portaltilecount then
							portalmbacksb:add( tilequads[backgroundtile].quad, (x-1-xoff)*16*scale, ((y-1-yoff)*16-8)*scale, 0, scale, scale )
						elseif backgroundtile <= smbtilecount+portaltilecount+customtilecount then
							custommbacksb[tilequads[backgroundtile].ts]:add( tilequads[backgroundtile].quad, (x-1-xoff)*16*scale, ((y-1-yoff)*16-8)*scale, 0, scale, scale )
						end
					end
				end
			end
		end
	end
	createedgewrap() --edge wrapping
	queuespritebatchupdate = false
end

function game_keypressed(key, textinput)
	if pausemenuopen then
		if menuprompt then
			if (key == "left" or key == "a") then
				pausemenuselected2 = 1
			elseif (key == "right" or key == "d") then
				pausemenuselected2 = 2
			elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
				if pausemenuselected2 == 1 then
					if SERVER then
						stopmusic()
						love.audio.stop()
						pausemenuopen = false
						menuprompt = false
						server_lobby()
						lobby_load()
						return
					end
					if CLIENT then
						net_quit()
					end
					if dcplaying then
						stopmusic()
						love.audio.stop()
						pausemenuopen = false
						menuprompt = false
						dcplaying = false
						menu_load()
						gamestate = "mappackmenu"
						mappacktype = "daily_challenge"
						mappackhorscroll = 2
						mappackhorscrollsmooth = 2
					else
						stopmusic()
						love.audio.stop()
						pausemenuopen = false
						menuprompt = false
						menu_load()
					end
				else
					menuprompt = false
				end
			elseif key == "escape" then
				menuprompt = false
			end
			return
		elseif desktopprompt then
			if (key == "left" or key == "a") then
				pausemenuselected2 = 1
			elseif (key == "right" or key == "d") then
				pausemenuselected2 = 2
			elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
				if pausemenuselected2 == 1 then
					love.audio.stop()
					love.event.quit()
				else
					desktopprompt = false
				end
			elseif key == "escape" then
				desktopprompt = false
			end
			return
		elseif suspendprompt then
			if (key == "left" or key == "a") then
				pausemenuselected2 = 1
			elseif (key == "right" or key == "d") then
				pausemenuselected2 = 2
			elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
				if dcplaying then
					suspendprompt = false
				elseif pausemenuselected2 == 1 then
					stopmusic()
					love.audio.stop()
					suspendgame()
					suspendprompt = false
					pausemenuopen = false
				else
					suspendprompt = false
				end
			elseif key == "escape" then
				suspendprompt = false
			end
			return
		end
		if (key == "down" or key == "s") then
			if pausemenuselected < #pausemenuoptions then
				pausemenuselected = pausemenuselected + 1
			end
		elseif (key == "up" or key == "w") then
			if pausemenuselected > 1 then
				pausemenuselected = pausemenuselected - 1
			end
		elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
			if pausemenuoptions[pausemenuselected] == "resume" then
				pausemenuopen = false
				if pausedaudio then
					love.audio.play(pausedaudio)
					pausedaudio = nil
				else
					playmusic()
				end
			elseif pausemenuoptions[pausemenuselected] == "suspend" then
				if dcplaying then
					pausemenuopen = false
					updatesizes("reset")
					levelscreen_load("dc")
					updatesizes("reset")
				else
					suspendprompt = true
					pausemenuselected2 = 1
				end
			elseif pausemenuoptions2[pausemenuselected] == "menu" then
				menuprompt = true
				pausemenuselected2 = 1
			elseif pausemenuoptions2[pausemenuselected] == "desktop" then
				desktopprompt = true
				pausemenuselected2 = 1
			end
		elseif key == "escape" then
			pausemenuopen = false
			if pausedaudio then
				love.audio.play(pausedaudio)
				pausedaudio = nil
			else
				playmusic()
			end
		elseif (key == "right" or key == "d") then
			if pausemenuoptions[pausemenuselected] == "volume" then
				if volume < 1 then
					volume = volume + 0.1
					love.audio.setVolume( volume )
					soundenabled = true
					playsound(coinsound)
				end
			end
			
		elseif (key == "left" or key == "a") then
			if pausemenuoptions[pausemenuselected] == "volume" then
				volume = math.max(volume - 0.1, 0)
				love.audio.setVolume( volume )
				if volume == 0 then
					soundenabled = false
				end
				playsound(coinsound)
			end
		end
			
		return
	end
	
	--chat
	if (SERVER or CLIENT) then
		if key == "/" or (chatentrytoggle and key == "escape") then
			chatentrytoggle = not chatentrytoggle
			if key == "escape" then
				chatentrytoggle = false
			end
			guielements.chatentry.active = chatentrytoggle
			guielements.sendbutton.active = chatentrytoggle
			guielements.chatentry.inputting = chatentrytoggle
		end
		if chatentrytoggle then
			return
		end
	end
	
	if endpressbutton then
		endpressbutton = false
		endgame()
		return
	end

	for i = 1, players do
		if editormode and (editormenuopen or rightclickmenuopen) then
			break
		end

		if controls[i]["jump"][1] == key then
			objects["player"][i]:button("jump")
			objects["player"][i]:wag()
			objects["player"][i]:jump()
			animationsystem_buttontrigger(i, "jump")
		elseif controls[i]["run"][1] == key then
			objects["player"][i]:button("run")
			objects["player"][i]:fire()
			animationsystem_buttontrigger(i, "run")
		elseif controls[i]["reload"][1] == key then
			objects["player"][i]:button("reload")
			if objects["player"][i].portalgun then
				local pi = false
				--only reset portals that can be controlled by player
				if objects["player"][i].portals == "1 only" then
					pi = 1
				elseif objects["player"][i].portals == "2 only" then
					pi = 2
				end
				objects["player"][i]:removeportals(pi)
			end
			animationsystem_buttontrigger(i, "reload")
		elseif controls[i]["use"][1] == key then
			objects["player"][i]:button("use")
			objects["player"][i]:use()
			animationsystem_buttontrigger(i, "use")
		elseif controls[i]["left"][1] == key then
			objects["player"][i]:button("left")
			objects["player"][i]:leftkey()
			animationsystem_buttontrigger(i, "left")
		elseif controls[i]["right"][1] == key then
			objects["player"][i]:button("right")
			objects["player"][i]:rightkey()
			animationsystem_buttontrigger(i, "right")
		elseif controls[i]["up"][1] == key then
			objects["player"][i]:button("up")
			objects["player"][i]:upkey()
			animationsystem_buttontrigger(i, "up")
		elseif controls[i]["down"][1] == key then
			objects["player"][i]:button("down")
			objects["player"][i]:downkey()
			animationsystem_buttontrigger(i, "down")
		end
		
		if controls[i]["portal1"][1] == key and objects["player"][i] then
			objects["player"][i]:shootportal(1)
			return
		end
		
		if controls[i]["portal2"][1] == key and objects["player"][i] then
			objects["player"][i]:shootportal(2)
			return
		end
	end

	if android then
		if controls[1]["up"][1] == key then
			if playertype == "minecraft" then
				mccurrentblock = mccurrentblock + 1
				if mccurrentblock >= 10 then
					mccurrentblock = 1
				end
			elseif bullettime then
				speedtarget = speedtarget - 0.1
				if speedtarget < 0.1 then
					speedtarget = 0.1
				end
			end
		elseif controls[1]["down"][1] == key then
			if playertype == "minecraft" then
				mccurrentblock = mccurrentblock - 1
				if mccurrentblock <= 0 then
					mccurrentblock = 9
				end
			elseif bullettime then
				speedtarget = speedtarget + 0.1
				if speedtarget > 1 then
					speedtarget = 1
				end
			end
		end
	end
	
	if key == "escape" then
		if not editormode and testlevel then
			stoptestinglevel()
			return
		elseif not editormode and not everyonedead then
			pausemenuopen = true
			if not android then --doesn't work for some reason
				pausedaudio = love.audio.pause()
			end
			playsound(pausesound)
		end
	end
	
	if editormode then
		editor_keypressed(key)
	end
end

function stoptestinglevel()
	marioworld = testlevelworld
	mariolevel = testlevellevel
	testlevel = false
	player_position = {objects["player"][1].x, objects["player"][1].y, xscroll, yscroll}
	stopmusic()
	love.audio.stop()
	editormode = true
	if mariosublevel ~= 0 then
		startlevel(mariosublevel)
	else
		startlevel(marioworld .. "-" .. mariolevel)
	end
	player_position = nil
end

function game_keyreleased(key, unicode)
	for i = 1, players do
		if controls[i]["jump"][1] == key then
			objects["player"][i]:buttonrelease("jump")
			objects["player"][i]:stopjump()
			animationsystem_buttonreleasetrigger(i, "jump")
		elseif controls[i]["run"][1] == key then
			objects["player"][i]:buttonrelease("run")
			animationsystem_buttonreleasetrigger(i, "run")
		elseif controls[i]["reload"][1] == key then
			objects["player"][i]:buttonrelease("reload")
			animationsystem_buttonreleasetrigger(i, "reload")
		elseif controls[i]["use"][1] == key then
			objects["player"][i]:buttonrelease("use")
			animationsystem_buttonreleasetrigger(i, "use")
		elseif controls[i]["left"][1] == key then
			objects["player"][i]:buttonrelease("left")
			animationsystem_buttonreleasetrigger(i, "left")
		elseif controls[i]["right"][1] == key then
			objects["player"][i]:buttonrelease("right")
			animationsystem_buttonreleasetrigger(i, "right")
		elseif controls[i]["up"][1] == key then
			objects["player"][i]:buttonrelease("up")
			animationsystem_buttonreleasetrigger(i, "up")
		elseif controls[i]["down"][1] == key then
			objects["player"][i]:buttonrelease("down")
			animationsystem_buttonreleasetrigger(i, "down")
		end
	end
end

function shootportal(plnumber, i, sourcex, sourcey, direction, mirrored)
	if objects["player"][plnumber].portalgundisabled then
		return
	end

	--box
	if objects["player"][plnumber].pickup then
		return
	end
	--portalgun delay
	if portaldelay[plnumber] > 0 then
		return
	else
		portaldelay[plnumber] = portalgundelay
	end
	if not objects["player"][plnumber].portalgun then
		return
	end
	
	local otheri = 1
	local color = objects["player"][plnumber].portal2color
	if i == 1 then
		otheri = 2
		color = objects["player"][plnumber].portal1color
	end
	
	local cox, coy, side, tendency, x, y = traceline(sourcex, sourcey, direction)
	
	local mirror = false
	if cox and inmap(cox, coy) and tilequads[map[cox][coy][1]]:getproperty("mirror", cox, coy) then
		mirror = true
	end
	
	objects["player"][plnumber].lastportal = i
	
	table.insert(portalprojectiles, portalprojectile:new(sourcex, sourcey, x, y, color, true, {objects["player"][plnumber].portal, i, cox, coy, side, tendency, x, y}, mirror, mirrored, plnumber))
end

function game_mousepressed(x, y, button)
	local s = ""
	if pausemenuopen then
		return
	end
	if editormode and editorstate ~= "portalgun" then
		editor_mousepressed(x, y, button)
	else
		if editormode then
			editor_mousepressed(x, y, button)
		end
		
		if not noupdate and objects["player"][mouseowner] then
			if button == "l" then
				objects["player"][mouseowner]:shootportal(1)
			elseif button == "r" then
				objects["player"][mouseowner]:shootportal(2)
			end
		end
			
		if button == "wd" then
			if playertype == "minecraft" then
				mccurrentblock = mccurrentblock + 1
				if mccurrentblock >= 10 then
					mccurrentblock = 1
				end
			elseif bullettime then
				speedtarget = speedtarget - 0.1
				if speedtarget < 0.1 then
					speedtarget = 0.1
				end
			end
		elseif button == "wu" then
			if playertype == "minecraft" then
				mccurrentblock = mccurrentblock - 1
				if mccurrentblock <= 0 then
					mccurrentblock = 9
				end
			elseif bullettime then
				speedtarget = speedtarget + 0.1
				if speedtarget > 1 then
					speedtarget = 1
				end
			end
		end
	end
end


function modifyportalwalls()
	--Create and remove new stuff
	for a, b in pairs(portals) do
		for i = 1, 2 do
			if b["x" .. i] then
				if b["facing" .. i] == "up" then
					objects["portalwall"][a .. "-" .. i .. "-1"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-1, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-2"] = portalwall:new(b["x" .. i]-1, b["y" .. i], 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-3"] = portalwall:new(b["x" .. i], b["y" .. i], 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-4"] = portalwall:new(b["x" .. i]+1, b["y" .. i]-1, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-5"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-1, 0, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-6"] = portalwall:new(b["x" .. i]+1, b["y" .. i]-1, 0, 0, true)
					
					modifyportaltiles(b["x" .. i], b["y" .. i], 1, 0, portals[a], i, "remove")
				elseif b["facing" .. i] == "down" then
					objects["portalwall"][a .. "-" .. i .. "-1"] = portalwall:new(b["x" .. i]-2, b["y" .. i]-1, 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-2"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-1, 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-3"] = portalwall:new(b["x" .. i]-2, b["y" .. i]-1, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-4"] = portalwall:new(b["x" .. i], b["y" .. i]-1, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-5"] = portalwall:new(b["x" .. i]-2, b["y" .. i], 0, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-6"] = portalwall:new(b["x" .. i], b["y" .. i], 0, 0, true)
					
					modifyportaltiles(b["x" .. i], b["y" .. i], -1, 0, portals[a], i, "remove")
				elseif b["facing" .. i] == "left" then
					objects["portalwall"][a .. "-" .. i .. "-1"] = portalwall:new(b["x" .. i], b["y" .. i]-2, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-2"] = portalwall:new(b["x" .. i], b["y" .. i]-1, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-3"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-2, 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-4"] = portalwall:new(b["x" .. i]-1, b["y" .. i], 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-5"] = portalwall:new(b["x" .. i]-1, b["y" .. i], 0, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-6"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-2, 0, 0, true)
					
					modifyportaltiles(b["x" .. i], b["y" .. i], 0, -1, portals[a], i, "remove")
				elseif b["facing" .. i] == "right" then
					objects["portalwall"][a .. "-" .. i .. "-1"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-1, 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-2"] = portalwall:new(b["x" .. i]-1, b["y" .. i], 0, 1, true)
					objects["portalwall"][a .. "-" .. i .. "-3"] = portalwall:new(b["x" .. i]-1, b["y" .. i]-1, 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-4"] = portalwall:new(b["x" .. i]-1, b["y" .. i]+1, 1, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-5"] = portalwall:new(b["x" .. i], b["y" .. i]-1, 0, 0, true)
					objects["portalwall"][a .. "-" .. i .. "-6"] = portalwall:new(b["x" .. i], b["y" .. i]+1, 0, 0, true)
					
					modifyportaltiles(b["x" .. i], b["y" .. i], 0, 1, portals[a], i, "remove")
				end
			end
		end
	end
	
	--remove conflicting portalwalls (only exist when both portals exists!)
	for a, b in pairs(portals) do
		for j = 1, 2 do
			local otherj = 1
			if j == 1 then
				otherj = 2
			end
			for c, d in pairs(portals) do
				for i = 1, 2 do
					local otheri = 1
					if i == 1 then
						otheri = 2
					end
					--B.J PORTAL WILL REMOVE WALLS OF D.OTHERJ, SO B.OTHERJ MUST EXIST
					
					if b["x" .. j] and b["x" .. otherj] and d["x" .. i] then
						local conside, conx, cony = b["facing" .. j], b["x" .. j], b["y" .. j]
						
						for k = 1, 4 do
							local w = objects["portalwall"][c .. "-" .. i .. "-" .. k]
							if w then
								if conside == "right" then
									if w.x == conx and w.y == cony-1 and w.height == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx and w.y == cony and w.height == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx-1 and w.y == cony and w.width == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
								elseif conside == "left" then
									if w.x == conx-1 and w.y == cony-2 and w.height == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx-1 and w.y == cony-1 and w.height == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx-1 and w.y == cony-1 and w.width == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
								elseif conside == "up" then
									if w.x == conx-1 and w.y == cony-1 and w.width == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx and w.y == cony-1 and w.width == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx and w.y == cony-1 and w.height == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
								else
									if w.x == conx-2 and w.y == cony and w.width == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx-1 and w.y == cony and w.width == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
									if w.x == conx-1 and w.y == cony-1 and w.height == 1 then
										objects["portalwall"][c .. "-" .. i .. "-" .. k] = nil
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function modifyportaltiles(x, y, xplus, yplus, portal, i, mode)
	if not x or not y then
		return
	end
	if i == 1 then
		if portal.facing2 ~= false then
			if mode == "add" then
				objects["tile"][tilemap(x, y)] = tile:new(x-1, y-1)
				objects["tile"][tilemap(x+xplus, y+yplus)] = tile:new(x-1+xplus, y-1+yplus)
			else
				objects["tile"][tilemap(x, y)] = nil
				objects["tile"][tilemap(x+xplus, y+yplus)] = nil
			end
		end
	else
		if portal.facing1 ~= false then
			if mode == "add" then
				objects["tile"][tilemap(x, y)] = tile:new(x-1, y-1)
				objects["tile"][tilemap(x+xplus, y+yplus)] = tile:new(x-1+xplus, y-1+yplus)
			else
				objects["tile"][tilemap(x, y)] = nil
				objects["tile"][tilemap(x+xplus, y+yplus)] = nil
			end
		end
	end
end

function getportalposition(i, x, y, side, tendency) --returns the "optimal" position according to the parsed arguments (or false if no possible position was found)
	local xplus, yplus = 0, 0
	if side == "up" then
		yplus = -1
	elseif side == "right" then
		xplus = 1
	elseif side == "down" then
		yplus = 1
	elseif side == "left" then
		xplus = -1
	end
	
	if side == "up" or side == "down" then
		if tendency == -1 then
			if getTile(x-1, y, true, true, side) == true and getTile(x, y, true, true, side) == true and getTile(x-1, y+yplus, nil, false, side, true) == false and getTile(x, y+yplus, nil, false, side, true) == false then
				if side == "up" then
					return x-1, y
				else
					return x, y
				end
			elseif getTile(x, y, true, true, side) == true and getTile(x+1, y, true, true, side) == true and getTile(x, y+yplus, nil, false, side, true) == false and getTile(x+1, y+yplus, nil, false, side, true) == false then
				if side == "up" then
					return x, y
				else
					return x+1, y
				end
			end
		else
			if getTile(x, y, true, true, side) == true and getTile(x+1, y, true, true, side) == true and getTile(x, y+yplus, nil, false, side, true) == false and getTile(x+1, y+yplus, nil, false, side, true) == false then
				if side == "up" then
					return x, y
				else
					return x+1, y
				end
			elseif getTile(x-1, y, true, true, side) == true and getTile(x, y, true, true, side) == true and getTile(x-1, y+yplus, nil, false, side, true) == false and getTile(x, y+yplus, nil, false, side, true) == false then
				if side == "up" then
					return x-1, y
				else
					return x, y
				end
			end
		end
	else
		if tendency == -1 then
			if getTile(x, y-1, true, true, side) == true and getTile(x, y, true, true, side) == true and getTile(x+xplus, y-1, nil, false, side, true) == false and getTile(x+xplus, y, nil, false, side, true) == false then
				if side == "right" then
					return x, y-1
				else
					return x, y
				end
			elseif getTile(x, y, true, true, side) == true and getTile(x, y+1, true, true, side) == true and getTile(x+xplus, y, nil, false, side, true) == false and getTile(x+xplus, y+1, nil, false, side, true) == false then
				if side == "right" then
					return x, y
				else
					return x, y+1
				end
			end
		else
			if getTile(x, y, true, true, side) == true and getTile(x, y+1, true, true, side) == true and getTile(x+xplus, y, nil, false, side, true) == false and getTile(x+xplus, y+1, nil, false, side, true) == false then
				if side == "right" then
					return x, y
				else
					return x, y+1
				end
			elseif getTile(x, y-1, true, true, side) == true and getTile(x, y, true, true, side) == true and getTile(x+xplus, y-1, nil, false, side, true) == false and getTile(x+xplus, y, nil, false, side, true) == false then
				if side == "right" then
					return x, y-1
				else
					return x, y
				end
			end
		end
	end
	
	return false
end


function getTile(x, y, portalable, portalcheck, facing, ignoregrates, dir) --returns masktable value of block (As well as the ID itself as second return parameter) also includes a portalcheck and returns false if a portal is on that spot.
	if portalcheck then
		for i, v in pairs(portals) do
			--Get the extra block of each portal
			local portal1xplus, portal1yplus, portal2xplus, portal2yplus = 0, 0, 0, 0
			if v.facing1 == "up" then
				portal1xplus = 1
			elseif v.facing1 == "right" then
				portal1yplus = 1
			elseif v.facing1 == "down" then
				portal1xplus = -1
			elseif v.facing1 == "left" then
				portal1yplus = -1
			end
			
			if v.facing2 == "up" then
				portal2xplus = 1
			elseif v.facing2 == "right" then
				portal2yplus = 1
			elseif v.facing2 == "down" then
				portal2xplus = -1
			elseif v.facing2 == "left" then
				portal2yplus = -1
			end
			
			if v.x1 ~= false then
				if (x == v.x1 or x == v.x1+portal1xplus) and (y == v.y1 or y == v.y1+portal1yplus) and (facing == nil or v.facing1 == facing) then
					return false
				end
			end
		
			if v.x2 ~= false then
				if (x == v.x2 or x == v.x2+portal2xplus) and (y == v.y2 or y == v.y2+portal2yplus) and (facing == nil or v.facing2 == facing) then
					return false
				end
			end
		end
	end
	
	--check for tubes
	for i, v in pairs(objects["geldispenser"]) do
		if (x == v.cox or x == v.cox+1) and (y == v.coy or y == v.coy+1) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	for i, v in pairs(objects["cubedispenser"]) do
		if (x == v.cox or x == v.cox+1) and (y == v.coy or y == v.coy+1) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	if objects["flipblock"][tilemap(x, y)] then
		local v = objects["flipblock"][tilemap(x, y)]
		if not v.flip then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end

	if objects["buttonblock"][tilemap(x, y)] then
		local v = objects["buttonblock"][tilemap(x, y)]
		if v.solid then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end

	if objects["clearpipesegment"][tilemap(x, y)] then
		if portalcheck then
			return false
		else
			return true
		end
	end

	if objects["frozencoin"][tilemap(x, y)] then
		if portalcheck then
			return false
		else
			return true
		end
	end

	if blockedportaltiles[tilemap(x, y)] then
		if portalcheck then
			return false
		else
			return true
		end
	end

	if objects["tile"][tilemap(x, y)] and (objects["tile"][tilemap(x, y)].slant or objects["tile"][tilemap(x, y)].slab) and ismaptile(x,y) then
		if portalcheck then
			return false, map[x][y][1]
		else
			return true, map[x][y][1]
		end
	end
	
	--bonusstage thing for keeping it from fucking up by allowing portals to be shot next to the vine in 4-2_2 for example
	if bonusstage then
		if y == mapheight and (x == 4 or x == 6) then
			if portalcheck then
				return false
			else
				return true
			end
		end
	end
	
	if x <= 0 or y <= 0 or y >= mapheight+1 or x > mapwidth then
		return false, 1
	end
	
	if tilequads[map[x][y][1]]:getproperty("invisible", x, y) or tilequads[map[x][y][1]].leftslant or tilequads[map[x][y][1]].rightslant 
		or tilequads[map[x][y][1]].halfleftslant1 or tilequads[map[x][y][1]].halfleftslant2
		or tilequads[map[x][y][1]].halfrightslant1 or tilequads[map[x][y][1]].halfrightslant2 then
		return false
	end
	
	if portalcheck then
		local side
		if facing == "up" then
			side = "top"
		elseif facing == "right" then
			side = "right"
		elseif facing == "down" then
			side = "bottom"
		elseif facing == "left" then
			side = "left"
		end
		
		--To stop people from portalling under the vine, which caused problems, but was fixed elsewhere (and betterer)
		--[[for i, v in pairs(objects["vine"]) do
			if x == v.cox and y == v.coy and side == "top" then
				return false, 1
			end
		end--]]
		
		if map[x][y]["portaloverride"] and map[x][y]["portaloverride"][side] then
			return true, map[x][y][1]
		end
		
		if map[x][y]["gels"][side] == 3 then
			return true, map[x][y][1]
		else
			return tilequads[map[x][y][1]]:getproperty("collision", x, y) and tilequads[map[x][y][1]]:getproperty("portalable", x, y) and not tilequads[map[x][y][1]]:getproperty("grate", x, y), map[x][y][1]
		end
	else
		if ignoregrates then
			return tilequads[map[x][y][1]]:getproperty("collision", x, y) and not tilequads[map[x][y][1]]:getproperty("grate", x, y), map[x][y][1]
		else
			return (tilequads[map[x][y][1]]:getproperty("collision", x, y) or map[x][y][1] == 130), map[x][y][1]
		end
	end
end

function getPortal(x, y, dir) --returns the block where you'd come out when you'd go in the argument's block
	for i, v in pairs(portals) do
		if v.x1 ~= false and v.x2 ~= false then
			--Get the extra block of each portal
			local portal1xplus, portal1yplus, portal2xplus, portal2yplus = 0, 0, 0, 0
			if v.facing1 == "up" then
				portal1xplus = 1
			elseif v.facing1 == "right" then
				portal1yplus = 1
			elseif v.facing1 == "down" then
				portal1xplus = -1
			elseif v.facing1 == "left" then
				portal1yplus = -1
			end
			
			if v.facing2 == "up" then
				portal2xplus = 1
			elseif v.facing2 == "right" then
				portal2yplus = 1
			elseif v.facing2 == "down" then
				portal2xplus = -1
			elseif v.facing2 == "left" then
				portal2yplus = -1
			end
			
			if v.x1 ~= false and (not dir or v.facing1 == dir) then
				if (x == v.x1 or x == v.x1+portal1xplus) and (y == v.y1 or y == v.y1+portal1yplus) and (facing == nil or v.facing1 == facing) then
					if v.facing1 ~= v.facing2 then
						local xplus, yplus = 0, 0
						if v.facing1 == "left" or v.facing1 == "right" then
							if y == v.y1 then
								if v.facing2 == "left" or v.facing2 == "right" then
									yplus = portal2yplus
								else
									xplus = portal2xplus
								end
							end
							
							return v.x2+xplus, v.y2+yplus, v.facing2, v.facing1, v.x2, v.y2, v.x1, v.y1
						else
							if x == v.x1 then
								if v.facing2 == "left" or v.facing2 == "right" then
									yplus = portal2yplus
								else
									xplus = portal2xplus
								end
							end
							
							return v.x2+xplus, v.y2+yplus, v.facing2, v.facing1, v.x2, v.y2, v.x1, v.y1
						end	
					else
						return v.x2+(x-v.x1), v.y2+(y-v.y1), v.facing2, v.facing1, v.x2, v.y2, v.x1, v.y1
					end
				end
			end
		
			if v.x2 ~= false and (not dir or v.facing2 == dir) then
				if (x == v.x2 or x == v.x2+portal2xplus) and (y == v.y2 or y == v.y2+portal2yplus) and (facing == nil or v.facing2 == facing) then
					if v.facing1 ~= v.facing2 then
						local xplus, yplus = 0, 0
						if v.facing2 == "left" or v.facing2 == "right" then
							if y == v.y2 then
								if v.facing1 == "left" or v.facing1 == "right" then
									yplus = portal1yplus
								else
									xplus = portal1xplus
								end
							end
							
							return v.x1+xplus, v.y1+yplus, v.facing1, v.facing2, v.x1, v.y1, v.x2, v.y2
						else
							if x == v.x2 then
								if v.facing1 == "left" or v.facing1 == "right" then
									yplus = portal1yplus
								else
									xplus = portal1xplus
								end
							end
							
							return v.x1+xplus, v.y1+yplus, v.facing1, v.facing2, v.x1, v.y1, v.x2, v.y2
						end	
					else
						return v.x1+(x-v.x2), v.y1+(y-v.y2), v.facing1, v.facing2, v.x1, v.y1, v.x2, v.y2
					end
				end
			end
		end
	end
	
	return false
end

function insideportal(x, y, width, height) --returns whether an object is in, and which, portal.
	if width == nil then
		width = 12/16
	end
	if height == nil then
		height = 12/16
	end
	for i, v in pairs(portals) do
		if v.x1 ~= false and v.x2 ~= false then
			for j = 1, 2 do				
				local portalx, portaly, portalfacing
				if j == 1 then
					portalx = v.x1
					portaly = v.y1
					portalfacing = v.facing1
				else
					portalx = v.x2
					portaly = v.y2
					portalfacing = v.facing2
				end
				
				if portalfacing == "up" then
					xplus = 1
				elseif portalfacing == "down" then
					xplus = -1
				elseif portalfacing == "left" then
					yplus = -1
				end
				
				if portalfacing == "right" then
					if (math.floor(y) == portaly or math.floor(y) == portaly-1) and inrange(x, portalx-width, portalx, false) then
						return portals[i], j
					end
				elseif portalfacing == "left" then
					if (math.floor(y) == portaly-1 or math.floor(y) == portaly-2) and inrange(x, portalx-1-width, portalx-1, false) then
						return portals[i], j
					end
				elseif portalfacing == "up" then
					if inrange(y, portaly-height-1, portaly-1, false) and inrange(x, portalx-1.5-.2, portalx+.5+.2, true) then
						return portals[i], j
					end	
				elseif portalfacing == "down" then
					if inrange(y, portaly-height, portaly, false) and inrange(x, portalx-2, portalx-.5, true) then
						return portals[i], j
					end	
				end
				
				--widen rect by 3 pixels?
				
			end
		end
	end
	
	return false
end

function moveoutportal() --pushes objects out of the portal i in.
	for i, v in pairs(objects) do
		if i ~= "tile" and i ~= "portalwall" then
			for j, w in pairs(v) do
				if w.active and w.static == false then
					local p1, p2 = insideportal(w.x, w.y, w.width, w.height)
					
					if p1 ~= false then
						local portalfacing, portalx, portaly
						if p2 == 1 then
							portalfacing = p1.facing1
							portalx = p1.x1
							portaly = p1.y1
						else
							portalfacing = p1.facing2
							portalx = p1.x2
							portaly = p1.y2
						end
						
						if portalfacing == "right" then
							w.x = portalx
						elseif portalfacing == "left" then
							w.x = portalx - 1 - w.width
						elseif portalfacing == "up" then
							w.y = portaly - 1 - w.height
						elseif portalfacing == "down" then
							w.y = portaly
						end
					end
				end
			end
		end
	end
end

function nextlevel()
	stopmusic()
	love.audio.stop()
	mariolevel = mariolevel + 1
	if tonumber(marioworld) then
		if mariolevel > (#mappacklevels[marioworld] or 4) then
			mariolevel = 1
			marioworld = marioworld + 1
		end
	end
	
	if dcplaying then
		dchighscore()
	end
	
	levelscreen_load("next")
end

function warpzone(i, l)
	love.audio.stop()
	mariolevel = l or 1
	marioworld = i or 1
	mariosublevel = 0
	prevsublevel = false
	
	-- minus 1 world glitch just because I can.
	if not displaywarpzonetext and i == 4 and haswarpzone then
		marioworld = "M"
	end
	
	levelscreen_load("next")
end

function changeswitchstate(color, perma, flipblocks)
	for j, w in pairs(objects["buttonblock"]) do
		if w.color == color then
			w:change()
		end
	end
	for j, w in pairs(objects["belt"]) do
		if w.t == "switch" and w.color == color then
			w:change()
		end
	end
	for j, w in pairs(tracks) do
		if w.switch and w.color == color then
			w:change()
		end
	end
	for i = 1, #animationswitchtriggerfuncs do
		local t = animationswitchtriggerfuncs[i]
		if tonumber((t[2] or 0)) and tonumber((t[2] or 0)) == color then
			t[1]:trigger()
		end
	end

	if perma then
		solidblockperma[color] = not solidblockperma[color]
	end
	if flipblocks then
		for j, w in pairs(objects["flipblock"]) do
			if w.t == "switchblock" and w.color == color then
				w.on = not w.on
				if w.on then
					w.quad = flipblockquad[color][w.quadi]
				else
					w.quad = flipblockquad[color][w.quadi+2]
				end
			end
		end
	end
end

function game_mousereleased(x, y, button)
	if button == "l" then
		if playertype == "minecraft" then
			breakingblockX = false
		end
	end
	
	if editormode then
		editor_mousereleased(x, y, button)
	end
end

function getMouseTile(x, y)
	local xout = math.floor((x+xscroll*screenzoom*16*scale)/(16*screenzoom*scale))+1
	local yout = math.floor((y+yscroll*screenzoom*16*scale)/(16*screenzoom*scale))+1
	return xout, yout
end

function savemap(filename)
	local s = ""
	local backgroundtile
	for y = 1, mapheight do
		for x = 1, mapwidth do
			for i = 1, #map[x][y] do
				s = s .. tostring(map[x][y][i])
				--is the enemy offset horizontally?
				if i == 2 and map[x][y]["argument"] then
					s = s .. ":" .. tostring(map[x][y]["argument"])
				end
				--tack on a background tile
				backgroundtile = bmapt(x, y, i)
				if backgroundtile then
					s = s .. "~" .. tostring(backgroundtile)
				end
				--seperator
				if i ~= #map[x][y] then
					s = s .. "-"
				end
			end
			if y ~= mapheight or x ~= mapwidth then
				s = s .. ","
			end
		end
	end
	
	--options
	s = s .. ";height=" .. mapheight
	if background == 4 then
		s = s .. ";background=" .. round(backgroundrgb[1]*255) .. "," .. round(backgroundrgb[2]*255) .. "," .. round(backgroundrgb[3]*255)
	else
		s = s .. ";background=" .. background
	end
	s = s .. ";spriteset=" .. spriteset
	if musici > 7 then
		s = s .. ";music=" .. musictable[musici]
	else
		s = s .. ";music=" .. musici
	end
	if intermission then
		s = s .. ";intermission"
	end
	if bonusstage then
		s = s .. ";bonusstage"
	end
	if haswarpzone then
		s = s .. ";haswarpzone"
	end
	if underwater then
		s = s .. ";underwater"
	end
	if custombackground then
		if tostring(custombackground) == custombackground then
			s = s .. ";custombackground=" .. custombackground
		else
			s = s .. ";custombackground"
		end
	end
	if autoscrolling then
		if tonumber(autoscrollingspeed) then
			s = s .. ";autoscrolling=" .. autoscrollingspeed
		else
			s = s .. ";autoscrolling"
		end
	end
	if edgewrapping then
		s = s .. ";edgewrapping"
	end
	if lightsout then
		s = s .. ";lightsout"
	end
	if lowgravity then
		s = s .. ";lowgravity"
	end
	if customforeground then
		if tostring(customforeground) == customforeground then
			s = s .. ";customforeground=" .. customforeground
		else
			s = s .. ";customforeground"
		end
	end
	if not portalgun then
		s = s .. ";noportalgun"
	else
		s = s .. ";portalguni=" .. portalguni
	end
	if musici == 7 then
		if guielements["custommusiciinput"] then
			s = s .. ";custommusic=" .. guielements["custommusiciinput"].value
		else
			s = s .. ";custommusic=1"
		end
	end
	s = s .. ";timelimit=" .. mariotimelimit
	s = s .. ";scrollfactor=" .. scrollfactor
	s = s .. ";scrollfactory=" .. scrollfactory
	s = s .. ";scrollfactor2=" .. scrollfactor2
	s = s .. ";scrollfactor2y=" .. scrollfactor2y
	if nofunallowed then
		s = s .. ";nofunallowed"
	end

	s = s .. ";vs=" .. VERSION
	
	--tileset
	
	love.filesystem.createDirectory( mappackfolder )
	love.filesystem.createDirectory( mappackfolder .. "/" .. mappack )
	
	local success, message = love.filesystem.write(mappackfolder .. "/" .. mappack .. "/" .. filename .. ".txt", s)
	
	--don't create a map height file if it's 15 (default) (Update: no more map files cause they're bad)
	if mapheight ~= 15 then
		if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/heights/" .. marioworld .. "-" .. mariolevel .. "_" .. actualsublevel .. ".txt") then
			love.filesystem.remove(mappackfolder .. "/" .. mappack .. "/heights/" .. marioworld .. "-" .. mariolevel .. "_" .. actualsublevel .. ".txt") --remove file
		end
	end
	
	print("Map saved as " .. mappackfolder .. "/" .. filename .. ".txt")
	if success then
		notice.new(TEXT["Map saved!"], notice.white, 2)
	else
		notice.new("Could not save map!\n" .. message, notice.red, 4)
	end
end

function savelevel()
	if mariosublevel == 0 then
		savemap(marioworld .. "-" .. mariolevel)
	else
		savemap(marioworld .. "-" .. mariolevel .. "_" .. mariosublevel)
	end

	--metadata
	if editormode then
		promptsaveeditormetadata()
	end
end

function traceline(sourcex, sourcey, radians, reportal)
	local currentblock = {}
	local x, y = sourcex, sourcey
	currentblock[1] = math.floor(x)
	currentblock[2] = math.floor(y+1)
		
	local emancecollide = false
	for i, v in pairs(emancipationgrills) do
		if v:getTileInvolved(currentblock[1]+1, currentblock[2]) then
			emancecollide = true
		end
	end
	
	local doorcollide = false
	for i, v in pairs(objects["door"]) do
		if v.dir == "hor" then
			if v.open == false and (v.cox == currentblock[1] or v.cox == currentblock[1]+1) and v.coy == currentblock[2] then
				doorcollide = true
				break
			end
		else
			if v.open == false and v.cox == currentblock[1]+1 and (v.coy == currentblock[2] or v.coy == currentblock[2]+1) then
				doorcollide = true
				break
			end
		end
	end

	local tileposition = tilemap(currentblock[1]+1, currentblock[2])
	
	if objects["flipblock"][tileposition] and not objects["flipblock"][tileposition].flip then
		buttonblockcollide = true
	end

	local pixeltilecollide = false --TODO: fix? I don't think the +1 should be added to the x
	if objects["tile"][tileposition] then
		if objects["tile"][tileposition].slant then
			pixeltilecollide = true
		elseif objects["tile"][tileposition].slab then
			buttonblockcollide = true
		end
	end
	
	local buttonblockcollide = false
	if objects["buttonblock"][tileposition] then
		local v = objects["buttonblock"][tileposition]
		if v.solid then
			buttonblockcollide = true
		end
	end

	if objects["clearpipesegment"][tileposition] then
		buttonblockcollide = true
	end
	
	if objects["frozencoin"][tileposition] then
		buttonblockcollide = true
	end

	if blockedportaltiles[tileposition] then
		buttonblockcollide = true
	end
	
	if emancecollide or doorcollide or flipblockcollide or buttonblockcollide or pixeltilecollide then
		return false, false, false, false, x, y
	end
	
	local side
	
	while currentblock[1]+1 > 0 and currentblock[1]+1 <= mapwidth and (flagx == false or (currentblock[1]+1 <= flagx or not flagborder)) and (axex == false or currentblock[1]+1 <= axex) and (currentblock[2] > 0 or currentblock[2] >= math.floor(sourcey+0.5)) and currentblock[2] < mapheight+1 do --while in map range
		local oldy = y
		local oldx = x
		
		--calculate X and Y diff..
		local ydiff, xdiff
		local side1, side2
		
		if inrange(radians, -math.pi/2, math.pi/2, true) then --up
			ydiff = (y-(currentblock[2]-1)) / math.cos(radians)
			y = currentblock[2]-1
			side1 = "down"
		else
			ydiff = (y-(currentblock[2])) / math.cos(radians)
			y = currentblock[2]
			side1 = "up"
		end
		
		if inrange(radians, 0, math.pi, true) then --left
			xdiff = (x-(currentblock[1])) / math.sin(radians)
			x = currentblock[1]
			side2 = "right"
		else
			xdiff = (x-(currentblock[1]+1)) / math.sin(radians)
			x = currentblock[1]+1
			side2 = "left"
		end
		
		--smaller diff wins
		
		if xdiff < ydiff then
			y = oldy - math.cos(radians)*xdiff
			side = side2
		else
			x = oldx - math.sin(radians)*ydiff
			side = side1
		end
		
		if side == "down" then
			currentblock[2] = currentblock[2]-1
		elseif side == "up" then
			currentblock[2] = currentblock[2]+1
		elseif side == "left" then
			currentblock[1] = currentblock[1]+1
		elseif side == "right" then
			currentblock[1] = currentblock[1]-1
		end
		
		local collide, tileno = getTile(currentblock[1]+1, currentblock[2])
		local emancecollide = false
		for i, v in pairs(emancipationgrills) do
			if v:getTileInvolved(currentblock[1]+1, currentblock[2]) then
				emancecollide = true
			end
		end
		
		if tileno then
			
			if tilequads[tileno]:getproperty("platform", currentblock[1]+1, currentblock[2]) or tilequads[tileno]:getproperty("platformdown", currentblock[1]+1, currentblock[2])
				or tilequads[tileno]:getproperty("platformleft", currentblock[1]+1, currentblock[2]) or tilequads[tileno]:getproperty("platformright", currentblock[1]+1, currentblock[2]) then
				if ((side == "up" and tilequads[tileno]:getproperty("platform", currentblock[1]+1, currentblock[2])) or
					(side == "down" and tilequads[tileno]:getproperty("platformdown", currentblock[1]+1, currentblock[2])) or
					(side == "left" and tilequads[tileno]:getproperty("platformleft", currentblock[1]+1, currentblock[2])) or
					(side == "right" and tilequads[tileno]:getproperty("platformright", currentblock[1]+1, currentblock[2]))) then
					collide = true
				else
					collide = false
				end
			end
			if tilequads[tileno].grate then
				collide = false
			end
		end
		
		local doorcollide = false
		for i, v in pairs(objects["door"]) do
			if v.dir == "hor" then
				if v.open == false and (v.cox == currentblock[1] or v.cox == currentblock[1]+1) and v.coy == currentblock[2] then
					doorcollide = true
				end
			else
				if v.open == false and v.cox == currentblock[1]+1 and (v.coy == currentblock[2] or v.coy == currentblock[2]+1) then
					doorcollide = true
				end
			end
		end
		
		--Check for ceilblocker
		if y < 0 then
			if map[currentblock[1]] and entitylist[map[currentblock[1]][1][2]] and entitylist[map[currentblock[1]][1][2]].t == "ceilblocker" then
				return false, false, false, false, x, y
			end
		end

		local tileposition = tilemap(currentblock[1]+1, currentblock[2])
		
		--local flipblockcollide = false
		if objects["flipblock"][tileposition] and not objects["flipblock"][tileposition].flip then
			collide = true
		end

		if objects["tile"][tileposition] then
			if (objects["tile"][tileposition].slant or objects["tile"][tileposition].slab) and (tilequads[tileno] and not tilequads[tileno].grate) then
				return false, false, false, false, x, y
			end
		end
			
		--local buttonblockcollide = false
		if objects["buttonblock"][tileposition] then
			local v = objects["buttonblock"][tileposition]
			if v.solid then
				collide = true
			end
		end

		if objects["clearpipesegment"][tileposition] then
			collide = true
		end

		if objects["frozencoin"][tileposition] then
			collide = true
		end

		if blockedportaltiles[tileposition] then
			collide = true
		end
		
		if collide == true then
			break
		elseif emancecollide or doorcollide or flipblockcollide or buttonblockcollide or pixeltilecollide then
			return false, false, false, false, x, y
		elseif x > xscroll + width or x < xscroll or y > yscroll + height + 1 or (y < yscroll and sourcey >= yscroll) then
			return false, false, false, false, x, y
		end
	end
	
	if currentblock[1]+1 > 0 and currentblock[1]+1 <= mapwidth and (currentblock[2] > 0 or currentblock[2] >= math.floor(sourcey+0.5))  and currentblock[2] < mapheight+1 and currentblock[1] ~= nil then
		local tendency
	
		--get tendency
		if side == "down" or side == "up" then
			if math.fmod(x, 1) > 0.5 then
				tendency = 1
			else
				tendency = -1
			end
		elseif side == "left" or side == "right" then
			if math.fmod(y, 1) > 0.5 then
				tendency = 1
			else
				tendency = -1
			end
		end
		
		return currentblock[1]+1, currentblock[2], side, tendency, x, y
	else
		return false, false, false, false, x, y
	end
end

function loadentity(t, x, y, r, id)
	local r = r
	if not r then
		--check if tile has settable option, if so default to this.
		r = {}
		if rightclickvalues[t] then
			r[3] = rightclickvalues[t][2]
		elseif rightclicktype[t] then
			r[3] = rightclicktype[t].default
		end
	end

	if t == "warppipe" then
		pipes[tilemap(x,y)] = pipe:new("warppipe", x, y, r)
	elseif t == "pipe" then
		if not (ismaptile(x, y) and map[x][y][1] and tilequads[map[x][y][1]].noteblock) then
			pipes[tilemap(x,y)] = pipe:new("pipe", x, y, r)
		end
	elseif t == "pipe2" then
		pipes[tilemap(x,y)] = pipe:new("pipe2", x, y, r)
	elseif t == "pipespawn" then
		local offseted = false
		--two way vertical pipe
		if inmap(x+1, y) and entityquads[map[x+1][y][2]] and entityquads[map[x+1][y][2]].t == "pipe" 
		and (not (map[x][y][3] and type(map[x][y][3]) == "string" and not (map[x][y][3]:find("up") or map[x][y][3]:find("down"))) ) then
			x = x+1
			offseted = true
		end
		--two way horizontal pipe
		if not offseted then
			if inmap(x, y+1) and entityquads[map[x][y+1][2]] and entityquads[map[x][y+1][2]].t == "pipe" 
			and (not (map[x][y][3] and type(map[x][y][3]) == "string" and not (map[x][y][3]:find("left") or map[x][y][3]:find("right"))) ) then
				y = y+1
				offseted = true
			end
		end
		exitpipes[tilemap(x,y)] = pipe:new("pipespawn", x, y, r)
	elseif t == "pipespawndown" then
		if inmap(x+1, y) and entityquads[map[x+1][y][2]] and entityquads[map[x+1][y][2]].t == "pipe2" then
			x = x+1
		end
		exitpipes[tilemap(x,y)] = pipe:new("pipespawndown", x, y, r)
	elseif t == "pipespawnhor" then
		if inmap(x, y+1) and entityquads[map[x][y+1][2]] and (entityquads[map[x][y+1][2]].t == "pipe" or entityquads[map[x][y+1][2]].t == "pipe2") then
			y = y+1
		end
		exitpipes[tilemap(x,y)] = pipe:new("pipespawnhor", x, y, r)
	elseif t == "flag" then
		flagx = x-1	
		flagy = y
		if r[3] then
			local v = convertr(r[3], {"string", "bool"}, true)
			flagborder = (v[1] == "true")
			if v[2] ~= nil then
				showcastleflag = v[2]
			else
				if custombackground then
					showcastleflag = false
				else
					showcastleflag = true
				end
			end
		else
			flagborder = true
			if custombackground then
				showcastleflag = false
			else
				showcastleflag = true
			end
		end
	elseif t == "manycoins" then
		map[x][y][3] = 7

	elseif t == "flyingfishstart" then
		flyingfishstartx = x
	elseif t == "flyingfishend" then
		flyingfishendx = x
		
	elseif t == "meteorstart" then
		meteorstartx = x
	elseif t == "meteorend" then
		meteorendx = x
		
	elseif t == "bulletbillstart" then
		bulletbillstartx = x
	elseif t == "bulletbillend" then
		bulletbillendx = x
		
	elseif t == "bigbillstart" then
		bigbillstartx = x
	elseif t == "bigbillend" then
		bigbillendx = x

	elseif t == "windstart" then
		windstartx = x
		if r[3] then
			local v = convertr(r[3], {"num"}, true)
			windentityspeed = v[1]
		else
			windentityspeed = windspeed
		end
	elseif t == "windend" then
		windendx = x
		
	elseif t == "axe" then
		axex = x
		axey = y

	elseif t == "lakitoend" then
		lakitoendx = x
	elseif t == "angrysunend" then
		angrysunendx = x
		
	elseif t == "checkpoint" then
		if not tablecontains(checkpoints, x) then
			table.insert(checkpoints, x)
			checkpointpoints[x] = y
			if r and #r > 2 then
				table.insert(objects["checkpoint"], checkpointentity:new(x, y, r, #checkpoints))
			end
		end
	elseif t == "checkpointflag" then
		if not tablecontains(checkpoints, x) then
			table.insert(checkpoints, x)
			checkpointpoints[x] = y
			objects["checkpointflag"][x] = checkpointflag:new(x, y, r, #checkpoints)
		end
	elseif t == "mazestart" then
		if not tablecontains(mazestarts, x) then
			table.insert(mazestarts, x)
		end
		mazesfuck = true
	elseif t == "mazeend" then
		if not tablecontains(mazeends, x) then
			table.insert(mazeends, x)
		end
		mazesfuck = true
	elseif t == "ceilblocker" then
		table.insert(objects["ceilblocker"], ceilblocker:new(x))
	elseif t == "geltop" then
		if tilequads[map[x][y][1]].collision then
			if type(r[3]) == "string" and r[3]:find("|") then
				local s = r[3]:split("|")
				local t = tonumber(s[1])
				if s[2] == "true" then map[x][y]["gels"]["top"] = t end
				if s[3] == "true" then map[x][y]["gels"]["left"] = t end
				if s[4] == "true" then map[x][y]["gels"]["bottom"] = t end
				if s[5] == "true" then map[x][y]["gels"]["right"] = t end
			else
				map[x][y]["gels"]["top"] = r[3]
			end
		end
	elseif t == "gelleft" then
		if tilequads[map[x][y][1]].collision then
			if type(r[3]) == "string" and r[3]:find("|") then
				local s = r[3]:split("|")
				local t = tonumber(s[1])
				if s[2] == "true" then map[x][y]["gels"]["top"] = t end
				if s[3] == "true" then map[x][y]["gels"]["left"] = t end
				if s[4] == "true" then map[x][y]["gels"]["bottom"] = t end
				if s[5] == "true" then map[x][y]["gels"]["right"] = t end
			else
				map[x][y]["gels"]["left"] = r[3]
			end
		end
	elseif t == "gelbottom" then
		if tilequads[map[x][y][1]].collision then
			if type(r[3]) == "string" and r[3]:find("|") then
				local s = r[3]:split("|")
				local t = tonumber(s[1])
				if s[2] == "true" then map[x][y]["gels"]["top"] = t end
				if s[3] == "true" then map[x][y]["gels"]["left"] = t end
				if s[4] == "true" then map[x][y]["gels"]["bottom"] = t end
				if s[5] == "true" then map[x][y]["gels"]["right"] = t end
			else
				map[x][y]["gels"]["bottom"] = r[3]
			end
		end
	elseif t == "gelright" then
		if tilequads[map[x][y][1]].collision then
			if type(r[3]) == "string" and r[3]:find("|") then
				local s = r[3]:split("|")
				local t = tonumber(s[1])
				if s[2] == "true" then map[x][y]["gels"]["top"] = t end
				if s[3] == "true" then map[x][y]["gels"]["left"] = t end
				if s[4] == "true" then map[x][y]["gels"]["bottom"] = t end
				if s[5] == "true" then map[x][y]["gels"]["right"] = t end
			else
				map[x][y]["gels"]["right"] = r[3]
			end
		end
	elseif t == "firestart" then
		firestartx = x
	elseif r[2] and tablecontains(customenemies, r[2]) then
		if enemiesdata[r[2]].spawnonload then
			local type, name = t[1], t[2]
			if (not tilequads[r[1]]["breakable"]) and (not tilequads[r[1]]["coinblock"]) then
				local obj = enemy:new(x, y, r[2], r)
				if r["argument"] and obj then
					if r["argument"] == "o" then --offsetted
						obj.x = obj.x + .5
						if obj.startx then
							obj.startx = obj.startx + .5
						end
					elseif r["argument"] == "b" then --supersized
						supersizeentity(obj)
					end
				end
				table.insert(objects["enemy"], obj)
				table.insert(enemiesspawned, {x, y})
				trackobject(x, y, obj, "enemy")
			end
		end
	else
		spawnentity(t, x, y, r, id)
	end
end

function spawnentity(t, x, y, r, id)
	local r = r
	if not r then
		--check if tile has settable option, if so default to this.
		r = {}
		if rightclickvalues[t] then
			r[3] = rightclickvalues[t][2]
		elseif rightclicktype[t] then
			r[3] = rightclicktype[t].default
		end
	end

	if t == "text" then
		table.insert(objects["text"], text:new(x, y, r, r[3]))
		
	elseif t == "tiletool" then
		table.insert(objects["tiletool"], tiletool:new(x, y, r, r[3]))
		
	elseif t == "enemytool" then
		table.insert(objects["enemytool"], enemytool:new(x, y, r, r[3]))
		
	elseif t == "regiontrigger" then
		table.insert(objects["regiontrigger"], regiontrigger:new(x, y, r[3], r))
		
	elseif t == "animationtrigger" then
		table.insert(objects["animationtrigger"], animationtrigger:new(x, y, r, r[3]))
	elseif t == "animationoutput" then
		table.insert(objects["animationoutput"], animationoutput:new(x, y, r, r[3]))

	elseif t == "risingwater" then
		table.insert(objects["risingwater"], risingwater:new(x, y, r))
		
	elseif t == "emancehor" then
		table.insert(emancipationgrills, emancipationgrill:new(x, y, "hor", r))
	elseif t == "emancever" then
		table.insert(emancipationgrills, emancipationgrill:new(x, y, "ver", r))
	elseif t == "laserfield" then
		table.insert(laserfields, laserfield:new(x, y, "ver", r))
		
	elseif t == "doorver" then
		table.insert(objects["door"], door:new(x, y, r, "ver"))
	elseif t == "doorhor" then
		table.insert(objects["door"], door:new(x, y, r, "hor"))
		
	elseif t == "button" then
		table.insert(objects["button"], button:new(x, y, 1, r))
	elseif t == "buttonbox" then
		table.insert(objects["button"], button:new(x, y, 2, r))
	elseif t == "buttonedgeless" then
		table.insert(objects["button"], button:new(x, y, 3, r))
		
	elseif t == "pushbuttonleft" then
		table.insert(objects["pushbutton"], pushbutton:new(x, y, "left", r))
	elseif t == "pushbuttonright" then
		table.insert(objects["pushbutton"], pushbutton:new(x, y, "right", r))
		
	elseif t == "wallindicator" then
		table.insert(objects["wallindicator"], wallindicator:new(x, y, r))
		
	elseif t == "groundlightver" then
		table.insert(objects["groundlight"], groundlight:new(x, y, 1, r))
	elseif t == "groundlighthor" then
		table.insert(objects["groundlight"], groundlight:new(x, y, 2, r))
	elseif t == "groundlightupright" then
		table.insert(objects["groundlight"], groundlight:new(x, y, 3, r))
	elseif t == "groundlightrightdown" then
		table.insert(objects["groundlight"], groundlight:new(x, y, 4, r))
	elseif t == "groundlightdownleft" then
		table.insert(objects["groundlight"], groundlight:new(x, y, 5, r))
	elseif t == "groundlightleftup" then
		table.insert(objects["groundlight"], groundlight:new(x, y, 6, r))
		
	elseif t == "faithplateup" then
		table.insert(objects["faithplate"], faithplate:new(x, y, "up", r[3], r))
	elseif t == "faithplateright" then
		table.insert(objects["faithplate"], faithplate:new(x, y, "right", r[3], r))
	elseif t == "faithplateleft" then
		table.insert(objects["faithplate"], faithplate:new(x, y, "left", r[3], r))
		
	elseif t == "laserright" then
		table.insert(objects["laser"], laser:new(x, y, "right", r))
	elseif t == "laserdown" then
		table.insert(objects["laser"], laser:new(x, y, "down", r))
	elseif t == "laserleft" then
		table.insert(objects["laser"], laser:new(x, y, "left", r))
	elseif t == "laserup" then
		table.insert(objects["laser"], laser:new(x, y, "up", r))
		
	elseif t == "lightbridgeright" then
		table.insert(objects["lightbridge"], lightbridge:new(x, y, "right", r))
	elseif t == "lightbridgeleft" then
		table.insert(objects["lightbridge"], lightbridge:new(x, y, "left", r))
	elseif t == "lightbridgedown" then
		table.insert(objects["lightbridge"], lightbridge:new(x, y, "down", r))
	elseif t == "lightbridgeup" then
		table.insert(objects["lightbridge"], lightbridge:new(x, y, "up", r))
		
	elseif t == "funnelright" then
		table.insert(objects["funnel"], funnel:new(x, y, "right", r))
	elseif t == "funneldown" then
		table.insert(objects["funnel"], funnel:new(x, y, "down", r))
	elseif t == "funnelleft" then
		table.insert(objects["funnel"], funnel:new(x, y, "left", r))
	elseif t == "funnelup" then
		table.insert(objects["funnel"], funnel:new(x, y, "up", r))
		
	elseif t == "laserdetectorright" then
		table.insert(objects["laserdetector"], laserdetector:new(x, y, "right", r))
	elseif t == "laserdetectordown" then
		table.insert(objects["laserdetector"], laserdetector:new(x, y, "down", r))
	elseif t == "laserdetectorleft" then
		table.insert(objects["laserdetector"], laserdetector:new(x, y, "left", r))
	elseif t == "laserdetectorup" then
		table.insert(objects["laserdetector"], laserdetector:new(x, y, "up", r))
		
	elseif t == "boxtube" then
		table.insert(objects["cubedispenser"], cubedispenser:new(x, y, r))
		
	elseif t == "bluegeldown" then
		table.insert(objects["geldispenser"], geldispenser:new(x, y, 1, "down", r))
	elseif t == "bluegelright" then
		table.insert(objects["geldispenser"], geldispenser:new(x, y, 1, "right", r))
	elseif t == "bluegelleft" then
		table.insert(objects["geldispenser"], geldispenser:new(x, y, 1, "left", r))
					
	elseif t == "orangegeldown" then
		table.insert(objects["geldispenser"], geldispenser:new(x, y, 2, "down", r))
	elseif t == "orangegelright" then
		table.insert(objects["geldispenser"], geldispenser:new(x, y, 2, "right", r))
	elseif t == "orangegelleft" then
		table.insert(objects["geldispenser"], geldispenser:new(x, y, 2, "left", r))
					
	elseif t == "whitegeldown" then
		table.insert(objects["geldispenser"], geldispenser:new(x, y, 3, "down", r))
	elseif t == "whitegelright" then
		table.insert(objects["geldispenser"], geldispenser:new(x, y, 3, "right", r))
	elseif t == "whitegelleft" then
		table.insert(objects["geldispenser"], geldispenser:new(x, y, 3, "left", r))
			
	elseif t == "purplegeldown" then
		table.insert(objects["geldispenser"], geldispenser:new(x, y, 4, "down", r))
	elseif t == "purplegelright" then
		table.insert(objects["geldispenser"], geldispenser:new(x, y, 4, "right", r))
	elseif t == "purplegelleft" then
		table.insert(objects["geldispenser"], geldispenser:new(x, y, 4, "left", r))
		
	elseif t == "watergeldown" then
		table.insert(objects["geldispenser"], geldispenser:new(x, y, 5, "down", r))
	elseif t == "watergelright" then
		table.insert(objects["geldispenser"], geldispenser:new(x, y, 5, "right", r))
	elseif t == "watergelleft" then
		table.insert(objects["geldispenser"], geldispenser:new(x, y, 5, "left", r))

	elseif t == "timer" then
		table.insert(objects["walltimer"], walltimer:new(x, y, r[3], r))
	elseif t == "notgate" then
		table.insert(objects["notgate"], notgate:new(x, y, r))
	elseif t == "orgate" then
		table.insert(objects["orgate"], orgate:new(x, y, r))
	elseif t == "andgate" then
		table.insert(objects["andgate"], andgate:new(x, y, r))
	elseif t == "rsflipflop" then
		table.insert(objects["rsflipflop"], rsflipflop:new(x, y, r))
	elseif t == "animatedtiletrigger" then
		table.insert(objects["animatedtiletrigger"], animatedtiletrigger:new(x, y, r))

	elseif t == "platformup" and r[4] then --linked platforms spawn automatically
		table.insert(objects["platform"], platform:new(x, y, "up", r[3], r)) --Platform right
		table.insert(enemiesspawned, {x, y})
		net_spawnenemy(x, y)
	elseif t == "platformright" and r[4] then
		table.insert(objects["platform"], platform:new(x, y, "right", r[3], r)) --Platform up
		table.insert(enemiesspawned, {x, y})
		net_spawnenemy(x, y)
	elseif t == "platform" and r[4] then
		table.insert(objects["platform"], platform:new(x, y, "default", r[3], r)) --Platform up
		table.insert(enemiesspawned, {x, y})
		net_spawnenemy(x, y)
		
	elseif t == "platformspawnerup" then
		table.insert(platformspawners, platformspawner:new(x, y, "up", r[3]))
	elseif t == "platformspawnerdown" then
		table.insert(platformspawners, platformspawner:new(x, y, "down", r[3]))

	elseif t == "redseesaw" then
		table.insert(objects["redseesaw"], redseesaw:new(x, y, r[3]))
		
	elseif t == "box" then
		table.insert(objects["box"], box:new(x, y))
	elseif t == "box2" then
		table.insert(objects["box"], box:new(x, y, "box2"))
	elseif t == "edgelessbox" then
		table.insert(objects["box"], box:new(x, y, "edgeless"))
		
	elseif t == "energylauncherright" then
		table.insert(objects["energylauncher"], energylauncher:new(x, y, "right", r))
	elseif t == "energylauncherleft" then
		table.insert(objects["energylauncher"], energylauncher:new(x, y, "left", r))
	elseif t == "energylauncherup" then
		table.insert(objects["energylauncher"], energylauncher:new(x, y, "up", r))
	elseif t == "energylauncherdown" then
		table.insert(objects["energylauncher"], energylauncher:new(x, y, "down", r))

	elseif t == "energycatcherright" then
		table.insert(objects["energycatcher"], energycatcher:new(x, y, "right", r[3]))
	elseif t == "energycatcherleft" then
		table.insert(objects["energycatcher"], energycatcher:new(x, y, "left", r[3]))
	elseif t == "energycatcherup" then
		table.insert(objects["energycatcher"], energycatcher:new(x, y, "up", r[3]))
	elseif t == "energycatcherdown" then
		table.insert(objects["energycatcher"], energycatcher:new(x, y, "down", r[3]))
		
	elseif t == "turretleft" then --change to enemy? (be wary of region triggers)
		table.insert(objects["turret"], turret:new(x, y, "left", "turret", r[3]))
	elseif t == "turretright" then
		table.insert(objects["turret"], turret:new(x, y, "right", "turret", r[3]))
	elseif t == "turret2left" then
		table.insert(objects["turret"], turret:new(x, y, "left", "turret2", r[3]))
	elseif t == "turret2right" then
		table.insert(objects["turret"], turret:new(x, y, "right", "turret2", r[3]))
		
	elseif t == "squarewave" then
		table.insert(objects["squarewave"], squarewave:new(x, y, r, r[3]))
	elseif t == "delayer" then
		table.insert(objects["delayer"], delayer:new(x, y, r, r[3]))
		
	elseif t == "rocketturret" then
		table.insert(objects["rocketturret"], rocketturret:new(x, y, r))
		
	elseif t == "glados" then --change to enemy? (be wary of region triggers)
		table.insert(objects["glados"], glados:new(x, y, r[3]))
		
	elseif t == "pedestal" then
		table.insert(objects["pedestal"], pedestal:new(x, y, r[3]))
		
	elseif t == "portal1" then
		table.insert(objects["portalent"], portalent:new(x, y, 1, r))
	elseif t == "portal2" then
		table.insert(objects["portalent"], portalent:new(x, y, 2, r))
		
	elseif t == "randomizer" then
		table.insert(objects["randomizer"], randomizer:new(x, y, r[3], r))
	elseif t == "musicchanger" then
		table.insert(objects["musicchanger"], musicchanger:new(x, y, r, r[3]))
		
	elseif t == "longfire" then --change to enemy? (be wary of region triggers)
		table.insert(objects["longfire"], longfire:new(x, y, r[3]))
	elseif t == "longfireoff" then
		table.insert(objects["longfire"], longfire:new(x, y, r[3], true))

	elseif t == "kingbill" then
		table.insert(kingbilllaunchers, kingbilllauncher:new(x, y, r[3], r))
		
	elseif t == "spring" then --change to enemy? (be wary of region triggers)
		table.insert(objects["spring"], spring:new(x, y))
	elseif t == "springgreen" then
		table.insert(objects["spring"], spring:new(x, y, "green"))
		
	elseif t == "seesaw" then
		table.insert(seesaws, seesaw:new(x, y, r[3]))
		
	elseif t == "blocktogglebutton" then --change to enemy? (be wary of region triggers)
		table.insert(objects["blocktogglebutton"], blocktogglebutton:new(x-0.5, y-1/16, r[3]))
	elseif t == "bigblocktogglebutton" then
		table.insert(objects["blocktogglebutton"], blocktogglebutton:new(x-0.5, y-1/16, r[3], "big"))

	elseif t == "flipblock" then
		objects["flipblock"][tilemap(x, y)] = flipblock:new(x, y)
	elseif t == "actionblock" then
		objects["flipblock"][tilemap(x, y)] = flipblock:new(x, y, "actionblock")
	elseif t == "switchblock" then
		objects["flipblock"][tilemap(x, y)] = flipblock:new(x, y, "switchblock", r[3])
	elseif t == "propellerbox" then
		if not tilequads[map[x][y][1]].collision then
			objects["flipblock"][tilemap(x, y)] = flipblock:new(x, y, "propellerbox")
		end
	elseif t == "cannonbox" then
		if not tilequads[map[x][y][1]].collision then
			objects["flipblock"][tilemap(x, y)] = flipblock:new(x, y, "cannonbox")
		end

	elseif t == "buttonblockon" then
		objects["buttonblock"][tilemap(x, y)] = buttonblock:new(x, y, r[3], true)
	elseif t == "buttonblockoff" then
		objects["buttonblock"][tilemap(x, y)] = buttonblock:new(x, y, r[3], false)
	elseif t == "pbuttonblockon" then
		objects["buttonblock"][tilemap(x, y)] = buttonblock:new(x, y, "p", true)
	elseif t == "pbuttonblockoff" then
		objects["buttonblock"][tilemap(x, y)] = buttonblock:new(x, y, "p", false)
		
	elseif t == "door" then
		objects["doorsprite"][tilemap(x, y)] = doorsprite:new(x, y, r, "door")
	elseif t == "pdoor" then
		objects["doorsprite"][tilemap(x, y)] = doorsprite:new(x, y, r, "pdoor")
	elseif t == "keydoor" then
		objects["doorsprite"][tilemap(x, y)] = doorsprite:new(x, y, r, "keydoor")

	elseif t == "skewer" then
		table.insert(objects["skewer"], skewer:new(x, y, r[3], r))
		
	elseif t == "belt" then
		table.insert(objects["belt"], belt:new(x, y, r))
	elseif t == "beltswitch" then
		table.insert(objects["belt"], belt:new(x, y, r, "switch"))

	elseif t == "collectable" then
		local coinblock = (tilequads[map[x][y][1]].collision and (tilequads[map[x][y][1]].breakable or tilequads[map[x][y][1]].coinblock))
		if not checkcollectable(x, y, tonumber(r[3])) then
			objects["collectable"][tilemap(x, y)] = collectable:new(x, y, r, false, coinblock)
		else
			objects["collectable"][tilemap(x, y)] = collectable:new(x, y, r, true, coinblock)
		end
	elseif t == "collectablelock" then
		table.insert(objects["collectablelock"], collectablelock:new(x, y, r[3]))

	elseif t == "snakeblock" then
		table.insert(snakeblocks, snakeblocksline:new(x, y, r))

	elseif t == "camerastop" then
		table.insert(objects["camerastop"], camerastop:new(x, y, r))

	elseif t == "clearpipe" then
		table.insert(clearpipes, clearpipe:new(x, y, r, "clearpipe"))
	elseif t == "pneumatictube" then
		table.insert(clearpipes, clearpipe:new(x, y, r, "pneumatictube"))

	elseif t == "plantcreeper" then
		table.insert(objects["plantcreeper"], plantcreeper:new(x, y, r))

	elseif t == "track" then
		table.insert(tracks, track:new(x, y, r, false))
	elseif t == "trackswitch" then
		table.insert(tracks, track:new(x, y, r, "switch"))

	elseif t == "grinder" then
		table.insert(objects["grinder"] , grinder:new(x, y, r[3]))
	end
end

function spawnenemyentity(x, y)
	if not inmap(x, y) then
		return false
	end

	if editormode then
		return false
	end

	--don't do anything if it's already spawned
	for i = 1, #enemiesspawned do
		if x == enemiesspawned[i][1] and y == enemiesspawned[i][2] then
			return false
		end
	end

	local r = map[x][y] --tile
	if #r > 1 then
		--get the name of the entity
		local t
		if tablecontains(customenemies, r[2]) then
			--custom enemy
			t = {"customenemy", r[2]}
		elseif entitylist[r[2]] then
			t = entitylist[r[2]].t
		else --entity does not exist
			return false
		end

		--was it an enemy?
		local obj, wasenemy, objtable = spawnenemy(t, x, y, r)
		if wasenemy then
			--argument
			if r["argument"] and obj then
				if r["argument"] == "o" then --offsetted
					obj.x = obj.x + .5
					if obj.startx then
						obj.startx = obj.startx + .5
					end
				elseif r["argument"] == "b" then --supersized
					supersizeentity(obj)
				end
			end
			--track
			local tracked = trackobject(x, y, obj, objtable)
			--don't attempt to spawn again
			table.insert(enemiesspawned, {x, y})
			if wasenemy ~= "ignore" and (not tracked) then
				net_spawnenemy(x, y)
				
				--spawn enemies in 5x1 line so they spawn as a unit and not alone.
				spawnenemyentity(x-2, y)
				spawnenemyentity(x-1, y)
				spawnenemyentity(x+1, y)
				spawnenemyentity(x+2, y)
			end
		end
	end
end

function spawnenemy(t, x, y, r, spawner)
	local r = r --tile
	if not r then
		--check if tile has settable option, if so default to this.
		r = {1}
		if rightclickvalues[t] then
			r[3] = rightclickvalues[t][2]
		elseif rightclicktype[t] then
			r[3] = rightclicktype[t].default
		end
	end
	if (anyiteminblock and tilequads[r[1]]["collision"])
		or (r[2] and entitylist[r[2]] and entitylist[r[2]].block and tilequads[r[1]]["collision"] and (tilequads[r[1]]["breakable"] or (not tilequads[r[1]]["breakable"]) and tilequads[r[1]]["coinblock"]) and not spawner) then
		return false, "ignore"
	end
	
	local obj, objtable --object that spawned, table object is stored in
	local wasenemy = true

	if type(t) == "table" then --{"customenemy", "name"}
		local type, name = t[1], t[2]
		if (not tilequads[r[1]]["breakable"]) and (not tilequads[r[1]]["coinblock"]) then
			objtable, obj = "enemy", enemy:new(x, y, name, r)
		else
			wasenemy = "ignore"
		end
	else
		if t == "goomba" then
			objtable, obj = "goomba", goomba:new(x-0.5, y-1/16)
		elseif t == "goombahalf" then
			objtable, obj = "goomba", goomba:new(x, y-1/16)
		elseif t == "koopa" then
			objtable, obj = "koopa", koopa:new(x-0.5, y-1/16)
		elseif t == "koopahalf" then
			objtable, obj = "koopa", koopa:new(x, y-1/16)
		elseif t == "koopared" then
			objtable, obj = "koopa", koopa:new(x-0.5, y-1/16, "red")
		elseif t == "kooparedhalf" then
			objtable, obj = "koopa", koopa:new(x, y-1/16, "red")
		elseif t == "beetle" then
			objtable, obj = "koopa", koopa:new(x-0.5, y-1/16, "beetle")
		elseif t == "beetlehalf" then
			objtable, obj = "koopa", koopa:new(x, y-1/16, "beetle")
		elseif t == "downbeetle" then
			objtable, obj = "koopa", koopa:new(x-0.5, y-4/16, "downbeetle")
		elseif t == "kooparedflying" then
			objtable, obj = "koopa", koopa:new(x-.5, y-1/16, "redflying")
		elseif t == "koopaflying" then
			objtable, obj = "koopa", koopa:new(x-.5, y-1/16, "flying")
		elseif t == "bowser" then
			if r[3] and r[3] == "enemy" then
				objtable, obj = "bowser", bowser:new(x-5, y-1/16, nil, true)
			else
				obj = bowser:new(x, y-1/16)
				objects["bowser"]["boss"] = obj
			end
		elseif t == "cheepred" then
			objtable, obj = "cheep", cheepcheep:new(x-.5, y-1/16, 1)
		elseif t == "cheepwhite" then
			objtable, obj = "cheep", cheepcheep:new(x-.5, y-1/16, 2)
		elseif t == "spikey" then
			objtable, obj = "goomba", goomba:new(x-0.5, y-1/16, "spikey")
		elseif t == "spikeyhalf" then
			objtable, obj = "goomba", goomba:new(x, y-1/16, "spikey")
		elseif t == "downspikey" then
			objtable, obj = "koopa", koopa:new(x-0.5, y-4/16, "downspikey")
		elseif t == "spikeyfall" then
			objtable, obj = "goomba", goomba:new(x-0.5, y-1/16, "spikeyfall")
		elseif t == "spikeyshell" then
			objtable, obj = "koopa", koopa:new(x-0.5, y-1/16, "spikeyshell")
		elseif t == "lakito" then
			objtable, obj = "lakito", lakito:new(x, y-1/16)
		elseif t == "squid" then
			objtable, obj = "squid", squid:new(x, y-1/16)
		elseif t == "paragoomba" then
			objtable, obj = "goomba", goomba:new(x-0.5, y-1/16, "paragoomba")
		elseif t == "sidestepper" then
			objtable, obj = "sidestepper", sidestepper:new(x-0.5, y-1/16)
		elseif t == "barrel" then
			objtable, obj = "barrel", barrel:new(x-0.5, y-1/16)
		elseif t == "icicle" then
			objtable, obj = "icicle", icicle:new(x, y, "small", false, r[3])
		elseif t == "iciclebig" then
			objtable, obj = "icicle", icicle:new(x, y, "big", false, r[3])
		elseif t == "angrysun" then
			objtable, obj = "angrysun", angrysun:new(x, y-1/16)
		elseif t == "splunkin" then
			objtable, obj = "splunkin", splunkin:new(x-0.5, y-1/16)
		elseif t == "splunkinhalf" then
			objtable, obj = "splunkin", splunkin:new(x, y-1/16)
		elseif t == "biggoomba" then
			objtable, obj = "goomba", goomba:new(x-0.5, y-1/16, "biggoomba")
		elseif t == "bigspikey" then
			objtable, obj = "goomba", goomba:new(x-0.5, y-1/16, "bigspikey")
		elseif t == "bigkoopa" then
			objtable, obj = "koopa", koopa:new(x-0.5, y-1/16, "bigkoopa")
		elseif t == "shell" then
			objtable, obj = "koopa", koopa:new(x-0.5, y-1/16, "shell")
		elseif t == "goombrat" then
			objtable, obj = "goomba", goomba:new(x-0.5, y-1/16, "goombrat")
		elseif t == "goombrathalf" then
			objtable, obj = "goomba", goomba:new(x, y-1/16, "goombrat")
		elseif t == "thwomp" then
			objtable, obj = "thwomp", thwomp:new(x-3/16, y, "down", r[3])
		elseif t == "thwomphalf" then
			objtable, obj = "thwomp", thwomp:new(x+5/16, y, "down", r[3])
		elseif t == "thwompleft" then
			objtable, obj = "thwomp", thwomp:new(x+5/16, y, "left", r[3])
		elseif t == "thwompright" then
			objtable, obj = "thwomp", thwomp:new(x+5/16-1, y, "right", r[3])
		elseif t == "fishbone" then
			objtable, obj = "fishbone", fishbone:new(x-.5, y-1/16, 1)
		elseif t == "drybones" then
			objtable, obj = "drybones", drybones:new(x-0.5, y-1/16)
		elseif t == "dryboneshalf" then
			objtable, obj = "drybones", drybones:new(x, y-1/16)
		elseif t == "muncher" then
			local physics = false
			if ismaptile(x, y+1) and tilequads[map[x][y+1][1]] and not tilequads[map[x][y+1][1]].collision then
				physics = true
			end
			objtable, obj = "muncher", muncher:new(x-0.5, y-1/16, physics, r[3])
		elseif t == "bigbeetle" then
			objtable, obj = "koopa", koopa:new(x-0.5, y-1/16, "bigbeetle")
		elseif t == "drygoomba" then
			objtable, obj = "goomba", goomba:new(x-0.5, y-1/16, "drygoomba")
		elseif t == "drygoombahalf" then
			objtable, obj = "goomba", goomba:new(x, y-1/16, "drygoomba")
		elseif t == "donut" then
			objtable, obj = "donut", donut:new(x, y, "donut", nil, r[3])
		elseif t == "donutlast" then
			objtable, obj = "donut", donut:new(x, y, "donutlast", nil, r[3])
		elseif t == "parabeetle" then
			objtable, obj = "parabeetle", parabeetle:new(x-0.5, y-1/16)
		elseif t == "ninji" then
			objtable, obj = "ninji", ninji:new(x-0.5, y-1/16)
		elseif t == "boo" then
			objtable, obj = "boo", boo:new(x-0.5, y-1/16)
		elseif t == "mole" then
			objtable, obj = "mole", mole:new(x-0.5, y-1/16, r[3])
		elseif t == "moleground" then
			objtable, obj = "mole", mole:new(x-0.5, y-1/16, "true")
		elseif t == "bigmole" then
			objtable, obj = "bigmole", bigmole:new(x-0.5, y-1/16)
		elseif t == "bomb" then
			objtable, obj = "bomb", bomb:new(x-0.5, y-1/16)
		elseif t == "bombhalf" then
			objtable, obj = "bomb", bomb:new(x, y-1/16)
		elseif t == "parabeetleright" then
			objtable, obj = "parabeetle", parabeetle:new(x-0.5, y-1/16, "parabeetleright")
		elseif t == "boomboom" then
			objtable, obj = "boomboom", boomboom:new(x-0.5, y-1/16, r[3])
		elseif t == "levelball" then
			if not tilequads[r[1]]["collision"] then
				objtable, obj = "levelball", levelball:new(x-0.5, y-1/16)
			end
		elseif t == "koopablue" then
			objtable, obj = "koopa", koopa:new(x-0.5, y-1/16, "blue")
		elseif t == "koopabluehalf" then
			objtable, obj = "koopa", koopa:new(x, y-1/16, "blue")
		elseif t == "koopaflying2" then
			objtable, obj = "koopa", koopa:new(x-.5, y-1/16, "flying2")
		elseif t == "pinksquid" then
			objtable, obj = "squid", squid:new(x, y-1/16, "pink")
		elseif t == "sleepfish" then
			objtable, obj = "cheep", cheepcheep:new(x-.5, y-1/16, 3)
		elseif t == "amp" then
			objtable, obj = "amp", amp:new(x, y, r[3])
			if obj.t == "fuzzy" then
				objtable = "fuzzy"
			end
		elseif t == "parabeetlegreen" then
			objtable, obj = "parabeetle", parabeetle:new(x-0.5, y-1/16, "parabeetlegreen")
		elseif t == "parabeetlegreenright" then
			objtable, obj = "parabeetle", parabeetle:new(x-0.5, y-1/16, "parabeetlegreenright")
		elseif t == "shyguy" then
			objtable, obj = "goomba", goomba:new(x-0.5, y-1/16, "shyguy")
		elseif t == "shyguyhalf" then
			objtable, obj = "goomba", goomba:new(x, y-1/16, "shyguy")
		elseif t == "beetleshell" then
			objtable, obj = "koopa", koopa:new(x-0.5, y-1/16, "beetleshell")
		elseif t == "spiketop" then
			if ismaptile(x, y+1) and ismaptile(x, y-1) and tilequads[map[x][y-1][1]]:getproperty("collision",x,y-1) and not tilequads[map[x][y+1][1]]:getproperty("collision",x,y+1) then
				objtable, obj = "goomba", goomba:new(x-0.5, y-1/16, "spiketopup")
			else
				objtable, obj = "goomba", goomba:new(x-0.5, y-1/16, "spiketop")
			end
		elseif t == "spiketophalf" then
			if ismaptile(x, y+1) and ismaptile(x, y-1) and tilequads[map[x][y-1][1]]:getproperty("collision",x,y-1) and not tilequads[map[x][y+1][1]]:getproperty("collision",x,y+1) then
				objtable, obj = "goomba", goomba:new(x, y-1/16, "spiketopup")
			else
				objtable, obj = "goomba", goomba:new(x, y-1/16, "spiketop")
			end
		elseif t == "pokey" then
			objtable, obj = "pokey", pokey:new(x-0.5, y-3/16, "pokey", r[3])
		elseif t == "snowpokey" then
			objtable, obj = "pokey", pokey:new(x-0.5, y-3/16, "snowpokey", r[3])
		elseif t == "fighterfly" then
			objtable, obj = "goomba", goomba:new(x-0.5, y-1/16, "fighterfly")
		elseif t == "chainchomp" then
			objtable, obj = "chainchomp", chainchomp:new(x, y)
		elseif t == "rockywrench" then
			objtable, obj = "rockywrench", rockywrench:new(x, y)
		elseif t == "thwimp" then
			objtable, obj = "thwomp", thwomp:new(x, y, "thwimp")
		elseif t == "drybeetle" then
			objtable, obj = "drybones", drybones:new(x-0.5, y-1/16, "drybeetle")
		elseif t == "drybeetlehalf" then
			objtable, obj = "drybones", drybones:new(x, y-1/16, "drybeetle")
		elseif t == "boocrawler" then
			if ismaptile(x, y+1) and ismaptile(x, y-1) and tilequads[map[x][y-1][1]]:getproperty("collision",x,y-1) and not tilequads[map[x][y+1][1]]:getproperty("collision",x,y+1) then
				objtable, obj = "drybones", drybones:new(x-0.5, y-1/16, "boocrawlerup")
			else
				objtable, obj = "drybones", drybones:new(x-0.5, y-1/16, "boocrawler")
			end
		elseif t == "tinygoomba" then
			objtable, obj = "goomba", goomba:new(x, y+15/16, "tinygoomba")
		elseif t == "koopaling" then
			objtable, obj = "koopaling", koopaling:new(x-0.5, y-1/16, r[3])
		elseif t == "bowserjr" then
			objtable, obj = "koopaling", koopaling:new(x-0.5, y-1/16, 8, r[3])
		elseif t == "bowser3" then
			objtable, obj = "koopaling", koopaling:new(x-0.5, y-1/16, 9, r[3])
		elseif t == "squidnanny" then
			objtable, obj = "squid", squid:new(x, y-1/16, "nanny")
		elseif t == "wigglerangry" then
			objtable, obj = "goomba", goomba:new(x-0.5, y-1/16, "wigglerangry")
		elseif t == "wiggler" then
			objtable, obj = "goomba", goomba:new(x-0.5, y-1/16, "wiggler")
		elseif t == "magikoopa" then
			objtable, obj = "magikoopa", magikoopa:new(x-0.5, y-1/16)
		elseif t == "spike" then
			objtable, obj = "spike", spike:new(x-0.5, y-1/16, r[3])
		elseif t == "spikeball" then
			objtable, obj = "spikeball", spikeball:new(x-0.5, y, r[3], "left", true)
			
		elseif t == "platformup" and not r[4] then
			objtable, obj = "platform", platform:new(x, y, "up", r[3]) --Platform right
		elseif t == "platformright" and not r[4] then
			objtable, obj = "platform", platform:new(x, y, "right", r[3]) --Platform up
		elseif t == "platform" and not r[4] then
			objtable, obj = "platform", platform:new(x, y, "default", r[3]) --Platform
			
		elseif t == "platformfall" then
			objtable, obj = "platform", platform:new(x, y, "fall", r[3]) --Platform fall
			
		elseif t == "platformbonus" then
			objtable, obj = "platform", platform:new(x, y, "justright", r[3])
			
		elseif t == "plant" then
			objtable, obj = "plant", plant:new(x, y, "plant", r[3])
	
		elseif t == "castlefirecw" then
			objtable, obj = "castlefire", castlefire:new(x, y, r[3], "cw")
			
		elseif t == "castlefireccw" then
			objtable, obj = "castlefire", castlefire:new(x, y, r[3], "ccw")
			
		elseif t == "rotodisc" then
			objtable, obj = "castlefire", castlefire:new(x, y, r[3], nil, "rotodisc")
			
		elseif t == "boocircle" then
			objtable, obj = "castlefire", castlefire:new(x, y, r[3], nil, "boocircle")
			
		elseif t == "hammerbro" then
			objtable, obj = "hammerbro", hammerbro:new(x, y)
			
		elseif t == "boomerangbro" then
			objtable, obj = "hammerbro", hammerbro:new(x, y, "boomerang")
			
		elseif t == "firebro" then
			objtable, obj = "hammerbro", hammerbro:new(x, y, "fire")
			
		elseif t == "bighammerbro" then
			objtable, obj = "hammerbro", hammerbro:new(x, y, "big")
			
		elseif t == "icebro" then
			objtable, obj = "hammerbro", hammerbro:new(x, y, "ice")
			
		elseif t == "downplant" then
			objtable, obj = "plant", plant:new(x, y, "plant", r[3] or "down")
			
		elseif t == "redplant" then
			objtable, obj = "plant", plant:new(x, y, "redplant", r[3])

		elseif t == "reddownplant" then
			objtable, obj = "plant", plant:new(x, y, "redplant", r[3] or "down")
		
		elseif t == "dryplant" then
			objtable, obj = "plant", plant:new(x, y, "dryplant", r[3])
			
		elseif t == "drydownplant" then
			objtable, obj = "plant", plant:new(x, y, "dryplant", r[3] or "down")
			
		elseif t == "fireplant" then
			objtable, obj = "plant", plant:new(x, y, "fireplant", r[3])
			
		elseif t == "downfireplant" then
			objtable, obj = "plant", plant:new(x, y, "fireplant", r[3] or "down")
		
		elseif t == "torpedoted" then
			objtable, obj = "torpedolauncher", torpedolauncher:new(x, y)
		
		elseif t == "frozencoin" then
			objects["frozencoin"][tilemap(x, y)] = frozencoin:new(x, y)
			
		elseif t == "powblock" then
			objtable, obj = "powblock", powblock:new(x, y)
		elseif t == "verspring" then
			objtable, obj = "smallspring", smallspring:new(x, y, "ver")
		elseif t == "horspring" then
			objtable, obj = "smallspring", smallspring:new(x, y, "hor")
		
		elseif t == "bulletbill" then
			table.insert(rocketlaunchers, rocketlauncher:new(x, y))
		elseif t == "bigbill" then
			table.insert(bigbilllaunchers, bigbilllauncher:new(x, y))
		elseif t == "cannonball" then
			table.insert(cannonballlaunchers, cannonballlauncher:new(x, y, r[3]))
		elseif t == "homingbullet" then
			table.insert(rocketlaunchers, rocketlauncher:new(x, y, "homing"))
		elseif t == "cannonballcannon" then
			objtable, obj = "cannonballcannon", cannonballcannon:new(x, y, r[3])
			
		elseif t == "upfire" then
			objtable, obj = "upfire", upfire:new(x, y, r[3])

		elseif t == "coin" then
			if not (ismaptile(x, y) and tilequads[map[x][y][1]] and tilequads[map[x][y][1]].collision and tilequads[map[x][y][1]].breakable) then
				objects["coin"][tilemap(x, y)] = coin:new(x, y)
			end

		elseif t == "cheepcheep" then
			if math.random(2) == 1 then
				--objtable, obj = "cheep", enemy:new(x, y, "cheepcheepwhite", r)
				objtable, obj = "cheep", cheepcheep:new(x-.5, y-1/16, 2)
			else
				--objtable, obj = "cheep", enemy:new(x, y, "cheepcheepred", r)
				objtable, obj = "cheep", cheepcheep:new(x-.5, y-1/16, 1)
			end
		elseif t == "goombashoe" then
			if (not tilequads[r[1]]["collision"]) or spawner then
				if r[3] == 2 then
					objtable, obj = "goomba", goomba:new(x-0.5, y-1/16, "goombaheel")
				else
					objtable, obj = "goomba", goomba:new(x-0.5, y-1/16, "goombashoe")
				end
			end
		elseif t == "bigcloud" then
			if not tilequads[r[1]]["collision"] or spawner then
				obj = mushroom:new(x-0.5, y-1/16, "bigcloud", r[3])
				obj.uptimer = mushroomtime+0.00001; obj.active = true
				objtable = "mushroom"
			end
		elseif t == "drybonesshell" then
			if not tilequads[r[1]]["collision"] or spawner then
				obj = mushroom:new(x-0.5, y-1/16, "drybonesshell")
				obj.uptimer = mushroomtime+0.00001
				objtable = "mushroom"
			end
		--items without block
		elseif t == "threeup" and ((not tilequads[r[1]].collision) or spawner) then
			obj = smbsitem:new(x-0.5, y+14/16, "threeup")
			obj.uptimer = mushroomtime+0.00001
			objtable = "threeup"
		elseif t == "plusclock" and ((not tilequads[r[1]].collision) or spawner) then
			obj = smbsitem:new(x-0.5, y+14/16, "clock", r[3] or 100)
			obj.uptimer = mushroomtime+0.00001
			objtable = "smbsitem"
		elseif t == "swimwing" and ((not tilequads[r[1]].collision) or spawner) then
			obj = smbsitem:new(x-0.5, y+14/16, "wing")
			obj.uptimer = mushroomtime+0.00001
			objtable = "smbsitem"
		elseif t == "dkhammer" and ((not tilequads[r[1]].collision) or spawner) then
			obj = smbsitem:new(x-0.5, y+14/16, "dkhammer")
			obj.uptimer = mushroomtime+0.00001
			objtable = "smbsitem"
		elseif t == "luckystar" and ((not tilequads[r[1]].collision) or spawner) then
			obj = smbsitem:new(x-0.5, y+14/16, "luckystar")
			obj.uptimer = mushroomtime+0.00001
			objtable = "smbsitem"
		elseif t == "key" and ((not tilequads[r[1]].collision) or spawner) then
			obj = smbsitem:new(x-0.5, y+14/16, "key")
			obj.uptimer = mushroomtime+0.00001
			objtable = "smbsitem"
		elseif t == "pbutton" and ((not tilequads[r[1]].collision) or spawner) then
			obj = blocktogglebutton:new(x-0.5, y-1/16, r[3], "p")
			objtable = "pbutton"
			--these may break old mappacks, quote if needed
		elseif t == "mushroom" and (((r[2] == 2) and not tilequads[r[1]].collision) or spawner) then
			obj = mushroom:new(x-0.5, y-2/16)
			obj.uptimer = mushroomtime+0.00001
			obj.speedx = mushroomspeed
			objtable = "mushroom"
		elseif t == "fireflower" and ((not tilequads[r[1]].collision) or spawner) then
			obj = flower:new(x-0.5, y+14/16)
			obj.uptimer = mushroomtime
			obj.speedx = mushroomspeed
			objtable = "flower"
		elseif t == "oneup" and ((not tilequads[r[1]].collision) or spawner) then
			obj = mushroom:new(x-0.5, y-2/16, "oneup")
			obj.uptimer = mushroomtime+0.00001
			obj.speedx = mushroomspeed
			objtable = "oneup"
		elseif t == "star" and ((not tilequads[r[1]].collision) or spawner) then
			obj = star:new(x-0.5, y-2/16)
			obj.uptimer = mushroomtime+0.00001
			objtable = "star"
		elseif t == "poisonmush" and ((not tilequads[r[1]].collision) or spawner) then
			obj = poisonmush:new(x-0.5, y-2/16)
			obj.uptimer = mushroomtime+0.00001
			obj.speedx = mushroomspeed
			objtable = "poisonmush"
		elseif t == "yoshi" and ((not tilequads[r[1]].collision) or spawner) then
			obj = yoshiegg:new(x-0.5, y+14/16, r[3])
			obj.uptimer = mushroomtime+0.00001
			objtable = "yoshiegg"
		elseif t == "hammersuit" and ((not tilequads[r[1]].collision) or spawner) then
			obj = star:new(x-0.5, y-2/16, "hammersuit")
			obj.uptimer = mushroomtime+0.00001
			objtable = "hammersuit"
		elseif t == "frogsuit" and ((not tilequads[r[1]].collision) or spawner) then
			obj = star:new(x-0.5, y-2/16, "frogsuit")
			obj.uptimer = mushroomtime+0.00001
			objtable = "frogsuit"
		elseif t == "leaf" and ((not tilequads[r[1]].collision) or spawner) then
			obj = leaf:new(x-0.5, y)
			objtable = "leaf"
		elseif t == "minimushroom" and ((not tilequads[r[1]].collision) or spawner) then
			obj = mushroom:new(x-0.5, y+5/16, "mini")
			obj.uptimer = mushroomtime+0.00001
			obj.speedx = mushroomspeed
			objtable = "mushroom"
		elseif t == "iceflower" and ((not tilequads[r[1]].collision) or spawner) then
			obj = flower:new(x-0.5, y+14/16, "ice")
			obj.uptimer = mushroomtime+0.00001
			objtable = "flower"
		elseif t == "bigmushroom" and ((not tilequads[r[1]].collision) or spawner) then
			obj = mushroom:new(x-0.5, y-2/16, "big")
			obj.uptimer = mushroomtime+0.00001
			obj.speedx = mushroomspeed
			objtable = "mushroom"
		elseif t == "bigclassicmushroom" and ((not tilequads[r[1]].collision) or spawner) then
			obj = mushroom:new(x-0.5, y-2/16, "bigclassic")
			obj.uptimer = mushroomtime+0.00001
			obj.speedx = mushroomspeed
			objtable = "mushroom"
		elseif t == "tanookisuit" and ((not tilequads[r[1]].collision) or spawner) then
			obj = star:new(x-0.5, y-2/16, "tanookisuit")
			obj.uptimer = mushroomtime+0.00001
			objtable = "flower"
		elseif t == "feather" and ((not tilequads[r[1]].collision) or spawner) then
			obj = flower:new(x-0.5, y+14/16, "feather")
			obj.uptimer = mushroomtime+0.00001
			objtable = "flower"
		elseif t == "carrot" and ((not tilequads[r[1]].collision) or spawner) then
			obj = flower:new(x-0.5, y+14/16, "carrot")
			obj.uptimer = mushroomtime+0.00001
			objtable = "flower"
		elseif t == "weirdmushroom" and ((not tilequads[r[1]].collision) or spawner) then
			obj = mushroom:new(x-0.5, y-2/16, "weird")
			obj.uptimer = mushroomtime+0.00001
			obj.speedx = mushroomspeed
			objtable = "mushroom"
		elseif t == "superballflower" and ((not tilequads[r[1]].collision) or spawner) then
			obj = flower:new(x-0.5, y+14/16, "superball")
			obj.uptimer = mushroomtime+0.00001
			objtable = "flower"
		elseif t == "blueshell" and ((not tilequads[r[1]].collision) or spawner) then
			obj = flower:new(x-0.5, y+14/16, "blueshell")
			obj.uptimer = mushroomtime+0.00001
			objtable = "flower"
		elseif t == "boomerangflower" and ((not tilequads[r[1]].collision) or spawner) then
			obj = flower:new(x-0.5, y+14/16, "boomerang")
			obj.uptimer = mushroomtime+0.00001
			objtable = "flower"
		else
			wasenemy = false
		end
	end

	if obj and objtable then
		table.insert(objects[objtable], obj)
	end
	
	return obj, wasenemy, objtable
end

function item(i, x, y, size)
	local t = "entity"
	if type(i) == "table" then
		t = i[1]
		i = i[2]
	end
	--[[if inmap(x, y) and tilequads[map[x][y][1]]--[[["noteblock"] and _G[i] then
		local obj = _G[i]:new(x-0.5, y-1)
		obj.x = x-0.5-(obj.width/2)
		obj.y = y
		obj:update(0)
		obj.speedy = mushroomjumpforce
		obj.uptimer = mushroomtime
		table.insert(objects[i], obj)
		return
	end]]
	
	if t == "customenemy" then
		if enemiesdata[i] then
			table.insert(itemanimations, itemanimation:new(x, y, i, size))
		else
			return false
		end
	elseif i == "powerup" and enemiesdata["mushroom"] and enemiesdata["flower"] then
		if size and size <= 1 then
			table.insert(itemanimations, itemanimation:new(x, y, "mushroom"))
		else
			table.insert(itemanimations, itemanimation:new(x, y, "flower"))
		end
	elseif i == "mushroom" or i == "powerup" or i == "fireflower" then
		if size and size > 1 then
			table.insert(objects["flower"], flower:new(x-0.5, y-2/16))
		else
			table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16))
		end
	elseif i == "oneup" then
		table.insert(objects["oneup"], mushroom:new(x-0.5, y-2/16, "oneup"))
	elseif i == "star" then
		table.insert(objects["star"], star:new(x-0.5, y-2/16))
	elseif i == "vine" then
		table.insert(objects["vine"], vine:new(x, y))
	elseif i == "poisonmush" then
		table.insert(objects["poisonmush"], poisonmush:new(x-0.5, y-2/16))
	elseif i == "threeup" then
		table.insert(objects["threeup"], smbsitem:new(x-0.5, y-2/16, "threeup"))
	elseif i == "plusclock" then
		table.insert(objects["smbsitem"], smbsitem:new(x-0.5, y-2/16, "clock", map[x][y][3] or 100))
	elseif i == "swimwing" then
		table.insert(objects["smbsitem"], smbsitem:new(x-0.5, y-2/16, "wing"))
	elseif i == "dkhammer" then
		table.insert(objects["smbsitem"], smbsitem:new(x-0.5, y-2/16, "dkhammer"))
	elseif i == "luckystar" then
		table.insert(objects["smbsitem"], smbsitem:new(x-0.5, y-2/16, "luckystar"))
	elseif i == "key" then
		table.insert(objects["smbsitem"], smbsitem:new(x-0.5, y-2/16, "key"))
	elseif i == "hammersuit" then
		if size and size > 1 then
			table.insert(objects["hammersuit"], star:new(x-0.5, y-2/16, "hammersuit"))
		else
			table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16))
		end
	elseif i == "frogsuit" then
		if size and size > 1 then
			table.insert(objects["frogsuit"], star:new(x-0.5, y-2/16, "frogsuit"))
		else
			table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16))
		end
	elseif i == "leaf" then
		if size and size > 1 then
			table.insert(objects["leaf"], leaf:new(x-0.5, y-2/16))
		else
			table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16))
		end
	elseif i == "minimushroom" then
		table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16, "mini"))
	elseif i == "iceflower" then
		if size and size > 1 then
			table.insert(objects["flower"], flower:new(x-0.5, y-2/16, "ice"))
		else
			table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16))
		end
	elseif i == "yoshi" then
		table.insert(objects["yoshiegg"], yoshiegg:new(x-0.5, y-2/16, map[x][y][3]))
	elseif i == "pbutton" then
		table.insert(objects["pbutton"], blocktogglebutton:new(x-0.5, y-1/16, map[x][y][3], "p"))
	elseif i == "bigmushroom" then
		table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16, "big"))
	elseif i == "bigclassicmushroom" then
		table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16, "bigclassic"))
	elseif i == "goombashoe" then
		local obj = mushroom:new(x-0.5, y-2/16, "goombashoe")
		if ismaptile(x,y) and map[x][y][3] and map[x][y][3] == 2 then
			obj.heel = true
		end
		table.insert(objects["mushroom"], obj)
	elseif i == "tanookisuit" then
		if size and size > 1 then
			table.insert(objects["flower"], star:new(x-0.5, y-2/16, "tanookisuit"))
		else
			table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16))
		end
	elseif i == "feather" then
		if size and size > 1 then
			table.insert(objects["flower"], flower:new(x-0.5, y-2/16, "feather"))
		else
			table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16))
		end
	elseif i == "carrot" then
		if size and size > 1 then
			table.insert(objects["flower"], flower:new(x-0.5, y-2/16, "carrot"))
		else
			table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16))
		end
	elseif i == "superballflower" then
		if size and size > 1 then
			table.insert(objects["flower"], flower:new(x-0.5, y-2/16, "superball"))
		else
			table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16))
		end
	elseif i == "blueshell" then
		if size and size > 1 then
			table.insert(objects["flower"], flower:new(x-0.5, y-2/16, "blueshell"))
		else
			table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16))
		end
	elseif i == "boomerangflower" then
		if size and size > 1 then
			table.insert(objects["flower"], flower:new(x-0.5, y-2/16, "boomerang"))
		else
			table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16))
		end
	elseif i == "weirdmushroom" then
		table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16, "weird"))
	elseif i == "bigcloud" then
		table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16, "bigcloud", map[x][y][3]))
	elseif i == "drybonesshell" then
		table.insert(objects["mushroom"], mushroom:new(x-0.5, y-2/16, "drybonesshell"))
	elseif i == "propellerbox" then
		objects["flipblock"][tilemap(x, y)] = flipblock:new(x, y, "propellerbox")
		objects["flipblock"][tilemap(x, y)]:hit()
		map[x][y][1] = 1
		objects["tile"][tilemap(x, y)] = nil
		map[x][y]["gels"] = {}
	elseif i == "cannonbox" then
		objects["flipblock"][tilemap(x, y)] = flipblock:new(x, y, "cannonbox")
		objects["flipblock"][tilemap(x, y)]:hit()
		map[x][y][1] = 1
		objects["tile"][tilemap(x, y)] = nil
		map[x][y]["gels"] = {}
	elseif i == "levelball" then
		playsound(boomsound)
		makepoof(x-.5, y-1.5, "boom")
		local obj = levelball:new(x-0.5, y-17/16)
		obj.speedy = -10
		table.insert(objects["levelball"], obj)
	elseif anyiteminblock and _G[i] then
		local obj = _G[i]:new(x-0.5, y-1)
		obj.x = x-0.5-(obj.width/2)
		obj.y = y-1-obj.height
		obj.speedy = -mushroomjumpforce
		table.insert(objects[i], obj)
	else
		local r = map[x][y]
		local id = r[2]
		if id and entitylist[id] and entitylist[id].block then
			local obj, wasenemy, objtable = spawnenemy(i, x, y, false, "spawner")
			table.insert(spawnanimations, spawnanimation:new(x, y-1, "block", obj))
			table.insert(enemiesspawned, {x, y})
		end
		--(tilequads[r[1]]["collision"] and tilequads[r[1]]["breakable"] and not spawner)
	end
end

function addpoints(i, x, y)
	if not i then --or not x or not y
		return false
	end
	if i > 0 then
		marioscore = marioscore + i
		if x ~= nil and y ~= nil then
			table.insert(scrollingscores, scrollingscore:new(i, x, y))
		end
	elseif i == 0 then
		--no points!
	else
		table.insert(scrollingscores, scrollingscore:new(-i, x, y))
	end
end

function makepoof(x, y, t, color)
	local t = t or "poof"
	if t == "poof" then
		table.insert(poofs, poof:new(x, y, {1,2,3,4}, 0.4))
	elseif t == "longpoof" then --power suit
		table.insert(poofs, poof:new(x, y, {3,4,1,2,3,4}, 1))
	elseif t == "powpoof" then --cannons
		table.insert(poofs, poof:new(x, y, {1,-1,-2,2,3,-3,-4,4}, 0.5, 0, 0, true))
	elseif t == "smallpoof" then
		table.insert(poofs, poof:new(x, y, {2,3,4}, 0.3))
	elseif t == "makerpoof" then --mario maker poof
		table.insert(poofs, poof:new(x, y, {19,20,21,22}, 0.4))
	elseif t == "makerpoofbig" then --mario maker poof big
		table.insert(poofs, poof:new(x, y, {19,20,21,22}, 0.4, false, false, false, 2))
	elseif t == "makerpoofbigger" then --mario maker poof bigger
		table.insert(poofs, poof:new(x, y, {19,20,21,22}, 0.4, false, false, false, 4))
	elseif t == "pow" then --hit
		table.insert(poofs, poof:new(x, y, {5,6,5,6}, 0.15))
	elseif t == "boom" then --sparks
		local speed = 5
		local lifetime = 0.6
		table.insert(poofs, poof:new(x, y, {7,8,9,10,7,8,9,10}, lifetime, -speed, 0))
		table.insert(poofs, poof:new(x, y, {7,8,9,10,7,8,9,10}, lifetime, -speed*.71, -speed*.71))
		table.insert(poofs, poof:new(x, y, {7,8,9,10,7,8,9,10}, lifetime, 0, -speed))
		table.insert(poofs, poof:new(x, y, {7,8,9,10,7,8,9,10}, lifetime, speed*.71, -speed*.71))
		table.insert(poofs, poof:new(x, y, {7,8,9,10,7,8,9,10}, lifetime, speed, 0))
		table.insert(poofs, poof:new(x, y, {7,8,9,10,7,8,9,10}, lifetime, speed*.71, speed*.71))
		table.insert(poofs, poof:new(x, y, {7,8,9,10,7,8,9,10}, lifetime, 0, speed))
		table.insert(poofs, poof:new(x, y, {7,8,9,10,7,8,9,10}, lifetime, -speed*.71, speed*.71))
	elseif t == "splash" then --water splash
		table.insert(poofs, poof:new(x, y-.5, {11,12,13,14,15}, 0.4))
	elseif t == "sweat" then --koopaling sweat (eugh i don't like how that looks)
		table.insert(poofs, poof:new(x-1, y, {16,17,18,17,18,17,18}, 0.5))
		table.insert(poofs, poof:new(x+1, y, {-16,-17,-18,-17,-18,-17,-18}, 0.5))
	elseif t == "smoke" then --meteor smoke
		table.insert(poofs, poof:new(x, y, {23,24,25,26}, 0.2))
	elseif t == "turretshot" then --turret shot
		table.insert(poofs, poof:new(x, y, {27,28}, 0.1, nil, nil, nil, nil, color))
	end
end

function addzeros(s, i)
	for j = string.len(s)+1, i do
		s = "0" .. s
	end
	return s
end

function properprint2(s, x, y)
	for i = 1, string.len(tostring(s)) do
		if font2quads[string.sub(s, i, i)] then
			love.graphics.draw(smallfont, font2quads[string.sub(s, i, i)], x+((i-1)*4)*scale, y, 0, scale, scale)
		end
	end
end

function playsound(sound)
	if soundenabled then
		if sound.stop then --string?
			sound:stop()
			sound:play()
		elseif _G[sound .. "sound"] then
			_G[sound .. "sound"]:stop()
			_G[sound .. "sound"]:play()
		end
	end
end

function runkey(i)
	local s = controls[i]["run"]
	return checkkey(s,i,"run")
end

function rightkey(i)
	local s = controls[i]["right"]
	return checkkey(s,i,"right")
end

function leftkey(i)
	local s = controls[i]["left"]
	return checkkey(s,i,"left")
end

function downkey(i)
	local s = controls[i]["down"]
	return checkkey(s,i,"down")
end

function upkey(i)
	local s = controls[i]["up"]
	return checkkey(s,i,"up")
end

function jumpkey(i)
	local t = {}
	local s = controls[i]["jump"]
	return checkkey(s,i,"jump")
end

function usekey(i)
	local s = controls[i]["use"]
	return checkkey(s,i,"use")
end

function reloadkey(i)
	local t = {}
	local s = controls[i]["reload"]
	return checkkey(s,i,"reload")
end

function keydown(s, i)
	if s == "jump" and jumpkey(i) then
		return true
	elseif s == "left" and leftkey(i) then
		return true
	elseif s == "right" and rightkey(i) then
		return true
	elseif s == "up" and upkey(i) then
		return true
	elseif s == "down" and downkey(i) then
		return true
	elseif s == "run" and runkey(i) then
		return true
	elseif s == "use" and usekey(i) then
		return true
	elseif s == "reload" and reloadkey(i) then
		return true
	end
	return false
end

function checkkey(s,i,n)
	if s[1] == "joy" then
		if android and androidButtonDown(i,n) then
			return true
		end
		if s[3] == "hat" then
			if string.match(love.joystick.getHat(s[2], s[4]), s[5]) then
				return true
			else
				return false
			end
		elseif s[3] == "but" then
			if love.joystick.isDown(s[2], s[4]) then
				return true
			else
				return false
			end
		elseif s[3] == "axe" then
			if s[5] == "pos" then
				if love.joystick.getAxis(s[2], s[4]) > joystickdeadzone then
					return true
				else
					return false
				end
			else
				if love.joystick.getAxis(s[2], s[4]) < -joystickdeadzone then
					return true
				else
					return false
				end
			end
		end
	elseif s[1] then
		if s[1] == "" then
			return false
		end
		local success, keyIsDown = pcall(love.keyboard.isDown, s[1])
		if not success then
			print("Invalid key: '" .. s[1] .. "'")
			return false
		elseif keyIsDown then
			return true
		elseif android then
			return androidButtonDown(i,n)
		else 
			return false
		end
	end
end

function game_joystickpressed( joystick, button )
	--pause with controller
	for i = 1, players do
		local s = controls[i]["pause"]
		if s and s[1] == "joy" and joystick == s[2] and s[3] == "but" and button == s[4] then
			game_keypressed("escape")
			break
		end
	end

	if pausemenuopen then
		--select pause options
		for i = 1, players do
			local s1 = controls[i]["jump"]
			local s2 = controls[i]["pause"]
			if (s2 and s2[1] == "joy") or i == 1 then
				if s1[1] == "joy" and joystick == tonumber(s1[2]) and s1[3] == "but" and button == tonumber(s1[4]) then
					game_keypressed("return")
				end
			end
		end
		return
	end

	if endpressbutton then
		endgame()
		return
	end
	
	for i = 1, players do
		if (not noupdate) and objects then --and objects["player"][i].controlsenabled then -- and --and (not objects["player"][i].vine) and (not objects["player"][i].fence) then
			if editormode and (editormenuopen or rightclickmenuopen) then
				break
			end

			local s1 = controls[i]["jump"]
			local s2 = controls[i]["run"]
			local s3 = controls[i]["reload"]
			local s4 = controls[i]["use"]
			local s5 = controls[i]["left"]
			local s6 = controls[i]["right"]
			local s7 = controls[i]["portal1"]
			local s8 = controls[i]["portal2"]
			local s9 = controls[i]["up"]
			local s10 = controls[i]["down"]

			if s1[1] == "joy" and joystick == tonumber(s1[2]) and s1[3] == "but" and button == tonumber(s1[4]) then
				objects["player"][i]:button("jump")
				objects["player"][i]:wag()
				objects["player"][i]:jump()
				animationsystem_buttontrigger(i, "jump")
				return
			elseif s2[1] == "joy" and joystick == s2[2] and s2[3] == "but" and button == s2[4] then
				objects["player"][i]:button("run")
				objects["player"][i]:fire()
				animationsystem_buttontrigger(i, "run")
				return
			elseif s3[1] == "joy" and joystick == s3[2] and s3[3] == "but" and button == s3[4] then
				objects["player"][i]:button("reload")
				if objects["player"][i].portalgun then
					local pi = false
					--only reset portals that can be controlled by player
					if objects["player"][i].portals == "1 only" then
						pi = 1
					elseif objects["player"][i].portals == "2 only" then
						pi = 2
					end
					objects["player"][i]:removeportals(pi)
				end
				animationsystem_buttontrigger(i, "reload")
				return
			elseif s4[1] == "joy" and joystick == s4[2] and s4[3] == "but" and button == s4[4] then
				objects["player"][i]:button("use")
				objects["player"][i]:use()
				animationsystem_buttontrigger(i, "use")
				return
			elseif s5[1] == "joy" and joystick == s5[2] and s5[3] == "but" and button == s5[4] then
				objects["player"][i]:button("left")
				objects["player"][i]:leftkey()
				animationsystem_buttontrigger(i, "left")
				return
			elseif s6[1] == "joy" and joystick == s9[2] and s9[3] == "but" and button == s9[4] then
				objects["player"][i]:button("up")
				objects["player"][i]:upkey()
				animationsystem_buttontrigger(i, "up")
				return
			elseif s6[1] == "joy" and joystick == s10[2] and s10[3] == "but" and button == s10[4] then
				objects["player"][i]:button("down")
				objects["player"][i]:downkey()
				animationsystem_buttontrigger(i, "down")
				return
			end
			
			local s = controls[i]["portal1"]
			if s and s[1] == "joy" then
				if s[3] == "but" then
					if joystick == s[2] and button == s[4] and objects["player"][i] and i ~= mouseowner then
						objects["player"][i]:shootportal(1)
						return
					end
				end
			end
			
			local s = controls[i]["portal2"]
			if s and s[1] == "joy" then
				if s[3] == "but" then
					if joystick == tonumber(s[2]) and button == tonumber(s[4]) and objects["player"][i] and i ~= mouseowner then
						objects["player"][i]:shootportal(2)
						return
					end
				end
			end
		end
	end
end

function game_joystickreleased( joystick, button )
	for i = 1, players do
		if (not noupdate) and objects then --objects["player"][i].controlsenabled then --and (not objects["player"][i].vine) and (not objects["player"][i].fence) then
			if editormode and (editormenuopen or rightclickmenuopen) then
				break
			end
			
			local s1 = controls[i]["jump"]
			local s2 = controls[i]["run"]
			local s3 = controls[i]["reload"]
			local s4 = controls[i]["use"]
			local s5 = controls[i]["left"]
			local s6 = controls[i]["right"]
			local s7 = controls[i]["portal1"]
			local s8 = controls[i]["portal2"]
			local s9 = controls[i]["up"]
			local s10 = controls[i]["down"]
			if s1[1] == "joy" and joystick == tonumber(s1[2]) and s1[3] == "but" and button == tonumber(s1[4]) then
				objects["player"][i]:buttonrelease("jump")
				objects["player"][i]:stopjump()
				animationsystem_buttonreleasetrigger(i, "jump") return
			elseif s2[1] == "joy" and joystick == s2[2] and s2[3] == "but" and button == s2[4] then
				objects["player"][i]:buttonrelease("run")
				animationsystem_buttonreleasetrigger(i, "run") return
			elseif s3[1] == "joy" and joystick == s3[2] and s3[3] == "but" and button == s3[4] then
				objects["player"][i]:buttonrelease("reload")
				animationsystem_buttonreleasetrigger(i, "reload") return
			elseif s4[1] == "joy" and joystick == s4[2] and s4[3] == "but" and button == s4[4] then
				objects["player"][i]:buttonrelease("use")
				animationsystem_buttonreleasetrigger(i, "use") return
			elseif s5[1] == "joy" and joystick == s5[2] and s5[3] == "but" and button == s5[4] then
				objects["player"][i]:buttonrelease("left")
				animationsystem_buttonreleasetrigger(i, "left") return
			elseif s6[1] == "joy" and joystick == s6[2] and s6[3] == "but" and button == s6[4] then
				objects["player"][i]:buttonrelease("right")
				animationsystem_buttonreleasetrigger(i, "right") return
			elseif s9[1] == "joy" and joystick == s9[2] and s9[3] == "but" and button == s9[4] then
				objects["player"][i]:buttonrelease("up")
				animationsystem_buttonreleasetrigger(i, "up") return
			elseif s10[1] == "joy" and joystick == s10[2] and s10[3] == "but" and button == s10[4] then
				objects["player"][i]:buttonrelease("down")
				animationsystem_buttonreleasetrigger(i, "down") return
			end
		end
	end
end

function inrange(i, a, b, include)
	if a > b then
		b, a = a, b
	end
	
	if include then
		return i >= a and i <= b
	else
		return i > a and i < b
	end
end

function adduserect(x, y, width, height, callback)
	local t = {}
	t.x = x
	t.y = y
	t.width = width
	t.height = height
	t.callback = callback
	t.delete = false
	
	table.insert(userects, t)
	return t
end

function userect(x, y, width, height)
	local outtable = {}
	
	for i, v in pairs(userects) do
		if aabb(x, y, width, height, v.x, v.y, v.width, v.height) then
			table.insert(outtable, v.callback)
		end
	end
	
	return outtable
end

function drawrectangle(x, y, width, height)
	love.graphics.rectangle("fill", x*scale, y*scale, width*scale, scale)
	love.graphics.rectangle("fill", x*scale, y*scale, scale, height*scale)
	love.graphics.rectangle("fill", x*scale, (y+height-1)*scale, width*scale, scale)
	love.graphics.rectangle("fill", (x+width-1)*scale, y*scale, scale, height*scale)
end

function inmap(x, y)
	if not x or not y then
		return false
	end
	if x >= 1 and x <= mapwidth and y >= 1 and y <= mapheight then
		return true
	else
		return false
	end
end

function istile(x, y)
	return inmap(x,y) and math.floor(x) == x and math.floor(y) == y
end

function ismaptile(x, y)
	return (istile(x, y) and map[x] and map[x][y])
end

function playmusic()
	if (editormode and (not PlayMusicInEditor)) or NoMusic then
		return
	end
	if musici >= 7 then
		if custommusic then
			music:play(custommusic, not nolowtime and (mariotime < 100 and mariotime > 0))
		end
	elseif musici ~= 1 then
		music:playIndex(musici-1, not nolowtime and (mariotime < 100 and mariotime > 0))
	end
end

function stopmusic()
	if musici >= 7 then
		music:stop(custommusic, (mariotime < 100 and mariotime > 0))
	elseif musici ~= 1 then
		music:stopIndex(musici-1, (mariotime < 100 and mariotime > 0))
	end
	pbuttonsound:stop()
	music:stop("starmusic")
	music:disableintromusic()
end
	
function updatesizes(reset)
	mariosizes = {}
	if (not objects) or reset then
		for i = 1, players do
			mariosizes[i] = 1
		end
	else
		for i = 1, players do
			if objects["player"][i].ignoresize then
				mariosizes[i] = 1
				objects["player"][i].ignoresize = false
			else
				mariosizes[i] = objects["player"][i].size
			end
		end
	end
end

function updateplayerproperties(reset)
	marioproperties = {}
	if (not objects) or reset then
		for i = 1, players do
			marioproperties[i] = {}
		end
	else
		for i = 1, players do
			marioproperties[i] = {}
			if objects and objects["player"] and objects["player"][i] then
				if objects["player"][i].shoe then
					if objects["player"][i].shoe == "yoshi" then
						if objects["player"][i].yoshi.color then
							marioproperties[i].shoe = {"yoshi", objects["player"][i].yoshi.color}
						else
							marioproperties[i].shoe = {"yoshi", 1}
						end
					else
						marioproperties[i].shoe = objects["player"][i].shoe
					end
				end
				if objects["player"][i].helmet then
					marioproperties[i].helmet = objects["player"][i].helmet
				end
				if objects["player"][i].key then
					marioproperties[i].key = objects["player"][i].key
				end
				if objects["player"][i].mariolevel then
					marioproperties[i].mariolevel = objects["player"][i].mariolevel
				end
				if objects["player"][i].fireenemy then
					marioproperties[i].fireenemy = objects["player"][i].fireenemy
					marioproperties[i].customcolors = objects["player"][i].basecolors
				end
				if objects["player"][i].health then
					marioproperties[i].health = objects["player"][i].health
				end
			end
		end
	end
end

function hitrightside()
	if haswarpzone then
		objects["plant"] = {}
		displaywarpzonetext = true
	end
end

function getclosestplayer(x)
	closestplayer = 1
	for i = 2, players do
		if math.abs(objects["player"][closestplayer].x+6/16-x) < math.abs(objects["player"][i].x+6/16-x) then
			closestplayer = i
		end
	end
	
	return closestplayer
end

function endgame()
	if testlevel then
		stoptestinglevel()
		return
	end
	love.audio.stop()
	if pressbtosteve then
		playertype = "minecraft"
		playertypei = 2
	else
		hardmode = true
	end
	gamefinished = true
	saveconfig()
	menu_load()
	if dcplaying then
		dcplaying = false
		gamestate = "mappackmenu"
		mappacktype = "daily_challenge"
		mappackhorscroll = 2
		mappackhorscrollsmooth = 2
	end

	if CLIENT or SERVER then
		net_quit()
	end
end

--Minecraft stuff

function placeblock(x, y, side)
	if side == "up" then
		y = y - 1
	elseif side == "down" then
		y = y + 1
	elseif side == "left" then
		x = x - 1
	elseif side == "right" then
		x = x + 1
	end
	
	if not inmap(x, y) then
		return false
	end
	
	--get block
	local tileno
	if inventory[mccurrentblock].t ~= nil then
		tileno = inventory[mccurrentblock].t
	else
		return false
	end
	
	if #checkrect(x-1, y-1, 1, 1, "all") == 0 then
		if map[x][y] == emptytile then map[x][y] = deepcopy(emptytile) end
		map[x][y][1] = tileno
		objects["tile"][tilemap(x, y)] = tile:new(x-1, y-1, 1, 1, true)
		generatespritebatch()
	
		inventory[mccurrentblock].count = inventory[mccurrentblock].count - 1
		
		if inventory[mccurrentblock].count == 0 then
			inventory[mccurrentblock].t = nil
		end
		
		return true
	else
		return false
	end
end

function collectblock(i)
	local success = false
	for j = 1, 9 do
		if inventory[j].t == i and inventory[j].count < 64 then
			inventory[j].count = inventory[j].count+1
			success = true
			break
		end
	end
	
	if not success then
		for j = 1, 9 do
			if inventory[j].t == nil then
				inventory[j].count = 1
				inventory[j].t = i
				success = true
				break
			end
		end
	end
	
	return success
end

function breakblock(x, y)
	--create a cute block
	if objects["tile"][tilemap(x, y)] then
		table.insert(miniblocks, miniblock:new(x-.5, y-.2, map[x][y][1]))
	end
	
	map[x][y][1] = 1
	map[x][y][2] = nil
	map[x][y]["gels"] = {}
	map[x][y]["portaloverride"] = nil
	objects["tile"][tilemap(x, y)] = nil
	objects["flipblock"][tilemap(x, y)] = nil
	objects["buttonblock"][tilemap(x, y)] = nil
	
	generatespritebatch()
end

function respawnplayers()
	if mariolivecount == false then
		return
	end
	for i = 1, players do
		if mariolives[i] == 1 and objects["player"].dead then
			objects["player"][i]:respawn()
		end
	end
end

function cameraxpan(target, t)
	xpan = true
	xpanstart = xscroll
	xpandiff = target-xpanstart
	xpantime = t
	xpantimer = 0
end

function cameraypan(target, t)
	ypan = true
	ypanstart = yscroll
	ypandiff = target-ypanstart
	ypantime = t
	ypantimer = 0
end

function camerasnap(targetx, targety, anim)
	if (not autoscroll) and (not anim) then
		return
	end
	local x, y = xscroll, yscroll

	if targetx and targety then
		--just snap to target
		x, y = targetx, targety
	else 
		--find target
		local fastestplayer = 1
		while fastestplayer <= players and objects["player"][fastestplayer].dead do
			fastestplayer = fastestplayer + 1
		end
		if not objects["player"][fastestplayer] then
			return
		end
		if not CLIENT and not SERVER then
			if mapwidth <= width then
				for i = 1, players do
					if not objects["player"][i].dead and math.abs(starty-objects["player"][i].y) > math.abs(starty-objects["player"][fastestplayer].y) then
						fastestplayer = i
					end
				end
			else
				for i = 1, players do
					if not objects["player"][i].dead and objects["player"][i].x > objects["player"][fastestplayer].x then
						fastestplayer = i
					end
				end
			end
		end
		local fastestplayer = objects["player"][fastestplayer]
		if fastestplayer.x > xscroll+scrollingstart then
			x = fastestplayer.x-scrollingstart-1
		elseif fastestplayer.x < xscroll+scrollingleftstart then
			x = fastestplayer.x-scrollingleftstart
		end
		if fastestplayer.y > yscroll+9 then
			y = fastestplayer.y-9
		elseif fastestplayer.y < yscroll+4 then
			y = fastestplayer.y-4
		end
	end

	if autoscrollx or anim then
		xscroll = math.max(0, math.min(x, mapwidth-width))
		splitxscroll[1] = xscroll
	end
	if autoscrolly or anim then
		yscroll = math.max(0, math.min(y, mapheight-height-1))
		splityscroll[1] = yscroll
	end

	if not (editormode and not testlevel) then
		for x = math.max(1, math.floor(xscroll)), math.min(mapwidth, math.ceil(xscroll+width*screenzoom2)) do
			for y = math.max(1, math.floor(yscroll)), math.min(mapheight, math.ceil(yscroll+height*screenzoom2+1)) do
				spawnenemyentity(x,y)
			end
		end
	end
end

function updateranges()
	for i, v in pairs(objects["laser"]) do
		v:updaterange()
	end
	for i, v in pairs(objects["lightbridge"]) do
		v:updaterange()
	end
	for i, v in pairs(objects["funnel"]) do
		v:updaterange()
	end
end

function createdialogbox(text, speaker, color)
	dialogboxes = {}
	table.insert(dialogboxes, dialogbox:new(text, speaker, color))
end

function checkportalremove(x, y)
	for i, v in pairs(portals) do
		--Get the extra block of each portal
		local portal1xplus, portal1yplus, portal2xplus, portal2yplus = 0, 0, 0, 0
		if v.facing1 == "up" then
			portal1xplus = 1
		elseif v.facing1 == "right" then
			portal1yplus = 1
		elseif v.facing1 == "down" then
			portal1xplus = -1
		elseif v.facing1 == "left" then
			portal1yplus = -1
		end
		
		if v.facing2 == "up" then
			portal2xplus = 1
		elseif v.facing2 == "right" then
			portal2yplus = 1
		elseif v.facing2 == "down" then
			portal2xplus = -1
		elseif v.facing2 == "left" then
			portal2yplus = -1
		end
		
		if v.x1 ~= false then
			if (x == v.x1 or x == v.x1+portal1xplus) and (sy == v.y1 or y == v.y1+portal1yplus) then--and (facing == nil or v.facing1 == facing) then
				v:removeportal(1)
			end
		end
	
		if v.x2 ~= false then
			if (x == v.x2 or x == v.x2+portal2xplus) and (y == v.y2 or y == v.y2+portal2yplus) then--and (facing == nil or v.facing2 == facing) then
				v:removeportal(2)
			end
		end
	end
end

function setphysics(i)
	local i = i or 1
	mariomakerphysics = false
	smb2jphysics = false
	portalphysics = false
	if i == 1 then--mari0
		maxyspeed = mari0maxyspeed
		bounceheight = smbbounceheight
		koopajumpforce = smbkoopajumpforce
		koopaflyinggravity = smbkoopaflyinggravity
		springgreenhighforce = mari0springgreenhighforce
	elseif i == 2 then--smb
		maxyspeed = smbmaxyspeed
		bounceheight = smbbounceheight
		koopajumpforce = smbkoopajumpforce
		koopaflyinggravity = smbkoopaflyinggravity
		springgreenhighforce = smbspringgreenhighforce
	elseif i == 3 then--smb2j-mari0
		maxyspeed = mari0maxyspeed
		bounceheight = smb2jbounceheight --4 1/2 blocks high
		koopajumpforce = smb2jkoopajumpforce --2 1/2 blocks high
		koopaflyinggravity = smb2jkoopaflyinggravity
		springgreenhighforce = mari0springgreenhighforce
		smb2jphysics = true
	elseif i == 4 then--smb2j
		maxyspeed = smbmaxyspeed
		bounceheight = smb2jbounceheight
		koopajumpforce = smb2jkoopajumpforce
		koopaflyinggravity = smb2jkoopaflyinggravity
		springgreenhighforce = smbspringgreenhighforce
		smb2jphysics = true
	elseif i == 5 then --mari0 maker
		maxyspeed = mari0maxyspeed
		bounceheight = smbbounceheight
		koopajumpforce = smbkoopajumpforce
		koopaflyinggravity = smbkoopaflyinggravity
		springgreenhighforce = mari0springgreenhighforce
		mariomakerphysics = true
	elseif i == 6 then --mario maker
		maxyspeed = smbmaxyspeed
		bounceheight = smbbounceheight
		koopajumpforce = smbkoopajumpforce
		koopaflyinggravity = smbkoopaflyinggravity
		springgreenhighforce = smbspringgreenhighforce
		mariomakerphysics = true
	elseif i == 7 then --portal
		maxyspeed = mari0maxyspeed
		bounceheight = smbbounceheight
		koopajumpforce = smbkoopajumpforce
		koopaflyinggravity = smbkoopaflyinggravity
		springgreenhighforce = mari0springgreenhighforce
		mariomakerphysics = true
		portalphysics = true
	end
end

function setcamerasetting(i)
	if i == 2 then --centered
		scrollingstart = (width/2)+.5
		scrollingcomplete = (width/2)-1.5
		scrollingleftstart = (width/2)+1
		scrollingleftcomplete = (width/2)-2
	elseif i == 3 then

	end
end

function createedgewrap() --create blocks on borders for edge wrapping
	if edgewrapping then
		objects["edgewrap"] = {}
		for y = 1, mapheight do
			if tilequads[map[1][y][1]].collision or tilequads[map[mapwidth][y][1]].collision then
				table.insert(objects["edgewrap"], tile:new(mapwidth, y-1))
				table.insert(objects["edgewrap"], tile:new(-1, y-1))
			end
		end
	end
end

function onscreen(x, y, w, h)
	if w and h then
		return (x+w >= xscroll and y+h-.5 >= yscroll and x <= xscroll+width*screenzoom2 and y-.5 <= yscroll+height*(1/screenzoom))
	else
		return (x >= xscroll and y-.5 >= yscroll and x <= xscroll+width*screenzoom2 and y-.5 <= yscroll+height*(1/screenzoom))
	end
end

function ondrawscreen(x, y, w, h)
	if w and h then
		return (x+w >= 0 and y+h-.5 >= 0 and x < width*16*scale and y < height*16*scale)
	else
		return (x >= 0 and y-.5 >= 0 and x < xscroll*16*scale and y < height*16*scale)
	end
end

function checkcollectable(x, y, t)
	local w, l, s = tostring(marioworld), tostring(mariolevel), tostring(actualsublevel)
	if collectables[w .. "-" .. l .. "-" .. s] 
	and collectables[w .. "-" .. l .. "-" .. s][x .. "-" .. y]
	and collectables[w .. "-" .. l .. "-" .. s][x .. "-" .. y] == t then
		return true
	end
	return false
end

function getcollectable(x, y)
	local c = objects["collectable"][tilemap(x, y)]
	if not c then
		print("collectable not found", x, y)
		return false
	end
	local t = tonumber(c.t)
	local w, l, s = tostring(marioworld), tostring(mariolevel), tostring(actualsublevel)

	local level, coords = w .. "-" .. l .. "-" .. s, x .. "-" .. y
	if not collectables[level]  then
		collectables[level] = {}
	end
	collectables[level][coords] = t --add to map memory

	table.insert(collectableslist[t], {level,coords}) --mark location
	collectablescount[t] = collectablescount[t]+1 --update count

	addpoints(200)
	playsound(_G["collectable" .. t .. "sound"])
	objects["collectable"][tilemap(x, y)]:get()
	objects["collectable"][tilemap(x, y)] = nil
	return t
end

function convertr(r, types, dontgivedefaultvalues) --convert right cick values
	if not r then
		return {}
	end
	if type(r) == "number" then
		r = tostring(r)
	end
	local t = r:split("|")
	for i = 1, #types do
		local id = types[i]
		if not t[i] then
			if dontgivedefaultvalues then
				t[i] = nil
			else
				if id == "num" then
					t[i] = 0
				elseif id == "bool" then
					t[i] = false
				elseif id == "string" then
					t[i] = ""
				else
					t[i] = id
				end
			end
		else
			if id == "num" then
				local s = t[i]:gsub("n", "-")
				t[i] = tonumber(s) or 0
			elseif id == "bool" then
				t[i] = (t[i] == "true")
			end
		end
	end
	return t
end

function lightsoutstencil()
	for i2, v2 in pairs(objects) do
		if i2 ~= "tile" and i2 ~="buttonblock" and i2 ~= "clearpipesegment" then
			for i, v in pairs(objects[i2]) do
				if (v.active or (i2 == "player" or i2 == "enemy")) and v.light and onscreen(v.x+v.width/2-v.light, v.y+v.height/2-v.light, v.light*2, v.light*2) then
					local r = v.light
					if i2 ~= "player" then
						r = r+math.sin(lightsoutwave*(math.pi*2/0.2))*0.05
					end
					love.graphics.circle("fill", math.floor((v.x+(v.width/2)-xscroll)*16)*scale, math.floor((v.y+(v.height/2)-yscroll)*16-8)*scale, math.floor(r*16)*scale)
				end
			end
		end
	end
	if flagx and flagy and onscreen(flagx+.5-2, flagy-9-2, 4, 12) then
		local r = 2
		love.graphics.rectangle("fill", math.floor((flagx+.5-r-xscroll)*16)*scale, math.floor((flagy-11+r-yscroll)*16-8)*scale, math.floor((r*2)*16)*scale, math.floor((12-r*2)*16)*scale)
		love.graphics.circle("fill", math.floor((flagx+.5-xscroll)*16)*scale, math.floor((flagy-9-yscroll)*16-8)*scale, math.floor(r*16)*scale)
		love.graphics.circle("fill", math.floor((flagx+.5-xscroll)*16)*scale, math.floor((flagy-1-yscroll)*16-8)*scale, math.floor(r*16)*scale)
	end
end

function updatecustombackgrounds(dt)
	--animated backgrounds and foregrounds
	if custombackground then
		for i, b in pairs(custombackgroundanim) do
			if b.speedx then
				b.x = b.x + b.speedx*dt
			end
			if b.speedy then
				b.y = b.y + b.speedy*dt
			end
			if b.quad then
				b.timer = b.timer - dt
				while b.timer < 0 do
					b.frame = b.frame + 1
					if b.frame > #b.frames then
						b.frame = 1
					end
					b.quadi = b.frames[b.frame]
					b.timer = b.timer + b.delay[math.min(b.frame, #b.delay)]
				end
			end
		end
	end
	if customforeground then
		for i, b in pairs(customforegroundanim) do
			if b.speedx then
				b.x = b.x + b.speedx*dt
			end
			if b.speedy then
				b.y = b.y + b.speedy*dt
			end
			if b.quad then
				b.timer = b.timer - dt
				while b.timer < 0 do
					b.frame = b.frame + 1
					if b.frame > #b.frames then
						b.frame = 1
					end
					b.quadi = b.frames[b.frame]
					b.timer = b.timer + b.delay[math.min(b.frame, #b.delay)]
				end
			end
		end
	end
end

function rendercustombackground(xscroll, yscroll, scrollfactor, scrollfactory)
	local xscroll, yscroll = xscroll or 0, yscroll or 0
	local oxscroll, oyscroll = xscroll or 0, yscroll or 0
	local scrollfactor, scrollfactory = scrollfactor or 0, scrollfactory or 0
	if custombackground then
		for i = #custombackgroundimg, 1, -1  do
			local xscroll = xscroll / (i * scrollfactor + 1)
			local yscroll = yscroll / (i * scrollfactory + 1)
			if reversescrollfactor(scrollfactor) == 1 then
				xscroll = 0
			end
			if reversescrollfactor(scrollfactory) == 1 then
				yscroll = 0
			end

			local quad = false
			if custombackgroundanim[i] then
				--animate
				xscroll = xscroll - custombackgroundanim[i].x
				yscroll = yscroll - custombackgroundanim[i].y
				if custombackgroundanim[i].quad then
					quad = custombackgroundanim[i].quad[custombackgroundanim[i].quadi]
				end
				if custombackgroundanim[i].staticx or custombackgroundanim[i].static then
					xscroll = 0
				elseif custombackgroundanim[i].clamptolevelwidth then
					xscroll = (oxscroll/math.max(1,mapwidth-width)) * (custombackgroundwidth[i]-width)
				end
				if custombackgroundanim[i].staticy or custombackgroundanim[i].static then
					yscroll = 0
				elseif custombackgroundanim[i].clamptolevelheight then
					yscroll = (oyscroll/math.max(1,mapheight-1-height)) * (custombackgroundheight[i]-height)
				end
			end

			local min = 1
			if xscroll < 0 or yscroll < 0 then
				min = 0
			end
			if custombackgroundquad[i] and not SlowBackgrounds then --optimized static background
				local x1, y1 = math.floor(xscroll*16*scale)/scale, math.floor(yscroll*16*scale)/scale
				local qx, qy, qw, qh, sw, sh = custombackgroundquad[i]:getViewport()
				custombackgroundquad[i]:setViewport( x1, y1, width*16*screenzoom2, height*16*screenzoom2, sw, sh )
				love.graphics.draw(custombackgroundimg[i], custombackgroundquad[i], 0, 0, 0, scale, scale)
			else
				for y = min, math.ceil(height/custombackgroundheight[i])+1 do
					for x = min, math.ceil(width/custombackgroundwidth[i])+1 do
						local x1, y1 = math.floor(((x-1)*custombackgroundwidth[i])*16*scale) - math.floor(math.fmod(xscroll, custombackgroundwidth[i])*16*scale), math.floor(((y-1)*custombackgroundheight[i])*16*scale) - math.floor(math.fmod(yscroll, custombackgroundheight[i])*16*scale)
						if ondrawscreen(x1, y1, custombackgroundwidth[i]*16*scale, custombackgroundheight[i]*16*scale) then
							if quad then
								love.graphics.draw(custombackgroundimg[i], quad, x1, y1, 0, scale, scale)
							else
								love.graphics.draw(custombackgroundimg[i], x1, y1, 0, scale, scale)
							end
						end
					end
				end
			end
		end
	end
end

function rendercustomforeground(xscroll, yscroll, scrollfactor, scrollfactory)
	local xscroll, yscroll = xscroll or 0, yscroll or 0
	local oxscroll, oyscroll = xscroll or 0, yscroll or 0
	local scrollfactor2, scrollfactor2y = scrollfactor or 0, scrollfactory or 0
	if customforeground then
		for i = #customforegroundimg, 1, -1  do
			local xscroll = xscroll * (i*scrollfactor2 + 1)
			local yscroll = yscroll * (i*scrollfactor2y + 1)
			if reversescrollfactor2(scrollfactor2) == 1 then
				xscroll = 0
			end
			if reversescrollfactor2(scrollfactor2y) == 1 then
				yscroll = 0
			end

			local quad = false
			if customforegroundanim[i] then
				--animate
				xscroll = xscroll - customforegroundanim[i].x
				yscroll = yscroll - customforegroundanim[i].y
				if customforegroundanim[i].quad then
					quad = customforegroundanim[i].quad[customforegroundanim[i].quadi]
				end
				if customforegroundanim[i].staticx or customforegroundanim[i].static then
					xscroll = 0
				elseif customforegroundanim[i].clamptolevelwidth then
					xscroll = (oxscroll/math.max(1,mapwidth-width)) * (customforegroundwidth[i]-width)
				end
				if customforegroundanim[i].staticy or customforegroundanim[i].static then
					yscroll = 0
				elseif customforegroundanim[i].clamptolevelheight then
					yscroll = (oyscroll/math.max(1,mapheight-1-height)) * (customforegroundheight[i]-height)
				end
			end

			local min = 1
			if xscroll < 0 or yscroll < 0 then
				min = 0
			end
			for y = min, math.ceil(height/customforegroundheight[i])+1 do
				for x = min, math.ceil(width/customforegroundwidth[i])+1 do
					local x1, y1 = math.floor(((x-1)*customforegroundwidth[i])*16*scale) - math.floor(math.fmod(xscroll, customforegroundwidth[i])*16*scale), math.floor(((y-1)*customforegroundheight[i])*16*scale) - math.floor(math.fmod(yscroll, customforegroundheight[i])*16*scale)
					--if ondrawscreen(x1, y1, customforegroundwidth[i]*16*scale, customforegroundheight[i]*16*scale) then
						if quad then
							love.graphics.draw(customforegroundimg[i], quad, x1, y1, 0, scale, scale)
						else
							love.graphics.draw(customforegroundimg[i], x1, y1, 0, scale, scale)
						end
					--end
				end
			end
		end
	end
end

function trackobject(x, y, obj, objtable) --grab entity onto track
	local r = map[x][y]
	if obj and r["track"] and ((not (r["track"].grab == "t" or r["track"].grab == "tr" or r["track"].grab == "tf" or r["track"].grab == "trf" or r["track"].grab == "")) or (objtable and objtable == "tilemoving")) then
		local dir, fast = "forward", false
		if r["track"].grab:find("r") then
			dir = "backwards"
		end
		if r["track"].grab:find("f") then
			obj.trackedfast = true
			fast = true
		end
		table.insert(objects["trackcontroller"], trackcontroller:new(x,y,objtable,obj,dir,force))
		return true
	end
	return false
end

function createblockbounce(x, y)
	local i = tilemap(x, y)
	blockbounce[i] = {}
	return blockbounce[i]
end

function getblockbounce(x, y)
	--string concat is slow as hell so im doing this instead
	return blockbounce[tilemap(x, y)]
end

function tilemap(x, y)
	--tile ids used to use string concat (x .. "-" .. y) which was really slow
	--now it uses a single number, no strings attached
	--  1  2  4
	--  3  5  8
	--  6  9 13
	--Central polygonal numbers (the Lazy Caterer's sequence)
	if editormode or mazesfuck then
		--return ((x*(x -3+(2*y) ))/2) + ((y*(y-1))/2) + 1
		return (x*(x+2*y-3) + y*(y-1))*.5 --simplified
	else
		if x > originalmapwidth then --mazes
			x = x-originalmapwidth
			return originalmapwidth+mapheight+1+(x*(x+2*y-3) + y*(y-1))*.5
		else
			return (y-1)*originalmapwidth + x
		end
	end
end

function drawmaptiles(drawtype, xscroll, yscroll)
	local fore = (drawtype == "foreground")
	local drop = (drawtype == "dropshadow") or (drawtype == "menudropshadow")
	local menudraw = (drawtype == "menu") or (drawtype == "menudropshadow")
	local collision = (drawtype == "collision")
	local lmap = map

	local xfromdraw,xtodraw, yfromdraw,ytodraw, xoff,yoff = getdrawrange(xscroll,yscroll)
		
	for y = yfromdraw, ytodraw do
		for x = xfromdraw, xtodraw do
			--actual tile
			if (not lmap[x]) then
				if fore then
					print("foreground tile doesnt exist " .. x)
				else
					print("drawable tile doesnt exist " .. x)
				end
				break
			end
			local t = lmap[x][y]
			if not t then
				break
			end

			if (not fore) then--fore or drop then
				--clear pipes
				local coord = tilemap(x, y)
				if objects and objects["clearpipesegment"][coord] then
					if drop then
						objects["clearpipesegment"][coord]:draw(drop)
					else
						table.insert(clearpipesegmentdrawqueue, coord)
					end
				end
				--switch blocks
				if objects and objects["buttonblock"][coord] and ((not drop) or objects["buttonblock"][coord].active) then
					objects["buttonblock"][coord]:draw()
				end
				--frozen coins
				if objects and objects["frozencoin"][coord] and ((not drop) or objects["frozencoin"][coord].active) then
					objects["frozencoin"][coord]:draw()
				end
			end
			
			local tilenumber = t[1]
			if menudraw then
				tilenumber = tonumber(tilenumber) or 1
			end
			local cox, coy = x, y

			local bounceyoffset = 0
			if blockbounce then
				local blockbouncet = getblockbounce(x, y)
				if blockbouncet then
					local v = blockbouncet
					local timer = math.abs(v.timer)
					if timer < blockbouncetime/2 then
						bounceyoffset = timer / (blockbouncetime/2) * blockbounceheight
					else
						bounceyoffset = (2 - timer / (blockbouncetime/2)) * blockbounceheight
					end
					if v.timer < 0 then
						bounceyoffset = -bounceyoffset
					end
				end
			end

			if fore or drop or menudraw then
				if tilequads[tilenumber]:getproperty("foreground", cox, coy) then
					if tilenumber > 90000 then
						love.graphics.draw(tilequads[tilenumber].image, tilequads[tilenumber]:getquad(cox, coy), math.floor((x-1-xoff)*16*scale), math.floor(((y-1-yoff-bounceyoffset)*16-8)*scale), 0, scale, scale)
					else
						love.graphics.draw(tilequads[tilenumber].image, tilequads[tilenumber].quad, math.floor((x-1-xoff)*16*scale), math.floor(((y-1-yoff-bounceyoffset)*16-8)*scale), 0, scale, scale)
					end
				end
			end
			if (not fore) or drop or menudraw then
				if not tilequads[tilenumber]:getproperty("foreground", cox, coy) then
					if tilequads[tilenumber].coinblock and tilenumber < 90000 and not tilequads[tilenumber].invisible then --coinblock
						love.graphics.draw(coinblockimage, coinblockquads[spriteset][coinframe], math.floor((x-1-xoff)*16*scale), math.floor(((y-1-yoff-bounceyoffset)*16-8)*scale), 0, scale, scale)
					elseif (tilequads[tilenumber].coin and tilenumber < 90000) or (menudraw and t[2] == "187") then --coin
						love.graphics.draw(coinimage, coinquads[spriteset][coinframe], math.floor((x-1-xoff)*16*scale), math.floor(((y-1-yoff-bounceyoffset)*16-8)*scale), 0, scale, scale)
					elseif tilenumber > 90000 then --same as below, but keeps animated tiles on grid
						if not tilequads[tilenumber].invisible then
							love.graphics.draw(tilequads[tilenumber].image, tilequads[tilenumber]:getquad(cox, coy), math.floor((x-1-xoff)*16*scale), math.floor(((y-1-yoff-bounceyoffset)*16-8)*scale), 0, scale, scale)
						end
					elseif bounceyoffset ~= 0 or menudraw or (_3DMODE and (((not collision) and (not tilequads[tilenumber].collision))) or ((collision and tilequads[tilenumber].collision and bounceyoffset ~= 0))) then
						if not tilequads[tilenumber].invisible then
							love.graphics.draw(tilequads[tilenumber].image, tilequads[tilenumber].quad, math.floor((x-1-xoff)*16*scale), ((y-1-yoff-bounceyoffset)*16-8)*scale, 0, scale, scale)
						end
					end
				end
				if objects and objects["coin"][tilemap(cox,coy)] then
					objects["coin"][tilemap(cox,coy)]:draw()
				end
			end
			
			--Gel overlays!
			if t["gels"] and (not tilequads[tilenumber].foreground) and (not drop) and (not fore) then
				for i = 1, 4 do
					local dir = "top"
					local r = 0
					if i == 2 then
						dir = "right"
						r = math.pi/2
					elseif i == 3 then
						dir = "bottom"
						r = math.pi
					elseif i == 4 then
						dir = "left"
						r = math.pi*1.5
					end
					
					if t["gels"][dir] == 1 then
						love.graphics.draw(gel1ground, math.floor((x-.5-xoff)*16*scale), math.floor(((y-1-yoff-bounceyoffset)*16)*scale), r, scale, scale, 8, 8)
					elseif t["gels"][dir] == 2 then
						love.graphics.draw(gel2ground, math.floor((x-.5-xoff)*16*scale), math.floor(((y-1-yoff-bounceyoffset)*16)*scale), r, scale, scale, 8, 8)
					elseif t["gels"][dir] == 3 then
						love.graphics.draw(gel3ground, math.floor((x-.5-xoff)*16*scale), math.floor(((y-1-yoff-bounceyoffset)*16)*scale), r, scale, scale, 8, 8)
					elseif t["gels"][dir] == 4 then
						love.graphics.draw(gel4ground, math.floor((x-.5-xoff)*16*scale), math.floor(((y-1-yoff-bounceyoffset)*16)*scale), r, scale, scale, 8, 8)
					end
				end
			end

			--tracks!
			if t["track"] and (not t["track"].invisible) and (not drop) and (not fore) then
				if editormode then
					if not (customrcopen and customrcopen == "trackpath" and t["track"].cox == rightclickmenucox and t["track"].coy == rightclickmenucoy) then
						love.graphics.setColor(1, 1, 1, 100/255)
						drawtrack(cox, coy, t["track"].start, t["track"].ending)
						love.graphics.setColor(1, 1, 1, 1)
					end
				else
					drawtrack(cox, coy, t["track"].start, t["track"].ending)
				end
			end
			
			if editormode and (((not fore) and not tilequads[tilenumber].foreground) or (fore and tilequads[tilenumber].foreground)) and (not drop) then
				if tilequads[t[1]].invisible and t[1] ~= 1 then
					love.graphics.draw(tilequads[t[1]].image, tilequads[t[1]].quad, math.floor((x-1-xoff)*16*scale), ((y-1-yoff)*16-8)*scale, 0, scale, scale)
				end
				
				if #t > 1 and t[2] ~= "link" then
					tilenumber = t[2]
					if tablecontains(customenemies, tilenumber) and enemiesdata[tilenumber] and (enemiesdata[tilenumber].width and enemiesdata[tilenumber].height) then --ENEMY PREVIEW THING
						local v = enemiesdata[tilenumber]
						local exoff, eyoff = ((0.5-v.width/2+(v.spawnoffsetx or 0))*16 + v.offsetX - v.quadcenterX)*scale, (((v.spawnoffsety or 0)-v.height+1)*16-v.offsetY - v.quadcenterY)*scale
						
						local mx, my = getMouseTile(love.mouse.getX(), love.mouse.getY()+8*scale)
						local alpha = 150/255
						if cox == mx and coy == my then
							alpha = 1
						end
						local offsetx = 0
						if t["argument"] and t["argument"] == "o" then --offset
							offsetx = .5
						end
						
						love.graphics.setColor(1, 0, 0, alpha)
						love.graphics.rectangle("fill", math.floor((x-1-xoff+offsetx)*16*scale), math.floor(((y-1-yoff)*16-8)*scale), 16*scale, 16*scale)
						love.graphics.setColor(1, 1, 1, alpha)
						if v.showicononeditor and v.icongraphic then
							love.graphics.draw(v.icongraphic, math.floor((x-1-xoff+offsetx)*16*scale), ((y-1-yoff)*16-8)*scale, 0, scale, scale)
						else
							love.graphics.draw(v.graphic, v.quad, math.floor((x-1-xoff+offsetx)*16*scale+exoff), math.floor(((y-1-yoff)*16)*scale+eyoff), 0, (v.animationscalex or 1)*scale, (v.animationscaley or 1)*scale)
						end
						if t["argument"] and t["argument"] == "b" then --supersize
							love.graphics.setColor(1, 1, 1, 200/255)
							love.graphics.draw(entityquads[313].image, entityquads[313].quad, math.floor((x-1-xoff)*16*scale), ((y-1-yoff)*16-8)*scale, 0, scale, scale)
						end
					elseif entityquads[tilenumber] and entityquads[tilenumber].t then
						local i = entityquads[tilenumber].t
						if (i == "pipe" or i == "pipespawn" or i == "warppipe") and t[3] then
							--pipe display
							local qs = 1
							if i == "pipespawn" then
								qs = 2
							elseif i == "warppipe" then
								qs = 3
							end
							love.graphics.setColor(1, 1, 1, 150/255)
							if type(t[3]) == "string" then
								local s = t[3]:split("|")
								if s[3] then
									local dir = s[3] or "down"
									love.graphics.draw(pipesimg, pipesquad[qs][dir], math.floor((x-1-xoff)*16*scale), ((y-1-yoff)*16-8)*scale, 0, scale, scale)
								else
									love.graphics.draw(pipesimg, pipesquad[qs]["default"], math.floor((x-1-xoff)*16*scale), ((y-1-yoff)*16-8)*scale, 0, scale, scale)
								end
							else
								love.graphics.draw(pipesimg, pipesquad[qs]["default"], math.floor((x-1-xoff)*16*scale), ((y-1-yoff)*16-8)*scale, 0, scale, scale)
							end
						else
							local offsetx = 0
							if t["argument"] and t["argument"] == "o" then --offset
								offsetx = .5
								love.graphics.setScissor(math.floor((x-1-xoff)*16*screenzoom*scale), math.floor(((y-1-yoff)*16-8)*screenzoom*scale), 16*screenzoom*scale, 16*screenzoom*scale)
							end
							love.graphics.setColor(1, 1, 1, 150/255)
							love.graphics.draw(entityquads[tilenumber].image, entityquads[tilenumber].quad, math.floor((x-1-xoff+offsetx)*16*scale), ((y-1-yoff)*16-8)*scale, 0, scale, scale)
							if offsetx > 0 then
								love.graphics.setScissor()
							end
							if t["argument"] and t["argument"] == "b" then --supersize
								love.graphics.setColor(1, 1, 1, 200/255)
								love.graphics.draw(entityquads[313].image, entityquads[313].quad, math.floor((x-1-xoff+offsetx)*16*scale), ((y-1-yoff)*16-8)*scale, 0, scale, scale)
							end
							if (entityquads[tilenumber].t == "track" or entityquads[tilenumber].t == "trackswitch") and not trackpreviews then
								generatetrackpreviews()
							end
						end
					end
					if not drop then
						love.graphics.setColor(1, 1, 1, 1)
					end
				end
			end
		end
	end
end

function drawtile(tilenumber, x, y, r, sx, sy, ox, oy)
	--currently unused
	if tilequads[tilenumber].invisible then
		return false
	end
	if tilequads[tilenumber].coinblock and tilenumber < 90000 and not tilequads[tilenumber].invisible then --coinblock
		love.graphics.draw(coinblockimage, coinblockquads[spriteset][coinframe], x, y, r, sx, sy, ox, oy)
	elseif tilequads[tilenumber].coin and tilenumber < 90000 then --coin
		love.graphics.draw(coinimage, coinquads[spriteset][coinframe], x, y, r, sx, sy, ox, oy)
	elseif tilenumber > 90000 then --same as below, but keeps animated tiles on grid
		if not tilequads[tilenumber].invisible then
			love.graphics.draw(tilequads[tilenumber].image, tilequads[tilenumber].quad, x, y, r, sx, sy, ox, oy)
		end
	else
		love.graphics.draw(tilequads[tilenumber].image, tilequads[tilenumber].quad, x, y, r, sx, sy, ox, oy)
	end
end

function supersizeentity(v, size)
	v.supersized = size or 2
	if v.x and v.y and v.width and v.height then
		local x, y, y2 = v.x+v.width/2, v.y+v.height/2, v.y+v.height

		v.animationscalex = (size or 2)
		v.animationscaley = (size or 2)
		v.width = v.width*(size or 2)
		v.height = v.height*(size or 2)
		v.weight = (v.weight or 1)*(size or 2)
		--v.offsetX = v.offsetX*2
		--v.offsetY = v.offsetY*2-8

		if v.movedist then
			v.movedist = v.movedist*(size or 2)
		end

		v.x = x-v.width/2
		if v.supersizedown or (v.gravity and v.gravity < 0) then
			--upsidedown
		elseif (v.static or (v.gravity and v.gravity == 0)) and (not v.supersizeup) then
			v.y = y-v.height/2
		else
			v.y = y2-v.height
		end

		if v.supersizeoffsetx then
			v.x = v.x + v.supersizeoffsetx
		end
		if v.supersizeoffsety then
			v.x = v.y + v.supersizeoffsety
		end
	end

	if v.dosupersize then
		v:dosupersize()
	end
end

function checkfortileincoord(x, y)
	--used for enemies that turn around ledges
	return ( (tilequads[map[x][y][1]]:getproperty("collision", x, y) and (not tilequads[map[x][y][1]]:getproperty("invisible", x, y)) and (not (objects["tile"][tilemap(x, y)] and objects["tile"][tilemap(x, y)].slab)) )
		or (objects["flipblock"][tilemap(x, y)] and objects["flipblock"][tilemap(x, y)].active)
		or (objects["buttonblock"][tilemap(x, y)] and objects["buttonblock"][tilemap(x, y)].active)
		or (objects["frozencoin"][tilemap(x, y)])
		or objects["clearpipesegment"][tilemap(x, y)] )
end

function startlowtime()
	if pbuttonsound:isPlaying() then
		pbuttonsound:setVolume(0)
	else
		stopmusic()
		love.audio.stop()
	end
	playsound(lowtimesound)
	queuelowtime = 7.5
end

--replace any characters that may mess with level saving
function makelevelfilesafe(s)
	s = s:gsub(",","ª"); s = s:gsub("%.","º"); s = s:gsub("%-","¯")
	return s
end
function readlevelfilesafe(s)
	s = s:gsub("ª",","); s = s:gsub("º","%."); s = s:gsub("¯","%-")
	return s
end

function getdrawrange(xscroll,yscroll,spritebatch)
	local xfromdraw, xtodraw = math.max(1, math.floor(xscroll)+1), math.min(mapwidth, math.floor(xscroll+width*(1/screenzoom))+1)
	local yfromdraw, ytodraw = math.max(1, math.floor(yscroll)+1), math.min(mapheight, math.floor(yscroll+height*(1/screenzoom)+1+0.5)+1)
	local xoff = math.floor(xscroll)
	if not spritebatch then
		xoff = xoff+math.fmod(xscroll, 1)
		if xscroll < 0 then
			xoff = math.ceil(xscroll)+math.fmod(xscroll, 1)
		end
	end
	local yoff = math.floor(yscroll)
	if not spritebatch then
		yoff = yoff+math.fmod(yscroll, 1)
		if yscroll < 0 then
			yoff = math.ceil(yscroll)+math.fmod(yscroll, 1)
		end
	end
	if spritebatch and dropshadow then -- fix shadows disappearing too early, .1875 equals to 3 pixels (3/16)
		xfromdraw = math.floor(math.max(xfromdraw - .1875, 1))
		yfromdraw = math.floor(math.max(yfromdraw - .1875, 1))
	end
	return xfromdraw,xtodraw, yfromdraw,ytodraw, xoff,yoff
end

function setscreenzoom(z)
	screenzoom = z
	screenzoom2 = 1/screenzoom
end
-------------------
--DAILY CHALLENGE--
-------------------
function dchighscore()
	if DChigh[1] == "-" then
		DCcompleted = DCcompleted + 1
	end
	local old = {DChigh[1], DChigh[2], DChigh[3]}
	local highscore = false
	local timefinished = round(mariotimelimit-realmariotime, 2)
	if DChigh[1] == "finished" then
		DChigh[1] = timefinished
		highscore = true
	elseif not tonumber(DChigh[1]) or timefinished < DChigh[1] then
		DChigh[1] = timefinished
		DChigh[2] = old[1]
		DChigh[3] = old[2]
		highscore = true
	elseif not tonumber(DChigh[2]) or timefinished < DChigh[2] then
		DChigh[2] = timefinished
		DChigh[3] = old[2]
		highscore = true
	elseif not tonumber(DChigh[3]) or timefinished < DChigh[3] then
		DChigh[3] = timefinished
		highscore = true
	end
	if highscore then
		local s = tostring(DCcompleted) .. "~" .. datet[1] .. "/" .. datet[2] .. "/" .. datet[3]
		love.filesystem.write("alesans_entities/dc.txt", s)
	end
end
