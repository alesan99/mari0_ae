cappy = class:new()

local throwdist = 4
local throwspeed = 10
local holdtime = 0.5
local returnspeed = 15

local playery = -1/16

local spintime = 0.12

local releasenotice = false--people keep on asking the same question and it's annoying

function cappy:init(player)
	self.player = player
	self.num = self.player.playernumber

	self.x = self.player.x
	self.y = self.player.y
	
	self.active = false
	self.static = true
	
	self.speedy = 0
	self.speedx = 0
	self.width = 12/16
	self.height = 13/16
	self.category = 4
	self.gravity = 0
	self.mask = {	true, 
					true, false, false, false, false,
					false, true, false, false, false,
					false, true, false, false, false,
					false, false, false, false, false,
					false, false, false, false, false,
					false, false, false, false, false,
					false, true}
	self.rotation = 0
	--IMAGE STUFF
	self.drawable = false
	if self.player.hats then
		self.hat = self.player.hats[1]
	else
		self.hat = 1
	end
	if not self.hat or self.hat == 0 then
		self.hat = 1
	end
	self.spin = 1
	self.dir = "left"
	self.spintimer = 0
	self.holdtimer = 0
	
	self.thrown = false
	self.returning = false

	self.button = false --what button was used to trigger it?
	
	self.cooldown = 0
	
	--Possesion
	self.host = false
	
	self.jumping = false
end

function cappy:update(dt)
	if self.thrown then
		if self.returning then
			--start returning
			local rx, ry = (self.player.x + -self.x), (self.player.y + -self.y)
			local dist = math.sqrt(rx*rx+ry*ry)
			self.speedx, self.speedy = (rx)/dist*returnspeed, (ry)/dist*returnspeed
		elseif math.abs(self.x-self.ox) > throwdist or self.speedx == 0 then
			--stay in position when thrown
			self.speedx = 0
			self.speedy = 0
			if ((self.button == "run" and runkey(self.num)) or (self.button == "use" and usekey(self.num))) and self.holdtimer < holdtime then
				self.holdtimer = self.holdtimer + dt
			else
				self.returning = true
				self.holdtimer = 0
			end
		end
		--spin animation
		self.spintimer = self.spintimer + dt
		while self.spintimer > spintime do
			self.spin = -self.spin
			self.spintimer = self.spintimer-spintime
		end
	elseif self.host then
		self.x = self.host.x
		self.y = self.host.y
		self.player.x = self.host.x+(self.host.width/2)-(self.player.width/2)
		self.player.y = self.host.y+playery
		self.player.drawable = false --persist
		
		if self.host.movedist then
			self.player.x = self.host.x-3
		end
		
		--turn hat
		if self.host.speedx then
			self.player.speedx = self.host.speedx
			self.player.speedy = self.host.speedy
			if self.host.speedx < 0 then
				self.spin = -1
			else
				self.spin = 1
			end
		end
		
		--move
		self.cooldown = math.max(0, self.cooldown - dt)
		if leftkey(self.num) then
			if self.host.speedx then
				if self.host.small and self.host.speedx >= 0 then
					self.host:stomp(self.x+self.host.width, self)
				elseif self.host.speedx >= 0 and self.host.rightcollide then
					self.host:rightcollide("spring", self)
				end
			end
			if self.host.startx and self.host.speedx then
				self.host.startx = self.host.startx - math.abs(self.host.speedx)*dt
			end
			if (self.host.gravity and self.host.gravity == 0) then
				self.host.speedx = -math.abs(self.host.speedx)
			end
			self.player.x = self.player.x-0.1
		elseif rightkey(self.num) then
			if self.host.speedx then
				if self.host.small and self.host.speedx <= 0 then
					self.host:stomp(self.x-self.host.width, self)
				elseif self.host.speedx <= 0 and self.host.leftcollide then
					self.host:leftcollide("spring", self)
				end
			end
			if self.host.startx and self.host.speedx then
				self.host.startx = self.host.startx + math.abs(self.host.speedx)*dt
			end
			if (self.host.gravity and self.host.gravity == 0) then
				self.host.speedx = math.abs(self.host.speedx)
			end
			self.player.x = self.player.x+0.1
		end
		if upkey(self.num) then
			if self.host.rotation then
				self.host.rotation = self.host.rotation - dt
			end
			self.player.y = self.player.y-0.2
		elseif downkey(self.num) then
			if (self.host.small == false) or (self.host.shellanimal and not self.host.small) then
				self.host:stomp()
			elseif self.host.dead == false and self.host.stomp and self.cooldown <= 0 then
				self.host:stomp()
				self.cooldown = 0.5
				if self.host.dead then
					self:release()
					return
				end
			end
			if self.host.rotation then
				self.host.rotation = self.host.rotation + dt
			end
			self.player.y = self.player.y+0.1
		end
		if runkey(self.num) then
			self.host:update(dt)
		end
		if self.host.shot or self.host.dead or self.host.delete or levelfinished then
			self:release()
			return
		end
		
		if self.host.jumptime and self.host.timer2 then
			self.host.timer2 = 0
		end
		
		if self.jumping and (self.host.speedy == 0 or self.host.speedy == -goombajumpforce) then
			self.jumping = false
		end
		
		if self.spin == 1 then
			self.dir = "right"
		else
			self.dir = "left"
		end
	end
