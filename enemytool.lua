enemytool = class:new()

function enemytool:init(x, y, r, e)
	self.cox = x
	self.coy = y
	self.x = x-1
	self.y = y-1
	self.r = r
	self.customenemy = true
	self.animation = false
	self.spawnonlyonscreen = false
	if e:find("|") then
		local v = convertr(e, {"string", "num", "num", "bool", "string", "bool"}, true)
		self.enemy = v[1]
		self.xvel = v[2]
		self.yvel = v[3]
		if v[4] == nil then
			self.legacy = true
			if tablecontains(customenemies, self.enemy) then
				self.customenemy = true
			else
				self.customenemy = false
			end
		else
			self.customenemy = v[4]
		end
		if v[5] and v[5] ~= "none" then
			self.animation = v[5]
		end
		if v[6] ~= nil then
			self.spawnonlyonscreen = v[6]
		end
	else
		self.enemy = e or "goomba"
		self.legacy = true
		self.xvel = 0
		self.yvel = 0
	end
	self:translateenemy()
	self.drawable = false
	
	self.linked = false
	self.pass = false
	self.outtable = {}
	self.timer = 0
	if self.animation == "cannon" then
		self.time = math.random(bulletbilltimemin*10, bulletbilltimemax*10)/10
	elseif self.animation == "pipeup" or self.animation == "pipedown" or self.animation == "pipeleft" or self.animation == "piperight" then
		self.pipe = true
		self.spawned = {}
		self.spawnmax = math.huge
		self.timer = pipespawndelay/2
	end

	--is it supersized?
	if ismaptile(x, y) and map[x][y]["argument"] then
		if map[x][y]["argument"] == "b" then --supersized
			self:dosupersize()
			self.supersized = 2
		end
	end
end

function enemytool:update(dt)
	if (not self.linked) and onscreen(self.x-2, self.y-2, 4, 4) then
		--automatic spawning
		if self.pipe then
			local cx, cy, cw, ch = self.x, self.y, 2, 1
			if self.animation == "pipeleft" or self.animation == "piperight" then
				cx, cy, cw, ch = self.x, self.y-1, 1, 2
			end
			if #self.spawned > 0 then
				--only have one object spawned
				local delete = {}
				for i, v in pairs(self.spawned) do
					if v.delete then
						table.insert(delete, i)
					end
				end
				table.sort(delete, function(a,b) return a>b end)
				for i, v in pairs(delete) do
					table.remove(self.spawned, v) --remove
				end
			end
			if #self.spawned < self.spawnmax then
				local col = checkrect(cx, cy, cw, ch, {"player"}, nil)
				if #col == 0 then
					self.timer = self.timer + dt
					while self.timer > pipespawndelay do
						self:spawn()
						self.timer = self.timer - pipespawndelay
					end
				end
			end
		elseif self.animation == "cannon" then
			local cx, cy, cw, ch = self.x-1, self.y-6, 3, 12
			local col = checkrect(cx, cy, cw, ch, {"player"}, nil)
			if #col == 0 then
				self.timer = self.timer + dt
				while self.timer > self.time do
					self:spawn()
					self.timer = self.timer - pipespawndelay
					self.time = math.random(bulletbilltimemin*10, bulletbilltimemax*10)/10
				end
			end
		end
	end
end

function enemytool:link()
	if #self.r > 3 then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[5]) == v.cox and tonumber(self.r[6]) == v.coy then
					v:addoutput(self)
					self.linked = true
				end
			end
		end
	end
end

function enemytool:input(t)
	if t == "on" then
		if not self.pass then
			self:spawn()
			self.pass = true
		end
	elseif t == "off" then
		self.pass = false
	elseif t == "toggle" then
		self:spawn()
	end
end

