----------------------------------------------------------------------------------------------------------------------------------------------------------------
plantfire = class:new()

function plantfire:init(x, y, koopaling)
	self.x = x-6/16
	self.y = y-11/16
	--PHYSICS STUFF
	self.speedx = 0
	self.speedy = 0
	self.width = 8/16
	self.height = 8/16
	self.static = false
	self.active = true
	self.category = 4
	self.mask = {	true, 
					true, false, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					false, true}
	self.gravity = 0
	self.emancipatecheck = true
	self.autodelete = true
	self.delete = false

	--IMAGE STUFF
	self.drawable = true
	self.graphic = fireballimg
	self.quad = fireballquad[1]
	self.offsetX = 4
	self.offsetY = 4
	self.quadcenterX = 4
	self.quadcenterY = 4
	self.quadi = 1
	self.timer = 0
	self.rotation = 0
	
	if koopaling and koopaling ~= "plantfire" then --{speedx, speedy, i}
		local t = koopaling
		self.speedx = t[1]
		self.speedy = t[2]
		self.t = t[3]
		self.activatetimer = t[4]
		if self.activatetimer and self.activatetimer > 0 then
			self.static = true
			self.active = false
			self.drawable = false
		else
			self.activatetimer = false
		end
		
		self.x = x
		self.y = y
		if self.t == 2 or self.t == 3 then
			self.width = 12/16
			self.height = 12/16
			self.mask[2] = false
			if self.t == 3 then
				if self.speedx < 0 then
					self.animationdirection = "left"
				end
				self.gravity = yacceleration/2
			end
		elseif self.t == 4 then
			self.width = 12/16
			self.height = 12/16
			if self.speedx < 0 then
				self.animationdirection = "left"
			end
			self.starty = self.y
			local closestplayer = 1
			for i = 2, players do
				local v = objects["player"][i]
				if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
					closestplayer = i
				end
			end
			if objects["player"][closestplayer] then
				self.targety = math.min(self.y+5, math.max(self.y-5, objects["player"][closestplayer].y+(math.random(1,4)-3)))
				if self.targety > self.y then
					self.speedy = 3.5
				else
					self.speedy = -3.5
				end
			end
			self.mask[13] = false
		elseif self.t == "magikoopa" then
			self.width = 12/16
			self.height = 12/16
			self.mask[2] = false
			self.activetimer = false
		else
			self.width = 8/16
			self.height = 8/16
		end
		
		self.graphic = koopalingshotimg
		self.quadi = 1
		if self.t == 2 or self.t == 3 then
			self.quad = koopalingshotquad[self.t][self.quadi]
			self.offsetX = 6
			self.offsetY = 2
			self.quadcenterX = 8
			self.quadcenterY = 8
		elseif self.t == 4 then
			self.offsetX = 6
			self.offsetY = 2
			self.quadcenterX = 8
			self.quadcenterY = 8
			self.quadi = 1
			self.quad = koopalingshotquad[3][self.quadi+1]
			self.light = 1
		elseif self.t == "magikoopa" then --magikoopa
			self.offsetX = 6
			self.offsetY = 2
			self.quadcenterX = 8
			self.quadcenterY = 8
			self.quadi = 1
			self.graphic = magikoopamagicimg
			self.quad = magikoopamagicquad[self.quadi]
			self.delete = nil
			self.light = 2
		else
			self.quad = koopalingshotquad[self.t][self.quadi]
			self.offsetX = 4
			self.offsetY = 4
			self.quadcenterX = 8
			self.quadcenterY = 8
			self.light = 1
		end
	else
		local closestplayer = 1 --find closest player
		for i = 2, players do
			local v = objects["player"][i]
			if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
				closestplayer = i
			end
		end
		if objects["player"][closestplayer] then
			local p = objects["player"][closestplayer]
			local angle = -math.atan2((p.x+p.width/2)-(self.x+self.width/2), (p.y+p.height/2)-(self.y+self.height/2-3/16))-math.pi/2
			--snap angle to 8 angles
			angle = math.floor((angle/(math.pi*2))*16+.5)/16*(math.pi*2)
			self.speedx, self.speedy = math.cos(angle+math.pi)*(plantfirespeed), math.sin(angle+math.pi)*(plantfirespeed)
			self.angle = angle
		end
		self.light = 2
		if koopaling and koopaling == "plantfire" then
			if mariomakerphysics then
				self.mask[2] = false
				self.hitblocks = true
			end
		end
	end

	self.lifetime = 8
end

