hammerbro = class:new()
local throwgroups = {1, 3}

function hammerbro:init(x, y, t)
	--PHYSICS STUFF
	self.startx = x
	self.starty = y
	self.x = x-6/16
	self.y = y-12/16
	self.speedy = 0
	self.speedx = -hammerbrospeed
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.category = 20
	self.mask = {true, false, false, false, false, true, false, false, false, true}
	self.autodelete = true
	self.gravity = 40
	self.freezable = true
	self.frozen = false
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = hammerbrosimg
	self.quad = hammerbrosquad[spriteset][1]
	self.q = hammerbrosquad
	self.offsetX = 6
	self.offsetY = 8
	self.quadcenterX = 8
	self.quadcenterY = 21
	
	self.t = t or "hammer"
	if t == "fire" then
		self.graphic = firebrosimg
	elseif t == "boomerang" then
		self.graphic = boomerangbrosimg
	elseif t == "ice" then
		self.graphic = icebrosimg
	elseif t == "big" then
		self.graphic = bighammerbrosimg
		self.quad = bighammerbrosquad[spriteset][1]
		self.q = bighammerbrosquad
		self.offsetX = 10
		self.offsetY = -1
		self.quadcenterX = 12
		self.quadcenterY = 23
		self.width = 20/16
		self.height = 24/16
		self.x = x-10/16
		self.y = y-24/16
	end
	
	self.rotation = 0 --for portals
	
	self.direction = "left"
	self.animationtimer = 0
	self.animationdirection = "left"
	
	self.falling = false
	
	self.quadi = 1
	self.timer = 0.5
	self.timer2 = 0
	self.queue = 1
	
	self.jumping = false
	self.jump = false --is it jumping?
	if self.t == "big" then
		self.jumptime = hammerbrojumptime*1.5
	else
		self.jumptime = hammerbrojumptime
	end
	
	self.shot = false
	
	if marioworld >= 7 then
		self.chasetimer = 0
		self.chasetime = 44
		self.chasepersist = false
		if smb2jphysics then
			self.chasetime = 0
			--self.chasepersist = true
		end
	end

	self.dontenterclearpipes = true
	self.movetotoponpassivecollide = true
end

