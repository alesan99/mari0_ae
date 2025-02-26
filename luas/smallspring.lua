smallspring = class:new()

local veranim = {2,3,2,1}
local horanim = {5,6,7,4}
local bouncerangex = 0.2 --how much pixels are added to each side
local bouncerangey = 4/16--height of bounce range

function smallspring:init(x, y, dir)
	--PHYSICS STUFF
	self.x = x-1
	self.y = y-1
	self.cox = self.x
	self.coy = self.y
	self.width = 1
	self.height = 1
	self.speedx = 0
	self.speedy = 0
	self.static = false
	self.active = true
	self.dir = dir or "ver"
	
	self.extremeautodelete = true
	self.drawable = false
	self.category = 19
	self.mask = {	true, 
					false, false, false, false, true,
					false, true, false, true, false,
					false, false, true, false, false,
					true, true, false, false, false,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	if self.dir == "hor" then
		self.anim = horanim
		self.baseframe = 4
		self.baserotation = math.pi*1.5
		self.trackplatform = true
	else
		self.anim = veranim
		self.baseframe = 1
		self.baserotation = 0
	end
	self.rotation = self.baserotation

	self.timer = 0
	self.frame = self.baseframe
	self.springytable = {0, 4/16, 9/16, 0, 3/16, 5/16, -4/16}
	self.pipespawnmax = 1
end

function smallspring:update(dt)
	--rotate back to 0 (portals)
	self.rotation = math.fmod(self.rotation, math.pi*2)
	if self.rotation > self.baserotation then
		self.rotation = self.rotation - portalrotationalignmentspeed*dt
		if self.rotation < self.baserotation then
			self.rotation = self.baserotation
		end
	elseif self.rotation < self.baserotation then
		self.rotation = self.rotation + portalrotationalignmentspeed*dt
		if self.rotation > self.baserotation then
			self.rotation = self.baserotation
		end
	end

	if edgewrapping then --wrap around screen
		local minx, maxx = -self.width, mapwidth
		if self.x < minx then
			self.x = maxx
		elseif self.x > maxx then
			self.x = minx
		end
	end

	if self.timer > 0 then
		self.timer = self.timer - dt
		self.frame = self.anim[math.floor(((springtime-self.timer)/springtime)*#self.anim)+1]
		if self.timer < 0 then
			self.frame = self.baseframe
		end
	elseif self.dir == "hor" then
		local checktable = {"box", "smallspring", "powblock", "koopa", "spikeball"}
		local colls = checkrect(self.x-bouncerangex, (self.y+self.height/2)-bouncerangey/2, 1+bouncerangex*2, bouncerangey, checktable)
		
		if #colls > 0 then
			for j = 1, #colls, 2 do
				local a = colls[j]
				local b = objects[a][colls[j+1]]
				if not (a == "smallspring" and b.cox == self.cox and b.coy == self.coy) and (not b.tracked) then
					local dir = "right"
					if b.x+b.width/2 < self.x+b.width/2 then
						dir = "left"
					end
					if math.abs(b.speedx) < 2 and (a ~= "koopa" or b.small) then
						self:hit(a, b, dir)
					end
				end
			end
		end
	end

	if self.speedx > 0 then
		self.speedx = self.speedx - friction*dt*2
		if self.speedx < 0 then
			self.speedx = 0
		end
	elseif self.speedx < 0 then
		self.speedx = self.speedx + friction*dt*2
		if self.speedx > 0 then
			self.speedx = 0
		end
	end
	return false
end

function smallspring:draw()
	if self.customscissor then
		love.graphics.setScissor(math.floor((self.customscissor[1]-xscroll)*16*scale), math.floor((self.customscissor[2]-.5-yscroll)*16*scale), self.customscissor[3]*16*scale, self.customscissor[4]*16*scale)
	end
	love.graphics.draw(smallspringimg, smallspringquad[self.frame], math.floor((self.x+.5-xscroll)*16*scale), ((self.y+(8/16)-yscroll)*16-8)*scale, self.rotation, scale, scale, 8, 12)
	love.graphics.setScissor()
end

function smallspring:hit(a, b, dir)
	if dir == "up" then
		if a == "player" then
			if not b.spring then
				b.speedy = -springforce
			end
		elseif b.gravity ~= 0 then
			b.speedy = -springforce
		end
	elseif dir == "down" then
		if a == "player" then
			self.speedy = -20
		end
		--b.speedy = springforce
	elseif dir == "left" then
		if a == "spikeball" then
			b:kick("left", "smallspring")
			b.speedx = math.abs(b.speedx)
		else
			b.speedx = -springhorforce
		end
	elseif dir == "right" then
		if a == "spikeball" then
			b:kick("right", "smallspring")
			b.speedx = -math.abs(b.speedx)
		else
			b.speedx = springhorforce
		end
	end
	if self.timer > 0 then
		return
	end
	playsound(blockhitsound)
	self.timer = springtime
end

function smallspring:passivecollide(a, b)
	return false
end

function smallspring:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return true
	end
	if a == "smallspring" and self.dir == "hor" and b.dir == "hor" and self.speedy < 0 and b.speedy == 0 then
		b.speedy = self.speedy
	end
	if self.dir == "ver" and not b.static then
		self:hit(a, b, "up")
	end
	return true
end

function smallspring:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return true
	end
	if a == "redseesaw" then
		return true
	end
	if self.dir == "ver" and not b.static and a ~= "smallspring" and a ~= "icicle" and a ~= "donut" then
		--self:hit(a, b, "down")
	end
	return true
end

function smallspring:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return true
	end
	if a == "tile" and self.dir == "hor" then
		self.speedx = math.abs(self.speedx)
	end
	if self.dir == "hor" and not b.static then
		self:hit(a, b, "left")
	end
	return true
end

function smallspring:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return true
	end
	if a == "tile" and self.dir == "hor" then
		self.speedx = -math.abs(self.speedx)
	end
	if self.dir == "hor" and not b.static then
		self:hit(a, b, "right")
	end
	return true
end

function smallspring:globalcollide(a, b)
	if a == "snakeblock" then
		return true
	end
end