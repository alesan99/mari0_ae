risingwater = class:new()

function risingwater:init(x, y, r)
	--region, type, fill, fill speed, oscillate, link power, link reverse
	self.cox = x
	self.coy = y

	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	
	if #self.r > 0 and self.r[1] ~= "link" then
		--rightclick things
		if self.r[1]:find("|") then
			local v = convertr(self.r[1], {"num", "num", "num", "num", "string", "num", "num", "bool", "num", "bool"})
			self.rx = (self.cox-1)+v[3]
			self.ry = (self.coy-1)+v[4]
			self.rw = v[1]
			self.rh = v[2]
			self.t = v[5] or "water"
			self.filllow = v[6]
			self.fillspeed = v[7]/self.rh
			self.oscillate = v[8]
			self.waittime = v[9]
			self.ontop = v[10]
		end
		table.remove(self.r, 1)
	end

	self.drawover = self.ontop
	self.x = self.rx
	self.y = self.ry
	self.width = self.rw
	self.height = self.rh
	self.speed = self.fillspeed
	self.fill = self.filllow
	if self.filllow == 1 then
		self.filllow = 0
	end

	if self.t == "clear water" then
		self.quadi = 1
		self.animdelay = 0.2
	elseif self.t == "water" then
		self.quadi = 2
		self.animdelay = 0.2
	elseif self.t == "poison" then
		self.quadi = 3
		self.animdelay = 0.2
	elseif self.t == "poison water" then
		self.quadi = 3
		self.animdelay = 0.2
	elseif self.t == "lava" then
		self.quadi = 4
		self.animdelay = 0.2
	elseif self.t == "quicksand" then
		self.quadi = 5
		self.animdelay = 0.2
	end

	if self.t == "clear water" or self.t == "water" then
		self.water = true
		self.checktable = {"player", "cheep", "enemy"}
	elseif self.t == "poison water" then
		self.water = true
		self.hurt = true
		self.checktable = {"player", "enemy"}
	elseif self.t == "quicksand" then
		self.sand = true
		self.sandsink = 80
		self.sandspeedy = 0.9
		self.sandspeedx = 2
		self.checktable = {"player", "goomba", "koopa", "pokey", "enemy"}
	elseif self.t == "lava" or self.t == "poison" then
		self.kill = true
		self.checktable = {"player"}
	end

	self.animtimer = 0
	self.frame = 1
	self.timer = 0

	self.waittimer = 0

	self.power = true
	self.drain = false
	self.reverse = false

	self:updatefill()

	self.sinewave = 0

	if self.rw >= width and self.rh > 3 then
		self.spritebatch = love.graphics.newSpriteBatch(risingwaterimg, 1000)
		self.spritebatchupdated = false
	end
end

