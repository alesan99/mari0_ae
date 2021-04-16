magikoopa = class:new()

function magikoopa:init(x, y)
	--PHYSICS STUFF
	self.x = x-6/16
	self.y = y-23/16
	self.speedy = 0
	self.speedx = 0
	self.width = 12/16
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
	
	self.emancipatecheck = true
	self.autodelete = true
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = magikoopaimg
	self.quad = magikoopaquad[spriteset][1]
	self.quadi = 1
	self.offsetX = 6
	self.offsetY = -3
	self.quadcenterX = 16
	self.quadcenterY = 14
	
	self.rotation = 0 --for portals
	
	self.direction = "left"
	self.animationtimer = 0
	
	self.animationdirection = "left"
	
	self.falling = false
	
	self.timer = 0
	
	self.shot = false
end

function magikoopa:update(dt)
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
		if self.speedx > 0 then
			self.speedx = self.speedx - friction*dt*2
			if self.speedx < 0 then
				self.speedx = 0
			end
		else
			self.speedx = self.speedx + friction*dt*2
			if self.speedx > 0 then
				self.speedx = 0
			end
		end
		
		local closestplayer = 1
		local closestdist = math.sqrt((objects["player"][1].x-self.x)^2+(objects["player"][1].y-self.y)^2)
		for i = 2, players do
			local v = objects["player"][i]
			local dist = math.sqrt((v.x-self.x)^2+(v.y-self.y)^2)
			if dist < closestdist then
				closestdist = dist
				closestplayer = i
			end
		end
		if objects["player"][closestplayer].x + objects["player"][closestplayer].width/2 > self.x + self.width/2 then
			self.animationdirection = "left"
		else
			self.animationdirection = "right"
		end
		self.timer = self.timer + dt
		if self.timer > 3 then
			if (not self.track) then
				self:teleport()
				self.active = false
			end
			self.timer = self.timer - 3
			self.shooted = false
		elseif self.timer > 1.5 then
			self.quadi = math.floor(self.timer*8%2)+1
			if (not self.track) then
				if self.timer > 2.8 then
					self.animationscalex = 1-((self.timer-2.8)/.2)
					if self.supersized then
						self.animationscalex = self.animationscalex*self.supersized
					end
				end
			end
		elseif self.timer > 1 then
			if not self.shooted then
				self.animationscalex = false
				if self.supersized then
					self.animationscalex = self.supersized
				end
				self:shoot(closestplayer)
				self.shooted = true
			end
			self.quadi = 2
		else
			self.quadi = 3
			if (not self.track) then
				if self.timer < .2 then
					self.animationscalex = (self.timer)/.2
					if self.supersized then
						self.animationscalex = self.animationscalex*self.supersized
					end
					self.active = false
				else
					self.active = true
				end
			end
		end
		self.quad = magikoopaquad[spriteset][self.quadi]
		return false
	end
end

function magikoopa:shoot(closestplayer)
	local p = objects["player"][closestplayer]
	local relativex, relativey = ((p.x+p.width/2) + -(self.x+self.width/2)), ((p.y+p.height) + -(self.y+self.height))
	local distance = math.sqrt(relativex*relativex+relativey*relativey)
	local speed = 4
	speedx, speedy = (relativex)/distance*(speed), (relativey)/distance*(speed)
	
	local offsetx, offsety = -8/16, 5/16
	if self.animationdirection == "right" then
		speedx = -math.abs(speedx)
	else
		offsetx = self.width
		speedx = math.abs(speedx)
	end
	local obj = plantfire:new(self.x+offsetx, self.y+offsety, {speedx, speedy, "magikoopa"})
	if self.supersized then
		supersizeentity(obj)
	end
	table.insert(objects["plantfire"], obj)
	playsound(suitsound)
end

function magikoopa:teleport()
	local playertiles = {}
	for i = 1, players do
		local p = objects["player"][i]
		for x = math.floor(p.x)+1, math.floor(p.x+p.width)+1 do
			for y = math.floor(p.y)+1, math.floor(p.y+p.height)+1 do
				table.insert(playertiles, {x,y})
			end
		end
	end
	local teleporttiles = {}
	for y = math.ceil(yscroll)+1, math.floor(yscroll)+height do
		for x = math.ceil(xscroll), math.floor(xscroll)+width do
			if inmap(x, y) and checkfortileincoord(x, y) and inmap(x, y-1) and not checkfortileincoord(x, y-1) then
				local pass = true
				for j, w in ipairs(playertiles) do
					if w[1] == x and w[2] == y then
						pass = false --ignore if inside player
					end
				end
				if pass then
					table.insert(teleporttiles, x)
					table.insert(teleporttiles, y-1)
				end
			end
		end
	end
	if #teleporttiles > 0 then
		local i = math.random(1, #teleporttiles/2)*2
		local x, y = teleporttiles[i-1], teleporttiles[i]
		self.x = x-.5-self.width/2
		self.y = y-self.height
	end
end

function magikoopa:stomp()
	self:shotted()
end

function magikoopa:shotted(dir) --fireball, star, turtle
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
	if self.supersized then
		self.animationscalex = self.supersized
	else
		self.animationscalex = false
	end
end

function magikoopa:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	return false
end

function magikoopa:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	return false
end

function magikoopa:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function magikoopa:globalcollide(a, b)
	if a == "bulletbill" or a == "bigbill" then
		if b.killstuff ~= false then
			return true
		end
	end
	
	if a == "fireball" or a == "player" then
		return true
	end
end

function magikoopa:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function magikoopa:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end

function magikoopa:emancipate(a)
	self:shotted()
end

function magikoopa:laser()
	self:shotted()
end

function magikoopa:dotrack()
	self.track = true
end