flower = class:new()

function flower:init(x, y, t)
	--PHYSICS STUFF
	self.starty = y
	self.x = x-6/16
	self.y = y-11/16
	self.speedy = 0
	self.speedx = 0
	self.width = 12/16
	self.height = 12/16
	self.static = true
	self.active = true
	self.category = 6
	self.mask = {true}
	self.destroy = false
	self.autodelete = true
	self.gravity = 0
	self.t = t or "fire"
	
	--IMAGE STUFF
	self.drawable = false
	self.pipespawnmax = 1
	if self.t == "ice" then
		self.graphic = iceflowerimg
		self.quad = flowerquad[spriteset][1]
	elseif self.t == "tanooki" then
		self.graphic = itemsimg
		self.quad = itemsquad[spriteset][10]
	elseif self.t == "feather" then
		self.graphic = itemsimg
		self.quad = itemsquad[spriteset][11]
	elseif self.t == "carrot" then
		self.graphic = itemsimg
		self.quad = itemsquad[spriteset][12]
	elseif self.t == "superball" then
		self.graphic = superballflowerimg
		self.quad = coinblockquads[spriteset][1]
	elseif self.t == "blueshell" then
		self.graphic = itemsimg
		self.quad = itemsquad[spriteset][16]
	elseif self.t == "boomerang" then
		self.graphic = itemsimg
		self.quad = itemsquad[spriteset][17]
	elseif self.t == "hammersuit" then
		self.graphic = itemsimg
		self.quad = itemsquad[spriteset][14]
	elseif self.t == "frogsuit" then
		self.graphic = itemsimg
		self.quad = itemsquad[spriteset][15]
	else
		self.graphic = flowerimg
		self.quad = flowerquad[spriteset][1]
	end
	self.offsetX = 7
	self.offsetY = 3
	self.quadcenterX = 9
	self.quadcenterY = 8
	
	self.rotation = 0 --for portals
	self.uptimer = 0
	self.timer = 0
	self.quadi = 1
	
	self.falling = false
	self.light = 1
end

function flower:update(dt)	
	if self.uptimer < mushroomtime then
		self.uptimer = self.uptimer + dt
		self.y = self.y - dt*(1/mushroomtime)
	end
	
	if self.uptimer >= mushroomtime then
		if not self.drawable then
			self.y = self.starty-27/16
		end
		self.active = true
		self.drawable = true
	end
	
	--animate
	if self.t == "superball" then
		self.quad = coinblockquads[spriteset][coinframe]
	elseif (not self.t) or self.t == "fire" or self.t == "ice" then
		self.timer = self.timer + dt
		while self.timer > staranimationdelay do
			self.quadi = self.quadi + 1
			if self.quadi == 5 then
				self.quadi = 1
			end
			self.quad = flowerquad[spriteset][self.quadi]
			self.timer = self.timer - staranimationdelay
		end
	end
	
	if self.destroy then
		return true
	else
		return false
	end
end

function flower:draw()
	if self.uptimer < mushroomtime and not self.destroy then
		--Draw it coming out of the block.
		love.graphics.draw(self.graphic, self.quad, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), 0, scale, scale, self.quadcenterX, self.quadcenterY)
	end
end

function flower:passivecollide(a, b)
	if self.active and a == "player" then
		self:use(b)
	end
end

function flower:leftcollide(a, b)
	if a == "player" then
		self:use(b)
	end
	
	return false
end

function flower:rightcollide(a, b)
	if a == "player" then
		self:use(b)
	end
	
	return false
end

function flower:floorcollide(a, b)
	if self.active and a == "player" then
		self:use(b)
	end	
end

function flower:ceilcollide(a, b)
	if self.active and a == "player" then
		self:use(b)
	end	
end

function flower:jump(x)
	
end

function flower:use(b)
	if self.t == "ice" then
		b:grow(7)
	elseif self.t == "tanooki" then
		b:grow(9)
	elseif self.t == "feather" then
		b:grow(10)
	elseif self.t == "carrot" then
		b:grow(11)
	elseif self.t == "superball" then
		b:grow(13)
	elseif self.t == "blueshell" then
		b:grow(14)
	elseif self.t == "boomerang" then
		b:grow(15)
	elseif self.t == "hammersuit" then
		b:grow(4)
	elseif self.t == "frogsuit" then
		b:grow(5)
	else
		b:grow(3)
	end
	self.active = false
	self.destroy = true
	self.drawable = false
end