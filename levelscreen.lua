function levelscreen_load(reason, i)
	--BLOCKTOGGLE STUFF
	solidblocksred = true
	solidblocksblue = true
	solidblocksyellow = true
	solidblocksgreen = true

	if reason ~= "sublevel" and reason ~= "vine" and reason ~= "animation" and testlevel then
		stoptestinglevelsafe = true
		marioworld = testlevelworld
		mariolevel = testlevellevel
		editormode = true
		testlevel = false
		startlevel(marioworld .. "-" .. mariolevel)
		return
	end

	windsound:stop()
	if not continuesublevelmusic then
		music:disableintromusic()
	end

	levelscreenimagecheck = false
	checkcheckpoint = false
	dcfinish = false
	
	--check if lives left
	livesleft = false
	for i = 1, players do
		if mariolivecount == false or (mariolives[i] and mariolives[i] > 0) then
			livesleft = true
		end
	end
	
	if reason == "sublevel" then
		gamestate = "sublevelscreen"
		blacktime = sublevelscreentime
		sublevelscreen_level = i
	elseif reason == "vine" then
		gamestate = "sublevelscreen"
		blacktime = sublevelscreentime
		sublevelscreen_level = i
	elseif reason == "dc" then
		gamestate = "dclevelscreen"
		blacktime = 0.8
	elseif livesleft then
		gamestate = "levelscreen"
		blacktime = levelscreentime
		if reason == "next" or reason == "animation" then --next level
			respawnsublevel = 0
			checkpointx = nil
			checkpointsublevel = false
			
			--check if next level doesn't exist
			if not dcplaying then
				local gamefinished = false
				if not love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/" .. marioworld .. "-" .. mariolevel .. ".txt") then
					gamefinished = true
					--check incase there are fewer than 4 levels in the world
					if reason == "next" and tonumber(mariolevel) and mariolevel <= 4 then
						if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/" .. marioworld+1 .. "-1.txt") then
							marioworld = marioworld + 1
							mariolevel = 1
							gamefinished = false
						end
					end
				end
				if gamefinished then
					if testlevel then
						testlevelworld = 1
						testlevellevel = 1
						notice.new("You have finished this mappack!", notice.white, 5)
						stoptestinglevel()
					else
						gamestate = "mappackfinished"
						blacktime = gameovertime
						
						if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/endingmusic.ogg") or love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/endingmusic.mp3") then
							playsound(endingmusic)
						else
							music:play("princessmusic")
						end
						if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/ending.png") then
							levelscreenimage = love.graphics.newImage(mappackfolder .. "/" .. mappack .. "/ending.png")
							levelscreenimagecheck = true
						end
					end
				else
					if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/" .. marioworld .. "-" .. mariolevel .. "levelscreen.png") then
						levelscreenimage = love.graphics.newImage(mappackfolder .. "/" .. mappack .. "/" .. marioworld .. "-" .. mariolevel .. "levelscreen.png")
						levelscreenimagecheck = true
					elseif love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/" .. marioworld .. "levelscreen.png") then
						levelscreenimage = love.graphics.newImage(mappackfolder .. "/" .. mappack .. "/" .. marioworld .. "levelscreen.png")
						levelscreenimagecheck = true
					elseif love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/levelscreen.png") then
						levelscreenimage = love.graphics.newImage(mappackfolder .. "/" .. mappack .. "/levelscreen.png")
						levelscreenimagecheck = true
					end
				end
			else
				dcfinish = true
				blacktime = 0.8
			end
		else
			checkcheckpoint = true
			
			if reason == "death" and i then
				respawnsublevel = i
				--sublevelscreen_level = i
			end
			
			if not dcplaying then
				if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/" .. marioworld .. "-" .. mariolevel .. "levelscreen.png") then
					levelscreenimage = love.graphics.newImage(mappackfolder .. "/" .. mappack .. "/" .. marioworld .. "-" .. mariolevel .. "levelscreen.png")
					levelscreenimagecheck = true
				elseif love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/" .. marioworld .. "levelscreen.png") then
					levelscreenimage = love.graphics.newImage(mappackfolder .. "/" .. mappack .. "/" .. marioworld .. "levelscreen.png")
					levelscreenimagecheck = true
				elseif love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/levelscreen.png") then
					levelscreenimage = love.graphics.newImage(mappackfolder .. "/" .. mappack .. "/levelscreen.png")
					levelscreenimagecheck = true
				end
			end
		end
	else
		gamestate = "gameover"
		blacktime = gameovertime
		playsound(gameoversound)
		checkpointx = nil
		
		if not dcplaying and love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/gameover.png") then
			levelscreenimage = love.graphics.newImage(mappackfolder .. "/" .. mappack .. "/gameover.png")
			levelscreenimagecheck = true
		end
	end
	
	if editormode then
		blacktime = 0
	end
	
	if reason ~= "initial" and not everyonedead then
		updatesizes()
		updateplayerproperties()
	end
	
	if marioworld == 1 or mariolevel == 1 then
		blacktime = blacktime * 1.5
	end
	
	coinframe = 1
	
	love.graphics.setBackgroundColor(0, 0, 0)
	levelscreentimer = 0
	
	--reached worlds
	local updated = false
	if not reachedworlds[mappack] then
		reachedworlds[mappack] = {}
	end
	
	if tonumber(marioworld) and not reachedworlds[mappack][marioworld] and gamestate ~= "mappackfinished" then
		if marioworld > 8 then
			for i = 1, marioworld-1 do
				if reachedworlds[mappack][i] == nil then
					reachedworlds[mappack][i] = false
				end
			end
		end
		reachedworlds[mappack][marioworld] = true
		updated = true
	end
	
	if updated then
		saveconfig()
	end

	server_levelscreen(reason, i)
