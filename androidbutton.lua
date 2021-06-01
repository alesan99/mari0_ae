touchButton = class:new()

function touchButton:init(i,x,y,w,h)
	self.i = i or "run"
	self.key = false
	self.mousebut = false
	self.held = false
	self.touch = false

	self.round = false
	self.text = false

	self.active = true

	self.x = x
	self.y = y
	self.w = w
	self.h = h
end

function touchButton:draw()
	if self.active then
		love.graphics.setLineWidth(1)
		if self.held then
			love.graphics.setColor(100, 100, 100, 140)
		else
			love.graphics.setColor(30, 30, 30, 80)
		end
		if self.round then
			local x, y, r = self.x+self.w/2, self.y+self.h/2,self.w/2
			love.graphics.circle("fill", x, y, r, 8)
			love.graphics.setColor(255, 255, 255, 140)
			love.graphics.circle("line", x, y, r, 8)
		else
			local x, y, w, h = self.x, self.y, self.w, self.h
			love.graphics.rectangle("fill", x, y, w, h)
			love.graphics.setColor(255, 255, 255, 100)
			love.graphics.rectangle("line", x+.5, y+.5, w, h)
		end

		if self.text then
			properprintfast(self.text, math.floor(self.x+self.w/2-string.len(self.text)*4), math.floor(self.y+self.h/2-4))
		end
	end
end

function touchButton:update(dt)
	self.active = ((not editormode) or ((not editormenuopen) and (not HIDEANDROIDBUTTONS)))
end

function touchButton:over(x,y)
	if x > self.x and x < self.x+self.w and y > self.y and y < self.y+self.h then
		return true
	end
	return false
end

function touchButton:testPress(x,y)
	if self.active and self:over(x,y) then
		self:press()
	end
end
function touchButton:testRelease(x,y)
	if self.active and self:over(x,y) then
		self:release()
	end
end

function touchButton:press()
	if not self.held then
		self.held = true

		if self.key then
			love.keypressed(self.key)
		end
		if self.mousebut then
			love.mousepressed(self.mousebut)
		end
	end
end

function touchButton:release()
	if self.held then
		self.held = false
	end
end

