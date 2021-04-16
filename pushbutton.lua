pushbutton = class:new()

function pushbutton:init(x, y, dir, r)
	self.cox = x
	self.coy = y
	self.dir = dir
	self.base = "down"
	
	self.out = false
	self.outtable = {}	

	--Input list
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	if #self.r > 0 and self.r[1] ~= "link" then
		local v = convertr(self.r[1], {"string","string"}, true)
		--DIRECTION
		if v[1] then
			self.dir = v[1]
		end
		--BASE
		if v[2] then
			self.base = v[2]
		end
		table.remove(self.r, 1)
	end

	adduserect(x-10/16, y-12/16, 4/16, 12/16, self)
	
	self.timer = pushbuttontime
end

function pushbutton:update(dt)
	if self.timer < pushbuttontime then
		self.timer = self.timer + dt
		if self.timer >= pushbuttontime then
			self.pusheddown = false
			self.timer = pushbuttontime
		end
	end
end

function pushbutton:draw()
	local quad = 1
	if self.pusheddown then
		quad = 2
	end
	
	local horscale = scale
	if self.dir == "right" then
		horscale = -scale
	end
	
	local r = 0
	if self.base == "left" then
		r = math.pi/2
	elseif self.base == "up" then
		r = math.pi
	elseif self.base == "right" then
		r = math.pi*1.5
	end
	
	love.graphics.draw(pushbuttonimg, pushbuttonquad[spriteset][quad], math.floor((self.cox-0.5-xscroll)*16*scale), (self.coy-yscroll-1)*16*scale, r, horscale, scale, 8, 8)
end

function pushbutton:addoutput(a, t)
	table.insert(self.outtable, {a, t or false})
end

function pushbutton:used()
	if self.timer == pushbuttontime then
		self.pusheddown = true
		self.timer = 0
		for i = 1, #self.outtable do
			if self.outtable[i][1].input then
				self.outtable[i][1]:input("toggle", self.outtable[i][2])
			end
		end
	end
end