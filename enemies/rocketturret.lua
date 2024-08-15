rocketturret = class:new()

function rocketturret:init(x, y, r)
	--PHYSICS STUFF
	self.x = x-1
	self.y = y-15/16
	self.width = 1
	self.height = 15/16
	self.static = true
	self.active = true
	self.category = 5
	self.dir = "left"
	
	self.mask = {true}

	--IMAGE STUFF
	self.drawable = true
	self.graphic = rocketturretimage
	self.quad = rocketturretquad[1]
	self.offsetX = 8
	self.offsetY = 1
	self.quadcenterX = 8
	self.quadcenterY = 8
	self.state = "normal"
	self.statequadi = 1
	
	self.timer = 0
	
	self.animationdirection = "right"
	
	self.r = r
	self.on = true
	self.outtable = {}

	self.targetangle = false
	self.targeted = false
	self.angle = false

	self.firing = false
end	

local function unwrap(a)
	while a < 0 do
		a = a + (math.pi*2)
	end
	while a > (math.pi*2) do
		a = a - (math.pi*2)
	end
	return a
end

local function angles(a1, a2)
	local a1 = unwrap(a1)-math.pi
	local a2 = unwrap(a2)-math.pi
	local diff = a1-a2
	if math.abs(diff) < math.pi then
		return a1 > a2, diff
	else
		return diff < 0, diff
	end
end

