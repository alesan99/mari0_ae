spawnanimation = class:new()

function spawnanimation:init(x, y, a, obj)
	self.cox = x
	self.coy = y
	self.x = x-1
	self.y = y-1
	self.a = a
	self.obj = obj

	self.v = {} --old values
	self.v.speedx = self.obj.speedx
	self.v.speedy = self.obj.speedy
	self.v.active = self.obj.active
	self.v.customscissor = self.obj.customscissor or false
	self.v.customscissor2 = self.obj.customscissor2 or false
	self.v.invertedscissor = self.obj.invertedscissor or false

	if self.a == "block" then
		self.time = mushroomtime
		self.obj.active = false
		self.obj.customscissor = {self.x-3, self.y-6, 7, 7}
	elseif self.a == "cannon" then
		self.time = 1/math.max(0.5, math.abs(self.obj.speedx or 1))
		self.dist = -1
		if self.obj.speedx and self.obj.speedx > 0 then
			self.dist = 1
			if self.obj.leftcollide then
				self.obj:leftcollide("",{})
			end
		end
		self.obj.active = false
		self.obj.customscissor = {self.x, self.y-2, 1, 5}
		self.obj.invertedscissor = true
		playsound(bulletbillsound)
		
	elseif self.a == "pipeup" or self.a == "pipedown" or self.a == "pipeleft" or self.a == "piperight" then
		self.time = pipeanimationtime
		self.startx = self.x
		self.starty = self.y
		self.targetx = self.x
		self.targety = self.y
		self.obj.active = false
		if self.a == "pipeup" then
			self.startx = self.x+1-self.obj.width/2
			self.targetx = self.startx
			self.targety = self.y+1-self.obj.height
			self.starty = self.y+(1.5)
			self.obj.customscissor = {self.x-2, self.y-5, 6, 6}
		elseif self.a == "pipedown" then
			self.startx = self.x+1-self.obj.width/2
			self.targetx = self.startx
			self.targety = self.y
			self.starty = self.targety-(self.obj.height+0.5)
			self.obj.customscissor = {self.x-2, self.y, 6, 6}
		elseif self.a == "pipeleft" then
			self.starty = self.y-self.obj.height/2
			self.targety = self.starty
			self.targetx = self.x+1-self.obj.width
			self.startx = self.x+(1.5)
			self.obj.customscissor = {self.x-5, self.y-2, 6, 6}
		elseif self.a == "piperight" then
			self.starty = self.y-self.obj.height/2
			self.targety = self.starty
			self.targetx = self.x
			self.startx = self.targetx-(self.obj.width+0.5)
			self.obj.customscissor = {self.x, self.y-2, 6, 6}
		end
		self.a = "pipe"
	end
	self.timer = 0
end

function spawnanimation:update(dt)
	self.timer = math.min(self.time, self.timer + dt)
	if self.a == "block" then
		self.obj.x = self.x+0.5-self.obj.width/2
		self.obj.y = self.y+2-self.obj.height-(self.timer/self.time)
		self:restrain()
		self.obj.customscissor = {self.x-3, self.y-6, 7, 7}
	elseif self.a == "cannon" then
		self.obj.x = self.x+0.5-self.obj.width/2+(self.dist*(self.timer/self.time))
		self.obj.y = self.y+0.5-self.obj.height/2
		self:restrain()
	elseif self.a == "pipe" then
		self.obj.x = self.startx+(self.targetx-self.startx)*(self.timer/self.time)
		self.obj.y = self.starty+(self.targety-self.starty)*(self.timer/self.time)
		self:restrain()
	end
	if self.timer >= self.time then
		self:release()
		return true
	end
end

function spawnanimation:restrain()
	self.obj.speedx = 0
	self.obj.speedy = 0
	self.obj.active = false
end

function spawnanimation:release()
	for name, value in pairs(self.v) do
		self.obj[name] = value
	end
	--make sure enemy isn't stationary when released
	if (self.a == "block" or self.a == "pipe") then
		if self.obj.releasespeedx and self.obj.speedx == 0 then
			if self.startx and self.targetx < self.startx then --move left
				self.obj.speedx = -math.abs(self.obj.releasespeedx)
			elseif self.startx and self.targetx > self.startx then --move right
				self.obj.speedx = math.abs(self.obj.releasespeedx)
			else --default direction
				self.obj.speedx = self.obj.releasespeedx
			end
		end
		if self.obj.releasespeedy and self.obj.speedy == 0 then
			if self.starty and self.targety < self.starty then --move up
				self.obj.speedy = -math.abs(self.obj.releasespeedy)
			elseif self.starty and self.targetx > self.startx then --move down
				self.obj.speedy = math.abs(self.obj.releasespeedy)
			else --default direction
				self.obj.speedy = self.obj.releasespeedy
			end
		end
	end
	if self.obj.dospawnanimation then
		self.obj:dospawnanimation(self.a)
	end
end

--[[function spawnanimation:draw()

end]]