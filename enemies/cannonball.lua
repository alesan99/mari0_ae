cannonballcannon = class:new()

function cannonballcannon:init(x, y, r)
	--PHYSICS STUFF
	self.x = x-1
	self.y = y-1
	self.speedy = 0
	self.speedx = 0
	self.width = 1
	self.height = 1
	self.static = false
	self.active = true
	self.category = 2

	self:randomtime()
	self.timer = self.time-0.5

	--rightclick things
	local v = convertr(r, {"string", "num", "string"})
	self.dir = v[1]
	self.speed = v[2]
	self.base = v[3]
	
	self.mask = {	true, 
					false, false, false, false, false,
					false, true, false, true, false,
					false, false, true, false, false,
					true, true, false, false, false,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	
	self.autodelete = true
	self.drawable = false

	if self.base == "down" then
		self.supersizeoffsetx = .5
	elseif self.base == "up" then
		self.supersizedown = true
		self.supersizeoffsetx = .5
		self.static = true
	elseif self.base == "left" then
		self.supersizedown = true
		self.supersizeoffsetx = .5
		self.static = true
	elseif self.base == "right" then
		self.supersizedown = true
		self.supersizeoffsetx = -.5
		self.static = true
	end
	
	self.rotation = 0 --for portals
	self.trackplatform = true
	self.trackplatformpush = true
	self.movealongtrackblock = true
	self.pipespawnmax = 1
end

function cannonballcannon:update(dt)
	--rotate back to 0 (portals)
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
		self.speedx = self.speedx - friction*dt
		if self.speedx < 0 then
			self.speedx = 0
		end
	else
		self.speedx = self.speedx + friction*dt
		if self.speedx > 0 then
			self.speedx = 0
		end
	end

	self.timer = self.timer + dt
	if self.timer > self.time and onscreen(self.x-3, self.y-3, self.width+6, self.height+6) then
		if self:fire() then
			self.timer = 0
			self:randomtime()
		end
	end
end

function cannonballcannon:draw()
	local i = 0
	if self.speed > cannonballspeed then
		i = 2
	end
	if self.customscissor then
		love.graphics.setScissor(math.floor((self.customscissor[1]-xscroll)*16*scale), math.floor((self.customscissor[2]-.5-yscroll)*16*scale), self.customscissor[3]*16*scale, self.customscissor[4]*16*scale)
	end
	local r = 0
	if self.dir == "left" then
		r = math.pi*1.5
	elseif self.dir == "left up" then
		r = math.pi*1.75
	elseif self.dir == "right up" then
		r = math.pi*.25
	elseif self.dir == "right" then
		r = math.pi*.5
	elseif self.dir == "right down" then
		r = math.pi*.75
	elseif self.dir == "down" then
		r = math.pi
	elseif self.dir == "left down" then
		r = math.pi*1.25
	end
	local sx, sy = 1, 1
	local ox, oy = 0, 0
	if self.supersized then
		sx, sy = self.animationscalex, self.animationscaley
		ox, oy = 8/16, 8/16
	end
	love.graphics.draw(cannonballcannonimg, flipblockquad[spriteset][1+i], math.floor((self.x+.5+ox-xscroll)*16*scale), ((self.y+.5+oy-yscroll)*16-8)*scale, r, sx*scale, sy*scale, 8, 8)
	local r = 0
	if self.base == "right" then
		r = math.pi*1.5
	elseif self.base == "left" then
		r = math.pi*.5
	elseif self.base == "up" then
		r = math.pi
	end
	love.graphics.draw(cannonballcannonimg, flipblockquad[spriteset][2+i], math.floor((self.x+.5+ox-xscroll)*16*scale), ((self.y+.5+oy-yscroll)*16-8)*scale, r, sx*scale, sy*scale, 8, 8)
	love.graphics.setScissor()
end


function cannonballcannon:fire()
	if self.clearpipe then
		return false
	end
	local obj = cannonball:new(self.x+1, self.y+1, self.dir, self.speed, "cannonballcannon")
	if self.supersized then
		supersizeentity(obj)
		obj.x = self.x+self.width/2-obj.width/2
		obj.y = self.y+self.height/2-obj.height/2
	end
	table.insert(objects["cannonball"], obj)
	return true
end

function cannonballcannon:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return true
end

function cannonballcannon:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return true
end

function cannonballcannon:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return true
end

function cannonballcannon:globalcollide(a, b)

end

function cannonballcannon:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return true
end

function cannonballcannon:passivecollide(a, b)
	return false
end

function cannonballcannon:randomtime()
	local rand = math.random(bulletbilltimemin*10, bulletbilltimemax*10)/10
	self.time = rand
end
----------------------
cannonballlauncher = class:new()

function cannonballlauncher:init(x, y, vars)
	self.x = x
	self.y = y
	self.id = id
	self:randomtime()
	self.timer = self.time-0.5
	self.autodelete = true
	local vars = vars:split("|")
	self.dir = vars[1] or 1
	self.speed = cannonballspeed
	if #vars >= 2 then
		self.speed = tonumber(vars[2])
	end
end

function cannonballlauncher:update(dt)
	self.timer = self.timer + dt
	if self.timer > self.time and self.x > splitxscroll[1] and self.x < splitxscroll[1]+width+2 then
		if self:fire() then
			self.timer = 0
			self:randomtime()
		end
	end
end

function cannonballlauncher:fire()
	table.insert(objects["cannonball"], cannonball:new(self.x, self.y, self.dir, self.speed))
	return true
end

function cannonballlauncher:randomtime()
	local rand = math.random(bulletbilltimemin*10, bulletbilltimemax*10)/10
	self.time = rand
end

----------------------
cannonball = class:new()
function cannonball:init(x, y, dir, speed, origin)
	self.startx = x-14/16
	--PHYSICS STUFF
	self.x = self.startx
	self.y = y-14/16
	local speed = speed or cannonballspeed
	self.speed = speed
	if dir == "left" then
		self.speedy = 0
		self.speedx = -speed
	elseif dir == "right" then
		self.speedy = 0
		self.speedx = speed
	elseif dir == "down" then
		self.speedx = 0
		self.speedy = speed
	elseif dir == "up" then
		self.speedx = 0
		self.speedy = -speed
	elseif dir == "right up" then
		self.speedy = -speed*.707
		self.speedx = speed*.707
	elseif dir == "left up" then
		self.speedy = -speed*.707
		self.speedx = -speed*.707
	elseif dir == "right down" then
		self.speedy = speed*.707
		self.speedx = speed*.707
	elseif dir == "left down" then
		self.speedy = speed*.707
		self.speedx = -speed*.707
	end
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.gravity = 0
	self.rotation = 0
	self.autodelete = true
	self.timer = 0
	
	--IMAGE STUFF
	self.drawable = true
	self.quad = cannonballquad[spriteset][1]
	if speed > cannonballspeed then
		self.quad = cannonballquad[spriteset][2]
		playsound(cannonfastsound)
	else
		playsound(bulletbillsound)
	end
	self.offsetX = 6
	self.offsetY = 2
	self.quadcenterX = 6
	self.quadcenterY = 6
	self.graphic = cannonballimg
	
	self.category = 11
	self.animationdirection = dir
	
	self.mask = {	true, 
					true, false, false, false, true,
					true, true, true, true, true,
					true, false, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					false, true}
					
	self.shot = false
	self.lifetime = 10

	self.kills = true
	if origin and origin == "mario" then
		self.player = true
		self.kills = false
		self.mask[2] = false
		self.killstuff = true
		self.lifetime = 4
		self.resistsstar = true
	end
	if (not origin) or origin ~= "cannonballcannon" then
		makepoof(self.x+self.width/2, self.y+self.height/2, "powpoof")
	end
end

function cannonball:update(dt)
	if self.delete then
		return true
	end
	--collect coins
	if self.player then
		local x = math.floor(self.x+self.width/2)+1
		local y = math.floor(self.y+self.height/2)+1
		if inmap(x, y) then
			if tilequads[map[x][y][1]].coin then
				collectcoin(x, y)
			elseif objects["coin"][tilemap(x, y)] and not objects["coin"][tilemap(x, y)].frozen then
				collectcoin2(x, y)
			elseif objects["collectable"][tilemap(x, y)] then
				getcollectable(x, y)
			end
		end
	end
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
	else
		self.timer = self.timer + dt
		if self.timer >= self.lifetime then
			return true
		end
	end
end

function cannonball:stomp(dir) --fireball, star, turtle
	self.shot = true
	self.speedy = 0
	self.direction = dir or "right"
	self.active = false
	self.gravity = shotgravity
	if self.direction == "left" then
		self.speedx = -shotspeedx
	else
		self.speedx = shotspeedx
	end
end

function cannonball:shotted(dir)
	self:stomp(dir)
end

function cannonball:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return true
end

function cannonball:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return true
end

function cannonball:ceilcollide(a, b)
	if a == "player" or a == "box" then
		self:stomp()
		return false
	end
	if self:globalcollide(a, b) then
		return false
	end
	return true
end

function cannonball:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return true
end

function cannonball:globalcollide(a, b)
	if a == "tile" then
		local x, y = b.cox, b.coy
		if self.speed > cannonballspeed then
			local r = map[x][y]
			if tilequads[r[1]].breakable then
				hitblock(x, y, {size=2})
			elseif tilequads[map[x][y][1]].coinblock or (tilequads[map[x][y][1]].debris and blockdebrisquads[tilequads[map[x][y][1]].debris]) then -- hard block
				destroyblock(x, y)
			end
		else
			hitblock(x, y, {size=2}, {sound = onscreen(x,y)})
		end
		self.delete = true
		makepoof(self.x+self.width/2, self.y+self.height/2, "makerpoof")
		return true
	elseif self.killstuff then
		if fireballkill[a] and (not (b.resistsenemykill or b.resistseverything)) then
			b:shotted("left")
			return true
		end
		return true
	else
		return true
	end
end

function cannonball:portaled()
	self.killstuff = true
end