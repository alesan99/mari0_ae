mole = class:new()

function mole:init(x, y, r)
	--PHYSICS STUFF
	self.x = x-6/16
	self.y = y-11/16
	self.speedy = 0
	self.speedx = -molespeed
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.category = 4
	self.gravity = yacceleration
	
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
	self.inground = true
	self.freezable = true
	self.frozen = false
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = moleimage
	self.quad = molequad[spriteset][1]
	self.offsetX = 6
	self.offsetY = 3
	self.quadcenterX = 8
	self.quadcenterY = 8
	
	self.rotation = 0 --for portals
	
	self.direction = "left"
	self.animationtimer = 0

	self.animationdirection = "left"
	self.movedirection = "left"
	
	self.falling = false
	self.jumptimer = 0
	self.freezetimer = 0
	
	self.shot = false

	self.ground = true
	local v = convertr(r, {"bool"}, true)
	if v[1] ~= nil then
		self.ground = v[1]
	end
	
	if (not self.ground) or (map[math.floor(x+0.5)] and map[math.floor(x+0.5)][math.floor(y+17/16)] 
		and not tilequads[map[math.floor(x+0.5)][math.floor(y+17/16)][1]].collision) then
		self.inground = false
		self.speedx = -molespeed
		if not ground then
			self.quad = molequad[spriteset][3]
		else
			self.quad = molequad[spriteset][2]
		end
		self.gravity = yacceleration
		self.mask = {	true, 
			false, false, false, false, true,
			false, true, false, true, false,
			false, false, true, false, false,
			true, true, false, false, false,
			false, true, true, false, false,
			true, false, true, true, true,
			false, true}
	end
	
	if map[math.floor(x+0.5)] and map[math.floor(x+0.5)][math.floor(y+1/16)] and tilequads[map[math.floor(x+0.5)][math.floor(y+1/16)][1]].collision then
		self.mask = {true}
	end
end

function mole:update(dt)
	local closestplayer = 1 --find closest player
	for i = 2, players do
		local v = objects["player"][i]
		if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
			closestplayer = i
		end
	end
	
	if self.inground then
		self.speedy = 0
		self.speedx = 0
		self.gravity = 0
		self.static = true
		self.active = false
		for i = 1, players do
			local v = objects["player"][i]
			if inrange(v.x+v.width/2, self.x+self.width/2-3, self.x+self.width/2+3) then --no player near
				playsound(blockbreaksound)
				self.speedx = 0
				--self.speedx = -molespeed
				self.static = false
				self.active = true
				self.speedy = -ninjijumpforce
				self.quad = molequad[spriteset][2]
				self.gravity = yacceleration
				self.mask = {	true, 
							false, false, false, false, true,
							false, true, false, true, false,
							false, false, true, false, false,
							true, true, false, false, false,
							false, true, true, false, false,
							true, false, true, true, true,
							false, true}
				self.inground = false
			end
		end
		self.trackable = false
	end
	
	if self.shot == false and self.inground == false and not self.frozen and self.quad ~= molequad[spriteset][2] then
		local p = objects["player"][closestplayer]
		if self.x+self.width/2 > p.x+p.width/2 + molechaserange then
			self.animationdirection = "right"
			self.movedirection = "right"
			
			--self.speedx = -molespeed
		elseif self.x+self.width/2 < p.x+p.width/2 - molechaserange then
			self.animationdirection = "left"
			self.movedirection = "left"
			
			--self.speedx = molespeed
		end
		if self.movedirection == "left" then
			if self.speedx > molespeed then
				self.speedx = self.speedx - moleacceleration*dt
				if self.speedx < molespeed then
					self.speedx = molespeed
				end
			elseif self.speedx < molespeed then
				self.speedx = self.speedx + moleacceleration*dt
				if self.speedx > molespeed then
					self.speedx = molespeed
				end
			end
		else
			if self.speedx < -molespeed then
				self.speedx = self.speedx + moleacceleration*dt
				if self.speedx > -molespeed then
					self.speedx = -molespeed
				end
			elseif self.speedx > -molespeed then
				self.speedx = self.speedx - moleacceleration*dt
				if self.speedx < -molespeed then
					self.speedx = -molespeed
				end
			end
		end
	end
	
	if self.speedy == -ninjijumpforce then
		self.jumptimer = self.jumptimer + dt
		while self.animationtimer > 0.5 do
			self.speedy = -5
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
		
	else
		if self.inground == false and not self.frozen then
			self.animationtimer = self.animationtimer + dt
			while self.animationtimer > moleanimationspeed do
				self.animationtimer = self.animationtimer - moleanimationspeed
				if self.quad == molequad[spriteset][3] then
					self.quad = molequad[spriteset][4]
				else
					self.quad = molequad[spriteset][3]
				end
			end
		end
		
		--check if mole offscreen		
		return false
	end
end

function mole:stomp()
	playsound(shotsound)
	self.shot = true
	self.speedy = -shotjumpforce
	self.speedx = 0
	self.quad = molequad[spriteset][2]
	self.active = false
	self.gravity = shotgravity
end

function mole:shotted(dir) --fireball, star, turtle
	if self.inground then
		return false
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

function mole:freeze()
	self.frozen = true
end

function mole:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.speedx = molebounceforce
	if self.speedy == 0 then
		self.speedy = -5
	end
	return false
end

function mole:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.speedx = -molebounceforce
	if self.speedy == 0 then
		self.speedy = -5
	end
	return false
end

function mole:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function mole:globalcollide(a, b)
	--[[if a == "tile" and self.quad == molequad[spriteset][2] and self.speedy < 0 then
		return true
	end]]
	
	if a == "bulletbill" or a == "bigbill" then
		if b.killstuff ~= false then
			return true
		end
	end
	
	if a == "fireball" or a == "player" then
		return true
	end
end

function mole:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.speedy = 0
end

function mole:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end

function mole:emancipate(a)
	self:shotted()
end

function mole:laser()
	self:shotted()
end