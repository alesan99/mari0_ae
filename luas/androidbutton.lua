touchButton = class:new()

function touchButton:init(i,t,x,y,w,h,round)
	--Function
	self.player = 1
	self.i = i or "run"
	if self.i == "l" or self.i == "r" then
		self.mousebut = true
	elseif type(self.i) == "string" then
		self.key = true
	else
		self.func = true
	end

	self.held = false
	self.ti = false
	self.touch = false

	self.autoscrollGone = false

	--Appearance
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.round = round
	if self.round then
		self.r = self.w/2
	end
	self.text = t
	if type(t) == "table" then
		self.text = false
		self.img = t[1]
		self.q = t[2]
	end

	--Active conditions
	self.active = true
	self.editor = false
	self.portal = false
	self.alwaysactive = false
end

function touchButton:draw(spriteBatch, quad)
	if self.active then
		local highlight = (self.highlightFunc and self.highlightFunc())
		--Skin
		if spriteBatch then
			local x, y, w, h = quad[1]:getViewport()
			if self.held then
				spriteBatch:add(quad[2], self.x, self.y, 0, self.w/w, self.h/h)
			else
				spriteBatch:add(quad[1], self.x, self.y, 0, self.w/w, self.h/h)
			end
			
			if highlight then
				spriteBatch:add(quad[3], self.x, self.y, 0, self.w/w, self.h/h)
			end
		--No Skin, use realtime shapes
		else
			if highlight then
				love.graphics.setLineWidth(2)
			else
				love.graphics.setLineWidth(1)
			end
			if self.held then
				love.graphics.setColor(100, 100, 100, 140)
			elseif highlight then
				love.graphics.setColor(90, 90, 90, 140)
			elseif self.color then
				love.graphics.setColor(self.color[1], self.color[2], self.color[3], 80)
			else
				love.graphics.setColor(30, 30, 30, 80)
			end
			if self.round then
				local x, y, r = self.x+self.w/2, self.y+self.h/2,self.r
				love.graphics.circle("fill", x, y, r, 8)
				love.graphics.setColor(255, 255, 255, 140)
				love.graphics.circle("line", x, y, r, 8)
			else
				local x, y, w, h = self.x, self.y, self.w, self.h
				love.graphics.rectangle("fill", x, y, w, h)
				love.graphics.setColor(255, 255, 255, 140)
				love.graphics.rectangle("line", x+.5, y+.5, w, h)
			end

			love.graphics.setColor(255, 255, 255)
			if self.text then
				properprintfast(self.text, math.floor(self.x+self.w/2-string.len(self.text)*4), math.floor(self.y+self.h/2-4))
			elseif self.img then
				love.graphics.draw(self.img,self.q,self.x,self.y)
			end
		end
	end
end

function touchButton:postDraw()
	if self.active then
		--Skin
		if self.text and self.drawText then
			properprintfast(self.text, math.floor(self.x+self.w/2-string.len(self.text)*4), math.floor(self.y+self.h/2-4))
		elseif self.img then
			love.graphics.draw(self.img,self.q,self.x,self.y)
		end
	end
end

function touchButton:update(dt)
	--Check if it should be active
	if self.hide or jsonerrorwindow.opened then
		self.active = false
	elseif self.editor then
		self.active = editormode and (not editormenuopen) and ((not HIDEANDROIDBUTTONS) or self.hideButton) and ((not self.editorTool) or ANDROIDSHOWTOOLS)
	elseif self.portal then
		if objects and objects["player"] and objects["player"][self.player].portalgun then
			self.active = ((not editormode) or (((not editormenuopen) and editorstate == "portalgun") and (not HIDEANDROIDBUTTONS)))
		else
			self.active = false
		end
	elseif self.i == "runlock" then
		self.active = (gamestate == "game") and ((not editormode) or (not editormenuopen) and (autoscroll and (not HIDEANDROIDBUTTONS)))
	else
		self.active = ((not editormode) or ((not editormenuopen) and (not (self.autoscrollGone and (not autoscroll))) and (not HIDEANDROIDBUTTONS)) or self.i == "start")
			and (not (self.gameOnly and gamestate ~= "game"))
			and (not (self.multiplayerOnly and (players <= 1 or (SERVER or CLIENT) or players < self.playeri)))
			and (gamestate ~= "filebrowser")
	end
end

function touchButton:over(x,y)
	if x > self.x and x < self.x+self.w and y > self.y and y < self.y+self.h then
		return true
	end
	return false
end

function touchButton:testPress(id,x,y)
	if self.active and self:over(x,y) then
		return self:press(id,x,y)
	end
end
function touchButton:testRelease(id,x,y)
	if self.active and self.id == id then
		return self:release(id,x,y)
	end
end

function touchButton:press(id,x,y)
	if (not self.held) then
		self.held = true
		self.id = id

		if self.key then
			if self.i == "start" then
				if gamestate == "game" or gamestate == "options" or gamestate == "mappackmenu" or gamestate == "onlinemenu" then
					love.keypressed("escape")
				else
					love.keypressed("return")
				end
			elseif self.i == "runlock" then
				if gamestate == "game" then
					touchRunLock = not touchRunLock
				end
			elseif controls[self.player][self.i][1] then
				if controls[self.player][self.i][1] == "joy" then
					local c = controls[self.player][self.i]
					if c[3] == "but" then
						love.joystickpressed(c[2],c[4],"simulated")
					end
				else
					love.keypressed(controls[self.player][self.i][1])
				end
			end
		end
		if self.mousebut then
			local x,y = androidGetCoords(mouseTouchX,mouseTouchY)
			love.mousepressed(mouseTouchX,mouseTouchY,self.i,"simulated")
		end
		if self.func then
			self.i()
		end
		return true
	end
	return false
end

function touchButton:release(id,x,y)
	if self.held then
		self.held = false
		self.id = false

		if self.key then
			if self.i == "start" then
				if gamestate == "game" or gamestate == "options" or gamestate == "mappackmenu" or gamestate == "onlinemenu" then
					love.keyreleased("escape")
				else
					love.keyreleased("return")
				end
			elseif self.i == "runlock" then
			elseif controls[self.player][self.i][1] then
				if controls[self.player][self.i][1] == "joy" then
					local c = controls[self.player][self.i]
					if c[3] == "but" then
						love.joystickreleased(c[2],c[4],"simulated")
					end
				else
					love.keyreleased(controls[self.player][self.i][1])
				end
			end
		end
		if self.mousebut then
			local x,y = androidGetCoords(mouseTouchX,mouseTouchY)
			love.mousereleased(mouseTouchX,mouseTouchY,self.i,"simulated")
		end
	end
end
