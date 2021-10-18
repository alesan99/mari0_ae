drybones = class:new()

function drybones:init(x, y, t)
	--PHYSICS STUFF
	self.x = x-6/16
	self.y = y-11/16
	self.speedy = 0
	self.speedx = -drybonesspeed
	--self.gravity = 80
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.category = 5
	
	self.mask = {	true, 
					false, false, false, false, true,
					false, true, false, true, false,
					false, false, true, false, false,
					true, true, false, false, true,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	
	self.autodelete = true
	self.t = t or "drybones"
	self.flying = false
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = drybonesimage
	self.quad = drybonesquad[spriteset][1]
	self.offsetX = 6
	self.offsetY = 0
	self.quadcenterX = 8
	self.quadcenterY = 19
	
	self.rotation = 0
	self.direction = "left"
	self.animationdirection = "right"
	self.animationtimer = 0
	
	--self.returntilemaskontrackrelease = true
	if self.t == "drybeetle" then
		self.graphic = drybeetleimg
		self.quad = starquad[spriteset][1]
		self.quadcenterY = 8
		self.offsetY = 3
		
		self.spiked = false
		self.timer = 0
	elseif self.t == "boocrawler" or self.t == "boocrawlerup" then
		self.graphic = boocrawlerimg
		self.quadi = 5
		self.quad = boocrawlerquad[spriteset][self.quadi]
		self.quadcenterX = 16
		self.quadcenterY = 8
		self.offsetX = 6
		self.offsetY = 3

		if self.t == "boocrawlerup" then
			self.gravity = -yacceleration
			self.upsidedown = true
			self.offsetY = 1
			self.y = y-14/16
		end
		self.t = "boocrawler"
		self.light = 1
		
		self.spiked = true
		self.timer = 0
		self.speedx = -barrelspeed
		self.mask[4] = true

		self.trackable = false
	end
	
	self.small = false
	self.moving = true
	
	self.falling = false
	
	self.shot = false
	
	self.bonepile = false
	self.deathtimer = 0
	self.freezable = true
	self.freezetimer = 0
end	

function drybones:func(i) -- 0-1 in please
	return (-math.cos(i*math.pi*2)+1)/2
end

function drybones:update(dt)
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
	
	if self.bonepile and (not self.frozen) then
		self.deathtimer = self.deathtimer + dt
		if self.deathtimer > 7 then
			self.quadcenterX = 8
			self.quadcenterY = 19
			self.offsetY = 0
			if self.t == "drybeetle" then
				self.graphic = drybeetleimg
				self.quad = starquad[spriteset][1]
				self.quadcenterY = 8
				self.offsetY = 3
			else
				self.graphic = drybonesimage
				self.quad = drybonesquad[spriteset][1]
			end
			self.small = false
			self.static = false
			self.active = true
			self.bonepile = false
			self.mask = {	true, 
				false, false, false, false, true,
				false, true, false, true, false,
				false, false, true, false, false,
				true, true, false, false, true,
				false, true, true, false, false,
				true, false, true, true, true,
				false, true}
			self.deathtimer = 0
			return false
		elseif self.deathtimer < 0.2 or self.deathtimer > 6.8 then
			if self.quad == drybonesquad[spriteset][4] then
				self.quad = drybonesquad[spriteset][3]
				self.quadcenterX = 11
			end
			return false
		else
			if self.quad == drybonesquad[spriteset][3] then
				self.quad = drybonesquad[spriteset][4]
				self.quadcenterX = 8
			end
			return false
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
	elseif not self.frozen then
		if not self.spiked and not (self.t == "drybeetle" and self.timer > 2.5) then
			if self.speedx > 0 then
				self.animationdirection = "left"
			else
				self.animationdirection = "right"
			end
		end
		--drybones turn around
		if self.falling == false and self.flying == false and self.small == false then
			--check if nothing below
			local x = math.floor(self.x + self.width/2+1)
			local y = math.floor(self.y + self.height+1.5)
			if self.upsidedown then
				y = math.floor(self.y + .5)
			end
			if inmap(x, y) and tilequads[map[x][y][1]].collision == false and ((inmap(x+.5, y) and tilequads[map[math.ceil(x+.5)][y][1]].collision) or (inmap(x-.5, y) and tilequads[map[math.floor(x-.5)][y][1]].collision)) then
				if self.speedx < 0 then
					self.animationdirection = "left"
					self.x = x-self.width/2
				else
					self.animationdirection = "right"
					self.x = x-1-self.width/2
				end
				self.speedx = -self.speedx
			end
		end
	
		if self.small == false and self.t ~= "boocrawler" then
			local q = drybonesquad
			if self.t == "drybeetle" then
				q = starquad
			end
			self.animationtimer = self.animationtimer + dt
			while self.animationtimer > drybonesanimationspeed do
				self.animationtimer = self.animationtimer - drybonesanimationspeed
				if self.quad == q[spriteset][1] then
					self.quad = q[spriteset][2]
				else
					self.quad = q[spriteset][1]
				end
			end
		end
		
		if self.t == "drybeetle" and (not self.small) and (not self.tracked) then --dry beetle movement
			self.timer = self.timer + dt
			if self.timer > 3.8 then
				self.spiked = false
				if self.supersized then
					self.stompbounceifsmall = true
				end
				self.quad = starquad[spriteset][1]
				if self.animationdirection == "right" then
					self.speedx = -drybonesspeed
				else
					self.speedx = drybonesspeed
				end
				self.timer = 0
			elseif self.timer > 2.5 then
				if self.timer < 2.7 or self.timer > 3.6 then
					self.spiked = false
					if self.supersized then
						self.stompbounceifsmall = true
					end
					self.quad = starquad[spriteset][3]
				else
					self.spiked = true
					self.stompbounceifsmall = false
					self.quad = starquad[spriteset][4]
				end
				self.speedx = 0
			end
		elseif self.t == "boocrawler" then --boo crawler movement
			self.timer = self.timer + dt
			if self.timer > 5 then --show
				if self.quadi < 5 then
					self.speedx = 0
					self.animationtimer = self.animationtimer + dt
					while self.animationtimer > barrelanimationspeed do
						self.animationtimer = self.animationtimer - barrelanimationspeed
						self.quadi = math.min(5, self.quadi + 1)
					end
					if self.quadi > 0 then
						self.quad = boocrawlerquad[spriteset][self.quadi]
						self.drawable = true
						self.light = 1
					end
				else
					if self.animationdirection == "right" then
						self.speedx = -barrelspeed
					else
						self.speedx = barrelspeed
					end
					self.mask[3] = false
					self.timer = 0
				end
			elseif self.timer > 3 then --hide
				if self.quadi > 0 then
					self.speedx = 0
					self.animationtimer = self.animationtimer + dt
					while self.animationtimer > barrelanimationspeed do
						self.animationtimer = self.animationtimer - barrelanimationspeed
						self.quadi = math.max(0, self.quadi - 1)
					end
					if self.quadi > 0 then
						self.quad = boocrawlerquad[spriteset][self.quadi]
					else
						self.drawable = false
						self.light = false
					end
				elseif not self.mask[3] then
					if self.animationdirection == "right" then
						self.speedx = -barrelspeed
					else
						self.speedx = barrelspeed
					end
					self.mask[3] = true
				end
			end
		end
		
		if self.small == false and not self.spiked and not (self.t == "boocrawler" and self.quadi ~= 1 and self.quadi ~= 5) and not (self.t == "drybeetle" and self.timer > 2.5) then
			local speed = drybonesspeed
			if self.t == "boocrawler" then
				speed = barrelspeed
			end
			if self.speedx > 0 then
				if self.speedx > speed then
					self.speedx = self.speedx - friction*dt*2
					if self.speedx < speed then
						self.speedx = speed
					end
				elseif self.speedx < speed then
					self.speedx = self.speedx + friction*dt*2
					if self.speedx > speed then
						self.speedx = speed
					end
				end
			else
				if self.speedx < -speed then
					self.speedx = self.speedx + friction*dt*2
					if self.speedx > -speed then
						self.speedx = -speed
					end
				elseif self.speedx > -speed then
					self.speedx = self.speedx - friction*dt*2
					if self.speedx < -speed then
						self.speedx = -speed
					end
				end
			end
		end
		
		return false
	end
end

function drybones:stomp(x, b)
	if self.small == false then
		playsound(blockbreaksound)
		self.small = true
		self.quadcenterY = 19
		self.offsetY = 0
		self.graphic = drybonesimage
		self.quad = drybonesquad[spriteset][3]
		--self.static = true
		--self.active = false
		self.bonepile = true
		self.mask = {	false, 
			false, true, true, true, true,
			true, true, true, true, true,
			true, true, true, true, true,
			true, true, true, true, true,
			true, true, true, true, true,
			true, true, true, true, true,
			true, true}
		if self.t == "drybeetle" then
			self.timer = 0
		end
		self.trackable = false
		self.speedx = 0
		self.speedy = 0
	end
end

function drybones:shotted(dir) --fireball, star, turtle
	if self.small == false then
		playsound(shotsound)
		self.shot = true
		self.small = true
		if self.t == "boocrawler" then
			self.graphic = booimage
			self.quad = booquad[spriteset][1]
			self.offsetX = 6
			self.offsetY = 3
			self.quadcenterX = 8
			self.quadcenterY = 8
		else
			self.graphic = drybonesimage
			self.quad = drybonesquad[spriteset][4]
			self.quadcenterY = 19
			self.offsetY = 0
		end
		self.speedy = -shotjumpforce
		self.direction = dir or "right"
		self.active = false
		self.gravity = shotgravity
		if self.direction == "left" then
			self.speedx = -shotspeedx
		else
			self.speedx = shotspeedx
		end
	else
		return true
	end
end

function drybones:freeze()
	self.frozen = true
	self.speedx = 0
end

function drybones:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end

	if self.small == false then
		self.animationdirection = "left"
		self.speedx = -self.speedx
	else
		return false
	end
end

function drybones:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end

	if self.small == false then
		self.animationdirection = "right"
		self.speedx = -self.speedx
	else
		return false
	end
end

function drybones:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end

function drybones:globalcollide(a, b)
	if a == "bulletbill" or a == "bigbill" then
		if b.killstuff ~= false then
			return true
		end
	end
	if a == "fireball" or a == "player" then
		return true
	end
end

function drybones:emancipate(a)
	self:shotted()
end

function drybones:floorcollide(a, b)
	self.falling = false
	if self.t == "flying" and self.flying then
		if self:globalcollide(a, b) then
			return false
		end
		self.speedy = -drybonesjumpforce
	end
end

function drybones:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if self.upsidedown then
		self.falling = false
	end
end

function drybones:laser()
	self:shotted()
end

function drybones:startfall()
	self.falling = true
end

function drybones:dosupersize()
	self.stompbounceifsmall = true
	self.stompbouncesound = true
end