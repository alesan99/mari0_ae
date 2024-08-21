randomizer = class:new()

function randomizer:init(x, y, m, r)
	self.cox = x
	self.coy = y
	self.x = x
	self.y = y
	self.r = r
	local vars = tostring(m)
	vars = vars:split("|")
	self.m = tonumber(vars[1]) or 1
	self.visible = (vars[2] or "true") == "true"
	
	self.outtable = {}
	self.on = false
	self.target = nil
	self.initial = true
end

function randomizer:link()
	if #self.r > 3 then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[5]) == v.cox and tonumber(self.r[6]) == v.coy then
					v:addoutput(self)
					self.linked = true
				end
			end
		end
	end
end

function randomizer:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end

function randomizer:update(dt)
	
end

function randomizer:draw()
	if self.visible then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(gateimg, gatequad[4], math.floor((self.x-1-xscroll)*16*scale), ((self.y-1-yscroll)*16-8)*scale, 0, scale, scale)
	end
end

function randomizer:out(t)
	for i = 1, #self.outtable do
		if self.outtable[i][1].input then
			self.outtable[i][1]:input(t, self.outtable[i][2])
		end
	end
end

function randomizer:input(t)
	if t == "off" then
		self.on = false
		if #self.outtable ~= 0 and self.m ~= 2 then
			if self.m == 3 then
				for i = 1, #self.outtable do
					if math.random(1, 2) == 1 then
						self.outtable[i][1]:input("toggle", self.outtable[i][2])
					end
				end
			elseif self.m == 2 then
				self.target = math.random(1, #self.outtable)
				self.outtable[self.target][1]:input("toggle", self.outtable[self.target][2])
			else
				self.outtable[self.target][1]:input("off", self.outtable[self.target][2])
			end
		end
	elseif t == "on" then
		self.on = true
		if #self.outtable ~= 0 then
			self.target = math.random(1, #self.outtable)
			if self.m == 3 then
				for i = 1, #self.outtable do
					if math.random(1, 2) == 1 then
						self.outtable[i][1]:input("toggle", self.outtable[i][2])
					end
				end
			elseif self.m == 2 then
				self.outtable[self.target][1]:input("toggle", self.outtable[self.target][2])
			else
				self.outtable[self.target][1]:input("on", self.outtable[self.target][2])
			end
		end
	else
		self.on = not self.on
		if self.m == 3 then
			for i = 1, #self.outtable do
				if math.random(1, 2) == 1 then
					self.outtable[i][1]:input("toggle", self.outtable[i][2])
				end
			end
		else
			if self.on then
				if #self.outtable ~= 0 then
					self.target = math.random(1, #self.outtable)
					self.outtable[self.target][1]:input("toggle", self.outtable[self.target][2])
				end
			else
				if #self.outtable ~= 0 then
					if self.m == 2 then
						self.target = math.random(1, #self.outtable)
					end
					self.outtable[self.target][1]:input("toggle", self.outtable[self.target][2])
				end
			end
		end
	end
end
