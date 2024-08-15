squarewave = class:new()

function squarewave:init(x, y, r, vars)
	self.x = x
	self.y = y
	self.cox = x
	self.coy = y
	self.r = r

	self.timer = 0

	local vars = tostring(vars)
	vars = vars:split("|")
	--OFF TIME
	self.time1 = math.max(0.001, tonumber(vars[1])) or 0.5
	--ON TIME
	self.time2 = self.time1
	--VISIBLE
	self.visible = true
	if #vars >= 2 then
		self.time2 = math.max(0.001, tonumber(vars[2])) or 0.5
		self.visible = vars[3] == "true"
	end
	--WAVE OFFSET
	if vars[4] then
		self.timer = tonumber(vars[4])*(self.time1+self.time2)
	end
	
	self.outtable = {}
	
end

function squarewave:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end

function squarewave:update(dt)
	self.timer = self.timer + dt
	if self.timer - dt <= self.time1 and self.timer > self.time1 then
		self:out("on")
	end
	
	if self.timer - dt <= self.time2+self.time1 and self.timer > self.time2+self.time1 then
		self:out("off")
		self.timer = self.timer - self.time2-self.time1
	end
end

function squarewave:out(t)
	for i = 1, #self.outtable do
		if self.outtable[i][1].input then
			self.outtable[i][1]:input(t, self.outtable[i][2])
		end
	end
end

function squarewave:draw()
	if self.visible then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(gateimg, gatequad[2], math.floor((self.x-1-xscroll)*16*scale), ((self.y-1-yscroll)*16-8)*scale, 0, scale, scale)
	end
end
