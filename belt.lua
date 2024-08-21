belt = class:new()

local speedfast = 6
local speedslow = 3

function belt:init(x, y, r, t)
	--PHYSICS STUFF
	self.cox = x
	self.coy = y
	self.x = x-1
	self.y = y-1
	self.height = 1
	self.static = true
	self.active = true
	self.speedx = 0
	self.speedy = 0
	self.activestatic = true
	self.category = 2
	self.mask = {	true, 
					false, false, false, false, false,
					false, false, false, true, false,
					false, false, true, false, false,
					true, true, false, false, false,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	self.gravity = 0
	self.portalable = false
	
	self.t = t or false
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	self.speed = speedslow
	self.width = 3
	self.on = true
	
	if #self.r > 0 and self.r[1] ~= "link" and self.r[1]:find("|") then
		local vars = r[3]:split("|")
		local s = vars[1]:gsub("n", "-")
		if vars[1] and tonumber(s) then
			self.speed = tonumber(s)
		elseif vars[1] == "right slow" then
			self.speed = speedslow
		elseif vars[1] == "right fast" then
			self.speed = speedfast
		elseif vars[1] == "left slow" then
			self.speed = -speedslow
		elseif vars[1] == "left fast" then
			self.speed = -speedfast
		end
		self.width = math.min(99, math.max(2, math.floor(tonumber(vars[2]) or 3)))
		if self.t == "switch" and vars[3] then
			self.color = tonumber(vars[3])
		end
		table.remove(self.r, 1)
	end

	if self.t == "switch" then
		self.switchon = false
		if solidblockperma[self.color] then
			self:change()
		end
	end
	
	--IMAGE STUFF
	self.drawable = false
	self.animtimer = 0
	self.frame = 1
	
	self.outtable = {}

	self.gels = {}
	self.geloffset = 0
	self.gelsurface = self.width*2+2
	for i = 1, self.gelsurface do
		self.gels[i] = false
	end

	--block portals along length
	for i = 1, self.width do
		blockedportaltiles[tilemap(x+i-1, y)] = true
	end

	--move things
	self.checktable = {"player", "box", "smallspring", "turret", "mushroom", "oneup", "powblock", "ice", "enemy", "core", "pbutton"}
	for i, v in pairs(enemies) do
		if objects[v] and underwater == false then
			table.insert(self.checktable, v)
		end
	end
end

function belt:update(dt)
	if self.on then
		local speed = self.speed
		--animation
		self.animtimer = math.fmod(self.animtimer - speed*2*dt, 1)
		while self.animtimer < 0 do
			self.animtimer = self.animtimer + 1
		end
		self.frame = math.max(1, math.ceil(self.animtimer*8))
		
		for i, v in pairs(self.checktable) do
			for j, w in pairs(objects[v]) do
				if w.width and (not w.ignoreplatform) and w.active and inrange(w.x, self.x-w.width, self.x+self.width) and (not w.vine) and (not w.fence) then
					if w.y == self.y - w.height then
						if #checkrect(w.x+speed*dt, w.y, w.width, w.height, {"exclude", w}, true) == 0 then
							w.oldxplatform = w.x
							w.x = w.x + speed*dt
						end
					elseif v == "player" and w.gravitydir == "up" and w.y == self.y+self.height then
						if #checkrect(w.x-speed*dt, w.y, w.width, w.height, {"exclude", w}, true) == 0 then
							w.oldxplatform = w.x
							w.x = w.x - speed*dt
						end
					end
				end
			end
		end

		--gel
		self.geloffset = (self.geloffset + speed*dt)%(self.gelsurface)
		while self.geloffset < 0 do
			self.geloffset = self.geloffset + (self.gelsurface)
		end
	end
end

function belt:draw()
	--vertically on screen
	if self.y < yscroll and self.y > yscroll+height then
		return
	end
	local img = beltimg
	local row = spriteset
	if self.t == "switch" then
		if self.switchon then
			img = beltoffimg
		else
			img = beltonimg
		end
		row = self.color
	end

	love.graphics.draw(img, beltquad[row][self.frame*3-2], math.floor((self.x-xscroll)*16*scale), math.floor((self.y-yscroll-.5)*16*scale), 0, scale, scale)
	for i = 1, self.width-2 do
		if self.x+i+1 > xscroll and self.x < xscroll+width then --horizontally on screen
			love.graphics.draw(img, beltquad[row][self.frame*3-1], math.floor((self.x+i-xscroll)*16*scale), math.floor((self.y-yscroll-.5)*16*scale), 0, scale, scale)
		end
	end
	love.graphics.draw(img, beltquad[row][self.frame*3], math.floor((self.x+self.width-xscroll-1)*16*scale), math.floor((self.y-yscroll-.5)*16*scale), 0, scale, scale)
	--gel
	for i = 1, self.gelsurface do
		local l = i - math.floor(self.geloffset)
		if l < 1 then
			l = l + self.gelsurface
		end
		if self.gels[l] then
			local id = self.gels[l]
			local x, y, copies, r = self.x+i +(self.geloffset%1), self.y+1, 1, 0
			if i == self.width+1 then
				x = self.x+self.width
				r = math.pi/2
			elseif i == self.gelsurface then
				x = self.x+1
				r = math.pi*1.5
			elseif i > self.width then
				x = self.x+self.width-(i-self.width) -(self.geloffset%1) +3
				r = math.pi
				if i == self.width+2 or i == self.gelsurface-1 then
					copies = 2
				end
			else
				if i == 1 or i == self.width then
					copies = 2
				end
			end
			if copies ~= 1 then
				love.graphics.setScissor(math.floor(((self.x-xscroll)*16)*scale), ((y-1-yscroll)*16-8)*scale, self.width*16*scale, 16*scale)
			end
			for x2 = 1, copies do
				if x2 == 2 then
					x = x - 1
				end
				if id == 1 then
					love.graphics.draw(gel1ground, math.floor(((x-xscroll)*16-8)*scale), ((y-yscroll)*16-16)*scale, r, scale, scale, 8, 8)
				elseif id == 2 then
					love.graphics.draw(gel2ground, math.floor(((x-xscroll)*16-8)*scale), ((y-yscroll)*16-16)*scale, r, scale, scale, 8, 8)
				elseif id == 3 then
					love.graphics.draw(gel3ground, math.floor(((x-xscroll)*16-8)*scale), ((y-yscroll)*16-16)*scale, r, scale, scale, 8, 8)
				elseif id == 4 then
					love.graphics.draw(gel4ground, math.floor(((x-xscroll)*16-8)*scale), ((y-yscroll)*16-16)*scale, r, scale, scale, 8, 8)
				end
			end
			if copies ~= 1 then
				love.graphics.setScissor()
			end
		end
	end
end

function drawbelt(x, y, length, i, color) --for editor
	local img = beltimg
	local row = spriteset
	if i == "beltswitch" then
		img = beltonimg
		row = tonumber(color) or 1
	end
	x, y = x-1, y-1
	length = math.min(99, math.max(2, math.floor(tonumber(length or 3))))
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(img, beltquad[row][1], math.floor((x-xscroll)*16*scale), math.floor((y-yscroll-.5)*16*scale), 0, scale, scale)
	for i = 1, length-2 do
		love.graphics.draw(img, beltquad[row][2], math.floor((x+i-xscroll)*16*scale), math.floor((y-yscroll-.5)*16*scale), 0, scale, scale)
	end
	love.graphics.draw(img, beltquad[row][3], math.floor((x+length-xscroll-1)*16*scale), math.floor((y-yscroll-.5)*16*scale), 0, scale, scale)
end

function belt:link()
	while #self.r >= 3 do
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[2]) == v.cox and tonumber(self.r[3]) == v.coy then
					if self.r[4] == "reverse" then
					else
						self.power = false
					end
					v:addoutput(self, self.r[4] or "power")
				end
			end
		end
		
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
	end
end

function belt:input(t, input)
	if input == "reverse" then
		self.speed = -self.speed
	else--if input == "power" then
		if t == "on" then
			self.on = true
		elseif t == "off" then
			self.on = false
		else
			self.on = not self.on
		end
	end
end

function belt:change(on)
	self.switchon = not self.switchon
	self.speed = -self.speed
end

function belt:getgel(x)
	local l = math.max(1, math.min(self.width, x-math.floor(self.x))) - math.floor(self.geloffset)
	if l < 1 then
		l = l + self.gelsurface
	end
	return self.gels[l]
end

function belt:leftcollide(a, b)
end

function belt:rightcollide(a, b)
end

function belt:ceilcollide(a, b)
	if a == "gel" then
		local testx = math.floor((b.x+b.width/2)-self.x - self.geloffset)+1
		if testx < 1 then
			testx = testx + self.gelsurface
		end
		local x = math.min(self.gelsurface, math.max(1, testx) )
		if b.id == 5 then
			self.gels[x] = nil
		else
			self.gels[x] = b.id
		end
	end
	return true
end

function belt:globalcollide(a, b)
end

function belt:floorcollide(a, b)
end

function belt:passivecollide(a, b)
end
