gel = class:new()

function gel:init(x, y, id)
	self.id = id
	
	--PHYSICS STUFF
	self.x = x-14/16
	self.y = y-12/16
	self.speedy = 0
	self.speedx = 0
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.category = 8
	self.mask = {false, false, true, true, true, true, true, true, false, false, true}
	self.ignorecheckrect = {[8] = true}
	self.gravity = 50
	--self.autodelete = true
	self.extremeautodelete = true
	--self.timer = 0
	
	--IMAGE STUFF
	self.drawable = true
	self.quadi = math.random(3)
	self.quad = gelquad[self.quadi]
	self.offsetX = 8
	self.offsetY = 0
	self.quadcenterX = 8
	self.quadcenterY = 8
	self.rotation = 0 --for portals
	if self.id == 1 then
		self.graphic = gel1img
	elseif self.id == 2 then
		self.graphic = gel2img
	elseif self.id == 3 then
		self.graphic = gel3img
	elseif self.id == 4 then
		self.graphic = gel4img
	elseif self.id == 5 then
		self.graphic = gel5img
	end
	
	self.noclearpipesound = true
	self.destroy = false
	--self.lifetime = gellifetime
end

function gel:update(dt)
	self.speedy = math.min(gelmaxspeed, self.speedy)
	
	if self.funnel or self.clearpipe then
		self.mask[8] = true
		self.gravity = 50
		self.funnel = false
		self.timer = 0
	end
	
	self.rotation = 0
	
	--[[self.timer = self.timer + dt
	if self.timer >= (self.lifetime or gellifetime) then
		return true
	end]]
	
	if self.destroy then
		self:callback()
	end
	return self.destroy
end

function gel:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.destroy = true
	if a == "tile" then
		local x, y = b.cox, b.coy
		
		if (inmap(x+1, y) and self:geltilecheck(x+1, y)) or (inmap(x, y) and not self:geltilecheck(x, y)) then
			return
		end
		
		--see if adjsajcjet tile is a better fit
		if math.floor(self.y+self.height/2)+1 ~= y then
			if inmap(x, math.floor(self.y+self.height/2)+1) and self:geltilecheck(x, math.floor(self.y+self.height/2)+1) then
				y = math.floor(self.y+self.height/2)+1
			end
		end
		
		self:applygel("right", x, y)
	elseif a == "tilemoving" then
		self:applygel("right", b)
	elseif a == "lightbridgebody" and b.dir == "ver" then
		self:applygel("right", b)
	end
end

function gel:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.destroy = true
	if a == "tile" then
		local x, y = b.cox, b.coy
		
		if (inmap(x-1, y) and self:geltilecheck(x-1, y)) or (inmap(x, y) and not self:geltilecheck(x, y)) then
			return
		end
		
		--see if adjsajcjet tile is a better fit
		if math.floor(self.y+self.height/2)+1 ~= y then
			if inmap(x, math.floor(self.y+self.height/2)+1) and self:geltilecheck(x, math.floor(self.y+self.height/2)+1) then
				y = math.floor(self.y+self.height/2)+1
			end
		end
		
		self:applygel("left", x, y)
	elseif a == "tilemoving" then
		self:applygel("left", b)
	elseif a == "lightbridgebody" and b.dir == "ver" then
		self:applygel("left", b)
	end
end

function gel:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.destroy = true
	if a == "tile" then
		local x, y = b.cox, b.coy
		
		if (inmap(x, y-1) and self:geltilecheck(x, y-1)) or (inmap(x, y) and not self:geltilecheck(x, y)) then
			return
		end
		
		--see if adjsajcjet tile is a better fit
		if math.floor(self.x+self.width/2)+1 ~= x then
			if inmap(math.floor(self.x+self.width/2)+1, y) then
				if self:geltilecheck(math.floor(self.x+self.width/2)+1, y) then
					x = math.floor(self.x+self.width/2)+1
				end
			end
		end
		
		if inmap(x, y) and tilequads[map[x][y][1]].collision then
			if map[x][y]["gels"]["top"] == self.id or (self.id == 5 and not map[x][y]["gels"]["top"]) then
				if self.speedx > 0 then
					for cox = x+1, x+self.speedx*0.2 do
						if inmap(cox, y-1) and self:geltilecheck(cox, y) and not self:geltilecheck(cox, y-1) then
							if self:applygel("top", cox, y) then
								break
							end
						else
							break
						end
					end
				elseif self.speedx < 0 then
					for cox = x-1, x+self.speedx*0.2, -1 do
						if inmap(cox, y-1) and self:geltilecheck(cox, y) and not self:geltilecheck(cox, y-1) then
							if self:applygel("top", cox, y) then
								break
							end
						else
							break
						end
					end
				end
			else
				self:applygel("top", x, y)
			end
		end
	elseif a == "tilemoving" then
		self:applygel("top", b)
	elseif a == "lightbridgebody" and b.dir == "hor" then
		self:applygel("top", b)
	end
end

function gel:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.destroy = true
	if a == "tile" then
		local x, y = b.cox, b.coy
		if not inmap(x, y+1) or (not self:geltilecheck(x,y+1)) then
			local x, y = b.cox, b.coy
			self:applygel("bottom", x, y)
		end
	elseif a == "tilemoving" then
		self:applygel("bottom", b)
	elseif a == "lightbridgebody" and b.dir == "hor" then
		self:applygel("bottom", b)
	end
end

function gel:globalcollide(a, b)
	if a == "clearpipesegment" and not self.clearpipepass then
		self.clearpipepass = true
		return true
	end
	if self.funnel and a == "gel" then
		--small gel blobs get combined with others
		if ((self.quadi < b.quadi) and (not b.destroy)) or b.destroy or b.id ~= self.id then
			if b.destroy then
				self.x = (self.x+b.x)/2
				self.y = (self.y+b.y)/2
			end
			return true
		end
	end
	if a == "tile" then
		local x, y = b.cox, b.coy
		if not self:geltilecheck(x,y) then
			return true
		end
	end
end

function gel:passivecollide(a, b)
	if a == "gel" then
		return false
	end
	return true
end

function gel:applygel(side, x, y)
	if x and (not y) then
		local b = x
		local id = b.gels[side]
		if id and id == 5 then
			--can't put gel
			return false
		elseif self.id == 5 then
			b.gels[side] = nil
		else
			b.gels[side] = self.id
		end
	else
		local id = map[x][y]["gels"][side]
		if id and id == 5 then
			--can't put gel
			return false
		elseif self.id == 5 then
			map[x][y]["gels"][side] = false
		else
			map[x][y]["gels"][side] = self.id
		end
		if id ~= self.id then
			return true
		end
	end
	return false
end

function gel:geltilecheck(x,y)
	local t = tilequads[map[x][y][1]]
	return t:getproperty("collision", x, y) and t:getproperty("invisible", x, y) == false and t:getproperty("grate", x, y) == false and t.leftslant == false and t.rightslant == false
end

function gel:callback()
	if self.calledback then
		return false
	end
	if self.parent and self.parent.callback then
		self.parent:callback()
		self.calledback = true
	end
end

function gel:dofunnel()
	self.mask[8] = false
end

function gel:autodeleted()
	self:callback()
end