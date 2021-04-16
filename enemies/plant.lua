plant = class:new()

function plant:init(x, y, t, dir)
	self.cox = x
	self.coy = y
	self.t = t or "plant"
	self.dir = dir or "up"
	
	self.timer = 0
	
	if self.dir == "up" then
		self.x = x-8/16
		self.y = y+9/16
		self.width = 16/16
		self.height = 14/16
	elseif self.dir == "down" then
		self.x = x-8/16
		self.y = y-1
		self.width = 16/16
		self.height = 14/16
	elseif self.dir == "left" then
		self.y = y-1.5
		self.x = x+9/16
		self.height = 16/16
		self.width = 14/16
	elseif self.dir == "right" then
		self.y = y-1.5
		self.x = x-1
		self.height = 16/16
		self.width = 14/16
	end
	self.startx = self.x
	self.starty = self.y
	
	self.static = true
	self.active = true
	
	self.destroy = false
	
	self.category = 29
	
	self.mask = {true}
	
	self.freezable = true
	self.frozen = false
	
	--IMAGE STUFF
	self.drawable = true
	
	self.offsetX = 8
	self.offsetY = 1
	self.quadcenterX = 8
	self.quadcenterY = 17
	
	self.quad = plantquads[spriteset][1]
	self.quads = plantquads
	if self.t == "plant" then
		self.graphic = plantimg

		self.animationdelay = plantanimationdelay
		self.outtime = plantouttime
		self.intime = plantintime
		self.movedist = plantmovedist
		self.movespeed = plantmovespeed
		self.playernear = 3
	elseif self.t == "redplant" then
		self.graphic = redplantimg

		self.animationdelay = redplantanimationdelay
		self.outtime = redplantouttime
		self.intime = redplantintime
		self.movedist = redplantmovedist
		self.movespeed = redplantmovespeed
		self.playernear = 1
	elseif self.t == "dryplant" then
		self.graphic = dryplantimg
		
		self.animationdelay = plantanimationdelay
		self.outtime = plantouttime
		self.intime = plantintime
		self.movedist = plantmovedist
		self.movespeed = plantmovespeed
		self.playernear = 3
	elseif self.t == "fireplant" then
		self.graphic = plantimg

		self.animationdelay = plantanimationdelay
		self.outtime = fireplantouttime
		self.intime = plantintime
		self.movedist = plantmovedist
		self.movespeed = plantmovespeed

		self.playernear = 3

		self.graphic = fireplantimg
		self.quad = ampquad[spriteset][1]

		self.animationdirection = "right"
		self.offsetX = 8
		self.offsetY = 1
		self.quadcenterX = 16
		self.quadcenterY = 20

		self.quadi = 1
		self.quadnum = 1
		self.timer = 0
		self.shootfire = false
		self.shottedo = false
		self.inpipe = true
	end
	self.insidepipe = true

	if self.dir == "down" or self.dir == "right" then
		--switch in and out time
		local intime, outtime = self.intime, self.outtime
		self.outtime = intime
		self.intime = outtime
	end

	if self.dir == "up" then
		self.customscissor = {x-1, y-2, 2, 2}

		self.timer1 = 0
		self.timer2 = self.outtime+1.5
	elseif self.dir == "down" then
		self.customscissor = {x-1, y-1, 2, 2}

		self.timer1 = 0
		if self.t == "redplant" then
			self.timer2 = self.outtime
		else
			self.timer2 = self.outtime-0.3
		end
		self.y = self.starty - self.movedist

		self.rotation = math.pi

		self.insidepipe = false
	elseif self.dir == "left" then
		self.customscissor = {x-2, y-2, 2, 2}

		self.offsetX = 7
		self.offsetY = 0
		self.timer1 = 0
		self.timer2 = self.outtime+1.5

		self.rotation = math.pi*1.5
	elseif self.dir == "right" then
		self.customscissor = {x-1, y-2, 2, 2}

		self.offsetX = 7
		self.offsetY = 0
		self.timer1 = 0
		if self.t == "redplant" then
			self.timer2 = self.outtime
		else
			self.timer2 = self.outtime-0.3
		end
		self.x = self.startx - self.movedist

		self.rotation = math.pi*.5

		self.insidepipe = false
	end
	
	self.quadnum = 1
	self.freezetimer = 0
