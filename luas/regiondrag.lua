regiondrag = class:new()

function regiondrag:init(width, height, x, y)
	self.x = tonumber(x) or 1
	self.y = tonumber(y) or 1
	self.width = tonumber(width) or 1
	self.height = tonumber(height) or 1
	self.active = false
	self.static = true
	self.grabbed = {corner1=false, corner2=false, corner3=false, corner4=false, center=false}
	self.over = {corner1=false, corner2=false, corner3=false, corner4=false, center=false}

	self.nubsize = 6
	if android then
		self.nubsize = 12
	end

	self.step = 16/8--how many fraction of tiles will
	--i think i had a stroke when i wrote that
	--change it to 16 if you want it to be smooth
	
	self.outtable = {}
end

function regiondrag:draw()
	--center panel
	if not self.grabbed["corner1"] and not self.grabbed["corner2"] and not self.grabbed["corner3"] and not self.grabbed["corner4"] and (self.over.center or self.grabbed.center) then
		love.graphics.setColor(255, 180, 65, 111)
	else
		love.graphics.setColor(234, 160, 45, 111)
	end
	love.graphics.rectangle("fill", ((((self.x)*16)-xscroll*16))*scale, ((self.y-(8/16)-yscroll)*16)*scale, (self.width*16)*scale, (self.height*16)*scale)
	--corners
	for i = 1, 4 do
		if self.over["corner" .. i] or self.grabbed["corner" .. i] then
			love.graphics.setColor(255, 106, 0, 150)
		else
			love.graphics.setColor(255, 106, 0, 100)
		end
		if i == 1 then
			love.graphics.rectangle("fill", ((((self.x)*16)-xscroll*16)-(self.nubsize*.5))*scale, (((self.y-(8/16)-yscroll)*16)-(self.nubsize*.5))*scale, self.nubsize*scale, self.nubsize*scale)
		elseif i == 2 then
			love.graphics.rectangle("fill", ((((self.x+self.width)*16)-xscroll*16)-(self.nubsize*.5))*scale, ((((self.y)-(8/16)-yscroll)*16)-(self.nubsize*.5))*scale, self.nubsize*scale, self.nubsize*scale)
		elseif i == 3 then
			love.graphics.rectangle("fill", ((((self.x)*16)-xscroll*16)-(self.nubsize*.5))*scale, ((((self.y+self.height)-(8/16)-yscroll)*16)-(self.nubsize*.5))*scale, self.nubsize*scale, self.nubsize*scale)
		elseif i == 4 then
			love.graphics.rectangle("fill", ((((self.x+self.width)*16)-xscroll*16)-(self.nubsize*.5))*scale, ((((self.y+self.height)-(8/16)-yscroll)*16)-(self.nubsize*.5))*scale, self.nubsize*scale, self.nubsize*scale)
		end
	end
	love.graphics.setColor(255, 255, 255, 255)
end

function regiondrag:update(dt)
	local x, y = love.mouse.getPosition()
	x, y = x+((xscroll*16)*scale), y+((yscroll*16)*scale)
	--corner 1
	if x/scale > (self.x*16)-(self.nubsize*.5) and (y/scale)+8 > (self.y*16)-(self.nubsize*.5) and x/scale < (self.x*16)+(self.nubsize*.5) and (y/scale)+8 < (self.y*16)+(self.nubsize*.5) then
		self.over.corner1 = true
	else
		self.over.corner1 = false
	end
	--corner 2
	if x/scale > ((self.x+self.width)*16)-(self.nubsize*.5) and (y/scale)+8 > (self.y*16)-(self.nubsize*.5) and x/scale < ((self.x+self.width)*16)+(self.nubsize*.5) and (y/scale)+8 < (self.y*16)+(self.nubsize*.5) then
		self.over.corner2 = true
	else
		self.over.corner2 = false
	end
	--corner 3
	if x/scale > (self.x*16)-(self.nubsize*.5) and (y/scale)+8 > ((self.y+self.height)*16)-(self.nubsize*.5) and x/scale < (self.x*16)+(self.nubsize*.5) and (y/scale)+8 < ((self.y+self.height)*16)+(self.nubsize*.5) then
		self.over.corner3 = true
	else
		self.over.corner3 = false
	end
	--corner 4
	if x/scale > ((self.x+self.width)*16)-(self.nubsize*.5) and (y/scale)+8 > ((self.y+self.height)*16)-(self.nubsize*.5) and x/scale < ((self.x+self.width)*16)+(self.nubsize*.5) and (y/scale)+8 < ((self.y+self.height)*16)+(self.nubsize*.5) then
		self.over.corner4 = true
	else
		self.over.corner4 = false
	end
	--center
	if x/scale > self.x*16 and (y/scale)+8 > self.y*16 and x/scale < (self.x+self.width)*16 and (y/scale)+8 < (self.y+self.height)*16 and not self.over.corner1 and not self.over.corner2 and not self.over.corner3 and not self.over.corner4 then
		self.over.center = true
	else
		self.over.center = false
	end
	--grabbed
	if self.grabbed.corner1 then
		self.x = math.floor((x/scale)/16*self.step)/self.step
		self.y = math.floor(((y/scale)+8)/16*self.step)/self.step
		self.width = self.x2-self.x
		self.height = self.y2-self.y
	elseif self.grabbed.corner2 then
		self.y = math.floor(((y/scale)+8)/16*self.step)/self.step
		self.height = self.y2-self.y
		self.width = math.floor((x/scale)/16*self.step)/self.step-self.x+1/self.step
	elseif self.grabbed.corner3 then
		self.x = math.floor((x/scale)/16*self.step)/self.step
		self.width = self.x2-self.x
		self.height = math.floor(((y/scale)+8)/16*self.step)/self.step-self.y+1/self.step
	elseif self.grabbed.corner4 then
		self.width = math.floor((x/scale)/16*self.step)/self.step-self.x+1/self.step
		self.height = math.floor(((y/scale)+8)/16*self.step)/self.step-self.y+1/self.step
	elseif self.grabbed.center then
		self.x = round(((x-self.movex)/scale)/16*self.step,0)/self.step+self.oldx
		self.y = round(((y-self.movey)/scale)/16*self.step,0)/self.step+self.oldy
	end
	if self.width < 0 then
		local oldx = self.x
		local x2 = self.x+self.width
		self.x = x2
		self.width = math.abs(self.width)
	end
	if self.height < 0 then
		local oldy = self.y
		local y2 = self.y+self.height
		self.y = y2
		self.height = math.abs(self.height)
	end
	if self.width == 0 then
		self.width = 1/self.step
	end
	if self.height == 0 then
		self.height = 1/self.step
	end
end

function regiondrag:click(x, y, button)
	if self.over.corner1 then
		self.x2 = self.x+self.width
		self.y2 = self.y+self.height
		self.grabbed.corner1 = true
	elseif self.over.corner2 then
		self.grabbed.corner2 = true
		self.y2 = self.y+self.height
	elseif self.over.corner3 then
		self.grabbed.corner3 = true
		self.x2 = self.x+self.width
	elseif self.over.corner4 then
		self.grabbed.corner4 = true
	elseif self.over.center then
		x, y = x+((xscroll*16)*scale), y+((yscroll*16)*scale)
		self.oldx = self.x
		self.oldy = self.y
		self.movex = x
		self.movey = y
		self.grabbed.center = true
	end
end

function regiondrag:unclick(x, y, button)
	self.grabbed = {corner1=false, corner2=false, corner3=false, corner4=false, center=false}
end

function regiondrag:keypress()

end

function regiondrag:keyrelease()

end
