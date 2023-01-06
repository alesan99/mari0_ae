sidestepper = class:new()

function sidestepper:init(x, y, t)
	--PHYSICS STUFF
	self.x = x-6/16
	self.y = y-11/16
	self.speedy = 0
	self.speedx = -sidestepperspeed
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.category = 4
	
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
	self.graphic = sidestepperimage
	self.quad = starquad[spriteset][1]
	self.quadi = 1
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

	self.speed = sidestepperspeed
	self.angry = false
	
	self.shot = false
	self.freezable = true
end

function sidestepper:update(dt)
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

	if edgewrapping then --wrap around screen
		local minx, maxx = -self.width, mapwidth
		if self.x < minx then
			self.x = maxx
		elseif self.x > maxx then
			self.x = minx
		end
	end
	
	if self.dead then
		self.deathtimer = self.deathtimer + dt
		if self.deathtimer > sidestepperdeathtime then
			return true
		else
			return false
		end
		
	elseif self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
	elseif self.frozen then
	elseif self.angry then
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > sidestepperanimationspeed/2 do
			self.animationtimer = self.animationtimer - sidestepperanimationspeed/2
			if self.quadi == 4 then
				self.quadi = 3
			else
				self.quadi = 4
			end
			self.quad = starquad[spriteset][self.quadi]
		end	
	else
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > sidestepperanimationspeed do
			self.animationtimer = self.animationtimer - sidestepperanimationspeed
			if self.quadi == 2 then
				self.quadi = 1
			else
				self.quadi = 2
			end
			self.quad = starquad[spriteset][self.quadi]
		end	
		return false
	end
end

function sidestepper:stomp()

end

function sidestepper:freeze()
	self.frozen = true
	if not self.angry then
		self:anger()
		return
	end
end

function sidestepper:hitbelow(dir)
	self:shotted(dir)
	self.speedy = -shotjumpforce
end

function sidestepper:shotted(dir)
	if not self.angry then
		self:anger()
		return
	end
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

function sidestepper:anger()
	self.quad = starquad[spriteset][3]
	self.angry = true
	self.speed = sidestepperspeed*2
	if self.speedx > 0 then
		self.speedx = self.speed
	else
		self.speedx = -self.speed
	end
end

function sidestepper:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	if a == "pixeltile" and b.dir == "right" then
		self.y = self.y - 1/16
		return false
	end
	
	self.speedx = self.speed
	
	return false
end

function sidestepper:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	if a == "pixeltile" and b.dir == "left" then
		self.y = self.y - 1/16
		return false
	end
	
	self.speedx = -self.speed
	
	return false
end

function sidestepper:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function sidestepper:globalcollide(a, b)
	if a == "bulletbill" or a == "bigbill" then
		if b.killstuff ~= false then
			return true
		end
	end
	
	if a == "fireball" or a == "player" then
		return true
	end
end

function sidestepper:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function sidestepper:passivecollide(a, b)
	--self:leftcollide(a, b)
	return false
end

function sidestepper:emancipate(a)
	self:shotted()
end

function sidestepper:laser()
	self:shotted()
end
