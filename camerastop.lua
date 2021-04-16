camerastop = class:new()

function camerastop:init(x, y, r)
	self.cox = x
	self.coy = y
	self.rx = self.cox-1
	self.ry = self.coy-1
	self.rw = 1
	self.rh = 1

	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	
	if #self.r > 0 and self.r[1] ~= "link" then
		--rightclick things
		local v = convertr(self.r[1], {"num", "num", "num", "num", "bool", "bool"}, true)
		self.rx = (self.cox-1)+v[3]
		self.ry = (self.coy-1)+v[4]
		self.rw = v[1]
		self.rh = v[2]
		self.forcepush = v[5] --forcefully push camera out of way?
		self.ignoreifoffscreen = v[6]
		table.remove(self.r, 1)
	end

	self.power = true
end

function camerastop:collide(oldx, oldy)
	local playersonscreen = true
	if self.ignoreifoffscreen then
		for i = 1, players do
			local p = objects["player"][i]
			if not onscreen(p.x,p.y,p.width,p.height) then
				playersonscreen = false
				break
			end
		end
	end
	if self.power and ((not self.ignoreifoffscreen) or playersonscreen) then
		local x1, y1, w1, h1 = self.rx, self.ry-.5, self.rw, self.rh
		local xscroll, yscroll = splitxscroll[1], splityscroll[1]
		local x2, y2, w2, h2 = xscroll, yscroll, width, height
		if x1+w1 >= x2 and x1 <= x2+w2 and y1+h1 >= y2 and y1 <= y2+h2 then
			--force push if camera is inside box
			local forcepush = false
			if self.forcepush then
				local cx, cy = (x2+w2/2), (y2+h2/2) --camera center pos
				if cx < x1 then
					forcepush = "left"
				end
				if cx > x1+w1 then
					forcepush = "right"
				end
				if cy > y1+h1 then
					forcepush = "down"
				end
				if cy < y1 then
					forcepush = "up"
				end
			end
			--right
			if (oldx+width <= x1 and xscroll+width > x1) or forcepush == "left" then
				splitxscroll[1] = math.max(0, x1-width)
			--left
			elseif (oldx >= x1+w1 and xscroll < x1+w1) or forcepush == "right" then
				splitxscroll[1] = math.min(mapwidth-width, x1+w1)
			end
			--down
			if (oldy+height <= y1 and yscroll+height > y1) or forcepush == "up" then
				splityscroll[1] = math.max(0, y1-height)
			--up
			elseif (oldy >= y1+h1 and yscroll < y1+h1) or forcepush == "down" then
				splityscroll[1] = math.min(mapheight-1-height, y1+h1)
			end

			if xscroll ~= splitxscroll[1] or yscroll ~= splityscroll[1] then
				generatespritebatch()
			end
		end
	end
end

function camerastop:link()
	while #self.r >= 3 do
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[2]) == v.cox and tonumber(self.r[3]) == v.coy then
					self.linked = true
					v:addoutput(self, self.r[4] or "power")
				end
			end
		end
		
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
	end
end

function camerastop:input(t, input)
	if input == "power" then
		if t == "on" then
			self.power = false
		elseif t == "off" then
			self.power = true
		else
			self.power = not self.power
		end
	end
end