function rocketturret:update(dt)
	if self.on and not (#objects["glados"] > 0 and not neurotoxin) and (not self.targeted) and (not self.firing) then
		local closestplayer = 1 --find closest player
		for i = 2, players do
			local v = objects["player"][i]
			if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
				closestplayer = i
			end
		end
		local v = objects["player"][closestplayer]
		if v.x+v.width/2 > self.x+self.width/2 then
			self.animationdirection = "left"
			self.dir = "right"
		else
			self.animationdirection = "right"
			self.dir = "left"
		end
		local x1, y1, x2, y2 = (self.x+self.width/2), (self.y+self.height/2-3/16), (v.x+v.width/2), (v.y+v.height/2)
		x2, y2 = x1+15, y1+(v.y-self.y)
		if v.x+v.width/2 < self.x+self.width/2 then
			x2 = x1-15
		end
		self.targetangle = math.atan2(x1-x2, y1-y2)
	end

	--buggy
	if self.angle then
		local pos, diff = angles(self.targetangle, self.angle)
		if pos then
			self.angle = self.angle + math.abs(diff)*3*dt
		else
			self.angle = self.angle - math.abs(diff)*3*dt
		end
	elseif self.targetangle then
		self.angle = self.targetangle
	end
	
	if self.state == "ready" then
		self.statequadi = 2
	elseif self.state == "launch" then
		self.statequadi = 3
	elseif not self.on or (#objects["glados"] > 0 and not neurotoxin) then
		self.statequadi = 4
	else
		self.statequadi = 1
	end
	self.quad = rocketturretquad[self.statequadi]
	
	if (neurotoxin or #objects["glados"] == 0) and self.on and self.x > xscroll-1 and self.x < xscroll+width then
		if self.state == "normal" then
			self.timer = self.timer + dt
			if self.timer > 3 then
				self.state = "ready"
				self.timer = 0
				local closestplayer = 1 --find closest player
				for i = 2, players do
					local v = objects["player"][i]
					if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
						closestplayer = i
					end
				end
				self.targeted = objects["player"][closestplayer].y + -self.y
			end
		elseif self.state == "ready" then
			self.timer = self.timer + dt
			if self.timer > 0.8 then
				playsound(boomsound)
				self:launchrocket()
				self.state = "launch"
				self.timer = 0
				self.targeted = false
			end
		elseif self.state == "launch" then
			self.timer = self.timer + dt
			if self.timer > 0.2 and (not self.firing) then
				self.state = "normal"
				self.timer = 0
			end
		end
	end
end

function rocketturret:draw()
	if self.angle and (neurotoxin or #objects["glados"] == 0) and self.on and self.x > xscroll-1 and self.x < xscroll+width then
		local a = unwrap(self.angle)
		if a > math.pi*1.5 then --weird bugs galore
			a = a-math.pi*2
		end
		local cox, coy, side, tend, x, y = traceline(self.x+self.width/2, self.y+self.height/2-3/16, a)
		if x then
			--check if current block is a portal
			local opp = "left"
			if a > math.pi*1.25 then
			elseif a > math.pi*.75 then
				opp = "up"
			elseif a > math.pi*0.25 then
				opp = "right"
			elseif a > -math.pi*.25 then
				opp = "down"
			end
			local portalx, portaly, portalfacing, infacing = getPortal(cox, coy, opp)
		--	if portalx or portaly then
		--		love.graphics.setColor(101, 0, 0, 150)
		--	else
				love.graphics.setColor(101, 228, 255, 150)
		--	end
			love.graphics.setLineWidth(2)
			love.graphics.setLineStyle("rough")
			love.graphics.line(((self.x+self.width/2)-xscroll)*16*scale, ((self.y+self.height/2-3/16)-yscroll-8/16)*16*scale, (x-xscroll)*16*scale, (y-yscroll-8/16)*16*scale)
			if portalx then
				--let's just brute force this
				local diffx, diffy = x-(cox-1), y-(coy-1)
				local angle = a
				if portalfacing == "left" then
					portalx = portalx - 1
					portaly = portaly - 1
					if infacing == "left" then
						angle = math.pi*2-a
					elseif infacing == "right" then
						portalx = portalx - 1
					end
				elseif portalfacing == "right" then
					portalx = portalx - 1
					portaly = portaly - 1
					if infacing == "left" then
						portalx = portalx + 1
					elseif infacing == "right" then
						angle = math.pi*2-a
					end
				elseif portalfacing == "down" then
					if infacing == "left" then
						diffx = -diffy
						diffy = 0
						angle = math.pi*1.5+a
					elseif infacing == "right" then
						portalx = portalx - 1
						diffx = diffy
						diffy = 0
						angle = math.pi*.5+a
					end
				elseif portalfacing == "up" then
					portaly = portaly - 1
					portalx = portalx - 1
					if infacing == "left" then
						diffx = diffy
						diffy = 0
						angle = math.pi*.5+a
					elseif infacing == "right" then
						portalx = portalx + 1
						diffx = -diffy
						diffy = 0
						angle = math.pi*1.5+a
					end
				end
				if angle > math.pi*1.5 then --weird bugs galore
					angle = angle-math.pi*2
				end
				if infacing ~= "up" or infacing ~= "down" then
					local cox, coy, side, tend, x, y = traceline(portalx+diffx, portaly+diffy, angle)
					love.graphics.setColor(101, 228, 255, 150)
					love.graphics.line(((portalx+diffx)-xscroll)*16*scale, ((portaly+diffy)-yscroll-8/16)*16*scale, (x-xscroll)*16*scale, (y-yscroll-8/16)*16*scale)
				end
			end
		end
	end
end

function rocketturret:launchrocket()
	local obj
	if self.dir == "right" then
		obj = turretrocket:new(self.x+12/16, self.y+1/16, self.targeted, self.dir)
	else
		obj = turretrocket:new(self.x, self.y+1/16, self.targeted, self.dir)
	end
	obj.parent = self
	self.firing = true
	table.insert(objects["turretrocket"], obj)
end

function rocketturret:input(t)
	if t == "on" then
		self.on = true
	elseif t == "off" then
		self.on = false
	elseif t == "toggle" then
		self.on = not self.on
	end
end

function rocketturret:link()
	if #self.r > 2 then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[4]) == v.cox and tonumber(self.r[5]) == v.coy then
					v:addoutput(self)
					self.on = false
				end
			end
		end
	end
end

function rocketturret:leftcollide(a, b)

end

function rocketturret:rightcollide(a, b)

end

function rocketturret:passivecollide(a, b)

end

function rocketturret:globalcollide(a, b)
end

function rocketturret:floorcollide(a, b)

end

function rocketturret:ceilcollide(a, b)

end

function rocketturret:rocketready()
	self.firing = false
end

-------ROCKET TURRET BULLET THING------
turretrocket = class:new()

function turretrocket:init(x, y, gg, dir)
	--PHYSICS STUFF
	self.x = x
	self.y = y
	self.speedy = gg
	if dir == "right" then
		self.speedx = 15
	else
		self.speedx = -15
	end
	self.width = 5/16
	self.height = 5/16
	self.static = false
	self.active = true
	self.category = 4
	self.gravity = 0
	self.rotation = 0
	self.dir = dir
	
	self.mask = {true, 
				false, false, false, true, true,
				true, true, true, true, true,
				true, true, true, true, true,
				true, true, true, true, true,
				true, true, true, false, true,
				true, false, true, true, true,
				false, true}
	
	self.autodelete = true
	self.emancipatecheck = true

	--IMAGE STUFF
	self.drawable = true
	self.graphic = turretrocketimage
	self.quad = turretrocketquad[1]
	self.offsetX = 3
	self.offsetY = 5
	self.quadcenterX = 3
	self.quadcenterY = 3
	
	if self.dir == "right" then
		self.animationdirection = "left"
	else
		self.animationdirection = "right"
	end
end	

function turretrocket:update(dt)
	if self.rotation ~= 0 then
		if math.abs(math.abs(self.rotation)-math.pi/2) < 0.1 then
			self.rotation = -math.pi/2
		else
			self.rotation = 0
		end
	end
	if self.delete then
		self:callback()
		return true
	end
	if self.speedx > 0 then
		self.animationdirection = "left"
	else
		self.animationdirection = "right"
	end
end

function turretrocket:hit(a, b, gelside)
	if a == "tile" then
		local x, y = b.cox, b.coy
		if gelside and map[x][y]["gels"] and map[x][y]["gels"][gelside] == 1 then
			if gelside == "left" or gelside == "right" then
				self.speedx = -self.speedx
			else
				self.speedy = -self.speedy
			end
			return
		else
			local ti = 1
			if ismaptile(x, y) and map[x][y][1] then ti = map[x][y][1] end
			if (tilequads[ti].coinblock or (tilequads[ti].debris and blockdebrisquads[tilequads[ti].debris])) then -- hard block
				destroyblock(x, y)
			else
				hitblock(x, y, {size=2})
			end
			self.delete = true
		end
	elseif a == "glados" then
		self.delete = true
	else
		if mariohammerkill[a] then
			b:shotted("right")
			if a ~= "bowser" then
				addpoints(firepoints[a], self.x, self.y)
			end
		end
		self.delete = true
		playsound(blockhitsound)
	end
	self:callback()
	makepoof(self.x+self.width/2, self.y+self.height/2, "poof")
end

function turretrocket:emancipate()
	if not self.delete then
		table.insert(emancipateanimations, emancipateanimation:new(self.x, self.y, self.width, self.height, self.graphic, self.quad, self.speedx, self.speedy, self.rotation, self.offsetX, self.offsetY, self.quadcenterX, self.quadcenterY))
		self.delete = true
		self.drawable = false
		self:callback()
	end
end

function turretrocket:globalcollide(a, b)
	return false
end

function turretrocket:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self:hit(a, b, "right")
	return false
end

function turretrocket:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self:hit(a, b, "left")
	return false
end

function turretrocket:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self:hit(a, b, "top")
	return false
end

function turretrocket:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self:hit(a, b, "bottom")
	return false
end

function turretrocket:passivecollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self:hit(a, b)
	return false
end

function turretrocket:autodeleted()
	self:callback()
end

function turretrocket:callback()
	if self.parent and not self.calledback then
		self.parent:rocketready()
		self.calledback = true
	end
end
