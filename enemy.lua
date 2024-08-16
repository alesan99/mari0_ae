--Some SE functions (Also keep track of AE ADDITION s)
local function twistdirection(gravitydir, dir) --mario.lua
	if not gravitydir or (gravitydir > math.pi/4*1 and gravitydir <= math.pi/4*3) then
		if dir == "floor" then
			return "floor"
		elseif dir == "left" then
			return "left"
		elseif dir == "ceil" then
			return "ceil"
		elseif dir == "right" then
			return "right"
		end
	elseif gravitydir > math.pi/4*3 and gravitydir <= math.pi/4*5 then
		if dir == "floor" then
			return "left"
		elseif dir == "left" then
			return "ceil"
		elseif dir == "ceil" then
			return "right"
		elseif dir == "right" then
			return "floor"
		end
	elseif gravitydir > math.pi/4*5 and gravitydir <= math.pi/4*7 then
		if dir == "floor" then
			return "ceil"
		elseif dir == "left" then
			return "right"
		elseif dir == "ceil" then
			return "floor"
		elseif dir == "right" then
			return "left"
		end
	else
		if dir == "floor" then
			return "right"
		elseif dir == "left" then
			return "floor"
		elseif dir == "ceil" then
			return "left"
		elseif dir == "right" then
			return "ceil"
		end
	end
end

local function unwrap(a)
	while a < 0 do
		a = a + (math.pi*2)
	end
	while a > (math.pi*2) do
		a = a - (math.pi*2)
	end
	return a
end
local function angles(a1, a2)
	local a1 = unwrap(a1)-math.pi
	local a2 = unwrap(a2)-math.pi
	local diff = a1-a2
	if math.abs(diff) < math.pi then
		return a1 > a2
	else
		return diff < 0
	end
end
local function anglesdiff(a1, a2)
	local a1 = unwrap(a1)-math.pi
	local a2 = unwrap(a2)-math.pi
	return math.abs(a1-a2) --diff
end

enemy = class:new()

