poof = class:new()

function poof:init(x, y, frames, lifetime, sx, sy, static, sscale, color)
	self.x = x
	self.y = y
	self.speedx = sx or 0
	self.speedy = sy or 0
	self.static = static or false--stays static on screen regardless of scrolling
	if self.static then
		self.xscroll = xscroll or 0
		self.yscroll = yscroll or 0
	end
	self.scale = sscale or 1

	self.frames = frames or {1, 2, 3, 4} --negatives indicate mirroring
	self.framecount = #self.frames
	self.frame = 1

	self.color = color

	self.lifetimer = 0
	self.lifetime = lifetime or 1
end

function poof:update(dt)
	self.x = self.x + self.speedx*dt
	self.y = self.y + self.speedy*dt

	self.lifetimer = self.lifetimer + dt
	if self.lifetimer > self.lifetime then
		return true
	end

	self.frame = math.max(1, math.ceil((self.lifetimer/self.lifetime)*self.framecount))

	return false
end

function poof:draw()
	if self.color then
		love.graphics.setColor(self.color)
	else
		love.graphics.setColor(255, 255, 255)
	end
	local mirror = 1
	if self.frames[self.frame] < 0 then
		mirror = -1
	end
	love.graphics.draw(poofimg, poofquad[spriteset][math.abs(self.frames[self.frame])], math.floor((self.x-(self.xscroll or xscroll))*16*scale), math.floor((self.y-(self.yscroll or yscroll)-.5)*16*scale), 0, self.scale*scale*mirror, self.scale*scale, 8, 8)
end
