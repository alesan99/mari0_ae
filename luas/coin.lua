--most simple entity ever

coin = class:new()

function coin:init(x, y)
	self.cox = x
	self.coy = y
	self.speedy = 0
	self.speedx = 0
	
	self.width = 1
	self.height = 1
	self.rotation = 0 --for portals
	self.category = 2

	self.active = false
	self.static = true
end

function coin:update(dt)
	if math.abs(self.speedx) > 0 or math.abs(self.speedy) > 0 then
		self.static = false
	end

	--rotate back to 0 (portals)
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
	return false
end

function coin:draw()
	love.graphics.draw(coinimage, coinquads[spriteset][coinframe], math.floor((self.cox-1-xscroll)*16*scale), ((self.coy-1-yscroll)*16-8)*scale, 0, scale, scale)
end