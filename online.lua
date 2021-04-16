--local http = require("socket.http")
--local mime = require("mime")

local website = "http://alesan99.blogspot.com/p/mari0-dlc-v14.html?m=1"
--yes, i know it says v14. I accidentally called the v12 dlc "v13", so I now have to use the next update name
--just think about it like how cars always use the next year in their names

function downloadmappackinfo()
	local data, a, b = http.request(website)
	--[[local data, code, headers, status = http.request{
		url = website,
		--headers = {authentication = "Basic "},
		--protocol = nil
	}
	print(data,  authentication, unpack(headers), status)]]
	if data then
		--work around for a copy of the data showing up in the page
		local metacontent = data:find("meta content='[mappackinfo]")
		if metacontent then
			local findend = data:find("og:description", metacontent+20)
			if findend then
				data = data:sub(findend+20, -2)
			end
		end

		--love.filesystem.write("alesans_entities/online.txt", data)
	
		local s = data:gsub("<br />", "")
		if not s:find("%[mappackinfo]") then
			return "error"
		end
		local find1 = s:find("%[mappackinfo]")+13
		local find2 = s:find("%[mappackinfo]", find1)-1

		local mappackdata = s:sub(find1, find2)
		mappackdata = mappackdata:gsub("\n", "") --get rid of line breaks
		
		local iconlink = false
		local findicons1 = s:find("%[icons]")
		if findicons1 then
			findicons1 = findicons1+7
			local findicons2 = s:find("%[icons]", findicons1)-1
			iconlink = s:sub(findicons1, findicons2)
		end

		return mappackdata, iconlink
	elseif a then
		notice.new(a, notice.red, 4)
	end
	onlinemappacklisterror = true
	return "error"
end

function downloadmappack(url, out, size)
	if size == "url" then
		--just open the link
		return love.system.openURL(url)
	else
		--download image and convert it to zip
		local data = http.request(url)
		if data then
			if data:sub(1, 6) == "<html>" then
				return false
			else
				love.filesystem.write("alesans_entities/onlinemappacks/" .. out .. ".png", data)
				data = nil
				if love.filesystem.exists("alesans_entities/onlinemappacks/" .. out .. ".png") then
					return imagetofile(size, out)
				else
					return false
				end
			end
		end
	end
	return false
end

local mountedmappacks = {}
function mountmappack(filename)
	if mountedmappacks[filename] then
		return false
	end
	local success = love.filesystem.mount("alesans_entities/onlinemappacks/" .. filename, mappackfolder, true)
	if success then
		mountedmappacks[filename] = true
	end
	return success
end

function imagetofile(size, out)
	local dlen = size
	local d = {}
	local cdlen = 0

	local filesize = love.filesystem.getSize("alesans_entities/onlinemappacks/" .. out .. ".png")
	if filesize == 0 then
		love.filesystem.remove("alesans_entities/onlinemappacks/" .. out .. ".png")
		return false
	end
	
	local imgdata = love.image.newImageData("alesans_entities/onlinemappacks/" .. out .. ".png")
	
	local pixel = {0, 0}
	
	--get bytes
	while true do
		local b = {imgdata:getPixel(pixel[1], pixel[2])}
		local v = dlen-cdlen
		if v < 4 then
			for i = 1, v do
				table.insert(d, string.char(b[i]))
			end
			break
		else
			table.insert(d, string.char(b[1]))
			table.insert(d, string.char(b[2]))
			table.insert(d, string.char(b[3]))
			table.insert(d, string.char(b[4]))
			cdlen = cdlen + 4
		end
		
		pixel[1] = pixel[1] + 1
		if pixel[1] > 500-1 then
			pixel[2] = pixel[2] + 1
			pixel[1] = 0
		end
	end
	
	imgdata = nil
	collectgarbage("collect")
	love.filesystem.remove("alesans_entities/onlinemappacks/" .. out .. ".png")
	return love.filesystem.write("alesans_entities/onlinemappacks/" .. out, table.concat(d))
end

function newOnlineImage(url)
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