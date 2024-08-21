local previous_state = false
local dir = ""
local browsergui = {} --buttons
local filegui = {} --buttons
local promptgui = {} --buttons

local filebrowserimg
local filebrowserquad

local prompt = false

local listscrollv, listscroll = 0, 0
local listy = 13
local listsize = 26

local files = {}

local loaddirectory
local newfile, newfolder, deletefile, parentdirectory, getfile, editfile, downloadfile, renamefile, openprompt, closeprompt

function openfile(path)
	if android then
		filebrowser_load(path)
	else
		love.system.openURL("file://" .. love.filesystem.getSaveDirectory() .. "/" .. path)
	end
end

function filebrowser_load(directory)
	--Save the previous state to return to
	previous_state = gamestate
	gamestate = "filebrowser"

	browsergui = {}

	loaddirectory(directory)

	--buttons
	browsergui["exit"] = guielement:new("button", 10, 203, "exit", filebrowser_exit, 2)
	browsergui["exit"].bordercolor = {255, 0, 0}
	browsergui["exit"].bordercolorhigh = {255, 127, 127}

	browsergui["newfile"] = guielement:new("button", 51, 203, "new file", newfile, 2)
	browsergui["newfolder"] = guielement:new("button", 124, 203, "new folder", newfolder, 2)

	browsergui["download"] = guielement:new("button", 213, 203, "download", openprompt, 2, {"download"})

	browsergui["back"] = guielement:new("button", 286, 203, "back", parentdirectory, 2)
	
	 --scrollbar(x, y, yrange, width, height, start, dir)
	browsergui["scroll"] = guielement:new("scrollbar", 380, 13, 184, 20, 80, 0, "ver")

	--graphics
	filebrowserimg = love.graphics.newImage("graphics/GUI/filebrowser.png")
	filebrowserquad = {}
	for i = 1, 4 do
		filebrowserquad[i] = love.graphics.newQuad((i-1)*16, 0, 16, 16, 64, 16)
	end
end

function filebrowser_exit()
	gamestate = previous_state

	browsergui = {}
	filegui = {}
	promptgui = {}
end

function loaddirectory(directory)
	--get all files in directory
	dir = directory
	files = love.filesystem.getDirectoryItems(dir)

	--create buttons
	filegui = {}
	for i = 1, #files do
		local file = files[i]
		local cdir = dir
		--get rid of last / if it exists
		if cdir:sub(-1) == "/" then
			cdir = cdir:sub(1, -2)
		end
		local filepath = cdir .. "/" .. file
		local info = love.filesystem.getInfo(filepath)
		filegui[file] = {}
		if info.type == "directory" then
			--delete
			filegui[file][1] = guielement:new("button", 349, listy+listsize*(i-1), "", openprompt, 2, {"delete", file}, 1.5, 18)
			filegui[file][1].filebrowserimage = 1
			--rename
			filegui[file][2] = guielement:new("button", 312, listy+listsize*(i-1), "", openprompt, 2, {"rename", file}, 1.5, 18)
			filegui[file][2].filebrowserimage = 3
			--open folder
			filegui[file][3] = guielement:new("button", 284, listy+listsize*(i-1), "", loaddirectory, 2, {filepath}, 1.5, 18)
			filegui[file][3].filebrowserimage = 4
		elseif info.type == "file" then
			--delete
			filegui[file][1] = guielement:new("button", 349, listy+listsize*(i-1), "", openprompt, 2, {"delete", file}, 1.5, 18)
			filegui[file][1].filebrowserimage = 1
			--rename
			filegui[file][2] = guielement:new("button", 312, listy+listsize*(i-1), "", openprompt, 2, {"rename", file}, 1.5, 18)
			filegui[file][2].filebrowserimage = 3
			--edit file
			filegui[file][3] = guielement:new("button", 284, listy+listsize*(i-1), "", openprompt, 2, {"edit", file}, 1.5, 18)
			filegui[file][3].filebrowserimage = 2
		end
	end
end