function enemytool:spawn()
	local i = self.enemy
	local x = self.cox
	local y = self.coy
	local dir = "left"
	if self.xvel > 0 then
		dir = "right"
	end
	--if objects["player"][1].x < self.cox then
	--	dir = "left"
	--end
	
	if i == nil then
		return false
	end
	if self.spawnonlyonscreen and not onscreen(self.x-2, self.y-2, 4, 4) then
		return false
	end

	--spawn the enemy
	local obj, wasenemy, objtable
	local spawnstufftable = {
		["groundmole"] = function()
			obj = mole:new(x-0.5, y-1/16)
			table.insert(objects["mole"], obj)
		end,
		["ground mole"] = self["groundmole"],
		["mole"]  = function()
			obj = mole:new(x-0.5, y-1/16)
			table.insert(objects["mole"], obj)
			obj.width = 12/16
			obj.height = 12/16
			obj.quad = molequad[spriteset][3]
			obj.gravity = yacceleration
			obj.mask = {	true, 
						false, false, false, false, true,
						false, true, false, true, false,
						false, false, true, false, false,
						true, true, false, false, false,
						false, true, true, false, false,
						true, false, true, true, true}
			obj.inground = false
		end,
		["monty mole"] = self["mole"],
		["bowser"]  = function()
			obj = bowser:new(x-4, y-1/16)
			table.insert(objects["bowser"], obj)
		end,
		["bowserfire"]  = function()
			obj = fire:new(x,y)
			table.insert(objects["fire"], obj)
		end,
		["bulletbillsingle"]  = function()
			obj = bulletbill:new(x, y, dir)
			table.insert(objects["bulletbill"], obj)
		end,
		["bulletbill"] = self["billsingle"],
		["bullet bill"] = self["billsingle"],
		["bulletbill right"]  = function()
			table.insert(objects["bulletbill"], bulletbill:new(x, y, "right"))
		end,
		["bulletbill left"]  = function()
			table.insert(objects["bulletbill"], bulletbill:new(x, y, "left"))
		end,
		["bigbillsingle"]  = function()
			obj = bigbill:new(x, y, dir)
			table.insert(objects["bigbill"], obj)
		end,
		["bigbill"] = self["billsingle"],
		["banzai bill"] = self["billsingle"],
		["banzai bill left"]  = function()
			table.insert(objects["bigbill"], bigbill:new(x, y, "left"))
		end,
		["bigbillleft"] = self["banzai bill left"],
		["big bill left"] = self["banzai bill left"],
		["bigbill left"] = self["banzai bill left"],
		["banzai bill right"]  = function()
			table.insert(objects["bigbill"], bigbill:new(x, y, "right"))
		end,
		["bigbillright"] = self["banzai bill right"],
		["big bill right"] = self["banzai bill right"],
		["bigbill right"] = self["banzai bill right"],
		["kingbill"]  = function()
			table.insert(objects["kingbill"], kingbill:new(xscroll-200/16, y))
		end,
		["king bill"] = self["kingbill"],
		["cannonball"]  = function()
			table.insert(objects["cannonball"], cannonball:new(x, y, "left"))
		end,
		["cannonball single"] = self["cannonball"],
		["cannon ball"] = self["cannonball"],
		["hammer"]  = function()
			if dir == "left" then
				obj = hammer:new(x-1-5/16, y, "left")
			else
				obj = hammer:new(x, y, "right")
			end
			table.insert(objects["hammer"], obj)
		end,
		["brofireball"]  = function()
			obj = brofireball:new(x-1, y-1, dir)
			table.insert(objects["brofireball"], obj)
		end,
		["broboomerang"]  = function()
			obj = boomerang:new(x-1, y-1, dir)
			table.insert(objects["boomerang"], obj)
		end,
		["broiceball"]  = function()
			obj = brofireball:new(x-1, y-1, dir, "ice")
			table.insert(objects["brofireball"], obj)
		end,
		["flyingfish"]  = function()
			obj = flyingfish:new()
			table.insert(objects["flyingfish"], obj)
		end,
		["jumping fish"] = self["flyingfish"],
		["meteor"]  = function()
			obj = meteor:new()
			table.insert(objects["meteor"], obj)
		end,
		["turretleft"]  = function()
			table.insert(objects["turret"], turret:new(x, y, "left"))
		end,
		["turret left"] = self["turretleft"],
		["turretright"]  = function()
			table.insert(objects["turret"], turret:new(x, y, "right"))
		end,
		["turret"] = self["turretright"],
		["turret right"] = self["turretright"],
		["turret2left"]  = function()
			table.insert(objects["turret"], turret:new(x, y, "left", "turret2"))
		end,
		["defective turret left"] = self["turret2left"],
		["turret2right"]  = function()
			table.insert(objects["turret"], turret:new(x, y, "right", "turret2"))
		end,
		["defective turret"] = self["turret2right"],
		["spring"]  = function()
			table.insert(objects["spring"], spring:new(x, y, nil))
		end,
		["moving spring"]  = function()
			table.insert(objects["spring"], spring:new(x, y, nil, true))
		end,
		["greenspring"]  = function()
			table.insert(objects["spring"], spring:new(x, y, "green"))
		end,
		["spring green"] = self["springgreen"],
		["moving greenspring"]  = function()
			table.insert(objects["spring"], spring:new(x, y, "green", true))
		end,
		["moving green spring"] = self["moving greenspring"],
		["spike snow"]  = function()
			obj = spike:new(x-0.5, y-1/16, "snow")
			table.insert(objects["spike"], obj)
		end,
		["snowball"]  = function()
			obj = spikeball:new(x-0.5, y, "snow", "left", true)
			table.insert(objects["spikeball"], obj)
		end,
		["koopaling"]  = function()
			table.insert(objects["koopaling"], koopaling:new(x-0.5, y-1/16, 1))
		end,
		["koopaling2"]  = function()
			table.insert(objects["koopaling"], koopaling:new(x-0.5, y-1/16, 2))
		end,
		["koopaling3"]  = function()
			table.insert(objects["koopaling"], koopaling:new(x-0.5, y-1/16, 3))
		end,
		["koopaling4"]  = function()
			table.insert(objects["koopaling"], koopaling:new(x-0.5, y-1/16, 4))
		end,
		["koopaling5"]  = function()
			table.insert(objects["koopaling"], koopaling:new(x-0.5, y-1/16, 5))
		end,
		["koopaling6"]  = function()
			table.insert(objects["koopaling"], koopaling:new(x-0.5, y-1/16, 6))
		end,
		["koopaling7"]  = function()
			table.insert(objects["koopaling"], koopaling:new(x-0.5, y-1/16, 7))
		end,
		["box"]  = function() --change to enemy? (be wary of region triggers)
			obj = box:new(x, y)
			table.insert(objects["box"], obj)
		end,
		["box2"]  = function()
			obj = box:new(x, y, "box2")
			table.insert(objects["box"], obj)
		end,
		["edgelessbox"]  = function()
			obj = box:new(x, y, "edgeless")
			table.insert(objects["box"], obj)
		end,
		["coin"]  = function()
			if self.animation then
				obj = tilemoving:new(x, y, 116)
				table.insert(objects["tilemoving"], obj)
			else
				objects["coin"][tilemap(x, y)] = coin:new(x, y)
			end
		end,
		["spikeyfall"]  = function()
			obj = goomba:new(self.x+6/16, self.y, "spikeyfall")
			table.insert(objects["goomba"], obj)
		end,
		["gel1"]  = function()
			obj = gel:new(self.x+1, self.y+1, 1)
			table.insert(objects["gel"], obj)
		end,
		["gel2"]  = function()
			obj = gel:new(self.x+1, self.y+1, 2)
			table.insert(objects["gel"], obj)
		end,
		["gel3"]  = function()
			obj = gel:new(self.x+1, self.y+1, 3)
			table.insert(objects["gel"], obj)
		end,
		["gel4"]  = function()
			obj = gel:new(self.x+1, self.y+1, 4)
			table.insert(objects["gel"], obj)
		end,
		["gelcleanse"]  = function()
			obj = gel:new(self.x+1, self.y+1, 5)
			table.insert(objects["gel"], obj)
		end
	}
	if self.customenemy and tablecontains(customenemies, i) then
		obj = enemy:new(x, y, i)
		--turn in the right direction
		if obj and self.animation == "piperight" and (not obj.dontmirror) then
			obj.animationdirection = "left"
		elseif obj and self.animation == "pipeleft" and (not obj.dontmirror) then
			obj.animationdirection = "right"
		end
		table.insert(objects["enemy"], obj)
	elseif spawnstufftable[i] then
		spawnstufftable[i]()
	else
		obj, wasenemy, objtable = spawnenemy(i, x, y, false, "spawner")
		--turn in the right direction
		if obj and dir == "right" and obj.animationdirection then
			if obj.animationdirection == "right" then
				obj.animationdirection = "left"
			else
				obj.animationdirection = "right"
			end
		end
	end

	if obj then
		if self.supersized and (not self.customenemy) then
			for n, t in pairs(entitylist) do
				if i == t.t and t.supersize then --is the enemy supersizable?
					supersizeentity(obj)
				end
			end
		end

		if obj.speedx then
			if self.animation == "cannon" and self.xvel == 0 then
				--default cannon
				local pl = 1
				for i = 2, players do
					if math.abs(objects["player"][i].x+objects["player"][i].width/2 - (self.cox-.5)) 
						< math.abs(objects["player"][pl].x+objects["player"][pl].width/2 - (self.cox-.5)) then
						pl = i
					end
				end
				if objects["player"][pl].x+objects["player"][pl].width/2 > (self.cox-.5) then
					obj.speedx = obj.speedx+bulletbillspeed
				else
					obj.speedx = obj.speedx-bulletbillspeed
				end
				obj.speedy = obj.speedy+self.yvel
			else
				obj.speedx = obj.speedx+self.xvel
				obj.speedy = obj.speedy+self.yvel
			end
		end

		if self.pipe and obj.pipespawnmax then
			self.spawnmax = obj.pipespawnmax
			table.insert(self.spawned, obj)
		end

		if self.animation == "poof" then
			makepoof(obj.x+obj.width/2, obj.y+obj.height/2, "powpoof")
		elseif self.animation then
			if obj.width and obj.height and (not obj.children) and (not obj.child) and not (obj.nospawnanimation) then
				table.insert(spawnanimations, spawnanimation:new(self.cox, self.coy, self.animation, obj))
			end
		else
			--track
			if objtable and obj.width and obj.height then
				trackobject(self.cox, self.coy, obj, objtable)
			end
		end
	end
