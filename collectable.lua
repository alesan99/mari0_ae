collectable = class:new()

function collectable:init(x, y, r, collected, coinblock)
	self.cox = x
	self.coy = y

	self.r = {unpack(r)}
	self.t = 1
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	if #self.r > 0 and self.r[1] ~= "link" then
		self.t = self.r[1]
		table.remove(self.r, 1)
	end
	
	self.active = false
	self.static = true

	self.outtable = {}
	self.collected = collected
	if not collected then
		self.update = false
	end
	self.coinblock = coinblock or false
end

function collectable:update(dt)
	if self.collected then
		self:get()
		objects["collectable"][tilemap(self.cox, self.coy)] = nil
	end
end

function collectable:draw()
	if (not self.collected) and (not self.coinblock) then
		love.graphics.draw(collectableimg, collectablequad[spriteset][self.t][coinframe], math.floor((self.cox-1.5-xscroll)*16*scale), ((self.coy-1.5-yscroll)*16-8)*scale, 0, scale, scale)
	end
end

function collectable:get()
	if #self.outtable > 0 then
		self:out("on")
	end
end

function collectable:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end

function collectable:out(t)
	for i = 1, #self.outtable do
		if self.outtable[i][1].input then
			self.outtable[i][1]:input(t, self.outtable[i][2])
		end
	end
end

function collectable:link()
	while #self.r > 2 do
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[2]) == v.cox and tonumber(self.r[3]) == v.coy then
					v:addoutput(self, "collect")
				end
			end
		end
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
	end
end

function collectable:input(t, i)
	if t == "on" or t == "toggle" then
		getcollectable(self.cox, self.coy)
	end
end

--lock
collectablelock = class:new()
function collectablelock:init(x, y, r)
	self.cox = x
	self.coy = y

	self.t = t or 1
	
	self.active = false
	self.static = true

	local vars = r:split("|")
	self.t = tonumber(vars[1]) or 1
	self.count = tonumber(vars[2]) or 1

	self.on = false
	self.initial = true

	self.outtable = {}
end

function collectablelock:update(dt)
	if self.initial and not self.on and collectablescount[self.t] >= self.count then
		self:out("on")
		self.on = true
		self.initial = false
		--return true
	end
end

function collectablelock:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end

function collectablelock:removecheck()
	if self.on and collectablescount[self.t] < self.count then
		self:out("off")
	end
end

function collectablelock:out(t)
	for i = 1, #self.outtable do
		if self.outtable[i][1].input then
			self.outtable[i][1]:input(t, self.outtable[i][2])
		end
	end
end