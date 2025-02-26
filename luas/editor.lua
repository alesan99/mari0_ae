--i figured i should start using local functions despite 1.6 using like none
local undo_clear, undo_store, undo_stopstore--[[, undo_undo]]
local meta_data, promptedmetadatasave
local updatetilesscrollbar, updatelevelscrollbar
local worldscrollbarheight, levelscrollbarheight
local tilehotkeys = {
	["1"] = {t=false, entity=false},
	["2"] = {t=false, entity=false},
	["3"] = {t=false, entity=false},
	["4"] = {t=false, entity=false},
	["5"] = {t=false, entity=false},
	["6"] = {t=false, entity=false},
	["7"] = {t=false, entity=false},
	["8"] = {t=false, entity=false},
	["9"] = {t=false, entity=false},
	["0"] = {t=false, entity=false},
}
local tilehotkeysindex = {}
local tilehotkeysentityindex = {}

local editorsavedata = false

local trackgenerationid

function editor_load(player_position) --{x, y, xscroll, yscroll}
	--BLOCKTOGGLE STUFF
	solidblockperma = {false, false, false, false}
	collectables = {} --[marioworld-mariolevel-mariosublevel][x-y]
	collectableslist = {{},{},{},{},{},{},{},{},{},{}}
	collectablescount = {0,0,0,0,0,0,0,0,0,0}
	animationnumbers = {}
	autosave = false
	
	subleveltest = false
	
	--assist mode
	if assistmode == nil then
		if AutoAssistMode then
			assistmode = true
		else
			assistmode = false
		end
		latesttiles = {{1, 1}, {2, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}, {1, 1}} --{type of tile, id}
	end
	backgroundtilemode = false

	--sublevels in level
	sublevelstable = {}
	if not (mappacklevels[marioworld]) then
		print("PANIC, levels not found!")
		for k = 0, defaultsublevels do
			table.insert(sublevelstable, k)
		end
	else
		if (not mappacklevels[marioworld][mariolevel]) then
			print("PANIC, sublevels not found!")
			mappacklevels[marioworld][mariolevel] = defaultsublevels
		end

		for k = 0, mappacklevels[marioworld][mariolevel] do
			table.insert(sublevelstable, k)
		end
	end

	brushsizetoggle = false
	brushsizex = 1
	brushsizey = 1
	quickmenuopen = false
	quickmenuopeny = (height*16)-24
	quickmenuclosedy = (height*16)
	quickmenuy = quickmenuclosedy
	quickmenusel = false
	quickmenuspeed = 200

	tilehotkeysindex = {}
	tilehotkeysentityindex = {}
	for i, t in pairs(tilehotkeys) do
		if t.entity then
			tilehotkeysentityindex[t.t] = i
		else
			tilehotkeysindex[t.t] = i
		end
	end

	levelmodified = false
	
	if not currentanimation then
		currentanimation = 1
	end
	animationguilines = {}
	
	tileselection = false
	tileselectionants = 0
	tileselectionmoving = false --dragging tile selection
	if tilesoffset == nil then
		--there was a weird crash with this, idk if this fixes it
		tilesoffset = 0
	end
	
	editmtobjects = false
	mtsavehighlighttime = 5
	mtsavetimer = 0
	mtjustsaved = false
	mtsavecolors = {255, 112, 112, 128}
	pastingtiles = false
	pastemode = 1
	pastecenter = {0, 0}
	mtclipboard = {} -- fill with x, y, tile
	
	tooltipa = -1000
	
	minimapscroll = 0
	minimapx = 3
	minimapy = 30
	minimapheight = 15
	
	currenttile = 1
	
	minimapscrollspeed = 30
	minimapdragging = false
	minimapmoving = false

	tilemenuy = 0
	tilemenumoving = false
	
	allowdrag = true
	if love.mouse.isDown("l") then
		allowdrag = false
	end
	
	animationguiarea =  {12, 33, 399, 212}
	animationlineinset = 14
	
	rightclickmenuopen = false
	customrcopen = false
	
	powerlinestate = 1
	selectiontoolclick = {{false, false}, {false, false}}
	selectiontoolselection = {}
	
	guielements["tabmain"] = guielement:new("button", 1, 1, TEXT["main"], maintab, 3)
	guielements["tabmain"].fillcolor = {63, 63, 63}
	guielements["tabtiles"] = guielement:new("button", guielements["tabmain"].x+guielements["tabmain"].width+10, 1, TEXT["tiles"], tilestab, 3)
	guielements["tabtiles"].fillcolor = {63, 63, 63}
	guielements["tabtools"] = guielement:new("button", guielements["tabtiles"].x+guielements["tabtiles"].width+10, 1, TEXT["tools"], toolstab, 3)
	guielements["tabtools"].fillcolor = {63, 63, 63}
	guielements["tabmaps"] = guielement:new("button", guielements["tabtools"].x+guielements["tabtools"].width+10, 1, TEXT["maps"], mapstab, 3)
	guielements["tabmaps"].fillcolor = {63, 63, 63}
	guielements["tabcustom"] = guielement:new("button", guielements["tabmaps"].x+guielements["tabmaps"].width+10, 1, TEXT["custom"], customtab, 3)
	guielements["tabcustom"].fillcolor = {63, 63, 63}
	guielements["tabanimations"] = guielement:new("button", guielements["tabcustom"].x+guielements["tabcustom"].width+10, 1, TEXT["animations"], animationstab, 3)
	guielements["tabanimations"].fillcolor = {63, 63, 63}
	
	--MAIN
	if android then
		autoscroll = false
	end
	guielements["autoscrollcheckbox"] = guielement:new("checkbox", width*16-14-utf8.len(TEXT["follow player"])*8, 20, toggleautoscroll, autoscroll, TEXT["follow player"])
	for i = 1, #backgroundcolor do
		guielements["defaultcolor" .. i] = guielement:new("button", 17+(i-1)*12, 78, " ", defaultbackground, 0, {i})
		if i == 4 then
			guielements["defaultcolor" .. i].fillcolor = backgroundrgb
		else
			guielements["defaultcolor" .. i].fillcolor = backgroundcolor[i]
		end
	end
	--guielements["backgrounddropdown"] = guielement:new("dropdown", 17, 85, 6, changebackground, background, "blue", "black", "water", "rgb")
	guielements["backgroundinput1"] = guielement:new("input", 65, 78, 3, changebackgroundrgb, backgroundrgb[1], 3, nil, nil, 0)
	guielements["backgroundinput2"] = guielement:new("input", 93, 78, 3, changebackgroundrgb, backgroundrgb[2], 3, nil, nil, 0)
	guielements["backgroundinput3"] = guielement:new("input", 121, 78, 3, changebackgroundrgb, backgroundrgb[3], 3, nil, nil, 0)
	guielements["backgroundinput1"].numdrag = {0,255}
	guielements["backgroundinput2"].numdrag = {0,255}
	guielements["backgroundinput3"].numdrag = {0,255}
	guielements["musicdropdown"] = guielement:new("dropdown", 17, 102, 15, changemusic, musici, unpack(editormusictable))
	guielements["custommusiciinput"] = guielement:new("input", 150, 102, 2, changemusic, custommusici, 2, 1, "music", 0)
	guielements["spritesetdropdown"] = guielement:new("dropdown", 17, 126, 11, changespriteset, spriteset, "overworld", "underground", "castle", "underwater")

	guielements["timelimitdecrease"] = guielement:new("button", 17, 152, "{", decreasetimelimit, 0)
	guielements["timelimitdecrease"].autorepeat = true
	guielements["timelimitdecrease"].repeatwait = 0.3
	guielements["timelimitdecrease"].repeatdelay = 0.08
	guielements["timelimitinput"] = guielement:new("input", 29, 152, string.len(mariotimelimit), changetimelimit, tostring(mariotimelimit), 6, nil, nil, 0)
	guielements["timelimitinput"].justdisplay = true
	guielements["timelimitinput"].textoffset = 0
	guielements["timelimitinput"].inputtingfunc = changetimelimitinputting
	guielements["timelimitinput"].uninputtingfunc = changetimelimituninputting
	guielements["timelimitincrease"] = guielement:new("button", 33 + string.len(mariotimelimit)*8, 152, "}", increasetimelimit, 0)
	guielements["timelimitincrease"].autorepeat = true
	guielements["timelimitincrease"].repeatwait = 0.3
	guielements["timelimitincrease"].repeatdelay = 0.08
	
	guielements["portalgundropdown"] = guielement:new("dropdown", 17, 175, 11, changeportalgun, portalguni, "normal", "none", "1 only", "2 only", "gel")
	--guielements["portalgundropdown"].dropup = true
	guielements["widthbutton"] = guielement:new("button", 384-(utf8.len(TEXT["change size"])*8), 200, TEXT["change size"], openchangewidth, 2)
	guielements["savebutton"] = guielement:new("button", 10, 200, TEXT["save"], function() savelevel(); levelmodified = false end, 2)
	guielements["menubutton"] = guielement:new("button", guielements["savebutton"].x+guielements["savebutton"].width+12, 200, TEXT["exit"], function() openconfirmmenu("exit") end, 2)
	guielements["testbutton"] = guielement:new("button", guielements["menubutton"].x+guielements["menubutton"].width+12, 200, TEXT["test level"], test_level, 2)
	guielements["testbuttonplayer"] = guielement:new("button", guielements["testbutton"].x+guielements["testbutton"].width+12, 200, TEXT["quick test"], function() test_level(objects["player"][1].x, objects["player"][1].y) end, 2)
	guielements["savebutton"].bordercolor = {255, 0, 0}
	guielements["savebutton"].bordercolorhigh = {255, 127, 127}
	
	--guielements["levelpropertiesdropdown"] = guielement:new("dropdown", 200, 69, 20, function() end, 1, "level properties")
	guielements["levelpropertiesdropdown"] = guielement:new("button", 200, 69, TEXT["level properties      ↓"], levelpropertiestoggle, 1)
	levelpropertiesdropdown = false
	local lpx = 202
	local lpy = guielements["levelpropertiesdropdown"].y+14
	guielements["intermissioncheckbox"] = guielement:new("checkbox", lpx, lpy+10*(1-1), toggleintermission, intermission, TEXT["intermission"])
	guielements["warpzonecheckbox"] = guielement:new("checkbox", lpx, lpy+10*(2-1), togglewarpzone, haswarpzone, TEXT["warpzone text"])
	guielements["underwatercheckbox"] = guielement:new("checkbox", lpx, lpy+10*(3-1), toggleunderwater, underwater, TEXT["underwater"])
	guielements["bonusstagecheckbox"] = guielement:new("checkbox", lpx, lpy+10*(4-1), togglebonusstage, bonusstage, TEXT["bonus stage"])
	guielements["edgewrappingcheckbox"] = guielement:new("checkbox", lpx, lpy+10*(5-1), toggleedgewrapping, edgewrapping, TEXT["wrap around"])
	guielements["lightsoutcheckbox"] = guielement:new("checkbox", lpx, lpy+10*(6-1), togglelightsout, lightsout, TEXT["lights out"])
	guielements["lowgravitycheckbox"] = guielement:new("checkbox", lpx, lpy+10*(7-1), togglelowgravity, lowgravity, TEXT["low gravity"])
	
	guielements["autoscrollingcheckbox"] = guielement:new("checkbox", 200, 86, toggleautoscrolling, autoscrolling, TEXT["autoscroll"])
	guielements["autoscrollingscrollbar"] = guielement:new("scrollbar", 298, 86, 93, 35, 9, reverseautoscrollingscrollbar(), "hor")
	guielements["autoscrollingscrollbar"].scrollstep = 0

	guielements["custombackgroundcheckbox"] = guielement:new("checkbox", 200, 133, togglecustombackground, custombackground, TEXT["background"])
	guielements["customforegroundcheckbox"] = guielement:new("checkbox", 200, 166, togglecustomforeground, customforeground, TEXT["foreground"])
	guielements["scrollfactorxscrollbar"] = guielement:new("scrollbar", 298, 145, 93, 35, 9, reversescrollfactor(), "hor")
	guielements["scrollfactoryscrollbar"] = guielement:new("scrollbar", 298, 155, 93, 35, 9, reversescrollfactor(scrollfactory), "hor")
	guielements["scrollfactor2xscrollbar"] = guielement:new("scrollbar", 298, 177, 93, 35, 9, reversescrollfactor2(), "hor")
	guielements["scrollfactor2yscrollbar"] = guielement:new("scrollbar", 298, 187, 93, 35, 9, reversescrollfactor2(scrollfactor2y), "hor")
	guielements["scrollfactorxscrollbar"].scrollstep = 0
	guielements["scrollfactoryscrollbar"].scrollstep = 0
	guielements["scrollfactor2xscrollbar"].scrollstep = 0
	guielements["scrollfactor2yscrollbar"].scrollstep = 0

	guielements["backgrounddropdown"] = guielement:new("dropdown", 298, 133, 10, changecustombackground, 1, unpack(custombackgrounds))
	guielements["foregrounddropdown"] = guielement:new("dropdown", 298, 165, 10, changecustomforeground, 1, unpack(custombackgrounds))
	for i = 1, #custombackgrounds do
		if custombackground and type(custombackground) == "string" and custombackground == custombackgrounds[i] then
			guielements["backgrounddropdown"].var = i
			guielements["custombackgroundcheckbox"].var = true
		end
		if customforeground and type(customforeground) == "string" and customforeground == custombackgrounds[i] then
			guielements["foregrounddropdown"].var = i
			guielements["customforegroundcheckbox"].var = true
		end
	end

	--mapsize stuff
	guielements["maptopup"] = guielement:new("button", 0, 0, "↑", changenewmapsize, nil, {"top", "up"}, nil, 8, 0.02)
	guielements["maptopdown"] = guielement:new("button", 0, 0, "↓", changenewmapsize, nil, {"top", "down"}, nil, 8, 0.02)
	guielements["mapleftleft"] = guielement:new("button", 0, 0, "{", changenewmapsize, nil, {"left", "left"}, nil, 8, 0.02)
	guielements["mapleftright"] = guielement:new("button", 0, 0, "}", changenewmapsize, nil, {"left", "right"}, nil, 8, 0.02)
	guielements["maprightleft"] = guielement:new("button", 0, 0, "{", changenewmapsize, nil, {"right", "left"}, nil, 8, 0.02)
	guielements["maprightright"] = guielement:new("button", 0, 0, "}", changenewmapsize, nil, {"right", "right"}, nil, 8, 0.02)
	guielements["mapbottomup"] = guielement:new("button", 0, 0, "↑", changenewmapsize, nil, {"bottom", "up"}, nil, 8, 0.02)
	guielements["mapbottomdown"] = guielement:new("button", 0, 0, "↓", changenewmapsize, nil, {"bottom", "down"}, nil, 8, 0.02)
	
	guielements["mapwidthapply"] = guielement:new("button", 0, 0, TEXT["apply"], mapwidthapply, 3)
	guielements["mapwidthcancel"] = guielement:new("button", 0, 0, TEXT["cancel"], mapwidthcancel, 3)
	
	--TILES
	guielements["tilesall"] = guielement:new("button", 5, 20, TEXT["all"], tilesall, 2)
	guielements["tilessmb"] = guielement:new("button", guielements["tilesall"].x+guielements["tilesall"].width+8, 20, TEXT["smb"], tilessmb, 2)
	guielements["tilesportal"] = guielement:new("button", guielements["tilessmb"].x+guielements["tilessmb"].width+8, 20, TEXT["portal"], tilesportal, 2)
	guielements["tilescustom"] = guielement:new("button", guielements["tilesportal"].x+guielements["tilesportal"].width+8, 20, TEXT["custom"], tilescustom, 2)
	guielements["tilesanimated"] = guielement:new("button", guielements["tilescustom"].x+guielements["tilescustom"].width+8, 20, TEXT["animated"], tilesanimated, 2)
	guielements["tilesobjects"] = guielement:new("button", guielements["tilesanimated"].x+guielements["tilesanimated"].width+8, 20, TEXT["objects"], tilesobjects, 2)
	guielements["tilesentities"] = guielement:new("button", width*16-12-utf8.len(TEXT["entities"])*8, 20, TEXT["entities"], tilesentities, 2)
	
	guielements["tilesscrollbar"] = guielement:new("scrollbar", 381, 37, 167, 15, 40, 0, "ver")
	
	--TOOLS
	guielements["linkbutton"] = guielement:new("button", 5, 22, TEXT["link tool"], linkbutton, 2, false, 1, 120)
	guielements["linkbutton"].bordercolor = {0, 255, 0}
	guielements["linkbutton"].bordercolorhigh = {220, 255, 220}
	guielements["portalbutton"] = guielement:new("button", 5, 40, TEXT["portal gun"], portalbutton, 2, false, 1, 120)
	guielements["portalbutton"].bordercolor = {0, 0, 255}
	guielements["portalbutton"].bordercolorhigh = {127, 127, 255}
	guielements["selectionbutton"] = guielement:new("button", 5, 58, TEXT["selection tool"], selectionbutton, 2, false, 1, 120)
	guielements["selectionbutton"].bordercolor = {255, 106, 0}
	guielements["selectionbutton"].bordercolorhigh = {255, 206, 127}
	guielements["powerlinebutton"] = guielement:new("button", 5, 76, TEXT["power line draw"], powerlinebutton, 2, false, 1, 120)
	guielements["powerlinebutton"].bordercolor = {255, 216, 0}
	guielements["powerlinebutton"].bordercolorhigh = {255, 255, 220}
	currenttooldesc = 1 --what description should be displayed for the buttons
	
	guielements["livesdecrease"] = guielement:new("button", 294, 104, "{", livesdecrease, 0)
	guielements["livesincrease"] = guielement:new("button", 314, 104, "}", livesincrease, 0)
	
	guielements["physicsdropdown"] = guielement:new("dropdown", 294, 117, 11, changephysics, currentphysics, "mari0", "smb", "mari0-smb2j", "smb2j", "mari0-maker", "mario maker", "portal")
	guielements["cameradropdown"] = guielement:new("dropdown", 294, 130, 11, changecamerasetting, camerasetting, "default", "centered"--[[, "forward only"]])
	guielements["dropshadowcheckbox"] = guielement:new("checkbox", 294, 143, toggledropshadow, dropshadow, TEXT["drop shadow"])
	guielements["realtimecheckbox"] = guielement:new("checkbox", 294, 154, togglerealtime, realtime, TEXT["real time"])
	local _, count = TEXT["real time"]:gsub("\n", '')
	guielements["continuemusiccheckbox"] = guielement:new("checkbox", 294, guielements["realtimecheckbox"].y+11+10*count, togglecontinuemusic, continuesublevelmusic, TEXT["cont. music"])
	_, count = TEXT["cont. music"]:gsub("\n", '')
	guielements["nolowtimecheckbox"] = guielement:new("checkbox", 294, guielements["continuemusiccheckbox"].y+11+10*count, togglenolowtime, nolowtime, TEXT["no low time"])

	--MAPS
	guielements["savebutton2"] = guielement:new("button", 300, 196, TEXT["save level"], guielements["savebutton"].func, 0, nil, 2.4, 94, true)
	--guielements["autosavecheckbox"] = guielement:new("checkbox", 300, guielements["savebutton2"].y+16, function() autosave = not autosave; guielements["autosavecheckbox"].var = autosave end, autosave, TEXT["autosave"])
	guielements["savebutton2"].bordercolor = {255, 0, 0}
	guielements["savebutton2"].bordercolorhigh = {255, 127, 127}
	
	guielements["worldscrollbar"] = guielement:new("scrollbar", 90, 20, 201, 11, 75, 0, "ver")
	guielements["levelscrollbar"] = guielement:new("scrollbar", 383, 20, 173, 14, 60, oldlevelscrollbar or 0, "ver")
	oldworldscrollbarv = 0
	oldlevelscrollbarv = 0
	oldlevelscrollbar = 0
	
	levelrightclickmenu = guielement:new("rightclick", 0, 0, 6, levelrightclickmenuclick, false, "action", "copy", "paste", "delete")
	levelrightclickmenu.active = false
	
	--CUSTOM TAB
	guielements["graphicscustomtab"] = guielement:new("button", 5, 20, TEXT["graphics"], customtabtab, 2, {"graphics"})
	guielements["tilescustomtab"] = guielement:new("button", guielements["graphicscustomtab"].x+guielements["graphicscustomtab"].width+8, 20, TEXT["tiles"], customtabtab, 2, {"tiles"})
	guielements["backgroundscustomtab"] = guielement:new("button", guielements["tilescustomtab"].x+guielements["tilescustomtab"].width+8, 20, TEXT["backgrounds"], customtabtab, 2, {"backgrounds"})
	guielements["soundscustomtab"] = guielement:new("button", guielements["backgroundscustomtab"].x+guielements["backgroundscustomtab"].width+8, 20, TEXT["sounds"], customtabtab, 2, {"sounds"})
	guielements["textcustomtab"] = guielement:new("button", guielements["soundscustomtab"].x+guielements["soundscustomtab"].width+8, 20, TEXT["text"], customtabtab, 2, {"text"})
	guielements["enemiescustomtab"] = guielement:new("button", guielements["textcustomtab"].x+guielements["textcustomtab"].width+8, 20, TEXT["enemies"], customtabtab, 2, {"enemies"})
	
	customtabstate = "graphics"
	
	--custom graphics
	changecurrentimage(1, true)
	
	guielements["currentimagedropdown"] = guielement:new("dropdown", 184, 63, 22, changecurrentimage, currentcustomimage[1], unpack(imagestable))
	guielements["currentimagedropdown"].displayentries = imagestabledisplay
	--guielements["currentimagedropdown"].scrollbar.scrollstep = 0.11 --how much mousewheel scrolls
	guielements["exportimagetemplate"] = guielement:new("button", 184, 88, TEXT["export template"], exportcustomimage, 2)
	guielements["openfoldercustom"] = guielement:new("button", 184, 105, TEXT["open folder"], opencustomimagefolder, 2)
	guielements["saveimage"] = guielement:new("button", 176, 199, TEXT["update image"], savecustomimage, 2)
	guielements["saveimage"].bordercolor = {255, 0, 0}
	guielements["saveimage"].bordercolorhigh = {255, 127, 127}
	guielements["resetimage"] = guielement:new("button", guielements["saveimage"].x+guielements["saveimage"].width+8, 199, TEXT["reset"], resetcustomimage, 2)
	
	--custom tiles
	guielements["exporttilestemplate"] = guielement:new("button", 184, 63, TEXT["export template"], exportcustomimage, 2)
	guielements["exportanimatedtilestemplate"] = guielement:new("button", 184, 163, TEXT["export template"], exportcustomimage, 2, {"animated"})
	guielements["openfoldertilescustom"] = guielement:new("button", 184, 80, TEXT["open folder"], opencustomimagefolder, 2, {"tiles"})
	guielements["openfolderanimatedtilescustom"] = guielement:new("button", 184, 180, TEXT["open folder"], opencustomimagefolder, 2, {"animated"})
	
	--custom background
	changecurrentbackground(1, true)
	guielements["currentbackgrounddropdown"] = guielement:new("dropdown", 184, 63, 10, changecurrentbackground, 1, "background", "foreground")
	guielements["openfolderbackgroundscustom"] = guielement:new("button", 184, 131, TEXT["open folder"], opencustomimagefolder, 2, {"backgrounds"})
	
	--custom sounds
	changecurrentsound(1, true)
	guielements["currentsounddropdown"] = guielement:new("dropdown", 184, 63, 16, changecurrentsound, 1, unpack(soundliststring))
	--guielements["currentsounddropdown"].scrollbar.scrollstep = 0.11 --how much mousewheel scrolls
	guielements["openfoldersoundscustom"] = guielement:new("button", 184, 105, TEXT["open folder"], opencustomimagefolder, 2, {"sounds"})
	guielements["openfoldermusiccustom"] = guielement:new("button", 184, 164, TEXT["open folder"], opencustomimagefolder, 2, {"music"})
	guielements["savesounds"] = guielement:new("button", 176, 199, TEXT["update sounds"], savecustomimage, 2)
	guielements["savesounds"].bordercolor = {255, 0, 0}
	guielements["savesounds"].bordercolorhigh = {255, 127, 127}

	--custom enemies
	changecurrentenemy(1, true)
	guielements["currentenemydropdown"] = guielement:new("dropdown", 184, 63, 22, changecurrentenemy, 1, unpack(customenemies))
	if guielements["currentenemydropdown"].scrollbar then
		--guielements["currentenemydropdown"].scrollbar.scrollstep = 0.11 --how much mousewheel scrolls
	end
	guielements["openfolderenemiescustom"] = guielement:new("button", 184, 105, TEXT["open folder"], opencustomimagefolder, 2)
	
	textcolorl = endingtextcolorname
	textcolorp = hudtextcolorname
	textstate = "hud"
	
	--custom text
	guielements["savecustomtext"] = guielement:new("button", 10, 201, "save text", savecustomtext, 2)
	guielements["savecustomtext"].bordercolor = {255, 0, 0}
	guielements["savecustomtext"].bordercolorhigh = {255, 127, 127}

	guielements["hudtexttab"] = guielement:new("button", 10, 40, TEXT["hud"], texttabtab, 2, {"hud"})
	guielements["endingtexttab"] = guielement:new("button", guielements["hudtexttab"].x+guielements["hudtexttab"].width+8, 40, TEXT["ending"], texttabtab, 2, {"ending"})
	guielements["castletexttab"] = guielement:new("button", guielements["endingtexttab"].x+guielements["endingtexttab"].width+8, 40, TEXT["castle"], texttabtab, 2, {"castle"})
	guielements["levelscreentexttab"] = guielement:new("button", guielements["castletexttab"].x+guielements["castletexttab"].width+8, 40, TEXT["levelscreen"], texttabtab, 2, {"levelscreen"})
	
	guielements["editendingtext1"] = guielement:new("input", 10, 67, 32, nil, endingtext[1], 32)
	guielements["editendingtext2"] = guielement:new("input", 10, 81, 32, nil, endingtext[2], 32)
	guielements["editplayername"] = guielement:new("input", 10, 67, 12, nil, playername, 12)
	guielements["endingcolor"] = guielement:new("dropdown", 10, 97, 7, changeendingtextcolor, tablecontainsi(textcolorsnames, textcolorl), unpack(textcolorsnames))
	guielements["endingcolor"].coloredtext = true
	--guielements["endingcolor<"] = guielement:new("button", 10, 97, "{", endingtextcolorleft, 1)
	--guielements["endingcolor>"] = guielement:new("button", guielements["endingcolor<"].x+guielements["endingcolor<"].width+utf8.len(TEXT["color"])*8+7, 97, "}", endingtextcolorright, 1)
	guielements["edittoadtext1"] = guielement:new("input", 10, 67, 32, nil, toadtext[1], 32)
	guielements["edittoadtext2"] = guielement:new("input", 10, 81, 32, nil, toadtext[2], 32)
	guielements["edittoadtext3"] = guielement:new("input", 10, 95, 32, nil, toadtext[3], 32)
	guielements["editpeachtext1"] = guielement:new("input", 10, 121, 32, nil, peachtext[1], 32)
	guielements["editpeachtext2"] = guielement:new("input", 10, 135, 32, nil, peachtext[2], 32)
	guielements["editpeachtext3"] = guielement:new("input", 10, 149, 32, nil, peachtext[3], 32)
	guielements["editpeachtext4"] = guielement:new("input", 10, 163, 32, nil, peachtext[4], 32)
	guielements["editpeachtext5"] = guielement:new("input", 10, 177, 32, nil, peachtext[5], 32)
	guielements["stevecheckbox"] = guielement:new("checkbox", 10, 191, togglesteve, pressbtosteve, "steve")
	guielements["hudcolor"] = guielement:new("dropdown", 10, 83, 7, changehudtextcolor, tablecontainsi(textcolorsnames, textcolorp), unpack(textcolorsnames))
	guielements["hudcolor"].coloredtext = true
	--guielements["hudcolor<"] = guielement:new("button", 10, 83, "{", hudtextcolorleft, 1)
	--guielements["hudcolor>"] = guielement:new("button", guielements["hudcolor<"].x+guielements["hudcolor<"].width+utf8.len(TEXT["color"])*8+7, 83, "}", hudtextcolorright, 1)
	guielements["hudworldlettercheckbox"] = guielement:new("checkbox", 10, 98, togglehudworldletter, hudworldletter, TEXT["use letters for worlds over 9"])
	guielements["hudvisiblecheckbox"] = guielement:new("checkbox", 10, 109, togglehudvisible, hudvisible, TEXT["hud visible"])
	guielements["hudoutlinecheckbox"] = guielement:new("checkbox", 10, 120, togglehudoutline, hudoutline, TEXT["hud outline"])
	guielements["hudsimplecheckbox"] = guielement:new("checkbox", 10, 131, togglehudsimple, hudsimple, TEXT["simple hud"])
	guielements["editlevelscreentext"] = guielement:new("input", 10, 81, 40, nil, levelscreentext[marioworld .. "-" .. mariolevel] or "", 45)
	
	--animationS
	guielements["animationsscrollbarver"] = guielement:new("scrollbar", animationguiarea[1]-10, animationguiarea[2], animationguiarea[4]-animationguiarea[2], 10, 40, 0, "ver", nil, nil, nil, nil, true)
	guielements["animationsscrollbarhor"] = guielement:new("scrollbar", animationguiarea[1], animationguiarea[4], animationguiarea[3]-animationguiarea[1], 40, 10, 0, "hor", nil, nil, nil, nil, false)
	guielements["animationsscrollbarhor"].scrollstep = 0
	
	local args = {}
	for i, v in ipairs(animations) do
		table.insert(args, string.sub(v.name, 1, -6))
	end
	guielements["animationselectdrop"] = guielement:new("dropdown", 15, 20, 15, selectanimation, 1, unpack(args))
	guielements["animationnewbutton"] = guielement:new("button", 3, 20, "+", createnewanimation, nil)
	guielements["animationsavebutton"] = guielement:new("button", 150, 19, TEXT["save"], saveanimation, 1)
	guielements["animationdelbutton"] = guielement:new("button", guielements["animationsavebutton"].x+guielements["animationsavebutton"].width+8, 19, "x", removeanimation, 1)
	guielements["animationnameinput"] = guielement:new("input", 282, 20, 14, function() animationsaveas = guielements["animationnameinput"].value; guielements["animationnameinput"].inputting = false end, "", 20, nil, nil, 0)
	if animations[currentanimation] then
		guielements["animationnameinput"].value = string.sub(animations[currentanimation].name, 1, -6)
		guielements["animationnameinput"]:updatePos()
	end

	addanimationtriggerbutton = guielement:new("button", 0, 0, "+", addanimationtrigger, nil, nil, nil, 8)
	addanimationtriggerbutton.textcolor = {0, 200, 0}
	
	addanimationconditionbutton = guielement:new("button", 0, 0, "+", addanimationcondition, nil, nil, nil, 8)
	addanimationconditionbutton.textcolor = {0, 200, 0}
	
	addanimationactionbutton = guielement:new("button", 0, 0, "+", addanimationaction, nil, nil, nil, 8)
	addanimationactionbutton.textcolor = {0, 200, 0}
	
	--get current description and shit
	local mappackname = ""
	local mappackauthor = ""
	local mappackdescription = ""
	if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/settings.txt") then
		local data = love.filesystem.read(mappackfolder .. "/" .. mappack .. "/settings.txt")
		local split1 = data:split("\n")
		for i = 1, #split1 do
			local split2 = split1[i]:split("=")
			if split2[1] == "name" then
				mappackname = split2[2]
			elseif split2[1] == "author" then
				mappackauthor = split2[2]
			elseif split2[1] == "description" then
				mappackdescription = split2[2]
			end
		end
	end
	if love.filesystem.getInfo( mappackfolder .. "/" .. mappack .. "/icon.png" ) then
		editmappackicon = love.graphics.newImage(mappackfolder .. "/" .. mappack .. "/icon.png")
	else
		editmappackicon = nil
	end
	
	multitileobjects = {}
	multitileobjectnames = {}
	loadmtobjects()
	guielements["mtobjectrename"] = guielement:new("input", 6, 39, 30, 
	function() 
		multitileobjectnames[guielements["mtobjectrename"].i] = guielements["mtobjectrename"].value
		guielements["mtobjectrename"].active = false
		changemtname(guielements["mtobjectrename"].i)
	end, "", 30)
	
	guielements["edittitle"] = guielement:new("input", 5, 115, 17, nil, mappackname, 17)
	guielements["editauthor"] = guielement:new("input", 5, 140, 13, nil, mappackauthor, 13)
	guielements["editdescription"] = guielement:new("input", 5, 165, 17, nil, mappackdescription, 51, 3)
	guielements["savesettings"] = guielement:new("button", 5, 203, TEXT["save settings"], savesettings, 2)
	guielements["savesettings"].bordercolor = {255, 0, 0}
	guielements["savesettings"].bordercolorhigh = {255, 127, 127}
	
	confirmmenuopen = false
	confirmmenuguisave = false
	
	--MISC
	editortilemousescroll = false
	editortilemousescrolltimer = 0

	undo_clear()
	
	tilesall()
	if editorloadopen then
		editoropen()
		editorloadopen = false
	else
		editorclose()
		editorstate = "main"
		editentities = false
	end
	
	if PersistentEditorTools then
		if PersistentEditorToolsLocal and (not editorsavedata) and love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/editorsave.json") then
			local data = love.filesystem.read(mappackfolder .. "/" .. mappack .. "/editorsave.json")
			editorsavedata = JSON:decode(data)
		end
		if editorsavedata then
			local e = editorsavedata
			currenttile = e.currenttile
			editentities = e.editentities
			brushsizex = e.brushsizex
			brushsizey = e.brushsizey
			if e.editorstate then
				editorstate = e.editorstate
			end
			customtabstate = e.customtabstate
			assistmode = e.assistmode
			backgroundtilemode = e.backgroundtilemode
			
			editorsavedata = false
		end
	end
	
	if currentanimation and currentanimation ~= 1 then
		selectanimation(currentanimation, "initial")
	end

	if player_position then
		--test from position
		objects["player"][1].x = player_position[1]
		objects["player"][1].y = player_position[2]
		camerasnap(player_position[3], player_position[4])
	end
	trackgenerationid = 0
	trackpreviews = false
end

function editor_update(dt)
	----------
	--EDITOR--
	----------	
	
	--[[level modified debug
	if oldlevelmodified ~= nil then
		if oldlevelmodified ~= levelmodified and levelmodified then
			notice.new("level modified",notice.white)
		end
	end
	oldlevelmodified = levelmodified]]
	if editormenuopen == false or minimapmoving then
		--key scroll
		local speed = 30
		if love.keyboard.isDown("rshift") then
			speed = 70
		end
		if (love.keyboard.isDown("left") or (android and leftkey(1) and not autoscroll)) and ((rightclickmenuopen or (not brushsizetoggle)) and not typingintextinput) then
			autoscroll = false
			guielements["autoscrollcheckbox"].var = autoscroll
			splitxscroll[1] = splitxscroll[1] - speed*gdt
			if splitxscroll[1] < 0 then
				splitxscroll[1] = 0
			end
			generatespritebatch()
		elseif (love.keyboard.isDown("right") or (android and rightkey(1) and not autoscroll)) and ((rightclickmenuopen or (not brushsizetoggle)) and not typingintextinput) then
			autoscroll = false
			guielements["autoscrollcheckbox"].var = autoscroll
			splitxscroll[1] = splitxscroll[1] + speed*gdt
			if splitxscroll[1] > mapwidth-width then
				splitxscroll[1] = mapwidth-width
			end
			generatespritebatch()
		end
		if mapheight ~= 15 and ((rightclickmenuopen or (not brushsizetoggle)) and not typingintextinput) then
			if (love.keyboard.isDown("up") or (android and upkey(1) and not autoscroll)) then
				autoscroll = false
				guielements["autoscrollcheckbox"].var = autoscroll
				splityscroll[1] = splityscroll[1] - speed*gdt
				if splityscroll[1] < 0 then
					splityscroll[1] = 0
				end
				generatespritebatch()
			elseif (love.keyboard.isDown("down") or (android and downkey(1) and not autoscroll)) then
				autoscroll = false
				guielements["autoscrollcheckbox"].var = autoscroll
				splityscroll[1] = splityscroll[1] + speed*gdt
				if splityscroll[1] >= mapheight-height-1 then
					splityscroll[1] = mapheight-height-1
				end
				generatespritebatch()
			end
		end
	end
	if editormenuopen == false and (not minimapmoving) then
		if editorstate == "powerline" then
			local x, y = love.mouse.getPosition()
			if love.mouse.isDown("l") then
				powerlinedraw(x, y)
			elseif love.mouse.isDown("r") then
				editentities = true
				currenttile = 1
				placetile(x, y)
			end
		elseif customrcopen == "path" and allowdrag then
			--draw path (this used to be so simple, but then i added clear pipes ;( )
			local x, y = love.mouse.getPosition()
			local rcp = rightclickpath
			local ox, oy =  rcp.last[1],  rcp.last[2]
			local dir = rcp.dir
			local mtx, mty = getMouseTile(x, y+8*screenzoom*scale)
			local tx = mtx-rcp.x
			local ty = mty-rcp.y
			local changedorigin = false
			if (not rcp.pipe) and rcp.path and #rcp.path == 1 and love.mouse.isDown("l") then --change origin of snakeblock
				local length = rcp.snakelength or 3
				if (ty == 0 and (tx == 1 or tx == -length)) or ((ty == -1 or ty == 1) and (tx == 0 or tx == 1-length)) then
					rcp.path[1][1], rcp.path[1][2] = tx, ty
					if ty == 0 then
						if mtx > rcp.x then
							rcp.dir = "right"
						else
							rcp.dir = "left"
						end
					elseif ty > 0 then
						rcp.dir = "down"
					else
						rcp.dir = "up"
					end
					rcp.last[1], rcp.last[2] = tx, ty
					changedorigin = true
				end
			end
			
			if love.mouse.isDown("l") and not changedorigin then
				local coveredtiles = {}
				--fit into pipe path
				if rcp.pipe then
					if (dir == "right" or dir == "left") and ty < oy then
						ty = ty + 1
					elseif (dir == "down" or dir == "up") and tx < ox then
						tx = tx + 1
					end
					--allow going left too
					if #rcp.path == 1 and tx == ox-1 then
						dir = "left"
					end
				end
				local overlap = ((tx == ox) and (ty == oy))
				--allow dragging again
				if (not rcp.drag) and overlap then
					rcp.drag = true
				end
				if not overlap then
					local lx, ly = rcp.last[1], rcp.last[2]--last pos
					for i = #rcp.path, 1, -1 do
						--check normal overlap
						local pass = true
						if (tx == rcp.path[i][1] and ty == rcp.path[i][2]) and not (i == #rcp.path-1) then
							pass = false
						end
						--check pipe overlap
						if rcp.pipe and not (i == #rcp.path-1) then
							local cx, cy = rcp.path[i][1], rcp.path[i][2]--check x, check y
							table.insert(coveredtiles, {cx, cy})
							local dir
							if ly < cy then dir = "up"; table.insert(coveredtiles, {cx-1, cy})
							elseif lx > cx then dir = "right"; table.insert(coveredtiles, {cx, cy-1})
							elseif lx < cx then dir = "left"; table.insert(coveredtiles, {cx, cy-1})
							elseif ly > cy then dir = "down"; table.insert(coveredtiles, {cx-1, cy})
							end
							lx, ly = cx, cy
							if dir then
								if dir == "up" and ty == cy and tx == cx-1 then pass = false
								elseif dir == "right" and tx == cx and ty == cy-1 then pass = false
								elseif dir == "left" and tx == cx and ty == cy-1 then pass = false
								elseif dir == "down" and ty == cy and tx == cx-1 then pass = false
								end
							end
						end

						if not pass then
							overlap = true
							break
						end
					end
				end

				if (not overlap) and rcp.drag then
					local erase = false
					local place = false
					if tx == ox+1 and ty == oy then
						if dir == "left" then
							erase = true
						else
							--no overlapping turns
							local pass = true
							if rcp.pipe and dir == "down" and rcp.path[#rcp.path-2] and rcp.path[#rcp.path][1] ~= rcp.path[#rcp.path-2][1] then
								pass = false
							end
							if pass then
								rcp.dir = "right"
								place = true
							end
						end
					elseif tx == ox-1 and ty == oy then
						if dir == "right" then
							erase = true
						else
							--no overlapping turns
							local pass = true
							if rcp.pipe and dir == "down" and rcp.path[#rcp.path-2] and rcp.path[#rcp.path][1] ~= rcp.path[#rcp.path-2][1] then
								pass = false
							end
							if pass then
								rcp.dir = "left"
								place = true
							end
						end
					elseif tx == ox and ty == oy+1 then
						if dir == "up" then
							erase = true
						else
							--no overlapping turns
							local pass = true
							if rcp.pipe and dir == "right" and rcp.path[#rcp.path-2] and rcp.path[#rcp.path][2] ~= rcp.path[#rcp.path-2][2] then
								pass = false
							end
							if pass then
								rcp.dir = "down"
								place = true
							end
						end
					elseif tx == ox and ty == oy-1 then
						if dir == "down" then
							erase = true
						else
							--no overlapping turns
							local pass = true
							if rcp.pipe and dir == "right" and rcp.path[#rcp.path-2] and rcp.path[#rcp.path][2] ~= rcp.path[#rcp.path-2][2] then
								pass = false
							end
							if pass then
								rcp.dir = "up"
								place = true
							end
						end
					end
					if place then
						if rcp.pipe then 
							local turn = (dir ~= rcp.dir)
							--add additional segment for turning pipe
							local pass = true
							for i, t in pairs(coveredtiles) do
								if tx == t[1] and ty == t[2] then pass = false
								elseif turn and rcp.dir == "up" and tx == t[1] and ty-1 == t[2] then pass = false
								elseif turn and rcp.dir == "left" and tx-1 == t[1] and ty == t[2] then pass = false
								elseif (rcp.dir == "up" or rcp.dir == "down") and tx-1 == t[1] and ty == t[2] then pass = false
								elseif (rcp.dir == "left" or rcp.dir == "right") and tx == t[1] and ty-1 == t[2] then pass = false
								end
							end
							if pass then
								table.insert(rcp.path, {tx, ty})
								if turn then
									if rcp.dir == "up" then
										table.insert(rcp.path, {tx, ty-1})
										rcp.drag = false
									elseif rcp.dir == "left" then
										table.insert(rcp.path, {tx-1, ty})
										rcp.drag = false
									end
								end
								rcp.last = {rcp.path[#rcp.path][1], rcp.path[#rcp.path][2]}
							else
								rcp.dir = dir
							end
						else
							table.insert(rcp.path, {tx, ty})
							rcp.last = {rcp.path[#rcp.path][1], rcp.path[#rcp.path][2]}
						end
					elseif erase and #rcp.path > 1 then
						table.remove(rcp.path, #rcp.path)
						--remove additional segment for turning pipe
						if rcp.pipe and (dir == "left" or dir == "up") and rcp.path[#rcp.path-1] and rcp.path[#rcp.path-2] then
							if not ((tx == rcp.path[#rcp.path-2][1]) or (ty == rcp.path[#rcp.path-2][2])) then
								tx, ty = rcp.path[#rcp.path-1][1], rcp.path[#rcp.path-1][2]
								table.remove(rcp.path, #rcp.path)
								rcp.drag = false
							end
						end
						rcp.last = {rcp.path[#rcp.path][1], rcp.path[#rcp.path][2]}
						rcp.dir = "right"
						if #rcp.path > 1 then
							local lx, ly = rcp.path[#rcp.path-1][1], rcp.path[#rcp.path-1][2]
							if lx > tx then
								rcp.dir = "left"
							elseif ly < ty then
								rcp.dir = "down"
							elseif ly > ty then
								rcp.dir = "up"
							end
						end
					end
				end
			end
		elseif customrcopen == "trackpath" and allowdrag then
			--draw track
			local x, y = love.mouse.getPosition()
			if love.mouse.isDown("l") then
				local rcp = rightclicktrack
				local ox, oy =  rcp.last[1],  rcp.last[2]
				local dir = rcp.dir
				local tx, ty = getMouseTile(x, y+8*screenzoom*scale)
				tx = tx-rcp.x
				ty = ty-rcp.y
				local overlap = ((tx == ox) and (ty == oy))
				--allow dragging again
				if (not rcp.drag) and overlap then
					rcp.drag = true
				end
				local looped, looping = false, false
				if #rcp.path > 3 and rcp.path[1][3] ~= "c" and rcp.path[1][3] ~= "o" then
					looped = true
					overlap = false
				end
				if #rcp.path > 3 and rcp.path[1][1] == tx and rcp.path[1][2] == ty then
					looping = true
				end
				if not overlap then
					for i = #rcp.path, 1, -1 do
						--check overlap
						if (tx == rcp.path[i][1] and ty == rcp.path[i][2]) and i ~= #rcp.path-1 and (#rcp.path <= 3 or i ~= 1) and not (looped and i == #rcp.path) then
							overlap = true
							break
						end
					end
				end
				if (not overlap) and rcp.drag and (not (looping and looped)) then
					local erase = false
					local place = false
					if rcp.path[#rcp.path-1] and (tx == rcp.path[#rcp.path-1][1] and ty == rcp.path[#rcp.path-1][2]) then
						erase = true
					elseif looped and tx == rcp.path[#rcp.path][1] and ty == rcp.path[#rcp.path][2] then
						erase = true
					end
					if (not erase) and (not looped) then
						if tx == ox+1 and ty == oy then
							rcp.dir = "r"
							place = true
						elseif tx == ox-1 and ty == oy then
							rcp.dir = "l"
							place = true
						elseif tx == ox and ty == oy+1 then
							rcp.dir = "d"
							place = true
						elseif tx == ox-1 and ty == oy-1 then
							rcp.dir = "lu"
							place = true
						elseif tx == ox+1 and ty == oy-1 then
							rcp.dir = "ru"
							place = true
						elseif tx == ox-1 and ty == oy+1 then
							rcp.dir = "ld"
							place = true
						elseif tx == ox+1 and ty == oy+1 then
							rcp.dir = "rd"
							place = true
						elseif tx == ox and ty == oy-1 then
							rcp.dir = "u"
							place = true
						end
					end
					if place then
						if looping then
							--make loop
							rcp.path[1][3] = oppositetrackdirection(rcp.dir)
							rcp.path[#rcp.path][4] = rcp.dir
						else
							local openorclosed = rcp.path[#rcp.path][4]
							rcp.path[#rcp.path][4] = rcp.dir
							table.insert(rcp.path, {tx, ty, oppositetrackdirection(rcp.dir), openorclosed, "d"})
						end
					elseif erase and #rcp.path > 1 then
						if looped then
							--remove loop
							rcp.path[#rcp.path][4] = "c"
							rcp.path[1][3] = "c"
						else
							local openorclosed = rcp.path[#rcp.path][4]
							table.remove(rcp.path, #rcp.path)
							rcp.path[#rcp.path][4] = openorclosed
						end
					end
					if place or erase then
						rcp.last = {rcp.path[#rcp.path][1], rcp.path[#rcp.path][2], rcp.path[#rcp.path][3], rcp.path[#rcp.path][4], rcp.path[#rcp.path][5]}
					end
				end
			end
		end

		if not android then
			if love.keyboard.isDown("lshift") then
				brushsizetoggle = true
			else
				brushsizetoggle = false
			end
		end
		if love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl") or love.keyboard.isDown("rgui") or love.keyboard.isDown("lgui") then
			ctrlpressed = true
		else
			ctrlpressed = false
		end
		
		if rightclickmenuopen and customrcopen then
			if rightclickobjects then
				for i = 1, #rightclickobjects do
					local obj = rightclickobjects[i]
					obj:update(dt)
				end
			end
		end
		
		if editorstate == "linktool" or editorstate == "portalgun" or editorstate == "selectiontool" or editorstate == "powerline" then
			return
		end
		
		tileselectionants = (tileselectionants + 8*dt)%16
		if love.mouse.isDown("l") and allowdrag and customrcopen == false and not (assistmode and quickmenuopen) then
			local x, y = love.mouse.getPosition()
			if tileselection then
				if not tileselection.finished then
					--increase tileselection
					local tx, ty = getMouseTile(x, y+8*screenzoom*scale)
					tileselection[3] = tx
					tileselection[4] = ty
				end
				
			elseif pastingtiles then
				--PASTE TILES
				for i, v in pairs(mtclipboard) do
					for j, w in pairs(v) do
						if w[1] == 1 and (not w[2]) and (not w["back"]) and pastemode == 1 then
							-- nothing
						else
							local tx, ty = getMouseTile(x+(i-1 + pastecenter[1])*16*scale, y+(j-1 + pastecenter[2])*16*scale+8*scale)
							if ismaptile(tx, ty) then
								local d = mtclipboard[i][j]
								currenttile = d[1]
								--[[placetile(x+(i-1 + pastecenter[1])*16*scale, y+(j-1 + pastecenter[2])*16*scale)
								local tile1 = d[1]
								if tile1 == 1 then
									tile1 = false --don't paste empty space
								end
								if not backgroundtilemode then
									if not d[3] then
										map[tx][ty][1] = tile1 or map[tx][ty][1]
										map[tx][ty][2] = d[2] or map[tx][ty][2]
										map[tx][ty]["back"] = d["back"]
									else
										map[tx][ty] = {tile1 or map[tx][ty][1], d[2] or map[tx][ty][2], d[3] or map[tx][ty][3], back=d["back"]}
									end
								end
								map[tx][ty]["gels"] = {}]]
							end
						end
					end
				end
				allowdrag = false
			elseif (brushsizex > 1 or brushsizey > 1) and not pastingtiles then
				for lx = 1, brushsizex do
					for ly = 1, brushsizey do
						placetile(x+((lx-1)*16*scale), y+((ly-1)*16*scale))
					end
				end
			elseif not pastingtiles then
				placetile(x, y)
			end
		end
	elseif editorstate == "main" then
		if love.mouse.isDown("l") and not changemapwidthmenu and not minimapmoving then
			local mousex, mousey = love.mouse.getPosition()
			if mousey >= minimapy*scale and mousey < (minimapy+34)*scale then
				if mousex >= minimapx*scale and mousex < (minimapx+394)*scale then
					--HORIZONTAL
					if mousex < (minimapx+width)*scale then
						if minimapscroll > 0 then
							minimapscroll = minimapscroll - minimapscrollspeed*dt
							if minimapscroll < 0 then
								minimapscroll = 0
							end
						end
					elseif mousex >= (minimapx+394-width)*scale then
						if minimapscroll < mapwidth-width-170 then
							minimapscroll = minimapscroll + minimapscrollspeed*dt
							if minimapscroll > mapwidth-width-170 then
								minimapscroll = mapwidth-width-170
							end
						end
					end
					
					--VERTICAL
					if mousey < (minimapy+5)*scale then
						if yscroll > 0 then
							yscroll = yscroll - minimapscrollspeed*dt
							if yscroll < 0 then
								yscroll = 0
							end
							splityscroll[1] = yscroll
						end
					elseif mousey >= (minimapy+minimapheight*2+4-5)*scale then
						if yscroll < mapheight-height then
							yscroll = yscroll + minimapscrollspeed*dt
							if yscroll > mapheight-height-1 then
								yscroll = mapheight-height-1
							end
							splityscroll[1] = yscroll
						end
					end
				
					splitxscroll[1] = (mousex/scale-3-width) / 2 + minimapscroll
					
					if splitxscroll[1] < minimapscroll then
						splitxscroll[1] = minimapscroll
					end
					if splitxscroll[1] > 170 + minimapscroll then
						splitxscroll[1] = 170 + minimapscroll
					end
					if splitxscroll[1] > mapwidth-width then
						splitxscroll[1] = mapwidth-width
					end
	
					--SPRITEBATCH UPDATE
					if math.floor(splitxscroll[1]) ~= spritebatchX[1] or math.floor(splityscroll[1]) ~= spritebatchY[1] then
						generatespritebatch()
						spritebatchX[1] = math.floor(splitxscroll[1])
						spritebatchY[1] = math.floor(splityscroll[1])
					end
				end
			elseif minimapdragging and mousey >= (height-8)*16*scale then --full minimap
				minimapdragging = false
				minimapmoving = true
				nothingtab()
			end
			
			--mapwidth repeat
			if guirepeattimer > 0 then
				guirepeattimer = guirepeattimer - dt
			else
			end
		end
		updatescrollfactor()
	elseif editorstate == "tiles" then
		local x, y = love.mouse.getPosition()
		tilesoffset = (guielements["tilesscrollbar"].value or 0) * (tilescrollbarheight or 1) * scale
		if (editentities and not editenemies) and not DisableToolTips then
			local t, list = getentitylistpos(x, y)
			local tile
			if t and list then
				tile = entitiesform[list][t]
			end
			if tile ~= prevtile then
				if tile and (tooltipimages[tile] or type(tile) == "string") then
					entitytooltipobject = entitytooltip:new(tile)
				end
			end
			
			if tile and (tooltipimages[tile] or type(tile) == "string") then
				entitytooltipobject:update(dt)
				tooltipa = math.min(255, tooltipa + dt*4000)
			else
				tooltipa = math.max(-2000, tooltipa - dt*4000)
			end

			prevtile = tile
		end

		if y > tilemenuy+height*16-32 and y > tilemenuy+height*16 then
			tilemenumoving = true
		end

		--tile stamp selection on android
		if android and tilestampholdtimer then
			tilestampholdtimer = tilestampholdtimer + dt
			if tilestampholdtimer > 0.8 then
				if math.abs(x-tilestampholdx) < 5*scale and math.abs(y-tilestampholdy) < 5*scale then
					editor_mousepressed(tilestampholdx,tilestampholdy,"l")
					love.system.vibrate(0.1)
				end
				tilestampholdtimer = false
			end
		end
	elseif editorstate == "tools" then
		--update description for the button that is being hovered
		if guielements["linkbutton"]:inhighlight(love.mouse.getPosition()) then
			currenttooldesc = 1
		elseif guielements["portalbutton"]:inhighlight(love.mouse.getPosition()) then
			currenttooldesc = 2
		elseif guielements["selectionbutton"]:inhighlight(love.mouse.getPosition()) then
			currenttooldesc = 3
		elseif guielements["powerlinebutton"]:inhighlight(love.mouse.getPosition()) then
			currenttooldesc = 4
		end
	elseif editorstate == "maps" then
		--map button scroll
		local v = worldscrollbarheight*guielements["worldscrollbar"].value
		
		if v ~= oldworldscrollbarv then
			for i = 1, #mappacklevels do --world
				guielements["world-" .. i].y = math.floor(20+((i-1)*16)-v)
			end
			guielements["newworld"].y = math.floor(20+((#mappacklevels)*16)-v)
		end
		
		oldworldscrollbarv = v
		--level button scroll
		v = levelscrollbarheight*guielements["levelscrollbar"].value
		if v ~= oldlevelscrollbarv then
			for j = 1, #mappacklevels[currentworldselection] do --level
				for k = 0, mappacklevels[currentworldselection][j] do --sublevel
					local name = currentworldselection .. "-" .. j .. "_" .. k
					if k < 1 then
						guielements[name].y = math.floor(20+((j-1)*39)-v)
					else
						guielements[name].y = math.floor(41+((j-1)*39)-v)
					end
				end
				guielements["newsublevel-" .. currentworldselection .. "-" .. j].y = math.floor(41+((j-1)*39)-v)
			end
			guielements["newlevel-" .. currentworldselection].y = math.floor(20+((#mappacklevels[currentworldselection])*39)-v)
		end
		oldlevelscrollbarv = v
		oldlevelscrollbar = guielements["levelscrollbar"].value
		
		--scrollbar priority
		local x, y = love.mouse.getPosition()
		if x > 103*scale then
			guielements["levelscrollbar"].scrollstepdisabled = false
			guielements["worldscrollbar"].scrollstepdisabled = true
		else
			guielements["levelscrollbar"].scrollstepdisabled = true
			guielements["worldscrollbar"].scrollstepdisabled = false
		end
	elseif editorstate == "custom" then
		if customtabstate == "enemies" then
			if currentcustomenemy then
				local en = enemiesdata[currentcustomenemy[2]]
				if en then
					if en.animationtype == "mirror" then
						currentcustomenemy.timer = currentcustomenemy.timer + dt
						while currentcustomenemy.timer > en.animationspeed do
							currentcustomenemy.timer = currentcustomenemy.timer - en.animationspeed
							if currentcustomenemy.animationdirection == "left" then
								currentcustomenemy.animationdirection = "right"
							else
								currentcustomenemy.animationdirection = "left"
							end
						end
					elseif en.animationtype == "frames" then
						currentcustomenemy.timer = currentcustomenemy.timer + dt
						if type(en.animationspeed) == "table" then
							while currentcustomenemy.timer > en.animationspeed[currentcustomenemy.timerstage] do
								currentcustomenemy.timer = currentcustomenemy.timer - en.animationspeed[currentcustomenemy.timerstage]
								currentcustomenemy.quadi = currentcustomenemy.quadi + 1
								if currentcustomenemy.quadi > en.animationstart + en.animationframes - 1 then
									currentcustomenemy.quadi = currentcustomenemy.quadi - en.animationframes
								end
								currentcustomenemy.timerstage = currentcustomenemy.timerstage + 1
								if currentcustomenemy.timerstage > #en.animationspeed then
									currentcustomenemy.timerstage = 1
								end
							end
						else
							while currentcustomenemy.timer > en.animationspeed do
								currentcustomenemy.timer = currentcustomenemy.timer - en.animationspeed
								currentcustomenemy.quadi = currentcustomenemy.quadi + 1
								if currentcustomenemy.quadi > en.animationstart + en.animationframes - 1 then
									currentcustomenemy.quadi = currentcustomenemy.quadi - en.animationframes
								end
							end
						end
					end
				end
			end
		end
	end
	if musici == 7 and editorstate == "main" and guielements["custommusiciinput"].active == false then
		guielements["custommusiciinput"].active = true
	elseif guielements["custommusiciinput"].active == true then
		guielements["custommusiciinput"].active = false
	end
	if editortilemousescroll then
		editortilemousescrolltimer = editortilemousescrolltimer + dt
		if editortilemousescrolltimer > .4 then
			editortilemousescroll = false
			editortilemousescrolltimer = 0
		end
	end
	
	if assistmode and not editormenuopen then --quick menu
		local x, y = love.mouse.getX()/scale, love.mouse.getY()/scale
		
		if ((x > ((width*8)-30) and y > (quickmenuy-7) and x < ((width*8)+30) and y < (quickmenuy+7)) or
			(x > (width*8)-((#latesttiles*24)/2) and y > (quickmenuy) and x < (width*8)+((#latesttiles*24)/2) and y < (quickmenuy)+24)) and not (quickmenuy == quickmenuclosedy and love.mouse.isDown("l")) then
			quickmenuy = math.max(quickmenuy-quickmenuspeed*dt, quickmenuopeny)
			quickmenuopen = true
		else
			quickmenuopen = false
			quickmenuy = math.min(quickmenuy+quickmenuspeed*dt, quickmenuclosedy)
		end
		
		if quickmenuopen then
			quickmenusel = false
			local checkx = (width*8)-((#latesttiles*24)/2)
			local val = math.ceil((x-checkx)/24)
			if val > 0 and val <= #latesttiles then
				quickmenusel = val
			end
			--[[for i = 1, #latesttiles do
				local checkx = (((width*8)-((#latesttiles*24)/2))+(24*(i-1))+2)
				if x > checkx and y > quickmenuy+2 and x < checkx+20 and y < quickmenuy+22 then
					quickmenusel = i
					break
				end
			end]]
		end
	end
	
	if animationguilines then
		for i, v in pairs(animationguilines) do
			for k, w in pairs(v) do
				w:update(dt)
			end
		end
	end
end

function editor_draw()
	love.graphics.setColor(255, 255, 255)
	
	local mousex, mousey = love.mouse.getPosition()
	
	--EDITOR
	if not editormenuopen then
		if customrcopen and customrcopen == "trackpath" then
			love.graphics.setColor(255, 255, 255, 200)
			properprintF(TEXT["erase: click previous track\nchange ends: right click\nchange grabbing: right click"], 1*scale, (height*16-3*10)*scale)
		elseif tileselection and tileselection.finished then
			love.graphics.setColor(255, 255, 255, 200)
			properprintF(TEXT["move:left click\ncopy:ctrl+c\npaste:ctrl+v\ncut:ctrl+x\ndelete:backspace/delete\nsave as object:ctrl+s"], 1*scale, (height*16-6*10)*scale)
		elseif ctrlpressed and not love.mouse.isDown("l") then
			love.graphics.setColor(255, 255, 255, 200)
			properprintF(TEXT["undo:ctrl+z\ntile selection:left click\nentity selection:ctrl+e\nselect entire map:ctrl+a"], 1*scale, (height*16-4*10)*scale)
		elseif backgroundtilemode or assistmode or editorstate == "linktool" or editorstate == "portalgun" or editorstate == "selectiontool" or editorstate == "powerline" then
			local s
			if backgroundtilemode then
				s = TEXT["background layer"]
			elseif assistmode then
				s = TEXT["assist mode"]
			elseif editorstate == "linktool" then
				s = TEXT["link tool"]
			elseif editorstate == "portalgun" then
				s = TEXT["portal gun"]
			elseif editorstate == "selectiontool" then
				s = TEXT["selection tool"]
			elseif editorstate == "powerline" then
				s = TEXT["power line draw"]
			end
			love.graphics.setColor(0, 0, 0, 120)
			properprintF(s, 3*scale, 211*scale)
			love.graphics.setColor(255, 255, 255, 180)
			properprintF(s, 2*scale, 210*scale)
			love.graphics.setColor(255, 255, 255, 255)
		end
		
		--links!
		if editorstate == "linktool" then
			love.graphics.setLineStyle("rough")
			
			love.graphics.setLineWidth(scale)
			
			local cox, coy = getMouseTile(mousex, mousey+8*screenzoom*scale)
			
			local table1 = {}
			for i, v in pairs(outputsi) do
				table.insert(table1, v)
			end
			for i, v in pairs(inputsi) do
				table.insert(table1, v)
			end
			
			for x = math.floor(splitxscroll[1]), math.floor(splitxscroll[1])+width+1 do
				for y = math.floor(splityscroll[1]), math.floor(splityscroll[1])+height+1 do
					for i, v in pairs(table1) do
						if inmap(x, y) and #map[x][y] > 1 and map[x][y][2] == v then							
							local r = map[x][y]
							local drawline = false
							local printlabels = false
							
							if (rightclickmenuopen and x == rightclickmenucox and y == rightclickmenucoy) then
								love.graphics.setColor(0, 255, 0, 150)
							elseif (cox == x and coy == y and (not love.mouse.isDown("l"))) then
								love.graphics.setColor(0, 255, 0, 255)
								if tablecontains(r, "link")  then
									drawline = true
									printlabels = true
								end
							elseif tablecontains(r, "link") then
								love.graphics.setColor(150, 255, 150, 100)
								drawline = true
							elseif tablecontains(outputsi, map[x][y][2]) and cox == x and coy == y and linktoolX and love.mouse.isDown("l") then
								love.graphics.setColor(255, 255, 0, 255)
							elseif tablecontains(outputsi, map[x][y][2]) then
								love.graphics.setColor(255, 255, 150, 150)
							elseif cox == x and coy == y and not love.mouse.isDown("l") then
								love.graphics.setColor(255, 0, 0, 255)
							else
								love.graphics.setColor(255, 150, 150, 150)
							end
							love.graphics.rectangle("fill", math.floor((x-splitxscroll[1]-1)*16*scale), ((y-splityscroll[1]-1)*16-8)*scale, 16*scale, 16*scale)
							
							if drawline then
								local tx, ty = x, y
								local x1, y1 = (tx-.5-xscroll)*16*scale, (ty-1-yscroll)*16*scale
								local x2, y2
								local drawtable = {}
						
								for i = 1, #map[tx][ty] do
									if map[tx][ty][i] == "link" then
										if map[tx][ty][i+1] and tonumber(map[tx][ty][i+1]) and map[tx][ty][i+2] and tonumber(map[tx][ty][i+2]) then
											local next1, next2 = tonumber(map[tx][ty][i+1]), tonumber(map[tx][ty][i+2])
											x2, y2 = math.floor((next1-xscroll-.5)*16*scale), math.floor((next2-yscroll-1)*16*scale)
											
											local t = map[tx][ty][i]
											if map[tx][ty][i+3] then
												t = map[tx][ty][i+3]
											end
											table.insert(drawtable, {x1, y1, x2, y2, t})
										end
									end
								end
								
								table.sort(drawtable, function(a,b) return math.abs(a[3]-a[1])>math.abs(b[3]-b[1]) end)
								
								for i = 1, #drawtable do
									local x1, y1, x2, y2, t = unpack(drawtable[i])
									love.graphics.setColor(127, 127, 255*(i/#drawtable), 255)
									
									love.graphics.line(x1, y1, x2, y2)
									
									if printlabels then
										properprintFbackground(t, math.floor(x2-string.len(t)*4*scale), y2+10*scale)
									end
								end
							end
						end
					end
				end
			end
			love.graphics.setLineStyle("smooth")
		end
		if rightclickmenuopen then
			if customrcopen then
				--custom right-click menus
				if customrcopen == "seesaw" then --draw seesaw
					local t = rightclickvalues2--seesawtype[rightclickvalues2[1]]
					if t[1] then
						local platwidth = math.floor((rightclickobjects[8].value*9+1)*2)/2
						local x, y = rightclickmenucox, rightclickmenucoy
						love.graphics.setColor(255, 255, 255, 200)
						love.graphics.draw(seesawimg, seesawquad[spriteset][1], math.floor((x-1-xscroll)*16*scale), (y-1.5-yscroll)*16*scale, 0, scale, scale)
						love.graphics.draw(seesawimg, seesawquad[spriteset][2], math.floor((x-1+t[1]-xscroll)*16*scale), (y-1.5-yscroll)*16*scale, 0, scale, scale)
						for i = 1, t[1]-1 do
							love.graphics.draw(seesawimg, seesawquad[spriteset][4], math.floor((x-1+i-xscroll)*16*scale), (y-1.5-yscroll)*16*scale, 0, scale, scale)
						end
						for i = 1, t[2]-1 do
							love.graphics.draw(seesawimg, seesawquad[spriteset][3], math.floor((x-1-xscroll)*16*scale), (y+i-1.5-yscroll)*16*scale, 0, scale, scale)
						end
						for i = 1, t[3]-1 do
							love.graphics.draw(seesawimg, seesawquad[spriteset][3], math.floor((x+t[1]-1-xscroll)*16*scale), (y+i-1.5-yscroll)*16*scale, 0, scale, scale)
						end
						for i = 1, platwidth do
							local q = 2
							if i == 1 then
								q = 1
							elseif i == platwidth then
								q = 3
							end
							love.graphics.draw(platformimg, platformquad[q], math.floor((x-(platwidth/2)+i-1.5-xscroll)*16*scale), math.floor((y+t[2]-yscroll-25/16)*16*scale), 0, scale, scale)
							love.graphics.draw(platformimg, platformquad[q], math.floor((x-(platwidth/2)+t[1]+i-1.5-xscroll)*16*scale), math.floor((y+t[3]-yscroll-25/16)*16*scale), 0, scale, scale)
						end
						if math.ceil(platwidth) ~= platwidth then
							love.graphics.draw(platformimg, platformquad[3], math.floor((x-(platwidth/2)+platwidth-1.5-xscroll)*16*scale), math.floor((y+t[2]-yscroll-25/16)*16*scale), 0, scale, scale)
							love.graphics.draw(platformimg, platformquad[3], math.floor((x-(platwidth/2)+t[1]+platwidth-1.5-xscroll)*16*scale), math.floor((y+t[3]-yscroll-25/16)*16*scale), 0, scale, scale)
						end
					end
				elseif customrcopen == "platformup" or customrcopen == "platformright" or customrcopen == "platform" or customrcopen == "platformfall" then
					local t = rightclickvalues2
					if t[1] then
						local platwidth = math.floor((rightclickobjects[2].value*9+1)*2)/2
						local dx, dy = 0, 0
						if customrcopen ~= "platformfall" then
							dx = round(rightclickobjects[4].value*(rightclickobjects[4].rcrange[2]-rightclickobjects[4].rcrange[1])+rightclickobjects[4].rcrange[1], 4)
							dy = round(rightclickobjects[6].value*(rightclickobjects[6].rcrange[2]-rightclickobjects[6].rcrange[1])+rightclickobjects[6].rcrange[1], 4)
						end
						local x, y = rightclickmenucox, rightclickmenucoy
						local offx, offy = 0, 0
						if platwidth ~= math.floor(platwidth) then --or customrcopen == "platform" then
							offx = -platwidth/2+0.5
						end
						if customrcopen == "platformup" then
							offy = -8/16
						elseif (customrcopen == "platformright" and dy ~= 0) then
							offy = -15/16
						end
						
						for i = 1, platwidth do
							local q = 2
							if i == 1 then
								q = 1
							elseif i == platwidth then
								q = 3
							end
							love.graphics.setColor(255,255,255,255)
							love.graphics.draw(platformimg, platformquad[q], math.floor((x+i-2-xscroll+offx)*16*scale), math.floor((y-yscroll-23/16+offy)*16*scale), 0, scale, scale)
							love.graphics.setColor(255,255,255,100)
							love.graphics.draw(platformimg, platformquad[q], math.floor((x+dx+i-2-xscroll+offx)*16*scale), math.floor((y+dy-yscroll-23/16+offy)*16*scale), 0, scale, scale)
						end
						if math.ceil(platwidth) ~= platwidth then
							love.graphics.setColor(255,255,255,255)
							love.graphics.draw(platformimg, platformquad[3], math.floor((x+platwidth-2-xscroll+offx)*16*scale), math.floor((y-yscroll-23/16+offy)*16*scale), 0, scale, scale)
							love.graphics.setColor(255,255,255,100)
							love.graphics.draw(platformimg, platformquad[3], math.floor((x+dx+platwidth-2-xscroll+offx)*16*scale), math.floor((y+dy-yscroll-23/16+offy)*16*scale), 0, scale, scale)
						end
					end
				elseif customrcopen == "platformspawnerup" or customrcopen == "platformspawnerdown" then
					local t = rightclickvalues2
					if t[1] then
						local platwidth = math.floor((rightclickobjects[5].value*9+1)*2)/2
						local dx, dy = 0, 0
						local x, y = rightclickmenucox, rightclickmenucoy
						local offx, offy = 0, -0.5
						if platwidth ~= math.floor(platwidth) then
							offx = -platwidth/2+0.5
						end

						local transparent = false
						while (t[4] == "down" and y+offy < mapheight+0.5) or (t[4] == "up" and y+offy > 0) do
							love.graphics.setColor(255,255,255,255)
							if transparent then
								love.graphics.setColor(255, 255, 255, 100)
							end
							for i = 1, platwidth do
								local q = 2
								if i == 1 then
									q = 1
								elseif i == platwidth then
									q = 3
								end
								love.graphics.draw(platformimg, platformquad[q], math.floor((x+i-2-xscroll+offx)*16*scale), math.floor((y-yscroll-23/16+offy)*16*scale), 0, scale, scale)
							end
							if math.ceil(platwidth) ~= platwidth then
								love.graphics.draw(platformimg, platformquad[3], math.floor((x+platwidth-2-xscroll+offx)*16*scale), math.floor((y-yscroll-23/16+offy)*16*scale), 0, scale, scale)
							end

							if t[4] == "down" then
								offy = offy + ((rightclickobjects[9].value*9+1) * (((rightclickobjects[7].value*19.5)/2)+0.5))
							elseif t[4] == "up" then
								offy = offy - ((rightclickobjects[9].value*9+1) * (((rightclickobjects[7].value*19.5)/2)+0.5))
							end
							if not transparent then
								transparent = true
							end
						end
					end
				elseif customrcopen == "belt" or customrcopen == "beltswitch" then
					drawbelt(rightclickmenucox, rightclickmenucoy, rightclickvalues2[2], customrcopen, rightclickvalues2[3] or false)
				elseif customrcopen == "redseesaw" then
					redseesaweditordraw(rightclickmenucox-1, rightclickmenucoy-1, tonumber(rightclickvalues2[1]) or 1)
				elseif customrcopen == "bowser" then
					local x, y = rightclickmenucox, rightclickmenucoy
					local ox = 4
					local qi = 1
					if rightclickvalues2[1] == 2 then
						ox = -1
						qi = 2
					end
					love.graphics.setColor(255, 255, 255, 200)
					love.graphics.draw(bowserimg, bowserquad[qi][1][1], math.floor((x+ox-xscroll)*16*scale), (y-2.5-yscroll+1/16)*16*scale, 0, scale, scale)
				elseif customrcopen == "text" then
					if rightclickvalues2[1] then
						local textx, texty = ((rightclickmenucox-1))-xscroll, (rightclickmenucoy-1-(3/16)-yscroll)
						local size, sizesep = 1, 8/16
						if rightclickvalues2[6] and tostring(rightclickvalues2[6]) == "true" then --big
							size, sizesep = 2, 1
							texty = texty - 4/16
						end
						if rightclickvalues2[5] and tostring(rightclickvalues2[5]) == "true" then --centered
							textx = textx - ((#rightclickvalues2[1]*sizesep)/2)+.5
						end
						if rightclickvalues2[2] then
							love.graphics.setColor(textcolors[rightclickobjects[4].entries[rightclickvalues2[2]]])
						end
						if rightclickvalues2[3] and tostring(rightclickvalues2[3]) == "true" then
							properprintbackground(rightclickvalues2[1], textx*16*scale, texty*16*scale, nil, nil, size)
						end
						properprint(rightclickvalues2[1], textx*16*scale, texty*16*scale, size)
					end
				elseif customrcopen == "castlefireccw" or customrcopen == "castlefirecw" then
					local x, y = rightclickmenucox, rightclickmenucoy
					local length, delay, angle = rightclickvalues2[1] or 3, 0, rightclickvalues2[3] or 0
					for i = 1, length do
						love.graphics.draw(fireballimg, fireballquad[1], math.floor((x-0.75+(((i-1)/2)*math.sin(((-angle+90)/360)*math.pi*2))-xscroll)*16*scale), math.floor((y-1.25+(((i-1)/2)*math.cos(((-angle+90)/360)*math.pi*2))-yscroll)*16*scale), 0, scale, scale)
					end
				elseif customrcopen == "tiletool" then
					--tile tool preview
					local tile
					local x, y = rightclickmenucox, rightclickmenucoy
					local mod = false
					local command = rightclickvalues2[1]
					if string.sub(command, 1, 10) == "change to " then
						tile = tonumber(string.sub(command, 11, -1))
					elseif string.sub(command, 1, 12) == "set back to " then
						tile = tonumber(string.sub(command, 13, -1))
					elseif string.sub(command, 1, 4) == "mod " then
						mod = true
						local s = command:split(" ")
						local s2 = command:find(" to ")
						if s2 and s[2] and tonumber(s[2]) and s[3] and tonumber(s[3]) and tonumber(command:sub(s2+4, -1)) then
							x = tonumber(s[2])
							y = tonumber(s[3])
							tile = tonumber(command:sub(s2+4, -1))
						end
						love.graphics.setColor(255,255,255,150)
						local tx, ty = getMouseTile(mousex, mousey+8*screenzoom*scale)
						properprint(tx .. "-" .. ty, mousex, mousey)
					end
					--tile tool preview selection
					if tile and tilequads[tile] then
						love.graphics.setColor(255, 255, 255, 150)
						if mod then
							love.graphics.draw(tilequads[tile].image, tilequads[tile].quad, math.floor((x-xscroll-1)*16*scale), math.floor(((y-yscroll-2)*16+8)*scale), 0, scale, scale)
						else
							local x1, x2, y1, y2 = x, y, x, y
							if rightclickvalues2[2] then
								local v1, v2 = rightclickvalues2[4]:gsub("n", "-"), rightclickvalues2[5]:gsub("n", "-")
								local v3, v4 = rightclickvalues2[2]:gsub("n", "-"), rightclickvalues2[3]:gsub("n", "-")
								x1, y1 = x+(tonumber(v1) or 0), y+(tonumber(v2) or 0)
								x2, y2 = x1+(tonumber(v3) or 1)-1, y1+(tonumber(v4) or 1)-1
							end
							for dx = x1, x2 do
								for dy = y1, y2 do
									love.graphics.draw(tilequads[tile].image, tilequads[tile].quad, math.floor((dx-xscroll-1)*16*scale), math.floor(((dy-yscroll-2)*16+8)*scale), 0, scale, scale)
								end
							end
						end
					end
				elseif customrcopen == "faithplateup" or customrcopen == "faithplateleft" or customrcopen == "faithplateright" then
					
					local yoffset = -8/16
					local x = rightclickmenucox-.5
					local y = rightclickmenucoy-.5
					local pointstable = {(x-xscroll)*16*scale, ((y+yoffset)-yscroll-.5)*16*scale}
					
					local speedx, speedy
					
					speedx = (rightclickobjects[2].value*100-50)
					speedy = -(rightclickobjects[4].value*45+5)
					
					local step = 1/60
					
					repeat
						x, y = x+speedx*step, y+speedy*step
						speedy = speedy + yacceleration*step
						table.insert(pointstable, (x-xscroll)*16*scale)
						table.insert(pointstable, ((y+yoffset)-yscroll-.5)*16*scale)
					until y+yoffset > yscroll+height+.5
					
					love.graphics.setColor(62, 213, 244, 160)
					love.graphics.setLineWidth(3)
					love.graphics.line(pointstable)
				elseif customrcopen == "snakeblock" then
					if rightclickvalues2[2] and rightclickvalues2[3] then
						local q = 1
						if tonumber(rightclickvalues2[3]) > snakeblockspeed then
							q = 3
						end
						for i = 1, tonumber(rightclickvalues2[2]) do
							local x, y = rightclickmenucox-i+1, rightclickmenucoy
							love.graphics.draw(snakeblockimg, starquad[spriteset][q], math.floor((x-xscroll-.5)*16*scale), math.floor(((y-yscroll-1.5)*16+8)*scale), 0, scale, scale, 8, 8)
						end
					end
				end
				if customrcopen == "region" then
					guielements["rightclickdrag"]:draw()
				elseif customrcopen == "path" then
					local rcp = rightclickpath
					local lx, ly = rcp.last[1], rcp.last[2]--last pos
					local quadcenterx, quadcentery = 8, 8
					if rcp.pipe then
						quadcenterx = 24
					end
					for i = #rcp.path, 1, -1 do
						local offx, offy = 0, 0
						--get quad (direction and start)
						local q = 1
						local r = 0
						if i == #rcp.path then
							if rcp.pipe then --make big (pipe)
								q = 4
							else
								quadcenterx = 8
								q = 2
							end
							if rcp.dir == "right" then
								r = math.pi*0.5
							elseif rcp.dir == "left" then
								r = math.pi*1.5; if rcp.pipe then offy = -16 end
							elseif rcp.dir == "down" then
								r = math.pi; if rcp.pipe then offx = -16 end
							end
						else
							if rcp.pipe then --make wide (pipe)
								quadcenterx = 24
								q = 3
							end
							local dir = "up"
							if lx > rcp.path[i][1] then
								r = math.pi*0.5; dir = "right"
							elseif lx < rcp.path[i][1] then
								r = math.pi*1.5; dir = "left"; if rcp.pipe then offy = -16 end
							elseif ly > rcp.path[i][2] then
								r = math.pi; dir = "down"; if rcp.pipe then offx = -16 end
							end

							if rcp.pipe then
								if (rcp.path[i-1] and rcp.path[i+1]) and not 
									((rcp.path[i+1][1] ~= rcp.path[i-1][1] and rcp.path[i+1][2] == rcp.path[i-1][2])
									or (rcp.path[i+1][2] ~= rcp.path[i-1][2] and rcp.path[i+1][1] == rcp.path[i-1][1]))	then
									q = 5
									if dir == "left" then offx = -16
									elseif dir == "up" then offy = -16 end
								elseif (rcp.path[i-1] and rcp.path[i-2]) and 
									 ((dir == "right" and rcp.path[i][2] ~= rcp.path[i-1][2]) 
							   		or (dir == "left" and rcp.path[i][2] == rcp.path[i-1][2] and rcp.path[i][2] ~= rcp.path[i-2][2]) 
							 		or (dir == "down" and rcp.path[i][1] ~= rcp.path[i-1][1]) 
							 		or (dir == "up" and rcp.path[i][1] == rcp.path[i-1][1] and rcp.path[i][1] ~= rcp.path[i-2][1])) then
									--is the path 2 tiles ago in a different direction?
									q = false
								elseif (rcp.path[i+1] and rcp.path[i+2]) and
									 ((dir == "left" and rcp.path[i][2] ~= rcp.path[i+1][2]) 
									or (dir == "right" and rcp.path[i][2] == rcp.path[i+1][2] and rcp.path[i][2] ~= rcp.path[i+2][2]) 
									or (dir == "up" and rcp.path[i][1] ~= rcp.path[i+1][1]) 
									or (dir == "down" and rcp.path[i][1] == rcp.path[i+1][1] and rcp.path[i][1] ~= rcp.path[i+2][1])) then
									--is the path 2 tiles ahead in a different direction?
									q = false
								end
							end
						end
						if q then
							lx, ly = rcp.path[i][1], rcp.path[i][2]
							love.graphics.draw(pathmarkerimg, pathmarkerquad[q], math.floor(((rcp.x+rcp.path[i][1]-xscroll-.5)*16+offx)*scale), math.floor(((rcp.y+rcp.path[i][2]-yscroll-1.5)*16+offy+8)*scale), r, scale, scale, quadcenterx, quadcentery)
						end
					end
				elseif customrcopen == "trackpath" then
					love.graphics.setColor(255,255,255)
					local rcp = rightclicktrack
					local lx, ly = rcp.last[1], rcp.last[2]--last pos
					for i = 1, #rcp.path do
						local tx, ty = rcp.x+rcp.path[i][1], rcp.y+rcp.path[i][2]
						drawtrack(tx, ty, rcp.path[i][3], rcp.path[i][4])
						--is object selected to be tracked? (d=default(entity),r=reverse,t=tile,tr=tile reverse)
						if i ~= 1 and ismaptile(tx, ty) and (map[tx][ty][2] or rcp.path[i][5] == "t" or rcp.path[i][5] == "tr" or rcp.path[i][5] == "tf" or rcp.path[i][5] == "tfr") then
							local trackable = rcp.path[i][5] or "d"
							if trackable ~= "" then
								local dir = rcp.path[i][4]
								local quadi = 1
								local r = 0
								if dir == "r" or dir == "ru" or dir == "rd" or dir == "u" then
									dir = oppositetrackdirection(dir)
								end
								if trackable == "r" or trackable == "tr" or trackable == "fr" or trackable == "tfr" then
									dir = oppositetrackdirection(dir)
								end
								if dir == "l" or dir == "lu" then
									r = 0
								elseif dir == "r" or dir == "rd" then
									r = math.pi
								elseif dir == "u" or dir == "ru" then
									r = math.pi*.5
								elseif dir == "d" or dir == "ld" then
									r = math.pi*1.5
								end
								if trackable == "d" or trackable == "r" or trackable == "f" or trackable == "fr" then
									if #dir == 2 then --diagonal
										quadi = 2
									else
										quadi = 1
									end
								elseif trackable == "t" or trackable == "tr" or trackable == "tf" or trackable == "tfr" then
									if map[tx][ty][2] then
										love.graphics.draw(tilequads[map[tx][ty][1]].image, tilequads[map[tx][ty][1]].quad, math.floor(((tx-xscroll-1)*16)*scale), math.floor(((ty-yscroll-1.5)*16)*scale), 0, scale, scale)
									end
									if #dir == 2 then --diagonal
										quadi = 4
									else
										quadi = 3
									end
								end
								local cox, coy = getMouseTile(mousex, mousey+8*screenzoom*scale)
								if (cox == tx and coy == ty and not trackrightclickmenu.active) or (trackrightclickmenu.active and trackrightclickmenustage == i) then
									love.graphics.setColor(255,216,0,255)
								end
								love.graphics.draw(trackmarkerimg, trackmarkerquad[quadi], math.floor(((tx-xscroll-.5)*16)*scale), math.floor(((ty-yscroll-1)*16)*scale), r, scale, scale, 8, 8)
								love.graphics.setColor(255,255,255)
							end
						end
					end
					--next track
					love.graphics.setColor(255,216,0,150)
					local left, right, up, down, leftup, leftdown, rightup, rightdown = true,true,true,true,true,true,true,true
					for i = #rcp.path, 1, -1 do
						--check overlap
						local x, y = rcp.path[i][1], rcp.path[i][2]
						if x == lx-1 and y == ly then
							left = false
						elseif x == lx+1 and y == ly then
							right = false
						elseif x == lx and y == ly-1 then
							up = false
						elseif x == lx and y == ly+1 then
							down = false
						elseif x == lx-1 and y == ly-1 then
							leftup = false
						elseif x == lx-1 and y == ly+1 then
							leftdown = false
						elseif x == lx+1 and y == ly-1 then
							rightup = false
						elseif x == lx+1 and y == ly+1 then
							rightdown = false
						end
					end
					if left then drawtrack(rcp.x+lx-1, rcp.y+ly, "c", "c") end
					if right then drawtrack(rcp.x+lx+1, rcp.y+ly, "c", "c") end
					if up then drawtrack(rcp.x+lx, rcp.y+ly-1, "c", "c") end
					if down then drawtrack(rcp.x+lx, rcp.y+ly+1, "c", "c") end
					if leftup then 	drawtrack(rcp.x+lx-1, rcp.y+ly-1, "c", "c") end
					if leftdown then drawtrack(rcp.x+lx-1, rcp.y+ly+1, "c", "c") end
					if rightup then drawtrack(rcp.x+lx+1, rcp.y+ly-1, "c", "c") end
					if rightdown then drawtrack(rcp.x+lx+1, rcp.y+ly+1, "c", "c") end
					--right click menu
					if trackrightclickmenu.active then
						trackrightclickmenu:draw()
					end
				elseif customrcopen == "link" then
					local x1, y1 = math.floor((linktoolX-xscroll-.5)*16*scale), math.floor((linktoolY-yscroll-1)*16*scale)
					local x2, y2 = mousex, mousey
					
					--draw proper outputs
					for x = math.floor(splitxscroll[1]), math.floor(splitxscroll[1])+width+1 do
						for y = math.floor(splityscroll[1]), math.floor(splityscroll[1])+height+1 do
							for i, v in pairs(outputsi) do
								if inmap(x, y) and #map[x][y] > 1 and map[x][y][2] == v then							
									local r = map[x][y]
									if tablecontains(outputsi, map[x][y][2]) then
										love.graphics.setColor(255, 255, 150, 150)
									else
										love.graphics.setColor(255, 150, 150, 150)
									end
									love.graphics.rectangle("fill", math.floor((x-splitxscroll[1]-1)*16*scale), ((y-splityscroll[1]-1)*16-8)*scale, 16*scale, 16*scale)
								end
							end
						end
					end
					
					love.graphics.setColor(255, 172, 47, 255)
					
					drawlinkline(x1, y1, x2, y2)
					
					love.graphics.setColor(200, 140, 30, 255)
					
					love.graphics.draw(linktoolpointerimg, x2-math.ceil(scale/2), y2, 0, scale, scale, 3, 3)
					
					properprintFbackground(linktoolt, math.floor(x2+4*scale), y2-4*scale, true)
				else
					--draw links
					local tx, ty = rightclickmenucox, rightclickmenucoy
					local x1, y1 = (rightclickmenucox-.5-xscroll)*16*scale, (rightclickmenucoy-1-yscroll)*16*scale
					local x2, y2
					local drawtable = {}
			
					for i = 1, #map[tx][ty] do
						if map[tx][ty][i] == "link" and map[tx][ty][i+1] and map[tx][ty][i+2] then
							x2, y2 = math.floor((map[tx][ty][i+1]-xscroll-.5)*16*scale), math.floor((map[tx][ty][i+2]-yscroll-1)*16*scale)
							
							local t = map[tx][ty][i]
							if map[tx][ty][i+3] then
								t = map[tx][ty][i+3]
							end
							table.insert(drawtable, {x1, y1, x2, y2, t})
						end
					end
					
					table.sort(drawtable, function(a,b) return math.abs(a[3]-a[1])>math.abs(b[3]-b[1]) end)
					
					for i = 1, #drawtable do
						local x1, y1, x2, y2, t = unpack(drawtable[i])
						love.graphics.setColor(127, 127, 255*(i/#drawtable), 255)
						
						if math.fmod(i, 2) == 0 then
							drawlinkline2(x1, y1, x2, y2)
						else
							drawlinkline(x1, y1, x2, y2)
						end
						
						properprintFbackground(t, math.floor(x2-string.len(t)*4*scale), y2+10*scale, true)
					end
					
					--draw actual menu
					love.graphics.setColor(10, 10, 10, 190)
					love.graphics.rectangle("fill", rightclickobjects.x*scale, rightclickobjects.y*scale, rightclickobjects.width*scale, rightclickobjects.height*scale)
					--draw them bottom to top to make drop-downs work
					love.graphics.setColor(255, 255, 255)
					local ontop = {} --drop ups drawn on top
					for i = #rightclickobjects, 1, -1  do
						local obj = rightclickobjects[i]
						if obj.type == "dropdown" and obj.extended then
							table.insert(ontop, i)
						elseif not obj.dontdraw then
							obj:draw()
						end
					end
					--draw on top objects
					for i = 1, #ontop do
						local obj = rightclickobjects[ontop[i]]
						obj:draw()
					end
				end
			elseif rightclickmenu then
				rightclickmenu:draw()
			end
			
		elseif editorstate ~= "linktool" and editorstate ~= "portalgun" and editorstate ~= "selectiontool" and editorstate ~= "powerline" then
			local x, y = getMouseTile(love.mouse.getX(), love.mouse.getY()-8*screenzoom*scale)
			
			love.graphics.push()
			love.graphics.scale(screenzoom,screenzoom)
			if inmap(x, y+1) then
				if pastingtiles then
					-- draw mtclipboard
						for i, v in ipairs(mtclipboard) do
							for j, w in ipairs(v) do
								--w = tonumber(w)
								local tilei = w[1]
								if tilei == 1 and pastemode == 1 then
									love.graphics.setColor(255, 255, 255, 8)
									love.graphics.draw(tilequads[tilei].image, tilequads[tilei].quad, math.floor((x-splitxscroll[1]-1 + pastecenter[1])*16*scale)+(i-1)*16*scale, ((y-splityscroll[1]-1 + pastecenter[2])*16+8)*scale+((j-1)*16*scale), 0, scale, scale)
								else
									love.graphics.setColor(255, 255, 255, 72)
									love.graphics.draw(tilequads[tilei].image, tilequads[tilei].quad, math.floor((x-splitxscroll[1]-1 + pastecenter[1])*16*scale)+(i-1)*16*scale, ((y-splityscroll[1]-1 + pastecenter[2])*16+8)*scale+((j-1)*16*scale), 0, scale, scale)
								end
								local entityi = w[2]
								if entityi and type(w[2]) == "number" then
									love.graphics.setColor(255, 255, 255, 72)
									love.graphics.draw(entityquads[entityi].image, entityquads[entityi].quad, math.floor((x-splitxscroll[1]-1 + pastecenter[1])*16*scale)+(i-1)*16*scale, ((y-splityscroll[1]-1 + pastecenter[2])*16+8)*scale+((j-1)*16*scale), 0, scale, scale)
								end
							end
						end
					--end
					if android then
						love.graphics.setColor(255, 255, 255, 200)
						love.graphics.setLineWidth(1*scale)
						love.graphics.rectangle("line",math.floor((x-splitxscroll[1]-1)*16*scale), math.floor(((y-splityscroll[1]-1)*16+8)*scale), 16*scale, 16*scale)
					end
				end
			
				love.graphics.setColor(255, 255, 255, 200)
				if tileselection or ctrlpressed or tileselectionmoving then
					local x1, y1 = x, y+1
					local x2, y2 = x, y+1
					if tileselectionmoving then
						x1, y1 = x+pastecenter[1], y+pastecenter[2]+1
						x2, y2 = x+pastecenter[1]+#mtclipboard-1, y+pastecenter[2]+#mtclipboard[1]
					elseif tileselection then
						x1, y1 = math.min(tileselection[1],tileselection[3]),math.min(tileselection[2],tileselection[4])
						x2, y2 = math.max(tileselection[1],tileselection[3]),math.max(tileselection[2],tileselection[4])
					end
					x1, y1 = math.max(xscroll-1, x1), math.max(yscroll-1, y1)
					x2, y2 = math.min(xscroll+width*screenzoom2+1, x2), math.min(yscroll+height*screenzoom2+1, y2)
					local sx, sy, sw, sh = x1-1, y1-1, x2-x1+1, y2-y1+1
					love.graphics.setColor(0, 131, 255, 45)
					love.graphics.rectangle("fill", ((sx-xscroll)*16)*scale,((sy-yscroll)*16-8)*scale, sw*16*scale, sh*16*scale)
					love.graphics.setColor(255,255,255)
					love.graphics.stencil(function() 
						love.graphics.setLineWidth(scale)
						love.graphics.rectangle("line", (math.floor((sx-xscroll)*16)+.5)*scale, (math.floor((sy-yscroll)*16)-8+.5)*scale, (sw*16-1)*scale, (sh*16-1)*scale) end, "increment")
					love.graphics.setStencilTest("greater", 0)
					for mx = 2, sw do
						love.graphics.draw(antsimg, math.floor(((sx+mx-1-xscroll)*16-math.floor(tileselectionants)))*scale, math.floor((sy-yscroll)*16-8-math.floor(tileselectionants))*scale, 0, scale, scale)
						love.graphics.draw(antsimg, math.floor(((sx+mx-1-xscroll)*16-math.floor(tileselectionants)))*scale, math.floor((sy+sh-1-yscroll)*16-8-math.floor(tileselectionants))*scale, 0, scale, scale)
						love.graphics.draw(antsimg, math.floor(((sx+mx-1-xscroll)*16-math.floor(tileselectionants)))*scale, math.floor((sy+sh-yscroll)*16-8-math.floor(tileselectionants))*scale, 0, scale, scale)
					end
					for my = 1, sh+1 do
						love.graphics.draw(antsimg, math.floor(((sx-xscroll)*16-math.floor(tileselectionants)))*scale, math.floor((sy+my-1-yscroll)*16-8-math.floor(tileselectionants))*scale, 0, scale, scale)
						love.graphics.draw(antsimg, math.floor(((sx+sw-1-xscroll)*16-math.floor(tileselectionants)))*scale, math.floor((sy+my-1-yscroll)*16-8-math.floor(tileselectionants))*scale, 0, scale, scale)
						love.graphics.draw(antsimg, math.floor(((sx+sw-xscroll)*16-math.floor(tileselectionants)))*scale, math.floor((sy+my-1-yscroll)*16-8-math.floor(tileselectionants))*scale, 0, scale, scale)
					end
					love.graphics.setStencilTest()
				elseif editentities == false and not pastingtiles then
					love.graphics.draw(tilequads[currenttile].image, tilequads[currenttile].quad, math.floor((x-splitxscroll[1]-1)*16*scale), math.floor(((y-splityscroll[1]-1)*16+8)*scale), 0, scale, scale)
					if android then
						love.graphics.setLineWidth(1*scale)
						love.graphics.rectangle("line",math.floor((x-splitxscroll[1]-1)*16*scale), math.floor(((y-splityscroll[1]-1)*16+8)*scale), 16*scale, 16*scale)
					end
					if editortilemousescroll and (brushsizex <= 1 and brushsizey <= 1) then
						for i = 1, 2 do
							love.graphics.setColor(255, 255, 255, 200-(i*70))
							if currenttile - i >= 1 then
								if currenttile - i >= 89996 and currenttile - i < 90001 then
								else
									love.graphics.draw(tilequads[currenttile-i].image, tilequads[currenttile-i].quad, math.floor((x-splitxscroll[1]-1)*16*scale), math.floor(((y-splityscroll[1]-1)*16+8-((i*16)+i))*scale), 0, scale, scale)
								end
							end
						end
						for i = 1, 2 do
							love.graphics.setColor(255, 255, 255, 200-(i*70))
							if (currenttile + i > smbtilecount+portaltilecount+customtilecount and currenttile + i < 90000) or (currenttile + i > animatedtilecount+90000 and currenttile + i > 89996) then
							else
								love.graphics.draw(tilequads[currenttile+i].image, tilequads[currenttile+i].quad, math.floor((x-splitxscroll[1]-1)*16*scale), math.floor(((y-splityscroll[1]-1)*16+8+((i*16)+i))*scale), 0, scale, scale)
							end
						end
					elseif (brushsizex > 1 or brushsizey > 1) then
						for xl = 1, brushsizex do
							for yl = 1, brushsizey do
								if yl == 1 and xl == 1 then
								else
									love.graphics.setColor(255, 255, 255, 200)
									love.graphics.draw(tilequads[currenttile].image, tilequads[currenttile].quad, math.floor((x-splitxscroll[1]-1+xl-1)*16*scale), math.floor(((y-splityscroll[1]-1+yl-1)*16+8)*scale), 0, scale, scale)
								end
							end
						end
					end
					--replace tiles
					if love.keyboard.isDown("e") and not android then
						local ontile = map[x][y+1][1]
						for x = math.floor(xscroll)+1, math.min(mapwidth, math.floor(xscroll+width)+1) do
							for y = math.floor(yscroll)+1, math.min(mapheight, math.floor(yscroll+height)+1) do
								if onscreen(x-1, y-1, 1, 1) and ontile == map[x][y][1] then
									love.graphics.setColor(255, 255, 255, 200)
									love.graphics.draw(tilequads[currenttile].image, tilequads[currenttile].quad, math.floor((x-splitxscroll[1]-1)*16*scale), math.floor(((y-splityscroll[1]-2)*16+8)*scale), 0, scale, scale)
								end
							end
						end
					elseif love.keyboard.isDown("f") and not android then
						local ontile = map[x][y+1][1]
						if backgroundtilemode then
							ontile = map[x][y+1]["back"]
						end
						local replacetiles = paintbucket(x, y+1, ontile, "onscreen")
						for i, t in pairs(replacetiles) do
							local x, y = t[1], t[2]
							--if onscreen(x-1, y-1, 1, 1) then
								love.graphics.setColor(255, 255, 255, 200)
								love.graphics.draw(tilequads[currenttile].image, tilequads[currenttile].quad, math.floor((x-splitxscroll[1]-1)*16*scale), math.floor(((y-splityscroll[1]-2)*16+8)*scale), 0, scale, scale)
							--end
						end
					end
				elseif not pastingtiles then 
					--offset enemy
					local offsetx = 0
					if (entitylist[currenttile] and entitylist[currenttile].offset) or (enemiesdata[currenttile] and enemiesdata[currenttile].offsetable) then
						local allowoffset = true
						--don't clip with entity on the right
						if ismaptile(x+1, y+1) and map[x+1][y+1][2] and map[x+1][y+1][2] == currenttile and not map[x+1][y+1].argument then
							allowoffset = false
						elseif ismaptile(x, y+1) and map[x][y+1][2] and map[x][y+1][2] == currenttile and not map[x][y+1].argument then
							allowoffset = false
						end
						if allowoffset then
							local mx = ((love.mouse.getX()/scale)+(xscroll*16))%16
							--[[if mx < 16*0 then
								offsetx = -.5
							else]]if mx > 16*0.75 then
								offsetx = .5
							end
						end
					end
					if not tilequads[currenttile] and enemiesdata[currenttile] then --custom enemy
						local v = enemiesdata[currenttile]
						if v.showicononeditor and v.icongraphic then
							love.graphics.draw(v.icongraphic, math.floor((x-xscroll-1+offsetx)*16*scale), math.floor(((y-yscroll-0.5)*16)*scale), 0, scale, scale)
						else
							local xoff, yoff = ((0.5-v.width/2+(v.spawnoffsetx or 0))*16 + v.offsetX - v.quadcenterX)*scale, (((v.spawnoffsety or 0)-v.height+1)*16-v.offsetY - v.quadcenterY)*scale
							love.graphics.draw(v.graphic, v.quad, math.floor((x-xscroll-1+offsetx)*16*scale+xoff), math.floor(((y-yscroll)*16)*scale+yoff), 0, scale, scale)
						end
					else
						love.graphics.draw(entityquads[currenttile].image, entityquads[currenttile].quad, math.floor((x-splitxscroll[1]-1+offsetx)*16*scale), math.floor(((y-splityscroll[1]-1)*16+8)*scale), 0, scale, scale)
					end
					if android then
						love.graphics.setLineWidth(1*scale)
						love.graphics.rectangle("line",math.floor((x-splitxscroll[1]-1)*16*scale), math.floor(((y-splityscroll[1]-1)*16+8)*scale), 16*scale, 16*scale)
					end
					if editortilemousescroll and ( brushsizex <= 1 and brushsizey <= 1) then
						if type(editortilemousescroll) == "table" then
							local t = editortilemousescroll
							for i = 1, 2 do
								love.graphics.setColor(255, 255, 255, 200-(i*70))
								if tonumber(t[i]) and t[i] > 0 then
									love.graphics.draw(entityquads[t[i]].image, entityquads[t[i]].quad, math.floor((x-splitxscroll[1]-1)*16*scale), math.floor(((y-splityscroll[1]-1)*16+8-((i*16)+i))*scale), 0, scale, scale)
								end
							end
							for i = 1, 2 do
								love.graphics.setColor(255, 255, 255, 200-(i*70))
								if tonumber(t[2+i]) and t[2+i] > 0 then
									love.graphics.draw(entityquads[t[2+i]].image, entityquads[t[2+i]].quad, math.floor((x-splitxscroll[1]-1)*16*scale), math.floor(((y-splityscroll[1]-1)*16+8+((i*16)+i))*scale), 0, scale, scale)
								end
							end
						elseif type(currenttile) == "number" then
							for i = 1, 2 do
								love.graphics.setColor(255, 255, 255, 200-(i*70))
								if currenttile - i > 0 then
									love.graphics.draw(entityquads[currenttile-i].image, entityquads[currenttile-i].quad, math.floor((x-splitxscroll[1]-1)*16*scale), math.floor(((y-splityscroll[1]-1)*16+8-((i*16)+i))*scale), 0, scale, scale)
								end
							end
							for i = 1, 2 do
								love.graphics.setColor(255, 255, 255, 200-(i*70))
								if currenttile + i < #entitylist then
									love.graphics.draw(entityquads[currenttile+i].image, entityquads[currenttile+i].quad, math.floor((x-splitxscroll[1]-1)*16*scale), math.floor(((y-splityscroll[1]-1)*16+8+((i*16)+i))*scale), 0, scale, scale)
								end
							end
						end
					elseif (brushsizex > 1 or brushsizey > 1) then
						for xl = 1, brushsizex do
							for yl = 1, brushsizey do
								if yl == 1 and xl == 1 then 
								elseif not tilequads[currenttile] and enemiesdata[currenttile] then --custom enemy
									local v = enemiesdata[currenttile]
									if v.showicononeditor and v.icongraphic then
										love.graphics.draw(v.icongraphic, math.floor((x-splitxscroll[1]-1+xl-1)*16*scale), math.floor(((y-splityscroll[1]-0.5+yl-1)*16)*scale), 0, scale, scale)
									else
										local xoff, yoff = ((0.5-v.width/2+(v.spawnoffsetx or 0))*16 + v.offsetX - v.quadcenterX)*scale, (((v.spawnoffsety or 0)-v.height+1)*16-v.offsetY - v.quadcenterY)*scale
										love.graphics.draw(v.graphic, v.quad, math.floor((x-splitxscroll[1]-1+xl-1)*16*scale+xoff), math.floor(((y-splityscroll[1]-1+yl-1)*16+16)*scale+yoff), 0, scale, scale)
									end
								else
									love.graphics.setColor(255, 255, 255, 200)
									love.graphics.draw(entityquads[currenttile].image, entityquads[currenttile].quad, math.floor((x-splitxscroll[1]-1+xl-1)*16*scale), math.floor(((y-splityscroll[1]-1+yl-1)*16+8)*scale), 0, scale, scale)
								end
							end
						end
					end
				end
			end
			love.graphics.pop()
		end
		
		if assistmode and not editormenuopen then --quickmenu
			love.graphics.setColor(0, 0, 0, 110)
			love.graphics.rectangle("fill", ((width*8)-30)*scale, (quickmenuy-7)*scale, 60*scale, 7*scale)
			love.graphics.setColor(255, 255, 255, 200)
			
			if quickmenuopen then
				love.graphics.draw(quickmenuarrowimg, ((width*8)-3)*scale, (quickmenuy-1)*scale, 0, scale, -scale)
			else
				love.graphics.draw(quickmenuarrowimg, ((width*8)-3)*scale, (quickmenuy-6)*scale, 0, scale, scale)
			end
			
			if quickmenuy ~= quickmenuclosedy then
				love.graphics.setColor(0, 0, 0, 180)
				love.graphics.rectangle("fill", ((width*8)-((#latesttiles*24)/2))*scale, (quickmenuy)*scale, (#latesttiles*24)*scale, 24*scale)
				
				love.graphics.setColor(0, 0, 0, 200)
				love.graphics.rectangle("fill", ((width*8)-((#latesttiles*24)/2)+47)*scale,  (quickmenuy+2)*scale, 2*scale, 20*scale)
				
				for i = 1, #latesttiles do
					local t = latesttiles[i]
					love.graphics.setColor(255, 255, 255, 255)
					local x = (((width*8)-((#latesttiles*24)/2))+(24*(i-1))+4)
					if t[1] == 1 and tilequads[t[2]] then
						love.graphics.draw(tilequads[t[2]].image, tilequads[t[2]].quad, x*scale, (quickmenuy+4)*scale, 0, scale, scale)
					elseif t[1] == 2 and entityquads[t[2]] then
						if type(t[2]) == "string" then
							local v = enemiesdata[t[2]]
							love.graphics.setScissor(x*scale, (quickmenuy+4)*scale, 16*scale, 16*scale)
							if v.icongraphic then
								love.graphics.draw(v.icongraphic, x*scale, (quickmenuy+4)*scale, 0, scale, scale)
							elseif v.quad then
								love.graphics.draw(v.graphic, v.quad, x*scale, (quickmenuy+4)*scale, 0, scale, scale)
							else
								love.graphics.draw(entityquads[1].image, entityquads[1].quad, x*scale, (quickmenuy+4)*scale, 0, scale, scale)
							end
							love.graphics.setScissor()
						else
							love.graphics.draw(entityquads[t[2]].image, entityquads[t[2]].quad, x*scale, (quickmenuy+4)*scale, 0, scale, scale)
						end
					end
					if quickmenusel == i then
						love.graphics.setColor(255, 255, 255, 127)
						love.graphics.rectangle("fill", x*scale, (quickmenuy+4)*scale, 16*scale, 16*scale)
					end
				end
			end
			
			love.graphics.setColor(255, 255, 255, 255)
		end
		if editorstate == "selectiontool" then
			if selectiontoolclick[1][1] and selectiontoolclick[1][2] then
				love.graphics.setLineStyle("rough")
				love.graphics.setLineWidth(2*scale)
				love.graphics.rectangle("line", (selectiontoolclick[1][1] - xscroll*16)*scale, (selectiontoolclick[1][2] - yscroll*16)*scale, mousex-(selectiontoolclick[1][1] - xscroll*16)*scale, mousey-(selectiontoolclick[1][2] - yscroll*16)*scale)
				
				love.graphics.setLineStyle("smooth")
			elseif #selectiontoolselection > 0 and not rightclickmenuopen then
				love.graphics.setColor(255, 255, 255, 120)
				for i, t in pairs(selectiontoolselection) do
					local x, y = t[1], t[2]
					love.graphics.rectangle("fill", math.floor((x-splitxscroll[1]-1)*16*scale), ((y-splityscroll[1]-1)*16-8)*scale, 16*scale, 16*scale)
				end
			end
		end
		if love.keyboard.isDown("lalt") then
			love.graphics.setColor(255, 255, 255, 120)
			local tx, ty = getMouseTile(mousex, mousey+8*scale)
			properprint(tx .. "-" .. ty, mousex, mousey)
			-- .. " " .. tilemap(tx, ty)
		end
	elseif changemapwidthmenu or minimapmoving then
		local w = width*16-52
		local h = height*16-52
		
		local s, nmw, nmox, nmh, nmoy --newmapwidth, newmapoffsetx, newmapheight, newmapoffsety
		if changemapwidthmenu then
			s = math.min(w/newmapwidth, h/newmapheight)
		
			w = newmapwidth*s
			h = newmapheight*s
			nmw = newmapwidth
			nmox = newmapoffsetx
			nmh = newmapheight
			nmoy = newmapoffsety
		else
			s = math.min(w/mapwidth, h/mapheight)
		
			w = mapwidth*s
			h = mapheight*s
			nmw = mapwidth
			nmox = 0
			nmh = mapheight
			nmoy = 0
		end
		
		local mapx, mapy = (width*16 - w)/2, (height*16 - h)/2
		
		love.graphics.setColor(0, 0, 0, 200)
		love.graphics.rectangle("fill", (mapx-2)*scale, (mapy-2)*scale, (w+4)*scale, (h+4)*scale)
		
		--minimap
		for x = 1, mapwidth do
			for y = 1, mapheight do
				if x > -nmox and x <= nmw-nmox and y > -nmoy and y <= nmh-nmoy then
					local id = map[x][y][1]
					if id ~= nil and (rgblist[id] or animatedrgblist[id]) and id ~= 0 and not tilequads[id].invisible then
						if id > 90000 then
							if animatedrgblist[id] and animatedrgblist[id][animatedtilesframe[id]] then
								love.graphics.setColor(animatedrgblist[id][animatedtilesframe[id]])
								love.graphics.rectangle("fill", (mapx+(x-1+nmox)*s)*scale, (mapy+(y-1+nmoy)*s)*scale, s*scale, s*scale)
							end
						else 
							love.graphics.setColor(rgblist[id])
							love.graphics.rectangle("fill", (mapx+(x-1+nmox)*s)*scale, (mapy+(y-1+nmoy)*s)*scale, s*scale, s*scale)
						end
					end
				end
			end
		end
		
		love.graphics.setColor(255, 0, 0, 255)
		drawrectangle(mapx-1, mapy-1, w+2, h+2)
		
		--resizing stuff
		if changemapwidthmenu then
			love.graphics.setColor(255, 255, 255)
			properprintFbackground(TEXT["old width: "] .. mapwidth, 26*scale, (mapy-21)*scale, true)
			properprintFbackground(TEXT["old height: "] .. mapheight, 26*scale, (mapy-11)*scale, true)
			
			properprintFbackground(TEXT["new width: "] .. newmapwidth, 26*scale, (mapy+h+4)*scale, true)
			properprintFbackground(TEXT["new height: "] .. newmapheight, 26*scale, (mapy+h+14)*scale, true)
			
			--button positioning
			guielements["maptopup"].x, guielements["maptopup"].y = width*8-5, mapy-24
			guielements["maptopdown"].x, guielements["maptopdown"].y = width*8-5, mapy-13
			
			guielements["mapbottomup"].x, guielements["mapbottomup"].y = width*8-5, mapy+h+2
			guielements["mapbottomdown"].x, guielements["mapbottomdown"].y = width*8-5, mapy+h+13
			
			guielements["mapleftleft"].x, guielements["mapleftleft"].y = mapx-24, height*8-5
			guielements["mapleftright"].x, guielements["mapleftright"].y = mapx-13, height*8-5
			
			guielements["maprightleft"].x, guielements["maprightleft"].y = mapx+w+2, height*8-5
			guielements["maprightright"].x, guielements["maprightright"].y = mapx+w+13, height*8-5
			
			guielements["mapwidthapply"].x, guielements["mapwidthapply"].y = width*8+10, mapy+h+4
			guielements["mapwidthcancel"].x, guielements["mapwidthcancel"].y = width*8+65, mapy+h+4
			
			guielements["maptopup"]:draw()
			guielements["maptopdown"]:draw()
			guielements["mapleftleft"]:draw()
			guielements["mapleftright"]:draw()
			guielements["maprightleft"]:draw()
			guielements["maprightright"]:draw()
			guielements["mapbottomup"]:draw()
			guielements["mapbottomdown"]:draw()
			
			guielements["mapwidthapply"]:draw()
			guielements["mapwidthcancel"]:draw()
		else --just moving camera
			love.graphics.setColor(255,0,0)
			love.graphics.rectangle("line", (mapx+(xscroll+nmox)*s)*scale, (mapy+(yscroll+nmoy+.5)*s)*scale, width*s*scale, height*s*scale)
			love.graphics.setColor(255,255,255)
			properprintFbackground(TEXT["toggle minimap with m"], 8*scale, (height*16-16)*scale)
		end
	else
		if editorstate == "maps" then
			love.graphics.setColor(0, 0, 0, 100)
		else
			love.graphics.setColor(0, 0, 0, 230)
		end
		
		if not minimapdragging then
			love.graphics.rectangle("fill", 1*scale, 18*scale, 398*scale, (205+tilemenuy)*scale)		
		else
			love.graphics.rectangle("fill", 1*scale, 18*scale, 398*scale, (18+minimapheight*2)*scale)
		end
		
		guielements["tabmain"]:draw()
		guielements["tabtiles"]:draw()
		guielements["tabtools"]:draw()
		guielements["tabmaps"]:draw()
		guielements["tabcustom"]:draw()
		guielements["tabanimations"]:draw()
		
		if editorstate == "tiles" then
			--TILES
			love.graphics.setColor(255, 255, 255)
			
			--properprint("tilelist", 3*scale, 24*scale)
			guielements["tilesall"]:draw()
			guielements["tilessmb"]:draw()
			guielements["tilesportal"]:draw()
			guielements["tilescustom"]:draw()
			guielements["tilesanimated"]:draw()
			guielements["tilesobjects"]:draw()
			guielements["tilesentities"]:draw()
			
			drawrectangle(4, 37, 375, 167+tilemenuy)
			
			--tilemenuy
			love.graphics.push()
			love.graphics.translate(0, tilemenuy*scale)
			
			love.graphics.setScissor(5*scale, (38)*scale, 373*scale, (165+tilemenuy)*scale)
			
			if editmtobjects then
				if #multitileobjects > 0 then
					for i = 1, #multitileobjects do
						if i < 10 then
							love.graphics.setColor(127, 127, 127, 255)
							love.graphics.rectangle("fill", 6*scale, math.floor(i-1)*17*scale+39*scale-tilesoffset, 14*scale, 14*scale)
							love.graphics.setColor(0, 0, 0, 255)
							love.graphics.rectangle("fill", 7*scale, math.floor(i-1)*17*scale+39*scale-tilesoffset+1*scale, 14*scale-2*scale, 14*scale-2*scale)
							love.graphics.setColor(255, 255, 255, 255)
							properprint(i .. " " .. multitileobjectnames[i], 8*scale, math.floor(i-1)*17*scale+42*scale-tilesoffset)
						else
							properprint(multitileobjectnames[i], 8*scale, math.floor(i-1)*17*scale+42*scale-tilesoffset)
						end
					end
				else
					love.graphics.setColor(255, 255, 255)
					properprintF(TEXT["no objects saved"], (194-utf8.len(TEXT["no objects saved"])*4)*scale, 52*scale)
					properprintF(TEXT["press ctrl in map to save tile selection"], (194-utf8.len(TEXT["press ctrl in map to save tile selection"])*4)*scale, 62*scale)
					properprintF(TEXT["as an object"], (194-utf8.len(TEXT["as an object"])*4)*scale, 72*scale)
				end
			elseif editentities == false then
				if animatedtilelist then
					for i = 1, tilelistcount+1 do
						love.graphics.draw(tilequads[i+tileliststart-1+90000].image, tilequads[i+tileliststart-1+90000].quad, math.fmod((i-1), 22)*17*scale+5*scale, math.floor((i-1)/22)*17*scale+38*scale-tilesoffset, 0, scale, scale)
						if tilehotkeysindex[i+tileliststart-1+90000] then
							properprintbackground(tilehotkeysindex[i+tileliststart-1+90000], math.fmod((i-1), 22)*17*scale+13*scale, math.floor((i-1)/22)*17*scale+47*scale-tilesoffset)
						end
					end
				else
					for i = 1, tilelistcount+1 do
						local dy = math.floor((i-1)/22)*17*scale+38*scale-tilesoffset
						if dy > 0 and dy < height*16*scale then
							love.graphics.draw(tilequads[i+tileliststart-1].image, tilequads[i+tileliststart-1].quad, math.fmod((i-1), 22)*17*scale+5*scale, dy, 0, scale, scale)
							if tilehotkeysindex[i+tileliststart-1] then
								properprintbackground(tilehotkeysindex[i+tileliststart-1], math.fmod((i-1), 22)*17*scale+13*scale, math.floor((i-1)/22)*17*scale+47*scale-tilesoffset)
							end
						end
					end
				end
			else
				--nice and organized entities
				for list = 1, #entitiesform do
					if entitiesform[list].hidden then
						love.graphics.setColor(127, 127, 127)
						properprint("+", (368)*scale, (40+entitiesform[list].y-10)*scale-tilesoffset)
					else
						love.graphics.setColor(255, 255, 255)
						properprint("-", (367)*scale, (40+entitiesform[list].y-10)*scale-tilesoffset)
					end
					properprintF(TEXT[entitiesform[list].name], (5)*scale, (40+entitiesform[list].y-10)*scale-tilesoffset)
					love.graphics.setColor(255, 255, 255)
					if not entitiesform[list].hidden then
						for i = 1, #entitiesform[list] do
							local t = entitiesform[list][i]
							local x = math.fmod((i-1), 22)*17*scale+5*scale
							local y = (math.floor((i-1)/22)*17*scale+(39+entitiesform[list].y)*scale)
							love.graphics.setColor(255, 255, 255)
							if tonumber(t) then
								love.graphics.draw(entityquads[t].image, entityquads[t].quad, x, y-tilesoffset, 0, scale, scale)
							else
								local v = enemiesdata[t]
								local starty = y-tilesoffset
								if starty < 39*scale and starty > 23*scale then
									love.graphics.setScissor(x, 39*scale, 16*scale, (16*scale)-((39*scale)-starty))
								else
									love.graphics.setScissor(x, math.min(y-tilesoffset, 186*scale), 16*scale, 16*scale)
								end
								if starty > 23*scale then
									if v.icongraphic then
										love.graphics.draw(v.icongraphic, x, y-tilesoffset, 0, scale, scale)
									elseif v.quad then
										love.graphics.draw(v.graphic, v.quad, x, y-tilesoffset, 0, scale, scale)
									else
										love.graphics.draw(entityquads[1].image, entityquads[1].quad, x, y-tilesoffset, 0, scale, scale)
									end
								end
								love.graphics.setScissor(5*scale, 38*scale, 373*scale, 165*scale)
							end
							if tilehotkeysentityindex[t] then
								properprintbackground(tilehotkeysentityindex[t], x+8*scale, y-tilesoffset+9*scale)
							end
						end
					end
				end
				love.graphics.setColor(255, 255, 255)
			end
			
			local mtbutton
			local mousex, mousey = love.mouse.getX(), love.mouse.getY()
			local tile = gettilelistpos(mousex, mousey)
			if editentities == false and not editmtobjects then
				if tilestampselection then
					local t = tilestampselection

					love.graphics.setLineWidth(2*scale)
					love.graphics.setColor(255, 255, 255, 127)
					love.graphics.rectangle("line", t.mx, t.my, mousex-t.mx, mousey-t.my)

					local x1, y1, x2, y2 = t.x, t.y, mousex, mousey
					if mousex <= t.x then
						x1 = t.x+17*scale
					end
					if mousey <= t.y then
						y1 = t.y+17*scale
					end
					if x2 < x1 then
						x2 = x1; x1 = mousex
					end
					if y2 < y1 then
						y2 = y1; y1 = mousey
					end
					for tx = 1, math.ceil((x2-x1)/(17*scale)) do
						for ty = 1, math.ceil((y2-y1)/(17*scale)) do
							local tile = gettilelistpos(x1+(17*scale)*(tx-1), y1+(17*scale)*(ty-1))
							if tile and tile <= tilelistcount+1 then
								love.graphics.setColor(255, 255, 255, 127)
								love.graphics.rectangle("fill", (5+math.fmod((tile-1), 22)*17)*scale, (38+math.floor((tile-1)/22)*17)*scale-tilesoffset, 16*scale, 16*scale)
							end
						end
					end
				else
					if tile and tile <= tilelistcount+1 then
						love.graphics.setColor(255, 255, 255, 127)
						love.graphics.rectangle("fill", (5+math.fmod((tile-1), 22)*17)*scale, (38+math.floor((tile-1)/22)*17)*scale-tilesoffset, 16*scale, 16*scale)
					end
				end
			elseif editmtobjects then
				if #multitileobjects > 0 then
					entry = getlistpos(mousex, mousey)
					mtbutton = getmtbutton(mousex) -- 0 1 2 3 = nobutton up down delete
					if entry and entry <= #multitileobjects-1 then
						love.graphics.setColor(255, 255, 255, 64)
						love.graphics.rectangle("fill", 5*scale, (38+math.floor((tile-1)/22)*17)*scale-tilesoffset, 373*scale, 16*scale)
						--buttons
						for i = 1, 3 do
							if mtbutton == i then love.graphics.setColor(255, 255, 255, 255)
							else love.graphics.setColor(127, 127, 127, 255) end
							love.graphics.rectangle("fill", (333+15*(i-1))*scale, (39+math.floor((tile-1)/22)*17)*scale-tilesoffset, 14*scale, 14*scale)
							love.graphics.setColor(0, 0, 0, 255)
							love.graphics.rectangle("fill", (333+15*(i-1)+1)*scale, (39+math.floor((tile-1)/22)*17)*scale-tilesoffset+1*scale, 14*scale-2*scale, 14*scale-2*scale)
							if mtbutton == i then
								if i == 3 then love.graphics.setColor(255, 0, 0, 255)
								else love.graphics.setColor(255, 255, 255, 255) end
							else love.graphics.setColor(127, 127, 127, 255) end
							if i == 1 then
								--up
								love.graphics.draw(uparrowimg, (333+15*(i-1)+3)*scale, (38+math.floor((tile-1)/22)*17)*scale-tilesoffset+3*scale, 0, scale, scale)
							elseif i == 2 then
								--down
								love.graphics.draw(downarrowimg, (333+15*(i-1)+3)*scale, (38+math.floor((tile-1)/22)*17)*scale-tilesoffset+3*scale, 0, scale, scale)
							elseif i == 3 then
								--delete
								properprint("x",(333+15*(i-1)+3)*scale, (39+math.floor((tile-1)/22)*17)*scale-tilesoffset+3*scale)
							end
						end
					end

					if guielements["mtobjectrename"].active then
						guielements["mtobjectrename"]:draw()
					end
				end
			else
				local tile, list = getentitylistpos(love.mouse.getX(), love.mouse.getY())
				if tile then
					local x = (5+math.fmod((tile-1), 22)*17)*scale
					local y = (math.floor(((tile-1))/22)*17*scale+(39+entitiesform[list].y)*scale)
					love.graphics.setColor(255, 255, 255, 127)
					love.graphics.rectangle("fill", x, y-tilesoffset, 16*scale, 16*scale)
				elseif list then
					local x = (5)*scale
					local y = ((39+entitiesform[list].y-10)*scale)
					love.graphics.setColor(255, 255, 255, 127)
					love.graphics.rectangle("fill", x, y-tilesoffset, 373*scale, 9*scale)
				end
			end
			
			love.graphics.setScissor()
			
			guielements["tilesscrollbar"]:draw()
			
			if editentities then
				local tilei, list = getentitylistpos(love.mouse.getX(), love.mouse.getY())
				if tilei then
					local tile = entitiesform[list][tilei]
					local customenemydescription = (tile and (not tonumber(tile)) and tablecontains(customenemies, tile) and 
						enemiesdata[tile] and enemiesdata[tile].description)
					if tonumber(tile) or customenemydescription then
						local newstring = entitydescriptions[tile]
						if customenemydescription then
							newstring = enemiesdata[tile].description
						elseif TEXT["entitydescriptions"] and TEXT["entitydescriptions"][tile] then
							newstring = TEXT["entitydescriptions"][tile]
						end
						if string.len(newstring) > 49 then
							local chari = 49
							if string.len(newstring) < 98 then
								--proper wrapping with spaces
								while string.sub(newstring, chari+1, chari+1) ~= " " do
									chari = chari - 1
								end
								newstring = string.sub(newstring, 1, chari) .. "\n" .. string.sub(newstring, chari+2, 98)
							else
								newstring = string.sub(newstring, 1, chari) .. "\n" .. string.sub(newstring, chari+1, 98)
							end
						end
						properprintF(newstring, 3*scale, 205*scale)
					else
						properprint(tile, 3*scale, 205*scale)
					end
				end
			elseif editmtobjects then
				if mtbutton == 1 then
					properprintF(TEXT["move up"], 10*scale, 210*scale)
				elseif mtbutton == 2 then
					properprintF(TEXT["move down"], 10*scale, 210*scale)
				elseif mtbutton == 3 then
					properprintF(TEXT["delete"], 10*scale, 210*scale)
				else
					local entry = getlistpos(mousex, mousey)
					if entry and entry <= #multitileobjects-1 then
						if mousex < 20*scale and entry <= 9 then
							properprintF(TEXT["shortcut: hold ctrl and press number"], 10*scale, 210*scale)
						else
							properprintF(TEXT["right click to rename"], 10*scale, 210*scale)
						end
					end
				end
			else
				if tile then
					local actualtile = tile+tileliststart-1
					if animatedtilelist then
						actualtile = tile+tileliststart-1+90000
					end
					if tilequads[actualtile] then
						love.graphics.setColor(255, 255, 255, 255)
						if tilequads[actualtile].collision and tilequads[actualtile].platform then
							love.graphics.setColor(255, 255, 255, 255)
							properprint("collision : semi.", 3*scale, 205*scale)
						elseif tilequads[actualtile].collision then
							love.graphics.setColor(255, 255, 255, 255)
							properprint("collision : yes", 3*scale, 205*scale)
						else
							love.graphics.setColor(255, 255, 255, 127)
							properprint("collision : no", 3*scale, 205*scale)
						end
						if tilequads[actualtile].collision and tilequads[actualtile].portalable then
							love.graphics.setColor(255, 255, 255, 255)
							properprint("portalable: yes", 3*scale, 215*scale)
						else
							love.graphics.setColor(255, 255, 255, 127)
							properprint("portalable: no", 3*scale, 215*scale)
						end
						if tilequads[actualtile].collision and (tilequads[actualtile].debris and blockdebrisquads[tilequads[actualtile].debris]) then
							love.graphics.setColor(255, 255, 255, 255)
							properprint("breakable : hard", 140*scale, 205*scale)
						elseif tilequads[actualtile].collision and tilequads[actualtile].breakable then
							love.graphics.setColor(255, 255, 255, 255)
							properprint("breakable : yes", 140*scale, 205*scale)
						else
							love.graphics.setColor(255, 255, 255, 127)
							properprint("breakable : no", 140*scale, 205*scale)
						end
						if tilequads[actualtile].foreground then
							love.graphics.setColor(255, 255, 255, 255)
							properprint("foreground: yes", 140*scale, 215*scale)
						else
							love.graphics.setColor(255, 255, 255, 127)
							properprint("foreground: no", 140*scale, 215*scale)
						end
						
						love.graphics.setColor(255, 255, 255, 255)
						properprint("id: " .. actualtile, (396-(#("id: " .. actualtile)*8))*scale, 215*scale)
					end
				end
			end
			
			love.graphics.setColor(255, 255, 255)

			if editentities and not editenemies and editorstate == "tiles" and editormenuopen and entitytooltipobject then
				entitytooltipobject:draw(math.max(0, tooltipa))
			end

			--tilemenuy
			love.graphics.pop()
		elseif editorstate == "main" then		
			--MINIMAP
			love.graphics.setColor(255, 255, 255)
			properprintF(TEXT["minimap"], 3*scale, 21*scale)
			love.graphics.rectangle("fill", minimapx*scale, minimapy*scale, 394*scale, 34*scale)
			love.graphics.setColor(backgroundcolor[background])
			love.graphics.rectangle("fill", (minimapx+2)*scale, (minimapy+2)*scale, 390*scale, 30*scale)
			
			local lmap = map
			
			love.graphics.setScissor((minimapx+2)*scale, (minimapy+2)*scale, 390*scale, 30*scale)
			
			for x = 1, mapwidth do
				for y = math.floor(yscroll)+1, math.min(mapheight, math.ceil(yscroll)+16) do
					if x-minimapscroll > 0 and x-minimapscroll < 196 then
						if lmap[x][y] then
							local id = lmap[x][y][1]
							if id ~= nil and id ~= 0 and not tilequads[id].invisible then
								if id > 90000 then
									if animatedrgblist[id] and animatedrgblist[id][animatedtilesframe[id]] then
										love.graphics.setColor(animatedrgblist[id][animatedtilesframe[id]])
										love.graphics.rectangle("fill", (minimapx+x*2-minimapscroll*2)*scale, (minimapy+(y+1)*2-(math.floor(yscroll)+1)*2-math.fmod(yscroll, 1)*2)*scale, 2*scale, 2*scale)
									end
								else 
									if rgblist[id] then
										love.graphics.setColor(rgblist[id])
										love.graphics.rectangle("fill", (minimapx+x*2-minimapscroll*2)*scale, (minimapy+(y+1)*2-(math.floor(yscroll)+1)*2-math.fmod(yscroll, 1)*2)*scale, 2*scale, 2*scale)
									end
								end
							end
						end
					end
				end
			end
			
			love.graphics.setScissor()
			
			love.graphics.setColor(255, 0, 0)
			drawrectangle(splitxscroll[1]*2+minimapx-minimapscroll*2, minimapy, (width+2)*2, 34)
			drawrectangle(splitxscroll[1]*2+minimapx-minimapscroll*2+1, minimapy+1, (width+1)*2, 32)
			guielements["autoscrollcheckbox"]:draw()
			
			if minimapdragging == false then
				guielements["savebutton"]:draw()
				guielements["menubutton"]:draw()
				guielements["testbutton"]:draw()
				guielements["testbuttonplayer"]:draw()
				guielements["widthbutton"]:draw()
				guielements["timelimitdecrease"]:draw()
				guielements["timelimitinput"]:draw()
				--properprint(mariotimelimit, 29*scale, 154*scale)
				guielements["timelimitincrease"]:draw()
				properprintF(TEXT["timelimit"], 8*scale, 142*scale)
				
				--left side
				
				properprintF(TEXT["music"], 8*scale, 93*scale)
				--guielements["backgrounddropdown"]:draw()
				properprintF(TEXT["background color"], 8*scale, 69*scale)
				guielements["backgroundinput1"]:draw()
				guielements["backgroundinput2"]:draw()
				guielements["backgroundinput3"]:draw()
				for i = 1, #backgroundcolor do
					guielements["defaultcolor" .. i]:draw()
				end
				
				if guielements["portalgundropdown"].extended then
					guielements["spritesetdropdown"]:draw()
					properprintF(TEXT["spriteset"], 8*scale, 117*scale)
					guielements["musicdropdown"]:draw()
					if musici == 7 then
						guielements["custommusiciinput"]:draw()
					end
					
					properprintF(TEXT["portal gun"], 8*scale, 166*scale)
					guielements["portalgundropdown"]:draw()
				else
					properprintF(TEXT["portal gun"], 8*scale, 166*scale)
					guielements["portalgundropdown"]:draw()
					
					guielements["spritesetdropdown"]:draw()
					properprintF(TEXT["spriteset"], 8*scale, 117*scale)
					guielements["musicdropdown"]:draw()
					if musici == 7 then
						guielements["custommusiciinput"]:draw()
					end
				end
				
				--right side
				guielements["autoscrollingcheckbox"]:draw()
				guielements["autoscrollingscrollbar"]:draw()
				if autoscrolling then
					love.graphics.setColor(255, 255, 255, 255)
				else
					love.graphics.setColor(150, 150, 150, 255)
				end
				properprint(formatscrollnumber(autoscrollingspeed), (guielements["autoscrollingscrollbar"].x+1+guielements["autoscrollingscrollbar"].xrange*guielements["autoscrollingscrollbar"].value)*scale, (guielements["autoscrollingscrollbar"].y+1)*scale)

				guielements["custombackgroundcheckbox"]:draw()
				guielements["customforegroundcheckbox"]:draw()
				
				if custombackground then
					love.graphics.setColor(255, 255, 255, 255)
				else
					love.graphics.setColor(150, 150, 150, 255)
				end
				properprintF(TEXT["scrollfactor"], 199*scale, 146*scale)
				if customforeground then
					love.graphics.setColor(255, 255, 255, 255)
				else
					love.graphics.setColor(150, 150, 150, 255)
				end
				properprintF(TEXT["scrollfactor"], 199*scale, 178*scale)
				
				guielements["scrollfactoryscrollbar"]:draw()
				guielements["scrollfactorxscrollbar"]:draw()
				guielements["scrollfactor2yscrollbar"]:draw()
				guielements["scrollfactor2xscrollbar"]:draw()
				if custombackground then
					love.graphics.setColor(255, 255, 255, 255)
				else
					love.graphics.setColor(150, 150, 150, 255)
				end
				properprint(formatscrollnumber(scrollfactor), (guielements["scrollfactorxscrollbar"].x+1+guielements["scrollfactorxscrollbar"].xrange*guielements["scrollfactorxscrollbar"].value)*scale, 146*scale)
				properprint(formatscrollnumber(scrollfactory), (guielements["scrollfactorxscrollbar"].x+1+guielements["scrollfactoryscrollbar"].xrange*guielements["scrollfactoryscrollbar"].value)*scale, 156*scale)
				if customforeground then
					love.graphics.setColor(255, 255, 255, 255)
				else
					love.graphics.setColor(150, 150, 150, 255)
				end
				properprint(formatscrollnumber(scrollfactor2), (guielements["scrollfactor2xscrollbar"].x+1+guielements["scrollfactor2xscrollbar"].xrange*guielements["scrollfactor2xscrollbar"].value)*scale, 178*scale)
				properprint(formatscrollnumber(scrollfactor2y), (guielements["scrollfactor2xscrollbar"].x+1+guielements["scrollfactor2yscrollbar"].xrange*guielements["scrollfactor2yscrollbar"].value)*scale, 188*scale)

				love.graphics.setColor(255, 255, 255, 255)

				--level properties
				guielements["levelpropertiesdropdown"]:draw()
				
				if guielements["foregrounddropdown"].extended then
					guielements["backgrounddropdown"]:draw()
					guielements["foregrounddropdown"]:draw()
				else
					guielements["foregrounddropdown"]:draw()
					guielements["backgrounddropdown"]:draw()
				end

				if levelpropertiesdropdown then
					local len = 9
					local lpd = guielements["levelpropertiesdropdown"]
					local high = guielements["levelpropertiesdropdown"]:inhighlight(love.mouse.getPosition())
					love.graphics.setColor(0,0,0)
					love.graphics.rectangle("fill", (lpd.x+1)*scale, (lpd.y+12)*scale, (lpd.width+5-2)*scale, (8*len+1-1)*scale)
					if high then
						love.graphics.setColor(255,255,255)
					else
						love.graphics.setColor(127,127,127)
					end
					drawrectangle(lpd.x, lpd.y+12, lpd.width+5, 8*len+1)
					guielements["intermissioncheckbox"]:draw()
					guielements["warpzonecheckbox"]:draw()
					guielements["underwatercheckbox"]:draw()
					guielements["bonusstagecheckbox"]:draw()
					guielements["edgewrappingcheckbox"]:draw()
					guielements["lightsoutcheckbox"]:draw()
					guielements["lowgravitycheckbox"]:draw()
				end
			end
		elseif editorstate == "maps" then
			love.graphics.setColor(0, 0, 0, 210)
			love.graphics.rectangle("fill", 2*scale, 19*scale, 100*scale, 203*scale)
			love.graphics.rectangle("fill", 103*scale, 195*scale, 295*scale, 27*scale)
			love.graphics.setColor(0, 0, 0, 50)
			love.graphics.rectangle("fill", 103*scale, 19*scale, 295*scale, 175*scale)
			
			guielements["worldscrollbar"]:draw()
			guielements["levelscrollbar"]:draw()
			
			love.graphics.setScissor(2*scale, 20*scale, 100*scale, 201*scale)
			for i = 1, #mappacklevels do --world
				if guielements["world-" .. i].y > 0 and guielements["world-" .. i].y < height*16 then
					guielements["world-" .. i]:draw()
				end
			end
			guielements["newworld"]:draw()
			love.graphics.setScissor()
			
			
			love.graphics.setScissor(104*scale, 20*scale, 278*scale, 173*scale)
			local i = currentworldselection
			for j = 1, #mappacklevels[i] do --level
				local y = (46+((j-1)*39)-(guielements["levelscrollbar"].value*math.max(0, (#mappacklevels[currentworldselection]*39)+17-173)))
				if y > 0 and y < height*16 then
					love.graphics.setColor(255, 255, 255)
					properprint("sub", 106*scale, y*scale)
					for k = 0, mappacklevels[i][j] do --sublevel
						local name = i .. "-" .. j .. "_" .. k
						guielements[name]:draw()
					end
					if guielements["newsublevel-" .. i .. "-" .. j].active then
						guielements["newsublevel-" .. i .. "-" .. j]:draw()
					end
				end
			end
			guielements["newlevel-" .. i]:draw()

			love.graphics.setScissor()
			
			love.graphics.setColor(255, 255, 255)
			properprintF(TEXT["do not forget to save\nyour current level!"], 108*scale, 200*scale)
			guielements["savebutton2"]:draw()
			--guielements["autosavecheckbox"]:draw()
			
			if levelrightclickmenu.active then
				levelrightclickmenu:draw()
			end
		elseif editorstate == "tools" then
			guielements["linkbutton"]:draw()
			guielements["portalbutton"]:draw()
			guielements["selectionbutton"]:draw()
			guielements["powerlinebutton"]:draw()
			
			love.graphics.setColor(51, 51, 51)
			love.graphics.rectangle("fill", 140*scale, 22*scale, 255*scale, 69*scale)
			love.graphics.rectangle("fill", 132*scale, (22+(currenttooldesc-1)*18)*scale, 8*scale, 15*scale)
			love.graphics.setColor(0, 0, 0)
			love.graphics.rectangle("fill", 141*scale, 23*scale, 253*scale, 67*scale)
			love.graphics.rectangle("fill", 132*scale, (23+(currenttooldesc-1)*18)*scale, 9*scale, 13*scale)
			love.graphics.setColor(255, 255, 255)
			properprintF(TEXT["tool descriptions"][currenttooldesc], 143*scale, 26*scale)
			
			properprintF(TEXT["mappack title:"], 5*scale, 106*scale)
			properprintF(TEXT["author:"], 5*scale, 131*scale)
			properprintF(TEXT["description:"], 5*scale, 156*scale)
			guielements["edittitle"]:draw()
			guielements["editauthor"]:draw()
			guielements["editdescription"]:draw()
			guielements["savesettings"]:draw()

			guielements["dropshadowcheckbox"]:draw()
			guielements["realtimecheckbox"]:draw()
			guielements["continuemusiccheckbox"]:draw()
			guielements["nolowtimecheckbox"]:draw()
			
			properprintF(TEXT["lives:"], 228*scale, 106*scale)
			guielements["livesincrease"]:draw()
			if mariolivecount == false then
				properprint("inf", 306*scale, 106*scale)
			else
				properprint(mariolivecount, 306*scale, 106*scale)
			end
			guielements["livesdecrease"]:draw()
			
			properprintF(TEXT["camera:"], 228*scale, 132*scale)
			guielements["cameradropdown"]:draw()

			properprintF(TEXT["physics:"], 228*scale, 119*scale)
			guielements["physicsdropdown"]:draw()
			
			properprintF("icon:", 150*scale, 138*scale)
			
			if mousex > 151*scale and mousey > 146*scale and mousex < 203*scale and mousey < 198*scale then
				love.graphics.setColor(255, 255, 255)
			else
				love.graphics.setColor(127, 127, 127)
			end
			local w = love.graphics.getLineWidth()
			love.graphics.setLineWidth(scale)
			love.graphics.rectangle("line", 151.5*scale, 146.5*scale, 51*scale, 51*scale)
			love.graphics.setColor(255, 255, 255)
			if editmappackicon ~= nil then
				local scale2w = scale*50 / math.max(1, editmappackicon:getWidth())
				local scale2h = scale*50 / math.max(1, editmappackicon:getHeight())
				love.graphics.draw(editmappackicon, 152*scale, 147*scale, 0, scale2w, scale2h)
			else
				love.graphics.draw(mappacknoicon, 152*scale, 147*scale, 0, scale, scale)
			end
			love.graphics.setLineWidth(w)
		elseif editorstate == "custom" then
			love.graphics.setColor(255, 255, 255)
			love.graphics.rectangle("fill", 5*scale, 37*scale, 390*scale, scale)
			love.graphics.rectangle("fill", 394*scale, 38*scale, scale, 180*scale)
			love.graphics.rectangle("fill", 5*scale, 38*scale, scale, 180*scale)
			love.graphics.rectangle("fill", 5*scale, 218*scale, 390*scale, scale)
			
			guielements["graphicscustomtab"]:draw()
			guielements["tilescustomtab"]:draw()
			guielements["backgroundscustomtab"]:draw()
			guielements["soundscustomtab"]:draw()
			guielements["textcustomtab"]:draw()
			guielements["enemiescustomtab"]:draw()
			
			if customtabstate == "graphics" then
				love.graphics.setColor(255, 255, 255)
				properprint(currentcustomimage[3], 10*scale, 41*scale)
				love.graphics.rectangle("fill", 10*scale, 50*scale, 164*scale, 164*scale)
				love.graphics.draw(customimagebackimg, 12*scale, 52*scale, 0, scale, scale)
				local img = _G[currentcustomimage[2]]
				local sx, sy = math.max(1, math.floor(160/img:getWidth())), math.max(1, math.floor(160/img:getWidth()))
				if img:getWidth() > 160 or img:getHeight() > 160 then
					if img:getHeight() > img:getWidth() then
						sx, sy = 160/img:getHeight(), 160/img:getHeight()
					else
						sx, sy = 160/img:getWidth(), 160/img:getWidth()
					end
				elseif img:getHeight() > img:getWidth() then
					sx, sy = math.max(1, math.floor(160/img:getHeight())), math.max(1, math.floor(160/img:getHeight()))
				end
				love.graphics.draw(img, 92*scale, 132*scale, 0, sx*scale, sy*scale, img:getWidth()/2, img:getHeight()/2)
				
				properprintF(TEXT["current image"], 176*scale, 54*scale)
				properprintF(TEXT["image template"], 176*scale, 79*scale)
				properprintF(TEXT["replace image"], 176*scale, 125*scale)
				love.graphics.setColor(127, 127, 127)
				properprintF(TEXT["drag an image file into\nthe square to replace it!"], 184*scale, 134*scale)
				properprintF(TEXT["or 'open folder' and\nchange the image there!"], 184*scale, 157*scale)
				love.graphics.setColor(255, 255, 255)
				
				guielements["exportimagetemplate"]:draw()
				guielements["openfoldercustom"]:draw()
				guielements["saveimage"]:draw()
				guielements["resetimage"]:draw()
				guielements["currentimagedropdown"]:draw()
			elseif customtabstate == "tiles" then
				love.graphics.setColor(255, 255, 255)
				properprintF(TEXT["custom tileset"], 10*scale, 41*scale)
				love.graphics.rectangle("fill", 10*scale, 50*scale, 164*scale, 164*scale)
				love.graphics.draw(customimagebackimg, 12*scale, 52*scale, 0, scale, scale)
				local mx, my = love.mouse.getPosition()
				local img
				--show tile properties
				if mx > 375*scale and mx < (375+15)*scale and my > 199*scale and my < (199+15)*scale then
					img = tilepropertiesimg
				elseif customtiles then
					img = customtilesimg[1]
				end
				if img then
					local sx, sy = math.max(1, math.floor(160/img:getWidth())), math.max(1, math.floor(160/img:getWidth()))
					if img:getWidth() > 160 or img:getHeight() > 160 then
						if img:getHeight() > img:getWidth() then
							sx, sy = 160/img:getHeight(), 160/img:getHeight()
						else
							sx, sy = 160/img:getWidth(), 160/img:getWidth()
						end
					elseif img:getHeight() > img:getWidth() then
						sx, sy = math.max(1, math.floor(160/img:getHeight())), math.max(1, math.floor(160/img:getHeight()))
					end
					love.graphics.draw(img, 92*scale, 132*scale, 0, sx*scale, sy*scale, img:getWidth()/2, img:getHeight()/2)
				end
				properprintF(TEXT["tileset template"], 176*scale, 54*scale)
				properprintF(TEXT["add tileset"], 176*scale, 100*scale)
				properprintF(TEXT["animated tiles"], 176*scale, 154*scale)
				love.graphics.setColor(127, 127, 127)
				properprintF(TEXT["drag an image file into\nthe square to replace it!"], 184*scale, 109*scale)
				properprintF(TEXT["or 'open folder' and\nchange the image there!"], 184*scale, 132*scale)
				love.graphics.setColor(255, 255, 255)
				
				guielements["exporttilestemplate"]:draw()
				guielements["exportanimatedtilestemplate"]:draw()
				guielements["openfoldertilescustom"]:draw()
				guielements["openfolderanimatedtilescustom"]:draw()
				guielements["saveimage"]:draw()
				love.graphics.setColor(127, 127, 127)
				if mx > 375*scale and mx < (375+15)*scale and my > 199*scale and my < (199+15)*scale then
					love.graphics.setColor(255, 255, 255)
				end
				love.graphics.rectangle("fill", 375*scale, 199*scale, 15*scale, 15*scale)
				love.graphics.setColor(0, 0, 0)
				love.graphics.rectangle("fill", (375+1)*scale, (199+1)*scale, 13*scale, 13*scale)
				love.graphics.setColor(255, 255, 255)
				love.graphics.draw(tilepropertiesimg, (375+2)*scale, (199+2)*scale, 0, (11/tilepropertiesimg:getWidth())*scale, (11/tilepropertiesimg:getHeight())*scale)
			elseif customtabstate == "backgrounds" then
				love.graphics.setColor(255, 255, 255)
				properprintF(TEXT["custom background"], 10*scale, 41*scale)
				love.graphics.rectangle("fill", 10*scale, 50*scale, 164*scale, 164*scale)
				love.graphics.draw(customimagebackimg, 12*scale, 52*scale, 0, scale, scale)
				
				if editorbackgroundstate == "background" then
					love.graphics.setColor(255, 255, 255)
				else
					love.graphics.setColor(255, 255, 255, 150)
				end
				local w, h = width*16, height*16
				local sx, sy = math.max(1, math.floor(160/w)), math.max(1, math.floor(160/w))
				sx, sy = 160/w, 160/w
				if custombackgroundimg then
					love.graphics.push()
					love.graphics.setScissor(12*scale, 52*scale, 160*scale, 160*scale)
					love.graphics.translate(12*scale, (132-(h*sy)/2)*scale)
					love.graphics.scale(sx, sy)
					rendercustombackground(0,0,0,0)
					love.graphics.pop()
					love.graphics.setScissor()
				end
				if editorbackgroundstate == "foreground" then
					love.graphics.setColor(255, 255, 255)
				else
					love.graphics.setColor(255, 255, 255, 150)
				end
				if customforegroundimg then
					love.graphics.push()
					love.graphics.setScissor(12*scale, 52*scale, 160*scale, 160*scale)
					love.graphics.translate(12*scale, (132-(h*sy)/2)*scale)
					love.graphics.scale(sx, sy)
					rendercustomforeground(0,0,0,0)
					love.graphics.pop()
					love.graphics.setScissor()
				end
				love.graphics.setColor(255, 255, 255)
				properprintF(TEXT["current"], 176*scale, 54*scale)
				properprintF(TEXT["add background"], 176*scale, 79*scale)
				love.graphics.setColor(127, 127, 127)
				properprintF(TEXT["drag file to add custom\nbackground or foreground!"], 184*scale, 88*scale)
				properprintF(TEXT["or just put a .png\nin the backgrounds folder"], 184*scale, 112*scale)
				properprintF(TEXT["add a .json file\nfor animated backgrounds"], 184*scale, 159*scale)
				love.graphics.setColor(255, 255, 255)
				properprintF(TEXT["animated backgrounds"], 176*scale, 150*scale)

				guielements["openfolderbackgroundscustom"]:draw()
				guielements["currentbackgrounddropdown"]:draw()
				guielements["saveimage"]:draw()
			elseif customtabstate == "sounds" then
				love.graphics.setColor(255, 255, 255)
				properprintF(TEXT["custom sounds"], 10*scale, 41*scale)
				love.graphics.rectangle("fill", 10*scale, 50*scale, 164*scale, 164*scale)
				love.graphics.draw(customimagebackimg, 12*scale, 52*scale, 0, scale, scale)
				love.graphics.draw(gateimg, gatequad[5], 92*scale, 132*scale, math.sin(((coinanimation-1)/5)*(math.pi*2))/6, 8*scale, 8*scale, 8, 8)
				properprintF(TEXT["current sound"], 176*scale, 54*scale)
				properprintF(TEXT["sound template"], 176*scale, 79*scale)
				properprintF(TEXT["replace sound"], 176*scale, 124*scale)
				properprintF(TEXT["add music"], 176*scale, 155*scale)
				love.graphics.setColor(127, 127, 127)
				properprintF(TEXT["open sounds folder to\nreplace sounds!"], 184*scale, 133*scale)
				properprintF(TEXT["put any .mp3 or .ogg\nin the music folder!"], 184*scale, 181*scale)
				love.graphics.setColor(255, 255, 255)
				
				guielements["exportimagetemplate"]:draw()
				guielements["openfoldersoundscustom"]:draw()
				guielements["openfoldermusiccustom"]:draw()
				guielements["savesounds"]:draw()
				guielements["currentsounddropdown"]:draw()
			elseif customtabstate == "text" then
				guielements["endingtexttab"]:draw()
				guielements["hudtexttab"]:draw()
				guielements["castletexttab"]:draw()
				guielements["levelscreentexttab"]:draw()
				guielements["savecustomtext"]:draw()
				if textstate == "ending" then
					properprintF(TEXT["ending text"], 11*scale, 57*scale)
					guielements["editendingtext1"]:draw()
					guielements["editendingtext2"]:draw()
					--love.graphics.setColor(textcolors[textcolorl])
					--properprintF(TEXT["color"], 24*scale, 100*scale)
					--guielements["endingcolor<"]:draw()
					--guielements["endingcolor>"]:draw()
					guielements["endingcolor"]:draw()
				elseif textstate == "hud" then
					love.graphics.setColor(255, 255, 255)
					properprintF(TEXT["player name"], 11*scale, 57*scale)
					guielements["editplayername"]:draw()
					--love.graphics.setColor(textcolors[textcolorp])
					--properprintF(TEXT["color"], 23*scale, 86*scale)
					--guielements["hudcolor<"]:draw()
					--guielements["hudcolor>"]:draw()
					guielements["hudworldlettercheckbox"]:draw()
					guielements["hudvisiblecheckbox"]:draw()
					guielements["hudoutlinecheckbox"]:draw()
					guielements["hudsimplecheckbox"]:draw()
					guielements["hudcolor"]:draw()
				elseif textstate == "castle" then
					love.graphics.setColor(255, 255, 255)
					properprintF(TEXT["toad"], 11*scale, 57*scale)
					guielements["edittoadtext1"]:draw()
					guielements["edittoadtext2"]:draw()
					guielements["edittoadtext3"]:draw()
					properprintF(TEXT["peach"], 11*scale, 111*scale)
					guielements["editpeachtext1"]:draw()
					guielements["editpeachtext2"]:draw()
					guielements["editpeachtext3"]:draw()
					guielements["editpeachtext4"]:draw()
					guielements["editpeachtext5"]:draw()
					guielements["stevecheckbox"]:draw()
				elseif textstate == "levelscreen" then
					love.graphics.setColor(255, 255, 255)
					local sublev = ""
					if mariosublevel ~= 0 then
						sublev = "-" .. mariosublevel
					end
					properprintF(TEXT["level "] .. marioworld .. "-" .. mariolevel .. sublev, 11*scale, 57*scale)
					properprintF(TEXT["caption"], 11*scale, 70*scale)
					guielements["editlevelscreentext"]:draw()
					love.graphics.setColor(127, 127, 127)
					properprintF(TEXT["add a background image\nby naming it\n'"] .. marioworld .. "-" .. mariolevel .. "levelscreen.png'", 159*scale, 110*scale)
					properprintF(TEXT["or drag an image file\ninto the square!"], 159*scale, 143*scale)
					love.graphics.setColor(255, 255, 255)
					love.graphics.rectangle("fill", 11*scale, 110*scale, 144*scale, 82*scale)
					properprintF(TEXT["preview"], 11*scale, 100*scale)
					
					-- levelscreen preview
					love.graphics.setScissor(12*scale, 111*scale, 142*scale, 80*scale)
					love.graphics.push()
					love.graphics.translate(12*scale, 111*scale)
					love.graphics.scale((80/224), (80/224))
					
					love.graphics.setColor(0, 0, 0)
					love.graphics.rectangle("fill", 0, 0, 400*scale, 224*scale)
					love.graphics.setColor(255, 255, 255)
					
					if levelscreenimage then
						love.graphics.draw(levelscreenimage, 0, 0, 0, scale, scale)
					end
					
					local world = marioworld
					if hudworldletter and tonumber(world) and world > 9 and world <= 9+#alphabet then
						world = alphabet:sub(world-9, world-9)
					end
					properprintF(TEXT["world "] .. world .. "-" .. mariolevel, (width/2*16)*scale-40*scale, 72*scale - (players-1)*6*scale)
					
					--for i = 1, 1 do
					local i = 1
					local x = (width/2*16)*scale-29*scale
					local y = (97 + (i-1)*20 - (players-1)*8)*scale
					local v = characters.data[mariocharacter[i]]
					
					for j = 1, #characters.data[mariocharacter[i]]["animations"] do
						love.graphics.setColor(mariocolors[i][j])
						if playertype == "classic" or playertype == "cappy" or not portalgun then--no portal gun
							 love.graphics.draw(v["animations"][j], v["small"]["idle"][5], x+(v.smalloffsetX)*scale, y+(11-v.smalloffsetY)*scale, 0, scale, scale, v.smallquadcenterX, v.smallquadcenterY)
						else
							love.graphics.draw(v["animations"][j], v["small"]["idle"][3], x+(v.smalloffsetX)*scale, y+(11-v.smalloffsetY)*scale, 0, scale, scale, v.smallquadcenterX, v.smallquadcenterY)
						end
					end
			
					--hat
					
					offsets = hatoffsets["idle"]
					if #mariohats[i] > 1 or mariohats[i][1] ~= 1 then
						local yadd = 0
						for j = 1, #mariohats[i] do
							love.graphics.setColor(255, 255, 255)
							love.graphics.draw(hat[mariohats[i][j]].graphic, hat[mariohats[i][j]].quad[1], x+(v.smalloffsetX)*scale, y+(11-v.smalloffsetY)*scale, 0, scale, scale, v.smallquadcenterX - hat[mariohats[i][j]].x + offsets[1], v.smallquadcenterY - hat[mariohats[i][j]].y + offsets[2] + yadd)
							yadd = yadd + hat[mariohats[i][j]].height
						end
					elseif #mariohats[i] == 1 then
						love.graphics.setColor(mariocolors[i][1])
						love.graphics.draw(hat[mariohats[i][1]].graphic, hat[mariohats[i][1]].quad[1], x+(v.smalloffsetX)*scale, y+(11-v.smalloffsetY)*scale, 0, scale, scale, v.smallquadcenterX - hat[mariohats[i][1]].x + offsets[1], v.smallquadcenterY - hat[mariohats[i][1]].y + offsets[2])
					end
				
					love.graphics.setColor(255, 255, 255, 255)
					
					if playertype == "classic" or playertype == "cappy" or not portalgun then--no portal gun
						love.graphics.draw(v["animations"][0], v["small"]["idle"][5], x+(v.smalloffsetX)*scale, y+(11-v.smalloffsetY)*scale, 0, scale, scale, v.smallquadcenterX, v.smallquadcenterY)
					else
						love.graphics.draw(v["animations"][0], v["small"]["idle"][3], x+(v.smalloffsetX)*scale, y+(11-v.smalloffsetY)*scale, 0, scale, scale, v.smallquadcenterX, v.smallquadcenterY)
					end
					
					properprint("*  3", (width/2*16)*scale-8*scale, y+7*scale)
					--end
					
					local s = guielements["editlevelscreentext"].value
					properprint(s, (width/2*16)*scale-string.len(s)*4*scale, 200*scale)
					
					love.graphics.pop()
					love.graphics.setScissor()
				end
			elseif customtabstate == "enemies" then
				love.graphics.setColor(255, 255, 255)
				if currentcustomenemy[2] then
					properprint(currentcustomenemy[2], 10*scale, 41*scale)
				else
					properprint("custom enemies: none", 10*scale, 41*scale)
				end
				love.graphics.rectangle("fill", 10*scale, 50*scale, 164*scale, 164*scale)
				love.graphics.draw(customimagebackimg, 12*scale, 52*scale, 0, scale, scale)
				
				if enemiesdata[currentcustomenemy[2]] and enemiesdata[currentcustomenemy[2]].graphic then
					local en = currentcustomenemy[2]
					local img = enemiesdata[en].graphic
					local w, h = img:getWidth(), img:getHeight()
					local quad = false
					if enemiesdata[en].quadbase then
						quad = enemiesdata[en].quadbase[spriteset][currentcustomenemy.quadi]
						local qx, qy, qw, qh = quad:getViewport()
						w, h = qw, qh
					end
					local sx, sy = math.max(1, math.floor(160/w)), math.max(1, math.floor(160/w))
					if w > 160 or h > 160 then
						if h > w then
							sx, sy = 160/h, 160/h
						else
							sx, sy = 160/w, 160/w
						end
					elseif h > w then
						sx, sy = math.max(1, math.floor(160/h)), math.max(1, math.floor(160/h))
					end
					if currentcustomenemy.animationdirection == "right" then
						sx = -sx
					end
					if quad then
						love.graphics.draw(img, quad, 92*scale, 132*scale, 0, sx*scale, sy*scale, w/2, h/2)
					else
						love.graphics.draw(img, 92*scale, 132*scale, 0, sx*scale, sy*scale, w/2, h/2)
					end
				end

				properprintF(TEXT["current enemy"], 176*scale, 54*scale)
				properprintF(TEXT["enemy template"], 176*scale, 79*scale)
				properprintF(TEXT["add new enemies"], 176*scale, 125*scale)
				love.graphics.setColor(127, 127, 127)
				properprintF(TEXT["'open folder' to add\nmore enemies!"], 184*scale, 134*scale)
				properprintF(TEXT["making enemies is simple!\nno coding required.\nopen the .json file\nto add/change properties"], 184*scale, 158*scale)
				love.graphics.setColor(255, 255, 255)
				
				guielements["exportimagetemplate"]:draw()
				guielements["openfolderenemiescustom"]:draw()
				guielements["currentenemydropdown"]:draw()
			end
		elseif editorstate == "animations" then
			if #animations > 0 then
				love.graphics.setScissor(animationguiarea[1]*scale, animationguiarea[2]*scale, (animationguiarea[3]-animationguiarea[1])*scale, (animationguiarea[4]-animationguiarea[2])*scale)
				local completeheight = 14+#animationguilines.triggers*13+12+#animationguilines.conditions*13+12+#animationguilines.actions*13
				local offy = math.max(0, guielements["animationsscrollbarver"].value/1*(completeheight-(animationguiarea[4]-animationguiarea[2])))
				local completewidth = 0
				for i, v in pairs(animationguilines) do
					for k, w in pairs(v) do
						local width = 32+animationlineinset
						for j, z in pairs(w.elements) do
							width = width + w.elements[j].width
						end
						if width > completewidth then
							completewidth = width
						end
					end
				end
				
				local offx = -math.max(0, guielements["animationsscrollbarhor"].value/1*(completewidth-(animationguiarea[3]-animationguiarea[1])))
				
				love.graphics.setColor(255, 255, 255)
				
				local y = animationguiarea[2]+1-offy
				y = y + 2
				
				addanimationtriggerbutton.x = animationguiarea[1]+2+offx
				addanimationtriggerbutton.y = y-2
				addanimationtriggerbutton:draw()
				
				properprintF(TEXT["triggers:"], (animationguiarea[1]+13+offx)*scale, y*scale)
				y = y + 10
				
				for i, v in pairs(animationguilines.triggers) do
					v:draw((animationguiarea[1]+animationlineinset+offx), y)
					y = y + 13
				end
				y = y + 2
				
				addanimationconditionbutton.x = animationguiarea[1]+2+offx
				addanimationconditionbutton.y = y-2
				addanimationconditionbutton:draw()
				
				properprintF(TEXT["conditions:"], (animationguiarea[1]+13+offx)*scale, y*scale)
				y = y + 10
				
				for i, v in pairs(animationguilines.conditions) do
					v:draw((animationguiarea[1]+animationlineinset+offx), y)
					y = y + 13
				end
				y = y + 2
				
				addanimationactionbutton.x = animationguiarea[1]+2+offx
				addanimationactionbutton.y = y-2
				addanimationactionbutton:draw()
				
				properprintF(TEXT["actions:"], (animationguiarea[1]+13+offx)*scale, y*scale)
				y = y + 10
				
				for i, v in pairs(animationguilines.actions) do
					v:draw((animationguiarea[1]+animationlineinset+offx), y)
					y = y + 13
				end
				
				for i, v in pairs(animationguilines) do
					for k, w in pairs(v) do
						for anotherletter, fuck in pairs(w.elements) do
							if fuck.gui and not fuck.gui.priority then
								fuck.gui:draw()
							end
						end
					end
				end
				
				love.graphics.setScissor()
				
				love.graphics.setColor(90, 90, 90)
				drawrectangle(animationguiarea[1]-10, animationguiarea[4], 10, 10)
			end
			
			--GUI not priority
			for i, v in pairs(guielements) do
				if not v.priority and v.active then
					v:draw()
				end
			end
				
				
			if editorstate == "animations" and editormenuopen and not changemapwidthmenu then
				for i, v in pairs(animationguilines) do
					for k, w in pairs(v) do
						for anotherletter, fuck in pairs(w.elements) do
							if fuck.gui and fuck.gui.priority then
								fuck.gui:draw()
							end
						end
					end
				end
			end

			--GUI priority
			for i, v in pairs(guielements) do
				if v.priority and v.active then
					v:draw()
				end
			end
		end
		
		if confirmmenuopen then
			love.graphics.setColor(0,0,0,200)
			love.graphics.rectangle("fill", 0, 0, width*16*scale, height*16*scale)
			love.graphics.setColor(0,0,0)
			love.graphics.rectangle("fill", 69*scale, 71*scale, 262*scale, 82*scale)
			love.graphics.setColor(255, 255, 255)
			drawrectangle(70, 72, 260, 80)

			properprintF(TEXT["are you sure?"], (200-utf8.len(TEXT["are you sure?"])*4)*scale, 80*scale)
			properprintF(TEXT["unsaved changes will be lost!"], (200-utf8.len(TEXT["unsaved changes will be lost!"])*4)*scale, 92*scale)
			guielements["confirmsave"]:draw()
			guielements["confirmexit"]:draw()
			--guielements["confirmcancel"]:draw()
		end
	end
end

--TABS

function maintab()
	if _G["from" .. editorstate .. "tab"] then
		_G["from" .. editorstate .. "tab"]()
	end

	editorstate = "main"
	for i, v in pairs(guielements) do
		v.active = false
	end
	tilemenuy = 0
	tilemenumoving = false
	
	guielements["tabmain"].fillcolor = {0, 0, 0}
	guielements["tabtiles"].fillcolor = {63, 63, 63}
	guielements["tabtools"].fillcolor = {63, 63, 63}
	guielements["tabmaps"].fillcolor = {63, 63, 63}
	guielements["tabcustom"].fillcolor = {63, 63, 63}
	guielements["tabanimations"].fillcolor = {63, 63, 63}
	guielements["tabmain"].active = true
	guielements["tabtiles"].active = true
	guielements["tabtools"].active = true
	guielements["tabmaps"].active = true
	guielements["tabcustom"].active = true
	guielements["tabanimations"].active = true
	
	guielements["autoscrollcheckbox"].active = true
	--guielements["backgrounddropdown"].active = true
	guielements["musicdropdown"].active = true
	if musici == 7 then
		guielements["custommusiciinput"].active = true
	end
	guielements["backgroundinput1"].active = true
	guielements["backgroundinput2"].active = true
	guielements["backgroundinput3"].active = true
	
	for i = 1, #backgroundcolor do
		guielements["defaultcolor" .. i].active = true
	end
	guielements["spritesetdropdown"].active = true
	guielements["timelimitdecrease"].active = true
	guielements["timelimitinput"].active = true
	guielements["timelimitincrease"].active = true
	guielements["portalgundropdown"].active = true
	guielements["savebutton"].active = true
	guielements["menubutton"].active = true
	guielements["testbutton"].active = true
	guielements["testbuttonplayer"].active = true
	guielements["widthbutton"].active = true

	guielements["levelpropertiesdropdown"].active = true
	levelpropertiesactive(levelpropertiesdropdown)
end

function levelpropertiesactive(t)
	guielements["intermissioncheckbox"].active = t
	guielements["warpzonecheckbox"].active = t
	guielements["underwatercheckbox"].active = t
	guielements["bonusstagecheckbox"].active = t
	guielements["edgewrappingcheckbox"].active = t
	guielements["lightsoutcheckbox"].active = t
	guielements["lowgravitycheckbox"].active = t
	
	guielements["autoscrollingcheckbox"].active = not t
	guielements["autoscrollingscrollbar"].active = not t

	guielements["custombackgroundcheckbox"].active = not t
	guielements["customforegroundcheckbox"].active = not t
	guielements["scrollfactorxscrollbar"].active = not t
	guielements["scrollfactoryscrollbar"].active = not t
	guielements["scrollfactor2xscrollbar"].active = not t
	guielements["scrollfactor2yscrollbar"].active = not t
	guielements["backgrounddropdown"].active = not t
	guielements["foregrounddropdown"].active = not t
end

function levelpropertiestoggle()
	levelpropertiesdropdown = not levelpropertiesdropdown
	if levelpropertiesdropdown then
		guielements["levelpropertiesdropdown"].textcolor = {127, 127, 127}
	else
		guielements["levelpropertiesdropdown"].textcolor = {255, 255, 255}
	end
	levelpropertiesactive(levelpropertiesdropdown)
end

function tilestab()
	if _G["from" .. editorstate .. "tab"] then
		_G["from" .. editorstate .. "tab"]()
	end

	editorstate = "tiles"
	for i, v in pairs(guielements) do
		v.active = false
	end
	tilemenuy = 0
	tilemenumoving = false
	
	guielements["tabmain"].fillcolor = {63, 63, 63}
	guielements["tabtiles"].fillcolor = {0, 0, 0}
	guielements["tabtools"].fillcolor = {63, 63, 63}
	guielements["tabmaps"].fillcolor = {63, 63, 63}
	guielements["tabcustom"].fillcolor = {63, 63, 63}
	guielements["tabanimations"].fillcolor = {63, 63, 63}
	guielements["tabmain"].active = true
	guielements["tabtiles"].active = true
	guielements["tabtools"].active = true
	guielements["tabmaps"].active = true
	guielements["tabcustom"].active = true
	guielements["tabanimations"].active = true
	
	guielements["tilesscrollbar"].active = true
	
	guielements["tilesall"].active = true
	guielements["tilessmb"].active = true
	guielements["tilesportal"].active = true
	guielements["tilescustom"].active = true
	guielements["tilesanimated"].active = true
	guielements["tilesobjects"].active = true
	guielements["tilesentities"].active = true
	
	if animatedtileslist then
		tilesanimated()
	elseif editmtobjects then
		tilesobjects()
	elseif editentities then
		tilesentities()
	else
	end
end

function toolstab()
	if _G["from" .. editorstate .. "tab"] then
		_G["from" .. editorstate .. "tab"]()
	end

	editorstate = "tools"
	for i, v in pairs(guielements) do
		v.active = false
	end
	tilemenuy = 0
	tilemenumoving = false
	
	guielements["tabmain"].fillcolor = {63, 63, 63}
	guielements["tabtiles"].fillcolor = {63, 63, 63}
	guielements["tabtools"].fillcolor = {0, 0, 0}
	guielements["tabmaps"].fillcolor = {63, 63, 63}
	guielements["tabcustom"].fillcolor = {63, 63, 63}
	guielements["tabanimations"].fillcolor = {63, 63, 63}
	guielements["tabmain"].active = true
	guielements["tabtiles"].active = true
	guielements["tabtools"].active = true
	guielements["tabmaps"].active = true
	guielements["tabcustom"].active = true
	guielements["tabanimations"].active = true
	
	guielements["linkbutton"].active = true
	guielements["portalbutton"].active = true
	guielements["selectionbutton"].active = true
	guielements["powerlinebutton"].active = true
	guielements["edittitle"].active = true
	guielements["editauthor"].active = true
	guielements["editdescription"].active = true
	guielements["savesettings"].active = true
	
	guielements["livesdecrease"].active = true
	guielements["livesincrease"].active = true
	guielements["physicsdropdown"].active = true
	guielements["cameradropdown"].active = true
	guielements["dropshadowcheckbox"].active = true
	guielements["realtimecheckbox"].active = true
	guielements["continuemusiccheckbox"].active = true
	guielements["nolowtimecheckbox"].active = true
end

function mapstab()
	if _G["from" .. editorstate .. "tab"] then
		_G["from" .. editorstate .. "tab"]()
	end

	editorstate = "maps"
	for i, v in pairs(guielements) do
		v.active = false
	end
	tilemenuy = 0
	tilemenumoving = false
	
	guielements["tabmain"].fillcolor = {63, 63, 63}
	guielements["tabtiles"].fillcolor = {63, 63, 63}
	guielements["tabtools"].fillcolor = {63, 63, 63}
	guielements["tabmaps"].fillcolor = {0, 0, 0}
	guielements["tabcustom"].fillcolor = {63, 63, 63}
	guielements["tabanimations"].fillcolor = {63, 63, 63}
	guielements["tabmain"].active = true
	guielements["tabtiles"].active = true
	guielements["tabtools"].active = true
	guielements["tabmaps"].active = true
	guielements["tabcustom"].active = true
	guielements["tabanimations"].active = true
	
	guielements["worldscrollbar"].active = true
	guielements["levelscrollbar"].active = true
	
	for i = 1, #mappacklevels do --world
		guielements["world-" .. i].active = true
	end
	guielements["newworld"].active = true
	guielements["savebutton2"].active = true
	--guielements["autosavecheckbox"].active = true
	
	switchworldselection(marioworld)
	updatelevelscrollbar()
end

function customtab()
	if _G["from" .. editorstate .. "tab"] then
		_G["from" .. editorstate .. "tab"]()
	end

	editorstate = "custom"
	for i, v in pairs(guielements) do
		v.active = false
	end
	tilemenuy = 0
	tilemenumoving = false
	
	customtabtab(customtabstate)
end

--tabs in tabs
function customtabtab(t)
	local t = t or "graphics"
	for i, v in pairs(guielements) do
		v.active = false
	end
	guielements["tabmain"].fillcolor = {63, 63, 63}
	guielements["tabtiles"].fillcolor = {63, 63, 63}
	guielements["tabtools"].fillcolor = {63, 63, 63}
	guielements["tabmaps"].fillcolor = {63, 63, 63}
	guielements["tabcustom"].fillcolor = {0, 0, 0}
	guielements["tabanimations"].fillcolor = {63, 63, 63}
	guielements["tabmain"].active = true
	guielements["tabtiles"].active = true
	guielements["tabtools"].active = true
	guielements["tabmaps"].active = true
	guielements["tabcustom"].active = true
	guielements["tabanimations"].active = true
	
	guielements["graphicscustomtab"].textcolor = {127, 127, 127}
	guielements["tilescustomtab"].textcolor = {127, 127, 127}
	guielements["backgroundscustomtab"].textcolor = {127, 127, 127}
	guielements["soundscustomtab"].textcolor = {127, 127, 127}
	guielements["textcustomtab"].textcolor = {127, 127, 127}
	guielements["enemiescustomtab"].textcolor = {127, 127, 127}
	guielements["graphicscustomtab"].active = true
	guielements["tilescustomtab"].active = true
	guielements["backgroundscustomtab"].active = true
	guielements["soundscustomtab"].active = true
	guielements["textcustomtab"].active = true
	guielements["enemiescustomtab"].active = true
	
	if t == "graphics" then
		guielements["graphicscustomtab"].textcolor = {255, 255, 255}
		guielements["currentimagedropdown"].active = true
		guielements["exportimagetemplate"].active = true
		guielements["openfoldercustom"].active = true
		guielements["saveimage"].active = true
		guielements["resetimage"].active = true
	elseif t == "tiles" then
		guielements["tilescustomtab"].textcolor = {255, 255, 255}
		guielements["exporttilestemplate"].active = true
		guielements["exportanimatedtilestemplate"].active = true
		guielements["openfoldertilescustom"].active = true
		guielements["openfolderanimatedtilescustom"].active = true
		guielements["saveimage"].active = true
	elseif t == "backgrounds" then
		guielements["backgroundscustomtab"].textcolor = {255, 255, 255}
		guielements["saveimage"].active = true
		guielements["openfolderbackgroundscustom"].active = true
		guielements["currentbackgrounddropdown"].active = true
	elseif t == "sounds" then
		guielements["currentsounddropdown"].active = true
		guielements["soundscustomtab"].textcolor = {255, 255, 255}
		guielements["exportimagetemplate"].active = true
		guielements["openfoldersoundscustom"].active = true
		guielements["openfoldermusiccustom"].active = true
		guielements["savesounds"].active = true
	elseif t == "text" then
		texttabtab(textstate)
	elseif t == "enemies" then
		guielements["enemiescustomtab"].textcolor = {255, 255, 255}
		guielements["currentenemydropdown"].active = true
		guielements["exportimagetemplate"].active = true
		guielements["openfolderenemiescustom"].active = true
	end
	
	customtabstate = t
end

function texttabtab(t)
	local t = t or "hud"
	for i, v in pairs(guielements) do
		v.active = false
	end
	guielements["tabmain"].fillcolor = {63, 63, 63}
	guielements["tabtiles"].fillcolor = {63, 63, 63}
	guielements["tabtools"].fillcolor = {63, 63, 63}
	guielements["tabmaps"].fillcolor = {63, 63, 63}
	guielements["tabcustom"].fillcolor = {0, 0, 0}
	guielements["tabanimations"].fillcolor = {63, 63, 63}
	guielements["tabmain"].active = true
	guielements["tabtiles"].active = true
	guielements["tabtools"].active = true
	guielements["tabmaps"].active = true
	guielements["tabcustom"].active = true
	guielements["tabanimations"].active = true
	
	guielements["graphicscustomtab"].textcolor = {127, 127, 127}
	guielements["tilescustomtab"].textcolor = {127, 127, 127}
	guielements["backgroundscustomtab"].textcolor = {127, 127, 127}
	guielements["soundscustomtab"].textcolor = {127, 127, 127}
	guielements["textcustomtab"].textcolor = {255, 255, 255}
	guielements["enemiescustomtab"].textcolor = {127, 127, 127}
	guielements["graphicscustomtab"].active = true
	guielements["tilescustomtab"].active = true
	guielements["backgroundscustomtab"].active = true
	guielements["soundscustomtab"].active = true
	guielements["textcustomtab"].active = true
	guielements["enemiescustomtab"].active = true
	
	guielements["endingtexttab"].textcolor = {127, 127, 127}
	guielements["hudtexttab"].textcolor = {127, 127, 127}
	guielements["castletexttab"].textcolor = {127, 127, 127}
	guielements["levelscreentexttab"].textcolor = {127, 127, 127}
	guielements["endingtexttab"].active = true
	guielements["hudtexttab"].active = true
	guielements["castletexttab"].active = true
	guielements["levelscreentexttab"].active = true
	guielements["savecustomtext"].active = true
	
	if t == "hud" then
		guielements["hudtexttab"].textcolor = {255, 255, 255}
		guielements["editplayername"].active = true
		guielements["hudcolor"].active = true
		--guielements["hudcolor<"].active = true
		--guielements["hudcolor>"].active = true
		guielements["hudworldlettercheckbox"].active = true
		guielements["hudvisiblecheckbox"].active = true
		guielements["hudoutlinecheckbox"].active = true
		guielements["hudsimplecheckbox"].active = true
	elseif t == "ending" then
		guielements["endingtexttab"].textcolor = {255, 255, 255}
		guielements["editendingtext1"].active = true
		guielements["editendingtext2"].active = true
		guielements["endingcolor"].active = true
		--guielements["endingcolor<"].active = true
		--guielements["endingcolor>"].active = true
	elseif t == "castle" then
		guielements["castletexttab"].textcolor = {255, 255, 255}
		guielements["edittoadtext1"].active = true
		guielements["edittoadtext2"].active = true
		guielements["edittoadtext3"].active = true
		guielements["editpeachtext1"].active = true
		guielements["editpeachtext2"].active = true
		guielements["editpeachtext3"].active = true
		guielements["editpeachtext4"].active = true
		guielements["editpeachtext5"].active = true
		guielements["stevecheckbox"].active = true
	elseif t == "levelscreen" then
		guielements["levelscreentexttab"].textcolor = {255, 255, 255}
		guielements["editlevelscreentext"].active = true
		--levelscreenimage
		if levelscreenimagecheck ~= mappack .. "-" .. marioworld .. "-" .. mariolevel then
			if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/" .. marioworld .. "-" .. mariolevel .. "levelscreen.png") then
				levelscreenimage = love.graphics.newImage(mappackfolder .. "/" .. mappack .. "/" .. marioworld .. "-" .. mariolevel .. "levelscreen.png")
			elseif love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/" .. marioworld .. "levelscreen.png") then
				levelscreenimage = love.graphics.newImage(mappackfolder .. "/" .. mappack .. "/" .. marioworld .. "levelscreen.png")
			elseif love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/levelscreen.png") then
				levelscreenimage = love.graphics.newImage(mappackfolder .. "/" .. mappack .. "/levelscreen.png")
			else
				levelscreenimage = false
			end
			levelscreenimagecheck = mappack .. "-" .. marioworld .. "-" .. mariolevel
		end
	end
	
	textstate = t
end

function animationstab()
	if _G["from" .. editorstate .. "tab"] then
		_G["from" .. editorstate .. "tab"]()
	end

	editorstate = "animations"
	for i, v in pairs(guielements) do
		v.active = false
	end
	tilemenuy = 0
	tilemenumoving = false
	
	guielements["tabmain"].fillcolor = {63, 63, 63}
	guielements["tabtiles"].fillcolor = {63, 63, 63}
	guielements["tabtools"].fillcolor = {63, 63, 63}
	guielements["tabmaps"].fillcolor = {63, 63, 63}
	guielements["tabcustom"].fillcolor = {63, 63, 63}
	guielements["tabanimations"].fillcolor = {0, 0, 0}
	guielements["tabmain"].active = true
	guielements["tabtiles"].active = true
	guielements["tabtools"].active = true
	guielements["tabmaps"].active = true
	guielements["tabcustom"].active = true
	guielements["tabanimations"].active = true
	
	guielements["animationsscrollbarver"].active = true
	guielements["animationsscrollbarhor"].active = true
	guielements["animationsavebutton"].active = true
	guielements["animationdelbutton"].active = true
	guielements["animationselectdrop"].active = true
	guielements["animationnewbutton"].active = true
	guielements["animationnameinput"].active = true
	
	generateanimationgui()
end

function fromanimationstab()
	if #animationguilines > 0 then
		saveanimation()
	end
end

function nothingtab()
	if _G["from" .. editorstate .. "tab"] then
		_G["from" .. editorstate .. "tab"]()
	end

	for i, v in pairs(guielements) do
		v.active = false
	end
end

function changeendingtextcolor(var)
	textcolorl = textcolorsnames[var]
	guielements["endingcolor"].var = var
end

function openconfirmmenu(menutype, args)
	if NoExitConfirmation or love.keyboard.isDown("lshift") or levelmodified ~= true then
		if menutype == "exit" then
			createeditorsavedata("menu")
			menu_load()
		elseif menutype == "maps" then
			createeditorsavedata("changelevel")
			mapnumberclick(unpack(args))
		end
		return
	end

	confirmmenuopen = true
	confirmmenuguisave = {}
	for i, v in pairs(guielements) do
		if v.active then
			table.insert(confirmmenuguisave, v)
			v.active = false
		end
	end

	if menutype == "exit" then
		guielements["confirmsave"] = guielement:new("button", width*8, 112, TEXT["save and exit"], function() savelevel(); createeditorsavedata("menu"); menu_load() end, 2)
		guielements["confirmexit"] = guielement:new("button", width*8, 129, TEXT["exit"], function() createeditorsavedata("menu"); menu_load() end, 2)
	elseif menutype == "maps" then
		guielements["confirmsave"] = guielement:new("button", width*8, 112, TEXT["save and continue"], function() savelevel(); createeditorsavedata("changelevel"); mapnumberclick(unpack(args)) end, 2)
		guielements["confirmexit"] = guielement:new("button", width*8, 129, TEXT["continue"], function() createeditorsavedata("changelevel"); mapnumberclick(unpack(args)) end, 2)
	end
	--guielements["confirmcancel"] = guielement:new("button", width*8, 136, TEXT["cancel"], closeconfirmmenu, 2)

	guielements["confirmsave"].x = guielements["confirmsave"].x - (guielements["confirmsave"].width / 2) - 3
	guielements["confirmexit"].x = guielements["confirmexit"].x - (guielements["confirmexit"].width / 2) - 3
	--guielements["confirmcancel"].x = guielements["confirmcancel"].x - (guielements["confirmcancel"].width / 2) - 3
	guielements["confirmsave"].bordercolor = {255, 0, 0}
	guielements["confirmsave"].bordercolorhigh = {255, 127, 127}
end

function closeconfirmmenu()
	confirmmenuopen = false
	for i, v in pairs(confirmmenuguisave) do
		v.active = true
	end
	confirmmenuguisave = false

	guielements["confirmsave"] = nil
	guielements["confirmexit"] = nil
	--guielements["confirmcancel"] = nil
end

function createeditorsavedata(t) -- "testing", "menu", "changelevel"
	if (not PersistentEditorTools) or (t == "menu" and (not PersistentEditorToolsLocal)) then
		editorsavedata = false
		return
	end

	editorsavedata = {
		currenttile = currenttile,
		editentities = editentities,
		brushsizex = brushsizex,
		brushsizey = brushsizey,
		customtabstate = customtabstate,
		assistmode = assistmode,
		backgroundtilemode = backgroundtilemode
	}
	if t == "changelevel" then
		return
	end

	editorsavedata["editorstate"] = editorstate
	if PersistentEditorToolsLocal then
		local data = JSON:encode_pretty(editorsavedata)
		love.filesystem.write(mappackfolder .. "/" .. mappack .. "/editorsave.json", data)
	end
end

function changehudtextcolor(var)
	textcolorp = textcolorsnames[var]
	if textcolorp == "black" then
		togglehudoutline(false)
	elseif textcolorp ~= "white" then
		togglehudoutline(true)
	end
	guielements["hudcolor"].var = var
end

function generateanimationgui()
	if not animations[currentanimation] then
		createnewanimation(nil,"dont_generate_gui")
	end

	animationguilines = {}
	animationguilines.triggers = {}
	for i, v in pairs(animations[currentanimation].triggers) do
		table.insert(animationguilines.triggers, animationguiline:new(v, "trigger"))
	end
	animationguilines.conditions = {}
	for i, v in pairs(animations[currentanimation].conditions) do
		table.insert(animationguilines.conditions, animationguiline:new(v, "condition"))
	end
	animationguilines.actions = {}
	for i, v in pairs(animations[currentanimation].actions) do
		table.insert(animationguilines.actions, animationguiline:new(v, "action"))
	end
end

function createnewanimation(name,dont_generate_gui)
	local s = {}
	s.triggers = {}
	s.conditions = {}
	s.actions = {}
	
	if not name then
		local i = 1
		while love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/animations/animation" .. i .. ".json") do
			i = i + 1
		end
		name = "animation" .. i
	end

	love.filesystem.createDirectory(mappackfolder .. "/" .. mappack .. "/animations/")
	love.filesystem.write(mappackfolder .. "/" .. mappack .. "/animations/" .. name .. ".json", JSON:encode_pretty(s))
	
	table.insert(animations, animation:new(mappackfolder .. "/" .. mappack .. "/animations/" .. name .. ".json", name .. ".json"))
	
	currentanimation = #animations
	if not dont_generate_gui then
		generateanimationgui(currentanimation)
	end
	
	updateanimationdropdown()
	guielements["animationnameinput"].value = string.sub(animations[currentanimation].name, 1, -6)
	guielements["animationnameinput"]:updatePos()
	animationsaveas = false
end

function updateanimationdropdown()	
	local args = {}
	for i, v in ipairs(animations) do
		table.insert(args, string.sub(v.name, 1, -6))
	end
	
	guielements["animationselectdrop"] = guielement:new("dropdown", 15, 20, 15, selectanimation, currentanimation, unpack(args))
end
	
function deleteanimationguiline(t, tabl)
	for i, v in ipairs(animationguilines[t .. "s"]) do
		if v == tabl then
			table.remove(animationguilines[t .. "s"], i)
		end
	end
end

function movedownanimationguiline(t, tabl)
	for i, v in ipairs(animationguilines[t .. "s"]) do
		if v == tabl then
			if i ~= #animationguilines[t .. "s"] then
				animationguilines[t .. "s"][i], animationguilines[t .. "s"][i+1] = animationguilines[t .. "s"][i+1], animationguilines[t .. "s"][i]
				break
			end
		end
	end
end

function moveupanimationguiline(t, tabl)
	for i, v in ipairs(animationguilines[t .. "s"]) do
		if v == tabl then
			if i ~= 1 then
				animationguilines[t .. "s"][i], animationguilines[t .. "s"][i-1] = animationguilines[t .. "s"][i-1], animationguilines[t .. "s"][i]
				break
			end
		end
	end
end

function selectanimation(i, initial)
	guielements["animationselectdrop"].var = i
	if not initial then
		saveanimation()
	end
	currentanimation = i
	if not initial then
		generateanimationgui()
	end
	guielements["animationnameinput"].value = string.sub(animations[currentanimation].name, 1, -6)
	guielements["animationnameinput"]:updatePos()
	animationsaveas = false
end

function saveanimation()
	local out = {}
	
	local typelist = {"triggers", "conditions", "actions"}
	for h, w in ipairs(typelist) do
		out[w] = {}
		for i, v in ipairs(animationguilines[w]) do
			out[w][i] = {}
			for j, k in ipairs(v.elements) do
				if k.gui then
					local val = ""
					if k.gui.type == "dropdown" then
						if j == 1 then
							--find normal name
							for l, m in pairs(animationlist) do
								if m.nicename == k.gui.entries[k.gui.var] then
									val = l
									break
								end
							end
						else
							val = k.gui.entries[k.gui.var]
						end
					elseif k.gui.type == "input" then
						val = k.gui.value
					end
					
					table.insert(out[w][i], val)
				end
			end
		end
	end
	
	animations[currentanimation].triggers = out.triggers
	animations[currentanimation].conditions = out.conditions
	animations[currentanimation].actions = out.actions
	
	local json = JSON:encode_pretty(out)
	if animationsaveas then
		love.filesystem.write(mappackfolder .. "/" .. mappack .. "/animations/" .. animationsaveas .. ".json", json)
		love.filesystem.remove(animations[currentanimation].filepath)
		table.remove(animations, currentanimation)
		table.insert(animations, animation:new(mappackfolder .. "/" .. mappack .. "/animations/" .. animationsaveas .. ".json", animationsaveas .. ".json"))
		updateanimationdropdown()
		currentanimation = #animations
		guielements["animationselectdrop"].var = #animations
		animationsaveas = false
	else
		love.filesystem.write(animations[currentanimation].filepath, json)
	end
	animationsaveas = false
end

local areyousure = false
function removeanimation()
	if areyousure then
		--areyousure = false
	else
		notice.new("Delete Animation?\nPress button again if yes.", notice.white, 2)
		areyousure = true
		return false
	end
	love.filesystem.remove(animations[i or currentanimation].filepath)
	table.remove(animations, currentanimation)
	if #animations <= 0 then
		createnewanimation()
	else
		notice.new("Animation Deleted", notice.red, 3)
	end
	updateanimationdropdown()
	currentanimation = #animations
	guielements["animationselectdrop"].var = #animations
	generateanimationgui(currentanimation)
end

function addanimationtrigger()
	table.insert(animationguilines.triggers, animationguiline:new({}, "trigger"))
end

function addanimationcondition()
	table.insert(animationguilines.conditions, animationguiline:new({}, "condition"))
end

function addanimationaction()
	table.insert(animationguilines.actions, animationguiline:new({}, "action"))
end

function openchangewidth()
	levelmodified = true
	for i, v in pairs(guielements) do
		v.active = false
	end
	
	guielements["maptopup"].active = true
	guielements["maptopdown"].active = true
	guielements["mapbottomup"].active = true
	guielements["mapbottomdown"].active = true
	guielements["mapleftleft"].active = true
	guielements["mapleftright"].active = true
	guielements["maprightleft"].active = true
	guielements["maprightright"].active = true
	guielements["mapwidthapply"].active = true
	guielements["mapwidthcancel"].active = true

	changemapwidthmenu = true
	newmapwidth = mapwidth
	newmapheight = mapheight
	newmapoffsetx = 0
	newmapoffsety = 0
end

function mapwidthapply()
	changemapwidthmenu = false
	objects["tile"] = {}
	
	local newmap = {}
	for x = 1, newmapwidth do
		newmap[x] = {}
		for y = 1, newmapheight do
			local oldx, oldy = x-newmapoffsetx, y-newmapoffsety
			if inmap(oldx, oldy) then
				newmap[x][y] = map[oldx][oldy]
			else
				newmap[x][y] = {1, gels={}}--, portaloverride={}
			end
			
			if tilequads[newmap[x][y][1]]["collision"] then
				objects["tile"][tilemap(x, y)] = tile:new(x-1, y-1, 1, 1, true)
			end
		end
	end
	
	objects["player"][1].x = objects["player"][1].x + newmapoffsetx
	objects["player"][1].y = objects["player"][1].y + newmapoffsety
	
	map = newmap
	mapwidth = newmapwidth
	mapheight = newmapheight
	
	xscroll = xscroll + newmapoffsetx
	yscroll = yscroll + newmapoffsety
	
	if xscroll < 0 then
		xscroll = 0
	end
	
	if xscroll > mapwidth-width-1 then
		xscroll = math.max(0, mapwidth-width-1)
		hitrightside()
	end
	
	if yscroll < 0 then
		yscroll = 0
	end
	
	if yscroll > mapheight-height-1 then
		yscroll = math.max(0, mapheight-height-1)
	end
	
	splitxscroll = {xscroll}
	splityscroll = {yscroll}
	
	--move all them links!
	for x = 1, mapwidth do
		for y = 1, mapheight do
			for i, v in pairs(map[x][y]) do
				if v == "link" then
					if map[x][y][i+1] and tonumber(map[x][y][i+1]) then
						map[x][y][i+1] = tonumber(map[x][y][i+1]) + newmapoffsetx
					end
					if map[x][y][i+2] and tonumber(map[x][y][i+2]) then
						map[x][y][i+2] = tonumber(map[x][y][i+2]) + newmapoffsety
					end
				end
			end
		end
	end
	
	objects["screenboundary"]["right"].x = mapwidth
	generatespritebatch()
	
	editorclose()
	allowdrag = false
	
	--maintab()
end

function mapwidthcancel()
	changemapwidthmenu = false
	editorclose()
	allowdrag = false
	--maintab()
end

function changenewmapsize(side, dir)
	if side == "top" then
		if dir == "up" then
			newmapheight = newmapheight + 1
			newmapoffsety = newmapoffsety + 1
		else
			if newmapheight > 15 then
				newmapheight = newmapheight - 1
				newmapoffsety = newmapoffsety - 1
			end
		end
	elseif side == "bottom" then
		if dir == "up" then
			if newmapheight > 15 then
				newmapheight = newmapheight - 1
			end
		else
			newmapheight = newmapheight + 1
		end
	elseif side == "left" then
		if dir == "left" then
			newmapwidth = newmapwidth + 1
			newmapoffsetx = newmapoffsetx + 1
		else
			if newmapwidth > 1 then
				newmapwidth = newmapwidth - 1
				newmapoffsetx = newmapoffsetx - 1
			end
		end
	elseif side == "right" then
		if dir == "left" then
			if newmapwidth > 1 then
				newmapwidth = newmapwidth - 1
			end
		else
			newmapwidth = newmapwidth + 1
		end
	end
end

function updatetilesscrollbar()
	guielements["tilesscrollbar"].yrange = guielements["tilesscrollbar"].yrange + guielements["tilesscrollbar"].height
	guielements["tilesscrollbar"].height = math.max(30, math.min(1, 165/(tilescrollbarheight+165))*167)
	guielements["tilesscrollbar"].yrange = guielements["tilesscrollbar"].yrange - guielements["tilesscrollbar"].height
	guielements["tilesscrollbar"].scrollstep = math.max(0.0001, 73/tilescrollbarheight)
end

function updatelevelscrollbar()
	local scrolllimit = 201
	worldscrollbarheight = math.max(0, ((#mappacklevels+1-(1/16))*16)-scrolllimit)
	guielements["worldscrollbar"].yrange = guielements["worldscrollbar"].yrange + guielements["worldscrollbar"].height
	guielements["worldscrollbar"].height = math.max(30, math.min(1, scrolllimit/(worldscrollbarheight+scrolllimit))*scrolllimit)
	guielements["worldscrollbar"].yrange = guielements["worldscrollbar"].yrange - guielements["worldscrollbar"].height
	guielements["worldscrollbar"].scrollstep = math.max(0.0001, 73/worldscrollbarheight)
	if not currentworldselection then return end
	local scrolllimit = 173
	levelscrollbarheight = math.max(0, (#mappacklevels[currentworldselection]*39)+17-scrolllimit)
	guielements["levelscrollbar"].yrange = guielements["levelscrollbar"].yrange + guielements["levelscrollbar"].height
	guielements["levelscrollbar"].height = math.max(30, math.min(1, scrolllimit/(levelscrollbarheight+scrolllimit))*scrolllimit)
	guielements["levelscrollbar"].yrange = guielements["levelscrollbar"].yrange - guielements["levelscrollbar"].height
	guielements["levelscrollbar"].scrollstep = math.max(0.0001, 73/levelscrollbarheight)
end

function tilesall()
	guielements["tilesall"].textcolor = {255, 255, 255}
	guielements["tilessmb"].textcolor = {127, 127, 127}
	guielements["tilesportal"].textcolor = {127, 127, 127}
	guielements["tilescustom"].textcolor = {127, 127, 127}
	guielements["tilesanimated"].textcolor = {127, 127, 127}
	guielements["tilesentities"].textcolor = {127, 127, 127}
	guielements["tilesobjects"].textcolor = {127, 127, 127}
	
	tileliststart = 1
	tilelistcount = smbtilecount + portaltilecount + customtilecount -1
	
	tilescrollbarheight = math.max(0, math.ceil((smbtilecount + portaltilecount + customtilecount)/22)*17 - 1 - (17*9) - 12)
	if (not tonumber(currenttile)) or editentities then
		currenttile = 1
	end
	animatedtilelist = false
	editentities = false
	editmtobjects = false
	updatetilesscrollbar()
end

function tilessmb()
	guielements["tilesall"].textcolor = {127, 127, 127}
	guielements["tilessmb"].textcolor = {255, 255, 255}
	guielements["tilesportal"].textcolor = {127, 127, 127}
	guielements["tilescustom"].textcolor = {127, 127, 127}
	guielements["tilesanimated"].textcolor = {127, 127, 127}
	guielements["tilesentities"].textcolor = {127, 127, 127}
	guielements["tilesobjects"].textcolor = {127, 127, 127}
	
	tileliststart = 1
	tilelistcount = smbtilecount-1
	
	tilescrollbarheight = math.max(0, math.ceil((smbtilecount)/22)*17 - 1 - (17*9) - 12)
	if (not tonumber(currenttile)) or editentities then
		currenttile = 1
	end
	animatedtilelist = false
	editentities = false
	editmtobjects = false
	updatetilesscrollbar()
end

function tilesportal()
	guielements["tilesall"].textcolor = {127, 127, 127}
	guielements["tilessmb"].textcolor = {127, 127, 127}
	guielements["tilesportal"].textcolor = {255, 255, 255}
	guielements["tilescustom"].textcolor = {127, 127, 127}
	guielements["tilesanimated"].textcolor = {127, 127, 127}
	guielements["tilesentities"].textcolor = {127, 127, 127}
	guielements["tilesobjects"].textcolor = {127, 127, 127}
	
	tileliststart = smbtilecount + 1
	tilelistcount = portaltilecount - 1
	
	tilescrollbarheight = math.max(0, math.ceil((portaltilecount)/22)*17 - 1 - (17*9) - 12)
	if (not tonumber(currenttile)) or editentities then
		currenttile = 1
	end
	animatedtilelist = false
	editentities = false
	editmtobjects = false
	updatetilesscrollbar()
end

function tilescustom()
	guielements["tilesall"].textcolor = {127, 127, 127}
	guielements["tilessmb"].textcolor = {127, 127, 127}
	guielements["tilesportal"].textcolor = {127, 127, 127}
	guielements["tilescustom"].textcolor = {255, 255, 255}
	guielements["tilesanimated"].textcolor = {127, 127, 127}
	guielements["tilesentities"].textcolor = {127, 127, 127}
	guielements["tilesobjects"].textcolor = {127, 127, 127}
	
	tileliststart = smbtilecount + portaltilecount + 1
	tilelistcount = customtilecount - 1
	
	tilescrollbarheight = math.max(0, math.ceil((customtilecount)/22)*17 - 1 - (17*9) - 12)
	if (not tonumber(currenttile)) or editentities then
		currenttile = 1
	end
	animatedtilelist = false
	editentities = false
	editmtobjects = false
	updatetilesscrollbar()
end

function tilesanimated()
	guielements["tilesall"].textcolor = {127, 127, 127}
	guielements["tilessmb"].textcolor = {127, 127, 127}
	guielements["tilesportal"].textcolor = {127, 127, 127}
	guielements["tilescustom"].textcolor = {127, 127, 127}
	guielements["tilesanimated"].textcolor = {255, 255, 255}
	guielements["tilesentities"].textcolor = {127, 127, 127}
	guielements["tilesobjects"].textcolor = {127, 127, 127}
	
	animatedtilelist = true
	tilelistcount = animatedtilecount - 1
	tileliststart = 1
	
	tilescrollbarheight = math.max(0, math.ceil((animatedtilecount)/22)*17 - 1 - (17*9) - 12)
	if (not tonumber(currenttile)) or editentities then
		currenttile = 1
	end
	editentities = false
	editmtobjects = false
	updatetilesscrollbar()
end

function tilesentities()
	guielements["tilesall"].textcolor = {127, 127, 127}
	guielements["tilessmb"].textcolor = {127, 127, 127}
	guielements["tilesportal"].textcolor = {127, 127, 127}
	guielements["tilescustom"].textcolor = {127, 127, 127}
	guielements["tilesanimated"].textcolor = {127, 127, 127}
	guielements["tilesentities"].textcolor = {255, 255, 255}
	guielements["tilesobjects"].textcolor = {127, 127, 127}
	
	animatedtilelist = false
	tilescrollbarheight = math.max(0, entitiesform[#entitiesform].y+entitiesform[#entitiesform].h - 164)
	editentities = true
	editmtobjects = false
	
	if (not tonumber(currenttile)) or currenttile > entitiescount then
		currenttile = 1
	end
	updatetilesscrollbar()
end

function tilesobjects()
	guielements["tilesall"].textcolor = {127, 127, 127}
	guielements["tilessmb"].textcolor = {127, 127, 127}
	guielements["tilesportal"].textcolor = {127, 127, 127}
	guielements["tilescustom"].textcolor = {127, 127, 127}
	guielements["tilesanimated"].textcolor = {127, 127, 127}
	guielements["tilesobjects"].textcolor = {255, 255, 255}
	guielements["tilesentities"].textcolor = {127, 127, 127}
	
	tilescrollbarheight = math.max(0, math.ceil((#multitileobjects))*17 - 1 - (17*9) - 12)
	editentities = false
	editmtobjects = true
	animatedtilelist = false
	
	if (not tonumber(currenttile)) or currenttile > #multitileobjects then
		currenttile = 1
	end
	updatetilesscrollbar()
end

function placetile(x, y, tilei)
	local cox, coy = getMouseTile(x, y+8*screenzoom*scale)
	if inmap(cox, coy) == false then
		return
	end
	
	levelmodified = true
	if assistmode then --update latest tiles
		updatelatesttiles()
	end
	
	local currenttile = tilei or currenttile
	local argument
	if editentities and ((entitylist[currenttile] and entitylist[currenttile].offset) or (enemiesdata[currenttile] and enemiesdata[currenttile].offsetable)) then
		local allowoffset = true
		--don't clip with entity on the right
		if ismaptile(cox+1, coy) and map[cox+1][coy][2] and map[cox+1][coy][2] == currenttile and not map[cox+1][coy].argument then
			allowoffset = false
		elseif map[cox][coy][2] and map[cox][coy][2] == currenttile and not map[cox][coy].argument then
			allowoffset = false
		end
		if allowoffset then
			local mx = ((x/scale)+(xscroll*16))%16
			--[[if mx < 16*0 and inmap(cox-1, coy) then
				cox = cox - 1
				argument = "o"
			else]]
			if mx > 16*0.75 then
				if entitylist[currenttile] and type(entitylist[currenttile].offset) == "number" then
					currenttile = entitylist[currenttile].offset
				else
					argument = "o"
				end
			end
		end
	end
	
	if backgroundtilemode then
		if not editentities then
			if map[cox][coy]["back"] ~= currenttile then
				if currenttile == 1 then
					map[cox][coy]["back"] = nil
				else
					map[cox][coy]["back"] = currenttile
					bmap_on = true
				end
				undo_store(cox, coy)
				generatespritebatch()
			end
		end
	elseif editentities == false then
		if tilequads[currenttile].collision == true and (tilequads[map[cox][coy][1]].collision == false or (objects["tile"][tilemap(cox, coy)] and objects["tile"][tilemap(cox, coy)].slant)) then
			local oldtile
			local tilequad = tilequads[currenttile]
			if tilequad.platform or tilequad.leftslant or tilequad.halfleftslant1 or tilequad.halfleftslant2 or
				tilequad.rightslant or tilequad.halfrightslant1 or tilequads.halfrightslant2 then
				--fix platforms and slants acting like solid blocks when first placed in editor
				--so many people complained about this minor oddity
				--guess i have to do a wack workaround
				oldtile = map[cox][coy][1]
				map[cox][coy][1] = currenttile
			end
			objects["tile"][tilemap(cox, coy)] = tile:new(cox-1, coy-1, 1, 1, true)
			if oldtile then
				map[cox][coy][1] = oldtile
			end
		elseif tilequads[currenttile].collision == false and tilequads[map[cox][coy][1]].collision == true then
			objects["tile"][tilemap(cox, coy)] = nil
		end

		if map[cox][coy][1] ~= currenttile then
			undo_store(cox, coy)

			map[cox][coy][1] = currenttile
			map[cox][coy]["gels"] = {}
			generatespritebatch()
		end
		
		if currenttile == 136 then
			currenttile = 137
			placetile(x+16*scale, y, 137)
			
			currenttile = 138
			placetile(x, y+16*scale, 138)
			
			currenttile = 139
			placetile(x+16*scale, y+16*scale, 139)
			
			currenttile = 136
		end
			
	else
		local t = map[cox][coy]
		--update track previews
		local queuetrackpreview
		if trackpreviews and map[cox][coy][2] and entityquads[map[cox][coy][2]] and (entityquads[map[cox][coy][2]].t == "track" or entityquads[map[cox][coy][2]].t == "trackswitch") then
			queuetrackpreview = true
		end
		if entityquads[currenttile] and entityquads[currenttile].t == "remove" then --removing tile
			if map[cox][coy][2] and map[cox][coy][2] ~= currenttile then
				undo_store(cox, coy)
			end
			for i = 2, #map[cox][coy] do
				map[cox][coy][i] = nil
			end
			map[cox][coy]["argument"] = nil
		elseif entitylist[currenttile] and entitylist[currenttile].argument then --argument
			if map[cox][coy]["argument"] then
				undo_store(cox, coy)
			end
			if map[cox][coy]["argument"] and map[cox][coy]["argument"] == entitylist[currenttile].argument then
				--map[cox][coy]["argument"] = nil
			elseif map[cox][coy][2] and entitylist[map[cox][coy][2]] and entitylist[map[cox][coy][2]][entitylist[currenttile].argumentname] then
				map[cox][coy]["argument"] = entitylist[currenttile].argument
			elseif entitylist[currenttile].t == "supersize" and map[cox][coy][2] and tablecontains(customenemies, map[cox][coy][2]) and
				enemiesdata[map[cox][coy][2]] and enemiesdata[map[cox][coy][2]].supersize then
				map[cox][coy]["argument"] = entitylist[currenttile].argument
			end
		else
			if map[cox][coy][2] ~= currenttile then
				undo_store(cox, coy)
			end
			map[cox][coy][2] = currenttile
			--check if tile has settable option, if so default to this.
			if entitylist[currenttile] and rightclickvalues[entitylist[currenttile].t] then
				map[cox][coy][3] = rightclickvalues[entitylist[currenttile].t][2]
				for i = 4, #map[cox][coy] do
					map[cox][coy][i] = nil
				end
			elseif tablecontains(customenemies, currenttile) and enemiesdata[currenttile] and (enemiesdata[currenttile].rightclickmenu or enemiesdata[currenttile].rightclick) then --custom enemies
				local v = enemiesdata[currenttile]
				if v.rightclickmenu then
					if v.rightclickmenutable then
						map[cox][coy][3] = 2
					else
						local default = v.rightclickmenu[2]
						local s = tostring(default)
						default = s:gsub("-", "B")
						map[cox][coy][3] = default
					end
				elseif v.rightclick then
					local default = ""
					local b = v.rightclickdefaults
					for i = 1, #b-1 do
						default = default .. tostring(b[i]) .. "|"
					end
					default = default .. b[#b]
					default = default:gsub("-", "B")

					map[cox][coy][3] = default
				end
				for i = 4, #map[cox][coy] do
					map[cox][coy][i] = nil
				end
			elseif entitylist[currenttile] and rightclicktype[entitylist[currenttile].t] then
				map[cox][coy][3] = rightclicktype[entitylist[currenttile].t].default
				for i = 4, #map[cox][coy] do
					map[cox][coy][i] = nil
				end
			else
				for i = 3, #map[cox][coy] do
					map[cox][coy][i] = nil
				end
			end
			map[cox][coy]["argument"] = argument
		end
		if queuetrackpreview then
			generatetrackpreviews()
		end
	end
	editortilemousescroll = false
	editortilemousescrolltimer = 0
end

function powerlinedraw(x, y)
	local cox, coy = getMouseTile(x, y+8*scale)
	if inmap(cox, coy) == false then
		return
	end

	if not allowdrag then
		return
	end
	
	--connect the power lines oh boi
	if powerlinestate == 1 and ((inmap(cox, coy-1) and (map[cox][coy-1][2] == 43 or map[cox][coy-1][2] == 46 or map[cox][coy-1][2] == 47))
	or (inmap(cox, coy+1) and (map[cox][coy+1][2] == 43 or map[cox][coy+1][2] == 45 or map[cox][coy+1][2] == 48))) then
		map[cox][coy][2] = 43
	elseif powerlinestate == 2 and ((inmap(cox-1, coy) and (map[cox-1][coy][2] == 44 or map[cox-1][coy][2] == 45 or map[cox-1][coy][2] == 46))
	or (inmap(cox+1, coy) and (map[cox+1][coy][2] == 44 or map[cox+1][coy][2] == 47 or map[cox+1][coy][2] == 48))) then
		map[cox][coy][2] = 44
	elseif (inmap(cox-1, coy) and map[cox-1][coy][2] == 43) or (inmap(cox+1, coy) and map[cox+1][coy][2] == 43) then
		map[cox][coy][2] = 44
		powerlinestate = 2
		if inmap(cox-1, coy) and map[cox-1][coy][2] == 43 then
			if inmap(cox-1, coy-1) and (map[cox-1][coy-1][2] == 43 or map[cox-1][coy-1][2] == 47 or map[cox-1][coy-1][2] == 46) then
				map[cox-1][coy][2] = 45
			elseif inmap(cox-1, coy+1) and (map[cox-1][coy+1][2] == 43 or map[cox-1][coy+1][2] == 45 or map[cox-1][coy+1][2] == 48) then
				map[cox-1][coy][2] = 46
			else
				map[cox-1][coy][2] = 44
			end
		else
			if inmap(cox+1, coy-1) and (map[cox+1][coy-1][2] == 43 or map[cox+1][coy-1][2] == 46 or map[cox+1][coy-1][2] == 47) then
				map[cox+1][coy][2] = 48
			elseif inmap(cox+1, coy+1) and (map[cox+1][coy+1][2] == 43 or map[cox+1][coy+1][2] == 45 or map[cox+1][coy+1][2] == 48) then
				map[cox+1][coy][2] = 47
			else
				map[cox+1][coy][2] = 44
			end
		end
	elseif (inmap(cox, coy-1) and map[cox][coy-1][2] == 44) or (inmap(cox, coy+1) and map[cox][coy+1][2] == 44) then
		map[cox][coy][2] = 43
		powerlinestate = 1
		if inmap(cox, coy-1) and map[cox][coy-1][2] == 44 then
			if inmap(cox-1, coy-1) and (map[cox-1][coy-1][2] == 44 or map[cox-1][coy-1][2] == 45 or map[cox-1][coy-1][2] == 46) then
				map[cox][coy-1][2] = 47
			elseif inmap(cox+1, coy-1) and (map[cox+1][coy-1][2] == 44 or map[cox+1][coy-1][2] == 47 or map[cox+1][coy-1][2] == 48) then
				map[cox][coy-1][2] = 46
			else
				map[cox][coy-1][2] = 43
			end
		else
			if inmap(cox-1, coy+1) and (map[cox-1][coy+1][2] == 44 or map[cox-1][coy+1][2] == 46 or map[cox-1][coy+1][2] == 47) then
				map[cox][coy+1][2] = 48
			elseif inmap(cox+1, coy+1) and (map[cox+1][coy+1][2] == 44 or map[cox+1][coy+1][2] == 47 or map[cox+1][coy+1][2] == 48) then
				map[cox][coy+1][2] = 45
			else
				map[cox][coy+1][2] = 43
			end
		end
	else
		if powerlinestate == 1 then
			map[cox][coy][2] = 43
		elseif powerlinestate == 2 then
			map[cox][coy][2] = 44
		end
	end
	
	for i = 3, #map[cox][coy] do
		map[cox][coy][i] = nil
	end
end

function updatelatesttiles()
	local ct1 = 1
	local ct2 = currenttile
	if editentities then ct1 = 2 end
	local t = latesttiles[3]
	
	if ct2 ~= 1 then
		local yes = true
		for i = 3, #latesttiles do --check if already in quick menu
			if (ct1 == latesttiles[i][1] and ct2 == latesttiles[i][2]) then
				yes = false
				break
			end
		end
		if yes then
			for i = #latesttiles, 4, -1 do
				latesttiles[i] = {latesttiles[i-1][1], latesttiles[i-1][2]}
			end
			latesttiles[3] = {ct1, ct2}
		end
	end
end

function editorclose()
	editormenuopen = false
	for i, v in pairs(guielements) do
		v.active = false
	end
end

function editoropen()
	for i = 1, players do
		objects["player"][i]:removeportals()
	end
	if editorstate == "linktool" or editorstate == "portalgun" or editorstate == "selectiontool" or editorstate == "powerline" then
		editorstate = "tools"
	end
	rightclickmenuopen = false
	editormenuopen = true
	targetmapwidth = mapwidth
	targetmapheight = mapheight
	--guielements["mapwidthincrease"].x = 282 + string.len(targetmapwidth)*8
	--guielements["mapheightincrease"].x = 282 + string.len(targetmapheight)*8
	if mariolivecount == false then
		guielements["livesincrease"].x = 314 - 6 + 24
	else
		guielements["livesincrease"].x = 314 - 6 + string.len(mariolivecount)*8
	end
	guirepeattimer = 0
	getmaps()
	tilestampselection = false
	
	if editorstate == "main" then
		maintab()
	elseif editorstate == "tiles" then
		tilestab()
	elseif editorstate == "tools" then
		toolstab()
	elseif editorstate == "maps" then
		mapstab()
	elseif editorstate == "custom" then
		customtab()
	elseif editorstate == "animations" then
		animationstab()
	end
end

function mapnumberclick(i, j, k)
	if editormode then
		if promptedmetadatasave then
			--save editor meta data
			saveeditormetadata()
			promptedmetadatasave = false
		end
		if levelmodified and autosave then
			guielements["savebutton2"].func()
		end

		marioworld = i
		mariolevel = j
		actualsublevel = k
		checkpointx = nil
		editorloadopen = true
		if k ~= 0 then
			startlevel(k)
		else
			startlevel(i .. "-" .. j)
		end
	end
end

function getmaps()
	local clickablerange = {20, 20+201}
	existingmaps = {}
	for i = 1, #mappacklevels do --world
		local world = i
		if hudworldletter and world > 9 and world <= 9+#alphabet then
			world = alphabet:sub(world-9, world-9)
		end
		guielements["world-" .. i] = guielement:new("button", 3, 20+((i-1)*16), TEXT["world "] .. world, switchworldselection, 0, {i}, 1.4, 83, true)
		guielements["world-" .. i].bordercolor = {150, 150, 150}
		guielements["world-" .. i].bordercolorhigh = {255, 255, 255}
		guielements["world-" .. i].fillcolor = {0, 0, 0}
		if i == marioworld then
			guielements["world-" .. i].fillcolor = {30, 30, 30}
		end
		guielements["world-" .. i].clickswithinyrange = clickablerange
		
		createlevelbuttons(i)
	end
	
	guielements["newworld"] = guielement:new("button", 3, 20+(#mappacklevels*16), TEXT["new world"], addworld, 0, nil, 1.4, 83, true)
	guielements["newworld"].bordercolor = {150, 150, 150}
	guielements["newworld"].bordercolorhigh = {255, 255, 255}
	guielements["newworld"].fillcolor = {0, 0, 0}
end

function createlevelbuttons(i)
	local clickablerange = {20, 192}

	existingmaps[i] = {}
	for j = 1, #mappacklevels[i] do --level
		existingmaps[i][j] = {}
		for k = 0, mappacklevels[i][j] do --sublevel
			local name = i .. "-" .. j .. "_" .. k
			if k == 0 then
				guielements[name] = guielement:new("button", 104, 20+((j-1)*39), TEXT["level "] .. j, function() openconfirmmenu("maps", {i, j, k}) end, 0, nil, 1.8, 71, true)
			else
				guielements[name] = guielement:new("button", 134+((k-1)*19), 41+((j-1)*39), k, function() openconfirmmenu("maps", {i, j, k}) end, 0, nil, 1.6, 15, true)
			end
			
			local s = i .. "-" .. j
			if k ~= 0 then
				s = s .. "_" .. k
			end
			s = s .. ".txt"
			if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/" .. s) then
				existingmaps[i][j][k] = true
				guielements[name].textcolor = {255, 255, 255}
				if meta_data and meta_data[i .. "~" .. j .. "~" .. k] then
					local d = meta_data[i .. "~" .. j .. "~" .. k]
					if d.img then
						guielements[name].image = d.img
						guielements[name].imagecolor = {128, 128, 128}
						guielements[name].imageoffsetx = 2
						guielements[name].imageoffsety = 2
					end
					--guielements[name].fillcolor = meta_data[i .. "~" .. j .. "~" .. k]
				end
			else
				guielements[name].textcolor = {50, 50, 50}
			end
			
			if i == marioworld and j == mariolevel and k == mariosublevel then
				if existingmaps[i][j][k] == true  then
					guielements[name].textcolor = {0, 0, 0}
				else
					guielements[name].textcolor = {100, 100, 100}
				end
					
				guielements[name].bordercolorhigh = {255, 255, 255}
				guielements[name].fillcolor = {255, 255, 255}
				guielements[name].image = false
			end
			
			guielements[name].clickswithinyrange = clickablerange
		end
		
		guielements["newsublevel-" .. i .. "-" .. j] = guielement:new("button", 134+((mappacklevels[i][j])*19), 41+((j-1)*39), "+", addsublevel, 0, {j}, 1.6, 15, true)
		if not (mappacklevels[i][j] < maxsublevels) then
			guielements["newsublevel-" .. i .. "-" .. j].active = false
		end
	end
	
	guielements["newlevel-" .. i] = guielement:new("button", 104, 20+(#mappacklevels[i]*39), TEXT["new level"], addlevel, 0, nil, 1.6, 83, true)
	guielements["newlevel-" .. i].bordercolor = {150, 150, 150}
	guielements["newlevel-" .. i].bordercolorhigh = {255, 255, 255}
	guielements["newlevel-" .. i].fillcolor = {0, 0, 0}
end

function switchworldselection(w)
	--switch map "page"
	local w = w or 1
	currentworldselection = w
	
	for i = 1, #mappacklevels do
		if i == w then
			guielements["world-" .. i].fillcolor = {80, 80, 80}
		else
			if i == marioworld then
				guielements["world-" .. i].fillcolor = {30, 30, 30}
			else
				guielements["world-" .. i].fillcolor = {0, 0, 0}
			end
		end
		
		for j = 1, #mappacklevels[i] do --level
			for k = 0, mappacklevels[i][j] do --sublevel
				local name = i .. "-" .. j .. "_" .. k
				guielements[name].active = (i == w)
			end
			if mappacklevels[i][j] < maxsublevels then
				guielements["newsublevel-" .. i .. "-" .. j].active = (i == w)
			end
		end
	end
	
	oldlevelscrollbarv = -1 --update scroll
	guielements["newlevel-" .. w].active = true
	--guielements["levelscrollbar"].value = 0
	updatelevelscrollbar()
end

function addworld()
	if #mappacklevels < maxworlds then
		table.insert(mappacklevels, {defaultsublevels,defaultsublevels,defaultsublevels,defaultsublevels})
		local i = #mappacklevels
		createlevelbuttons(i)
		
		local world = i
		if hudworldletter and world > 9 and world <= 9+#alphabet then
			world = alphabet:sub(world-9, world-9)
		end
		guielements["world-" .. i] = guielement:new("button", 3, 20+((i-1)*16), TEXT["world "] .. world, switchworldselection, 0, {i}, 1.4, 83, true)
		guielements["world-" .. i].bordercolor = {150, 150, 150}
		guielements["world-" .. i].bordercolorhigh = {255, 255, 255}
		guielements["world-" .. i].fillcolor = {0, 0, 0}
		
		guielements["newworld"].y = guielements["newworld"].y + 16
		updatelevelscrollbar()
	else
		guielements["newworld"].fillcolor = {100, 0, 0}
	end
end

function addlevel()
	local w = currentworldselection
	if #mappacklevels[w] < maxlevels then
		table.insert(mappacklevels[w], defaultsublevels)
		createlevelbuttons(w)
		guielements["levelscrollbar"].value = 1
		oldlevelscrollbarv = -1 --update scroll
		
		guielements["newlevel-" .. w].y = guielements["newlevel-" .. w].y + 39
		updatelevelscrollbar()
	else
		guielements["newlevel-" .. w].fillcolor = {100, 0, 0}
	end
end

function addsublevel(l)
	local w, l = currentworldselection, l

	--make new sublevel button
	if mappacklevels[w][l] < maxsublevels then
		local k = mappacklevels[w][l] + 1
		mappacklevels[w][l] = k
		createlevelbuttons(w)
		oldlevelscrollbarv = -1 --update scroll

		sublevelstable = {}
		for k = 0, mappacklevels[marioworld][mariolevel] do
			table.insert(sublevelstable, k)
		end

		--guielements["newsublevel-" .. w .. "-" .. l].x = guielements["newsublevel-" .. w .. "-" .. l].x + 19
	else
		guielements["newsublevel-" .. w .. "-" .. l].textcolor = {100, 0, 0}
	end
end

function editor_mousepressed(x, y, button)
	if changemapwidthmenu or minimapmoving then
		return
	end
	
	if rightclickmenuopen then
		if customrcopen then
			if customrcopen == "trackpath" then
				--edit track
				local x, y = love.mouse.getPosition()
				local rcp = rightclicktrack
				local ox, oy =  rcp.last[1],  rcp.last[2]
				local dir = rcp.dir
				local tx, ty = getMouseTile(x, y+8*scale)
				local ttx,tty = tx, ty
				tx = tx-rcp.x
				ty = ty-rcp.y
				if button == "l" then
					if trackrightclickmenu.active then
						trackrightclickmenu:click(x, y, button)
						trackrightclickmenu.active = false
						rcp.drag = true
						return
					end
				elseif button == "r" then
					--right click menu for track grab options
					if trackrightclickmenu.active then
						--trackrightclickmenu:click(x, y, button)
						trackrightclickmenu.active = false
						rcp.drag = true
						return
					end
					--Change from open to closed
					local editpath = false
					if (tx == rcp.path[1][1] and ty == rcp.path[1][2]) then
						editpath = 1
					elseif (tx == rcp.path[#rcp.path][1] and ty == rcp.path[#rcp.path][2]) then
						editpath = #rcp.path
					end
					if editpath then
						if rcp.path[editpath][3] == "c" or rcp.path[editpath][3] == "o" then
							rcp.path[editpath][3] = oppositetrackdirection(rcp.path[editpath][3])
							return
						end
						if rcp.path[editpath][4] == "c" or rcp.path[editpath][4] == "o" then
							rcp.path[editpath][4] = oppositetrackdirection(rcp.path[editpath][4])
							return
						end
						--rcp.drag = false
					end
					--Change what object is being grabbed (entity or tile)
					local start = #rcp.path-1
					if rcp.path[#rcp.path][4] ~= "c" and rcp.path[#rcp.path][4] ~= "o" then
						start = #rcp.path
					end
					for i = start, 2, -1 do
						--check normal overlap
						if (tx == rcp.path[i][1] and ty == rcp.path[i][2]) and ismaptile(ttx, tty) then
							trackrightclickmenustage = i
							trackrightclickmenu.active = true
							trackrightclickmenu.x = x/scale
							trackrightclickmenu.y = y/scale
							trackrightclickmenu:updatePos()
							return 
							--old cycle through code (i like it but there's just too many options :( )
							--[[if rcp.path[i][5] == "d" then
								if not map[ttx][tty][2] then
									if tilequads[map[ttx][tty][1] ].collision then
										rcp.path[i][5] = "t" --tile
									end
								else
									rcp.path[i][5] = "r" --reverse
								end
							elseif rcp.path[i][5] == "r" then
								rcp.path[i][5] = "t" --tile
							elseif rcp.path[i][5] == "t" then
								rcp.path[i][5] = "tr" --tile reverse
							elseif rcp.path[i][5] == "tr" then
								rcp.path[i][5] = "d" --defaults
							end
							--break
							return]]
						end
					end
				end
			end
			--close
			local doreturn = false
			if button == "r" and rightclickobjects and rightclickobjects[1] and (x > rightclickobjects.x*scale and x < (rightclickobjects.x+rightclickobjects.width)*scale and 
				y > rightclickobjects.y*scale and y < (rightclickobjects.y+rightclickobjects.height)*scale) and
				customrcopen ~= "region" and customrcopen ~= "path" and customrcopen ~= "trackpath" and customrcopen ~= "link" then
				--don't close
				doreturn = true
			elseif button == "r" then
				rightclickmenuopen = false
				allowdrag = false
				if customrcopen == "region" then
					rcrtsize()
				elseif customrcopen == "path" then
					setrcpath()
				elseif customrcopen == "trackpath" then
					setrctrack()
				elseif customrcopen == "link" then
				else
					closecustomrc(true)
				end
				customrcopen = false
				return
			end
			--otherwise, update objects
			if rightclickobjects then
				for i = 1, #rightclickobjects do
					local obj = rightclickobjects[i]
					if obj and obj.priority then
						if obj:click(x, y, button) then
							return
						end
					end
				end
				
				for i = 1, #rightclickobjects do
					local obj = rightclickobjects[i]
					if obj and not obj.priority then
						if obj:click(x, y, button) then
							return
						end
					end
				end
			end
			--click out of right click menu
			if button == "l" and rightclickobjects and rightclickobjects[1] then
				if not ((x > rightclickobjects.x*scale and x < (rightclickobjects.x+rightclickobjects.width)*scale and 
				y > rightclickobjects.y*scale and y < (rightclickobjects.y+rightclickobjects.height)*scale)) then
					if customrcopen == "region" then
					elseif customrcopen == "path" then
					elseif customrcopen == "trackpath" then
					elseif customrcopen == "link" then
					else
						rightclickmenuopen = false
						allowdrag = false
						closecustomrc(true)
						customrcopen = false
						return
					end
				end
			end
			if doreturn then return end
		elseif rightclickmenu then
			rightclickmenu:click(x, y, button)
			rightclickmenuopen = false
			allowdrag = false
			return
		end
	end
	
	if levelrightclickmenu.active then
		levelrightclickmenu:click(x, y, button)
		levelrightclickmenu.active = false
		ignoregui = true
		return
	end

	if button == "m" or (button == "l" and eyedroppertool) then
		--eye dropper (pick tile)
		local cox, coy = getMouseTile(x, y+8*screenzoom*scale)
		if pastingtiles then
			pastingtiles = false
		end
		if eyedroppertool then eyedroppertool = false; ANDROIDSHOWTOOLS = false end
		if inmap(cox, coy) == false then
			return
		end
		if editentities and map[cox][coy][2] then
			currenttile = map[cox][coy][2]
			return false
		end
		editentities = false
		tilesall()
		if backgroundtilemode then
			local backgroundtile = bmapt(cox, coy, 1)
			if backgroundtile then
				currenttile = backgroundtile
			else
				currenttile = 1
			end
		else
			currenttile = map[cox][coy][1]
		end
	elseif button == "l" then
		if editormenuopen == false then
			levelmodified = true
			if customrcopen == "link" then
				local tileX, tileY = getMouseTile(x, y+8*scale)
				setrclink(tileX, tileY)
				return
			elseif editorstate == "linktool" then
				local tileX, tileY = getMouseTile(x, y+8*scale)
				local r = map[tileX][tileY]
				if #r > 1 then
					local tile = r[2]
					--LIST OF NUMBERS THAT ARE ACCEPT AS OUTPUT (doors, lights)
					if tablecontains( inputsi, r[2] ) then
						--linktoolX, linktoolY = tileX, tileY
						--syke, just open up the right click menu
						openrightclickmenu(x, y, tileX, tileY)
						--then automatically click the link button ONLY if there's just one
						local count = 0
						local button
						for i, b in ipairs(rightclickobjects) do
							if b and b.type == "button" and b.func == startrclink then
								count = count + 1
								button = b
							end
						end
						if count == 1 and button then
							startrclink(unpack(button.arguments))
						end
					end
				end
			elseif editorstate == "selectiontool" then
				if not customrcopen then
					selectiontoolclick[1][1] = x/scale + xscroll*16
					selectiontoolclick[1][2] = y/scale + yscroll*16
					selectiontoolselection = {}
				end
			elseif editorstate ~= "portalgun" and customrcopen == false and not (assistmode and quickmenuopen) then
				undo_clear()
				
				-- left click on the selected area
				if tileselection and tileselection.finished
				and x > (tileselection[1]-xscroll-1)*16*scale and y > ((tileselection[2]-yscroll-1)*16-8)*scale
				and x < (tileselection[3]-xscroll)*16*scale and y < ((tileselection[4]-yscroll)*16-8)*scale then
					mtclipboard = getTilesSelection()
					emptySelection("store")
					pastecenter =  {-(math.floor((x-(tileselection[1]-xscroll)*16*scale)/scale/16))-1, -(math.floor((y-((tileselection[2]-yscroll-1)*16-8)*scale)/scale/16))}
					pastingtiles = true
					editentities = false
					tilesall()
					tileselectionmoving = true
					
					allowdrag = false
					return
				end
				if ctrlpressed then
					if pastingtiles then
						pastingtiles = false
						mtclipboard = {}
					end
					resettileselection()
					local tx, ty = getMouseTile(x, y+8*screenzoom*scale)
					tileselection = {tx, ty, tx, ty}
					tileselection.finished = false
					allowdrag = true
				elseif pastingtiles then
					--PASTE TILES
					for i, v in pairs(mtclipboard) do
						for j, w in pairs(v) do
							if w[1] == 1 and (not w[2]) and (not w["back"]) and pastemode == 1 then
								-- nothing
							else
								local tx, ty = getMouseTile(x+(i-1 + pastecenter[1])*16*scale, y+(j-1 + pastecenter[2])*16*scale+8*scale)
								if ismaptile(tx, ty) then
									local d = mtclipboard[i][j]
									currenttile = d[1]
									placetile(x+(i-1 + pastecenter[1])*16*scale, y+(j-1 + pastecenter[2])*16*scale)
									local tile1 = d[1]
									if tile1 == 1 then
										tile1 = false --don't paste empty space
									end
									if not backgroundtilemode then
										map[tx][ty] = shallowcopy(d)
										map[tx][ty][1] = tile1 or map[tx][ty][1]
									end
									map[tx][ty]["gels"] = {}
								end
							end
						end
					end
					--allowdrag = false
				end

				if tileselection and pastingtiles == false then
					--finish tileselection
				elseif pastingtiles == false then
					if (brushsizex > 1 or brushsizey > 1) then
						for lx = 1, brushsizex do
							for ly = 1, brushsizey do
								placetile(x+((lx-1)*16*scale), y+((ly-1)*16*scale))
							end
						end
					elseif editentities == false and ((love.keyboard.isDown("e") and not android) or (android and replacetool)) then
						--replace tiles
						local tx, ty = getMouseTile(x, y+8*screenzoom*scale)
						if inmap(tx, ty) then
							local ontile = map[tx][ty][1]
							if backgroundtilemode then
								ontile = map[tx][ty]["back"]
							end
							for sx = 1, mapwidth do
								for sy = 1, mapheight do
									local checktile
									if backgroundtilemode then
										ontile = map[sx][sy]["back"]
									else
										checktile = map[sx][sy][1]
									end
									if ontile == checktile then
										placetile(((sx-1-math.floor(xscroll))*16*scale), ((sy-1-math.floor(yscroll)-.5)*16*scale))
									end
								end
							end
						end
					elseif editentities == false and ((love.keyboard.isDown("f") and not android) or (android and paintbuckettool)) then
						--fill tiles
						local tx, ty = getMouseTile(x, y+8*screenzoom*scale)
						if inmap(tx, ty) then
							local ontile = map[tx][ty][1]
							if backgroundtilemode then
								ontile = map[tx][ty]["back"]
							end
							local replacetiles = paintbucket(tx, ty, ontile)
							for i, t in pairs(replacetiles) do
								local sx, sy = t[1], t[2]
								placetile(((sx-1-math.floor(xscroll))*16*scale), ((sy-1-math.floor(yscroll)-.5)*16*scale))
							end
						end
					else
						placetile(x, y)
					end
				end
			end
			
			if assistmode and quickmenuopen then
				if quickmenusel then
					currenttile = latesttiles[quickmenusel][2]
					editentities = (latesttiles[quickmenusel][1] == 2)
				end
			end
		else
			if editorstate == "tiles" then
				local tile = gettilelistpos(x, y)
				if editmtobjects then
					tile = getlistpos(x, y)
					local mtbutton = getmtbutton(x)
					if tile and not guielements["mtobjectrename"].active then
						if mtbutton == 0 then
							allowdrag = false
							editorclose()
							mtclipboard = multitileobjects[tile+1]
							pastecenter = {0, 0}
							pastingtiles = true
							editentities = false
							tilesall()
							resettileselection()
						else
							if mtbutton == 1 then
								moveline(mappackfolder .. "/" .. mappack .. "/objects.txt",tile+1,"up")
								loadmtobjects()
							elseif mtbutton == 2 then
								moveline(mappackfolder .. "/" .. mappack .. "/objects.txt",tile+1,"down")
								loadmtobjects()
							elseif mtbutton == 3 then
								deleteline(mappackfolder .. "/" .. mappack .. "/objects.txt", tile+1)
								loadmtobjects()
							end
						end
					end
				elseif editentities == false then
					if tile and tile <= tilelistcount+1 then
						if animatedtilelist then
							currenttile = tile + tileliststart-1+90000
						else
							currenttile = tile + tileliststart-1
						end
						if love.keyboard.isDown("lshift") or (tilestampholdtimer and tilestampholdtimer > 0.8) then
							local sx, sy = x, y
							sx = (sx - 5*scale)/scale
							sy = sy + tilesoffset
							sy = (sy - 38*scale)/scale
							sx = math.floor(sx/17)
							sy = math.floor(sy/17)
							tilestampselection = {x = (sx*17+5)*scale, y = (sy*17+38)*scale-tilesoffset, mx = love.mouse.getX(), my = love.mouse.getY()}
						else
							if android then
								--hold to do tile stamp selection
								tilestampholdtimer = 0
								tilestampholdx = x
								tilestampholdy = y
							else
								editorclose()
								allowdrag = false
							end
						end
					end
				else
					local tile, list = getentitylistpos(x, y)
					if tile then
						currenttile = entitiesform[list][tile]
						if not android then
							editorclose()
							allowdrag = false
						end
					elseif list then
						if not entitiesform[list].hidden then --hide
							entitiesform[list].hidden = true
							entitiesform[list].h = 0
							local namespacing = 10
							local ly = 0 --listy
							for list = 1, #entitiesform do
								ly = ly + namespacing
								entitiesform[list].y = ly
								ly = ly + entitiesform[list].h
							end
						else --unhide
							entitiesform[list].hidden = false
							entitiesform[list].h = 17*(math.ceil(#entitiesform[list]/22))
							local namespacing = 10
							local ly = 0 --listy
							for list = 1, #entitiesform do
								ly = ly + namespacing
								entitiesform[list].y = ly
								ly = ly + entitiesform[list].h
							end
						end
						local v = guielements["tilesscrollbar"].value*tilescrollbarheight
						tilescrollbarheight = math.max(0.01, entitiesform[#entitiesform].y+entitiesform[#entitiesform].h - 164)
						updatetilesscrollbar()
						guielements["tilesscrollbar"].value = math.max(0,math.min(1,v/tilescrollbarheight))
					end
				end
			elseif editorstate == "main" then
				if y >= minimapy*scale and y < (minimapy+34)*scale then
					if x >= minimapx*scale and x < (minimapx+394)*scale then
						minimapdragging = true
						toggleautoscroll(false)
					end
				end
			end
		end
		
	elseif button == "wu" then
		if editormenuopen or rightclickmenuopen then
		else
			if EditorZoom and ctrlpressed then
				local dy = 1
				local r1, r2 = love.mouse.getX()/(width*16*scale), love.mouse.getY()/(height*16*scale)
				local zoom1 = screenzoom
				local centerx, centery = xscroll+(width*(1/screenzoom))*r1, yscroll+(height*(1/screenzoom))*r2
				setscreenzoom(math.min(1,math.max(0.05, screenzoom + (screenzoom/(dy*5)))))
				if zoom1 ~= screenzoom then
					xscroll = centerx - (width*(1/screenzoom))*r1
					yscroll = centery - (height*(1/screenzoom))*r2
					splitxscroll[1] = xscroll
					splityscroll[1] = yscroll
				end
				autoscroll = false
				return
			elseif editentities then
					local dobreak = false
					for formi, form in pairs(entitiesform) do
						for count = 1, #form do
							ti = form[count]
							if currenttile == ti then
								local ti = math.max(count-1, 1)
								currenttile = form[ti]
								editortilemousescroll = {form[ti-1] or 0, form[ti-2] or 0, form[ti+1] or 0, form[ti+2] or 0}
								editortilemousescrolltimer = 0
								dobreak = true
								break
							end
						end
						if dobreak then break end
					end
			else
				if tonumber(currenttile) and currenttile > 1 then
					if currenttile ~= 90001 then
						currenttile = math.floor(currenttile) - 1
						editortilemousescroll = true
						editortilemousescrolltimer = 0
					end
				end
			end
		end
	elseif button == "wd" then
		if editormenuopen or rightclickmenuopen then
		else
			if EditorZoom and ctrlpressed then
				local dy = -1
				local r1, r2 = love.mouse.getX()/(width*16*scale), love.mouse.getY()/(height*16*scale)
				local zoom1 = screenzoom
				local centerx, centery = xscroll+(width*(1/screenzoom))*r1, yscroll+(height*(1/screenzoom))*r2
				setscreenzoom(math.min(1,math.max(0.05, screenzoom + (screenzoom/(dy*5)))))
				if zoom1 ~= screenzoom then
					xscroll = centerx - (width*(1/screenzoom))*r1
					yscroll = centery - (height*(1/screenzoom))*r2
					splitxscroll[1] = xscroll
					splityscroll[1] = yscroll
				end
				autoscroll = false
				return
			elseif editentities then
				local dobreak = false
				for formi, form in pairs(entitiesform) do
					for count = 1, #form do
						local ti = form[count]
						if currenttile == ti then
							ti = math.min(count+1, #form)
							currenttile = form[ti]
							editortilemousescroll = {form[ti-1] or 0, form[ti-2] or 0, form[ti+1] or 0, form[ti+2] or 0}
							editortilemousescrolltimer = 0
							dobreak = true
							break
						end
					end
					if dobreak then break end
				end
			elseif animatedtilelist or currenttile >= 90001 then
				if currenttile < animatedtilecount+90000 then
					currenttile = math.floor(currenttile) + 1
					editortilemousescroll = true
					editortilemousescrolltimer = 0
				end
			else
				if currenttile < smbtilecount+portaltilecount+customtilecount then
					currenttile = math.floor(currenttile) + 1
					editortilemousescroll = true
					editortilemousescrolltimer = 0
				end
			end
		end
		
	elseif button == "r" then
		if editormenuopen == false and editorstate ~= "powerline" then
			local tileX, tileY = getMouseTile(x, y+8*screenzoom*scale)
			if inmap(tileX, tileY) == false then
				return
			end
			if pastingtiles then
				pastingtiles = false
				--reset tileselection and stop pasting
			else
				if tileselection and tileselection.finished then
					--reset tileselection
					
					resettileselection()
					return
				end
			
				local r = map[tileX][tileY]
				if #r > 1 then
					openrightclickmenu(x, y, tileX, tileY)
				else
					if editorstate ~= "portalgun" and not customrcopen then
						local cox, coy = getMouseTile(x, y+8*screenzoom*scale)
						
						if objects["player"][1] then
							local p = objects["player"][1]
							p.x = cox-1+2/16
							p.y = coy-p.height
							if p.animation == "vinestart" then
								p.animation = false
								p.controlsenabled = true
								p.active = true
							end
							--check if anything below
							if (not rightkey(1)) and (not leftkey(1)) and #checkrect(p.x, p.y+3/16, p.width, p.height, {"tile"}, true) == 0 then
								p.static = true
								p.speedy = 0
								p.speedx = 0
								p.animationstate = "idle"
								p.falling = false
								p.jumping = false
								p:setquad()
							end
							--[[if objects["flipblock"][1] then
								objects["flipblock"][1].instantdelete = true
							end
							if #checkrect(p.x, p.y+3/16, p.width, p.height, {"tile"}, true) == 0 then
								table.insert(objects["flipblock"], tile:new(cox-1, coy, 1, 1, true))
							end]]
						end
					end
				end
			end
		else
			if editorstate == "main" then
				if y >= (minimapy+2)*scale and y < (minimapy+32)*scale then
					if x >= (minimapx+2)*scale and x < (minimapx+392)*scale then
						local x = math.floor((x-minimapx*scale+math.floor(minimapscroll*scale*2))/scale/2)
						local y = math.floor((y-minimapy*scale)/scale/2)
						
						if objects["player"][1] then
							objects["player"][1].x = x-1+2/16
							objects["player"][1].y = y-1+2/16
						end
					end
				end
			elseif editorstate == "tiles" then
				if editmtobjects then
					local tile = getlistpos(x, y)
					if tile and not guielements["mtobjectrename"].active then
						local obj = guielements["mtobjectrename"]
						obj.active = true
						obj.value = multitileobjectnames[tile+1]
						obj.i = tile+1
						obj.y = 39+(17*tile)-(tilesoffset/scale)
						obj.cursorpos = string.len(obj.value)+1
						obj.inputting = true
						allowdrag = false
					end
				end
			elseif editorstate == "maps" then
				for j = 1, #mappacklevels[currentworldselection] do --level
					for k = 0, mappacklevels[currentworldselection][j] do --sublevel
						local name = currentworldselection .. "-" .. j .. "_" .. k
						if guielements[name]:inhighlight(x, y) then
							levelrightclickmenu.active = true
							levelrightclickmenu.x = x/scale
							levelrightclickmenu.y = y/scale
							levelrightclickmenu:updatePos()
							levelrightclickmenu.level = {currentworldselection, j, k}
							levelrightclickmenu.button = guielements[name]
							return
						end
					end
				end
			end
		end
	end
end

function openrightclickmenu(x, y, tileX, tileY)
	local r = map[tileX][tileY]
	local tile = r[2]
	if not r[2] then
		return false
	end
	levelmodified = true
	local scoot = false
	--LIST OF TILES THAT DO SHIT
	if entitylist[r[2]] and rightclickvalues[entitylist[r[2]].t] then
		rightclickmenuX = x
		rightclickmenuY = y
		rightclickmenucox = tileX
		rightclickmenucoy = tileY
		rightclickmenuopen = true
		rightclickmenutile = entitylist[r[2]].t
		rightclickobjects = {}
		rightclickvalues2 = {}
		customrcopen = false
		
		--create button
		--get width and start
		local rcwidth = 0
		local start
		for i = 1, #rightclickvalues[rightclickmenutile] do
			if string.len(rightclickvalues[rightclickmenutile][i]) > rcwidth then
				rcwidth = string.len(rightclickvalues[rightclickmenutile][i])
			end
			
			if rightclickvalues[rightclickmenutile][i] == r[3] then
				start = rightclickvalues[rightclickmenutile][i]
			end
		end
		
		rightclickmenu = guielement:new("rightclick", x/scale, y/scale, rcwidth, rightclickmenuclick, start, unpack(rightclickvalues[rightclickmenutile]))
		if rightclickmenu.x+rightclickmenu.width*8 > width*16 then
			rightclickmenu.x = (width*16)-rightclickmenu.width*8
		end
	elseif tablecontains(customenemies, r[2]) and enemiesdata[r[2]] and enemiesdata[r[2]].rightclickmenu then
		local v = enemiesdata[r[2]]
		rightclickmenuX = x
		rightclickmenuY = y
		rightclickmenucox = tileX
		rightclickmenucoy = tileY
		rightclickmenuopen = true
		rightclickmenutile = r[2]
		rightclickobjects = {}
		rightclickvalues2 = {}
		customrcopen = false
		
		--create button
		--get width and start
		local rcwidth = 0
		local start = v.rightclickmenu[2]
		if v.rightclickmenutable then
			start = (tonumber(r[3]) or 2)
		end
		for i = 1, #v.rightclickmenu do
			--replace negative sign for saving
			if (not v.rightclickmenutable) then
				local s = tostring(v.rightclickmenu[i])
				v.rightclickmenu[i] = s:gsub("-", "B")
			end
			--get longest name
			if v.rightclickmenudisplay then
				if string.len(v.rightclickmenudisplay[i]) > rcwidth then
					rcwidth = string.len(v.rightclickmenudisplay[i])
				end
			else
				if type(v.rightclickmenu[i]) == "table" then
					notice.new("right click option name\nmissing for option " .. i, notice.red, 3)
				elseif string.len(v.rightclickmenu[i]) > rcwidth then
					rcwidth = string.len(v.rightclickmenu[i])
				end
			end
			
			--is the option currently selected?
			if i ~= 1 and (not v.rightclickmenutable) and v.rightclickmenu[i] == tostring(r[3]) then
				if v.rightclickmenudisplay then
					start = v.rightclickmenudisplay[i]
				else
					start = v.rightclickmenu[i]
				end
			end
		end
		
		if v.rightclickmenudisplay then
			rightclickmenu = guielement:new("rightclick", x/scale, y/scale, rcwidth, rightclickmenuclick, start, unpack(v.rightclickmenudisplay))
		else
			rightclickmenu = guielement:new("rightclick", x/scale, y/scale, rcwidth, rightclickmenuclick, start, unpack(v.rightclickmenu))
		end
		if rightclickmenu.x+rightclickmenu.width*8 > width*16 then
			rightclickmenu.x = (width*16)-rightclickmenu.width*8
		end
		if v.rightclickmenutable then
			rightclickmenu.trustWhatStartWasSetAs = true
		end
	elseif tablecontains(customenemies, r[2]) and enemiesdata[r[2]] and enemiesdata[r[2]].rightclick then
		local v = enemiesdata[r[2]]
		rightclickmenuX = x
		rightclickmenuY = y
		rightclickmenucox = tileX
		rightclickmenucoy = tileY
		rightclickmenuopen = true
		rightclickobjects = {width = 8, height = 6}
		customrcopen = "custom_enemy"

		local rx, ry = (x/scale)+4, (y/scale)+4

		local default = ""
		local b = v.rightclickdefaults
		for i = 1, #b-1 do
			default = default .. tostring(b[i]) .. "|"
		end
		default = default .. b[#b]
		default = default:gsub("-", "B")

		local usingdefaultvalues = false
		if not r[3] then
			table.insert(map[rightclickmenucox][rightclickmenucoy], 3, default)
			usingdefaultvalues = true
		end

		rightclickvalues2 = {map[rightclickmenucox][rightclickmenucoy][3]} --right-click values
		if tostring(map[rightclickmenucox][rightclickmenucoy][3]):find("|") then
			rightclickvalues2 = tostring(map[rightclickmenucox][rightclickmenucoy][3]):split("|") --split the values
		end

		--load in default values if there aren't enough
		if default and tostring(default):find("|") and (not usingdefaultvalues) then
			local defaultvalues = default:split("|")
			local numberofdefaultvalues = #defaultvalues
			for i = #rightclickvalues2+1, numberofdefaultvalues do
				rightclickvalues2[i] = defaultvalues[i]
			end
		end

		local vt = rightclickvalues2
		local addv = 0
		local width = 0
		local extraobjects = 0
		local index = 0
		for i = 1, #v.rightclick do
			if v.rightclick[i][1] ~= "text" then
				index = index + 1
			end
			local obj = i+extraobjects
			width = 0
			if v.rightclick[i][1] == "text" then
				table.insert(rightclickobjects, guielement:new("text", rx, ry, v.rightclick[i][2], {255, 255, 255}))
				width = 8*#v.rightclick[i][2]
				addv = 10
			elseif v.rightclick[i][1] == "dropdown" then
				local ni = index
				local var = vt[index]
				local ents = v.rightclick[i][4]
				if tostring(var) then
					local target = tostring(var):gsub("B", "-")
					var = tablecontainsistring(ents, target)
					vt[index] = var
				end
			
				local obj = guielement:new("dropdown", rx, ry, v.rightclick[i][3], function(v) rightclickobjects[obj].var = v; vt[ni] = v end, vt[index], unpack(ents))
				if v.rightclick[i][5] then
					obj.displayentries = deepcopy(v.rightclick[i][5])
				end
				table.insert(rightclickobjects, obj)
				width = v.rightclick[i][3]*8+13
				addv = 15
			elseif v.rightclick[i][1] == "input" then
				local ni = index
				table.insert(rightclickobjects, guielement:new("input", rx, ry, v.rightclick[i][3], function(v) vt[ni] = v end, vt[index], v.rightclick[i][3], 1, "rightclick"))
				width = v.rightclick[i][3]*8+5
				addv = 16
			elseif v.rightclick[i][1] == "checkbox" then
				local ni = index
				local var = vt[index]
				if type(var) == "string" then
					var = (vt[index] == "true")
				end

				table.insert(rightclickobjects, guielement:new("checkbox", rx, ry+2, function(v) rightclickobjects[obj].var = v; vt[ni] = v end, var, v.rightclick[i][3] or ""))
				width = #v.rightclick[i][3]*8+10
				addv = 13
			end

			if width+8 > rightclickobjects.width then
				rightclickobjects.width = width+8
			end
			ry = ry + addv
			rightclickobjects.height = rightclickobjects.height + addv
		end

		scoot = true
	elseif entitylist[r[2]] and rightclicktype[entitylist[r[2]].t] then --custom rightclick menu
		rightclickmenuX = x
		rightclickmenuY = y
		rightclickmenucox = tileX
		rightclickmenucoy = tileY
		rightclickmenuopen = true
		rightclickobjects = {width = 8, height = 6} --width 4px border | height 4px border, 2px obj separation
		
		local rx, ry = (x/scale)+4, (y/scale)+4
		local rct = rightclicktype[entitylist[r[2]].t] --custom right-click table

		
		customrcopen = entitylist[r[2]].t --rct.name
		
		local usingdefaultvalues = false
		if ((not r[3]) or (r[3] == "link" and #r == 5)) and rct.default then
			table.insert(map[rightclickmenucox][rightclickmenucoy], 3, rct.default) --load default if there is no right-click value
			usingdefaultvalues = true
		end
		
		rightclickvalues2 = {map[rightclickmenucox][rightclickmenucoy][3]}--right-click values
		if tostring(map[rightclickmenucox][rightclickmenucoy][3]):find("|") then
			rightclickvalues2 = tostring(map[rightclickmenucox][rightclickmenucoy][3]):split("|")--split the values
		end

		--load in default values if there aren't enough
		local defaultvalues = {}
		if rct.default and (not rct.fixdefault) and (not usingdefaultvalues) then
			if tostring(rct.default):find("|") then
				defaultvalues = rct.default:split("|")
			else
				defaultvalues = {rct.default}
			end
			local numberofdefaultvalues = #defaultvalues
			for i = #rightclickvalues2+1, numberofdefaultvalues do
				if ((rct.ignoredefault and rct.ignoredefault[i])) then
					rightclickvalues2[i] = rct.ignoredefault[i]
				else
					rightclickvalues2[i] = defaultvalues[i]
				end
			end
		end

		--modify values in special ways
		local vt = rightclickvalues2
		if rct.varfunc then
			local i = 1
			while rightclickvalues2[i] do
				rightclickvalues2[i] = rct.varfunc(rightclickvalues2[i], i)
				i = i + 1
			end
		end
		
		for i, t in pairs(rct.format) do
			local addv = 0
			local width = 0
			local ttype = type(t)
			if ttype == "string" then
				table.insert(rightclickobjects, guielement:new("text", rx, ry, t, {255, 255, 255}))
				width = 8*#t
				addv = 10
			elseif ttype == "table" then
				local obj = t[1]
				if obj == "input" then
					table.insert(rightclickobjects, guielement:new("input", rx, ry, t[4], t[7], vt[t[2]] or t[3], t[5], t[6], "rightclick"))
					width = t[4]*8+5
					addv = 16
				elseif obj == "smallinput" then
					table.insert(rightclickobjects, guielement:new("input", rx, ry-2, t[4], t[7], vt[t[2]] or t[3], t[5], t[6], "rightclick", 1, nil, nil, 0))
					width = t[4]*8+3
					addv = 14
				elseif obj == "dropdown" then
					local var = vt[t[2]]
					if var == nil and t.default ~= nil then
						var = t.default
					end
					if ((not rct.t) or t.ignorerctt) and tostring(var) then
						local list = t[5]
						for i = 1, #list do
							if tostring(var) == tostring(list[i]) then
								var = i
								vt[t[2]] = i
								break
							end
						end
					end

					local func = t[4] --function called when dropdown is clicked
					if not func then --if there is no function, make one
						local varid, objecti = t[2], #rightclickobjects+1
						func = function(v)
							rightclickobjects[objecti].var = v
							rightclickvalues2[varid] = v
						end
					end

					local d = guielement:new("dropdown", rx, ry, t[3], func, var or 1, unpack(t[5]))
					if t[6] then
						d.displayentries = t[6]
					end
					--d.dropup = ((d.y+11+(10*#d.entries)) > (height*16))
					table.insert(rightclickobjects, d)
					width = t[3]*8+13
					addv = 15
				elseif obj == "button" then
					if type(t[3]) == "table" then
						for i = 3, #t do
							local b = guielement:new("button", rx+width, ry, t[i][1], t[i][2], 1, t[i][3])
							if t[i].textcolor then
								b.textcolor = t[i].textcolor
							end
							table.insert(rightclickobjects, b)
							width = width + #t[i][1]*8+6
						end
					else
						local b = guielement:new("button", rx, ry, t[3], t[4], 1, t[5])
						if t[i].textcolor then
							b.textcolor = t[i].textcolor
						end
						table.insert(rightclickobjects, b)
						width = #t[3]*8+6
					end
					addv = 14
				elseif obj == "dirbuttonset" or obj == "hordirbuttonset" or obj == "verdirbuttonset" or obj == "rotdirbuttonset" or obj == "rotbuttonset" or obj == "orientationbuttonset" or obj == "anglebuttonset" then
					--buttons for 4 directions
					local bt
					if obj == "dirbuttonset" then
						bt = {{{directionsimg, directionsquad["left"]}, "left"},
						{{directionsimg, directionsquad["up"]}, "up"},
						{{directionsimg, directionsquad["right"]}, "right"},
						{{directionsimg, directionsquad["down"]}, "down"}}
					elseif obj == "hordirbuttonset" then
						bt = {{{directionsimg, directionsquad["left"]}, "left"},
						{{directionsimg, directionsquad["right"]}, "right"}}
					elseif obj == "verdirbuttonset" then
						bt = {{{directionsimg, directionsquad["up"]}, "up"},
						{{directionsimg, directionsquad["down"]}, "down"}}
					elseif obj == "rotdirbuttonset" then
						bt = {{{directionsimg, directionsquad["cw"]}, "right"},
						{{directionsimg, directionsquad["ccw"]}, "left"}}
					elseif obj == "rotbuttonset" then
						bt = {{{directionsimg, directionsquad["cw"]}, "cw"},
						{{directionsimg, directionsquad["ccw"]}, "ccw"}}
					elseif obj == "orientationbuttonset" then
						bt = {{{directionsimg, directionsquad["hor"]}, "hor"},
						{{directionsimg, directionsquad["ver"]}, "ver"}}
					elseif obj == "anglebuttonset" then
						bt = {{{directionsimg, directionsquad["left"]}, "left"},
						{{directionsimg, directionsquad["left up"]}, "left up"},
						{{directionsimg, directionsquad["up"]}, "up"},
						{{directionsimg, directionsquad["right up"]}, "right up"},
						{{directionsimg, directionsquad["right"]}, "right"},
						{{directionsimg, directionsquad["right down"]}, "right down"},
						{{directionsimg, directionsquad["down"]}, "down"},
						{{directionsimg, directionsquad["left down"]}, "left down"}}
					end
					local buttonsstart = #rightclickobjects+1
					for i = 1, #bt do
						--button press function
						local buttonfunc = function(variablenum, dir, obj, objstart, objs)
							--set variable and update button color
							rightclickvalues2[variablenum] = dir
							for i = objstart, objstart+objs-1 do
								if i == obj then
									rightclickobjects[i].bordercolorhigh = {255,127,127}
									rightclickobjects[i].bordercolor = {255,0,0}
								else
									rightclickobjects[i].bordercolorhigh = {255,255,255}
									rightclickobjects[i].bordercolor = {127,127,127}
								end
							end
						end
						local b = guielement:new("button", rx+width, ry, bt[i][1], buttonfunc, 0, {t[2], bt[i][2], #rightclickobjects+1, buttonsstart, #bt}, 1, 8)
						if rightclickvalues2[t[2]] == bt[i][2] then--is the direction selected
							b.bordercolorhigh = {255, 127, 127}
							b.bordercolor = {255, 0, 0}
						end
						table.insert(rightclickobjects, b)
						width = width + 8+4
					end
					addv = 14
				elseif obj == "checkbox" then
					local var = vt[t[2]]
					if var == nil and t.default ~= nil then
						var = t.default
					end
					if type(var) == "string" then
						var = vt[t[2]] == "true"
					end
					local func = t[4] --function called when check box is ticked
					if not func then --if there is no function, make one
						local varid, objecti = t[2], #rightclickobjects+1
						func = function(v)
							rightclickobjects[objecti].var = v
							rightclickvalues2[varid] = v
						end
					end

					local d = guielement:new("checkbox", rx, ry+2, func, var, t[3] or "")
					table.insert(rightclickobjects, d)
					width = #t[3]*8+10
					addv = 13
				elseif obj == "slider" then
					local d = guielement:new("scrollbar", rx, ry, 100, 33, 9, vt[t[2]], "hor")
					d.backgroundcolor = {0,0,0}
					d.scrollstep = 0
					d.displayfunction = t[3]
					d.rightclickvalue = t[2]
					if t.range then
						local v = tostring(vt[t[2]] or defaultvalues[d.rightclickvalue] or 0)
						v = v:gsub("n", "-")
						v = tonumber(v)
						d.value = (v-t.range[1])/(t.range[2]-t.range[1])
						d.rcrange = t.range
						--convert to value for saving
						d.updatefunc = function(self, v)
							local i = self.rightclickvalue
							local min, max, rnd, step = self.rcrange[1], self.rcrange[2], self.rcrange.round, self.rcrange.step
							local s
							if step then
								s = math.floor(((v*(max-min))+min) * (1/step)) /(1/step)
							else
								s = round((v*(max-min))+min, rnd or 2)
							end
							s = tostring(s)
							rightclickvalues2[i] = s:gsub("-", "n")
						end
						--what's displayed in slider
						d.displayfunction = function(self, v)
							local min, max, rnd, step = self.rcrange[1], self.rcrange[2], self.rcrange.round, self.rcrange.step
							local s
							if step then
								s = math.floor(((v*(max-min))+min) * (1/step)) /(1/step)
							else
								s = round((v*(max-min))+min, rnd or 2)
							end
							if math.floor(s) ~= s or string.len(s) <= math.floor(self.width/8)-2 then
								return formatscrollnumber(s)
							else
								return s
							end
						end
						d:updatefunc(d.value)
					end
					if (not d.value) and defaultvalues then
						d.value = ((tonumber(defaultvalues[d.rightclickvalue]) or 0)-t.range[1])/(t.range[2]-t.range[1])
					end
					table.insert(rightclickobjects, d)
					width = 100
					addv = 12
				end
			end
			
			if width+8 > rightclickobjects.width then
				rightclickobjects.width = width+8
			end
			ry = ry + addv
			rightclickobjects.height = rightclickobjects.height + addv
		end

		if rct.objfunc then
			rct.objfunc()
		end
		
		scoot = true
	end
	if scoot then
		--Move if out of screen
		local scootx = ((x/scale)+rightclickobjects.width > width*16)
		local scooty = ((y/scale)+rightclickobjects.height > height*16)
		local shiftx = ((x/scale)-rightclickobjects.width < 0)
		local shifty = ((y/scale)-rightclickobjects.height < 0)
	
		local truey = rightclickobjects[1].y
			
		if scootx or scooty then
			for i = 1, #rightclickobjects do
				local obj = rightclickobjects[i]
				if scootx then
					if shiftx then
						--neither work, just shift
						rightclickobjects[i].x = ((width*16)-(x/scale))-rightclickobjects.width+rightclickobjects[i].x
					else
						rightclickobjects[i].x = rightclickobjects[i].x - rightclickobjects.width
					end
				end
				if scooty then
					if shifty then
						--neither work, just shift
						rightclickobjects[i].y = ((height*16)-(y/scale))-rightclickobjects.height+rightclickobjects[i].y
					else
						--just flip
						rightclickobjects[i].y = rightclickobjects[i].y - rightclickobjects.height
					end
				end
				obj:updatePos()
			end
		end
		rightclickobjects.x = rightclickobjects[1].x-4
		rightclickobjects.y = rightclickobjects[1].y-4
	end
	return true
end

function rightclickmenuclick(i)
	if i > 1 then
		local r = map[rightclickmenucox][rightclickmenucoy]
		if tablecontains(customenemies, r[2]) and enemiesdata[r[2]] and enemiesdata[r[2]].rightclickmenu then
			--custom enemy
			--print(i, enemiesdata[r[2]].rightclickmenu[i])
			if enemiesdata[r[2]].rightclickmenutable then
				r[3] = i
			else
				r[3] = enemiesdata[r[2]].rightclickmenu[i]
			end
		else
			r[3] = rightclickvalues[rightclickmenutile][i]
		end
		
		if editorstate == "selectiontool" and #selectiontoolselection > 0 then
			for i, t in pairs(selectiontoolselection) do
				local x, y = t[1], t[2]
				if map[x][y][2] == r[2] then
					map[x][y][3] = r[3]
				end
			end
		end
	end
end

function closecustomrc(save)
	if customrcopen == false then
		return
	end
	if rightclickobjects and inmap(rightclickmenucox,rightclickmenucoy) then
		if customrcopen == "custom_enemy" then
			local v = enemiesdata[map[rightclickmenucox][rightclickmenucoy][2]]
			local vt = rightclickvalues2
			if v then
				local index = 0
				for i = 1, #v.rightclick do
					if v.rightclick[i][1] ~= "text" then
						index = index + 1
						if v.rightclick[i][1] == "dropdown" then
							local ents =  v.rightclick[i][4]
							if vt[index] then
								vt[index] = tostring(ents[vt[index]])
								vt[index] = vt[index]:gsub("-", "B")
							end
						end
					end
				end
			else
				notice.new("rightclick menu error", notice.red, 3)
			end
		else
			--save dropdowns correctly
			local rct = rightclicktype[entitylist[map[rightclickmenucox][rightclickmenucoy][2]].t] --custom right-click table
			local vt = rightclickvalues2
			if rct then
				for i, t in pairs(rct.format) do
					local ttype = type(t)
					if ttype == "table" then
						local obj = t[1]
						if obj == "dropdown" and ((not rct.t) or t.ignorerctt) then
							if vt[t[2]] then
								vt[t[2]] = t[5][vt[t[2]]]
							end
						end
					end
				end
			else
				notice.new("rightclick menu error", notice.red, 3)
			end
		end
	end
	if rightclicktype[customrcopen] and rightclicktype[customrcopen].savefunc then
		rightclicktype[customrcopen].savefunc()
	end
	if customrcopen == "custom_enemy" then
		local s = ""
		for i = 1, #rightclickvalues2 do
			s = s .. tostring(rightclickvalues2[i]) .. "|"
		end
		s = s:sub(1, -2)
		map[rightclickmenucox][rightclickmenucoy][3] = s
	elseif save and rightclicktype[customrcopen].default then
		local s = ""
		for i = 1, #rightclickvalues2 do
			s = s .. tostring(rightclickvalues2[i]) .. "|"
		end
		s = s:sub(1, -2)
		map[rightclickmenucox][rightclickmenucoy][3] = s
		
		if editorstate == "selectiontool" and #selectiontoolselection > 0 then
			for i, t in pairs(selectiontoolselection) do
				local x, y = t[1], t[2]
				if map[x][y][2] == map[rightclickmenucox][rightclickmenucoy][2] then
					map[x][y][3] = map[rightclickmenucox][rightclickmenucoy][3]
				end
			end
		end
	end
	rightclickvalues2 = {}
	rightclickobjects = {}
	customrcopen = false
end

function startrcregion(var, step)
	local var = var or 1
	if editorstate == "linktool" then
		editorstate = "tools"
	end
	
	local r = map[rightclickmenucox][rightclickmenucoy]

	local x, y
	if rightclickvalues2[var+2] and rightclickvalues2[var+3] then
		x, y = rightclickvalues2[var+2]:gsub("n", "-"), rightclickvalues2[var+3]:gsub("n", "-")
		x = rightclickmenucox-1+tonumber(x)
		y = rightclickmenucoy-1+tonumber(y)
	end
	guielements["rightclickdrag"] = regiondrag:new(tonumber(rightclickvalues2[var]), tonumber(rightclickvalues2[var+1]), x or rightclickmenucox-1, y or rightclickmenucoy-1)
	guielements["rightclickdrag"].vars = deepcopy(rightclickvalues2)
	guielements["rightclickdrag"].cox = rightclickmenucox-1
	guielements["rightclickdrag"].coy = rightclickmenucoy-1
	if step then
		guielements["rightclickdrag"].step = step
	end
	closecustomrc(true)
	rightclickobjects = {}
	customrcopen = "region"
	rightclickmenuopen = true
end

function rcrtsize() --right click region trigger size
	local w = tostring(guielements["rightclickdrag"].width):gsub("-", "n") --change - to n to make level load properly
	local h = tostring(guielements["rightclickdrag"].height):gsub("-", "n")
	local x = tostring(guielements["rightclickdrag"].x-guielements["rightclickdrag"].cox):gsub("-", "n")
	local y = tostring(guielements["rightclickdrag"].y-guielements["rightclickdrag"].coy):gsub("-", "n")

	rightclickvalues2 = deepcopy(guielements["rightclickdrag"].vars)
	
	local r = map[rightclickmenucox][rightclickmenucoy]
	customrcopen = entitylist[r[2]].t
	if rightclicktype[customrcopen].regionfunc then
		rightclicktype[customrcopen].regionfunc(w,h,x,y)
	end
	closecustomrc(true)
	guielements["rightclickdrag"] = nil
end

function startrcpath(var) --snake block path
	local var = var or 1
	local t = {}
	if type(var) == "table" then
		t = var
		var = t[1]
	end
	if editorstate == "linktool" then
		editorstate = "tools"
	end

	rightclickpath = {
		path = {t.default or {1,0}},
		last = t.default or {1,0}, --last placed
		dir = "right",
		x = rightclickmenucox,--offsetx
		y = rightclickmenucoy,--offsety
		pipe = t.pipe or false, --is it wide?
		vars = deepcopy(rightclickvalues2),
		drag = true, --able to add onto path currently?
		snakelength = rightclickvalues2[2], --if snakeblock, what is its length
	}
	local rcp = rightclickpath

	--load path
	if rightclickvalues2[var] then
		local s = rightclickvalues2[var]:gsub("n", "-")
		local s2 = s:split("`")
		local s3
		local ox, oy = rcp.last[1], rcp.last[2]
		for i = 1, #s2 do
			s3 = s2[i]:split(":")
			local x, y = tonumber(s3[1]), tonumber(s3[2])
			if x and y then
				rcp.last = {x, y}
				table.insert(rcp.path, {x, y})
				if x > ox then
					rcp.dir = "right"
				elseif x < ox then
					rcp.dir = "left"
				elseif y > oy then
					rcp.dir = "down"
				elseif y < oy then
					rcp.dir = "up"
				end
				ox, oy = x, y
			else
				break
			end
		end
	end
	
	--different origin for snakeblock
	if (not rcp.pipe) and (not t.default) then
		if #rcp.path > 1 then
			local ox, oy = 1, 0
			local tx, ty = rcp.path[2][1], rcp.path[2][2]
			if ty == 0 then
				if tx > 0 then
					--nothing
				else
					ox, oy = tx+1, ty
				end
			elseif ty > 0 then
				ox, oy = tx, ty-1
			else
				ox, oy = tx, ty+1
			end
			rcp.path[1][1], rcp.path[1][2] = ox, oy
		end
	end
	
	closecustomrc(true)
	rightclickobjects = {}
	customrcopen = "path"
	rightclickmenuopen = true
end

function setrcpath()
	rightclickvalues2 = deepcopy(rightclickpath.vars)

	local rcp = rightclickpath
	local s = ""
	for i = 2, #rcp.path do
		local x = tostring(rcp.path[i][1])
		local y = tostring(rcp.path[i][2])
		s = s .. x:gsub("-", "n") .. ":" .. y:gsub("-", "n") .. "`"
	end
	s = s:sub(1, -2)

	local r = map[rightclickmenucox][rightclickmenucoy]
	customrcopen = entitylist[r[2]].t
	if rightclicktype[customrcopen].pathfunc then
		rightclicktype[customrcopen].pathfunc(s)
	end
	rightclickpath = {}
	closecustomrc(true)
	allowdrag = true
end

function startrctrack(var) --track path
	local var = var or 1
	local t = {}
	if type(var) == "table" then
		t = var
		var = t[1]
	end
	if editorstate == "linktool" then
		editorstate = "tools"
	end

	rightclicktrack = {
		--c=closed,o=open,u=up,d=down,l=left,r=right,ur=up-right,etc.
		--grab: d=default,r=reverse,t=tile,tr=reverse tile
		path = {t.default or {0,0,"c","c","d"}},
		last = t.default or {0,0,"c","c","d"}, --last placed
		dir = "c",
		x = rightclickmenucox,--offsetx
		y = rightclickmenucoy,--offsety
		vars = deepcopy(rightclickvalues2),
		drag = true, --able to add onto path currently?
		var = var --which entity variable is the path loaded to?
	}
	local rcp = rightclicktrack

	--load path
	if rightclickvalues2[var] then
		rcp.path = {}
		local s = rightclickvalues2[var]:gsub("n", "-")
		local s2 = s:split("`")
		local s3
		local ox, oy = rcp.last[1], rcp.last[2]
		for i = 1, #s2 do
			s3 = s2[i]:split(":")
			local x, y = tonumber(s3[1]), tonumber(s3[2])
			local start, ending, grab = s3[3], s3[4], s3[5]
			if x and y then
				rcp.last = {x, y,start,ending}
				table.insert(rcp.path, {x, y, start, ending, grab})
				ox, oy = x, y
			else
				break
			end
		end
	end
	
	--grab right click menu (rightclick-ception!)
	trackrightclickmenustage = nil
	local clickfunc = function(i)
		local t = {"", "d", "r", "f", "fr", "t", "tr", "tf", "tfr"}
		rightclicktrack.path[trackrightclickmenustage][5] = t[i-1]
	end
	trackrightclickmenu = guielement:new("rightclick", 0, 0, 13, clickfunc, false,
		"track grabs:", "nothing", "entity {","entity }","entity fast {","entity fast }","tile {","tile }","tile { fast", "tile } fast")
	trackrightclickmenu.active = false
	
	closecustomrc(true)
	rightclickobjects = {}
	customrcopen = "trackpath"
	if android then
		ANDROIDRIGHTCLICK = false
	end
	rightclickmenuopen = true
end

function setrctrack()
	rightclickvalues2 = deepcopy(rightclicktrack.vars)

	local rcp = rightclicktrack
	local s = ""
	for i = 1, #rcp.path do
		--x:y:start:ending`
		local x = tostring(rcp.path[i][1])
		local y = tostring(rcp.path[i][2])
		local start = tostring(rcp.path[i][3])
		local ending = tostring(rcp.path[i][4])
		local grab = tostring(rcp.path[i][5])
		s = s .. x:gsub("-", "n") .. ":" .. y:gsub("-", "n") .. ":" .. start .. ":" .. ending .. ":" .. grab .. "`"
	end
	s = s:sub(1, -2)

	local r = map[rightclickmenucox][rightclickmenucoy]
	customrcopen = entitylist[r[2]].t
	if rightclicktype[customrcopen].trackfunc then
		rightclicktype[customrcopen].trackfunc(s, rightclicktrack.var)
	end
	rightclicktrack = {}
	closecustomrc(true)
	generatetrackpreviews()
end

function startrclink(t, i) --name of link, link id
	--[[if editorstate == "linktool" then
		editorstate = "tools"
	end]]
	
	local r = map[rightclickmenucox][rightclickmenucoy]
	linktooli = false
	if #r > 1 then
		local tile = r[2]
		linktoolX, linktoolY = rightclickmenucox, rightclickmenucoy
		linktoolt = t or "input"
		linktooli = i
	end
	closecustomrc(true)
	rightclickobjects = {}
	customrcopen = "link"
	rightclickmenuopen = true
end

function setrclink(endx, endy)
	local x, y = rightclickmenucox, rightclickmenucoy
	local r = map[endx][endy]
	--LIST OF NUMBERS THAT ARE ACCEPTED AS INPUTS (buttons, laserdetectors)
	local customoutput = false
	if rightclicktype[entityquads[map[rightclickmenucox][rightclickmenucoy][2]].t].customoutputs and entityquads[r[2]] then
		customoutput = tablecontains(
		rightclicktype[entityquads[map[rightclickmenucox][rightclickmenucoy][2]].t].customoutputs, entityquads[r[2]].t )
	end
	if #r > 1 and (tablecontains( outputsi, r[2] ) or customoutput) then
		r = map[x][y]
		
		local i = 1
		while (r[i] ~= "link" or (linktooli and tostring(linktooli) ~= tostring(r[i+3]))) and i <= #r do
			i = i + 1
		end
		
		map[x][y][i] = "link"
		map[x][y][i+1] = endx
		map[x][y][i+2] = endy
		if linktooli then
			map[x][y][i+3] = linktooli
		end
		
		if editorstate == "selectiontool" and #selectiontoolselection > 0 then
			for i, t in pairs(selectiontoolselection) do
				local x, y = t[1], t[2]
				if tablecontains(inputsi, map[x][y][2]) then
					local r = map[x][y]
					local i = 1
					while (r[i] ~= "link" or (linktooli and tostring(linktooli) ~= tostring(r[i+3]))) and i <= #r do
						i = i + 1
					end
					map[x][y][i] = "link"
					map[x][y][i+1] = endx
					map[x][y][i+2] = endy
					if linktooli then
						map[x][y][i+3] = linktooli
					end
				end
			end
		end
	end

	allowdrag = false
	customrcopen = false
	rightclickmenuopen = false
end

function resetrclink(id) --id
	local x, y = rightclickmenucox, rightclickmenucoy
	local r = map[x][y]
		
	local i = 1
	while (r[i] ~= "link" or (id and tostring(id) ~= tostring(r[i+3]))) and i <= #r do
		i = i + 1
	end
	
	table.remove(map[x][y], i)
	table.remove(map[x][y], i)
	table.remove(map[x][y], i)
	if id then
		table.remove(map[x][y], i)
	end
	
	if editorstate == "selectiontool" and #selectiontoolselection > 0 then
		for i, t in pairs(selectiontoolselection) do
			local x, y = t[1], t[2]
			if tablecontains(inputsi, map[x][y][2]) then
				local i = 1
				while (r[i] ~= "link" or (id and tostring(id) ~= tostring(r[i+3]))) and i <= #r do
					i = i + 1
				end
				table.remove(map[x][y], i)
				table.remove(map[x][y], i)
				table.remove(map[x][y], i)
				if id then
					table.remove(map[x][y], i)
				end
			end
		end
	end

	linktoolX, linktoolY = nil, nil
end

function editor_mousereleased(x, y, button)
	if minimapmoving then
		return
	end

	if button == "l" then
		if editormenuopen == false then
			tilemenumoving = false
			if editorstate == "linktool" then
			elseif editorstate == "selectiontool" then
				if selectiontoolclick[1][1] and selectiontoolclick[1][2] then
					selectiontoolclick[2][1] = x/scale + xscroll*16
					selectiontoolclick[2][2] = y/scale + yscroll*16
					local x1, y1, x2, y2 = selectiontoolclick[1][1], selectiontoolclick[1][2], selectiontoolclick[2][1], selectiontoolclick[2][2]
					if x2 < x1 then
						x1 = selectiontoolclick[2][1]
						x2 = selectiontoolclick[1][1]
					end
					if y2 < y1 then
						y1 = selectiontoolclick[2][2]
						y2 = selectiontoolclick[1][2]
					end
					x1, y1, x2, y2 = math.ceil(x1/16), math.ceil((y1+8)/16), math.ceil(x2/16), math.ceil((y2+8)/16)
					for x = x1, x2 do
						for y = y1, y2 do
							if ismaptile(x, y) and map[x][y][2] and tonumber(map[x][y][2]) and map[x][y][2] > 1 then
								table.insert(selectiontoolselection, {x, y})
							end
						end
					end
				end
				
				selectiontoolclick = {{false, false}, {false, false}}
				allowdrag = true
			else
				if pastingtiles and tileselectionmoving then
					--PASTE TILES
					local sx, sy = getMouseTile(x, y+8*screenzoom*scale)
					sx = sx + pastecenter[1]-1
					sy = sy + pastecenter[2]-1
					for i, v in pairs(mtclipboard) do
						for j, w in pairs(v) do
							if not (w[1] == 1 and (not w[2]) and (not w["back"]) and pastemode == 1) then
								tx = sx + i
								ty = sy + j
								if ismaptile(tx, ty) then
									local d = mtclipboard[i][j]
									currenttile = d[1]
									backgroundtilemode = false
									placetile(x+(i-1 + pastecenter[1])*16*scale, y+(j-1 + pastecenter[2])*16*scale)
									map[tx][ty] = shallowcopy(d)
									map[tx][ty]["gels"] = {}
									--generate new tracks if track moved
									if d[2] and entityquads[d[2]] and (entityquads[d[2]].t == "track" or entityquads[d[2]].t == "trackswitch") then
										generatetrackpreviews()
									end
								end
							end
						end
					end
					for x = 1, mapwidth do
						for y = 1, mapheight do
							local d = map[x][y]
							if tablecontains(inputsi, d[2]) then
								for i = 3, #d do
									if d[i] == "link" then
										if inrange(d[i+1], tileselection[1], tileselection[3], true) and inrange(d[i+2], tileselection[2], tileselection[4], true) then
											d[i+1] = d[i+1] + (sx-tileselection[1])+1
											d[i+2] = d[i+2] + (sy-tileselection[2])+1
										end
									end
								end
								
							end
						end
					end
					local tx, ty = getMouseTile(x, y+8*screenzoom*scale)
					tileselection = {tx+math.floor(pastecenter[1]), ty+math.floor(pastecenter[2]), tx+math.floor(pastecenter[1])+#mtclipboard-1, ty+math.floor(pastecenter[2])+#mtclipboard[1]-1}
					tileselection.finished = true
					pastingtiles = false
					tileselectionmoving = false
				elseif tileselection and not tileselection.finished then
					local sx, sy = math.min(tileselection[1],tileselection[3]), math.min(tileselection[2],tileselection[4])
					local sw, sh = math.max(tileselection[1],tileselection[3]), math.max(tileselection[2],tileselection[4])
					tileselection = {sx, sy, sw, sh}
					tileselection.finished = true
				end
				allowdrag = true
			end
		else
			guirepeattimer = 0
			minimapdragging = false
			tilestampholdtimer = false
			if editorstate == "tiles" then
				allowdrag = true
				if editmtobjects then
				elseif editentities == false then
					if tilestampselection then
						local t = tilestampselection
						if x <= t.x then
							t.x = t.x+17*scale
						end
						if y <= t.y then
							t.y = t.y+17*scale
						end
						if x < t.x then
							t.x2 = t.x; t.x = x
						else
							t.x2 = x
						end
						if y < t.y then
							t.y2 = t.y; t.y = y
						else
							t.y2 = y
						end
						pastingtiles = true
						pastecenter = {0,0}
						mtclipboard = {}
						local tile = 1

						for tx = 1, math.ceil((t.x2-t.x)/(17*scale)) do
							mtclipboard[tx] = {}
							for ty = 1, math.ceil((t.y2-t.y)/(17*scale)) do
								local tile = gettilelistpos(t.x+(17*scale)*(tx-1), t.y+(17*scale)*(ty-1))
								if tile and tile <= tilelistcount+1 then
									if animatedtilelist then
										tile = tile + tileliststart-1+90000
									else
										tile = tile + tileliststart-1
									end
									mtclipboard[tx][ty] = {tile or 1}
								end
							end
						end
						allowdrag = false
						editorclose()
						tilestampselection = false
					else
						if android then
							local tile = gettilelistpos(x, y)
							if tile and tile <= tilelistcount+1 then
								editorclose()
								--allowdrag = false
							end
						end
					end
				else
					tilestampselection = false
					if android then
						local tile, list = getentitylistpos(x, y)
						if tile then
							editorclose()
							--allowdrag = false
						end
					end
				end
			end
		end
	end

	if rightclickmenuopen then
		if customrcopen then
			if rightclickobjects then
				for i = 1, #rightclickobjects do
					local obj = rightclickobjects[i]
					if obj then
						if obj:unclick(x, y, button) then
							return
						end
					end
				end
			end
		end
	end
	
	if animationguilines and editormenuopen and not changemapwidthmenu and not minimapmoving then
		for i, v in pairs(animationguilines) do
			for k, w in pairs(v) do					
				w:unclick(x, y, button)
			end
		end
	end
end

function editor_keypressed(key, textinput)
	if (not editormenuopen) and (not customrcopen) and (not rightclickmenuopen) then
		if key == "=" then
			assistmode = not assistmode
		elseif (key == "-" or key == "tab") then
			backgroundtilemode = not backgroundtilemode
		elseif key == "q" then
			if editentities then
				editentities = false
				currenttile = 1
				tilesall()
			else
				editentities = true
				currenttile = 1
				tilesentities()
			end
			editmtobjects = false
		elseif tilehotkeys[key] then
			--tile hotkeys
			if tilehotkeys[key].t then
				if ((not tilehotkeys[key].entity) and tilequads[tilehotkeys[key].t]) or (tilehotkeys[key].entity) then
					currenttile = tilehotkeys[key].t
					editentities = tilehotkeys[key].entity
					if editentities then
						tilesentities()
					else
						tilesall()
					end
					if type(tilehotkeys[key].t) == "string" then
						currenttile = tilehotkeys[key].t --set custom enemy
					end
				end
			end
		end
	end

	if key == "m" then
		if not editormenuopen and not rightclickmenuopen then
			minimapmoving = true
			editormenuopen = true
		elseif minimapmoving then
			minimapmoving = false
			editormenuopen = false
		end
	end
	if brushsizetoggle and (not editormenuopen) then
		if key == "up" and brushsizey > 1 then
			brushsizey = brushsizey - 1
		elseif key == "left" and brushsizex > 1 then
			brushsizex = brushsizex - 1
		elseif key == "down" and brushsizey < 15 then
			brushsizey = brushsizey + 1
		elseif key == "right" and brushsizex < 15 then
			brushsizex = brushsizex + 1
		end
	end
	if key == "escape" then
		if pastingtiles then
			pastingtiles = false
		elseif tileselection then
			resettileselection()
		end
		if customrcopen then
			if customrcopen == "region" then
				rcrtsize()
				rightclickmenuopen = false
				allowdrag = false
				customrcopen = false
			elseif customrcopen == "path" then
				setrcpath()
				rightclickmenuopen = false
				allowdrag = false
				customrcopen = false
			elseif customrcopen == "trackpath" then
				setrctrack()
				rightclickmenuopen = false
				allowdrag = false
				customrcopen = false
			elseif customrcopen == "link" then
				customrcopen = false
				rightclickmenuopen = false
			else
				closecustomrc(true)
				customrcopen = false
				rightclickmenuopen = false
			end
		elseif minimapmoving then
			minimapmoving = false
			editormenuopen = false
		elseif changemapwidthmenu then
			mapwidthcancel()
		elseif confirmmenuopen then
			closeconfirmmenu()
		else
			if editormenuopen then
				editorclose()
			else
				editoropen()
				customrcopen = false
			end
		end
	elseif (key == "return" or key == "\\") and not editormenuopen and rightclickmenuopen then
		if customrcopen == "region" then
			rcrtsize()
			rightclickmenuopen = false
			allowdrag = false
			customrcopen = false
		elseif customrcopen == "path" then
			setrcpath()
			rightclickmenuopen = false
			allowdrag = false
			customrcopen = false
		elseif customrcopen == "trackpath" then
			setrctrack()
			rightclickmenuopen = false
			allowdrag = false
			customrcopen = false
		elseif customrcopen == "link" then
			rightclickmenuopen = false
			allowdrag = false
			customrcopen = false
		elseif customrcopen then
			local inputting = false
			for i = 1, #rightclickobjects do
				local obj = rightclickobjects[i]
				if obj.inputting then
					inputting = true
				end
			end
			if not inputting then
				rightclickmenuopen = false
				allowdrag = false
				closecustomrc(true)
				customrcopen = false
			end
		end
	end
	if editormenuopen == false and rightclickmenuopen == false then
		if key == "delete" or key == "backspace" then
			if tileselection and tileselection.finished then
				emptySelection()
			end
		end
		if ctrlpressed then
			if key == "s" then
				if tileselection and tileselection.finished then
					--save
					
					savemtobject(getTilesSelection())
					loadmtobjects()
					tilesobjects()
					notice.new("Selection saved", notice.white, 3)
				elseif not tileseletion then
					--save level
					savelevel(); levelmodified = false
				end
			elseif key == "c" or key == "x" then
				if tileselection and tileselection.finished then
					--copy
					mtclipboard = getTilesSelection()
					
					if key == "x" then
						emptySelection()
						notice.new("Selection cut", notice.white, 3)
					else
						notice.new("Selection copied", notice.white, 3)
					end
				end
			elseif key == "v" then
				if pastingtiles == false and next(mtclipboard) ~= nil then
					pastecenter = {0, 0}
					pastingtiles = true
					editentities = false
					tilesall()
					-- clear selection
					resettileselection()
					notice.new("Selection Pasted", notice.white, 3)
				end
			elseif key == "a" then
				--select everything
				tileselection = {1, 1, mapwidth, mapheight}
				tileselection.finished = true
			elseif key == "e" then
				--deselect
				resettileselection()
				selectionbutton()
			elseif key == "z" then
				undo_undo()
			end
			
			-- number key + ctrl = paste that object (if exists)
			for i = 1, 9 do
				if key == tostring(i) and multitileobjects[i] ~= nil then
					mtclipboard = multitileobjects[i]
					pastecenter = {0, 0}
					pastingtiles = true
					editentities = false
				end
			end
		end
	elseif editormenuopen then
		--set tile hotkeys
		if editorstate == "tiles" then
			if tilehotkeys[key] then
				local mousex, mousey = love.mouse.getX(), love.mouse.getY()
				local tile = gettilelistpos(mousex, mousey)
				local selectedtile, isentity = false, false
				if editmtobjects then
				elseif editentities == false then
					if tile and tile <= tilelistcount+1 then
						if animatedtilelist then
							selectedtile = tile + tileliststart-1+90000
						else
							selectedtile = tile + tileliststart-1
						end
					end
				else
					local tile, list = getentitylistpos(love.mouse.getX(), love.mouse.getY())
					if tile then
						selectedtile = entitiesform[list][tile]
						isentity = true
					end
				end
				if selectedtile then
					if tilehotkeys[key].t == selectedtile then
						tilehotkeys[key].t = false
					else
						tilehotkeys[key].t = selectedtile
					end
					tilehotkeys[key].entity = isentity

					tilehotkeysindex = {}
					tilehotkeysentityindex = {}
					for i, t in pairs(tilehotkeys) do
						if t.entity then
							tilehotkeysentityindex[t.t] = i
						else
							tilehotkeysindex[t.t] = i
						end
					end
				end
			end
		end
	end
	
	if rightclickmenuopen and customrcopen then
		if rightclickobjects then
			for i = 1, #rightclickobjects do
				local obj = rightclickobjects[i]
				obj:keypress(key)
			end
		end
	end
	
	if animationguilines then
		for i, v in pairs(animationguilines) do
			for k, w in pairs(v) do
				w:keypressed(key, textinput)
			end
		end
	end

	--quicktest
	if key == "\\" and (not confirmmenuopen) then
		test_level(objects["player"][1].x, objects["player"][1].y)
		return
	end
end

function editor_mousemoved(x, y, dx, dy)
	if love.mouse.isDown("l") then
		if minimapmoving then
			local w = width*16-52
			local h = height*16-52
			local s, nmw, nmox, nmh, nmoy
			s = math.min(w/mapwidth, h/mapheight)
			w = mapwidth*s
			h = mapheight*s
			nmw = mapwidth
			nmox = 0
			nmh = mapheight
			nmoy = 0
		
			local mapx, mapy = (width*16 - w)/2, (height*16 - h)/2
			splitxscroll[1] = splitxscroll[1]+dx/s/scale
			if splitxscroll[1] < 0 then
				splitxscroll[1] = 0
			elseif splitxscroll[1] > mapwidth-width then
				splitxscroll[1] = mapwidth-width
			end
			splityscroll[1] = splityscroll[1]+dy/s/scale
			if splityscroll[1] < 0 then
				splityscroll[1] = 0
			elseif splityscroll[1] > mapheight-height-1 then
				splityscroll[1] = mapheight-height-1
			end
			
			toggleautoscroll(false)
		elseif tilemenumoving then
			--tilemenuy = math.min(0, math.max(-8*16, tilemenuy + dy/scale))
		end
	end
end

function editor_filedropped(file)
	if editormenuopen then
		if editorstate == "tools" then --add mappack icon
			local mousex, mousey = love.mouse.getPosition()
			if mousex > 151*scale and mousey > 146*scale and mousex < 203*scale and mousey < 198*scale then
				local r, d = pcall(love.image.newImageData, file)
				if r then
					d:encode("png", mappackfolder .. "/" .. mappack .. "/icon.png")
					editmappackicon = love.graphics.newImage(file)
				end
			end
		elseif editorstate == "custom" then --replace custom image
			if customtabstate == "graphics" or customtabstate == "tiles" or customtabstate == "backgrounds" or (customtabstate == "text" and textstate == "levelscreen") then
				replacecustomimage(file)
			end
		end
	end
end

function getTiles(pos1, pos2)
	local objecttable = {}
	local tx = {}
	local tile1x,tile1y = getMouseTile(pos1[1], pos1[2])
	local tile2x,tile2y = getMouseTile(pos2[1], pos2[2])
	local xnum = tile2x - tile1x
	local ynum = tile2y - tile1y
	for i = 1, xnum do
		tx = {}
		for j = 1, ynum do
			table.insert(tx, map[tile1x + i - 1][tile1y + j - 1][1])
		end
		table.insert(objecttable, tx)
	end
	return objecttable
end

function getTilesSelection()
	local objecttable = {}
	local tx
	for x = math.max(1,tileselection[1]), math.min(tileselection[3],mapwidth) do
		tx = {}
		for y = math.max(1, tileselection[2]), math.min(tileselection[4],mapheight) do
			table.insert(tx, shallowcopy(map[x][y]))
		end
		table.insert(objecttable, tx)
	end
	return objecttable
end

function emptySelection(storeundo)
	for x = tileselection[1], tileselection[3] do
		for y = tileselection[2], tileselection[4] do
			--[[if storeundo then
				undo_store(x,y)
			end]]
			currenttile = 1
			if ismaptile(x, y) then
				placetile((x-1-xscroll)*16*scale, (y-1-yscroll-.5)*16*scale)
				map[x][y] = {1}
				map[x][y]["gels"] = {}
			end
		end
	end
	mtjustsaved = true
	
	generatespritebatch()
end

function resettileselection()
	tileselection = false
end

function loadmtobjects()
	-- get multitile objects!
	multitileobjects = nil
	multitileobjects = {}
	multitileobjectnames = nil
	multitileobjectnames = {}
	if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/objects.txt") then
		local data = love.filesystem.read(mappackfolder .. "/" .. mappack .. "/objects.txt")
		if #data > 0 then
			data = string.sub(data, 1, -2)
			local split1 = data:split("\n")
			local split2, split3
			for i = 1, #split1 do
				-- objects
				split2 = split1[i]:split("=")
				table.insert(multitileobjectnames, split2[1])
				-- rows
				if string.find(split1[i],":") then
					split3 = split2[2]:split(":")
				else
					split3 = {split2[2]}
				end
				local ox = {}
				local oo = {}
				for j = 1, #split3 do
					ox = {}
					local split4 = split3[j]:split(",")
					for u = 1, #split4 do
						--finally get tile, entity, and rightclickvalues
						local split5 = split4[u]:split("-")
						local tile = tonumber(split5[1])
						local back
						if not tile then --background tiles
							local s = split5[1]:split("╚")
							tile = tonumber(s[1])
							back = tonumber(s[2])
						end
						local entity = split5[2]
						local argument
						if entity and (not tonumber(entity)) and entity:find("╔") then --entity arguments
							local s = split5[2]:split("╔")
							entity = s[1]
							argument = s[2]
						end
						table.insert(ox, {tile,tonumber(entity) or entity,split5[3],back=back,argument=argument})
					end
					table.insert(oo, ox)
				end
				table.insert(multitileobjects, oo)
			end
		end
	end
end

--check box shtuffs
function toggleautoscroll(var)
	if var ~= nil then
		autoscroll = var
	else
		autoscroll = not autoscroll
	end
	guielements["autoscrollcheckbox"].var = autoscroll
end
function toggleintermission(var)
	if var ~= nil then
		intermission = var
	else
		intermission = not intermission
	end
	guielements["intermissioncheckbox"].var = intermission; levelmodified = true
end
function togglewarpzone(var)
	if var ~= nil then
		haswarpzone = var
	else
		haswarpzone = not haswarpzone
	end
	guielements["warpzonecheckbox"].var = haswarpzone; levelmodified = true
end
function toggleunderwater(var)
	if var ~= nil then
		underwater = var
	else
		underwater = not underwater
	end
	guielements["underwatercheckbox"].var = underwater; levelmodified = true
end
function togglebonusstage(var)
	if var ~= nil then
		bonusstage = var
	else
		bonusstage = not bonusstage
	end
	guielements["bonusstagecheckbox"].var = bonusstage; levelmodified = true
end
function togglecustombackground(var)
	if var ~= nil then
		custombackground = var
	else
		custombackground = not custombackground
	end
	
	if custombackground then
		loadcustombackground(custombackground)
	end
	
	guielements["custombackgroundcheckbox"].var = custombackground; levelmodified = true
end
function togglecustomforeground(var)
	if var ~= nil then
		customforeground = var
	else
		customforeground = not customforeground
	end
	
	if customforeground then
		loadcustomforeground(customforeground)
	end
	
	guielements["customforegroundcheckbox"].var = customforeground; levelmodified = true
end
function toggleautoscrolling(var)
	if var ~= nil then
		autoscrolling = var
	else
		autoscrolling = not autoscrolling
	end
	guielements["autoscrollingcheckbox"].var = autoscrolling; levelmodified = true
end
function toggleedgewrapping(var)
	if var ~= nil then
		edgewrapping = var
	else
		edgewrapping = not edgewrapping
	end
	guielements["edgewrappingcheckbox"].var = edgewrapping; levelmodified = true
end
function togglelightsout(var)
	if var ~= nil then
		lightsout = var
	else
		lightsout = not lightsout
	end
	guielements["lightsoutcheckbox"].var = lightsout; levelmodified = true
end
function togglelowgravity(var)
	if var ~= nil then
		lowgravity = var
	else
		lowgravity = not lowgravity
	end
	guielements["lowgravitycheckbox"].var = lowgravity; levelmodified = true
end
function togglesteve(var)
	if var ~= nil then
		pressbtosteve = var
	else
		pressbtosteve = not pressbtosteve
	end
	guielements["stevecheckbox"].var = pressbtosteve
end
function togglehudvisible(var)
	if var ~= nil then
		hudvisible = var
	else
		hudvisible = not hudvisible
	end
	guielements["hudvisiblecheckbox"].var = hudvisible
end
function togglehudworldletter(var)
	if var ~= nil then
		hudworldletter = var
	else
		hudworldletter = not hudworldletter
	end
	guielements["hudworldlettercheckbox"].var = hudworldletter
	for i = 1, #mappacklevels do --world
		if guielements["world-" .. i] then
			local world = i
			if hudworldletter and world > 9 and world <= 9+#alphabet then
				world = alphabet:sub(world-9, world-9)
			end
			guielements["world-" .. i].text = TEXT["world "] .. world
		end
	end
end
function togglehudoutline(var)
	if var ~= nil then
		hudoutline = var
	else
		hudoutline = not hudoutline
	end
	guielements["hudoutlinecheckbox"].var = hudoutline
end
function togglehudsimple(var)
	if var ~= nil then
		hudsimple = var
	else
		hudsimple = not hudsimple
	end
	guielements["hudsimplecheckbox"].var = hudsimple
end

function changebackground(var)
	levelmodified = true
	if var == 4 then
		background = var
		backgroundrgbon = true
		--guielements["backgrounddropdown"].var = var
		love.graphics.setBackgroundColor(unpack(backgroundrgb))
		backgroundcolor[4] = backgroundrgb
	else
		background = var
		backgroundrgbon = false
		--guielements["backgrounddropdown"].var = var
		love.graphics.setBackgroundColor(backgroundcolor[var])
	end
end

function changebackgroundrgb()
	levelmodified = true
	local onev = tonumber(guielements["backgroundinput1"].value)
	local twov = tonumber(guielements["backgroundinput2"].value)
	local thev = tonumber(guielements["backgroundinput3"].value)
	if onev == nil then
		guielements["backgroundinput1"].value = 0
		tonumber(guielements["backgroundinput1"].value)
	end
	if twov == nil then
		guielements["backgroundinput2"].value = 0
		twov = tonumber(guielements["backgroundinput2"].value)
	end
	if thev == nil then
		guielements["backgroundinput3"].value = 0
		thev = tonumber(guielements["backgroundinput3"].value)
	end
	backgroundrgb = {guielements["backgroundinput1"].value, guielements["backgroundinput2"].value, guielements["backgroundinput3"].value}
	backgroundcolor[4] = backgroundrgb
	changebackground(4)
	guielements["backgroundinput1"].inputting = false
	guielements["backgroundinput2"].inputting = false
	guielements["backgroundinput3"].inputting = false
	guielements["defaultcolor4"].fillcolor = backgroundcolor[4]
end

function defaultbackground(i)
	levelmodified = true
	background = i --{unpack(backgroundcolor[i])}
	backgroundrgbon = (i==4)

	if i == 4 then
		backgroundcolor[4] = backgroundrgb
		guielements["backgroundinput1"].value = backgroundrgb[1]
		guielements["backgroundinput2"].value = backgroundrgb[2]
		guielements["backgroundinput3"].value = backgroundrgb[3]
	end

	love.graphics.setBackgroundColor(backgroundcolor[i])
	
	--guielements["colorsliderr"].internvalue = background[1]
	--guielements["colorsliderg"].internvalue = background[2]
	--guielements["colorsliderb"].internvalue = background[3]
end

--[[function updatebackground()
	background[1] = guielements["colorsliderr"].internvalue
	background[2] = guielements["colorsliderg"].internvalue
	background[3] = guielements["colorsliderb"].internvalue
	love.graphics.setBackgroundColor(unpack(background))
end]]

function changecustombackground(var)
	levelmodified = true
	custombackground = custombackgrounds[var]
	loadcustombackground(custombackground)
	guielements["backgrounddropdown"].var = var
	guielements["custombackgroundcheckbox"].var = true
end

function changecustomforeground(var)
	levelmodified = true
	customforeground = custombackgrounds[var]
	loadcustomforeground(customforeground)
	guielements["foregrounddropdown"].var = var
	guielements["customforegroundcheckbox"].var = true
end

function changemusic(var)
	levelmodified = true
	if musici == 7 and custommusic then
		music:stop(custommusic)
	elseif musici ~= 1 then
		music:stopIndex(musici-1)
	end
	musici = var
	if tonumber(guielements["custommusiciinput"].value) ~= nil then
		custommusic = custommusics[tonumber(guielements["custommusiciinput"].value)]
	else
		customusic = custommusics[1]
	end
	if musici == 7 then
		if custommusic then
			--music:play(custommusic)
		else
			notice.new("custom music not found", notice.red, 3)
		end
	elseif musici ~= 1 then
		--music:playIndex(musici-1)
	end
	guielements["musicdropdown"].var = var
end

function changespriteset(var)
	levelmodified = true
	spriteset = var
	guielements["spritesetdropdown"].var = var
end

function decreasetimelimit()
	levelmodified = true
	mariotimelimit = mariotimelimit - 10
	if mariotimelimit < 0 then
		mariotimelimit = 0
	end
	mariotime = mariotimelimit
	guielements["timelimitincrease"].x = 33 + string.len(mariotimelimit)*8
	guielements["timelimitinput"].width = string.len(mariotimelimit)
	guielements["timelimitinput"].value = mariotimelimit
end
function increasetimelimit()
	levelmodified = true
	mariotimelimit = mariotimelimit + 10
	mariotime = mariotimelimit
	guielements["timelimitincrease"].x = 33 + string.len(mariotimelimit)*8
	guielements["timelimitinput"].width = string.len(mariotimelimit)
	guielements["timelimitinput"].value = mariotimelimit
end

function changetimelimitinputting()
	guielements["timelimitincrease"].x = 33+6*8
	guielements["timelimitinput"].width = 6
	guielements["timelimitincrease"].active = false
	guielements["timelimitdecrease"].active = false
end
function changetimelimituninputting()
	guielements["timelimitinput"].value = mariotimelimit
	guielements["timelimitincrease"].x = 33 + string.len(mariotimelimit)*8
	guielements["timelimitinput"].width = string.len(mariotimelimit)
	guielements["timelimitincrease"].active = true
	guielements["timelimitdecrease"].active = true
end
function changetimelimit()
	levelmodified = true
	local newmariotimelimit = tonumber(guielements["timelimitinput"].value)
	if type(newmariotimelimit) ~= "number" then
		notice.new("time limit must be a number!", notice.red, 3)
		changetimelimituninputting()
	else
		mariotimelimit = math.max(0, math.min(math.floor(newmariotimelimit), 999999))
		guielements["timelimitinput"].value = mariotimelimit
		mariotime = mariotimelimit
		guielements["timelimitincrease"].x = 33 + string.len(mariotimelimit)*8
		guielements["timelimitinput"].width = string.len(mariotimelimit)
	end
	guielements["timelimitincrease"].active = true
	guielements["timelimitdecrease"].active = true
	guielements["timelimitinput"].inputting = false
end

function changeportalgun(var)
	levelmodified = true
	portalguni = var
	portalgun = not (portalguni == 2)
	guielements["portalgundropdown"].var = var
end

function applymapwidth()
	levelmodified = true
	changemapwidth(targetmapwidth)
end

function applymapheight()
	levelmodified = true
	changemapheight(targetmapheight)
end

--custom tab stuff
function changecurrentimage(var, initial)
	currentcustomimage = {var, imagestable[var], string.gsub(string.gsub(imagestable[var], "img", ""), "image", "") .. ".png"}
	if not initial then
		guielements["currentimagedropdown"].var = var
	end
end
function changecurrentbackground(var, initial)
	if var == 1 then
		editorbackgroundstate = "background"
	else
		editorbackgroundstate = "foreground"
	end
	if not initial then
		guielements["currentbackgrounddropdown"].var = var
	end
end
function changecurrentsound(var, initial)
	if currentcustomsound then
		if customsounds and customsounds[currentcustomsound[1]] then
			love.audio.stop(_G[soundliststring[currentcustomsound[1]] .. "sound"])
		else
			love.audio.stop(soundlist[currentcustomsound[1]])
		end
	end
	currentcustomsound = {var, soundliststring[var], soundliststring[var] .. ".ogg"}
	if not initial then
		guielements["currentsounddropdown"].var = var
		if customsounds and customsounds[var] then
			playsound(_G[soundliststring[var] .. "sound"])
		else
			playsound(soundlist[var])
		end
	end
end
function changecurrentenemy(var, initial)
	currentcustomenemy = {var, customenemies[var], timer = 0, quadi = 1, animationdirection = "left", timerstage = 1}
	if not initial then
		guielements["currentenemydropdown"].var = var
	end
end
function exportcustomimage(arg)
	if customtabstate == "graphics" then
		if not love.filesystem.getInfo( mappackfolder .. "/" .. mappack .. "/custom") then
			love.filesystem.createDirectory( mappackfolder .. "/" .. mappack .. "/custom")
		end
		love.filesystem.write(mappackfolder .. "/" .. mappack .. "/custom/" .. currentcustomimage[3], love.filesystem.read("graphics/" .. graphicspack .. "/" .. currentcustomimage[3]))
	elseif customtabstate == "tiles" then
		if arg == "animated" then
			if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/animated/1.png") then
				love.filesystem.write(mappackfolder .. "/" .. mappack .. "/animated/template.png", love.filesystem.read("graphics/templates/animated/1.png"))
				love.filesystem.write(mappackfolder .. "/" .. mappack .. "/animated/template.txt", love.filesystem.read("graphics/templates/animated/1.txt"))
			else
				love.filesystem.write(mappackfolder .. "/" .. mappack .. "/animated/1.png", love.filesystem.read("graphics/templates/animated/1.png"))
				love.filesystem.write(mappackfolder .. "/" .. mappack .. "/animated/1.txt", love.filesystem.read("graphics/templates/animated/1.txt"))
			end
		else
			if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/tiles.png") then
				love.filesystem.write(mappackfolder .. "/" .. mappack .. "/tilestemplate.png", love.filesystem.read("graphics/" .. graphicspack .. "/smbtiles.png"))
			else
				love.filesystem.write(mappackfolder .. "/" .. mappack .. "/tiles.png", love.filesystem.read("graphics/" .. graphicspack .. "/smbtiles.png"))
			end
		end
	elseif customtabstate == "sounds" then
		if not love.filesystem.getInfo( mappackfolder .. "/" .. mappack .. "/sounds") then
			love.filesystem.createDirectory( mappackfolder .. "/" .. mappack .. "/sounds")
		end
		love.filesystem.write(mappackfolder .. "/" .. mappack .. "/sounds/" .. currentcustomsound[3], love.filesystem.read("sounds/" .. currentcustomsound[3]))
	elseif customtabstate == "enemies" then
		local enemy = currentcustomenemy[2]
		if not enemy then
			enemy = "goomba"
		end
		if not love.filesystem.getInfo( mappackfolder .. "/" .. mappack .. "/enemies") then
			love.filesystem.createDirectory( mappackfolder .. "/" .. mappack .. "/enemies")
		end
		if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/enemies/" .. enemy .. ".json") then
			love.filesystem.write(mappackfolder .. "/" .. mappack .. "/enemies/" .. enemy .. ".json", love.filesystem.read(mappackfolder .. "/" .. mappack .. "/enemies/" .. enemy .. ".json"))
			if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/enemies/" .. enemy .. ".png") then
				love.filesystem.write(mappackfolder .. "/" .. mappack .. "/enemies/" .. enemy .. ".png", love.filesystem.read(mappackfolder .. "/" .. mappack .. "/enemies/" .. enemy .. ".png"))
			end
			if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/enemies/" .. enemy .. ".ogg") then
				love.filesystem.write(mappackfolder .. "/" .. mappack .. "/enemies/" .. enemy .. ".ogg", love.filesystem.read(mappackfolder .. "/" .. mappack .. "/enemies/" .. enemy .. ".ogg"))
			end
		elseif love.filesystem.getInfo("customenemies/" .. enemy .. ".json") then
			love.filesystem.write(mappackfolder .. "/" .. mappack .. "/enemies/" .. enemy .. ".json", love.filesystem.read("customenemies/" .. enemy .. ".json"))
			if love.filesystem.getInfo("customenemies/" .. enemy .. ".png") then
				love.filesystem.write(mappackfolder .. "/" .. mappack .. "/enemies/" .. enemy .. ".png", love.filesystem.read("customenemies/" .. enemy .. ".png"))
			end
		end
	end
end
function opencustomimagefolder(f)
	if android then
		notice.new("On android try a file manager\nand go to:\nAndroid > data > Love.to.mario >\nfiles > save > mari0_android", notice.red, 5)
	end
	if customtabstate == "graphics" then
		if not love.filesystem.getInfo( mappackfolder .. "/" .. mappack .. "/custom", "directory") then
			love.filesystem.createDirectory( mappackfolder .. "/" .. mappack .. "/custom")
		end
		openfile(mappackfolder .. "/" .. mappack .. "/custom")
	elseif customtabstate == "tiles" then
		if f == "tiles" then
			openfile(mappackfolder .. "/" .. mappack)
		elseif f == "animated" then
			if not love.filesystem.getInfo( mappackfolder .. "/" .. mappack .. "/animated", "directory") then
				love.filesystem.createDirectory( mappackfolder .. "/" .. mappack .. "/animated")
			end
			openfile(mappackfolder .. "/" .. mappack .. "/animated")
		end
	elseif customtabstate == "backgrounds" then
		if not love.filesystem.getInfo( mappackfolder .. "/" .. mappack .. "/backgrounds", "directory") then
			love.filesystem.createDirectory( mappackfolder .. "/" .. mappack .. "/backgrounds")
		end
		openfile(mappackfolder .. "/" .. mappack .. "/backgrounds")
	elseif customtabstate == "sounds" then
		if f == "sounds" then
			if not love.filesystem.getInfo( mappackfolder .. "/" .. mappack .. "/sounds", "directory") then
				love.filesystem.createDirectory( mappackfolder .. "/" .. mappack .. "/sounds")
			end
			openfile(mappackfolder .. "/" .. mappack .. "/sounds")
		else
			if not love.filesystem.getInfo( mappackfolder .. "/" .. mappack .. "/music", "directory") then
				love.filesystem.createDirectory( mappackfolder .. "/" .. mappack .. "/music")
			end
			openfile(mappackfolder .. "/" .. mappack .. "/music")
		end
	elseif customtabstate == "enemies" then
		if not love.filesystem.getInfo( mappackfolder .. "/" .. mappack .. "/enemies", "directory") then
			love.filesystem.createDirectory( mappackfolder .. "/" .. mappack .. "/enemies")
		end
		openfile(mappackfolder .. "/" .. mappack .. "/enemies")
	end
end
function savecustomimage()
	if customtabstate == "graphics" then
		loadcustomsprites()
		for i = 1, #smbspritebatch do
			smbspritebatch[i]:setTexture(smbtilesimg)
			portalspritebatch[i]:setTexture(portaltilesimg)
		end
		collectgarbage()
		notice.new("Updated sprites", notice.white, 2)
	elseif customtabstate == "tiles" then
		if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/tiles.png") then
			--remove custom sprites
			for i = smbtilecount+portaltilecount+1, #tilequads do
				tilequads[i] = nil
			end

			for i = smbtilecount+portaltilecount+1, #rgblist do
				rgblist[i] = nil
			end
			--add custom tiles
			customtiles = true
			loadtiles("custom")
		
			customspritebatch = {}
			for i = 1, 2 do
				customspritebatch[i] = {}
				for i2 = 1, #customtilesimg do
					customspritebatch[i][i2] = love.graphics.newSpriteBatch( customtilesimg[i2], maxtilespritebatchsprites )
				end
			end
			
			generatespritebatch()
			notice.new("Updated tiles", notice.white, 2)
		else
			customtiles = false
			customtilecount = 0
			notice.new("No tiles found!", notice.red, 2)
		end
		if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/animated/1.png") then
			loadanimatedtiles()
			notice.new("Updated animated tiles", notice.white, 2)
		end
	elseif customtabstate == "backgrounds" then
		if editorbackgroundstate == "foreground" then
			loadcustomforeground(customforeground)
		else
			loadcustombackground(custombackground)
		end
		notice.new("Loaded background", notice.white, 2)
	elseif customtabstate == "sounds" then
		loadcustomsounds()
		loadcustommusic()
		guielements["musicdropdown"].entries = editormusictable
		notice.new("Updated sounds and music", notice.white, 2)
	end
end
function resetcustomimage()
	love.filesystem.remove(mappackfolder .. "/" .. mappack .. "/custom/" .. currentcustomimage[3])
	_G[currentcustomimage[2]] = love.graphics.newImage("graphics/" .. graphicspack .. "/" .. currentcustomimage[3])
end
function replacecustomimage(file)
	local r, d = pcall(love.image.newImageData, file)
	if r then
		if customtabstate == "graphics" then
			d:encode("png", mappackfolder .. "/" .. mappack .. "/custom/" .. currentcustomimage[3])
			_G[currentcustomimage[2]] = love.graphics.newImage(file)
		elseif customtabstate == "tiles" then
			d:encode("png", mappackfolder .. "/" .. mappack .. "/tiles.png")
			savecustomimage()
		elseif customtabstate == "backgrounds" then
			local levelstring = marioworld .. "-" .. mariolevel
			if mariosublevel ~= 0 then
				levelstring = levelstring .. "_" .. mariosublevel
			end
			if editorbackgroundstate == "foreground" then
				d:encode("png", mappackfolder .. "/" .. mappack .. "/" .. levelstring .. "foreground1.png")
			else
				d:encode("png", mappackfolder .. "/" .. mappack .. "/" .. levelstring .. "background1.png")
			end
		elseif customtabstate == "text" and textstate == "levelscreen" then
			d:encode("png", mappackfolder .. "/" .. mappack .. "/" .. marioworld .. "-" .. mariolevel .. "levelscreen.png")
			if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/" .. marioworld .. "-" .. mariolevel .. "levelscreen.png") then
				levelscreenimage = love.graphics.newImage(mappackfolder .. "/" .. mappack .. "/" .. marioworld .. "-" .. mariolevel .. "levelscreen.png")
			else
				levelscreenimage = false
			end
			levelscreenimagecheck = mappack .. "-" .. marioworld .. "-" .. mariolevel
		end
	end
end

function linkbutton()
	editorstate = "linktool"
	editorclose()
end

function test_level(x, y)
	createeditorsavedata("test")
	
	local targetxscroll, targetyscroll = xscroll, yscroll
	if levelmodified and onlysaveiflevelmodified then
		savelevel()
	end
	editorclose()
	editormode = false
	testlevel = true
	testlevelworld = marioworld
	testlevellevel = mariolevel
	autoscroll = true
	checkpointx = false
	subleveltest = true

	updateplayerproperties("reset")
	updatesizes("reset")
	player_position = {x, y, xscroll, yscroll}
	if mariosublevel ~= 0 then
		startlevel(mariosublevel)
	else
		startlevel(marioworld .. "-" .. mariolevel)
	end
	player_position = nil

	if x and y then
		--test from position
		local p = objects["player"][1]
		p.x = x
		p.y = y
		p.invincible = true
		p.animationtimer = 2.4
		p.animation = "invincible"
		p.controlsenabled = true
		p.active = true
		p.customscissor = false
		camerasnap(targetxscroll, targetyscroll)
		generatespritebatch()
	end
end

function portalbutton()
	editorstate = "portalgun"
	editorclose()
end

function selectionbutton()
	editorstate = "selectiontool"
	editorclose()
end

function powerlinebutton()
	editorstate = "powerline"
	powerlinestate = 1
	allowdrag = false
	editorclose()
end

function getlistpos(x, y)
	if x >= 5*scale and y >= 38*scale and x < 378*scale and y < 203*scale then
		x = (x - 5*scale)/scale
		y = y + tilesoffset
		y = (y - 38*scale)/scale
		
		out = math.floor(y/17)
		if out <= #multitileobjects-1 then
			return out
		end
	end
	
	return false
end

function getmtbutton(x)
	local button = 0
	if (not guielements["mtobjectrename"].active) then
		if x >= 333*scale and x < 347*scale then
			button = 1
		elseif x >= 348*scale and x < 362*scale then
			button = 2
		elseif x >= 363*scale and x < 377*scale then
			button = 3
		end
	end
	
	return button
end

function gettilelistpos(x, y)
	if x >= 5*scale and y >= 38*scale and x < 378*scale and y < (203+tilemenuy)*scale then
		y = y - tilemenuy*scale

		x = (x - 5*scale)/scale
		y = y + tilesoffset
		y = (y - 38*scale)/scale
		
		out = math.floor(x/17)+1
		out = out + math.floor(y/17)*22
		
		return out
	end
	
	return false
end

function getentitylistpos(x, y)
	if y > 38*scale and x >= 5*scale and x < 378*scale and y < (203+tilemenuy)*scale then
		y = y - tilemenuy*scale

		x = (x - 5*scale)/scale
		y = (y - 38*scale) + tilesoffset
		for list = 1, #entitiesform do
			if y > entitiesform[list].y*scale and y < (entitiesform[list].y+entitiesform[list].h)*scale then
				y = (y - entitiesform[list].y*scale)/scale
				
				out = math.floor(x/17)+1
				out = out + math.floor(y/17)*22
				
				if out <= #entitiesform[list] then
					return out, list
				else
					return false
				end
			elseif y > (entitiesform[list].y-10)*scale and y < (entitiesform[list].y)*scale then
				return false, list
			end
		end
		
	end
	
	return false
end



function savesettings()
	local s = ""
	s = s .. "name=" .. guielements["edittitle"].value .. "\n"
	s = s .. "author=" .. guielements["editauthor"].value .. "\n"
	s = s .. "description=" .. guielements["editdescription"].value .. "\n"
	if mariolivecount == false then
		s = s .. "lives=0\n"
	else
		s = s .. "lives=" .. mariolivecount .. "\n"
	end
	if currentphysics and currentphysics ~= 1 then
		s = s .. "physics=" .. currentphysics .. "\n"
	end
	if camerasetting and camerasetting ~= 1 then
		s = s .. "camera=" .. camerasetting .. "\n"
	end
	if dropshadow then
		s = s .. "dropshadow=t\n"
	end
	if realtime then
		s = s .. "realtime=t\n"
	end
	if continuesublevelmusic then
		s = s .. "continuesublevelmusic=t\n"
	end
	if nolowtime then
		s = s .. "nolowtime=t\n"
	end
	
	love.filesystem.createDirectory( mappackfolder )
	love.filesystem.createDirectory( mappackfolder .. "/" .. mappack )
	
	love.filesystem.write(mappackfolder .. "/" .. mappack .. "/settings.txt", s)
	
	notice.new("Settings saved", notice.white, 3)
end

function savemtobject(objecttable, name)
	-- 1 read objects file
	local data, data2, datalines, objectname
	if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/objects.txt") then
		data = love.filesystem.read(mappackfolder .. "/" .. mappack .. "/objects.txt")
	else
		data = ""
	end
	if name then
		data = data .. name .. "="
	else
		datalines = data:split("\n")
		data = data .. "object " .. tostring(#datalines) .. " > mtobjsize="
	end
	-- 2 append new object (with \n at the end!)
	local s, m, n
	for i = 1, #objecttable do
		s = objecttable[i] -- x's
		for j = 1, #s do
			for layer = 1, #s[j] do
				if tostring(s[j][layer]):find("=") or tostring(s[j][layer]):find(":") then
					--some right click values have characters that will corrupt the object
					--TODO: Change delimeters?
					break
				end
				
				if layer == 1 and s[j]["back"] then --╚ instead of ~
					data = data .. s[j][layer] .. "╚" .. s[j]["back"] ..  "-"
				elseif layer == 2 and s[j]["argument"] then --╔ instead of :
					data = data .. s[j][layer] .. "╔" .. s[j]["argument"] .. "-"
				else
					data = data .. s[j][layer] .. "-"
				end
			end
			data = string.sub(data, 1, -2)
			data = data .. ","
			n = j
		end
		data = string.sub(data, 1, -2)
		data = data .. ":"
		m = i
	end
	data = string.sub(data, 1, -2)
	data = string.gsub(data, "mtobjsize", m .. " * " .. n)
	data = data .. "\n"
	love.filesystem.write(mappackfolder .. "/" .. mappack .. "/objects.txt", data)
	mtjustsaved = true
end

function changemtname(linenumber)
	if not love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/objects.txt") then
		return false
	end
	
	line = tonumber(linenumber)
	local data, newdata, split1
	data = love.filesystem.read(mappackfolder .. "/" .. mappack .. "/objects.txt")
	data = string.sub(data, 1, -2)
	newdata = ""
	split1 = data:split("\n")
	for i, v in ipairs(split1) do
		if i ~= line then
			newdata = newdata .. split1[i] .. "\n"
		else
			local s = split1[i]
			local s2 = s:split("=")

			newdata = newdata .. multitileobjectnames[line] .. "=" .. s2[2] .. "\n"
		end
	end
	love.filesystem.write(mappackfolder .. "/" .. mappack .. "/objects.txt", newdata)
end

function moveline(file, line, direction)
	if not love.filesystem.getInfo(file) then
		return false
	end
	if direction ~= "up" then
		direction = "down"
	end
	
	-- cant move first one up
	if line == 1 and direction == "up" then
		return false
	end
	
	line = tonumber(line)
	
	local data, newdata, split1, changeto, linetmp1, linetmp2
	
	data = love.filesystem.read(file)
	data = string.sub(data, 1, -2)
	newdata = ""
	split1 = data:split("\n")
	
	-- cant move last one down
	if line == #split1 and direction == "down" then
		return false
	end
	
	linetmp1 = split1[line]
	if direction == "up" then
		changeto = line-1
		linetmp2 = split1[changeto]
	else
		changeto = line+1
		linetmp2 = split1[changeto]
	end
	
	for i, v in ipairs(split1) do
		if i == line then
			newdata = newdata .. linetmp2 .. "\n"
		elseif i == changeto then
			newdata = newdata .. linetmp1 .. "\n"
		else
			newdata = newdata .. split1[i] .. "\n"
		end
	end
	love.filesystem.write(file, newdata)
end

function deleteline(file, line)
	if not love.filesystem.getInfo(file) then
		return false
	end
	line = tonumber(line)
	local data, newdata, split1
	data = love.filesystem.read(file)
	data = string.sub(data, 1, -2)
	newdata = ""
	split1 = data:split("\n")
	for i, v in ipairs(split1) do
		if i ~= line then
			newdata = newdata .. split1[i] .. "\n"
		end
	end
	love.filesystem.write(file, newdata)
end

function changeline(file, linenumber, newstring)
	if not love.filesystem.getInfo(file) then
		return false
	end
	line = tonumber(line)
	local data, newdata, split1
	data = love.filesystem.read(file)
	data = string.sub(data, 1, -2)
	newdata = ""
	split1 = data:split("\n")
	for i, v in ipairs(split1) do
			newdata = newdata .. split1[i] .. "\n"
		if i ~= line then
		else
			newdata = newdata .. newstring .. "\n"
		end
	end
	love.filesystem.write(file, newdata)
end

function livesdecrease()
	if mariolivecount == false then
		return
	end
	
	mariolivecount = mariolivecount - 1
	if mariolivecount == 0 then
		mariolivecount = false
		guielements["livesincrease"].x = 314 - 6 + 24
	else
		guielements["livesincrease"].x = 314 - 6 + string.len(mariolivecount)*8
	end
end

function livesincrease()
	if mariolivecount == false then
		mariolivecount = 1
	else
		mariolivecount = mariolivecount + 1
	end
	guielements["livesincrease"].x = 314 - 6 + string.len(mariolivecount)*8
end

function changephysics(var)
	currentphysics = var
	setphysics(currentphysics)
	guielements["physicsdropdown"].var = var
end

function changecamerasetting(var)
	camerasetting = var
	setcamerasetting(camerasetting)
	guielements["cameradropdown"].var = var
end
function toggledropshadow(var)
	if var ~= nil then
		dropshadow = var
	else
		dropshadow = not dropshadow
	end
	if dropshadow then
		notice.new(TEXT["drop shadow may\nreduce performance!"], notice.white, 3)
	end
	guielements["dropshadowcheckbox"].var = dropshadow
end
function togglerealtime(var)
	if var ~= nil then
		realtime = var
	else
		realtime = not realtime
	end
	guielements["realtimecheckbox"].var = realtime
end
function togglecontinuemusic(var)
	if var ~= nil then
		continuesublevelmusic = var
	else
		continuesublevelmusic = not continuesublevelmusic
	end
	guielements["continuemusiccheckbox"].var = continuesublevelmusic
end

function togglenolowtime(var)
	if var ~= nil then
		nolowtime = var
	else
		nolowtime = not nolowtime
	end
	guielements["nolowtimecheckbox"].var = nolowtime
end

function updatescrollfactor()
	--not a scrollfactor lol
	autoscrollingspeed = round(guielements["autoscrollingscrollbar"].value*autoscrollingmaxspeed, 2)

	scrollfactor = round((guielements["scrollfactorxscrollbar"].value*3)^2, 2)
	scrollfactory = round((guielements["scrollfactoryscrollbar"].value*3)^2, 2)
	scrollfactor2 = round((guielements["scrollfactor2xscrollbar"].value*3)^2, 2)
	scrollfactor2y = round((guielements["scrollfactor2yscrollbar"].value*3)^2, 2)
	if guielements["autoscrollingscrollbar"].dragging or guielements["scrollfactorxscrollbar"].dragging or 
	guielements["scrollfactoryscrollbar"].dragging or guielements["scrollfactor2xscrollbar"].dragging or 
	guielements["scrollfactor2yscrollbar"].dragging then--has it been changed?
		levelmodified = true
	end
end

function reversescrollfactor(s)
	return math.sqrt(s or scrollfactor)/3
end

function reversescrollfactor2(s)
	return math.sqrt(s or scrollfactor2)/3
end

function reverseautoscrollingscrollbar(s)
	return autoscrollingspeed/autoscrollingmaxspeed
end

function formatscrollnumber(i)
	if string.len(i) == 1 then
		return i .. ".00"
	elseif string.len(i) == 3 then
		if i < 0 then
			return i
		else
			return i .. "0"
		end
	elseif string.len(i) >= 5 then
		return tostring(i):sub(1,4)
	else
		return i
	end
end

function drawlinkline(x1, y1, x2, y2)
	love.graphics.rectangle("fill", x1, y1-math.ceil(scale/2), x2-x1, scale)
	love.graphics.rectangle("fill", x2-math.ceil(scale/2), y1, scale, y2-y1)
end

function drawlinkline2(x1, y1, x2, y2)
	love.graphics.rectangle("fill", x1-math.ceil(scale/2), y1, scale, y2-y1)
	love.graphics.rectangle("fill", x2, y2-math.ceil(scale/2), x1-x2, scale)
end

function generatetrackpreviews()
	trackgenerationid = trackgenerationid + 1 --how many times tracks have been generated, used to detect old ones
	for mx = 1, mapwidth do
		for my = 1, mapheight do
			if map[mx][my]["track"] and map[mx][my]["track"].id ~= trackgenerationid then --delete old tracks
				map[mx][my]["track"] = nil
			end
			if map[mx][my][2] and (entityquads[map[mx][my][2]].t == "track" or entityquads[map[mx][my][2]].t == "trackswitch") then
				local v
				local pathvars = 1 --how many track paths does the entity have?
				if entityquads[map[mx][my][2]].t == "trackswitch" then 
					v = convertr(map[mx][my][3], {"string", "string", "bool"}, true)
					pathvars = 2
				else
					v = convertr(map[mx][my][3], {"string", "bool"}, true)
				end
				local trackdata
				for pathvar = 1, pathvars do
					trackdata = v[pathvar]
					if trackdata then
						local s = trackdata:gsub("n", "-")
						local s2 = s:split("`")
						
						local s3
						for i = 1, #s2 do
							s3 = s2[i]:split(":")
							local x, y = tonumber(s3[1]), tonumber(s3[2])
							local start, ending, grab = s3[3], s3[4], s3[5]
							
							if x and y then
								local tx, ty = mx+x, my+y
								if ismaptile(tx,ty) then
									map[tx][ty]["track"] = {start=start, ending=ending, grab=grab, id=trackgenerationid, cox=mx, coy=my}
								else
									break
								end
							else
								break
							end
						end
					end
				end
			end
		end
	end
	trackpreviews = true
end

function levelrightclickmenuclick(i)
	local filename = levelrightclickmenu.level[1] .. "-" .. levelrightclickmenu.level[2]
	if levelrightclickmenu.level[3] ~= 0 then
		filename = filename .. "_" .. levelrightclickmenu.level[3]
	end
	if i == 2 then --copy
		if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/" .. filename .. ".txt") then
			levelrightclickmenu.copy = love.filesystem.newFileData(mappackfolder .. "/" .. mappack .. "/" .. filename .. ".txt")
			notice.new("Level Copied", notice.white, 3)
		else
			notice.new("No level to copy", notice.red, 3)
		end
	elseif i == 3 then --paste
		if levelrightclickmenu.copy then
			love.filesystem.write(mappackfolder .. "/" .. mappack .. "/" .. filename .. ".txt", levelrightclickmenu.copy)
			levelrightclickmenu.copy = nil
			collectgarbage()
			notice.new("Level Pasted", notice.white, 3)
		else
			notice.new("No level copied", notice.red, 3)
		end
	elseif i == 4 then --delete
		if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/" .. filename .. ".txt") then
			local readd = love.filesystem.read(mappackfolder .. "/" .. mappack .. "/" .. filename .. ".txt")
			if readd then
				levelrightclickmenu.copy = readd
				notice.new("Backup Copied", notice.white, 3)
				love.filesystem.remove(mappackfolder .. "/" .. mappack .. "/" .. filename .. ".txt")
				--delete editormetadata
				local levelstring = levelrightclickmenu.level[1] .. "~" .. levelrightclickmenu.level[2] .. "~" .. levelrightclickmenu.level[3]
				love.filesystem.remove(mappackfolder .. "/" .. mappack .. "/editor/" .. levelstring .. ".png")
				notice.new("Level Deleted", notice.red, 3)
			end
		end
	end
	if love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/" .. filename .. ".txt") then
		existingmaps[levelrightclickmenu.level[1]][levelrightclickmenu.level[2]][levelrightclickmenu.level[3]] = true
		levelrightclickmenu.button.textcolor = {255, 255, 255}
	else
		existingmaps[levelrightclickmenu.level[1]][levelrightclickmenu.level[2]][levelrightclickmenu.level[3]] = false
		levelrightclickmenu.button.textcolor = {80, 80, 80}
	end
	levelrightclickmenu.active = false
end

function paintbucket(tx, ty, ontile, onlyonscreen)
	local bot = {} --will navigate map to find ontiles and fill them
	local output = {} --list of tiles that should be changed {x, y}
	table.insert(bot, {tx,ty})
	local lmap = {} --create copy of map that can be modified freely
	for sx = 1, mapwidth do
		lmap[sx] = {}
		for sy = 1, mapheight do
			local ti = map[sx][sy][1]
			if backgroundtilemode then
				ti = map[sx][sy]["back"]
			end
			lmap[sx][sy] = (ti == ontile) --is it the same as on tile?
		end
	end
	--update bots until they are all gone
	while #bot > 0 do
		local delete = {}

		for i, b in pairs(bot) do
			local x, y = b[1], b[2]
			--make children around
			local nextbots = {{x-1, y},{x+1,y},{x,y-1},{x,y+1}}
			for i2 = 1, 4 do
				local nx, ny = nextbots[i2][1], nextbots[i2][2]
				if inmap(nx,ny) and lmap[nx][ny] and ((not onlyonscreen) or onscreen(nx-1, ny-1, 1, 1)) then
					lmap[nx][ny] = false
					table.insert(bot, {nx,ny})
				end
			end

			--fill if same as ontile
			lmap[x][y] = false
			table.insert(output, {x, y})
			table.insert(delete, i)
		end
		
		table.sort(delete, function(a,b) return a>b end)
		
		for i, v in pairs(delete) do
			table.remove(bot, v) --remove
		end
	end
	return output
end

function undo_clear()
	undotable = false
	undostore = true
end

function undo_store(x, y)
	if not undostore then
		return false
	end
	if not undotable then
		undotable = {}
	end
	table.insert(undotable, {x, y, deepcopy(map[x][y])})
end

function undo_stopstore()
	undostore = false
end

function undo_undo() --actual undo
	if undotable then
		local oldcurrenttile = currenttile
		local redotable = {}
		undostore = false
		for n, v in pairs(undotable) do
			local x, y = v[1], v[2]
			if inmap(x, y) then
				table.insert(redotable, {x, y, deepcopy(map[x][y])})
				--update collision, kind of ghetto but it works
				if not editentities then
					currenttile = v[3][1]
					placetile((x-1-xscroll)*16*scale, (y-1-yscroll-.5)*16*scale)
				end
				map[x][y] = v[3]
			end
		end
		undostore = true
		undotable = redotable
		currenttile = oldcurrenttile
		tileselection = false
	end
end

function loadeditormetadata()
	--save background colors for level buttons
	meta_data = {}
	local files = love.filesystem.getDirectoryItems(mappackfolder .. "/" .. mappack .. "/editor")
	for i = 1, #files do
		local v = mappackfolder .. "/" .. mappack .. "/editor/" .. files[i]
		local extension = string.sub(v, -4, -1)
		if extension == ".png" then
			local name = string.sub(files[i], 1, -5)
			meta_data[name] = {}
			meta_data[name].img = love.graphics.newImage(v)
		end
	end
	--[[
	if not love.filesystem.getInfo(mappackfolder .. "/" .. mappack .. "/editor.txt") then
		return false
	end
	local s = love.filesystem.read(mappackfolder .. "/" .. mappack .. "/editor.txt")
	local s2 = s:split("|")
	local s3
	for leveldatai = 1, #s2 do
		s3 = s2[leveldatai]:split("~")
		meta_data[s3[1] .. "~" .. s3[2] .. "~" .. s3[3] ] = {s3[4], s3[5], s3[6]}
		print("loading metadata " .. s3[1] .. "~" .. s3[2] .. "~" .. s3[3])
	end]]
end

function saveeditormetadata()
	if not meta_data then
		return false
	end
	love.filesystem.createDirectory(mappackfolder .. "/" .. mappack .. "/editor")
	local w, h = 14, 13
	if mariosublevel == 0 then
		w = 70
		h = 15
	end
	w, h = math.min(mapwidth, w), math.min(mapheight, h)
	local imgdata = love.image.newImageData(w, h)
	for y = 1, h do
		for x = 1, w do
			local id = map[x][mapheight-h+y][1]
			local r, g, b
			if rgblist[id] and id ~= 0 and not tilequads[id].invisible  then
				r, g, b = unpack(rgblist[id])
			else
				r, g, b = love.graphics.getBackgroundColor()
			end
			imgdata:setPixel(x-1, y-1, r, g, b, 255)
		end
	end
	local levelstring = marioworld .. "~" .. mariolevel .. "~" .. mariosublevel
	imgdata:encode("png", mappackfolder .. "/" .. mappack .. "/editor/" .. levelstring .. ".png")
	if not meta_data[levelstring] then
		meta_data[levelstring] = {}
	end
	meta_data[levelstring].img = love.graphics.newImage(imgdata)
	--[[meta_data[marioworld .. "~" .. mariolevel .. "~" .. mariosublevel] = backgroundcolor[background]
	print("saving metadata " .. marioworld .. "~" .. mariolevel .. "~" .. mariosublevel)
	local s = ""
	for i, t in pairs(meta_data) do
		s = s .. i .. "~" .. t[1] .. "~" .. t[2] .. "~" .. t[3] .. "|"
	end
	s = s:sub(1, -2)
	local success, message = love.filesystem.write(mappackfolder .. "/" .. mappack .. "/editor.txt", s)]]
end

function promptsaveeditormetadata()
	--save if doesn't exist
	local levelstring = marioworld .. "~" .. mariolevel .. "~" .. mariosublevel
	if not meta_data[levelstring] then
		saveeditormetadata()
		promptedmetadatasave = false
		return false
	end
	--save meta data only when switching levels
	promptedmetadatasave = true
end
