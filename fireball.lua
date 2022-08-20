fireball = class:new()

function fireball:init(x, y, dir, v, t)
	--PHYSICS STUFF
	self.y = y+4/16
	self.speedy = 0
	if dir == "right" then
		self.speedx = fireballspeed
		self.x = x+6/16
	else
		self.speedx = -fireballspeed
		self.x = x
	end
	self.width = 8/16
	self.height = 8/16
	self.active = true
	self.static = false
	self.category = 13
	
	self.mask = {	true,
					false, true, false, false, true,
					false, true, false, true, false,
					false, true, false, true, false,
					true, true, false, false, false,
					false, true, false, false, true,
					false, false, false, false, true,
					false, true}
					
	self.destroy = false
	self.destroysoon = false
	self.t = t or "fireball"
	--self.gravity = 40
	self.releasespeedx = fireballspeed
	
	--IMAGE STUFF
	self.drawable = true
	if self.t == "superball" then
		self.graphic = superballimg
		self.quad = superballquad[1]
		self.offsetX = 4
		self.offsetY = 4
		self.quadcenterX = 6
		self.quadcenterY = 6

		self.gravity = 0

		if dir == "right" then
			self.speedx = superballspeed
		else
			self.speedx = -superballspeed
		end
		self.speedy = superballspeed
		self.lifetime = 5
		self.light = 2
	elseif self.t == "iceball" then
		self.graphic = iceballimg
		self.quad = fireballquad[1]
		self.offsetX = 4
		self.offsetY = 4
		self.quadcenterX = 4
		self.quadcenterY = 4
		self.hp = 2

		if dir == "right" then
			self.speedx = iceballspeed+(v.speedx*.5)
		else
			self.speedx = -iceballspeed+(v.speedx*.5)
		end
		self.gravity = 30
	else
		self.graphic = fireballimg
		self.quad = fireballquad[1]
		self.offsetX = 4
		self.offsetY = 4
		self.quadcenterX = 4
		self.quadcenterY = 4
		self.light = 2
		
		self.lifetime = 10
	end
	
	self.fireballthrower = v
	
	self.rotation = 0 --for portals
	self.timer = 0
	self.quadi = 1
end

function fireball:update(dt)
	--rotate back to 0 (portals)
	self.rotation = 0
	
	--animate
	self.timer = self.timer + dt
	if self.t == "superball" then
		--collect coins
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
	elseif self.destroysoon == false then
		while self.timer > staranimationdelay do
			self.quadi = self.quadi + 1
			if self.quadi == 5 then
				self.quadi = 1
			end
			self.quad = fireballquad[self.quadi]
			self.timer = self.timer - staranimationdelay
		end
	else
		while self.timer > staranimationdelay do
			self.quadi = self.quadi + 1
			if self.quadi == 8 then
				self.destroy = true
				self.quadi = 7
			end
			
			self.quad = fireballquad[self.quadi]
			self.timer = self.timer - staranimationdelay
		end
	end
	
	if edgewrapping then --wrap around screen
		local minx, maxx = -self.width, mapwidth
		if self.x < minx then
			self.x = maxx
		elseif self.x > maxx then
			self.x = minx
		end
	end

	if self.lifetime then
		self.lifetime = self.lifetime - dt
	end
	
	if ((self.lifetime and self.lifetime < 0) or self.x < xscroll-1 or self.x > xscroll+width+1 or self.y > mapheight) and self.active then
		if self.fireballthrower then
			self.fireballthrower:fireballcallback()
		end
		self.destroy = true
	end
	
	if self.destroy then
		return true
	else
		return false
	end
end

function fireball:leftcollide(a, b)
	if a == "pixeltile" and b.dir == "right" then
		self.y = self.y - b.step
		self:floorcollide("tile", b)
		return false
	end
	
	if a == "donut" or a == "plantfire" then
		return false
	end

	--if self.t == "fireball" then
		--self.x = self.x-.5 --? Remove maybe
	--end
	self:hitstuff(a, b, "left")
	
	if self.t == "superball" then
		self.speedx = math.abs(self.speedx)
	elseif self.t == "iceball" then
		self:hitstuff(a, b, "left")
	else
		self.speedx = fireballspeed
	end

	return false
end

function fireball:rightcollide(a, b)
	if a == "pixeltile" and b.dir == "left" then
		self.y = self.y - b.step
		self:floorcollide("tile", b)
		return false
	end
	
	if a == "donut" or a == "plantfire" then
		return false
	end

	self:hitstuff(a, b, "right")
	
	if self.t == "superball" then
		self.speedx = -math.abs(self.speedx)
	elseif self.t == "iceball" then
		self:hitstuff(a, b, "right")
	else
		self.speedx = -fireballspeed
	end
	
	return false
end

