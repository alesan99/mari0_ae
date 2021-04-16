rockywrench = class:new()

function rockywrench:init(x, y)
	--PHYSICS STUFF
	self.cox = x
	self.coy = y
	self.x = x-14/16
	self.y = y-12/16
	self.speedy = 0
	self.speedx = 0
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.gravity = 0
	self.category = 4
	
	self.mask = {true, 
					true, false, false, false, true,
					false, true, false, true, false,
					false, false, true, false, false,
					true, true, false, false, false,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	
	self.portalable = false
	self.autodelete = true
	self.freezable = true
	self.frozen = false
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = rockywrenchimg
	self.quad = rockywrenchquad[spriteset][2]
	self.offsetX = 6
	self.offsetY = 4
	self.quadcenterX = 8
	self.quadcenterY = 24
	self.customscissor2 = {x-1, y-2, 1, 2}
	
	self.rotation = 0
	self.direction = "left"
	self.animationdirection = "left"
	self.animationtimer = 0
	self.freezetimer = 0
	self.shot = false

	self.nospawnanimation = true
	self.pipespawnmax = 1
	
	self.timer = 0
	self.inn = true
	self.wrench = false
	self.trackable = false
end

function rockywrench:update(dt)
	if self.frozen then
		return
	end
	
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		self.y = self.y+self.speedy*dt
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > goombaanimationspeed do
			if self.animationdirection == "left" then
				self.animationdirection = "right"
			else
				self.animationdirection = "left"
			end
			self.animationtimer = self.animationtimer - goombaanimationspeed
		end
		return false
	else
		self.timer = self.timer + dt
		if self.timer < rockywrenchintime then
			self.inn = true
			self.y = self.coy
			self.quad = rockywrenchquad[spriteset][2]
			self.active = false
		elseif self.timer < rockywrenchintime+rockywrenchmovetime then
			self.inn = false
			self.speedy = (-self.height+.5/16)/rockywrenchmovetime
			self.quad = rockywrenchquad[spriteset][1]
			self.active = true
		elseif self.timer < rockywrenchintime+rockywrenchmovetime+rockywrenchwrenchtime then
			self.inn = false
			self.y = self.coy-self.height+.5/16 --.5/16 fixes visual bug
			self.quad = rockywrenchquad[spriteset][1]
		elseif self.timer < rockywrenchintime+rockywrenchmovetime+rockywrenchwrenchtime+rockywrenchnowrenchtime then
			self.inn = false
			self.y = self.coy-self.height+.5/16
			self.quad = rockywrenchquad[spriteset][2]
			if not self.wrench then
				local obj
				if self.direction == "right" then
					obj = wrench:new(self.x+2/16, self.y-6/16, "right")
				else
					obj = wrench:new(self.x+8/16, self.y-6/16, "left")
				end
				self.wrench = true
				table.insert(objects["wrench"], obj)
			end
		else
			self.inn = false
			self.quad = rockywrenchquad[spriteset][2]
			self.speedy = (self.height+.5/16)/rockywrenchmovetime
			self.wrench = false
		end
		self.y = math.max(self.coy-self.height, math.min(self.coy, self.y))
		
		while self.timer > rockywrenchtotaltime do
			self.timer = self.timer - rockywrenchtotaltime
		end
		
		if self.inn then
			self.animationdirection = "right"
		else
			local closestplayer = 1 --find closest player
			for i = 2, players do
				local v = objects["player"][i]
				if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
					closestplayer = i
				end
			end
			
			if objects["player"][closestplayer].x+objects["player"][closestplayer].width/2 > self.x+self.width/2 then
				self.direction = "right"
				self.animationdirection = "left"
			elseif objects["player"][closestplayer].x+objects["player"][closestplayer].width/2 < self.x+self.width/2 then
				self.direction = "left"
				self.animationdirection = "right"
			end
		end
		
		return false
	end
end

function rockywrench:stomp(cause)
	self:shotted(self.animationdirection, true)
end

function rockywrench:shotted(dir, stomp)
	if stomp then
		playsound(stompsound)
	else
		playsound(shotsound)
	end
	self.shot = true
	self.speedy = -shotjumpforce
	self.direction = dir or "right"
	self.active = false
	self.gravity = shotgravity
	self.customscissor2 = nil
	self.quad = rockywrenchquad[spriteset][3]
end

function rockywrench:freeze()
	self.frozen = true
end

function rockywrench:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function rockywrench:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function rockywrench:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function rockywrench:globalcollide(a, b)
	if a == "bulletbill" or a == "bigbill" then
		if b.killstuff ~= false then
			return true
		end
	end
	if a == "fireball" or a == "player" then
		return true
	end
	if self.t == "spikeyfall" and a == "lakito" then
		return true
	end
end

function rockywrench:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function rockywrench:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end
-------------------------------------------
wrench = class:new()

function wrench:init(x, y, dir)
	--PHYSICS STUFF
	self.x = x
	self.y = y
	self.speedx = 0
	self.speedy = 0
	self.width = 8/16
	self.height = 8/16
	self.static = false
	self.active = true
	self.category = 4
	self.mask = {	true, 
					true, false, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true}
	self.gravity = 0
	self.autodelete = true
	self.delete = false
	self.targety = self.y
	self.starty = self.y
	self.dir = dir or "left"
	if self.dir == "left" then
		self.speedx = -3.5
	else
		self.speedx = 3.5
	end
	self.portalable = false

	--IMAGE STUFF
	self.drawable = true
	self.graphic = wrenchimg
	self.quad = wrenchquad[1]
	self.offsetX = 4
	self.offsetY = 4
	self.quadcenterX = 5
	self.quadcenterY = 5
	self.quadi = 1
	self.timer = 0
	self.lifetimer = 0
	self.rotation = 0
	
	local closestplayer = 1
	for i = 2, players do
		local v = objects["player"][i]
		if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
			closestplayer = i
		end
	end
	if objects["player"][closestplayer] then
		self.targety = math.min(self.y+3, math.max(self.y-3, objects["player"][closestplayer].y))
		if self.targety > self.y then
			self.speedy = 3.5
		else
			self.speedy = -3.5
		end
	end
end

function wrench:update(dt)
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
	
	--animate
	self.timer = self.timer + dt
	while self.timer > staranimationdelay do
		self.quadi = self.quadi + 1
		if self.quadi == 5 then
			self.quadi = 1
		end
		self.quad = wrenchquad[self.quadi]
		self.timer = self.timer - staranimationdelay
	end
	
	if self.targety > self.starty and self.y > self.targety then
		self.speedy = 0
	elseif self.targety < self.starty and self.y < self.targety then
		self.speedy = 0
	end
	
	self.lifetimer = self.lifetimer + dt
	if self.lifetimer >= 10 then
		return true
	end
	
	if self.y > mapheight+3 or self.delete then
		return true
	else
		return false
	end
end

function wrench:shotted(dir)
	self.shot = true
	self.active = false
	self.delete = true
end

function wrench:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function wrench:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function wrench:globalcollide(a, b)
	if a == "player" then
		self:shotted()
		return true
	end
end

function wrench:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function wrench:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function wrench:passivecollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end