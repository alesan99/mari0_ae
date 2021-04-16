mariohammer = class:new()

function mariohammer:init(x, y, dir, v)
	--PHYSICS STUFF
	self.y = y+4/16
	self.speedy = (-math.sqrt(2*yacceleration*3.5))+v.speedy --bobthelawyer?
	if dir == "right" then
		self.speedx = hammerspeed+v.speedx
		self.x = x+3/16
	else
		self.speedx = (-hammerspeed)+v.speedx
		self.x = x-24/16
	end
	self.width = 16/16
	self.height = 16/16
	self.active = true
	self.static = false
	self.category = 13
	
	self.mask = {	true,
					true, true, false, false, true,
					true, true, true, true, false,
					true, true, true, true, false,
					true, true, true, false, false,
					true, true, false, true, true,
					false, true, false, false, true,
					false, true}
					
	self.destroy = false
	self.destroysoon = false
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = hammerimg
	self.quadi = 1
	self.quad = hammerquad[spriteset][1]
	self.offsetX = 8
	self.offsetY = 0
	self.quadcenterX = 8
	self.quadcenterY = 8
	self.animationdirection = dir
	
	self.mariohammerthrower = v
	
	self.rotation = 0 --for portals
	self.timer = 0
end

function mariohammer:update(dt)
	--rotate back to 0 (portals)
	self.rotation = 0
	
	--animate
	self.timer = self.timer + dt
	while self.timer > hammeranimationspeed do
		self.quadi = self.quadi + 1
		if self.quadi == 5 then
			self.quadi = 1
		end
		self.quad = hammerquad[spriteset][self.quadi]
		self.timer = self.timer - hammeranimationspeed
	end
	
	if self.x < xscroll-1 or self.x > xscroll+width+1 or self.y > mapheight and self.active then
		self.mariohammerthrower:mariohammercallback()
		self.destroy = true
	end
	
	if self.destroy then
		return true
	else
		return false
	end
end

function mariohammer:leftcollide(a, b)
	--self.x = self.x-.5
	self:hitstuff(a, b)
	
	return false
end

function mariohammer:rightcollide(a, b)
	--self.x = self.x-.5
	self:hitstuff(a, b)
	
	return false
end

function mariohammer:floorcollide(a, b)
	self:hitstuff(a, b)
	return false
end

function mariohammer:ceilcollide(a, b)
	self:hitstuff(a, b)
	return false
end

function mariohammer:passivecollide(a, b)
	self:ceilcollide(a, b)
	return false
end

function mariohammer:hitstuff(a, b)
	if mariohammerkill[a] then
		if a == "koopaling" and b.t == 9 and not (b.hittimer and b.hittimer > 0) then
			addpoints(100, self.x, self.y)
		end
		b:shotted("right")
		if a ~= "bowser" then
			addpoints(firepoints[a], self.x, self.y)
		end
	elseif a == "enemy" then
		if b:shotted("right", nil, nil, false, true) ~= false and (not b.resistsenemykill) and (not b.resistshammer) then
			addpoints(b.firepoints or 200, self.x, self.y)
		else
			return false
		end
	elseif a == "boomboom" then
		if b.ducking == false then
			b:shotted("right")
		else

		end
	end
end

function mariohammer:explode()
	if self.active then
		self.mariohammerthrower:mariohammercallback()
		
		self.destroy = true
		self.active = false
		return true
	end
end