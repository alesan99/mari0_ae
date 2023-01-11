redseesaw = class:new()

function redseesaw:init(x, y, size)
	--PHYSICS STUFF
	self.cox = x
	self.coy = y--+(4/16)
	self.x = (x-1)+.5
	self.y = (y-1)+.5
	self.speedy = 0
	self.speedx = 0
	self.speed = 0
	self.targetspeed = 0
	self.width = 1
	self.height = 8/16
	self.offset = -self.height
	self.static = false
	self.active = false
	self.category = 15

	self.size = size or 6
	
	self.mask = {	true, 
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true}
	--[[self.mask = {	true, 
					false, false, false, false, false,
					false, true, false, true, false,
					false, false, true, false, false,
					true, true, false, false, false,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}]]
	
	self.emancipatecheck = true
	self.autodelete = false
	self.drawable = false
	
	self.rotation = math.pi*.5
	self.restrotation = math.pi*.5

	self.checktable = {"player", "enemy", "mushroom", "oneup", "star", "box", "smallspring", "powblock", "thwomp", "fireball", "pbutton", "levelball", "plantfire", "ice", "cannonballcannon"}
	for i, v in pairs(enemies) do
		if objects[v] then
			table.insert(self.checktable, v)
		end
	end
	self.trackable = true
	self.trackoffsetx = .5
	self.trackoffsety = 4/16
	self.trackanimtimer = 1
end

function redseesaw:update(dt)
	--self.rotation = self.rotation + dt
	--self.rotation = math.min(math.max(self.rotation, -math.pi*.25), math.pi*.25)
	self.targetspeed = 0
	local speedmultiplier = 0.005 --due to bad math, seesaws used to be frame dependent. now it isn't, but a multiplier needs to be chosen to match how it used to act at ~200fps

	local sr = self.size/2 --size radius
	local x1, x2 = self.x+math.sin(self.rotation-math.pi)*sr, self.x+math.sin(self.rotation)*sr --extents of seesaw
	local y1, y2 = self.y+math.cos(self.rotation-math.pi)*sr, self.y+math.cos(self.rotation)*sr --slope
	
	local updatetable = {}
	for i, v in pairs(self.checktable) do --Make mario stay on donut when donut is falling (makes mario fall through ground)
		for j, w in pairs(objects[v]) do
			if w.active and (not w.static) and (not (v == "player" and w.jumping)) and (not w.shot) and inrange(w.x+w.width/2, x1, x2) then
				if (not (w.mask and w.mask[self.category] == true)) and (not w.ignoreplatform) then --collides?
					local locationn = (((w.x+w.width/2)-x1)/(x2-x1)) --0-1
					local locationn2 = ((locationn-.5)*2) -- -1 - 1
					local targety = y1+(locationn*(y2-y1))+self.offset
					if inrange(w.y+w.height, targety-w.height/5, targety+w.height/2) or (w.y <= targety-w.height and w.y+w.speedy*dt >= targety-w.height) then
						local prehold, hold = true, true
						
						if v == "thwomp" then
							if w.hitground then
								hold = false
							end
						end

						if (w.y+w.height >= targety) and w.speedy >= 0 then
							if v == "player" then
								if w.falling and (not w.falloverride) and (not w.redseesaw) then
									--w:floorcollide("redseesaw", self)
								end
								if w.falling then
									animationsystem_playerlandtrigger(w.playernumber)
								end
								w.falling = false
								w.falloverride = true
								w.redseesaw = 0.1
								w.gravity = 0
							elseif v == "thwomp" then
								if w.t == "down" and w.attack and not w.hitground then
									self.speed = self.speed - (w.speedy*locationn2)
									w:pound()
									hold = false
									prehold = false
								end
								if w ~= "thwimp" and targety-w.height > w.y then --only go up
									prehold = false
								end
							elseif v == "box" and w.t == "edgeless" then
								w.speedx = w.speedx - (self.rotation-self.restrotation)*200*dt
							elseif v == "spikeball" and w.rolling then
								w.speedx = w.speedx - (self.rotation-self.restrotation)*200*dt
							elseif v == "fireball" then
								w:floorcollide("redseesaw", self)
							end

							local condition = "ignoreplatforms"
							if (self.speed*locationn2) < 0 then
								condition = false
							end
							--if prehold and #checkrect(w.x, targety-w.height, w.width, w.height, {"tile", "buttonblock", "flipblock", "platform", "donut"}, true, condition) == 0 then
							if prehold and not checkintile(w.x, targety-w.height, w.width, w.height, tileentities, w, condition) then
								w.y = targety-w.height
								w.speedy = math.min(0, w.speedy)
								w:floorcollide("redseesaw", self)
								if w.postfloorcollide then
									w:postfloorcollide("redseesaw", self)
								end
							end
						end

						if w.speedy >= 0 and hold then
							if math.ceil(w.y+w.height) >= targety then --make objects stay on tiles
								self.targetspeed = self.targetspeed - ( (locationn2*450*(w.weight or 1))*speedmultiplier--[[ *dt]])
							end
							--update their posistion after the seesaw moves aswell!
							table.insert(updatetable, {v, w, locationn})
							if v == "player" then
								w.falloverride = true
								w.redseesaw = 0.1
							end
							if (w.y <= targety-w.height and w.y+w.speedy*dt >= targety-w.height) and ((not v == "thwomp") and w.speedy >= 0 and w.attack) then
								w.speedy = math.min(0, w.speedy)
							end
						end
					end
				end
			end
		end
	end

	--if self.targetspeed == 0 then
		if self.rotation > self.restrotation then
			self.targetspeed = self.targetspeed - 80* speedmultiplier--[[*dt]] --40 in 60fps
			if self.rotation+self.speed*dt < self.restrotation then
				self.targetspeed = self.speed/2
				--self.speed = self.speed*0.9
			end
		elseif self.rotation < self.restrotation then
			self.targetspeed = self.targetspeed + 80* speedmultiplier--[[*dt]]
			if self.rotation+self.speed*dt > self.restrotation then
				self.targetspeed = self.speed/2
				--self.speed = self.speed*0.9
			end
		end
	--else
		if self.speed > self.targetspeed then
			self.speed = math.max(self.targetspeed, self.speed - 2*dt)
		elseif self.speed < self.targetspeed then
			self.speed = math.min(self.targetspeed, self.speed + 2*dt)
		end
	--end

	self.rotation = math.min(math.max(self.rotation+self.speed*dt, math.pi*.25), math.pi*.75)
	if self.rotation == math.pi*.75 then
		self.speed = -math.abs(self.speed)/2
	elseif self.rotation == math.pi*.25 then
		self.speed = math.abs(self.speed)/2
	end

	local dx = 0
	if self.track and self.oldx then
		dx = self.x - self.oldx
		self.trackanimtimer = (((self.trackanimtimer + 4*dt)-1)%2)+1
	end

	local x1, x2 = self.x+math.sin(self.rotation-math.pi)*sr, self.x+math.sin(self.rotation)*sr
	local y1, y2 = self.y+math.cos(self.rotation-math.pi)*sr, self.y+math.cos(self.rotation)*sr
	for a, b in pairs(updatetable) do
		local v, w, locationn1 = b[1], b[2], b[3]
		local locationn = (((w.x+w.width/2)-x1)/(x2-x1)) --0-1
		local targetx = (self.x-.5-((x2-x1)/2))+(locationn1*(x2-x1))
		local targety = y1+(locationn1*(y2-y1))+self.offset
		local wy = targety-w.height
		local wx = targetx+(-.5*(w.width*16)+8)/16+dx --listen, i don't know what this means
		--12/16 needs +2/16 offset
		--24/16 needs -4/16 offset
		--i just made an equation to account for these two, it might not work for everything
		--if #checkrect(wx, wy, w.width, w.height, {"tile", "buttonblock", "flipblock", "platform", "donut"}, true) == 0 and not (v == "thwomp" and wy > w.y) then --don't click
		if not checkintile(wx, wy, w.width, w.height, tileentities, w) and not (v == "thwomp" and wy > w.y) then --don't click
			w.y = wy
			w.x = wx

			--turn around edge
			if v == "drybones" or (v == "koopa" and w.t == "red" and not w.small) or (v == "goomba" and (w.t == "goombrat" or w.t == "spiketop" or w.t == "wiggler")) or (w.turnaroundoncliff and not w.small) then
				if not inrange(w.x+w.width/2+w.speedx*dt, x1, x2) then
					if w.speedx < 0 then
						w.animationdirection = "left"
					else
						w.animationdirection = "right"
					end
					w.speedx = -w.speedx
				end
			end
		end
	end
	
	if self.track then
		self.oldx = self.x
		self.oldy = self.y
	end

	return false
