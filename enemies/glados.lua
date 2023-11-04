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
	
	self.mask = {true, true, true, false}
	
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
	self.quad = gladosquad[1] -- I have two sides, glados and .
	self.offsetX = 32
	self.offsetY = -26
	self.quadcenterX = 34
	self.quadcenterY = 34
	
	self.rotation = 0 --for portals
	self.animationdirection = "left"

	self.hp = 4
	self.state = "notseen"
	self.targetcore = false
	self.explodetimer = 0
end

function glados:update(dt)
	-- she may not be used but at least she's clean
	if self.state == "notseen" then
		if not onscreen(self.x, self.y, self.width, self.height) then
			return
		end
		playsound(glados1sound)
		self.state = "start"
	end

	if self.state ~= "dead" then
		-- follow closest player
		closestplayer = 1
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
	end

	if self.state == "start" then
		if not glados1sound:isPlaying() then
			self:spawncore(self.hp)
			self.state = "running"
		end
	elseif self.state == "running" then
		if self.targetcore and self.targetcore.destroying then
			self.targetcore = false
			self.hp = self.hp - 1
			playsound(boomsound)
			if self.hp == 3 then -- first core
				playsound(glados2sound)
				toxintime = self.toxintime
				neurotoxin = true
			elseif self.hp == 0 then -- last core
				self.state = "dead"
				neurotoxin = false
				glados2sound:stop()
			end
		end
	end
	
	if self.state ~= "dead" then
		return
	end
	self.explodetimer = self.explodetimer + dt
	if self.explodetimer > 4 then
		nextlevel()
		return true
	elseif not boomsound:isPlaying() then
		earthquake = 20
		playsound(boomsound)
		makepoof(self.x+self.width*math.random(), self.y+self.height*math.random(), "poof")
		makepoof(self.x+self.width*math.random(), self.y+self.height*math.random(), "poof")
	end
end

function glados:globalcollide(a, b)
	if a == "turretrocket" then
		self:hit()
	elseif (a == "bulletbill" or a == "cannonball" or a == "bigbill" or a == "torpedoted") and b.killstuff then
		b:shotted(self.dir)
		self:hit()
	elseif a == "mariohammer" then
		b:explode()
		self:hit()
	end
end

function glados:hit()
	if self.state == "dead" or self.targetcore then
		return false
	end
	self:spawncore(self.hp)
	playsound(boomsound)
end

function glados:spawncore(i)
	local cores = {"anger","cakemix","curiosity","morality"}
	self.targetcore = core:new(self.x+32/16, self.y+60/16, cores[i])
	table.insert(objects["core"], self.targetcore)
end

function glados:leftcollide(a, b)
	self:globalcollide(a, b)
end
function glados:rightcollide(a, b)
	self:globalcollide(a, b)
end
function glados:ceilcollide(a, b)
	self:globalcollide(a, b)
end
function glados:floorcollide(a, b)
	self:globalcollide(a, b)
end
function glados:passivecollide(a, b)
	self:leftcollide(a, b)
end