function onlinemenu_load()
	objects = nil
	--mappack = "smb"
	
	gamestate = "onlinemenu"
	
	--maurice kept roasting me about this
	--guess that's what I get for reusing menus
	localnicks = {"mario", "luigi", "wario", "waluigi", "peach", "toad", "bowser", "chell", "mel", "p-body", "atlas", "glados", "wheatley", "cave"}
	if not localnick then
		localnick = localnicks[math.random(#localnicks)]
	end
	
	guielements = {}
	guielements.nickentry = guielement:new("input", 5, 30, 14, nil, localnick, 14, 1)
	
	guielements.configdecrease = guielement:new("button", 192, 31, "{", configdecrease, 0)
	guielements.configincrease = guielement:new("button", 214, 31, "}", configincrease, 0)
	
	
	guielements.ipentry = guielement:new("input", 6, 87, 23, joingame, "", 23, 1)
	guielements.portentry2 = guielement:new("input", 131, 145, 5, nil, "27020", 5, 1, true)
	
	guielements.portentry = guielement:new("input", 274, 87, 5, function() notice.new(TEXT["port notice"], notice.red, 12) end, "27020", 5, 1, true)
	
	guielements.magiccheckbox = guielement:new("checkbox", 220, 147, togglemagic, false, TEXT["use magicdns words"])
	
	guielements.hostbutton = guielement:new("button", 247, 199, TEXT["create game"], creategame, 2)
	guielements.hostbutton.bordercolor = {1, 0, 0}
	guielements.hostbutton.bordercolorhigh = {1, .5, .5}
	
	guielements.joinbutton = guielement:new("button", 61, 199, TEXT["join game"], joingame, 2)
	guielements.joinbutton.bordercolor = {0, 1, 0}
	guielements.joinbutton.bordercolorhigh = {.5, 1, .5}
	
	runanimationtimer = 0
	runanimationframe = 1
	runanimationdelay = 0.1
	
	playerconfig = 1
	
	usemagic = false--true
	
	magictimer = 0
	magicdelay = 0.15
	magics = {}
end

function onlinemenu_update(dt)
	runanimationtimer = runanimationtimer + dt
	while runanimationtimer > runanimationdelay do
		runanimationtimer = runanimationtimer - runanimationdelay
		runanimationframe = runanimationframe - 1
		if runanimationframe == 0 then
			runanimationframe = 3
		end
	end
	
	magictimer = magictimer + dt
	while magictimer > magicdelay do
		magictimer = magictimer - magicdelay
		if checkmagic(guielements.ipentry.value) then
			table.insert(magics, magic:new())
		end
	end
	
	local delete = {}
	
	for i, v in pairs(magics) do
		if v:update(dt) == true then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(magics, v) --remove
	end
	
	localnick = guielements.nickentry.value
end

function onlinemenu_draw()
	--TOP PART
	love.graphics.setColor(0, 0, 0, 200/255)
	love.graphics.rectangle("fill", 3*scale, 3*scale, 394*scale, 52*scale)
	love.graphics.setColor(1, 1, 1)
	
	properprintF(TEXT["online play"], 4*scale, 5*scale)
	
	properprintF(TEXT["your nick:"], 4*scale, 20*scale)
	guielements.nickentry:draw()
	
	properprintF(TEXT["use config"], 140*scale, 20*scale)
	properprintF(TEXT["config number"] .. playerconfig , 140*scale, 33*scale)
	guielements.configdecrease:draw()
	guielements.configincrease:draw()
	
	drawplayercard(240, 10, mariocolors[playerconfig], mariohats[playerconfig], localnick, nil, nil, mariocharacter[playerconfig])
	
	
	--BOTTOM PART
	
	--LEFT (JOIN)
	love.graphics.setColor(0, 0, 0, 200/255)
	love.graphics.rectangle("fill", 3*scale, 58*scale, 196*scale, 163*scale)
	
	love.graphics.setColor(1, 1, 1)
	properprintF(TEXT["join game"], 64*scale, 60*scale)
	
	properprintF(TEXT["address/magicdns"], 36*scale, 77*scale)
	guielements.ipentry:draw()
	love.graphics.setColor(150/255, 150/255, 150/255)
	properprintF(TEXT["join game instructons"], 24*scale, 107*scale)
	
	love.graphics.setColor(1, 1, 1)
	properprintF(TEXT["optional port:"], 21*scale, 148*scale)
	if guielements.portentry2.inputting then
		guielements.portentry2:draw()
	else
		properprintF(guielements.portentry2.value, 133*scale, 148*scale)
	end
	
	love.graphics.setColor(150/255, 150/255, 150/255)
	properprintF(TEXT["optional port instructions"], 24*scale, 162*scale)
	
	guielements.joinbutton:draw()
	
	--RIGHT (HOST)
	love.graphics.setColor(0, 0, 0, 200/255)
	love.graphics.rectangle("fill", 202*scale, 58*scale, 195*scale, 163*scale)
	
	love.graphics.setColor(1, 1, 1)
	properprintF(TEXT["host game"], 260*scale, 60*scale)
	properprintF(TEXT["port:"], 278*scale, 77*scale)
	
	if guielements.portentry.inputting then
		guielements.portentry:draw()
	else
		properprintF(guielements.portentry.value, 276*scale, 90*scale)
	end
	
	love.graphics.setColor(150/255, 150/255, 150/255)
	properprintF(TEXT["host game instructions"], 218*scale, 107*scale)
	
	guielements.magiccheckbox:draw()
	love.graphics.setColor(150/255, 150/255, 150/255)
	properprintF(TEXT["magicdns instructions"], 238*scale, 162*scale)
	
	guielements.hostbutton:draw()
	
	for i, v in pairs(magics) do
		v:draw()
	end
end


function drawplayercard(x, y, colortable, hattable, nick, ping, focus, character)
	if focus then
		love.graphics.setColor(.5, .5, .5, 150/255)
	else
		love.graphics.setColor(0, 0, 0, 1)
	end
	love.graphics.rectangle("fill", x*scale, y*scale, 150*scale, 38*scale)
	love.graphics.setColor(1, 1, 1, 1)
	drawrectangle(x+1, y+1, 148, 36)

	local v = characters.data[character or "mario"]
	if not v then
		v = characters.data["mario"]
	end
	if v then
		love.graphics.setColor(1, 1, 1, 1)
		for i = 0, #v.colorables do
			if i > 0 then
				love.graphics.setColor(unpack(colortable[i]))
			else
				love.graphics.setColor(1, 1, 1)
			end
			if mariocharacter[skinningplayer] then
				love.graphics.draw(v["animations"][i], v["small"]["run"][3][math.min(#v["small"]["run"],runanimationframe)], (x+4+v.smalloffsetX*2)*scale, (y+26-v.smalloffsetY*2)*scale, 0, scale*2, scale*2, v.smallquadcenterX, v.smallquadcenterY)
			end
		end
		
		--Scissors just for hat stacks
		local yadd = 0
		local addcolortohat = true

		if (type(hattable) == "table" and #hattable > 1) or hattable[1] ~= 1 then 
			addcolortohat = false
		end
		for i = 1, #hattable do
			if hat[hattable[i] ] then
				if addcolortohat then
					love.graphics.setColor(unpack(colortable[1]))
				end
				local offsets = customplayerhatoffsets(character, "hatoffsets", "running") or hatoffsets["running"]
				love.graphics.draw(hat[hattable[i] ].graphic, hat[hattable[i] ].quad[1], (x+4+v.smalloffsetX*2)*scale, (y+26-v.smalloffsetY*2)*scale, 0, scale*2, scale*2, v.smallquadcenterX - hat[hattable[i] ].x + offsets[runanimationframe][1], v.smallquadcenterY - hat[hattable[i] ].y + offsets[runanimationframe][2] + yadd)
				yadd = yadd + hat[hattable[i] ].height
			end
		end
	end

	love.graphics.setColor(1, 1, 1)
	properprintF(nick, x*scale+35*scale, y*scale+10*scale)

	if not ping then
		love.graphics.setColor(.5, .5, .5)
	end
	if not ping then
		properprintF("ping:", x*scale+35*scale, y*scale+22*scale)
		properprintF("host", x*scale+75*scale, y*scale+22*scale)
	else
		if tonumber(ping) then
			if tonumber(ping) < 40 then
				love.graphics.setColor((100+125*(tonumber(ping)/40))/255, 1, 100/255)
			elseif tonumber(ping) >= 40 and tonumber(ping) < 80 then
				love.graphics.setColor(1, (225-125*((tonumber(ping)-40)/40))/255, 100/255)
			elseif tonumber(ping) >= 80 then
				love.graphics.setColor(1, 100/255, 100/255)
			end
		else
			love.graphics.setColor(.5, .5, .5, 1)
		end
		properprintF("ping:", x*scale+35*scale, y*scale+22*scale)
		properprintF(ping .. "ms", (x+123-#(ping .. "ms")*8)*scale, y*scale+22*scale)
	end
end

function configdecrease()
	playerconfig = math.max(1, playerconfig-1)
end

function configincrease()
	playerconfig = math.min(4, playerconfig+1)
end

function togglemagic()
	usemagic = not usemagic
	guielements.magiccheckbox.var = usemagic
end

function checkmagic(s)
	if string.find(s, " ") then
		return true
	else
		return false
	end
end

function creategame()
	port = tonumber(guielements.portentry.value)
	if server_load(port) then
		lobby_load()
	else
		--menu_load()
		return
	end
	if usemagic then
		adjective, noun = magicdns_make()
	end
	
	playerlist = {}
	playerlist[1] = {connected=true, hats=mariohats[playerconfig], colors=mariocolors[playerconfig], nick=localnick, id="host", ping=0, character=mariocharacter[playerconfig]}
end

function joingame()
	local ip, port = "", tonumber(guielements.portentry2.value)
	local s = guielements.ipentry.value
	if checkmagic(s) then
		usemagic = true
		local split = s:split(" ")
		adjective, noun = split[1], split[2]
		ip, port = magicdns_find(adjective, noun)
		
		if ip == nil then
			notice.new(TEXT["INVALID MAGICDNS\nTHE HOST NEEDS TO PORT FORWARD!"], notice.red, 6 )
			return
		end
	else
		usemagic = false
		ip = guielements.ipentry.value
	end
	
	playerlist = {}
	playerlist[1] = {connected=true, hats=mariohats[playerconfig], colors=mariocolors[playerconfig], nick=localnick, id="self", ping=0, character=mariocharacter[playerconfig]}
	
	if client_load(ip, port) then
		lobby_load()
	else
		--menu_load()
	end
end

magicdns_validresponses = {"MADE", "KEPT", "REMOVED", "FOUND", "NOTFOUND", "ERROR"}

function magicdns_make()
	http.PORT = port
	s = http.request("http://dns.stabyourself.net/MAKE/" .. magicdns_identity .. "/" .. magicdns_session .. "/" .. port)
	result = (s or ""):split("/")
	magicdns_error(result)
	
	if result[1] == "MADE" then
		return string.lower(result[2]), string.lower(result[3])
	else
		notice.new("MAGICDNS MAKE FAILED HORRIBLY", notice.red, 3)
		print("MAGICDNS MAKE FAILED HORRIBLY");
		usemagic = false
		return;
	end
end

function magicdns_keep()
	s = http.request("http://dns.stabyourself.net/KEEP/"..magicdns_identity.."/"..magicdns_session)
	result = (s or ""):split("/")
	magicdns_error(result)
	if result[1] ~= "KEPT" then
		print("MAGICDNS KEEP FAILED! RETURNED: " .. (s or ""))
	elseif result[2] ~= "" then
		print("MAGICDNS EXTERNAL PORT KNOWN = " .. result[2])
	end
end

function magicdns_remove()
	s = http.request("http://dns.stabyourself.net/REMOVE/"..magicdns_identity.."/"..magicdns_session)
	result = (s or ""):split("/")
	magicdns_error(result)
	if result[1] ~= "REMOVED" then
		print("MAGICDNS REMOVE FAILED! RETURNED: " .. (s or ""))
	end
end
	
function magicdns_find(adjective, noun)
	s = http.request("http://dns.stabyourself.net/FIND/" .. magicdns_identity .. "/" .. string.upper(adjective) .. "/" .. string.upper(noun))
	
	local result = (s or ""):split("/")
	magicdns_error(result)
	if result[1] == "FOUND" then
		if result[4] == "" then
		print("MAGICDNS Server external port is not known!")
		
		notice.new("MAGICDNS Server external port is not known!", notice.red, 3)
		end		
		return result[2], result[3], result[4]
	else
		return nil
	end
end

function magicdns_error(result)
	if result[1] == "ERROR" then
		print("MAGICDNS ERROR: "..result[2])
		notice.new("MAGICDNS ERROR: "..result[2], notice.red, 3)
		return true
	elseif not tablecontains(magicdns_validresponses, result[1]) then
		print("MAGICDNS: nonstandard response: "..result[1])
		notice.new("MAGICDNS: nonstandard response: "..result[1], notice.red, 3)
		return true
	end
	return false
end
