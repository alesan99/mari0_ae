parabeetle = class:new()

function parabeetle:init(x, y, t)
	--PHYSICS STUFF
	self.oldy = y-11/16 --unused
	self.x = x-6/16
	self.y = y-11/16
	self.speedy = 0
	self.gravity = 0
	self.width = 16/16
	self.height = 11/16
	self.static = false
	self.active = true
	self.category = 4
	
	self.mask = {	true, 
					true, false, true, true, true,
					true, true, true, true, true,
					true, false, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true}
	
	self.emancipatecheck = true
	self.autodelete = true
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = parabeetleimage
	self.quad = parabeetlequad[spriteset][1]
	self.offsetX = 8
	self.offsetY = 3
	self.quadcenterX = 8
	self.quadcenterY = 8
	
	self.rotation = 0 --for portals
	
	self.direction = "left"
	self.animationtimer = 0
	self.t = t or "parabeetle"
	
	if self.t == "parabeetle" then
		self.speedx = -3
	elseif self.t == "parabeetleright" then
		self.speedx = 3
	elseif self.t == "parabeetlegreen" then
		self.speedx = -4.5
	elseif self.t == "parabeetlegreenright" then
		self.speedx = 4.5
	end
	self.graphic = parabeetleimg
	self.fall = true
	self.quadi = 1
	self.quad = parabeetlequad[self.quadi]
	
	if self.t == "parabeetleright" then
		self.animationdirection = "left"--well that's strange!
	elseif self.t == "parabeetlegreen" then
		self.quad = parabeetlequad[self.quadi+2]
		self.animationdirection = "right"
	elseif self.t == "parabeetlegreenright" then
		self.quad = parabeetlequad[self.quadi+2]
		self.animationdirection = "left"
	else
		self.animationdirection = "right"
	end
	
	self.falling = false
	
	self.dead = false
	self.deathtimer = 0
	self.timer = 0
	self.stepped = false
	
	self.shot = false
	self.trackplatform = true
end

function parabeetle:update(dt)
	--local checktable = {"player"}
	local on = false
	if not self.tracked then
		--for i, v in pairs(checktable) do
			for j, w in pairs(objects["player"]) do
				if inrange(w.x, self.x-w.width, self.x+self.width) and not w.jumping then
					if inrange(w.y, self.y - w.height - 0.2, self.y - w.height + self.height) then
						if #checkrect(w.x + self.speedx*dt,  self.y - w.height, w.width, w.height, {"exclude", w, {"parabeetle"}}) == 0 then
							if not self.stepped then
								w.jumping = false
								w.falling = false
								self:step(true)
							end
							on = true
							w.falloverride = 2
							w.x = w.x + self.speedx*dt
							w.y = self.y - w.height-- + self.speedy*dt
							w.speedy = math.min(self.speedy, w.speedy)
						end
					end
				end
			end
		--end
	end
	if self.stepped and not on then
		self:step(false)
	end
	
	if self.speedx > 0 then
		self.animationdirection = "left"
	else
		self.animationdirection = "right"
	end
	
	if self.stepped and self.rotation == 0 then --go up when stepped on
		self.speedy = math.max(-3, self.speedy - 7*dt)
	end
	
	if self.shot == false then
		local speed = goombaanimationspeed
		if self.stepped then
			speed = speed/2
		end
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > speed do
			self.animationtimer = self.animationtimer - speed
			if self.quadi == 1 then
				self.quadi = 2
			else
				self.quadi = 1
			end
			if self.t == "parabeetlegreen" or self.t == "parabeetlegreenright" then
				self.quad = parabeetlequad[self.quadi+2]
			else
				self.quad = parabeetlequad[self.quadi]
			end
		end
	end
	
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
		
	else
		if self.y < -3 then
			return true
		end
		return false
	end
end

function parabeetle:shotted(dir) --fireball, star, turtle
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

function parabeetle:step(on)
	if self.rotation ~= 0 then
		return false
	end
	self.stepped = on
	if on then
		self.speedy = 2.4
	else
		self.speedy = 0
	end
end

function parabeetle:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	return false
end

function parabeetle:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	return false
end

function parabeetle:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function parabeetle:globalcollide(a, b)
	if a == "bulletbill" or a == "bigbill" then
		if b.killstuff ~= false then
			return true
		end
	end
	
	if a == "fireball" or a == "player" then
		return true
	end
end

function parabeetle:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function parabeetle:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end

function parabeetle:emancipate(a)
	self:shotted()
end

function parabeetle:laser()
	self:shotted()
end