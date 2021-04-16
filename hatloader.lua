--Not the hatloader mod.

hat = {}
bighat = {}

hatcount = 0
local hati = 33+1 --defaulthats + 1 (makes sure hats are loaded in the correct order (defaults then customs))
function loadhat(path, imgpath)
	local imgpath = imgpath or "alesans_entities"
	local d
	if type(path) == "table" then
		d = path
	else
		local s = love.filesystem.read(path)
		if not s then
			return
		end
		
		d = JSON:decode(s) --read hat data
	end
	
	--LOAD SMALL HAT
	local i = d.i or hati --default hats have assigned ids
	hat[i] = {}
	local t = hat[i]
	t.x = d.x
	t.y = d.y
	t.height = d.height
	t.graphic = love.graphics.newImage(imgpath .. "/hats/" .. d.graphic .. ".png")
	if d.sliding then
		t.sliding = love.graphics.newImage(imgpath .. "/hats/" .. d.sliding .. ".png")
	end
	if d.death then
		t.death = love.graphics.newImage(imgpath .. "/hats/" .. d.death .. ".png")
	end
	t.directions = d.directions
	t.quad = {} --side, front, back
	if d.directions then
		for q = 1, 3 do
			t.quad[q] = love.graphics.newQuad((t.graphic:getWidth()/3)*(q-1), 0, t.graphic:getWidth()/3, t.graphic:getHeight(), t.graphic:getWidth(), t.graphic:getHeight())
		end
	else
		t.quad[1] = love.graphics.newQuad(0, 0, t.graphic:getWidth(), t.graphic:getHeight(), t.graphic:getWidth(), t.graphic:getHeight())
		t.quad[2] = t.quad[1]
		t.quad[3] = t.quad[1]
	end
	--LOAD THE BIG HAT
	bighat[i] = {}
	local t = bighat[i]
	t.x = d.bigx --BIG D
	t.y = d.bigy
	t.height = d.bigheight
	t.graphic = love.graphics.newImage(imgpath .. "/hats/" .. d.biggraphic .. ".png")
	if d.bigemblem then
		t.emblem = love.graphics.newImage(imgpath .. "/hats/" .. d.bigemblem .. ".png")
	end
	if d.bigsliding then
		t.sliding = love.graphics.newImage(imgpath .. "/hats/" .. d.bigsliding .. ".png")
	end
	if d.bigslidingemblem then
		t.slidingemblem = love.graphics.newImage(imgpath .. "/hats/" .. d.bigslidingemblem .. ".png")
	end
	if d.raccoon then
		t.raccoon = love.graphics.newImage(imgpath .. "/hats/" .. d.raccoon .. ".png")
	end
	if d.raccoonsliding then
		t.raccoonsliding = love.graphics.newImage(imgpath .. "/hats/" .. d.raccoonsliding .. ".png")
	end
	t.directions = d.directions
	t.quad = {} --side, front, back
	if d.directions then
		for q = 1, 3 do
			t.quad[q] = love.graphics.newQuad((t.graphic:getWidth()/3)*(q-1), 0, t.graphic:getWidth()/3, t.graphic:getHeight(), t.graphic:getWidth(), t.graphic:getHeight())
		end
	else
		t.quad[1] = love.graphics.newQuad(0, 0, t.graphic:getWidth(), t.graphic:getHeight(), t.graphic:getWidth(), t.graphic:getHeight())
		t.quad[2] = t.quad[1]
		t.quad[3] = t.quad[1]
	end

	if not d.i then
		--custom hats
		hati = hati + 1
	end

	hatcount = hatcount + 1
end

local files = love.filesystem.getDirectoryItems("alesans_entities/hats")

for i, v in pairs(files) do
	if string.sub(v, -5, -1) == ".json" then
		loadhat("alesans_entities/hats/" .. v)
	end
end