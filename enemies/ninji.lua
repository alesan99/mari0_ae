ninji = class:new()

function ninji:init(x, y, t)
	--PHYSICS STUFF
	self.x = x-6/16
	self.y = y-11/16
	self.speedy = 0
	self.speedx = 0
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
	self.graphic = ninjiimage
	self.quad = goombaquad[spriteset][1]
	self.offsetX = 6
	self.offsetY = 3
	self.quadcenterX = 8
	self.quadcenterY = 8
	
	self.rotation = 0 --for portals
	
	self.direction = "left"
	self.animationtimer = 0
	self.t = t or "ninji"
	
	self.falling = false
	
	self.jump = false
	self.jumptimer = 0
	
	self.shot = false
end

function ninji:update(dt)
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

	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
		
	else
	
		if self.jump then
			self.jumptimer = self.jumptimer + dt
			if self.jumptimer > 0.5 then
				self.quad = goombaquad[spriteset][2]
				self.jump = false
				self.jumptimer = 0
				if lowgravity then
					self.speedy = -ninjijumpforce*0.4
				else
					self.speedy = -ninjijumpforce
				end
			else
				self.quad = goombaquad[spriteset][1]
			end
		end
		
		local pl = 1
		for i = 2, players do
			if math.abs(objects["player"][i].x + 14/16 - self.x) < math.abs(objects["player"][pl].x + 14/16 - self.x) then
				pl = i
			end
		end

		if objects["player"][pl].x + 14/16 > self.x then
			self.animationdirection = "left"
		elseif objects["player"][pl].x + 14/16 < self.x then
			self.animationdirection = "right"
		end
		
		if self.speedx > 0 then
			if self.speedx > 0 then
				self.speedx = self.speedx - friction*dt*2
				if self.speedx < 0 then
					self.speedx = 0
				end
			elseif self.speedx < 0 then
				self.speedx = self.speedx + friction*dt*2
				if self.speedx > 0 then
					self.speedx = 0
				end
			end
		else
			if self.speedx < -0 then
				self.speedx = self.speedx + friction*dt*2
				if self.speedx > -0 then
					self.speedx = -0
				end
			elseif self.speedx > -0 then
				self.speedx = self.speedx - friction*dt*2
				if self.speedx < -0 then
					self.speedx = -0
				end
			end
		end
		
		return false
	end
end

function ninji:stomp()
	self.jump = false
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

function ninji:shotted(dir) --fireball, star, turtle
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

function ninji:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	return true
end

function ninji:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	return true
end

function ninji:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function ninji:globalcollide(a, b)
	if a == "bulletbill" or a == "bigbill" then
		if b.killstuff ~= false then
			return true
		end
	end
	
	if a == "fireball" or a == "player" then
		return true
	end
end

function ninji:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.jump = true
	self.quad = goombaquad[spriteset][1]
	self.speedy = 0
end

function ninji:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end

function ninji:emancipate(a)
	self:shotted()
end

function ninji:laser()
	self:shotted()
end