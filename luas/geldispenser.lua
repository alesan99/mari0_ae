geldispenser = class:new()

function geldispenser:init(x, y, id, dir, r)
	--PHYSICS STUFF
	self.cox = x
	self.coy = y
	self.x = x-1
	self.y = y-1
	self.speedy = 0
	self.speedx = 0
	self.width = 2
	self.height = 2
	self.static = true
	self.active = true
	self.category = 7
	self.mask = {true, false, false, false, false, false}
	
	self.dir = dir
	self.id = id
	self.timer = 0
	self.defaulton = true
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	if #self.r > 0 and self.r[1] ~= "link" then
		local v = convertr(self.r[1], {"string", "num", "bool"}, true)
		--DIRECTION
		self.dir = v[1]
		--TYPE
		self.id = v[2]
		--DEFAULT OFF
		if v[3] then
			self.defaulton = false
		end
		table.remove(self.r, 1)
	else
		self.legacy = true
	end

	self.count = 0

	self.on = self.defaulton
	self.outtable = {}
end

function geldispenser:input(t)
	if t == "on" then
		self.on = not self.defaulton
	elseif t == "off" then
		self.on = self.defaulton
	elseif t == "toggle" then
		self.on = not self.on
	end
end

function geldispenser:link()
	if #self.r > 2 then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[2]) == v.cox and tonumber(self.r[3]) == v.coy then
					v:addoutput(self)
					if self.legacy then
						self.defaulton = false
						self.on = false
					end
				end
			end
		end
	end
end

function geldispenser:update(dt)
	if #objects["gel"] > gelmaxcountglobal then
		return false
	elseif self.count > gelmaxcount then
		return false
	end

	if self.on then --don't dispense if not on
		self.timer = self.timer + dt
	end

	local speed = geldispensespeed
	if #objects["gel"] > 30 and (not onscreen(self.x, self.y, self.width, self.height)) then
		speed = geldispensespeed*1.5
	end
	
	while self.timer > speed do
		self.timer = self.timer - speed
		if self.dir == "down" then
			local obj = gel:new(self.x+1.5 + (math.random()-0.5)*1, self.y+12/16, self.id)
			table.insert(objects["gel"], obj)
			obj.speedy = 10
			obj.parent = self
		elseif self.dir == "up" then
			local obj = gel:new(self.x+1.5 + (math.random()-0.5)*1, self.y+self.height-12/16, self.id)
			table.insert(objects["gel"], obj)
			obj.speedy = -30
			obj.parent = self
		elseif self.dir == "right" then
			local obj = gel:new(self.x+14/16, self.y+1.5 + (math.random()-0.5)*1, self.id)
			table.insert(objects["gel"], obj)
			obj.speedx = 20
			obj.speedy = -4
			obj.parent = self
		elseif self.dir == "left" then
			local obj = gel:new(self.x+30/16, self.y+1.5 + (math.random()-0.5)*1, self.id)
			table.insert(objects["gel"], obj)
			obj.speedx = -20
			obj.speedy = -4
			obj.parent = self
		end
		self.count = self.count + 1
	end
	return false
end

function geldispenser:draw()
	if self.dir == "down" then
		love.graphics.draw(geldispenserimg, geldispenserquad[spriteset][self.id], math.floor((self.cox-xscroll-1)*16*scale), (self.coy-1.5-yscroll)*16*scale, 0, scale, scale, 0, 0)
	elseif self.dir == "up" then
		love.graphics.draw(geldispenserimg, geldispenserquad[spriteset][self.id], math.floor((self.cox-xscroll+1)*16*scale), (self.coy+.5-yscroll)*16*scale, math.pi, scale, scale, 0, 0)
	elseif self.dir == "right" then
		love.graphics.draw(geldispenserimg, geldispenserquad[spriteset][self.id], math.floor((self.cox-xscroll-1)*16*scale), (self.coy+.5-yscroll)*16*scale, math.pi*1.5, scale, scale, 0, 0)
	elseif self.dir == "left" then
		love.graphics.draw(geldispenserimg, geldispenserquad[spriteset][self.id], math.floor((self.cox-xscroll+1)*16*scale), (self.coy-1.5-yscroll)*16*scale, math.pi*0.5, scale, scale, 0, 0)
	end
end

function geldispenser:callback()
	self.count = self.count - 1
end