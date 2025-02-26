snakeblocksline = class:new()

function snakeblocksline:init(x, y, r)
	--region, type, fill, fill speed, oscillate, link power, link reverse
	self.x = x
	self.y = y

	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)

	self.path = {{self.x+1, self.y}}
	self.length = 3
	self.speed = 5
	self.loop = true
	self.respawn = false
	self.startdir = "right"
	self.firstdir = "right"
	
	if #self.r > 0 and self.r[1] ~= "link" then
		--rightclick things
		if self.r[1]:find("|") then
			local v = convertr(self.r[1], {"string", "num", "num", "bool", "bool"})
			--path
			local s = v[1]:gsub("n", "-")
			local s2 = s:split("`")
			local s3
			for i = 1, #s2 do
				s3 = s2[i]:split(":")
				local x, y = tonumber(s3[1]), tonumber(s3[2])
				if x and y then
					table.insert(self.path, {self.x+x, self.y+y})
				else
					break
				end
			end
			--different origin
			if #self.path > 1 then
				local ox, oy = 1, 0
				local tx, ty = self.path[2][1]-x, self.path[2][2]-y
				if math.abs(ty) <= 1 then
					if tx > 0 then
						--nothing
					else
						ox, oy = tx+1, ty
						self.firstdir = "left"
					end
				elseif ty > 0 then
					ox, oy = tx, ty-1
					self.firstdir = "down"
				else
					ox, oy = tx, ty+1
					self.firstdir = "up"
				end
				if tx < 0 then
					self.startdir = "left"
				end
				self.path[1][1], self.path[1][2] = ox+x, oy+y
			end
			--length
			self.length = math.max(3, v[2])
			--speed
			self.speed = math.max(0.2, v[3])
			--loop
			self.loop = v[4]
			--loop
			self.respawn = v[5]
		end
		table.remove(self.r, 1)
	end

	if #self.path < self.length then
		--don't loop if path is too short
		self.loop = false
	end

	self.animtimer = 0
	self.frame = 1
	self.timer = 0
	self.stage = 0
	self.backstage = self.stage-self.length+1

	self.quadi = 1
	if self.speed > snakeblockspeed then
		self.quadi = 3
	end

	self.checktable = {"player", "goomba", "koopa", "mole", "enemy", "box", "smallspring", "blocktogglebutton", "powblock", "thwomp"} --what can stay/get pushed on moving snake blocks

	self.child = {}
	self.currentchild = 2
	for i = 1, self.length do
		--local tx, ty = self.path[i][1], self.path[i][2]
		local blockx = self.x-self.length+i
		if self.startdir == "left" then
			blockx = self.x+1-i
		end
		local obj = snakeblock:new(blockx, self.y, self, false, self.quadi)
		self.child[i] = obj
		table.insert(objects["snakeblock"], obj)
		if i == 1 then
			obj.visible = false
			obj.active = false
		end
		obj.fallid = i
	end

	self.movingchild = {}
	local firstx = self.x
	if self.startdir == "left" then
		firstx = self.x-self.length+1
	end
	local obj = snakeblock:new(firstx, self.y, self, false, self.quadi)
	self:setstartdir(obj)
	self.movingchild[1] = obj
	self.movingchild[1].push = true
	table.insert(objects["snakeblock"], obj)
	local endx = self.x-self.length+1
	if self.startdir == "left" then
		endx = self.x
	end
	local obj = snakeblock:new(endx, self.y, self, false, self.quadi)
	self.movingchild[2] = obj
	obj.speedx = self.speed
	if self.startdir == "left" then
		obj.speedx = -self.speed
	end
	table.insert(objects["snakeblock"], obj)

	self.linked = false
	self.power = false
	self.falltimer = false
	self.falling = false
	self.felled = 0

	self.respawntimer = false

	self.sinewave = 0
end

