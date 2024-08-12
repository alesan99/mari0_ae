bigmole = class:new()

function bigmole:init(x, y)
	--PHYSICS STUFF
	self.x = x-12/16
	self.y = y-23/16
	self.speedy = 0
	self.speedx = -goombaspeed
	self.width = 24/16
	self.height = 24/16
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
	
	self.autodelete = true
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = bigmoleimage
	self.quad = bigmolequad[spriteset][1]
	self.offsetX = 12
	self.offsetY = -1
	self.quadcenterX = 16
	self.quadcenterY = 16
	
	self.rotation = 0 --for portals
	
	self.direction = "left"
	self.animationtimer = 0
	
	self.animationdirection = "right"
	
	self.falling = false
	
	self.shot = false
	self.trackplatform = true

	self.oldx = self.x
	self.oldy = self.y

	self.checktable = {"player","box"} --CARRY PLAYER
end

function bigmole:update(dt)
	if not self.tracked then
		for i, v in pairs(self.checktable) do
			for j, w in pairs(objects[v]) do
				if (not w.ignoreplatform) and w.active then
					if inrange(w.x, self.x-w.width, self.x+self.width) then
						if w.y+w.height >= self.y-(1/16) and w.y+w.height <= self.y+(4/16) and (not w.jumping) then
							if not checkintile(w.x+self.speedx*dt, w.y, w.width, w.height, tileentities, w, "ignoreplatforms") then
								w.oldxplatform = w.x
								w.x = w.x + (self.x-self.oldx)
								w.y = math.min(self.y-w.height, w.y)
								w.falling = false
								w.falloverridestrict = 2
								w.speedy = math.min(self.speedy, w.speedy)
							end
						end
					end
				end
			end
		end
	end
	self.oldx = self.x
	self.oldy = self.y
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
	
	if edgewrapping then --wrap around screen
		local minx, maxx = -self.width, mapwidth
		if self.x < minx then
			self.x = maxx
		elseif self.x > maxx then
			self.x = minx
		end
	end
	
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
		
	else
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > goombaanimationspeed do
			self.animationtimer = self.animationtimer - goombaanimationspeed
			if self.quad == bigmolequad[spriteset][1] then
				self.quad = bigmolequad[spriteset][2]
			else
				self.quad = bigmolequad[spriteset][1]
			end
		end
		
		if self.speedx > 0 then
			if self.speedx > goombaspeed then
				self.speedx = self.speedx - friction*dt*2
				if self.speedx < goombaspeed then
					self.speedx = goombaspeed
				end
			elseif self.speedx < goombaspeed then
				self.speedx = self.speedx + friction*dt*2
				if self.speedx > goombaspeed then
					self.speedx = goombaspeed
				end
			end
		else
			if self.speedx < -goombaspeed then
				self.speedx = self.speedx + friction*dt*2
				if self.speedx > -goombaspeed then
					self.speedx = -goombaspeed
				end
			elseif self.speedx > -goombaspeed then
				self.speedx = self.speedx - friction*dt*2
				if self.speedx < -goombaspeed then
					self.speedx = -goombaspeed
				end
			end
		end
		
		--check if bigmole offscreen		
		return false
	end
end

function bigmole:stomp()

end

function bigmole:shotted(dir, cause) --fireball, star, turtle
	if cause == "powblock" then
		playsound(shotsound)
		self.shot = true
		self.speedy = -shotjumpforce
		self.direction = dir or "right"
		self.active = false
		self.gravity = shotgravity
		self.autodelete = true
		if self.direction == "left" then
			self.speedx = -shotspeedx
		else
			self.speedx = shotspeedx
		end
		return false
	end
	self.speedy = -goombajumpforce
end

function bigmole:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.speedx = goombaspeed
	
	self.animationdirection = "left"
	
	return false
end

function bigmole:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	self.speedx = -goombaspeed
	
	self.animationdirection = "right"
	
	return false
end

function bigmole:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "player" then
		if self.animationdirection == "right" then
			b.speedx = -goombaspeed
		else
			b.speedx = goombaspeed
		end
	end
end

function bigmole:globalcollide(a, b)
	if a == "bulletbill" then
		if b.killstuff ~= false then
			return true
		end
	end
	
	if a == "fireball" or a == "player" then
		return true
	end
end

function bigmole:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.speedy = 0
end

function bigmole:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end

function bigmole:laser()
	self:shotted()
end