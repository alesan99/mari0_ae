cheepcheep = class:new()

local unwrap, angles
local stopchasingdistance = 24

function cheepcheep:init(x, y, color)
	self.x = x-6/16
	self.y = y-12/16
	self.starty = y-12/16
	self.width = 12/16
	self.height = 12/16
	self.rotation = 0 --for portals
	
	if math.random(2) == 1 then
		self.verticalmoving = true
	else
		self.verticalmoving = false
	end
	
	self.color = color
	
	self.active = true
	self.static = false
	self.autodelete = true
	self.gravity = 0
	self.category = 24
	if self.color == 3 then
		self.sleeping = true
		self.bubbletimer = 0
		self.bubbletime = bubblestime[math.random(#bubblestime)]
	end
	
	--IMAGE STUFF
	self.drawable = true
	self.offsetX = 6
	self.offsetY = 3
	self.quadcenterX = 8
	self.quadcenterY = 8
	self.portalable = false
	
	self.mask = {	true, 
					true, false, true, true, true,
					true, true, true, true, true,
					true, false, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true}
	
	if self.color == 3 then
		self.quadi = 2
		self.graphic = sleepfishimg
		self.quad = sleepfishquad[1][1]
		self.verticalmoving = false
		self.category = 4
		self.mask = {	true, 
						false, false, false, false, true,
						false, true, false, true, false,
						false, false, true, false, false,
						true, true, false, false, false,
						false, true, true, false, false,
						true, false, true, true, true,
						true}
		self.srotation = 0
	else
		self.frame = 1
		self.graphic = cheepcheepimg
		self.quad = cheepcheepquad[spriteset][(self.color-1)*2+self.frame]
	end
	self.speedy = 0
	if self.color == 1 then
		self.speedx = -cheepredspeed
	else
		self.speedx = -cheepwhitespeed
	end
	
	self.direction = "up"
	self.animationtimer = 0

	if self.color == 3 then
		self.waterborne = underwater
		local x, y = math.floor(self.x)+1, math.floor(self.y)+1
		if ismaptile(x, y) and map[x][y][1] and tilequads[map[x][y][1]] and tilequads[map[x][y][1]].water then
			self.waterborne = true
		end
		self.water = self.waterborne
		self.initial = 2
	end
		
	self.shot = false
	self.frozen = false
	self.freezetimer = 0
end

function cheepcheep:update(dt)
	--rotate back to 0 (portals)
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

	if self.initial then
		--how many frames since spawn (used for rising water to make it waterborne)
		self.initial = self.initial - 1
		if self.initial < 0 then
			self.initial = false
		end
	end
	
	if self.frozen then
	elseif self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
		
	elseif self.sleeping then
		if not self.track then
			self.speedx = 0
			self.speedy = 0
		end
		
		--bubbles
		self.bubbletimer = self.bubbletimer + dt
		while self.bubbletimer > self.bubbletime do
			self.bubbletimer = self.bubbletimer - self.bubbletime
			self.bubbletime = bubblestime[math.random(#bubblestime)]
			table.insert(bubbles, bubble:new(self.x+6/12, self.y+2/12))
		end
		
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > cheepanimationspeed*1.5 do
			self.animationtimer = self.animationtimer - cheepanimationspeed*1.5
			if self.frame == 1 then
				self.frame = 2
			else
				self.frame = 1
			end
			self.quad = sleepfishquad[1][self.frame]
		end

		local stop = (levelfinished or levelballfinish)
		if onscreen(self.x, self.y, self.width, self.height) and not stop then
			for i = 1, players do --check if player is near
				local v = objects["player"][i]
				if inrange(v.x+v.width/2, self.x+self.width/2-3, self.x+self.width/2+3) then --no player near
					if v.x > self.x then
						self.srotation = math.pi
						self.speedx = cheepredspeed
					else
						self.speedx = -cheepredspeed
					end
					self.sleeping = false
					self.frame = 1
					self.quad = sleepfishquad[2][self.frame]
				end
			end
		end
	else
		local animspeed = cheepanimationspeed
		if self.color == 3 then
			animspeed = cheepanimationfastspeed
		end
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > animspeed do
			self.animationtimer = self.animationtimer - animspeed
			if self.frame == 1 then
				self.frame = 2
			else
				self.frame = 1
			end
			if self.color == 3 then
				self.quad = sleepfishquad[2][self.frame]
			else
				self.quad = cheepcheepquad[spriteset][(self.color-1)*2+self.frame]
			end
		end

		--rip van fish chase
		if self.color == 3 and (not self.track) then
			local closestplayer = 1 --find closest player
			local v = objects["player"][1]
			local relativex, relativey = (v.x + -self.x), (v.y + -self.y)
			local dist = math.sqrt(relativex*relativex+relativey*relativey)
			for i = 2, players do
				local v = objects["player"][i]
				local relativex, relativey = (v.x + -self.x), (v.y + -self.y)
				local distance = math.sqrt(relativex*relativex+relativey*relativey)
				if distance < dist then
					closestplayer = i
				end
			end
			local stop = (levelfinished or levelballfinish)
			if dist > stopchasingdistance or stop then
				--go back to sleep if player is too far
				self.sleeping = true
				self.bubbletimer = 0
				self.quadi = 2
				self.graphic = sleepfishimg
				self.quad = sleepfishquad[1][1]
				self.verticalmoving = false
				self.category = 4
				self.mask = {	true, 
								false, false, false, false, true,
								false, true, false, true, false,
								false, false, true, false, false,
								true, true, false, false, false,
								false, true, true, false, false,
								true, false, true, true, true,
								true}
				self.srotation = 0
				return false
			end
			if objects["player"][closestplayer] then
				local p = objects["player"][closestplayer]
				local angle = -math.atan2((p.x+p.width/2)-(self.x+self.width/2), (p.y+p.height/2)-(self.y+self.height/2-3/16))-math.pi/2
				if p.starred then
					--swim away from player if they have a star
					angle = (angle+math.pi)%(math.pi*2)
				end
				if angles(angle, self.srotation) then
					self.srotation = self.srotation + cheepturnspeed*dt
				else
					self.srotation = self.srotation - cheepturnspeed*dt
				end
				if (self.waterborne and self.water) or (not self.waterborne) then
					self.speedx, self.speedy = math.cos(self.srotation+math.pi)*(cheepchasespeed), math.sin(self.srotation+math.pi)*(cheepchasespeed)
				end
			end
			if self.speedx > 0 then
				self.animationdirection = "left"
			elseif self.speedx < 0 then
				self.animationdirection = "right"
			end
		end
		
		--move up and down
		if self.verticalmoving and (not self.track) then
			if self.direction == "up" then
				self.speedy = -cheepyspeed
				if self.y < self.starty - cheepheight then
					self.direction = "down"
				end
			else
				self.speedy = cheepyspeed
				if self.y > self.starty + cheepheight then
					self.direction = "up"
				end
			end
		end

		if self.color == 3 and self.waterborne then
			--fall if not in waters
			local oldwater = self.water
			self.water = underwater
			if not self.water then
				local x = math.floor(self.x+self.width/2)+1
				local y = math.floor(self.y+self.height/2)+1
				if inmap(x, y) then
					if tilequads[map[x][y][1]].water then
						self.water = true
					end
				end
			end
			if self.risingwater then
				--how many frames since spawn (used for rising water to make it waterborne)
				self.risingwater = self.risingwater - 1
				self.water = true
				if self.risingwater < 0 then
					self.risingwater = false
				end
			end
			if oldwater == false and self.water == true then
				self.speedx = self.speedx*waterdamping
				self.speedy = self.speedy*waterdamping
			end
			if self.water then
				self.gravity = 0
			else
				self.gravity = nil
			end
			
			if self.y+self.height < uwmaxheight and underwater then
				self.speedy = uwpushdownspeed
			end
		end
		
		return false
	end
end

function cheepcheep:shotted(dir) --fireball, star, turtle
	playsound(shotsound)
	self.shot = true
	self.active = false
	self.gravity = shotgravity
	self.speedy = -shotjumpforce
	self.direction = dir or "right"
	if self.direction == "left" then
		self.speedx = -shotspeedx
	else
		self.speedx = shotspeedx
	end
end

function cheepcheep:freeze()
	self.frozen = true
end

function cheepcheep:rightcollide(a, b)
	if self:globalcollide(a,b) then
		return false
	end
end

function cheepcheep:leftcollide(a, b)
	if self:globalcollide(a,b) then
		return false
	end
end

function cheepcheep:ceilcollide(a, b)
	if self:globalcollide(a,b) then
		return false
	end
end

function cheepcheep:floorcollide(a, b)
	if self:globalcollide(a,b) then
		return false
	end
end

function cheepcheep:globalcollide(a, b)
	if self.color == 3 and a == "tile" then
		return false
	end
	return true	
end

function cheepcheep:dotrack()
	self.track = true
end

function unwrap(a)
	while a < 0 do
		a = a + (math.pi*2)
	end
	while a > (math.pi*2) do
		a = a - (math.pi*2)
	end
	return a
end

function angles(a1, a2)
	local a1 = unwrap(a1)-math.pi
	local a2 = unwrap(a2)-math.pi
	local diff = a1-a2
	if math.abs(diff) < math.pi then
		return a1 > a2
	else
		return diff < 0
	end
end