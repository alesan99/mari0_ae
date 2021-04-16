glados = class:new()

function glados:init(x, y, r)
	--PHYSICS STUFF
	self.x = x-1
	self.y = y-1
	self.speedy = 0
	self.speedx = 0
	self.width = 4
	self.height = 4
	self.static = true
	self.active = true
	self.category = 4
	self.gravity = 0
	
	self.mask = {true, true, false, false}
	
	self.emancipatecheck = false
	self.autodelete = false

	self.toxintime = 150
	if r then
		local v = convertr(r, {"num"})
		self.toxintime = v[1]
	end
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = gladosimage
	self.quad = gladosquad[1]
	self.offsetX = 32
	self.offsetY = -26
	self.quadcenterX = 34
	self.quadcenterY = 34
	
	self.rotation = 0 --for portals

	self.animationdirection = "left"
	
	self.timer = 0
	self.explodetimer = 0
	self.pooftimer = 0
	
	self.hp = 4
	self.rp = 4
	self.coredetect = false
	self.dead = false
	self.boot = false
	self.startcore = false
	self.initiated = false
	self.playglados1sound = true
end

function glados:update(dt)
	if self.boot and not self.dead then
		if self.playglados1sound == true then
			playsound(glados1sound)
			self.playglados1sound = false
		end
		
		if self.timer < 4 then
			self.timer = self.timer + dt
			if self.timer > 4 then
				table.insert(objects["core"], core:new(self.x+32/16, self.y+60/16, "morality"))
				self.initiated = true
				self.startcore = true
				self.hp = 3
			end
		end
		closestplayer = 1 --find closest player
		for i = 2, players do
			local v = objects["player"][i]
			if math.abs(self.x - v.x) < math.abs(self.x+30/16 - objects["player"][closestplayer].x) then
				closestplayer = i
			end
		end
		local v = objects["player"][closestplayer]
		if v.x > self.x+self.width/2 then
			self.animationdirection = "right"
			self.dir = "right"
		else
			self.animationdirection = "left"
			self.dir = "left"
		end
		
		if self.rp < 4 and self.rp ~= 0 then
			if not neurotoxin then
				neurotoxin = true
				toxintime = self.toxintime
			end
		end
		
		if self.startcore == true then
			if #objects["core"] == 0 then
				self.hp = 3
				self.rp = 3
				self.startcore = false
				playsound(boomsound)
				playsound(glados2sound)
			end
		end
		
		if self.coredetect == true then
			if #objects["core"] == 0 then
				self.rp = self.rp - 1
				self.coredetect = false
				playsound(boomsound)
			end
		end
		if self.rp == 0 then
			self.dead = true
		end
	elseif self.dead then
		neurotoxin = false
		self.explodetimer = self.explodetimer + dt
		earthquake = 20
		if self.explodetimer > 4 then
			nextlevel()
			return true--EXPLODE
		else
			if boomsound:isStopped() then
				playsound(boomsound)
			end
			self.pooftimer = self.pooftimer - dt
			if self.pooftimer < 0 then
				makepoof(self.x+self.width*math.random(), self.y+self.height*math.random(), "poof")
				makepoof(self.x+self.width*math.random(), self.y+self.height*math.random(), "poof")
				self.pooftimer = 0.2
			end
		end
	else
		if self.x < xscroll+25 then
			self.boot = true
		end
	end
end

function glados:hit()
	if self.dead then
		return false
	end
	if self.hp == self.rp and self.initiated then
		self.hp = self.hp - 1
		
		if self.hp == 2 then
			table.insert(objects["core"], core:new(self.x+32/16, self.y+60/16, "curiosity"))
		elseif self.hp == 1 then
			table.insert(objects["core"], core:new(self.x+32/16, self.y+60/16, "cakemix"))
		elseif self.hp == 0 then --still alive
			table.insert(objects["core"], core:new(self.x+32/16, self.y+60/16, "anger"))
		end
		self.coredetect = true
	end
	
	playsound(boomsound)
end

function glados:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function glados:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function glados:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function glados:globalcollide(a, b)
	if a == "turretrocket" then
		self:hit()
	elseif a == "bulletbill" or a == "cannonball" or a == "bigbill" or a == "torpedoted" then
		if b.killstuff then
			b:shotted(self.dir)
			self:hit()
		end
	elseif a == "mariohammer" then
		b:explode()
		self:hit()
	end
end

function glados:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function glados:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end