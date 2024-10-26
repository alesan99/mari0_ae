--[[
	STEAL MY SHIT AND I'LL FUCK YOU UP
	PRETTY MUCH EVERYTHING BY MAURICE GUÉGAN AND IF SOMETHING ISN'T BY ME THEN IT SHOULD BE OBVIOUS OR NOBODY CARES

	Please keep in mind that for obvious reasons, I do not hold the rights to artwork, audio or trademarked elements of the game.
	This license only applies to the code and original other assets. Obviously. Duh.
	Anyway, enjoy.
	
	
	
	DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
              Version 2, December 2004

	Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

	Everyone is permitted to copy and distribute verbatim or modified
	copies of this license document, and changing it is allowed as long
	as the name is changed.

			DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
	TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

	0. You just DO WHAT THE FUCK YOU WANT TO.]]
	
--[[
	-----------------------------------------------------------------------------
	"AWESOME" mod by Alesan99
	
	OTHER COOL DUDES
	-Maurice and Fakeuser for regular turrets
	-Automatik for helping me with the poison mushroom
	-Superjustinbros for some SMBS sprites
	-Qcode for some code and advice
	-Trosh for raccoon sprites from SE
	-Galas for power up sprites
	-Bobthelawyer for mario's hammer physics code
	-KGK64 for Dry beetle sprites
	-Skysometric for animated quad cache code from Mari0 SE Community Edtion
	-Oxiriar and Toonn from the Mari0 Gang Discord for smb3 item sprites
	-NH1507 for toad and toadette character sprites
	-HansAgain for new portal sprites, new mario sprites, banzai bills, and pneumatic tubes
	-Subpixel for bowser3, rotodiscs, ninji, and splunkin sprites
	-Critfish for overgrown portal sprites
	-Britdan for general bugtesting and misc. contributions on github
	-MadNyle for propeller sound effect and mega mushroom
	-fußmatte for helping create a TON of new characters for the font and Esperanto Translation
	-HugoBDesigner for Portugese-Br translation
	-Los for Russian Translation
	-qixils for the automatic GitHub workflows and LÖVE 11.4 update
	-WilliamFr0g and Kant for contributions on GitHub
	-----------------------------------------------------------------------------
]]

--version check
if love._version_major ~= 11 then error("You have an outdated version of Love2d! Get 11.5 and retry.") end

----- COLOR MIGRATION helpers -----
FFIAVAILABLE = pcall(function () require("ffi") end)

local function convertText(text)
	if type(text) == "table" then
		for i, v in ipairs(text) do
			if type(v) == "table" then
				text[i] = {love.math.colorFromBytes(unpack(v))}
			end
		end
	end
	return text
end

----- COLOR MIGRATION for real -----

local defaultSetColor = love.graphics.setColor
function love.graphics.setColor(r, g, b, a)
	if type(r) == "table" then r, g, b, a = unpack(r) end
    return defaultSetColor(love.math.colorFromBytes(r, g, b, a))
end

local defaultGetColor = love.graphics.getColor
function love.graphics.getColor()
	return love.math.colorToBytes(defaultGetColor())
end

local defaultSetBackgroundColor = love.graphics.setBackgroundColor
function love.graphics.setBackgroundColor(r, g, b, a)
	if type(r) == "table" then r, g, b, a = unpack(r) end
    return defaultSetBackgroundColor(love.math.colorFromBytes(r, g, b, a))
end

local defaultGetBackgroundColor = love.graphics.getBackgroundColor
function love.graphics.getBackgroundColor()
	return love.math.colorToBytes(defaultGetBackgroundColor())
end

local defaultClear = love.graphics.clear
function love.graphics.clear(r, g, b, a, ...)
	if r ~= nil and g ~= nil and b ~= nil then
		r, g, b, a = love.math.colorFromBytes(r, g, b, a)
	end
	return defaultClear(r, g, b, a, ...)
end

local defaultPrint = love.graphics.print
function love.graphics.print(text, ...)
	return defaultPrint(convertText(text), ...)
end

local defaultPrintf = love.graphics.printf
function love.graphics.printf(text, ...)
	return defaultPrintf(convertText(text), ...)
end

local defaultNewText = love.graphics.newText
function love.graphics.newText(font, text, ...)
	return defaultNewText(font, convertText(text), ...)
end

local Text = debug.getregistry().Text

local defaultTextSet = Text.set
function Text:set(text, ...)
	return defaultTextSet(self, convertText(text), ...)
end

local defaultTextSetf = Text.setf
function Text:setf(text, ...)
	return defaultTextSetf(self, convertText(text), ...)
end

local defaultTextAdd = Text.add
function Text:add(text, ...)
	return defaultTextAdd(self, convertText(text), ...)
end

local defaultTextAddf = Text.addf
function Text:addf(text, ...)
	return defaultTextAddf(self, convertText(text), ...)
end

local SpriteBatch = debug.getregistry().SpriteBatch

local defaultSpriteBatchSetColor = SpriteBatch.setColor
function SpriteBatch:setColor(...)
	return defaultSpriteBatchSetColor(self, love.math.colorFromBytes(...))
end

local defaultSpriteBatchGetColor = SpriteBatch.getColor
function SpriteBatch:getColor(...)
	return love.math.colorToBytes(defaultSpriteBatchGetColor(self, ...))
end

local ImageData = debug.getregistry().ImageData -- TODO: use FFI by default? not sure if fetching the pointer constantly will actually be efficient

local defaultImageDataSetPixel = ImageData.setPixel
function ImageData:setPixel(x, y, ...)
	return defaultImageDataSetPixel(self, x, y, love.math.colorFromBytes(...))
end

local defaultImageDataGetPixel = ImageData.getPixel
function ImageData:getPixel(...)
	return love.math.colorToBytes(defaultImageDataGetPixel(self, ...))
end

local defaultImageDataMapPixel = ImageData.mapPixel
function ImageData:mapPixel(pixelFunction, ...)
	return defaultImageDataMapPixel(self, function(x, y, r, g, b, a)
		local nr, ng, nb, na = pixelFunction(x, y, love.math.colorToBytes(r, g, b, a))
		if nr == nil then return r, g, b, a end
		return love.math.colorFromBytes(nr, ng, nb, na)
	end, ...)
end

-- TODO: ParticleSystem, linear/gamma functions, points, newMesh, [gs]etVertex

----- MAIN -----

require("utils")
hardloadhttps()

local debugconsole = false --debug
if debugconsole then debuginputon = true; debuginput = "print()"; print("DEBUG ON") end
local debugGraph,fpsGraph,memGraph,drawGraph
local debugGraphs = false

VERSION = 13.2002
VERSIONSTRING = "13.2 (10/26/2024)"
ANDROIDVERSION = 18

android = (love.system.getOS() == "Android" or love.system.getOS() == "iOS") --[DROID]
androidtest = false--testing android on pc

local loadingbarv = 0 --0-1
local loadingbardraw = function(add)
	love.graphics.clear()
	love.graphics.push()
	if android then
		love.graphics.scale(winwidth/(width*16*scale), winheight/(224*scale))
	end
	love.graphics.setColor(150, 150, 150)
	properprint("loading mari0..", ((width*16)*scale)/2-string.len("loading mari0..")*4*scale, 20*scale)
	love.graphics.setColor(50, 50, 50)
	local scale2 = scale
	if scale2 <= 1 then
		scale2 = 0.5
	else
		scale2 = 1
	end
	properprint(loadingtext, ((width*16)*scale)/2-string.len(loadingtext)*4*scale, ((height*16)*scale)/2+165*scale2)
	if FamilyFriendly then
		love.graphics.setColor(255, 255, 255)
		properprint("stys.eu", ((width*16)*scale)/2-string.len("stys.eu")*4*scale, 110*scale)
	else
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(logo, ((width*16)*scale)/2, ((height*16)*scale)/2, 0, scale2, scale2, 142, 150)
	end

	loadingbarv = loadingbarv + (add)/(8)
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle("fill", 0, (height*16-3)*scale, (width*16*loadingbarv)*scale, 3*scale)
	love.graphics.pop()
	love.graphics.present()
end

