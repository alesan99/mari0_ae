pedestal = class:new()

function pedestal:init(x, y, t)
	self.cox = x
	self.coy = y
	self.x = x-1
	self.y = y-1
	self.width = 1
	self.height = 1
	self.speedx = 0
	self.speedy = 0
	self.portals = t or "both"
	self.active = true
	self.static = true
	self.category = 23
	self.mask = {true, true, false}
	self.quadi = 1
	self.gun = true
	self.timer = 0
end

function pedestal:draw()
	love.graphics.draw(pedestalimage, pedestalquad[self.quadi], math.floor((self.cox-1-xscroll)*16*scale), ((self.y-0.5-yscroll)*16*scale), 0, scale, scale)
end

function pedestal:update(dt)
	if self.gun then

	else
		if self.quadi ~= 10 then
			self.timer = self.timer + dt
			if self.timer > 0.1 then
				self.quadi = self.quadi + 1
				self.timer = 0
			end
		end
	end
end

function pedestal:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function pedestal:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function pedestal:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function pedestal:get(b)
	if self.gun then
		if not b.characterdata.noportalgun then
			b.portalgun = true
			b.portals = self.portals
			b:updateportalsavailable()

			self.gun = false
			self.active = false
		end
	end
end

function pedestal:globalcollide(a, b)
	if a == "player" then
		self:get(b)
	end
end

function pedestal:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function pedestal:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end