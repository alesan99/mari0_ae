laserfield = class:new()

function laserfield:init(x, y, dir, r)
	self.cox = x
	self.coy = y
	self.x = x
	self.y = y
	self.dir = dir
	self.active = true
	self.inputstate = "off"

	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	if #self.r > 0 and self.r[1] ~= "link" then
		local v = convertr(self.r[1], {"string", "bool"}, true)
		
		if v[1] ~= nil then
			self.dir = v[1]
		end
		if v[2] ~= nil and v[2] then
			self.active = false
		end
		table.remove(self.r, 1)
	end
	
	self.destroy = false
	if getTile(self.x, self.y) == true then
		self.destroy = true
	end
	
	for i, v in pairs(laserfields) do
		local a, b = v:getTileInvolved(self.x, self.y)
		if a and b == self.dir then
			self.destroy = true
		end
	end
	
	self.particles = {}
	self.particles.i = {}
	self.particles.dir = {}
	self.particles.speed = {}
	self.particles.mod = {}
	
	self.involvedtiles = {}
	
	--find start and end
	if self.dir == "hor" then
		local curx = self.x
		while curx >= 1 and getTile(curx, self.y) == false do
			self.involvedtiles[curx] = self.y
			curx = curx - 1
		end
		self.startx = curx + 1
		
		local curx = self.x
		while curx <= mapwidth and getTile(curx, self.y) == false do
			self.involvedtiles[curx] = self.y
			curx = curx + 1
		end
		self.endx = curx - 1
		
		self.range = math.floor(((self.endx - self.startx + 1 + emanceimgwidth/16)*16)*scale)
	else
		local cury = self.y
		while cury >= 1 and getTile(self.x, cury) == false do
			self.involvedtiles[cury] = self.x
			cury = cury - 1
		end
		self.starty = cury + 1
		
		local cury = self.y
		while cury <= mapheight and getTile(self.x, cury) == false do
			self.involvedtiles[cury] = self.x
			cury = cury + 1
		end
		self.endy = cury - 1
		
		self.range = math.floor(((self.endy - self.starty + 1 + emanceimgwidth/16)*16)*scale)
	end
	
	self.outtable = {}
end

function laserfield:input(t)
	if t == "on" and self.inputstate == "off" then
		self.active = not self.active
	elseif t == "off" and self.inputstate == "on" then
		self.active = not self.active
	elseif t == "toggle" then
		self.active = not self.active
	end
	
	self.inputstate = t
end

function laserfield:link()
	while #self.r >= 3 do
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[2]) == v.cox and tonumber(self.r[3]) == v.coy then
					v:addoutput(self)
				end
			end
		end
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
	end
end

function laserfield:update(dt)
	if self.destroy then
		return true
	end
end

function laserfield:draw()
	if self.destroy == false then
		if self.dir == "hor" then
			parstartleft = math.floor((self.startx-1-xscroll)*16*scale)
			parstartright = math.floor((self.endx-1-xscroll)*16*scale)
			for x = self.startx, self.endx do
				love.graphics.draw(laserfieldimg, math.floor((x-xscroll-1)*16*scale), (self.y-20/16-yscroll)*16*scale, 0, scale, scale)
			end
			
			--Sidethings
			love.graphics.draw(emancesideimg, emancesidequad[spriteset][2], parstartleft, ((self.y-1-yscroll)*16-4)*scale, 0, scale, scale)
			love.graphics.draw(emancesideimg, emancesidequad[spriteset][2], parstartright+16*scale, ((self.y-1-yscroll)*16+4)*scale, math.pi, scale, scale)
		else
			parstartup = math.floor((self.starty-1-yscroll)*16*scale)
			parstartdown = math.floor((self.endy-1-yscroll)*16*scale)
			for y = self.starty, self.endy do
				love.graphics.draw(laserfieldimg, math.floor((self.x-xscroll-5/16)*16*scale), (y-1-yscroll)*16*scale, math.pi/2, scale, scale, 8, 1)
			end
			
			--Sidethings
			love.graphics.draw(emancesideimg, emancesidequad[spriteset][2], math.floor(((self.x-xscroll)*16-4)*scale), parstartup-8*scale, math.pi/2, scale, scale)
			love.graphics.draw(emancesideimg, emancesidequad[spriteset][2], math.floor(((self.x-xscroll)*16-12)*scale), parstartdown+8*scale, -math.pi/2, scale, scale)
		end
	end
end

function laserfield:getTileInvolved(x, y)
	if self.active then
		if self.dir == "hor" then
			if self.involvedtiles[x] == y then
				return true, "hor"
			else
				return false, "hor"
			end
		else
			if self.involvedtiles[y] == x then
				return true, "ver"
			else
				return false, "ver"
			end
		end
	else
		return false
	end
end