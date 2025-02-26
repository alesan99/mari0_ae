lightbridge = class:new()

function lightbridge:init(x, y, dir, r)
	self.cox = x
	self.coy = y
	self.dir = dir
	self.r = {unpack(r)}
	self.enableddefault = true
	self.enabled = self.enableddefault
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	if #self.r > 0 and self.r[1] ~= "link" then
		local v = convertr(self.r[1], {"string", "bool"}, true)
		
		if v[1] ~= nil then
			self.dir = v[1]
		end
		if v[2] ~= nil and v[2] then
			self.enableddefault = false
			self.enabled = self.enableddefault
		end
		table.remove(self.r, 1)
	else
		self.legacy = true
	end
	
	self.childtable = {}
	self.outtable = {}
	
	self.glowa = 1
	self.glowtimer = 0
	self.children = 0
	
	self:updaterange()
end

function lightbridge:link()
	if #self.r >= 3 then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[2]) == v.cox and tonumber(self.r[3]) == v.coy then
					v:addoutput(self)
					if self.legacy then
						self.enableddefault = false
						self.enabled = self.enableddefault
					end
				end
			end
		end
	end
end

function lightbridge:input(t)
	if t == "on" then
		self.enabled = not self.enableddefault
		self:updaterange()
	elseif t == "off" then
		self.enabled = self.enableddefault
		self:updaterange()
	else
		self.enabled = not self.enabled
		self:updaterange()
	end
end

function lightbridge:update(dt)
	self.glowtimer = self.glowtimer + dt*2
end

function lightbridge:getglowa(offset)
	return math.sin(self.glowtimer-offset*0.5)*.25+.75
end

function lightbridge:draw()
	local rot = 0
	if self.dir == "up" then
		rot = math.pi*1.5
	elseif self.dir == "down" then
		rot = math.pi*0.5
	elseif self.dir == "left" then
		rot = math.pi
	end

	love.graphics.draw(lightbridgesideimg, math.floor((self.cox-xscroll-.5)*16*scale), (self.coy-yscroll-1)*16*scale, rot, scale, scale, 8, 8)
end

function lightbridge:updaterange()
	--save old gel values
	local gels = {}
	
	for i, v in pairs(self.childtable) do
		if v.gels.top then
			table.insert(gels, {x=v.cox, y=v.coy, dir="top", i=v.gels.top})
		elseif v.gels.left then
			table.insert(gels, {x=v.cox, y=v.coy, dir="left", i=v.gels.left})
		elseif v.gels.right then
			table.insert(gels, {x=v.cox, y=v.coy, dir="right", i=v.gels.right})
		elseif v.gels.bottom then
			table.insert(gels, {x=v.cox, y=v.coy, dir="bottom", i=v.gels.bottom})
		end
	end	
	
	for i, v in pairs(self.childtable) do
		v.destroy = true
	end
	self.childtable = {} 
	
	if self.enabled == false then
		self:updateoutputs()
		return
	end
	
	local dir = self.dir
	local startx, starty = self.cox, self.coy
	local x, y = self.cox, self.coy
	self.children = 0
	
	local firstcheck = true
	local quit = false
	while x >= 1 and x <= mapwidth and y >= 1 and y <= mapheight and (tilequads[map[x][y][1]].collision == false or tilequads[map[x][y][1]].grate == true) and (x ~= startx or y ~= starty or dir ~= self.dir or firstcheck == true) and quit == false do
		firstcheck = false
		
		self.children = self.children + 1
		if dir == "right" then
			x = x + 1
			table.insert(objects["lightbridgebody"], lightbridgebody:new(self, x-1, y, "hor", self.children))
		elseif dir == "left" then
			x = x - 1
			table.insert(objects["lightbridgebody"], lightbridgebody:new(self, x+1, y, "hor", self.children))
		elseif dir == "up" then
			y = y - 1
			table.insert(objects["lightbridgebody"], lightbridgebody:new(self, x, y+1, "ver", self.children))
		elseif dir == "down" then
			y = y + 1
			table.insert(objects["lightbridgebody"], lightbridgebody:new(self, x, y-1, "ver", self.children))
		end
		
		--check if current block is a portal
		local opp = "left"
		if dir == "left" then
			opp = "right"
		elseif dir == "up" then
			opp = "down"
		elseif dir == "down" then
			opp = "up"
		end
		
		local portalx, portaly, portalfacing, infacing = getPortal(x, y, opp)
		if portalx ~= false and ((dir == "left" and infacing == "right") or (dir == "right" and infacing == "left") or (dir == "up" and infacing == "down") or (dir == "down" and infacing == "up")) then
			x, y = portalx, portaly
			dir = portalfacing
			
			if dir == "right" then
				x = x + 1
			elseif dir == "left" then
				x = x - 1
			elseif dir == "up" then
				y = y - 1
			elseif dir == "down" then
				y = y + 1
			end
		end

		self:checktile(x, y)
		
		--doors
		for i, v in pairs(objects["door"]) do
			if v.active then
				if v.dir == "ver" then
					if x == v.cox and (y == v.coy or y == v.coy-1) then
						quit = true
					end
				elseif v.dir == "hor" then
					if y == v.coy and (x == v.cox or x == v.cox+1) then
						quit = true
					end
				end
			end
		end
	end
	
	--Restore gels! yay!
	--crosscheck childtable with gels to see any matching shit
	for j, w in pairs(self.childtable) do
		for i, v in pairs(gels) do
			if v.x == w.cox and v.y == w.coy then
				if v.dir == "left" or v.dir == "right" then
					if w.dir == "ver" then
						w.gels[v.dir] = v.i
					end
				else
					if w.dir == "hor" then
						w.gels[v.dir] = v.i
					end
				end
			end
		end
	end

	self:updateoutputs()
