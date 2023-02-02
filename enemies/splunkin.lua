splunkin = class:new()

function splunkin:init(x, y, t)
	--PHYSICS STUFF
	self.x = x-6/16
	self.y = y-11/16
	
	self.speedy = 0
	self.speedx = -2
	self.fast = false
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.category = 4
	self.hp = splunkinhealth
	
	self.mask = {	true, 
					false, false, false, false, true,
					false, true, false, true, false,
					false, false, true, false, false,
					true, true, false, false, false,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	
	self.emancipatecheck = true
	self.autodelete = true
	
	--IMAGE STUFF
	self.drawable = true
	
	self.t = t or "splunkin"
	
	self.graphic = splunkinimage
	self.quad = splunkinquad[spriteset][1]
	self.quadi = 1
	self.quadset = 1
	
	self.offsetX = 6
	self.offsetY = 3
	self.quadcenterX = 8
	self.quadcenterY = 8
	
	self.rotation = 0 --for portals
	
	self.direction = "left"
	self.animationtimer = 0
	self.animationdirection = "left"
	
	self.falling = false
	
	self.dead = false
	self.deathtimer = 0
	
	self.shot = false

	self.freezable = true
	self.frozen = false
end

function splunkin:update(dt)
	--rotate back to 0 (portals)
	self.rotation = math.fmod(self.rotation, math.pi*2)
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
	
	if self.dead then
		self.deathtimer = self.deathtimer + dt
		if self.deathtimer > splunkindeathtime then
			return true
		else
			return false
		end
		
	elseif self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
		
	else
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > splunkinanimationspeed do
			self.animationtimer = self.animationtimer - splunkinanimationspeed
			if self.quadi == 1 then
				self.quadi = 2
			else
				self.quadi = 1
			end
			self.quad = splunkinquad[spriteset][self.quadi+3*(self.quadset-1)]
		end
		
		if self.fast == false then
			if self.speedx > 0 then
				if self.speedx > 2 then
					self.speedx = self.speedx - friction*dt*2
					if self.speedx < 2 then
						self.speedx = -2
					end
				elseif self.speedx < 2 then
					self.speedx = -2 + friction*dt*2
					if self.speedx > 2 then
						self.speedx = 2
					end
				end
			else
				if self.speedx < -2 then
					self.speedx = self.speedx + friction*dt*2
					if self.speedx > -2 then
						self.speedx = -2
					end
				elseif self.speedx > -2 then
					self.speedx = self.speedx - friction*dt*2
					if self.speedx < -2 then
						self.speedx = -2
					end
				end
			end
		else
			if self.speedx > 0 then
				if self.speedx > 4 then
					self.speedx = self.speedx - friction*dt*2
					if self.speedx < 4 then
						self.speedx = 4
					end
				elseif self.speedx < 4 then
					self.speedx = self.speedx + friction*dt*2
					if self.speedx > 4 then
						self.speedx = 4
					end
				end
			else
				if self.speedx < -4 then
					self.speedx = self.speedx + friction*dt*2
					if self.speedx > -4 then
						self.speedx = -4
					end
				elseif self.speedx > -4 then
					self.speedx = self.speedx - friction*dt*2
					if self.speedx < -4 then
						self.speedx = -4
					end
				end
			end
		end
			
		return false
	end
end

function splunkin:stomp()--hehe splunkin stomp
	self.quadset = 2
	self.quad = splunkinquad[spriteset][4]
	self.hp = self.hp - 1
	self.fast = true
	if self.hp == 0 then
		self.dead = true
		self.active = false
		self.quad = splunkinquad[spriteset][6]
	end
end

function splunkin:shotted(dir) --fireball, star, turtle
	self.quadset = 2
	self.quad = splunkinquad[spriteset][4]
	self.hp = self.hp - 1
	self.fast = true
	if self.frozen then
		self.hp = 0
	end
	if self.hp <= 0 then
		playsound(shotsound)
		self.shot = true
		self.speedy = -shotjumpforce
		self.direction = dir or "right"
		self.active = false
		self.gravity = shotgravity
		if self.direction == "left" then
			self.speedx = -shotspeedx
		else
			self.speedx = shotspeedx
		end
	end
end

function splunkin:freeze()
	self.freezetimer = 0
	self.frozen = true
end

function splunkin:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	if self.fast == false then
		self.speedx = 2
	else
		self.speedx = 4
	end
	
	return false
end

function splunkin:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	if self.fast == false then
		self.speedx = -2
	else
		self.speedx = -4
	end
	
	return false
end

function splunkin:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function splunkin:globalcollide(a, b)
	if a == "bulletbill" or a == "bigbill" then
		if b.killstuff ~= false then
			return true
		end
	end
	
	if a == "fireball" or a == "player" then
		return true
	end
end

function splunkin:startfall()

end

function splunkin:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function splunkin:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end

function splunkin:emancipate(a)
	self:shotted()
end

function splunkin:laser()
	self:shotted()
end