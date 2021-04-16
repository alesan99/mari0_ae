tiletool = class:new()

function tiletool:init(x, y, r, func)
	self.x = x-1
	self.y = y-1
	self.cox = x
	self.coy = y

	self.func = "nothing"
	self.regionX, self.regionY, self.regionwidth, self.regionheight = self.cox, self.coy, 1, 1
	
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	local v = convertr(self.r[1], {"string", "num", "num", "num", "num"}, true)
	if v then
		if v[1] then
			self.func = v[1]
		end
		if v[2] and v[3] and v[4] and v[5] then
			self.regionX, self.regionY, self.regionwidth, self.regionheight = self.cox+(tonumber(v[4]) or 0), self.coy+(tonumber(v[5]) or 0), tonumber(v[2]), tonumber(v[3])
		end
		table.remove(self.r, 1)
	end
	self.drawable = false
	
	self.tileid = {}
	for x = self.regionX, self.regionX + self.regionwidth-1 do
		for y = self.regionY, self.regionY + self.regionheight-1 do
			if inmap(x, y) then
				if string.find(self.func, "set back to ") then
					self.tileid[tilemap(x, y)] = map[x][y]["back"] or 1--background tile
				else
					self.tileid[tilemap(x, y)] = map[x][y][1] or 1
				end
				if self.func == "group" then
					map[x][y]["group"] = {self.regionX, self.regionY, self.regionX+self.regionwidth-1, self.regionY+self.regionheight-1}
				end
			end
		end
	end
	self.tileidfarcheck = true
	
	self.on = false
	self.linked = false
	self.outtable = {}
	
	if string.find(self.func, "check gel ") then
		self.checkgelside = "all"
		self.checkgelid = 1
		self:checkgel()
		self.power = true
	end
end

function tiletool:update(dt)
	if self.checkgelside then
		local gel = false
		if self.checkgelside == "all" then
			for x = self.regionX, self.regionX + self.regionwidth-1 do
				for y = self.regionY, self.regionY + self.regionheight-1 do
					if inmap(x, y) then
						if map[x][y]["gels"]["top"] == self.checkgelid
						 or map[x][y]["gels"]["bottom"] == self.checkgelid
						 or map[x][y]["gels"]["left"] == self.checkgelid
						 or map[x][y]["gels"]["right"] == self.checkgelid then
							gel = true
							break
						end
					end
				end
			end
		else
			for x = self.regionX, self.regionX + self.regionwidth-1 do
				for y = self.regionY, self.regionY + self.regionheight-1 do
					if inmap(x, y) then
						if map[x][y]["gels"][self.checkgelside] == self.checkgelid then
							gel = true
							break
						end
					end
				end
			end
		end

		if gel then
			if self.power == false then
				self:out("on")
				self.power = true
			end
		else
			if self.power == true then
				self:out("off")
				self.power = false
			end
		end
	end
end

function tiletool:link()
	while #self.r >= 3 do
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[2]) == v.cox and tonumber(self.r[3]) == v.coy then
					v:addoutput(self)
					self.linked = true
				end
			end
		end
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
	end
end

function tiletool:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end

function tiletool:out(t)
	for i = 1, #self.outtable do
		if self.outtable[i][1].input then
			self.outtable[i][1]:input(t, self.outtable[i][2])
		end
	end
end

function tiletool:input(t)
	if t == "on" then
		self.on = true
		self:trigger()
	elseif t == "off" then
		self.on = false
		self:trigger()
	elseif t == "toggle" then
		self.on = not self.on
		self:trigger()
	end
end

function tiletool:hit() --activate when block is hit
	if #self.outtable == 0 then
		self.on = not self.on
		self:trigger()
	end
end

function tiletool:trigger()
	local updatespritebatch = false
	for x = self.regionX, self.regionX + self.regionwidth-1 do
		for y = self.regionY, self.regionY + self.regionheight-1 do
			if inmap(x, y) then
				if self:action(x, y) then
					updatespritebatch = true
				end
			end
		end
	end
	if updatespritebatch then
		generatespritebatch()
	end
end