function filebrowser_update(dt)
	--scrolling
	listscrollv = browsergui["scroll"].value
	listscroll = listscrollv*math.max(0, #files*listsize - 184)

	--update buttons
	if prompt then
		for i, v in pairs(promptgui) do
			v:update(dt)
		end
	end

	for i = 1, #files do
		local file = files[i]
		for j, w in pairs(filegui[file]) do
			w.y = listy+listsize*(i-1) - listscroll + 3
			w:update(dt)
		end
	end

	for i, v in pairs(browsergui) do
		v:update(dt)
	end

	ignoregui = true --ignore previous gui
end

function filebrowser_draw()
	-- background
	love.graphics.setColor(0, 0, 0, 200)
	love.graphics.rectangle("fill", 0, 0, width*16*scale, height*16*scale)

	-- files
	for i = 0, #files-1 do
		local file = files[i+1]
		if (i*listsize+listsize+listy)-listscroll >= listy and i*listsize-listscroll < height*16-27 then --check if on screen
			love.graphics.setColor(255, 255, 255)
			love.graphics.rectangle("fill", 0, (i*listsize+listy - listscroll + listsize)*scale, width*16*scale, 1*scale)
			properprintfast(file, 1*scale, (i*listsize+listy - listscroll + listsize - math.floor(listsize/2+4))*scale)
		
			--buttons
			for j, w in pairs(filegui[file]) do
				w:draw()
				love.graphics.setColor(255, 255, 255)
				love.graphics.draw(filebrowserimg, filebrowserquad[w.filebrowserimage], (w.x+5)*scale, (w.y+2)*scale, 0, scale, scale)
			end
		end
	end
	browsergui["scroll"]:draw()

	-- directory
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill", 0, 0, width*16*scale, (listy-1)*scale)
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", 0, (listy-1)*scale, width*16*scale, 1*scale)
	properprintfast(dir, 1*scale, 2*scale)

	-- tool bar
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle("fill", 0*scale, 197*scale, width*16*scale, 27*scale)
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", 0*scale, 197*scale, width*16*scale, 1*scale)
	for i, v in pairs(browsergui) do
		v:draw()
	end

	-- prompt
	if prompt then
		love.graphics.setColor(0,0,0, 127)
		love.graphics.rectangle("fill", 0, 0, width*16*scale, height*16*scale)
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("fill", 50*scale, 56*scale, 300*scale, 100*scale)
		for i, v in pairs(promptgui) do
			v:draw()
		end
	end
end

function filebrowser_mousepressed(x, y, button)
	if prompt then
		for i, v in pairs(promptgui) do
			if v:click(x, y, button) then
				return
			end
		end
		return
	end

	--files
	if y > listy*scale and y < (height*16-27)*scale then
		for i = 1, #files do
			local file = files[i]
			for j, w in pairs(filegui[file]) do
				if w:click(x, y, button) then
					return
				end
			end
		end
	end

	--tools
	for i, v in pairs(browsergui) do
		if v:click(x, y, button) then
			return
		end
	end
end

function filebrowser_mousereleased(x, y, button)
	if prompt then
		for i, v in pairs(promptgui) do
			v:unclick(x, y, button)
		end
		return
	end

	--files
	for i = 1, #files do
		local file = files[i]
		for j, w in pairs(filegui[file]) do
			w:unclick(x, y, button)
		end
	end

	for i, v in pairs(browsergui) do
		v:unclick(x, y, button)
	end
end

function newfile()
	local filename = "new_file"
	local fileextension = ".txt"
	local i = 1
	while love.filesystem.getInfo(dir .. "/" .. filename .. i .. fileextension) do
		--file exists, try next number
		i = i + 1
		if i > 100 then
			--too many files, stop
			return
		end
	end

	love.filesystem.write(dir .. "/" .. filename .. i .. fileextension, "")

	--refresh
	loaddirectory(dir)
end

function newfolder()
	local filename = "new_folder"
	local i = 1
	while love.filesystem.getInfo(dir .. "/" .. filename .. i) do
		--file exists, try next number
		i = i + 1
		if i > 100 then
			--too many files, stop
			return
		end
	end

	love.filesystem.createDirectory(dir .. "/" .. filename .. i)

	--refresh
	loaddirectory(dir)
end

function deletefile(filepath)
	love.filesystem.remove(filepath)
	loaddirectory(dir)
end

function downloadfile(url)
	--download file
	if not https then
        notice.new("Can't connect to internet", notice.red, 4)
        return
    end
    local code, body = https.request(url)
    if code ~= 200 then
        notice.new(body, notice.red, 4)
        return
    end
	local filename = "download"
	local i = 1
	while love.filesystem.getInfo(dir .. "/" .. filename .. i) do
		--file exists, try next number
		i = i + 1
		if i > 100 then
			--too many files, stop
			return
		end
	end
	love.filesystem.write(dir .. "/" .. filename .. i, body)
	loaddirectory(dir)
end

function renamefile(name, newname)
	--https://love2d.org/forums/viewtopic.php?t=3594
	--rename file
	local writeDir = love.filesystem.getSaveDirectory() .. "/" .. dir .. "/"

	if not os.rename(writeDir..name, writeDir..newname) then
		return false
	end

	loaddirectory(dir)
	return true
end

function parentdirectory()
	--get parent directory
	--first, get rid of last /
	local cdir = dir
	if cdir:sub(-1) == "/" then
		cdir = cdir:sub(1, -2)
	end
	local split = cdir:split("/")
	local newdir = ""
	for i = 1, #split-1 do
		newdir = newdir .. split[i] .. "/"
	end
	loaddirectory(newdir)
end

function getfile(name, type)
	local file = love.filesystem.read(dir .. "/" .. name)
	if file then
		if type == "base64" then
			file = love.data.encode("string", "base64", file)
			notice.new("Copied file as base64 to clipboard", notice.white, 3)
		else
			notice.new("Copied file as text to clipboard", notice.white, 3)
		end
		love.system.setClipboardText(file)
	else
		notice.new("Error reading file", notice.red, 3)
	end
end

function editfile(name, contents, type)
	if type == "base64" then
		contents = love.data.decode("string", "base64", contents)
	end
	love.filesystem.write(dir .. "/" .. name, contents)
	notice.new("Saved file", notice.white, 3)
end

function openprompt(t, arg)
	prompt = true
	promptgui = {}

	if t == "rename" then
		promptgui["title"] = guielement:new("text", 53, 60, "rename file", {255, 255, 255})
		promptgui["textinput"] = guielement:new("input", 54,73, 35, nil, arg, 45)
		promptgui["textinput"].bypassspecialcharacters = true
		promptgui["textinput"].allowanycharacters = true
		promptgui["confirm"] = guielement:new("button", 282,137, "confirm", function() renamefile(arg, promptgui["textinput"].value); closeprompt() end, 2)
		promptgui["confirm"].bordercolor = {255, 0, 0}
		promptgui["confirm"].bordercolorhigh = {255, 127, 127}
	elseif t == "download" then
		promptgui["title"] = guielement:new("text", 53, 60, "download from url:", {255, 255, 255})
		promptgui["textinput"] = guielement:new("input", 54,73, 35, nil, arg, 45)
		promptgui["textinput"].bypassspecialcharacters = true
		promptgui["textinput"].allowanycharacters = true
		
		promptgui["paste"] = guielement:new("button", 54,88, "paste from clipboard", function() promptgui["textinput"].value = love.system.getClipboardText() end, 2)
		promptgui["confirm"] = guielement:new("button", 282,137, "confirm", function() downloadfile(promptgui["textinput"].value); closeprompt() end, 2)
		promptgui["confirm"].bordercolor = {255, 0, 0}
		promptgui["confirm"].bordercolorhigh = {255, 127, 127}
	elseif t == "edit" then
		promptgui["title"] = guielement:new("text", 53, 60, "edit file " .. arg, {255, 255, 255})
		
		promptgui["contents"] = guielement:new("text", 53, 70, "replace with new contents:", {255, 255, 255})
		promptgui["textinput"] = guielement:new("input", 54,80, 35, nil, "", 9999999)
		promptgui["textinput"].bypassspecialcharacters = true
		promptgui["textinput"].allowanycharacters = true
		
		promptgui["paste"] = guielement:new("button", 54,96, "paste from clipboard", function() promptgui["textinput"].value = love.system.getClipboardText() end, 2)

		promptgui["copytext"] = guielement:new("button", 54,114, "copy file", function() getfile(arg) end, 2)
		promptgui["copybase64"] = guielement:new("button", 154,114, "copy as base64", function() getfile(arg, "base64") end, 2)

		promptgui["savetext"] = guielement:new("button", 268,137, "save text", function() editfile(arg, promptgui["textinput"].value, "text"); closeprompt() end, 2)
		promptgui["savebase64"] = guielement:new("button", 168,137, "save base64", function() editfile(arg, promptgui["textinput"].value, "base64"); closeprompt() end, 2)
		promptgui["savetext"].bordercolor = {255, 0, 0}
		promptgui["savetext"].bordercolorhigh = {255, 127, 127}
		promptgui["savebase64"].bordercolor = {255, 0, 0}
		promptgui["savebase64"].bordercolorhigh = {255, 127, 127}
	elseif t == "delete" then
		promptgui["title"] = guielement:new("text", 53, 60, "delete this file?", {255, 255, 255})
		promptgui["titlefile"] = guielement:new("text", 53, 70, arg, {255, 255, 255})
		promptgui["confirm"] = guielement:new("button", 282,137, "confirm", function() deletefile(dir .. "/" .. arg); closeprompt() end, 2)
		promptgui["confirm"].bordercolor = {255, 0, 0}
		promptgui["confirm"].bordercolorhigh = {255, 127, 127}
	end

	promptgui["close"] = guielement:new("button", 54, 137, "close", closeprompt, 2)
end

function closeprompt()
	prompt = false
	promptgui = {}
end

function filebrowser_keypressed(key, textinput)
	if prompt then
		for i, v in pairs(promptgui) do
			v:keypress(key, textinput)
		end
		return
	end
end

function filebrowser_keyreleased(key)
	if prompt then
		return
	end
end