function hammerbro:update(dt)
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
	
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		--check if goomba offscreen
		if self.y > mapheight+3 then
			return true
		else
			return false
		end
		
	else
		if not self.frozen then
			if not self.track then
				if self.speedx < 0 then
					if self.x < self.startx-16/16 then
						self.speedx = hammerbrospeed
					end
				else
					if self.x > self.startx then
						self.speedx = -hammerbrospeed
					end
				end
			end
				
			self.timer = self.timer - dt
			if self.timer <= 0 then
				self:throwhammer(self.direction)
				if self.t == "boomerang" then
					self.timer = math.random(3, 4)
				else
					self.queue = self.queue - 1
					if self.queue == 0 then
						self.queue = throwgroups[math.random(2)]
						self.timer = 2
					else
						self.timer = 0.6
					end
				end
			end
				
			if not self.track then
				self.timer2 = self.timer2 + dt
				if self.timer2 > self.jumptime then
					self.timer2 = self.timer2 - self.jumptime
					--decide whether up or down
					local dir
					if (self.t ~= "big" and self.y > mapheight-4) or (self.t == "big" and self.y > mapheight-5) --[[12]] then
						dir = "up"
					elseif self.y < 6 then
						dir = "down"
					else
						if math.random(2) == 1 then
							dir = "up"
						else
							dir = "down"
						end
					end
					
					if dir == "up" then
						self.speedy = -hammerbrojumpforce
						self.mask[2] = true
						self.jumping = "up"
					else
						self.speedy = -hammerbrojumpforcedown
						self.mask[2] = true
						self.jumping = "down"
						self.jumpingy = self.y
					end
					if self.t == "big" then
						self.jump = true
					end
				end
				
				if self.jumping then
					if self.jumping == "up" then
						if self.speedy > 0 then
							self.jumping = false
							self.mask[2] = false
						end
					elseif self.jumping == "down" then
						if self.t == "big" then
							if self.y > self.jumpingy + 2.5 then
								self.jumping = false
								self.mask[2] = false
							end
						else
							if self.y > self.jumpingy + 2 then
								self.jumping = false
								self.mask[2] = false
							end
						end
					end
				end
			end
		
			--turn around?
			--find nearest player
			local closestplayer = 1
			for i = 2, players do
				local v = objects["player"][i]
				if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
					closestplayer = i
				end
			end
			
			if self.direction == "left" and objects["player"][closestplayer].x > self.x then
				self.direction = "right"
				self.animationdirection = "right"
			elseif self.direction == "right" and objects["player"][closestplayer].x < self.x then
				self.direction = "left"
				self.animationdirection = "left"
			end
		
			self.animationtimer = self.animationtimer + dt
			while self.animationtimer > hammerbroanimationspeed do
				self.animationtimer = self.animationtimer - hammerbroanimationspeed
				self.quadi = self.quadi + 1
				if self.quadi == 3 then
					self.quadi = 1
				end
				if self.timer < hammerbropreparetime then
					self.quad = self.q[spriteset][self.quadi+2]
				else
					self.quad = self.q[spriteset][self.quadi]
				end
			end
			
			if self.speedx > hammerbrospeed then
				self.speedx = self.speedx - friction*dt
				if self.speedx < hammerbrospeed then
					self.speedx = hammerbrospeed
				end
			elseif self.speedx < -hammerbrospeed then
				self.speedx = self.speedx + friction*dt
				if self.speedx > hammerbrospeed then
					self.speedx = -hammerbrospeed
				end
			end
			
			if self.chasetime then
				if self.chasetimer > self.chasetime then
					local closestplayer = 1
					local closestdist = math.sqrt((objects["player"][1].x-self.x)^2+(objects["player"][1].y-self.y)^2)
					for i = 2, players do
						local v = objects["player"][i]
						local dist = math.sqrt((v.x-self.x)^2+(v.y-self.y)^2)
						if dist < closestdist then
							closestdist = dist
							closestplayer = i
						end
					end
					
					if objects["player"][closestplayer].x + objects["player"][closestplayer].width/2 < self.x + self.width/2 then
						self.speedx = -hammerbroschasespeed
						self.wasleft = true
					elseif self.wasleft then
						self.wasleft = nil
						if self.chasepersist then
							self.speedx = hammerbroschasespeed
						else
							self.chasetimer = 0
							self.startx = self.x
						end
					end
				else
					self.chasetimer = self.chasetimer + dt
				end
			end
		end
		
		return false
	end
end

function hammerbro:throwhammer(dir)
	if self.t == "fire" then
		--wait this is fire not hammer are you crazy
		table.insert(objects["brofireball"], brofireball:new(self.x, self.y, dir))
		playsound(fireballsound)
	elseif self.t == "boomerang" then
		--are you out of you mind
		table.insert(objects["boomerang"], boomerang:new(self.x, self.y, dir))
		playsound(boomerangsound)
	elseif self.t == "ice" then
		--this is mental
		table.insert(objects["brofireball"], brofireball:new(self.x, self.y, dir, "ice"))
		playsound(fireballsound)
	else
		table.insert(objects["hammer"], hammer:new(self.x, self.y, dir))
	end
end

function hammerbro:stomp()--hehe hammerbro stomp
	self:shotted()
	self.speedy = 0
end

function hammerbro:shotted() --fireball, star, turtle
	playsound(shotsound)
	self.shot = true
	self.speedy = -shotjumpforce
	self.direction = dir or "right"
	self.active = false
	self.gravity = shotgravity
	self.speedx = 0
end

function hammerbro:freeze()
	self.frozen = true
end

function hammerbro:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.speedx = goombaspeed
	
	if a == "koopa" then
		if b.small and b.speedx ~= 0 then
			self:shotted("right")
		end
	elseif a == "bulletbill" then
		self:shotted("right")
	elseif a == "hammer" then
		if b.killstuff then
			self:shotted()
		else
			return false
		end
	elseif a == "brofireball" and b.killstuff then
		self:shotted()
	elseif a == "boomerang" and b.killstuff then
		self:shotted()
	end
	
	return false
end

function hammerbro:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.speedx = -goombaspeed
	
	if a == "koopa" then
		if b.small and b.speedx ~= 0 then
			self:shotted("left")
		end
	elseif a == "bulletbill" then
		self:shotted("left")
	elseif a == "hammer" then
		if b.killstuff then
			self:shotted()
		else
			return false
		end
	elseif a == "brofireball" and b.killstuff then
		self:shotted()
	elseif a == "boomerang" and b.killstuff then
		self:shotted()
	end
	
	return false
end

