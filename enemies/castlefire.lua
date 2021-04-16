castlefire = class:new()

function castlefire:init(x, y, length, dir, t)
	self.x = x
	self.y = y+1/16
	if t and t == "rotodisc" then
		self.t = "rotodisc"
		self.dist = 3
		self.num = 1
		self.dir = "left"
		if length then
			local vars = length:split("|")
			self.num = vars[1]
			self.dir = vars[2]
		end

		self.trackable = true
		self.trackoffsetx = 0.5
		self.trackoffsety = 0.5
		
		self.quadi = 1
		self.angle = 0
		self.timer = 0
		self.timer2 = 0
		self.child = {}
		for i = 1, self.num do
			local temp = castlefirefire:new("rotodisc")
			table.insert(objects["castlefirefire"], temp)
			table.insert(self.child, temp)
			local v = 0
			self.child[i].x = self.x+math.sin(v*math.pi*4+math.pi*i)*self.dist-1
			self.child[i].y = self.y+math.cos(v*math.pi*4+math.pi*i)*self.dist-1
		end
	elseif t and t == "boocircle" then
		self.x = x+2/16
		self.y = y+3/16
		self.t = "boocircle"

		self.dist = 3
		self.targetdist = self.dist
		if self.x > xscroll+width then
			self.dist = 0
		end

		self.speed = 1/3
		self.num = 8 --how many spaces are filled
		self.spacenum = 9.5 --how many spaces there are
		self.dir = "cw"

		if length and type(length) == "string" then
			local v = convertr(length, {"string","num","num","num","num"})
			self.dir = v[1]
			self.targetdist = v[2]
			if self.dist ~= 0 then
				self.dist = self.targetdist
			end
			self.num = v[3]
			self.spacenum = self.num+v[4]
			self.speed = v[5]
		end

		self.trackable = true
		self.trackoffsetx = 0.5
		self.trackoffsety = 0.5
		
		self.quadi = 1
		self.angle = 0
		self.timer = 0
		self.timer2 = 0
		self.child = {}
		for i = 1, self.num do
			local temp = boo:new(x-0.5, y-1/16)
			table.insert(objects["boo"], temp)
			table.insert(self.child, temp)
			local v = 0
			self.child[i].x = self.x+math.sin(v*math.pi*4+((math.pi*2)/(self.spacenum))*i)*self.dist-1
			self.child[i].y = self.y+math.cos(v*math.pi*4+((math.pi*2)/(self.spacenum))*i)*self.dist-1
			self.child[i].static = true
		end
	else
		self.t = "castlefire"
		self.angle = 0
		self.dir = dir or "cw"
		self.smooth = false
		if length and not tonumber(length) and length:find("|") then
			local vars = length:split("|")
			self.length = tonumber(vars[1]) or 6
			if tonumber(vars[2]) then
				self.delay = tonumber(vars[2])
			elseif vars[2] == "fast" then
				self.delay = castlefirefastdelay
			else
				self.delay = castlefiredelay
			end
			if vars[3] then
				self.angle = tonumber(vars[3])
			end
			if vars[4] then
				self.dir = vars[4]
			end
			if vars[5] then
				self.y = y
				self.smooth = (vars[5] == "true")
			end
		else
			self.length = length or 6
			self.delay = castlefiredelay
		end
		self.quadi = 1
		self.child = {}
		for i = 1, self.length do
			local temp = castlefirefire:new()
			table.insert(objects["castlefirefire"], temp)
			table.insert(self.child, temp)
		end
		self.timer = 0
		self.timer2 = 0

		self.trackable = true
		self.trackoffsetx = 0.5
		self.trackoffsety = 0.5

		--middle fire isn't active (you can sometimes clip through the top of a block and get killed)
		local cx, cy = math.floor(self.x), math.floor(self.y)
		if inmap(cx, cy) and tilequads[map[cx][cy][1]].collision and not tilequads[map[cx][cy][1]].breakable and not tilequads[map[cx][cy][1]].platform then
			if self.child[1] then
				self.child[1].active = false
			end
		end
	
		self:updatepos()
		self:updatequad()
	end
end

