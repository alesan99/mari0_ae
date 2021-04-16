plantcreeper = class:new()

function plantcreeper:init(x, y, r)
	--path
	self.cox = x
	self.coy = y

	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)

	self.path = {{self.cox, self.coy}}
	self.sleeping = false

	self.x = x-28/16
	self.y = y-20/16
	self.speedy = 0
	self.speedx = 0
	self.width = 24/16
	self.height = 24/16
	self.static = true
	self.active = true
	self.portalable = false
	self.category = 29
	self.mask = {true}

	self.drawable = true
	self.graphic = plantcreeperimg
	self.quadi = 1
	self.quadioffset = 0
	self.quad = plantcreeperquad.head[self.quadi+self.quadioffset]
	self.animtimer = 0
	self.offsetX = 12
	self.offsetY = -4
	self.quadcenterX = 16
	self.quadcenterY = 16
	
	if #self.r > 0 and self.r[1] ~= "link" then
		--rightclick things
		--if self.r[1]:find("|") then
			--n1:2`0:2`1:2:joint`1:1
			local v = convertr(self.r[1], {"string", "bool"})
			--path
			local s = v[1]:gsub("n", "-")
			local s2 = s:split("`")
			local s3
			for i = 1, #s2 do
				s3 = s2[i]:split(":")
				local x, y = tonumber(s3[1]), tonumber(s3[2])
				if x and y then
					table.insert(self.path, {self.cox+x, self.coy+y})
				else
					break
				end
			end
			self.sleeping = v[2]
		--end
		table.remove(self.r, 1)
	end

	self.start = 1 --start stage (different for down and right)

	local dir = "left"
	self.children = {}
	for i = 1, #self.path-1 do
		local tx, ty = self.path[i][1], self.path[i][2]
		local quadi = 2
		local ignore, turn = false, false
		--get direction
		if self.path[i+1] then
			if self.path[i+1][2] < ty then
				dir = "up"
			elseif self.path[i+1][2] > ty then
				dir = "down"
			end
			if self.path[i+1][1] < tx then
				dir = "left"
			elseif self.path[i+1][1] > tx then
				dir = "right"
			end
		end
		--set start stage
		if i == 1 and (dir == "down" or dir == "right") then
			self.start = math.min(#self.path, 2)
		end

		self.path[i].dir = dir
		if (self.path[i-1] and self.path[i+1] and i ~= #self.path) and not 
			((self.path[i+1][1] ~= self.path[i-1][1] and self.path[i+1][2] == self.path[i-1][2])
			or (self.path[i+1][2] ~= self.path[i-1][2] and self.path[i+1][1] == self.path[i-1][1]))	then

			if (self.path[i+1][1] == tx+1 and self.path[i+1][2] == ty and self.path[i-1][1] == tx and self.path[i-1][2] == ty+1)
			or (self.path[i+1][1] == tx and self.path[i+1][2] == ty+1 and self.path[i-1][1] == tx+1 and self.path[i-1][2] == ty) then
				turn = "c1"
			elseif (self.path[i+1][1] == tx-1 and self.path[i+1][2] == ty and self.path[i-1][1] == tx and self.path[i-1][2] == ty+1)
			or (self.path[i+1][1] == tx and self.path[i+1][2] == ty+1 and self.path[i-1][1] == tx-1 and self.path[i-1][2] == ty) then
				turn = "c2"
			elseif (self.path[i+1][1] == tx and self.path[i+1][2] == ty-1 and self.path[i-1][1] == tx+1 and self.path[i-1][2] == ty)
			or (self.path[i+1][1] == tx+1 and self.path[i+1][2] == ty and self.path[i-1][1] == tx and self.path[i-1][2] == ty-1) then
				turn = "c3"
			else
				turn = "c4"
			end
		elseif (self.path[i-1] and self.path[i-2] and i ~= #self.path) and 
			((dir == "right" and self.path[i][2] ~= self.path[i-1][2]) 
			or (dir == "left" and self.path[i][2] == self.path[i-1][2] and self.path[i][2] ~= self.path[i-2][2]) 
			or (dir == "down" and self.path[i][1] ~= self.path[i-1][1]) 
			or (dir == "up" and self.path[i][1] == self.path[i-1][1] and self.path[i][1] ~= self.path[i-2][1])) then
			--is the path 2 tiles ago in a different direction?
			ignore = true
		elseif (self.path[i+1] and self.path[i+2] and i ~= #self.path) and
			((dir == "left" and self.path[i][2] ~= self.path[i+1][2]) 
			or (dir == "right" and self.path[i][2] == self.path[i+1][2] and self.path[i][2] ~= self.path[i+2][2]) 
			or (dir == "up" and self.path[i][1] ~= self.path[i+1][1]) 
			or (dir == "down" and self.path[i][1] == self.path[i+1][1] and self.path[i][1] ~= self.path[i+2][1])) then
			--is the path 2 tiles ahead in a different direction?
			ignore = true
		end
		self.path[i].turn = turn or false
		if not ignore then
			local sx, sy = tx-.5, ty-.5
			if not turn then
				if dir == "left" or dir == "right" then
					sx = tx
				elseif dir == "up" or dir == "down" then
					sy = ty
				end
			elseif turn == "c2" then
				sx = sx - 2/16
			elseif turn == "c3" then
				sy = sy - 2/16
			elseif turn == "c4" then
				sx = sx - 2/16
				sy = sy - 2/16
			end
			local obj = plantcreepersegment:new(sx, sy, dir, turn)
			if i ~= 1 then
				obj.active = false
			end
			self.children[i] = obj
			self.path[i].dir = dir
			table.insert(objects["plantcreepersegment"], obj)
		end
	end
	--tack on extra path
	if dir == "down" then
		table.insert(self.path, {self.path[#self.path][1], self.path[#self.path][2]+1})
	elseif dir == "right" then
		table.insert(self.path, {self.path[#self.path][1]+1, self.path[#self.path][2]})
	end

	--don't go past selected path
	if #self.path > 2 then
		table.remove(self.path, #self.path)
	end

	self.stage = self.start
	self.targetstage = #self.path
	self.movingdir = "forward"
	if self.sleeping then
		self.quadioffset = 2
		self.quad = plantcreeperquad.head[self.quadi+self.quadioffset]
		--self.stage = #self.path
		--self.targetstage = #self.path
	end
	self.dir = "right"

	self.hittimer = 0
	self.waittimer = 0
	self.stomped = false
	self.stompable = true
	self.killsontop = false
	self.killsonbottom = true
	self.killsonsides = true

	self.properenemyspawn = false --starts moving when onscreen, like a normal entitiy
end

function plantcreeper:update(dt)
	if self.delete then
		return true
	end

	if not self.properenemyspawn then
		if onscreen(self.x-1, self.y-1, self.width+2, self.height+2) then
			self.properenemyspawn = true
		else
			return false
		end
	end

	--animation
	if (not self.stomped) and (not (self.sleeping and self.targetstage <= self.stage)) and (not (self.dir == "up")) then
		self.animtimer = self.animtimer + dt
		while self.animtimer > plantanimationdelay do
			self.animtimer = self.animtimer - plantanimationdelay
			if self.quadi == 1 then
				self.quadi = 2
			else
				self.quadi = 1
			end
			self.quad = plantcreeperquad.head[self.quadi+self.quadioffset]
		end
	else
		self.quad = plantcreeperquad.head[2+self.quadioffset]
	end

	--invincibility
	if self.hittimer > 0 then
		self.hittimer = self.hittimer - dt
		if self.hittimer <= 0 then
			self.stompbounce = false
		end
	end

	--wait before moving
	if self.waittimer > 0 then
		self.waittimer = self.waittimer - dt
		if self.waittimer <= 0 then
			self.stomped = false
		end
		return false
	end

	--update stage
	local oldstage = self.stage
	local nextstage
	local speed = plantcreeperspeed
	if self.stomped then
		speed = plantcreeperstompspeed*((math.abs(self.stage-self.targetstage)+1)/plantcreeperstompdist)
	end
	if self.targetstage >= self.stage then
		self.stage = math.min(self.targetstage, self.stage + speed*dt)
		nextstage = self.path[self:getstage(self.stage)+1]
	else
		self.stage = math.max(self.targetstage, self.stage - speed*dt)
		nextstage = self.path[self:getstage(self.stage)-1]
	end

	if self.path[math.floor(self.stage)] and self.path[math.floor(self.stage)].dir then
		if self.path[math.floor(self.stage)].dir == "left" then
			self.rotation = math.pi*1.5
			self.dir = "left"
			self.stompable = true
		elseif self.path[math.floor(self.stage)].dir == "right" then
			self.rotation = math.pi*.5
			self.dir = "right"
			self.stompable = true
		elseif self.path[math.floor(self.stage)].dir == "down" then
			self.rotation = math.pi
			self.dir = "down"
			self.stompable = true
		else
			self.rotation = 0
			self.dir = "up"
			self.stompable = true
		end
		if self.stomped then
			self.stompable = true
		end
	end

	--update children
	if self:getstage(oldstage) ~= self:getstage(self.stage) then
		if oldstage > self.stage then --backwards
			if self.children[self:getstage(self.stage)] then
				self.children[self:getstage(self.stage)].active = false
			end
			if self.children[self:getstage(self.stage)-1] then
				self.children[self:getstage(self.stage)-1].active = false
			end
		else --forwards
			if self.children[self:getstage(self.stage)-2] then
				self.children[self:getstage(self.stage)-2].active = true
			end
			if self.children[self:getstage(self.stage)-1] then
				self.children[self:getstage(self.stage)-1].active = true
			end
		end
	end

	--move
	local addx, addy = 0, 0
	local v = (math.abs(self.stage)%1)
	if nextstage and self.path[self:getstage(self.stage)] then
		if self.targetstage < self.stage then
			addx = nextstage[1]-self.path[self:getstage(self.stage)][1]
			addy = nextstage[2]-self.path[self:getstage(self.stage)][2]
			v = 1-v
		else
			addx = nextstage[1]-self.path[self:getstage(self.stage)][1]
			addy = nextstage[2]-self.path[self:getstage(self.stage)][2]
		end
	else
		--[[stop object from being frozen
		if dir == "right" then
			addx = 1
		elseif dir == "down" then
			addy = 1
		elseif dir == "up" then
			addy = -1
		elseif dir == "left" then
			addx = -1
		end
		if b.clearpipe.dir == "backwards" and b.clearpipe.stage < #self.path then
			addx = -addx
			addy = -addy
			v = 1-v
		end]]
	end
	--keep object in position
	--b.speedx = 0
	--b.speedy = 0
	self.x = self.path[self:getstage(self.stage)][1]-1-self.width/2 + addx*v
	self.y = self.path[self:getstage(self.stage)][2]-1-self.height/2 + addy*v

	--move back and forth
	if self.stage == self.targetstage then
		if self.stomped then
			if self.stage <= self.start then
				self:destroy()
			else
				--self.stomped = false
				--if not self.sleeping then
					self.targetstage = #self.path
				--end
				if self.sleeping then
					self.waittimer = plantcreepersleepingstomptime
				else
					self.waittimer = plantcreeperstomptime
				end
			end
		elseif not self.sleeping then
			if self.movingdir == "forward" then
				self.targetstage = self.start
				self.movingdir = "backwards"
				self.waittimer = plantcreeperouttime
			else
				self.targetstage = #self.path
				self.movingdir = "forward"
				self.waittimer = plantcreeperintime
			end
		end
	end
end

function plantcreeper:getstage(stage)
	if self.targetstage >= self.stage then
		return math.max(self.start, math.min(#self.path, math.floor(stage)))
	else
		return math.max(self.start, math.min(#self.path, math.ceil(stage)))
	end
end

function plantcreeper:draw()
	--cut off body under head
	local radius = 12
	local turn = false
	if (self.path[math.floor(self.stage)].turn) or not self.children[math.floor(self.stage)] then
		radius = 12
		turn = true
	end
	love.graphics.stencil(function()
		love.graphics.circle("fill", math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale, 8), radius*scale)
		if turn then
			if self.dir == "up" then
				love.graphics.rectangle("fill", math.floor(((self.x-xscroll-1)*16+self.offsetX+(32-radius*2)/2)*scale), math.floor(((self.y-yscroll-1.2)*16-self.offsetY)*scale, 8), (radius*2)*scale, 16*scale)
			elseif self.dir == "down" then
				love.graphics.rectangle("fill", math.floor(((self.x-xscroll-1)*16+self.offsetX+(32-radius*2)/2)*scale), math.floor(((self.y-yscroll+0.2)*16-self.offsetY)*scale, 8), (radius*2)*scale, 16*scale)
			elseif self.dir == "right" then
				love.graphics.rectangle("fill", math.floor(((self.x-xscroll+0.2)*16+self.offsetX)*scale), math.floor(((self.y-yscroll-1)*16-self.offsetY+(32-radius*2)/2)*scale, 8), 16*scale, (radius*2)*scale)
			else
				love.graphics.rectangle("fill", math.floor(((self.x-xscroll-1.2)*16+self.offsetX)*scale), math.floor(((self.y-yscroll-1)*16-self.offsetY+(32-radius*2)/2)*scale, 8), 16*scale, (radius*2)*scale)
			end
		end
	end, "increment")
	love.graphics.setStencilTest("less", 1)

	--[[plantcreeperquad[1]:setViewport(112, 32+16*(self.stage%1), 16, 16, 128, 64)
	plantcreeperquad[2]:setViewport(64+16*(self.stage%1), 0, 16, 16, 128, 64)]]

	local target = self.stage
	if (not self.path[math.floor(self.stage)].turn) and (self.path[math.floor(self.stage)].dir == "right" or self.path[math.floor(self.stage)].dir == "down") then
		target = self.stage-1
	end

	for i = 1, math.floor(target) do
		if self.children[i] then
			local b = self.children[i]
			local x, y = self.children[i].x, self.children[i].y
			if onscreen(x-1, y-1, 3, 3) then
				local quadi = 1
				if b.dir == "left" or b.dir == "right" then
					quadi = 2
				end
				if b.turn then
					if b.turn == "c1" then
						quadi = 3
					elseif b.turn == "c2" then
						quadi = 4
						x = x - 6/16
					elseif b.turn == "c3" then
						quadi = 5
						y = y - 6/16
					else
						quadi = 6
						x = x - 6/16
						y = y - 6/16
					end
				end
				love.graphics.draw(plantcreeperimg, plantcreeperquad[quadi], math.floor((x+.5-xscroll)*16*scale), math.floor(((y+.5-yscroll)*16-8)*scale), 0, scale, scale, 8, 8)
			end
		end
	end
	love.graphics.setStencilTest()
end


function plantcreeper:stomp(x, b)
	self.stomped = true
	self.movingdir = "backwards"
	if b and type(b) == "table" and b.groundpounding and b.size and b.size ~= -1 then
		self.targetstage = math.max(self.start,math.floor(self.stage-plantcreeperstompdist*1.5))
	else
		self.targetstage = math.max(self.start,math.floor(self.stage-plantcreeperstompdist))
	end
	self.waittimer = 0
	self.hittimer = plantcreeperhittime
	self.stompbounce = true
end

function plantcreeper:shotted()
	if self.hittimer > 0 then
		return false
	end
	playsound(shotsound)
	self:stomp()
end

function plantcreeper:destroy()
	makepoof(self.x+self.width/2, self.y+self.height/2, "makerpoofbig")
	self.delete = true
	for j, w in pairs(self.children) do
		w.delete = true
	end
	playsound(shotsound)
end

function plantcreeper:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function plantcreeper:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function plantcreeper:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function plantcreeper:globalcollide(a, b)
	
end

function plantcreeper:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function plantcreeper:passivecollide(a, b)
	return false
end

--SEGMENT--
plantcreepersegment = class:new()

function plantcreepersegment:init(x, y, dir, turn)
	--PHYSICS STUFF
	self.cox = x
	self.coy = y
	self.x = x-1
	self.y = y-1
	self.speedx = 0
	self.speedy = 0
	self.width = 1
	self.height = 1
	if turn then
		self.width = 18/16
		self.height = 18/16
	end
	self.active = true
	self.static = true
	self.category = 2
	self.mask = {true}
	
	self.emancipatecheck = false
	self.autodelete = false
	self.drawable = false
	self.portalable = false
	
	self.rotation = 0 --for portals
	--self.graphic = plantcreeperimg
	--self.quad = plantcreeperquad[1]
	self.offsetX = 8
	self.offsetY = 0
	self.quadcenterX = 8
	self.quadcenterY = 8

	self.dir = dir
	self.turn = turn or false
end

function plantcreepersegment:update(dt)
	if self.delete then
		return true
	end
	return false
end

function plantcreepersegment:draw()
end

function plantcreepersegment:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function plantcreepersegment:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function plantcreepersegment:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function plantcreepersegment:globalcollide(a, b)
	
end

function plantcreepersegment:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function plantcreepersegment:passivecollide(a, b)
	return false
end