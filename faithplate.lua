faithplate = class:new()

function faithplate:init(x, y, dir, vars, r)
	self.cox = x
	self.coy = y
	self.dir = dir
	
	self.x = x-1
	self.y = y-1
	self.width = 2
	self.height = 0.125
	self.active = true
	self.static = true
	self.category = 26

	self.legacy = false --keep old faithplate movement
	self.snap = false
	self.sx = 0
	self.sy = 40
	self.r = r
	self.defaulton = true
	self.on = self.defaulton

	if vars and vars ~= "link" then
		local v = convertr(vars, {"num", "num", "bool", "bool"}, true)
		self.vars = v
		self.sx = v[1]
		self.sy = v[2]
		--SNAP
		if v[3] ~= nil then
			self.snap = v[3]
		end
		--DEFAULT OFF
		if v[4] ~= nil and v[4] == true then
			self.defaulton = false
			self.on = self.defaulton
		end
		if self.sx > 10 then
			self.dir = "right"
		elseif self.sx < -10 then
			self.dir = "left"
		end
	elseif self.dir == "up" then
		self.sx = 0
		self.sy = 40
		self.legacy = true
	elseif self.dir == "left" then
		self.sx = -30
		self.sy = 30
		self.legacy = true 
	elseif self.dir == "right" then
		self.sx = 30
		self.sy = 30
		self.legacy = true 
	end
	
	self.mask = {true}
	
	self.animationtimer = 1
	
	self.includetable = {
		"player", "box", "gel", "turret", "enemy", "ice", "energyball", "tilemoving",
		"mushroom", "flower", "oneup", "star", "fireball", "fire", "poisonmush", "brofireball",
		"boomerang", "hammersuit", "mariohammer", "frogsuit", "levelball", "core", "iceball",
		"powblock", "smallspring", "pbutton"
	}
	local ignorelist = {"icicle", "cheep", "squid", "flyingfish", "cheepwhite", "cheepred", "chainchomp", "pinksquid", "parabeetle", "parabeetleright", "boo", "rockywrench"}
	for i, v in pairs(enemies) do
		if not tablecontains(ignorelist, v) then
			table.insert(self.includetable, v)
		end
	end
end

function faithplate:update(dt)
	if self.animationtimer < 1 then
		self.animationtimer = self.animationtimer + dt / faithplatetime
	end

	if not self.on then
		return
	end

	local intable = checkrect(self.x+.5, self.y-0.125, 1, 0.125, self.includetable)
	
	for i = 1, #intable, 2 do
		local v = objects[intable[i]][intable[i+1]]
		if (not v.ignorefaithplate) and (not v.ignorefaithplates) then
			if not (math.abs(self.sx) < 0.1 and not self.snap) then --don't change horizontal speed
				v.speedx = self.sx
			end
			v.speedy = -self.sy

			if self.snap then
				v.x = self.x+1-v.width/2
			end
			
			if v.faithplate then
				v:faithplate(self.dir)
			end
			
			self.animationtimer = 0
		end
	end
end

function faithplate:draw()
	local quadi = 2
	if self.on then quadi = 1 end
	love.graphics.setScissor(math.floor((self.cox-1-xscroll)*16*scale), (self.coy-4-yscroll)*16*scale, 32*scale, (2.5+2/16)*16*scale)
	
	if not custombackground then
		love.graphics.setColor(unpack(backgroundcolor[background]))
		love.graphics.rectangle("fill", math.floor((self.cox-1-xscroll)*16*scale), (self.coy-1.5-yscroll)*16*scale, 32*scale, 2*scale)
		love.graphics.setColor(1, 1, 1)
	end

	if self.animationtimer < 1 then
		if self.dir == "right" then
			local rot = 0
			if self.animationtimer < 0.1 then
				rot = math.pi/4*(self.animationtimer/0.1)
			elseif self.animationtimer < 0.3 then
				rot = math.pi/4
			else
				rot = math.pi/4*(1 - (self.animationtimer-0.3)/0.7)
			end
				
			love.graphics.draw(faithplateplateimg, faithplatequad[quadi], math.floor((self.cox+1-xscroll)*16*scale), (self.coy-1.5-yscroll)*16*scale, rot, scale, scale, 32)
		elseif self.dir == "left" then
			local rot = 0
			if self.animationtimer < 0.1 then
				rot = math.pi/4*(self.animationtimer/0.1)
			elseif self.animationtimer < 0.3 then
				rot = math.pi/4
			else
				rot = math.pi/4*(1 - (self.animationtimer-0.3)/0.7)
			end
				
			love.graphics.draw(faithplateplateimg, faithplatequad[quadi], math.floor((self.cox-1-xscroll)*16*scale), (self.coy-1.5-yscroll)*16*scale, -rot, -scale, scale, 32)
		elseif self.dir == "up" then
			local ymod = 0
			if self.animationtimer < 0.1 then
				ymod = .5*(self.animationtimer/0.1)
			elseif self.animationtimer < 0.3 then
				ymod = .5
			else
				ymod = .5*(1 - (self.animationtimer-0.3)/0.7)
			end
			
			love.graphics.draw(faithplateplateimg, faithplatequad[quadi], math.floor((self.cox-1-xscroll)*16*scale), (self.coy-1.5-yscroll-ymod)*16*scale, 0, scale, scale)
		end
	else
		if self.dir ~= "left" then
			love.graphics.draw(faithplateplateimg, faithplatequad[quadi], math.floor((self.cox-1-xscroll)*16*scale), (self.coy-1.5-yscroll)*16*scale, 0, scale, scale)
		else
			love.graphics.draw(faithplateplateimg, faithplatequad[quadi], math.floor((self.cox+1-xscroll)*16*scale), (self.coy-1.5-yscroll)*16*scale, 0, -scale, scale)
		end
	end
	
	love.graphics.setScissor()
end

function faithplate:input(t)
	if t == "on" then
		self.on = not self.defaulton
	elseif t == "off" then
		self.on = self.defaulton
	elseif t == "toggle" then
		self.on = not self.on
	end
end

function faithplate:link()
	if #self.r > 2 then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[5]) == v.cox and tonumber(self.r[6]) == v.coy then
					v:addoutput(self)
					if self.vars[4] == nil then
						self.defaulton = false
						self.on = self.defaulton
					end
				end
			end
		end
	end
end
