platformspawner = class:new()

function platformspawner:init(x, y, direction, size)
	self.x = x
	self.y = y
	self.direction = direction
	self.timer = 0
	
	self.size = size
	self.speed = platformjustspeed
	self.delay = platformspawndelay

	if type(size) == "string" then
		local v = size:split("|")
		self.size = tonumber(v[1])
		self.speed = tonumber(v[2])
		self.delay = tonumber(v[3])
		if v[4] ~= nil then
			self.direction = v[4]
		end
	end
end

function platformspawner:update(dt)
	self.timer = self.timer + dt
	if self.timer > self.delay then
		if self.direction == "up" then
			local obj = platform:new(self.x, self.y+1, "justup", self.size)
			obj.speedy = -self.speed
			table.insert(objects["platform"], obj)
		else
			local obj = platform:new(self.x, self.y-0.5, "justdown", self.size)
			obj.speedy = self.speed
			table.insert(objects["platform"], obj)
		end
		
		self.timer = self.timer - self.delay
	end
	
	if self.x < xscroll - .5 then
		return true
	end
end