pokey = class:new()

function pokey:init(x, y, t, l, c, col)
	--PHYSICS STUFF
	self.x = x-6/16
	self.y = y-11/16
	self.speedy = 0
	self.speedx = 0
	self.width = 12/16
	self.height = 14/16
	self.static = false
	self.active = true
	self.category = 4
	self.t = t or "pokey"
	self.length = l or 3
	if l and l == "default" then
		self.length = 3
	end
	self.bodypart = c or false --child?
	self.col = col or false --collision? (only bottom i think)
	if self.length == 1 then
		self.col = true
	end
	
	if not c then --if not child
		self.child = {}
		for i = 1, self.length-1 do
			self.y = self.y - self.height
			local col = (i == 1)
			self.child[i] = pokey:new(self.x+6/16, self.y+self.height+11/16, self.t, nil, true, col)
			table.insert(objects["pokey"], self.child[i])
			--if col then
				self.child[i].head = self
				self.child[i].i = i
			--end
		end
		self.wiggletimer = 0 --0-math.pi*2
	end
	
	if self.col then
		self.mask = {	true, 
						false, false, false, false, true,
						false, true, false, true, false,
						false, false, true, false, false,
						true, true, false, false, false,
						false, true, true, false, false,
						true, false, true, true, true,
						false, true}
		self.portalable = true
	else
		self.mask = {	true, 
						true, false, false, false, true,
						false, true, false, true, false,
						false, false, true, false, false,
						true, true, false, false, false,
						false, true, true, false, false,
						true, false, true, true, true,
						false, true}
		self.portalable = false
	end
	
	self.emancipatecheck = true
	self.autodelete = true
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = pokeyimg
	if self.bodypart then
		if self.t == "snowpokey" then
			self.quad = pokeyquad[2][2]
		else
			self.quad = pokeyquad[1][2]
		end
	else
		if self.t == "snowpokey" then
			self.quad = pokeyquad[2][1]
		else
			self.quad = pokeyquad[1][1]
		end
	end
	self.offsetX = 6
	self.offsetY = 2
	self.quadcenterX = 8
	self.quadcenterY = 9
	
	self.rotation = 0 --for portals
	
	self.direction = "left"
	self.animationtimer = 0
	self.animationdirection = "right"
	
	self.falling = false
	
	self.shot = false
	self.trackable = false
	self.dontenterclearpipes = true
end

