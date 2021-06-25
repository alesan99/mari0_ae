--local http = require("socket.http")
--local mime = require("mime")
local https = {timeout = 5,time = 0,body = "",status = 0};

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
		if DirectDLCDownloads and love.system.getOS() == "Windows" and url:find("%.zip") then
			--attempt to do a direct download on windows
			out = out:gsub("%.zip","")
			return directRequest(url,"GET",nil,out), "downloaded"
		end
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

--by bio1712 (https://love2d.org/forums/viewtopic.php?t=85782)
function directRequest(url,method,data,out)
	url = url or "";
	method = method or "GET";
	data = data or "";
	data = data:gsub(" ","/SPACE/");
	data = data:gsub("&","/AND/");
	createJS(out);
	local dir = love.filesystem.getAppdataDirectory() .. "/LOVE/" .. love.filesystem.getIdentity() .. "/alesans_entities/onlinemappacks/https_request.js";
	local str = "" .. dir:gsub("/","\\") .. " " .. url .. " " .. method .. " " .. data .. "";
	os.execute(str);
	print(out .. ".zip")
	
	https.timer = os.time();
	local ok = false
	while true do
		if love.filesystem.isFile("alesans_entities/onlinemappacks/status.txt") and love.filesystem.isFile("alesans_entities/onlinemappacks/" .. out .. ".zip") then
			https.status = tonumber(love.filesystem.read("alesans_entities/onlinemappacks/status.txt"):sub(1,3));
			--https.body = love.filesystem.read(out .. ".zip");
			--print("len:" .. https.body:len());
			if https.status == 200 then
				ok = true; break;
			else 
				ok = false; break;
			end
		end
		if os.time() > https.timeout + https.time then
			https.body = "";
			https.status = -1;
			ok = false; break;
		end
		love.timer.sleep();
	end
	love.filesystem.remove("alesans_entities/onlinemappacks/status.txt");
	love.filesystem.remove("alesans_entities/onlinemappacks/https_request.js");
	return ok;
end

function createJS(out)
	local file = [[var xHttp;
	var URL;
	var method;
	var FSO;
	var file;
	var data;
	var scriptDir = WScript.ScriptFullName.substring(0,WScript.ScriptFullName.lastIndexOf(WScript.ScriptName)-1);

	xHttp = new ActiveXObject("MSXML2.ServerXMLHTTP");
	URL = WScript.Arguments.Item(0);

	try {
		method = WScript.Arguments.Item(1);
		data = WSCript.Arguments.Item(2);
		data = data.replace("/SPACE/"," ");
		data = data.replace("/AND/","&");
	} catch(err) {

	}

	if (!method) {
		method = "GET";
	}

	if (!data) {
		var d = new Date();
		data = "c=" + d.getTime();
	} else {
		var d = new Date();
		data = data + "&d=" + d.getTime();
	}


	xHttp.open(method, URL, false);
	xHttp.setOption(2, 13056);
	xHttp.setRequestHeader("Content-Type", "application/zip");
	xHttp.send(data);

	FSO = new ActiveXObject("Scripting.FileSystemObject");

	fileName = scriptDir + "\\]] .. out .. [[.zip";

	var fsT = new ActiveXObject("ADODB.Stream");
	fsT.type = 1; 
	fsT.open(); 
	fsT.write(xHttp.responseBody);
	fsT.saveToFile(fileName, 2);

	fileName = scriptDir + "\\status.txt";
	file = FSO.CreateTextFile(fileName,true);
	file.Write(xHttp.status + "\n");
	file.Close();
	]]

	love.filesystem.write("alesans_entities/onlinemappacks/https_request.js",file);
end