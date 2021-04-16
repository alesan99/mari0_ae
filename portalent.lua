portalent = class:new()

function portalent:init(x, y, i, r)
	self.cox = x
	self.coy = y
	self.x = x
	self.y = y
	self.placedx = x
	self.placedy = y
	
	self.dir = "up"
	self.portal = i
	self.id = 1
	self.power = false

	--Input list
	self.input1state = "off"
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	
	--DIRECTION AND ID
	local v = convertr(self.r[1], {"string", "num", "bool"}, true)
	if #self.r > 0 and self.r[1] ~= "link" then
		if v[1] then
			self.dir = v[1]
		end
		--ID
		if v[2] then
			self.id = tonumber(v[2])
		end
		--POWER
		if v[3] ~= nil and v[3] then
			self.power = true
		end
		table.remove(self.r, 1)
	end
	
	if not portals[self.id] then
		portals[self.id] = portal:new(self.id)
	end
	
	if self.power then
		self:trigger()
	end
end

function portalent:link()
	while #self.r >= 3 do
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[2]) == v.cox and tonumber(self.r[3]) == v.coy then
					v:addoutput(self, self.r[4] or "power")
				end
			end
		end
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
	end
end

function portalent:update(dt)
	
end

function portalent:draw()
	
end

function portalent:input(t, input)
	if input == "power" then
		local oldpower = self.power
		if t == "on" and self.input1state == "off" then
			self.power = not self.power
		elseif t == "off" and self.input1state == "on" then
			self.power = not self.power
		elseif t == "toggle" then
			self.power = not self.power
		end
		
		if self.power and not oldpower then
			self:trigger()
		elseif not self.power and oldpower then
			self:rem()
		end
		
		self.input1state = t
	end
end

function portalent:trigger()
	local portal = portals[self.id]
	--[[if objects["player"][self.id] then
		portal = objects["player"][self.id].portals
	end]]
	self.placedx, self.placedy = portal:createportal(self.portal, self.x, self.y, self.dir, -1)
end

function portalent:rem()
	if portals[self.id]["x" .. self.portal] == self.placedx and portals[self.id]["y" .. self.portal] == self.placedy and portals[self.id]["facing" .. self.portal] == self.dir then
		portals[self.id]:removeportal(self.portal)
	else
		print("Portal wasn't removed because it isn't at this position")
	end
end