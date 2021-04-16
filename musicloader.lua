music = {
	toload = {
	"overworld",
	"underground",
	"castle",
	"underwater",
	"starmusic",
	"princessmusic",
	},
	loaded = {},
	list = {},
	list_fast = {},
	pitch = 1,
}

local musicpath = "sounds/%s.ogg"

local intromusic = false --{intro name, started music}

function music:init()
	intromusic = false --music that is currently in it's intro phase
end

function music:load(musicfile) -- can take a single file string or an array of file strings
	if type(musicfile) == "table" then
		for i, v in ipairs(musicfile) do
			self:preload(musicpath:format(v), v)
			--load fast music
			if love.filesystem.exists(musicpath:format(v .. "-fast")) then
				self:preload(musicpath:format(v .. "-fast"), v .. "-fast")
			end
		end
	else --custom music
		self:preload(musicfile)
		--load fast music
		if love.filesystem.exists(musicfile:sub(1, -5) .. "-fast" .. musicfile:sub(-4, -1)) then
			self:preload(musicfile:sub(1, -5) .. "-fast" .. musicfile:sub(-4, -1))
		end
		--load intro music
		if love.filesystem.exists(musicfile:sub(1, -5) .. "-intro" .. musicfile:sub(-4, -1)) then
			self:preloadintro(musicfile:sub(1, -5) .. "-intro" .. musicfile:sub(-4, -1))
		end
	end
end

function music:preload(musicfile, name)
	if name or self.loaded[musicfile] == nil then
		local source = love.audio.newSource(musicfile, "stream")
		source:setLooping(true)
		source:setPitch(self.pitch)
		self.loaded[name or musicfile] = source
	end
end

function music:preloadintro(musicfile, name)
	if name or self.loaded[musicfile] == nil then
		local source = love.audio.newSource(musicfile, "stream")
		source:setPitch(self.pitch)
		self.loaded[name or musicfile] = source
	end
end

function music:play(name, isfast, nointro)
	local filename = name
	local isintro = false
	if name and soundenabled then
		--find fast
		intromusic = false
		if isfast and self.loaded[name:sub(1, -5) .. "-fast" .. name:sub(-4, -1)] then
			name = name:sub(1, -5) .. "-fast" .. name:sub(-4, -1)
		elseif (not nointro) and self.loaded[name:sub(1, -5) .. "-intro" .. name:sub(-4, -1)] then
			name = name:sub(1, -5) .. "-intro" .. name:sub(-4, -1)
			isintro = true
		end
		if self.loaded[name] then
			--self.loaded[name]:setPitch(0.61538)
			playsound(self.loaded[name])
			if isintro then
				intromusic = {name, filename}
			end
		elseif self.loaded[musicpath:format(name)] then
			playsound(self.loaded[musicpath:format(name)])
		end
	end
end

function music:playIndex(index, isfast)
	local name = self.list[index]
	--find fast default music
	if isfast then
		name = name .. "-fast"
	end
	self:play(name)
end

function music:stop(name, isfast)
	if name then
		--find fast
		if isfast and self.loaded[name:sub(1, -5) .. "-fast" .. name:sub(-4, -1)] then
			name = name:sub(1, -5) .. "-fast" .. name:sub(-4, -1)
		elseif intromusic and name == intromusic[2] then
			name = name:sub(1, -5) .. "-intro" .. name:sub(-4, -1)
		end
		if self.loaded[name] then
			love.audio.stop(self.loaded[name])
		elseif self.loaded[musicpath:format(name)] then
			love.audio.stop(self.loaded[musicpath:format(name)])
		end
		if intromusic and name == intromusic[1] then
			intromusic = false
		end
	end
end

function music:stopIndex(index, isfast)
	local name = self.list[index]
	--find fast default music
	if isfast then
		name = name .. "-fast"
	end
	self:stop(name)
	intromusic = false
end

function music:stopall()
	for name, source in pairs(self.loaded) do
		if source ~= false then
			source:stop()
		end
	end
	intromusic = false
end

function music:getPlaying()
	for name, source in pairs(self.loaded) do
		if source:isPlaying() then
			return name, source
		end
	end
	return false
end

function music:update()
	for name, source in pairs(self.loaded) do
		if source ~= false then
			source:setPitch(self.pitch)
		end
	end
	if intromusic then
		if self.loaded[intromusic[1]] and self.loaded[intromusic[1]]:isStopped() then
			music:play(intromusic[2], nil, true)
			intromusic = false
		end
	end
end

function music:playingmusic()
	for name, source in pairs(self.loaded) do
		if source ~= false and source:isPlaying() then
			return true
		end
	end
	return false
end

function music:disableintromusic()
	intromusic = false
end


music:load(music.toload)

-- the original/default music needs to be put in the correct lists
for i,v in ipairs(music.toload) do
	if not v:match("princessmusic") then
		table.insert(music.list, v)
	end
end

music:init()
