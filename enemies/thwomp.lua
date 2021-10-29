thwomp = class:new()

local closerange = 1 --distance before thwomp smashes, this is the frame where the thwomp is smug

function thwomp:init(x, y, t, r)
	--PHYSICS STUFF
	self.x = x-1
	self.y = y-1
	self.speedy = 0
	self.speedx = 0
	self.width = 22/16
	self.height = 30/16
	self.gravity = 0
	self.static = false
	self.active = true
	self.category = 4
	self.portalable = true
	self.killstuff = true
	self.t = t or "down"
	
	self.mask = {	true, 
					false, false, false, false, true,
					false, true, false, true, false,
					false, false, true, false, false,
					true, true, false, false, false,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	
	self.autodelete = true
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = thwompimage
	self.quad = thwompquad[spriteset][2]
	self.offsetX = 11
	self.offsetY = -7
	self.quadcenterX = 12
	self.quadcenterY = 16
	
	self.rotation = 0 --for portals
	
	self.shot = false
	
	self.attack = false
	self.hitground = false
	self.hitgroundtimer = 0
	self.waittimer = 0 --time it takes to attack again

	--self.returntilemaskontrackrelease = true
	if self.t == "thwimp" then
		self.x = x-15/16
		self.y = y-14/16
		self.width = 14/16
		self.height = 14/16
		
		self.graphic = thwimpimg
		self.quad = thwimpquad[spriteset]
		self.offsetX = 7
		self.offsetY = 2
		self.quadcenterX = 8
		self.quadcenterY = 8
		
		self.timer = 0
		self.attackdir = "left"
		
		self.portalable = true
		self.gravity = false
	else
		--origin
		self.ox = self.x
		self.oy = self.y
		self.returntoorigin = false
		self.r = r
		
		local v = convertr(r, {"bool"}, true)
		if v[1] then
			self.returntoorigin = true
		end

		self.supersizeoffsetx = 1
		if self.t == "left" then
		elseif self.t == "right" then
			self.animationdirection = "left"
			self.supersizeoffsetx = -1
		end
		self.trackplatform = true
	end

	self.supersizedown = true
end

function thwomp:update(dt)
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		return false
	elseif self.t == "thwimp" then
		if self.attack then
			
		else
			self.timer = self.timer + dt
			if self.timer > 1 then
				if self.attackdir == "right" then
					self.attackdir = "left"
					self.speedx = -6.3
					self.speedy = -32
				else
					self.attackdir = "right"
					self.speedx = 6.3
					self.speedy = -32
				end
				self.attack = true
				self.timer = 0
			end
		end
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
	else
		if self.t == "left" or self.t == "right" then
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
		if not self.attack then
			self.waittimer = self.waittimer - dt

			--reset sprite to calm
			self.quad = thwompquad[spriteset][2]

			local attackrange = 3
			if self.t == "left" or self.t == "right" then
				attackrange = 1.7
			end

			for i = 1, players do
				local v = objects["player"][i]
				if ((self.t == "down" and inrange(v.x+v.width/2, self.x+self.width/2-attackrange-closerange, self.x+self.width/2+attackrange+closerange) and v.y > self.y)
				or (self.t == "left" and self.x-xscroll < width and (inrange(v.y, self.y+self.height/2-attackrange-closerange, self.y+self.height/2+attackrange+closerange) or inrange(v.y+v.height, self.y+self.height/2-attackrange-closerange, self.y+self.height/2+attackrange+closerange)) and v.x < self.x)
				or (self.t == "right" and self.x+self.width-xscroll > 0 and (inrange(v.y, self.y+self.height/2-attackrange-closerange, self.y+self.height/2+attackrange+closerange) or inrange(v.y+v.height, self.y+self.height/2-attackrange-closerange, self.y+self.height/2+attackrange+closerange)) and v.x > self.x)) then
					local dist = math.abs((v.x+v.width/2)-(self.x+self.width/2))
					if self.t == "left" or self.t == "right" then
						if (self.y+self.height/2) < (v.y+v.height/2) then--from below
							dist = math.abs(v.y-(self.y+self.height/2))
						else --from above
							dist = math.abs((v.y+v.height)-(self.y+self.height/2))
						end
					end
					if dist < attackrange and self.waittimer <= 0 then --attack
						self.attack = true
						self.hitground = false
						self.speedx = 0
						self.speedy = 0
						if self.t == "left" or self.t == "right" then
							self.quad = thwompquad[spriteset][5]
						else
							self.quad = thwompquad[spriteset][1]
						end
						self.waittimer = 0.5
						self.trackable = false
						return
					else --look
						if self.t == "left" or self.t == "right" then
							self.quad = thwompquad[spriteset][4]
						else
							self.quad = thwompquad[spriteset][3]
						end
						break
					end
				end
			end
		elseif self.attack then
			if self.hitgroundtimer > 0 then
				self.hitgroundtimer = self.hitgroundtimer - dt
				if self.hitgroundtimer < 0 then
					self.hitgroundtimer = 0
					if self.t == "left" then
						self.speedx = thwompreturnspeed
					elseif self.t == "right" then
						self.speedx = -thwompreturnspeed
					else
						self.speedy = -thwompreturnspeed
					end
					self.quad = thwompquad[spriteset][2]
					return
				elseif self.hitgroundtimer < thwompwait/2 then
					self.quad = thwompquad[spriteset][2]
				end
			elseif self.hitground then
				--returning
				if self.t == "left" then
					self.speedx = thwompreturnspeed
				elseif self.t == "right" then
					self.speedx = -thwompreturnspeed
				else
					self.speedy = -thwompreturnspeed
				end
				--return to origin
				if self.returntoorigin then
					if self.t == "left" then
						if self.x+self.speedx*dt >= self.ox then
							self:rest()
							self.x = self.ox
						end
					elseif self.t == "right" then
						if self.x+self.speedx*dt <= self.ox then
							self:rest()
							self.x = self.ox
						end
					else
						if self.y+self.speedy*dt <= self.oy then
							self:rest()
							self.y = self.oy
						end
					end
				end
			else
				if self.t == "left" then
					self.speedx = math.max(-thwompattackspeed, self.speedx-26*dt)
				elseif self.t == "right" then
					self.speedx = math.min(thwompattackspeed, self.speedx+26*dt)
				else
					self.speedy = math.min(thwompattackspeed, self.speedy+26*dt)
				end
			end
		end
		
		if self.t == "down" and (not self.track) then
			if self.speedx > 0 or self.speedx < 0 then
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
				if self.speedx > 0 then
					self.speedx = self.speedx - 40*dt
					if self.speedx < 0 then
						self.speedx = 0
						self.rotation = 0
					end
				else
					self.speedx = self.speedx + 40*dt
					if self.speedx > 0 then
						self.speedx = 0
						self.rotation = 0
					end
				end
			end
			return false
		end
	end
end

function thwomp:shotted(dir) --fireball, star, turtle
	--playsound(blockhitsound)
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
end

function thwomp:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if self.t == "left" and self.attack then
		return self:hit(a, b)
	elseif self.t == "right" and self.hitground then
		self:rest()
		return true
	end
	if a == "player" then
		return false
	end
	return true
end

function thwomp:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if self.t == "right" and self.attack then
		return self:hit(a, b)
	elseif self.t == "left" and self.hitground then
		self:rest()
		return true
	end
	if a == "player" then
		return false
	end
	return true
end

function thwomp:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if self.t == "thwimp" then
		self.speedy = 0
		return true
	end
	if self.t == "down" and self.hitground and (a ~= "player") then
		self:rest()
		return true
	end
	return true
end

function thwomp:globalcollide(a, b)
	if a == "tracksegment" or a == "player" then
		return true
	end
end

function thwomp:rest() --returning
	if self.t == "left" or self.t == "right" then
		self.speedx = 0
	else
		self.speedy = 0
	end
	self.quad = thwompquad[spriteset][2]
	self.attack = false
	self.hitground = false
end

function thwomp:pound() --hit something!
	if self.hitground then
		return
	end
	if self.supersized then
		playsound(thwompbigsound)
	else
		playsound(thwompsound)
	end
	if self.t == "down" then
		self.speedy = 0
	else
		self.speedx = 0
	end
	self.hitground = true
	self.hitgroundtimer = thwompwait
	self.quad = thwompquad[spriteset][1]
end

function thwomp:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if self.t == "down" and self.attack then
		return self:hit(a, b)
	end
	if self.t == "thwimp" then
		self.attack = false
		self.speedx = 0
		self.speedy = 0
		if b.width == 1 then
			local dif = self.x-math.floor(self.x)
			if dif > .5 then
				self.x = math.ceil(self.x)+1/16
			else
				self.x = math.floor(self.x)+1/16
			end
		end
		return true
	end
	if self.t == "left" or self.t == "right" then
		return true
	end
	return false
end

function thwomp:hit(a, b)
	if a == "tile" then
		local pounded = false
		--im the dollar menu guy, i'd hit that.. block
		local x1, x2, y1, y2 = math.ceil(self.x), math.ceil(self.x+self.width), math.ceil(self.y+.5), math.ceil(self.y+self.height+.5)
		if self.t == "left" then
			x1, x2, y1, y2 = math.ceil(self.x-.5), math.ceil(self.x+self.width-.5), math.ceil(self.y+.1), math.ceil(self.y+self.height-.1)
		elseif self.t == "right" then
			x1, x2, y1, y2 = math.ceil(self.x+.5), math.ceil(self.x+self.width+.5), math.ceil(self.y+.1), math.ceil(self.y+self.height-.1)
		end
		for x = x1, x2 do
			for y = y1, y2 do
				local inmap = true
				if x < 1 or x > mapwidth or y < 1 or y > mapheight then
					inmap = false
				end
				if inmap then
					local r = map[x][y]
					if r then
						if self.supersized and (tilequads[r[1]].debris and blockdebrisquads[tilequads[r[1]].debris]) then
							destroyblock(x, y)
						elseif tilequads[r[1]].breakable or tilequads[map[x][y][1]].coinblock then
							hitblock(x, y, {size=2})
						elseif tilequads[r[1]].collision then
							pounded = true
						end
						if not self.supersized then
							pounded = true
						end
					end
				end
			end
		end
		if pounded then
			self:pound()
		end
		return true
	elseif a == "blocktogglebutton" then
		return true
	elseif a == "donut" or a == "flipblock" then
		local x, y = b.cox, b.coy
		--search for blocks under
		for j, w in pairs(objects[a]) do
			if (not w.tracked) and (not w.falling) and self.x <= w.x+w.width and w.x <= self.x+self.width then
				if w ~= b then
					w:ceilcollide("thwomp", self)
				end
			end
		end
		self:pound()
		return true
	elseif a == "thwomp" or a == "snakeblock" or a == "buttonblock" or a == "belt" or a == "frozencoin" or (a == "enemy" and b.stopsthwomps) then
		self:pound()
		return true
	end
	if a ~= "thwomp" then
		if mariohammerkill[a] then
			b:shotted("left")
			return false
		elseif a == "enemy" then
			if b:shotted("right", nil, nil, false, true) ~= false and (not b.resistsenemykill) and (not b.resistshammer) then
				addpoints(b.firepoints or 200, self.x, self.y)
			else
				return false
			end
		end
	end
	return false
end

function thwomp:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end

function thwomp:dotrack()
	self.track = true
end

function thwomp:dosupersize()
	self.ox = self.x
	self.oy = self.y
end