skewer = class:new()

function skewer:init(x, y, dir, r)
	--PHYSICS STUFF
	self.cox = x
	self.coy = y
	self.speedy = 0
	self.speedx = 0
	self.gravity = 0
	self.static = true
	self.active = true
	self.activestatic = true
	self.category = 4
	self.portalable = false
	self.killstuff = true
	
	self.mask = {	true, 
					false, false, false, false, true,
					false, true, false, true, false,
					false, false, true, false, false,
					true, true, false, false, false,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	self.autodelete = false
	
	--IMAGE STUFF
	self.drawable = false
	
	self.rotation = 0 --for portals
	
	self.shot = false
	
	self.attack = false
	self.hitground = false
	self.hitgroundtimer = 0
	self.waittimer = 0 --time it takes to attack again

	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	
	if #self.r > 0 and self.r[1] ~= "link" then
		--this is where you get the direction, but it's already an argument
		table.remove(self.r, 1)
	end
	
	self.length = skewerstartlength
	self.dir = dir or "down"
	self.x = x-.5
	self.y = y-.5
	if self.dir == "down" then
		self.y = self.y - .5
		self.width = 44/16
		self.height = self.length
		self.x = self.x - self.width/2 + .5
	elseif self.dir == "up" then
		self.width = 44/16
		self.height = self.length
		self.y = self.y + .5 - self.height
		self.x = self.x - self.width/2 + .5
	elseif self.dir == "right" then
		self.x = self.x - .5
		self.height = 44/16
		self.width = self.length
		self.y = self.y - self.height/2 + .5
	elseif self.dir == "left" then
		self.height = 44/16
		self.width = self.length
		self.x = self.x - 2.5
		self.y = self.y - self.height/2 + .5
	end
	self.timer = 0
	self.wait = 0
	self.wind = true
	self.retract = false

	self.power = true
end

function skewer:update(dt)
	--wait
	if self.wait > 0 then
		self.wait = self.wait - dt
		return
	end
	--move
	if self.power then
		self.timer = self.timer + dt
	end
	if self.timer > skewertime then
		if self.wind then
			self.length = math.max(self.length - skewerretractspeed*dt, skewerminlength)
			if self.length == skewerminlength then
				self.wind = false
				self.wait = 0.2
			end
		elseif self.retract then
			self.length = math.max(self.length - skewerretractspeed*dt, skewerstartlength)
			if self.length == skewerstartlength then
				self.timer = 0
				self.retract = false
				self.wind = true
			end
		else
			local hit = false
			local onscreen = false
			self.length = math.min(skewermaxlength, self.length + skewerspeed*dt)
			--detect blocks
			if self.length > skewerstartlength then
				local x1, x2, y1, y2
				if self.dir == "down" then
					x1 = self.x
					x2 = self.x+self.width
					y1 = self.y+self.height
					y2 = self.y+self.length
				elseif self.dir == "up" then
					x1 = self.x
					x2 = self.x+self.width
					y1 = self.y+self.height-self.length
					y2 = self.y
				elseif self.dir == "right" then
					x1 = self.x+self.width
					x2 = self.x+self.length
					y1 = self.y
					y2 = self.y+self.height
				elseif self.dir == "left" then
					x1 = self.x+self.width-self.length
					x2 = self.x
					y1 = self.y
					y2 = self.y+self.height
				end
				for x = math.ceil(x1), math.ceil(x2) do
					for y = math.ceil(y1), math.ceil(y2) do
						local inmap = true
						if x < 1 or x > mapwidth or y < 1 or y > mapheight then
							inmap = false
							hit = true
						end
						if not onscreen and x > xscroll-2 and y > yscroll-2 and x < xscroll+width+2 and y < yscroll+height+2 then
							onscreen = true
						end
						if inmap then
							local r = map[x][y]
							if r then
								if tilequads[r[1]].collision and  
								((self.dir == "down" and tilequads[r[1]].platform) or
								(self.dir == "up" and tilequads[r[1]].platformdown) or
								(self.dir == "right" and tilequads[r[1]].platformleft) or
								(self.dir == "left" and tilequads[r[1]].platformright) or
								((not tilequads[r[1]].platform) and (not tilequads[r[1]].platformdown)
								and (not tilequads[r[1]].platformleft) and (not tilequads[r[1]].platformright))
								) then
									if tilequads[r[1]].breakable then
										hitblock(x, y, {size=2})
									elseif tilequads[map[x][y][1]].coinblock or (tilequads[map[x][y][1]].debris and blockdebrisquads[tilequads[map[x][y][1]].debris]) then -- hard block
										destroyblock(x, y)
										hit = true
									else
										hit = true
									end
								end
								if objects["frozencoin"][tilemap(x, y)] then
									objects["frozencoin"][tilemap(x, y)]:meltice("destroy")
									hit = true
								end
							end
						end
					end
				end
			end
			
			if hit or self.length == skewermaxlength then
				if onscreen then
					playsound(thwompsound)
				end
				self.retract = true
				self.wait = 0.4
			end
		end
	end
	--apply length
	if self.dir == "down" then
		self.height = self.length
	elseif self.dir == "up" then
		self.y = self.y + self.height
		self.height = self.length
		self.y = self.y - self.height
	elseif self.dir == "right" then
		self.width = self.length
	elseif self.dir == "left" then
		self.x = self.x + self.width
		self.width = self.length
		self.x = self.x - self.width
	end
end

function skewer:draw()
	love.graphics.setColor(255, 255, 255)
	if self.dir == "down" then
		love.graphics.draw(skewerimg, skewerquad[spriteset][3], (self.x+self.width/2-xscroll)*16*scale, (self.y+self.length-1-yscroll)*16*scale, 0, scale, scale, 32, 8)
		love.graphics.setScissor((self.x+self.width/2-32/16-xscroll)*16*scale, (self.y-.5-yscroll)*16*scale, 64*scale, self.length*16*scale)
		for i = 1, math.floor(self.length) do
			love.graphics.draw(skewerimg, skewerquad[spriteset][(i%2)+1], (self.x+self.width/2-xscroll)*16*scale, (self.y+self.length-1-i-yscroll)*16*scale, 0, scale, scale, 32, 8)
		end
		love.graphics.setScissor()
	elseif self.dir == "up" then
		love.graphics.draw(skewerimg, skewerquad[spriteset][3], (self.x+self.width/2-xscroll)*16*scale, (self.y-yscroll)*16*scale, math.pi, scale, scale, 32, 8)
		love.graphics.setScissor((self.x+self.width/2-32/16-xscroll)*16*scale, math.floor((self.y-.5-yscroll)*16)*scale, 64*scale, math.ceil(self.length*16*scale))
		for i = 1, math.floor(self.length) do
			love.graphics.draw(skewerimg, skewerquad[spriteset][(i%2)+1], (self.x+self.width/2-xscroll)*16*scale, (self.y+i-yscroll)*16*scale, math.pi, scale, scale, 32, 8)
		end
		love.graphics.setScissor()
	elseif self.dir == "right" then
		love.graphics.draw(skewerimg, skewerquad[spriteset][3], (self.x+self.length-.5-xscroll)*16*scale, (self.y+self.height/2-.5-yscroll)*16*scale, math.pi*1.5, scale, scale, 32, 8)
		love.graphics.setScissor((self.x-xscroll)*16*scale, (self.y-1-yscroll)*16*scale, self.length*16*scale, 64*scale)
		for i = 1, math.floor(self.length) do
			love.graphics.draw(skewerimg, skewerquad[spriteset][(i%2)+1], (self.x+self.length-.5-i-xscroll)*16*scale, (self.y+self.height/2-.5-yscroll)*16*scale, math.pi*1.5, scale, scale, 32, 8)
		end
		love.graphics.setScissor()
	elseif self.dir == "left" then
		love.graphics.draw(skewerimg, skewerquad[spriteset][3], (self.x+.5-xscroll)*16*scale, (self.y+self.height/2-.5-yscroll)*16*scale, math.pi*.5, scale, scale, 32, 8)
		love.graphics.setScissor(math.floor((self.x-xscroll)*16)*scale, (self.y-1-yscroll)*16*scale, math.ceil(self.length*16)*scale, 64*scale)
		for i = 1, math.floor(self.length) do
			love.graphics.draw(skewerimg, skewerquad[spriteset][(i%2)+1], (self.x+.5+i-xscroll)*16*scale, (self.y+self.height/2-.5-yscroll)*16*scale, math.pi*.5, scale, scale, 32, 8)
		end
		love.graphics.setScissor()
	end
end

function skewer:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return true
end

function skewer:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return true
end

function skewer:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function skewer:globalcollide(a, b)
	if mariohammerkill[a] then
		b:shotted("right")
		if a ~= "bowser" then
			addpoints(firepoints[a], self.x, self.y)
		end
	elseif a == "enemy" then
		if b:shotted("right", false, false, true) ~= false then
			addpoints(b.firepoints or 200, self.x, self.y)
		end
	end
end

function skewer:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function skewer:passivecollide(a, b)
	if not self.retract then
		local hit = false
		if a == "donut" or a == "flipblock" or a == "powblock" then
			b:ceilcollide("skewer", self)
			hit = true
		elseif a == "buttonblock" or a == "frozencoin" then
			hit = true
		elseif a == "blocktogglebutton" then
			b:ceilcollide("skewer", self)
			hit = true
		end
		if hit then
			self.length = math.floor(self.length)
			playsound(thwompsound)
			self.retract = true
			self.wait = 0.4
			return true
		end
		return false
	end
end

function skewer:link()
	while #self.r >= 3 do
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[2]) == v.cox and tonumber(self.r[3]) == v.coy then
					if self.r[4] == "trigger" then
						self.power = false
					end
					v:addoutput(self, self.r[4] or "trigger")
				end
			end
		end
		
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
	end
end

function skewer:input(t, input)
	if input == "trigger" then
		if t ~= "off" then
			if self.timer < skewertime then
				self.timer = skewertime+1
			end
		end
	end
end