end

function enemytool:translateenemy()
	--backwards compatibility fuck
	if (not self.customenemy) and self.legacy then
		local compatable = { --haha get it
			["red koopa"] = "koopared",
			["buzzy beetle"] = "beetle",
			["flying koopa"] = "koopaflying",
			["cheep cheep"] = "cheepred",
			["white cheep"] = "cheepwhite",
			["spiny"] = "spikey",
			["spiny shell"] = "spikeyshell",
			["lakitu"] = "lakito",
			["blooper"] = "squid",
			["crab"] = "sidestepper",
			["bigicicle"] = "iciclebig",
			["angry sun"] = "angrysun",
			["sun"] = "angrysun",
			["pumpkin"] = "splunkin",
			["big goomba"] = "biggoomba",
			["big spikey"] = "bigspikey",
			["big koopa"] = "bigkoopa",
			["dry bones"] = "drybones",
			["big beetle"] = "bigbeetle",
			["dry goomba"] = "drygoomba",
			["bob omb"] = "bomb",
			["boom boom"] = "boomboom",
			["? ball"] = "levelball",
			["blue koopa"] = "koopablue",
			["flying koopa 2"] = "koopaflying2",
			["pink squid"] = "pinksquid",
			["rip van fish"] = "sleepfish",
			["shy guy"] = "shyguy",
			["hammer bro"] = "hammerbro",
			["boomerang bro"] = "boomerangbro",
			["fire bro"] = "firebro",
			["down plant"] = "downplant",
			["venus firetrap"] = "fireplant",
			["torpedo ted"] = "torpedolauncher",
			["podoboo"] = "upfire",
			["dk hammer"] = "dkhammer",
			["bony beetle"] = "drybeetle",
			["beetle shell"] = "beetleshell",
			["smb3 bowser"] = "bowser3"
		}
		self.enemy = compatable[self.enemy] or self.enemy
	end
end

function enemytool:dosupersize()

end
