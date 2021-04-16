core = class:new()

function core:init(x, y, t)
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
					false, true, false, true, true,
					false, false, true, false, false,
					true, true, false, false, true,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
					
	self.emancipatecheck = true

	self.userect = adduserect(self.x, self.y, 12/16, 12/16, self)
	
	self.t = t
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = coreimage
	if self.t == "curiosity" then
		self.quad = corequad[2]
	elseif self.t == "cakemix" then
		self.quad = corequad[3]
	elseif self.t == "anger" then
		self.quad = corequad[4]
	elseif self.t == "morality" then
		self.quad = corequad[1]
	end
	self.offsetX = 6
	self.offsetY = 2
	self.quadcenterX = 6
	self.quadcenterY = 6
	
	self.rotation = 0 --for portals
	
	self.falling = false
	self.destroying = false
	self.outtable = {}
	self.portaledframe = false

	self.gravitydir = "down"
end

function core:update(dt)
	local friction = boxfrictionair
	if self.falling == false then
		friction = boxfriction
	end
	
	if not self.pushed then
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
	else
		self.pushed = false
	end
	
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
	
	if self.speedx < 0 then
		self.animationdirection = "left"
	elseif self.speedx > 0 then
		self.animationdirection = "right"
	elseif self.speedx == 0 then
		self.animationdirection = self.animationdirection
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

function core:leftcollide(a, b)
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
	end
end

function core:rightcollide(a, b)
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
	end
end

function core:floorcollide(a, b)
	if self.falling then
		self.falling = false
	end
	
	if (a == "goomba" and b.t ~= "spikey") or a == "bulletbill" then
		b:stomp()
		addpoints(200, self.x, self.y)
		playsound(stompsound)
		self.falling = true
		return false
	end
end

function core:passivecollide(a, b)
	if a == "player" then
		if self.x+self.width > b.x+b.width then
			self.x = b.x+b.width
		else
			self.x = b.x-self.width
		end
	end
end

function core:startfall()
	self.falling = true
end

function core:emancipate()
	if self.parent then
		self.parent:cubeemancipate()
	end
	self:destroy()
end

function core:destroy()
	self.userect.delete = true
	self.destroying = true
	
	for i = 1, #self.outtable do
		if self.outtable[i][1].input then
			self.outtable[i][1]:input("toggle", self.outtable[i][2])
		end
	end
end

function core:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end

function core:used(id)
	self.parent = objects["player"][id]
	self.active = false
	objects["player"][id]:pickupbox(self)
end

function core:dropped(gravitydir)
	local gravitydirection = gravitydir
	self.parent = nil
	self.active = true
	if gravitydirection then
		if gravitydirection == "up" then
			self.gravity = -yacceleration
			self.speedx = 0
		else
			self.gravity = yacceleration
			self.speedx = 0
		end
	end
end

function core:portaled()
	self.portaledframe = true
end