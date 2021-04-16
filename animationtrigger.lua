--input
animationtrigger = class:new()

function animationtrigger:init(x, y, r, id)
	self.x = x
	self.y = y
	self.cox = x
	self.coy = y
	
	self.r = r
	self.id = tostring(id)
end

function animationtrigger:link()
	if #self.r > 2 then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[5]) == v.cox and tonumber(self.r[6]) == v.coy then
					v:addoutput(self)
				end
			end
		end
	end
end

function animationtrigger:input(t)
	if t == "on" or t == "toggle" then
		if not animationtriggerfuncs[self.id] then
			return
		end
		
		for i = 1, #animationtriggerfuncs[self.id] do
			animationtriggerfuncs[self.id][i]:trigger()
		end
	end
end

--output
animationoutput = class:new()

function animationoutput:init(x, y, r, id)
	self.x = x
	self.y = y
	self.cox = x
	self.coy = y
	
	self.r = r
	self.id = tostring(id)

	self.out = true

	self.outtable = {}
end

function animationoutput:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end

function animationoutput:trigger(signal)
	for i = 1, #self.outtable do
		if self.outtable[i][1].input then
			self.outtable[i][1]:input(signal or "toggle", self.outtable[i][2])
		end
	end
end