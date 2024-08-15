local socket = require "socket"

local udp
 
local address, port = "localhost", 27020
 
local entity
local clients
local updaterate = 0.1
local pingrate = 2
local updatetimer --update timer
local actions
local levelscreensync
local enemyspawnx

local clientconnecttimer = 0
local clientconnected = false
local clientconnecttime = 4

local spamtimer = 0 --stop "funny" kids from spamming
local spamtime = 0.2
local spamcounter = 0
local spammercount = 10

local lobbytimeout = 12 --kick player if ping is higher than this (a ping this high means they've disconnected)

function client_load(a, p)
	address, port = a or "localhost", p or 27020

	udp = socket.udp()
	udp:settimeout(0)
 
	udp:setpeername(address, port)
	if tostring(udp) and not (tostring(udp):sub(1, 14) == "udp{connected}") then
		udp:close()
		notice.new("server not found", notice.red, 3)
		return false
	end
 
	math.randomseed(os.time()) 
 
	entity = tostring(math.random(99999))
	clients = {}
	playerlist[1].id = entity
 
	local s = "" --colors
	for i = 1, #mariocolors[playerconfig] do
		s = s .. mariocolors[playerconfig][i][1] .. "|" .. mariocolors[playerconfig][i][2] .. "|" .. mariocolors[playerconfig][i][3] .. "|"
	end
	s = s:sub(1, -2)
	
	local dg = string.format("%s~%s~%s~%s~%s~%s", entity, 'connect', localnick, s, mariohats[playerconfig][1], tostring(mariocharacter[playerconfig]))
	udp:send(dg)
	updatetimer = 0
	actions = {}
	levelscreensync = false
	enemyspawnx = 0

	clientconnected = false
	clientconnecttimer = 0
	
	SERVER = false
	CLIENT = true
	
	return true
end

function server_load(p)
	port = p or 27020
	
	udp = socket.udp()
	entity = nil
	clients = {}
	
	udp:setsockname("*", port)
	udp:settimeout(0)
	
	updatetimer = 0
	actions = {}
	enemyspawnx = 0
	
	SERVER = true
	CLIENT = false
	
	return true
end

function server_update(dt)
	-- SERVER CODE --
	
	--send
	if gamestate == "lobby" then
		--update ping
		local kickedplayer = false --not a table because only one player should be kicked in a frame (otherwise ids would get shuffled)
		for i, t in pairs(clients) do
			if clients[i].ping then
				clients[i].ping = clients[i].ping + dt
				if not kickedplayer and clients[i].ping > lobbytimeout then
					kickedplayer = clients[i].i
				end
			end
		end
		if kickedplayer then
			server_disconnect(kickedplayer)
		end
		updatetimer = updatetimer + dt
		if updatetimer > pingrate then
			for i, t in pairs(clients) do
				if not clients[i].ping then
					clients[i].ping = 0
					if t.i and playerlist[t.i] and playerlist[t.i].ping then
						udp:sendto(string.format("%s~%f", 'ping', playerlist[t.i].ping), t[1], t[2])
					end
				end
			end
	 
			updatetimer = updatetimer - pingrate
		end
	elseif gamestate == "game" or gamestate == "levelscreen" or gamestate == "sublevelscreen" then
		--one-time actions
		updatetimer = updatetimer + dt
		if updatetimer > updaterate then
			if #actions > 0 then
				local s = "" --colors
				for i2 = 1, #actions do
					s = s .. actions[i2] .. "~"
				end
				s = s:sub(1, -2)
				--for i, t in pairs(clients) do
					playerlist[1].actions = s
					--udp:sendto(string.format("%s~%s~%s", 'action', playerlist[1].id, s), t[1], t[2])
				--end
				actions = {}
			end
			for entity, t in pairs(clients) do
				for i = 1, players do
					if i ~= clients[entity].i then
						--send player actions to clients
						if playerlist[i].actions then
							udp:sendto(string.format("%s~%s~%s", 'action', playerlist[i].id, playerlist[i].actions), clients[entity][1], clients[entity][2])
						end
						--send player locations to clients
						if objects and gamestate == "game" and objects["player"][i] and (not (objects["player"][i].dead and objects["player"][i].speedy > 0)) then
							local x, y = tostring(round(objects["player"][i].x, 6)), tostring(round(objects["player"][i].y, 6))
							local speedx, speedy = tostring(round(objects["player"][i].speedx, 5) or 0), tostring(round(objects["player"][i].speedy, 5) or 0)
							local gravity, animationstate = objects["player"][i].gravity or 0, objects["player"][i].animationstate or "idle"
							local pointingangle = tostring(round(objects["player"][i].pointingangle, 4))
							if not objects["player"][i].portalgun then pointingangle = objects["player"][i].animationdirection or "right" end
							local ft = {"f", "f"}
							if speedx == math.floor(speedx) then ft[1] = "d" end; if speedy == math.floor(speedy) then ft[2] = "d" end
						
							if (objects["player"][i].speedx ~= 0 or objects["player"][i].speedy ~= 0) or
							 ((not objects["player"][i].oldx) or (objects["player"][i].oldx ~= objects["player"][i].x)) or
							 ((not objects["player"][i].oldy) or (objects["player"][i].oldy ~= objects["player"][i].y)) then
								local dg = string.format("%s~%s~%s~%s~%s~%s~%d~%s~%s", 'move', playerlist[i].id, x, y, speedx, speedy, gravity, animationstate, pointingangle)
								udp:sendto(dg, clients[entity][1], clients[entity][2])
							end
							objects["player"][i].oldx = objects["player"][i].x; objects["player"][i].oldy = objects["player"][i].y
						end
					end
				end
				for i = 1, players do
					playerlist[i].actions = false
				end
			end
			updatetimer = updatetimer - updaterate
		end
	end
	
	--recieve
	local data, msg_or_ip, port_or_nil = udp:receivefrom()
	if data then
		print(data)
		
		--add player to list
		local t = data:split("~")
		cmd = t[2]
		local entity = t[1]
		local safe = true
		if entity and not clients[entity] then
			--clients[entity] = {msg_or_ip, port_or_nil}
			safe = false
		end
		
		--commands
		if cmd == 'connect' then
			if entity and not clients[entity] then
				clients[entity] = {msg_or_ip, port_or_nil}
			end
			if gamestate ~= "lobby" then
				--kick out during game
				notice.new("rejected player\ncant join during the game", notice.red, 3)
				udp:sendto(string.format("%s~%s", 'notice', "cant connect during the game"), clients[entity][1], clients[entity][2])
				udp:sendto('kick', clients[entity][1], clients[entity][2])
				return
			end
			if not t[6] then --no character sent, must be from v11 or lower
				notice.new("rejected player\ncant join with outdated version", notice.red, 3)
				udp:sendto(string.format("%s~%s", 'notice', "outdated game!\nyou need to be on version " .. VERSIONSTRING), clients[entity][1], clients[entity][2])
				udp:sendto('kick', clients[entity][1], clients[entity][2])
				return
			end
			local c, color = t[4]:split("|"), {}
			for i = 1, math.floor(#c/3) do
				table.insert(color, {tonumber(c[(i-1)*3+1]),tonumber(c[(i-1)*3+2]),tonumber(c[(i-1)*3+3])})
			end
			local hat = tonumber(t[5]) or 1
			if t[5] == "nil" then
				hat = nil
			end
			table.insert(playerlist, {connected=true, id=entity, hats={hat}, colors=color, nick=t[3], ping = 0, character=t[6] or false})
			setcustomplayer(playerlist[#playerlist].character, #playerlist, "initial")
			if mariocharacter[#playerlist] then --change character to mario if other character isn't loaded
				playerlist[#playerlist].character = mariocharacter[#playerlist]
			end
			clients[entity].i = #playerlist
			clients[entity].nick = t[3] or entity
			players = #playerlist
			local s = ""--player information
			for i = 1, #playerlist do
				local c = "" --colors
				for i2 = 1, #playerlist[i].colors do
					c = c .. playerlist[i].colors[i2][1] .. "|" .. playerlist[i].colors[i2][2] .. "|" .. playerlist[i].colors[i2][3] .. "|"
				end
				c = c:sub(1, -2)
				s = s .. playerlist[i].id .. ";" .. tostring(playerlist[i].nick) .. ";" .. c .. ";" .. tostring(playerlist[i].hats[1]) .. ";" .. tostring(playerlist[i].character) .. "~"
				if i ~= 1 then
					controls[i] = {}
					controls[i]["right"] = {""}
					controls[i]["left"] = {""}
					controls[i]["down"] = {""}
					controls[i]["up"] = {""}
					controls[i]["run"] = {""}
					controls[i]["jump"] = {""}
					controls[i]["aimx"] = {""} --mouse aiming, so no need
					controls[i]["aimy"] = {""}
					controls[i]["portal1"] = {""}
					controls[i]["portal2"] = {""}
					controls[i]["reload"] = {""}
					controls[i]["use"] = {""}
				end
			end
			s = s:sub(1, -2)
			for i, t in pairs(clients) do
				udp:sendto(string.format("%s~%d~%s", 'connect', #playerlist, s), t[1], t[2])
			end
			--send them the settings
			server_infinitelives(infinitelives, clients[entity])
			server_infinitetime(infinitetime, clients[entity])
			server_setmappack(mappack, clients[entity])
			notice.new(playerlist[players].nick .. " connected", notice.white, 3)
		elseif cmd == 'pong' and safe then
			--get ping
			if clients[entity] and clients[entity].i and playerlist[clients[entity].i] then
				playerlist[clients[entity].i].ping = clients[entity].ping
				clients[entity].ping = false
			end
		elseif cmd == 'chat' and safe then
			--recieve chat message and relay to clients
			local name = t[3]
			if clients[t[3]] then
				name = clients[t[3]].nick or t[3]
			end
			if gamestate ~= "lobby" then
				notice.new(tostring(name) .. ":" .. tostring(t[4]), notice.white, 10)
			end
			table.insert(chatmessages, {id = entity, message = t[4]})
			if t[4] == "kappa" then
				playsound(rainboomsound)
			else
				--playsound(blockhitsound)
			end
			local dg = string.format("%s~%s~%s", 'chat', t[3], t[4])
			for i, t in pairs(clients) do
				if i ~= entity then
					udp:sendto(dg, t[1], t[2])
				end
			end
		elseif cmd == 'disconnect' and safe then
			server_disconnect(clients[entity].i)
			clients[entity] = nil
		elseif cmd == 'move' and safe then
			if objects then
				net_moveplayer(clients[entity].i, t)
			end
		elseif cmd == 'update' and safe then
			--relay player information to clients
			
		elseif cmd == 'action' and safe then
			local id = clients[entity].i
			if id and objects then
				local a = ""
				for i = 1, #t-2 do
					a = a .. t[i+2] .. "~"
					local s = t[i+2]:split("|")
					net_doaction(objects["player"][id], s)
				end
				if playerlist[id].actions then
					playerlist[id].actions = playerlist[id].actions .. "~" .. a:sub(1, -2)
				else
					playerlist[id].actions = a:sub(1, -2)
				end
			end
		elseif cmd == 'mappackerror' and safe then
			--player is missing mappack
			if guielements.mappack then
				guielements.mappack.textcolor = {127, 0, 0}
				notice.new(playerlist[clients[entity].i].nick .. " is missing the mappack!", notice.red, 5)
			end
		elseif cmd == 'quit' then
			
		else
			print("unrecognised command:", cmd)
		end
	elseif msg_or_ip ~= 'timeout' then
		print("Unknown network error: "..tostring(msg_or_ip))
		--notice.new("Unknown network error: "..tostring(msg_or_ip), notice.red, 3)
	end
end

function client_update(dt)
	-- CLIENT CODE --

	if spamtimer > 0 then--this is why we can't have nice things
		spamtimer = spamtimer - dt
	end

	--send
	if gamestate == "game" or gamestate == "levelscreen" or gamestate == "sublevelscreen" then
		--send player posistion
		updatetimer = updatetimer + dt
		if updatetimer > updaterate and gamestate == "game" and objects and objects["player"] and objects["player"][1] then
			local i = 1
			if (not (objects["player"][i].dead and objects["player"][i].speedy > 0)) then
				local x, y = tostring(round(objects["player"][1].x, 6)), tostring(round(objects["player"][1].y, 6))
				local speedx, speedy = tostring(round(objects["player"][1].speedx, 5) or 0), tostring(round(objects["player"][1].speedy, 5) or 0)
				local gravity, animationstate = objects["player"][1].gravity or 0, objects["player"][1].animationstate or "idle"
				local pointingangle = tostring(round(objects["player"][1].pointingangle, 4))
				if not objects["player"][1].portalgun then pointingangle = objects["player"][1].animationdirection or "right" end
				local ft = {"f", "f"}
				if speedx == math.floor(speedx) then ft[1] = "d" end; if speedy == math.floor(speedy) then ft[2] = "d" end
				
				if (objects["player"][1].speedx ~= 0 or objects["player"][1].speedy ~= 0) or ((not objects["player"][1].oldx) or (objects["player"][1].oldx ~= objects["player"][1].x)) or ((not objects["player"][1].oldy) or (objects["player"][1].oldy ~= objects["player"][1].y)) then
					local dg = string.format("%s~%s~%s~%s~%s~%s~%d~%s~%s", entity, 'move', x, y, speedx, speedy, gravity, animationstate, pointingangle)
					udp:send(dg)
				end
				objects["player"][1].oldx = objects["player"][1].x; objects["player"][1].oldy = objects["player"][1].y
		
				--local dg = string.format("%s~%s", entity, 'update')
				--udp:send(dg)
			end
	 
			updatetimer = updatetimer - updaterate
		end
		
		--one-time actions
		if #actions > 0 then
			local s = "" --colors
			for i2 = 1, #actions do
				s = s .. actions[i2] .. "~"
			end
			s = s:sub(1, -2)
			udp:send(string.format("%s~%s~%s", entity, 'action', s))
			actions = {}
		end
	end
 
	--recieve
	repeat
		local data, msg = udp:receive()
		if data then
			print(data)
			local t = data:split("~")
			local cmd = t[1]
			if cmd == 'connect' then
				if gamestate == "lobby" then
					clientconnected = true
					--update player list
					players = tonumber(t[2])
					playerlist = {{connected=true, hats=mariohats[playerconfig], colors=mariocolors[playerconfig], nick=localnick, id=entity, character=mariocharacter[playerconfig]}}
					local id, nick, color, hats, p
					for i = 1, players do
						local t2 = t[2+i]:split(";")
						id, nick, color, hats, character = t2[1], t2[2], {}, tonumber(t2[4]) or 1, t2[5]
						if id ~= playerlist[1].id then
							if t2[3] then
								local c = t2[3]:split("|")
								for i2 = 1, math.floor(#c/3) do
									table.insert(color, {tonumber(c[(i2-1)*3+1]),tonumber(c[(i2-1)*3+2]),tonumber(c[(i2-1)*3+3])})
								end
							end
							if character == "false" then
								character = "mario"
							end
							if t2[4] == "nil" then
								hats = nil
							end
							table.insert(playerlist, {connected=true, id=id, hats={hats}, colors=color, nick=nick, ping = 0, character=character or false})
							setcustomplayer(playerlist[#playerlist].character, #playerlist, "initial")
						end
						if i ~= 1 then
							controls[i] = {}
							controls[i]["right"] = {""}
							controls[i]["left"] = {""}
							controls[i]["down"] = {""}
							controls[i]["up"] = {""}
							controls[i]["run"] = {""}
							controls[i]["jump"] = {""}
							controls[i]["aimx"] = {""} --mouse aiming, so no need
							controls[i]["aimy"] = {""}
							controls[i]["portal1"] = {""}
							controls[i]["portal2"] = {""}
							controls[i]["reload"] = {""}
							controls[i]["use"] = {""}
						end
					end
				end
			elseif cmd == 'ping' then
				--get ping
				playerlist[1].ping = tonumber(t[2])
				udp:send(string.format("%s~%s", entity, 'pong'))
			elseif cmd == 'start' then
				--start game
				for i = 1, players do
					if playerlist[i] then
						if playerlist[i].character then
							setcustomplayer(playerlist[i].character, i, "initial")
						end
						mariocolors[i] = playerlist[i].colors
						mariohats[i] = playerlist[i].hats
					end
				end
				game_load()--true)
			elseif cmd == 'levelscreen' then
				if gamestate ~= "levelscreen" or gamestate ~= "sublevelscreen" then
					levelscreen_load(t[2], tonumber(t[3]))
				end
				marioworld = tonumber(t[4]) or t[4] or marioworld
				mariolevel = tonumber(t[5]) or t[5] or mariolevel
				mariosublevel = tonumber(t[6]) or t[6] or mariosublevel
				--sublevelscreen_level = mariosublevel
				actualsublevel = mariosublevel
			elseif cmd == 'levelscreensync' then
				levelscreensync = true
				levelscreentimer = blacktime
			elseif cmd == 'chat' then
				--recieve chat message
				if gamestate ~= "lobby" then
					notice.new(tostring(t[2]) .. ":" .. tostring(t[3]), notice.white, 10)
				end
				table.insert(chatmessages, {id = t[2], message = t[3]})
				if t[3] == "kappa" then
					playsound(rainboomsound)
				else
					--playsound(blockhitsound)
				end
			elseif cmd == 'move' then
				if objects then
					local i
					for p = 1, players do
						if t[2] == playerlist[p].id then
							i = p
							break
						end
					end
					if i then
						net_moveplayer(i, t)
					end
				end
			elseif cmd == 'action' then
				local id
				for p = 1, players do
					if t[2] == playerlist[p].id then
						id = p
						break
					end
				end
				if id and objects then
					for i = 1, #t-2 do
						local s = t[i+2]:split("|")
						net_doaction(objects["player"][id], s)
					end
				end
			elseif cmd == 'infinitelives' then
				infinitelives = (t[2] == "true")
				if guielements.infinitelives then
					guielements.infinitelives.var = infinitelives
				end
			elseif cmd == 'infinitetime' then
				infinitetime = (t[2] == "true")
				if guielements.infinitetime then
					guielements.infinitetime.var = infinitetime
				end
			elseif cmd == 'mappack' then
				local target = t[2]
				if mappack ~= t[2] and mappacklist then
					for i = 1, #mappacklist do
						--find and set mappack
						if mappacklist[i] == target then
							mappack = target
							if mappackbackground and mappackbackground[mappackselection] then
								loadbackground(mappackbackground[mappackselection] .. ".txt")
							else
								loadbackground("1-1.txt")
							end
							mappackselection = i
							if guielements.mappack then
								guielements.mappack.text = target:lower()
								guielements.mappack.textcolor = {127, 127, 127}
							end
							break
						end
						--didn't find mappack, send message
						if i == #mappacklist then
							if guielements.mappack then
								guielements.mappack.text = target:lower()
								guielements.mappack.textcolor = {127, 0, 0}
							end
							notice.new("missing mappack!", notice.red, 5)
							udp:send(string.format("%s~%s", entity, 'mappackerror'))
						end
					end
				end
			elseif cmd == 'disablecheats' then
				playertype = "portal"
				playertypei = 1
				bullettime = false
				speedtarget = 1
				portalknockback = false
				bigmario = false
				goombaattack = false
				sonicrainboom = false
				playercollisions = false
				--infinitetime = false
				--infinitelives = false
				notice.new("cheats disabled", notice.white, 3)
			elseif cmd == 'lobby' then
				if gamestate ~= "lobby" then
					love.audio.stop()
					lobby_load()
				end
			elseif cmd == 'notice' then
				notice.new("Server:" .. t[2], notice.red, 5)
			elseif cmd == 'kick' then
				net_quit()
				notice.new("Kicked from server", notice.red, 5)
			else
				print("unrecognised command:", cmd)
			end
		elseif msg ~= 'timeout' then 
			print("Network error: "..tostring(msg))
			notice.new("Network error: "..tostring(msg), notice.red, 3)
			net_quit()
		end
	until not data

	--make sure client is actually connected
	if not clientconnected then
		clientconnecttimer = clientconnecttimer + dt
		if clientconnecttimer > clientconnecttime then
			net_quit()
			notice.new("Could not connnect", notice.red, 5)
			return
		end
	end
end

function server_start()
	for i = 1, players do
		if playerlist[i] then
			if playerlist[i].character then
				setcustomplayer(playerlist[i].character, i, "initial")
			end
			mariocolors[i] = playerlist[i].colors
			mariohats[i] = playerlist[i].hats
		end
	end
	for i, t in pairs(clients) do
		udp:sendto(string.format("%s~%d~%d", 'start', #playerlist, 0), t[1], t[2])
	end
	players = #playerlist
	game_load()--true)
end

function server_lobby()
	for i, t in pairs(clients) do
		udp:sendto(string.format("%s", 'lobby'), t[1], t[2])
	end
end

function net_quit()
	if CLIENT then
		udp:send(string.format("%s~%s", entity, 'disconnect'))
	elseif SERVER then
		for i, t in pairs(clients) do
			udp:sendto("kick", t[1], t[2])
		end
	end
	
	players = 1
	gamestate = "menu"
	menu_load()
	udp:close()
	SERVER = false
	CLIENT = false
	
	loadconfig("nodefaultconfig")
	loadbackground("1-1.txt")
	setcustomplayer(mariocharacter[1], 1, "initial")
end

function server_levelscreen(reason, subleveli)
	if SERVER then
		for i, t in pairs(clients) do
			udp:sendto(string.format('levelscreen~%s~%s~%s~%s~%s', tostring(reason), tostring(subleveli), tostring(marioworld), tostring(mariolevel), tostring(actualsublevel)), t[1], t[2])
		end
	end
end

function net_levelscreensync()
	if not SERVER and not CLIENT then
		return true
	elseif SERVER then
		for i, t in pairs(clients) do
			udp:sendto('levelscreensync', t[1], t[2])
		end
		return true
	elseif levelscreensync then
		levelscreensync = false
		return true
	end
	return false
end


function net_sendchat(s)
	table.insert(chatmessages, {id = playerlist[1].id, message = s})
	if SERVER then
		local dg = string.format("%s~%s~%s", 'chat', playerlist[1].id, s)
		for i, t in pairs(clients) do
			udp:sendto(dg, t[1], t[2])
		end

		--commands
		if gamestate == "game" and s:find("/") then
			net_command(s)
		elseif s == "/disablecheats" then
			for i, t in pairs(clients) do
				udp:sendto('disablecheats', t[1], t[2])
			end
			notice.new("cheats disabled", notice.white, 3)
		end
	else
		if spamcounter > spammercount then
			return false
		elseif spamtimer <= 0 then
			spamtimer = spamtime
		else
			spamcounter = spamcounter + 1
		end
		local dg = string.format("%s~%s~%s~%s", entity, 'chat', playerlist[1].id, s)
		udp:send(dg)
	end
end

function net_command(s)
	local s = s:sub(2,-1)
	if s == "nextlevel" then
		nextlevel()
		server_infinitetime(infinitetime, clients[entity])
		notice.new("skipped level", notice.white, 3)
	elseif s == "reload" then
		levelscreen_load("death")
		notice.new("reloaded level", notice.white, 3)
	elseif s:sub(1,5) == "level" then
		local v = s:split(" ")
		love.audio.stop()
		
		--why do sublevels suck so much
		marioworld = tonumber(v[2]) or marioworld
		mariolevel = tonumber(v[3]) or mariolevel
		mariosublevel = tonumber(v[4]) or mariosublevel
		testlevelworld = marioworld
		testlevellevel = mariolevel
		actualsublevel = mariosublevel
		respawnsublevel = mariosublevel
		levelscreen_load("animation")
		mariosublevel = tonumber(v[4]) or mariosublevel
		actualsublevel = mariosublevel
		respawnsublevel = mariosublevel
		notice.new("skipped level", notice.white, 3)
	elseif s == "infinitelives" then
		infinitelives = not infinitelives
		server_infinitelives(infinitelives, clients[entity])
		notice.new("set infinite lives to " .. tostring(infinitelives), notice.white, 3)
	elseif s == "infinitetime" then
		infinitetime = not infinitetime
		server_infinitetime(infinitetime, clients[entity])
		notice.new("set infinite time to " .. tostring(infinitetime), notice.white, 3)
	end
end

function net_action(i, a, t) --player no?, action name, argument
	if (CLIENT or SERVER) and i == 1 then
		if t then
			table.insert(actions, a .. "|" .. t)
		else
			table.insert(actions, a)
		end
	end
end

function server_disconnect(removei)
	if (not removei) or (not playerlist[removei]) then
		--sometimes the player never connected in the first place. ugh
		notice.new("failed to remove player " .. tostring(removei), notice.red, 3)
		return
	end
	playerlist[removei].connected = false
	notice.new(playerlist[removei].nick .. " disconnected", notice.white, 3)
	table.remove(playerlist, removei)
	players = players - 1
	local s = ""--player information
	for i = 1, #playerlist do
		local c = "" --colors
		for i2 = 1, #playerlist[i].colors do
			c = c .. playerlist[i].colors[i2][1] .. "|" .. playerlist[i].colors[i2][2] .. "|" .. playerlist[i].colors[i2][3] .. "|"
		end
		c = c:sub(1, -2)
		s = s .. playerlist[i].id .. ";" .. tostring(playerlist[i].nick) .. ";" .. c .. ";" .. tostring(playerlist[i].hats[1]) .. ";" .. tostring(playerlist[i].character) .. "~"
	end
	s = s:sub(1, -2)

	local delete = {}
	for i, t in pairs(clients) do
		if t.i then
			if t.i ~= removei then
				if t.i >= removei then
					t.i = t.i - 1
				end
				udp:sendto(string.format("%s~%d~%s", 'connect', #playerlist, s), t[1], t[2])
			else
				table.insert(delete,i) --remove if has id of player being kicked
			end
		else
			table.insert(delete,i) --remove if no id
		end
	end
	--table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		--table.remove(clients, v) --remove
		clients[v] = nil
		print("removed client: " .. tostring(v))
	end
end

function net_moveplayer(player, t)
	if not (objects and objects["player"] and objects["player"][player]) then
		return
	end
	objects["player"][player].x = tonumber(t[3])
	objects["player"][player].y = tonumber(t[4])
	objects["player"][player].speedx = tonumber(t[5])
	objects["player"][player].speedy = tonumber(t[6])
	objects["player"][player].gravity = tonumber(t[7])
	objects["player"][player].animationstate = t[8]
	if objects["player"][player].animationstate == "dead" then
		if (not objects["player"][player].dead) then
			objects["player"][player]:die("lava")
		end
		objects["player"][player].dead = true
	end
	objects["player"][player]:setquad(t[8])
	if tonumber(t[9]) then
		objects["player"][player].pointingangle = tonumber(t[9])
	else --no portal gun
		objects["player"][player].animationdirection = t[9]
	end
end

function net_spawnenemy(x, y)
	if (CLIENT or SERVER) and x > enemyspawnx then
		enemyspawnx = x
		local dospawn = true
		--[[for i = 1, #enemiesspawned do
			if x == enemiesspawned[i][1] then
				dospawn = false
				break
			end
		end]]
		if dospawn then
			net_action(1, "se|" .. x)
		end
	end
end

function net_doaction(player, s)
	if not (objects and player) then --make sure gamestarted
		return
	end
	if s[1] == 'jump' then
		player:jump()
	elseif s[1] == 'duck' then
		player:duck(true)
	elseif s[1] == 'unduck' then
		player:duck(false)
	elseif s[1] == 'die' then
		player.netaction = true
		player:die(s[2])
		player.netaction = nil
	elseif s[1] == 'grow' then
		player.netaction = true
		player:grow(tonumber(s[2]))
		player.netaction = nil
	elseif s[1] == 'pipe' then
		player:pipe(tonumber(s[2]), tonumber(s[3]), s[4], tonumber(s[5]))
		print(unpack(s))
	elseif s[1] == 'warppipe' then
		player:pipe(tonumber(s[2]), tonumber(s[3]), s[4], tonumber(s[5]))
	elseif s[1] == 'door' then
		player:door(tonumber(s[2]), tonumber(s[3]), s[4])
	elseif s[1] == 'upkey' then
		player:upkey()
	elseif s[1] == 'fire' then
		player:fire()
	elseif s[1] == 'portal' then
		player.pointingangle = tonumber(s[5])
		shootportal(player.playernumber, tonumber(s[2]), tonumber(s[3]), tonumber(s[4]), tonumber(s[5]))
	elseif s[1] == 'removeportals' then
		player:removeportals()
	elseif s[1] == 'use' then
		player.pointingangle = tonumber(s[2])
		player:use()
	elseif s[1] == "levelball" then
		if not levelfinished then
			for i = 1, players do
				local obj = levelball:new(objects["player"][i].x+6/16, objects["player"][i].y+11/16)
				table.insert(objects["levelball"], obj)
				obj.drawable = false
				obj.sound = bowserendsound
				obj.autodelete = false
			end
		end
	elseif s[1] == 'hitblock' then
		local x, y = tonumber(s[2]), tonumber(s[3])
		local offset = false --make sure block wasn't already hit
		if getblockbounce(x, y) then
			offset = true
		end
		if not offset then
			hitblock(x, y, {size = tonumber(s[4])}, {})
		end
	elseif s[1] == "grabfence" then
		player:grabfence()
	elseif s[1] == "dropfence" then
		player:dropfence()
	elseif s[1] == "shoed" then
		local shoe = s[2]
		if shoe == "false" then
			shoe = false
		end
		player:shoed(shoe, s[3] == "true", s[4] == "true")
	elseif s[1] == 'se' then --spawn enemy
		local x = tonumber(s[2])
		for y = 1, mapheight do
			spawnenemyentity(x, y)
		end
	end
end

function server_infinitelives(bool, t) --true?, client
	if not t then
		for i, t in pairs(clients) do
			udp:sendto(string.format("%s~%s", 'infinitelives', tostring(bool) or true), t[1], t[2])
		end
	else
		udp:sendto(string.format("%s~%s", 'infinitelives', tostring(bool) or true), t[1], t[2])
	end
end

function server_infinitetime(bool, t)
	if not t then
		for i, t in pairs(clients) do
			udp:sendto(string.format("%s~%s", 'infinitetime', tostring(bool) or true), t[1], t[2])
		end
	else
		udp:sendto(string.format("%s~%s", 'infinitetime', tostring(bool) or true), t[1], t[2])
	end
end

function server_setmappack(m, t)
	if not t then
		mappack = mappacklist[mappackselection]
		if mappackbackground and mappackbackground[mappackselection] then
			loadbackground(mappackbackground[mappackselection] .. ".txt")
		else
			loadbackground("1-1.txt")
		end
		local s = string.format("%s~%s", 'mappack', m)
		for i, t in pairs(clients) do
			udp:sendto(s, t[1], t[2])
		end
	else
		udp:sendto(string.format("%s~%s", 'mappack', m), t[1], t[2])
	end
end

function net_getport()
	return port
end
