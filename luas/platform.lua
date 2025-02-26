platform = class:new()

function platform:init(x, y, dir, size, r)
	--PHYSICS STUFF
	self.size = size or 2
	if dir == "justright" then
		self.size = size or 3
	end
	if type(self.size) == "string" then
		self.size = tonumber(self.size) or 2
	end

	--variables
	self.cox = x
	self.coy = y
	self.legacy = true
	if dir == "up" then
		self.time = platformvertime
		self.distancex = 0
		self.distancey = platformverdistance
	elseif dir == "right" or dir == "default" then
		self.time = platformhortime
		self.distancex = -platformhordistance
		self.distancey = 0
	end
	if (dir == "up" or dir == "right" or dir == "default") and type(size) == "string" then
		local v = convertr(size, {"num","num","num","num"}, false)
		self.size = v[1]
		self.distancex = v[2]
		self.distancey = v[3]
		self.time = v[4]

		if math.abs(self.distancex) < 0.1 then
			self.distancex = 0
		end
		if math.abs(self.distancey) < 0.1 then
			self.distancey = 0
		end
	end

	if (self.size ~= math.floor(self.size)) or breakoutmode then--or dir == "default" then
		self.x = x-self.size/2-0.5
	else
		self.x = x-1
	end	
	self.y = y-15/16
	self.startx = self.x
	self.starty = self.y-8/16--15/16
	if dir == "right" then
		self.starty = self.y-15/16
	elseif dir == "default" then
		self.starty = self.y
	end
	self.speedx = 0 --!
	self.speedy = 0
	self.width = self.size
	self.height = 8/16
	self.static = true
	self.active = true
	self.category = 15
	self.mask = {true}
	self.gravity = 0
	
	--IMAGE STUFF
	self.drawable = false
	
	self.rotation = 0
	
	self.dir = dir --(Right, up, Justup, Justdown, justright(bonus stage), fall)
	self.timer = 0
	
	if self.dir == "justup" then
		self.speedy = -platformjustspeed
	elseif self.dir == "justdown" then
		self.speedy = platformjustspeed
	elseif self.dir == "default" then
		self.dir = "right"
	end

	--LINKING
	self.r = r
	self.on = true
	if self.r then
		self.on = false
		self.trackspeed = 0
		self.linked = true
		self.x = self.startx
		self.y = self.starty
	end

	self.checktable = {"player", "box", "smallspring", "enemy"}
	for i, v in pairs(enemies) do
		if objects[v] and underwater == false then
			table.insert(self.checktable, v)
		end
	end

	--jump through bottom when mario maker physics are enabled
	if mariomakerphysics then
		self.PLATFORM = true
	end

	self.track = false
	self.trackanimtimer = 1
	self.trackplatform = true --carry when on track
	self.trackable = true
	if self.dir == "justright" then
		self.platformtracki = 4
		self.trackspeed = 0 --don't move until stepped on
	else
		if self.dir == "fall" then
			self.trackspeed = 0
		end
		self.platformtracki = 1
		self.trackoffsety = -1/16
	end
	self.trackgraboncenterofobject = true
	self.oldx, self.oldy = self.x, self.y
end

function platform:func(i) -- 0-1 in please
	return (-math.cos(i*math.pi*2)+1)/2
end

