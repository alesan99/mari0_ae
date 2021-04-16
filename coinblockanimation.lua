coinblockanimation = class:new()

function coinblockanimation:init(x, y, t, i)
	self.x = x
	self.y = y
	
	self.timer = 0
	self.frame = 1

	if t then
		self.t = t
		if self.t == "collectable" then
			self.i = i
			self.offsety = 0
			self.speedy = -20.5
		end
	end
end

function coinblockanimation:update(dt)
	if self.t == "collectable" then
		self.timer = self.timer + dt
		while self.timer > 0.098 do
			self.frame = self.frame + 1
			self.timer = self.timer - 0.098
		end

		self.speedy = self.speedy + yacceleration*dt
		self.offsety = self.offsety + self.speedy*dt
		
		if self.frame >= 6 then
			
			addpoints(-200, self.x, self.y)
			return true
		end
	else
		self.timer = self.timer + dt
		while self.timer > coinblockdelay do
			self.frame = self.frame + 1
			self.timer = self.timer - coinblockdelay
		end
		
		if self.frame >= 31 then
			addpoints(-200, self.x, self.y)
			return true
		end
	end
	
	return false
end