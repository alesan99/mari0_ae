blocktogglebutton = class:new()

function blocktogglebutton:init(x, y, color, t)
	--PHYSICS STUFF
	self.t = t or  "small"
	
	self.cox = x
	self.coy = y
	self.x = x-8/16
	if self.t == "big" then
		self.width = 2
		self.height = 2
		self.y = y-31/16
	else
		self.width = 1
		self.height = 1
		self.y = y-15/16
	end
	
	self.static = true
	self.active = true
	self.speedx = 0
	self.speedy = 0
	
	if self.t == "p" and map[self.x+1] and map[self.x+1][self.y+1] and tilequads[map[self.x+1][self.y+1][1]].collision then
		self.inblock = true
		self.static = true
	end
	
	self.dir = "down"
	if self.t == "p" then
		self.color = 1
		if color then
			local v = convertr(color, {"string"}, true)
			self.dir = v[1] or "down"
		end
	else
		self.color = color or 1
	end
	
	self.category = 2
	self.mask = {	true, 
					false, false, false, false, true,
					false, true, false, true, false,
					false, false, true, false, false,
					true, true, false, false, false,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	
	self.autodelete = false
	self.extremeautodelete = true
	
	--IMAGE STUFF
	self.drawable = not self.inblock
	if self.t == "big" then
		self.graphic = bigblocktogglebuttonimage
		self.quad = bigblockquad[self.color][1]
	elseif self.t == "p" then
		self.graphic = pbuttonimg
		self.quad = flipblockquad[spriteset][1]
		self.quadi = 1
		if not self.inblock then
			self.static = false
		end
	else
		self.graphic = blocktogglebuttonimage
		self.quad = flipblockquad[self.color][1]
		self.quadi = 1
	end
	self.offsetX = 8
	self.offsetY = 0
	self.quadcenterX = 8
	self.quadcenterY = 8

	self.rotation = 0
	if self.dir ~= "down" then
		self.static = true
		self.activestatic = true
		if self.dir == "up" then
			self.rotation = math.pi
		elseif self.dir == "left" then
			self.rotation = math.pi*.5
		elseif self.dir == "right" then
			self.rotation = math.pi*1.5
		end
	end

	self.falling = false
	
	self.pushed = false
	self.time = 4
	if self.t == "p" then
		self.time = pbuttontime
	end
	self.timer = 0
	self.timer2 = 0
	self.animtimer = 0
	self.uptimer = 0
	self.light = 3
	self.pipespawnmax = 1
end

function blocktogglebutton:update(dt)
	if self.dir == "down" then
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
	end

	if self.pushed then
		self.active = false
		if not self.noti then
			self.timer = self.timer + dt
		end
		if self.timer > self.time and self.t ~= "big" then
			if self.t == "p" then
				self.timer = 0
				self.noti = true
				local yespls = true
				for j, w in pairs(objects["pbutton"]) do
					if w.pushed and not w.noti then
						yespls = false
					end
				end
				if yespls then
					self:changeblocks(true)
					pbuttonsound:stop()
					if (not music:playingmusic()) and (not lowtimesound:isPlaying()) and (not levelfinished) then
						playmusic()
					end
				end
			else
				self.quad = flipblockquad[self.color][self.quadi]
				self.active = true
				self.pushed = false
				self.timer = 0
			end
		end
		if self.t == "p" and self.timer < 8 and not self.noti then
			self.timer2 = self.timer2 + dt
		end
	else--if self.t == "p" then
		self.animtimer = self.animtimer + dt
		while self.animtimer > goombaanimationspeed do
			if self.quadi == 2 then
				self.quadi = 1
			else
				self.quadi = 2
			end
			if self.t == "p" then
				self.quad = flipblockquad[spriteset][self.quadi]
			elseif self.t == "big" then
				self.quad = bigblockquad[self.color][self.quadi]
			else
				self.quad = flipblockquad[self.color][self.quadi]
			end
			self.animtimer = self.animtimer - goombaanimationspeed
		end
	end
	if self.inblock then
		if self.uptimer < mushroomtime then
			self.uptimer = self.uptimer + dt
			self.y = self.y - dt*(1/mushroomtime)
		else
			if not self.drawable then
				self.static = false
				self.active = true
				self.drawable = true
				self.y = self.coy-15/16-1
			end
		end
	end
end

function blocktogglebutton:draw()
	if not self.drawable then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.graphic, self.quad, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), self.rotation, scale, scale, self.quadcenterX, self.quadcenterY)
	end
