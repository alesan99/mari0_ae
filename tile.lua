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
		--Slopes
		if t.rightslant or t.leftslant then
			self.SLOPE = true
		end
		--Slabs
		if t.rightslant and t.leftslant then
			self.SLOPE = nil
			self.slab = true
			if t.fullrightslant and t.fullleftslant then
				self.height = 0.5
				if (not t.downslant) and self.height ~= 1 then
					self.y = self.y + 0.5
				end
			elseif t.fullrightslant and t.halfleftslant1 then
				self.height = 0.5
				self.width = 0.5
				if (not t.downslant) and self.height ~= 1 then
					self.y = self.y + 0.5
				end
			elseif t.fullrightslant and t.halfleftslant2 then
				self.width = 0.5
			elseif t.halfrightslant1 and t.fullleftslant then
				self.height = 0.5
				self.width = 0.5
				self.x = self.x + 0.5
				if (not t.downslant) and self.height ~= 1 then
					self.y = self.y + 0.5
				end
			elseif t.halfrightslant2 and t.fullleftslant then
				self.width = 0.5
				self.x = self.x + 0.5
			end
		--Right slopes
		elseif t.rightslant then
			self.slant = "right"; self.dir = self.slant
			self.y1 = 0
			self.y2 = 1
			if t.halfrightslant1 then
				self.y1 = 0.5
				self.y2 = 1
			elseif t.halfrightslant2 then
				self.y1 = 0
				self.y2 = 0.5
			end
			self.incline = math.abs(self.y2-self.y1)
		--Left slopes
		elseif t.leftslant then
			self.slant = "left"; self.dir = self.slant
			self.y1 = 1
			self.y2 = 0
			if t.halfleftslant1 then
				self.y1 = 1
				self.y2 = 0.5
			elseif t.halfleftslant2 then
				self.y1 = 0.5
				self.y2 = 0
			end
			self.incline = math.abs(self.y2-self.y1)
		end
		--Upside down slopes
		if self.SLOPE and t.downslant then
			self.y1 = 1-self.y1
			self.y2 = 1-self.y2
			self.UPSIDEDOWNSLOPE = true
		end
		--Platform tiles (No collision)
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

		--Disable collisions if next to slopes
		--if not (t.PLATFORM or t.PLATFORMDOWN or t.PLATFORMLEFT or t.PLATFORMRIGHT) then 
			local tleft, tabove
			if ismaptile(self.cox-1, self.coy) and tilequads[map[self.cox-1][self.coy][1]] then
				local tq = tilequads[map[self.cox-1][self.coy][1]]
				tleft = tq.leftslant and (not tq.slab)
				if tleft and t.platform then tleft = false end --Make sure platform slopes DO NOT affect other tiles
			end
			if ismaptile(self.cox, self.coy-1) and tilequads[map[self.cox][self.coy-1][1]] then
				local tq = tilequads[map[self.cox][self.coy-1][1]]
				tabove = (tq.leftslant or tq.rightslant) and (not tq.downslant) and (not tq.slab)
				if tabove and (t.platform or (self.SLOPE and not self.UPSIDEDOWNSLOPE)) then
					tabove = false
				end
			end
			--disable top flat collisions for platform slopes if next to another similar slope (because they should be one continuous line)
			if self.SLOPE and t.platform and t.rightslant and (not t.downslant) and ismaptile(self.cox-1, self.coy-1) and tilequads[map[self.cox-1][self.coy-1][1]] then
				local tq = tilequads[map[self.cox-1][self.coy-1][1]]
				if tq.rightslant and (not tq.downslant) and (not tq.slab) then
					self.platformslopenotopcollision = true
				end
			end
			if tleft or tabove then
				local up, down, left, right = cancollideside(self, "up"), cancollideside(self, "down"), cancollideside(self, "left"), cancollideside(self, "right")
				if tleft then
					left = false
				end
				if tabove then
					up = false
				end
				self.byslope = true
				if not (up and down and left and right) then
					self.PLATFORM = up or nil
					self.PLATFORMDOWN = down or nil
					self.PLATFORMLEFT = left or nil
					self.PLATFORMRIGHT = right or nil
				end
			end
		--end
		if t.rightslant and (not t.platform) and (not t.slab) then  --maps are loaded from left -> right, so the slope tile on the right has to look to the left to disable the tile's collision
			local tr, tright
			if ismaptile(self.cox-1, self.coy) and tilequads[map[self.cox-1][self.coy][1]] then
				local tq = tilequads[map[self.cox-1][self.coy][1]]
				if tq.collision then
					tr = objects["tile"][tilemap(self.cox-1, self.coy)]
					tright = true
				end
			end
			if tright and tr then
				local up, down, left, right = cancollideside(tr, "up"), cancollideside(tr, "down"), cancollideside(tr, "left"), cancollideside(tr, "right")
				right = false
				tr.byslope = true
				if not (up and down and left and right) then
					tr.PLATFORM = up or nil
					tr.PLATFORMDOWN = down or nil
					tr.PLATFORMLEFT = left or nil
					tr.PLATFORMRIGHT = right or nil
				end
			end
		end
		if t.leftslant and t.platform and (not t.downslant) and (not t.slab) then
			--disable top flat collisions for platform slopes if next to another similar slope (because they should be one continuous line)
			if ismaptile(self.cox-1, self.coy+1) and tilequads[map[self.cox-1][self.coy+1][1]] then
				local tq = tilequads[map[self.cox-1][self.coy+1][1]]
				local t = objects["tile"][tilemap(self.cox-1, self.coy+1)]
				if tq.leftslant and not tq.downslant then
					t.platformslopenotopcollision = true
				end
			end
		end
	end
end