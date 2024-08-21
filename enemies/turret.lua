--most of this is by Maruice. Me and Fakeuser added extra things

turret = class:new()

local handlePlayerCollisions

function turret:init(x, y, dir, t, r)
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
	self.dead = false
	self.frenzy = false
	self.dir = dir or "left"
	self.t = t or "turret"
	self.knockback = true

	self.r = r
	if self.r and self.r ~= "link" then
		local v = convertr(self.r, {"string", "string", "bool"}, true)
		--DIR
		self.dir = v[1]

		--OFFSET?
		if v[2] == "defective" then
			self.t = "turret2"
		else
			self.t = "turret"
		end

		self.knockback = v[3]
		if v[3] == nil then
			if (not mappackversion) or mappackversion <= 13.0114 then
				self.knockback = false
			else
				self.knockback = true
			end
		end
	end
	
	self.drawable = false
	self.mask = {true}

	self.graphic = turretimg
	if self.t == "turret2" then
		self.graphic = turret2img
	end
	self.offsetX = 5
	self.offsetY = 6
	self.quadcenterX = 6
	self.quadcenterY = 7
	self.armoffsetX = 6
	self.armoffsetY = 4
	self.armquadcenterX = 6
	self.armquadcenterY = 5
	
	self.rotation = 0
	self.rotationspeed = 0
	self.armrotation = 0
	self.armtargetrotation = 0
	
	self.target = "none"
	self.timer = 0
	
	self.updatetimer = 0
	self.frenzytimer = 0
	self.shottimer = 0
	
	self.emancipatecheck = true
	self.falling = false
	self.parent = nil
	self.userect = adduserect(self.x, self.y, 12/16, 12/16, self)
end

function turret:update(dt)
	self:specifficupdate(dt)

	local friction = boxfrictionair
	if self.falling == false then
		friction = boxfriction
	end

	if self.gel and (not self.parent) and self.rotationspeed ~= 0 then
		self.rotation = (self.rotation + (self.rotationspeed)*dt)%(math.pi*2)
		while self.rotation < 0 do
			self.rotation = self.rotation + math.pi*2
		end
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
		if self.parent.starred then
			self.parent:cubeemancipate()
			self:explode()
		end
	end
	
	self.userect.x = self.x
	self.userect.y = self.y
	
	if self.funnel then
		self:dofrenzy()
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

function turret:leftcollide(a, b)
	if self:globalcollide(a,b) then
		return false
	end
	if a == "player" then
		self.pushed = true
		return false
	end
	if a == "laser" then
		playsound(boomsound)
		self:destroy()
	end
end

function turret:rightcollide(a, b)
	if self:globalcollide(a,b) then
		return true
	end
	if a == "player" then
		self.pushed = true
		return false
	end
	if a == "laser" then
		playsound(boomsound)
		self:destroy()
	end
end

function turret:floorcollide(a, b)
	if self:globalcollide(a,b) then
		return false
	end
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
	if a == "laser" then
		playsound(boomsound)
		self:destroy()
	end
	if self.gel == 1 then
		self:bluegel("top")
	end
end

function turret:ceilcollide(a, b)
	if self:globalcollide(a,b) then
		return false
	end

	if a == "box" and b.speedy > 2 then
		playsound(blockhitsound)
		self:dofrenzy()
	end
end

function turret:passivecollide(a, b)
	if self:globalcollide(a,b) then
		return false
	end
	if a == "player" then
		if self.x+self.width > b.x+b.width then
			self.x = b.x+b.width
		else
			self.x = b.x-self.width
		end
	end
end

function turret:globalcollide(a, b)
	if a == "gel" then
		--cover in gel
		self.rotationspeed = 0
		if b.id == 5 then
			self.gel = false
		else
			self.gel = b.id
			if self.gel == 1 then
				self:dofrenzy()
			end
		end
		return true
	end
	if a == "energyball" or a == "turretrocket" or (a == "bomb" and b.explosion) then
		self:dofrenzy()
		return true
	end
	return false
end

function turret:startfall()
	self.falling = true
end

function turret:emancipate()
	if self.destroying then
		return false
	end
	local speedx, speedy = self.speedx, self.speedy
	if self.parent then
		self.parent:cubeemancipate()
		speedx = speedx + self.parent.speedx
		speedy = speedy + self.parent.speedy
	end
	table.insert(emancipateanimations, emancipateanimation:new(self.x, self.y, self.width, self.height, self.graphic, turretquad[1], speedx, speedy, self.rotation, self.offsetX, self.offsetY, self.quadcenterX, self.quadcenterY))
	self:destroy()
