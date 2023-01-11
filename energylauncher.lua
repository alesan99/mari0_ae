energylauncher = class:new()

function energylauncher:init(x, y, dir, r)
	--PHYSICS STUFF
	self.x = x-1
	self.y = y-1
	self.width = 8/16
	self.height = 16/16
	self.static = true
	self.active = true
	self.category = 4
	self.gravity = 0
	self.portalable = false
	self.dir = dir or "right"
	self.defaulton = true
	self.green = false

	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	if self.r[1] and self.r[1] ~= "link" then
		local v = convertr(self.r[1], {"string", "bool", "bool", "bool"}, true)
		--DIR
		self.dir = v[1]

		--OFFSET?
		self.offset = v[2]
	
		if self.offset then
			if self.dir == "left" or self.dir == "right" then
				self.y = self.y + .5
			else
				self.x = self.x + .5
			end
		end

		--GREEN
		self.green = v[4]

		--DEFAULT OFF?
		self.defaulton = not v[3]
		table.remove(self.r, 1)
	end
	
	self.on = self.defaulton
	self.rotation = 0
	
	self.mask = {true}
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = energylauncherimage
	if self.on then
		self.quad = energylauncherquad[1][2]
	else
		self.quad = energylauncherquad[1][1]
	end
	self.offsetX = 8
	self.offsetY = 0
	self.quadcenterX = 8
	self.quadcenterY = 8
	if self.dir == "right" then --multiple directions. This code is so bad I feel bad :(
		self.animationdirection = "right"
	elseif self.dir == "left" then
		self.animationdirection = "left"
		self.offsetX = 0
		self.x = self.x + 8/16
	elseif self.dir == "up" then
		self.rotation = -math.pi/2
		self.y = self.y + 8/16
		self.offsetY = 8
		self.width = 16/16
		self.height = 8/16
	elseif self.dir == "down" then
		self.rotation = math.pi/2
		self.width = 16/16
		self.height = 8/16
	end
	self.children = 0

	self.launchtimer = 0
	
	self.falling = false
end

function energylauncher:update(dt)
	if self.finished then
		return false
	end
	if (not self.on) or self.children >= 1 then --Check if there's a energy pellet
		--nothing
	else
		self.launchtimer = self.launchtimer + dt
		if self.launchtimer > 0.5 and self.children < 1 then
			self:launchenergyball()
		end
	end
end

function energylauncher:launchenergyball()
	local t = "yellow"
	if self.green then
		t = "green"
	end
	local obj
	if self.dir == "right" then
		obj = energyball:new(self.x+8/16, self.y+4/16, self.dir, t, self)
	elseif self.dir == "down" then
		obj = energyball:new(self.x+4/16, self.y+8/16, self.dir, t, self)
	elseif self.dir == "left" then
		obj = energyball:new(self.x-8/16, self.y+4/16, self.dir, t, self)
	elseif self.dir == "up" then
		obj = energyball:new(self.x+4/16, self.y-8/16, self.dir, t, self)
	end
	self.child = obj
	table.insert(objects["energyball"], obj)
	self.children = self.children + 1
	self.launchtimer = 0
end

function energylauncher:callback(caught)
	self.children = self.children - 1
	self.child = false
	if caught then
		self.finished = true
	end
end

function energylauncher:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function energylauncher:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function energylauncher:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function energylauncher:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "player" and b.speedy < 0 then
		playsound(blockhitsound) --make sound when hit by mario
	end
end


function energylauncher:globalcollide(a, b)

end

function energylauncher:passivecollide(a, b)
	return false
end

function energylauncher:input(t)
	local quadi = 1
	if t == "on" then
		self.on = not self.defaulton
	elseif t == "off" then
		self.on = self.defaulton
	elseif t == "toggle" then
		self.on = not self.on
	end
	if self.on then
		quadi = 2
		if self.green then
			self.launchtimer = 0.5
			if self.child then
				self.child.destroy = true
			end
		end
	end
	self.quad = energylauncherquad[1][quadi]
end

function energylauncher:link()
	if #self.r > 2 then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[2]) == v.cox and tonumber(self.r[3]) == v.coy then
					v:addoutput(self)
				end
			end
		end
	end
end

-----------------------------------------------ENERGY PELLET---------------------------------------------------
energyball = class:new()

function energyball:init(x, y, dir, t, parent)
	--PHYSICS STUFF
	self.x = x
	self.y = y
	self.dir = dir or "right"
	
	if self.dir == "right" then
		self.speedx = 3
		self.speedy = 0
	elseif self.dir == "left" then
		self.speedx = -3
		self.speedy = 0
	elseif self.dir == "up" then
		self.speedx = 0
		self.speedy = -3
	elseif self.dir == "down" then
		self.speedx = 0
		self.speedy = 3
	end
	
	self.width = 8/16
	self.height = 8/16
	self.static = false
	self.active = true
	self.category = 4
	self.t = t or "yellow"
	self.ti = 1
	if self.t == "green" then
		self.ti = 2
	end
	self.hp = 3
	self.gravity = 0
	
	self.mask = {true, false}
	
	--IMAGE STUFF
	self.drawable = true
	self.quadi = 1
	self.graphic = energyballimage
	self.quad = energyballquad[self.ti][self.quadi]
	self.offsetX = 4
	self.offsetY = 4
	self.quadcenterX = 4
	self.quadcenterY = 4
	
	self.rotation = 0 --for portals
	
	self.direction = "left"
	self.animationtimer = 0
	
	self.falling = false
	
	self.dead = false
	self.deathtimer = 0
	self.extremeautodelete = true

	self.parent = parent
	
	self.shot = false
end

function energyball:update(dt)
	if self.hp > 0 or self.t == "green" then
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > 0.1 do
			self.animationtimer = self.animationtimer - 0.1
			self.quadi = self.quadi + 1
			if self.quadi == 5 then
				self.quadi = 1
			end
			self.quad = energyballquad[self.ti][self.quadi]
		end
	end
	if self.hp <= 0 or self.destroy then
		if self.hp <= 0 then
			table.insert(emancipateanimations, emancipateanimation:new(self.x, self.y, self.width, self.height, self.graphic, self.quad, self.speedx*0.2, self.speedy*0.2, self.rotation, self.offsetX, self.offsetY, self.quadcenterX, self.quadcenterY))
		end
		self.parent:callback(self.catched)
		return true
	end
end

function energyball:hitwall()
	if self.t ~= "green" then
		self.hp = self.hp - 1
		if self.hp < 0 then
			self.destroy = true
			return true
		end
	end
end

function energyball:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "energycatcher" then
		if b.dir == "right" then
			--self.hp = 0
			self.destroy = true
			self.catched = true
			return true
		end
	end
	if onscreen(self.x, self.y, self.width, self.height) then
		playsound(energybouncesound)
	end
	if a == "pixeltile" and b.dir == "right" then
		if b.step == 0 then --upside down
			self.speedy = -self.speedx
			self.speedx = 0
		else
			self.speedy = self.speedx
			self.speedx = 0
		end
		return true
	elseif a == "tile" or a == "flipblock" or a == "door" or a == "frozencoin" then
		self:hitwall()
	end
	self.speedx = math.abs(self.speedx)
	return false
end

function energyball:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if onscreen(self.x, self.y, self.width, self.height) then
		playsound(energybouncesound)
	end
	if a == "pixeltile" and b.dir == "left" then
		if b.step == 0 then --upside down
			self.speedy = self.speedx
			self.speedx = 0
		else
			self.speedy = -self.speedx
			self.speedx = 0
		end
		return true
	elseif a == "tile" or a == "flipblock" or a == "door" or a == "frozencoin" then
		self:hitwall()
	end
	self.speedx = -math.abs(self.speedx)
	if a == "energycatcher" then
		if b.dir == "left" then
			--self.hp = 0
			self.destroy = true
			self.catched = true
			return true
		end
	end
	return false
end

function energyball:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.speedy = math.abs(self.speedy)
	if onscreen(self.x, self.y, self.width, self.height) then
		playsound(energybouncesound)
	end
	if a == "pixeltile" and b.step == 0 then
		if b.dir == "right" then
			self.speedx = self.speedy
			self.speedy = 0
		else
			self.speedx = -self.speedy
			self.speedy = 0
		end
		return true
	elseif a == "tile" or a == "flipblock" or a == "door" or a == "frozencoin" then
		self:hitwall()
	end
	if a == "energycatcher" then
		if b.dir == "down" then
			--self.hp = 0
			self.destroy = true
			self.catched = true
			return true
		end
	end
end

function energyball:globalcollide(a, b)
	if a == "turret" then
		b:dofrenzy()
	end
end

function energyball:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if onscreen(self.x, self.y, self.width, self.height) then
		playsound(energybouncesound)
	end
	if a == "pixeltile" then
		if b.dir == "right" then
			self.speedx = self.speedy
			self.speedy = 0
		else
			self.speedx = -self.speedy
			self.speedy = 0
		end
		return true
	elseif a == "tile" or a == "flipblock" or a == "door" or a == "frozencoin" then
		self:hitwall()
	end
	self.speedy = -math.abs(self.speedy)
	if a == "energycatcher" then
		if b.dir == "up" then
			--self.hp = 0
			self.destroy = true
			self.catched = true
			return true
		end
	end
end

function energyball:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end

function energyball:portaled()
	self.hp = 3
end

function energyball:emancipate(a)
	self.destroy = true
end

function energyball:laser()
	self.destroy = true
end

function energyball:autodeleted()
	self.destroy = true
	self.parent:callback(self.catched)
end