function hammerbro:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "player" or a == "box" then
		self:stomp()
	elseif a == "koopa" then
		if b.small and b.speedx ~= 0 then
			self:shotted("left")
		end
	elseif a == "bulletbill" then
		self:shotted("right")
	elseif a == "hammer" then
		if b.killstuff then
			self:shotted()
		else
			return false
		end
	elseif a == "brofireball" and b.killstuff then
		self:shotted()
	elseif a == "boomerang" and b.killstuff then
		self:shotted()
	end
end

function hammerbro:passivecollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "hammer" then
		if b.killstuff then
			self:shotted()
		else
			return false
		end
	elseif a == "tile" or a == "flipblock" or a == "frozencoin" or a == "clearpipesegment" then
		--move to top of tile
		return true
	end
end

function hammerbro:globalcollide(a, b)
	if a == "hammer" then
		if not b.killstuff then
			return true
		else
			self:shotted()
		end
	elseif a == "player" then
		return true
	end
end

function hammerbro:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "bulletbill" then
		self:shotted("right")
	elseif a == "hammer" then
		if b.killstuff then
			self:shotted()
		else
			return false
		end
	elseif a == "brofireball" and b.killstuff then
		self:shotted()
	elseif a == "boomerang" and b.killstuff then
		self:shotted()
	end
	
	if self.t == "big" and a == "tile" and self.jump and onscreen(self.x, self.y, self.width, self.height) then
		for i = 1, players do
			objects["player"][i]:groundshock()
		end
		earthquake = 4
		playsound(thwompsound)
	end
	self.jump = false
end

function hammerbro:emancipate(a)
	self:shotted()
end

function hammerbro:portaled()
	self.jumping = false
	self.mask[2] = false
end

function hammerbro:dotrack()
	self.track = true
end

--------------------------------------------------------
hammer = class:new()

function hammer:init(x, y, dir)
	--PHYSICS STUFF
	self.x = x
	self.y = y-16/16
	self.starty = self.y
	self.speedy = -hammerstarty
	self.speedx = -hammerspeed
	if dir == "right" then
		self.speedx = -self.speedx
	end
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.category = 14
	self.mask = {	true,
					true, false, false, false, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, false, true,
					true, true, true, true, true,
					true, true, true, true, true,
					false, true}
	self.emancipatecheck = true
	self.gravity = hammergravity
	self.autodelete = true
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = hammerimg
	self.quadi = 1
	self.quad = hammerquad[spriteset][1]
	self.offsetX = 6
	self.offsetY = 2
	self.quadcenterX = 8
	self.quadcenterY = 8

	self.freezable = true
	
	self.rotation = 0 --for portals
	self.animationdirection = dir
	self.timer = 0
end

function hammer:update(dt)
	if self.frozen then
		return false
	end

	self.timer = self.timer + dt
	while self.timer > hammeranimationspeed do
		self.quadi = self.quadi + 1
		if self.quadi == 5 then
			self.quadi = 1
		end
		self.quad = hammerquad[spriteset][self.quadi]
		self.timer = self.timer - hammeranimationspeed
	end
	
	if self.mask[20] and self.y > self.starty + 1 then
		self.mask[20] = false
	end
end

function hammer:leftcollide()
	return false
end

function hammer:rightcollide()
	return false
end

function hammer:floorcollide()
	return false
end

function hammer:ceilcollide()
	return false
end

function hammer:portaled()
	self.killstuff = true
end

function hammer:emancipate(a)
	return true
end

--------------------------------------------------------
brofireball = class:new()

function brofireball:init(x, y, dir,t)
	--PHYSICS STUFF
	self.y = y+4/16
	self.t = t or "fire"
	self.speedy = 0
	if self.t == "ice" then
		self.speedy = -fireballjumpforce
		self.gravity = 30
		if dir == "right" then
			self.speedx = iceballbrospeed
			self.x = x+6/16
		else
			self.speedx = -iceballbrospeed
			self.x = x
		end
	else
		if dir == "right" then
			self.speedx = fireballbrospeed
			self.x = x+6/16
		else
			self.speedx = -fireballbrospeed
			self.x = x
		end
	end
	self.width = 8/16
	self.height = 8/16
	self.active = true
	self.static = false
	self.category = 4
	
	self.mask = {	true,
					false, false, false, false, true,
					false, true, false, true, false,
					false, true, false, true, false,
					true, true, false, true, false,
					false, true, false, false, true,
					false, false, false, false, true,
					false, true}
	self.destroy = false
	self.destroysoon = false
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = fireballimg
	self.quad = fireballquad[1]
	if self.t == "ice" then
		self.graphic = iceballimg
	end
	self.offsetX = 4
	self.offsetY = 4
	self.quadcenterX = 4
	self.quadcenterY = 4
	
	self.rotation = 0 --for portals
	self.timer = 0
	self.quadi = 1
