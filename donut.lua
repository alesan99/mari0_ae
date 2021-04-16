donut = class:new() --it took a long time, but now you can eat donuts in Mari0. BEST MOD 10/10. "Totally Mind blowing" -Maurice

function donut:init(x, y, t, respawn, r)
	--PHYSICS STUFF
	self.x = x-1
	self.y = y-1
	self.cox = x
	self.coy = y
	self.speedy = 0
	self.speedx = 0
	self.width = 1
	self.height = 1
	self.static = true
	self.active = true
	self.category = 2
	self.gravity = 0
	self.portalable = false
	
	self.mask = {true}
	
	self.emancipatecheck = false
	self.autodelete = true

	self.PLATFORM = true
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = donutimage
	self.quadi = 2
	self.quad = starquad[spriteset][self.quadi+1]
	self.offsetX = 8
	self.offsetY = 0
	self.quadcenterX = 8
	self.quadcenterY = 8
	
	self.rotation = 0 --for portals
	
	self.direction = "left"
	self.animationtimer = 0
	self.t = t or "donut"

	if self.t == "donutlast" then
		self.last = true
		self.quadi = 0
		self.quad = starquad[spriteset][self.quadi+1]
	end
	
	self.falling = false
	
	self.falling = false
	self.fallingtimer = 0
	self.shaketimer = 0

	self.respawn = respawn or false
	if self.respawn then
		self.drawable = false
		self.active = false
		if self.t == "donutlast" then
			self.respawntimer = 4
		else
			self.respawntimer = 10
		end
		self.autodelete = false
	end

	self.dorespawn = true --should it even respawn at all?
	if r then
		self.r = r
		local v = convertr(r, {"bool"}, true)
		if v[1] ~= nil then
			self.dorespawn = v[1]
		end
	end
	self.trackplatform = true

	self.checktable = {}
	for i, v in pairs(enemies) do
		if objects[v] and underwater == false then
			table.insert(self.checktable, v)
		end
	end
	table.insert(self.checktable, "player")
end

function donut:update(dt)
	if self.respawn then
		self.respawntimer = self.respawntimer - dt
		if self.respawntimer < 0 and onscreen(self.x, self.y) then
			self:appear()
		else
			return false
		end
	end

	if self.falling then
		if self.fallingtimer > goombadeathtime then
			self.speedy = 8
			local x, y, y2 = self.cox, math.floor(self.y+17/16), math.floor(self.y+16/16)
			if (not inmap(x, y)) or (not tilequads[map[x][y][1]].collision and inmap(x, y2) and not tilequads[map[x][y2][1]].collision) then --stop players from falling through ground
				for i, v in pairs(self.checktable) do --Make mario stay on donut when donut is falling (makes mario fall through ground)
					for j, w in pairs(objects[v]) do
						if ((not w.gravity) or w.gravity ~= 0) and (not w.jumping) and inrange(w.x, self.x-w.width, self.x+self.width) then
							if inrange(w.y, self.y - w.height - 0.1, self.y - w.height + 0.1) then
								local x1, y1 = math.ceil(w.x+0.001), math.ceil(self.y+self.height-.5)
								local x2, y2 = math.ceil(w.x+w.width-0.001), math.ceil(self.y+self.height-.5)
								local maxy, col = math.huge, false
								if (inmap(x1, y1) and tilequads[map[x1][y1][1]]:getproperty("collision", x1, y1) and not tilequads[map[x1][y1][1]]:getproperty("invisible", x1, y1)) then
									maxy = y1-1-w.height
								elseif (inmap(x2, y2) and tilequads[map[x2][y2][1]]:getproperty("collision", x2, y2) and not tilequads[map[x2][y2][1]]:getproperty("invisible", x2, y2)) then
									maxy = y2-1-w.height
								end
								if #checkrect(w.x, self.y - (12/16) + self.speedy*dt, w.width, 12/16, {"donut"}, nil, "donut") >= 3 then
									maxy = y2-1-w.height
								end
								w.y = math.min(maxy, self.y - w.height + self.speedy*dt)
							end
						end
					end
				end
			end
			self.offsetX = 8
			self.trackable = false
		elseif self.last then
			local on = false --on top
			for j, w in pairs(objects["player"]) do
				if (not w.jumping and inrange(w.x, self.x-w.width, self.x+self.width)) then
					on = true
					break
				end
			end
			
			if on then
				self.fallingtimer = self.fallingtimer + dt
				self.quad = starquad[spriteset][self.quadi+2]
				self.shaketimer = (self.shaketimer + 8*dt)%1
				self.offsetX = 7+math.floor(math.abs(self.shaketimer-.5)*4+.5)
			else
				self.falling = false
				self.fallingtimer = 0
				self.quad = starquad[spriteset][self.quadi+1]
				self.offsetX = 8
				self.shaketimer = 0
			end
		else
			self.fallingtimer = self.fallingtimer + dt
			self.quad = starquad[spriteset][self.quadi+2]
			self.shaketimer = (self.shaketimer + 8*dt)%1
			self.offsetX = 7+math.floor(math.abs(self.shaketimer-.5)*4+.5)
		end
	
		return false
	end
end

function donut:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	return false
end

function donut:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	return false
end

function donut:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "player" then
		if b.size ~= -1 then
			self.falling = true
			self.static = false
		end
	elseif a == "thwomp" or a == "skewer" then
		self.falling = true
		self.last = false
		self.static = false
	end
	return true
end

function donut:globalcollide(a, b)
	
end

function donut:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	return false
end

function donut:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end

function donut:autodeleted()
	--respawn
	if not self.dorespawn then
		return
	end
	if self.t == "donutlast" or self.t == "donut" then
		local obj = donut:new(self.cox, self.coy, self.t, true)
		if self.trackdonut then
			obj.trackable = true
			obj.trackspeed = 0
			local succ = trackobject(self.cox, self.coy, obj, "donut")
		end
		table.insert(objects["donut"], obj)
	end
end

function donut:appear()
	self.drawable = true
	self.active = true
	self.respawn = false
	self.autodelete = true
	self.trackspeed = nil

	makepoof(self.x+self.width/2, self.y+self.height/2, "makerpoof")
end

function donut:dotrack(track)
	if track then
		self.trackdonut = true
	end
end