end

function blocktogglebutton:changeblocks(b)
	if self.t == "p" then
		local bricki = 7
		if spriteset == 2 then
			bricki = 49
		elseif spriteset == 3 then
			bricki = 122
		end
		for x = 1, mapwidth do
			for y = 1, mapheight do
				local t = map[x][y][1]
				if b then
					if map[x][y].oldtile then
						if b and (t == bricki or t == 116) then
							map[x][y][1] = map[x][y].oldtile or map[x][y][1]
							if tilequads[map[x][y][1]].collision then
								objects["tile"][tilemap(x, y)] = tile:new(x-1, y-1, 1, 1, true)
							else
								objects["tile"][tilemap(x, y)] = nil
								checkportalremove(x, y)
								objects["tile"][tilemap(x, y)] = nil
							end
							map[x][y].oldtile = nil
							if map[x][y].oldentitycoin then
								objects["coin"][tilemap(x, y)] = coin:new(x, y)
								map[x][y][2] = 187
								map[x][y].oldentitycoin = nil
							end
						end
					end
					if objects["frozencoin"][tilemap(x, y)] and objects["frozencoin"][tilemap(x, y)].brick then
						objects["frozencoin"][tilemap(x, y)].brick = false
					end
				elseif not b then
					if tilequads[t].breakable then
						map[x][y][1] = 116
						map[x][y].oldtile = t
						objects["tile"][tilemap(x, y)] = nil
						checkportalremove(x, y)
						objects["tile"][tilemap(x, y)] = nil
					elseif tilequads[t].coin then
						map[x][y][1] = bricki
						map[x][y].oldtile = t
						objects["tile"][tilemap(x, y)] = tile:new(x-1, y-1, 1, 1, true)
					elseif objects["coin"][tilemap(x, y)] then
						objects["coin"][tilemap(x, y)] = nil
						map[x][y][1] = bricki
						map[x][y][2] = nil
						map[x][y].oldtile = t
						map[x][y].oldentitycoin = true
						objects["tile"][tilemap(x, y)] = tile:new(x-1, y-1, 1, 1, true)
					end
					if objects["frozencoin"][tilemap(x, y)] then
						objects["frozencoin"][tilemap(x, y)].brick = true
					end
				end
			end
		end
		generatespritebatch()
		--switch pblocks
		for j, w in pairs(objects["buttonblock"]) do
			if w.color == self.t then
				w:change()
			end
		end
		--open pdoors
		local dolock = true --dont close doors if other p-switches are active
		if b then
			for j, w in pairs(objects["pbutton"]) do
				if w.timer > 0 then
					dolock = false
				end
			end
		end
		if dolock then
			for j, w in pairs(objects["doorsprite"]) do
				if w.i == "pdoor" then
					w:lock(b)
				end
			end
			for j, w in pairs(objects["belt"]) do
				w.on = b
			end
			--trigger animations while you're at it
			for i = 1, #animationswitchtriggerfuncs do
				local t = animationswitchtriggerfuncs[i]
				if (not b)  and t[2] == "pswitch-on" then
					t[1]:trigger()
				elseif b and t[2] == "pswitch-off" then
					t[1]:trigger()
				end
			end
		end
	else
		changeswitchstate(self.color, (self.t == "big"), true)
	end
end

