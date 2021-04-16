meteor = class:new()

function meteor:init()
	self.width = 12/16
	self.height = 12/16
	self.y = -self.height
	self.x = math.random(math.floor(splitxscroll[1]), math.floor(splitxscroll[1])+width)
	self.rotation = 0 --for portals
	
	self.speedy = meteorspeeds[math.random(1,#meteorspeeds)]
	self.speedx = 0
	
	self.active = true
	self.static = false
	self.autodelete = true
	self.gravity = 0
	self.category = 4
	
	self.mask = {	true, 
					false, false, false, false, true,
					false, true, false, true, false,
					false, false, true, false, false,
					true, true, false, false, false,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = meteorimg
	self.quad = meteorquad[1][1]
	self.offsetX = 6
	self.offsetY = 3
	self.quadcenterX = 8
	self.quadcenterY = 8
	
	self.animationtimer = 0
	
	self.deathtimer = 0

	--big
	if math.random(1, 6) == 1 then
		self.width = self.width*2
		self.height = self.height*2
		self.offsetX = self.offsetX*2
		self.offsetY = self.offsetY*2-8
		self.animationscalex = 2
		self.animationscaley = 2
		self.x = self.x + 4/16
		self.y = self.y - 12/16
	end
	
	self.shot = false
	self.dead = false

	self.smoketimer = math.random()*.2

	--delete if blocked by tile
	if checkintile(self.x, 0, self.width, self.height, tileentities, self) then
		self.dead = true
	end
end

function meteor:update(dt)
	if self.dead then
		return true
	end

	--rotate back to 0 (portals)
	if self.rotation > 0 then
		self.rotation = self.rotation - portalrotationalignmentspeed*dt
		if self.rotation < 0 then
			self.rotation = 0
		end
	elseif self.rotation < 0 then
		self.rotation = self.rotation + portalrotationalignmentspeed*dt
		if self.rotation > 0 then
			self.rotation = 0
		end
	end
	
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
		
	else
		self.smoketimer = self.smoketimer + dt
		if self.smoketimer > 0.2 then
			makepoof(self.x+self.width/2+(math.random()*.2-.1), self.y, "smoke")
			self.smoketimer = 0
		end

		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > cheepanimationspeed do
			self.animationtimer = self.animationtimer - cheepanimationspeed
			if self.frame == 1 then
				self.frame = 2
			else
				self.frame = 1
			end
			self.quad = meteorquad[1][self.frame]
		end
		
		return false
	end
end

function meteor:crash(nosound)
	if not nosound then
		playsound(boomsound)
	end
	self.dead = true
	self.active = false
	self.drawable = false
	table.insert(blockdebristable, blockdebris:new(self.x+.5, self.y+.5, 3.5, -23, meteorimg, meteorquad[2]))
	table.insert(blockdebristable, blockdebris:new(self.x+.5, self.y+.5, -3.5, -23, meteorimg, meteorquad[2]))
	table.insert(blockdebristable, blockdebris:new(self.x+.5, self.y+.5, 3.5, -14, meteorimg, meteorquad[2]))
	table.insert(blockdebristable, blockdebris:new(self.x+.5, self.y+.5, -3.5, -14, meteorimg, meteorquad[2]))
end

function meteor:shotted(dir) --fireball, star, turtle
	self:crash()
end

function meteor:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self:crash()
end

function meteor:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self:crash()
end

function meteor:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self:crash()
end

function meteor:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "meteor" then
		return false
	end
	if a == "tile" then
		if self.width > 1 then
			--big
			local x1, x2 = math.floor(self.x)+1, math.floor(self.x+self.width)+1
			for x = x1, x2 do
				if inmap(x, b.coy) then
					local r = map[x][b.coy]
					if r[1] and tilequads[r[1]].breakable or (tilequads[r[1]].debris and blockdebrisquads[tilequads[r[1]].debris]) then
						destroyblock(x, b.coy, "nopoints")
					end
				end
			end
		else
			local r = map[b.cox][b.coy]
			if r[1] and tilequads[r[1]].breakable or (tilequads[r[1]].debris and blockdebrisquads[tilequads[r[1]].debris]) then
				destroyblock(b.cox, b.coy, "nopoints")
			end
		end
	elseif b.shotted then
		b:shotted("left")
		if self.width > 1 then
			return false
		end
	end
	self:crash()
	
	return true
end

function meteor:globalcollide(a, b)
	if self.dead then
		return true
	end
	if a == "meteor" then
		return true
	end
	return false
end

function meteor:portaled()
	self.gravity = 5
end