end

function turret:destroy()
	self.userect.delete = true
	self.destroying = true	
end

function turret:used(id)
	self.parent = objects["player"][id]
	self.active = false
	objects["player"][id]:pickupbox(self)
end

function turret:dropped()
	self.parent = nil
	self.active = true
end 

function turret:portaled()
	self.portaledframe = true
end

function turret:specifficupdate(dt)
	-- only active turrets please	
	if not self.active and not self.frenzy then return end

	while self.rotation > math.pi do
		self.rotation = self.rotation - 2 * math.pi
	end
	while self.rotation <= -math.pi do
		self.rotation = self.rotation + 2 * math.pi
	end
	
	if not self.frenzy then
		if self.rotation > turretcriticleangle or self.rotation < -turretcriticleangle then
			self.frenzy = true
			self.frenzytimer = 0
			self.timer = turrettime
		end
	end
	
	-- frenzy turret shoots randomly
	if self.frenzy then
		self:frenzyturret(dt)
	else		
		--update target
		self.updatetimer = self.updatetimer + dt
		if self.updatetimer > turretupdatetime then
			self.updatetimer = self.updatetimer - turretupdatetime
			self:updatetarget()
		end
		
		if (self.timer > turrettime/2 or self.target == "none") and self.armrotation ~= self.armtargetrotation then
			self.armrotation = self.armrotation + (self.armtargetrotation - self.armrotation)*dt*turretarmrotationspeed
			if self.armrotation > self.armtargetrotation then
				if self.armrotation < self.armtargetrotation then
					self.armrotation = self.armtargetrotation
				end
			else
				if self.armrotation > self.armtargetrotation then
					self.armrotation = self.armtargetrotation
				end
			end
		end
		
		if self.target == "none" then
			self.timer = math.max(0, self.timer - dt)
		else
			self.timer = math.min(turrettime, self.timer+dt)
		end
		
		if self.timer == turrettime and self.t ~= "turret2" then
			self.shottimer = self.shottimer + dt
			if self.shottimer > turretshottime then
				self.shottimer = self.shottimer - turretshottime
				if self.dir == "right" then
					local cox, coy, side, tend, x, y = traceline(self.x+self.width/2, self.y+self.height/2-3/16, -self.armrotation-math.pi/2+math.random()*0.05-.025)
					table.insert(objects["turretshot"], turretshot:new(self.x+self.width/2+0.2, self.y+self.height/2-3/16, x, y, self.armrotation, self.knockback))
				else
					local cox, coy, side, tend, x, y = traceline(self.x+self.width/2, self.y+self.height/2-3/16, -self.armrotation+math.pi/2+math.random()*0.05-.025)
					table.insert(objects["turretshot"], turretshot:new(self.x+self.width/2-0.2, self.y+self.height/2-3/16, x, y, self.armrotation + math.pi, self.knockback))
				end
				if not turretshotsound:isPlaying() then
					playsound(turretshotsound)
				end
			end
		end
	end
	return false
end

function turret:updatetarget()
	self.target = "none"
	for i = 1, players do
		local v = objects["player"][i]
		
		if not v.dead then
			local dist = math.sqrt(((self.x+self.width/2)-(v.x+v.width/2))^2 + ((self.y+self.height/2-3/16)-(v.y+v.height/2))^2)
			local angle = -math.atan2((v.x+v.width/2)-(self.x+self.width/2), (v.y+v.height/2)-(self.y+self.height/2-3/16))
			local angle2 = math.atan2((self.x+self.width/2)-(v.x+v.width/2), (self.y+self.height/2-3/16)-(v.y+v.height/2))
			
			local cox, coy, side, tend, x, y = traceline(self.x+self.width/2, self.y+self.height/2-3/16, angle2)
			local dist2 = math.sqrt(((self.x+self.width/2)-x)^2 + ((self.y+self.height/2-3/16)-y)^2)			
			
			if self.dir == "left" and dist <= dist2 and inrange(angle, math.pi/2-turretroom, math.pi/2+turretroom) then
				self.target = i
				self.armtargetrotation = angle-math.pi/2
			elseif self.dir == "right" and dist <= dist2 and inrange(angle, -math.pi/2+turretroom, -math.pi/2-turretroom) then
				self.target = i
				self.armtargetrotation = angle+math.pi/2
			end
		end
	end
	
	if self.target == "none" then
		self.armtargetrotation = 0
	end
