animatedquad = class:new()

function animatedquad:init(imgpath, s, t)
	self.image = love.graphics.newImage(imgpath)
	self.t = t
	if self.image:getHeight() > 16 then
		self.number = t
		self.imagedata = love.image.newImageData(imgpath)
		self.quadlist = {}
		for x = 1, math.floor(self.image:getWidth()/17) do
			table.insert(self.quadlist, love.graphics.newQuad((x-1)*17, 0, 16, 16, self.image:getWidth(), self.image:getHeight()))
		end
		self.quad = self.quadlist[1]
		self.quadi = 1
		getquadprops(self.imagedata, 1, 1, self)
		self.properties = {}
		for x = 1, #self.quadlist do
			self.properties[x] = {}
			getquadprops(self.imagedata, x, 1, self.properties[x])
		end
		self.props = self.properties[self.quadi]
		self.delays = {}
		self.timer = 0
		self.spikes = {}
		
		self.delays = s:split(",")
		
		if self.delays[1] == "triggered" then
			self.triggered = true
			table.remove(self.delays, 1)
		else
			for i, v in ipairs(self.properties) do
				if self.props.collision ~= v.collision or self.props.portalable ~= v.portalable then
					self.cache = {}
					break
				end
			end
		end
		
		for i = 1, #self.delays do
			self.delays[i] = tonumber(self.delays[i])
		end
		
		local delaycount = #self.delays
		for j = #self.delays+1, #self.quadlist do
			self.delays[j] = self.delays[math.fmod(j-1, delaycount)+1]
		end
	else
		self.quadlist = {}
		for x = 1, math.floor(self.image:getWidth()/16) do
			table.insert(self.quadlist, love.graphics.newQuad((x-1)*16, 0, 16, 16, self.image:getWidth(), self.image:getHeight()))
		end
		self.quad = self.quadlist[1]
		self.quadi = 1
		self.properties = s
		self.delays = {}
		self.timer = 0
		
		local lines
		if string.find(s, "\r\n") then
			lines = s:split("\r\n")
		else
			lines = s:split("\n")
		end
		
		for i = 1, #lines do
			local s2 = lines[i]:split("=")
			local s3
			if string.find(s2[1], ":") then
				s3 = s2[1]:split(":")
			else
				s3 = {s2[1]}
			end
			if s3[1] == "delay" then
				local s4 = s2[2]:split(",")
				
				for j = 1, #s4 do
					if tonumber(s4[j]) then
						self.delays[j] = tonumber(s4[j])/1000
					else
						notice.new("bad animated tile delay " .. j .. "\n" .. tostring(t-90000) .. ".txt", notice.red, 10)
					end
				end
			else
				self[s3[1]] = (s2[2] == "true")
			end
		end
		
		for j = #self.delays+1, #self.quadlist do
			self.delays[j] = self.delays[#self.delays]
		end
	end
end

function animatedquad:updateproperties()
	local oldcol = self.collision
	local oldportalable = self.portalable
	
	self.props = self.properties[self.quadi]
	if not self.props then
		self.props = {}
	end
	for i, t in pairs(self.props) do
		self[i] = t
	end
	
	if self.cache then --only go through animated tiles
		if (oldcol ~= self.props.collision) or (oldportalable ~= self.props.portalable) then
			for i, v in ipairs(self.cache) do
				local x = v.x
				local y = v.y
				if oldcol ~= self.props.collision then --change collision
					if self.props.collision then
						objects["tile"][tilemap(x, y)] = tile:new(x-1, y-1)
					else
						objects["tile"][tilemap(x, y)] = nil
						checkportalremove(x, y)
					end
				elseif oldportalable ~= self.props.portalable then --change portalbility
					if oldportalable ~= self.portalable and not self.props.portalable then
						checkportalremove(x, y)
					end
				end
				local b = objects["tile"][tilemap(x, y)]
				if b then
					b.PLATFORM = self.props.platform
					b.PLATFORMDOWN = self.props.platformdown
					b.PLATFORMLEFT = self.props.platformleft
					b.PLATFORMRIGHT = self.props.platformright
				end
			end
		end
	end
end

function animatedquad:update(dt)
	if self.triggered then
		return false
	end
	if (not pausemenuopen) and self.delays[self.quadi] then
		self.timer = self.timer + dt
		while self.timer > self.delays[self.quadi] do
			self.timer = self.timer - self.delays[self.quadi]
			self.quadi = self.quadi + 1
			if self.quadi > #self.quadlist then
				self.quadi = 1
			end
			self.quad = self.quadlist[self.quadi]
			if animatedtilesframe[self.t] ~= self.quadi then
				animatedtilesframe[self.t] = self.quadi
				if self.props and objects then
					self:updateproperties()
				end
			end
		end
	end
end

function animatedquad:getquad(x, y)
	if self.triggered and x and y and animatedtimers and animatedtimers[x] and animatedtimers[x][y] then
		return self.quadlist[animatedtimers[x][y]:geti()]
	else
		return self.quadlist[self.quadi]
	end
end

local function getquadprops(self)
	local list = {"collision",
	"invisible",
	"breakable",
	"coinblock",
	"coin",
	"portalable",
	"platform",
	"spikesup",
	"spikesdown",
	"spikesleft",
	"spikesright",
	"grate",
	"water",
	"mirror",
	"foreground",
	"bridge",
	"lava",
	"leftslant",
	"rightslant",
	"noteblock",
	"vine",
	"ice"}
	local t = {}
	for i, w in pairs(list) do
		t[w] = self[w]
	end
	return t
end

function animatedquad:getproperty(s, x, y)
	if self.triggered and x and y and animatedtimers and animatedtimers[x] and animatedtimers[x][y] then
		return self.properties[animatedtimers[x][y]:geti()][s]
	else
		if not self.props then
			self.props = getquadprops(self, self.quadi, 1, self.properties[self.quadi])
		end
		return self[s]
	end
end