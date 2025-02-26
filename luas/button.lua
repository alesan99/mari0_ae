button = class:new()

function button:init(x, y, t, r)
	self.cox = x
	self.coy = y
	
	--PHYSICS STUFF
	self.x = x-15/16
	self.y = y-3/16
	self.width = 30/16
	self.height = 3/16
	self.static = true
	self.active = false
	self.category = 22
	
	self.dir = "down"
	self.t = t or 1
	if self.t == 2 or self.t == 3 then
		self.checktable = {"box"}
	else
		self.checktable = {"player", "box", "core", "powblock", "smallspring", "pbutton", "enemy"}
		for i, v in pairs(enemies) do
			if v ~= "icicle" and v ~= "chainchomp" then
				table.insert(self.checktable, v)
			end
		end
	end

	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)
	--DIRECTION
	if #self.r > 0 and self.r[1] ~= "link" then
		self.dir = self.r[1]
		table.remove(self.r, 1)
	end
	
	self.mask = {true}
	
	self.drawable = false
	
	self.out = false
	self.outtable = {}
	self.pressings = {}
end

function button:update(dt)
	local x, y, width, height
	if self.dir == "down" then
		x = self.x+5/16
		y = self.y-2/16
		width = 20/16
		height = 1
	elseif self.dir == "left" then
		x = self.x-12/16
		y = self.y-7/16
		width = 1
		height = 20/16
	elseif self.dir == "right" then
		x = self.x+10/16
		y = self.y-7/16
		width = 1
		height = 20/16
	elseif self.dir == "up" then
		x = self.x+5/16
		y = self.y-24/16
		width = 20/16
		height = 1
	end
	
	local colls = checkrect(x, y, width, height, self.checktable)
	
	--ignore certain entities (needed for cube and sphere buttons for example)
	local delete
	for j = 1, #colls, 2 do
		local rem = false
		local obj = objects[colls[j]][colls[j+1]]
		if (self.t == 2 and (obj.t ~= "box1" and obj.t ~= "box2")) or (self.t == 3 and obj.t ~= "edgeless") or obj.doesntpressbuttons then
			if not delete then delete = {} end
			table.insert(delete, j)
			table.insert(delete, j+1)
		end
	end
	
	if delete then
		table.sort(delete, function(a,b) return a>b end)
		
		for i, v in pairs(delete) do
			table.remove(colls, v)
		end
	end
	
	--update lights on cubes
	for j = 1, #colls, 2 do
		local add = true
		for i, v in pairs(self.pressings) do
			if objects[colls[j]][colls[j+1]] == v then
				add = false
			end
		end
		
		if add then
			table.insert(self.pressings, objects[colls[j]][colls[j+1]])
			if objects[colls[j]][colls[j+1]].onbutton then
				objects[colls[j]][colls[j+1]]:onbutton(true)
			end
		end
	end
	
	local delete
	for i, v in pairs(self.pressings) do
		local rem = true
		for j = 1, #colls, 2 do
			if objects[colls[j]][colls[j+1]] == v then
				rem = false
			end
		end
		
		if rem then
			if not delete then delete = {} end
			table.insert(delete, i)
		end
	end
	if delete then
		table.sort(delete, function(a,b) return a>b end)
		for i, v in pairs(delete) do
			if self.pressings[v].onbutton then
				self.pressings[v]:onbutton(false)
			end
			table.remove(self.pressings, v)
		end
	end
	
	--send out put if being pressed
	if (#colls > 0) ~= self.out then
		self.out = not self.out
		for i = 1, #self.outtable do
			if self.outtable[i][1].input then
				if self.out then
					self.outtable[i][1]:input("on", self.outtable[i][2])
				else
					self.outtable[i][1]:input("off", self.outtable[i][2])
				end
			end
		end
	end
end

function button:draw()
	local quad = 1
	if self.out then
		quad = 2
	end

	if self.dir == "down" then	
		love.graphics.draw(buttonimg, buttonquad[spriteset][self.t][quad], math.floor((self.x-1/16-xscroll)*16*scale), ((self.y-yscroll)*16-10)*scale, 0, scale, scale)
	elseif self.dir == "left" then
		love.graphics.draw(buttonimg, buttonquad[spriteset][self.t][quad], math.floor((self.x+4/16-xscroll)*16*scale), ((self.y-yscroll)*16-21)*scale, math.pi/2, scale, scale)
	elseif self.dir == "right" then
		love.graphics.draw(buttonimg, buttonquad[spriteset][self.t][quad], math.floor((self.x+10/16-xscroll)*16*scale), ((self.y-yscroll)*16+11)*scale, -math.pi/2, scale, scale)
	elseif self.dir == "up" then
		love.graphics.draw(buttonimg, buttonquad[spriteset][self.t][quad], math.floor((self.x+31/16-xscroll)*16*scale), ((self.y-yscroll)*16-16)*scale, math.pi, scale, scale)
	end
end

function button:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end
