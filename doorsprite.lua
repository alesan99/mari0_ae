doorsprite = class:new()

function doorsprite:init(x, y, r, i)
	self.cox = x
	self.coy = y
	self.r = r
	self.i = i

	local v = convertr(r[3], {"num", "num", "bool"}, true)
	self.targetsublevel = v[1] or 0
	self.exitid = v[2] or 1
	self.visible = true
	if v[3] ~= nil then
		self.visible = v[3]
	end
	if pipeexitid and pipeexitid > 1 and pipeexitid == self.exitid then
		pipestartx = x+.5
		pipestarty = y
		pipestartdir = "up"
	end
	
	if self.i == "door" then
		self.quad = doorspritequad[1]
	elseif self.i == "pdoor" then
		self.quad = doorspritequad[2]
		self.locked = true
	elseif self.i == "keydoor" then
		self.quad = doorspritequad[3]
		self.locked = true
	end
	
	self.frame = 1
	self.active = false
	self.static = true

	self.player = false
	self.outtable = {}
end

function doorsprite:draw()
	if self.visible then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(doorspriteimg, self.quad[self.frame], math.floor((self.cox-1-xscroll)*16*scale), math.floor((self.coy-2-(8/16)-yscroll)*16*scale), 0, scale, scale)
	end
end

function doorsprite:lock(lock)
	self.locked = lock
	if self.i == "pdoor" then
		if self.locked then
			self.frame = 1
		else
			self.frame = 2
		end
	elseif self.i == "keydoor" then
		if self.locked then
			self.frame = 1
		else
			self.frame = 2
			playsound(keyopensound)
		end
	end
end

function doorsprite:link()
	if #self.r > 3 then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[5]) == v.cox and tonumber(self.r[6]) == v.coy then
					self.exit = true
					self.exitx = v.cox
					self.exity = v.coy
					break
				end
			end
		end
	end
end

function doorsprite:addoutput(a, t)
end

function doorsprite:out()
end

function doorsprite:input(t)
end
