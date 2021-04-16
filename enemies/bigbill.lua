bigbilllauncher = class:new()

function bigbilllauncher:init(x, y)
	self.x = x
	self.y = y
	self.id = id
	self:randomtime()
	self.timer = self.time-0.5
	self.autodelete = true
end

function bigbilllauncher:update(dt)
	self.timer = self.timer + dt
	if self.timer > self.time and self.x > splitxscroll[1] and self.x < splitxscroll[1]+width+2 then
		if self:fire() then
			self.timer = 0
			self:randomtime()
		end
	end
end

function bigbilllauncher:fire()
	if #objects["bigbill"] >= maximumbigbills then
		return false
	end
	
	--get nearest player
	local pl = 1
	for i = 2, players do
		if math.abs(objects["player"][i].x + 32/16 - self.x) < math.abs(objects["player"][pl].x + 32/16 - self.x) then
			pl = i
		end
	end
	
	if objects["player"][pl].x + 32/16 > self.x + bigbillrange then
		local x = self.x+1
		if inmap(self.x+1, self.y) and tilequads[map[self.x+1][self.y][1]].collision then
			--offset bigbill if cannon is wide
			if inmap(self.x+2, self.y) and tilequads[map[self.x+2][self.y][1]].collision then
				--don't fire to right if coming out of pipe
				return false
			end
			x = x+1
		end
		table.insert(objects["bigbill"], bigbill:new(x, self.y, "right"))
		return true
	elseif objects["player"][pl].x + 32/16 < self.x - bigbillrange then
		if inmap(self.x-1, self.y) and tilequads[map[self.x-1][self.y][1]].collision then
			--don't fire to right if coming out of pipe
			return false
		end
		table.insert(objects["bigbill"], bigbill:new(self.x, self.y, "left"))
		return true
	end
end

function bigbilllauncher:randomtime()
	local rand = math.random(bigbilltimemin*10, bigbilltimemax*10)/10
	self.time = rand
end

----------------------
bigbill = class:new()
function bigbill:init(x, y, dir)
	self.startx = x-2
	--PHYSICS STUFF
	self.x = self.startx
	self.y = y-2
	self.speedy = 0
	if dir == "left" then
		self.x = self.x+1
		self.speedx = -bigbillspeed
		self.customscissor = {self.startx-1, self.y, 2, 2}
	else
		self.x = self.x-1
		self.speedx = bigbillspeed
		self.customscissor = {self.startx+1, self.y, 2, 2}
	end
	self.width = 32/16
	self.height = 32/16
	self.static = false
	self.active = false
	self.gravity = 0
	self.rotation = 0
	self.autodelete = true
	self.timer = 0
	
	--IMAGE STUFF
	self.drawable = true
	self.quad = bigbillquad[spriteset]
	self.offsetX = 16
	self.offsetY = -8
	self.quadcenterX = 16
	self.quadcenterY = 16
	self.graphic = bigbillimg
	
	self.category = 11
	self.animationdirection = dir
	
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

function bigbill:update(dt)
	if self.customscissor then
		if self.x < self.startx - 1 or self.x > self.startx + 1 then
			self.customscissor = nil
			self.active = true
		else
			self.x = self.x+self.speedx*dt
			self.y = self.y+self.speedy*dt
		end
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
		if self.timer >= bigbilllifetime then
			return true
		end
	
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

function bigbill:stomp(dir) --fireball, star, turtle
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

function bigbill:shotted(dir)
	self:stomp(dir)
end

function bigbill:freeze()
	self.frozen = true
	self.static = true
end

function bigbill:rightcollide(a, b)
	self:globalcollide(a, b)
	return false
end

function bigbill:leftcollide(a, b)
	self:globalcollide(a, b)
	return false
end

function bigbill:ceilcollide(a, b)
	self:globalcollide(a, b)
	if a == "player" or a == "box" then
		self:stomp()
	end
	return false
end

function bigbill:floorcollide(a, b)
	self:globalcollide(a, b)
	return false
end

function bigbill:globalcollide(a, b)
	if self.killstuff then
		if fireballkill[a] and not b.resistsenemykill then
			b:shotted("left")
			return true
		end
	else
		return true
	end
end

function bigbill:portaled()
	self.killstuff = true
end

function bigbill:dospawnanimation(a)
	if a == "pipe" then
		self.customscissor = false
		self.active = true
	end
end