end

function cappy:draw()
	if self.drawable then
		local width, height = self.width, self.height
		local offsety = -6
		if self.host then
			offsety = -5
			width, height = self.host.width, self.host.height
		end
		
		if self.hat == 1 then
			love.graphics.setColor(self.player.colors[1])
		else
			love.graphics.setColor(1, 1, 1)
		end
		local graphic = hat[self.hat].graphic
		local quad = hat[self.hat].quad[1]
		if self.player.size > 1 then
			graphic = bighat[self.hat].graphic
			quad = bighat[self.hat].quad[1]
		end
		love.graphics.draw(graphic, quad, math.floor((self.x+width/2-xscroll)*16*scale), ((self.y-yscroll)*16-8-offsety)*scale, 0, (self.spin)*scale, scale, 4, 8)
	end
end

function cappy:trigger(dir, button)
	if self.host then
		if upkey(self.num) then
			self:release()
		else
			self:fire()
		end
	elseif not self.thrown then
		self.button = button
		self:throw(dir)
	end
end

function cappy:throw(dir)
	self.player.drawhat = false
	if self.player.jumping or self.player.falling then
		self.player.speedy = math.min(-6, self.player.speedy-6) --stall in the air
	end
	self.drawable = true

	self.thrown = true
	self.active = true
	self.static = false
	self.x = self.player.x
	self.y = self.player.y
	
	self.returning = false
	self.ox = self.x
	self.speedy = 0
	if dir == "left" then
		self.speedx = -throwspeed
	else
		self.speedx = throwspeed
	end
end


function cappy:back()
	if self.host then
		return
	end
	
	self.player.drawhat = true
	self.drawable = false
	
	self.thrown = false
	self.holdtimer = 0
	self.active = false
	self.static = true
	self.x = self.player.x
	self.y = self.player.y
end

function cappy:capture(b, a)
	self.host = b
	
	if self.host.portaled then
		self.host:portaled()
	end
	
	self.player.static = true
	self.player.active = false
	self.player.drawable = false
	self.active = false
	self.static = true
	
	self.drawable = true
	self.thrown = false
	
	if not releasenotice then
		notice.new("to exit enemy: hold up\nthen press the run button", notice.white, 6)
		releasenotice = true
	end
end

function cappy:release()
	self.player.static = false
	self.player.active = true
	self.player.drawable = true

	if self.host then
		self.player.x = self.host.x+(self.host.width/2)-(self.player.width/2)
		self.player.y = self.host.y-self.player.height
	end
	if levelfinished then
		self.player.active = true
		self.player.speedx = 0
		self.player.speedy = 0
	else
		self.player.speedy = -10
		self.player.invincible = true
		self.player.animationtimer = 2
		self.player.animation = "invincible"
	end
	
	self.host = false
	self.jumping = false
	self.cooldown = 0
	
	self:back()
end

function cappy:jump()
	if self.host and self.host.speedy then
		if self.jumping then
			return
		end
		local force = -jumpforce - (math.abs(self.host.speedx) / maxrunspeed)*jumpforceadd
		self.host.speedy = math.max(-jumpforce - jumpforceadd, force)
		self.jumping = true
		
		if self.host.width < 0.5 then
			playsound(jumptinysound)
		elseif self.host.width < 1 then
			playsound(jumpsound)
		else--if self.host.width < 2 then
			playsound(jumpbigsound)
		end
	end
end

function cappy:fire()
	local host  = self.host
	if self.host and self.host.speedy then
		if host.shoot then
			host:shoot(self.num)
		end
		if host.throwhammer then
			host:throwhammer(self.dir)
			--if host.t == "hammer" and objects["hammer"][#objects["hammer"]] then
			--	objects["hammer"][#objects["hammer"]]:portaled()
			--end
		end
		if host.explosion and not host.stomped then
			host:stomp()
		end
		if host.timer then
			host.timer = lakitothrowtime
		end
	end
end

function cappy:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function cappy:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function cappy:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function cappy:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function cappy:globalcollide(a, b)
	if self.returning and (not self.host) and a == "player" then
		self:back()
	end
	--capture
	if tablecontains(enemies, a) then
		self:capture(b, a)
	elseif mariohammerkill[a] then
		self:capture(b, a)
		--[[b:shotted("right")
		if a ~= "bowser" then
			addpoints(firepoints[a], self.x, self.y)
		end]]
	elseif a == "enemy" then
		self:capture(b, a)
		--[[if b:shotted("right", false, false, true) ~= false then
			addpoints(b.firepoints or 200, self.x, self.y)
		end]]
	end
	return true
end
