musicchanger = class:new()

function musicchanger:init(x, y, r, music)
	self.x = x
	self.y = y
	self.cox = x
	self.coy = y
	self.r = r
	local vars = {music}
	if music:find("|") then
		vars = music:split("|")
	end
	self.m = readlevelfilesafe(vars[1] or "")
	self.customn = vars[2] or 1
	self.music = "none"
	if self.m == "overworld" then
		self.music = "overworld"
	elseif self.m == "underground" then
		self.music = "underground"
	elseif self.m == "castle" then
		self.music = "castle"
	elseif self.m == "underwater" then
		self.music = "underwater"
	elseif self.m == "star" then
		self.music = "starmusic"
	elseif self.m == "custom" then
		if vars[2] then
			if custommusics[tonumber(self.customn) or 1] then
				self.music = custommusics[tonumber(self.customn) or 1]
			end
		else
			if custommusic then
				self.music = custommusic
			end
		end
	else
		self.music = mappackfolder .. "/" .. mappack .. "/" .. self.m
	end
	self.visible = ((vars[3] or "true") == "true")
	self.on = false
	
	self.outtable = {}
end

function musicchanger:link()
	if #self.r > 3 then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[5]) == v.cox and tonumber(self.r[6]) == v.coy then
					v:addoutput(self)
				end
			end
		end
	end
end

function musicchanger:draw()
	if self.visible then
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(gateimg, gatequad[5], math.floor((self.x-1-xscroll)*16*scale), ((self.y-1-yscroll)*16-8)*scale, 0, scale, scale)
	end
end

function musicchanger:play()
	stopmusic()
	music:stop(custommusic)
	--stop all music changers
	for j, w in pairs(objects["musicchanger"]) do
		if w.cox ~= self.cox or w.coy ~= self.coy then
			w:cease()
		end
	end
	music:play(self.music)
	self.on = true
end

function musicchanger:stop()
	music:stop(self.music)
	playmusic()
	self.on = false
end

function musicchanger:cease()
	music:stop(self.music)
	self.on = false
end

function musicchanger:input(t)
	if t == "off" then
		if self.on then
			self:stop()
		end
	elseif t == "on" then
		if not self.on then
			self:play()
		end
	else
		if not self.on then
			self:play()
		else
			self:stop()
		end
	end
end
