text = class:new()

function text:init(x, y, r, text)
	self.cox = x
	self.coy = y
	self.x = x-16/16
	self.y = y-16/16
	self.r = r
	self.showtextdefault = true
	self.centered = false
	if text == nil then
		self.text = "text"
		self.color = {255, 255, 255}
	else
		local r = convertr(self.r[3], {"string", "string", "bool", "bool", "bool", "bool"}, true)
		--text
		self.text = r[1]
		--color
		self.color = textcolors[r[2]] or textcolors["white"]
		--outline
		if r[3] ~= nil then
			self.outline = r[3]
		end
		--default off
		if r[4] ~= nil then
			self.showtextdefault = not r[4]
		else
			self.legacy = true
		end
		--centered
		if r[5] ~= nil then
			self.centered = r[5]
		end
		--big
		if r[6] ~= nil then
			self.big = r[6]
		end
	end
	self.drawable = false
	self.showtext = self.showtextdefault
	
	self.outtable = {}
end

function text:draw()
	if self.showtext then
		local x, y = ((self.x))-xscroll, (self.y-(3/16)-yscroll)
		local size, sizesep = 1, 8/16
		if self.big then
			size, sizesep = 2, 1
			y = y - (4/16)
		end
		if self.centered then
			x = x - ((#self.text*sizesep)/2)+.5
		end
		if self.outline then
			love.graphics.setColor(0,0,0,255)
			properprintbackground(self.text, x*16*scale, y*16*scale, false, nil, size)
		end
		love.graphics.setColor(self.color)
		properprint(self.text, x*16*scale, y*16*scale, size)
	end
end

function text:link()
	if #self.r > 3 then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[5]) == v.cox and tonumber(self.r[6]) == v.coy then
					v:addoutput(self)
					if self.legacy then
						self.showtextdefault = false
						self.showtext = false
					end
				end
			end
		end
	end
end

function text:input(t)
	if t == "on" then
		self.showtext = not self.showtextdefault
	elseif t == "off" then
		self.showtext = self.showtextdefault
	elseif t == "toggle" then
		self.showtext = not self.showtext
	end
end

