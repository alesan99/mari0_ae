laserdetector = class:new()

function laserdetector:init(x, y, dir, r)
	self.cox = x
	self.coy = y
	self.dir = dir
	self.detectslasers = true
	self.detectslightbridges = false
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	if #self.r > 0 and self.r[1] ~= "link" then
		local v = convertr(self.r[1], {"string", "bool", "bool"}, true)
		self.dir = v[1]
		self.detectslasers = v[2]
		self.detectslightbridges = v[3]
		table.remove(self.r, 1)
	end
	
	self.drawable = false
	
	self.outtable = {}
	self.allowclear = true
	self.out = "off"
end

function laserdetector:update(dt)
	self.allowclear = true
	
	if self.out ~= self.prevout then
		self.prevout = self.out
		for i = 1, #self.outtable do
			if self.outtable[i][1].input then
				self.outtable[i][1]:input(self.out, self.outtable[i][2])
			end
		end
	end
end

function laserdetector:input(t)
	self.allowclear = false
	if t == "on" then
		self.out = "on"
	end
end

function laserdetector:draw()
	local quadi = 1
	if self.out == "on" then
		quadi = 2
	end
	local rot = 0
	if self.dir == "down" then
		rot = math.pi/2
	elseif self.dir == "left" then
		rot = math.pi
	elseif self.dir == "up" then
		rot = math.pi*1.5
	end
	love.graphics.draw(laserdetectorimg, laserdetectorquad[quadi], math.floor((self.cox-xscroll-0.5)*16*scale), (self.coy-1-yscroll)*16*scale, rot, scale, scale, 8, 8)
end

function laserdetector:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end

function laserdetector:clear()
	if self.allowclear then
		self.allowclear = false
		self.out = "off"
	end
end