end

function turret:frenzyturret(dt)
	self.shottimer = self.shottimer + dt
	if self.shottimer > turretshottime then
		self.shottimer = self.shottimer - turretshottime
		local speed = 20 -- roughly 1 degree every second
		if math.random() > 0.5 then
			self.armrotation = self.armrotation + speed * dt
		else
			self.armrotation = self.armrotation - speed * dt
		end
		
		local tx, ty = self.x + self.width/2, self.y + self.height/2-3/16
		if self.dir == "left" then
			if self.armrotation >= math.pi / 4 then self.armrotation = math.pi / 4 end
			if self.armrotation <= -math.pi / 4 then self.armrotation = -math.pi / 4 end
			
			if self.rotation > -math.pi and self.rotation <= -math.pi / 2 then
				tx = tx - 5 * math.sin(self.armrotation)
				ty = ty + 5 * math.cos(self.armrotation)
			elseif self.rotation > -math.pi / 2 and self.rotation <= 0 then
				tx = tx - 5 * math.cos(self.armrotation)
				ty = ty - 5 * math.sin(self.armrotation)
			elseif self.rotation > 0 and self.rotation <= math.pi / 2 then
				tx = tx + 5 * math.sin(self.armrotation)
				ty = ty - 5 * math.cos(self.armrotation)
			elseif self.rotation > math.pi / 2 and self.rotation <= math.pi then
				tx = tx + 5 * math.cos(self.armrotation)
				ty = ty + 5 * math.sin(self.armrotation)
			else
				tx, ty = 0, 0
			end
		else -- facing right
			if self.armrotation >= math.pi / 4 then self.armrotation = math.pi / 4 end
			if self.armrotation <= -math.pi / 4 then self.armrotation = -math.pi / 4 end

			if self.rotation > -math.pi and self.rotation <= -math.pi / 2 then
				tx = tx + 5 * math.sin(self.armrotation)
				ty = ty - 5 * math.cos(self.armrotation)
			elseif self.rotation > -math.pi / 2 and self.rotation <= 0 then
				tx = tx + 5 * math.cos(self.armrotation)
				ty = ty + 5 * math.sin(self.armrotation)
			elseif self.rotation > 0 and self.rotation <= math.pi / 2 then
				tx = tx - 5 * math.sin(self.armrotation)
				ty = ty + 5 * math.cos(self.armrotation)
			elseif self.rotation > math.pi / 2 and self.rotation <= math.pi then
				tx = tx - 5 * math.cos(self.armrotation)
				ty = ty - 5 * math.sin(self.armrotation)
			else
				tx, ty = 0, 0
			end
		end
		
		if self.t ~= "turret2" then
			table.insert(objects["turretshot"], turretshot:new(self.x+self.width/2, self.y+self.height/2-3/16, tx, ty, self.armrotation, self.knockback))
			if not turretshotsound:isPlaying() then
				playsound(turretshotsound)
			end
		end
	end
	
	self.frenzytimer = self.frenzytimer + dt
	if self.frenzytimer > frenzytime then
		self:explode()
	end
end

function turret:explode()
	self.parent = nil
	self.frenzy = false
	self.active = false
	self.dead = true
	self.drawable = false
	self.timer = 0
	self.armrotation = 0;
	local x, y = self.x, self.y
	if self.rotation > -math.pi and self.rotation <= -math.pi / 2 then
		x = x + self.height / 2
		y = y - self.width / 2
	elseif self.rotation > -math.pi / 2 and self.rotation <= 0 then
		x = x + self.width/2
		y = y - self.height / 2
	elseif self.rotation > 0 and self.rotation <= math.pi / 2 then
		x = x - self.height / 2
		y = y + self.width / 2
	elseif self.rotation > math.pi / 2 and self.rotation <= math.pi then
		x = x - self.width / 2
		y = y - self.height / 2
	end
	makepoof(self.x+self.width/2, self.y+self.height/2, "powpoof")
	playsound(boomsound)
	self:destroy()
end