function platform:update(dt)
	if (self.dir == "right" or self.dir == "up") and self.on and (not self.track) then
		self.timer = self.timer + dt
		while self.timer > self.time do
			self.timer = self.timer - self.time
		end

		if self.distancex ~= 0 then
			local newx = self:func(self.timer/self.time)*self.distancex + self.startx
			self.speedx = (newx-self.x)/dt
		end

		if self.distancey ~= 0 then
			local newy = self:func(self.timer/self.time)*self.distancey + self.starty
			self.speedy = (newy-self.y)/dt
		end
	end
	
	if self.track then -- on track (or was)
		if not self.tracked then
			if self.size > 2 then
			end
			local xdiff = self.x-self.oldx
			local ydiff = self.y-self.oldy
			local condition = false
			if ydiff < 0 then
				condition = "ignoreplatforms"
			end
			for i, v in pairs(self.checktable) do
				for j, w in pairs(objects[v]) do
					if (not w.ignoreplatform) and w.active then
						if inrange(w.x, self.x-w.width, self.x+self.width) then --vertical carry
							if ((w.y == self.y - w.height) or 
								(w.y+w.height >= self.y-0.4 and w.y+w.height < self.y+0.4))
								and (not w.jumping) and not (self.speedy > 0 and w.speedy < 0) then --and w.speedy >= self.speedy
								if #checkrect(w.x+xdiff, self.y-w.height, w.width, w.height, {"exclude", w}, true, condition) == 0 then
									w.oldxplatform = w.x
									w.x = w.x + xdiff
									w.y = self.y-w.height
									w.falling = false
									w.speedy = self.speedy
								end
							end
						end
					end
				end
			end
		end
		if self.on then
			self.trackanimtimer = (((self.trackanimtimer + 4*dt)-1)%2)+1
		else
			self.trackanimtimer = 1
		end
		self.oldx, self.oldy = self.x, self.y
	elseif self.dir == "right" or self.dir == "justright" or self.dir == "up" or self.dir == "justup" or self.dir == "justdown" then
		self.x = self.x + self.speedx*dt
		
		for i, v in pairs(self.checktable) do
			for j, w in pairs(objects[v]) do
				if (not w.ignoreplatform) and w.active then
					if self.speedx ~= 0 then
						if inrange(w.x, self.x-w.width, self.x+self.width) then
							if w.y == self.y - w.height then
								if ((not w.playernumber) and not checkintile(w.x+self.speedx*dt, w.y, w.width, w.height, {}, w, "ignoreplatforms")) or
									(w.playernumber and #checkrect(w.x+self.speedx*dt, w.y, w.width, w.height, {"exclude", w}, true) == 0) then
									w.oldxplatform = w.x
									w.x = w.x + self.speedx*dt
									--make sure red koopas dont fall off
									if v == "drybones" or (v == "koopa" and w.t == "red" and not w.small) or (v == "goomba" and (w.t == "goombrat" or w.t == "spiketop" or w.t == "wiggler")) or (w.turnaroundoncliff and not w.small) then
										if not inrange(w.x+w.width/2+w.speedx*dt, self.x, self.x+self.width) then
											if w.speedx < 0 then
												w.animationdirection = "left"
											else
												w.animationdirection = "right"
											end
											w.speedx = -w.speedx
										end
									end
								end
							end
						end
					end
					if self.speedy ~= 0 then
						if not w.jumping and inrange(w.x, self.x-w.width, self.x+self.width) and w.speedy and w.height then
							local clip_past_platform = (w.y+w.height-w.speedy*dt < self.y and w.y+w.height > self.y)
							if inrange(w.y, self.y - w.height - 0.1, self.y - w.height + 0.1) or clip_past_platform then
								local x1, y1 = math.ceil(w.x+0.01), math.ceil(self.y+self.height)
								local x2, y2 = math.ceil(w.x+w.width), math.ceil(self.y+self.height)
								local maxy, col = math.huge, false
								if (inmap(x1, y1) and checkfortileincoord(x1, y1)) then
									maxy = y1-1-w.height
								elseif (inmap(x2, y2) and checkfortileincoord(x2, y2)) then
									maxy = y2-1-w.height
								end
								w.y = math.min(maxy, self.y - w.height + self.speedy*dt)
								if clip_past_platform then
									w.speedy = 0
								end
							end
						end
					end
				end
			end
		end
		self.y = self.y + self.speedy*dt
	elseif self.dir == "fall" and breakoutmode then
		local speed = 15
		if leftkey(1) then self.speedx = -speed
		elseif rightkey(1) then self.speedx = speed
		else self.speedx = 0 end
		self.gravity = 0; self.static = false; self.PLATFORM = false; self.mask[2] = false
		self.trackanimtimer = (((self.trackanimtimer + 4*dt)-1)%2)+1
	elseif self.dir == "fall" then
		local numberofobjects = 0
		for i, v in pairs(self.checktable) do
			for j, w in pairs(objects[v]) do
				if (not w.ignoreplatform) and w.active then
					if not w.jumping and inrange(w.x, self.x-w.width, self.x+self.width) then
						if inrange(w.y, self.y - w.height - 0.1, self.y - w.height + 0.1) then
							numberofobjects = numberofobjects + 1
							if #checkrect(w.x, w.y, w.width, w.height, {"exclude", w}) == 0 then
								local x1, y1 = math.ceil(w.x+0.01), math.ceil(self.y+self.height)
								local x2, y2 = math.ceil(w.x+w.width), math.ceil(self.y+self.height)
								local maxy, col = math.huge, false
								if (inmap(x1, y1) and tilequads[map[x1][y1][1]]:getproperty("collision", x1, y1) and not tilequads[map[x1][y1][1]]:getproperty("invisible", x1, y1)) then
									maxy = y1-1-w.height
								elseif (inmap(x2, y2) and tilequads[map[x2][y2][1]]:getproperty("collision", x2, y2) and not tilequads[map[x2][y2][1]]:getproperty("invisible", x2, y2)) then
									maxy = y2-1-w.height
								end
								w.y = math.min(maxy, self.y - w.height + self.speedy*dt)
								--make sure red koopas dont fall off
								if v == "drybones" or (v == "koopa" and w.t == "red" and not w.small) or (v == "goomba" and (w.t == "goombrat" or w.t == "spiketop" or w.t == "wiggler")) or (w.turnaroundoncliff and not w.small) then
									if not inrange(w.x+w.width/2+w.speedx*dt, self.x, self.x+self.width) then
										if w.speedx < 0 then
											w.animationdirection = "left"
										else
											w.animationdirection = "right"
										end
										w.speedx = -w.speedx
									end
								end
							end
						end
					end
				end
			end
		end
		
		self.speedy = numberofobjects*4
		
		self.y = self.y + self.speedy*dt
	end
	
	if self.dir == "justup" and self.y < -1 then
		return true
	elseif (self.dir == "justdown" or self.dir == "fall") and self.y > mapheight+1 then
		return true
	end
	
	return false
end

function platform:draw(drop)
	local img = platformimg
	if self.dir == "justright" then
		img = platformbonusimg
	end

	for i = 1, self.size do
		local quadi, ox = 2, 0
		if i == 1 then
			quadi = 1
		elseif math.ceil(self.size) ~= self.size and i == math.ceil(self.size)-1 then
			quadi = 1.5
		elseif i == self.size then
			quadi = 3
		end
		love.graphics.draw(img, platformquad[quadi], math.floor((self.x+i-1-xscroll+ox)*16*scale), math.floor((self.y-yscroll-8/16)*16*scale), 0, scale, scale)
	end
	
	if math.ceil(self.size) ~= self.size then --draw 1 more on the rightest
		local quadi, ox = 3, 0
		if self.size < 2 then
			quadi, ox = 2.5, 0.5
		end
		love.graphics.draw(img, platformquad[quadi], math.floor((self.x+self.size-1-xscroll+ox)*16*scale), math.floor((self.y-yscroll-8/16)*16*scale), 0, scale, scale)
	end

	--trackable platform
	if (self.track or breakoutmode) and (not drop) then
		love.graphics.draw(platformtrackimg, goombaquad[self.platformtracki][math.floor(self.trackanimtimer)], math.floor((self.x+self.size/2-xscroll)*16*scale), math.floor((self.y-yscroll-8/16)*16*scale), 0, scale, scale, 8, 0)
	end
end

function platform:rightcollide(a, b)
	if breakoutmode then return true end
	return false
end

function platform:leftcollide(a, b)
	if breakoutmode then return true end
	return false
end

function platform:ceilcollide(a, b)
	if self.dir == "justright" then
		self.trackspeed = nil
		if not self.track then
			self.speedx = platformbonusspeed
		end
	elseif self.dir == "fall" then
		self.trackspeed = nil
	end
	return false
end

function platform:floorcollide(a, b)
	return false
end

function platform:passivecollide(a, b)
	return false
end

function platform:link()
	if #self.r > 3 then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[5]) == v.cox and tonumber(self.r[6]) == v.coy then
					v:addoutput(self)
				end
			end
		end
	end
end

function platform:input(t)
	if t == "on" then
		self.on = true
	elseif t == "off" then
		self.on = false
	elseif t == "toggle" then
		self.on = not self.on
	end

	if not self.on then
		self.speedx = 0; self.speedy = 0
		self.trackspeed = 0
	else
		self.trackspeed = nil
	end
end

function platform:dotrack(track)
	self.track = true
	if track then
		self.active = true
		self.tracked = true
	else
		self.static = false
		self.active = true
		self.tracked = false
		--self.gravity = nil
	end
	self.oldx, self.oldy = self.x, self.y
end