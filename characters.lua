--I have no idea what i'm even doing
local animfiles = {"", "big", "fire", "ice", "superball", "hammer", "frog", "raccoon", "tiny", "tanooki", "skinny", "cape", "shell", "boomerang"}
local blankimg = love.graphics.newImage(love.image.newImageData(1, 1))
local splitimage

function loadcustomplayers()
	characters = {list = {}, data = {}}
	local dir = love.filesystem.getDirectoryItems("alesans_entities/characters")

	-- mount zips
	for i, v in ipairs(dir) do
		if v:sub(-4, -1) == ".zip" then
			mountto("alesans_entities/characters/" .. v, "alesans_entities/characters")
		end
	end
	-- refresh with new mounted items
	dir = love.filesystem.getDirectoryItems("alesans_entities/characters")

	-- load characters
	for i, v in ipairs(dir) do
		local folder = "alesans_entities/characters/" .. v

		if love.filesystem.getInfo(folder .. "/config.json") then
			local playerstuff = {
				--identification
				name = v,
				i = #characters["list"]+1,

				--colors
				colorables = {"hat", "hair", "skin"},
				colors = {},
				defaultcolors = false,
				starcolors = starcolors,
				flowercolor = false,
				hammersuitcolor = false,
				frogsuitcolor = false,
				leafcolor = false,
				iceflowercolor = false,
				tanookisuitcolor = false,
				statuecolor = statuecolor,
				superballcolor = false,
				blueshellcolor = false,
				boomerangcolor = false,

				--hats
				hats = false,

				--stats
				walkacceleration = walkacceleration,
				runacceleration = runacceleration,
				walkaccelerationair = walkaccelerationair,
				runaccelerationair = runaccelerationair,
				minspeed = minspeed,
				frogminspeed = frogminspeed,
				frogfriction = frogfriction,
				maxwalkspeed = maxwalkspeed,
				maxrunspeed = maxrunspeed,
				friction = friction,
				superfriction = superfriction,
				frictionair = frictionair,
				airslidefactor = airslidefactor,
				icefriction = icefriction,
				icewalkacceleration = icewalkacceleration,
				icerunacceleration = icerunacceleration,
				gelmaxrunspeed = gelmaxrunspeed,
				gelmaxwalkspeed = gelmaxwalkspeed,
				gelrunacceleration = gelrunacceleration,
				gelwalkacceleration = gelwalkacceleration,
				bluegelminforce = bluegelminforce,
				fencespeed = fencespeed,

				idleanimationspeed = idleanimationspeed,
				runanimationspeed = runanimationspeed,
				jumpanimationspeed = 8,
				jumpanimationloop = false,
				fallanimationspeed = 8,
				fallanimationloop = false,
				piperunanimationspeed = piperunanimationspeed,
				swimanimationspeed = swimanimationspeed,
				fenceanimationspeed = fenceanimationspeed,
				vineframedelay = vineframedelay,

				yacceleration = yacceleration,
				yaccelerationjumping = yaccelerationjumping,
				tinymariogravity = tinymariogravity,
				tinymariogravityjumping = tinymariogravityjumping,
				skinnymariogravity = skinnymariogravity,
				jumpforce = jumpforce,
				jumpforceadd = jumpforceadd,
				raccoonjumpforce = raccoonjumpforce,
				raccoonjumpforceadd = raccoonjumpforceadd,
				raccoonflyjumpforce = raccoonflyjumpforce,
				raccoonflytime = raccoonflytime,
				capejumpforce = capejumpforce,
				passivespeed = passivespeed,

				uwwalkacceleration = uwwalkacceleration,
				uwrunacceleration = uwrunacceleration,
				uwwalkaccelerationair = uwwalkaccelerationair,
				uwmaxairwalkspeed = uwmaxairwalkspeed,
				uwmaxairshellwalkspeed = uwmaxairshellwalkspeed,
				uwmaxwalkspeed = uwmaxwalkspeed,
				uwmaxrunspeed = uwmaxrunspeed,
				uwfriction = uwfriction,
				uwsuperfriction = uwsuperfriction,
				uwfrictionair = uwfrictionair,
				uwairslidefactor = uwairslidefactor,
				uwjumpforce = uwjumpforce,
				uwjumpforceadd = uwjumpforceadd,
				uwyacceleration = uwyacceleration,
				uwyaccelerationjumping = uwyaccelerationjumping,
				waterjumpforce = waterjumpforce,

				--abilities
				fireenemy = false,
				smallducking = false,
				breaksblockssmall = false,
				skid = false,
				groundpound = false,
				doublejump = false,
				
				--frames (anything that is quoted out doesn't work)
				idleframes = 1,
				runframes = 3,
				jumpframes = 1,
				fallframes = 0,
				customframes = 0,
				swimframes = 4,
				climbframes = 2,
				swimpushframes = 0,
				fenceframes = 0,
				smallduckingframes = 0,
				groundpoundframes = 0,
				--carryingframes = 0,
				--carryingwalkingframes = 0,
				--carryingjumpframes = 0,
				--grabbingframes = 0,
				--wallslideframes = 0,
				--spinjumpframes = 0,
				blueshellframes = 4,
				shoeframes = 0,
				--yoshiframes = 0,

				nopointing = false,
				portalgunoverlay = false, --paste an image of a portal gun on top of character
				portalgununderhat = false,
				nojumpsound = false,

				--powerup/health
				defaultsize = false,
				health = false,--3,
			
				--graphics positioning
				smalloffsetX = 6,
				smalloffsetY = 3,
				smallquadcenterX = 11,
				smallquadcenterY = 10,

				smallquadwidth = 20,
				smallquadheight = 20,
				smallimgwidth = 300,
				smallimgheight = 100,
			
				shrinkquadcenterX = 9,
				shrinkquadcenterY = 32,
				shrinkoffsetY = -3,
				shrinkquadcenterY2 = 16,
			
				growquadwidth = 20,
				growquadheight = 24,
				growquadcenterY = 16,
				growquadcenterY2 = 10,
			
				bigquadcenterY = 20,
				bigquadcenterX = 9,
				bigoffsetY = -3,
				bigoffsetX = 6,
			
				bigquadwidth = 20,
				bigquadheight = 36,
				bigimgwidth = 280,
				bigimgheight = 180,
			
				duckquadcenterY = 26,
				duckoffsetY = 3,
				
				hammerquadcenterY = 20,
				hammerquadcenterX = 9,
				hammeroffsetY = -3,
				hammeroffsetX = 6,
			
				hammerquadwidth = 20,
				hammerquadheight = 36,
				hammerimgwidth = 280,
				hammerimgheight = 180,
				
				frogquadcenterY = 24,
				frogquadcenterX = 9,
				frogoffsetY = -1,
				frogoffsetX = 6,
			
				frogquadwidth = 20,
				frogquadheight = 36,
				frogimgwidth = 280,
				frogimgheight = 180,

				raccoonquadcenterY = 20,
				raccoonquadcenterX = 14,
				raccoonoffsetY = -3,
				raccoonoffsetX = 6,
			
				raccoonquadwidth = 26,
				raccoonquadheight = 36,
				raccoonimgwidth = 624,
				raccoonimgheight = 180,

				raccoonhatoffsetX = -5,--added to the hat offset with raccon or tanooki
				raccoonhatspinoffsetX = -1,--added to the hat offset when spinning

				hugeoffsetX = 18,
				hugeoffsetY = -41,
				hugequadcenterX = 9,
				hugequadcenterY = 20,

				hugeclassicoffsetX = 12,
				hugeclassicoffsetY = -1,
				hugeclassicquadcenterX = 11,
				hugeclassicquadcenterY = 10,
			
				hugeclassicduckquadcenterY = 22,
				hugeclassicduckoffsetY = 7,

				capequadwidth = 34,
				capequadheight = 36,
				capeimgwidth = 884,
				capeimgheight = 180,

				capequadcenterY = 20,
				capequadcenterX = 17,
				capeoffsetY = -3,
				capeoffsetX = 6,

				capehatoffsetX = -8, --added to the hat offset with cape powerup

				--these are specifically for the cape image
				capeimgoffsetX = 0,
				capeimgoffsetY = 0,
				capeimgduckingoffsetY = -6,
				capeimgfenceoffsetX = -9,
				capeimgfireenemyoffsetX = 8,

				tinyoffsetX = 3,
				tinyoffsetY = 4,
				tinyquadcenterX = 5,
				tinyquadcenterY = 6,

				tinyquadwidth = 10,
				tinyquadheight = 10,
				tinyimgwidth = 150,
				tinyimgheight = 50,
				
				shellquadcenterY = 20,
				shellquadcenterX = 9,
				shelloffsetY = -3,
				shelloffsetX = 6,
			
				shellquadwidth = 20,
				shellquadheight = 36,
				shellimgwidth = 400,
				shellimgheight = 180,
				
				boomerangquadcenterY = 20,
				boomerangquadcenterX = 9,
				boomerangoffsetY = -3,
				boomerangoffsetX = 6,
			
				boomerangquadwidth = 20,
				boomerangquadheight = 36,
				boomerangimgwidth = 340,
				boomerangimgheight = 180,

				--helmet offsets
				helmetoffsetX = -3,
				helmetoffsetY = 7,
				helmetbigoffsetX = 3,
				helmetcapeoffsetX = -4,
				helmetraccoonoffsetX = -1,
				helmetfrogoffsetX = -2,
				helmetfrogoffsetY = -2,
				helmetskinnyoffsetX = -3,
				helmetskinnyoffsetY = 7,
				helmettinyoffsetX = 4,
				helmettinyoffsetY = 9,
				helmetspinoffsetX = -2, --added to the offset when spinning
				propellerhelmetoffsetX = 0,--added to offset when wearing propeller box
				propellerhelmetoffsetY = 4,
				cannonhelmetoffsetX = 0,--added to offset when wearing cannon box
				cannonhelmetoffsetY = 1,

				--shoe offsets
				smallyoshioffsetY = 9,
				bigyoshioffsetY = 5,
				hugeyoshioffsetY = -12,
				tinyyoshioffsetY = 12,
				hugeclassicyoshioffsetY = 14,
				
				yoshiimgoffsetY = 36, --yoshi's sprite offset
				yoshiimghugeoffsetY = 64,
				yoshiwalkoffsets = {1, 2, 0},
				yoshiskinnyoffsetY = -6, --mario's sprite offset when on yoshi
				yoshitinyoffsetY = -4, 

				smallshoeoffsetY = 7,
				bigshoeoffsetY = -5,
				hugeshoeoffsetY = -12,
				tinyshoeoffsetY = 12,
				hugeclassicshoeoffsetY = 14,

				shoeimgoffsetY = 23,
				shoeimghugeoffsetY = 43,
				shoeimghugeclassicoffsetY = 38,
				cloudimgoffsetY = 23,
				cloudimghugeoffsetY = 43,
				cloudimghugeclassicoffsetY = 38,
				drybonesshellimgoffsetY = 23,
				drybonesshellimghugeoffsetY = 43,
				drybonesshellimghugeclassicoffsetY = 38,
				drybonesshellimgduckingoffsetY = 8, --added to offsetY when ducking in drybones shell
				drybonesshellimghugeclassicduckingoffsetY = -8,
				drybonesshellimghugeduckingoffsetY = 8,
			}
			playerstuff.imgs = {} --list of imgs

			--load properties
			local s = love.filesystem.read(folder .. "/config.json")
			
			JSONcrashgame = false
			local temp
			local suc, err = pcall(function() return JSON:decode(s) end)
			if suc then
				temp = err
				--works! so set properties
				for i, v in pairs(temp) do
					-- set properties
					playerstuff[i] = v
					if i == "health" or i == "fireenemy" then
						playerstuff["advanced"] = true
					end
				end
			else
				jsonerrorwindow:open("CHARACTER JSON ERROR! (" .. v .. ".json)", JSONerror[2],
					function() 
						loadcustomplayers()
						resetcustomplayers()
					end)
				JSONcrashgame = true
			end
			if playerstuff.fireenemy and type(playerstuff.fireenemy) == "table" then
				for i, v in pairs(playerstuff.fireenemy) do
					local a = i:lower()
					if type(v) == "string" then
						playerstuff.fireenemy[a] = v:lower()
					else
						playerstuff.fireenemy[a] = v
					end
				end
			end

			for i2, n in pairs(animfiles) do
				local n = n .. "animations"
				if love.filesystem.getInfo(folder .. "/" .. n .. ".png") or love.filesystem.getInfo(folder .. "/" .. n .. "1.png") then
					playerstuff.imgs[n] = true
				end
			end

			--check if for the right version
			if playerstuff.version then
				local vs = playerstuff.version
				if vs and vs > VERSION then
					if math.abs(vs-VERSION) < 0.1 then
						notice.new(v .. " was made for a\nnew patch of mari0 ae\ndownload the new version", notice.white, 4.5)
					else
						notice.new(v .. " was made for a\nnewer version of mari0 ae\ndownload the new version!", notice.red, 8)
					end
				end
			end
			
			characters.data[v] = playerstuff
			table.insert(characters["list"], v)

			--create animations0.png animations1.png
			if playerstuff.splitmissingimages and playerstuff.writefiles then
				local i = v
				local imgs = characters.data[i].imgs
				if not characters.data[i]["animations"] then
					for i2, v in pairs(animfiles) do
						local n = v .. "animations"
						if imgs[n] and not love.filesystem.getInfo(folder .. "/" .. n .. "1.png") then
							characters.data[i][n] = {}
							local img = love.image.newImageData("alesans_entities/characters/" .. i .. "/" .. n .. ".png")
							local imgdata = splitimage(img, characters.data[i].splitcolors, true, "imagedata")
							imgdata:encode("png", "alesans_entities/characters/" .. i .. "/" .. n .. "0.png")
							for j = 1, #characters.data[i].colorables do
								imgdata = splitimage(img, characters.data[i].splitcolors[j], nil, "imagedata")
								imgdata:encode("png", "alesans_entities/characters/" .. i .. "/" .. n .. j .. ".png")
							end
						end
					end
				end
			end
		end
	end
end

function resetcustomplayers()
	for i = 1, #mariocharacter do
		if mariocharacter[i] then
			setcustomplayer(mariocharacter[i], i, "initial")
		end
	end
end

---@param img love.ImageData
---@param color table
---@param exclude boolean?
---@param imagedata boolean?
local function _splitimageshaders(img, color, exclude, imagedata)
	if not splitShader then
		splitShader = love.graphics.newShader[[
			uniform Image inputImage;
			uniform vec3 splitColor;

			#ifdef VERTEX
			vec4 position( mat4 transform_projection, vec4 vertex_position )
			{
				return transform_projection * vertex_position;
			}
			#endif
			#ifdef PIXEL
			vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
			{
				vec4 texcolor = Texel(inputImage, texture_coords);
				if (abs(texcolor.r-splitColor.r) > 0.01 || abs(texcolor.g-splitColor.g) > 0.01 || abs(texcolor.b-splitColor.b) > 0.01)
				{ discard; }
				return vec4(1.0,1.0,1.0,1.0);
			}
			#endif
		]]
	end
	local drawable = love.graphics.newImage(img)
	local output = love.graphics.newCanvas(drawable:getWidth(), drawable:getHeight())
	if exclude then
		local outputdata = output:newImageData()
		return love.graphics.newImage(outputdata)
	end
	local c = love.graphics.getCanvas()
	love.graphics.setCanvas(output)
	love.graphics.setShader(splitShader)
	splitShader:send("inputImage", drawable)
	splitShader:send("splitColor", {color[1]/255,color[2]/255,color[3]/255})
	love.graphics.draw(drawable,0,0)
	love.graphics.setShader()
	love.graphics.setCanvas(c)
	local outputdata = output:newImageData()
	return love.graphics.newImage(outputdata)
end

---@param img love.ImageData
---@param color table
---@param exclude boolean?
---@param imagedata boolean?
local function _splitimageffi(img, color, exclude, imagedata)
	local output    = img:clone()
	local pointer   = require("ffi").cast("uint8_t*", output:getFFIPointer()) -- imageData has one byte per channel per pixel.
	local bytecount = output:getWidth() * output:getHeight() -- pixel count * 4

	for i = 0, 4*bytecount-1, 4 do
		local r, g, b, a = pointer[i], pointer[i+1], pointer[i+2], pointer[i+3]

		local place = false
		if exclude then
			place = true
			for _, c in pairs(color) do
				if r == c[1] and g == c[2] and b == c[3] then
					place = false
					break
				end
			end
		else
			if r == color[1] and g == color[2] and b == color[3] then
				place = true
			end
		end
		if place then
			-- if exclude, values remain the same, so no need to do anything
			if not exclude then
				pointer[i]   = 255
				pointer[i+1] = 255
				pointer[i+2] = 255
				pointer[i+3] = a
			end
		else
			pointer[i]   = 0
			pointer[i+1] = 0
			pointer[i+2] = 0
			pointer[i+3] = 0
		end
	end

	if imagedata then
		return output
	else
		return love.graphics.newImage(output)
	end
end

---@param img love.ImageData
---@param color table
---@param exclude boolean?
---@param imagedata boolean?
local function _splitimagenative(img, color, exclude, imagedata)
	local output = img:clone()
	output:mapPixel(function(_, _, r, g, b, a)
		local place = false
		if exclude then
			place = true
			for _, c in pairs(color) do
				if r == c[1] and g == c[2] and b == c[3] then
					place = false
					break
				end
			end
		else
			if r == color[1] and g == color[2] and b == color[3] then
				place = true
			end
		end
		if place then
			if exclude then
				return r, g, b, a
			else
				return 255, 255, 255, a
			end
		end
		return 0, 0, 0, 0
	end)
	if imagedata then
		return output
	else
		return love.graphics.newImage(output)
	end
end

---@param img love.ImageData
---@param color table
---@param exclude boolean?
---@param imagedata boolean?
function splitimage(img, color, exclude, imagedata) --split singe image into colorable images
	if false then --useShader then
		return _splitimageshaders(img, color, exclude, imagedata)
	elseif true then
		return _splitimageffi(img, color, exclude, imagedata)
	else
		return _splitimagenative(img, color, exclude, imagedata)
	end
end

function setcustomplayer(i, pn, initial) --name, player number, initial (don't change colors to defaults)
	if i and characters.data[i] then
		if love.filesystem.getInfo("alesans_entities/characters/" .. i .. "/config.txt") then
			--incompatible probably
			if love.filesystem.getInfo("alesans_entities/characters/" .. i .. "/animationsBAK.png") then --SE Character
				notice.new("Incompatible Character Detected\nUse characters made for mari0:AE!", notice.red, 5)
			elseif not love.filesystem.getInfo("alesans_entities/characters/" .. i .. "/config.json") then --Old Character Format
				notice.new("Incompatible Character Detected\nUse characters made for\nmari0:AE version " .. VERSIONSTRING .. "!", notice.red, 5)
			end
		end

		local imgs = characters.data[i].imgs
		if not characters.data[i]["animations"] then
			for i2, v in pairs(animfiles) do
				local n = v .. "animations"
				if imgs[n] then
					characters.data[i][n] = {}
					if #characters.data[i].colors == #characters.data[i].colorables and not characters.data[i].dontsplitcolors then
						local img = love.image.newImageData("alesans_entities/characters/" .. i .. "/" .. n .. ".png")
						characters.data[i][n][0] = splitimage(img, characters.data[i].colors, true)
						for j = 1, #characters.data[i].colorables do
							characters.data[i][n][j] = splitimage(img, characters.data[i].colors[j])
						end
					elseif love.filesystem.getInfo("alesans_entities/characters/" .. i .. "/" .. n .. "1.png") then
						for j = 0, #characters.data[i].colorables do
							if not love.filesystem.getInfo("alesans_entities/characters/" .. i .. "/" .. n .. j .. ".png") then
								characters.data[i][n][j] = blankimg
							else
								characters.data[i][n][j] = love.graphics.newImage("alesans_entities/characters/" .. i .. "/" .. n .. j .. ".png")
							end
						end
					else
						characters.data[i][n][0] = love.graphics.newImage("alesans_entities/characters/" .. i .. "/" .. n .. ".png")
						for j = 1, #characters.data[i].colorables do
							characters.data[i][n][j] = blankimg
						end
					end
				elseif v ~= "fire" and v ~= "ice" and v ~= "superball" then
					characters.data[i][n] = characters.data["mario"][n]--_G["mario" .. n]
				end
			end
			--cape and bunnyears
			if love.filesystem.getInfo("alesans_entities/characters/" .. i .. "/cape.png") then
				characters.data[i].capeimg = love.graphics.newImage("alesans_entities/characters/" .. i .. "/cape.png")
			end
			if love.filesystem.getInfo("alesans_entities/characters/" .. i .. "/bunnyears.png") then
				characters.data[i].bunnyears = love.graphics.newImage("alesans_entities/characters/" .. i .. "/bunnyears.png")
			end
			--health counter
			if love.filesystem.getInfo("alesans_entities/characters/" .. i .. "/health.png") then
				local img = love.graphics.newImage("alesans_entities/characters/" .. i .. "/health.png")
				characters.data[i].healthimg = img
				local w, h = img:getWidth(), img:getHeight()
				local t = {}
				for y = 1, 2 do
					table.insert(t, love.graphics.newQuad(0, (h/2)*(y-1), w, h/2, w, h))
				end
				characters.data[i].healthquad = t
			end
		end
		if not characters.data[i]["quads"] then
			loadplayerquads(characters.data[i])
		end
		if characters.data[i].defaultcolors and characters.data[i].defaultcolors[pn] then
			if (not initial) or (mariocolors[pn] and #mariocolors[pn] < #characters.data[i].defaultcolors[pn]) then
				--this doesn't work correctly
				--for some reason the number of mario colors is always 4
				--i dont fuckin know
				--print(initial, #mariocolors[pn], #characters.data[i].defaultcolors[pn])
				if #characters.data[i].defaultcolors[pn] >= #characters.data[i].colorables then
					for j = 1, #characters.data[i].colorables do
						if characters.data[i].defaultcolors[pn][j] then
							mariocolors[pn][j] = shallowcopy(characters.data[i].defaultcolors[pn][j])
						else
							print("missing colorable:" .. j)
						end
					end
				end
				if characters.data[i].defaulthat and not initial then
					local hat = characters.data[i].defaulthat
					if hat == 0 then
						hat = nil
					end
					mariohats[pn] = {hat}
				end
			end
		end

		if characters.data[i].fireenemy then
			enemies_load()
		end

		if pn == 1 then
			playername = characters.data[i].name or "character"
		end
		
		mariocharacter[pn] = i
		return true
	else
		setcustomplayer("mario", pn, initial)
		return false
	end
end

function customplayerhatoffsets(i, targettable, anim, frame)
	--target table is hatoffsets, bighatoffsets, skinnyhatoffsets
	if i and characters.data[i] and characters.data[i][targettable] then
		if characters.data[i][targettable][anim] then
			if frame and type(characters.data[i][targettable][anim]) == "table" and characters.data[i][targettable][anim][frame] and type(characters.data[i][targettable][anim][frame]) == "table" then
				return characters.data[i][targettable][anim][frame]
			end
			return characters.data[i][targettable][anim]
		end
	end
	return false
end

--[[function getplayer() --sets abilities and sprites
	playerstuff = { playername, jumpheight, speed, grip(friction)}
	playerabilities = {raccoon}
end]]
