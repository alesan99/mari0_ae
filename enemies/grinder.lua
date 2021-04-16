grinder = class:new()

local bounceforcex = 8
local bounceforcey = 11
local bumperdamping = 0.3
local grinderforce = 5

function grinder:init(x, y, t)
	--PHYSICS STUFF
	self.cox = x
	self.coy = y
	self.radius = 1.5
	self.width = self.radius*2
	self.height = self.radius*2
	self.x = x-.5-self.height/2
	self.y = y-.5-self.width/2

	self.speedy = 0
	self.speedx = 0
	self.static = true
	self.active = true

	self.category = 4
	self.gravity = 0
	
	self.autodelete = false
	self.t = t or "grinder"
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = grinderimg
	self.quad = grinderquad[spriteset][1]
	self.offsetX = 24
	self.offsetY = -16
	self.quadcenterX = 24
	self.quadcenterY = 24

	self.category = 2
	self.mask = {	true, 
		true, false, true, true, true,
		true, true, true, true, true,
		true, true, true, true, true,
		true, true, true, true, true,
		true, true, true, true, true,
		true, true, true, true, true,
		true, false}
	
	self.rotation = 0
	self.rtimer = 0

	if self.t == "grinder" then
		self.kills = true
	elseif self.t == "bumper" then
		self.quad = grinderquad[spriteset][2]

		self.blinktimer = false
		self.blinktime = 8
	end
	
	self.animationdirection = "right"
end

function grinder:update(dt)
	if self.t == "grinder" then --32
		--SPEEEEEN
		self.rtimer = self.rtimer + dt
		while self.rtimer > 0.074 do
			self.rotation = -((math.abs(self.rotation) + (math.pi/16))%(math.pi*2))
			self.rtimer = self.rtimer - 0.074
		end
	elseif self.t == "bumper" then
		if self.blinktimer then
			--wiggle and blink
			self.animationscalex = 1+((math.sin((self.blinktimer/2)*math.pi)*(1-(self.blinktimer/self.blinktime))))*0.2
			self.animationscaley = self.animationscalex
			--self.animationscaley = 1+((math.sin((self.blinktimer/2-1)*math.pi)*(1-(self.blinktimer/self.blinktime))))*0.3
			self.blinktimer = self.blinktimer + 20*dt
			if self.blinktimer > 2 then
				if self.blinktimer%3 < 2.5 then
					self.quad = grinderquad[spriteset][3]
				else
					self.quad = grinderquad[spriteset][2]
				end
			end
			if self.blinktimer > self.blinktime then
				self.quad = grinderquad[spriteset][2]
				self.blinktimer = false
			end
		end
	end
	return false
end

function grinder:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function grinder:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function grinder:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function grinder:globalcollide(a, b)
end

function grinder:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function grinder:passivecollide(a, b)
	if a == "player" then
		if self.blinktimer and self.blinktimer < 2.5 then
			return false
		end
		local x, y = b.x+b.width/2, b.y+b.height/2
		local cx, cy = self.x+self.width/2, self.y+self.height/2
		local top = false
		local dx, dy
		if y < cy then --top half
			dy = b.y+b.height
			top = true
		else --bottom half
			dy = b.y
		end
		if x < cx then --left
			dx = b.x+b.width
		else --right
			dx = b.x
		end
		local dist = (dx-cx)*(dx-cx)+(dy-cy)*(dy-cy)
		if (dist <= self.radius*self.radius) or ((x-cx)*(x-cx)+(y-cy)*(y-cy) < self.radius*self.radius) then --hit!
			if a == "player" then
				if self.t == "grinder" then
					local strongshoe, stronghelmet = (b.shoe and b.shoe ~= "cloud" and top), (b.helmet and (b.helmet == "beetle" or self.helmet == "spikey") and not top)
					if (b.invincible or b.starred) then
					elseif strongshoe or stronghelmet then
						--bounce on grinder
						local angle = -math.atan2(x-cx, y-cy)+math.pi/2
						local grav = b.gravity or yacceleration
						if stronghelmet and not top then
							b.speedx = (math.cos(angle)*bounceforcex) + b.speedx*bumperdamping
							b.speedy = (math.sin(angle)*bounceforcey) - math.sqrt(2*grav*bounceheight) + 1.8
						else
							b.speedx = math.cos(angle)*grinderforce
							b.speedy = (math.sin(angle)*grinderforce)-math.sqrt(2*grav*bounceheight)
						end
						b.jumping = false
						b.falling = true
						b.animationstate = "jumping"
						b:setquad()
						if strongshoe and top and jumpkey(b.playernumber) then
							b.jumping = true
						end
						if strongshoe then
							playsound(stompsound)
						else
							playsound(helmethitsound)
						end
					else			
						b:die("Enemy (floorcollide)")
					end
				elseif self.t == "bumper" then
					--bounce
					local angle = -math.atan2(x-cx, y-cy)+math.pi/2
					local grav = b.gravity or yacceleration
					b.speedx = (math.cos(angle)*bounceforcex) + b.speedx*bumperdamping
					b.speedy = (math.sin(angle)*bounceforcey) - math.sqrt(2*grav*bounceheight) + 1.8

					b.jumping = false
					b.falling = true
					b.animationstate = "jumping"
					b:setquad()
					if top and jumpkey(b.playernumber) then
						b.jumping = true
						playsound(bumperjumpsound)
						--b.speedy = b.speedy + 3
					else
						playsound(bumperhitsound)
					end
					self.blinktimer = 0
				end
			end
		end
	end
	return false
end

function grinder:dotrack(track)
	self.trackgrinder = true
end