function castlefire:update(dt)
	if self.t == "rotodisc" then
		self.timer = self.timer + dt
		while self.timer > 4 do
			self.timer = self.timer - 4
		end
		for i = 1, self.num do
			local v = self.timer/4
			if self.dir == "right" then
				v = -v
			end
			self.child[i].x = self.x+math.sin(v*math.pi*4+math.pi*i)*self.dist-1
			self.child[i].y = self.y+math.cos(v*math.pi*4+math.pi*i)*self.dist-1
		end
		
		self.timer2 = self.timer2 + dt
		while self.timer2 > staranimationdelay do
			self.timer2 = self.timer2 - staranimationdelay
			self.quadi = self.quadi + 1
			if self.quadi > 4 then
				self.quadi = 1
			end
			self:updatequad()
		end
	elseif self.t == "boocircle" then
		if self.dist < self.targetdist then
			self.dist = math.min(self.targetdist, self.dist+8*dt)
		end
		
		self.timer = self.timer + dt*self.speed
		while self.timer > 4 do
			self.timer = self.timer - 4
		end
		for i = 1, self.num do
			local v = self.timer/4
			if self.dir == "cw" then
				v = -v
			end
			if self.child[i] and not self.child[i].shot then
				self.child[i].x = self.x+math.sin(v*math.pi*4+((math.pi*2)/(self.spacenum))*i)*self.dist-1
				self.child[i].y = self.y+math.cos(v*math.pi*4+((math.pi*2)/(self.spacenum))*i)*self.dist-1
				self.child[i].scared = false
				self.child[i].quad = booquad[spriteset][1]
			end
		end
	else
		self.timer = self.timer + dt
		
		if self.smooth then
			if self.dir == "cw" then
				self.angle = self.angle + (castlefireangleadd/self.delay)*dt
				self.angle = math.fmod(self.angle, 360)
			else
				self.angle = self.angle - (castlefireangleadd/self.delay)*dt
				while self.angle < 0 do
					self.angle = self.angle + 360
				end
			end
			
			self:updatepos()
		else
			while self.timer > self.delay do
				self.timer = self.timer - self.delay
				if self.dir == "cw" then
					self.angle = self.angle + castlefireangleadd
					self.angle = math.fmod(self.angle, 360)
				else
					self.angle = self.angle - castlefireangleadd
					while self.angle < 0 do
						self.angle = self.angle + 360
					end
				end
				
				self:updatepos()
			end
		end

		if self.track or self.onmovingtile then
			--stay updated when on track
			if not self.smooth then
				self:updatepos()
			end

			if (not self.tracked) and (not self.onmovingtile) then
				self.speedy = self.speedy + trackgravity*dt
				self.x = self.x + self.speedx*dt
				self.y = self.y + self.speedy*dt
			end
		end
		
		self.timer2 = self.timer2 + dt
		while self.timer2 > castlefireanimationdelay do
			self.timer2 = self.timer2 - castlefireanimationdelay
			self.quadi = self.quadi + 1
			if self.quadi > 4 then
				self.quadi = 1
			end
			self:updatequad()
		end
	end
end

function castlefire:updatepos()
	local x = self.x-.5
	local y = self.y-.5
	
	for i = 1, self.length do
		local xadd = math.cos(math.rad(self.angle))*(i-1)*0.5
		local yadd = math.sin(math.rad(self.angle))*(i-1)*0.5
		
		self.child[i].x = x+xadd-0.25
		self.child[i].y = y+yadd-0.25

		--melt frozen coins
		local cox, coy = math.floor(self.child[i].x+self.child[i].width/2)+1, math.floor(self.child[i].y+self.child[i].height/2)+1
		if objects["frozencoin"][tilemap(cox, coy)] then
			objects["frozencoin"][tilemap(cox, coy)]:meltice()
		end
	end
end

function castlefire:updatequad()
	if self.t == "rotodisc" then
		for i = 1, self.num do
			self.child[i].quad = starquad[spriteset][self.quadi]
		end
	else
		for i = 1, self.length do
			self.child[i].quad = fireballquad[self.quadi]
		end
	end
end

function castlefire:dotrack()
	self.track = true
	self.speedx = 0
	self.speedy = 0
end

function castlefire:dosupersize()
	if self.t == "boocircle" then
		self.dist = self.dist*1.5--*self.supersized
		for i = 1, self.num do
			if self.child[i] then
				supersizeentity(self.child[i])
			end
		end
	end
end

--------------

castlefirefire = class:new()

function castlefirefire:init(t)
	--PHYSICS STUFF
	self.y = 0
	self.x = 0
	self.width = 8/16
	self.height = 8/16
	self.active = true
	self.static = true
	self.category = 23
	
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
	self.graphic = fireballimg
	self.quad = fireballquad[1]
	self.offsetX = 4
	self.offsetY = 4
	self.quadcenterX = 4
	self.quadcenterY = 4
	self.light = 1
	
	--rotodisc
	if t and t == "rotodisc" then
		self.width = 1
		self.height = 1
		
		self.graphic = rotodiscimg
		self.quad = starquad[spriteset][1]
		self.offsetX = 8
		self.offsetY = 0
		self.quadcenterX = 8
		self.quadcenterY = 8

		self.light = 2
	end
end