mushroom = class:new()

function mushroom:init(x, y, t, r)
	--PHYSICS STUFF
	self.x = x-6/16
	self.y = y-11/16
	self.speedy = 0
	self.speedx = 0
	self.width = 12/16
	self.height = 12/16
	self.static = true
	self.active = true
	self.category = 6
	self.mask = {	true,
					false, false, true, true, true,
					false, true, false, true, true,
					false, true, true, false, true,
					true, true, false, true, true,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	self.destroy = false
	self.autodelete = true
	
	--IMAGE STUFF
	self.drawable = false
	self.graphic = itemsimg
	self.quad = itemsquad[spriteset][1]
	self.offsetX = 6
	self.offsetY = 3
	self.quadcenterX = 8
	self.quadcenterY = 8
	
	if t == "oneup" then
		self.t = "oneup"
		self.graphic = itemsimg
		self.quad = itemsquad[spriteset][2]
		self.pipespawnmax = 3
	elseif t == "big" then
		self.t = "big"
		self.x = x-12/16
		self.y = y-23/16
		self.width = 24/16
		self.height = 24/16
		self.graphic = bigmushroomimg
		self.quad = bigmushroomquad
		self.offsetX = 13
		self.offsetY = -1
		self.quadcenterX = 16
		self.quadcenterY = 16
	elseif t == "bigclassic" then
		self.t = "bigclassic"
		self.x = x-12/16
		self.y = y-23/16
		self.width = 24/16
		self.height = 24/16
		self.animationscalex = 2
		self.animationscaley = 2
		self.offsetX = 13
		self.offsetY = -1
	elseif t == "mini" then
		self.t = "mini"
		self.x = x-3/16
		self.y = y-11/16
		self.width = 6/16
		self.height = 6/16
		self.graphic = itemsimg
		self.quad = itemsquad[spriteset][7]
		self.offsetX = 3
		self.offsetY = 6
		self.quadcenterX = 8
		self.quadcenterY = 12
	elseif t == "weird" then
		self.t = "weird"
		self.graphic = itemsimg
		self.quad = itemsquad[spriteset][13]
	elseif t == "goombashoe" then
		self.t = "goombashoe"
		self.starty = y+27/16
		self.graphic = goombashoeimg
		self.quad = goombashoequad[spriteset][4]
		self.animationtimer = 0
		self.speedx = 0
		self.pipespawnmax = 1
		self.resistsyoshitounge = true
	elseif t == "bigcloud" then
		self.t = "bigcloud"
		self.starty = y+27/16
		self.graphic = bigcloudimg
		self.quad = bigcloudquad[spriteset]
		self.animationtimer = 0
		self.speedx = 0
		self.gravity = 15
		self.quadcenterX = 10
		self.pipespawnmax = 1
		if r and r == "true" then
			self.infinite = true
		end
		self.resistsyoshitounge = true
	elseif t == "drybonesshell" then
		self.t = "drybonesshell"
		self.starty = y+27/16
		self.graphic = drybonesshellimg
		self.quad = starquad[spriteset][1]
		self.animationtimer = 0
		self.speedx = 0
		self.pipespawnmax = 1
		self.resistsyoshitounge = true
	end
	
	self.rotation = 0 --for portals
	self.uptimer = 0
	
	self.falling = false
	self.light = 1
end

function mushroom:update(dt)
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
	
	if self.uptimer < mushroomtime then
		self.uptimer = self.uptimer + dt
		if self.uptimer >= mushroomtime then
			self.drawable = true --fixes mushroom being invisible for a frame after coming out block
		end
		if self.t == "mini" then
			self.y = self.y - dt*(1/mushroomtime-8/16)
		else
			self.y = self.y - dt*(1/mushroomtime)
		end
		if self.t ~= "goombashoe" and self.t ~= "bigcloud" and self.t ~= "drybonesshell" then
			self.speedx = mushroomspeed
		elseif self.heel then
			self.quad = goombashoequad[spriteset][6]
		end
		self.active = false
	else
		if self.static == true then
			self.static = false
			self.active = true
			self.drawable = true
		end
		
		if self.t == "goombashoe" then
			self.animationtimer = (self.animationtimer + dt)%(goombaanimationspeed*2)
			if self.heel then
				self.quad = goombashoequad[spriteset][6]
			elseif self.animationtimer > goombaanimationspeed then
				self.quad = goombashoequad[spriteset][5]
			else
				self.quad = goombashoequad[spriteset][4]
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
	end
	
	if self.destroy then
		return true
	else
		return false
	end
end

function mushroom:draw()
	if self.uptimer < mushroomtime and not self.destroy then
		--Draw it coming out of the block.
		if not self.t or self.t == "goombashoe" or self.t == "weird" or self.t == "bigcloud" or self.t == "drybonesshell" or self.t == "oneup" then
			love.graphics.draw(self.graphic, self.quad, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), 0, (self.animationscalex or 1)*scale, (self.animationscaley or 1)*scale, self.quadcenterX, self.quadcenterY)
		elseif self.t == "mini" then
			love.graphics.draw(itemsimg, self.quad, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), 0, scale, scale, self.quadcenterX, self.quadcenterY)
		elseif self.t == "big" then
			love.graphics.draw(self.graphic, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), 0, scale/2*(self.uptimer/mushroomtime)+scale/2, scale/2*(self.uptimer/mushroomtime)+scale/2, self.quadcenterX, self.quadcenterY)
		elseif self.t == "bigclassic" then
			love.graphics.draw(self.graphic, self.quad, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), 0, (1+(self.uptimer/mushroomtime))*scale, (1+(self.uptimer/mushroomtime))*scale, self.quadcenterX, self.quadcenterY)
		end
	end
