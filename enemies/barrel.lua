barrel = class:new()

function barrel:init(x, y, t)
	--PHYSICS STUFF
	self.x = x-6/16
	self.y = y-11/16
	self.speedy = 0
	self.speedx = -barrelspeed
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.category = 4
	self.killstuff = true
	
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
	self.graphic = barrelimage
	self.quad = goombaquad[spriteset][1]
	self.offsetX = 6
	self.offsetY = 3
	self.quadcenterX = 8
	self.quadcenterY = 8
	
	self.rotation = 0 --for portals
	
	self.direction = "left"
	self.animationtimer = 0
	self.t = t or "barrel"
	
	self.graphic = barrelimage
	self.fall = true
	self.quad = goombaquad[spriteset][1]
	
	self.falling = false
	
	self.dead = false
	self.deathtimer = 0
	
	self.shot = false
end

function barrel:update(dt)
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
	
	if self.dead then
		self.deathtimer = self.deathtimer + dt
		if self.deathtimer > barreldeathtime then
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
		while self.animationtimer > barrelanimationspeed do
			self.animationtimer = self.animationtimer - barrelanimationspeed
			if self.t == "barrel" then
				if self.quad == goombaquad[spriteset][1] then
					self.quad = goombaquad[spriteset][2]
				else
					self.quad = goombaquad[spriteset][1]
				end
			end
		end
		
		--check if barrel offscreen		
		return false
	end
end

function barrel:stomp()

end

function barrel:shotted(dir)
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

function barrel:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	playsound(blockhitsound)
	self.speedx = barrelspeed
	
	if self.t == "barrel" then
		self.animationdirection = "left"
	end
	
	return false
end

function barrel:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	playsound(blockhitsound)
	self.speedx = -barrelspeed
	
	if self.t == "barrel" then
		self.animationdirection = "right"
	end
	
	return false
end

function barrel:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function barrel:globalcollide(a, b)
	if a == "bulletbill" or a == "bigbill" then
		if b.killstuff ~= false then
			return true
		end
	end
	
	if a == "fireball" or a == "player" then
		return true
	end
	
	if mariohammerkill[a] and not b.resistsenemykill then
		b:shotted("left")
		return true
	end
end

function barrel:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function barrel:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end

function barrel:emancipate(a)
	self:shotted()
end

function barrel:laser()
	self:shotted()
end