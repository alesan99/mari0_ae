tile = class:new()

function tile:init(x, y)
	self.cox = x+1
	self.coy = y+1
	self.x = x
	self.y = y
	self.speedx = 0
	self.speedy = 0
	self.width = 1
	self.height = 1
	self.active = true
	self.static = true
	self.category = 2
	self.mask = {true}
	if map[self.cox] and map[self.cox][self.coy] and tilequads[map[self.cox][self.coy][1]] and tilequads[map[self.cox][self.coy][1]].collision then
		local t = tilequads[map[self.cox][self.coy][1]]
		if t.rightslant or t.halfrightslant1 or t.halfrightslant2 or t.leftslant or t.halfleftslant1 or t.halfleftslant2 then
			self.slants = math.min(16*3,16*scale)
		end
		if (t.rightslant or t.halfrightslant1 or t.halfrightslant2) and (t.leftslant or t.halfleftslant1 or t.halfleftslant2) then
			--slant
			self.slants = nil
			self.slab = true
			if t.rightslant and t.leftslant then
				self.height = 0.5
				if (not t.downslant) and self.height ~= 1 then
					self.y = self.y + 0.5
				end
			elseif t.rightslant and t.halfleftslant1 then
				self.height = 0.5
				self.width = 0.5
				if (not t.downslant) and self.height ~= 1 then
					self.y = self.y + 0.5
				end
			elseif t.rightslant and t.halfleftslant2 then
				self.width = 0.5
			elseif t.halfrightslant1 and t.leftslant then
				self.height = 0.5
				self.width = 0.5
				self.x = self.x + 0.5
				if (not t.downslant) and self.height ~= 1 then
					self.y = self.y + 0.5
				end
			elseif t.halfrightslant2 and t.leftslant then
				self.width = 0.5
				self.x = self.x + 0.5
			end
		elseif t.rightslant then
			self.slant = "right"
			self.active = false
			self.step = 1/(self.slants)
			for num = 1, self.slants do
				objects["pixeltile"][num + tilemap(self.cox, self.coy)*100] = pixeltile:new(self.x+((num-1)*self.step), self.y+((num-1)*self.step), self.cox, self.coy, 1/self.slants, 1-((num-1)*self.step), "right", self.step)
			end
		elseif t.halfrightslant1 then
			self.slant = "right"
			self.active = false
			self.step = 1/self.slants/2
			for num = 1, self.slants do
				objects["pixeltile"][num + tilemap(self.cox, self.coy)*100] = pixeltile:new(self.x+((num-1)/self.slants), self.y+0.5+((num-1)*self.step), self.cox, self.coy, 1/self.slants,  0.5-((num-1)*self.step), "right", self.step)
			end
		elseif t.halfrightslant2 then
			self.slant = "right"
			self.active = false
			self.step = 1/self.slants/2
			for num = 1, self.slants do
				objects["pixeltile"][num + tilemap(self.cox, self.coy)*100] = pixeltile:new(self.x+((num-1)/self.slants), self.y+((num-1)*self.step), self.cox, self.coy, 1/self.slants, 1-((num-1)*self.step), "right", self.step)
			end
		elseif t.leftslant then
			self.slant = "left"
			self.active = false
			self.step = 1/(self.slants)
			for num = 1, self.slants do
				objects["pixeltile"][self.slants+1-num + tilemap(self.cox, self.coy)*100] = pixeltile:new(self.x+(1-(num*self.step)), self.y+((num-1)*self.step), self.cox, self.coy, 1/self.slants, 1-((num-1)*self.step), "left", self.step)
			end
		elseif t.halfleftslant1 then
			self.slant = "left"
			self.active = false
			self.step = 1/self.slants/2
			for num = 1, self.slants do
				objects["pixeltile"][self.slants+1-num + tilemap(self.cox, self.coy)*100] = pixeltile:new(self.x+(1-(num/self.slants)), self.y+0.5+((num-1)*self.step), self.cox, self.coy, 1/self.slants, 0.5-((num-1)*self.step), "left", self.step)
			end
		elseif t.halfleftslant2 then
			self.slant = "left"
			self.active = false
			self.step = 1/self.slants/2
			for num = 1, self.slants do
				objects["pixeltile"][self.slants+1-num + tilemap(self.cox, self.coy)*100] = pixeltile:new(self.x+(1-(num/self.slants)), self.y+((num-1)*self.step), self.cox, self.coy, 1/self.slants, 1-((num-1)*self.step), "left", self.step)
			end
		end
		if self.slants and t.downslant then
			for num = 1, self.slants do
				local b = objects["pixeltile"][num + tilemap(self.cox, self.coy)*100]
				b.y = self.y
				b.step = 0
			end
		end
		if t.platform then
			self.PLATFORM = true
		end
		if t.platformdown then
			self.PLATFORMDOWN = true
		end
		if t.platformleft then
			self.PLATFORMLEFT = true
		end
		if t.platformright then
			self.PLATFORMRIGHT = true
		end
	end
end

pixeltile = class:new()

function pixeltile:init(x, y, cox, coy, width, height, dir, step)
	self.cox = cox
	self.coy = coy
	self.x = x
	self.y = y
	self.speedx = 0
	self.speedy = 0
	self.step = step or 1/(16*scale)
	self.width = width or self.step
	self.height = height
	self.dir = dir
	self.active = true
	self.static = true
	self.category = 2
	self.mask = {true}
end