function pokey:update(dt)
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

	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
		
	else
		--check if nothing below
		if self.col then
			local x = math.floor(self.x + self.width/2+1)
			local y = math.floor(self.y + self.height+1.5)
			if inmap(x, y) and (not checkfortileincoord(x, y)) and ((inmap(x+.5, y) and checkfortileincoord(math.ceil(x+.5), y)) or (inmap(x-.5, y) and checkfortileincoord(math.floor(x-.5), y))) then
				if self.speedx < 0 then
					self.animationdirection = "left"
					self.x = x-self.width/2
				else
					self.animationdirection = "right"
					self.x = x-1-self.width/2
				end
				self.speedx = -self.speedx
			end
		end

		if self.bodypart then
			--update wiggle
			if self.head then
				self.offsetX = 6+math.sin(self.head.wiggletimer+(math.floor((self.y-self.head.y)/self.height)*2))
			end
		else
			--update wiggle
			self.wiggletimer = (self.wiggletimer + 6*dt)%(math.pi*2)
			self.offsetX = 6+math.sin(self.wiggletimer)
		end
		
		--update dominant body part if previous one is killed
		--and update position
		if (not self.bodypart) then --not child, is head
			if not self.col then --has body
				local survivor = false
				for i = 1, self.length-1 do
					if self.child[i] and not self.child[i].shot then
						survivor = i
						break
					end
				end
				if survivor then
					--update main body
					self.child[survivor].col = true
					self.child[survivor].mask = {	true, 
							false, false, false, false, true,
							false, true, false, true, false,
							false, false, true, false, false,
							true, true, false, false, false,
							false, true, true, false, false,
							true, false, true, true, true}
					self.child[survivor].portalable = true
					self.x = self.child[survivor].x
					self.speedx = self.child[survivor].speedx
					local hi = -1
					for i = 1, self.length-1 do
						if self.child[i] and not self.child[i].shot then
							hi = hi + 1
							self.child[i].x = self.child[survivor].x
							self.child[i].speedx = self.child[survivor].speedx
							self.child[i].y = math.min(self.child[i].y, self.child[survivor].y-(self.height*hi))
						end
					end
					hi = hi + 1
					self.y = math.min(self.y, self.child[survivor].y-(self.height*(hi)))
				else
					--turn into main body
					self.col = true
					self.mask = {	true, 
							false, false, false, false, true,
							false, true, false, true, false,
							false, false, true, false, false,
							true, true, false, false, false,
							false, true, true, false, false,
							true, false, true, true, true,
							false, true}
					self.portalable = true
				end
			end
		end
		
		if (not self.bodypart) and (not self.shot) and (not self.col) then
			--kill self if no body parts left
			local survivor = false
			for i = 1, self.length-1 do
				if self.child[i] and not self.child[i].shot then
					survivor = i
					break
				end
			end
			if not survivor or self.child[survivor].y > mapheight then
				self:shotted()
			end
		end

		if self.speedx < 0 then
			self.animationdirection = "right"
		else
			self.animationdirection = "left"
		end
		if self.speedx > 0 then
			if self.speedx > goombaspeed then
				self.speedx = self.speedx - friction*dt*2
				if self.speedx < goombaspeed then
					self.speedx = goombaspeed
				end
			elseif self.speedx < goombaspeed then
				self.speedx = self.speedx + friction*dt*2
				if self.speedx > goombaspeed then
					self.speedx = goombaspeed
				end
			end
		else
			if self.speedx < -goombaspeed then
				self.speedx = self.speedx + friction*dt*2
				if self.speedx > -goombaspeed then
					self.speedx = -goombaspeed
				end
			elseif self.speedx > -goombaspeed then
				self.speedx = self.speedx - friction*dt*2
				if self.speedx < -goombaspeed then
					self.speedx = -goombaspeed
				end
			end
		end
		
		return false
	end
end

function pokey:stomp()
	self.jump = false
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
	
	if not self.bodypart then
		for j, w in pairs(self.child) do
			if not w.shot then
				w:shotted()
			end
		end
		local snowball = spikeball:new(self.x+self.width/2, self.y+self.height, "snow", "left", true)
		if self.supersized then
			supersizeentity(snowball)
		end
		table.insert(objects["spikeball"], snowball)
	end
end

function pokey:shotted(dir) --fireball, star, turtle
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
	
	if not self.bodypart then
		for j, w in pairs(self.child) do
			if not w.shot then
				w:shotted()
			end
		end
	end
end

function pokey:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if b.PLATFORM then
		return false
	end
	
	self.speedx = goombaspeed
	
	return false
end

function pokey:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if b.PLATFORM then
		return false
	end
	
	self.speedx = -goombaspeed
	
	return false
end

function pokey:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "pokey" and not b.col then
		return false
	end
end

function pokey:globalcollide(a, b)
	if a == "bulletbill" or a == "bigbill" then
		if b.killstuff ~= false then
			return true
		end
	end
	
	if a == "fireball" or a == "player" then
		return true
	end
end

function pokey:startfall()

end

function pokey:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function pokey:passivecollide(a, b)
	if b.PLATFORM then
		return false
	end
	if a == "pokey" and b.head == self.head then
		return true
	end
	self:leftcollide(a, b)
	return false
end

function pokey:emancipate(a)
	self:shotted()
end

function pokey:laser()
	self:shotted()
end

function pokey:portaled(a)
	if self.col then
		local y = 0
		if self.head and self.head.length then
			for i = 1, self.head.length do
				if self.head.child[i] and not self.head.child[i].col then
					y = y + 1
					self.head.child[i].y = self.y - self.height*y
					self.head.child[i].x = self.x
				end
			end
			y = y + 1
			self.head.y = self.y - self.height*y
		end
	end
end

function pokey:dosupersize()
	if self.child and self.length then
		for i = 1, self.length-1 do
			if self.child[i] then
				supersizeentity(self.child[i])
			end
		end
	end
end