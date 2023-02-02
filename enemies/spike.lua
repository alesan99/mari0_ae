spike = class:new()

local spikespeed = 2
local spikespittime = 1
local spikespitdelay = 3
local spikespittwicedelay = 0.6
local spikespitstart = 2
local spikespitend = 4
local spikestilltime = 0.6

function spike:init(x, y, t)
	--PHYSICS STUFF
	self.x = x-6/16
	self.y = y-11/16
	self.speedy = 0
	self.speedx = -spikespeed
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.category = 4
	
	self.mask = {	true, 
					false, false, false, false, true,
					false, true, false, true, false,
					false, false, true, false, false,
					true, true, false, false, false,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	
	self.emancipatecheck = true
	self.autodelete = true
	self.freezable = true
	self.frozen = false

	self.t = t or "spike" --spike or snow
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = spikeimg
	self.quad = spikequad[spriteset][1]
	self.offsetX = 6
	self.offsetY = 3
	self.quadcenterX = 8
	self.quadcenterY = 8
	if self.t == "snow" then
		self.graphic = snowspikeimg
	end
	
	self.rotation = 0 --for portals
	
	self.direction = "left"
	self.animationtimer = 0
	self.animationdirection = "right"
	self.movedirection = "left"
	
	self.falling = false

	self.spit = false
	self.spittwice = true
	self.spittimer = spikespitdelay
	self.spittingtimer = 0
	self.spitanimationtimer = 0
	self.spitframe = 1
	self.spitframes = {3,4,4,4,5,6,6}
	self.stilltimer = 0
	self.quadi = 3
	self.spikeball = false
	
	self.shot = false
end

function spike:update(dt)
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

	local closestplayer = 1 --find closest player
	for i = 2, players do
		local v = objects["player"][i]
		if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
			closestplayer = i
		end
	end
	
	
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
	elseif self.frozen then
		return false
	elseif self.spit then
		self.spittingtimer = self.spittingtimer + dt
		--spit ball
		local dist = 1
		if self.supersized then
			dist = self.supersized
		end
		if self.spitframe > (spikespitend+1) then
			if self.spikeball then
				if not self.spikeball.shot then
					local framedelay = spikespittime/#self.spitframes
					local timerange = (#self.spitframes-(spikespitend+1))*framedelay
					local offsetx = math.sin(math.min(1, (self.spittingtimer-((spikespitend+1)*framedelay))/timerange)*math.pi)*(4/16)
					if self.movedirection == "left" then
						self.spikeball.x = self.x + offsetx
					else
						self.spikeball.x = self.x - offsetx
					end
					self.spikeball.y = self.y - dist
				end
			end
		elseif self.spitframe > spikespitstart then
			if self.spikeball then
				if not self.spikeball.shot then
					local framedelay = spikespittime/#self.spitframes
					local timerange = (spikespitend-spikespitstart)*framedelay
					self.spikeball.x = self.x
					self.spikeball.y = self.y - dist*math.min(1, (self.spittingtimer-(spikespitstart*framedelay))/timerange)
				end
			end
		end
		--spit animation
		self.spitanimationtimer = self.spitanimationtimer + dt
		while self.spitanimationtimer > spikespittime/#self.spitframes and self.spitframe < #self.spitframes do
			self.spitframe = self.spitframe + 1
			self.quad = spikequad[spriteset][self.spitframes[self.spitframe]]
			self.spitanimationtimer = self.spitanimationtimer - spikespittime/#self.spitframes
		end
		if self.spittingtimer > spikespittime then
			self.spittingtimer = 0
			self.spitanimationtimer = 0
			self.quadi = 3
			self.quad = spikequad[spriteset][1]
			if self.spittwice then
				self.spittimer = spikespittwicedelay
				self.spittwice = false
			else
				self.spittimer = spikespitdelay
				self.spittwice = true
			end
			self.spikeball:spit()
			self.spikeball = false
			self.spit = false
			self.stilltimer = spikestilltime
		end

		if self.speedx > 0 then
			self.speedx = math.max(0, self.speedx - friction*dt)
		elseif self.speedx < spikespeed then
			self.speedx = math.min(0, self.speedx + friction*dt)
		end
	else
		--spitting
		if not (self.falling or self.clearpipe) then
			self.spittimer = self.spittimer - dt
			if self.spittimer < 0 then
				self.spit = true
				self.quad = spikequad[spriteset][self.quadi]
				self.spitframe = 1
				self.speedx = 0
				local ball = spikeball:new(self.x+self.width/2, self.y+self.height, self.t, self.movedirection)
				self.spikeball = ball
				if self.supersized then
					supersizeentity(self.spikeball)
					self.spikeball.y = self.spikeball.y-self.spikeball.height/self.supersized
				end
				self.spikeball:spitting()
				table.insert(objects["spikeball"], ball)
			end
		end

		--movement
		if self.stilltimer > 0 then
			self.stilltimer = self.stilltimer - dt
			if self.speedx > 0 then
				self.speedx = math.max(0, self.speedx - friction*dt)
			elseif self.speedx < spikespeed then
				self.speedx = math.min(0, self.speedx + friction*dt)
			end
			if self.x > objects["player"][closestplayer].x + 1 then
				self.animationdirection = "right"
				self.movedirection = "left"
			elseif self.x < objects["player"][closestplayer].x - 1 then
				self.animationdirection = "left"
				self.movedirection = "right"
			end
		else
			if self.x > objects["player"][closestplayer].x + 1 then
				self.movedirection = "left"
			elseif self.x < objects["player"][closestplayer].x - 1 then
				self.movedirection = "right"
			end
			if self.movedirection == "right" then
				if self.speedx > spikespeed then
					self.speedx = self.speedx - friction*dt*2
					if self.speedx < spikespeed then
						self.speedx = spikespeed
					end
				elseif self.speedx < spikespeed then
					self.speedx = self.speedx + friction*dt*2
					if self.speedx > spikespeed then
						self.speedx = spikespeed
					end
				end
			else
				if self.speedx < -spikespeed then
					self.speedx = self.speedx + friction*dt*2
					if self.speedx > -spikespeed then
						self.speedx = -spikespeed
					end
				elseif self.speedx > -spikespeed then
					self.speedx = self.speedx - friction*dt*2
					if self.speedx < -spikespeed then
						self.speedx = -spikespeed
					end
				end
			end
			if self.spit then
				if self.movedirection == "left" then
					self.animationdirection = "right"
				else
					self.animationdirection = "left"
				end
			else
				if self.speedx < 0 then
					self.animationdirection = "right"
				else
					self.animationdirection = "left"
				end
			end
		end
		
		--walking animation
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > goombaanimationspeed do
			self.animationtimer = self.animationtimer - goombaanimationspeed
			if self.quad == spikequad[spriteset][2] then
				self.quad = spikequad[spriteset][1]
			else
				self.quad = spikequad[spriteset][2]
			end
		end
			
		return false
	end
end

function spike:stomp()
	local dir = "left"
	if math.random(1,2) == 2 then dir = "right" end
	self:shotted(dir)
end

function spike:shotted(dir) --fireball, star, turtle
	playsound(shotsound)
	self.shot = true
	self.speedy = -shotjumpforce
	self.direction = dir or "right"
	self.active = false
	self.gravity = shotgravity
	if self.direction == "left" then
		self.speedx = -shotspeedx
	else
		self.speedx = shotspeedx
	end

	if self.spikeball then
		self.spikeball:spit()
		if self.t == "snow" then
			self.spikeball.speedx = 0
		end
	end
end

function spike:freeze()
	self.freezetimer = 0
	self.frozen = true
	self.speedx = 0
end

function spike:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if not self.spit then
		self.speedx = spikespeed
		self.animationdirection = "left"
		self.movedirection = "right"
	end
	return false
end

function spike:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if not self.spit then
		self.speedx = -spikespeed
		self.animationdirection = "right"
		self.movedirection = "left"
	end
	return false
end

function spike:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function spike:globalcollide(a, b)
	if a == "bulletbill" or a == "bigbill" then
		if b.killstuff ~= false then
			return true
		end
	end
	
	if a == "fireball" or a == "player" then
		return true
	end
end

function spike:startfall()
	self.falling = true
end

function spike:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.falling = false
end

function spike:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end

function spike:emancipate(a)
	self:shotted()
end

function spike:laser()
	self:shotted()
end

--spike ball
spikeball = class:new()

local spikeballspeed = 4.5
function spikeball:init(x, y, t, dir, rolling)
	--PHYSICS STUFF
	self.width = 12/16
	self.height = 12/16
	self.x = x-self.width/2
	self.y = y-self.height
	self.static = false
	self.active = true
	self.category = 4
	self.dir = dir or "left"
	self.speedy = 0
	if self.dir == "left" then
		self.speedx = -spikeballspeed
	else
		self.speedx = spikeballspeed
	end
	self.gravity = 0
	
	self.mask = {	true, 
					false, false, false, false, true,
					false, true, false, true, false,
					false, false, true, false, false,
					true, true, false, false, false,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	
	self.emancipatecheck = true
	self.autodelete = true
	self.freezable = true
	self.frozen = false

	self.t = t or "spike"
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = spikeballimg
	self.quad = goombaquad[spriteset][1]
	self.offsetX = 6
	self.offsetY = 3
	self.quadcenterX = 8
	self.quadcenterY = 8

	if self.t == "snow" then
		self.quad = goombaquad[spriteset][2]
		self.stompable = true
		self.speedx = 0
	end
	
	self.rotation = 0 --for portals
	
	self.direction = "left"
	self.animationtimer = 0

	self.animationdirection = "right"
	
	self.shot = false

	self.rolling = false
	if rolling then
		self:startrolling()
	end
end

function spikeball:update(dt)
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
	end

	if self.frozen then
		return false
	end

	if self.rolling then
		--roll
		self.rotation = self.rotation + ((self.speedx*math.pi)/(self.supersized or 1))*dt
	else
		--fake spinning
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > goombaanimationspeed do
			self.animationtimer = self.animationtimer - goombaanimationspeed
			if self.animationdirection == "left" then
				self.animationdirection = "right"
			else
				self.animationdirection = "left"
			end
		end
	end
end

function spikeball:draw()
	if not self.drawable then
		local offsetX, offsetY = self.offsetX, self.offsetY
		if self.supersized then
			offsetX = offsetX*self.supersized
			offsetY = (offsetY-8)*self.supersized+8
		end
		love.graphics.draw(self.graphic, self.quad, math.floor(((self.x-xscroll)*16+offsetX)*scale), math.floor(((self.y-yscroll)*16-offsetY)*scale), 0, (self.animationscalex or 1)*scale, (self.animationscaley or 1)*scale, self.quadcenterX, self.quadcenterY)
	end
end

function spikeball:stomp(x, b)
	if self.rolling and self.speedx == 0 then
		local dir = "right"
		if b and b.x+b.width/2 > self.x+self.width/2 then
			dir = "left"
		end
		self:kick(dir)
	else
		self:broke()
	end
end

function spikeball:kick(dir, smallspring)
	playsound(shotsound)
	if dir == "left" then
		self.speedx = -spikeballspeed
	else
		self.speedx = spikeballspeed
	end
	self.speedy = -9
	if smallspring then
		if lowgravity then
			self.speedy = -6
		else
			self.speedy = -13
		end
	end
end

function spikeball:shotted(dir)
	if onscreen(self.x-1, self.y-1, self.width+2, self.height+2) then
		playsound(shotsound)
	end
	self.shot = true
	self.speedy = -shotjumpforce
	self.direction = dir or "right"
	self.active = false
	self.gravity = shotgravity
	if self.direction == "left" then
		self.speedx = -shotspeedx
	else
		self.speedx = shotspeedx
	end
end

function spikeball:broke(dir)
	local dir = dir
	if not dir then
		dir = "left"
		if math.random(1,2) == 2 then dir = "right" end
	end
	self:shotted(dir)
end

function spikeball:freeze()
	self.frozen = true
end

function spikeball:spitting()
	self.static = true
	self.rolling = false
	self.drawable = false
end

function spikeball:spit()
	if self.dir == "left" then
		self.speedx = -spikeballspeed
	else
		self.speedx = spikeballspeed
	end
	self.static = false
	self.drawable = true
end

function spikeball:startrolling()
	if self.rolling then
		return false
	end
	self.gravity = yacceleration
	self.rolling = true
	self.falling = false
	if self.t == "spike" then
		self.killstuff = true
	end
end

function spikeball:startfall()
	self.falling = true
end

function spikeball:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "tile" and self.t == "spike" then
		local ti = 1
		if ismaptile(b.cox, b.coy) and map[b.cox][b.coy][1] then
			ti = map[b.cox][b.coy][1]
		end
		if self.supersized and tilequads[ti].coinblock or (tilequads[ti].debris and blockdebrisquads[tilequads[ti].debris]) then -- hard block
			destroyblock(b.cox, b.coy)
			if self.supersized then
				return false
			end
		else
			hitblock(b.cox, b.coy, {size=2}, {sound = onscreen(b.cox,b.coy)})
			if self.supersized and not (ismaptile(b.cox, b.coy) and map[b.cox][b.coy][1] and tilequads[map[b.cox][b.coy][1]].collision) then
				return false
			end
		end
	end
	if self.rolling and a == "player" then
		if self.speedx < 0 then
			self:broke("right")
		else
			self:kick("right")
		end
		return false
	end
	if a == "smallspring" then
		self.speedx = math.abs(self.speedx)
		self:startrolling()
		return false
	end
	if not self.static then
		self:broke()
	end
	return false
end

function spikeball:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "tile" and self.t == "spike" then
		local ti = 1
		if ismaptile(b.cox, b.coy) and map[b.cox][b.coy][1] then
			ti = map[b.cox][b.coy][1]
		end
		if self.supersized and tilequads[ti].coinblock or (tilequads[ti].debris and blockdebrisquads[tilequads[ti].debris]) then -- hard block
			destroyblock(b.cox, b.coy)
			if self.supersized then
				return false
			end
		else
			hitblock(b.cox, b.coy, {size=2}, {sound = onscreen(b.cox,b.coy)})
			if self.supersized and not (ismaptile(b.cox, b.coy) and map[b.cox][b.coy][1] and tilequads[map[b.cox][b.coy][1]].collision) then
				return false
			end
		end
	end
	if self.rolling and a == "player" then
		if self.speedx > 0 then
			self:broke("left")
		else
			self:kick("left")
		end
		return false
	end
	if a == "smallspring" then
		self.speedx = -math.abs(self.speedx)
		self:startrolling()
		return false
	end
	if not self.static then
		self:broke()
	end
	return false
end

function spikeball:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "player" then
		return false
	end
	if not self.static then
		self:broke()
	end
end

function spikeball:globalcollide(a, b)
	if self.killstuff and a ~= "spike" then
		if fireballkill[a] and not b.resistsenemykill then
			b:shotted("left")
			return true
		end
	end
	if a == "bulletbill" or a == "bigbill" then
		if b.killstuff ~= false then
			return true
		end
	end
	
	if a == "fireball" or (a == "player" and not self.rolling) then
		return true
	end
end

function spikeball:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if self.rolling then
		if b.SLOPE then
			if b.dir == "left" then
				self.speedx = self.speedx - 16*b.incline*gdt
			else
				self.speedx = self.speedx + 16*b.incline*gdt
			end
		end
	end
	if self.rolling and a == "player" then
		if b.x+b.width/2 > self.x+self.width/2 then
			self:kick("left")
		else
			self:kick("right")
		end
		return false
	end
	if not self.rolling then
		self:broke()
	else
		self.falling = false
		if self.speedy > 0 then
			self.speedy = -((self.speedy-1)*0.5)
		end
	end
end

function spikeball:passivecollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "spike" then
		return false
	end
	if a == "player" then
		return false
	end
	if a == "tile" and self.t == "spike" then
		local ti = 1
		if ismaptile(b.cox, b.coy) and map[b.cox][b.coy][1] then
			ti = map[b.cox][b.coy][1]
		end
		if self.supersized and tilequads[ti].coinblock or (tilequads[ti].debris and blockdebrisquads[tilequads[ti].debris]) then -- hard block
			destroyblock(b.cox, b.coy)
			if self.supersized then
				return false
			end
		else
			hitblock(b.cox, b.coy, {size=2}, {sound = onscreen(b.cox,b.coy)})
			if self.supersized and not (ismaptile(b.cox, b.coy) and map[b.cox][b.coy][1] and tilequads[map[b.cox][b.coy][1]].collision) then
				return false
			end
		end
	end
	if a == "smallspring" then
		self.speedx = -self.speedx
		self:startrolling()
		return false
	end
	if not self.static then
		self:broke()
	end
	return false
end

function spikeball:emancipate(a)
	self:shotted()
end

function spikeball:laser()
	self:shotted()
end

function spikeball:portaled()
	self.killstuff = true
end

function spikeball:dosupersize()
	self.killstuff = true
end