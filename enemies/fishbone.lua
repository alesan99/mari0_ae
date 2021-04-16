fishbone = class:new()

local homespeed = 4

function fishbone:init(x, y, color)
	self.x = x
	self.y = y
	self.starty = y
	self.width = 18/16
	self.height = 12/16
	self.rotation = 0 --for portals
	
	self.color = color
	
	self.active = true
	self.static = false
	self.autodelete = true
	self.gravity = 0
	self.category = 24
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = fishboneimg
	self.quad = fishbonequad[self.color][1]
	self.offsetX = 9
	self.offsetY = 2
	self.quadcenterX = 12
	self.quadcenterY = 7
	self.portalable = false
	
	self.mask = {	true, 
					true, false, true, true, true,
					true, true, true, true, true,
					true, false, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true}
	
	self.speedy = 0

	self.speedx = -1.8
	
	self.direction = "up"
	self.animationtimer = 0
	
	self.rotation = 0
	
	self.chase = false
	self.startedchase = false
	
	self.wallinvincible = false
	
	self.dontenterclearpipes = true
	self.shot = false
end

function fishbone:update(dt)
	--rotate back to 0 (portals)
	if not self.chase then
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
	end
	
	if (not self.track) then
		if (not self.chase) then
			local closestplayer = 1 --find closest player
			for i = 2, players do
				local v = objects["player"][i]
				if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
					closestplayer = i
				end
			end
			if objects["player"][closestplayer] then
				local p = objects["player"][closestplayer]
				if p.x < self.x and p.x > self.x-10 then
					local angle = -math.atan2((p.x+p.width/2)-(self.x+self.width/2), (p.y+p.height/2)-(self.y+self.height/2-3/16))-math.pi/2
					if angle > -1.1 and angle < 1.1 then
						local relativex, relativey = (p.x + -self.x), (p.y + -self.y)
						local distance = math.sqrt(relativex*relativex+relativey*relativey)
						self.speedx, self.speedy = (relativex)/distance*(homespeed), (relativey)/distance*(homespeed)
						self.rotation = angle
						self.chase = true
						self.color = 2
						self.frame = 1
						self.quad = fishbonequad[self.color][self.frame]
						self.mask[2] = false
						self.startedchase = true
					end
				end
			end
		elseif self.startedchase then
			self.startedchase = false
		end
	end
	
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
		
	else
		if self.chase then
			self.animationtimer = self.animationtimer + dt
			while self.animationtimer > cheepanimationspeed/2 do
				self.animationtimer = self.animationtimer - cheepanimationspeed/2
				if self.frame == 1 then
					self.frame = 2
				else
					self.frame = 1
				end
				self.quad = fishbonequad[self.color][self.frame]
			end
		else
			self.animationtimer = self.animationtimer + dt
			while self.animationtimer > cheepanimationspeed do
				self.animationtimer = self.animationtimer - cheepanimationspeed
				if self.frame == 1 then
					self.frame = 2
				else
					self.frame = 1
				end
				self.quad = fishbonequad[self.color][self.frame]
			end
		end
		
		return false
	end
end

function fishbone:shotted(dir) --fireball, star, turtle
	playsound(blockbreaksound)
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

function fishbone:rightcollide(a, b)
	if self:globalcollide() then
		return false
	end
	
end

function fishbone:leftcollide(a, b)
	if self:globalcollide() then
		return false
	end
	
end

function fishbone:ceilcollide(a, b)
	if self:globalcollide() then
		return false
	end
	
end

function fishbone:floorcollide(a, b)
	if self:globalcollide() then
		return false
	end
	
end

function fishbone:passivecollide(a, b)
	if a == "tile" then
		if self.chase then
			if self.startedchase then
				self.wallinvincible = true
			elseif not self.wallinvincible then
				self:shotted(dir)
			end
		end
	end
	return false
end

function fishbone:globalcollide(a, b)
	return true
end

function fishbone:dotrack()
	self.track = true
end