function fireball:floorcollide(a, b)
	if self.t == "iceball" and a == "tile" then
		self.hp = self.hp - 1
		if self.hp <= 0 then
			self:explode()
			playsound(iciclesound)
			return false
		end
	end

	if a ~= "tile" and a ~= "portalwall" and a ~= "flipblock" and a ~= "buttonblock" and a ~= "snakeblock" or a == "frozencoin" then
		self:hitstuff(a, b, "floor")
	end

	if self.t == "superball" then
		self.speedy = -math.abs(self.speedy)
	elseif self.t == "iceball" then
		self.speedy = -iceballjumpforce
	else
		self.speedy = -fireballjumpforce
	end
	return false
end

function fireball:ceilcollide(a, b)
	if a == "donut" then
		return false
	end

	self:hitstuff(a, b, "ceil")

	if self.t == "superball" then
		self.speedy = math.abs(self.speedy)
		if a == "flipblock" then
			b:hit()
		end
	end
end

function fireball:passivecollide(a, b)
	if self.t == "superball" then
		if a == "tile" then
			if self.x+self.width/2 > b.x+b.width/2 then
				self.speedx = math.abs(self.speedx)
			else
				self.speedx = -math.abs(self.speedx)
			end
			return true
		end
	end
	if a ~= "clearpipesegment" and a ~= "plantfire" then
		self:ceilcollide(a, b)
	end
	return false
end

function fireball:hitstuff(a, b, truedir)
	local dir = "right"
	if self.x+self.width/2 > b.x+b.width/2 then
		dir = "left"
	end
	if self.t == "iceball" then
		if a == "tile" or a == "portalwall" or a == "spring" or a == "kingbill" or a == "angrysun" or a == "springgreen" or a == "thwomp" or a == "fishbone" or a == "muncher" or (a == "bigkoopa" and b.t == "bigbeetle") or a == "meteor" or a == "parabeetle" or a == "boo" or a == "torpedoted" then
			playsound(iciclesound)
		elseif iceballfreeze[a] then
			if b.freezable and (not b.frozen) and (not b.resistseverything) then
				self:explode()
				table.insert(objects["ice"], ice:new(b.x+b.width/2, b.y+b.height, b.width, b.height, a, b))
			end
		end
		if not (a == "clearpipesegment" and (b.entrance or b.exit)) then
			self:explode()
		end
		return
	end
	if self.t == "fireball" and (a == "tile" or a == "bulletbill" or a == "portalwall" or a == "spring" or a == "bigbill" or a == "kingbill" or a == "barrel" or a == "angrysun" or a == "springgreen" or a == "thwomp" or a == "fishbone" or a == "drybones" or a == "muncher" or (a == "bigkoopa" and b.t == "bigbeetle") or a == "meteor" or (a == "goomba" and (b.t == "drygoomba" or b.t == "spiketop")) or (a == "downplant" and b.t == "dryplant") or a == "parabeetle" or a == "boo" or a == "torpedoted" or (a == "plant" and b.t == "dryplant") or a == "chainchomp" or a == "buttonblock" or a == "flipblock" or a == "frozencoin" or a == "snakeblock" or a == "spikeball") then
		self:explode()
		playsound(blockhitsound)
		
	elseif a == "enemy" then
		if b.reflectsfireballs then
			if truedir == "left" or truedir == "right" then
				self.speedx = -self.speedx
			end
		else
			if b:shotted(dir, false, false, true) ~= false then
				addpoints(b.firepoints or 200, self.x, self.y)
			end
			self:explode()
		end
	
	elseif (a == "koopa" and (b.t == "beetle" or b.t == "beetleshell" or b.t == "bigbeetle" or b.t == "downbeetle")) or a == "spikeball" or a == "amp" then
		self:explode()

	elseif fireballkill[a] then
		local shot = b:shotted(dir)
		if a ~= "bowser" and (a ~= "koopaling" or shot) then
			addpoints(firepoints[a] or 200, self.x, self.y)
		end
		self:explode()
	
	elseif a == "bomb" then
		if not b.explosion then
			local dir = "right"
			if self.x > b.x then
				dir = "left"
			end
			b:shotted2(dir)
			self:explode()
		else
			self:explode()
		end
	elseif a == "boomboom" then
		if not b.ducking then
			b:shotted("right")
			self:explode()
		else
			self:explode()
		end
	end
end

function fireball:explode()
	if self.active then
		if self.fireballthrower then
			self.fireballthrower:fireballcallback()
		end
		
		if self.t == "superball" then
			self.destroy = true
			self.active = false
			makepoof(self.x+self.width/2, self.y+self.height/2, "makerpoof")
		else
			self.destroysoon = true
			self.quadi = 5
			self.quad = fireballquad[self.quadi]
			self.active = false

			self.quadcenterX = 8
			self.quadcenterY = 8
		end
	end
end
