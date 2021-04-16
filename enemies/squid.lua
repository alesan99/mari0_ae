squid = class:new()

function squid:init(x, y, color, p)
	self.x = x-1+2/16
	self.y = y-1+4/16
	self.width = 12/16
	self.height = 12/16
	self.rotation = 0 --for portals
	
	self.speedy = 0
	self.speedx = 0
	
	self.active = true
	self.static = false
	self.autodelete = true
	self.gravity = 0
	self.category = 30
	
	self.color = color or "white"
	
	self.freezable = true
	self.frozen = false
	
	--IMAGE STUFF
	self.drawable = true
	if self.color == "pink" then
		self.graphic = pinksquidimg
		self.quad = squidquad[spriteset][1]
	elseif self.color == "baby" then
		self.graphic = squidbabyimg
		self.quad = squidbabyquad[spriteset][1]
	else
		self.graphic = squidimg
		self.quad = squidquad[spriteset][1]
	end
	self.offsetX = 6
	self.offsetY = 3
	self.quadcenterX = 8
	self.quadcenterY = 8
	
	self.mask = {	true,
					true, false, true, true, true,
					true, true, true, true, true,
					true, false, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true}
	
	self.direction = "left"
	
	self.timer = 0
	self.state = "idle"
	self.freezetimer = 0
	
	self.shot = false
	
	if self.color == "nanny" then
		self.child = {}
		for i = 1, 4 do
			self.child[i] = squid:new(x+3/16, y-(8/16)*i, "baby", self)
			table.insert(objects["squid"], self.child[i])
		end
	elseif self.color == "baby" then
		self.parent = p
		self.i = #self.parent.child+1
		
		self.width = 6/16
		self.height = 6/16
		
		self.offsetX = 4
		self.offsetY = 3
		self.quadcenterX = 4
		self.quadcenterY = 6
	end
end

function squid:update(dt)
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

	if self.frozen then
		return false
	end
	
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
		
	elseif self.color == "baby" then
		if not self.parent or self.parent.shot then
			self:shotted(dir)
			return false
		end
		local i = self.i-1
		local v = self.parent.child[i] --target
		if self.i == 1 then
			v = self.parent
		end
		while ((not v) or v.shot) and i > 0 do
			i = i-1
			if i < 1 then
				v = self.parent
			else
				v = self.parent.child[i]
			end
		end
		local relativex, relativey = (v.x+ -self.x), (v.y + -self.y) - self.i/8
		local distance = math.sqrt(relativex*relativex+relativey*relativey)
		if not self.chase then
			self.speedx = 0
			self.speedy = squidfallspeed
			self.state = "idle"
			if self.supersized then
				self.chase = (distance > 1*self.supersized)
			else
				self.chase = (distance > 1)
			end
		else
			self.state = "upward"
			self.speedx, self.speedy = (relativex)/distance*(squidxspeed), (relativey)/distance*(squidxspeed)
			if distance < 1/16 then
				self.speedx = 0
				self.state = "idle"
				self.chase = false
			end
		end
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		if self.state == "idle" then
			self.quad = squidbabyquad[spriteset][1]
		else
			self.quad = squidbabyquad[spriteset][2]
		end
		
		return false
	elseif not self.frozen then
		if self.track then
			self.animationtimer = self.animationtimer + dt
			while self.animationtimer > goombaanimationspeed*2 do
				self.animationtimer = self.animationtimer - goombaanimationspeed*2
				if self.quad == squidquad[spriteset][1] then
					self.quad = squidquad[spriteset][2]
				else
					self.quad = squidquad[spriteset][1]
				end
			end
		else
			--get nearest player
			closestplayer = 1
			for i = 2, players do
				local v = objects["player"][i]
				if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
					closestplayer = i
				end
			end
			
			if self.state == "idle" then
				self.speedy = squidfallspeed
				
				--get if change state to upward
				if (self.y+self.speedy*dt) + self.height + 0.0625 >= (objects["player"][closestplayer].y - (24/16 - objects["player"][closestplayer].height)) then
					self.state = "upward"
					self.upx = self.x
					self.speedx = 0
					self.speedy = 0
					
					--get if to change direction
					if true then--math.random(2) == 1 then
						if self.direction == "right" then
							if self.x > objects["player"][closestplayer].x then
								self.direction = "left"
							end
						else
							if self.x < objects["player"][closestplayer].x then
								self.direction = "right"
							end
						end
					end
				end
				
			elseif self.state == "upward" then
				if self.direction == "right" then
					self.speedx = self.speedx + squidacceleration*dt
					if self.speedx > squidxspeed then
						self.speedx = squidxspeed
					end
				else
					self.speedx = self.speedx - squidacceleration*dt
					if self.speedx < -squidxspeed then
						self.speedx = -squidxspeed
					end
				end
				
				self.speedy = self.speedy - squidacceleration*dt
				
				if self.speedy < -squidupspeed then
					self.speedy = -squidupspeed
				end
				
				if math.abs(self.x - self.upx) >= 2 then
					self.state = "downward"
					self.quad = squidquad[spriteset][2]
					self.downy = self.y
					self.speedx = 0
				end
				
			elseif self.state == "downward" then
				self.speedy = squidfallspeed
				if self.y > self.downy + squiddowndistance then
					self.state = "idle"
					self.quad = squidquad[spriteset][1]
				end
			end
		end
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
	else
		self.speedx = 0
		self.speedy = 0
	end
end

function squid:shotted(dir) --fireball, star, turtle
	playsound(shotsound)
	self.shot = true
	self.active = false
	self.gravity = shotgravity
	self.speedy = -shotjumpforce
	self.direction = dir or "right"
	if self.direction == "left" then
		self.speedx = -shotspeedx
	else
		self.speedx = shotspeedx
	end
end

function squid:stomp()
	self:shotted("left")
end

function squid:freeze()
	self.frozen = true
end

function squid:rightcollide(a, b)
	if self:globalcollide() then
		return false
	end
	
end

function squid:leftcollide(a, b)
	if self:globalcollide() then
		return false
	end
	
end

function squid:ceilcollide(a, b)
	if self:globalcollide() then
		return false
	end
	
end

function squid:floorcollide(a, b)
	if self:globalcollide() then
		return false
	end
	
end

function squid:globalcollide(a, b)
	return true	
end

function squid:dotrack()
	self.track = true
	self.animationtimer = 0
end

function squid:dosupersize()
	if self.color == "nanny" then
		for i = 1, 4 do
			supersizeentity(self.child[i])
		end
	end
end