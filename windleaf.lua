windleaf = class:new()
local speeds = {18, 18, 18, 5}

function windleaf:init(x, y)
	self.x = x
	self.y = y
	self.speedx = speeds[math.random(#speeds)]
	self.speedy = self.speedx*0.9
	if windentityspeed < 0 then
		self.speedx = -self.speedx
	end
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = windleafimage
	self.quad = windleafquad[spriteset][math.random(1,2)] --random leaf bro!
	self.offsetX = 6
	self.offsetY = 2
	self.quadcenterX = 3
	self.quadcenterY = 3
end

function windleaf:update(dt)
	self.x = self.x + self.speedx*dt
	self.y = self.y + self.speedy*dt
	
	if ((self.speedx > 0 and self.x > xscroll+width+1) or (self.speedx < 0 and self.x < xscroll)) or self.y > yscroll+height+1 or self.delete then --check if off screen
		return true
	else
		return false
	end
end