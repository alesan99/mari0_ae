blockdebris = class:new()

function blockdebris:init(x, y, speedx, speedy, img, q, noframes)
	self.x = x
	self.y = y
	self.speedx = speedx
	self.speedy = speedy
	self.image = img or blockdebrisimage
	self.quad = q or blockdebrisquads.default[spriteset]
	
	self.timer = 0
	self.frame = 1
	self.noframes = noframes
	
	self.rotation = 0
end

function blockdebris:update(dt)
	if dropshadow then
		self.rotation = self.rotation + self.speedx*math.pi*dt
	elseif not self.noframes then
		self.timer = self.timer + dt
		while self.timer > blockdebrisanimationtime do
			self.timer = self.timer - blockdebrisanimationtime
			if self.frame == 1 then
				self.frame = 2
			else
				self.frame = 1
			end
		end
	end
	
	self.speedy = self.speedy + blockdebrisgravity*dt
	
	self.x = self.x + self.speedx*dt
	self.y = self.y + self.speedy*dt
	
	if self.y > mapheight then
		return true
	end
	
	return false
end

function blockdebris:draw()
	local q = self.quad[self.frame]
	if self.noframes then
		q = self.quad
	end
	love.graphics.draw(self.image, q, math.floor((self.x-xscroll)*16*scale), math.floor((self.y-yscroll-.5)*16*scale), self.rotation, scale, scale, 4, 4)
end