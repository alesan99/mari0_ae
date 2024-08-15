ice = class:new()

function ice:init(x, y, w, h, a, enemy)
	self.width = (math.ceil(w) or 1)+.5
	self.height = (math.ceil(h) or 1)+.5

	self.x = x-self.width/2
	self.y = y-self.height

	self.speedx = 0
	self.speedy = 0
	
	self.active = true
	self.static = false
	self.activestatic = false
	self.category = 32

	self.mask = {true}

	self.rotation = 0
	self.timer = 0

	self.offsetX = 0
	self.shaketimer = 0

	self.a = a
	self.enemy = enemy
	self.oldenemystatic = self.enemy.static
	self.oldenemyactive = self.enemy.active
	self.oldenemyresistsyoshitounge = self.enemy.resistsyoshitounge
	self.oldenemycustomscissor = self.enemy.customscissor
	if self.enemy.freeze then
		self.enemy:freeze()
	end
	if enemy.static or math.abs(enemy.speedy) > 2 or (enemy.gravity and enemy.gravity == 0) then
		self.static = true
		self.activestatic = true
		self.y = enemy.y+enemy.height/2-self.height/2
		self.dontfallafterfreeze = enemy.dontfallafterfreeze
	end
	if enemy.dontfallafterfreeze then
		self.oldenemytrackspeed = enemy.trackspeed
	end
	enemy.iceblock = self
	self.falling = false
	self:hold()
end

function ice:update(dt)
	if (not self.enemy) or self.enemy.shot or self.enemy.delete then
		self:meltice()
		return true
	end
	self:hold()

	if self.funnel then
		if self.static then
			self.static = false
			self.activestatic = false
		end
		self.gravity = yacceleration
		self.funnel = false
	end
	
	if edgewrapping then --wrap around screen
		local minx, maxx = -self.width, mapwidth
		if self.x < minx then
			self.x = maxx
		elseif self.x > maxx then
			self.x = minx
		end
	end

	if math.abs(self.speedx) < 1 then
		self.timer = self.timer + dt
	else
		--collect collectables if moving
		local x = math.floor(self.x+self.width/2)+1
		local y = math.floor(self.y+self.height)+1
		if ismaptile(x, y) then
			if objects["collectable"][tilemap(x, y)] then
				getcollectable(x, y)
			end
		end
		local y = math.floor(self.y+self.height/2)+1
		if ismaptile(x, y) then
			if objects["collectable"][tilemap(x, y)] then
				getcollectable(x, y)
			end
		end
	end

	if self.static and (not self.dontfallafterfreeze) then
		--start falling if static
		if self.timer > iceblockairtime then
			self.static = false
			self.activestatic = false
			self.falling = true
		elseif self.timer > iceblockairtime-1 then
			self.shaketimer = (self.shaketimer + 8*dt)%1
			self.offsetX = math.floor(math.abs(self.shaketimer-.5)*4+.5)
		end
	else
		--unfreeze
		if self.timer > freezetime then
			self:meltice()
		elseif self.timer > freezetime-1 then
			self.shaketimer = (self.shaketimer + 8*dt)%1
			self.offsetX = math.floor(math.abs(self.shaketimer-.5)*4+.5)
		end
	end

	--[[hold player if falling
	if self.falling then
		local ydiff = self.speedy*dt
		local condition = false
		if ydiff < 0 then
			condition = "ignoreplatforms"
		end
		for j, w in pairs(objects["player"]) do
			if inrange(w.x, self.x-w.width, self.x+self.width) then --vertical carry
				if ((w.y == self.y - w.height) or ((w.y+w.height >= self.y-0.1 and w.y+w.height < self.y+0.1)))
					and (not w.jumping) then
					if not checkintile(w.x, w.y+ydiff, w.width, w.height, tileentities, w) then
						w.y = self.y-w.height
						w.falling = false
						w.jumping = false
						w.speedy = 0
						--w.speedy = b.speedy
					end
				end
			end
		end
	end]]
end

function ice:draw(enemylayer)
	if (not enemylayer) and self.enemy and self.enemy.drawable then
		return false
	end
	for x = 1, self.width*2 do
		for y = 1, self.height*2 do
			local q = 5
			if x == 1 and y == 1 then
				q = 1
			elseif x == self.width*2 and y == 1 then
				q = 3
			elseif x == 1 and y == self.height*2 then
				q = 7
			elseif x == self.width*2 and y == self.height*2 then
				q = 9
			elseif y == 1 then
				q = 2
			elseif x == 1 then
				q = 4
			elseif y == self.height*2 then
				q = 8
			elseif x == self.width*2 then
				q = 6
			end
			love.graphics.draw(iceimg, icequad[q], math.floor(((self.x-xscroll)*16+8*(x-1)+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-8+8*(y-1))*scale), 0, scale, scale)
		end
	end
