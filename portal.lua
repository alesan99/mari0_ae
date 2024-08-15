portal = class:new()

function portal:init(number, c1, c2)	
	self.number = number
	self.portal1color = c1 or getDefaultPortalColor(1)
	self.portal2color = c2 or getDefaultPortalColor(2)
	self.animationtimer = 0
	self.portalframe = 1
	self.openscale = {0, 0}
	
	self.x1, self.y1, self.facing1, self.x2, self.y2, self.facing2 = false, false, false, false, false, false
end

function portal:createportal(i, cox, coy, side, tendency)
	if cox and tendency then
		local otheri = 1
		if i == 1 then
			otheri = 2
		end
		
		moveoutportal(i)
	
		--remove the portal temporarily so that it doesn't obstruct itself
		local oldx, oldy, oldfacing
		if i == 1 then
			oldx, oldy, oldfacing = self.x1, self.y1, self.facing1
			self.x1, self.y1 = false, false
		else
			oldx, oldy, oldfacing = self.x2, self.y2, self.facing2
			self.x2, self.y2 = false, false
		end
		
		local newx, newy = getportalposition(i, cox, coy, side, tendency)
		
		if newx and (newx ~= oldx or newy ~= oldy or side ~= oldfacing) then
			if i == 1 then
				self.x1 = newx
				self.y1 = newy
				self.facing1 = side
			else
				self.x2 = newx
				self.y2 = newy
				self.facing2 = side
			end
	
			--physics
			--Recreate old hole
			if oldfacing == "up" then	
				modifyportaltiles(oldx, oldy, 1, 0, self, i, "add")
			elseif oldfacing == "down" then	
				modifyportaltiles(oldx, oldy, -1, 0, self, i, "add")
			elseif oldfacing == "left" then	
				modifyportaltiles(oldx, oldy, 0, -1, self, i, "add")
			elseif oldfacing == "right" then	
				modifyportaltiles(oldx, oldy, 0, 1, self, i, "add")
			end
			
			if oldx == false then --Remove blocks from other portal
				local x, y, side
				if otheri == 1 then
					side = self.facing1
					x, y = self.x1, self.y1
				else
					side = self.facing2
					x, y = self.x2, self.y2
				end
					
				if side == "up" then
					modifyportaltiles(x, y, 1, 0, self, otheri, "remove")
				elseif side == "down" then
					modifyportaltiles(x, y, -1, 0, self, otheri, "remove")
				elseif side == "left" then
					modifyportaltiles(x, y, 0, -1, self, otheri, "remove")
				elseif side == "right" then
					modifyportaltiles(x, y, 0, 1, self, otheri, "remove")
				end
			end
			
			if i == 1 then
				playsound("portal1open")
			else
				playsound("portal2open")
			end
			
			modifyportalwalls()
			updateranges()
			self.openscale[i] = 0
		else
			--recreate the temporarily removed portal
			self["x" .. i],  self["y" .. i] = oldx, oldy
		end
	end

	if i == 1 then
		if self.x1 and self.y1 then
			return self.x1, self.y1, self.facing1
		else
			return oldx, oldy, oldfacing
		end
	else
		if self.x2 and self.y2 then
			return self.x2, self.y2, self.facing1
		else
			return oldx, oldy, oldfacing
		end
	end
end

function portal:removeportal(i)
	if self["x" .. i] then
		moveoutportal(i)
		local otheri = 1
		if i == 1 then
			otheri = 2
		end
		
		if self["facing" .. i] == "up" then	
			modifyportaltiles(self["x" .. i], self["y" .. i], 1, 0, self, i, "add")
		elseif self["facing" .. i] == "down" then	
			modifyportaltiles(self["x" .. i], self["y" .. i], -1, 0, self, i, "add")
		elseif self["facing" .. i] == "left" then	
			modifyportaltiles(self["x" .. i], self["y" .. i], 0, -1, self, i, "add")
		elseif self["facing" .. i] == "right" then	
			modifyportaltiles(self["x" .. i], self["y" .. i], 0, 1, self, i, "add")
		end
		
		if self["x" .. otheri] then
			if self["facing" .. otheri] == "up" then	
				modifyportaltiles(self["x" .. otheri], self["y" .. otheri], 1, 0, self, otheri, "add")
			elseif self["facing" .. otheri] == "down" then	
				modifyportaltiles(self["x" .. otheri], self["y" .. otheri], -1, 0, self, otheri, "add")
			elseif self["facing" .. otheri] == "left" then	
				modifyportaltiles(self["x" .. otheri], self["y" .. otheri], 0, -1, self, otheri, "add")
			elseif self["facing" .. otheri] == "right" then	
				modifyportaltiles(self["x" .. otheri], self["y" .. otheri], 0, 1, self, otheri, "add")
			end
		end
		
		self["x" .. i] = false
		self["y" .. i] = false
		self["facing" .. i] = false
		
		modifyportalwalls()
		for j = 1, 6 do
			objects["portalwall"][self.number .. "-" .. i .. "-" .. j] = nil
		end
		updateranges()
	end
end

function portal:update(dt)
	self.animationtimer = self.animationtimer + dt
	while self.animationtimer > portalanimationdelay do
		self.animationtimer = 0
		self.portalframe = self.portalframe + 1
		if self.portalframe > portalanimationcount then
			self.portalframe = 1
		end
	end
	
	for i = 1, 2 do
		self.openscale[i] = math.min(1, self.openscale[i]+dt*15)
	end
end

function portal:draw()
	for i = 1, 2 do
		if self["x" .. i] ~= false then
			--Standard values "up"
			local rotation = 0
			local offsetx, offsety = 16, -3
			if self["facing" .. i] == "right" then
				rotation = math.pi/2
				offsetx, offsety = 11, 8
			elseif self["facing" .. i] == "down" then
				rotation = math.pi
				offsetx, offsety = 0, 3
			elseif self["facing" .. i] == "left" then
				rotation = math.pi*1.5
				offsetx, offsety = 5, -8
			end
			
			local glowalpha = 100
			if self.x2 and self.x1 then
				--portal glow
				love.graphics.setColor(255, 255, 255, 80 - math.abs(self.portalframe-3)*10)
				love.graphics.draw(portalglowimg, math.floor(((self["x" .. i]-1-xscroll)*16+offsetx)*scale), math.floor(((self["y" .. i]-yscroll-1)*16+offsety)*scale), rotation, scale*self.openscale[i], scale, 16, 20)
				love.graphics.setColor(255, 255, 255, 255)
			end
			
			love.graphics.setColor(self["portal" .. i .. "color"])
			love.graphics.draw(portalimg, portalquad[self.portalframe], math.floor(((self["x" .. i]-1-xscroll)*16+offsetx)*scale), math.floor(((self["y" .. i]-yscroll-1)*16+offsety)*scale), rotation, scale*self.openscale[i], scale, 16, 8)
		end
	end
end
