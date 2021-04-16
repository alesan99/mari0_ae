fire = class:new()

function fire:init(x, y)
	--PHYSICS STUFF
	if objects["bowser"]["boss"] then --make bowser fire this
		self.y = objects["bowser"]["boss"].y+0.25
		self.x = objects["bowser"]["boss"].x-0.750
		
		--get goal Y
		self.targety = objects["bowser"]["boss"].starty-math.random(3)+2/16
		self.source = "bowser"
	else
		self.y = y-1+1/16
		self.targety = self.y
		self.x = x+6/16
		self.source = "none"
	end
	
	self.speedy = 0
	self.speedx = -firespeed
	
	self.width = 24/16
	self.height = 8/16
	self.active = true
	self.static = false
	self.gravity = 0
	self.autodelete = true
	self.light = 2
	self.gravity = 0
	self.category = 17
	
	self.mask = {	true,
					true, false, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					false, true}
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = fireimg
	self.quad = firequad[1]
	self.offsetX = 12
	self.offsetY = 4
	self.quadcenterX = 12
	self.quadcenterY = 4
	
	self.rotation = 0 --for portals
	self.timer = 0
	self.quadi = 1
	
	playsound(firesound)
end

function fire:update(dt)
	--animate
	self.timer = self.timer + dt
	while self.timer > fireanimationdelay do
		if self.quadi == 2 then
			self.quadi = 1
		else
			self.quadi = 2
		end
		
		self.quad = firequad[self.quadi]
		self.timer = self.timer - fireanimationdelay
	end

	if self.speedx > 0 then
		self.animationdirection = "left"
	elseif self.speedx < 0 then
		self.animationdirection = "right"
	end
	
	if self.y > self.targety then
		self.y = self.y - fireverspeed*dt
		if self.y < self.targety then
			self.y = self.targety
		end
	elseif self.y < self.targety then
		self.y = self.y + fireverspeed*dt
		if self.y > self.targety then
			self.y = self.targety
		end
	end
end

function fire:leftcollide(a, b)
	return false
end

function fire:rightcollide(a, b)
	return false
end

function fire:floorcollide(a, b)
	return false
end

function fire:ceilcollide(a, b)
	return false
end