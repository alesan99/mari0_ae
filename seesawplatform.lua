seesawplatform = class:new()

function seesawplatform:init(x, y, size, callback, side)
	--PHYSICS STUFF
	self.size = size or 2
	self.startx = x-self.size	
	self.starty = y	
	self.x = x-self.size/2-0.5
	self.y = y-17/16
	self.speedx = 0 --!
	self.speedy = 0
	self.width = self.size
	self.height = 8/16
	self.static = true
	self.active = true
	self.category = 15
	self.mask = {true}
	self.gravity = 0
	
	self.callback = callback
	self.side = side

	self.checktable = {"player", "box", "enemy"}
	for i, v in pairs(enemies) do
		if objects[v] and underwater == false then
			table.insert(self.checktable, v)
		end
	end
	
	--IMAGE STUFF
	self.drawable = false
	
	self.rotation = 0
	
	self.speedy = 0
end

function seesawplatform:update(dt)
	local previousX = self.x
	local previousY = self.y
	
	local numberofobjects = 0
	
	for i, v in pairs(self.checktable) do
		for j, w in pairs(objects[v]) do
			if w.active and (not w.ignoreplatform) and (not w.jumping) and w.width and inrange(w.x, self.x-w.width, self.x+self.width) then
				if inrange(w.y, self.y - w.height - 0.1, self.y - w.height + 0.1) then
					numberofobjects = numberofobjects + 1
					if #checkrect(w.x, w.y, w.width, w.height, {"exclude", w}) == 0 then
						local x1, y1 = math.ceil(w.x+0.01), math.ceil(self.y+self.height)
						local x2, y2 = math.ceil(w.x+w.width), math.ceil(self.y+self.height)
						local maxy, col = math.huge, false
						if (inmap(x1, y1) and checkfortileincoord(x1, y1)) then
							maxy = y1-1-w.height
						elseif (inmap(x2, y2) and checkfortileincoord(x2, y2)) then
							maxy = y2-1-w.height
						end
						w.y = math.min(maxy, self.y - w.height + self.speedy*dt)
					end
				end
			end
		end
	end
	
	self.y = self.y + self.speedy*dt
	
	--report back on number of objects
	if self.side == "left" then
		self.callback:callbackleft(numberofobjects)
	else
		self.callback:callbackright(numberofobjects)
	end
	
	if self.y > mapheight+1 then
		return true
	end
	
	return false
end

function seesawplatform:draw()
	for i = 1, self.size do
		local quadi = 2
		if i == 1 then
			quadi = 1
		elseif i == self.size then
			quadi = 3
		end
		love.graphics.draw(platformimg, platformquad[quadi], math.floor((self.x+i-1-xscroll)*16*scale), math.floor((self.y-yscroll-8/16)*16*scale), 0, scale, scale)
	end
	
	if math.ceil(self.size) ~= self.size then --draw 1 more on the rightest
		love.graphics.draw(platformimg, platformquad[3], math.floor((self.x+self.size-1-xscroll)*16*scale), math.floor((self.y-yscroll-8/16)*16*scale), 0, scale, scale)
	end
end

function seesawplatform:rightcollide(a, b)
	return false
end

function seesawplatform:leftcollide(a, b)
	return false
end

function seesawplatform:ceilcollide(a, b)
	return false
end

function seesawplatform:floorcollide(a, b)
	return false
end