end

function levelscreen_update(dt)
	if endingmusic:isPlaying() then
		levelscreentimer = 1
	else
		levelscreentimer = levelscreentimer + dt
	end
	
	if CLIENT and levelscreentimer > blacktime+5 and (love.keyboard.isDown("escape") or (android and jumpkey(1))) then --netplay
		net_quit()
	end
	
	if levelscreentimer > blacktime and net_levelscreensync() then
		if gamestate == "levelscreen" then
			gamestate = "game"
			if dcplaying then
				if dcfinish then
					menu_load()
					dcplaying = false
					gamestate = "mappackmenu"
					mappacktype = "daily_challenge"
					mappackhorscroll = 2
					mappackhorscrollsmooth = 2
				else
					startlevel("dc")
				end
			else
				if respawnsublevel ~= 0 then
					actualsublevel = respawnsublevel
					startlevel(marioworld .. "-" .. mariolevel .. "_" .. respawnsublevel)
					mariosublevel = actualsublevel --this nonsensical sublevel logic is making me lose my mind, remove this is someone complains
				else
					mariosublevel = respawnsublevel
					actualsublevel = 0
					startlevel(marioworld .. "-" .. mariolevel)
				end
			end
		elseif gamestate == "sublevelscreen" then
			gamestate = "game"
			actualsublevel = sublevelscreen_level
			startlevel(sublevelscreen_level, "sublevel")
		elseif gamestate == "dclevelscreen" then
			gamestate = "game"
			startlevel("dc")
		else
			if SERVER or CLIENT then
				lobby_load()
			else
				menu_load()
			end
			if dcplaying then
				dcplaying = false
				gamestate = "mappackmenu"
				mappacktype = "daily_challenge"
				mappackhorscroll = 2
				mappackhorscrollsmooth = 2
			end
		end
		
		return
	end
end

