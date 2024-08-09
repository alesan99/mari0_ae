--also dk hammer and wing

smbsitem = class:new()

function smbsitem:init(x, y, t, r)
	--PHYSICS STUFF
	self.starty = y
	self.x = x-6/16
	self.y = y-12/16
	self.speedy = 0
	self.speedx = 0
	self.width = 12/16
	self.height = 12/16
	self.static = true
	self.active = true
	self.category = 6
	self.mask = {true}
	self.destroy = false
	self.autodelete = true
	self.gravity = 0
	self. t = t
	
	--IMAGE STUFF
	self.drawable = false
	self.graphic = itemsimg
	if self.t == "clock" then
		self.quad = itemsquad[spriteset][5]
		self.time = 100
		if r then
			self.time = tonumber(r)
		end
	elseif self.t == "wing" then
		self.quad = itemsquad[spriteset][8]
	elseif self.t == "dkhammer" then
		self.quad = itemsquad[spriteset][9]
	elseif self.t == "key" then
		self.graphic = keyimg
		self.quad = keyquads[spriteset][1]
		self.autodelete = false
	elseif self.t == "luckystar" then
		self.graphic = luckystarimg
		self.quadi = 1
		self.quad = goombaquad[spriteset][1]
		self.animationtimer = 0
		self.light = 2
	elseif self.t == "threeup" then
		self.graphic = itemsimg
		self.quad = itemsquad[spriteset][4]
	end
	self.offsetX = 6
	self.offsetY = 2
	self.quadcenterX = 8
	self.quadcenterY = 8
	
	self.rotation = 0 --for portals
	self.uptimer = 0
	self.pipespawnmax = 1
	
	self.falling = false
end

function smbsitem:update(dt)
	if self.uptimer < mushroomtime then
		self.uptimer = self.uptimer + dt
		if not self.tracked then
			self.y = self.y - dt*(1/mushroomtime)
		end
	end
	
	if self.uptimer >= mushroomtime then
		if not self.drawable then
			self.y = self.starty-28/16
		end
		self.active = true
		self.drawable = true
	end
	
	if self.t == "key" then
		self.quad = keyquads[spriteset][coinframe]
	elseif self.t == "luckystar" then
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > goombaanimationspeed do
			self.animationtimer = self.animationtimer - goombaanimationspeed
			if self.quadi == 2 then self.quadi = 1 else self.quadi = 2 end
			self.quad = goombaquad[spriteset][self.quadi]
		end
	end
	
	if self.destroy then
		return true
	else
		return false
	end
end

function smbsitem:draw()
	if self.uptimer < mushroomtime and not self.destroy then
		--Draw it coming out of the block.
		love.graphics.draw(self.graphic, self.quad, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), 0, scale, scale, self.quadcenterX, self.quadcenterY)
	end
end

function smbsitem:leftcollide(a, b)
	if a == "player" then
		self:action(b)
	end
	
	return false
end

function smbsitem:rightcollide(a, b)
	if a == "player" then
		self:action(b)
	end
	
	return false
end

function smbsitem:floorcollide(a, b)
	if a == "player" then
		self:action(b)
	end
end

function smbsitem:ceilcollide(a, b)
	if a == "player" then
		self:action(b)
	end
end

function smbsitem:passivecollide(a, b)
	if a == "player" then
		self:action(b)
	end
end

function smbsitem:action(b)
	if self.t == "clock" then
		mariotime = mariotime + self.time
		playsound(mushroomeatsound)
		addpoints(1000, self.x+self.width/2, self.y)
	elseif self.t == "wing" then
		b:dive(true)
		b.swimwing = 10
		playsound(mushroomeatsound)
		addpoints(1000, self.x+self.width/2, self.y)
	elseif self.t == "dkhammer" then
		b.dkhammer = 16
		b.dkhammeranim = 0
		b.dkhammerframe = 1
		playsound(mushroomeatsound)
		addpoints(1000, self.x+self.width/2, self.y)
	elseif self.t == "key" then
		if not b.key then
			b.key = 1
		else
			b.key = b.key + 1
		end
		playsound(keysound)
	elseif self.t == "luckystar" then
		for i2, v2 in kpairs(objects, objectskeys) do
			if i1 ~= "tile" and i2 ~= "buttonblock" then
				for i, v in pairs(objects[i2]) do
					if v.active and v.shotted and onscreen(v.x,v.y) and (not v.resistspowblock) then
						local dir = "right"
						if math.random(1,2)==1 then
							dir = "left"
						end
						v:shotted(dir, "powblock")
					end
				end
			end
		end
		playsound(mushroomeatsound)
		addpoints(1000, self.x+self.width/2, self.y)
	elseif self.t == "threeup" then
		if mariolivecount ~= false then
			for i = 1, players do
				mariolives[i] = mariolives[i]+3
				respawnplayers()
			end
		end
		table.insert(scrollingscores, scrollingscore:new("3up", self.x, self.y))
		playsound(oneupsound)
	end
	self.active = false
	self.destroy = true
	self.drawable = false
end

function smbsitem:jump(x)
	self.falling = true
	self.speedy = -mushroomjumpforce
end
