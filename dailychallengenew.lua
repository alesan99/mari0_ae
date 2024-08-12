DCversion = "3.1"

--future updates just incase I feel like adding more later
if love.filesystem.getInfo("alesans_entities/daily_challenge_expansion.data") then
	ok, chunk = pcall(love.filesystem.load, "alesans_entities/daily_challenge_expansion.data")
	if ok then
		local ok, result = pcall(chunk)
		if ok then
			if tonumber(result) and tonumber(result) >= tonumber(DCversion) then
				print(tostring(result) .. tostring(DCversion))
				return
			end
		else
			print("Daily challenge Error!: " .. tostring(result))
		end
	end
end

function getdailychallenge()
	local randomobj = love.math.newRandomGenerator(math.floor((datet[1]*((datet[1]*datet[2])+datet[3]))*datet[3]/datet[2]))
	randomobj:random(1, 256)
	local id = randomobj:random(1, #DCchaltable)
	return DCchaltable[id], DCchaltable[id].name
end

local randomobj
local randomtable
local generatedc

local create
local pblock
local cluster

DCchaltable = {
	{
		id = "run", --id
		name = "reach the goal!", --name
		obj = "finish", --objective
		width = {100, 250},
		height = 15,
	},
	{
		id = "goomba",
		name = "stomp all the goombas!",
		obj = "defeat",
		a = "goomba",
		width = 25,
		height = 15,
	},
}

function createdailychallenge()
	custommusics = {}
	if not custommusics["dc"] then
		if love.filesystem.getInfo("sounds/dailychallenge.ogg") then
			custommusics["dc"] = "sounds/dailychallenge.ogg"
		else
			custommusics["dc"] = "sounds/overworld-fast.ogg"
		end
		music:load(custommusics["dc"])
	end
	
	mariotimelimit = 100
	background = 1
	spriteset = 1
	realmariotime = mariotimelimit
	mariocoincount = 0
	marioscore = 0
	underwater = false
	
	randomobj = love.math.newRandomGenerator(math.floor((datet[1]*((datet[1]*datet[2])+datet[3]))*datet[3]/datet[2]))--come up with a seed
	randomobj:random(1, 256)
	local id = randomobj:random(1, #DCchaltable)
	currentdc = DCchaltable[id]
	DCchalobjective = currentdc.name

	generatedc(currentdc)
	--currentdc = DCchaltable[#DCchaltable]
	
	musici = 7
	custommusic = false
	custommusici = "dc"

	--editormode = true

	local animation = nil
end

function generatedc(c)
	--size
	if type(c.width) == "table" then
		mapwidth = randomtable(c.width)
	else
		mapwidth = c.width
	end
	if type(c.height) == "table" then
		mapheight = randomtable(c.height)
	else
		mapheight = c.height
	end
	cmap = {}
	map = {}
	for x = 1, mapwidth do
		map[x] = {}
		for y = 1, mapheight do
			map[x][y] = {1}
			map[x][y]["gels"] = {}
		end
	end
	--generate elements
	if c.id == "run" then
		createscenery("clouds")
		create("ground", 1, mapheight-1, mapwidth, 2)
		create("flagfinish", 1, mapheight-1, mapwidth, 2)
	elseif c.id == "goomba" then
		createscenery("hills")
		create("ground", 1, mapheight-1, mapwidth, 2)
		cluster(78, 1, 3, 1, mapheight-4)
		cluster(78, mapwidth, 3, 1, mapheight-4)
		map[7][mapheight-3][2] = 6
	end
end

function checkdcwin()
	local check = currentdc.obj
	if check == "defeat" then
		if #objects[currentdc.a] == 0 then
			realmariotime = mariotime
			nextlevel()
			return true
		end
	end
	return false
end

function createscenery(t, x, y, w, h)
	if t == "clouds" then
		local x = 0
		while x < mapwidth do
			create("cloud", x, 3+randomobj:random(1, 4), randomtable({3,3,3,4}), 2)
			x = x + randomobj:random(5, 11)
		end
	elseif t == "hills" then
		local x = 0
		while x < mapwidth do
			create("hill", x, mapheight, randomtable({7,9,11}))
			x = x + randomobj:random(8, 16)
		end
	end
end

function create(t, x, y, w, h)
	if t == "ground" then
		cluster(2, x, y, w, h)
	elseif t == "pipe" then
		pblock(16, x, y)
		pblock(17, x+w-1, y)
		cluster(38, x, y+1, w, h-1)
		cluster(39, x+w-1, y+1, h-1)
	elseif t == "cloud" then
		pblock(33, x, y)
		pblock(55, x, y+1)
		cluster(34, x+1, y, w-2, 1)
		cluster(56, x+1, y+1, w-2, 1)
		pblock(35, x+w-1, y)
		pblock(57, x+w-1, y+1)
	elseif t == "bush" then
		pblock(4, x, y)
		cluster(5, x+1, y, w-2, 1)
		pblock(6, x+w-1, y)
	elseif t == "bushes" then
		local x2 = x+w-1
		while x < w-2 do
			create("bush", x, y, randomtable({2,3,3,4}, 1))
			x = x + randomobj:random(8, 12)
		end
	elseif t == "fence" then
		cluster(86, x, y, w, 1)
	elseif t == "hill" then
		local w, y, x = w, y, x
		while w > 0 do
			for x1 = 0, w-1 do
				if w == 1 then
					pblock(3, x+x1, y)
				elseif x1 == 0 then
					pblock(24, x+x1, y)
				elseif x1 == w-1 then
					pblock(26, x+x1, y)
				elseif w == 3 then
					pblock(25, x+x1, y)
				else
					local i = randomobj:random(1, 5)
					if i == 1 then
						pblock(25, x+x1, y)
					elseif i == 2 then
						pblock(28, x+x1, y)
					else
						pblock(27, x+x1, y)
					end
				end
			end
			y = y - 1; x = x + 1; w = w - 2
		end
	elseif t == "tree" then
		pblock(70, x, y)
		cluster(71, x+1, y, w-2, 1)
		pblock(72, x+w-1, y)
		cluster(93, x+1, y+1, w-2, h-1)
	elseif t == "mushroom" then
		pblock(20, x, y)
		cluster(21, x+1, y, w-2, 1)
		pblock(22, x+w-1, y)
		pblock(43, x+math.floor(w/2), y+1)
		cluster(63, x+math.floor(w/2), y+2, 1, h-2)
	elseif t == "flag" then
		pblock(78, x, y)
		cluster(103, x, y-9, 1, 9)
		pblock(100, x, y-10)
		flagx = x-1
		flagy = y
		flagimgx = flagx+8/16
		flagimgy = 3+1/16
	elseif t == "castle" then
		cluster(45, x-1, y-4, 3, 1)
		pblock(67, x-1, y-3)
		pblock(47, x, y-3)
		pblock(69, x+1, y-3)
		cluster(23, x-1, y-2, 3, 1)
		pblock(45, x+2, y-2)
		pblock(45, x-2, y-2)
		cluster(47, x-2, y-1, 5, 2)
		pblock(68, x, y)
		pblock(46, x, y-1)
	elseif t == "flagfinish" then
		create("ground", mapwidth-15, mapheight-1, 16, 2)
		create("flag", mapwidth-14, mapheight-2)
		create("castle", mapwidth-8, mapheight-2)
	end
end

function pblock(i, x, y, l)
	if inmap(x,y) then
		map[x][y][l or 1] = i
		if (l or 1) == 1 and tilequads[i]["collision"] then
			objects["tile"][tilemap(x, y)] = tile:new(x-1, y-1, 1, 1, true)
		end
	end
end

function cluster(i, x1, y1, w, h)
	local x2, y2 = x1+w-1, y1+h-1
	for x = x1, x2 do
		for y = y1, y2 do
			pblock(i, x, y)
		end
	end
end

function randomtable(t)
	return t[randomobj:random(1, #t)]
end