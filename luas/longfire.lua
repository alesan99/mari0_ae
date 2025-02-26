longfire = class:new()

function longfire:init(x, y, r, on)
	--PHYSICS STUFF
	self.speedy = 0
	self.speedx = 0
	
	self.x = x-47/16
	self.y = y-14/16
	self.width = 47/16
	self.height = 14/16
	
	self.dir = "left"
	self.on = false
	if on then
		self.on = true
	end
	if r then
		local v = convertr(r, {"string", "bool"}, true)
		self.dir = v[1] or "left"
		if v[2] ~= nil then
			self.on = v[2]
		end
	end
	
	if self.dir == "right" then
		self.x = x-15/16
	elseif self.dir == "up" then
		self.x = x-15/16
		self.y = y-47/16
		self.width = 14/16
		self.height = 47/16
	elseif self.dir == "down" then
		self.x = x-15/16
		self.y = y-1
		self.width = 14/16
		self.height = 47/16
	end
	
	self.active = true
	self.static = true
	self.gravity = 0
	self.category = 17
	
	self.mask = {	true,
					true, false, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					false, true}
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = longfireimg
	self.quad = longfirequad[1]
	self.offsetX = 47
	self.offsetY = 2
	self.quadcenterX = 48
	self.quadcenterY = 8
	self.rotation = 0
	if self.dir == "right" then
		self.offsetX = -1
		self.offsetY = 2
		self.animationdirection = "left"
	elseif self.dir == "up" then
		self.rotation = math.pi*.5
		self.offsetX = 7
		self.offsetY = -39
	elseif self.dir == "down" then
		self.rotation = math.pi*1.5
		self.offsetX = 7
		self.offsetY = 8
	end
	self.timer = 0
	self.timer2 = 0
	self.toggletimer = 0
	self.quadi = 1
	self.burp = true
end

function longfire:update(dt)
	if not self.on then
		self.active = false
		self.light = false
		if self.quadi ~= 1 then
			self.timer2 = self.timer2 + dt
			if self.timer2 > 0.1 then
				self.quadi = self.quadi - 1
				self.timer2 = 0
			end
			self.quad = longfirequad[self.quadi]
		end
		self.toggletimer = self.toggletimer + dt
		if self.toggletimer > 2 then
			self.on = true
			self.toggletimer = 0
		end
	end

	if self.active then
		--melt frozen coins / munchers
		for x = 1, math.ceil(self.width) do
			for y = 1, math.ceil(self.height) do
				local cox, coy = math.floor(self.x+(x-1))+1, math.floor(self.y+(y-1))+1
				if objects["frozencoin"][tilemap(cox, coy)] then
					objects["frozencoin"][tilemap(cox, coy)]:meltice()
				end
			end
		end
		for i, v in pairs(objects["muncher"]) do
			if v.frozen and aabb(self.x,self.y,self.width,self.height, v.x, v.y, v.width, v.height) then
				v:melt()
			end
		end
	end
	
	if self.on then
		if self.burp == true then
			if onscreen(self.x, self.y) then
				playsound(firesound)
			end
			self.burp = false
		end
		--animate
		if self.quadi < 4 then
			self.timer2 = self.timer2 + dt
			if self.timer2 > 0.1 then
				self.quadi = self.quadi + 1
				self.timer2 = 0
			end
			self.quad = longfirequad[self.quadi]
		else
			self.timer = self.timer + dt
			while self.timer > fireanimationdelay do
				if self.quadi == 4 then
					self.quadi = 5
				else
					self.quadi = 4
				end
				
				self.quad = longfirequad[self.quadi]
				self.timer = self.timer - fireanimationdelay
			end
			self.active = true
		end
		self.toggletimer = self.toggletimer + dt
		if self.toggletimer > 2 then
			self.burp = true
			self.on = false
			self.toggletimer = 0
		end
		self.light = 2
	end
end

function longfire:leftcollide(a, b)
	return false
end

function longfire:rightcollide(a, b)
	return false
end

function longfire:floorcollide(a, b)
	return false
end

function longfire:ceilcollide(a, b)
	return false
end

function longfire:draw()
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("line", ((self.x*16)-xscroll)*scale, ((self.y+.5*16)-yscroll)*scale, ((self.x+self.width)*16-xscroll)*scale, ((self.y+self.height+.5)*16-yscroll)*scale)
end
