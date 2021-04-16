rocketlauncher = class:new()

function rocketlauncher:init(x, y, t)
	self.x = x
	self.y = y
	self.t = t or false
	self.id = id
	self:randomtime()
	self.timer = self.time-0.5
	self.autodelete = true
end

function rocketlauncher:update(dt)
	self.timer = self.timer + dt
	if self.timer > self.time and self.x > splitxscroll[1] and self.x < splitxscroll[1]+width+2 then
		if self:fire() then
			self.timer = 0
			self:randomtime()
		end
	end
end

function rocketlauncher:fire()
	if #objects["bulletbill"] >= maximumbulletbills then
		return false
	end
	
	--get nearest player
	local pl = 1
	for i = 2, players do
		if math.abs(objects["player"][i].x + 14/16 - self.x) < math.abs(objects["player"][pl].x + 14/16 - self.x) then
			pl = i
		end
	end
	
	if objects["player"][pl].x + 14/16 > self.x + bulletbillrange then
		if mariomakerphysics and inmap(self.x+1, self.y) and tilequads[map[self.x+1][self.y][1]] and tilequads[map[self.x+1][self.y][1]].collision then
			return false
		end
		table.insert(objects["bulletbill"], bulletbill:new(self.x, self.y, "right", self.t))
		return true
	elseif objects["player"][pl].x + 14/16 < self.x - bulletbillrange then
		if mariomakerphysics and inmap(self.x-1, self.y) and tilequads[map[self.x-1][self.y][1]] and tilequads[map[self.x-1][self.y][1]].collision then
			return false
		end
		table.insert(objects["bulletbill"], bulletbill:new(self.x, self.y, "left", self.t))
		return true
	end
end

function rocketlauncher:randomtime()
	local rand = math.random(bulletbilltimemin*10, bulletbilltimemax*10)/10
	if self.t == "homing" then
		rand = math.random(bulletbillchasetimemin*10, bulletbillchasetimemax*10)/10
	end
	self.time = rand
end

----------------------
bulletbill = class:new()
function bulletbill:init(x, y, dir, t)
	self.startx = x-14/16
	--PHYSICS STUFF
	self.x = self.startx
	self.y = y-14/16
	self.speedy = 0
	if dir == "left" then
		self.speedx = -bulletbillspeed
		self.customscissor = {self.x-18/16, self.y-2/16, 1, 1}
	else
		self.speedx = bulletbillspeed
		self.customscissor = {self.x+14/16, self.y-2/16, 1, 1}
	end
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.gravity = 0
	self.rotation = 0
	self.autodelete = true
	self.timer = 0
	self.t = t or false
	
	--IMAGE STUFF
	self.drawable = true
	self.quad = bulletbillquad[spriteset]
	self.offsetX = 6
	self.offsetY = 2
	self.quadcenterX = 8
	self.quadcenterY = 8
	self.graphic = bulletbillimg
	
	self.category = 11
	self.animationdirection = dir
	if self.t == "homing" then
		self.animationdirection = "left"
		self.graphic = homingbulletimg
		self.speedx = -bulletbillchasespeed
		if dir == "right" then
			self.rotation = math.pi
			self.flipped = true
			self.speedx = bulletbillchasespeed
		end
	end
	
	self.mask = {	true, 
					true, false, false, false, true,
					true, true, true, true, true,
					true, false, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					false, true}
					
	self.shot = false
	self.freezable = true
	
	playsound(bulletbillsound)
end

local function unwrap(a)
	while a < 0 do
		a = a + (math.pi*2)
	end
	while a > (math.pi*2) do
		a = a - (math.pi*2)
	end
	return a
end

local function angles(a1, a2)
	local a1 = unwrap(a1)-math.pi
	local a2 = unwrap(a2)-math.pi
	local diff = a1-a2
	if math.abs(diff) < math.pi then
		return a1 > a2
	else
		return diff < 0
	end
end

function bulletbill:update(dt)
	if self.x < self.startx - 1 or self.x > self.startx + 1 then
		self.customscissor = nil
	end
	
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		--check if goomba offscreen
		if self.y > mapheight+3 then
			return true
		else
			return false
		end
	elseif not self.frozen then
		self.timer = self.timer + dt
		if self.timer >= bulletbilllifetime then
			return true
		end
		
		if self.t == "homing" then
			if not self.customscissor and self.timer < bulletbillchasetime then
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
				if objects["player"][closestplayer] then
					local p = objects["player"][closestplayer]
					local angle = -math.atan2((p.x+p.width/2)-(self.x+self.width/2), (p.y+p.height/2)-(self.y+self.height/2-3/16))-math.pi/2
					local turnDir1 = angles(angle, self.rotation)
					if turnDir1 then
						self.rotation = self.rotation + bulletbillturnspeed*dt
					else
						self.rotation = self.rotation - bulletbillturnspeed*dt
					end
					local turnDir2 = angles(angle, self.rotation)
					if turnDir1 ~= turnDir2 then --correct rotation if it over-shoots
						self.rotation = angle
					end
					self.speedx, self.speedy = math.cos(self.rotation+math.pi)*(bulletbillchasespeed), math.sin(self.rotation+math.pi)*(bulletbillchasespeed)
				end
			end
		else
			if self.rotation ~= 0 then
				if math.abs(math.abs(self.rotation)-math.pi/2) < 0.1 then
					self.rotation = -math.pi/2
				else
					self.rotation = 0
				end
			end
			
			if self.speedx < 0 then
				self.animationdirection = "left"
			elseif self.speedx > 0 then
				self.animationdirection = "right"
			elseif self.speedy < 0 then
				self.animationdirection = "right"
			elseif self.speedy > 0 then
				self.animationdirection = "left"
			end
		end
	end
end

function bulletbill:stomp(dir) --fireball, star, turtle
	self.shot = true
	self.speedy = 0
	self.direction = dir or "right"
	self.active = false
	self.gravity = shotgravity
	if self.direction == "left" then
		self.speedx = -shotspeedx
	else
		self.speedx = shotspeedx
	end
end

function bulletbill:shotted(dir)
	self:stomp(dir)
end

function bulletbill:freeze()
	self.frozen = true
	self.static = true
end

function bulletbill:rightcollide(a, b)
	self:globalcollide(a, b)
	return false
end

function bulletbill:leftcollide(a, b)
	self:globalcollide(a, b)
	return false
end

function bulletbill:ceilcollide(a, b)
	self:globalcollide(a, b)
	if a == "player" or a == "box" then
		self:stomp()
	end
	return false
end

function bulletbill:floorcollide(a, b)
	self:globalcollide(a, b)
	return false
end

function bulletbill:globalcollide(a, b)
	if self.killstuff then
		if fireballkill[a] and not b.resistsenemykill then
			b:shotted("left")
			return true
		end
	else
		return true
	end
end

function bulletbill:portaled()
	self.killstuff = true
end

function bulletbill:dospawnanimation(a)
	if a == "pipe" then
		self.customscissor = false
	end
end