--[[--[DROID]
--ANDROID STUFF
local mousetx = 0
local mousety = 0
local mouseid = false

if android then
	androidbuttons = {
		["jump"] = {346, 169, 395, 219},
		["run"] = {292, 169, 342, 219},
		["start"] = {352, 5, 395, 21},
		["left"] = {5+5, 159, 35+5, 189},
		["right"] = {65+5, 159, 95+5, 189},
		["up"] = {35+5, 129, 65+5, 159},
		["down"] = {35+5, 189, 65+5, 219},
		["runlock"] = {267, 194, 267+25, 194+25}
	}
	aeditorbuttonsw = 24
	aeditorbuttons = {
		{function() HIDEANDROIDBUTTONS = not HIDEANDROIDBUTTONS end},
		{function() editentities = false
			currenttile = 1 end},
		{function() editentities = true
			currenttile = 1 end},
		{function() ANDROIDRIGHTCLICK = not ANDROIDRIGHTCLICK end},
		{function() backgroundtilemode = not backgroundtilemode end},
	}

	function getandroidbutton(x, y)
		for i, b in pairs(androidbuttons) do
			if x > b[1] and y > b[2] and x < b[3] and y < b[4] then
				return i
			end
		end
		if editormode and (not editormenuopen) then
			local i2 = #aeditorbuttons
			local bx, by = 2, 2
			if HIDEANDROIDBUTTONS then i2 = 1 end
			for i = 1, i2 do
				if x > bx and x < bx+aeditorbuttonsw and y > by and y < by+aeditorbuttonsw then
					return i
				end
				bx = bx + aeditorbuttonsw + 2
			end
		end
		return false
	end

	function love.keyboard.isDown(k)
		if k == "space" then k = " " end
		if k == controls[1]["run"][1] and touchrunlock then
			return true
		end
		return touchkey[k] or false
	end
	
	function love.touchpressed(id, x, y, dx, dy, pressure)
		local ox, oy = x, y
		x, y = x/(winwidth/gamewidth), y/(winheight/gameheight)

		local button = getandroidbutton(x, y)
		if button == "jump" and ((not editormode) or ((not editormenuopen) and (not HIDEANDROIDBUTTONS))) then --a
			love.keypressed(controls[1]["jump"][1])
			touchkey[controls[1]["jump"][1] ] = id
			return true
		elseif button == "run" and ((not editormode) or ((not editormenuopen) and (not HIDEANDROIDBUTTONS))) then--b
			love.keypressed(controls[1]["run"][1])
			touchkey[controls[1]["run"][1] ] = id
			if gamestate == "game" then
				love.keypressed(controls[1]["use"][1])
				touchkey[controls[1]["use"][1] ] = id
			end
			return true
		elseif button == "start" then--start
			if gamestate == "game" or gamestate == "options" or gamestate == "mappackmenu" or gamestate == "onlinemenu" then
				love.keypressed("escape")
				touchkey["escape"] = id
			else
				love.keypressed("return")
				touchkey["return"] = id
			end
			return true
		end
		if button == "left" and ((not editormode) or ((not editormenuopen) and (not HIDEANDROIDBUTTONS))) then--left
			love.keypressed(controls[1]["left"][1])
			touchkey[controls[1]["left"][1] ] = id
			return true
		elseif button == "right" and ((not editormode) or ((not editormenuopen) and (not HIDEANDROIDBUTTONS))) then--right
			love.keypressed(controls[1]["right"][1])
			touchkey[controls[1]["right"][1] ] = id
			return true
		elseif button == "up" and ((not editormode) or ((not editormenuopen) and (not HIDEANDROIDBUTTONS))) then--up
			love.keypressed(controls[1]["up"][1])
			touchkey[controls[1]["up"][1] ] = id
			return true
		elseif button == "down" and ((not editormode) or ((not editormenuopen) and (not HIDEANDROIDBUTTONS))) then --down
			love.keypressed(controls[1]["down"][1])
			touchkey[controls[1]["down"][1] ] = id
			return true
		end
		if gamestate == "game" and (not editormode) and objects and objects["player"][1] and objects["player"][1].portalgun then
			for i = 1, 3 do
				if x > 6 and y > 73+27*(i-1) and x < 6+25 and y < 73+25+27*(i-1) then --shoot portal
					if i == 1 then
						love.keypressed(controls[1]["reload"][1])
						touchkey[controls[1]["reload"][1] ] = id
					elseif i == 2 then
						game_mousepressed(x, y, "r")
					elseif i == 3 then
						game_mousepressed(x, y, "l")
					end
					return true
				end
			end
		end
		if gamestate == "game" and button == "runlock" then
			touchrunlock = not touchrunlock
			return true
		end
		if editormode and (not editormenuopen) then
			local i2 = #aeditorbuttons
			local bx, by = 2, 2
			if HIDEANDROIDBUTTONS then i2 = 1 end
			for i = 1, i2 do
				if x > bx and x < bx+aeditorbuttonsw and y > by and y < by+aeditorbuttonsw then
					aeditorbuttons[i][1]()
					return true
				end
				bx = bx + aeditorbuttonsw + 2
			end
		end
		
		--rightclick
		if editormode and (not editormenuopen) and ((not rightclickmenuopen) or (customrcopen and customrcopen == "trackpath")) and ANDROIDRIGHTCLICK then--love.keyboard.isDown(controls[1]["run"][1]) then
			mousetx = ox
			mousety = oy
			editor_mousepressed(x, y, "r")
			return true
		end
		
		mousetx = ox
		mousety = oy
		mouseid = id
	end

	function love.touchmoved(id, x, y, dx, dy, pressure)
		if mouseid == id then
			mousetx = x
			mousety = y
		end
		--slide finger to different button
		local ax, ay = x/(winwidth/gamewidth), y/(winheight/gameheight)
		local but = getandroidbutton(ax, ay)
		if but and controls[1][but] and not touchkey[controls[1][but][1] ] then
			love.touchreleased(id, x, y, dx, dy, pressure)
			love.touchpressed(id, x, y, dx, dy, pressure)
		end
	end

	function love.touchreleased(id, x, y, dx, dy, pressure)
		--find and release button
		for key, touchid in pairs(touchkey) do
			if id == touchid then
				love.keyreleased(key)
				touchkey[key] = false
				if key == controls[1]["run"][1] and gamestate == "game" then
					love.keypressed(controls[1]["use"][1])
					touchkey[controls[1]["use"][1] ] = false
				end
				return true
			end
		end
		if mouseid == id then
			mousetx = x
			mousety = y
			mouseid = false
		end
	end

	if (not androidtest) then
		--these may be causing issues with touching, TODO?
		lmx = love.mouse.getX
		function love.mouse.getX()
			if resizable and letterboxfullscreen then
				local cw, ch = gamewidth, gameheight--current size
				local tw, th = winwidth, winheight--target size
				local s
				if cw/tw > ch/th then s = tw/cw
				else s = th/ch end
				return math.max(0, math.min(cw*s, mousetx - ((tw*0.5)-(cw*s*0.5))))/s
			else
				return mousetx/(winwidth/gamewidth)
			end
		end
		lmy = love.mouse.getY
		function love.mouse.getY()
			if resizable and letterboxfullscreen then
				local cw, ch = gamewidth, gameheight--current size
				local tw, th = winwidth, winheight--target size
				local s
				if cw/tw > ch/th then s = tw/cw
				else s = th/ch end
				return math.max(0, math.min(ch*s, mousety - ((th*0.5)-(ch*s*0.5))))/s
			else
				return mousety/(winheight/gameheight)
			end
		end

		function love.mouse.isDown(button)
			local target = "l"
			if ANDROIDRIGHTCLICK then--love.keyboard.isDown(controls[1]["run"][1]) then
				target = "r"
			end
			return (button == target and mouseid)
		end
		function love.mouse.getPosition()
			local x, y = love.mouse.getX(), love.mouse.getY()
			return x, y
		end
	end
	function love.textinput(c)
		love.keypressed(c)
	end
end]]