function turret:draw()
	if self.dead then 
		return 
	end
	local dirscale = scale
	if self.dir == "right" then
		dirscale = -dirscale
	end
	
	love.graphics.setColor(255, 255, 255)
	if not self.frenzy then
		love.graphics.draw(self.graphic, turretquad[1], math.floor(((self.x-xscroll)*16+self.offsetX+1)*scale), ((self.y-.5-yscroll)*16+self.offsetY-1)*scale, 0, dirscale, scale, self.quadcenterX, self.quadcenterY)
	else
		love.graphics.draw(self.graphic, turretquad[1], math.floor(((self.x-xscroll)*16+self.offsetX+1)*scale), ((self.y-.5-yscroll)*16+self.offsetY)*scale,  self.rotation, dirscale, scale, self.quadcenterX, self.quadcenterY)
	end

	local shade = 255*(1-turretdarkenfactor*self.timer)
	love.graphics.setColor(shade, shade, shade)

	if not self.frenzy then
		love.graphics.draw(self.graphic, turretquad[2], math.floor(((self.x-xscroll)*16+self.armoffsetX)*scale), ((self.y-.5-yscroll)*16+self.armoffsetY-1)*scale, self.armrotation+self.rotation, dirscale, scale, self.armquadcenterX, self.armquadcenterY)
	else
		love.graphics.draw(self.graphic, turretquad[2], math.floor(((self.x-xscroll)*16+self.armoffsetX)*scale), ((self.y-.5-yscroll)*16+self.armoffsetY)*scale, self.armrotation+self.rotation, dirscale, scale, self.armquadcenterX, self.armquadcenterY)
	end
end

function turret:laser(dir)
	self.frenzy = true
end

function turret:doclearpipe(pipe)
	--freak out when in tube
	self:dofrenzy()
end

function turret:dofrenzy()
	if not self.frenzy then
		self.frenzy = true
		self.frenzytimer = 0
		self.timer = turrettime
	end
end

function turret:bluegel(dir)
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

-------------------------------------------------------------------------------------------------
turretshot = class:new()

function turretshot:init(x, y, tx, ty, r, knockback)
	self.x = x
	self.y = y
	self.tx = tx
	self.ty = ty
	self.timer = 0
	self.knockback = knockback
	--self.hittimer = 0
end

function turretshot:update(dt)
	--self.hittimer = self.hittimer + dt
	--while self.hittimer > turrethitdelay do
		local i = self.timer/turretshotduration
		local startx = self.x + (self.tx - self.x)*i
		local starty = self.y + (self.ty - self.y)*i
		
		local endx = self.x + (self.tx - self.x)*(i+.1)
		local endy = self.y + (self.ty - self.y)*(i+.1)

		if handlePlayerCollisions(startx, starty, endx, endy, self.knockback) then
			return true
		end
	--	self.hittimer = self.hittimer - turrethitdelay
	--end

	self.timer = self.timer + dt
	if self.timer > turretshotduration then
		return true
	end
end

function turretshot:draw()
	local i = self.timer/turretshotduration
	local startx = self.x + (self.tx - self.x)*i
	local starty = self.y + (self.ty - self.y)*i
	
	local endx = self.x + (self.tx - self.x)*(i+.1)
	local endy = self.y + (self.ty - self.y)*(i+.1)
	
	love.graphics.setColor(255, 0, 0)
	local linestyle = love.graphics.getLineStyle()
	local linewidth = love.graphics.getLineWidth()
	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(1*scale)
	love.graphics.line((startx-xscroll)*16*scale, (starty-yscroll-.5)*16*scale, (endx-xscroll)*16*scale, (endy-yscroll-.5)*16*scale)
	if HITBOXDEBUG and (editormode or testlevel) then
		love.graphics.setLineWidth(1)
		handlePlayerCollisions(startx, starty, endx, endy, self.knockback)
	end
	love.graphics.setLineStyle(linestyle)
	love.graphics.setLineWidth(linewidth)
end

function handlePlayerCollisions(sx, sy, ex, ey, knockback)
	local checktable = {"player", "box", "lightbridgebody"}
	for i, v in pairs(checktable) do
		for j, w in pairs(objects[v]) do
			if (not w.dead) then
				local tw = math.abs(ex - sx)
				local th = math.abs(ey - sy)
				
				if HITBOXDEBUG and (editormode or testlevel) then
					love.graphics.setColor(255, 255, 255)
					love.graphics.rectangle("line", (math.min(sx, ex)-xscroll)*16*scale, (math.min(sy, ey)-yscroll-.5)*16*scale, tw*16*scale, th*16*scale)
				end
				if aabb(math.min(sx, ex), math.min(sy, ey), tw, th, w.x, w.y, w.width, w.height) then
					if w.turretshot then
						w:turretshot(math.min(sx, ex)+tw/2, math.min(sy, ey)+th/2, (ex-sx), (ey-sy), knockback)
					end
					return true
				end
			end
		end
	end
end
