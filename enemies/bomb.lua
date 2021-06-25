bomb = class:new()

local bombspeed = 2
local bombkickspeed = 10
local bombkickspeedy = 10

function bomb:init(x, y)
	--PHYSICS STUFF
	self.x = x-6/16
	self.y = y-11/16
	self.speedy = 0
	self.speedx = -bombspeed
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.category = 32
	self.gravity = 80
	
	self.mask = {	true, 
					false, false, false, false, true,
					false, true, false, true, false,
					false, false, true, false, false,
					false, true, false, false, false,
					false, false, true, false, false,
					true, false, true, true, false,
					false, true}
	
	self.emancipatecheck = true
	self.autodelete = true
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = bombimage
	self.quad = bombquad[spriteset][1]
	self.offsetX = 6
	self.offsetY = 3
	self.quadcenterX = 8
	self.quadcenterY = 8
	self.quadi = 5
	
	self.timer = 0
	
	self.rotation = 0 --for portals
	
	self.direction = "left"
	self.animationtimer = 0
	
	self.animationdirection = "right"
	
	self.falling = false
	
	self.dead = false
	self.deathtimer = 0
	
	self.freezable = true
	self.freezetimer = 0
	
	self.shot = false
	
	self.stomped = false
	self.explodetimer = 0
	
	self.explosion = false
	self.explosiontimer = 0

	self.meltice = true --makes custom fire enemies pass through
end

function bomb:update(dt)
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
		if self.speedx > 0 then
			self.speedx = math.max(0, self.speedx - friction*dt*bombspeed)
		elseif self.speedx < 0 then
			self.speedx = math.min(0, self.speedx + friction*dt*bombspeed)
		end
		return false
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
	
	elseif self.explosion then
		self.timer = self.timer + dt
		while self.timer > 0.1 do
			self.quadi = self.quadi + 1
			if self.quadi == 8 then
				self.quadi = 7
			end
			self.quad = fireballquad[self.quadi]
			self.timer = self.timer - 0.1
		end
		self.explosiontimer = self.explosiontimer + dt
		if self.explosiontimer > 0.5 then
			return true
		end
	elseif self.stomped then
		self.explodetimer = self.explodetimer + dt
		if self.explodetimer > 3 then
			self:explode()
		end

		if not self.falling then
			if self.speedx > 0 then
				self.speedx = math.max(0, self.speedx - friction*dt)
			elseif self.speedx < 0 then
				self.speedx = math.min(0, self.speedx + friction*dt)
			end
		end
	else
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > goombaanimationspeed do
			self.animationtimer = self.animationtimer - goombaanimationspeed
			if self.quad == bombquad[spriteset][1]  then
				self.quad = bombquad[spriteset][2]
			else
				self.quad = bombquad[spriteset][1]
			end
		end
		
		if self.speedx > 0 then
			if self.speedx > bombspeed then
				self.speedx = self.speedx - friction*dt*bombspeed
				if self.speedx < bombspeed then
					self.speedx = bombspeed
				end
			elseif self.speedx < bombspeed then
				self.speedx = self.speedx + friction*dt*bombspeed
				if self.speedx > bombspeed then
					self.speedx = bombspeed
				end
			end
		else
			if self.speedx < -bombspeed then
				self.speedx = self.speedx + friction*dt*bombspeed
				if self.speedx > -bombspeed then
					self.speedx = -bombspeed
				end
			elseif self.speedx > -bombspeed then
				self.speedx = self.speedx - friction*dt*bombspeed
				if self.speedx < -bombspeed then
					self.speedx = -bombspeed
				end
			end
		end
			
		return false
	end
end

