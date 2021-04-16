local http = require("socket.http")
require "love.image"
require "love.filesystem"
require "love.graphics"
channel = love.thread.getChannel("command")
channel2 = love.thread.getChannel("data")

function newOnlineImage(url)
	--Authentication TESTING
	--local chunks = {}
	--[[local data, code, headers, status = http.request{
		url = url,
		method = "GET",
		path = "/qIHJSvp.png",
		["useragent"] = "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36",
		headers = {
			["user-agent"] = "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36",
		}
		--sink = ltn12.sink.table(chunks)
		--protocol = nil
	}]]
	--local response = table.concat(chunks)
	--print(chunks)
	--print(status)
	--print(data,  authentication, unpack(headers), status)
	--[[local chunks = {}
	local r, c, h = http.request{
			url = "https://www.google.com/", --url
			method = "GET",
			["useragent"] = "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36",
			headers = {
				["dnt"] = 0,
				["max-age"] = 0,
				["vary"] = "Upgrade-Insecure-Requests",
				["user-agent"] = "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36",
			},
			sink = ltn12.sink.table(chunks),
		}
	print(r,c,unpack(h))
	for i, s in pairs(h) do
		print(i, s)
	end
	local response = table.concat(chunks)
	print(response)]]

	local onlinedata = http.request(url)
	if not onlinedata then
		return false
	else
		local ok, data = pcall(love.image.newImageData, love.filesystem.newFileData(onlinedata, "temp.png"))
		if not ok then
			return false
		else
			return data
		end
	end
end

while true do
	local v = channel:demand()
	if v then
		if v == "stop" then
			--stop the thread
			break
		else
			--if url is received then load image
			local url = v
			local data = newOnlineImage(url)
			if data then
				channel2:supply({"img", data})
			else
				channel2:supply({"error"})
			end
		end
	end
end