leaf = class:new()

function leaf:init(x, y)
	--PHYSICS STUFF
	self.x = x-6/16
	self.y = y-11/16
	self.startx = self.x
	self.starty = self.y
	self.speedy = 0
	self.speedx = 0
	self.width = 12/16
	self.height = 12/16
	self.static = true
	self.active = true
	self.category = 6
	self.gravity = 0
	self.mask = {	true,
					true, false, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true}
	self.destroy = false
	self.autodelete = true
	
	self.dance = true
	self.dancev = 0
	self.startdancing = false
	self.dancey = 0
	
	--IMAGE STUFF
	self.drawable = false
	self.graphic = itemsimg
	self.quad = itemsquad[spriteset][6]
	self.offsetX = 7
	self.offsetY = 3
	self.quadcenterX = 8
	self.quadcenterY = 8
	self.animationdirection = "right"
	
	self.rotation = 0 --for portals
	self.uptimer = 0
	self.timer = 0
	self.timer2 = 0
	
	self.falling = false
end

function leaf:update(dt)
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
	
	if self.uptimer < 0.0001 then
		self.uptimer = self.uptimer + dt
		self.y = self.y - 16/16
		self.gravity = 14
		self.speedy = -leafjumpforce
		self.dance = true
	else

		if self.dance and self.speedy > 0 and self.gravity and self.gravity > 0 then
			self.gravity = 0
			self.starty = self.y
			self.startdancing = true
		end
		if self.static == true then
			self.static = false
			self.active = true
			self.drawable = true
		end
	end
	
	--fall in a fancy way
	if self.dance and (not self.static) and self.startdancing and self.active and (not self.tracked) then
		self.starty = self.starty + 1.3*dt
		self.y = self.starty
		self.dancev = self.dancev + 1.8*dt
		while self.dancev > 2 do
			self.dancev = self.dancev - 2
		end

		local v = self.dancev%1
		local dist = 2
		if self.dancev < 1 then
			--right
			self.x = self.startx + ((-math.cos(math.pi*v)+1)*.5)*dist
			self.animationdirection = "left"
		else
			--left
			self.x = self.startx + (dist-((-math.cos(math.pi*v)+1)*.5)*dist)
			self.animationdirection = "right"
		end
		self.y = self.starty + math.sin(v*math.pi)*.6
	end
	
	if self.destroy then
		return true
	else
		return false
	end
end

function leaf:draw()
	if self.uptimer < mushroomtime and not self.destroy then
		--Draw it coming out of the block.
		love.graphics.draw(self.graphic, self.quad, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), 0, scale, scale, self.quadcenterX, self.quadcenterY)
	end
end

function leaf:leftcollide(a, b)
	if a == "player" then
		self:use(b)
	end
	
	return false
end

function leaf:rightcollide(a, b)
	if a == "player" then
		self:use(b)
	end
	
	return false
end

function leaf:floorcollide(a, b)
	if a == "player" then
		self:use(b)
	end	
end

function leaf:ceilcollide(a, b)
	if a == "player" then
		self:use(b)
	end	
end

function leaf:passivecollide(a, b)
	if a == "player" then
		self:use(b)
	end	
end


function leaf:jump(x)

end

function leaf:use(b)
	b:grow(6)
	self.active = false
	self.destroy = true
	self.drawable = false
end

function leaf:dotrack()
	self.dance = false
end