end

function plant:update(dt)
	if self.shottedo then
		return true
	end

	if (not self.frozen) then
		--plant animation
		if self.t ~= "fireplant" then
			self.timer1 = self.timer1 + dt
			while self.timer1 > self.animationdelay do
				self.timer1 = self.timer1 - self.animationdelay
				if self.quadnum == 1 then
					self.quadnum = 2
				else
					self.quadnum = 1
				end
				self.quad = self.quads[spriteset][self.quadnum]
			end
		end
		
		--normal plant movement
		if (not self.track) then
			self.timer2 = self.timer2 + dt
			if self.timer2 < self.outtime then
				self.inpipe = not self.insidepipe
				if self.dir == "up" or self.dir == "down" then
					self.y = self.y - self.movespeed*dt
					if self.y < self.starty - self.movedist then
						self.shootfire = self.insidepipe
						self.y = self.starty - self.movedist
					end
				elseif self.dir == "left" or self.dir == "right" then
					self.x = self.x - self.movespeed*dt
					if self.x < self.startx - self.movedist then
						self.shootfire = self.insidepipe
						self.x = self.startx - self.movedist
					end
				end
			elseif self.timer2 < self.outtime+self.intime then
				self.shootfire = not self.insidepipe
				self.inpipe = self.insidepipe
				if self.dir == "up" or self.dir == "down" then
					self.y = self.y + self.movespeed*dt
					if self.y > self.starty then
						self.y = self.starty
					end
				elseif self.dir == "left" or self.dir == "right" then
					self.x = self.x + self.movespeed*dt
					if self.x > self.startx then
						self.x = self.startx
					end
				end
			else
				if self.dir == "up" then
					for i = 1, players do
						local v = objects["player"][i]
						if inrange(v.x+v.width/2, self.x+self.width/2-self.playernear, self.x+self.width/2+self.playernear) then --no player near
							return
						end
					end
				end
				self.timer2 = 0
			end
		end
	end

	if self.customscissor then
		if self.dir == "up" then
			self.active = (self.y <= self.customscissor[2]+self.customscissor[4])
		elseif self.dir == "down" then
			self.active = (self.y+self.height >= self.customscissor[2])
		elseif self.dir == "left" then
			self.active = (self.x <= self.customscissor[1]+self.customscissor[3])
		elseif self.dir == "right" then
			self.active = (self.x+self.width >= self.customscissor[1])
		end
	end

	if self.t == "fireplant" and (not self.frozen) then
		local closestplayer = 1 --find closest player
		for i = 2, players do
			local v = objects["player"][i]
			if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
				closestplayer = i
			end
		end
		--face player
		if self.shottedo == false then
			self.timer1 = self.timer1 + dt
			while self.timer1 > plantanimationdelay do
				self.timer1 = self.timer1 - plantanimationdelay
				if self.quadi == 1 and self.timer < 1.5 then
					self.quadi = 2
				else
					self.quadi = 1
				end
			end
			if self.x + self.width/2 >= objects["player"][closestplayer].x + objects["player"][closestplayer].width/2 then
				if self.dir == "up" then
					self.animationdirection = "left"
				elseif self.dir == "down" then
					self.animationdirection = "right"
				elseif self.dir == "left" then
					self.quadnum = 1
				elseif self.dir == "right" then
					self.quadnum = 2
				end
			else
				if self.dir == "up" then
					self.animationdirection = "right"
				elseif self.dir == "down" then
					self.animationdirection = "left"
				elseif self.dir == "left" then
					self.quadnum = 2
				elseif self.dir == "right" then
					self.quadnum = 1
				end
			end
			if self.y + self.height/2 >= objects["player"][closestplayer].y + objects["player"][closestplayer].height/2 then
				if self.dir == "up" then
					self.quadnum = 1
				elseif self.dir == "down" then
					self.quadnum = 2
				elseif self.dir == "left" then
					self.animationdirection = "right"
				elseif self.dir == "right" then
					self.animationdirection = "left"
				end
			else
				if self.dir == "up" then
					self.quadnum = 2
				elseif self.dir == "down" then
					self.quadnum = 1
				elseif self.dir == "left" then
					self.animationdirection = "left"
				elseif self.dir == "right" then
					self.animationdirection = "right"
				end
			end
			self.quad = ampquad[spriteset][(self.quadnum*2-1)+(self.quadi-1)]
		end
		
		if ((self.shootfire and not self.shottedo and not self.inpipe) or self.track) and (self.x+self.width)-xscroll > 0 then
			self.timer = self.timer + dt
			if self.timer > 2 and onscreen(self.x, self.y, self.width, self.height) then
				local ox, oy = 2/16+self.width/2, 7/16+self.height/2
				local ignoretiles = {}
				if self.dir == "up" then
					oy = oy - .5*(self.supersized or 1)
					table.insert(ignoretiles, {self.cox, self.coy+1})
					table.insert(ignoretiles, {self.cox+1, self.coy+1})
				elseif self.dir == "down" then
					oy = oy + .5*(self.supersized or 1)
					table.insert(ignoretiles, {self.cox, self.coy-1})
					table.insert(ignoretiles, {self.cox+1, self.coy-1})
				elseif self.dir == "left" then
					ox = ox - .5*(self.supersized or 1)
					table.insert(ignoretiles, {self.cox+1, self.coy})
					table.insert(ignoretiles, {self.cox+1, self.coy-1})
				elseif self.dir == "right" then
					ox = ox + .5*(self.supersized or 1)
					table.insert(ignoretiles, {self.cox-1, self.coy})
					table.insert(ignoretiles, {self.cox-1, self.coy-1})
				end
				local obj = plantfire:new(self.x+ox, self.y+oy, "plantfire")
				if self.dir == "up" or self.dir == "down" then
					local s = math.abs(obj.speedx)
					if s > 2 then
						obj.ignoretiles = ignoretiles
					end
				else
					local s = math.abs(obj.speedy)
					if s > 2 then
						obj.ignoretiles = ignoretiles
					end
				end
				if self.supersized then
					supersizeentity(obj)
				end
				table.insert(objects["plantfire"], obj)
				--playsound(fireballsound)
				self.timer = 0
			end
		end
	end
	
	return self.destroy