function risingwater:update(dt)
	--rise (or drain)
	if self.waittimer > 0 then
		self.waittimer = self.waittimer - dt
	elseif self.power then
		local drain = self.drain
		if self.reverse then
			drain = not drain
		end
		if drain then
			--smooth movement
			local dist1 = math.abs(self.height-self.rh)
			local dist2 = math.abs(self.height-self.filllow*self.rh)
			if dist2 < 1 then
				self.speed = self.fillspeed*(dist2+0.1)
			elseif dist1 < 1 then
				self.speed = self.fillspeed*(dist1+0.1)
			else
				self.speed = math.min(self.fillspeed, self.speed+20*dt)
			end
			self.fill = math.max(self.filllow, self.fill - self.speed*dt)
			if self.oscillate and self.fill == self.filllow then
				self.drain = not self.drain
				self.waittimer = self.waittime
			end
		else
			--smooth movement
			local dist1 = math.abs(self.height-self.rh)
			local dist2 = math.abs(self.height-self.filllow*self.rh)
			if dist1 < 1 then
				self.speed = self.fillspeed*(dist1+0.1)
			elseif dist2 < 1 then
				self.speed = self.fillspeed*(dist2+0.1)
			else
				self.speed = math.min(self.fillspeed, self.speed+20*dt)
			end
			self.fill = math.min(1, self.fill + self.speed*dt)
			if self.oscillate and self.fill == 1 then
				self.drain = not self.drain
				self.waittimer = self.waittime
			end
		end
	end

	self.sinewave = self.sinewave + 12*dt

	--affect entities
	local colls = checkrect(self.x, self.y, self.width, self.height, self.checktable)
	if #colls > 0 then
		for j = 1, #colls, 2 do
			local a = colls[j]
			local b = objects[a][colls[j+1]]
			if (not b.clearpipe) then
				if a == "player" then
					if (not b.fence) then
						local drybonesshell = (b.shoe and b.shoe == "drybonesshell")
						local getshurt = true
						if drybonesshell then
							if b.y < self.y then
								local targety = false
								if b.speedy >= 0 and self.height > b.height/2 then
									targety = (self.y-b.height/2)
									if self.speed <= 1 then
										targety = targety + (math.sin(self.sinewave)*.1)
									end
								end
								if targety and #checkrect(b.x, targety, b.width, b.height, {"tile", "buttonblock", "flipblock", "platform", "donut", "frozencoin"}, true, "ignoreplatforms") == 0 then
									b.y = targety
									b.speedy = math.min(0, b.speedy)
								end
								b.groundpounding = false
								b.groundpoundcanceled = false
								b.falling = false
								b.lavasurfing = true
								if not b.jumping then
									b.falloverride = true
								end
								getshurt = false
							end
						end
						if self.water then
							if not b.water and not b.risingwater then
								if b.y < self.y then
									--makepoof(b.x+b.width/2, self.y+1/16, "splash")
								end
								b:dive(true)
							end
							b.risingwater = true
						end
						local inportal
						if self.kill then
							if (inportal == nil) and b.y < self.y then
								--don't kill if portalling (portalling above lava into the ground would kill)
								inportal = insideportal(b.x, b.y, b.width, b.height)
							end
							if getshurt and (not (levelfinished and not b.controlsenabled)) and (not inportal) then
								b:die("lava")
							end
						end
						if self.hurt then
							if (inportal == nil) and b.y < self.y then
								inportal = insideportal(b.x, b.y, b.width, b.height)
							end
							if getshurt and (not (levelfinished and not b.controlsenabled)) and (not inportal) then
								if not (b.invincible or b.starred) then
									b:die("poison")
								end
							end
						end
						if self.sand then
							local gravity = yacceleration or b.gravity
							if lowgravity and not b.ignorelowgravity then
								if b.jumping or (b.falling and b.speedy < 0) then
									gravity = (b.gravity or yacceleration)*lowgravityjumpingmult
								else
									gravity = (b.gravity or yacceleration)*lowgravitymult
								end
							end
							if b.speedy > 0 and b.falling then
								b.falling = false
								b.jumping = false
								b.animationstate = "idle"
							end
							b.speedy = math.min(self.sandspeedy - gravity*dt, b.speedy + self.sandsink*dt)
							b.quicksand = true
							b.speedx = math.min(self.sandspeedx, math.max(-self.sandspeedx, b.speedx))
							if b.speedx == 0 and not b.jumping then
								b.animationstate = "idle"
							end
						end
					end
				else
					if self.water then
						if b.float then
							if not b.risingwater then
								b:dive(true)
								b.risingwater = true
							end
							local speed = 800
							if type(b.float) == "number" then
								speed = b.float
							end
							b.speedy = math.max(-120, b.speedy-speed*dt)
						end
						if a == "enemy" then
							b.risingwater = 2
						end
						if a == "cheep" and b.color == 3 then
							if b.initial then
								b.waterborne = true
							end
							b.water = true
							b.risingwater = 2
						end
					end
					if self.kill then
						if a == "enemy" and not b.resistsfire then
							if b:shotted("right", false, false, true) ~= false then
								addpoints(b.firepoints or 200, self.x, self.y)
							end
						else
							addpoints(firepoints[obj], b.x, b.y)
							b:shotted(self.animationdirection)
						end
					end
					if self.sand and not b.ignorequicksand then
						b.speedy = math.min(self.sandspeedy, b.speedy + self.sandsink*dt)
						b.speedx = math.min(self.sandspeedx, math.max(-self.sandspeedx, b.speedx))
					end
				end
			end
		end
	end

	--animation
	self.animtimer = self.animtimer + dt
	while self.animtimer > self.animdelay do
		self.frame = self.frame + 1
		if self.frame > 4 then
			self.frame = 1
		end
		self.animtimer = self.animtimer - self.animdelay
	end

	--update water
	self:updatefill()

	if self.spritebatch and onscreen(self.x, self.y, self.width, self.height) then
		self.spritebatch:clear()
		for x = 1, math.ceil(self.width) do
			for y = 1, math.ceil(self.height) do
				if onscreen(self.x+(x-1), self.y+(y-1), 1, 1) then
					local framei = 2
					if y == 1 then
						framei = 1
					end
					self.spritebatch:add(risingwaterquad[spriteset][self.quadi][framei][self.frame], math.floor((self.x+(x-1)-xscroll)*16*scale), math.floor(((self.y+(y-1)-yscroll)*16-8)*scale), 0, scale, scale)
				end
			end
		end
		self.spritebatchupdated = true
	end