function snakeblocksline:update(dt)
	if self.delete then
		return true
	end

	if self.respawntimer then
		self.respawntimer = self.respawntimer - dt
		if self.respawntimer < 0 then
			self:dorespawn()
		end
	elseif self.falling then

	elseif self.falltimer then
		self.falltimer = self.falltimer - dt
		if self.falltimer < 0 then
			self:fall()
		end
	elseif self.power then
		--move blocks
		self.timer = self.timer + dt*self.speed
		while self.timer > 1 do
			self.stage = self.stage + 1
			self.backstage = self.backstage + 1
			if not self.path[self.stage] then
				if self.loop then
					--loop
					self.stage = 1
				else
					--start falling
					self:startfalling()
					break
				end
			end
			if self.backstage > #self.path and self.loop then
				self.backstage = self.stage-self.length+1
			end
			--move block in back to the front
			local oldchildx, oldchildy = self.child[self.currentchild].x, self.child[self.currentchild].y
			self.child[self.currentchild].x = self.path[self.stage][1]-1
			self.child[self.currentchild].y = self.path[self.stage][2]-1
			--change fall ids (current child get set to the length, every other is pushed back)
			for i = 1, self.length do
				if i == self.currentchild then
					self.child[i].fallid = self.length
				elseif i ~= 1 then
					self.child[i].fallid = self.child[i].fallid-1
				end
			end
			self.currentchild = (self.currentchild%(self.length))+1
			if self.currentchild == 1 then
				self.currentchild = 2
			end
			self.child[1].x = oldchildx
			self.child[1].y = oldchildy
			self:updatemovingchildspeed()

			self.timer = self.timer - 1
		end
	end
end

function snakeblocksline:updatemovingchildspeed()
	--moving child front
	local dir = self.startdir
	local ox, oy = math.floor(self.movingchild[1].x+0.5)+1, math.floor(self.movingchild[1].y+0.5)+1
	if self.path[self.stage] then
		ox, oy = self.path[self.stage][1], self.path[self.stage][2]
	end
	local nextstage = self.stage+1
	if nextstage > #self.path then nextstage = 1 end
	if self.path[nextstage] then
		local nx, ny = self.path[nextstage][1], self.path[nextstage][2]
		if nx < ox then
			dir = "left"
		elseif ny > oy then
			dir = "down"
		elseif ny < oy then
			dir = "up"
		else
			dir = "right"
		end
	end
	self.movingchild[1].x = self.path[self.stage][1]-1
	self.movingchild[1].y = self.path[self.stage][2]-1
	self.movingchild[1].dx = self.movingchild[1].x
	self.movingchild[1].dy = self.movingchild[1].y
	if self.stage == #self.path and not self.loop then
		self.movingchild[1].speedx = 0
		self.movingchild[1].speedy = 0
	elseif dir == "right" then
		self.movingchild[1].speedx = self.speed
		self.movingchild[1].speedy = 0
	elseif dir == "left" then
		self.movingchild[1].speedx = -self.speed
		self.movingchild[1].speedy = 0
	elseif dir == "down" then
		self.movingchild[1].speedx = 0
		self.movingchild[1].speedy = self.speed
	elseif dir == "up" then
		self.movingchild[1].speedx = 0
		self.movingchild[1].speedy = -self.speed
	end
	--moving child back
	local dir = self.startdir
	local nextstage = self.backstage+1
	if nextstage > #self.path then nextstage = 1 end
	if self.path[nextstage] then
		local ox, oy = math.floor(self.movingchild[2].x+0.5)+1, math.floor(self.movingchild[2].y+0.5)+1
		if self.path[self.backstage] then
			ox, oy = self.path[self.backstage][1], self.path[self.backstage][2]
		end
		local nx, ny = self.path[nextstage][1], self.path[nextstage][2]
		if nx < ox then
			dir = "left"
		elseif ny > oy then
			dir = "down"
		elseif ny < oy then
			dir = "up"
		else
			dir = "right"
		end
		self.movingchild[2].x = ox-1
		self.movingchild[2].y = oy-1
		self.movingchild[2].dx = self.movingchild[2].x
		self.movingchild[2].dy = self.movingchild[2].y
	end
	if self.stage == #self.path and not self.loop then
		self.movingchild[2].speedx = 0
		self.movingchild[2].speedy = 0
	elseif dir == "right" then
		self.movingchild[2].speedx = self.speed
		self.movingchild[2].speedy = 0
	elseif dir == "left" then
		self.movingchild[2].speedx = -self.speed
		self.movingchild[2].speedy = 0
	elseif dir == "down" then
		self.movingchild[2].speedx = 0
		self.movingchild[2].speedy = self.speed
	elseif dir == "up" then
		self.movingchild[2].speedx = 0
		self.movingchild[2].speedy = -self.speed
	end
end

function snakeblocksline:startfalling()
	self.child[1].active = true
	self.child[1].visible = true
	self.movingchild[1].speedx = 0
	self.movingchild[1].active = false
	self.movingchild[1].visible = false
	self.movingchild[2].active = false
	self.movingchild[2].visible = false
	self.falltimer = snakeblockfalltime
	for i = 1, #self.child do
		self.child[i].shake = true
	end
end

