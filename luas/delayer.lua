delayer = class:new()

function delayer:init(x, y, r, vars)
	self.x = x
	self.y = y
	self.cox = x
	self.coy = y
	self.r = r
	
	self.outtable = {}
	self.lighted = false
	local vars = tostring(vars)
	vars = vars:split("|")
	self.time = tonumber(vars[1]) or 1
	self.visible = (vars[2] or "true") == "true"
	self.timer = 0--self.time
	self.timers = {}
	self.timer2 = 0
	self.quad = 1
	self.activate = false
end

function delayer:link()
	if #self.r > 3 then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[5]) == v.cox and tonumber(self.r[6]) == v.coy then
					v:addoutput(self)
				end
			end
		end
	end
end

function delayer:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end

function delayer:update(dt)
	local delete = {}
	
	for i = 1, #self.timers do
		local v = self.timers[i]
		v.timeleft = v.timeleft - dt
		if v.timeleft <= 0 then
			self:out(v.t)
		
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(self.timers, v) --remove
	end

	if self.activate then
		self.timer = self.timer - dt
		
		if self.timer <= 0 then
			self:out(self.timers[1])
			table.remove(self.timers, 1)
			if #self.timers > 0 then
				self.timer = self.time
			else
				self.activate = false
			end
		end
	end
end

function delayer:draw()
	if self.visible then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(gateimg, gatequad[3], math.floor((self.x-1-xscroll)*16*scale), ((self.y-yscroll-1)*16-8)*scale, 0, scale, scale)
	end
end

function delayer:out(t)
	for i = 1, #self.outtable do
		if self.outtable[i][1].input then
			self.outtable[i][1]:input(t, self.outtable[i][2])
		end
	end
end

function delayer:input(t)
	table.insert(self.timers, {t=t, timeleft=self.time})
end
