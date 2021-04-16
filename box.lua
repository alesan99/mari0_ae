box = class:new()

function box:init(x, y, t)
	--PHYSICS STUFF
	self.cox = x
	self.coy = y
	self.x = x-14/16
	self.y = y-12/16
	self.speedy = 0
	self.speedx = 0
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.category = 9
	self.parent = nil
	self.portaloverride = true

	self.mask = {	true,
					false, false, false, false, false,
					false, false, false, true, true,
					false, false, true, false, false,
					true, true, false, false, true,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
					
	self.emancipatecheck = true

	self.userect = adduserect(self.x, self.y, 12/16, 12/16, self)
	
	self.t = t or "box1"
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = boximage
	if self.t == "box2" then
		self.boxframe = 2
	elseif self.t == "edgeless" then
		self.boxframe = 3
	else
		self.boxframe = 1
	end
	self.quad = boxquad[spriteset][self.boxframe][1]
	self.overlaygraphic = false
	self.overlayquad = false
	
	self.offsetX = 6
	self.offsetY = 2
	self.quadcenterX = 6
	self.quadcenterY = 6
	
	self.rotation = 0 --for portals
	self.rotationspeed = 0
	
	self.falling = false
	self.destroying = false
	self.outtable = {}
	self.portaledframe = false

	self.gel = false
	self.pipespawnmax = 1

	self.gravitydir = "down"
end

function box:update(dt)
	if edgewrapping then --wrap around screen
		local minx, maxx = -self.width, mapwidth
		if self.x < minx then
			self.x = maxx
		elseif self.x > maxx then
			self.x = minx
		end
	end

	if self.insidetile then
		self.insidetile = self.insidetile - 1
		if self.insidetile <= 0 then
			self.insidetile = false
		end
	end
	
	local friction = boxfrictionair
	if self.falling == false and self.t ~= "edgeless" then
		friction = boxfriction
	end
	
	if (inmap(math.floor(self.x+1+self.width), math.floor(self.y+self.height+20/16)) or inmap(math.floor(self.x+1), math.floor(self.y+self.height+20/16))) then
		local t, t2
		local cox, coy = math.floor(self.x+1), math.floor(self.y+self.height+20/16)
		local cox2 = math.floor(self.x+1+self.width)
		if inmap(cox, coy) then
			t = map[cox][coy]
		end
		if inmap(cox2, coy) then
			t2 = map[cox2][coy]
		end
		if (t and ((t[2] and entityquads[t[2]] and entityquads[t[2]].t == "ice") or (t[1] and tilequads[t[1]] and tilequads[t[1]]:getproperty("ice", cox, coy)))) or
			(t2 and ((t2[2] and entityquads[t2[2]] and entityquads[t2[2]].t == "ice") or (t2[1] and tilequads[t2[1]] and tilequads[t2[1]]:getproperty("ice", cox, coy)))) then
			friction = icefriction
		end
	end
	
	if not self.pushed then
		if self.gravitydir == "right" or self.gravity == "left" then
			if self.speedy > 0 then
				self.speedy = self.speedy - friction*dt
				if self.speedy < 0 then
					self.speedy = 0
				end
			else
				self.speedy = self.speedy + friction*dt
				if self.speedy > 0 then
					self.speedy = 0
				end
			end
		else
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
		end
	else
		self.pushed = false
	end
	
	--rotate back to 0 (portals)
	if self.gel and (not self.parent) and self.rotationspeed ~= 0 then
		self.rotation = (self.rotation + (self.rotationspeed)*dt)%(math.pi*2)
		while self.rotation < 0 do
			self.rotation = self.rotation + math.pi*2
		end
	elseif self.t ~= "edgeless" then
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
		self.rotation = self.rotation + (self.speedx*math.pi)*dt
	end
	
	if self.parent then
		local oldx = self.x
		local oldy = self.y
		
		self.x = self.parent.x+math.sin(-self.parent.pointingangle)*0.3
		self.y = self.parent.y-math.cos(-self.parent.pointingangle)*0.3
		
		if self.portaledframe == false then
			for h, u in pairs(emancipationgrills) do
				if u.active then
					if u.dir == "hor" then
						if inrange(self.x+6/16, u.startx-1, u.endx, true) and inrange(u.y-14/16, oldy, self.y, true) then
							self:emancipate(h)
						end
					else
						if inrange(self.y+6/16, u.starty-1, u.endy, true) and inrange(u.x-14/16, oldx, self.x, true) then
							self:emancipate(h)
						end
					end
				end
			end
		end
	end
	
	self.userect.x = self.x
	self.userect.y = self.y
	
	if self.funnel then
		self.gravity = yacceleration
		self.funnel = false
	end

	--check if offscreen
	if self.y > mapheight+2 then
		self:destroy()
	end
	
	self.portaledframe = false
	
	if self.destroying then
		return true
	else
		return false
	end
end

function box:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if self.gel == 1 then
		self:bluegel("right")
	end
	if a == "button" then
		self.y = b.y - self.height
		self.x = b.x + b.width - 0.01
		if self.speedy > 0 then
			self.speedy = 0
		end
		return false
	elseif a == "player" then
		self.pushed = true
		return false
	elseif a == "tile" then
		if inmap(b.cox, b.coy) and map[b.cox][b.coy]["gels"] and 
		map[b.cox][b.coy]["gels"]["right"] then
			if map[b.cox][b.coy]["gels"]["right"] == 4 then
				self:purplegel("left")
			end
		end
	end
end

function box:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if self.gel == 1 then
		self:bluegel("left")
	end
	if a == "button" then
		self.y = b.y - self.height
		self.x = b.x - self.width+0.01
		if self.speedy > 0 then
			self.speedy = 0
		end
		return false
	elseif a == "player" then
		self.pushed = true
		return false
	elseif a == "tile" then
		if inmap(b.cox, b.coy) and map[b.cox][b.coy]["gels"] and 
		map[b.cox][b.coy]["gels"]["left"] then
			if map[b.cox][b.coy]["gels"]["left"] == 4 then
				self:purplegel("right")
			end
		end
	end
end

function box:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if self.falling then
		self.falling = false
	end
	
	if a == "goomba" or a == "bulletbill" then
		b:stomp("box")
		addpoints(200, self.x, self.y)
		playsound(stompsound)
		self.falling = true
		return false
	end
	if self.gel == 1 then
		self:bluegel("top")
	elseif a == "tile" then
		if inmap(b.cox, b.coy) and map[b.cox][b.coy]["gels"] and 
		map[b.cox][b.coy]["gels"]["top"] then
			if map[b.cox][b.coy]["gels"]["top"] == 1 then
				self.speedy = math.min(0, -self.speedy)
			elseif map[b.cox][b.coy]["gels"]["top"] == 4 then
				self:purplegel("down")
			end
		end
	end

	if a == "pixeltile" and self.t == "edgeless" then
		if b.dir == "left" then
			self.speedx = self.speedx - 6000*b.step*gdt
		else
			self.speedx = self.speedx + 6000*b.step*gdt
		end
	end
	
	if a == "enemy" and b.killedbyboxes then
		if b.stompable then
			b:stomp()
		else
			b:shotted("right", false, false, false)
		end
		addpoints(200, self.x, self.y)
		playsound("stomp")
		self.falling = true
		self.speedy = -10
		return false
	end

	if a == "player" then
		if self.gravitydir == "right" or self.gravity == "left" then
			self.pushed = true
			return false
		end
	end
end

function box:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "player" then
		if self.gravitydir == "right" or self.gravity == "left" then
			self.pushed = true
			return false
		end
	elseif a == "tile" then
		if inmap(b.cox, b.coy) and map[b.cox][b.coy]["gels"] and 
		map[b.cox][b.coy]["gels"]["bottom"] then
			if map[b.cox][b.coy]["gels"]["bottom"] == 4 then
				self:purplegel("up")
			end
		end
	end
end

function box:passivecollide(a, b)
	if self.gel == 1 then
		self:bluegel("top")
	end
	if a == "player" then
		if self.gravitydir == "right" or self.gravity == "left" then
			if self.y+self.height > b.y+b.height then
				self.y = b.y+b.height
			else
				self.y = b.y-self.height
			end
		else
			if self.x+self.width > b.x+b.width then
				self.x = b.x+b.width
			else
				self.x = b.x-self.width
			end
		end
	end
	if a == "tile" then
		--boxes usually clip walls horizontally at around 85-99 speedx
		--if (not self.insidetile) then
		local threshold = 88
		if self.speedx > threshold then
			self.x = b.x-self.width
			self.speedx = 0
		elseif self.speedx < -threshold then
			self.x = b.x+b.width
			self.speedx = 0
		end
		--end
		--self.insidetile = 2
	end
end

function box:globalcollide(a, b)
	if a == "gel" then
		--cover in gel
		self.rotationspeed = 0
		if b.id == 5 then
			self.gel = false
			self.overlaygraphic = false
			self.overlayquad = false
		else
			self.gel = b.id
			self.overlaygraphic = boxgelimg
			self.overlayquad = boxgelquad[spriteset][1][self.gel]
			if self.t == "edgeless" then
				self.overlayquad = boxgelquad[spriteset][2][self.gel]
			end
		end
		return true
	end
end

function box:bluegel(dir)
	if dir == "top" then
		--if self.speedy > gdt*yacceleration*10 then
			self.speedy = math.min(-20, -self.speedy)
			self.falling = true
			self.speedx = math.random(-10,10)
			self.rotationspeed = self.speedx
			
			return true
		--end
	elseif dir == "left" then
		if self.speedx > horbounceminspeedx then
			self.speedx = math.min(-horbouncemaxspeedx, -self.speedx*horbouncemul)
			self.speedy = math.min(self.speedy, -horbouncespeedy)
			
			return true
		end
	elseif dir == "right" then
		if self.speedx < -horbounceminspeedx then
			self.speedx = math.min(horbouncemaxspeedx, -self.speedx*horbouncemul)
			self.speedy = math.min(self.speedy, -horbouncespeedy)
			
			return false
		end
	end
end

function box:purplegel(dir)
	if dir == "top" then
		self.gravitydir = "up"
	elseif dir == "bottom" then
		self.gravitydir = "down"
	elseif dir == "left" then
		if self.gravitydir ~= "left" then
			self.speedx = self.speedy/2
		end
		self.gravitydir = "left"
	elseif dir == "right" then
		if self.gravitydir ~= "right" then
			self.speedx = self.speedy/2
		end
		self.gravitydir = "right"
	end
end

function box:startfall()
	self.falling = true
end

function box:emancipate()
	if self.destroying then
		return false
	end
	local speedx, speedy = self.speedx, self.speedy
	if self.parent then
		self.parent:cubeemancipate()
		speedx = speedx + self.parent.speedx
		speedy = speedy + self.parent.speedy
	end
	table.insert(emancipateanimations, emancipateanimation:new(self.x, self.y, self.width, self.height, self.graphic, self.quad, speedx, speedy, self.rotation, self.offsetX, self.offsetY, self.quadcenterX, self.quadcenterY))
	self:destroy()
end

function box:destroy()
	self.userect.delete = true
	self.destroying = true
	
	for i = 1, #self.outtable do
		if self.outtable[i][1].input then
			self.outtable[i][1]:input("toggle", self.outtable[i][2])
		end
	end
end

function box:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end

function box:used(id)
	self.parent = objects["player"][id]
	self.active = false
	self.speedx = 0
	self.speedy = 0
	objects["player"][id]:pickupbox(self)
end

function box:dropped(gravitydir)
	local gravitydirection = gravitydir
	self.parent = nil
	self.active = true
	if gravitydirection then
		self.gravitydir = gravitydirection
		if self.gravitydir == "left" or self.gravitydir == "right" then
			self.speedy = 0
		else
			self.speedx = 0
		end
	end
end

function box:portaled()
	self.portaledframe = true
end

function box:onbutton(s)
	if s then
		self.quad = boxquad[spriteset][self.boxframe][2]
	else
		self.quad = boxquad[spriteset][self.boxframe][1]
	end
end