function snakeblocksline:fall()
	self.falling = true
	for i = 1, #self.child do
		--start falling
		--but they're out of order for some reason
		self.child[i]:startfalling(self.child[i].fallid)
		self.child[i].shake = false
	end
end

function snakeblocksline:fell()
	self.felled = self.felled + 1
	if self.felled >= self.length then
		if self.respawn then
			self.felled = 0
			self.respawntimer = 3
			self.power = false
		else
			for i = 1, #self.child do
				self.child[i].delete = true
			end
			self.movingchild[1].delete = true
			self.movingchild[2].delete = true
			self.delete = true
		end
	end
end

function snakeblocksline:dorespawn()
	self.falling = false
	self.falltimer = false
	self.respawntimer = false
	self.stage = 0
	self.timer = 0
	self.backstage = self.stage-self.length+1
	self.currentchild = 2
	for i = 1, self.length do
		self.child[i].x = self.x-self.length+i-1
		self.child[i].y = self.y-1
		self.child[i].quadi = self.quadi
		self.child[i].fell = false
		self.child[i]:setquad()
		self.child[i].speedy = 0
		self.child[i]:move(false)
		if i == 1 then
			self.child[i].visible = false
			self.child[i].active = false
		end
		makepoof(self.child[i].x+.5, self.child[i].y+.5, "makerpoof")
	end
	self.movingchild[1].active = true
	self.movingchild[1].visible = true
	self.movingchild[1].x = self.x-1
	self.movingchild[1].y = self.y-1
	self.movingchild[1].dx = false
	self.movingchild[1].dy = false
	self.movingchild[1].speedx = self.speed
	self.movingchild[1].speedy = 0
	self:setstartdir(self.movingchild[1])
	self.movingchild[1]:move(self.power)
	self.movingchild[1].quadi = self.quadi
	self.movingchild[1]:setquad()
	self.movingchild[2].active = true
	self.movingchild[2].visible = true
	self.movingchild[2].x = self.x-self.length
	self.movingchild[2].y = self.y-1
	self.movingchild[2].dx = false
	self.movingchild[2].dy = false
	self.movingchild[2].speedx = self.speed
	self.movingchild[2].speedy = 0
	self.movingchild[2]:move(self.power)
	self.movingchild[2].quadi = self.quadi
	self.movingchild[2]:setquad()
end

function snakeblocksline:setstartdir(obj)
	--first snake block automatically goes right, adjust it to follow to set starting direction
	obj.speedx = 0
	obj.speedy = 0
	if self.firstdir == "up" then
		obj.speedy = -self.speed
	elseif self.firstdir == "down" then
		obj.speedy = self.speed
	elseif self.firstdir == "left" then
		obj.speedx = -self.speed
	else
		obj.speedx = self.speed
	end
end

function snakeblocksline:link()
	while #self.r >= 3 do
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[2]) == v.cox and tonumber(self.r[3]) == v.coy then
					self.linked = true
					v:addoutput(self, self.r[4] or "power")
				end
			end
		end
		
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
	end
end

function snakeblocksline:powerswitch(power)
	if self.falling or self.falltimer or self.respawntimer then
		return
	end
	self.power = power
	self.movingchild[1]:move(self.power)
	self.movingchild[2]:move(self.power)
end

function snakeblocksline:input(t, input)
	if input == "power" then
		if t == "on" then
			self.power = true
		elseif t == "off" then
			self.power = false
		else
			self.power = not self.power
		end
		self:powerswitch(self.power)
	end
end
----------------------------------------------------------------------------------------------
snakeblock = class:new()

