animatedtiletrigger = class:new()

function animatedtiletrigger:init(x, y, r)
	self.x = x
	self.y = y
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	
	self.visible = true
	
	--VISIBLE & REGION
	if #self.r > 0 and self.r[1] ~= "link" then
		local s = self.r[1]:gsub("n", "-")
		s = s:split("|")

		self.visible = (s[1] == "true")

		self.regionX, self.regionY, self.regionwidth, self.regionheight = self.x-1+(tonumber(s[4]) or 0), self.y-1+(tonumber(s[5]) or 0), tonumber(s[2]), tonumber(s[3])
		
		table.remove(self.r, 1)
	end
end

function animatedtiletrigger:link()
	while #self.r > 2 do
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

function animatedtiletrigger:update()

end

function animatedtiletrigger:draw()	
	if self.visible then
		love.graphics.draw(gateimg, gatequad[6], math.floor((self.x-1-xscroll)*16*scale), ((self.y-yscroll-1)*16-8)*scale, 0, scale, scale)
	end
end

function animatedtiletrigger:input(t, input)
	for x = self.regionX+1, self.regionX + self.regionwidth do
		for y = self.regionY+1, self.regionY + self.regionheight do
			if animatedtimers[x] and animatedtimers[x][y] then
				animatedtimers[x][y]:input(t)
			end
		end
	end
end