end

function mushroom:use(a, b) --DUDE MUSHROOMS LMAO
	if not self.active then
		return false
	end

	if self.t and self.t == "oneup" then
		givelive(b.playernumber, self)
		self.active = false
		self.destroy = true
		self.drawable = false
		return false
	end

	if a == "player" then
		if b.animation == "grow1" or b.animation == "grow2" or b.animation == "shrink" then
			return false
		end
		self.active = false
		self.destroy = true
		self.drawable = false
		if not self.t then
			b:grow()
		elseif self.t == "big" then
			if not (b.clearpipe) then
				b:grow(8)
			end
		elseif self.t == "bigclassic" then
			b:grow(16)
		elseif self.t == "mini" then
			b:grow(-1)
		elseif self.t == "weird" then
			b:grow(12)
		elseif self.t == "goombashoe" or self.t == "bigcloud"  or self.t == "drybonesshell" then
			if b.shoe then
				self.active = true
				self.destroy = false
				self.drawable = true
			elseif self.heel then
				b:shoed("heel")
			elseif self.t == "bigcloud" then
				if self.infinite then
					b:shoed("cloudinfinite")
				else
					b:shoed("cloud")
				end
			elseif self.t == "drybonesshell" then
				b:shoed("drybonesshell")
			else
				b:shoed(true)
			end
		end
	end
end

function mushroom:leftcollide(a, b)
	if self.t ~= "goombashoe" and self.t ~= "bigcloud" and self.t ~= "drybonesshell" then
		self.speedx = mushroomspeed
	end
	
	if a == "player" then
		if (self.t and (self.t == "goombashoe" or self.t == "bigcloud" or self.t == "drybonesshell")) then
			self.speedx = 0; return false
		end
		self:use(a, b)
	end
	
	return false
end

function mushroom:rightcollide(a, b)
	if self.t ~= "goombashoe" and self.t ~= "bigcloud" and self.t ~= "drybonesshell" then
		self.speedx = -mushroomspeed
	end
	
	if a == "player" then
		if (self.t and (self.t == "goombashoe" or self.t == "bigcloud" or self.t == "drybonesshell")) then
			self.speedx = 0; return false
		end
		self:use(a, b)
	end
	
	return false
end

function mushroom:floorcollide(a, b)
	if a == "player" then
		if (self.t and (self.t == "goombashoe" or self.t == "bigcloud" or self.t == "drybonesshell")) then
			self.speedx = 0; return false
		end
		self:use(a, b)
	end	
	if a == "tile" then
		local x, y = b.cox, b.coy
		if self.speedx ~= 0 and inmap(x, y) and tilequads[map[x][y][1]].noteblock then
			hitblock(x, y, self, {dir="down"})
			self.falling = true
			self.speedy = -mushroomjumpforce
		end
	end
end

function mushroom:ceilcollide(a, b)
	if a == "player" then
		self:use(a, b)
	end	
end

function mushroom:passivecollide(a, b)
	if a == "player" and not (self.t and (self.t == "goombashoe" or self.t == "bigcloud" or self.t == "drybonesshell")) then
		self:use(a, b)
	end	
	if a == "donut" then
		return false
	end	
end

function mushroom:jump(x)
	self.falling = true
	self.speedy = -mushroomjumpforce
	if self.t ~= "goombashoe" and self.t ~= "bigcloud" and self.t ~= "drybonesshell" then
		if self.x+self.width/2 < x-0.5 then
			self.speedx = -mushroomspeed
		elseif self.x+self.width/2 > x-0.5 then
			self.speedx = mushroomspeed
		end
	end
end

function givelive(id, t)
	if mariolivecount ~= false then
		for i = 1, players do
			mariolives[i] = mariolives[i]+1
			respawnplayers()
		end
	end
	t.destroy = true
	t.active = false
	table.insert(scrollingscores, scrollingscore:new("1up", t.x, t.y))
	playsound(oneupsound)
end	