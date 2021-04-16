angrysun = class:new()

function angrysun:init(x, y)
	--PHYSICS STUFF
	self.starty = y
	self.oldy = y
	self.x = x-21/16
	self.y = y-18/16
	self.speedx = 0 --!
	self.speedy = 0
	self.width = 18/16
	self.height = 18/16
	self.static = false
	self.active = true
	
	self.mask = {	true,
					true, false, true, true, true,
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
	self.fallingtimer = 0
	self.gouptimer = 0
	self.falling = false
	self.goup = false
	self.movex = false
	self.downtime = 3
	self.side = "left"
	self.animationtimer = 0
	
	--IMAGE STUFF
	self.drawable = false
	
	self.direction = "left"
	
	self.rotation = 0
	
	self.timer = 0
	
	self.movex = 0
	self.movey = 0
	self.movex2 = 0
	self.movey2 = 0

	self.light = 2
	self.trackable = false
	self.pipespawnmax = 1
end

function angrysun:update(dt)
	if self.falling then
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > 0.2 do
			self.animationtimer = 0
		end
		self.fallingtimer = self.fallingtimer + dt
		
		local v = math.min(1, self.fallingtimer/2)
		if self.falling == "right" then
			self.movex = (width-7)*v
		else
			self.movex = (width-7)*(1-v)
		end
		self.movey = math.sin(v*math.pi)*(mapheight-self.starty-3)
		
		if self.fallingtimer > 2 then
			self.falling = false
		end
	end
	
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		if self.passive == false then
			self.timer = self.timer + dt
			if self.timer > angrysunrespawn then
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
		self.speedx = -angrysunpassivespeed
	else
		if not self.falling then
			self.timer = self.timer + dt
			if self.timer > self.downtime then
				if self.movex+3 < width/2 then
					self.falling = "right"
				else
					self.falling = "left"
				end
				self.fallingtimer = 0
				self.timer = 0
				self.movex2 = 0
				self.movey2 = 0
			elseif self.timer > self.downtime-1 then
				local v = math.min(1, self.timer-(self.downtime-1))
				if self.movex+3 < width/2 then
					self.movex2 = math.sin(-v*math.pi*4+math.pi*1.5)*1.5+1.5
					self.movey2 = math.cos(-v*math.pi*4+math.pi*1.5)*1.5
				else
					self.movex2 = math.sin(v*math.pi*4+math.pi/2)*1.5-1.5
					self.movey2 = math.cos(v*math.pi*4+math.pi/2)*1.5
				end
				
			end
		end
		
		--movement
		
		--stay on the same place even if the screen is moving
		self.x = xscroll + self.movex + self.movex2 + 3
		self.y = yscroll + self.movey + self.movey2 + self.starty
	end
		
	--check if switch to passive
	if angrysunend then
		self.passive = true
	end
end

function angrysun:draw()
	local horscale = scale
	if self.direction == "left" then
		horscale = -scale
	end
	
	local verscale = scale
	if self.shot then
		verscale = -scale
	end
	
	local quad = 1
	if self.animationtimer > 0.1 and self.falling then
		quad = 2
	else
		quad = 1
	end
	
	love.graphics.draw(angrysunimg, angrysunquad[quad], math.floor((self.x-xscroll+11/16)*16*scale), (self.y-yscroll-0.5+7/16)*16*scale, 0, horscale, verscale, 12, 12)
end

function angrysun:shotted()
	playsound(shotsound)
	self.shot = true
	self.speedy = -shotjumpforce
	self.direction = dir or "right"
	self.active = false
	self.gravity = shotgravity
	self.speedx = 0
	self.timer = 0
end

function angrysun:rightcollide(a, b)
	return false
end

function angrysun:leftcollide(a, b)
	return false
end

function angrysun:ceilcollide(a, b)
	return false
end

function angrysun:floorcollide(a, b)
	return false
end

function angrysun:passivecollide(a, b)
	if a == "frozencoin" then
		return true
	end
	return false
end