function blocktogglebutton:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function blocktogglebutton:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function blocktogglebutton:ceilcollide(a, b)
	if self.dir == "down" and self:press(a, b) then
		return false
	end
end

function blocktogglebutton:press(a, b)
	if a == "player" or a == "thwomp" or a == "skewer" or (a == "fireball" and b.t == "superball") or a == "icicle" or a == "spikeball" or a == "muncher" or (a == "enemy" and (b.activateswitches or b.small)) or (a == "koopa" and b.small) then
		if self.t == "big" then
			self.quad = bigblockquad[self.color][3]
		elseif self.t == "p" then
			self.quad = flipblockquad[spriteset][3]
		else
			self.quad = flipblockquad[self.color][3]
		end
		local yespls = true
		if self.t == "p" then
			for j, w in pairs(objects["pbutton"]) do
				if w.pushed and not w.noti then
					yespls = false
				end
			end
		end
		if yespls then
			self:changeblocks()
		end
		self.pushed = true
		playsound(bulletbillsound)
		if self.t == "p" then
			stopmusic()
			if lowtimesound:isPlaying() then
				pbuttonsound:setVolume(0)
			else
				pbuttonsound:setVolume(1)
			end
			playsound(pbuttonsound)
			--playsound(pbuttonpushsound) i didn't find a sound :(
		else
			playsound(switchsound)
		end
		return true
	end
	return false
end

function blocktogglebutton:globalcollide(a, b)
	if a == "thwomp" then
	   return true
	end
end

function blocktogglebutton:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if self.dir == "down" then
		if a == "player" and b.gravitydir == "down" and b.speedy < 0 then
			playsound(blockhitsound)
		end
	elseif self.dir == "up" then
		if self:press(a, b) then
			return false
		end
	end
end

function blocktogglebutton:passivecollide(a, b)
	return false
end

--------------------------------------------------------------------------------------

buttonblock = class:new()

function buttonblock:init(x, y, color, solid)
	--PHYSICS STUFF
	self.cox = x
	self.coy = y
	self.x = x-1
	self.y = y-1
	
	self.width = 1
	self.height = 1
	
	self.color = color or 1
	self.solid = true
	
	self.static = true
	self.active = true
	
	self.category = 2
	self.mask = {true}
	self.gravity = 0
	self.portalable = false
	
	if solid then
		if self.color == "p" then
			self.quadon = spikeyquad[1]
			self.quadoff = spikeyquad[2]
		else
			self.quadon = flipblockquad[self.color][1]
			self.quadoff = flipblockquad[self.color][2]
		end
		self.quad = self.quadon
	else
		if self.color == "p" then
			self.quadon = spikeyquad[3]
			self.quadoff = spikeyquad[4]
		else
			self.quadon = flipblockquad[self.color][3]
			self.quadoff = flipblockquad[self.color][4]
		end
		self.quad = self.quadoff
		self:change()
	end
	
	if solidblockperma[self.color] then
		self:change()
	end
	
	self.autodelete = false
	
	--IMAGE STUFF
	self.drawable = false
	if self.color == "p" then
		self.graphic = pblockimg
	else
		self.graphic = buttonblockimage
	end
	self.offsetX = 8
	self.offsetY = 0
	self.quadcenterX = 8
	self.quadcenterY = 8
end

function buttonblock:draw()
	--love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.graphic, self.quad, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), 0, scale, scale, self.quadcenterX, self.quadcenterY)
end

function buttonblock:change()
	self.solid = not self.solid
	if not self.solid then
		self.quad = self.quadoff
		self.active = false
	else
		self.quad = self.quadon
		self.active = true
	end
end

function buttonblock:leftcollide(a, b)
	
end

function buttonblock:rightcollide(a, b)
	 
end

function buttonblock:ceilcollide(a, b)

end

function buttonblock:globalcollide(a, b)

end

function buttonblock:floorcollide(a, b)
	
end
