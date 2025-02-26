notgate = class:new()

function notgate:init(x, y, r)
	self.x = x
	self.y = y
	self.cox = x
	self.coy = y
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)

	self.visible = true
	if #self.r > 0 and self.r[1] ~= "link" then
		self.visible = (self.r[1] or "true") == "true"
		table.remove(self.r, 1)
	end
	
	self.outtable = {}
	self.state = "on"
	self.initial = true
	self.loops = 0
end

function notgate:link()
	if #self.r >= 3 then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[2]) == v.cox and tonumber(self.r[3]) == v.coy then
					v:addoutput(self)
				end
			end
		end
	end
end

function notgate:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end

function notgate:update(dt)
	if self.initial then
		self.initial = false
		if self.state == "on" then
			self:input("off")
		end
	end
	self.loops = 0
end

function notgate:draw()
	if self.visible then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(gateimg, gatequad[1], math.floor((self.x-1-xscroll)*16*scale), ((self.y-1-yscroll)*16-8)*scale, 0, scale, scale)
	end
end

function notgate:out(t)
	for i = 1, #self.outtable do
		if self.outtable[i][1].input then
			self.outtable[i][1]:input(t, self.outtable[i][2])
		end
	end
end

function notgate:input(t)
	if t == "off" then
		self.state = "on"
	elseif t == "on" then
		self.state = "off"
	else
		if self.state == "off" then
			self.state = "on"
		else
			self.state = "off"
		end
	end
	self.loops = self.loops + 1
	if self.loops > 999 then
		return false
	end
	self:out(self.state)
end