function bomb:explode()
	self.explodetimer = 0
	self.explosion = true
	self.stompbounce = false
	self.freezable = false
	self.trackable = false
	self.dead = true
	
	local oldw, oldh = self.width, self.height
	self.width = 2
	self.height = 2
	if self.supersized then
		self.width = self.width*2
		self.height = self.height*2
	end
	self.x = self.x+oldw/2 - self.width/2
	self.y = self.y+oldh/2 - self.height/2
	self.speedx = 0
	self.speedy = 0
	self.static = true
	self.activestatic = true
	
	if self.supersized then
		self.animationscalex = self.animationscalex*2
		self.animationscaley = self.animationscaley*2
	else
		self.animationscalex = 2
		self.animationscaley = 2
	end
	self.offsetX = 16
	self.offsetY = -8
	self.quadi = 5
	self.graphic = fireballimg
	self.quad = fireballquad[self.quadi]
	
	for x = math.ceil(self.x), math.ceil(self.x+self.width) do
		for y = math.ceil(self.y), math.ceil(self.y+self.height) do
			local inmap = true
			if x < 1 or x > mapwidth or y < 1 or y > mapheight then
				inmap = false
			end
			if inmap then
				local r = map[x][y]
				if r then
					if tilequads[r[1]].breakable or (tilequads[r[1]].debris and blockdebrisquads[tilequads[r[1]].debris]) then
						destroyblock(x, y, "nopoints")
					end
					if objects["frozencoin"][tilemap(x, y)] then
						objects["frozencoin"][tilemap(x, y)]:meltice("destroy")
						hit = true
					end
				end
			end
		end
	end
	
	playsound(boomsound)
end

function bomb:stomp()
	self.quad = bombquad[spriteset][3]
	self.stomped = true
	self.stompbounce = true
	self.speedx = 0
	self.light = 1
end

function bomb:shotted(dir)
	if self.explosion then
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

function bomb:shotted2(dir)
	if self.stomped then
		self:kick(dir)
	else
		self:stomp()
	end
end

function bomb:hitbelow(dir)
	if not self.stomped then
		self:stomp()
	end
	self.falling = true
	self.speedy = -mushroomjumpforce
	if dir == "left" then
		self.speedx = -shotspeedx
	else
		self.speedx = shotspeedx
	end
end

function bomb:freeze()
	if not self.explosion then
		self.speedx = 0
		self.speedy = 0
		self.frozen = true
	end
end

function bomb:kick(dir)
	if not (math.abs(self.speedx) < bombkickspeed*0.8) then
		return false
	end
	playsound(shotsound)
	if dir == "left" then
		self.speedx = -bombkickspeed
		self.animationdirection = "right"
	else
		self.speedx = bombkickspeed
		self.animationdirection = "left"
	end
	self.speedy = -bombkickspeedy
end

function bomb:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	if self.stomped then
		self.speedx = math.abs(self.speedx/2) --reduce speed a bit so it doesn't bounce as far
		self.animationdirection = "left"
	elseif not self.explosion then
		self.speedx = bombspeed
		self.animationdirection = "left"
	end
	
	return false
end

function bomb:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	if self.stomped then
		self.speedx = -math.abs(self.speedx/2)
		self.animationdirection = "right"
	elseif not self.explosion then
		self.speedx = -bombspeed
		self.animationdirection = "right"
	end
	
	return false
end

function bomb:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end

	if a == "muncher" and (not self.explosion) and (not b.static) then
		self:explode()
		return false
	end
end

function bomb:globalcollide(a, b)
	if self.stomped and not self.explosion then
		if a == "player" then
			if b.x+b.width/2 > self.x+self.width/2 then
				self:kick("left")
			else
				self:kick("right")
			end
			return true
		end
	end
	
	if a == "bulletbill" or a == "bigbill" then
		if b.killstuff ~= false then
			return true
		end
	end

	if (not self.stomped) and (a == "castlefirefire" or a == "longfire" or a == "plantfire" or a == "brofireball" or a == "fire" or a == "upfire" or a == "angrysun" or (b and b.meltsice)) then
		playsound(shotsound)
		self:stomp()
		return true
	end
	
	if a == "fireball" or a == "player" then
		return true
	end
	
	if self.explosion then
		if a == "enemy" and not (b.resistsenemykill or b.resistseverything) then
			if b:shotted("right", false, false, true) ~= false then
				addpoints(b.firepoints or 200, self.x, self.y)
			end
		elseif (fireballkill[a] and (not b.resistsenemykill)) or a == "bomb" then
			b:shotted("right")
		elseif a == "powblock" then
			b:hit()
		elseif a == "flipblock" then
			b:hit()
			self.activestatic = false
		end
	end
end

function bomb:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.falling = false
end

function bomb:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end

function bomb:emancipate(a)
	self:shotted()
end

function bomb:laser()
	self:shotted()
end