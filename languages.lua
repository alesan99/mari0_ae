--Languages use .lua files inside the languages folder
--English is default, any missing strings in the language file will fallback to English
function set_language(lang)
	local s = love.filesystem.read("languages/english.json")
	TEXT = JSON:decode(s)
	s = nil

	if lang ~= "english" then
		if love.filesystem.getInfo("languages/" .. lang .. ".json") then
			local s = love.filesystem.read("languages/" .. lang .. ".json")
			local t = JSON:decode(s)
			for j, w in pairs(t) do
				TEXT[j] = w
			end
		else
			CurrentLanguage = "english"
		end
	end
end
set_language("english")

local Languages, LanguageCount
local sel = 1
local languagemenu_select
function languagemenu_open()
	--Load list of languages
	if not Lanugages then
		Languages = {}
		LanguageCount = 0
		local files = love.filesystem.getDirectoryItems("languages")
		for num, filename in pairs(files) do
			if string.sub(filename, -5, -1) == ".json" and string.sub(filename, 1, -6) ~= "names" then
				Languages[string.sub(filename, 1, -6)] = {name=string.sub(filename, 1, -6)}
				LanguageCount = LanguageCount + 1
			end
		end
		--Load Names
		local s = love.filesystem.read("languages/names.json")
		local t = JSON:decode(s)
		for j, w in pairs(t) do
			if Languages[j] then
				Languages[j].name = w
			end
		end
	end

	if not CurrentLanguage then
		CurrentLanguage = "english"
	end
	--Find Current Selection
	local i = 1
	for name, t in pairs(Languages) do
		if name == CurrentLanguage then
			sel = i
			break
		end
		i = i + 1
	end
end
function languagemenu_draw()
	--Darken Background
	love.graphics.setColor(0, 0, 0, 100/255)
	love.graphics.rectangle("fill", 0, 0, width*16*scale, 224*scale)
	--Window
	local w, h = 220, (LanguageCount+1)*10+10
	local x, y = (width*16-w)/2, (height*16-h)/2
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", x*scale, y*scale, w*scale, h*scale)
	love.graphics.setColor(1, 1, 1)
	drawrectangle(x+1, y+1, w-2, h-2)
	--Text
	properprintF(TEXT["language"], (x+(w-utf8.len(TEXT["language"])*8)/2)*scale, (y+6)*scale)
	local i = 1
	for name, t in pairs(Languages) do
		love.graphics.setColor(100/255, 100/255, 100/255, 1)
		if sel == i then
			love.graphics.setColor(1, 1, 1)
			properprintf(">", (x+6)*scale, (y+6+i*10)*scale)
		end
		properprintf(t.name, (x+16)*scale, (y+6+i*10)*scale)
		i = i + 1
	end
end
function languagemenu_keypressed(key)
	if (key == "up" or key == "w") then
		sel = math.max(1, sel-1)
	elseif (key == "down" or key == "s") then
		sel = math.min(LanguageCount, sel+1)
	elseif (key == "return" or key == "enter" or key == "kpenter" or key == " ") then
		return languagemenu_select()
	elseif key == "escape" then
		return true
	end
end
function languagemenu_mousepressed(mx, my, button)
	local w, h = 220, (LanguageCount+1)*10+10
	local x, y = (width*16-w)/2, (height*16-h)/2
	for i = 1, LanguageCount do
		if mx > (x+6)*scale and my > (y+6+i*10)*scale and mx < (x+6+w)*scale and my < (y+16+i*10)*scale then
			return languagemenu_select()
		end
	end
end
function languagemenu_mousemoved(mx, my, dx, dy)
	local w, h = 220, (LanguageCount+1)*10+10
	local x, y = (width*16-w)/2, (height*16-h)/2
	for i = 1, LanguageCount do
		if mx > (x+6)*scale and my > (y+6+i*10)*scale and mx < (x+6+w)*scale and my < (y+16+i*10)*scale then
			sel = i
			break
		end
	end
end
function languagemenu_update(dt)

end
function languagemenu_select()
	local i = 1
	for name, t in pairs(Languages) do
		if i == sel then
			CurrentLanguage = name
			set_language(CurrentLanguage)
			saveconfig()

			return true
		end
		i = i + 1
	end
	return false
end