end

function redseesaw:draw()
	love.graphics.push()
	love.graphics.translate((self.x-xscroll)*16*scale, (self.y-yscroll-.5)*16*scale)
	love.graphics.rotate(-self.rotation-math.pi/2)
	--love.graphics.rectangle("fill", (-self.size/2)*16*scale, 0, (self.size)*16*scale, (-self.offset)*16*scale)
	for i = 1, math.ceil(self.size) do
		local q = 2
		local x = ((-self.size/2)+(i-1))
		if i == 1 then
			q = 1
		elseif i == math.ceil(self.size) then
			q = 3
			x = x - (self.size-math.floor(self.size))
		end
		love.graphics.draw(redseesawimg, redseesawquad[spriteset][q], x*16*scale, (8/16)*16*scale, 0, scale, -scale)
	end
	love.graphics.pop()
	love.graphics.push()
	love.graphics.translate((self.x-xscroll)*16*scale, (self.y-yscroll-.5)*16*scale)
	if self.track then
		love.graphics.draw(platformtrackimg, goombaquad[3][math.floor(self.trackanimtimer)], (-.5)*16*scale, (-6/16)*16*scale, 0, scale, scale)
	else
		love.graphics.draw(redseesawimg, redseesawquad[spriteset][4], (-.5)*16*scale, (-5/16)*16*scale, 0, scale, scale)
	end
	love.graphics.pop()
end

function redseesaweditordraw(dx, dy, size)
	for i = 1, math.ceil(size) do
		local q = 2
		local x = ((-size/2)+(i-1))
		if i == 1 then
			q = 1
		elseif i == math.ceil(size) then
			q = 3
			x = x - (size-math.floor(size))
		end
		love.graphics.draw(redseesawimg, redseesawquad[spriteset][q], (x*16*scale)+((dx-xscroll+.5)*16*scale), (16*scale)+(((dy-yscroll-1.5)*16*scale)), 0, scale, scale)
	end
	love.graphics.draw(redseesawimg, redseesawquad[spriteset][4], (-.5)*16*scale+((dx-xscroll+.5)*16*scale), (-5/16)*16*scale+(((dy-yscroll)*16*scale)), 0, scale, scale)
end

function redseesaw:rightcollide(a, b)
	return false
end

function redseesaw:leftcollide(a, b)
	return false
end

function redseesaw:ceilcollide(a, b)
	return false
end

function redseesaw:floorcollide(a, b)
	return false
end

function redseesaw:passivecollide(a, b)
	return false
end

function redseesaw:dotrack()
	self.track = true
	self.active = true
end