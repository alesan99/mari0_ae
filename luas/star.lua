star = class:new()

function star:init(x, y, t)
	--PHYSICS STUFF
	self.x = x-6/16
	self.y = y-11/16
	self.speedy = 0
	self.speedx = 0
	self.width = 12/16
	self.height = 12/16
	self.static = true
	self.active = true
	self.category = 6
	self.mask = {	true,
					false, false, true, true, true,
					false, true, false, true, true,
					false, true, true, false, true,
					true, true, false, true, true,
					false, true, true, false, false,
					true, false, true, true, true,
					true}
	self.destroy = false
	self.gravity = 40
	self.autodelete = true
	self.releasespeedx = mushroomspeed
	
	--IMAGE STUFF
	self.drawable = false
	self.graphic = starimg
	self.quad = starquad[spriteset][1]
	self.offsetX = 7
	self.offsetY = 3
	self.quadcenterX = 9
	self.quadcenterY = 8

	self.t = t or "star"

	if self.t == "hammersuit" then
		self.graphic = itemsimg
		self.quad = itemsquad[spriteset][14]
	elseif self.t == "tanookisuit" then
		self.graphic = itemsimg
		self.quad = itemsquad[spriteset][10]
	elseif self.t == "frogsuit" then
		self.graphic = itemsimg
		self.quad = itemsquad[spriteset][15]
	end
	
	self.rotation = 0 --for portals
	self.uptimer = 0
	self.timer = 0
	self.quadi = 1
	
	self.falling = false
	self.light = 2
	self.pipespawnmax = 1
end

function star:update(dt)
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
	
	if self.uptimer < mushroomtime then
		self.uptimer = self.uptimer + dt
		self.y = self.y - dt*(1/mushroomtime)
	else
		if self.static == true then
			self.static = false
			self.active = true
			self.drawable = true
			if not self.tracked then
				self.speedy = -starjumpforce/2
				self.speedx = mushroomspeed
			end
		end
	end
	
	if self.t == "star" then
		--animate
		self.timer = self.timer + dt
		while self.timer > staranimationdelay do
			self.quadi = self.quadi + 1
			if self.quadi == 5 then
				self.quadi = 1
			end
			self.quad = starquad[spriteset][self.quadi]
			self.timer = self.timer - staranimationdelay
		end
	end
	
	if self.destroy then
		return true
	else
		return false
	end
end

function star:draw()
	if (self.drawable == false) and (not self.destroy) then
		--Draw it coming out of the block.
		love.graphics.draw(self.graphic, self.quad, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), 0, scale, scale, self.quadcenterX, self.quadcenterY)
	end
end

function star:globalcollide(a, b)

end

function star:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return true
	end
	self.speedx = mushroomspeed
	
	if a == "player" then
		self:use(b)
	end
	
	return false
end

function star:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return true
	end
	self.speedx = -mushroomspeed
	
	if a == "player" then
		self:use(b)
	end
	
	return false
end

function star:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return true
	end
	if self.active and a == "player" then
		self:use(b)
	end	
	
	if a ~= "tracksegment" then
		self.speedy = -starjumpforce
	end
	return false
end

function star:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return true
	end
	if self.active and a == "player" then
		self:use(b)
	end
end

function star:passivecollide(a, b)
	if self:globalcollide(a, b) then
		return true
	end
	if self.active and a == "player" then
		self:use(b)
	end
end

function star:use(b)
	if b.animation == "grow1" or b.animation == "grow2" or b.animation == "shrink" then
		return false
	end
	if self.t == "star" then
		b:star()
	elseif self.t == "tanookisuit" then
		b:grow(9)
	elseif self.t == "hammersuit" then
		b:grow(4)
	elseif self.t == "frogsuit" then
		b:grow(5)
	end
	self.active = false
	self.destroy = true
	self.drawable = false
end

function star:jump(x)
	self.falling = true
	self.speedy = -mushroomjumpforce
	if self.x+self.width/2 < x-0.5 then
		self.speedx = -mushroomspeed
	elseif self.x+self.width/2 > x-0.5 then
		self.speedx = mushroomspeed
	end
end