end

function risingwater:draw()
	--[[draw orange rectangle
	love.graphics.setColor(234, 160, 45, 111)
	love.graphics.rectangle("fill", (((self.rx)*16)-xscroll*16)*scale, ((self.ry-(8/16)-yscroll)*16)*scale, (self.rw*16)*scale, (self.rh*16)*scale)
	love.graphics.setColor(0, 0, 255, 150)
	love.graphics.rectangle("fill", (((self.x)*16)-xscroll*16)*scale, ((self.y-(8/16)-yscroll)*16)*scale, (self.width*16)*scale, (self.height*16)*scale)
	love.graphics.setColor(255, 255, 255, 255)]]
	if not onscreen(self.x, self.y, self.width, self.height) then
		return false
	end

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setScissor(math.floor((((self.x)*16)-xscroll*16)*scale), math.floor(((self.y-(8/16)-yscroll)*16)*scale), math.ceil((self.width*16)*scale), math.ceil((self.height*16)*scale))
	if self.spritebatch and self.spritebatchupdated then
		love.graphics.draw(self.spritebatch)
	else
		for x = 1, math.ceil(self.width) do
			for y = 1, math.ceil(self.height) do
				if onscreen(self.x+(x-1), self.y+(y-1), 1, 1) then
					local framei = 2
					if y == 1 then
						framei = 1
					end
					love.graphics.draw(risingwaterimg, risingwaterquad[spriteset][self.quadi][framei][self.frame], math.floor((self.x+(x-1)-xscroll)*16*scale), math.floor(((self.y+(y-1)-yscroll)*16-8)*scale), 0, scale, scale)
				end
			end
		end
	end
	love.graphics.setScissor()
end

function risingwater:updatefill()
	self.height = self.rh*self.fill
	self.y = self.ry+self.rh-self.height
end

function risingwater:link()
	while #self.r >= 3 do
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[2]) == v.cox and tonumber(self.r[3]) == v.coy then
					if self.r[4] == "power" then
						self.power = false
					end
					v:addoutput(self, self.r[4] or "reverse")
				end
			end
		end
		
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
	end
end

function risingwater:input(t, input)
	if input == "power" then
		if t == "on" then
			self.power = true
			self.waittimer = 0
		elseif t == "off" then
			self.power = false
		else
			self.power = not self.power
			self.waittimer = 0
		end
	elseif input == "reverse" then
		if t == "on" then
			self.reverse = true
		elseif t == "off" then
			self.reverse = false
		else
			self.reverse = not self.reverse
		end
		if self.waittimer > 0 then
			self.drain = not self.drain
			self.waittimer = 0
		end
	end
end

function risingwater:inside(x, y)
	return (x > self.x and y > self.y and x < self.x+self.width and y < self.y+self.height)
end