end

function plant:shotted()
	playsound(shotsound)
	self.destroy = true
	self.active = false
end

function plant:freeze()
	self.frozen = true
end

function plant:dotrack()
	self.customscissor = false
	self.track = true
end

function plant:dosupersize()
	if self.dir == "up" then
		self.y = self.y+1
	elseif self.dir == "left" then
		self.x = self.x+1
	elseif self.dir == "down" then
		self.y = self.y+30/16
	elseif self.dir == "right" then
		self.x = self.x+30/16
	end
	self.startx = self.x
	self.starty = self.y

	
	if self.dir == "up" then
		self.customscissor[2] = self.customscissor[2] - 2
		self.customscissor[4] = 4

		self.customscissor[1] = self.customscissor[1] - 1
		self.customscissor[3] = self.customscissor[3] + 2
	elseif self.dir == "down" then
		self.customscissor[4] = 4

		self.customscissor[1] = self.customscissor[1] - 1
		self.customscissor[3] = self.customscissor[3] + 2
	elseif self.dir == "left" then
		self.customscissor[1] = self.customscissor[1] - 2
		self.customscissor[3] = 4

		self.customscissor[2] = self.customscissor[2] - 1
		self.customscissor[4] = self.customscissor[4] + 2
	elseif self.dir == "right" then
		self.customscissor[3] = 4

		self.customscissor[2] = self.customscissor[2] - 1
		self.customscissor[4] = self.customscissor[4] + 2
	end
	--put big plants into 2 tile wides pipes i guess?
	if self.width > self.height then
		self.width = self.width - 2/16
		self.x = self.x + 1/16
		self.offsetX = self.offsetX - .5
	else
		self.height = self.height - 2/16
		self.y = self.y + 1/16
		self.offsetY = self.offsetY + .5
	end
end