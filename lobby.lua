local onlinenotice = false

function lobby_load()
	collectables = {} --[marioworld-mariolevel-mariosublevel][x-y]
	collectableslist = {{},{},{},{},{},{},{},{},{},{}}
	collectablescount = {0,0,0,0,0,0,0,0,0,0}

	gamestate = "lobby"
	guielements = {}
	guielements.chatentry = guielement:new("input", 4, 207, 43+7/8, sendchat, "", 43)
	guielements.sendbutton = guielement:new("button", 359, 207, "send", sendchat, 1)
	guielements.playerscroll = guielement:new("scrollbar", 389, 3, 104, 8, 50, 0)
	
	chatmessages = {}
	
	guielements.infinitelives = guielement:new("checkbox", 7, 20, 
		function() if SERVER then infinitelives = not infinitelives; guielements.infinitelives.var = infinitelives; server_infinitelives(infinitelives) end end, infinitelives, "infinite lives")
	guielements.infinitetime = guielement:new("checkbox", 7, 33,
		function() if SERVER then infinitetime = not infinitetime; guielements.infinitetime.var = infinitetime; server_infinitetime(infinitetime) end end, infinitetime, "infinite time")
	if not mappacklist then--load mappack list
		loadmappacks()
	end
	for i = 1, #mappacklist do
		if mappacklist[i] == mappack then
			mappackselection = i
			break
		end
	end
	guielements.mappack = guielement:new("button", 21, 57, mappacklist[mappackselection]:lower(),
		function()
			--if mappack ~= mappacklist[mappackselection] then
				guielements.mappack.textcolor = {255, 255, 255}
				server_setmappack(mappacklist[mappackselection])
			--end
		end, 1, nil, nil, 192, true)
	guielements.mappackleft = guielement:new("button", 7, 57, "{",
		function() mappackselection = math.max(1, mappackselection-1); guielements.mappack.text = mappacklist[mappackselection]:lower(); guielements.mappack.textcolor = {127, 127, 127} end, 1)
	guielements.mappackright = guielement:new("button", 219, 57, "}",
		function() mappackselection = math.min(#mappacklist, mappackselection+1); guielements.mappack.text = mappacklist[mappackselection]:lower(); guielements.mappack.textcolor = {127, 127, 127} end, 1)
	if CLIENT then
		guielements.infinitelives.active = false
		guielements.infinitetime.active = false
		guielements.mappack.active = false
		guielements.mappack.textcolor = {127, 127, 127}
		guielements.mappackleft.active = false
		guielements.mappackleft.textcolor = {127, 127, 127}
		guielements.mappackright.active = false
		guielements.mappackright.textcolor = {127, 127, 127}
	end
	if SERVER then
		guielements.startbutton = guielement:new("button", 7, 80, "start game", server_start, 1)
	end
	guielements.quitbutton = guielement:new("button", 131, 80, "quit to menu", net_quit, 1)
	
	magicdns_timer = 0
	magicdns_delay = 30

	if SERVER and not onlinenotice then
		notice.new("online multiplayer\nwill not work if\nyou don't port forward!\nlook up a tutorial!!!", notice.white, 12)
		onlinenotice = true
		--[[
			Hi alexan99 i cant play multiplayer on android. Can you help me?	
			How to play multiplayer on two android devices.
			Ui: i wriate the addres (macicen or something the name that)
			and i try joined to secon device and on the second device
			i not showing up and i started the game on my device,
			on the second device not started. Can you help me to fix ?
		]]
	end
end

function lobby_update(dt)
	runanimationtimer = runanimationtimer + dt
	while runanimationtimer > runanimationdelay do
		runanimationtimer = runanimationtimer - runanimationdelay
		runanimationframe = runanimationframe - 1
		if runanimationframe == 0 then
			runanimationframe = 3
		end
	end
	
	if SERVER and usemagic then
		magicdns_timer = magicdns_timer + dt
		while magicdns_timer > magicdns_delay do
			magicdns_timer = magicdns_timer - magicdns_delay
			--this needs to be changed so the delay is like 2 seconds until the external port is known
			magicdns_keep()
		end
	end
end

function lobby_draw()
	--STUFF
	love.graphics.setColor(0, 0, 0, 200)
	love.graphics.rectangle("fill", 3*scale, 3*scale, 233*scale, 104*scale)
	
	love.graphics.setColor(255, 255, 255, 255)
	properprintF("settings", 9*scale, 9*scale)
	guielements.infinitelives:draw()
	guielements.infinitetime:draw()
	properprintF("mappack", 9*scale, 46*scale)
	guielements.mappack:draw()
	guielements.mappackleft:draw()
	guielements.mappackright:draw()
	
	if usemagic and adjective and noun then
		properprintFbackground("magicdns: " .. adjective .. " " .. noun, 4*scale, 98*scale, true)
	else
		properprintFbackground("port: " .. net_getport(), 4*scale, 98*scale, true)
	end
	if SERVER then
		guielements.startbutton:draw()
	end
	guielements.quitbutton:draw()
	
	--PLAYERLIST
	love.graphics.setScissor(239*scale, 3*scale, 161*scale, 104*scale)
	
	local missingpixels = math.max(0, (players*41-3)-104)
	
	love.graphics.setColor(0, 0, 0, 200)
	love.graphics.rectangle("fill", 239*scale, 3*scale, 150*scale, 104*scale)
	
	love.graphics.translate(0, -missingpixels*guielements.playerscroll.value*scale)
	
	local y = 1
	for i = 1, #playerlist do
		if playerlist[i].connected then
			local focus = i == 1--netplayerid == playerlist[i].id
			local ping = nil
			if playerlist[i].id ~= "host" and not playerlist[i].ping then
				ping = "---"
			elseif playerlist[i].id ~= "host" then
				ping = round(playerlist[i].ping*1000)
			end
			drawplayercard(239, (y-1)*41+3, playerlist[i].colors, playerlist[i].hats, playerlist[i].nick, ping, focus, playerlist[i].character)
			y = y + 1
		end
	end
	
	love.graphics.translate(0, missingpixels*guielements.playerscroll.value*scale)
	guielements.playerscroll:draw()
	love.graphics.setScissor()
	
	--chat
	lobby_drawchat()
end

function sendchat()
	net_sendchat(guielements.chatentry.value)
	guielements.chatentry.value = ""
	guielements.chatentry.cursorpos = 1
	guielements.chatentry.inputting = true
	guielements.chatentry.textoffset = 0
	
	if chatentrytoggle then
		chatentrytoggle = false
		love.keyboard.setKeyRepeat(false)
		guielements.chatentry.active = chatentrytoggle
		guielements.sendbutton.active = chatentrytoggle
		guielements.chatentry.inputting = chatentrytoggle
	end
end

function lobby_drawchat()
	--chat
	love.graphics.setColor(0, 0, 0, 200)
	love.graphics.rectangle("fill", 3*scale, 110*scale, 394*scale, 111*scale)
	love.graphics.setColor(255, 255, 255, 255)
	drawrectangle(4, 111, 392, 109)
	
	guielements.chatentry:draw()
	guielements.sendbutton:draw()
	
	--chat messages
	local height = 0
	for i = #chatmessages, math.max(1, #chatmessages-8), -1 do
		--find playerlist number
		local pid = 0
		for j = 1, #playerlist do
			
			if playerlist[j].id == chatmessages[i].id then
				pid = j
				break
			end
		end
		
		if pid ~= 0 then
			local nick = playerlist[pid].nick

			--[[local background = {255, 255, 255, 127}
			
			local adds = 0
			for i = 1, #playerlist[pid].colors[1] do
				adds = adds + playerlist[pid].colors[1][i]
			end
			
			if adds/3 > 40 then
				background = {0, 0, 0}
			end]]
			
			love.graphics.setColor(playerlist[pid].colors[1])
			properprintbackground(nick, 8*scale, (196-(height*10))*scale, true)
			
			love.graphics.setColor(255, 255, 255)
			properprint(":" .. chatmessages[i].message, (8+(string.len(nick))*8)*scale, (196-(height*10))*scale)
			height = height + 1
		end
	end
end
