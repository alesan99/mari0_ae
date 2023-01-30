amp = class:new()

function amp:init(x, y, r)
	--PHYSICS STUFF
	self.cox = x
	self.coy = y
	self.x = x-1
	self.y = y-1
	self.width = 1
	self.height = 1

	self.path = 0
	self.t = "fuzzy"

	if type(r) == "string" then --multiple properties
		local v = convertr(r, {"num", "string"}, true)
		self.path = v[1]
		self.t = v[2]
	else
		self.path = r or 0
		self.t = "amp"
	end

	if self.path == 1 then
		self.speedx = -5
		self.speedy = 0
	elseif self.path == 2 then
		self.speedx = 0
		self.speedy = 5
	elseif self.path == 3 then
		self.speedx = -5
		self.speedy = 0
	elseif self.path == 4 then
		self.speedx = -5
		self.speedy = 5
	else
		self.speedx = 0
		self.speedy = 0
	end
	
	self.static = false
	self.active = true
	self.category = 11
	self.gravity = 0
	self.portalable = false
	
	self.mask = {true}
	
	self.autodelete = true
	
	--IMAGE STUFF
	self.drawable = true
	self.rotation = 0
	
	self.animationtimer = 0
	self.movetimer = 0

	if self.t == "fuzzy" then
		--this one goes out to ceave gaming
		self.graphic = fuzzyimg
		self.quad = goombaquad[spriteset][1]
		self.offsetX = 8
		self.offsetY = 0
		self.quadcenterX = 8
		self.quadcenterY = 8
		self.quadi = 1

		self.category = 4
		self.mask = {	true, 
			false, false, false, false, true,
			false, true, false, true, false,
			false, false, true, false, false,
			true, true, false, false, false,
			false, true, true, false, false,
			true, false, true, true, true,
			false, true}

		self.shot = false
		self.freezable = true
		self.stompbounce = true
		self.portalable = true

		self.trackgravity = 28
		self.animationtime = 0.1
		self.shotable = true
		self.stompbouncesound = true
		self.shoestompbounce = true
	elseif self.t == "amp" then
		--some bratty kid suggested this way back
		--which im hiding it now
		self.graphic = ampimage
		self.quad = ampquad[spriteset][1]
		self.offsetX = 0
		self.offsetY = 8
		self.quadcenterX = 8
		self.quadcenterY = 8
		self.quadi = 1

		self.freezable = true
		self.dontfallafterfreeze = true

		self.animationtime = 0.1
		self.shotted = nil
		self.resistsyoshitounge = true
		self.light = 3
	end
	self.resistsshoe = true
	self.clearpipespeed = 0
	self.noclearpiperotation = true
	self.noclearpipesound = true

	self.falling = false
	self.timer = 0

	self.trackable = true
	self.track = false
end

function amp:update(dt)
	--shot
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
	elseif self.frozen then
		return false
	end

	--animation
	self.animationtimer = self.animationtimer + dt
	while self.animationtimer > self.animationtime do
		self.quadi = self.quadi + 1
		if self.t == "amp" and self.quadi >= 5 then
			self.quadi = 1
		elseif self.t == "fuzzy" and self.quadi >= 3 then
			self.quadi = 1
		end
		if self.t == "amp" then
			self.quad = ampquad[spriteset][self.quadi]
		elseif self.t == "fuzzy" then
			self.quad = goombaquad[spriteset][self.quadi]
		end
		self.animationtimer = self.animationtimer - 0.1
	end

	if self.track then
		--dont move if tracked
		return false
	end
	
	if self.path ~= 0 then
		self.movetimer = self.movetimer + dt
	end
	if self.path == 1 then
		if self.movetimer > 1.5 then
			self.speedx = -self.speedx
			self.movetimer = 0
		end
	elseif self.path == 2 then
		if self.movetimer > 1.5 then
			self.speedy = -self.speedy
			self.movetimer = 0
		end
	elseif self.path == 3 then
		if self.movetimer > 1 then
			if self.speedx == -5 and self.speedy == 0 then
				self.speedx = 0
				self.speedy = 5
			elseif self.speedx == 0 and self.speedy == 5 then
				self.speedx = 5
				self.speedy = 0
			elseif self.speedx == 5 and self.speedy == 0 then
				self.speedx = 0
				self.speedy = -5
			elseif self.speedx == 0 and self.speedy == -5 then
				self.speedx = -5
				self.speedy = 0
			end
			self.movetimer = 0
		end
	elseif self.path == 4 then
		if self.movetimer > 0.6 then
			if self.speedx == -5 and self.speedy == 5 then
				self.speedx = 5
				self.speedy = 5
			elseif self.speedx == 5 and self.speedy == 5 then
				self.speedx = 5
				self.speedy = -5
			elseif self.speedx == 5 and self.speedy == -5 then
				self.speedx = -5
				self.speedy = -5
			elseif self.speedx == -5 and self.speedy == -5 then
				self.speedx = -5
				self.speedy = 5
			end
			self.movetimer = 0
		end
	end
end

function amp:globalcollide(a, b)
	if a == "tracksegment" then
		return true
	end
	return false
end

function amp:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return true
	end
	return false
end

function amp:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return true
	end
	return false
end

function amp:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return true
	end
	return false
end

function amp:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return true
	end
	return false
end

function amp:passivecollide(a, b)
	if self:globalcollide(a, b) then
		return true
	end
	return false
end

function amp:shotted(dir)
	if not self.shotable then
		return false
	end
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
end

function amp:freeze()
	self.frozen = true
	self.static = true
end

function amp:dotrack(track, fast)
	self.track = true
	if self.t == "fuzzy" then
		if fast then
			self.trackspeed = 8
		else
			self.trackspeed = 4
		end
	end
end

function amp:doclearpipe()
	self.activestatic = true
	self.killsinsideclearpipes = true
end