function levelscreen_draw()
	local properprintfunc = properprintF
	if hudoutline then
		properprintfunc = properprintFbackground
	end
	local properprintbasicfunc = properprint
	if hudoutline then
		properprintbasicfunc = properprintbackground
	end
	if levelscreentimer < blacktime - blacktimesub and levelscreentimer > blacktimesub then
		love.graphics.setColor(1, 1, 1, 1)
		
		if gamestate == "levelscreen" and not dcplaying then
			if levelscreenimagecheck then
				love.graphics.draw(levelscreenimage, 0, 0, 0, scale, scale)
			end
			
			local world = marioworld
			if hudworldletter and tonumber(world) and world > 9 and world <= 9+#alphabet then
				world = alphabet:sub(world-9, world-9)
			elseif world == "M" then
				world = " "
			end
			properprintfunc("world " .. world .. "-" .. mariolevel, (width/2*16)*scale-40*scale, 72*scale - (players-1)*6*scale)
			
			for i = 1, players do
				local x = (width/2*16)*scale-29*scale
				local y = (97 + (i-1)*20 - (players-1)*8)*scale
				local v = characters.data[mariocharacter[i]]
				
				for j = 1, #characters.data[mariocharacter[i]]["animations"] do
					love.graphics.setColor(unpack(mariocolors[i][j]))
					if playertype == "classic" or playertype == "cappy" or not portalgun then--no portal gun
					 	love.graphics.draw(v["animations"][j], v["small"]["idle"][5], x+(v.smalloffsetX)*scale, y+(11-v.smalloffsetY)*scale, 0, scale, scale, v.smallquadcenterX, v.smallquadcenterY)
					else
						love.graphics.draw(v["animations"][j], v["small"]["idle"][3], x+(v.smalloffsetX)*scale, y+(11-v.smalloffsetY)*scale, 0, scale, scale, v.smallquadcenterX, v.smallquadcenterY)
					end
				end
		
				--hat
				
				offsets = customplayerhatoffsets(mariocharacter[i], "hatoffsets", "idle") or hatoffsets["idle"]
				if #mariohats[i] > 1 or mariohats[i][1] ~= 1 then
					local yadd = 0
					for j = 1, #mariohats[i] do
						love.graphics.setColor(1, 1, 1)
						love.graphics.draw(hat[mariohats[i][j]].graphic, hat[mariohats[i][j]].quad[1], x+(v.smalloffsetX)*scale, y+(11-v.smalloffsetY)*scale, 0, scale, scale, v.smallquadcenterX - hat[mariohats[i][j]].x + offsets[1], v.smallquadcenterY - hat[mariohats[i][j]].y + offsets[2] + yadd)
						yadd = yadd + hat[mariohats[i][j]].height
					end
				elseif #mariohats[i] == 1 then
					love.graphics.setColor(mariocolors[i][1])
					love.graphics.draw(hat[mariohats[i][1]].graphic, hat[mariohats[i][1]].quad[1], x+(v.smalloffsetX)*scale, y+(11-v.smalloffsetY)*scale, 0, scale, scale, v.smallquadcenterX - hat[mariohats[i][1]].x + offsets[1], v.smallquadcenterY - hat[mariohats[i][1]].y + offsets[2])
				end
			
				love.graphics.setColor(1, 1, 1, 1)
				
				if playertype == "classic" or playertype == "cappy" or not portalgun then--no portal gun
					love.graphics.draw(v["animations"][0], v["small"]["idle"][5], x+(v.smalloffsetX)*scale, y+(11-v.smalloffsetY)*scale, 0, scale, scale, v.smallquadcenterX, v.smallquadcenterY)
				else
					love.graphics.draw(v["animations"][0], v["small"]["idle"][3], x+(v.smalloffsetX)*scale, y+(11-v.smalloffsetY)*scale, 0, scale, scale, v.smallquadcenterX, v.smallquadcenterY)
				end
				
				if mariolivecount == false then
					properprintfunc("*  inf", (width/2*16)*scale-8*scale, y+7*scale)
				else
					properprintfunc("*  " .. mariolives[i], (width/2*16)*scale-8*scale, y+7*scale)
				end
			end
			
			if mappack == "smb" and marioworld == 2 and mariolevel == 1 then
				local s = "remember that you can run with "
				for i = 1, #controls[1]["run"] do
					s = s .. controls[1]["run"][i]
					if i ~= #controls[1]["run"] then
						s = s .. "-"
					end
				end
				properprintfunc(s, (width/2*16)*scale-string.len(s)*4*scale, 200*scale)
			elseif mappack == "portal" and marioworld == 1 and mariolevel == 1 then
				local s = "you can remove your portals with "
				for i = 1, #controls[1]["reload"] do
					s = s .. controls[1]["reload"][i]
					if i ~= #controls[1]["reload"] then
						s = s .. "-"
					end
				end
				properprintfunc(s, (width/2*16)*scale-string.len(s)*4*scale, 190*scale)
				
				local s = "you can grab cubes and push buttons with "
				for i = 1, #controls[1]["use"] do
					s = s .. controls[1]["use"][i]
					if i ~= #controls[1]["use"] then
						s = s .. "-"
					end
				end
				properprintfunc(s, (width/2*16)*scale-string.len(s)*4*scale, 200*scale)
			elseif mappack == "alesans_entities_mappack" and marioworld == 1 and mariolevel == 1 then
				local s = "mappack by alesan99"
				properprintfunc(s, (width/2*16)*scale-string.len(s)*4*scale, 200*scale)
			elseif levelscreentext[marioworld .. "-" .. mariolevel] then
				local s = levelscreentext[marioworld .. "-" .. mariolevel]
				properprintbasicfunc(s, (width/2*16)*scale-string.len(s)*4*scale, 200*scale)
			end
			
		elseif gamestate == "mappackfinished" then
			if levelscreenimagecheck then
				love.graphics.draw(levelscreenimage, 0, 0, 0, scale, scale)
			end
			love.graphics.setColor(endingtextcolor)
			
			properprintfunc(endingtext[1], width*8*scale-string.len(endingtext[1])*4*scale, 120*scale)
			properprintfunc(endingtext[2], width*8*scale-string.len(endingtext[2])*4*scale, 140*scale)
			love.graphics.setColor(1, 1, 1, 1)
		elseif gamestate == "dclevelscreen" or dcplaying then
			if dcfinish then
				properprintfunc("daily challenge completed!", width*8*scale-string.len("daily challenge completed!")*4*scale, 120*scale)
			else
				properprintfunc("daily challenge", width*8*scale-string.len("daily challenge")*4*scale, 120*scale)
				properprintfunc(DCchalobjective, width*8*scale-string.len(DCchalobjective)*4*scale, 140*scale)
			end
		else
			if levelscreenimagecheck then
				love.graphics.draw(levelscreenimage, 0, 0, 0, scale, scale)
			end
			properprintfunc("game over", (width/2*16)*scale-40*scale, 120*scale)
		end
		
		love.graphics.translate(0, -yoffset*scale)
		if yoffset < 0 then
			love.graphics.translate(0, yoffset*scale)
		end
		
		if hudvisible then
			drawHUD()
		end
	elseif CLIENT and levelscreentimer > blacktime then
		local s = "waiting for players..."
		properprintfunc(s, (width/2*16)*scale-string.len(s)*4*scale, 100*scale)
		if levelscreentimer > blacktime+5 then
			s = "something went wrong. press esc to quit"
			properprintfunc(s, (width/2*16)*scale-string.len(s)*4*scale, 140*scale)
		end
	end
end

local function levelscreen_skip()
	local timeskip = blacktime - blacktimesub
	levelscreentimer = math.max(levelscreentimer, timeskip)
end

function levelscreen_keypressed(key)
	if levelscreentimer > 0.4 then
		if key == "return" or key == controls[1]["jump"][1] then
			levelscreen_skip()
			return
		end
	end
end

function levelscreen_joystickpressed(joystick, button)
	if levelscreentimer > 0.4 then
		local s = controls[1]["jump"]
		if s[1] == "joy" and joystick == s[2] and s[3] == "but" and button == s[4] then
			levelscreen_skip()
			return
		end
	end
end