function snakeblock:init(x, y, parent, moving, quadi)
	--PHYSICS STUFF
	self.x = x-1
	self.y = y-1
	self.speedy = 0
	self.speedx = 0
	self.width = 1
	self.height = 1
	self.static = true
	self.active = true
	self.gravity = 0
	self.category = 2
	self.parent = parent
	self:move(moving)
	
	self.mask = {	true, 
					true, false, false, false, false,
					false, true, false, true, false,
					false, false, true, false, false,
					true, true, false, false, false,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	
	self.emancipatecheck = false
	self.autodelete = false
	self.drawable = false
	self.visible = true
	self.portalable = false
	
	self.rotation = 0 --for portals
	self.graphic = snakeblockimg
	self.quadi = quadi or 1
	self.quad = starquad[spriteset][self.quadi]
	self.offsetX = 8
	self.offsetY = 0
	self.quadcenterX = 8
	self.quadcenterY = 8

	self.shot = false
	self.explodetimer = 0
	self.scale = 1

	self.falling = false
	self.fell = false
	self.falltimer = false

	self.shake = false
	self.shaketimer = 0

	self.light = 2
end

function snakeblock:update(dt)
	if self.delete then
		return true
	elseif self.fell then
		return false
	end
	if self.dx and self.dy then
		if math.abs(self.x-self.dx) > 2 or math.abs(self.y-self.dy) > 2 then
			self.speedx = 0
			self.speedy = 0
		end
	end
	if self.shake then
		self.shaketimer = self.shaketimer + 2*dt
		if self.shaketimer > 0.1 then
			self.offsetX = ((self.offsetX-8)%2+7)
			self.shaketimer = 0
		end
	end
	if self.falltimer then
		self.falltimer = self.falltimer - 2*dt
		if self.falltimer < 0 then
			self.falltimer = false
			self:fall()
		end
	end
	if self.moving and self.active then
		for i, v in pairs(self.parent.checktable) do
			for j, w in pairs(objects[v]) do
				if (w.active) and (not w.static) and (not w.shot) and (not w.flying) and (not w.ignoreplatform) then
					--if self.speedy ~= 0 then --vertical carry
						if not w.jumping and inrange(w.x, self.x-w.width, self.x+self.width) then
							if inrange(w.y, self.y - w.height - 50*dt, self.y - w.height + 50*dt) then
								self.active = false
								local pass = false
								local condition = false
								if self.speedy < 0 then
									condition = "ignoreplatforms"
								end
								pass = (#checkrect(w.x, self.y - w.height, w.width, w.height, {"exclude", w}, true, condition) == 0)
								if pass then
									w.y = self.y - w.height
									--w.falling = false
									--w.falloverride = true
									w.speedy = self.speedy
								end
								self.active = true
							end
						end
					--end
					if self.speedx ~= 0 and self.push then --horizontal push
						if inrange(w.y+w.height/2, self.y, self.y+self.height) then
							if self.speedx > 0 and w.x < self.x+self.width and w.x+w.width > self.x+self.width then --right
								if #checkrect(self.x+self.width, w.y, w.width, w.height, {"exclude", w}, true, "ignoreplatforms") == 0 then
									w.oldxplatform = w.x
									w.x = self.x+self.width
									--w.speedx = math.max(self.speedx, w.speedx)
								end
							elseif self.speedx < 0 and w.x+w.width > self.x and w.x < self.x then
								if #checkrect(self.x-w.width, w.y, w.width, w.height, {"exclude", w}, true, "ignoreplatforms") == 0 then
									w.oldxplatform = w.x
									w.x = self.x-w.width
									--w.speedx = math.min(self.speedx, w.speedx)
								end
							end
						end
					end
				end
			end
		end
	end
	if self.y > mapheight then
		self.fell = true
		self.parent:fell()
	end
	return false
end

function snakeblock:draw()
	if self.visible then
		love.graphics.draw(self.graphic, self.quad, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), 0, scale, scale, self.quadcenterX, self.quadcenterY)
	end
end

function snakeblock:setquad()
	self.quad = starquad[spriteset][self.quadi]
end

function snakeblock:hit()
	playsound(blockhitsound)
end

function snakeblock:move(moving)
	self.moving = moving
	if self.moving then
		self.static = false
	else
		self.static = true
	end
end

function snakeblock:startfalling(i)
	if i == 1 then
		self:fall()
	else
		self.falltimer = 0.3*(i-1)
		self.offsetX = 8
		self.shake = false
	end
end

function snakeblock:fall()
	self:move(true)
	self.speedx = 0
	self.speedy = snakeblockfallspeed
	self.falling = true
	self.offsetX = 8
	self.shake = false

	self.quadi = self.quadi + 1
	self:setquad()
end

function snakeblock:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "thwomp" or a == "skewer" or (a == "koopa" and b.small) then
		self:hit()
	end
	return false
end

function snakeblock:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "thwomp" or a == "skewer" or (a == "koopa" and b.small) then
		self:hit()
	end
	return false
end

function snakeblock:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "player" and not self.parent.linked and not self.parent.power then
		self.parent:powerswitch(true)
	end
	if a == "thwomp" or a == "skewer" or a == "icicle" then
		self:hit()
	end
	return false
end

function snakeblock:globalcollide(a, b)
	
end

function snakeblock:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if self.falling then
		return false
	end
	if a == "player" then
		b.speedy = math.max(self.speedy+2, b.speedy)
	end
	if a == "player" or a == "skewer" then
		self:hit()
	end
	return false
end

function snakeblock:passivecollide(a, b)
	return false
end