function love.load()
	loadingbarv = 0

	marioversion = 1006
	versionstring = "version 1.6"
	shaderlist = love.filesystem.getDirectoryItems( "shaders/" )
	dlclist = {"dlc_a_portal_tribute", "dlc_acid_trip", "dlc_escape_the_lab", "dlc_scienceandstuff", "dlc_smb2J", "dlc_the_untitled_game"}
	
	magicdns_session_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	magicdns_session = ""
	for i = 1, 8 do
		rand = math.random(string.len(magicdns_session_chars))
		magicdns_session = magicdns_session .. string.sub(magicdns_session_chars, rand, rand)
	end
	--use love.filesystem.getIdentity() when it works
	magicdns_identity = love.filesystem.getSaveDirectory():split("/")
	magicdns_identity = string.upper(magicdns_identity[#magicdns_identity])
	
	local rem
	for i, v in pairs(shaderlist) do
		if v == "init.lua" then
			rem = i
		else
			shaderlist[i] = string.sub(v, 1, string.len(v)-5)
		end
	end
	
	table.remove(shaderlist, rem)
	table.insert(shaderlist, 1, "none")
	currentshaderi1 = 1
	currentshaderi2 = 1
	
	if android and not androidtest then
		love.filesystem.setIdentity("mari0_android") --[DROID]
	else
		love.filesystem.setIdentity("mari0")
	end
	
	local ok, result = pcall(loadconfig)
	if not ok then
		print("Corrupt settings: " .. tostring(result))
		players = 1
		defaultconfig()
	end
	
	saveconfig()
	if fourbythree then
		width = 16
	else
		width = 25
	end
	height = 14 --?
	fsaa = 0
	fullscreen = false
	if scale == 2 and resizable then
		changescale(5, fullscreen)
	else
		changescale(scale, fullscreen)
	end

	love.window.setTitle( "Mari0: AE" )
	
	love.window.setIcon(love.image.newImageData("graphics/icon.png"))
	
	love.graphics.setDefaultFilter("nearest", "nearest")
	
	love.graphics.setBackgroundColor(0, 0, 0)
	
	logo = love.graphics.newImage("graphics/stabyourself.png") --deleted later to save memory
	logoblood = love.graphics.newImage("graphics/stabyourselfblood.png")

	--UTF8 Font
	fontimage = love.graphics.newImage("graphics/SMB/font.png")
	fontbackimage = love.graphics.newImage("graphics/SMB/fontback.png")
	
	font = love.graphics.newFont("font.fnt", "graphics/SMB/font.png")
	fontback = love.graphics.newFont("font.fnt", "graphics/SMB/fontback.png")
	fontCAP = love.graphics.newFont("fontcap.fnt", "graphics/SMB/font.png")
	fontbackCAP = love.graphics.newFont("fontcap.fnt", "graphics/SMB/fontback.png")
	--gamefont = font
	--gamefontback = fontback
	--gamefontCAP = fontCAP
	--gamefontbackCAp = fontbackCAP
	love.graphics.setFont(font)

	utf8 = require("utf8")
	local t = require("libs.utf8_simple")
	utf8.chars = t.chars
	utf8.sub = t.sub
	fontglyphs = [[
		ABCDEFGHIJKLMNOPQRSTUVWXYZ
		abcdefghijklmnopqrstuvwxyz
		0123456789 ⇒←→↑↓
		.!?,:;'"-_+=><#%&*()[]{}/\
		@©~¡¿°^$£€¥
		ÁÂÀÄÅÃÆÇÉÊÈËÍÎÌÏÑÓÔÒÖÕØŒÚÛ
		ÙÜŠÝŸẞÞÐĆŃŚŹĄĘŁĈĜĤĴŜŬŽİŞƏĞ
		áâàäåãæçéêèëíîìïñóôòöõøœúû
		ùüšýÿßþðćńśźąęłĉĝĥĵŝŭžışəğ
		АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШ
		ЩЪЫЬЭЮЯ№«»„
		абвгдеёжзийклмнопрстуфхцчш
		щъыьэюя
	]]
	fontglyphs = fontglyphs:gsub("	","")
	fontquads = {}
	fontquadsback = {}
	fontindexCAP = {} --all uppercase
	fontindexOLD = {} --old font with all uppercase and U=up D=down A=, B=-
	--local out = string.format("chars count=%s\n", utf8.len(fontglyphs:gsub("\n",""))) --Export font.fnt (doesn't)
	local s = fontglyphs:split("\n")
	for line = 1, #s do
		for i, c, b in utf8.chars(s[line]) do
			fontquads[c] = love.graphics.newQuad((i-1)*10+1, (line-1)*10+1, 8, 8, fontimage:getWidth(),fontimage:getHeight())
			fontquadsback[c] = love.graphics.newQuad((i-1)*10, (line-1)*10, 10, 10, fontimage:getWidth(),fontimage:getHeight())
			--UPPER CASE
			local ci = c
			if line == 2 then
				ci = utf8.sub(s[1],i,i)
			elseif line == 8 or line == 9 then
				ci = utf8.sub(s[line-2],i,i)
			elseif line == 12 or line == 13 then
				ci = utf8.sub(s[line-2],i,i)
			end
			fontindexCAP[c] = ci
			--export font.fnt layout
			--out = out .. string.format("char id=%d x=%d y=%d width=10 height=10 xoffset=-1 yoffset=0 xadvance=8 page=0 chnl=15\n", utf8.codepoint(c), (i-1)*10, (line-1)*10)
			--Capitals
			--local qx,qy = fontquads[ci]:getViewport()
			--out = out .. string.format("char id=%d x=%d y=%d width=10 height=10 xoffset=-1 yoffset=0 xadvance=8 page=0 chnl=15\n", utf8.codepoint(c), qx-1,qy-1)
		end
	end
	--love.system.setClipboardText(out)
	fontindexCAP["{"] = "←"
	fontindexCAP["}"] = "→"
	for j, w in pairs(fontindexCAP) do
		fontindexOLD[j] = w
	end
	fontindexOLD["A"] = ","
	fontindexOLD["B"] = "-"
	fontindexOLD["D"] = "↓"
	fontindexOLD["U"] = "↑"

	if love.filesystem.getInfo("alesans_entities/familyfriendly.txt") then FamilyFriendly = true end
	
	math.randomseed(os.time());math.random();math.random()
	
	--intro
	loadingtexts = {"reticulating splines", "rendering important stuff", "01110000011011110110111001111001", "sometimes, i dream about cheese",
					"baking cake", "happy explosion day", "raising coolness by a fifth", "yay facepunch", "stabbing myself", "sharpening knives",
					"tanaka, thai kick", "loading game genie..", "slime will find you", "becoming self-aware", "it's a secret to everybody", "there is no minus world", 
					"oh my god, jc, a bomb", "silly loading message here", "motivational art by jorichi", "you're my favorite deputy", 
					"licensed under wtfpl", "banned in australia", "loading anti-piracy module", "watch out there's a sni", "attack while its tail's up!", 
					"what a horrible night to have a curse", "han shot first", "establishing connection to nsa servers..","how do i programm", 
					"making palette inaccurate..", "y cant mario crawl?", "please hold..", "avoiding lawsuits", "loading bugs", "traduciendo a ingles",
					"fixign typo..", "swing your arms", "this message will self destruct in 3 2 1", "preparing deadly neurotoxin", "loading asleons entetis..", 
					"now with online multiplayer", "any second now..", "all according to keikaku", "we need pow blocks!", "cross your fingers",
					"not accurate to the nes!", "improved stability to enhance user experience.", "0118 999 881 999 119 7253", "hoo-ray",
					"removing herobrine", "how do i play multiplayer????", "not mario maker", "hello there", "this statement is false", 
					"zap to the extreme", "it just works", "eat your arms", "travelling qpus...", "im a tire", "in real life!", "bold and brash", 
					"giant enemy crabs", "but im super duper, with a big tuper", "see that mountain? you can climb it", "loading alesan99's stuff"}
						
	loadingtext = loadingtexts[math.random(#loadingtexts)]
	loadingbardraw(1)
	
	--require ALL the files!
	require "shaders"
	require "spriteloader"
	require "variables"
	require "mappack"
	require "class"
	require "sha1"
	require "netplay"
	JSON = require "JSON"
	require "notice"
	require "languages"
	
	local luas = {"intro", "menu", "levelscreen", "game", "editor", "physics", "online", "quad", "animatedquad", "entity", "dailychallenge",
				"portalwall", "tile", "mario", "mushroom", "hatconfigs", "flower", "star", "coinblockanimation",
				"scrollingscore", "platform", "platformspawner", "portalparticle", "portalprojectile", "box", "emancipationgrill", "door",
				"button", "groundlight", "wallindicator", "walltimer", "lightbridge", "faithplate", "laser", "laserdetector", "gel", "geldispenser",
				"cubedispenser", "pushbutton", "screenboundary", "fireball", "gui", "blockdebris", "firework", "vine", "spring", "seesaw",
				"seesawplatform", "bubble", "rainboom", "miniblock", "notgate", "musicloader", "smbsitem",
				"donut", "levelball", "leaf", "mariotail", "windleaf", "energylauncher", "energycatcher", "blocktogglebutton", "squarewave",
				"delayer", "coin", "funnel", "longfire", "pedestal", "portalent", "text", "regiontrigger", "tiletool",  
				"enemytool", "randomizer", "yoshi", "musicchanger", "mariohammer", "regiondrag", "flipblock",
				"characters", "checkpoint", "onlinemenu", "lobby", "magic", "doorsprite", "enemies", "enemy", "itemanimation", "cappy",
				"emancipationfizzle", "emancipateanimation", "ceilblocker", "belt", "hatloader", "poof", "animationguiline", "animation",
				"animationsystem", "animationtrigger", "dialogbox", "portal", "orgate", "andgate", "animatedtiletrigger", "rsflipflop", "animatedtimer",
				"collectable", "powblock", "smallspring", "risingwater", "redseesaw", "snakeblock", "frozencoin", "entitytooltip", "spawnanimation",
				"camerastop", "clearpipe", "track", "tilemoving", "laserfield", "checkpointflag", "ice", "pipe", "errorwindow", "filebrowser"}
	for i = 1, #luas do
		require(luas[i])
	end
	print("done loading .luas!")
	loadingbardraw(1)
	local enemyluas = love.filesystem.getDirectoryItems("enemies")
	for i = 1, #enemyluas do
		require("enemies." .. enemyluas[i]:sub(1, enemyluas[i]:len()-4))
	end
	print("done loading enemies!")
	loadingbardraw(1)

	--json error window
	JSONcrashgame = true
	jsonerrorwindow = errorwindow:new("","")
	
	--internet connection
	http = require("socket.http")
	http.TIMEOUT = 1

	credited = true
	http.TIMEOUT = 7
	
	graphicspack = "SMB" --SMB, ALLSTARS
	playertypei = 1
	playertype = playertypelist[playertypei] --portal, minecraft
	
	if volume == 0 then
		soundenabled = false
	else
		soundenabled = true
	end
	love.filesystem.createDirectory("mappacks")
	love.filesystem.createDirectory("saves")
	
	love.filesystem.createDirectory("alesans_entities")
	love.filesystem.createDirectory("alesans_entities/mappacks")
	love.filesystem.createDirectory("alesans_entities/saves")
	love.filesystem.createDirectory("alesans_entities/onlinemappacks")
	love.filesystem.createDirectory("alesans_entities/characters")
	love.filesystem.createDirectory("alesans_entities/hats")
	
	--[[copy included zip dlcs to save folder (because of course you can't mount from source directory :/)
	local zips = love.filesystem.getDirectoryItems("alesans_entities/dlc_mappacks")
	if #zips > 0 then
		for j, w in pairs(zips) do
			if not love.filesystem.getInfo("alesans_entities/onlinemappacks/" .. w) then
				local filedata = love.filesystem.newFileData("alesans_entities/dlc_mappacks/" .. w)
				love.filesystem.write("alesans_entities/onlinemappacks/" .. w, filedata)
				if j == 1 and not love.filesystem.getInfo("alesans_entities/onlinemappacks/" .. w) then
					break
				end
			end
		end
	end]]

	--mount dlc zip files
	if onlinedlc then
		mountalldlc()
	end
	
	if checkmappack and love.filesystem.getInfo(mappackfolder .. "/" .. checkmappack .. "/") then
		mappack = checkmappack
		checkmappack = nil
		saveconfig()
	end

	if love.filesystem.getInfo("suspend") then
		convertoldsuspendfile()
	end

	loadingbardraw(1)
	
	--check date for daily challenges
	datet = {os.date("%m"),os.date("%d"),os.date("%Y")}
	DChigh = {"-", "-", "-"}
	DChightemp = false
	if love.filesystem.getInfo("alesans_entities/dc.txt") then
		local s = love.filesystem.read("alesans_entities/dc.txt")
		local s2 = s:split("~")
		DCcompleted = tonumber(s2[1])
		if s2[2] == datet[1] .. "/" .. datet[2] .. "/" .. datet[3] then
			DChigh[1] = "finished"
			DChightemp = true
		end
	else
		DCcompleted = 0
	end
	DCchalobjective = select(2, getdailychallenge())
	DCchalobjectivet = {""} --wrap the text so it won't look ugly in the menu
	local splt = DCchalobjective:split(" ")
	local i = 1
	while splt[i] do
		if (DCchalobjectivet[#DCchalobjectivet] .. splt[i] .. " "):len() <= 15 then
			DCchalobjectivet[#DCchalobjectivet] = DCchalobjectivet[#DCchalobjectivet] .. splt[i] .. " "
			i = i + 1
		else
			table.insert(DCchalobjectivet, "")
		end
	end
	
	--nitpicks
	loadnitpicks()

	loadcustomplayers()
	
	editormode = false
	yoffset = 0
	love.graphics.setPointSize(3*scale)
	love.graphics.setLineWidth(3*scale)
	
	uispace = math.floor(width*16*scale/4)
	guielements = {}
	
	--limit hats
	for playerno = 1, players do
		for i = 1, #mariohats[playerno] do
			if mariohats[playerno][i] > hatcount then
				mariohats[playerno][i] = hatcount
			end
		end
	end
	
	defaultcustomtext("initial")
	loadcustomtext()

	loadingbardraw(1)
	
	--custom players
	--loadplayer()
	
	--Backgroundcolors
	backgroundcolor = {}
	backgroundcolor[1] = {92, 148, 252}
	backgroundcolor[2] = {0, 0, 0}
	backgroundcolor[3] = {32, 56, 236}
	backgroundcolor[4] = {0, 0, 0} --custom
	--[[backgroundcolor[5] = {60, 188, 252}
	backgroundcolor[6] = {168, 228, 252}
	backgroundcolor[7] = {252, 216, 168}
	backgroundcolor[8] = {252, 188, 176}
	backgroundcolor[9] = {24, 60, 92}]]
	
	--IMAGES--
	
	menuselectimg = love.graphics.newImage("graphics/" .. graphicspack .. "/menuselect.png")
	mappackback = love.graphics.newImage("graphics/GUI/mappackback.png")
	mappacknoicon = love.graphics.newImage("graphics/GUI/mappacknoicon.png")
	mappackonlineicon = love.graphics.newImage("graphics/GUI/mappackonlineicon.png")
	mappackloadingicon = love.graphics.newImage("graphics/GUI/mappackloading.png")
	mappackoverlay = love.graphics.newImage("graphics/GUI/mappackoverlay.png")
	mappackhighlight = love.graphics.newImage("graphics/GUI/mappackhighlight.png")
	
	mappackscrollbar = love.graphics.newImage("graphics/GUI/mappackscrollbar.png")
	
	uparrowimg = love.graphics.newImage("graphics/GUI/uparrow.png")
	downarrowimg = love.graphics.newImage("graphics/GUI/downarrow.png")
	customenemyiconimg = love.graphics.newImage("graphics/GUI/customenemy.png")

	pathmarkerimg = love.graphics.newImage("graphics/GUI/pathmarker.png")
	trackmarkerimg = love.graphics.newImage("graphics/GUI/trackmarker.png")
	antsimg = love.graphics.newImage("graphics/GUI/ants.png")

	markbaseimg = love.graphics.newImage("graphics/markbase.png")
	markoverlayimg = love.graphics.newImage("graphics/markoverlay.png")
	
	--tiles
	smbtilesimg = love.graphics.newImage("graphics/" .. graphicspack .. "/smbtiles.png")
	portaltilesimg = love.graphics.newImage("graphics/" .. graphicspack .. "/portaltiles.png")
	entitiesimg = love.graphics.newImage("graphics/" .. graphicspack .. "/entities.png")
	tilequads = {}
	
	rgblist = {}
	
	--add smb tiles
	loadtiles("smb", "initial")
	--add portal tiles
	loadtiles("portal", "initial")
	--add entities
	entityquads = {}
	loadtiles("entity", "initial")
	
	--formated entities list
	entitiesform = {
		{name = "level markers",
			1,8,100,312,11, --erase and start
			21,--[[161,]]31,--[[233,256,]]81, --pipes (possibly combine them later?)
			257, --celing block (possibly camera block too?)
			23,24,25, 89, 33,34, 95,96, 131,132, 159,160, --zones
			35, --drag in
			304,--camera stop
			},
		{name = "platforming elements",
			309,--[[18,19,]]32,41,--[[42,]]92,80,289, --platforms
			258,137, --donut
			148,278, --block like entities
			266,287, --conveyors
			290, --snake block
			93,122,281,282, --springs
			14,219,--vines
			163,248,249,250, --doors
			79,--[[82,]]265,191, 228,  --fire
			315, --grinder
			285,164, --water
			211,292,293, 178,208,279,179,180,--buttons
			300,301, --helmet boxes
			302,--clear pipe
			306,317--tracks!
			},
		{name = "items",
			--[[297,]]2,3,101,4,187,296,5, --regulars
			121,269,217,218,113, --smbs items
			299,202,155,141,151,252,253,254,255,239,311,193,286,307,308, --new powerups
			207, --yoshi
			154, --? Ball
			},
		{name = "enemies",
			6,--[[9,]]103,114,237,118,--[[119,]] --goomba
			7,--[[10,]]117,78,158,116, 12,--[[13,]]77, 156,--[[157,]] --koopa, red, blue
			98,--[[99,]]263,261,115, --spiny
			75,--[[76,]]209,262,130, --beetle
			212,--[[213,]] --spiketop
			70,102,123,124,147,149,129,305, --plants
			15,120,241,138,221, --hammer bros
			16,17,298,184, 94,162,242, --fishies (and bloopers)
			22,83,264, 109,110, --lakitu and sun
			188, --fuzzy
			60,246,104,105,150,--[[192,]]303,145,--[[146,]] --bullets and military stuff
			142,260,247, 111,--[[112,]]--boos and splunkins
			--[[125,]]224,283,284,234,259, 127,--[[128,]]288,126,133,--[[134,]]235,--[[236,]]135,136, 97, --castle stuffs
			90,91,153,238,316,240, --bowser bosses
			106,216,107,108,280, --smbs enemies
			203,--[[204,]]140,214,215,--smb2 enemies
			139,152,189,190, --flying beetles
			--[[143,]]314,144,223, --moles
			220, 243, 244,251, 245, 294,295, --mario maker enemies
			
			313, --super size
			},
		{name = "i/o objects",
			275,210,271,270,291,200,199,276,277,201,205},
		{name = "gates",
			30,74, --not really logic gates
			84,274,273,186,272,185,206},
		{name = "portal elements",
			20,165,222, --cubes
			40,267,268, 68,--[[69,]] --buttons
			28,--[[29,]] --doors
			--[[26,]]27,--[[311,]] --emancipation and laserfield
			36,--[[37,38,39,]] 52,--[[53,54,55,]] 56,--[[57,58,59,]] --lasers
			43,44,45,46,47,48, --powerline
			49,--[50,51,]] --faithplate
			67, 61,--[[62,63, 64,65,66, 71,72,73, 181,182,183, 225,226,227,]] --dispensers
			85,--[[86,87,88,]] --gel
			166,--[[167,168,169,]] 170,--[[171,172,173,]] --energy launcher
			174,--[[175, 176,177,]] 194, --turrets
			195, --glados
			196,
			197,198, --portals
			231,--[[229,230,232]] --funnels
			310,--pneumatic tube (just clearpipe but shhh)
		},
		{name = "custom enemies",
		},
	}

	local namespacing = 10
	local ly = 0 --listy
	for list = 1, #entitiesform do
		ly = ly + namespacing
		entitiesform[list].y = ly
		entitiesform[list].h = 17*(math.ceil(#entitiesform[list]/22))
		ly = ly + entitiesform[list].h
	end
					
	--check if entities are missing because i'm stupid
	--[[local entitycheck = {}
	for i = 1, entitiescount do
		entitycheck[i] = 0 --false
	end
	for j, form in pairs(entitiesform) do
		for i = 1, #form do
			entitycheck[form[i] ] = entitycheck[form[i] ] + 1-- = true
		end
	end
	for j, w in pairs(entitycheck) do
		local s = w
		if s == 0 then
			s = "false"
		else
			s = "true " .. s
		end
		print(j .. " - " .. s)
	end]]
	
	--sledge bro shock
	shockimg = love.graphics.newImage("graphics/" .. graphicspack .. "/shock.png")
	shockquad = {}
	shockquad[1] = love.graphics.newQuad(0, 0, 4, 25, 8, 25)
	shockquad[2] = love.graphics.newQuad(4, 0, 4, 25, 8, 25)

	--if lights out mode isn't supported on device
	mariolightimg = love.graphics.newImage("graphics/" .. graphicspack .. "/mariolight.png")
	
	calendarimg = love.graphics.newImage("graphics/" .. graphicspack .. "/calendar.png")
	
	--menut tips
	menutips = {"resize the game window by changing the scale to 'resizable' in the options!",
			"download dlc mappacks by going to the dlc tab in the mappack menu!",
			"is there a problem with the mod? tell me at the stabyourself.net forums!",
			"there are currently about " .. math.floor(entitiescount-100) .. " new entities in this mod! try them out!",
			--"change your mappack folder to 'alesans_entities/mappacks' in the options to prevent crashes when you use unmodded mari0!",
			"lock your mouse with f12!",
			"display fps with f11!",
			"experienced an error? post your error found in 'mari0/alesans_entities/crashes' at the stabyourself.net forums!",
			"you can access the mari0 folder easily by pressing 'm' in the mappack selection menu!",
			"try out the dlc mappacks!",
			"try out today's daily challenge by going to the mappack selection menu and going to the 'daily challenge' tab!",
			"finish the super mario bros. mappack to unlock something special!",
			"turn on assist mode in the editor by pressing the +/equal sign key!",
			"play with friends online! press the left key to start!",
			"enter fullscreen with alt and enter.",
			"change your character in the settings!",
			"add more playable characters in the 'mari0/alesans_entities/characters' folder."}
	disabletips = false

	loadingbardraw(1)
	
	------------------------------
	------------QUADS-------------
	------------------------------
	numberglyphs = "012458"
	font2quads = {}
	for i = 1, 6 do
		font2quads[string.sub(numberglyphs, i, i)] = love.graphics.newQuad((i-1)*4, 0, 4, 8, 32, 8)
	end

	directionsimg = love.graphics.newImage("graphics/GUI/directions.png")
	local directionquadnames = {"hor", "ver", "left", "up", "right", "down", "cw", "ccw", "left up", "right up", "left down", "right down"}
	directionsquad = {}
	for x = 1, #directionquadnames do
		directionsquad[directionquadnames[x]] = love.graphics.newQuad((x-1)*7, 0, 7, 7, #directionquadnames*7, 7)
	end

	pathmarkerquad = {
		love.graphics.newQuad(0, 0, 16, 16, 64, 48),
		love.graphics.newQuad(16, 0, 16, 16, 64, 48),
		love.graphics.newQuad(0, 16, 32, 16, 64, 48),
		love.graphics.newQuad(0, 32, 32, 16, 64, 48),
		love.graphics.newQuad(32, 16, 32, 32, 64, 48),
	}
	trackmarkerquad = {
		love.graphics.newQuad(0, 0, 16, 16, 64, 16),
		love.graphics.newQuad(16, 0, 16, 16, 64, 16),
		love.graphics.newQuad(32, 0, 16, 16, 64, 16),
		love.graphics.newQuad(48, 0, 16, 16, 64, 16),
	}
	
	linktoolpointerimg = love.graphics.newImage("graphics/GUI/linktoolpointer.png")

	local pipedirs = {"up", "left", "down", "right", "default", ""}
	pipesimg = love.graphics.newImage("graphics/GUI/pipes.png")
	pipesquad = {}
	for y = 1, 4 do
		pipesquad[y] = {}
		for x = 1, 6 do
			pipesquad[y][pipedirs[x]] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, 96, 64)
		end
	end
	
	loadquads(true)

	--portals
	portalquad = {}
	for i = 0, 7 do
		portalquad[i] = love.graphics.newQuad(0, i*4, 32, 4, 32, 28)
	end
	
	--portals
	portal1quad = {}
	for i = 0, 7 do
		portal1quad[i] = love.graphics.newQuad(0, i*4, 32, 4, 64, 32)
	end
	
	portal2quad = {}
	for i = 0, 7 do
		portal2quad[i] = love.graphics.newQuad(32, i*4, 32, 4, 64, 32)
	end
	
	--Portal props
	pushbuttonquad = {}
	for y = 1, 4 do
		pushbuttonquad[y] = {}
		for x = 1, 2 do
			pushbuttonquad[y][x] = love.graphics.newQuad(16*(x-1), 16*(y-1), 16, 16, 32, 64)
		end
	end
	buttonquad = {}
	for y = 1, 4 do
		buttonquad[y] = {}
		for i = 1, 3 do
			buttonquad[y][i] = {}
			for x = 1, 2 do
				buttonquad[y][i][x] = love.graphics.newQuad(64*(i-1)+32*(x-1), 5*(y-1), 32, 5, 192, 20)
			end
		end
	end
	
	wallindicatorquad = {}
	for y = 1, 4 do
		wallindicatorquad[y] = {love.graphics.newQuad(0, 16*(y-1), 16, 16, 32, 64), love.graphics.newQuad(16, 16*(y-1), 16, 16, 32, 64)}
	end

	walltimerquad = {}
	for y = 1, 4 do
		walltimerquad[y] = {}
		for i = 1, 10 do
			walltimerquad[y][i] = love.graphics.newQuad((i-1)*16, (y-1)*16, 16, 16, 160, 64)
		end
	end

	excursionquad = {}
	for x = 1, 8 do
		excursionquad[x] = love.graphics.newQuad((x-1)*8, 0, 8, 32, 64, 32)
	end

	gelquad = {love.graphics.newQuad(0, 0, 12, 12, 36, 12), love.graphics.newQuad(12, 0, 12, 12, 36, 12), love.graphics.newQuad(24, 0, 12, 12, 36, 12)}
	
	--ground lights
	groundlightquad = {}
	for s = 1, 4 do
		groundlightquad[s] = {}
		for x = 1, 6 do
			groundlightquad[s][x] = {}
			for y = 1, 2 do
				groundlightquad[s][x][y] = love.graphics.newQuad((x-1)*16, (s-1)*32+(y-1)*16, 16, 16, 96, 128)
			end
		end
	end

	--turrets
	turretquad = {}
	for x = 1, 2 do
		turretquad[x] = love.graphics.newQuad((x-1)*12, 0, 12, 14, 24, 14)
	end

	--cube dispenser
	cubedispenserquad = {}
	for y = 1, 4 do
		cubedispenserquad[y] = love.graphics.newQuad(0, (y-1)*32, 32, 32, 32, 128)
	end

	--gel dispensers
	geldispenserquad = {}
	for y = 1, 4 do
		geldispenserquad[y] = {}
		for x = 1, 5 do
			geldispenserquad[y][x] = love.graphics.newQuad((x-1)*32, (y-1)*32, 32, 32, 160, 128)
		end
	end
	
	--faithplate
	faithplatequad = {}
	for y = 1, 4 do
		faithplatequad[y] = love.graphics.newQuad(0, (y-1)*16, 32, 16, 32, 32)
	end

	--laserdetector
	laserdetectorquad = {}
	for x = 1, 2 do
		laserdetectorquad[x] = love.graphics.newQuad((x-1)*16, 0, 16, 16, 32, 16)
	end

	--emanceside
	emancesidequad = {}
	for y = 1, 4 do
		emancesidequad[y] = {}
		for x = 1, 2 do
			emancesidequad[y][x] = love.graphics.newQuad((x-1)*5, (y-1)*8, 5, 8, 10, 32)
		end
	end

	--ice
	icequad = {}
	for i = 1, 9 do
		icequad[i] = love.graphics.newQuad((((i-1)%3))*8, math.floor(i/3-.1)*8, 8, 8, 24, 24)
	end
	
	bunnyearsimg = love.graphics.newImage("graphics/" .. graphicspack .. "/bunnyears.png")
	bunnyearsquad = {}
	for x = 1, 3 do
		bunnyearsquad[x] = love.graphics.newQuad((x-1)*15, 0, 15, 7, 30, 7)
	end
	
	capeimg = love.graphics.newImage("graphics/" .. graphicspack .. "/cape.png")
	capequad = {}
	for x = 1, 19 do
		capequad[x] = love.graphics.newQuad((x-1)*16, 0, 16, 34, 304, 34)
	end
	
	--eh
	rainboomquad = {}
	for x = 1, 7 do
		for y = 1, 7 do
			rainboomquad[x+(y-1)*7] = love.graphics.newQuad((x-1)*204, (y-1)*182, 204, 182, 1428, 1274)
		end
	end
	
	--magic!
	magicimg = love.graphics.newImage("graphics/magic.png")
	magicquad = {}
	for x = 1, 6 do
		magicquad[x] = love.graphics.newQuad((x-1)*9, 0, 9, 9, 54, 9)
	end

	--GUI
	checkboximg = love.graphics.newImage("graphics/GUI/checkbox.png")
	checkboxquad = {{love.graphics.newQuad(0, 0, 9, 9, 18, 18), love.graphics.newQuad(9, 0, 9, 9, 18, 18)}, {love.graphics.newQuad(0, 9, 9, 9, 18, 18), love.graphics.newQuad(9, 9, 9, 9, 18, 18)}}
	
	dropdownarrowimg = love.graphics.newImage("graphics/GUI/dropdownarrow.png")
	
	quickmenuarrowimg = love.graphics.newImage("graphics/GUI/quickmenuarrow.png")
	
	customimagebackimg = love.graphics.newImage("graphics/GUI/customimageback.png")
	tilepropertiesimg = love.graphics.newImage("graphics/tileproperties.png")
	
	mappackonlineiconquad = {}
	mappackonlineiconquad[1] = love.graphics.newQuad(0, 0, 50, 50, 64, 64)
	mappackonlineiconquad[2] = love.graphics.newQuad(50, 0, 14, 14, 64, 64)
	mappackonlineiconquad[3] = love.graphics.newQuad(50, 14*1, 14, 14, 64, 64)
	mappackonlineiconquad[4] = love.graphics.newQuad(50, 14*2, 14, 14, 64, 64)
	mappackonlineiconquad[5] = love.graphics.newQuad(50, 14*3, 14, 14, 64, 64)
	mappackonlineiconquad[6] = love.graphics.newQuad(0, 50, 14, 14, 64, 64)
	mappackonlineiconquad[7] = love.graphics.newQuad(14, 50, 14, 14, 64, 64)
	
	hudclockquad = {}
	hudclockquad[false] = love.graphics.newQuad(0, 0, 10, 9, 10, 18)
	hudclockquad[true] = love.graphics.newQuad(0, 9, 10, 9, 10, 18) --outline
	
	--Portal FX

	portalgunimg = love.graphics.newImage("graphics/" .. graphicspack .. "/portalgun.png")
	portalparticleimg = love.graphics.newImage("graphics/" .. graphicspack .. "/portalparticle.png")
	portalcrosshairimg = love.graphics.newImage("graphics/" .. graphicspack .. "/portalcrosshair.png")
	portaldotimg = love.graphics.newImage("graphics/" .. graphicspack .. "/portaldot.png")
	portalprojectileimg = love.graphics.newImage("graphics/" .. graphicspack .. "/portalprojectile.png")
	portalprojectileparticleimg = love.graphics.newImage("graphics/" .. graphicspack .. "/portalprojectileparticle.png")
	
	--Menu shit
	huebarimg = love.graphics.newImage("graphics/GUI/huebar.png")
	huebarmarkerimg = love.graphics.newImage("graphics/GUI/huebarmarker.png")
	volumesliderimg = love.graphics.newImage("graphics/GUI/volumeslider.png")
	
	laserfieldimg = love.graphics.newImage("graphics/" .. graphicspack .. "/laserfield.png")

	gradientimg = love.graphics.newImage("graphics/gradient.png");gradientimg:setFilter("linear", "linear")

	rainboomimg = love.graphics.newImage("graphics/rainboom.png")
	
	--sprites
	customsprites = false
	loadcustomsprites(true)
	
	--Ripping off
	minecraftbreakimg = love.graphics.newImage("graphics/Minecraft/blockbreak.png")
	minecraftbreakquad = {}
	for i = 1, 10 do
		minecraftbreakquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 160, 16)
	end
	minecraftgui = love.graphics.newImage("graphics/Minecraft/gui.png")
	minecraftselected = love.graphics.newImage("graphics/Minecraft/selected.png")
	minecraftpickaxeimg = love.graphics.newImage("graphics/Minecraft/pickaxe.png")
	minecraftpickaxequad = {}
	for y = 1, 5 do
		minecraftpickaxequad[y] = love.graphics.newQuad(0, (y-1)*20, 20, 20, 20, 100)
	end
	
	print("done loading all quads!")
	loadingbardraw(1)
	
	--AUDIO--
	--sounds
	jumpsound = love.audio.newSource("sounds/jump.ogg", "static")
	jumpbigsound = love.audio.newSource("sounds/jumpbig.ogg", "static")
	jumptinysound = love.audio.newSource("sounds/jumptiny.ogg", "static")
	stompsound = love.audio.newSource("sounds/stomp.ogg", "static")
	shotsound = love.audio.newSource("sounds/shot.ogg", "static")
	blockhitsound = love.audio.newSource("sounds/blockhit.ogg", "static")
	blockbreaksound = love.audio.newSource("sounds/blockbreak.ogg", "static")
	coinsound = love.audio.newSource("sounds/coin.ogg", "static")
	pipesound = love.audio.newSource("sounds/pipe.ogg", "static")
	boomsound = love.audio.newSource("sounds/boom.ogg", "static")
	mushroomappearsound = love.audio.newSource("sounds/mushroomappear.ogg", "static")
	mushroomeatsound = love.audio.newSource("sounds/mushroomeat.ogg", "static")
	shrinksound = love.audio.newSource("sounds/shrink.ogg", "static")
	deathsound = love.audio.newSource("sounds/death.ogg", "static")
	gameoversound = love.audio.newSource("sounds/gameover.ogg", "static")
	fireballsound = love.audio.newSource("sounds/fireball.ogg", "static")
	oneupsound = love.audio.newSource("sounds/oneup.ogg", "static")
	levelendsound = love.audio.newSource("sounds/levelend.ogg", "static")
	castleendsound = love.audio.newSource("sounds/castleend.ogg", "static")
	scoreringsound = love.audio.newSource("sounds/scorering.ogg", "static");scoreringsound:setLooping(true)
	intermissionsound = love.audio.newSource("sounds/intermission.ogg", "stream")
	firesound = love.audio.newSource("sounds/fire.ogg", "static")
	bridgebreaksound = love.audio.newSource("sounds/bridgebreak.ogg", "static")
	bowserfallsound = love.audio.newSource("sounds/bowserfall.ogg", "static")
	vinesound = love.audio.newSource("sounds/vine.ogg", "static")
	swimsound = love.audio.newSource("sounds/swim.ogg", "static")
	rainboomsound = love.audio.newSource("sounds/rainboom.ogg", "static")
	konamisound = love.audio.newSource("sounds/konami.ogg", "static")
	pausesound = love.audio.newSource("sounds/pause.ogg", "static")
	bulletbillsound = love.audio.newSource("sounds/bulletbill.ogg", "static")
	stabsound = love.audio.newSource("sounds/stab.ogg", "static")
	iciclesound = love.audio.newSource("sounds/icicle.ogg", "static")
	thwompsound = love.audio.newSource("sounds/thwomp.ogg", "static")
	boomerangsound = love.audio.newSource("sounds/boomerang.ogg", "static")
	raccoonswingsound = love.audio.newSource("sounds/raccoonswing.ogg", "static")
	raccoonplanesound = love.audio.newSource("sounds/raccoonplane.ogg", "static");raccoonplanesound:setLooping(true)
	skidsound = love.audio.newSource("sounds/skid.ogg", "static")
	turretshotsound = love.audio.newSource("sounds/turretshot.ogg", "static")
	pbuttonsound = love.audio.newSource("sounds/pbutton.ogg", "stream");pbuttonsound:setLooping(true)
	windsound = love.audio.newSource("sounds/wind.ogg", "static");windsound:setLooping(true)
	suitsound = love.audio.newSource("sounds/suit.ogg", "static")
	koopalingendsound = love.audio.newSource("sounds/koopalingend.ogg", "static")
	bowserendsound = love.audio.newSource("sounds/bowserend.ogg", "static")
	dooropensound = love.audio.newSource("sounds/dooropen.ogg", "static")
	doorclosesound = love.audio.newSource("sounds/doorclose.ogg", "static")
	keysound = love.audio.newSource("sounds/key.ogg", "static")
	keyopensound = love.audio.newSource("sounds/keyopen.ogg", "static")
	heelsound = love.audio.newSource("sounds/heel.ogg", "static")
	weirdmushroomsound = love.audio.newSource("sounds/weirdmushroom.ogg", "static")
	jumpskinnysound = love.audio.newSource("sounds/jumpskinny.ogg", "static")
	energybouncesound = love.audio.newSource("sounds/energybounce.ogg", "static")
	shufflesound = love.audio.newSource("sounds/shuffle.ogg", "static");shufflesound:setLooping(true)
	grabsound = love.audio.newSource("sounds/grab.ogg", "static")
	throwsound = love.audio.newSource("sounds/throw.ogg", "static")
	switchsound = love.audio.newSource("sounds/switch.ogg", "static")
	iciclefallsound = love.audio.newSource("sounds/iciclefall.ogg", "static")
	helmetsound = love.audio.newSource("sounds/helmet.ogg", "static")
	helmethitsound = love.audio.newSource("sounds/helmethit.ogg", "static")
	propellersound = love.audio.newSource("sounds/propeller.ogg", "static")
	clearpipesound = love.audio.newSource("sounds/clearpipe.ogg", "static")
	checkpointsound = love.audio.newSource("sounds/checkpoint.ogg", "static")
	megamushroomsound = love.audio.newSource("sounds/megamushroom.ogg", "stream");megamushroomsound:setLooping(true)
	powblocksound = love.audio.newSource("sounds/powblock.ogg", "static")
	cannonfastsound = love.audio.newSource("sounds/cannonfast.ogg", "static")
	bumperhitsound = love.audio.newSource("sounds/bumperhit.ogg", "static")
	bumperjumpsound = love.audio.newSource("sounds/bumperjump.ogg", "static")
	stompbigsound = love.audio.newSource("sounds/stompbig.ogg", "static")
	thwompbigsound = love.audio.newSource("sounds/thwompbig.ogg", "static")
	superballsound = love.audio.newSource("sounds/superball.ogg", "static")
	superballeatsound = love.audio.newSource("sounds/superballeat.ogg", "static")
	capeflysound = love.audio.newSource("sounds/capefly.ogg", "static")
	mushroombigeatsound = love.audio.newSource("sounds/mushroombigeat.ogg", "static")
	groundpoundsound = love.audio.newSource("sounds/groundpound.ogg", "static")
	sausagesound = love.audio.newSource("sounds/totaka.ogg", "static")--this is for um, the sausage entity.
	babysound = love.audio.newSource("sounds/baby.ogg", "static")
	--i don't like this but i KNOW someone is going to complain about sounds if i don't do this
	collectable1sound = love.audio.newSource("sounds/collectable1.ogg", "static")
	collectable2sound = love.audio.newSource("sounds/collectable2.ogg", "static")
	collectable3sound = love.audio.newSource("sounds/collectable3.ogg", "static")
	collectable4sound = love.audio.newSource("sounds/collectable4.ogg", "static")
	collectable5sound = love.audio.newSource("sounds/collectable5.ogg", "static")
	collectable6sound = love.audio.newSource("sounds/collectable6.ogg", "static")
	collectable7sound = love.audio.newSource("sounds/collectable7.ogg", "static")
	collectable8sound = love.audio.newSource("sounds/collectable8.ogg", "static")
	collectable9sound = love.audio.newSource("sounds/collectable9.ogg", "static")
	collectable10sound = love.audio.newSource("sounds/collectable10.ogg", "static")
	
	glados1sound = love.audio.newSource("sounds/glados1.ogg", "stream")
	glados2sound = love.audio.newSource("sounds/glados2.ogg", "static")
	
	portal1opensound = love.audio.newSource("sounds/portal1open.ogg", "static");portal1opensound:setVolume(0.3)
	portal2opensound = love.audio.newSource("sounds/portal2open.ogg", "static");portal2opensound:setVolume(0.3)
	portalentersound = love.audio.newSource("sounds/portalenter.ogg", "static");portalentersound:setVolume(0.3)
	portalfizzlesound = love.audio.newSource("sounds/portalfizzle.ogg", "static");portalfizzlesound:setVolume(0.3)
	
	lowtimesound = love.audio.newSource("sounds/lowtime.ogg", "static")
	
	updatesoundlist = function()
		soundlist = {jumpsound, jumpbigsound, stompsound, shotsound, blockhitsound, blockbreaksound, coinsound, pipesound, boomsound, mushroomappearsound, mushroomeatsound, shrinksound, deathsound, gameoversound,
					turretshotsound, oneupsound, levelendsound, castleendsound, scoreringsound, intermissionsound, firesound, fireballsound, bridgebreaksound, bowserfallsound, vinesound, swimsound, rainboomsound, 
					portal1opensound, portal2opensound, portalentersound, portalfizzlesound, lowtimesound, pausesound, stabsound, bulletbillsound, iciclesound, thwompsound, boomerangsound, raccoonswingsound,
					raccoonplanesound, skidsound, jumptinysound, pbuttonsound, windsound, suitsound, koopalingendsound, bowserendsound, dooropensound, doorclosesound, keysound, keyopensound, weirdmushroomsound, jumpskinnysound,
					energybouncesound, shufflesound, grabsound, throwsound, collectable1sound, collectable2sound, collectable3sound, collectable4sound, collectable5sound, collectable6sound, collectable7sound, 
					collectable8sound, collectable9sound, collectable10sound, switchsound, iciclefallsound, helmetsound, helmethitsound, propellersound, clearpipesound, megamushroomsound, stompbigsound, thwompbigsound,
					superballeatsound, superballsound, capeflysound, mushroombigeatsound, bumperhitsound, bumperjumpsound, cannonfastsound, powblocksound, checkpointsound, groundpoundsound, glados1sound, glados2sound}
		soundliststring = {"jump", "jumpbig", "stomp", "shot", "blockhit", "blockbreak", "coin", "pipe", "boom", "mushroomappear", "mushroomeat", "shrink", "death", "gameover",
			"turretshot", "oneup", "levelend", "castleend", "scorering", "intermission", "fire", "fireball", "bridgebreak", "bowserfall", "vine", "swim", "rainboom",
			"portal1open", "portal2open", "portalenter", "portalfizzle", "lowtime", "pause", "stab", "bulletbill", "icicle", "thwomp", "boomerang", "raccoonswing",
			"raccoonplane", "skid", "jumptiny", "pbutton", "wind", "suit", "koopalingend", "bowserend", "dooropen", "doorclose", "key", "keyopen", "weirdmushroom", "jumpskinny",
			"energybounce", "shuffle", "grab", "throw", "collectable1","collectable2","collectable3","collectable4","collectable5","collectable6","collectable7","collectable8", "collectable9", "collectable10",
			"switch", "iciclefall", "helmet", "helmethit", "propeller", "clearpipe", "megamushroom", "stompbig", "thwompbig", "superballeat", "superball", "capefly", "mushroombigeat", "bumperhit",
			"bumperjump", "cannonfast", "powblock", "checkpoint", "groundpound", "glados1", "glados2"}
		local temptable = {} --sort the sounds
		for i, t in pairs(soundlist) do
		table.insert(temptable, {t, soundliststring[i]})
		end
		table.sort(temptable, function(a, b) return a[2] < b[2] end)
		for i, t in pairs(temptable) do
		soundlist[i] = t[1]
		soundliststring[i] = t[2]
		end
	end
	updatesoundlist()
	
	print("done loading all " .. #soundlist .. " sounds!")
	loadingbardraw(1)
	
	musici = 2
	
	shaders:init()
	shaders:set(1, shaderlist[currentshaderi1])
	shaders:set(2, shaderlist[currentshaderi2])
	
	--[[for i, v in pairs(dlclist) do
		delete_mappack(v)
	end]]

	for i = 1, #mariocharacter do
		if mariocharacter[i] then
			setcustomplayer(mariocharacter[i], i, "initial")
		end
	end

	--mouse cursors
	if (not android) and (not androidsafe) then--fuck you love2d android, just fucking these instead of crashing
		mousecursor_hand = love.mouse.getSystemCursor("hand")
		mousecursor_sizewe = love.mouse.getSystemCursor("sizewe")
	end

	--android buttons
	if android then
		require "android"
		androidLoad()
	end

	--debug graphs
	if debugGraphs then
		debugGraph = require "libs.debugGraph"
		fpsGraph = debugGraph:new('fps', 0, 0)
		memGraph = debugGraph:new('mem', 0, 30)
		drawGraph = debugGraph:new('custom', 0, 60)
	end

	--Set Language
	if CurrentLanguage and CurrentLanguage ~= "english" then
		set_language(CurrentLanguage)
	end

	loadingbardraw(1)
	
	intro_load()
end

function love.update(dt)
	if music then
		music:update()
	end
	dt = math.min(0.01666667, dt)
	
	--speed
	if speed ~= speedtarget then
		if speed > speedtarget then
			speed = math.max(speedtarget, speed+(speedtarget-speed)*dt*5)
		elseif speed < speedtarget then
			speed = math.min(speedtarget, speed+(speedtarget-speed)*dt*5)
		end
		
		if math.abs(speed-speedtarget) < 0.02 then
			speed = speedtarget
		end
		
		if speed > 0 then
			for i, v in pairs(soundlist) do
				v:setPitch( speed )
			end
			music.pitch = speed
			love.audio.setVolume(volume)
		else
			love.audio.setVolume(0)
		end
	end
	
	dt = dt * speed
	gdt = dt
	
	if frameadvance == 1 then
		return
	elseif frameadvance == 2 then
		frameadvance = 1
	end

	if jsonerrorwindow.opened and jsonerrorwindow:update(dt) then
		
	end

	if skipupdate then
		skipupdate = false
		return
	end
	
	--netplay_update(dt)
	if CLIENT then
		client_update(dt)
	elseif SERVER then
		server_update(dt)
	end
	keyprompt_update()
	
	if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "lobby" or gamestate == "options" then
		menu_update(dt)
	elseif gamestate == "levelscreen" or gamestate == "gameover" or gamestate == "sublevelscreen" or gamestate == "mappackfinished" or gamestate == "dclevelscreen" then
		levelscreen_update(dt)
	elseif gamestate == "game" then
		game_update(dt)	
	elseif gamestate == "intro" then
		intro_update(dt)
	elseif gamestate == "filebrowser" then
		filebrowser_update(dt)
	end
	
	for i, v in pairs(guielements) do
		v:update(dt)
	end

	if debugGraphs then
		--Update the graphs
		fpsGraph:update(dt)
		memGraph:update(dt)
		drawGraph:update(dt, drawGraph.drawcalls)
	end

	if android then
		androidUpdate(dt)
	end
	
	notice.update(dt)
end

function love.draw()
	if resizable or android then
		if letterboxfullscreen and (shaders.passes[1].on or shaders.passes[2].on) then
			love.graphics.setColor(0, 0, 0)
			love.graphics.rectangle("fill", 0, 0, winwidth, winheight)
		end
		love.graphics.setCanvas({canvas, stencil=true})
		love.graphics.clear()
		lovedraw()
		love.graphics.setCanvas()
		if letterboxfullscreen and not (shaders.passes[1].on or shaders.passes[2].on) then
			love.graphics.setColor(0, 0, 0)
			love.graphics.rectangle("fill", 0, 0, winwidth, winheight)
			local cw, ch = canvas:getWidth(), canvas:getHeight()--current size
			local tw, th = winwidth, winheight--target size
			local s
			if cw/tw > ch/th then s = tw/cw
			else s = th/ch end
			love.graphics.setColor(255, 255, 255)
			love.graphics.draw(canvas, winwidth/2, winheight/2, 0, s, s, cw/2, ch/2)
		else
			love.graphics.setColor(255, 255, 255)
			love.graphics.draw(canvas, 0, 0, 0, winwidth/(width*16*scale), winheight/(224*scale))
		end

		if android and not androidLowRes then
			androidDraw()
		end
	else
		lovedraw()
	end
	
	if debugGraphs then
		--Draw graphs
		love.graphics.setColor(255,255,255)
		local stats = love.graphics.getStats()
		love.graphics.setLineWidth(2)
		drawGraph.label = "Drawcalls: " .. stats.drawcalls
		drawGraph.drawcalls = stats.drawcalls
		fpsGraph:draw()
		memGraph:draw()
		drawGraph:draw()
	end
end

function lovedraw()
	shaders:predraw()
	
	if resizable then
		love.graphics.setColor(love.graphics.getBackgroundColor())
		love.graphics.rectangle("fill", 0, 0, width*16*scale, height*16*scale)
	end
	love.graphics.setColor(255, 255, 255)
	love.graphics.push()
	if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "lobby" or gamestate == "options" then
		menu_draw()
	elseif gamestate == "levelscreen" or gamestate == "gameover" or gamestate == "mappackfinished" or gamestate == "dclevelscreen" then
		levelscreen_draw()
	elseif gamestate == "game" then
		game_draw()
	elseif gamestate == "intro" then
		intro_draw()
	elseif gamestate == "filebrowser" then
		filebrowser_draw()
	end
	love.graphics.pop()
	
	notice.draw()
	
	if showfps then
		love.graphics.setColor(255, 255, 255, 180)
		properprintfast(love.timer.getFPS(), 2*scale, 2*scale)
	end

	if jsonerrorwindow.opened then
		jsonerrorwindow:draw()
	end

	if android and androidLowRes then
		androidDraw()
	end
	
	shaders:postdraw()
	
	if debugconsole and debuginputon then
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(debuginput, 1, 1)
		love.graphics.setColor(255, 255, 255)
		love.graphics.print(debuginput, 2, 2)
	end
	--testing sublevels (i KNOW you'll need this)
	--love.graphics.setColor(255,255,255)
	--properprint("mariosublevel: " .. tostring(mariosublevel) .. "\nprevsublevel: " .. tostring(prevsublevel) .. "\nactualsublevel: " .. tostring(actualsublevel), 2, 2)

	love.graphics.setColor(255, 255, 255)
end

function saveconfig()
	local s = ""
	for i = 1, #controls do
		s = s .. "playercontrols:" .. i .. ":"
		local count = 0
		for j, k in pairs(controls[i]) do
			local c = ""
			for l = 1, #controls[i][j] do
				c = c .. controls[i][j][l]
				if l ~= #controls[i][j] then
					c = c ..  "-"
				end
			end
			s = s .. j .. "-" .. c
			count = count + 1
			s = s .. ","
		end
		s = s:sub(1,-2) .. ";"
	end
	
	if mariocharacter then
		s = s .. "mariocharacter:"
		for i = 1, 4 do
			if mariocharacter[i] then
				s = s .. mariocharacter[i] .. ","
			else
				s = s .. "mario,"
			end
		end
		s = s .. ";"
	end
	
	for i = 1, #mariocolors do
		s = s .. "playercolors:" .. i .. ":"
		for j = 1, #mariocolors[i] do
			for k = 1, 3 do
				s = s .. mariocolors[i][j][k]
				if j == #mariocolors[i] and k == 3 then
					s = s .. ";"
				else
					s = s .. ","
				end
			end
		end
	end
	
	for i = 1, #portalhues do
		s = s .. "portalhues:" .. i .. ":"
		s = s .. round(portalhues[i][1], 4) .. "," .. round(portalhues[i][2], 4) .. ";"
	end
	
	for i = 1, #mariohats do
		s = s .. "mariohats:" .. i
		if #mariohats[i] > 0 then
			s = s .. ":"
		end
		for j = 1, #mariohats[i] do
			s = s .. mariohats[i][j]
			if j == #mariohats[i] then
				s = s .. ";"
			else
				s = s .. ","
			end
		end
		
		if #mariohats[i] == 0 then
			s = s .. ";"
		end
	end
	
	if resizable then
		s = s .. "scale:2;"
	else
		s = s .. "scale:" .. scale .. ";"
	end

	s = s .. "letterbox:" .. tostring(letterboxfullscreen) .. ";"
	
	s = s .. "shader1:" .. shaderlist[currentshaderi1] .. ";"
	s = s .. "shader2:" .. shaderlist[currentshaderi2] .. ";"
	
	s = s .. "volume:" .. volume .. ";"
	s = s .. "mouseowner:" .. mouseowner .. ";"
	
	if mappackfolder == "alesans_entities/mappacks" then
		s = s .. "modmappacks;"
	end
	
	s = s .. "mappack:" .. mappack .. ";"
	
	if vsync then
		s = s .. "vsync;"
	end
	
	if gamefinished then
		s = s .. "gamefinished;"
	end
	
	--reached worlds
	for i, v in pairs(reachedworlds) do
		s = s .. "reachedworlds:" .. i .. ":"
		
		local n = math.max(8, #reachedworlds[i])
		
		for j = 1, n do
			if v[j] then
				s = s .. 1
			else
				s = s .. 0
			end
			
			if j == n then
				s = s .. ";"
			else
				s = s .. ","
			end
		end
	end
	
	s = s .. "resizable:" .. tostring(resizable) .. ";"
	if CurrentLanguage then
		s = s .. "language:" .. CurrentLanguage .. ";"
	end
	
	if fourbythree then
		s = s .. "fourbythree;"
	end
	
	if localnick then
		s = s .. "localnick:" .. localnick .. ";"
	end
	love.filesystem.write("alesans_entities/options.txt", s)
end

function loadconfig(nodefaultconfig)
	players = 1
	if not nodefaultconfig then
		defaultconfig()
	end
	
	local s
	if love.filesystem.getInfo("alesans_entities/options.txt") then
		s = love.filesystem.read("alesans_entities/options.txt")
	elseif love.filesystem.getInfo("options.txt") then
		s = love.filesystem.read("options.txt")
	else
		return
	end
	
	s1 = s:split(";")
	for i = 1, #s1-1 do
		s2 = s1[i]:split(":")
		
		if s2[1] == "playercontrols" then
			if controls[tonumber(s2[2])] == nil then
				controls[tonumber(s2[2])] = {}
			end
			
			s3 = s2[3]:split(",")
			for j = 1, #s3 do
				s4 = s3[j]:split("-")
				controls[tonumber(s2[2])][s4[1]] = {}
				for k = 2, #s4 do
					if tonumber(s4[k]) ~= nil then
						controls[tonumber(s2[2])][s4[1]][k-1] = tonumber(s4[k])
					elseif s4[k] == "space" then
						controls[tonumber(s2[2])][s4[1]][k-1] = " " -- fix imported configs from 1.6
					else
						controls[tonumber(s2[2])][s4[1]][k-1] = s4[k]
					end
				end
			end
			players = math.max(players, tonumber(s2[2]))
			
		elseif s2[1] == "playercolors" then
			if mariocolors[tonumber(s2[2])] == nil then
				mariocolors[tonumber(s2[2])] = {}
			end
			s3 = s2[3]:split(",")
			mariocolors[tonumber(s2[2])] = {}
			for j = 1, math.floor(#s3/3) do
				table.insert(mariocolors[tonumber(s2[2])], {tonumber(s3[3*(j-1)+1]), tonumber(s3[3*(j-1)+2]), tonumber(s3[3*(j-1)+3])})
			end
			
		elseif s2[1] == "portalhues" then
			if portalhues[tonumber(s2[2])] == nil then
				portalhues[tonumber(s2[2])] = {}
			end
			s3 = s2[3]:split(",")
			portalhues[tonumber(s2[2])] = {tonumber(s3[1]), tonumber(s3[2])}
		
		elseif s2[1] == "mariohats" then
			local playerno = tonumber(s2[2])
			mariohats[playerno] = {}
			
			if s2[3] == "mariohats" then --SAVING WENT WRONG OMG
			
			elseif s2[3] then
				s3 = s2[3]:split(",")
				for i = 1, #s3 do
					local hatno = tonumber(s3[i])
					--[[if hatno > hatcount then
						hatno = hatcount
					end]]
					--hats are limited later
					mariohats[playerno][i] = hatno
				end
			end
			
		elseif s2[1] == "scale" then
			if not nodefaultconfig and not android then
				scale = tonumber(s2[2])
			end
		elseif s2[1] == "letterbox" then
			if s2[2] then
				letterboxfullscreen = (s2[2] == "true")
			else
				letterboxfullscreen = true
			end
		elseif s2[1] == "shader1" then
			for i = 1, #shaderlist do
				if shaderlist[i] == s2[2] then
					currentshaderi1 = i
				end
			end
		elseif s2[1] == "shader2" then
			for i = 1, #shaderlist do
				if shaderlist[i] == s2[2] then
					currentshaderi2 = i
				end
			end
		elseif s2[1] == "volume" then
			volume = tonumber(s2[2])
			love.audio.setVolume( volume )
		elseif s2[1] == "mouseowner" then
			mouseowner = tonumber(s2[2])
		elseif s2[1] == "mappack" then
			if love.filesystem.getInfo(mappackfolder .. "/" .. s2[2] .. "/") then
				mappack = s2[2]
			else
				checkmappack = s2[2]
			end
		elseif s2[1] == "gamefinished" then
			gamefinished = true
		elseif s2[1] == "vsync" then
			vsync = true
		elseif s2[1] == "reachedworlds" then
			reachedworlds[s2[2]] = {}
			local s3 = s2[3]:split(",")
			for i = 1, #s3 do
				if tonumber(s3[i]) == 1 then
					reachedworlds[s2[2]][i] = true
				elseif #s3 > 8 then
					reachedworlds[s2[2]][i] = false
				end
			end
		elseif s2[1] == "modmappacks" then
			mappackfolder = "alesans_entities/mappacks"
			savesfolder = "alesans_entities/saves"
		elseif s2[1] == "resizable" then
			if s2[2] then
				resizable = (s2[2] == "true")
			else
				resizable = true
			end
		elseif s2[1] == "fourbythree" then
			fourbythree = true
		elseif s2[1] == "language" then
			CurrentLanguage = s2[2]
		elseif s2[1] == "localnick" then
			localnick = s2[2]
		elseif s2[1] == "mariocharacter" then
			local s3 = s2[2]:split(",")
			for i = 1, #s3 do
				if s3[i] == "false" then
					mariocharacter[i] = "mario"
				else
					mariocharacter[i] = s3[i]
				end
			end
		end
	end
	
	for i = 1, math.max(4, players) do
		if not portalhues[i] then
			break
		else
			portalcolor[i] = {getrainbowcolor(portalhues[i][1]), getrainbowcolor(portalhues[i][2])}
		end
	end
	players = 1
end


function defaultconfig()
	--------------
	-- CONTORLS --
	--------------
	
	-- Joystick stuff:
	-- joy, #, hat, #, direction (r, u, ru, etc)
	-- joy, #, axe, #, pos/neg
	-- joy, #, but, #
	-- You cannot set Hats and Axes as the jump button. Bummer.
	
	mouseowner = 1
	
	controls = {}
	
	local i = 1
	controlstable = {"left", "right", "up", "down", "run", "jump", "reload", "use", "aimx", "aimy", "portal1", "portal2", "pause"}
	controls[i] = {}
	controls[i]["right"] = {"d"}
	controls[i]["left"] = {"a"}
	controls[i]["down"] = {"s"}
	controls[i]["up"] = {"w"}
	controls[i]["run"] = {"lshift"}
	controls[i]["jump"] = {" "}
	controls[i]["aimx"] = {""} --mouse aiming, so no need
	controls[i]["aimy"] = {""}
	controls[i]["portal1"] = {""}
	controls[i]["portal2"] = {""}
	controls[i]["reload"] = {"r"}
	controls[i]["use"] = {"e"}
	controls[i]["pause"] = {""}
	
	for i = 2, 4 do
		controls[i] = {}
		controls[i]["right"] = {"joy", i-1, "hat", 1, "r"}
		controls[i]["left"] = {"joy", i-1, "hat", 1, "l"}
		controls[i]["down"] = {"joy", i-1, "hat", 1, "d"}
		controls[i]["up"] = {"joy", i-1, "hat", 1, "u"}
		controls[i]["run"] = {"joy", i-1, "but", 3}
		controls[i]["jump"] = {"joy", i-1, "but", 1}
		controls[i]["aimx"] = {"joy", i-1, "axe", 5, "neg"}
		controls[i]["aimy"] = {"joy", i-1, "axe", 4, "neg"}
		controls[i]["portal1"] = {"joy", i-1, "but", 5}
		controls[i]["portal2"] = {"joy", i-1, "but", 6}
		controls[i]["reload"] = {"joy", i-1, "but", 4}
		controls[i]["use"] = {"joy", i-1, "but", 2}
		controls[i]["pause"] = {""}
	end
	-------------------
	-- PORTAL COLORS --
	-------------------
	
	portalhues = {}
	portalcolor = {}
	for i = 1, 4 do
		local players = 4
		portalhues[i] = {(i-1)*(1/players), (i-1)*(1/players)+0.5/players}
		portalcolor[i] = {getrainbowcolor(portalhues[i][1]), getrainbowcolor(portalhues[i][2])}
	end
	
	--hats.
	mariohats = {}
	for i = 1, 4 do
		mariohats[i] = {1}
	end
	
	------------------
	-- MARIO COLORS --
	------------------
	--1: hat, pants (red)
	--2: shirt, shoes (brown-green)
	--3: skin (yellow-orange)
	
	mariocolors = {}
	mariocolors[1] = {{225,  32,   0}, {136, 112,   0}, {252, 152,  56}}
	mariocolors[2] = {{255, 255, 255}, {  0, 160,   0}, {252, 152,  56}}
	mariocolors[3] = {{  0,   0,   0}, {200,  76,  12}, {252, 188, 176}}
	mariocolors[4] = {{ 32,  56, 236}, {  0, 128, 136}, {252, 152,  56}}
	for i = 5, players do
		mariocolors[i] = mariocolors[math.random(4)]
	end

	mariocharacter = {"mario", "mario", "mario", "mario"}
	
	--options
	if android then
		scale = 1
	else
		scale = 2
	end
	resizable = true
	letterboxfullscreen = true
	volume = 1
	mappack = "smb"
	vsync = false
	mappackfolder = "mappacks"
	savesfolder = "saves"
	fourbythree = false
	localnick = false
	
	reachedworlds = {}
end

function writesuspendfile()
	local st = {}
	if marioworld == "M" then
		marioworld = 8
		mariolevel = 4
	end
	st.world = marioworld
	st.level = mariolevel
	st.coincount = mariocoincount
	st.score = marioscore
	st.players = players
	st.lives = mariolives
	st.size = {}
	st.character = {}
	st.fireenemy = {}
	st.colors = {}
	st.shoe = {}
	for i = 1, players do
		if objects["player"][i] then
			local p = objects["player"][i]
			st.size[i] = p.size
			st.character[i] = p.character
			if p.fireenemy then
				st.fireenemy[i] = p.fireenemy
				st.colors[i] = p.colors
			end
			--st.shoe[i] = p.shoe --needs to be changed for yoshi
		else
			st.size[i] = 1
		end
	end
	st.solidblockperma = solidblockperma
	--save collectables oh boy
	local c = false
	for i = 1, #collectablescount do
		if collectablescount[i] > 0 then
			c = true
			break
		end
	end
	if c then
		st.collectables = collectables
		st.collectablescount = collectablescount
	end
	st.animationnumbers = animationnumbers
	
	st.mappack = mappack
	st.mappackfolder = mappackfolder

	local s = JSON:encode_pretty(st)
	love.filesystem.write(savesfolder .. "/" .. mappack .. ".suspend", s)
end

function suspendgame()
	writesuspendfile()
	love.audio.stop()
	menu_load()
end

function continuegame()
	savefile = savesfolder .. "/" .. mappack .. ".suspend"
	if not love.filesystem.getInfo(savefile) then
		return
	end
	
	local s = love.filesystem.read(savefile)
	local st = JSON:decode(s)
	
	mariosizes = {}
	mariolives = {}
	
	marioworld = st.world
	mariolevel = st.level
	mariocoincount = st.coincount
	marioscore = st.score
	players = st.players
	if mariolivecount ~= false then
		mariolives = st.lives
	end
	mariosizes = st.size
	--mariocharacter = st.character
	for i = 1, #st.character do
		if mariocharacter[i] and st.character[i] then
			local keep_colors = false
			if mariocharacter[i] == st.character[i] then
				keep_colors = true
			end
			setcustomplayer(st.character[i], i, keep_colors)
		end
	end
	--[[for i, shoe in pairs(st.shoe) do
		marioproperties[i].shoe = shoe
	end]]
	for i, fireenemy in pairs(st.fireenemy) do
		marioproperties[i].fireenemy = fireenemy
	end

	for i, customcolors in pairs(st.colors) do
		marioproperties[i].customcolors = customcolors
	end
	mappack = st.mappack
	mappackfolder = st.mappackfolder

	loadbackground("1-1.txt")

	if solidblockperma then
		solidblockperma = st.solidblockperma
	end
	if st.collectables and st.collectablescount then
		collectables = st.collectables
		collectablescount = st.collectablescount
	end
	if st.animationnumbers then
		animationnumbers = st.animationnumbers
	end
end

function changescale(s, fullscreen)
	if android or (s == 5) then
		local window_resizable = true
		if android then
			scale = 1
			window_resizable = false
			fullscreen = true
		elseif fullscreen then
			local w, h = love.window.getDesktopDimensions()
			scale = math.max(1, math.floor(w/(width*16)))
		else
			scale = 2
		end
		resizable = true
		
		uispace = math.floor(width*16*scale/4)
		love.window.setMode(width*16*scale, 224*scale, {fullscreen=fullscreen, vsync=vsync, msaa=fsaa, resizable=window_resizable, minwidth=width*16, minheight=224, highdpi=false, usedpiscale=false}) --27x14 blocks (15 blocks actual height)
		
		gamewidth, gameheight = love.graphics.getDimensions()
		if android then
			gamewidth, gameheight = width*16, height*16
		elseif fullscreen then
			gamewidth, gameheight = width*16*scale, height*16*scale
		end
		winwidth, winheight = getWindowSize()

		canvas = love.graphics.newCanvas(width*16*scale, height*16*scale)
		canvas:setFilter("nearest", "nearest")
		
		if shaders then
			shaders:refresh()
		end
	else
		scale = s
		resizable = false
		
		if fullscreen then
			fullscreen = true
			scale = 2
			love.window.setMode(800, 600, {fullscreen=fullscreen, vsync=vsync, msaa=fsaa, highdpi=false, usedpiscale=false})
		end
		
		uispace = math.floor(width*16*scale/4)
		love.window.setMode(width*16*scale, height*16*scale, {fullscreen=fullscreen,vsync=vsync, msaa=fsaa, highdpi=false, usedpiscale=false}) --27x14 blocks (15 blocks actual height)
		
		gamewidth, gameheight = love.graphics.getDimensions()
		winwidth, winheight = getWindowSize()
		
		if shaders then
			shaders:refresh()
		end
	end
end

--resizing stuff
function love.resize(w, h)
	winwidth, winheight = w, h
	if resizable then
		if winwidth < (width*16*scale)*1.5 or winheight < (224*scale)*1.5 then
			canvas:setFilter("linear", "linear")
		else
			canvas:setFilter("nearest", "nearest")
		end
		--[[if winwidth/(width*16*scale) and winheight/(224*scale) == math.floor(winheight/(224*scale)) then
			canvas:setFilter("nearest", "nearest")
		else
			canvas:setFilter("linear", "linear")
		end]]
	end
	if shaders then
		shaders:refresh()
	end
end	

function getWindowSize(setW, setH)
	local w, h
	if fullscreen then
		w, h = love.window.getDesktopDimensions()
	else
		if setW and setH then
			w, h = setW, setH
		else
			w, h = love.graphics.getDimensions()
		end
		if DPIFix and resizable then
			local factor = DPIFix
			if not (type(DPIFix) == "number") then
				factor = 2
			end
			w, h = w*factor, h*factor
		end
	end
	return w, h
end

lgs = love.graphics.setScissor
function love.graphics.setScissor(x, y, w, h)
	if x and y and w and h then
		lgs(x, y, w, h)
	else
		lgs()
	end
end

lmx = love.mouse.getX
function love.mouse.getX()
	if android then
		local x,y = androidGetMouse()
		return x
	end
	local x = lmx()
	if resizable and letterboxfullscreen and canvas then
		local cw, ch = canvas:getWidth(), canvas:getHeight()--current size
		local tw, th = winwidth, winheight--target size
		local s
		if cw/tw > ch/th then s = tw/cw
		else s = th/ch end
		x = math.max(0, math.min(cw*s, x - ((tw*0.5)-(cw*s*0.5))))/s
	elseif resizable then
		x = x/(winwidth/gamewidth)
	end
	return x
end
lmy = love.mouse.getY
function love.mouse.getY()
	if android then
		local x,y = androidGetMouse()
		return y
	end
	local y = lmy()
	if resizable and letterboxfullscreen and canvas then
		local cw, ch = canvas:getWidth(), canvas:getHeight()--current size
		local tw, th = winwidth, winheight--target size
		local s
		if cw/tw > ch/th then s = tw/cw
		else s = th/ch end
		y = math.max(0, math.min(ch*s, y - ((th*0.5)-(ch*s*0.5))))/s
	elseif resizable then
		y = y/(winheight/gameheight)
	end
	return y
end
function love.mouse.getPosition()
	if android then
		return androidGetMouse()
	end
	local x, y = love.mouse.getX(), love.mouse.getY()
	return x, y
end

----------------

function love.keypressed(key, scancode, isrepeat, textinput)
	if key == "space" then key = " " end
	if debugconsole then
		if key == "backspace" and debuginputon then
			debuginput = debuginput:sub(1, -2)
		elseif key == "return" and debuginputon then
			func = loadstring(debuginput)
			ok, result = pcall(func) -- execute the chunk safely

			if not ok then -- will be false if there is an error
				print('The following error happened: ' .. tostring(result))
			else
				print('The result of loading is: ' .. tostring(result))
			end
		elseif key == "tab" then
			debuginputon = not debuginputon
			if debuginputon then
				love.keyboard.setKeyRepeat(true)
			else
				love.keyboard.setKeyRepeat(false)
			end
		end
		if debuginputon then
			return
		end
	end

	if jsonerrorwindow.opened then
		jsonerrorwindow:keypressed(key)
		return
	end
	
	if keyprompt then
		keypromptenter("key", key)
		return
	end

	for i, v in pairs(guielements) do
		if v:keypress(key,textinput) then
			return
		end
	end
	
	if key == "return" and love.keyboard.isDown("lalt") then
		fullscreen = not fullscreen
		winwidth, winheight = getWindowSize()
		if fullscreen then
			changescale(5, fullscreen)
		else
			changescale(scale, fullscreen)
		end
		if gamestate == "game" then
			updatespritebatch()
		end
		return
	end
	
	if key == "0" and HITBOXDEBUG then
		HITBOXDEBUGANIMS = not HITBOXDEBUGANIMS
	elseif key == "f10" then
		if android then
			--hide ui
			androidHIDE = not androidHIDE
		else
			HITBOXDEBUG = not HITBOXDEBUG
		end
	elseif key == "f11" then
		showfps = not showfps
	elseif key == "f12" then
		love.mouse.setGrabbed(not love.mouse.isGrabbed())
	end
	
	if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "lobby" or gamestate == "options" then
		--konami code
		if key == konami[konamii] or (android and key == androidkonami[konamii]) then--[[DROID]]
			konamii = konamii + 1
			if konamii == #konami+1 then
				if not konamisound:isPlaying() then
					playsound(konamisound)
				end
				gamefinished = true
				saveconfig()
				konamii = 1
				notice.new("Cheats unlocked!", notice.white, 5)
			end
		else
			konamii = 1
		end
		
		menu_keypressed(key, unicode)
	elseif gamestate == "game" then
		game_keypressed(key, textinput)
	elseif gamestate == "levelscreen" or gamestate == "gameover" then
		levelscreen_keypressed(key)
	elseif gamestate == "intro" then
		intro_keypressed()
	elseif gamestate == "filebrowser" then
		filebrowser_keypressed(key, textinput)
	end
end

function love.keyreleased(key, unicode)
	if key == "space" then key = " " end
	if gamestate == "menu" or gamestate == "options" then
		menu_keyreleased(key, unicode)
	elseif gamestate == "game" then
		game_keyreleased(key, unicode)
	elseif gamestate == "filebrowser" then
		filebrowser_keyreleased(key, unicode)
	end
end

function love.textinput(c)
	if android --[[and not androidtest]] then --[[DROID]]
		love.keypressed(c,nil,nil,"textinput")
	else
		if debugconsole and debuginputon then
			debuginput = debuginput .. c
		end
	end
end

function love.mousepressed(x, y, button, istouch)
	button = nummousebutton(button)
	if android then
		if istouch == true then
			return false
		elseif androidtest and istouch ~= "simulated" then
			love.touchpressed(1,x,y)
			return false
		end
	elseif resizable and letterboxfullscreen and canvas then
		x, y = love.mouse.getPosition()
	elseif resizable then
		x, y = x/(winwidth/gamewidth), y/(winheight/gameheight)
	end

	if jsonerrorwindow.opened then
		jsonerrorwindow:mousepressed(x, y, button)
		return
	end
	
	if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "lobby" or gamestate == "options" then
		menu_mousepressed(x, y, button)
	elseif gamestate == "game" then
		game_mousepressed(x, y, button)
	elseif gamestate == "intro" then
		intro_mousepressed()
	elseif gamestate == "filebrowser" then
		filebrowser_mousepressed(x, y, button)
	end
	
	--animations priorities
	if animationguilines and editormode and editormenuopen and (not changemapwidthmenu) and (not guielements["animationselectdrop"].extended) and editorstate == "animations" then
		local b = false
		for i, v in pairs(animationguilines) do
			for k, w in pairs(v) do
				if w:haspriority() then
					w:click(x, y, button)
					return
				end
			end
		end
		
		if x >= animationguiarea[1]*scale and y >= animationguiarea[2]*scale and x < animationguiarea[3]*scale and y < animationguiarea[4]*scale then
			addanimationtriggerbutton:click(x, y, button)
			addanimationconditionbutton:click(x, y, button)
			addanimationactionbutton:click(x, y, button)
			
			for i, v in pairs(animationguilines) do
				for k, w in pairs(v) do
					if w:click(x, y, button) then
						return
					end
				end
			end
		end
	end
	
	if ignoregui then
		ignoregui = false
		return
	end
	
	for i, v in pairs(guielements) do
		if v.priority then
			if v:click(x, y, button) then
				return
			end
		end
	end
	
	for i, v in pairs(guielements) do
		if not v.priority then
			if v:click(x, y, button) then
				return
			end
		end
	end
end

function love.mousereleased(x, y, button, istouch)
	button = nummousebutton(button)
	if android then
		if istouch == true then
			return false
		elseif androidtest and istouch ~= "simulated" then
			love.touchreleased(1,x,y)
			return false
		end
	elseif resizable and letterboxfullscreen and canvas then
		x, y = love.mouse.getPosition()
	elseif resizable then
		x, y = x/(winwidth/gamewidth), y/(winheight/gameheight)
	end

	if jsonerrorwindow.opened then
		jsonerrorwindow:mousereleased(x, y, button)
		return
	end

	if gamestate == "menu" or gamestate == "options" or gamestate == "mappackmenu" then
		menu_mousereleased(x, y, button)
	elseif gamestate == "game" then
		game_mousereleased(x, y, button)
	elseif gamestate == "filebrowser" then
		filebrowser_mousereleased(x, y, button)
	end
	
	if ignoregui then
		ignoregui = false
		return
	end
	
	for i, v in pairs(guielements) do
		v:unclick(x, y, button)
	end
end

function love.mousemoved(x, y, dx, dy, istouch)
	if android then
		if istouch == true then
			return false
		elseif androidtest and istouch ~= "simulated" then
			if love.mouse.isDown("l","notAndroid") then
				love.touchmoved(1,x,y,dx,dy)
			end
			return false
		end
	elseif resizable and letterboxfullscreen and canvas then
		x, y = love.mouse.getPosition()
		local cw, ch = canvas:getWidth(), canvas:getHeight()--current size
		local tw, th = winwidth, winheight--target size
		local s
		if cw/tw > ch/th then s = tw/cw
		else s = th/ch end
		dx, dy = dx/(s), dy/(s)
	elseif android or resizable then
		x, y = x/(winwidth/gamewidth), y/(winheight/gameheight)
		dx, dy = dx/(winwidth/gamewidth), dy/(winheight/gameheight)
	end
	if gamestate == "menu" or gamestate == "options" or gamestate == "mappackmenu" then
		menu_mousemoved(x, y, dx, dy)
	elseif gamestate == "game" then
		if editormode then
			editor_mousemoved(x, y, dx, dy)
		end
	end
end

function love.wheelmoved(x, y)
	if y > 0 then
        love.mousepressed(love.mouse.getX(), love.mouse.getY(), "wu")
    elseif y < 0 then
        love.mousepressed(love.mouse.getX(), love.mouse.getY(), "wd")
    end
end

function love.filedropped(file)
	if gamestate == "menu" or gamestate == "mappackmenu" then
		menu_filedropped(file)
	elseif gamestate == "game" and editormode then
		editor_filedropped(file)
	end
end

--really lazy 0.10.0 conversion
local oldmouse_isDown = love.mouse.isDown
function love.mouse.isDown(b,notAndroid)
	b = mousebuttonnum(b)
	if android and not notAndroid then
		return androidMouseDown(b)
	end
	return oldmouse_isDown(b)
end

local nummousebuttont = {"l", "r", "m", "x1", "x2", l = 1, r = 2, m = 3, x1 = 4, x2 = 5}
function nummousebutton(b)
	if type(b) == "number" then
		return nummousebuttont[b] or "l"
	else
		return b
	end
end

function mousebuttonnum(b)
	if type(b) == "string" then
		return nummousebuttont[b] or 1
	else
		return b
	end
end

local oldkeyboard_isDown = love.keyboard.isDown
function love.keyboard.isDown(k)
	if k == " " then
		k = "space"
	end
	return oldkeyboard_isDown(k)
end

function love.joystickpressed(joystick, button, simulated)
	local joystick = joystick
	if not simulated then
		joystick = joystick:getID()
	end
	
	if keyprompt then
		keypromptenter("joybutton", joystick, button)
		return
	end
	
	if gamestate == "menu" or gamestate == "mappackmenu" or gamestate == "onlinemenu" or gamestate == "lobby" or gamestate == "options" then
		menu_joystickpressed(joystick, button)
	elseif gamestate == "game" then
		game_joystickpressed(joystick, button)
	elseif gamestate == "levelscreen" or gamestate == "gameover" then
		levelscreen_joystickpressed(joystick, button)
	end
end

function love.joystickreleased(joystick, button, simulated)
	local joystick = joystick
	if not simulated then
		joystick = joystick:getID()
	end
	
	if gamestate == "menu" or gamestate == "options" then
		menu_joystickreleased(joystick, button)
	elseif gamestate == "game" then
		game_joystickreleased(joystick, button)
	end
end

local function getjoysticki(i)
	local joysticks = love.joystick.getJoysticks()
	return joysticks[i]
end
function love.joystick.getHatCount(i)
	return getjoysticki(i):getHatCount()
end
function love.joystick.getHat(i, h) --id, hat
	if getjoysticki(i) then
		return getjoysticki(i):getHat(h)
	else
		return "c"
	end
end
function love.joystick.getAxisCount(i)
	return getjoysticki(i):getAxisCount()
end
function love.joystick.getAxis(i, j) --id, axis
	if getjoysticki(i) and getjoysticki(i).getAxis then
		return getjoysticki(i):getAxis(j)
	else
		return 0 --workaround for annoying joystick bug
	end
end
function love.joystickadded(joystick)
	if android and notice then
		if joystick:isGamepad() then
			local gamepadName = joystick:getName()
			if gamepadName then
				notice.new(string.format("%s connected!", gamepadName), notice.white)
			else
				notice.new(string.format("Unknown gamepad connected!", gamepadName), notice.white)
			end
		end
	end
end
function love.joystick.isDown(i, b)
	if getjoysticki(i) then
		return getjoysticki(i):isDown(b)
	else
		return false
	end
end

function round(num, idp) --Not by me
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function getrainbowcolor(i)
	local whiteness = 255
	local r, g, b
	if i < 1/6 then
		r = 1
		g = i*6
		b = 0
	elseif i >= 1/6 and i < 2/6 then
		r = (1/6-(i-1/6))*6
		g = 1
		b = 0
	elseif i >= 2/6 and i < 3/6 then
		r = 0
		g = 1
		b = (i-2/6)*6
	elseif i >= 3/6 and i < 4/6 then
		r = 0
		g = (1/6-(i-3/6))*6
		b = 1
	elseif i >= 4/6 and i < 5/6 then
		r = (i-4/6)*6
		g = 0
		b = 1
	else
		r = 1
		g = 0
		b = (1/6-(i-5/6))*6
	end
	
	return {round(r*whiteness), round(g*whiteness), round(b*whiteness), 255}
end

function newRecoloredImage(path, tablein, tableout)
	local minalpha = 128
	local imagedata = love.image.newImageData( path )
	local width, height = imagedata:getWidth(), imagedata:getHeight()
	
	for y = 0, height-1 do
		for x = 0, width-1 do
			local oldr, oldg, oldb, olda = imagedata:getPixel(x, y)
			
			if olda > minalpha then
				for i = 1, #tablein do
					if oldr == tablein[i][1] and oldg == tablein[i][2] and oldb == tablein[i][3] then
						local r, g, b = unpack(tableout[i])
						imagedata:setPixel(x, y, r, g, b, olda)
					end
				end
			end
		end
	end
	
	return love.graphics.newImage(imagedata)
end

function string:split(d)
	local data = {}
	local from, to = 1, string.find(self, d)
	while to do
		table.insert(data, string.sub(self, from, to-1))
		from = to+d:len()
		to = string.find(self, d, from)
	end
	table.insert(data, string.sub(self, from))
	return data
end

function tablecontains(t, entry)
	for i, v in pairs(t) do
		if v == entry then
			return true
		end
	end
	return false
end

function tablecontainsi(t, entry)
	for i, v in pairs(t) do
		if v == entry then
			return i
		end
	end
	return false
end

function tablecontainsistring(t, entry)
	for i, v in pairs(t) do
		if tostring(v) == entry then
			return i
		end
	end
	return false
end

function getaveragecolor(imgdata, cox, coy)
	local minalpha = 127
	local xstart = (cox-1)*17
	local ystart = (coy-1)*17
	
	local r, g, b = 0, 0, 0
	
	local count = 0
	
	for x = xstart, xstart+15 do
		for y = ystart, ystart+15 do
			local pr, pg, pb, a = imgdata:getPixel(x, y)
			if a > minalpha then
				r, g, b = r+pr, g+pg, b+pb
				count = count + 1
			end
		end
	end
	
	r, g, b = r/count, g/count, b/count
	
	return r, g, b
end

function getaveragecolor2(imgdata, cox, coy)
	local minalpha = 127
	local xstart = (cox-1)*16
	local ystart = (coy-1)*16
	if imgdata:getHeight() > 16 then
		xstart = (cox-1)*17
		ystart = (coy-1)*17
	end
	
	local r, g, b = 0, 0, 0
	
	local count = 0
	
	for x = xstart, xstart+15 do
		for y = ystart, ystart+15 do
			local pr, pg, pb, a = imgdata:getPixel(x, y)
			if a > minalpha then
				r, g, b = r+pr, g+pg, b+pb
				count = count + 1
			end
		end
	end
	
	r, g, b = r/count, g/count, b/count
	
	return r, g, b
end

function keyprompt_update()
	if keyprompt then
		for i = 1, prompt.joysticks do
			for j = 1, #prompt.joystick[i].validhats do
				local dir = love.joystick.getHat(i, prompt.joystick[i].validhats[j])
				if dir ~= "c" then
					keypromptenter("joyhat", i, prompt.joystick[i].validhats[j], dir)
					return
				end
			end
			
			for j = 1, prompt.joystick[i].axes do
				local value = love.joystick.getAxis(i, j)
				if value > prompt.joystick[i].axisposition[j] + joystickdeadzone then
					keypromptenter("joyaxis", i, j, "pos")
					return
				elseif value < prompt.joystick[i].axisposition[j] - joystickdeadzone then
					keypromptenter("joyaxis", i, j, "neg")
					return
				end
			end
		end
	end
end

function print_r (t, indent) --Not by me
	local indent=indent or ''
	for key,value in pairs(t) do
		io.write(indent,'[',tostring(key),']') 
		if type(value)=="table" then io.write(':\n') print_r(value,indent..'\t')
		else io.write(' = ',tostring(value),'\n') end
	end
end

function love.focus(f)
	if (not f) and gamestate == "game"and (not editormode) and (not testlevel) and (not levelfinished) and (not everyonedead) and (not CLIENT) and (not SERVER) and (not dontPauseOnUnfocus) then
		pausemenuopen = true
		pausedaudio = love.audio.pause()
	end
end

function openSaveFolder(subfolder) --By Slime
	if android then
		notice.new("On android try a file manager\nand go to:\nAndroid > data > Love.to.mario", notice.white, 5)
		filebrowser_load(subfolder or "")
		return true
	end

	local path = love.filesystem.getSaveDirectory()
	path = subfolder and path.."/"..subfolder or path
	
	local cmdstr
	local successval = 0
	
	if os.getenv("WINDIR") then -- lolwindows
		--cmdstr = "Explorer /root,%s"
		if path:match("LOVE") then --hardcoded to fix ISO characters in usernames and made sure release mode doesn't mess anything up -saso
			cmdstr = "Explorer %%appdata%%\\LOVE\\mari0"
		else
			cmdstr = "Explorer %%appdata%%\\mari0"
		end
		path = path:gsub("/", "\\")
		successval = 1
	elseif os.getenv("HOME") then
		if path:match("/Library/Application Support") then -- OSX
			cmdstr = "open \"%s\""
		else -- linux?
			cmdstr = "xdg-open \"%s\""
		end
	end
	
	-- returns true if successfully opened folder
	return cmdstr and os.execute(cmdstr:format(path)) == successval
end

function getupdate()
	local onlinedata, code = http.request("http://server.stabyourself.net/mari0/?mode=mappacks")
	
	if code ~= 200 then
		return false
	elseif not onlinedata then
		return false
	end
	
	local latestversion
	
	local split1 = onlinedata:split("<")
	for i = 2, #split1 do
		local split2 = split1[i]:split(">")
		if split2[1] == "latestversion" then
			latestversion = tonumber(split2[2])
		end
	end
	
	if latestversion and latestversion > marioversion then
		return true
	end
	return false
end

--TTF Printing
function properprintfast(s, x, y, size)
	if s == nil then
		return
	end
	local size = size or 1
	--use with emulogic or any 8x8 font
	love.graphics.setFont(font)
	love.graphics.print(s, x, y-scale, 0, size*scale, size*scale)
end
function properprintfastbackground(s, x, y, size)
	--outlines
	if s == nil then
		return
	end
	local size = size or 1
	love.graphics.setFont(fontback)
	love.graphics.print(s, x, y-scale, 0, size*scale, size*scale)
	love.graphics.setFont(font)
	love.graphics.print(s, x, y-scale, 0, size*scale, size*scale)
end
function properprintfastf(s, x, y, w, size) --word wrap
	if s == nil then
		return
	end
	local size = size or 1
	love.graphics.setFont(font)
	love.graphics.printf(s, x, y-scale, w, "left", 0, size*scale, size*scale)
end
function properprintFast(s, x, y, size)
	--CAPITALS
	if s == nil then
		return
	end
	local size = size or 1
	love.graphics.setFont(fontCAP)
	love.graphics.print(s, x, y-scale, 0, size*scale, size*scale)
end
function properprintFastbackground(s, x, y, size)
	if s == nil then
		return
	end
	local size = size or 1
	love.graphics.setFont(fontbackCAP)
	love.graphics.print(s, x, y-scale, 0, size*scale, size*scale)
	love.graphics.setFont(fontCAP)
	love.graphics.print(s, x, y-scale, 0, size*scale, size*scale)
end
--UTF-8 Printing
function properprintf(s, x, y, size)
	--UTF-8
	if s then
		local size = size or 1
		local startx = x
		for i, char, b in utf8.chars(tostring(s)) do
			if char == " " then
			elseif char == "\n" then
				x = startx-((i)*(8*size))*scale
				y = y + (10*size)*scale
			elseif fontquads[char] then
				love.graphics.draw(fontimage, fontquads[char], x+((i-1)*(8*size))*scale, y, 0, size*scale, size*scale)
			end
		end
	end
end
function properprintfbackground(s, x, y, include, color, size)
	--UTF-8 outline
	if s then
		local size = size or 1
		local startx, starty = x, y
		for i, char, b in utf8.chars(tostring(s)) do
			if char == " " then
			elseif char == "\n" then
				x = startx-((i)*(8*size))*scale
				y = y + (10*size)*scale
			elseif fontquadsback[char] then
				love.graphics.draw(fontbackimage, fontquadsback[char], x+((i-1)*(8*size)-1*size)*scale, y-(1*size)*scale, 0, size*scale, size*scale)
			end
		end
		
		if include ~= false then
			if color then
				love.graphics.setColor(color)
			end
			properprintf(s, startx, starty, size)
		end
	end
end
function properprintF(s, x, y, size)
	--UTF-8 CAPITALS
	if s then
		local size = size or 1
		local startx = x
		for i, char, b in utf8.chars(tostring(s)) do
			if char == " " then
			elseif char == "\n" then
				x = startx-((i)*(8*size))*scale
				y = y + (10*size)*scale
			elseif fontquads[char] then
				love.graphics.draw(fontimage, fontquads[fontindexCAP[char]], x+((i-1)*(8*size))*scale, y, 0, size*scale, size*scale)
			end
		end
	end
end
function properprintFbackground(s, x, y, include, color, size)
	--UTF-8 CAPITALS OUTLINE
	if s then
		local size = size or 1
		local startx, starty = x, y
		for i, char, b in utf8.chars(tostring(s)) do
			if char == " " then
			elseif char == "\n" then
				x = startx-((i)*(8*size))*scale
				y = y + (10*size)*scale
			elseif fontquadsback[char] then
				love.graphics.draw(fontbackimage, fontquadsback[fontindexCAP[char]], x+((i-1)*(8*size)-1*size)*scale, y-(1*size)*scale, 0, size*scale, size*scale)
			end
		end
		
		if include ~= false then
			if color then
				love.graphics.setColor(color)
			end
			properprintF(s, startx, starty, size)
		end
	end
end
--Normal Mari0 Printing (no utf-8, Capitals may be displayed as a special character)
function properprint(s, x, y, size)
	if s == nil then
		return
	end
	local size = size or 1
	s = tostring(s)
	local startx = x
	for i = 1, string.len(s) do
		local char = string.sub(s, i, i)
		if char == " " then
		elseif char == "\n" then
			x = startx-((i)*(8*size))*scale
			y = y + (10*size)*scale
		elseif fontquads[char] then
			love.graphics.draw(fontimage, fontquads[fontindexOLD[char]], x+((i-1)*(8*size))*scale, y, 0, size*scale, size*scale)
		end
	end
end
function properprintbackground(s, x, y, include, color, size)
	local size = size or 1
	local startx, starty = x, y
	local skip = 0
	for i = 1, string.len(tostring(s)) do
		if skip > 0 then
			skip = skip - 1
		else
			local char = string.sub(s, i, i)
			if char == " " then
			elseif char == "\n" then
				x = startx-((i)*(8*size))*scale
				y = y + (10*size)*scale
			elseif fontquadsback[char] then
				love.graphics.draw(fontbackimage, fontquadsback[fontindexOLD[char]], x+((i-1)*(8*size)-1*size)*scale, y-(1*size)*scale, 0, size*scale, size*scale)
			end
		end
	end
	
	if include ~= false then
		if color then
			love.graphics.setColor(color)
		end
		properprint(s, startx, starty, size)
	end
end

local function error_printer(msg, layer)
    print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errorhandler(msg)
    msg = tostring(msg)

    error_printer(msg, 2)

    if not love.window or not love.graphics or not love.event then
        return
    end
	
	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	local screenshot = false
	if love.graphics.captureScreenshot then
		love.graphics.captureScreenshot(function(s) screenshot = love.graphics.newImage(s) end)
	end

    -- Load.
    if love.audio then love.audio.stop() end
    love.graphics.reset()
	love.graphics.setBackgroundColor(0, 0, 0)
	local fontscale = scale or 2
	if not font then
		font = love.graphics.newFont(8*scale)
		fontscale = 1
	end
	love.graphics.setFont(font)

    love.graphics.setColor(255, 255, 255, 255)

    local trace = debug.traceback()

    love.graphics.clear()

	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)

	local err = {}
	local traceback = {}

	table.insert(err, "Error\n")
	table.insert(err, sanitizedmsg.."\n\n")

	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end

    for l in string.gmatch(trace, "(.-)\n") do
        if not string.match(l, "boot.lua") then
            l = string.gsub(l, "stack traceback:", "Traceback [" .. VERSION .. "]\n")
            table.insert(traceback, l)
        end
    end
	
    local p = table.concat(err, "\n")
    local p2 = table.concat(traceback, "\n")
	
    p = string.gsub(p, "\t", "")
    p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

    p2 = string.gsub(p2, "\t", "")
	p2 = string.gsub(p2, "%[string \"(.-)\"%]", "%1")
	p2 = p2 .. "\n\nCrash saved in\nalesans_entities\\crashes"
	
	if love.filesystem and love.filesystem.createDirectory and love.filesystem.write and love.filesystem.getDirectoryItems and love.filesystem.remove then
		love.filesystem.createDirectory("alesans_entities/crashes")
		local items = love.filesystem.getDirectoryItems("alesans_entities/crashes") or {}
		if #items >= 10 then
			for i = 1, #items do
				love.filesystem.remove("alesans_entities/crashes/" .. items[i])
			end
			items = love.filesystem.getDirectoryItems("alesans_entities/crashes")
		end
		local s = ""
		for j, w in pairs(err) do
			s = s .. w .. "\r\n"
		end
		for j, w in pairs(traceback) do
			s = s .. w .. "\r\n"
		end
		if VERSION then
			s = s .. "version: " .. VERSION
		end
		love.filesystem.write("alesans_entities/crashes/" .. #items+1 .. ".txt", s)
	end
	
    local function draw()
		if not love.graphics.isActive() then return end
		love.graphics.clear(love.graphics.getBackgroundColor())
		if screenshot then
			love.graphics.setColor(30, 30, 30)
			love.graphics.draw(screenshot, 0, 0, 0, love.graphics.getWidth()/screenshot:getWidth(), love.graphics.getHeight()/screenshot:getHeight())
			if gradientimg and width and height then
			 	love.graphics.setColor(0, 0, 0)
			 	love.graphics.draw(gradientimg, 0, 0, 0, love.graphics.getWidth()/(width*16), love.graphics.getHeight()/(height*16))
			end
		end
		love.graphics.setColor(255, 255, 255)
		love.graphics.printf({{255,255,255,255},p,{255,255,255,100},p2}, 10, 10, (love.graphics.getWidth() - 10)/fontscale, nil, 0, fontscale, fontscale)
		love.graphics.print("Mari0 AE Version " .. VERSIONSTRING, love.graphics.getWidth() - font:getWidth("Mari0 AE Version " .. VERSIONSTRING)*fontscale - 5*scale, love.graphics.getHeight() - 15*scale, 0, fontscale, fontscale)
		love.graphics.present()
    end
	
    draw()
	
	local e, a, b, c
	
	return function()
		love.event.pump()
 
		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return 1
				elseif pressed == 3 then
					copyToClipboard()
				end
			end
		end
 
		draw()
 
		if love.timer then
			love.timer.sleep(0.1)
		end
	end
end

function love.quit()
    if CLIENT or SERVER then
		net_quit()
	end
    return false
end


function loadnitpicks()
	--shit i don't want to add
	--if people complain about stuff they can use this
	nitpicks = false
	if love.filesystem.getInfo("alesans_entities/nitpicks.json") then
		local data = love.filesystem.read("alesans_entities/nitpicks.json")
		t = JSON:decode(data or "")
		--CASE INSENSITVE THING
		for i, v in pairs(t) do
			t[i:lower()] = v
		end

		ForceDropShadow = t.dropshadow or t.forcedropshadow
		AutoAssistMode = t.assistmode
		--also available in settings.txt
		if t.fourbythree then
			fourbythree = true
			if fourbythree then	width = 16 else width = 25 end
			if scale == 2 and resizable then changescale(5, fullscreen)
			else changescale(scale, fullscreen) end
		end
		if t.windowwidth and t.windowheight then
			width = t.windowwidth
			height = t.windowheight
			maxtilespritebatchsprites = math.max(maxtilespritebatchsprites,width*height+width+height+1)
			if scale == 2 and resizable then changescale(5, fullscreen)
			else changescale(scale, fullscreen) end
		end
		PlayMusicInEditor = t.playmusicineditor
		DisableToolTips = t.disabletooltips
		DisableMouseInMainMenu = t.disablemouseinmainmenu
		if t.noportalgun then
			playertypei = 5
			playertype = playertypelist[playertypei]
		end
		if t.mariomakergravity then
			maxyspeed = smbmaxyspeed --SMB: 14
			mari0maxyspeed = maxyspeed
		end
		DontPauseOnUnfocus = t.dontpauseonunfocus
		FireButtonCannonHelmet = t.firebuttoncannonhelmet
		PipesInEditor = t.pipesineditor
		NoOnlineMultiplayerNames = t.noonlinemultiplayernames
		if t.letterbox ~= nil then
			letterboxfullscreen = t.letterbox --mouse inputs will be in the wrong place!
		end
		CustomPortalColors = t.customportalcolors
		UseButtonCappy = t.usebuttoncappy
		local oldfamilyfriendly = FamilyFriendly
		FamilyFriendly = t.familyfriendly or t.ilovefamilyguy
		if FamilyFriendly then
			love.filesystem.write("alesans_entities/familyfriendly.txt","")
		elseif oldfamilyfriendly then
			love.filesystem.remove("alesans_entities/familyfriendly.txt")
		end
		if t.showfps then
			showfps = t.showfps
		end
		InfiniteLivesMultiplayer = t.infinitelivesmultiplayer
		SlowBackgrounds = t.slowbackgrounds
		NoCharacterZipNotices = t.nocharacterzipnotices
		NoMusic = t.nomusic
		EditorZoom = t.editorzoom
		DirectDLCDownloads = t.directdlcdownloads
		CenterCamera = t.centercamera
		_3DMODE = t.render3d
		HITBOXDEBUG = t.viewhitboxes
		if t.pcversion then
			android = false
			androidsafe = true
		end
		if t.hideandroidbuttons then
			androidHIDE = true
		end
		if t.androidversion then
			android = t.androidversion
			androidtest = true
			changescale(scale, fullscreen)
		end
		if t.debugGraphs then
			debugGraphs = t.debugGraphs
		end
		if t.console then
			LoveConsole = true
			if love._openConsole then love._openConsole() end
		end
		NoExitConfirmation = t.noexitconfirmation
		PersistentEditorTools = true
		if t.persistenteditortools == false then
			PersistentEditorTools = false
		end
		PersistentEditorToolsLocal = t.persistenteditortoolslocal
		DPIFix = t.dpifix
	end
end

function disablecheats()
	playertype = "portal"
	playertypei = 1
	bullettime = false
	speedtarget = 1
	portalknockback = false
	bigmario = false
	goombaattack = false
	sonicrainboom = false
	playercollisions = false
	infinitetime = false
	infinitelives = false
	darkmode = false
end

function convertoldsuspendfile()
	local s = love.filesystem.read("suspend")
	local st = JSON:decode(s)

	-- *ahem* sus. [crowd cheering]
	local suspendedmappackfolder = st.mappackfolder
	local suspendedmappack = st.mappack
	love.filesystem.write(suspendedmappackfolder:gsub("mappacks", "saves") .. "/" .. suspendedmappack .. ".suspend", s)
	love.filesystem.remove("suspend")
end

--sausage (don't ask)
function dothesausage(i)
	if i then
		if i == 1 and sausagesound then
			titleimage = love.graphics.newImage("graphics/" .. graphicspack .. "/nippon/title.png")
			goombaimage = love.graphics.newImage("graphics/" .. graphicspack .. "/nippon/goomba.png")
			goombaimageframes = math.floor(goombaimage:getWidth()/16)
			goombaquad = {}
			for y = 1, 4 do
				goombaquad[y] = {}
				for x = 1, goombaimageframes do
					goombaquad[y][x] = love.graphics.newQuad((x-1)*16, (y-1)*16, 16, 16, goombaimage:getWidth(), 64)
				end
			end
			plantimg = love.graphics.newImage("graphics/" .. graphicspack .. "/nippon/plant.png")
			axeimg = love.graphics.newImage("graphics/" .. graphicspack .. "/nippon/axe.png")
			castleflagimg = love.graphics.newImage("graphics/" .. graphicspack .. "/nippon/castleflag.png")
			peachimg = love.graphics.newImage("graphics/" .. graphicspack .. "/nippon/peach.png")
			toadimg = love.graphics.newImage("graphics/" .. graphicspack .. "/nippon/toad.png")
			starimg = love.graphics.newImage("graphics/" .. graphicspack .. "/nippon/star.png")
			love.graphics.setBackgroundColor(0, 0, 0)
		end
	else
		if sausagesound then
			playsound(sausagesound)
			sausagesound = nil
		end
	end
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
