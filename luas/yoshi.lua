yoshi = class:new()

function yoshi:init(x, y, r)
	--PHYSICS STUFF
	self.x = x-4/16
	self.y = y-23/16
	self.speedy = 0
	self.speedx = 0
	self.width = 20/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.rideable = true
	self.player = nil
	
	self.category = 6
	self.mask = {	true,
					false, false, true, true, true,
					false, true, false, true, true,
					false, true, true, false, true,
					true, true, false, true, true,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	
	self.autodelete = false
	
	--IMAGE STUFF
	self.drawable = false
	self.color = r or 1
	self.quad = yoshiquad[self.color][1]
	self.offsetX = 11
	self.offsetY = 7
	self.quadcenterX = 15
	self.quadcenterY = 17
	self.animationdirection = "right"
	self.runanimationprogress = 1
	
	self.rotation = 0 --for portals
	self.falling = false
	self.jumping = false
	self.onground = false
	self.tounge = false
	self.toungewidth = 0
	self.toungemaxwidth = 2.5
	self.toungeheight = 12/16
	self.toungespeed = yoshitoungespeed
	self.toungeenemy = false
	
	self.state = "start"
	
	self.speedy = -yoshijumpforce
	
	self.drawcollision = true

	self.pipespawnmax = 2
end

function yoshi:update(dt)
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
	
	if self.speedx ~= 0 then
		if not self.jumping then
			self.state = "walking"
		end
		if self.speedx > 0 then
			self.animationdirection = "right"
		else
			self.animationdirection = "left"
		end
	elseif self.speedx == 0 and self.speedy == 0 then
		self.state = "idle"
	end
	
	if edgewrapping then --wrap around screen
		local minx, maxx = -self.width, mapwidth
		if self.x < minx then
			self.x = maxx
		elseif self.x > maxx then
			self.x = minx
		end
	end
	
	if self.tounge then
		self.toungewidth = math.max(0, math.min(self.toungemaxwidth, self.toungewidth + self.toungespeed*dt))
		
		local w, h = self.toungewidth, self.toungeheight
		local x, y = self.x+(self.width/2)+(8/16), self.y
		if self.jumping or self.falling then
			y = self.y-6/16
			if self.animationdirection == "right" then
				x = self.x+(self.width/2)+(3/16)
			else
				x = (self.x+(self.width/2)-(3/16))-w
			end
		else
			if self.animationdirection == "left" then
				x = (self.x+(self.width/2)-(8/16))-w
			end
		end
		if self.toungeenemy then

		else
			local dobreak = false
			for j, obj in pairs(yoshitoungekill) do
				for i, v in pairs(objects[obj]) do
					if (not v.shot) and v.width and aabb(x, y, w, h, v.x, v.y, v.width, v.height) then
						addpoints(firepoints[obj], v.x, v.y)
						v:shotted(self.animationdirection)
						if v.output then
							v:output()
						end
						v.instantdelete = true
						self.toungeenemy = {graphic=v.graphic, quad=v.quad}
						local dobreak = true
						break
					end
				end
				
				if dobreak then
					break
				end
			end
		end
		
		if self.toungewidth == self.toungemaxwidth then
			self.toungespeed = -yoshitoungespeed
		elseif self.toungewidth == 0 then
			self.toungespeed = yoshitoungespeed
			self.tounge = false
		end
	end
	
	if self.tounge then
		if self.jumping or self.falling then
			self.quad = yoshiquad[self.color][1]
		else
			self.quad = yoshiquad[self.color][7]
		end
	elseif self.state == "idle" and not self.jumping then
		self.quad = yoshiquad[self.color][2]
	elseif self.jumping or self.falling then
		self.quad = yoshiquad[self.color][6]
	elseif self.state == "walking" and not self.jumping then
		self.runanimationprogress = self.runanimationprogress + (math.abs(self.speedx)+4)/5*dt*runanimationspeed
		while self.runanimationprogress >= 4 do
			self.runanimationprogress = self.runanimationprogress - 3
		end
		self.quad = yoshiquad[self.color][math.floor(self.runanimationprogress)+2]
	elseif self.state == "ducking" then
		self.quad = yoshiquad[self.color][8]
	end
end

function yoshi:draw()
	if not self.active then
		return
	end
	
	if self.animationdirection == "left" then
		dirscale = -scale
	else
		dirscale = scale
	end
	
	local horscale = scale
	if self.shot or self.flipped then
		horscale = -scale
	end
	
	love.graphics.draw(yoshiimage, self.quad, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), self.rotation, dirscale, horscale, self.quadcenterX, self.quadcenterY)
