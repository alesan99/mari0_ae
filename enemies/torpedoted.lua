torpedolauncher = class:new() --i'm lazy and copied the downplant's code 

function torpedolauncher:init(x, y)
	self.cox = x
	self.coy = y
	
	self.timer = 0
	
	self.x = x-8/16
	self.y = y-24/16
	self.starty = self.y
	self.y=self.y- plantmovedist
	self.width = 16/16
	self.height = 14/16
	
	self.speedx = 0
	self.speedy = 0
	
	self.static = true
	self.active = true
	
	self.destroy = false
	
	self.inpipe = false
	self.aim = true
	
	self.category = 29
	
	self.mask = {true}
	
	--IMAGE STUFF
	self.drawable = false
	self.graphic = torpedolauncherimg
	self.quad = torpedolauncherquads[spriteset][1]
	self.animationdirection = "left"
	self.offsetX = 8
	self.offsetY = 6
	self.quadcenterX = 16
	self.quadcenterY = 12
	
	self.customscissor = {x-1, y-2, 2, 2}
	
	self.quadnum = 1
	self.timer = 0
	self.timer1 = 0
	self.timer2 = plantouttime

	self.trackable = false
end

function torpedolauncher:update(dt)
	closestplayer = 1 --find closest player
	for i = 2, players do
		local v = objects["player"][i]
		if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
			closestplayer = i
		end
	end

	self.timer2 = self.timer2 + dt
	if self.timer2 < plantouttime then
		self.y = self.y - plantmovespeed*dt
		self.timer = 0
		self.inpipe = true
		if self.y < self.starty - plantmovedist then
			self.y = self.starty - plantmovedist
			self.active = false
			self.quad = torpedolauncherquads[spriteset][1]
		end
	elseif self.timer2 < plantouttime+plantintime then
		if self.inpipe then
			self.aim = true
			self.active = true
		end
		self.y = self.y + plantmovespeed*dt
		self.inpipe = false
		if self.y > self.starty then
			self.y = self.starty
		end
	else
		self.timer2 = 0
	end
	
	if self.aim then
		--only turn to player once
		if objects["player"][closestplayer].x+objects["player"][closestplayer].width/2 < self.x+self.width/2 then
			self.animationdirection = "left"
		else
			self.animationdirection = "right"
		end
		self.aim = false
	end
	
	if self.active then 
		if self.inpipe == false and (self.x+self.width)-xscroll > -2  then
			self.timer = self.timer + dt
			if self.timer > 1.2 then
				self.quad = torpedolauncherquads[spriteset][2]
				table.insert(objects["torpedoted"], torpedoted:new(self.cox, self.y+1, self.animationdirection))
				self.timer = 0
			end
		end
		return
	end
	
	return self.destroy
end

function torpedolauncher:draw()
	local dirscale
	if self.animationdirection == "left" then
		dirscale = -scale
	else
		dirscale = scale
	end
	local horscale = scale
	if self.shot or self.flipped then
		horscale = -scale
	end
	
	love.graphics.setScissor(math.floor((self.customscissor[1]-xscroll)*16*scale), math.floor((self.customscissor[2]-.5-yscroll)*16*scale), self.customscissor[3]*16*scale, self.customscissor[4]*16*scale)
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.graphic, self.quad, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), self.rotation, dirscale, horscale, self.quadcenterX, self.quadcenterY)
	love.graphics.setScissor()
end
	
function torpedolauncher:shotted()
	playsound(shotsound)
	self.destroy = true
	self.active = false
end
-------------------------------------

torpedoted = class:new()
local torpedotedspeed = 10
local torpedotedacceleration = 10
function torpedoted:init(x, y, dir)
	self.startx = x-1
	--PHYSICS STUFF
	self.x = self.startx
	self.y = y-1
	self.speedy = 0
	self.speedx = 0
	self.width = 32/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.gravity = 0
	self.rotation = 0
	self.autodelete = true
	self.timer = 0
	
	--IMAGE STUFF
	self.drawable = true
	self.quad = torpedotedquad[spriteset][1]
	self.offsetX = 16
	self.offsetY = 2
	self.quadcenterX = 16
	self.quadcenterY = 8
	self.graphic = torpedotedimage
	
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
	self.animationtimer = 0
end

function torpedoted:update(dt)
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		--check if goomba offscreen
		if self.y > 18 then
			return true
		else
			return false
		end
	else
		self.timer = self.timer + dt
		if self.timer >= bulletbilllifetime then
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
		
		--acceleration zoom~
		if self.animationdirection == "left" then
			if math.abs(self.speedy) > math.abs(self.speedx) then
				self.speedy = math.min(self.speedy + torpedotedacceleration*dt, torpedotedspeed)
			else
				self.speedx = math.max(self.speedx - torpedotedacceleration*dt, -torpedotedspeed)
			end
		else
			if math.abs(self.speedy) > math.abs(self.speedx) then
				self.speedy = math.max(self.speedy - torpedotedacceleration*dt, -torpedotedspeed)
			else
				self.speedx = math.min(self.speedx + torpedotedacceleration*dt, torpedotedspeed)
			end
		end
		
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > 0.1 do
			self.animationtimer = self.animationtimer - 0.1
			if self.quad == torpedotedquad[spriteset][1] then
				self.quad = torpedotedquad[spriteset][2]
				local x, y = self.x+self.width/2, self.y+self.height/2
				if self.speedx < 0 then
					x = x+self.width/2
				elseif self.speedx > 0 then
					x = x-self.width/2
				elseif self.speedy < 0 then
					y = y+self.width/2
				elseif self.speedy > 0 then
					y = y-self.width/2
				end
				makepoof(x, y, "smallpoof")
			else
				self.quad = torpedotedquad[spriteset][1]
			end
		end
	end
end

function torpedoted:stomp(dir)
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

function torpedoted:shotted(dir)
	self:stomp(dir)
end

function torpedoted:rightcollide(a, b)
	self:globalcollide(a, b)
	return false
end

function torpedoted:leftcollide(a, b)
	self:globalcollide(a, b)
	return false
end

function torpedoted:ceilcollide(a, b)
	self:globalcollide(a, b)
	return false
end

function torpedoted:floorcollide(a, b)
	self:globalcollide(a, b)
	return false
end

function torpedoted:globalcollide(a, b)
	if self.killstuff then
		if fireballkill[a] then
			b:shotted("left")
			return true
		end
	else
		return true
	end
end

function torpedoted:portaled()
	self.killstuff = true
end
