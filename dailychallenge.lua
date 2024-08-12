DCversion = "4"

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
	local i = randomobj:random(1, #DCchaltable)
	return DCchaltable[i].t, DCchaltable[i].name, DCchaltable[i]
end
local createscenery, rectangle, createflag

DCchaltable = {
	{
		t="pipespeedrun",
		name="get to the flag!",
		finish=false,
		width={100, 150, 80, 90, 120},
	},
	{
		t="coin",
		name="collect 50 coins!",
		finish={"coins", 50},
		width={25, 50, 40},
	},
	{
		t="watercoin",
		name="collect 50 coins!",
		finish={"coins", 50},
		width={25, 50, 40},
	},
	{
		t="stomp",
		name="stomp all the goombas!",
		finish={"kill", "goomba"},
	},
	{
		t="stomp2",
		name="stomp all the splunkins!",
		finish={"kill", "splunkin"},
	},
	{
		t="hammerbro",
		name="defeat the hammer bros!",
		finish={"kill", "hammerbro"},
	},
	{
		t="firebro",
		name="defeat the fire bros!",
		finish={"kill", "hammerbro"},
	},
	{
		t="bulletbill",
		name="collect 10 coins",
		finish={"coins", 10},
	},
	{
		t="icespeedrun",
		name="get to the flag!",
		finish=false,
		width={200, 150, 180, 160, 100},
	},
	{
		t="wind",
		name="get to the top!",
		finish={"top"},
		height={15, 20, 25, 30},
	},
	{
		t="treetop",
		name="get to the flag!",
		finish=false,
		width={200, 150, 180, 160, 120},
	},
	{
		t="cloud",
		name="collect 25 coins on the platform!",
		finish={"coins",25},
		width={100, 110, 120, 130, 140, 150},
	},
	{
		t="boomboom",
		name="defeat boom boom!",
		finish={"kill", "boomboom"},
	},
	{
		t="spiny",
		name="defeat the spinies by dropping the cube!",
		finish={"kill", "goomba"},
	},
	{
		t="mushroom",
		name="get to the flag!",
		finish=false,
		width={200, 150, 180, 160, 120},
	},
	{
		t="molespeedrun",
		name="get to the flag!",
		finish=false,
		width={100, 150, 80, 90, 120},
	},
	{
		t="holespeedrun",
		name="get to the flag!",
		finish=false,
		width={100, 150, 200, 100, 120},
	},
	{
		t="sledgebro",
		name="defeat the sledge bros!", 
		finish={"kill", "hammerbro"},
	},
	{
		t="breakout",
		name="destroy all the blocks",
		finish={"lowcoins",0},
		counttimeseparately=true,
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
	mariocoincount = 0
	marioscore = 0
	underwater = false
	realtime = false
	
	local randomobj = love.math.newRandomGenerator(math.floor((datet[1]*((datet[1]*datet[2])+datet[3]))*datet[3]/datet[2]))--come up with a seed
	randomobj:random(1, 256)
	local cdc, dcname, t = getdailychallenge()
	currentdct = t
	currentdc = cdc

	if t.counttimeseparately then
		realmariotime = 0
	else
		realmariotime = mariotimelimit
	end
	
	musici = 7
	custommusic = false
	custommusici = "dc"

	--map size
	mapwidth = t.width or 25
	if type(mapwidth) == "table" then
		mapwidth = t.width[randomobj:random(1, #t.width)]
	end
	originalmapwidth = mapwidth
	mapheight = t.height or 15
	if type(mapheight) == "table" then
		mapheight = t.height[randomobj:random(1, #t.height)]
	end
	map = {}
	for x = 1, mapwidth do
		map[x] = {}
		for y = 1, mapheight do
			map[x][y] = {1}
			map[x][y]["gels"] = {}
		end
	end
	
	if currentdc == "pipespeedrun" then
		rectangle(2,1,14,mapwidth,2)
		local pipeno = randomobj:random(5, 25)
		for i = 1, pipeno do
			local height = randomobj:random(2, 4)
			local pipex = randomobj:random(5, mapwidth-9)
			local badx = true
			while badx do
				badx = false
				for x = pipex, pipex+1 do
					for y = 13-height+1, 13 do
						if tilequads[map[x][y][1]].collision then
							badx = true
							pipex = randomobj:random(5, mapwidth-9)
						end
					end
				end
			end
			for x = pipex, pipex+1 do
				for y = 13-height+1, 13 do
					if x == pipex and y == 13-height+1 then
						map[x][y][1] = 16
						if randomobj:random(1, 5) == 5 then
							map[x][y-1][2] = 70
						end
					elseif x == pipex+1 and y == 13-height+1 then
						map[x][y][1] = 17
					elseif x == pipex then
						map[x][y][1] = 38
					else
						map[x][y][1] = 39
					end
				end
			end
		end
		local brickno = randomobj:random(8, math.floor(mapwidth/5))
		for i = 1, brickno do
			local x = randomobj:random(2, mapwidth-10)
			map[x][8][1] = randomobj:random(7, 8)
			local rand = randomobj:random(1, 8)
			if rand == 1 then
				map[x][8][2] = 2
			elseif rand == 2 then
				map[x][8][2] = 4
			elseif rand == 3 then
				map[x][8][2] = 5
			end
		end
		createflag()
		createscenery("cloud", randomobj)
		createscenery("bush", randomobj)
	elseif currentdc == "coin" then
		for x = 1, mapwidth do
			for y = 1, mapheight do
				if (x == 2 or x == 3 or x == mapwidth-1 or x == mapwidth-2) and y == 10 then
					map[x][y][1] = randomobj:random(7, 8)
					if randomobj:random(1, 2) == 1 then
						map[x][y][2] = 5
					end
				elseif y > 13 then
					map[x][y][1] = 2
				end
			end
		end
		for i = 1, randomobj:random(4, 8) do
			local y = 3+randomobj:random(1, 8)
			while tilequads[map[5][y][1]].coin do
				y = 3+randomobj:random(1, 8)
			end
			for x = 5, mapwidth-5 do
				map[x][y][1] = 116
			end
		end
		createscenery("cloud", randomobj)
		if randomobj:random(1, 2) == 1 then
			createscenery("tree", randomobj)
			createscenery("fence", randomobj)
		else
			createscenery("bush", randomobj)
		end
	elseif currentdc == "watercoin" then
		underwater = true
		spriteset = 4
		background = 3
		for x = 1, mapwidth do
			for y = 1, mapheight do
				if (x == 2 or x == 3 or x == mapwidth-1 or x == mapwidth-2) and y == 10 then
					map[x][y][1] = randomobj:random(7, 8)
					if randomobj:random(1, 2) == 1 then
						map[x][y][2] = 5
					end
				elseif y == 1 or y == 2 then
					map[x][y][1] = 121
				elseif y == 3 then
					map[x][y][1] = 106
				elseif y > 13 and x <= 5 then
					map[x][y][1] = 98
				end
			end
		end
		for i = 1, randomobj:random(4, 8) do
			local y = 3+randomobj:random(1, 8)
			while tilequads[map[5][y][1]].coin do
				y = 3+randomobj:random(1, 8)
			end
			for x = 5, mapwidth-5 do
				map[x][y][1] = 116
			end
		end
		if randomobj:random(1, 2) == 1 then --fish
			map[13][13][2] = 184
		end
	elseif currentdc == "stomp" then
		rectangle(78, 1, 1, 1, mapheight)
		rectangle(78, mapwidth, 1, 1, mapheight)
		rectangle(2, 1, 14, mapwidth, 2)
		local goombano = randomobj:random(5, 15)
		for i = 1, goombano do
			local x = randomobj:random(6, 24)
			while map[x][13][2] == 6 do
				x = randomobj:random(6, 24)
			end
			map[x][13][2] = 6
		end
		createscenery("cloud", randomobj)
		createscenery("bush", randomobj)
	elseif currentdc == "hammerbro" then
		rectangle(2, 1, 14, mapwidth, 2)
		
		local rows = randomobj:random(2, 2)
		for i = 1, rows do
			local y = 10-(4*(i-1))
			for x = 7, 19 do
				map[x][y][1] = 7
			end
			local y2 = 9-(4*(i-1))
			local num = randomobj:random(1, 2)
			for n = 1, num do
				local x = 9+(7*(n-1))
				map[x][y2][2] = 15
			end
		end
		createscenery("cloud", randomobj)
		createscenery("bush", randomobj)
	elseif currentdc == "firebro" then
		background = 2
		rectangle(50, 1, 14, mapwidth, 2)

		local rows = randomobj:random(2, 2)
		for i = 1, rows do
			local y = 10-(4*(i-1))
			for x = 7, 19 do
				map[x][y][1] = 49
			end
			local y2 = 9-(4*(i-1))
			local x = 13
			map[x][y2][2] = 120
		end
	elseif currentdc == "bulletbill" then
		background = 2
		spriteset = 3
		rectangle(29, 1, 14, mapwidth, 2)

		local y = randomobj:random(8, 10)
		for x = 5, mapwidth-5 do
			map[x][y][1] = 116
		end
		bulletbilldelay = 0.5
		bulletbillstarted = true
		bulletbillstartx = false
		bulletbillendx = false
	elseif currentdc == "icespeedrun" then
		for x = 1, mapwidth do
			for y = 1, mapheight do
				if y > 13 then
					map[x][y][1] = 92
					map[x][y][2] = 164
				end
			end
		end
		local pipeno = randomobj:random(1, 8)
		for i = 1, pipeno do
			local height = randomobj:random(2, 4)
			local pipex = randomobj:random(7, mapwidth-12)
			local badx = true
			while badx do
				badx = false
				for x = pipex, pipex+1 do
					for y = 13-height+1, 13 do
						if tilequads[map[x][y][1]].collision then
							badx = true
							pipex = randomobj:random(7, mapwidth-12)
						end
					end
				end
			end
			for x = pipex, pipex+1 do
				for y = 13-height+1, 13 do
					if x == pipex and y == 13-height+1 then
						map[x][y][1] = 14
						if randomobj:random(1, 5) == 5 then
							map[x][y-1][2] = 70
						end
					elseif x == pipex+1 and y == 13-height+1 then
						map[x][y][1] = 15
					elseif x == pipex then
						map[x][y][1] = 36
					else
						map[x][y][1] = 37
					end
				end
			end
		end
		local pokeyno = randomobj:random(1, 12)
		for i = 1, pokeyno do
			local x = randomobj:random(10, mapwidth-10)
			while map[x][13][1] ~= 1 do
				x = randomobj:random(10, mapwidth-10)
			end
			map[x][13][2] = 215
			map[x][13][3] = randomobj:random(2, 5)
		end
		local treeno = randomobj:random(3, 10)
		for i = 1, treeno do
			local x = randomobj:random(10, mapwidth-9)
			while map[x-1][13][1] ~= 1 or map[x][13][1] ~= 1 or map[x+1][13][1] ~= 1 do
				x = randomobj:random(10, mapwidth-9)
			end
			local height = randomobj:random(5, 8)
			for y = 14-height+1, 13 do
				map[x][y][1] = 94
			end
			local widths = {3, 5}
			local width = widths[randomobj:random(1, 2)]
			for x2 = x-math.floor(width/2), x+math.floor(width/2) do
				if x2 == x-math.floor(width/2) then
					map[x2][14-height][1] = 89
				elseif x2 == x+math.floor(width/2) then
					map[x2][14-height][1] = 91
				else
					map[x2][14-height][1] = 90
				end
				if randomobj:random(1, 20) == 1 then
					map[x2][14-height+1][2] = 108
				end
			end
		end
		flagx = mapwidth-7
		flagy = 13
		flagimgx = flagx+8/16
		flagimgy = 3+1/16
		map[flagx+1][13][1] = 78
		for y = 3, 12 do
			if y == 3 then
				map[flagx+1][y][1] = 101
			else
				map[flagx+1][y][1] = 104
			end
		end
		createscenery("cloud", randomobj)
		createscenery("whitetree", randomobj)
		createscenery("fence", randomobj)
	elseif currentdc == "wind" then
		rectangle(2, 1, mapheight-1, 6, 2)

		startx = 3
		starty = mapheight-2
		windstarted = true
		local lastx = 3
		for y = mapheight-1, 4, -1 do
			for i = 1, randomobj:random(1, 2) do
				local x = randomobj:random(math.max(1, lastx-5), math.min(mapwidth, lastx+5))
				if y > mapheight-4 then
					x = math.max(x, 7)
				end
				map[x][y][1] = 78
				lastx = x
			end
		end
		createscenery("sky", randomobj)
		createscenery("hill", randomobj)
	elseif currentdc == "treetop" then
		for x = 1, mapwidth do
			for y = 1, mapheight do
				if y == 14 and x > 1 and x < 6 then
					map[x][y][1] = 71
				elseif y == 15 and x > 1 and x < 6 then
					map[x][y][1] = 93
				end
			end
		end
		map[1][14][1] = 70
		map[6][14][1] = 72
		local x = 8
		local height = 2
		while x < mapwidth-11 do
			height = randomobj:random(math.max(2, height-6), math.min(10, height+4))
			local width = randomobj:random(3, 10)
			while x+width-1 > mapwidth-7 do
				width = randomobj:random(3, 10)
			end
			for y = mapheight-height+1, mapheight do
				if y == mapheight-height+1 then
					map[x][y][1] = 70
					map[x+width-1][y][1] = 72
					for x = x+1, x+width-2 do
						map[x][y][1] = 71
						if randomobj:random(1, 20) == 1 then
							if randomobj:random(1, 2) == 1 then
								map[x][y-1][2] = 12
							else
								map[x][y-1][2] = 118
							end
						end
					end
				else
					for x = x+1, x+width-2 do
						map[x][y][1] = 93
					end
				end
			end
			x = x+width+randomobj:random(1, 5)
		end
		if randomobj:random(1, 20) == 1 then
			map[1][3][2] = 22
			lakitoendx = mapwidth-12
		end
		createflag("ground")
		createscenery("hill", randomobj)
		createscenery("cloud", randomobj)
	elseif currentdc == "cloud" then
		rectangle(14, 2, 14, 7, 1)

		for x = 1, mapwidth do
			for y = 1, mapheight do
				if y == 14 and x > 1 and x < 9 then
					map[x][y][1] = 79
				end
			end
		end
		local platy = randomobj:random(10, 13)
		map[10][platy][2] = 92
		local coinrows = randomobj:random(2, 6)
		for i = 1, coinrows do
			local y = randomobj:random(4, 12)
			while y == platy do
				 y = randomobj:random(4, 12)
			end
			for x = 12, mapwidth-4 do
				map[x][y][1] = 116
			end
		end
		local parabeetles = randomobj:random(5, 20)
		for i = 1, parabeetles do
			local x, y = randomobj:random(11, mapwidth-5), randomobj:random(5, 8)
			if randomobj:random(1, 4) == 1 then
				map[x][y][2] = 189
			else
				map[x][y][2] = 139
			end
		end
		createscenery("sky", randomobj)
	elseif currentdc == "stomp2" then
		--copy paste pls don't hurt me
		--its alesan from the future, i am going to hurt you
		spriteset = 2
		background = 2
		rectangle(111, 1, 1, 1, mapheight)
		rectangle(111, mapwidth, 1, 1, mapheight)
		rectangle(50, 1, 14, mapwidth, 2)

		local goombano = randomobj:random(3, 8)
		for i = 1, goombano do
			local x = randomobj:random(6, 24)
			while map[x][13][2] == 111 do
				x = randomobj:random(6, 24)
			end
			map[x][13][2] = 111
		end
		local boono = randomobj:random(0, 3)
		for i = 1, boono do
			map[randomobj:random(4, mapwidth-3)][randomobj:random(2, 5)][2] = 142
		end
	elseif currentdc == "boomboom" then
		spriteset = 3
		background = 2
		rectangle(29, 1, 1, mapwidth, 1)
		rectangle(29, 1, 14, mapwidth, 2)
		rectangle(29, 1, 1, 1, mapheight)
		rectangle(29, mapwidth, 1, 1, mapheight)
		
		map[mapwidth-4][13][2] = 153
		
		local y2 = 9
		local rows = randomobj:random(0, 3)
		for i = 1, rows do
			local x2 = math.floor((mapwidth/(rows+1))*i)
			map[x2][y2][1] = 29
			x2 = math.ceil((mapwidth/(rows+1))*i)
			map[x2][y2][1] = 29
		end
	elseif currentdc == "spiny" then
		spriteset = 3
		background = 2
		
		rectangle(154, 1, 1, mapwidth, 1)
		rectangle(154, 1, 14, mapwidth, 2)
		rectangle(154, 1, 1, 1, mapheight)
		rectangle(154, mapwidth, 1, 1, mapheight)
		for x = 1, mapwidth do
			for y = 1, mapheight do
				if x == 1 or x == mapwidth or y == 1 or y > 13 then
					map[x][y][1] = 154
				end
			end
		end
		
		map[2][10][1] = 192
		map[3][10][1] = 190
		map[mapwidth-1][10][1] = 191
		map[mapwidth-2][10][1] = 190
		table.insert(objects["box"], box:new(3, 9))
		
		local goombano = randomobj:random(1, 5)
		for i = 1, goombano do
			local x = randomobj:random(6, 24)
			while map[x][13][2] == 98 do
				x = randomobj:random(6, 24)
			end
			map[x][13][2] = 98
		end
	elseif currentdc == "mushroom" then
		for x = 1, mapwidth do
			for y = 1, mapheight do
				if y == 14 and x > 1 and x < 7 then
					map[x][y][1] = 21
				elseif y == 15 and x == 4 then
					map[x][y][1] = 43
				end
			end
		end
		map[1][14][1] = 20
		map[7][14][1] = 22
		local x = 8
		local height = 2
		while x < mapwidth-11 do
			height = randomobj:random(math.max(2, height-6), math.min(10, height+4))
			local width = 1+randomobj:random(1, 5)*2
			while x+width-1 > mapwidth-7 do
				width = 1+randomobj:random(1, 5)*2
			end
			for y = mapheight-height+1, mapheight do
				if y == mapheight-height+1 then
					map[x][y][1] = 20
					map[x+width-1][y][1] = 22
					for x = x+1, x+width-2 do
						map[x][y][1] = 21
						if randomobj:random(1, 16) == 1 then
							local rand = randomobj:random(1, 3)
							if rand == 1 then
								map[x][y-1][2] = 12
							elseif rand == 2 then
								map[x][y-1][2] = 78
							else
								map[x][y-1][2] = 118
							end
						end
					end
				elseif y == mapheight-height+2 then
					map[x+math.floor(width/2)][y][1] = 43
				else
					map[x+math.floor(width/2)][y][1] = 65
				end
			end
			x = x+width+randomobj:random(1, 5)
		end
		if randomobj:random(1, 20) == 1 then
			map[1][3][2] = 22
			lakitoendx = mapwidth-12
		end
		--flag
		createflag("ground")
		--bullet bills
		if randomobj:random(1, 3) == 1 then
			bulletbilldelay = 0.5
			bulletbillstarted = true
			bulletbillstartx = false
			bulletbillendx = false
		end
		createscenery("sky", randomobj)
	elseif currentdc == "molespeedrun" then
		rectangle(2, 1, 14, mapwidth, 2)

		local brickno = randomobj:random(8, math.floor(mapwidth/5))
		for i = 1, brickno do
			local x = randomobj:random(2, mapwidth-10)
			local y = randomobj:random(8, 10)
			map[x][y][1] = randomobj:random(7, 8)
			local rand = randomobj:random(1, 6)
			if rand == 1 then
				map[x][y][2] = 2
			elseif rand == 2 then
				map[x][y][2] = 4
			end
		end
		local moleno = randomobj:random(8, 16)
		for i = 1, moleno do
			local x = randomobj:random(8, mapwidth-10)
			map[x][mapheight-2][2] = 143
		end
		createflag()
		createscenery("cloud", randomobj)
		createscenery("tree", randomobj)
		createscenery("fence", randomobj)
	elseif currentdc == "holespeedrun" then
		rectangle(2, 1, 14, mapwidth, 2)

		local x = randomobj:random(6, 10)
		while x < mapwidth-16 do
			local size = randomobj:random(2, 5)
			for x2 = 1, size do
				for y2 = 1, 2 do
					local x3, y3 = x+x2-1, mapheight-2+y2
					if map[x3] then
						map[x3][y3][1] = 1
						objects["tile"][tilemap(x3, y3)] = nil
					end
				end
			end
			
			x = x + size + randomobj:random(5, 10)
		end
		createflag()
		createscenery("cloud", randomobj)
		createscenery("hill", randomobj)
	elseif currentdc == "sledgebro" then
		background = 2
		rectangle(2, 1, 14, mapwidth, 2)
		
		local rows = randomobj:random(2, 2)
		for i = 1, rows do
			local y = 10-(4*(i-1))
			for x = 7, 19 do
				map[x][y][1] = 7
			end
			local y2 = 9-(4*(i-1))
			local num = randomobj:random(1, 2)
			for n = 1, num do
				local x = 9+(7*(n-1))
				map[x][y2][2] = 221
			end
		end
		createscenery("redcloud", randomobj)
		createscenery("whitetree", randomobj)
		createscenery("fence", randomobj)
	elseif currentdc == "breakout" then
		background = 2
		breakoutmode = true

		local tileilist = {2, 50, 29, 98}
		local spritesets = {1, 2, 3, 4}
		local tilei = randomobj:random(1, #tileilist)
		spriteset = spritesets[tilei]
		rectangle(tileilist[tilei], 1, 3, mapwidth, 1)
		rectangle(tileilist[tilei], 1, 3, 1, mapheight-2)
		rectangle(tileilist[tilei], mapwidth, 3, 1, mapheight-2)
		--ball
		map[math.floor(mapwidth/2)][mapheight-2][2] = 6
		--paddle
		map[math.floor(mapwidth/2)][mapheight-1][2] = 32
		map[math.floor(mapwidth/2)][mapheight-1][3] = 4

		--blocks
		local tileilist = {7, 122, 49}
		local rows = randomobj:random(2, 3)
		local y = 5
		for i = 1, rows do
			local tilei = randomobj:random(1, #tileilist)
			local offset = randomobj:random(1,9)
			y = y + 1
			if i ~= 1 and randomobj:random(1,4) == 4 then
				y = y + 1
			end
			for x = 2, mapwidth-1 do
				if x == 1+offset or x == mapwidth-offset then
					map[x][y][1] = 8
				else
					map[x][y][1] = tileilist[tilei]
				end
				mariocoincount = mariocoincount + 1
			end
		end
	end
 
	--create collision
	for x = 1, mapwidth do
		for y = 1, mapheight do
			if tilequads[map[x][y][1]] and tilequads[map[x][y][1]].collision == true then
				objects["tile"][tilemap(x, y)] = tile:new(x-1, y-1, 1, 1, true)
			end
		end
	end
end

function checkdcwin(dt)
	local t = currentdct
	if not t.finish then
		return false
	end
	local pass = false
	local v = t.finish
	if v[1] == "coins" then
		if mariocoincount >= v[2] then
			pass = true
		end
	elseif v[1] == "lowcoins" then
		if mariocoincount <= v[2] then
			pass = true
		end
	elseif v[1] == "kill" then
		if #objects[v[2]] == 0 then
			pass = true
		end
	elseif v[1] == "top" then
		if objects["player"][1].y < 2 then
			pass = true
		end
	end
	if t.t == "breakout" then
		objects["player"][1].x = (mapwidth/2)
		objects["player"][1].active = false
		objects["player"][1].controlsenabled = false
		objects["player"][1].drawable = false
		if (not objects["player"][1].dead) and #objects["goomba"] <= 0 then
			objects["player"][1]:die("time")
		end
	end
	if t.counttimeseparately then
		realmariotime = realmariotime + dt
	end
	if pass then
		if t.counttimeseparately then
			mariotimelimit = 0
			realmariotime = -realmariotime
		else
			realmariotime = mariotime
		end
		nextlevel()
		return true
	end
	return false
end

function rectangle(i,rx,ry,w,h)
	for x = rx, rx+w-1 do
		for y = ry, ry+h-1 do
			if inmap(x, y) then
				map[x][y][1] = i
			end
		end
	end
end

function createscenery(t, randomobj)
	--t can be "hill", "bush", "cloud", "redcloud", "whitebush", "sky", "tree", "whitetree", "fence"
	if t == "hill" then
		--weird clouds
		local x = randomobj:random(1, 10)
		
		while x <= mapwidth do
			local size = 1+randomobj:random(2, 5)*2
			local y2 = mapheight
			while size > 0 do
				for x2 = 1, size do
					local i = 27
					if size == 1 then
						i = 3
					elseif x2 == 1 then
						i = 24
					elseif x2 == size then
						i = 26
					elseif size == 3 then
						i = 25
					elseif randomobj:random(1, 3) == 1 then
						i = 28
					end
					
					local x3, y3 = x+x2-1, y2
					if map[x3] and map[x3][y3] and map[x3][y3][1] == 1 then
						map[x3][y3][1] = i
					end	
				end
				x = x + 1
				y2 = y2 - 1
				size = size - 2
			end
			x = x + size + randomobj:random(6, 14)
		end
	elseif t == "bush" or t == "whitebush" then
		--those bushes that use same sprite as clouds
		local x = randomobj:random(1, 9)

		local bush = {5, 4, 6}
		if t == "whitebush" then
			bush = {34, 33, 35}
		end
		
		while x <= mapwidth do
			local size = randomobj:random(3, 4)
			for x2 = 1, size do
				local i = bush[1]
				if x2 == 1 then
					i = bush[2]
				elseif x2 == size then
					i = bush[3]
				end
				
				local x3, y3 = x+x2-1, mapheight-2
				if map[x3] and map[x3][y3] and map[x3][y3][1] == 1 then
					map[x3][y3][1] = i
				end	
			end
			x = x + size + randomobj:random(3, 9)
		end
	elseif t == "cloud" or t == "redcloud" or t == "sky" then
		--clouds
		local range = {4, 8}
		if t == "sky" then
			range = {4, mapheight-2}
		end
		local cloud = {34, 56, 33, 55, 35, 57}
		if t == "redcloud" then
			cloud = {31, 53, 30, 52, 32, 54}
		end
		local x, y = randomobj:random(1, 6), randomobj:random(range[1], range[2])
		while x <= mapwidth do
			local size = randomobj:random(3, 4)
			for x2 = 1, size do
				for y2 = 1, 2 do
					local i = cloud[1]
					if y2 == 2 then
						i = cloud[2]
					end
					if x2 == 1 then
						if y2 == 1 then
							i = cloud[3]
						elseif y2 == 2 then
							i = cloud[4]
						end
					elseif x2 == size then
						if y2 == 1 then
							i = cloud[5]
						elseif y2 == 2 then
							i = cloud[6]
						end
					end
					local x3, y3 = x+x2-1, y+y2-1
					if map[x3] and map[x3][y3] and map[x3][y3][1] == 1 then
						map[x3][y3][1] = i
					end
				end
			end
			x = x + size + randomobj:random(1, 6)
			y = randomobj:random(range[1], range[2])
		end
	elseif t == "tree" or t == "whitetree" then
		--those weird trees
		local x = randomobj:random(1, 9)

		local tree = {88,87,44,66}
		if t == "whitetree" then
			tree = {88,109,77,99}
		end
		
		while x <= mapwidth do
			local size = randomobj:random(2, 3)
			local size2 = randomobj:random(1, 2)
			if size == 2 then
				size2 = 1
			end
			for y2 = 1, size do
				local i = tree[1]
				if y2 == 1 then
					if size2 == 1 then
						i = tree[2]
					else
						i = tree[3]
					end
				elseif y2 == 2  and size2 == 2 then
					i = tree[4]
				end
				
				local x3, y3 = x, mapheight-size+y2-2
				if map[x3] and map[x3][y3] and map[x3][y3][1] == 1 then
					map[x3][y3][1] = i
				end	
			end
			x = x + size + randomobj:random(3, 9)
		end
	elseif t == "fence" then
		--some fence
		local x = randomobj:random(1, 9)
		
		while x <= mapwidth do
			local size = randomobj:random(1, 4)
			for x2 = 1, size do
				local x3, y3 = x+x2-1, mapheight-2
				if map[x3] and map[x3][y3] and map[x3][y3][1] == 1 then
					map[x3][y3][1] = 86
				end	
			end
			x = x + size + randomobj:random(3, 9)
		end
	end
end

function createflag(ground)
	flagx = mapwidth-7
	flagy = 13
	flagimgx = flagx+8/16
	flagimgy = 3+1/16
	map[flagx+1][13][1] = 78
	for y = 3, 12 do
		if y == 3 then
			map[flagx+1][y][1] = 100
		else
			map[flagx+1][y][1] = 103
		end
	end
	--ground
	if ground then
		for x = flagx-2, mapwidth do
			for y = 14, mapheight do
				map[x][y][1] = 2
			end
		end
	end
end