end

function brofireball:update(dt)
	--rotate back to 0 (portals)
	self.rotation = 0
	
	--animate
	self.timer = self.timer + dt
	if self.destroysoon == false then
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
	
	if self.destroy then
		return true
	else
		return false
	end
end

function brofireball:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.x = self.x-.5
	self:hitstuff(a, b)
	self:explode()
	
	return false
end

function brofireball:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self:hitstuff(a, b)
	self:explode()
	
	return false
end

function brofireball:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if self.t == "ice" and a == "tile" then
		self:explode()
		playsound(iciclesound)
		return false
	end
	
	if a ~= "tile" and a ~= "portalwall" then
		self:hitstuff(a, b)
	end
	self.speedy = -fireballjumpforce
	return false
end

function brofireball:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self:hitstuff(a, b)
end

function brofireball:globalcollide(a, b)
	if a == "brofireball" then
		return true
	end
end

function brofireball:passivecollide(a, b)
	self:ceilcollide(a, b)
	return false
end

function brofireball:hitstuff(a, b)
	if self.t == "ice" then
		if a == "tile" or a == "portalwall" or a == "spring" or a == "kingbill" or a == "angrysun" or a == "springgreen" or a == "thwomp" or a == "fishbone" or a == "muncher" or (a == "bigkoopa" and b.t == "bigbeetle") or a == "meteor" or a == "dryplant" or a == "drydownplant" or a == "parabeetle" or a == "boo" or a == "torpedoted" then
			playsound(iciclesound)
		elseif a == "player" then
			if (b.animationtimer == 0 or not (b.frozen or b.invincible)) and not (b.startimer < mariostarduration) then
				b:freeze()
			end
			self:explode()
		elseif iceballfreeze[a] then
			if b.freezable and (not b.frozen) then
				self:explode()
				table.insert(objects["ice"], ice:new(b.x+b.width/2, b.y+b.height, b.width, b.height, a, b))
			end
		end
		self:explode()
		return
	end
	
	if a == "tile" or a == "bulletbill" or a == "portalwall" or a == "spring" or a == "bigbill" or a == "kingbill" or a == "barrel" or a == "angrysun" or a == "springgreen" or a == "thwomp" or a == "fishbone" or a == "drybones" or a == "muncher" or (a == "bigkoopa" and b.t == "bigbeetle") or a == "meteor" or (a == "goomba" and b.t == "drygoomba") or (a == "downplant" and b.t == "dryplant") or a == "parabeetle" or a == "boo" or a == "torpedoted" or (a == "plant" and b.t == "dryplant") then
		self:explode()
		playsound(blockhitsound)
	elseif (a == "koopa" and (b.t == "beetle" or b.t == "beetleshell")) then
		self:explode()
	elseif a == "enemy" then
		if b:shotted("right", false, false, true) ~= false then
			addpoints(b.firepoints or 200, self.x, self.y)
		end
		self:explode()
	elseif fireballkill[a] and not b.resistsenemykill then
		b:shotted("right")
		self:explode()
	end
end

function brofireball:explode()
	if self.active then
		self.destroysoon = true
		self.quadi = 5
		self.quadcenterX = 8
		self.quadcenterY = 8
		self.quad = fireballquad[self.quadi]
		self.active = false
	end
end

function brofireball:doclearpipe(pipe)
	self.killsinsideclearpipes = true
	if pipe then
		self.activestatic = true
	else
		self.activestatic = false
	end
end

--------------------------------------------------------
boomerang = class:new()

