require "love.image"
require "love.filesystem"
require "love.graphics"
local channelin = love.thread.getChannel("mappackin")
local channelout = love.thread.getChannel("mappackout")

function string:split(d)
	local data = {}
	local from, to = 1, string.find(self, d)
	while to do
		table.insert(data, string.sub(self, from, to-1))
		from = to+d:len()
		to = string.find(self, d, from)
	end
	table.insert(data, string.sub(self, from))
	return data
end

function loadMappackInfo(url)
	local t = {"","","","1-1"}

	t[1] = ""--mappackname
	t[2] = ""--t.mappackauthor = ""
	t[3] = ""--t.mappackdescription = ""
	t[4] = "1-1"--t.mappackbackground = "1-1"
	t[5] = false--icon
	t[6] = false--dropshadow
	
	if love.filesystem.getInfo(url .. "/icon.png") then
		local ok, data = pcall(love.image.newImageData, url .. "/icon.png")
		if ok then
			t[5] = data
		end
	end
	
	if love.filesystem.getInfo(url .. "/settings.txt") then
		local s = love.filesystem.read(url .. "/settings.txt")
		local s1 = s:split("\n")
		for j = 1, #s1 do
			local s2 = s1[j]:split("=")
			if s2[1] == "name" then
				t[1] = s2[2]
			elseif s2[1] == "author" then
				t[2] = s2[2]
			elseif s2[1] == "description" then
				t[3] = s2[2]
			elseif s2[1] == "background" then
				t[4] = s2[2]
			elseif s2[1] == "dropshadow" then
				t[6] = (s2[2] == "t")
			end
		end
	end

	return t
end

channelout:supply({"running"})

while true do
	local v = channelin:demand()
	if v then
		if v[1] == "stop" then
			channelout:supply({"stopped"})
			channelin:clear()
			--stop the thread
			break
		else
			if v[2] then
				love.filesystem.setIdentity(v[2])
				--channelout:supply({"set dir to " .. v[2]})
			end
			--if url is received then load image
			local url = v[1]
			local data = loadMappackInfo(url)
			
			--channelout:supply({"loading" .. url})
			if data then
				channelout:supply({"mappack", data[1], data[2], data[3], data[4], data[5], data[6]})
			else
				channelout:supply({"error"})
			end
		end
	end
end