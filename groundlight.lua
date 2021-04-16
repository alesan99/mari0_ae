groundlight = class:new()

function groundlight:init(x, y, dir, r)
	self.x = x
	self.y = y
	self.dir = dir
	self.r = r
	
	self.lighted = false
	self.timer = 0
end

function groundlight:link()
	self.outtable = {}
	if #self.r > 2 then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[4]) == v.cox and tonumber(self.r[5]) == v.coy then
					v:addoutput(self)
				end
			end
		end
	end
end

function groundlight:update(dt)
	if self.timer > 0 then
		self.timer = self.timer - dt
		if self.timer <= 0 then
			self.timer = 0
			self:input("off")
		end
	end
end

function groundlight:draw()
	local statei = 1
	if self.lighted then
		statei = 2
	end
	
	love.graphics.draw(groundlightimg, groundlightquad[spriteset][self.dir][statei], math.floor((self.x-1-xscroll)*16*scale), ((self.y-1-yscroll)*16-8)*scale, 0, scale, scale)
end

function groundlight:input(t)
	if t == "on" then
		self.lighted = true
	elseif t == "off" then
		self.lighted = false
	elseif t == "toggle" then
		self.lighted = true
		self.timer = groundlightdelay
	end
end