end

function yoshi:ride(player, panic)
	if player then
		self.player = player
		self.player.yoshiquad = yoshiquad[self.color][1]
		self.static = true
		self.active = false
	else
		self.x = self.player.x+self.player.width/2-self.width/2
		self.y = self.player.y+self.player.height-self.height
		self.animationdirection = self.player.animationdirection
		
		self.speedy = 0
		if panic then
			if self.player.speedx < 0 then
				self.speedx = -yoshipanicspeed
			else
				self.speedx = yoshipanicspeed
			end
		else
			self.speedx = 0

			--turn into mario's size if clipping through wall
			if self.player.width < self.width and checkintile(self.x, self.y, self.width, self.height, {}, self, "ignoreplatforms") then
				self.x = self.x+self.width/2
				self.width = self.player.width
				self.x = self.x-self.width/2
			end
		end
		
		self.player = false
		self.static = false
		self.active = true
	end
end

function yoshi:globalcollide(a, b)
	if a == "fireball" or a == "player" or a == "yoshi" then
		return true
	end
end

function yoshi:passivecollide(a, b)
	return false
end

function yoshi:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.speedx = -self.speedx
	return false
end

function yoshi:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.speedx = -self.speedx
	return false
end

function yoshi:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.state = "idle"
	self.onground = true
	self.jumping = false
	self.falling = false
end

function yoshi:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

--EGG
yoshiegg = class:new()

function yoshiegg:init(x, y, r)
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
	self.mask = {true, false, true}
	self.destroy = false
	self.autodelete = true
	self.gravity = 40
	self.crack = false
	self.color = r or 1
	
	--IMAGE STUFF
	self.drawable = false
	self.graphic = yoshieggimg
	self.quad = yoshieggquad[self.color][1]
	self.offsetX = 9
	self.offsetY = 2
	self.quadcenterX = 9
	self.quadcenterY = 8
	
	self.rotation = 0 --for portals
	self.uptimer = 0
	self.timer = 0
	self.timer2 = 0
	self.breaktimer = 0
	
	self.falling = false
end

function yoshiegg:update(dt)	
	if self.uptimer < mushroomtime then
		self.uptimer = self.uptimer + dt
		self.y = self.y - dt*(1/mushroomtime)
	end
	
	if self.uptimer > mushroomtime then
		self.y = self.starty-27/16
		self.active = true
		self.drawable = true
		self.timer2 = self.timer2 + dt
		if self.timer2 > 0.2 then
			self.crack = true
		end
	end
	
	if self.crack then
		self.breaktimer = self.breaktimer + dt
		if self.breaktimer > yoshieggbreaktime then
			table.insert(objects["yoshi"], yoshi:new(self.x, self.y, self.color))
			self.destroy = true
		end
		self.quad = yoshieggquad[self.color][2]
	end
	
	if self.destroy then
		return true
	else
		return false
	end
end

function yoshiegg:draw()
	if self.uptimer < mushroomtime and not self.destroy then
		--Draw it coming out of the block.
		love.graphics.draw(self.graphic, self.quad, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), 0, scale, scale, self.quadcenterX, self.quadcenterY)
	end
end

function yoshiegg:leftcollide(a, b)
	return false
end

function yoshiegg:rightcollide(a, b)
	return false
end

function yoshiegg:floorcollide(a, b)
	
end

function yoshiegg:ceilcollide(a, b)

end