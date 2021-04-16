lakito = class:new()

function lakito:init(x, y)
	--PHYSICS STUFF
	self.starty = y
	self.x = x-1+2/16
	self.y = y-12/16
	self.speedx = 0 --!
	self.speedy = 0
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.freezable = true
	self.frozen = false
	
	self.mask = {	true,
					true, false, false, true, true,
					true, true, true, true, true,
					true, false, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					false, true}
	
	self.gravity = 0
	self.portalable = false
	self.passive = false
	self.category = 21
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = lakitoimg
	self.quadi = 1
	self.quad = lakitoquad[spriteset][self.quadi]
	self.offsetX = 6
	self.offsetY = 6
	self.quadcenterX = 8
	self.quadcenterY = 12
	
	self.direction = "left"
	self.animationdirection = "right"
	
	self.rotation = 0
	
	self.timer = 0
	self.freezetimer = 0

	self.trackable = false
	self.pipespawnmax = 1
end

function lakito:update(dt)
	if self.frozen then
		return
	end

	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		if self.passive == false then
			self.timer = self.timer + dt
			if self.timer > lakitorespawn then
				self.y = self.starty - 12/16
				self.x = splitxscroll[#splitxscroll] + width
				self.timer = 0
				self.shot = false
				self.active = true
				self.gravity = 0
				self.speedy = 0
				self.speedx = 0
			end
		end
		
	elseif self.passive then
		self.speedx = -lakitopassivespeed
	else
		if self.timer > lakitothrowtime-lakitohidetime then
			self.quadi = 2
		else
			self.quadi = 1
		end
		self.quad = lakitoquad[spriteset][self.quadi]

		local count = 0
		for i, v in pairs(objects["goomba"]) do
			if v.t == "spikeyfall" or v.t == "spikey" then
				count = count + 1
			end
		end
		
		self.timer = self.timer + dt
		if count < 3 then
			if self.timer > lakitothrowtime then
				table.insert(objects["goomba"], goomba:new(self.x+6/16, self.y, "spikeyfall"))
				self.timer = 0
			end
		end
		
		--movement
		--get nearest player (relative to that player's position in 1 second)
		local nearestplayer = 1
		local nearestplayerx = objects["player"][1].x + objects["player"][1].speedx * lakitodistancetime
		for i = 2, players do
			local v = objects["player"][i]
			if math.abs(self.x - (v.x + v.speedx*lakitodistancetime)) < nearestplayerx and not v.dead then
				nearestplayer = i
				nearestplayerx = v.x + v.speedx*lakitodistancetime
			end
		end
		
		local distance = math.abs(self.x - nearestplayerx)
		
		--check if too far in wrong direciton
		if self.direction == "left" and self.x < nearestplayerx-lakitospace then
			self.direction = "right"
		elseif self.direction == "right" and self.x > nearestplayerx+lakitospace then
			self.direction = "left"
		end

		if self.direction == "left" then
			self.animationdirection = "right"
		else
			self.animationdirection = "left"
		end
		
		if not self.frozen then
			if self.direction == "right" then
				self.speedx = math.max(2, round((distance-3)*2))
			else
				self.speedx = -2
			end
		else
			self.speedx = 0
		end
	end
		
	--check if switch to passive
	if lakitoend then
		self.passive = true
	end
end

--[[function lakito:draw()
	local horscale = scale
	if self.direction == "left" then
		horscale = -scale
	end
	
	local verscale = scale
	if self.shot then
		verscale = -scale
	end
	
	local quad = 1
	if self.timer > lakitothrowtime-lakitohidetime then
		quad = 2
	end
	
	love.graphics.draw(lakitoimg, lakitoquad[spriteset][quad], math.floor((self.x-xscroll-2/16+.5)*16*scale), (self.y-yscroll-0.5+1/16)*16*scale, 0, horscale, verscale, 8, 12)
end]]

function lakito:stomp()
	self:shotted(nil, "stomp")
	self.speedy = 0
end

function lakito:shotted(dir, stomp) --fireball, star, turtle
	if not stomp then
		playsound(shotsound)
	end
	self.shot = true
	self.speedy = -shotjumpforce
	self.direction = dir or "right"
	self.active = false
	self.gravity = shotgravity
	self.speedx = 0
	self.timer = 0
end

function lakito:freeze()
	self.frozen = true
end

function lakito:rightcollide(a, b)
	if a == "goomba" and b.t == "spikeyfall" then
		self:shotted()
		addpoints(firepoints["lakito"], self.x, self.y)
	end
	return false
end

function lakito:leftcollide(a, b)
	if a == "goomba" and b.t == "spikeyfall" then
		self:shotted()
		addpoints(firepoints["lakito"], self.x, self.y)
	end
	return false
end

function lakito:ceilcollide(a, b)
	if a == "goomba" and b.t == "spikeyfall" then
		self:shotted()
		addpoints(firepoints["lakito"], self.x, self.y)
	end
	return false
end

function lakito:floorcollide(a, b)
	if a == "goomba" and b.t == "spikeyfall" then
		self:shotted()
		addpoints(firepoints["lakito"], self.x, self.y)
	end
	return false
end