function boomerang:init(x, y, dir, v)
	--PHYSICS STUFF
	self.x = x
	self.y = y-16/16
	self.starty = self.y
	self.speedy = -3
	self.dir = dir
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.category = 14
	self.mask = {	true,
					true, false, false, false, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, false, true,
					true, true, true, true, true,
					true, true, true, true, true,
					false, true}
	self.emancipatecheck = true
	self.gravity = 0
	self.autodelete = true
	self.portalable = false
	self.boomerangbrocollide = false

	self.kills = true
	if v then -- essentially, if thrower is mario
		self.fireballthrower = v
		self.killstuff = true
		self.kills = false
		self.speed = boomerangspeed
		self.category = 4
		self.mask = {	true,
						false, false, false, false, true,
						false, true, false, true, false,
						false, true, false, true, false,
						true, true, false, false, false,
						false, true, false, false, true,
						false, false, false, false, true,
						false, true}
	else
		self.speed = boomerangbrospeed
	end

	self.speedx = -self.speed
	if dir == "right" then
		self.speedx = self.speed
	end
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = boomerangimg
	self.quadi = 1
	self.quad = hammerquad[spriteset][1]
	self.offsetX = 6
	self.offsetY = 2
	self.quadcenterX = 8
	self.quadcenterY = 8
	
	self.rotation = 0 --for portals
	self.animationdirection = dir
	self.timer = 0
	self.timer1 = 0
	self.timer2 = 0
	self.timer3 = 0
	self.timer1start = true
	self.timer2start = false
	self.timer3start = false
end

function boomerang:update(dt)
	if self.delete then
		self:explode()
		return true
	end
	if self.fireballthrower then
		--collect coins
		local x = math.floor(self.x+self.width/2)+1
		local y = math.floor(self.y+self.height)+1
		if inmap(x, y) then
			if tilequads[map[x][y][1]].coin then
				collectcoin(x, y)
			elseif objects["coin"][tilemap(x, y)] and not objects["coin"][tilemap(x, y)].frozen then
				collectcoinentity(x, y)
			elseif objects["collectable"][tilemap(x, y)] then
				getcollectable(x, y)
			end
		end
		local y = math.floor(self.y+self.height/2)+1
		if inmap(x, y) then
			if tilequads[map[x][y][1]].coin then
				collectcoin(x, y)
			elseif objects["coin"][tilemap(x, y)] and not objects["coin"][tilemap(x, y)].frozen then
				collectcoinentity(x, y)
			elseif objects["collectable"][tilemap(x, y)] then
				getcollectable(x, y)
			end
		end
	end
	if self.active then
		self.timer = self.timer + dt
		while self.timer > 0.17 do
			self.quadi = self.quadi + 1
			if self.quadi == 5 then
				self.quadi = 1
			end
			self.quad = hammerquad[spriteset][self.quadi]
			self.timer = self.timer - 0.17
		end
		
		if self.mask[20] and self.y > self.starty + 1 then
			self.mask[20] = false
		end

		if self.timer1start then
			self.timer1 = self.timer1 + dt
			if self.timer1 > 0.5 then
				self.speedy = 3
				self.timer1start = false
				self.timer2start = true
			else
				return false
			end
		elseif self.timer2start then
			self.timer2 = self.timer2 + dt
			if self.timer2 > 0.5 then
				if self.dir == "left" then
					self.speedx = self.speed
				else
					self.speedx = -self.speed
				end
				self.boomerangbrocollide = "hammerbro"
				if self.fireballthrower then
					self.boomerangbrocollide = "player"
				end
				self.timer2start = false
				self.timer3start = true
			else
				return false
			end
		elseif self.timer3start then
			self.timer3 = self.timer3 + dt
			if self.timer3 > 0.3 then
				self.speedy = 0
				self.timer3start = false
			else
				return false
			end
		end
	end
	if self.x < xscroll-1 or self.x > xscroll+width+1 or self.y > mapheight and self.active then
		self:explode()
		return true
	end
end

function boomerang:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function boomerang:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function boomerang:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function boomerang:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end


function boomerang:globalcollide(a, b)
	if self.boomerangbrocollide == a then
		self:explode()
		return true
	end
	
	if self.killstuff then
		if a == "enemy" then
			if b:shotted("right", false, false, true) ~= false then
				addpoints(b.firepoints or 200, self.x, self.y)
			end
		elseif mariohammerkill[a] then
			b:shotted("right")
			if a ~= "bowser" then
				addpoints(firepoints[a] or 200, self.x, self.y)
			end
		end
		return false
	end
end

function boomerang:explode()
	if self.delete then
		return false
	end
	self.drawable = false
	self.active = false
	self.delete = true
	if self.fireballthrower then
		self.fireballthrower:fireballcallback()
	end
end

function boomerang:portaled()
	self.killstuff = true
end

function boomerang:emancipate(a)
	return true
end
