spring = class:new()

function spring:init(x, y, t, p)
	self.cox = x
	self.coy = y
	
	--PHYSICS STUFF
	self.x = x-1
	self.y = y-31/16
	self.width = 16/16
	self.height = 31/16
	self.static = true
	self.active = true
	
	self.drawable = false
	
	self.timer = springtime
	
	self.category = 19
	
	self.mask = {true}
	
	--actual physics
	if t == "green" then
		self.green = true
	end
	self.physics = p or false
	if self.physics then
		self.static = false
		self.mask = {	true, 
						false, false, false, false, true,
						false, true, false, true, false,
						false, false, true, false, false,
						true, true, false, false, false,
						false, true, true, false, false,
						true, false, true, true, true,
						false, true}
		self.speedx = 0
		self.speedy = 0
		self.rotation = 0
		self.category = 19
		self.height = 30/16
		self.spring = false
	end
	
	self.frame = 1
end

function spring:update(dt)
	if self.physics then
		self.cox = self.x+1
		self.coy = self.y+31/16
		
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
		
		if self.speedy == 0 then
			if self.speedx > 0 then
				self.speedx = self.speedx - friction*dt*2
				if self.speedx < 0 then
					self.speedx = 0
				end
			elseif self.speedx < 0 then
				self.speedx = self.speedx + friction*dt*2
				if self.speedx > 0 then
					self.speedx = 0
				end
			end
		else
			if self.speedx > 0 then
				self.speedx = self.speedx - friction*dt
				if self.speedx < 0 then
					self.speedx = 0
				end
			elseif self.speedx < 0 then
				self.speedx = self.speedx + friction*dt
				if self.speedx > 0 then
					self.speedx = 0
				end
			end
		end
		
		if self.spring then
			self.x = self.springx
			self.springtimer = self.springtimer + dt
			self.y = self.springy - self.height - 31/16 + springytable[self.springb.frame]
			if self.springtimer > springtime then
				self:leavespring()
			end
			return
		end
	end
	
	if self.timer < springtime then
		self.timer = self.timer + dt
		if self.timer > springtime then
			self.timer = springtime
		end
		self.frame = math.ceil(self.timer/(springtime/3)+0.001)+1
		if self.frame > 3 then
			self.frame = 6-self.frame
		end
	end
end

function spring:draw()
	if self.green then
		if self.physics then
			love.graphics.draw(springgreenimg, springquads[spriteset][self.frame], math.floor((self.x-xscroll+.5)*16*scale), ((self.y-yscroll)*16+7)*scale, self.rotation, scale, scale, 8, 16)
		else
			love.graphics.draw(springgreenimg, springquads[spriteset][self.frame], math.floor((self.x-xscroll)*16*scale), ((self.y-yscroll)*16-8)*scale, 0, scale, scale)
		end
	else
		if self.physics then
			love.graphics.draw(springimg, springquads[spriteset][self.frame], math.floor((self.x-xscroll+.5)*16*scale), ((self.y-yscroll)*16+7)*scale, self.rotation, scale, scale, 8, 16)
		else
			love.graphics.draw(springimg, springquads[spriteset][self.frame], math.floor((self.x-xscroll)*16*scale), ((self.y-yscroll)*16-8)*scale, 0, scale, scale)
		end
	end
end

function spring:hit()
	self.timer = 0
end

function spring:passivecollide(a, b)
	if self.physics then
		self:leftcollide(a, b)
		return false
	end
end

function spring:ceilcollide(a, b)
	if self.physics then
		return true
	end
end

function spring:floorcollide(a, b)
	if self.physics then
		if (a == "spring" or a == "springgreen") and not self.spring then
			self:hitspring(b)
		end
		return true
	end
end

function spring:hitspring(b)
	self.springb = b
	self.springx = self.x
	self.springy = b.coy
	self.speedy = 0
	self.spring = true
	self.springtimer = 0
	self.gravity = 0
	self.mask[19] = true
	b:hit()
end

function spring:leavespring()
	self.y = self.springy - self.height-31/16
	self.speedy = -springforce
	self.gravity = yacceleration
	self.spring = false
	self.mask[19] = false
end

function spring:leftcollide(a, b)
	if self.physics then
		self.speedx = 0
		if a == "tile" then
			self.x = b.cox-2
		end
		return true
	end
end

function spring:rightcollide(a, b)
	if self.physics then
		self.speedx = 0
		if a == "tile" then
			self.x = b.cox
		end
		return true
	end
end