end

function lightbridge:addChild(t)
	table.insert(self.childtable, t)
end

function lightbridge:updateoutputs()
	for i, v in pairs(self.outtable) do
		v:clear()
	end
end

function lightbridge:checktile(x, y)
	--check if block is a detector
	for i, v in pairs(objects["laserdetector"]) do
		if x == v.cox and y == v.coy and (v.cox ~= self.r[4] or v.coy ~= self.r[5]) and v.detectslightbridges then
			table.insert(self.outtable, v)
			v:input("on")
		end
	end
end

------------------------------------

lightbridgebody = class:new()

function lightbridgebody:init(parent, x, y, dir, i)
	parent:addChild(self)
	self.i = i
	self.cox = x
	self.coy = y
	self.dir = dir
	self.parent = parent

	--PHYSICS STUFF
	if dir == "hor" then
		self.x = x-1
		self.y = y-9/16
		self.width = 1
		self.height = 1/8
	else
		self.x = x-9/16
		self.y = y-1
		self.width= 1/8
		self.height = 1
	end
	self.static = true
	self.active = true
	self.category = 28
	
	self.mask = {true}
	
	self.gels = {}
	
	self:pushstuff()
end

function lightbridgebody:pushstuff()
	local col = checkrect(self.x, self.y, self.width, self.height, {"box", "player"})
	for i = 1, #col, 2 do
		local v = objects[col[i]][col[i+1]]
		if self.dir == "ver" then
			if v.speedx >= 0 then
				if #checkrect(self.x + self.width, v.y, v.width, v.height, {"exclude", v}, true) > 0 then
					v.x = self.x - v.width
				else
					v.x = self.x + self.width
				end
			else
				if #checkrect(self.x - v.width, v.y, v.width, v.height, {"exclude", v}, true) > 0 then
					v.x = self.x + self.width
				else
					v.x = self.x - v.width
				end
			end
		elseif self.dir == "hor" then
			if v.speedy <= 0 then
				if #checkrect(v.x, self.y - v.height, v.width, v.height, {"exclude", v}, true) > 0 then
					v.y = self.y + self.height
				else
					v.y = self.y - v.height
				end
			else
				if #checkrect(v.x, self.y + self.height, v.width, v.height, {"exclude", v}, true) > 0 then
					v.y = self.y - v.height
				else
					v.y = self.y + self.height
				end
			end
		end
	end
end

function lightbridgebody:update(dt)
	if self.destroy then
		return true
	else
		return false
	end
end

function lightbridgebody:draw()
	love.graphics.setColor(255, 255, 255)
	
	local glowa = self.parent:getglowa(self.i)
	
	if self.dir == "hor" then
		love.graphics.draw(lightbridgeimg, math.floor((self.cox-xscroll-1)*16*scale), (self.coy-yscroll-1.5)*16*scale, 0, scale, scale)
		love.graphics.setColor(255, 255, 255, glowa*255)
		love.graphics.draw(lightbridgeglowimg, math.floor((self.cox-xscroll-1)*16*scale), (self.coy-yscroll-1.5)*16*scale, 0, scale, scale)
	else
		love.graphics.draw(lightbridgeimg, math.floor((self.cox-xscroll-1/16)*16*scale), (self.coy-yscroll-1)*16*scale, math.pi/2, scale, scale, 8, 1)
		love.graphics.setColor(255, 255, 255, glowa*255)
		love.graphics.draw(lightbridgeglowimg, math.floor((self.cox-xscroll-1/16)*16*scale), (self.coy-yscroll-1)*16*scale, math.pi/2, scale, scale, 8, 1)
	end
	
	love.graphics.setColor(255, 255, 255)
	
	--gel
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
		
		for i = 1, 4 do
			if self.gels[dir] == i then
				local img
				if i == 1 then
					img = gel1ground
				elseif i == 2 then
					img = gel2ground
				elseif i == 3 then
					img = gel3ground
				elseif i == 4 then
					img = gel4ground
				end
				
				love.graphics.draw(img, math.floor((self.cox-.5-xscroll)*16*scale), math.floor((self.coy-1-yscroll)*16*scale), r, scale, scale, 8, 2)
			end
		end
	end
end
