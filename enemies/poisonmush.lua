poisonmush = class:new()

function poisonmush:init(x, y)
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
					false, true}
	self.destroy = false
	self.autodelete = true
	
	--IMAGE STUFF
	self.drawable = false
	self.graphic = itemsimg
	self.quad = itemsquad[spriteset][3]
	self.offsetX = 7
	self.offsetY = 3
	self.quadcenterX = 9
	self.quadcenterY = 8
	
	self.rotation = 0 --for portals
	self.uptimer = 0
	
	self.falling = false
	self.light = 1
end

function poisonmush:update(dt)
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
	
	if self.uptimer < poisonmushtime then
		self.uptimer = self.uptimer + dt
		if self.uptimer >= poisonmushtime then
			self.drawable = true --fixes mushroom being invisible for a frame after coming out block
		end
		self.y = self.y - dt*(1/poisonmushtime)
		self.speedx = poisonmushspeed
		
	else
		if self.static == true then
			self.static = false
			self.active = true
			self.drawable = true
		end
	end
	
	if self.destroy then
		return true
	else
		return false
	end
end

function poisonmush:draw()
	if self.uptimer < poisonmushtime and not self.destroy then
		--Draw it coming out of the block.
		love.graphics.draw(itemsimg, self.quad, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), 0, scale, scale, self.quadcenterX, self.quadcenterY)
	end
end

function poisonmush:use(a,b)
	if b.animation == "grow1" or b.animation == "grow2" or b.animation == "shrink" then
		return false
	end
	if b.starred == false then
		b:die("poisonmush")
	end
	self.active = false
	self.destroy = true
	self.drawable = false
end

function poisonmush:leftcollide(a, b)
	self.speedx = poisonmushspeed
	
	if a == "player" then
		self:use(a, b)
		return false
	end
	
	return false
end

function poisonmush:rightcollide(a, b)
	self.speedx = -poisonmushspeed
	
	if a == "player" then
		self:use(a, b)
		return false
	end
	
	return false
end

function poisonmush:floorcollide(a, b)
	if a == "player" then
		self:use(a, b)
		return false
	end
	if a == "tile" then
		local x, y = b.cox, b.coy
		if self.speedx ~= 0 and inmap(x, y) and tilequads[map[x][y][1]].noteblock then
			hitblock(x, y, self, {dir="down"})
			self.falling = true
			self.speedy = -mushroomjumpforce
		end
	end
end

function poisonmush:ceilcollide(a, b)
	if a == "player" then
		self:use(a, b)
		return false
	end	
end

function poisonmush:passivecollide(a, b)
	if a == "player" then
		self:use(a, b)
		return false
	end	
end

function poisonmush:jump(x)
	self.falling = true
	self.speedy = -poisonmushjumpforce
	if self.x+self.width/2 < x-0.5 then
		self.speedx = -poisonmushspeed
	elseif self.x+self.width/2 > x-0.5 then
		self.speedx = poisonmushspeed
	end
end