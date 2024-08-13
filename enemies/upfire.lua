upfire = class:new()

function upfire:init(x, y, r)
	--PHYSICS STUFF
	self.cox = x
	self.coy = y
	self.starty = self.coy-1
	self.y = mapheight
	self.x = x-14/16
	
	self.speedy = 0
	self.speedx = 0
	
	self.width = 12/16
	self.height = 12/16
	self.active = true
	self.static = false
	self.gravity = upfiregravity
	self.autodelete = false
	
	local v = convertr(r, {"bool"}, true)
	if v[1] ~= nil then
		self.jumpforce = -math.sqrt(2*(self.gravity or yacceleration)*(mapheight-y+1))
		self.ignorelowgravity = true
	else
		self.jumpforce = -upfireforce
	end
	self.delay = 0
	self.category = 31
	
	self.mask = {	true,
					true, false, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					false}
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = upfireimg
	self.quad = upfirequad
	
	self.offsetX = 6
	self.offsetY = 3
	self.quadcenterX = 8
	self.quadcenterY = 8

	self.light = 2
	self.rotatetowardstrackpath = true
	self.rotatetowardstrackpathoffset = math.pi*1.5
	
	self.rotation = 0 --for portals
	self.timer = 0
end

function upfire:update(dt)
	--animate
	if self.y > mapheight and self.speedy > 0 then
		self.timer = self.timer + dt
		while self.timer > self.delay do
			self.speedy = self.jumpforce
			self.y = mapheight
			self.delay = math.random(0, 40)/10
			self.timer = self.timer - self.delay
		end
	end

	self.upsidedown = (self.speedy > 0)
	
	return false
end

function upfire:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function upfire:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function upfire:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function upfire:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function upfire:globalcollide(a, b)
	return true
end

function upfire:passivecollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end
