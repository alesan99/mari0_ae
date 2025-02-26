rsflipflop = class:new()

function rsflipflop:init(x, y, r)
	self.x = x
	self.y = y
	self.cox = x
	self.coy = y
	self.visible = false
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	
	--VISIBLE
	if #self.r > 0 and self.r[1] ~= "link" then
		self.visible = (self.r[1] == "true")
		table.remove(self.r, 1)
	end
	
	self.outtable = {}
	self.output = false
end

function rsflipflop:link()
	while #self.r > 3 do
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[2]) == v.cox and tonumber(self.r[3]) == v.coy then
					v:addoutput(self, self.r[4])
				end
			end
		end
		
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
	end
end

function rsflipflop:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end

function rsflipflop:draw()
	if self.visible then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(gateimg, gatequad[7], math.floor((self.x-1-xscroll)*16*scale), ((self.y-yscroll-1)*16-8)*scale, 0, scale, scale)
	end
end

function rsflipflop:out(t)
	for i = 1, #self.outtable do
		if self.outtable[i][1].input then
			self.outtable[i][1]:input(t, self.outtable[i][2])
		end
	end
end

function rsflipflop:input(t, input)
	if input == "set" then
		if (t == "on" or t == "toggle") and not self.output then
			self.output = true
			self:out("on")
		end
	elseif input == "reset" then
		if (t == "on" or t == "toggle") and self.output then
			self.output = false
			self:out("off")
		end
	end
end