function enemy:init(x, y, t, a, properties)
	if not enemiesdata[t] then
		return nil
	end
	
	self.t = t
	if a then
		self.a = {unpack(a)}
	else
		self.a = {}
	end
	
	--Some standard values..
	self.rotation = 0
	self.active = true
	self.static = false
	self.mask = {}
	self.gravitydirection = math.pi/2
	
	self.combo = 1
	
	self.falling = false
	
	self.shot = false
	self.outtable = {}
	
	self.speedx = 0
	self.speedy = 0
	
	--Get our enemy's properties from the property table
	for i, v in pairs(enemiesdata[self.t]) do
		self[i] = v
	end
	if properties then
		for i, v in pairs(properties) do
			self[i] = v
		end
	end

	-- update qaud if quadno is changed, better than running the same check 10 times
	local oldqaudno = (self.quadno or 1)

	--right click menu
	if self.rightclickmenu and self.a[3] then
		local s = tostring(self.a[3])
		if self.rightclickmenutable then
			if tonumber(self.a[3]) then
				self.a[3] = tonumber(self.a[3])
			end
			if self.rightclickmenumultipleproperties then
				local t = self.rightclickmenu[self.a[3]]
				if t then
					for i, v in pairs(t) do
						local name = v[1]
						local value = v[2]
						if type(value) == "table" then
							self[name] = deepcopy(value)
						else
							self[name] = value
						end
					end
				elseif testinglevel then
					notice.new("No rightclickmenu entry\nfor number:" .. tostring(self.a[3]), notice.red, 3)
				end
			else
				if type(self.rightclickmenu[self.a[3]]) == "table" then
					self[self.rightclickmenu[1]] = deepcopy(self.rightclickmenu[self.a[3]])
				else
					self[self.rightclickmenu[1]] = self.rightclickmenu[self.a[3]]
				end
			end
		else
			self.a[3] = s:gsub("B", "-")
			if tonumber(self.a[3]) then
				self.a[3] = tonumber(self.a[3])
			end

			if self.rightclickmenuboolean then
				self[self.rightclickmenu[1]] = (self.a[3] == "true")
			else
				self[self.rightclickmenu[1]] = self.a[3]
			end
		end
	end

	--right click
	if self.rightclick and #self.a > 0 then
		self.a[3] = tostring(self.a[3]):gsub("B", "-")
		local val
		-- types
		if self.rightclicktypes then
			val = convertr(self.a[3], self.rightclicktypes)
		else
			local types = {}
			local index = 0
			for i = 1, #self.rightclick do
				if self.rightclick[i][1] ~= "text" then
					index = index + 1
					if self.rightclick[i][1] == "dropdown" or self.rightclick[i][1] == "input" then
						local var = self.a[3]:split("|")
						if tonumber(var[index]) then
							types[index] = "num"
						else
							types[index] = "string"
						end
					elseif self.rightclick[i][1] == "checkbox" then
						types[index] = "bool"
					end
				end
			end
			val = convertr(self.a[3], types)
		end
		-- actally convert
		local index = 0
		for i = 1, #self.rightclick do
			if self.rightclick[i][1] ~= "text" then
				index = index + 1
				if type(self.rightclick[i][2]) == "table" then
					local var = false
					if self.rightclick[i][1] == "dropdown" then -- based on rightclickmenu
						for b = 1, #self.rightclick[i][4] do
							if self.rightclick[i][4][b] == val[index] or (tonumber(self.rightclick[i][4][b]) and tonumber(self.rightclick[i][4][b]) == val[index]) then
								var = b
							end
						end
					elseif self.rightclick[i][1] == "checkbox" then -- first list is for if true, second for if it is false
						if val[index] == true then var = 1 else var = 2 end
					elseif self.rightclick[i][1] == "input" then
						notice.new("you can't use a list\nfor an input!", notice.red, 3)
					end

					for i, v in pairs(self.rightclick[i][2][var]) do
						local name = v[1]
						local value = v[2]
						if (not self.casesensitive) and (name ~= "offsetX" and name ~= "offsetY" and name ~= "quadcenterX" and name ~= "quadcenterY") then
							value = value:lower()
						end
						if type(value) == "table" then
							self[name] = deepcopy(value)
						else
							self[name] = value
						end
					end
				else
					self[self.rightclick[i][2]] = val[index]
				end
			end
		end
		table.remove(self.a, 1)
	end
	
	-- if quadno is changed in either rightclick
	if oldqaudno ~= self.quadno then
		self.quad = self.quadgroup[self.quadno]
	end
	
	if self.customtimer then
		self.customtimertimer = 0
		self.currentcustomtimerstage = 1
	end
	
	--Decide on a random movement if it's random..
	if self.movementrandoms then
		self.movement = self.movementrandoms[math.random(#self.movementrandoms)]
	end
	
	self.x = x-.5-self.width/2+(self.spawnoffsetx or 0)
	self.y = y-self.height+(self.spawnoffsety or 0)
	
	if self.animationtype == "mirror" then
		self.animationtimer = 0
		self.animationdirection = "left"
	elseif self.animationtype == "frames" then
		self.quadi = self.animationstart
		self.quad = self.quadgroup[self.quadi]
		self.animationtimer = 0

		if type(self.animationspeed) == "table" then
			self.animationtimerstage = 1
		end
	elseif self.animationtype == "character" then
		self.quadi = self.animationstart
		self.quad = self.quadgroup[self.quadi]
		self.animationtimer = 0
		self.runanimationtimer = 0
	end

	if self.smallanimationstart and self.smallanimationframes then
		self.smallanimationtimer = 0
		self.smallanimationquadi = self.smallanimationstart
	end
	
	if self.stompanimation then
		self.deathtimer = 0
	end
	
	if self.shellanimal then
		self.upsidedown = false
		self.resettimer = 0
		self.wiggletimer = 0
		self.wiggleleft = true
		--self.returntilemaskontrackrelease = true
	end
	
	if self.customscissor then
		self.customscissor = {unpack(self.customscissor)}
		self.customscissor[1] = self.customscissor[1] + x - 1
		self.customscissor[2] = self.customscissor[2] + y - 1
	end
	
	if self.starttowardsplayerhorizontal or self.startawayfromplayerhorizontal then --Prize for best property name
		local closestplayer = 1
		self.animationdirection = "right"
		local closestdist = math.huge
		for i = 1, #objects["player"] do
			local v = objects["player"][i]
			local dist = math.sqrt((v.x-self.x)^2+(v.y-self.y)^2)
			if dist < closestdist then
				closestdist = dist
				closestplayer = i
			end
		end
		if objects["player"][closestplayer] then
			if objects["player"][closestplayer].x+objects["player"][closestplayer].width/2 < self.x+self.width/2 then
				self.speedx = -math.abs(self.speedx)
				if not self.dontmirror then --AE ADDITION
					self.animationdirection = "right"
				end
				if self.movement == "homing" then
					self.homingrotation = 0
				end
			else
				self.speedx = math.abs(self.speedx)
				if not self.dontmirror then --AE ADDITION
					self.animationdirection = "left"
				end
				if self.movement == "homing" then
					self.homingrotation = math.pi
				end
			end
			if self.startawayfromplayerhorizontal then
				self.speedx = -self.speedx
			end
		end
	end

	if self.killsenemiesonsides == nil then
		self.killsenemiesonsides = true
	end
	if self.killsenemiesontop == nil then
		self.killsenemiesontop = true
	end
	if self.killsenemiesonbottom == nil then
		self.killsenemiesonbottom = true
	end
	if self.killsenemiesonleft == nil then
		self.killsenemiesonleft = true
	end
	if self.killsenemiesonright == nil then
		self.killsenemiesonright = true
	end
	if self.killsenemiesonpassive == nil then
		self.killsenemiesonpassive = true
	end
	
	self.firstmovement = self.movement
	self.firstanimationtype = self.animationtype
	self.startoffsetY = self.offsetY
	self.startquadcenterY = self.quadcenterY
	self.startgravity = self.gravity
	self.startx = self.x
	self.starty = self.y
	self.startactive = self.active
	self.startdrawable = self.drawable
	self.startkillsenemies = self.killsenemies
	
	self.spawnallow = true
	self.spawnedenemies = {}
	if self.movement == "piston" then
		self.pistontimer = self.pistonretracttime
		self.pistonstate = "retracting"
		
		if self.spawnonlyonextended then
			self.spawnallow = false
		end
	elseif self.movement == "flyvertical" or self.movement == "flyhorizontal" then
		self.flyingtimer = 0
		self.startx = self.x
		self.starty = self.y
	elseif self.movement == "squid" then
		self.squidstate = "idle"
	elseif self.movement == "circle" then
		self.startx = self.x
		self.starty = self.y
		if not self.circletimer then
			self.circletimer = 0
		end
	elseif self.movement == "path" then
		self.startx = self.x
		self.starty = self.y
		self.movementpathstep = 1
		self.movementpathbackwards = false
	elseif self.movement == "crawl" then
		if self.crawlfloor == "up" then
			self.gravity = -self.crawlgravity
			self.gravityx = 0
			if self.crawldirection == "left" then self.speedx = self.crawlspeed else self.speedx = -self.crawlspeed end
		elseif self.crawlfloor == "left" then
			self.gravity = 0
			self.gravityx = -self.crawlgravity
			if self.crawldirection == "left" then self.speedy = -self.crawlspeed else self.speedy = self.crawlspeed end
		elseif self.crawlfloor == "right" then
			self.gravity = 0
			self.gravityx = self.crawlgravity
			if self.crawldirection == "left" then self.speedy = self.crawlspeed else self.speedy = -self.crawlspeed end
		else
			self.gravity = self.crawlgravity
			if self.crawldirection == "left" then self.speedx = -self.crawlspeed else self.speedx = self.crawlspeed end
			self.gravityx = 0
		end
		self.ignorelowgravity = true
		self.aroundcorner = false
	elseif self.movement == "homing" then
		if self.starthomingrotationtowardsplayer then --starting rotation is towards player
			local closestplayer = 1 --find closest player
			local relativex, relativey, dist
			for i = 1, players do
				local v = objects["player"][i]
				relativex, relativey = (v.x + -self.x), (v.y + -self.y)
				distance = math.sqrt(relativex*relativex+relativey*relativey)
				if ((not dist) or (distance < dist)) and not v.dead then
					closestplayer = i
				end
			end
			local p = objects["player"][closestplayer]
			if p then
				local angle = -math.atan2((p.x+p.width/2)-(self.x+self.width/2), (p.y+p.height/2)-(self.y+self.height/2))-math.pi/2
				self.homingrotation = unwrap(angle)
			end
		end
		if self.upsidedownifhomingrotationright then
			if (self.homingrotation >= math.pi*.5 and self.homingrotation <= math.pi*1.5) then
				self.upsidedown = true
			end
		end
	elseif self.movement == "chase" then
		self.movedirection = "left"
		self.movedirectiony = "left"
	elseif self.movement == "shadow" then
		self.shadowtable = {}
		self.shadowrate = self.shadowrate or 0.2 --delay at which position of target is recorded
		self.shadowlag = self.shadowlag or 1
		self.shadowtimer = 0
		if self.shadowinterpolate == nil then self.shadowinterpolate = true end
	end
	
	if self.speedxtowardsplayer or self.speedxawayfromplayer then
		local closestplayer = 1
		local closestdist = math.sqrt((objects["player"][1].x-self.x)^2+(objects["player"][1].y-self.y)^2)
		for i = 2, players do
			local v = objects["player"][i]
			local dist = math.sqrt((v.x-self.x)^2+(v.y-self.y)^2)
			if dist < closestdist then
				closestdist = dist
				closestplayer = i
			end
		end
		
		if objects["player"][closestplayer].x + objects["player"][closestplayer].width/2 > self.x + self.width/2 then
			self:leftcollide("", {}, "", {})
			self.speedx = math.abs(self.speedx)
		else
			self:rightcollide("", {}, "", {})
			self.speedx = -math.abs(self.speedx)
		end

		
		if self.speedxawayfromplayer then
			self.speedx = -self.speedx
		end
	end
	
	if self.lifetimerandoms then
		self.lifetime = self.lifetimerandoms[math.random(#self.lifetimerandoms)]
	end
	if self.lifetime and self.lifetime >= 0 then
		self.lifetimer = self.lifetime
	end
	
	if self.flickertime then
		self.flickertimer = 0
	end
	
	if self.jumps then
		self.jumptimer = 0
	end
	
	if self.spawnsenemy then
		self.spawnenemytimer = 0
		self.spawnenemydelay = self.spawnenemydelays[math.random(#self.spawnenemydelays)]
	end

	if self.bounces and (self.bouncedelay or self.bouncedelays) then
		self.bouncetimer = 0
		if self.bouncedelays then
			if self.bouncedelaysrandoms then
				self.bouncedelay = self.bouncedelays[math.random(#self.bouncedelays)]
			else
				self.bouncetimerstage = 1
				self.bouncedelay = self.bouncedelays[self.bouncetimerstage]
			end
		end
	end
	
	self.throwanimationstate = 0
	
	if self.chasetime then
		self.chasetimer = 0
	end
	
	if self.spawnsound then
		self:playsound(self.spawnsound)
	end

	if self.spawnchildren then
		if not (self.a and self.a[1] == "ignorespawnchildren") then
			for i = 1, #self.spawnchildren do
				local offsetx = self.spawnchildrenoffsetx or 0
				if type(self.spawnchildrenoffsetx) == "table" then
					offsetx = self.spawnchildrenoffsetx[i]
				end
				local offsety = self.spawnchildrenoffsety or 0
				if type(self.spawnchildrenoffsety) == "table" then
					offsety = self.spawnchildrenoffsety[i]
				end
				local a = {"ignorespawnchildren"}
				if self.childrencanspawnchildren then
					a = {}
				end
				local temp = enemy:new(self.x+self.width/2+.5+offsetx, self.y+self.height+offsety, self.spawnchildren[i], a)
				if self.spawnchildrenparent then
					temp.parent = self
				end
				if self.supersizechildren and self.supersized then
					supersizeentity(temp)
				end
				table.insert(objects["enemy"], temp)
			end
		end
	end

	if self.carryable then
		self.rigidgrab = true
		self.carryparent = false
		self.userect = adduserect(self.x+self.carryrange[1], self.y+self.carryrange[2], self.carryrange[3], self.carryrange[4], self)
		if self.throwntime then
			self.throwntimer = 0
		end
		self.pickupready = false
		self.pickupreadyplayers = {}
	end

	if self.jumps or self.noplayercollisiononthrow then
		--make copy of mask table, otherwise it modifies it for every enemy
		self.mask = deepcopy(self.mask)
	end

	if self.freezable == nil then
		self.freezable = true --AE ADDITION
	end

	if self.movement == "circle" then
		if self.circletimer ~= 0 then
			local v = ((self.circletimer/(self.circletime or 1))*math.pi*2)
			local newx = math.sin(v)*(self.circleradiusx or self.circleradius or 1) + self.startx
			local newy = math.cos(v)*(self.circleradiusy or self.circleradius or 1) + self.starty
			self.x = newx
			self.y = newy
		end
	end

	--snap position to tile grid
	if self.snapxtogrid then
		self.x = round(self.x)+(self.snapxtogridoffset or 0)
	end
	if self.snapytogrid then
		self.y = round(self.y)+(self.snapytogridoffset or 0)
	end

	--platform collision (ignore side collisions without any callbacks)
	if self.platformcollisionup then self.PLATFORM = true end
	if self.platformcollisiondown then self.PLATFORMDOWN = true end
	if self.platformcollisionleft then self.PLATFORMLEFT = true end
	if self.platformcollisionright then self.PLATFORMRIGHT = true end

	--block portals
	if self.blockportaltile then
		local t = {math.floor(x), math.floor(y)}
		if type(self.blockportaltile) == "table" then
			t = {math.floor(x)+math.floor(self.blockportaltile[1]), math.floor(y)+math.floor(self.blockportaltile[2])}
		end
		self.blockportaltilecoordinate = tilemap(t[1], t[2])
		blockedportaltiles[self.blockportaltilecoordinate] = true
	end
	
	--trigger animation on spawnn
	if self.animationtriggeronspawn or self.triggeranimationonspawn then
		self:triggeranimation(self.animationtriggeronspawn or self.triggeranimationonspawn)
	end
	if self.transformenemyanimationonspawn then
		transformenemyanimation(self.transformenemyanimationonspawn)
	end
	
	self.outtable = {}
end

function enemy:update(dt)
	--Just spawned
	if self.justspawned then
		self.justspawned = nil
	end

	--Funnels and fuck
	if self.funnel and not self.infunnel then
		self:enteredfunnel(true)
	end
	
	if self.infunnel and not self.funnel then
		self:enteredfunnel(false)
	end

	self.funnel = false
	
	if self.flickertime and self.flickertimer then
		self.flickertimer = self.flickertimer + dt
		while self.flickertimer > self.flickertime do
			self.flickertimer = self.flickertimer - self.flickertime
			self.drawable = not self.drawable
		end
	end
	
	if self.transformkill then
		if self.transformkilldeath then
			self:output()
		else
			self:output("transformed")
		end
		self.dead = true
		
		return true
	elseif self.kill then
		self:output()
		self.dead = true
		
		return true
	end
	
	if self.stompanimation and self.dead then
		self.deathtimer = self.deathtimer + dt
		if self.deathtimer > (self.stompanimationtime or 0.5) then
			self:output()
			
			return true
		else
			return false
		end
	end
	
	if (not self.doesntunrotate) and (not self.rotationanimation) and (not self.rollanimation) then
		self.rotation = unrotate(self.rotation, self.gravitydirection, dt)
	end
	
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
	end

	if self.frozen then
		return false
	end
	
	if self.lifetimer and not self.shot then
		self.lifetimer = self.lifetimer - dt
		if self.lifetimer <= 0 then
			if self.transforms and self:gettransformtrigger("lifetime") then
				self:transform(self:gettransformsinto("lifetime"))
			end
			self:output()
			self.dead = true
			
			return true
		end
	end

	if self.rotationanimation then
		self.rotation = self.rotation + (self.rotationanimationspeed or 1)*dt
	end
	if self.rollanimation then
		self.rotation = self.rotation + self.speedx*math.pi*dt
	end

	local oldx, oldy
	if self.platform or self.animationtype == "character" then
		oldx, oldy = self.x, self.y
	end

	--water
	if self.watergravity or self.waterdamping or (self.transforms and (self:gettransformtrigger("water") or self:gettransformtrigger("notinwater"))) then
		--is the enemy in water?
		local oldwater = self.water or false
		self.water = underwater
		if self.risingwater then
			--how many frames since in water
			self.risingwater = self.risingwater - 1
			self.water = true
			if self.risingwater < 0 then
				self.risingwater = false
			end
		end
		if not self.water then --water tiles
			local x1 = math.floor(self.x)+1
			local y1 = math.floor(self.y)+1
			local dobreak = false
			for x2 = math.max(1,x1), math.min(mapwidth,math.floor(self.x+self.width)+1) do
				for y2 = math.max(1,y1), math.min(mapheight,math.floor(self.y+self.height)+1) do
					if inmap(x2, y2) and tilequads[map[x2][y2][1]] and tilequads[map[x2][y2][1]].water then
						dobreak = true
						self.water = true
						break
					end
				end
				if dobreak then break end
			end
		end
		if oldwater == false and self.water == true then --in water
			self:dive(true)
			if self.transforms and self:gettransformtrigger("water") then
				self:transform(self:gettransformsinto("water"))
				return
			end
		elseif oldwater == true and self.water == false then --not in water
			if self.transforms and self:gettransformtrigger("notinwater") then
				self:transform(self:gettransformsinto("notinwater"))
				return
			end
		end
		if self.watergravity then
			if oldwater == false and self.water == true then
				self.gravity = self.watergravity
			elseif oldwater == true and self.water == false then
				self.gravity = self.startgravity
			end
		end
		if self.y+self.height < uwmaxheight and underwater and self.watergravity then
			self.speedy = uwpushdownspeed
		end
	end
	if self.float then
		self.risingwater = false
	end
	
	if self.animationtype == "mirror" then
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > self.animationspeed do
			self.animationtimer = self.animationtimer - self.animationspeed
			if self.animationdirection == "left" then
				self.animationdirection = "right"
			else
				self.animationdirection = "left"
			end
		end
	elseif self.animationtype == "frames" then
		self.animationtimer = self.animationtimer + dt
		if type(self.animationspeed) == "table" then
			while self.animationtimer > self.animationspeed[self.animationtimerstage] do
				self.animationtimer = self.animationtimer - self.animationspeed[self.animationtimerstage]
				self.quadi = self.quadi + 1
				if self.quadi > self.animationstart + self.animationframes - 1 then
					self.quadi = self.quadi - self.animationframes
				end
				self.quad = self.quadgroup[self.quadi]
				self.animationtimerstage = self.animationtimerstage + 1
				if self.animationtimerstage > #self.animationspeed then
					self.animationtimerstage = 1
				end
			end
		else
			while self.animationtimer > self.animationspeed do
				self.animationtimer = self.animationtimer - self.animationspeed
				self.quadi = self.quadi + 1
				if self.quadi > self.animationstart + self.animationframes - 1 then
					self.quadi = self.quadi - self.animationframes
				end
				self.quad = self.quadgroup[self.quadi]
			end
		end
		
		if not self.dontmirror then --AE ADDITION
			if self.speedx > 0 then
				self.animationdirection = "left"
			elseif self.speedx < 0 then
				self.animationdirection = "right"
			end
		end
	end
	
	if self.spawnsenemy then
		if lakitoend and self.movement == "follow" and (not self.ignorelakitoend) then
			self.speedx = -3
			return false
		end
		
		local playernear = false
		if self.dontspawnenemyonplayernear or self.spawnenemyonplayernear then
			local dist = self.spawnenemydist or self.dontspawnenemydist or 3
			if type(dist) == "table" then
				local col = checkrect(self.x+dist[1], self.y+dist[2], dist[3], dist[4], {"player"})
				if #col > 0 then
					playernear = true
				end
			else
				for i = 1, players do
					local v = objects["player"][i]
					if inrange(v.x+v.width/2, self.x+self.width/2-(dist), self.x+self.width/2+(dist)) then
						playernear = true
						break
					end
				end
			end
			if self.spawnenemyonplayernear then
				playernear = not playernear
			end
		end

		if (not playernear) then
			self.spawnenemytimer = self.spawnenemytimer + dt
			while self.spawnenemytimer >= self.spawnenemydelay and self.spawnallow and (not self.spawnmax or self:getspawnedenemies() < self.spawnmax) do
				if self.spawnsenemyrandoms then
					self.spawnsenemy = self.spawnsenemyrandoms[math.random(#self.spawnsenemyrandoms)]
				end
				self:spawnenemy(self.spawnsenemy)
				self.spawnenemytimer = 0
				self.spawnenemydelay = self.spawnenemydelays[math.random(#self.spawnenemydelays)]
				self.throwanimationstate = 0
				if self.animationtype == "frames" then
					self.quad = self.quadgroup[self.quadi + self.throwanimationstate]
				end
			end
			
			if self.throwpreparetime and self.spawnenemytimer >= (self.spawnenemydelay - self.throwpreparetime) then
				self.throwanimationstate = self.throwquadoffset
				if self.animationtype == "frames" then
					self.quad = self.quadgroup[self.quadi + self.throwanimationstate]
				end
			end
		end
	end

	if self.bounces and self.bouncedelay and (not self.falling) then
		self.bouncetimer = self.bouncetimer + dt
		if self.bouncetimer > self.bouncedelay then
			local force = self.bounceforce
			if type(self.bounceforce) == "table" then
				if self.bouncetimerstage and not self.bounceforcerandom then
					force = self.bounceforce[self.bouncetimerstage]
				else
					force = self.bounceforce[math.random(#self.bounceforce)]
				end
			end
			self.speedy = -(force or 10)
			self.bouncetimer = 0
			if self.bouncetimerstage then
				self.bouncetimerstage = self.bouncetimerstage + 1
				if self.bouncetimerstage > #self.bouncedelays then
					self.bouncetimerstage = 1
				end
				self.bouncedelay = self.bouncedelays[self.bouncetimerstage]
			elseif self.bouncedelaysrandoms then
				self.bouncedelay = self.bouncedelays[math.random(#self.bouncedelays)]
			end
		end
	end
	
	if self.movement == "truffleshuffle" then
		if self.speedx > 0 then
			if self.speedx > self.truffleshufflespeed then
				self.speedx = self.speedx - self.truffleshuffleacceleration*dt*2
				if self.speedx < self.truffleshufflespeed then
					self.speedx = self.truffleshufflespeed
				end
			elseif self.speedx < self.truffleshufflespeed then
				self.speedx = self.speedx + self.truffleshuffleacceleration*dt*2
				if self.speedx > self.truffleshufflespeed then
					self.speedx = self.truffleshufflespeed
				end
			end
		else
			if self.speedx < -self.truffleshufflespeed then
				self.speedx = self.speedx + self.truffleshuffleacceleration*dt*2
				if self.speedx > -self.truffleshufflespeed then
					self.speedx = -self.truffleshufflespeed
				end
			elseif self.speedx > -self.truffleshufflespeed then
				self.speedx = self.speedx - self.truffleshuffleacceleration*dt*2
				if self.speedx < -self.truffleshufflespeed then
					self.speedx = -self.truffleshufflespeed
				end
			end
		end
		
		if self.turnaroundoncliff and self.falling == false then
			--check if nothing below
			local x, y = math.floor(self.x + self.width/2+1), math.floor(self.y + self.height+1.5)
			if inmap(x, y) and (not checkfortileincoord(x, y)) and ((inmap(x+.5, y) and checkfortileincoord(math.ceil(x+.5), y)) or (inmap(x-.5, y) and checkfortileincoord(math.floor(x-.5), y))) and (not (inmap(x,y-1) and objects["tile"][tilemap(x, y-1)] and objects["tile"][tilemap(x, y-1)].SLOPE)) then
				if self.speedx < 0 then
					self.x = x-self.width/2
				else
					self.x = x-1-self.width/2
				end
				self.speedx = -self.speedx
			end
		end

		if edgewrapping then --wrap around screen
			local minx, maxx = -self.width, mapwidth
			if self.x < minx then
				self.x = maxx
			elseif self.x > maxx then
				self.x = minx
			end
		end
		
	elseif self.movement == "shell" then
		if self.small then
			if self.wakesup then
				if math.abs(self.speedx) < 0.0001 then
					self.resettimer = self.resettimer + dt
					if self.resettimer > self.resettime then
						self.offsetY = self.startoffsetY
						self.quadcenterY = self.startquadcenterY
						self.quad = self.quadgroup[self.animationstart]
						self.small = false
						self.speedx = -self.truffleshufflespeed
						self.resettimer = 0
						self.upsidedown = false
						self.kickedupsidedown = false
						self.movement = self.firstmovement
						self.animationtype = self.firstanimationtype
						
						if self.chasemarioonwakeup then
							local px = objects["player"][getclosestplayer(self.x)].x --AE ADDITION (changed x to self.x)
							if px > self.x then
								self.speedx = -self.speedx
							end
						end
					elseif self.resettimer > self.resettime-self.wiggletime then
						self.wiggletimer = self.wiggletimer + dt
						while self.wiggletimer > self.wiggledelay do
							self.wiggletimer = self.wiggletimer - self.wiggledelay
							if self.wiggleleft then
								if self.wigglequad then
									self.offsetY = self.wiggleoffsety or self.startoffsetY
									self.quadcenterY = self.wigglequadcentery or self.startquadcenterY
									if self.upsidedown then
										self.offsetY = self.upsidedownwiggleoffsety or self.upsidedownoffsety or 4
										self.quadcenterY = self.upsidedownwigglequadcentery or self.wigglequadcentery or self.upsidedownquadcentery or self.startquadcenterY
									end
									self.quad = self.quadgroup[self.wigglequad]
								else
									self.x = self.x + 1/16
								end
							else
								if self.wigglequad then
									self.offsetY = self.startoffsetY
									self.quadcenterY = self.startquadcenterY
									if self.upsidedown then
										self.offsetY = self.upsidedownoffsety or 4
										self.quadcenterY = self.upsidedownquadcentery or self.startquadcenterY
									end
									self.quad = self.quadgroup[self.smallquad]
								else
									self.x = self.x - 1/16
								end
							end
							self.wiggleleft = not self.wiggleleft
						end
					end
				else
					self.resettimer = 0
				end
			end
			if math.abs(self.speedx) >= 0.0001 then
				--shell animation
				if self.smallanimationstart and self.smallanimationframes and not self.kickedupsidedown then
					self.smallanimationtimer = self.smallanimationtimer + dt
					while self.smallanimationtimer > self.smallanimationspeed do
						self.smallanimationtimer = self.smallanimationtimer - self.smallanimationspeed
						self.smallanimationquadi = self.smallanimationquadi + 1
						if self.smallanimationquadi > self.smallanimationstart + self.smallanimationframes - 1 then
							self.smallanimationquadi = self.smallanimationquadi - self.smallanimationframes
						end
						self.quad = self.quadgroup[self.smallanimationquadi]
					end
				end
			end
		end
		
		if edgewrapping then --wrap around screen
			local minx, maxx = -self.width, mapwidth
			if self.x < minx then
				self.x = maxx
			elseif self.x > maxx then
				self.x = minx
			end
		end
		
	elseif self.movement == "follow" then
		local nearestplayer = 1
		while objects["player"][nearestplayer] and objects["player"][nearestplayer].dead do
			nearestplayer = nearestplayer + 1
		end
		
		if objects["player"][nearestplayer] then
			local nearestplayerx = objects["player"][nearestplayer].x
			for i = 2, players do
				local v = objects["player"][i]
				if v.x > nearestplayerx and not v.dead then
					nearestplayer = i
				end
			end
			
			nearestplayerx = nearestplayerx + objects["player"][nearestplayer].speedx*(self.distancetime or 1)
			
			local distance = math.abs(self.x - nearestplayerx)
			
			--check if too far in wrong direction
			if (not self.direction or self.direction == "left") and self.x < nearestplayerx-self.followspace then
				self.direction = "right"
				if not self.dontmirror then --AE ADDITION
					self.animationdirection = "right"
				end
			elseif self.direction == "right" and self.x > nearestplayerx+self.followspace then
				self.direction = "left"
				if not self.dontmirror then --AE ADDITION
					self.animationdirection = "left"
				end
			end
			
			if self.direction == "right" then
				if self.nofollowspeedup then
					self.speedx = self.followspeed or 2
				else
					self.speedx = math.max((self.followspeed or 2), round((distance-3)*2))
				end
			else
				self.speedx = -(self.followspeed or 2)
			end
		end
	elseif self.movement == "chase" then
		local closestplayer = 1 --find closest player
		for i = 2, players do
			local v = objects["player"][i]
			if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
				closestplayer = i
			end
		end
		local p = objects["player"][closestplayer]
		if self.chasespeed then
			if self.x+self.width/2 > p.x+p.width/2 + (self.chasespace or 2) then
				if not self.dontmirror then
					self.animationdirection = "right"
				end
				self.movedirection = "right"
			elseif self.x+self.width/2 < p.x+p.width/2 - (self.chasespace or 2) then
				if not self.dontmirror then
					self.animationdirection = "left"
				end
				self.movedirection = "left"
			end
			if self.movedirection == "left" then
				if self.speedx > self.chasespeed then
					self.speedx = self.speedx - self.chaseacceleration*dt*2
					if self.speedx < self.chasespeed then
						self.speedx = self.chasespeed
					end
				elseif self.speedx < self.chasespeed then
					self.speedx = self.speedx + self.chaseacceleration*dt*2
					if self.speedx > self.chasespeed then
						self.speedx = self.chasespeed
					end
				end
			else
				if self.speedx < -self.chasespeed then
					self.speedx = self.speedx + self.chaseacceleration*dt*2
					if self.speedx > -self.chasespeed then
						self.speedx = -self.chasespeed
					end
				elseif self.speedx > -self.chasespeed then
					self.speedx = self.speedx - self.chaseacceleration*dt*2
					if self.speedx < -self.chasespeed then
						self.speedx = -self.chasespeed
					end
				end
			end
		end
		if self.chasespeedy then
			if self.y+self.height/2 > p.y+p.height/2 + (self.chasespacey or 2) then
				if not self.dontmirror then
					self.animationdirectiony = "right"
				end
				self.movedirectiony = "right"
			elseif self.y+self.height/2 < p.y+p.height/2 - (self.chasespacey or 2) then
				if not self.dontmirror then
					self.animationdirectiony = "left"
				end
				self.movedirectiony = "left"
			end
			if self.movedirectiony == "left" then
				if self.speedy > self.chasespeedy then
					self.speedy = self.speedy - self.chaseaccelerationy*dt*2
					if self.speedy < self.chasespeedy then
						self.speedy = self.chasespeedy
					end
				elseif self.speedy < self.chasespeedy then
					self.speedy = self.speedy + self.chaseaccelerationy*dt*2
					if self.speedy > self.chasespeedy then
						self.speedy = self.chasespeedy
					end
				end
			else
				if self.speedy < -self.chasespeedy then
					self.speedy = self.speedy + self.chaseaccelerationy*dt*2
					if self.speedy > -self.chasespeedy then
						self.speedy = -self.chasespeedy
					end
				elseif self.speedy > -self.chasespeedy then
					self.speedy = self.speedy - self.chaseaccelerationy*dt*2
					if self.speedy < -self.chasespeedy then
						self.speedy = -self.chasespeedy
					end
				end
			end
		end

		if self.turnaroundoncliff and self.falling == false then
			--check if nothing below
			local x, y = math.floor(self.x + self.width/2+1), math.floor(self.y + self.height+1.5)
			if inmap(x, y) and tilequads[map[x][y][1]]:getproperty("collision", x, y) == false and ((inmap(x+.5, y) and tilequads[map[math.ceil(x+.5)][y][1]]:getproperty("collision", math.ceil(x+.5), y)) or (inmap(x-.5, y) and tilequads[map[math.floor(x-.5)][y][1]]:getproperty("collision", math.floor(x-.5), y))) then
				if self.speedx < 0 then
					self.x = x-self.width/2
					self.movedirection = "right"
				else
					self.x = x-1-self.width/2
					self.movedirection = "left"
				end
				self.speedx = -self.speedx
			end
		end

		if edgewrapping then --wrap around screen
			local minx, maxx = -self.width, mapwidth
			if self.x < minx then
				self.x = maxx
			elseif self.x > maxx then
				self.x = minx
			end
		end
	elseif self.movement == "piston" then
		self.pistontimer = self.pistontimer + dt
		
		if self.pistonstate == "extending" then		
			--move X
			if self.x > self.startx + self.pistondistx then
				self.x = self.x - self.pistonspeedx*dt
				if self.x < self.startx + self.pistondistx then
					self.x = self.startx + self.pistondistx
				end
			elseif self.x < self.startx + self.pistondistx then
				self.x = self.x + self.pistonspeedx*dt
				if self.x > self.startx + self.pistondistx then
					self.x = self.startx + self.pistondistx
				end
			end
			
			--move Y
			if self.y > self.starty + self.pistondisty then
				self.y = self.y - self.pistonspeedy*dt
				if self.y < self.starty + self.pistondisty then
					self.y = self.starty + self.pistondisty
				end
			elseif self.y < self.starty + self.pistondisty then
				self.y = self.y + self.pistonspeedy*dt
				if self.y > self.starty + self.pistondisty then
					self.y = self.starty + self.pistondisty
				end
			end
			
			if self.x == self.startx + self.pistondistx and self.y == self.starty + self.pistondisty and not self.spawnallow then
				self.spawnallow = true
				self.spawnenemytimer = self.spawnenemydelay
			end
			
			if self.pistontimer > self.pistonextendtime then
				self.pistontimer = 0
				self.spawnallow = false
				self.pistonstate = "retracting"
			end
			
			
		else --retracting			
			--move X
			if self.x > self.startx then
				self.x = self.x - self.pistonspeedx*dt
				if self.x < self.startx then
					self.x = self.startx
				end
			elseif self.x < self.startx then
				self.x = self.x + self.pistonspeedx*dt
				if self.x > self.startx then
					self.x = self.startx
				end
			end
			
			--move Y
			if self.y > self.starty then
				self.y = self.y - self.pistonspeedy*dt
				if self.y < self.starty then
					self.y = self.starty
				end
			elseif self.y < self.starty then
				self.y = self.y + self.pistonspeedy*dt
				if self.y > self.starty then
					self.y = self.starty
				end
			end
			
			if self.inactiveonretracted and self.x == self.startx and self.y == self.starty then
				self.active = false
			end
			
			if self.pistontimer > self.pistonretracttime then
				local playernear = false
				for i = 1, players do
					local v = objects["player"][i]
					if inrange(v.x+v.width/2, self.x+self.width/2-(self.dontpistondist or 3), self.x+self.width/2+(self.dontpistondist or 3)) then
						playernear = true
						break
					end
				end
				
				if not self.dontpistonnearplayer or not playernear then
					self.pistontimer = 0
					self.pistonstate = "extending"
					self.active = true
				end
			end
		end
	elseif self.movement == "wiggle" and (not self.track) then
		if self.speedx < 0 then
			if self.x < self.startx-self.wiggledistance then
				self.speedx = self.wigglespeed or 1
			end
		elseif self.speedx > 0 then
			if self.x > self.startx then
				self.speedx = -self.wigglespeed or 1
			end
		else
			self.speedx = self.wigglespeed or 1
		end
		
	elseif self.movement == "verticalwiggle" and (not self.track) then
		if self.speedy < 0 then
			if self.y < self.starty-self.verticalwiggledistance then
				self.speedy = self.verticalwigglespeed or 1
			end
		elseif self.speedy > 0 then
			if self.y > self.starty then
				self.speedy = -self.verticalwigglespeed or 1
			end
		else
			self.speedy = self.verticalwigglespeed or 1
		end
		
	elseif self.movement == "rocket" then
		if self.y > self.starty+(self.rocketdistance or 15) and self.speedy > 0 then
			self.y = self.starty+(self.rocketdistance or 15)
			
			self.speedy = -math.sqrt(2*(self.gravity or yacceleration)*(self.rocketdistance or 15))
		end
		
		if self.speedy < 0 then
			self.upsidedown = false
		else
			self.upsidedown = true
		end
		
	elseif self.movement == "squid" and (not self.track) then
		local closestplayer = 1
		local closestdist = math.sqrt((objects["player"][1].x-self.x)^2+(objects["player"][1].y-self.y)^2)
		for i = 2, players do
			local v = objects["player"][i]
			local dist = math.sqrt((v.x-self.x)^2+(v.y-self.y)^2)
			if dist < closestdist then
				closestdist = dist
				closestplayer = i
			end
		end
		
		if self.squidstate == "idle" then
			self.speedy = self.squidfallspeed
			
			--get if change state to upward
			if (self.y+self.speedy*dt) + self.height + 0.0625 >= (objects["player"][closestplayer].y - (24/16 - objects["player"][closestplayer].height)) then
				self.squidstate = "upward"
				self.upx = self.x
				self.speedx = 0
				self.speedy = 0
				
				if self.animationtype == "squid" then
					self.quad = self.quadgroup[2]
				end
				
				--get if to change direction
				if true then--math.random(2) == 1 then
					if self.direction == "right" then
						if self.x > objects["player"][closestplayer].x then
							self.direction = "left"
						end
					else
						if self.x < objects["player"][closestplayer].x then
							self.direction = "right"
						end
					end
				end
			end
			
		elseif self.squidstate == "upward" then
			if self.direction == "right" then
				self.speedx = self.speedx + self.squidacceleration*dt
				if self.speedx > self.squidxspeed then
					self.speedx = self.squidxspeed
				end
			else
				self.speedx = self.speedx - self.squidacceleration*dt
				if self.speedx < -self.squidxspeed then
					self.speedx = -self.squidxspeed
				end
			end
			
			self.speedy = self.speedy - self.squidacceleration*dt
			
			if self.speedy < -self.squidupspeed then
				self.speedy = -self.squidupspeed
			end
			
			if math.abs(self.x - self.upx) >= (self.squidhordistance or 2) then
				self.squidstate = "downward"
				self.downy = self.y
				self.speedx = 0
			end
			
		elseif self.squidstate == "downward" then
			self.speedy = self.squidfallspeed
			if self.y > self.downy + self.squiddowndistance then
				self.squidstate = "idle"
			end
			
			if self.animationtype == "squid" then
				self.quad = self.quadgroup[1]
			end
		end
		
	elseif self.movement == "targety" and (not self.track) then
		if self.y > self.targety then
			self.y = self.y - self.targetyspeed*dt
			if self.y < self.targety then
				self.y = self.targety
			end
		elseif self.y < self.targety then
			self.y = self.y + self.targetyspeed*dt
			if self.y > self.targety then
				self.y = self.targety
			end
		end
	elseif self.movement == "flyvertical" and (not self.track) then
		self.flyingtimer = self.flyingtimer + dt
		
		while self.flyingtimer > (self.flyingtime or 7) do
			self.flyingtimer = self.flyingtimer - (self.flyingtime or 7)
		end
		
		local newy = self:func(self.flyingtimer/(self.flyingtime or 7))*(self.flyingdistance or 7.5) + self.starty
		self.y = newy
	elseif self.movement == "flyhorizontal" and (not self.track) then
		self.flyingtimer = self.flyingtimer + dt
		
		while self.flyingtimer > (self.flyingtime or 7) do
			self.flyingtimer = self.flyingtimer - (self.flyingtime or 7)
		end
		
		local newx = self:func(self.flyingtimer/(self.flyingtime or 7))*(self.flyingdistance or 7.5) + self.startx
		if not self.dontmirror then
			if newx > self.x then --AE ADDITION
				self.animationdirection = "left"
			else
				self.animationdirection = "right"
			end
		end

		self.x = newx
	elseif self.movement == "circle" then --AE ADDITION
		self.circletimer = self.circletimer + dt
		
		while self.circletimer > math.abs(self.circletime or 1) do
			self.circletimer = self.circletimer - math.abs(self.circletime or 1)
		end
		
		local v = ((self.circletimer/(self.circletime or 1))*math.pi*2)
		local newx = math.sin(v)*(self.circleradiusx or self.circleradius or 1) + self.startx
		local newy = math.cos(v)*(self.circleradiusy or self.circleradius or 1) + self.starty
		self.x = newx
		self.y = newy
	elseif self.movement == "homing" then --AE ADDITION
		local p
		local pass, onlyrotatepass = true, false
		if self.homingatenemy then
			local dist
			for i, v in pairs(objects["enemy"]) do
				if (type(self.homingatenemy) == "string" and v.t == self.homingatenemy) or (type(self.homingatenemy) == "table" and tablecontains(self.homingatenemy, v.t)) then
					local relativex, relativey = (v.x + -self.x), (v.y + -self.y)
					local distance = math.sqrt(relativex*relativex+relativey*relativey)
					if ((not dist) or (distance < dist)) then
						p = v; dist = distance
					end
				end
			end
		else
			local closestplayer = 1 --find closest player
			local relativex, relativey, dist, distance
			for i = 1, players do
				local v = objects["player"][i]
				relativex, relativey = (v.x + -self.x), (v.y + -self.y)
				distance = math.sqrt(relativex*relativex+relativey*relativey)
				if ((not dist) or (distance < dist)) and (not v.dead) then
					closestplayer = i; dist = distance
				end
			end
			p = objects["player"][closestplayer]
		end
		if p and self.stophomingdist then --stop homing if player is too close
			local relativex, relativey = (p.x + -self.x), (p.y + -self.y)
			if math.sqrt(relativex*relativex+relativey*relativey) < self.stophomingdist then
				self.speedx, self.speedy = 0, 0
				pass = false
				onlyrotatepass = self.stophomingdistrotate--stay still, but allow enemy to rotate
			end
		end
		if p and (pass or onlyrotatepass) then
			local oldhomingrotation = self.homingrotation
			local angle = -math.atan2((p.x+p.width/2)-(self.x+self.width/2), (p.y+p.height/2)-(self.y+self.height/2))-math.pi/2
			local turnDir1 = angles(angle, self.homingrotation)
			if turnDir1 then
				self.homingrotation = self.homingrotation + self.homingturnspeed*dt
			else
				self.homingrotation = self.homingrotation - self.homingturnspeed*dt
			end
			local turnDir2 = angles(angle, self.homingrotation)
			if turnDir1 ~= turnDir2 then --correct rotation if it over-shoots
				self.homingrotation = angle
			end
			if pass then --sometimes the enemy is only allowed to aim
				if self.onlymovewhenhomingrotationatplayer and anglesdiff(angle, self.homingrotation) > self.onlymovewhenhomingrotationatplayerthreshold then
					--stop chasing if not facing player
					self.speedx, self.speedy = 0, 0
				else
					self.speedx, self.speedy = math.cos(self.homingrotation+math.pi)*(self.homingspeed), math.sin(self.homingrotation+math.pi)*(self.homingspeed)
					if self.dontchangehomingrotationwhenmoving then
						self.homingrotation = oldhomingrotation
					end
				end
			end
		end
		if self.rotationishomingrotation then
			self.rotation = self.homingrotation
		end
	elseif self.movement == "path" then
		local speedx, speedy = 0, 0
		local oldx, oldy = self.x, self.y
		local timedist = dt --how much time passed
		while timedist > 0 do
			local movedpasttarget = false
			local tx, ty = self.startx+self.movementpath[self.movementpathstep][1]+(self.movementpathoffsetx or 0), self.starty+self.movementpath[self.movementpathstep][2]+(self.movementpathoffsety or 0)
			local angle = -math.atan2(tx-self.x, ty-self.y)-math.pi/2
			local speed = self.movementpathspeed
			if type(self.movementpathspeed) == "table" then
				speed = self.movementpathspeed[self.movementpathstep]
			end

			self.x = self.x + (math.cos(angle+math.pi)*(speed))*timedist
			self.y = self.y + (math.sin(angle+math.pi)*(speed))*timedist

			--face or rotate
			if self.rotatetowardsmovementpath then
				self.rotation = angle
			else
				if not self.dontmirror then
					if self.x > oldx then
						self.animationdirection = "left"
					else
						self.animationdirection = "right"
					end
				end
			end

			--check if it is past target
			if ((oldx < tx and self.x > tx) or (oldx > tx and self.x < tx)) or ((oldy < ty and self.y > ty) or (oldy > ty and self.y < ty)) then
				movedpasttarget = true
			end

			if movedpasttarget then
				local distancemoved = math.sqrt((oldx-self.x)*(oldx-self.x)+(oldy-self.y)*(oldy-self.y))
				local targetdistance = math.sqrt((oldx-tx)*(oldx-tx)+(oldy-ty)*(oldy-ty))
				if self.movementpathbackwards then
					self.movementpathstep = self.movementpathstep - 1
					if self.movementpathstep < 1 then
						self.movementpathbackwards = false
						self.movementpathstep = 2
					end
				else
					self.movementpathstep = self.movementpathstep + 1
					--end of path, either loop back or bounce
					if self.movementpathstep > #self.movementpath then
						if self.transforms and self:gettransformtrigger("movementpathend") then
							self:transform(self:gettransformsinto("movementpathend"))
							return
						end
						if self.movementpathturnaround then
							self.movementpathstep = math.max(1, self.movementpathstep - 2)
							self.movementpathbackwards = true
						else
							self.movementpathstep = 1
						end
					end
				end
				self.x = tx
				self.y = ty
				oldx, oldy = self.x, self.y
				timedist = timedist - math.abs(distancemoved-targetdistance)/speed
			else
				timedist = 0
			end
		end
	elseif self.movement == "crawl" then
		if self.crawlrotation then 
			if self.crawlfloor == "down" then
				self.rotation = 0
			elseif self.crawlfloor == "up" then
				self.rotation = math.pi
			elseif self.crawlfloor == "right" then
				self.rotation = math.pi*1.5
			elseif self.crawlfloor == "left" then
				self.rotation = math.pi*.5
			end
		end
		
		if not self.dontmirror then
			if self.crawldirection == "right" then
				self.animationdirection = "left"
			else
				self.animationdirection = "right"
			end
		end
		
		if not self.aroundcorner then
			--go around corner?
			if self.crawldirection == "left" then
				if self.crawlfloor == "left" or self.crawlfloor == "right" then
					if self.speedx > 0 and self.crawlfloor == "right" then
						self.speedx = self.crawlspeed
						self.speedy = 0
						self.gravity = -(self.crawlgravity or yacceleration)
						self.gravityx = 0
						self.aroundcorner = true
						self.crawlfloor = "up"
					elseif self.speedx < 0 and self.crawlfloor == "left" then
						self.speedx = -self.crawlspeed
						self.speedy = 0
						self.gravity = (self.crawlgravity or yacceleration)
						self.gravityx = 0
						self.aroundcorner = true
						self.crawlfloor = "down"
					end
				elseif self.crawlfloor == "up" or self.crawlfloor == "down" then
					if self.speedy > 0 and self.crawlfloor == "down" then
						self.speedy = self.crawlspeed
						self.speedx = 0
						self.gravity = 0
						self.gravityx = (self.crawlgravity or yacceleration)
						self.aroundcorner = true
						self.crawlfloor = "right"
					elseif self.speedy < 0 and self.crawlfloor == "up" then
						self.speedy = -self.crawlspeed
						self.speedx = 0
						self.gravity = 0
						self.gravityx = -(self.crawlgravity or yacceleration)
						self.aroundcorner = true
						self.crawlfloor = "left"
					end
				end
			else
				if self.crawlfloor == "left" or self.crawlfloor == "right" then
					if self.speedx > 0 and self.crawlfloor == "right" then
						self.speedx = self.crawlspeed
						self.speedy = 0
						self.gravity = (self.crawlgravity or yacceleration)
						self.gravityx = 0
						self.aroundcorner = true
						self.crawlfloor = "down"
					elseif self.speedx < 0 and self.crawlfloor == "left" then
						self.speedx = -self.crawlspeed
						self.speedy = 0
						self.gravity = -(self.crawlgravity or yacceleration)
						self.gravityx = 0
						self.aroundcorner = true
						self.crawlfloor = "up"
					end
				elseif self.crawlfloor == "up" or self.crawlfloor == "down" then
					if self.speedy > 0 and self.crawlfloor == "down" then
						self.speedy = self.crawlspeed
						self.speedx = 0
						self.gravity = 0
						self.gravityx = -(self.crawlgravity or yacceleration)
						self.aroundcorner = true
						self.crawlfloor = "left"
					elseif self.speedy < 0 and self.crawlfloor == "up" then
						self.speedy = -self.crawlspeed
						self.speedx = 0
						self.gravity = 0
						self.gravityx = (self.crawlgravity or yacceleration)
						self.aroundcorner = true
						self.crawlfloor = "right"
					end
				end
			end
		end
	elseif self.movement == "shadow" then
		local length = self.shadowlag/self.shadowrate
		if length >= 2 or self.shadowlag == 0 then
			local target
			if self.shadowtarget == "player" and self.shadowtargetplayer then
				target = objects["player"][self.shadowtargetplayer]
			elseif self.shadowtarget == "parent" then
				if self.parent and not self.parent.delete then
					target = self.parent
				end
			elseif self.shadowtarget and objects[self.shadowtarget] then
				--find closest target
				local x1, y1 = self.x+self.width/2, self.y+self.height/2
				local dist = math.huge
				for j, w in pairs(objects[self.shadowtarget]) do
					if w ~= self and w.x and (not w.dead) then
						if self.shadowtarget == "enemy" and self.shadowtargetenemy then
							if w.t == self.shadowtargetenemy then
								local dist2 = ((x1-(w.x+w.width/2))*(x1-(w.x+w.width/2)))+((y1-(w.y+w.height/2))*(y1-(w.y+w.height/2)))
								if dist2 < dist then
									dist = dist2
									target = w
								end
							end
						else
							local dist2 = ((x1-(w.x+w.width/2))*(x1-(w.x+w.width/2)))+((y1-(w.y+w.height/2))*(y1-(w.y+w.height/2)))
							if dist2 < dist then
								dist = dist2
								target = w
							end
						end
					end
				end
			end 
			if target and target.x then
				--record target's position
				local ox = target.width/2
				local oy = target.height/2
				if self.shadowfromtargetbottom then
					oy = target.height
				end
				local tx = target.x+ox
				local ty = target.y+oy
				if self.shadowlag == 0 then
					self.shadowtable[1] = tx
					self.shadowtable[2] = ty
				else
					self.shadowtimer = self.shadowtimer + dt
					while self.shadowtimer > self.shadowrate do
						if (not self.shadowiftargetmoving) or (#self.shadowtable == 0 or
							(tx ~= self.shadowtable[#self.shadowtable-1] and ty ~= self.shadowtable[#self.shadowtable])) then
							if #self.shadowtable/2 >= length then
								table.remove(self.shadowtable,1)
								table.remove(self.shadowtable,1)
							end
							table.insert(self.shadowtable, tx)
							table.insert(self.shadowtable, ty)
						end
						self.shadowtimer = self.shadowtimer - self.shadowrate
					end
				end
			end
			local poof = false
			local ox = self.width/2
			local oy = self.height/2
			if self.shadowfromtargetbottom then
				oy = self.height
			end
			if self.shadowlag == 0 and target and target.x then
				self.x = (self.shadowtable[1] or self.x) -ox -(self.shadowoffsetx or 0)
				self.y = (self.shadowtable[2] or self.y) -oy -(self.shadowoffsety or 0)
				if self.shadowwaiting then
					self.shadowwaiting = false
					self.drawable = self.startdrawable
					self.active = self.startactive
					poof = true
				end
			elseif #self.shadowtable/2 >= length and self.shadowlag ~= 0 then
				if self.shadowwaiting then
					self.shadowwaiting = false
					self.drawable = self.startdrawable
					self.active = self.startactive
					poof = true
				end
				--set to position (and interpolate)
				local teleport = false
				if self.shadowteleportdist then
					local dist = ((self.shadowtable[1]-self.shadowtable[3])*(self.shadowtable[1]-self.shadowtable[3]))+((self.shadowtable[2]-self.shadowtable[4])*(self.shadowtable[2]-self.shadowtable[4]))
					if dist > self.shadowteleportdist*self.shadowteleportdist then
						teleport = true
					end
				end
				if self.shadowinterpolate and not teleport then
					local v = self.shadowtimer/self.shadowrate
					self.x = self.shadowtable[1]*(1-v)+self.shadowtable[3]*v -ox -(self.shadowoffsetx or 0)
					self.y = self.shadowtable[2]*(1-v)+self.shadowtable[4]*v -oy -(self.shadowoffsety or 0)
				else
					self.x = self.shadowtable[1] -ox -(self.shadowoffsetx or 0)
					self.y = self.shadowtable[2] -oy -(self.shadowoffsety or 0)
				end
			elseif self.shadownotactivewhenwaiting then
				if self.shadowwaiting == false then
					poof = true
				end
				self.drawable = false
				self.active = false
				self.shadowwaiting = true
			end
			if poof and self.shadowpoof then
				local t = self.shadowpoof
				if type(t) ~= "string" then t = "poof" end
				makepoof(self.x+self.width/2,self.y+self.height/2,t)
			end
		end
	end
	if (self.friction or self.airfriction) and self.movement ~= "truffleshuffle" then
		local friction = friction
		if self.airfriction and self.falling then
			friction = self.airfriction
		elseif type(self.friction) == "number" then
			friction = self.friction
		end
		if self.speedx > 0 then
			self.speedx = self.speedx - friction*dt
			if self.speedx < 0 then
				self.speedx = 0
			end
		else
			self.speedx = self.speedx + friction*dt
			if self.speedx > 0 then
				self.speedx = 0
			end
		end
	end
	if (self.verticalfriction or self.verticalairfriction) then
		local friction = friction
		if self.verticalairfriction and self.falling then
			friction = self.verticalairfriction
		elseif type(self.verticalfriction) == "number" then
			friction = self.verticalfriction
		end
		if self.speedy > 0 then
			self.speedy = self.speedy - friction*dt
			if self.speedy < 0 then
				self.speedy = 0
			end
		else
			self.speedy = self.speedy + friction*dt
			if self.speedy > 0 then
				self.speedy = 0
			end
		end
	end

	if self.xrelativetocamera then
		self.x = xscroll + self.xrelativetocamera
	end
	if self.yrelativetocamera then
		self.y = yscroll + self.yrelativetocamera
	end

	if self.sticktonearestplayer then --moves to where player is
		local closestplayer = 1
		local closestdist = math.sqrt((objects["player"][1].x-self.x)^2+(objects["player"][1].y-self.y)^2)
		for i = 2, players do
			local v = objects["player"][i]
			local dist = math.sqrt((v.x-self.x)^2+(v.y-self.y)^2)
			if dist < closestdist then closestdist = dist; closestplayer = i end
		end
		self.sticktoplayer = closestplayer
	end
	if self.sticktoplayer then
		local p = objects["player"][self.sticktoplayer]
		if p then
			local ox, oy = self.sticktoplayeroffsetx or 0, self.sticktoplayeroffsety or 0
			self.x = p.x+p.width/2-self.width/2+ox
			self.y = p.y+p.height/2-self.height/2+oy
		end
	end
	if self.teleportnearestplayer then --teleports player to enemy's position
		local closestplayer = 1
		local closestdist = math.sqrt((objects["player"][1].x-self.x)^2+(objects["player"][1].y-self.y)^2)
		for i = 2, players do
			local v = objects["player"][i]
			local dist = math.sqrt((v.x-self.x)^2+(v.y-self.y)^2)
			if dist < closestdist then closestdist = dist; closestplayer = i end
		end
		self.teleportplayer = closestplayer
	end
	if self.teleportplayer then
		local startp, endp = self.teleportplayer, self.teleportplayer
		if type(self.teleportplayer) == "boolean" then
			startp, endp = 1, players
		end
		for i = startp, endp do
			local p = objects["player"][i]
			if p then
				local ox, oy = self.teleportplayeroffsetx or 0, self.teleportplayeroffsety or 0
				p.x = (self.x+self.width/2)-(p.width/2)+ox
				p.y = (self.y+self.height/2)-(p.height/2)+oy
				if self.teleportplayerspeedx and self.teleportplayerspeedy then
					p.speedx = self.teleportplayerspeedx
					p.speedy = self.teleportplayerspeedy
				end
			end
		end
	end
	
	if self.jumps then
		self.jumptimer = self.jumptimer + dt
		if self.jumptimer > self.jumptime then
			self.jumptimer = self.jumptimer - self.jumptime
			--decide whether up or down
			local dir
			if self.y+self.height-0.01 > (mapheight-(self.jumponlyupdistfrombottom or 4)) then
				dir = "up"
			elseif self.y < 6 then
				dir = "down"
			else
				if math.random(2) == 1 then
					dir = "up"
				else
					dir = "down"
				end
			end
			
			if dir == "up" then
				self.speedy = -self.jumpforce
				self.mask[2] = true
				self.jumping = "up"
				self.falling = true
			else
				self.speedy = -self.jumpforcedown
				self.mask[2] = true
				self.jumping = "down"
				self.jumpingy = self.y
				self.falling = true
			end
		end
		
		if self.jumping then
			if self.jumping == "up" then
				if self.speedy > 0 then
					self.jumping = false
					self.mask[2] = false
				end
			elseif self.jumping == "down" then
				if self.y > self.jumpingy + self.height+1.1 then
					self.jumping = false
					self.mask[2] = false
				end
			end
		end
	end
	
	if self.facesplayer or self.facesplayery then
		local closestplayer = 1
		local closestdist = math.sqrt((objects["player"][1].x-self.x)^2+(objects["player"][1].y-self.y)^2)
		for i = 2, players do
			local v = objects["player"][i]
			local dist = math.sqrt((v.x-self.x)^2+(v.y-self.y)^2)
			if dist < closestdist then
				closestdist = dist
				closestplayer = i
			end
		end
		
		if self.facesplayer then
			if objects["player"][closestplayer].x + objects["player"][closestplayer].width/2 > self.x + self.width/2 then
				self.animationdirection = "left"
			else
				self.animationdirection = "right"
			end
		end
		if self.facesplayery then
			if objects["player"][closestplayer].y + objects["player"][closestplayer].height/2 > self.y + self.height/2 then
				self.upsidedown = false
			else
				self.upsidedown = true
			end
		end
	end
	
	if self.chasetime then
		if self.chasetimer > self.chasetime then
			local closestplayer = 1
			local closestdist = math.sqrt((objects["player"][1].x-self.x)^2+(objects["player"][1].y-self.y)^2)
			for i = 2, players do
				local v = objects["player"][i]
				local dist = math.sqrt((v.x-self.x)^2+(v.y-self.y)^2)
				if dist < closestdist then
					closestdist = dist
					closestplayer = i
				end
			end
			
			if objects["player"][closestplayer].x + objects["player"][closestplayer].width/2 < self.x + self.width/2 then
				self.speedx = -(self.chasespeed or 1.5)
				self.chasemariowasleft = true
			elseif self.chasemariowasleft then
				self.chasemariowasleft = nil
				self.chasetimer = 0
				self.startx = self.x
			end
		else
			self.chasetimer = self.chasetimer + dt
		end
	end

	
	if self.animationtype == "character" then
		if self.oldx then
			--Mario-like animation
			local xdiff = self.x-self.oldx
			local ydiff = self.y-self.oldy
			local running = math.abs(xdiff) > 0.001
			local jumping = math.abs(ydiff) > 0.001
			local falling = ydiff > 0.001
			local runstart = self.idleframes+1
			local jumpstart = self.idleframes+self.runframes+1
			local fallstart = self.idleframes+self.runframes+self.jumpframes+1
			if self.fallframes > 0 and falling then
				if self.quadi < fallstart or self.quadi > fallstart+self.fallframes-1 then
					self.quadi = fallstart
					self.animationtimer = 0
				end
				self.animationtimer = self.animationtimer + dt
				if self.quadi <= fallstart+self.fallframes-1 then
					while self.animationtimer > (self.fallanimationspeed or 0.1) do
						self.animationtimer = self.animationtimer - (self.fallanimationspeed or 0.1)
						self.quadi = math.min(fallstart+self.fallframes-1, (self.quadi+1 -fallstart)%(self.fallframes) +fallstart)
					end
				end
			elseif self.jumpframes > 0 and jumping then
				if self.quadi < jumpstart or self.quadi > jumpstart+self.jumpframes-1 then
					self.quadi = jumpstart
					self.animationtimer = 0
				end
				self.animationtimer = self.animationtimer + dt
				if self.quadi <= jumpstart+self.jumpframes-1 then
					while self.animationtimer > (self.jumpanimationspeed or 0.1) do
						self.animationtimer = self.animationtimer - (self.jumpanimationspeed or 0.1)
						self.quadi = math.min(jumpstart+self.jumpframes-1, (self.quadi+1 -jumpstart)%(self.jumpframes) +jumpstart)
					end
				end
			elseif self.runframes > 0 and running then
				if self.quadi < runstart or self.quadi > runstart+self.runframes-1 then
					self.quadi = runstart
					self.animationtimer = 0
				end
				self.animationtimer = self.animationtimer + dt
				while self.animationtimer > (self.runanimationspeed or 0.1) do
					self.animationtimer = self.animationtimer - (self.runanimationspeed or 0.1)
					self.quadi = (self.quadi+1 -runstart)%(self.runframes) +runstart
				end
			elseif self.idleframes > 1 then
				if self.quadi < 1 or self.quadi > 1+self.runframes-1 then
					self.quadi = 1
					self.animationtimer = 0
				end
				while self.animationtimer > (self.idleanimationspeed or 0.1) do
					self.animationtimer = self.animationtimer - (self.idleanimationspeed or 0.1)
					self.quadi = (self.quadi+1 -1)%(self.idleframes-1) +1
				end
			else
				if self.quadi < 1 or self.quadi > 1+self.runframes-1 then
					self.quadi = 1
				end
				self.quadi = 1
			end
			self.quad = self.quadgroup[self.quadi]
			
			if not self.dontmirror then
				if xdiff > 0 then
					self.animationdirection = "left"
				elseif xdiff < 0 then
					self.animationdirection = "right"
				end
			end
		end
		self.oldx = self.x
		self.oldy = self.y
	end

	--transform if falling
	if self.transforms and self.falling and self:gettransformtrigger("falling") then
		self:transform(self:gettransformsinto("falling"))
		return true
	end

	--platform
	if self.platform and self.platformchecktable and (not (self.trackplatform and self.tracked)) then
		local xdiff = self.speedx*dt
		if self.speedx == 0 and self.x ~= oldx then
			xdiff = self.x-oldx
		end
		local ydiff = self.speedy*dt
		if self.speedy == 0 and self.y ~= oldy then
			ydiff = self.y-oldy
		end
		local condition = false
		if ydiff < 0 then
			condition = "ignoreplatforms"
		end
		for i, v in pairs(self.platformchecktable) do
			for j, w in pairs(objects[v]) do
				if w.width and (not w.ignoreplatform) then
					if (not self.noplatformcarrying) and inrange(w.x, self.x-w.width, self.x+self.width) then --vertical carry
						if ((w.y == self.y - w.height) or 
							((self.movement == "circle" or self.movement == "flyvertical" or self.movement == "path" or self.speedy ~= 0) and w.y+w.height >= self.y-0.1 and w.y+w.height < self.y+0.1))
							and (not w.jumping) and not (self.speedy > 0 and w.speedy < 0) then --and w.speedy >= self.speedy
							if #checkrect(w.x+xdiff, self.y-w.height, w.width, w.height, {"exclude", w}, true, condition) == 0 then
								w.oldxplatform = w.x
								w.x = w.x + xdiff
								w.y = self.y-w.height
								w.falling = false
								w.speedy = self.speedy
							end
						end
					end
					if self.platformpush and xdiff ~= 0 then --horizontal push
						if inrange(w.y+w.height/2, self.y, self.y+self.height) then
							if xdiff > 0 and w.x < self.x+self.width and w.x+w.width > self.x+self.width then --right
								if #checkrect(self.x+self.width, w.y, w.width, w.height, {"exclude", w}, true, "ignoreplatforms") == 0 then
									w.oldxplatform = w.x
									w.x = self.x+self.width
								end
							elseif xdiff < 0 and w.x+w.width > self.x and w.x < self.x then
								if #checkrect(self.x-w.width, w.y, w.width, w.height, {"exclude", w}, true, "ignoreplatforms") == 0 then
									w.oldxplatform = w.x
									w.x = self.x-w.width
								end
							end
						end
					end
				end
			end
		end
	end

	--Check if player is near
	if self.transforms and (self:gettransformtrigger("playernear") or self:gettransformtrigger("playernotnear")) then
		local check = false
		if type(self.playerneardist) == "number" then
			for i = 1, players do
				local v = objects["player"][i]
				check = inrange(v.x+v.width/2, self.x+self.width/2-(self.playerneardist or 3), self.x+self.width/2+(self.playerneardist or 3))
				if check then break end
			end
		elseif type(self.playerneardist) == "table" and #self.playerneardist == 4 then
			local col = checkrect(self.x+self.playerneardist[1], self.y+self.playerneardist[2], self.playerneardist[3], self.playerneardist[4], {"player"})
			check = (#col > 0)
		end

		if check and self:gettransformtrigger("playernear")then
			self:transform(self:gettransformsinto("playernear"))
			return
		elseif (not check) and self:gettransformtrigger("playernotnear") then
			self:transform(self:gettransformsinto("playernotnear"))
			return
		end
	end
	
	--Check if enemy/enemies is near
	if self.transforms and (self:gettransformtrigger("enemynear") or self:gettransformtrigger("enemynotnear")) then
		local check = false
		for i, v in pairs(objects["enemy"]) do
			if (type(self.enemynearcheck) == "table" and tablecontains(self.enemynearcheck, v.t)) or self.enemynearcheck == v.t then
				if type(self.enemyneardist) == "number" then
					check = inrange(v.x+v.width/2, self.x+self.width/2-(self.enemyneardist or 3), self.x+self.width/2+(self.enemyneardist or 3))
				elseif type(self.enemyneardist) == "table" and #self.enemyneardist == 4 then
					check = aabb(v.x, v.y, v.width, v.height, self.x+self.enemyneardist[1], self.y+self.enemyneardist[2], self.enemyneardist[3], self.enemyneardist[4])
				end
				if check then break end
			end
		end

		if check and self:gettransformtrigger("enemynear")then
			self:transform(self:gettransformsinto("enemynear"))
			return
		elseif (not check) and self:gettransformtrigger("enemynotnear") then
			self:transform(self:gettransformsinto("enemynotnear"))
			return
		end
	end
	
	--Check if player if facing the enemy
	if self.staticifseen or self.staticifnotseen or (self.transforms and (self:gettransformtrigger("seen") or self:gettransformtrigger("notseen"))) then
		local lookedat = false
		for i = 1, players do
			local v = objects["player"][i]
			if v.x+(self.width/2) > self.x+(self.width/2) then
				if v.portals ~= "none" then --AE ADDITION (change)
					if v.pointingangle > 0 then
						lookedat = true
					end
				else
					if v.animationdirection == "left" then
						lookedat = true
					end
				end
			else
				if v.portals ~= "none" then --AE ADDITION (change)
					if v.pointingangle < 0 then
						lookedat = true
					end
				else
					if v.animationdirection == "right" then
						lookedat = true
					end
				end
			end
		end
		if (self.transforms and self:gettransformtrigger("notseen")) or self.staticifnotseen then
			lookedat = not lookedat
		end
		if lookedat then
			if self.staticifseen or self.staticifnotseen then
				self.static = true
			else
				if self:gettransformtrigger("seen") then
					self:transform(self:gettransformsinto("seen"))
				else
					self:transform(self:gettransformsinto("notseen"))
				end
				return
			end
		else
			if self.staticifseen or self.staticifnotseen then
				self.static = false
			end
		end
	end
	
	if self.rotatetowardsplayer then
		for i = 1, players do
			local v = objects["player"][i]
			if not v.dead then
				self.rotation = (-math.atan2((v.x+v.width/2)-(self.x+self.width/2), (v.y+v.height/2)-(self.y+self.height/2-3/16)))-math.pi/2
			end
		end
	end

	if self.carryable then
		if self.thrown then
			if self.throwntime then
				self.throwntimer = self.throwntimer - dt
				if self.throwntimer < 0 then
					if self.fliponcarry then
						self.flipped = false
					end
					if self.noplayercollisiononthrow then
						self.mask[3] = not self.mask[1] --no player collision
					end
					self.thrown = false
					if self.speedx > 0 then
						if not self.dontmirror then
							self.animationdirection = "left"
						end
						self.speedx = math.abs(self.speedx)
					elseif self.speedx < 0 then
						if not self.dontmirror then
							self.animationdirection = "right"
						end
						self.speedx = -math.abs(self.speedx)
					end
				end
			end
		elseif self.carryparent then
			local oldx = self.x
			local oldy = self.y
			
			local offsetx = (self.carryoffsetx or 0)
			if self.carryoffsetx then --carry in the direction player is facing
				if (self.carryparent.portalgun and self.carryparent.pointingangle > 0) or self.carryparent.animationdirection == "left" then
					offsetx = -offsetx
				end
			end
			self.x = (self.carryparent.x+self.carryparent.width/2-self.width/2) + offsetx
			self.y = (self.carryparent.y-self.height)+(self.carryoffsety or 0)

			if self.carryquad then
				self.quadi = self.carryquad
				self.quad = self.quadgroup[self.quadi]
			end

			if self.emancipatecheck then
				for h, u in pairs(emancipationgrills) do
					if u.active then
						if u.dir == "hor" then
							if inrange(self.x+6/16, u.startx-1, u.endx, true) and inrange(u.y-14/16, oldy, self.y, true) then
								self:emancipate(h)
							end
						else
							if inrange(self.y+6/16, u.starty-1, u.endy, true) and inrange(u.x-14/16, oldx, self.x, true) then
								self:emancipate(h)
							end
						end
					end
				end
			end

			--drop if not holding button
			if self.carryifholdingrunbutton and not runkey(self.carryparent.playernumber) then
				self.carryparent:use()
			end
		else
			self.pickupready = false
			for j, w in pairs(objects["player"]) do
				self.pickupreadyplayers[w.playernumber] = false
				local col = checkrect(self.x+self.carryrange[1], self.y+self.carryrange[2], self.carryrange[3], self.carryrange[4], {"player"})
				if #col > 0 then
					w.pickupready = self
					self.pickupready = true
					self.pickupreadyplayers[w.playernumber] = true
					
					--carry if holding button
					if (self.carryifholdingrunbutton and runkey(w.playernumber)) and not w.pickup then
						self:used(w.playernumber)
						w.pickupready = false
						break
					end
				end
			end
		end
		if self.userect then
			self.userect.x, self.userect.y = self.x+self.carryrange[1], self.y+self.carryrange[2]
		end
	end

	--blow entities kreygasm
	if self.blowrange then
		local col = checkrect(self.x+self.blowrange[1], self.y+self.blowrange[2], self.blowrange[3], self.blowrange[4], self.blowchecktable)
		for j = 1, #col, 2 do
			local a, b = col[j], objects[col[j]][col[j+1]]
			if (b.active or self.blownotactiveenemies) and ((not b.static) or self.blowstaticenemies) and b.blowable ~= false and (b.speedx or self.blowstrong) then
				if self.blowstrong then
					local fx, fy = b.x+(self.blowspeedx or 0)*dt, b.y+(self.blowspeedy or 0)*dt --future position
					
					local condition = "ignoreplatforms"
					if fy > b.y then
						condition = false
					end
					if not checkintile(fx, fy, b.width, b.height, tileentities, b, condition) then
						b.x = fx
						b.y = fy
					end
				else
					b.speedx = b.speedx+(self.blowspeedx or 0)*dt
					b.speedy = b.speedy+(self.blowspeedy or 0)*dt
				end
				if b.speedx then
					if self.blowminspeedx then
						b.speedx = math.max(self.blowminspeedx, b.speedx)
					end
					if self.blowmaxspeedx then
						b.speedx = math.min(self.blowmaxspeedx, b.speedx)
					end
					if self.blowminspeedy then
						b.speedy = math.max(self.blowminspeedy, b.speedy)
					end
					if self.blowmaxspeedy then
						b.speedy = math.min(self.blowmaxspeedy, b.speedy)
					end
				end
				if (not self.blowstrong) and a == "player" and b.speedy < 0 then
					b.falling = true
				end
			end
		end
	end

	--collect coins and collectables if enemy is over tile
	if (self.collectscoins or self.collectscollectables or self.collectscoinsinshell) and not ((self.collectscoinsinshell or self.collectscollectablesinshell) and not self.small) then --if it collects coins, it will collect collectables. But not the other way
		local collectscoins = self.collectscoins or self.collectscoinsinshell
		local collectscollectables = true
		if self.collectscollectables == false then --ignore collectables if explicitly set to false
			collectscollectables = false
		end
		for x = math.ceil(self.x), math.ceil(self.x+self.width) do
			for y = math.ceil(self.y), math.ceil(self.y+self.height) do
				if ismaptile(x, y) then
					if collectscoins and tilequads[map[x][y][1]].coin then
						collectcoin(x, y)
					elseif collectscoins and objects["coin"][tilemap(x, y)] then
						collectcoinentity(x, y)
					elseif collectscollectables and objects["collectable"][tilemap(x, y)] and not objects["collectable"][tilemap(x, y)].coinblock then
						local collectableid = objects["collectable"][tilemap(x, y)].t
						if not (self.collectscollectables and type(self.collectscollectables) == "table" and not self.collectscollectables[collectableid]) then
							--if the the property is set to a table, only collect collectable if the id number is set to true in the table
							getcollectable(x, y)
						end
					end
				end
			end
		end
	end
	
	if self.customtimer then
		--[delay, [action, parameter], argument]
		self.customtimertimer = self.customtimertimer + dt
		while self.customtimertimer > self.customtimer[self.currentcustomtimerstage][1] do
			self.customtimertimer = self.customtimertimer - self.customtimer[self.currentcustomtimerstage][1]
			self:customtimeraction(self.customtimer[self.currentcustomtimerstage][2], self.customtimer[self.currentcustomtimerstage][3], self.customtimer[self.currentcustomtimerstage][4])
			self.currentcustomtimerstage = self.currentcustomtimerstage + 1
			if self.currentcustomtimerstage > #self.customtimer then
				self.currentcustomtimerstage = 1
				if self.dontloopcustomtimer then
					self.customtimer = false
					break
				end
			end
		end
	end
	if self.customtrigger then --disabled until finished
		--[ ["if",property1,comparison,property2], [action, parameter],argument]
		for i = 1, #self.customtrigger do
			self:ifstatement(self.customtrigger[i][1], self.customtrigger[i][2], self.customtrigger[i][3])
		end
	end
end

function enemy:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end

function enemy:shotted(dir, cause, high, fireball, star)
	if self.resistseverything then
		return false
	end

	if fireball and self.resistsfire then
		return false
	end
	
	if star and self.resistsstar then
		return false
	end

	if cause and cause == "dkhammer" and self.resistsdkhammer then
		return false
	end

	if self.shothealth then
		if self.shothealth > 1 then
			self.shothealth = self.shothealth - 1
			if self.transforms then
				if self:gettransformtrigger("shotdamage") then
					self:transform(self:gettransformsinto("shotdamage"))
					return
				elseif self:gettransformtrigger("damage") then
					self:transform(self:gettransformsinto("damage"))
					return
				end
			end
			return
		end
	elseif self.health then --AE ADDITION
		if self.health > 1 then
			self.health = self.health - 1
			if self.transforms then
				if self:gettransformtrigger("damage") then
					self:transform(self:gettransformsinto("damage"))
					return
				end
			end
			return
		end
	end
	
	if self.givecoinwhenshot then
		collectcoin(nil, nil, tonumber(self.givecoinwhenshot) or 1)
	end
	
	if self.shotsound then
		self:playsound(self.shotsound)
	elseif not self.noshotsound then
		self:playsound("shot")
	end
	
	if self.transforms then
		if self:gettransformtrigger("shot") then
			self:transform(self:gettransformsinto("shot"), nil, "death")
			return
		elseif self:gettransformtrigger("death") then
			self:transform(self:gettransformsinto("death"), nil, "death")
			return
		end
	end
	
	self.speedy = -(self.shotjumpforce or shotjumpforce)
	if high then
		self.speedy = self.speedy*2
	end
	self.direction = dir or "right"
	self.gravity = shotgravity
	
	if self.direction == "left" then
		self.speedx = -(self.shotspeedx or shotspeedx)
	else
		self.speedx = self.shotspeedx or shotspeedx
	end
	
	if self.shellanimal then
		self.small = true
		self.quad = self.quadgroup[self.smallquad]
		if cause == true then --below
			self.upsidedown = true
			self.kickedupsidedown = true
			self.offsetY = self.upsidedownoffsety or 4
			self.quadcenterY = self.upsidedownquadcentery or self.startquadcenterY
			self.movement = self.smallmovement
			self.animationtype = "none"
		else
			self.shot = true
			self.active = false
		end
	else
		if self.shotframe then
			self.quad = self.quadgroup[self.shotframe]
		end
		self.shot = true
		self.active = false
	end
	
	if self.doesntflyawayonfireball then
		self.kill = true
		self.drawable = false
	end
	
	return true
end

function enemy:customtimeraction(action, arg, arg2)
	--set to a variable
	local ogarg, ogarg2 = arg, arg2
	if arg and type(arg) == "table" and arg[1] and arg[2] and arg[1] == "property" then
		arg = self[arg[2]]
	end

	if type(action) == "table" then --The new *better* custom timer format
		local a = action[1] --action
		local p = action[2] --parameter
		if a == "set" then
			self[p] = arg
			if p == "quadno" then
				--update frame
				self.quad = self.quadgroup[self.quadno]
			end
		elseif a == "add" then
			self[p] = self[p] + arg
		elseif a == "subtract" then
			self[p] = self[p] - arg
		elseif a == "multiply" then
			self[p] = self[p] * arg
		elseif a == "divide" then
			self[p] = self[p] / arg
		elseif a == "reverse" then
			if type(self[p]) == "boolean" then
				self[p] = not self[p]
			else
				self[p] = -self[p]
			end
		elseif a == "random" then
			if type(arg) == "number" then
				self[p] = math.random()*arg
			else
				self[p] = arg[math.random(#arg)]
			end
		elseif a == "abs" then
			self[p] = math.abs(self[p])
		elseif a == "sqrt" then
			self[p] = math.sqrt(self[p])
		elseif a == "mod" then
			self[p] = self[p]%arg
		elseif a == "pow" then
			self[p] = math.pow(self[p],arg)
		elseif a == "round" then
			self[p] = math.floor(self[p]+0.5)
		elseif a == "floor" then
			self[p] = math.floor(self[p])
		elseif a == "ceil" then
			self[p] = math.ceil(self[p])
		elseif a == "sin" then
			self[p] = math.sin(arg)
		elseif a == "cos" then
			self[p] = math.cos(arg)
		elseif a == "tan" then
			self[p] = math.tan(arg)
		elseif a == "atan2" then
			local in1, in2 = ogarg[1],ogarg[2]
			if ogarg[1] and type(ogarg[1]) == "table" and ogarg[1][1] and ogarg[1][2] and ogarg[1][1] == "property" then
				in1 = self[ogarg[1][2]]
			end
			if ogarg[2] and type(ogarg[2]) == "table" and ogarg[2][1] and ogarg[2][2] and ogarg[2][1] == "property" then
				in2 = self[ogarg[2][2]]
			end
			self[p] = math.atan2(in1,in2)
		elseif a == "min" then
			self[p] = math.min(self[p],arg)
		elseif a == "max" then
			self[p] = math.max(self[p],arg)
		elseif a == "log" then
			self[p] = math.log(arg)
		elseif a == "tonumber" then
			self[p] = tonumber(self[p])
		elseif a == "tostring" then
			self[p] = tostring(self[p])
		elseif a == "concat" then
			self[p] = self[p] .. arg

		elseif a == "if" then
			self:ifstatement(action, ogarg, ogarg2)
			--				   first;  Symb; Second;	 Action;	 Arg;
			--EXAMPLE: [0,["if","speedx",">=","speedy"],["set","speedy"],25]
		end
	else --backwards compatibility
		if action == "bounce" then
			if self.speedy == 0 then self.speedy = -(arg or 10) end
		elseif action == "playsound" then
			self:playsound(arg)
		elseif action == "spawnenemy" then
			if self.spawnsenemyrandoms then
				self.spawnsenemy = self.spawnsenemyrandoms[math.random(#self.spawnsenemyrandoms)]
			end
			self:spawnenemy(self.spawnsenemy)
		elseif action == "trackreverse" then
			if self.tracked then
				if self.trackcontroller.travel == "forward" then
					self.trackcontroller.travel = "backwards"
				else
					self.trackcontroller.travel = "forward"
				end
			end
		elseif action == "stopsound" then
			if self.sound and arg == self.t then
				self.sound:stop()
			elseif _G[arg .. "sound"] then
				_G[arg .. "sound"]:stop()
			end
		end
		if string.sub(action, 0, 7) == "reverse" then
			local parameter = string.sub(action, 8, string.len(action))
			self[parameter] = -self[parameter]
		elseif string.sub(action, 0, 3) == "add" then
			local parameter = string.sub(action, 4, string.len(action))
			self[parameter] = self[parameter] + arg
		elseif string.sub(action, 0, 8) == "multiply" then
			local parameter = string.sub(action, 9, string.len(action))
			self[parameter] = self[parameter] * arg
		elseif action == "setframe" then
			self.quad = self.quadgroup[arg]
		elseif LoveConsole and action == "print" then --only for advanced users!
			if self[arg] then
				print(self[arg])
			else
				print(arg)
			end
		elseif string.sub(action, 0, 3) == "set" then
			self[string.sub(action, 4, string.len(action))] = arg
		end
	end
end

function enemy:ifstatement(t, action, arg)
	--EXAMPLE: ["if","speedx","==","speedy"],["set","speedy"],10],
	--EXAMPLE: ["if","speedx","==","speedy","and","jumping","~=",false],["set","speedy"],10],
	local statementPass = false
	for step = 1, math.floor(#t/4) do
		local i = 1+(step-1)*4
		local check = t[i]:lower()

		--logic
		if check == "or" and statementPass then
			break
		end
		if statementPass == true or check == "or" or step == 1 then
			--get properties needed for comparison
			local prop1,prop2 = t[i+1], t[i+3]
			if (type(prop1) == "table" and prop1[1] and prop1[2] and prop1[1] == "property") then
				prop1 = self[prop1[2]]
			else
				prop1 = self[prop1]	
			end
			if (type(prop2) == "string" and self[prop2] ~= nil) then
				prop2 = self[prop2]
			elseif (type(prop2) == "table" and prop2[1] and prop2[2] and prop2[1] == "property") then
				prop2 = self[prop2[2]]
			end

			--comparison
			local comparison = t[i+2]
			if (not comparison) or (type(comparison) ~= "string") then
				return false
			end
			comparison = comparison:lower()

			local pass = false
			if (comparison == "equal" or comparison == "==") and (prop1 == prop2) then
				pass = true
			elseif (comparison == "notequal" or comparison == "~=" or comparison == "!=") and (prop1 ~= prop2) then
				pass = true
			elseif (comparison == "greater" or comparison == ">") and (prop1 > prop2) then
				pass = true
			elseif (comparison == "less" or comparison == "<") and (prop1 < prop2) then
				pass = true
			elseif (comparison == "greaterequal" or comparison == ">=") and (prop1 >= prop2) then
				pass = true
			elseif (comparison == "lessequal" or comparison == "<=") and (prop1 <= prop2) then
				pass = true
			elseif (comparison == "exists") and prop1 ~= nil then
				pass = true
			elseif (comparison == "notexists") and prop1 == nil then
				pass = true
			end

			statementPass = pass
		end
	end

	if statementPass then
		self:customtimeraction(action, arg)
	end
end

function enemy:func(i) -- 0-1 in please
	return (-math.cos(i*math.pi*2)+1)/2
end

function enemy:globalcollide(a, b, c, d, dir)
	if a == "tile" then
		if not self.resistsspikes then
			dir = twistdirection(self.gravitydirection, dir)
			if dir == "ceil" and tilequads[map[b.cox][b.coy][1]]:getproperty("spikesdown", b.cox, b.coy) then
				self:shotted()
				return false
			elseif dir == "right" and tilequads[map[b.cox][b.coy][1]]:getproperty("spikesleft", b.cox, b.coy) then
				self:shotted()
				return false
			elseif dir == "left" and tilequads[map[b.cox][b.coy][1]]:getproperty("spikesright", b.cox, b.coy) then
				self:shotted()
				return false
			elseif dir == "floor" and tilequads[map[b.cox][b.coy][1]]:getproperty("spikesup", b.cox, b.coy) then
				self:shotted()
				return false
			end
		end
	end

	if a == "platform" or a == "seesawplatform" then
		if dir == "floor" then
			if self.jumping and self.speedy < -jumpforce + 0.1 then
				return true
			end
		else
			return true
		end
	end
	
	if a == "player" and self.removeonmariocontact then
		if self.transforms then
			if self:gettransformtrigger("mariocontact") then
				self:transform(self:gettransformsinto("mariocontact"), nil, "death")
			elseif self:gettransformtrigger("death") then
				self:transform(self:gettransformsinto("death"), nil, "death")
				return
			end
		end
		self.kill = true
		self.drawable = false
		return true
	end

	if self.kickable then
		if a == "player" then
			if b.x+b.width/2 > self.x+self.width/2 then
				self:kick("left")
			else
				self:kick("right")
			end
			return true
		end
	end

	if self.meltice and b.meltsice and self.transforms and self:gettransformtrigger("melt") then
		self:transform(self:gettransformsinto("melt"))
	end

	if b.meltice and self.meltsice then
		return true
	end
	

	if self.transforms and (self:gettransformtrigger("globalcollide") or self:gettransformtrigger("collide")) and (not self.justspawned) then
		if self:gettransformtrigger("globalcollide") then
			if self:handlecollisiontransform("globalcollide",a,b) then
				if not self.dotransformaftercollision then
					return true
				end
			end
		else
			if self:handlecollisiontransform("collide",a,b) then
				if not self.dotransformaftercollision then
					return true
				end
			end
		end
	elseif self.transforms and dir == "passive" and self:gettransformtrigger("passivecollide") and (not self.justspawned) then
		if self:handlecollisiontransform("passivecollide",a,b) then
			if not self.dotransformaftercollision then
				return true
			end
		end
	end

	if self.thrown and (not self.dontkillwhenthrown) and not (b.resistsenemykill or b.resistseverything) then
		if a == "enemy" then
			if b:shotted("right", false, false, true) ~= false then
				addpoints(b.firepoints or 200, self.x, self.y)
				if self.throwncollisionignore then
					return true
				end
			end
			if not self.throwncombo then
				self.thrown = false
				self:shotted(self.animationdirection)
			elseif self.throwncombospeedx and self.throwncombospeedy then
				if self.speedx > 0 then
					self.speedx = self.throwncombospeedx
				else
					self.speedx = -self.throwncombospeedx
				end
				self.speedy = self.throwncombospeedy
			end
		elseif fireballkill[a] then
			if b:shotted("right") ~= false and a ~= "bowser" then
				addpoints(firepoints[a] or 200, self.x, self.y)
				if self.throwncollisionignore then
					return true
				end
			end
			if not self.throwncombo then
				self.thrown = false
				self:shotted(self.animationdirection)
			elseif self.throwncombospeedx and self.throwncombospeedy then
				if self.speedx > 0 then
					self.speedx = self.throwncombospeedx
				else
					self.speedx = -self.throwncombospeedx
				end
				self.speedy = self.throwncombospeedy
			end
		end
	end
	
	if self.killsenemies and ((self.killsenemiesonsides and (dir == "left" or dir == "right")) or (self.killsenemiesonbottom and dir == "floor") or (self.killsenemiesontop and dir == "ceil") or
		(self.killsenemiesonleft and dir == "left") or (self.killsenemiesonright and dir == "right") or (self.killsenemiesonpassive and dir == "passive"))
		and a == "enemy" and (not (b.resistsenemykill or b.resistseverything)) and (not b.killsenemies) then
		return true
	end
	
	if a ~= "enemy" then
		if self.freezesenemies then
			if iceballfreeze[a] then
				if b.freezable and (not b.frozen) then
					table.insert(objects["ice"], ice:new(b.x+b.width/2, b.y+b.height, b.width, b.height, a, b))
				end
			end
		end
		if self.killsenemies and ((self.killsenemiesonsides and (dir == "left" or dir == "right")) or (self.killsenemiesonbottom and dir == "floor") or (self.killsenemiesontop and dir == "ceil") or
			(self.killsenemiesonleft and dir == "left") or (self.killsenemiesonright and dir == "right") or (self.killsenemiesonpassive and dir == "passive")) then --AE ADDITION
			if b.shotted and not (b.resistsenemykill or b.resistseverything) then
				local dir = "right"
				if self.speedx < 0 then
					dir = "left"
				end
				
				if b:shotted(dir) ~= false then
					if self.bouncesonenemykill then
						self.speedy = -(self.bounceforce or 10)
					end
					addpoints((firepoints[b.t] or 200), self.x, self.y)
					return true
				end
			end
		end
	end
	
	if a == "fireball" and (self.resistsfire or self.reflectsfireballs) then
		return true
	end
	
	if b.freezesenemies and self.freezable  then
		if (not self.frozen) then
			table.insert(objects["ice"], ice:new(self.x+self.width/2, self.y+self.height, self.width, self.height, "enemy", self))
			return true
		end
	end
	
	if (b.killsenemies and ((b.killsenemiesonsides and (dir == "left" or dir == "right")) or (b.killsenemiesonbottom and dir == "ceil") or (b.killsenemiesontop and dir == "floor") or
	(b.killsenemiesonleft and dir == "right") or (b.killsenemiesonright and dir == "left") or (b.killsenemiesonpassive and dir == "passive"))) and (not (self.resistsenemykill or self.resistseverything)) then
		local dir = "right"
		if b.speedx < 0 then
			dir = "left"
		end
		if b.enemykillsdontflyaway then
			self.doesntflyawayonfireball = true
		end
		if b.small and not b.nocombo then
			if b.combo < #koopacombo then
				b.combo = b.combo + 1
				addpoints(koopacombo[b.combo], self.x, self.y)
			else
				for i = 1, players do
					if mariolivecount ~= false then
						mariolives[i] = mariolives[i]+1
						respawnplayers()
					end
				end
				table.insert(scrollingscores, scrollingscore:new("1up", self.x, self.y))
				playsound(oneupsound)
			end
		else
			addpoints((firepoints[self.t] or 200), self.x, self.y)
		end
		self:shotted(dir)

		if b.bouncesonenemykill then
			b.speedy = -(b.bounceforce or 10)
		end

		if b.enemykillsinstantly then
			self.instantdelete = true
			self:output()
		end
		
		return true
	end
	
	if self.breakblockside == nil or self.breakblockside == "global" then
		self:breakblock(a, b)
	end
	
	if self.nocollidestops or b.nocollidestops then
		return true
	end
end

function enemy:breakblock(a, b)
	if a == "tile" then
		if self.breakshardblocks and (tilequads[map[b.cox][b.coy][1]].coinblock or (tilequads[map[b.cox][b.coy][1]].debris and blockdebrisquads[tilequads[map[b.cox][b.coy][1]].debris])) then -- hard block
			destroyblock(b.cox, b.coy, "nopoints")
		else
			if self.breaksblocks then
				hitblock(b.cox, b.coy, self, true)
			elseif self.hitsblocks then
				hitblock(b.cox, b.coy, self, (self.small and math.abs(self.speedx) > 0.01))
			end
		end
	elseif a == "flipblock" then
		if self.breaksflipblocks or self.breaksentityblocks then
			b:destroy()
		elseif self.hitsflipblocks or self.hitsentityblocks then
			b:hit()
		end
	elseif a == "powblock" then
		if self.triggerspowblock then
			b:hit()
		end
	end
end

function enemy:leftcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d, "left") then
		return false
	end

	if self.ignoreleftcollide or b.ignorerightcollide then --AE ADDITION
		return false
	end
	
	if self.transforms and self:gettransformtrigger("leftcollide") and (not self.justspawned) then
		if self:handlecollisiontransform("leftcollide",a,b) then
			if not self.dotransformaftercollision then
				return
			end
		end
	end

	if a == "player" then --AE ADDITION
		return false
	end

	if self.movement == "crawl" then
		if (a == "tile" or a == "buttonblock" or a == "flipblock" or a == "frozencoin" or (a == "enemy" and b.static)) then
			if self.crawlfloor ~= "left" then
				if self.crawldirection == "left" then
					self.speedy = -self.crawlspeed
				else
					self.speedy = self.crawlspeed
				end
			end
			self.speedx = 0
			self.gravity = 0
			self.gravityx = -(self.crawlgravity or yacceleration)
			self.crawlfloor = "left"
			self.aroundcorner = false
			return true
		elseif self.crawlfloor == "up" or self.crawlfloor == "down" then
			if self.crawldirection == "left" then
				self.crawldirection = "right"
			else
				self.crawldirection = "left"
			end
			self.speedx = self.crawlspeed
			return true
		end
	end
	
	if (not self.frozen) and (self.reflects or self.reflectsx) then
		self.speedx = math.abs(self.speedx)
	end
	
	if self.breakblockside == "sides" or self.breakblockside == "left" then
		self:breakblock(a, b)
	end

	if self.gel then
		if a == "tile" then
			local x, y = b.cox, b.coy
			if (inmap(x+1, y) and tilequads[map[x+1][y][1]].collision) or (inmap(x, y) and tilequads[map[x][y][1]].collision == false) then
				return
			end
			--see if adjsajcjet tile is a better fit
			if math.floor(self.y+self.height/2)+1 ~= y then
				if inmap(x, math.floor(self.y+self.height/2)+1) and tilequads[map[x][math.floor(self.y+self.height/2)+1][1]].collision then
					y = math.floor(self.y+self.height/2)+1
				end
			end
			self:applygel("right", x, y)
		elseif a == "lightbridgebody" and b.dir == "ver" then
			self:applygel("right", b)
		end
	end
	
	if self.movement == "chase" and self.chasebounceforcex then
		self.speedx = self.chasebounceforcex
		if self.speedy == 0 and self.chasebounceforcey then
			self.speedy = -self.chasebounceforcey
		end
		return false
	end
	
	if (not self.frozen) and self.movement == "truffleshuffle" then
		self.speedx = self.truffleshufflespeed
		if not self.dontmirror then
			self.animationdirection = "left"
		end
		return false
	elseif (not self.frozen) and self.small then
		if (a ~= "enemy" and not tablecontains(enemies, a)) or (b.resistsenemykill or b.resistseverything) then
			self.speedx = self.smallspeed
			
			if not self.kickedupsidedown then
				if a == "tile" then
					hitblock(b.cox, b.coy, self, true)
				else
					self:playsound("blockhit")
				end
			end
			return false
		end
	end
end

function enemy:rightcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d, "right") then
		return false
	end

	if self.ignorerightcollide or b.ignoreleftcollide then --AE ADDITION
		return false
	end
	
	if self.transforms and self:gettransformtrigger("rightcollide") and (not self.justspawned) then
		if self:handlecollisiontransform("rightcollide",a,b) then
			if not self.dotransformaftercollision then
				return
			end
		end
	end

	if a == "player" then --AE ADDITION
		return false
	end

	if self.movement == "crawl" then
		if (a == "tile" or a == "buttonblock" or a == "flipblock" or a == "frozencoin" or (a == "enemy" and b.static)) then
			if self.crawlfloor ~= "right" then
				if self.crawldirection == "left" then
					self.speedy = self.crawlspeed
				else
					self.speedy = -self.crawlspeed
				end
			end
			self.speedx = 0
			self.gravity = 0
			self.gravityx = (self.crawlgravity or yacceleration)
			self.crawlfloor = "right"
			self.aroundcorner = false
			return true
		elseif self.crawlfloor == "up" or self.crawlfloor == "down" then
			if self.crawldirection == "right" then
				self.crawldirection = "left"
			else
				self.crawldirection = "right"
			end
			self.speedx = -self.crawlspeed
			return true
		end
	end
	
	if (not self.frozen) and (self.reflects or self.reflectsx) then
		self.speedx = -math.abs(self.speedx)
	end
	
	if self.breakblockside == "sides" or self.breakblockside == "right" then
		self:breakblock(a, b)
	end

	if self.gel then
		if a == "tile" then
			local x, y = b.cox, b.coy
			if (inmap(x-1, y) and tilequads[map[x-1][y][1]].collision) or (inmap(x, y) and tilequads[map[x][y][1]].collision == false) then
				return
			end
			--see if adjsajcjet tile is a better fit
			if math.floor(self.y+self.height/2)+1 ~= y then
				if inmap(x, math.floor(self.y+self.height/2)+1) and tilequads[map[x][math.floor(self.y+self.height/2)+1][1]].collision then
					y = math.floor(self.y+self.height/2)+1
				end
			end
			
			self:applygel("left", x, y)
		elseif a == "lightbridgebody" and b.dir == "ver" then
			self:applygel("left", b)
		end
	end
	
	if self.movement == "chase" and self.chasebounceforcex then
		self.speedx = -self.chasebounceforcex
		if self.speedy == 0 and self.chasebounceforcey then
			self.speedy = -self.chasebounceforcey
		end
		return false
	end

	if (not self.frozen) and self.movement == "truffleshuffle" then
		self.speedx = -self.truffleshufflespeed
		if not self.dontmirror then
			self.animationdirection = "right"
		end
		return false
	elseif (not self.frozen) and self.small then
		if (a ~= "enemy" and not tablecontains(enemies, a)) or (b.resistsenemykill or b.resistseverything) then
			self.speedx = -self.smallspeed
			
			if not self.kickedupsidedown then
				if a == "tile" then
					hitblock(b.cox, b.coy, self, true)
				else
					self:playsound("blockhit")
				end
			end
			return false
		end
	end
end

function enemy:ceilcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d, "ceil") then
		return false
	end

	if self.ignoreceilcollide or b.ignorefloorcollide then --AE ADDITION
		return false
	end

	
	if self.transforms and self:gettransformtrigger("ceilcollide") and (not self.justspawned) then
		if self:handlecollisiontransform("ceilcollide",a,b) then
			if not self.dotransformaftercollision then
				return
			end
		end
	end

	if a == "player" then --AE ADDITION
		return false
	end

	if self.movement == "crawl" then
		if (a == "tile" or a == "buttonblock" or a == "flipblock" or a == "frozencoin" or (a == "enemy" and b.static)) then
			if self.crawlfloor ~= "up" then
				if self.crawldirection == "left" then
					self.speedx = self.crawlspeed
				else
					self.speedx = -self.crawlspeed
				end
			end
			self.speedy = 0
			self.gravity = -(self.crawlgravity or yacceleration)
			self.gravityx = 0
			self.aroundcorner = false
			self.crawlfloor = "up"
			return true
		elseif self.crawlfloor == "left" or self.crawlfloor == "right" then
			if self.crawldirection == "left" then
				self.crawldirection = "right"
			else
				self.crawldirection = "left"
			end
			self.speedy = self.crawlspeed
			return true
		end
	end
	
	if (not self.frozen) and (self.reflects or self.reflectsy) then
		self.speedy = math.abs(self.speedy)
	end
	
	if self.breakblockside == "ceil" then
		self:breakblock(a, b)
	end

	if self.gel then
		if a == "tile" then
			local x, y = b.cox, b.coy
			if not inmap(x, y+1) or tilequads[map[x][y+1][1]].collision == false then
				local x, y = b.cox, b.coy
				self:applygel("bottom", x, y)
			end
		elseif a == "lightbridgebody" and b.dir == "hor" then
			self:applygel("bottom", b)
		end
	end
end

function enemy:floorcollide(a, b, c, d)
	if self:globalcollide(a, b, c, d, "floor") then
		return false
	end

	if self.ignorefloorcollide or b.ignoreceilcollide then --AE ADDITION
		return false
	end

	--Shake Ground --AE ADDITION
	if self.shakesground and (a == "tile") and self.falling and onscreen(self.x, self.y, self.width, self.height) then
		for i = 1, players do
			objects["player"][i]:groundshock()
		end
		earthquake = 4
		self:playsound(thwompsound)
		self.speedy = 0
	end
	
	if self.transforms and self:gettransformtrigger("floorcollide") and (not self.justspawned) then
		if self:handlecollisiontransform("floorcollide",a,b) then
			if not self.dotransformaftercollision then
				return
			end
		end
	end

	if a == "player" then --AE ADDITION
		return false
	end

	if self.movement == "crawl" then
		if (a == "tile" or a == "buttonblock" or a == "flipblock" or a == "frozencoin" or (a == "enemy" and b.static)) then
			if self.crawlfloor ~= "down" then
				if self.crawldirection == "right" then
					self.speedx = self.crawlspeed
				else
					self.speedx = -self.crawlspeed
				end
			end
			self.speedy = 0
			self.gravity = (self.crawlgravity or yacceleration)
			self.gravityx = 0
			self.aroundcorner = false
			self.crawlfloor = "down"
			return true
		elseif self.crawlfloor == "left" or self.crawlfloor == "right" then
			if self.crawldirection == "right" then
				self.crawldirection = "left"
			else
				self.crawldirection = "right"
			end
			self.speedy = -self.crawlspeed
			return true
		end
	end
	
	if (not self.frozen) and (self.reflects or self.reflectsy) then
		self.speedy = -math.abs(self.speedy)
	end
	
	if self.kickedupsidedown then
		self.speedx = 0
		self.kickedupsidedown = false
	end

	if self.thrown then
		if self.thrownbounce then
			self.speedy = -math.abs(self.speedy)*self.thrownbounce
			if self.throwndamping then
				self.speedx = self.speedx*self.throwndamping
			end
		end
		if self.throwntimeendonfloorcollide then
			self.throwntimer = 0
		end
	end

	if self.breakblockside == "floor" then
		self:breakblock(a, b)
	end

	if self.gel then
		if a == "tile" then
			local x, y = b.cox, b.coy
			if (inmap(x, y-1) and tilequads[map[x][y-1][1]].collision) or (inmap(x, y) and tilequads[map[x][y][1]].collision == false) then
				return
			end
			--see if adjsajcjet tile is a better fit
			if math.floor(self.x+self.width/2)+1 ~= x then
				local t = map[x][y][1]
				if inmap(x, y) and tilequads[t].collision and (not (tilequads[t].invisible or tilequads[t].grate)) then
					x = math.floor(self.x+self.width/2)+1
				end
			end
			
			if inmap(x, y) and tilequads[map[x][y][1]].collision then
				if map[x][y]["gels"]["top"] == self.gel or (self.gel == 5 and not map[x][y]["gels"]["top"]) then
					if self.speedx > 0 then
						for cox = x+1, x+self.speedx*0.2 do
							if inmap(cox, y-1) and tilequads[map[cox][y][1]].collision == true and tilequads[map[cox][y-1][1]].collision == false then
								if self:applygel("top", cox, y) then break end
							else break end
						end
					elseif self.speedx < 0 then
						for cox = x-1, x+self.speedx*0.2, -1 do
							if inmap(cox, y-1) and tilequads[map[cox][y][1]].collision and tilequads[map[cox][y-1][1]].collision == false then
								if self:applygel("top", cox, y) then break end
							else break end
						end
					end
				else
					self:applygel("top", x, y)
				end
			end
		elseif a == "lightbridgebody" and b.dir == "hor" then
			self:applygel("top", b)
		end
	end
	
	self.falling = false

	if (not self.frozen) and self.bounces and (not self.bouncedelay) then
		self.speedy = -(self.bounceforce or 10)
		self.falling = true
	end
end

function enemy:passivecollide(a, b, c, d)
	if self:globalcollide(a, b, c, d, "passive") then
		return false
	end

	if a == "player" then --AE ADDITION
		return false
	end
end

function enemy:startfall()
	self.falling = true
end

function enemy:stomp(x, b)
	if self.stompable or (self.shellanimal and self.small) then
		if self.pushmariowhenstomped and b then
			b.y = self.y - b.height-1/16
		end

		if b and b.groundpounding then
			if self.transforms then
				if self:gettransformtrigger("groundpound") then
					self:transform(self:gettransformsinto("groundpound"))
					return
				end
			elseif self.resistsgroundpound then
				return false
			end
		end

		if self.stomphealth then
			if self.stomphealth > 1 then
				self.stomphealth = self.stomphealth - 1
				if self.transforms then
					if self:gettransformtrigger("stompdamage") then
						self:transform(self:gettransformsinto("stompdamage"))
						return
					elseif self:gettransformtrigger("damage") then
						self:transform(self:gettransformsinto("damage"))
						return
					end
				end
				return
			end
		elseif self.health then --AE ADDITION
			if self.health > 1 then
				self.health = self.health - 1
				if self.transforms then
					if self:gettransformtrigger("damage") then
						self:transform(self:gettransformsinto("damage"))
						return
					end
				end
				return
			end
		end
	
		if self.transforms then
			if self:gettransformtrigger("stomp") then
				self:transform(self:gettransformsinto("stomp"), nil, "death")
				return
			elseif self:gettransformtrigger("death") then
				self:transform(self:gettransformsinto("death"), nil, "death")
				return
			end
		end
		
		if self.givecoinwhenstomped then
			collectcoin(nil, nil, tonumber(self.givecoinwhenstomped) or 1)
		end
		
		if self.shellanimal then
			if not self.small then
				self.quadcenterY = self.smallquadcentery or 19--self.startquadcenterY
				self.offsetY = self.smalloffsety or 0--self.startoffsetY
				self.quad = self.quadgroup[self.smallquad]
				self.small = true
				self.trackable = false
				self.movement = self.smallmovement
				self.speedx = 0
				self.animationtype = "none"
			elseif self.speedx == 0 then
				if self.x > x then
					self.speedx = self.smallspeed
					self.x = x+12/16+self.smallspeed*gdt
					if b then
						self.size = b.size
					else
						self.size = 1
					end
					self.killsenemies = true
				else
					self.speedx = -self.smallspeed
					self.x = x-self.width-self.smallspeed*gdt
					if b then
						self.size = b.size
					else
						self.size = 1
					end
					self.killsenemies = true
				end
			else
				self.speedx = 0
				self.combo = 1
				self.quad = self.quadgroup[self.smallquad]
				self.killsenemies = self.startkillsenemies
			end
		else
			self.active = false
			if self.stompanimation then
				self.quad = self.quadgroup[self.stompedframe]
				if self.fallswhenstomped then
					self.shot = true
					self.gravity = shotgravity
				else
					self.dead = true
				end
			elseif self.doesntflyawayonstomp then
				self.kill = true
				self.drawable = false
			else
				self.shot = true
				self.gravity = shotgravity
			end
		end
	end
end

function enemy:autodeleted()
	self.dead = true
	if self.transforms and self:gettransformtrigger("autodeleted") then
		self:transform(self:gettransformsinto("autodeleted"))
	end
	if self.shot then
		self:output()
	else
		self:output("autodeleted")
	end
end

function enemy:output(transformed)
	if (not self) or (not self.outtable) or self.outputted then
		--for some reason the enemy hasn't spawned correctly
		return false
	end
	self.outputted = true
	for i = 1, #self.outtable do
		if self.outtable[i][1].input then
			self.outtable[i][1]:input("toggle", self.outtable[i][2])
		end
	end
	if self.fireballthrower then
		self.fireballthrower:fireballcallback(self.t)
	end
	if self.carryparent then
		self.carryparent.pickup = nil
		self.userect.delete = true
		self.destroying = true
	end
	if self.userect then
		self.userect.delete = true
	end
	if self.blockportaltile and not self.dontremoveblockportaltileondeath then
		blockedportaltiles[self.blockportaltilecoordinate] = false
	end

	if (not transformed) or self.treattransformasdeath then
		--only happen on real deaths
		if self.givecoinondeath then --AE ADDITION
			collectcoin(nil, nil, tonumber(self.givecoinondeath) or 1)
		end
		if self.givekeyondeath then --AE ADDITION
			local closestdist = math.huge
			local closestplayer = 1
			for i = 2, #objects["player"] do
				local v = objects["player"][i]
				local dist = math.sqrt((v.x-self.x)^2+(v.y-self.y)^2)
				if dist < closestdist then
					closestdist = dist
					closestplayer = i
				end
			end
			if objects["player"][closestplayer].key then
				objects["player"][closestplayer].key = objects["player"][closestplayer].key + 1
			else
				objects["player"][closestplayer].key = 1
			end
		end
		if self.deathsound then --AE ADDITION
			self:playsound(self.deathsound)
		end
		if self.droplevelballondeath then
			local obj = levelball:new(self.x+self.width/2, self.y+self.height/2)
			obj.y = self.y+self.height-obj.height-1/16
			table.insert(objects["levelball"], obj)
		end
		if self.animationtriggerondeath or self.triggeranimationondeath then
			self:triggeranimation(self.animationtriggerondeath or self.triggeranimationondeath)
		end
		if self.transformenemyanimationondeath then
			transformenemyanimation(self.transformenemyanimationondeath)
		end
		if self.stopsoundondeath then
			local sound = self.stopsoundondeath
			if self.sound and (sound == self.t or sound == true) then
				self.sound:stop()
			elseif _G[sound .. "sound"] then
				_G[sound .. "sound"]:stop()
			end
		end
	end
end

function enemy:triggeranimation(s)
	if animationtriggerfuncs[s] then
		for i = 1, #animationtriggerfuncs[s] do
			local anim = animationtriggerfuncs[s][i]
			if anim.running and self.queueanimationtrigger then --you ever notice how queue has 4 silent letters?
				table.insert(anim.queue, "enemy")
			else
				anim:trigger()
			end
		end
		animationtriggerfuncs[s].triggered = true
	end
end

function enemy:portaled(exitdir)
	if self.killsenemiesafterportal then
		self.killsenemies = true
	end
	if self.transforms and self:gettransformtrigger("portaled") then
		self:transform(self:gettransformsinto("portaled"))
	end
end

function enemy:spawnenemy(t)
	local speedx, speedy = 0, 0
	if self.spawnenemyspeedx then
		speedx = self.spawnenemyspeedx
	end
	if self.spawnenemyspeedy then
		speedy = self.spawnenemyspeedy
	end
	
	if (self.spawnenemyspeedxrandomstart and self.spawnenemyspeedxrandomend) then
		speedx = math.random()*(self.spawnenemyspeedxrandomend-self.spawnenemyspeedxrandomstart) + self.spawnenemyspeedxrandomstart
	end
	
	if (self.spawnenemyspeedyrandomstart and self.spawnenemyspeedyrandomend) then
		speedy = math.random()*(self.spawnenemyspeedyrandomend-self.spawnenemyspeedyrandomstart) + self.spawnenemyspeedyrandomstart
	end
	
	local closestplayer = 1
	local closestdist = math.sqrt((objects["player"][1].x-self.x)^2+(objects["player"][1].y-self.y)^2)
	for i = 2, players do
		local v = objects["player"][i]
		local dist = math.sqrt((v.x-self.x)^2+(v.y-self.y)^2)
		if dist < closestdist then
			closestdist = dist
			closestplayer = i
		end
	end

	if self.spawnenemytowardsplayer then
		local a = -math.atan2(objects["player"][closestplayer].x-self.x, objects["player"][closestplayer].y-self.y)+math.pi/2
		
		speedx = math.cos(a)*self.spawnenemyspeed
		speedy = math.sin(a)*self.spawnenemyspeed
	end
	
	if self.spawnenemyspeedxtowardsplayer then
		if objects["player"][closestplayer].x + objects["player"][closestplayer].width/2 > self.x + self.width/2 then
			speedx = math.abs(speedx)
		else
			speedx = -math.abs(speedx)
		end
	end
	
	local xoffset = self.spawnenemyoffsetx or 0
	local yoffset = self.spawnenemyoffsety or 0

	local properties
	--set parameters before spawn
	if self.spawnpassedparametersbeforespawn then
		if not properties then properties = {} end
		if self.spawnpassedparameters then --pass parameters
			for i = 1, #self.spawnpassedparameters do
				if self.spawnpassedparameters[i] ~= nil then
					properties[self.spawnpassedparameters[i]] = self[self.spawnpassedparameters[i]]
				end
			end
		end
	end
	if self.spawnsetparametersbeforespawn then
		if not properties then properties = {} end
		if self.spawnsetparameters then --set new parameters
			for i = 1, #self.spawnsetparameters do
				if self.spawnsetparameters[i] ~= nil then
					properties[self.spawnsetparameters[i][1]] = self.spawnsetparameters[i][2]
				end
			end
		end
	end
	
	local temp = enemy:new(self.x+self.width/2+.5+xoffset, self.y+self.height+yoffset, t, {}, properties)
	temp.justspawned = true

	if not self.spawnpassedparametersbeforespawn then
		if self.spawnpassedparameters then --pass parameters
			for i = 1, #self.spawnpassedparameters do
				if self.spawnpassedparameters[i] ~= nil then
					temp[self.spawnpassedparameters[i]] = self[self.spawnpassedparameters[i]]
				end
			end
		end
	end
	if not self.spawnsetparametersbeforespawn then
		if self.spawnsetparameters then --set new parameters
			for i = 1, #self.spawnsetparameters do
				if self.spawnsetparameters[i] ~= nil then
					temp[self.spawnsetparameters[i][1]] = self.spawnsetparameters[i][2]
				end
			end
		end
	end

	table.insert(objects["enemy"], temp)
	
	temp.speedx = speedx
	temp.speedy = speedy
	
	if temp.movement == "truffleshuffle" and temp.speedx > 0 then
		temp.animationdirection = "left"
	end
	
	table.insert(self.spawnedenemies, temp)
	temp.spawner = self
end

function enemy:transform(t, returntransform, death)
	if self.justspawned then
		return false
	end

	if (self.kill or self.transformkill) and self.drawable == false then
		--already transformed!
		return false
	end
	local xoffset = self.transformsoffsetx or 0
	local yoffset = self.transformsoffsety or 0

	if self.transformsintorandoms then
		self.transformsinto = self.transformsintorandoms[math.random(#self.transformsintorandoms)]
		t = self.transformsinto
	end

	local properties
	--set parameters before spawn
	if self.transformpassedparametersbeforespawn then
		if self.transformpassedparameters then
			if not properties then properties = {} end
			for i = 1, #self.transformpassedparameters do
				if self.transformpassedparameters[i] ~= nil then
					properties[self.transformpassedparameters[i]] = self[self.transformpassedparameters[i]]
				end
			end
		end
	end
	if self.transformsetparametersbeforespawn then
		if self.transformsetparameters then --set new parameters
			if not properties then properties = {} end
			for i = 1, #self.transformsetparameters do
				if self.transformsetparameters[i] ~= nil then
					properties[self.transformsetparameters[i][1]] = self.transformsetparameters[i][2]
				end
			end
		end
	end

	local temp = enemy:new(self.x+self.width/2+.5+xoffset, self.y+self.height+yoffset, t, {}, properties)
	temp.justspawned = true
	
	--set parameters after spawn
	if not self.transformpassedparametersbeforespawn then
		if self.transformpassedparameters then
			for i = 1, #self.transformpassedparameters do
				if self.transformpassedparameters[i] ~= nil then
					temp[self.transformpassedparameters[i]] = self[self.transformpassedparameters[i]]
				end
			end
		end
	end
	if not self.transformsetparametersbeforespawn then
		if self.transformsetparameters then --set new parameters
			for i = 1, #self.transformsetparameters do
				if self.transformsetparameters[i] ~= nil then
					temp[self.transformsetparameters[i][1]] = self.transformsetparameters[i][2]
				end
			end
		end
	end

	if self.frozen and (not self.dontpassfrozen) and self.iceblock then --TODO FIX
		self.iceblock.enemy = temp
		temp:freeze("ignoretransform")
		temp.iceblock = self.iceblock
	end

	if self.supersized then
		supersizeentity(temp)
	end
	
	table.insert(objects["enemy"], temp)
	
	if self.spawner then
		table.insert(self.spawner.spawnedenemies, temp)
	end
	
	self.active = false
	self.transformkill = true
	if death then
		self.transformkilldeath = true --still do output death stuff
	end
	if self.tracked or self.clearpipe then
		self.transformedinto = temp
	end
	if self.fireenemyrideaftertransform then --DON'T set this property
		--is mario riding the enemy? should he still ride after enemy transforms?
		local v = self.fireenemyrideaftertransform
		v.fireenemyride = temp
		temp.fireenemyrideaftertransform = self.fireenemyrideaftertransform
		self.fireenemyrideaftertransform = nil
	end
	--self.kill = true
	self.drawable = false

	if returntransform then
		return temp
	end
end
 
function enemy:gettransformtrigger(n) --AE ADDITION
	if not self.transformtrigger then
		return false
	elseif type(self.transformtrigger) == "table" then
		return tablecontainsi(self.transformtrigger, n)
	else
		return (self.transformtrigger == n)
	end
end

function enemy:gettransformsinto(n) --AE ADDITION
	if not self.transformsinto then
		return false
	elseif type(self.transformsinto) == "table" and type(self.transformtrigger) == "table" then
		local i = tablecontainsi(self.transformtrigger, n)
		return self.transformsinto[i]
	else
		return self.transformsinto
	end
end

function enemy:emancipate()
	if not self.kill then
		table.insert(emancipateanimations, emancipateanimation:new(self.x, self.y, self.width, self.height, self.graphic, self.quad, self.speedx, self.speedy, self.rotation, self.offsetX, self.offsetY, self.quadcenterX, self.quadcenterY))
		self.kill = true
		self.drawable = false

		if self.carryparent then
			self.carryparent:cubeemancipate()
		end
	end
end

function enemy:laser(guns, pewpew)
	if not self.laserresistant then
		self:shotted()
	end
end

function enemy:enteredfunnel(inside)
	if inside then
		self.infunnel = true
	else
		self.infunnel = false
		self.gravity = self.startgravity
	end
end

function enemy:getspawnedenemies()
	local count = 0
	for i, v in pairs(self.spawnedenemies) do
		if not v.dead then
			count = count + 1
		end
	end
	
	return count
end

function enemy:dive(water) --AE ADDITION
	if water then
		--self.water = true
		--self.speedx = self.speedx*waterdamping
		self.speedy = self.speedy*(self.waterdamping or waterdamping)
	else
		--self.water = false
		if self.speedy < 0 then
			self.speedy = -waterjumpforce
		end
	end
end

function enemy:used(id)
	if self.thrown or self.frozen then
		return false
	end

	if self.dontcarryifmoving and math.abs(self.speedx) > 0.0001 then
		return false
	end

	if self.transforms and self:gettransformtrigger("carry") then
		local temp = self:transform(self:gettransformsinto("carry"), "returntransform")
		if temp and temp.carryable then
			temp:used(id)
		end
		return false
	end

	self.carryparent = objects["player"][id]
	self.active = self.activeoncarry
	self.startstatic = self.static
	self.static = true
	self.trackable = false
	if self.tracked then
		self.startstatic = false
	end

	if self.fliponcarry then
		self.flipped = true
	end

	objects["player"][id]:pickupbox(self)
	self.pickupready = false

	if self.grabsound then
		self:playsound(self.grabsound)
	elseif not self.nograbsound then
		self:playsound(grabsound)
	end
end

function enemy:dropped(gravitydir)
	self.active = self.activeonthrow
	self.static = self.startstatic
	if self.staticonthrow ~= nil then
		self.static = self.staticonthrow
	end

	if self.noplayercollisiononthrow then
		self.mask[3] = self.mask[1] --no player collision
	end

	self.thrown = true
	if self.throwntime then
		self.throwntimer = self.throwntime or 1.3
	end
	self.speedy = self.thrownspeedy or 0
	if not self.thrownignorecarryspeed then
		if (self.carryparent.portalgun and self.carryparent.pointingangle > 0) or self.carryparent.animationdirection == "left" then --left
			self.speedx = self.carryparent.speedx-(self.thrownspeedx or 0)
		else
			self.speedx = self.carryparent.speedx+(self.thrownspeedx or 0)
		end
	else
		if (self.carryparent.portalgun and self.carryparent.pointingangle > 0) or self.carryparent.animationdirection == "left" then --left
			self.speedx = -(self.thrownspeedx or 0)
		else
			self.speedx = (self.thrownspeedx or 0)
		end
	end

	local offsetx = (self.carryoffsetx or 0)
	if self.carryoffsetx and ((self.carryparent.portalgun and self.carryparent.pointingangle > 0) or self.carryparent.animationdirection == "left") then
		offsetx = -offsetx
	end
	self.x = (self.carryparent.x+self.carryparent.width/2-self.width/2) + offsetx
	self.y = (self.carryparent.y-self.height)+(self.carryoffsety or 0)

	if self.throwsound then
		self:playsound(self.throwsound)
	elseif not self.nothrowsound then
		self:playsound(throwsound)
	end
	self.carryparent = nil
	
	if self.transforms and self:gettransformtrigger("thrown") then
		self:transform(self:gettransformsinto("thrown"))
	end
end

function enemy:freeze(ignoretransform)
	if (not ignoretransform) and self.transforms and self:gettransformtrigger("freeze") then
		self:transform(self:gettransformsinto("freeze"))
		return
	end
	self.frozen = true
	self.speedx = 0
	self.speedy = 0
end

function enemy:kick(dir)
	if not (math.abs(self.speedx) < self.kickspeed*0.8) then
		return false
	end
	if not self.nokicksound then
		self:playsound(shotsound)
	end
	if dir == "left" then
		self.speedx = -self.kickspeed
		if not self.dontmirror then
			self.animationdirection = "right"
		end
	else
		self.speedx = self.kickspeed
		if not self.dontmirror then	
			self.animationdirection = "left"
		end
	end
	self.speedy = self.kickspeedy
end

function enemy:dotrack()
	self.track = true
	if self.transforms and self:gettransformtrigger("tracked") then
		self:transform(self:gettransformsinto("tracked"))
	end
end

function enemy:applygel(side, x, y)
	if x and (not y) then
		local b = x
		local id = b.gels[side]
		if id and id == 5 then
			--can't put gel
			return false
		elseif self.gel == 5 then
			b.gels[side] = nil
		else
			b.gels[side] = self.gel
		end
	else
		local id = map[x][y]["gels"][side]
		if id and id == 5 then
			--can't put gel
			return false
		elseif self.gel == 5 then
			map[x][y]["gels"][side] = false
		else
			map[x][y]["gels"][side] = self.gel
		end
		if id ~= self.gel then
			return true
		end
	end
	return false
end

function enemy:handlecollisiontransform(side,a,b)
	local docancel = false
	if self.transformtriggerenemycollide then
		--mutliple enemy collides
		if type(self.transformtriggerenemycollide) == "table" and type(self.transformtrigger) == "table" then
			for i, s in pairs(self.transformtrigger) do
				if s == side and a == "enemy" and self.transformtriggerenemycollide[i] == b.t then
					if type(self.transformsinto) == "table" then
						self:transform(self.transformsinto[i])
					else
						self:transform(self:gettransformsinto(side))
					end
					if self.transformtriggerenemycollidekill then
						if self.enemykillsdontflyaway then
							b.doesntflyawayonfireball = true
						end
						b:shotted(dir)
					end
					return true
				end
			end
		else
			if a == "enemy" and b.t == self.transformtriggerenemycollide then
				self:transform(self:gettransformsinto(side))
				if self.transformtriggerenemycollidekill then
					if self.enemykillsdontflyaway then
						b.doesntflyawayonfireball = true
					end
					b:shotted(dir)
				end
				return true
			end
		end
		docancel = true
	end

	if self.transformtriggerobjectcollide then
		--mutliple entity collides
		if type(self.transformtriggerobjectcollide) == "table" and type(self.transformtrigger) == "table" then
			for i, s in pairs(self.transformtrigger) do
				if s == side and self.transformtriggerobjectcollide[i] == a then
					if type(self.transformsinto) == "table" then
						self:transform(self.transformsinto[i])
					else
						self:transform(self:gettransformsinto(side))
					end
					return true
				end
			end
		else
			if a == self.transformtriggerobjectcollide then
				self:transform(self:gettransformsinto(side))
				return true
			end
		end
		docancel = true
	end
	if docancel then
		return false
	end
	self:transform(self:gettransformsinto(side))
	return true
end

function enemy:dosupersize()
	--set a custom set of properties when supersized
	if self.supersizeproperties then
		for i, v in pairs(self.supersizeproperties) do
			local name = i
			if (not self.casesensitive) or (name ~= "offsetX" and name ~= "offsetY" and name ~= "quadcenterX" and name ~= "quadcenterY") then
				name = name:lower()
			end
			self[name] = v
			if name == "quadno" then
				self.quad = self.quadgroup[self.quadno]
			end
		end
	end
end

function enemy:playsound(sound)
	if (not self.dontplaysoundsoffscreen) or onscreen(self.x, self.y, self.width, self.height) then
		if self.sound and sound == self.t then
			playsound(self.sound)
		else
			playsound(sound)
		end
	end
end
