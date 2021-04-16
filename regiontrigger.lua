regiontrigger = class:new()

function regiontrigger:init(x, y, vars, r)
	self.cox = x
	self.coy = y
	self.rx = x-1
	self.ry = y-1
	self.rw = 1
	self.rh = 1
	self.active = false

	self.checktable = {"player"}

	if vars ~= nil then
		self.vars = vars:split("|")
		local s = self.vars[1]:gsub("n", "-")
		self.rw = tonumber(s)
		s = self.vars[2]:gsub("n", "-")
		self.rh = tonumber(s)
		
		if #self.vars > 4 then
			s = self.vars[3]:gsub("n", "-")
			self.rx = self.cox-1+tonumber(s)
			s = self.vars[4]:gsub("n", "-")
			self.ry = self.coy-1+tonumber(s)

			local s = self.vars[5]
			if s == "player" then
				self.checktable = {"player"}
			elseif s == "enemy" then
				self.checktable = deepcopy(enemies)
				table.insert(self.checktable, "enemy")

			elseif s == "everything" then
				self.checktable = deepcopy(enemies)
				table.insert(self.checktable, "player")
				table.insert(self.checktable, "enemy")

				table.insert(self.checktable, "mushroom")
				table.insert(self.checktable, "oneup")
				table.insert(self.checktable, "poisonmush")
			else
				self.checktable = {s}
			end
		elseif #self.vars > 2 then
			s = self.vars[3]:gsub("n", "-")
			self.rx = tonumber(s)
			s = self.vars[4]:gsub("n", "-")
			self.ry = tonumber(s)
		end
	end
	self.quadi = 1
	self.timer = 0
	self.on = false
	self.inregion = false
	
	self.outtable = {}
	
	self.out = "off"
end

function regiontrigger:draw()
	--draw orange rectangle
	--[[love.graphics.setColor(234, 160, 45, 111)
	love.graphics.rectangle("fill", (((self.x)*16)-xscroll*16)*scale, ((self.y-(8/16))*16)*scale, (self.w*16)*scale, (self.h*16)*scale)
	love.graphics.setColor(255, 255, 255, 255)]]
end

function regiontrigger:update(dt)
	local col = checkrect(self.rx, self.ry, self.rw, self.rh, self.checktable, nil, "regiontrigger")
	if self.out == "off" and #col > 0 then
		self.out = "on"
		for i = 1, #self.outtable do
			self.outtable[i][1]:input(self.out, self.outtable[i][2])
		end
	elseif self.out == "on" and #col == 0 then
		self.out = "off"
		for i = 1, #self.outtable do
			self.outtable[i][1]:input(self.out, self.outtable[i][2])
		end
	end
end

function regiontrigger:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end