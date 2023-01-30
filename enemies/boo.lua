boo = class:new()

function boo:init(x, y, t)
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
	self.portalable = false
	self.gravity = 0
	
	self.mask = {	true, 
					true, false}
	
	self.emancipatecheck = true
	self.ignoreplatform = true
	self.autodelete = true
	self.light = 1
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = booimage
	self.quad = booquad[spriteset][1]
	self.offsetX = 6
	self.offsetY = 3
	self.quadcenterX = 8
	self.quadcenterY = 8
	
	self.rotation = 0 --for portals
	
	self.direction = "left"
	self.animationtimer = 0
	self.t = t or "boo"
	
	self.animationdirection = "left"
	self.scared = false
	
	self.falling = false
	
	self.dead = false
	self.deathtimer = 0
	
	self.shot = false
end

function boo:update(dt)
	local closestplayer = false
	if self.shot == false and self.scared == false then
		closestplayer = 1 --find closest player
		for i = 2, players do
			local v = objects["player"][i]
			if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
				closestplayer = i
			end
		end
		--Go left or right
		if (not self.track) then
			local relativex, relativey = (objects["player"][closestplayer].x + -self.x), (objects["player"][closestplayer].y + -self.y)
			local distance = math.sqrt(relativex*relativex+relativey*relativey)
			self.speedx, self.speedy = (relativex)/distance*(2), (relativey)/distance*(2)
			self.wat = false
		end
	end

	if not closestplayer then
		self.scared = false
	end

	if levelfinished or levelballfinish then
		self.scared = true
		self.speedy = 0
		self.speedx = 0
		self.quad = booquad[spriteset][2]
		return
	end
	
	--face mario
	if self.shot == false and closestplayer then
		if (self.x+self.speedx*dt) + self.width - 1.5 >= (objects["player"][closestplayer].x - (24/16 - objects["player"][closestplayer].width)) then
			self.animationdirection = "right"
		elseif (self.x+self.speedx*dt) - self.width + 1.5 <= (objects["player"][closestplayer].x + (24/16 + objects["player"][closestplayer].width)) then
			self.animationdirection = "left"
		end
	end
	
	--get scared
	if self.shot == false and ((not self.static) or self.track) and closestplayer then
		local g = objects["player"][closestplayer]
		if self.animationdirection == "right" then
			if (g.portalgun and g.pointingangle > 0) or (g.portalgun == false and g.animationdirection == "left") then
				self.scared = false
				self.quad = booquad[spriteset][1]
			else
				self.scared = true
				if (not self.track) then
					self.speedy = 0
					self.speedx = 0
				end
				self.quad = booquad[spriteset][2]
			end
		elseif self.animationdirection == "left" then
			if (g.portalgun and g.pointingangle < 0) or (g.portalgun == false and g.animationdirection == "right") then
				self.scared = false
				self.quad = booquad[spriteset][1]
			else
				self.scared = true
				if (not self.track) then
					self.speedy = 0
					self.speedx = 0
				end
				self.quad = booquad[spriteset][2]
			end
		end
	end

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
	end
end

function boo:shotted(dir) --fireball, star, turtle
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

function boo:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function boo:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function boo:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function boo:globalcollide(a, b)
	if a == "bulletbill" or a == "bigbill" then
		if b.killstuff ~= false then
			return true
		end
	end
	
	if a == "fireball" or a == "player" then
		return true
	end
end

function boo:startfall()

end

function boo:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function boo:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end

function boo:emancipate(a)
	self:shotted()
end

function boo:laser()
	self:shotted()
end

function boo:dotrack()
	self.track = true
end