end

function ice:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end

	if (not self.static) and self.speedx == 0 and a == "player" and b.speedx <= -iceblockkickminspeed then
		--kick
		self.speedx = -iceblockspeed
		playsound(shotsound)
	end

	if self.speedx > 0 then
		--kill enemies
		if mariohammerkill[a] then
			b:shotted("right")
			if a ~= "bowser" then
				addpoints(firepoints[a], self.x, self.y)
			end
			return false
		elseif a == "enemy" and b:shotted("right", false, false, true) ~= false and (not (b.resistsenemykill or b.resistseverything)) then
			addpoints(b.firepoints or 200, self.x, self.y)
			return false
		else
			self:meltice("destroy")
		end
	end
end

function ice:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end

	if (not self.static) and self.speedx == 0 and a == "player" and b.speedx >= iceblockkickminspeed then
		--kick
		self.speedx = iceblockspeed
		playsound(shotsound)
	end

	if self.speedx < 0 then
		--kill enemies
		if mariohammerkill[a] then
			b:shotted("right")
			if a ~= "bowser" then
				addpoints(firepoints[a], self.x, self.y)
			end
			return false
		elseif a == "enemy" and b:shotted("right", false, false, true) ~= false and (not (b.resistsenemykill or b.resistseverything)) then
			addpoints(b.firepoints or 200, self.x, self.y)
			return false
		else
			self:meltice("destroy")
		end
	end
end

function ice:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function ice:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end

	if self.falling and (not (self.speedy > 0 and self.speedy <= yacceleration*gdt)) then
		self:meltice("destroy")
		return false
	end
	if (a == "player" and b.gravitydir == "down") then
		self:meltice("destroy")
		return false
	end
end

function ice:passivecollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function ice:globalcollide(a, b)
	if a == "screenboundary" or a == "checkpointflag" then
		return true
	elseif (a == "fireball" and b.t == "fireball") or a == "castlefirefire" or a == "longfire" or a == "fire" or a == "plantfire" or (a == "brofireball" and b.t ~= "ice") or a == "upfire" or a == "angrysun" or b.meltsice then
		self:meltice()
	end
end

function ice:hold()
	--hold enemy
	local b = self.enemy
	b.static = true
	b.active = false
	b.resistsyoshitounge = true
	b.x = self.x+self.width/2-b.width/2
	b.y = self.y+self.height/2-b.height/2
	b.frozen = true
	b.customscissor = {self.x, self.y, self.width, self.height}
	if b.dontfallafterfreeze then
		b.trackspeed = 0
	else
		b.trackable = false
	end
end

function ice:release()
	--release enemy
	local b = self.enemy
	b.static = self.oldenemystatic
	b.active = self.oldenemyactive
	b.resistsyoshitounge = self.oldenemyresistsyoshitounge
	b.customscissor = self.oldenemycustomscissor
	b.frozen = false
	b.iceblock = nil
	if b.dontfallafterfreeze then
		b.trackspeed = self.oldenemytrackspeed
	end
end

function ice:meltice(destroy)
	self:release()
	self.active = false

	if destroy then
		playsound(iciclesound)
		local debris = rgbaToInt(80, 210, 250, 255)
		if blockdebrisquads[debris] then
			table.insert(blockdebristable, blockdebris:new(self.x+self.width/2, self.y+self.height/2, 3.5, -23, blockdebrisimage, blockdebrisquads[debris][spriteset]))
			table.insert(blockdebristable, blockdebris:new(self.x+self.width/2, self.y+self.height/2, -3.5, -23, blockdebrisimage, blockdebrisquads[debris][spriteset]))
			table.insert(blockdebristable, blockdebris:new(self.x+self.width/2, self.y+self.height/2, 3.5, -14, blockdebrisimage, blockdebrisquads[debris][spriteset]))
			table.insert(blockdebristable, blockdebris:new(self.x+self.width/2, self.y+self.height/2, -3.5, -14, blockdebrisimage, blockdebrisquads[debris][spriteset]))
		end
		
		local b = self.enemy
		b.frozen = true
		if mariohammerkill[self.a] then
			b:shotted("right")
			if a ~= "bowser" then
				addpoints(firepoints[a], self.x, self.y)
			end
		elseif self.a == "enemy" then
			if (not b.resistsiceblock) and (not b.resistsenemykill) and (not b.resistseverything) and (not b.resistseverything) and b:shotted("right", nil, nil, false, true) then
				addpoints(firepoints[b.t] or 100, self.x, self.y)
			end
		else
			b.instantdelete = true
		end
		b.frozen = false
	end

	self.instantdelete = true
end

function ice:laser()
	self:meltice()
end