function plantfire:update(dt)
	if not self.t or self.t ~= 3 then
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
	end
	
	if self.activatetimer then
		self.activatetimer = self.activatetimer - dt
		if self.activatetimer < 0 then
			self.static = false
			self.active = true
			self.drawable = true
		else
			return false
		end
	end
	
	if self.t == 4 then
		if self.targety > self.starty and self.y > self.targety then
			self.speedy = 0
		elseif self.targety < self.starty and self.y < self.targety then
			self.speedy = 0
		end
	end
	
	--animate
	if self.t then--koopalingshot
		if self.t == 1 and self.quadi < 3 then
			self.timer = self.timer + dt
			while self.timer > 0.5 do
				self.quadi = math.min(3, self.quadi + 1)
				self.timer = self.timer - 0.5
			end
			self.quad = koopalingshotquad[self.t][self.quadi]
		elseif self.t == 2 then
				self.timer = self.timer + dt
			while self.timer > goombaanimationspeed do
				self.quadi = self.quadi + 1
				if self.quadi == 3 then
					self.quadi = 1
				end
				self.timer = self.timer - goombaanimationspeed
			end
			self.quad = koopalingshotquad[self.t][self.quadi]
		elseif self.t == 3 then
			self.timer = self.timer + dt
			while self.timer > 0.1 do
				if self.animationdirection == "left" then
					self.rotation = self.rotation - math.pi/2
				else
					self.rotation = self.rotation + math.pi/2
				end
				self.timer = self.timer - 0.1
			end
			self.quad = koopalingshotquad[self.t][self.quadi]
		elseif self.t == 4 then
			self.timer = self.timer + dt
			while self.timer > goombaanimationspeed/3 do
				self.quadi = self.quadi + 1
				if self.quadi == 3 then
					self.quadi = 1
				end
				self.timer = self.timer - goombaanimationspeed/3
			end
			self.quad = koopalingshotquad[3][self.quadi+1]
		elseif self.t == "magikoopa" then
			self.timer = self.timer + dt
			while self.timer > goombaanimationspeed/3 do
				self.quadi = self.quadi + 1
				if self.quadi == 3 then
					self.quadi = 1
				end
				self.timer = self.timer - goombaanimationspeed/3
			end
			self.quad = magikoopamagicquad[self.quadi]
		end
	else
		self.timer = self.timer + dt
		while self.timer > staranimationdelay do
			self.quadi = self.quadi + 1
			if self.quadi == 5 then
				self.quadi = 1
			end
			self.quad = fireballquad[self.quadi]
			self.timer = self.timer - staranimationdelay
		end

		self.lifetime = self.lifetime - dt
		if self.lifetime < 0 then
			self.delete = true
			return true
		end
	end
	
	if self.y > mapheight+3 or self.y < -3 or self.delete or self.shot then
		if self.parent and self.parent.projectilecallback then
			self.parent:projectilecallback(self.idforparent)
		end
		return true
	else
		return false
	end
end

function plantfire:shotted(dir) --fireball, star, turtle
	self.shot = true
	self.active = false
	self.delete = true
	self.drawable = false
	
	if not self.t then
		if self.supersized then
			makepoof(self.x+self.width/2, self.y+self.width/2, "makerpoofbig")
		else
			makepoof(self.x+self.width/2, self.y+self.width/2, "makerpoof")
		end
		--playsound(blockhitsound)
		--[[local obj = brofireball:new(self.x-4/16, self.y-7/16, "left")
		obj:explode()
		table.insert(objects["brofireball"], obj)]]
	end
end

function plantfire:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	if self.t and (self.t == 2 or self.t == 3) then
		self.speedx = math.abs(self.speedx)
	end

	return false
end

function plantfire:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	if self.t and (self.t == 2 or self.t == 3) then
		self.speedx = -math.abs(self.speedx)
	end

	return false
end

function plantfire:globalcollide(a, b)
	if a == "player" or a == "frozencoin" then
		self:shotted()
		return true
	end
	
	if self.t == "magikoopa" then
		if self.delete then
			return true
		end
		if a == "tile" then
			local x, y = b.cox, b.coy
			if (tilequads[map[x][y][1]].breakable or (tilequads[map[x][y][1]].debris and blockdebrisquads[tilequads[map[x][y][1]].debris])) and not portalintile(x, y) then
				map[x][y][1] = 1
				objects["tile"][tilemap(x, y)] = nil
				map[x][y]["gels"] = {}
				local i = math.random(1, 4)
				if i == 1 then
					table.insert(objects["goomba"], goomba:new(x-0.5, y-1/16))
				elseif i == 2 then
					table.insert(objects["koopa"], koopa:new(x-0.5, y-1/16))
				elseif i == 3 then
					table.insert(objects["koopa"], koopa:new(x-0.5, y-1/16, "red"))
				elseif i == 4 then
					table.insert(objects["goomba"], goomba:new(x-0.5, y-1/16, "spikey"))
				end
				makepoof(x-.5, y-.5, "makerpoof")
			end
		elseif a == "tilemoving" then
			if (tilequads[b.t].breakable or (tilequads[b.t].debris and blockdebrisquads[tilequads[b.t].debris])) then
				local i = math.random(1, 4)
				if i == 1 then
					table.insert(objects["goomba"], goomba:new(b.x-0.5+1, b.y-1/16+1))
				elseif i == 2 then
					table.insert(objects["koopa"], koopa:new(b.x-0.5+1, b.y-1/16+1))
				elseif i == 3 then
					table.insert(objects["koopa"], koopa:new(b.x-0.5+1, b.y-1/16+1, "red"))
				elseif i == 4 then
					table.insert(objects["goomba"], goomba:new(b.x-0.5+1, b.y-1/16+1, "spikey"))
				end
				b.delete = true
				makepoof(b.x+.5, b.y+.5, "makerpoof")
			end
		end
		
		playsound(blockhitsound)
		self.delete = true
		generatespritebatch()
		return true
	elseif self.hitblocks then
		if self.ignoretiles and b.cox and b.coy then
			for i, t in pairs(self.ignoretiles) do
				if b.cox == t[1] and b.coy == t[2] then
					return true
				end
			end
		end
		self:shotted()
		return true
	end
end

function plantfire:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if self.t then
		if self.t == 2 then
			self.speedy = -math.abs(self.speedy)
		elseif self.t == 3 then
			self.speedy = -20
		end
	end
	return false
end

function plantfire:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if self.t and self.t == 2 then
		self.speedy = math.abs(self.speedy)
	end
	return false
end

function plantfire:passivecollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function plantfire:emancipate(a)
	self:shotted()
end