function tiletool:action(cox, coy)
	if self.func == "remove" then
		if (self.on or not self.linked) then
			objects["tile"][tilemap(cox, coy)] = nil
			map[cox][coy][1] = 1
			map[cox][coy]["gels"] = {}
			checkportalremove(cox, coy)
			self:updateranges()
			return true
		else
			map[cox][coy][1] = self.tileid[tilemap(cox, coy)]
			if tilequads[map[cox][coy][1]].collision then
				objects["tile"][tilemap(cox, coy)] = tile:new(cox-1, coy-1, 1, 1, true)
			end
			self:updateranges()
			return true
		end
	elseif self.func == "break" then
		--(tilequads[map[cox][coy][1]].breakable or (tilequads[map[cox][coy][1]].debris and blockdebrisquads[tilequads[map[cox][coy][1]].debris])) and 
		if tilequads[map[cox][coy][1]].collision and (self.on or not self.linked) then
			destroyblock(cox, coy, "nospritebatch")
			return true
		end
	elseif string.find(self.func, "change to ") then
		local tilei = self.func:sub(11, -1)
		if tonumber(tilei) ~= nil and math.floor(tonumber(tilei)) ~= 0 and map and map[cox] and map[cox][coy] and map[cox][coy][1] then
			local changeid = math.floor(tonumber(tilei))
			if (self.on or not self.linked) and tilequads[changeid] then
				objects["tile"][tilemap(cox, coy)] = nil
				map[cox][coy][1] = changeid
				if tilequads[map[cox][coy][1]].collision then
					objects["tile"][tilemap(cox, coy)] = tile:new(cox-1, coy-1, 1, 1, true)
				end
				checkportalremove(cox, coy)
				self:updateranges()
				return true
			else
				objects["tile"][tilemap(cox, coy)] = nil
				map[cox][coy][1] = self.tileid[tilemap(cox, coy)]
				if tilequads[map[cox][coy][1]].collision then
					objects["tile"][tilemap(cox, coy)] = tile:new(cox-1, coy-1, 1, 1, true)
				end
				checkportalremove(cox, coy)
				self:updateranges()
				return true
			end
		end
	elseif string.find(self.func, "set back to ") then
		local tilei = self.func:sub(13, -1)
		if tonumber(tilei) ~= nil and math.floor(tonumber(tilei)) ~= 0 and map and map[cox] and map[cox][coy] and map[cox][coy][1] then
			local changeid = math.floor(tonumber(tilei))
			bmap_on = true
			if (self.on or not self.linked) and tilequads[changeid] then
				map[cox][coy]["back"] = changeid
				return true
			else
				map[cox][coy]["back"] = self.tileid[tilemap(cox, coy)]
				return true
			end
		end
	elseif self.func == "hit" or self.func == "bump" then
		if (self.on or not self.linked) then
			hitblock(cox, coy, {size=2, nospritebatch=true})
			return true
		end
	elseif self.func == "explode" then
		if map[cox][coy][1] == self.tileid[tilemap(cox, coy)] and (self.on or not self.linked) then 
			playsound(boomsound)
			objects["tile"][tilemap(cox, coy)] = nil
			map[cox][coy][1] = 1
			map[cox][coy]["gels"] = {}
			self:updateranges()
			return true
		end
	elseif string.find(self.func, "set gel ") then
		local s = self.func:split(" ")
		local side = s[3] or "all"
		if side == "down" then
			side = "bottom"
		elseif side == "up" then
			side = "top"
		end
		local id = tonumber(s[4] or 1) or 1
		if (self.on or (not self.linked)) then
			if side ~= "all" then
				if id ~= nil then
					map[cox][coy]["gels"][side] = id
				end
			else
				map[cox][coy]["gels"]["top"] = id
				map[cox][coy]["gels"]["left"] = id
				map[cox][coy]["gels"]["right"] = id
				map[cox][coy]["gels"]["bottom"] = id
			end
		else
			map[cox][coy]["gels"] = {}
		end
	elseif self.func == "collect sides" then
		if self.on then
			if tilequads[map[cox-1][coy][1]].coin then 
				collectcoin(cox-1, coy)
			end
			if tilequads[map[cox+1][coy][1]].coin then
				collectcoin(cox+1, coy)
			end
			if tilequads[map[cox][coy][1]].coin then
				collectcoin(cox, coy)
			end
		end
	elseif self.func == "block debris" then
		if self.on then
			table.insert(blockdebristable, blockdebris:new(cox-.5, coy-.5, 3.5, -23))
			table.insert(blockdebristable, blockdebris:new(cox-.5, coy-.5, -3.5, -23))
			table.insert(blockdebristable, blockdebris:new(cox-.5, coy-.5, 3.5, -14))
			table.insert(blockdebristable, blockdebris:new(cox-.5, coy-.5, -3.5, -14))
		end
	elseif self.func == "remove gel" then
		if self.on then
			map[cox][coy]["gels"] = {}
		end
	elseif string.find(self.func, "mod ") and string.find(self.func, " to ") then
		--backwards compatibility!
		local s = self.func:split(" ")
		local x = tonumber(math.floor(s[2]))
		local y = tonumber(math.floor(s[3]))
		local s2 = self.func:split(" to ")
		local id = tonumber(math.floor(s2[2]))
		if self.tileidfarcheck then
			self.tileidfar = map[x][y][1]
			self.tileidfarcheck = false
		end
		if self.on then
			map[x][y][1] = id
		else
			map[x][y][1] = self.tileidfar
		end
		if tilequads[map[x][y][1]].collision then
			objects["tile"][tilemap(x, y)] = tile:new(x-1, y-1, 1, 1, true)
		else
			objects["tile"][tilemap(x, y)] = nil
		end
		checkportalremove(x, y)
		return true
	elseif string.find(self.func, "hit range ") then
		--backwards compatibility!
		local idiot80 = self.func:split("hit range ")
		local range = math.floor(tonumber(idiot80[2]))
		if range ~= nil and range ~= 0 and range <= 10 then
			if map[self.cox][self.coy][1] == self.tileid and (self.on or not self.linked) then
				for x = self.cox-range, self.cox+range do
					for y = self.coy-range, self.coy+range do
						hitblock(x, y, {size=2}, {nospritebatch=true})
					end
				end
				generatespritebatch()
			end
		end
	end
end

function tiletool:checkgel()
	local s = self.func:split(" ")
	local id = tonumber(s[3] or 1) or 1
	local side = s[4] or "all"
	if side == "up" then
		side = "top"
	elseif side == "down" then
		side = "bottom"
	end
	if id ~= nil and side ~= nil then
		self.checkgelside = side
		self.checkgelid = id
	end
end

function tiletool:updateranges()
	for i, v in pairs(objects["laser"]) do
		v:updaterange()
	end
	for i, v in pairs(objects["lightbridge"]) do
		v:updaterange()
	end
	for i, v in pairs(objects["funnel"]) do
		v:updaterange()
	end
end