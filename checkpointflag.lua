checkpointflag = class:new()

local animationframes = 1 --3 (disabled because people will complain about it being static after touched)

function checkpointflag:init(x, y, r, i)
	--PHYSICS STUFF
	self.cox = x
	self.coy = y
	self.r = r
	self.i = i
	self.color = {0,0,0}
	self.symbolcolor = {255,255,255}
	self.activatetimer = false

	local v = convertr(r[3], {"string", "num"}, true)
	self.dir = v[1]
	self.powerup = v[2] or 2
	self.rotation = 0

	if self.dir == "up" or self.dir == "down" then
		self.x = x-12/16
		if self.dir == "down" then
			self.y = y-2
		else
			self.y = y-1
			self.rotation = math.pi
		end
		self.width = 8/16
		self.height = 2
	else
		if self.dir == "right" then
			self.x = x-2
			self.rotation = math.pi*1.5
		else
			self.x = x-1
			self.rotation = math.pi*.5
		end
		self.y = y-12/16
		self.width = 2
		self.height = 8/16
	end

	self.speedy = 0
	self.speedx = 0
	self.static = true
	self.active = true
	self.category = 17
	self.mask = {true}
	self.destroy = false

	self.animframe = 0
	
	--IMAGE STUFF
	self.drawable = false
	
	self.falling = false
	self.light = 1
end

function checkpointflag:update(dt)
	if self.activatetimer then
		self.activatetimer = self.activatetimer + 20*dt
		if self.activatetimer >= 5 then
			self.activatetimer = false
		end
	else
		--self.animframe = (self.animframe+*dt)%animationframes
	end
	if self.destroy then
		return true
	else
		return false
	end
end

function checkpointflag:draw(drop)
	local offx, offy = 0, 0
	if self.dir == "down" then
		offx = 8
	elseif self.dir == "up" then
		offx = -8
	elseif self.dir == "right" then
		offy = -8
	else
		offy = 8
	end
	local quadi = animationframes+math.floor(self.animframe)
	if self.activatetimer then
		quadi = (animationframes-1)+math.floor(self.activatetimer)
	elseif not self.active then
		quadi = (animationframes-1)+5
		if not drop then
			love.graphics.setColor(self.color)
		end
		love.graphics.draw(checkpointflagimg, checkpointflagquad[spriteset][(animationframes-1)+6], math.floor(((self.x+self.width/2-xscroll)*16+offx)*scale), math.floor(((self.y+self.height/2-yscroll-.5)*16+offy)*scale), self.rotation, scale, scale, 16, 16)
		if not drop then
			love.graphics.setColor(self.symbolcolor)
			love.graphics.draw(checkpointflagimg, checkpointflagquad[spriteset][(animationframes-1)+7], math.floor(((self.x+self.width/2-xscroll)*16+offx)*scale), math.floor(((self.y+self.height/2-yscroll-.5)*16+offy)*scale), self.rotation, scale, scale, 16, 16)
		end
	end
	if not drop then
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.draw(checkpointflagimg, checkpointflagquad[spriteset][quadi], math.floor(((self.x+self.width/2-xscroll)*16+offx)*scale), math.floor(((self.y+self.height/2-yscroll-.5)*16+offy)*scale), self.rotation, scale, scale, 16, 16)
end

function checkpointflag:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return true
	end
end

function checkpointflag:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return true
	end
end

function checkpointflag:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return true
	end
end

function checkpointflag:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return true
	end
end

function checkpointflag:passivecollide(a, b)
	if self:globalcollide(a, b) then
		return true
	end
end

function checkpointflag:globalcollide(a, b)
	if a == "player" then
		self:activate(b.playernumber)
		if self.powerup == 1 then
		elseif self.powerup == 2 then
			if b.size == 1 then
				b:grow()
			end
		else
			b:grow(self.powerup)
		end
		playsound(checkpointsound)
		self.activatetimer = 1
	end
end

function checkpointflag:activate(playeri)
	checkpointi = self.i
	checkpointx = self.cox--checkpoints[checkpointi]
	checkpointsublevel = actualsublevel
	self.active = false
	self.color = mariocolors[playeri][1]
	if (self.color[1]+self.color[2]+self.color[3])/3 > 200 then --is the color bright? if so, use a black symbol
		self.symbolcolor = {0, 0, 0}
	end
end
