mario = class:new()

function mario:init(x, y, i, animation, size, t, properties)
	self.playernumber = i or 1
	if bigmario then
		self.size = 1
	elseif size and size == 8 then
		self.size = 1
	else
		self.size = size or 1
	end
	self.t = t or "portal"
	
	--custom character
	self.character = mariocharacter[self.playernumber]
	self.characterdata = characters.data[mariocharacter[self.playernumber]]
	
	--PHYSICS STUFF
	self.speedx = 0
	self.speedy = 0
	self.x = x
	self.width = 12/16
	self.height = 12/16
	self.portalgun = portalgun
	if self.characterdata.noportalgun then
		self.portalgun = false
		self.t = "classic"
	elseif playertype == "classic" or playertype == "cappy" then
		self.portalgun = false; portalguni = 2; portalgun = false
	end
	if self.portalgun then
		if portalguni == 3 then
			self.portals = "1 only"
		elseif portalguni == 4 then
			self.portals = "2 only"
		elseif portalguni == 5 then
			self.portals = "gel"
		else
			self.portals = "both"
		end
	else
		self.portals = "none"
	end
	self:updateportalsavailable()
	
	self.gravitydir = "down"
	
	if bigmario then
		self.width = self.width*scalefactor
		self.height = self.height*scalefactor
	end
	
	self.y = y+1-self.height
	self.static = false
	self.active = true
	self.category = 3
	self.mask = {	true, 
					false, true, false, false, false,
					false, true, false, false, false,
					false, true, false, false, false,
					false, false, false, false, false,
					false, false, false, false, false,
					false, false, false, false, false,
					false, true}
					
	if playercollisions then
		self.mask[3] = false
	end
	if edgewrapping then
		self.mask[10] = true
	end
	
	self.emancipatecheck = true
	
	--IMAGE STUFF
	self.smallgraphic = {}
	if self.character and self.characterdata["animations"] then
		for j = 0, #self.characterdata["animations"] do
			self.smallgraphic[j] = self.characterdata["animations"][j]
		end
	end
	
	self.biggraphic = {}
	if self.character and self.characterdata["biganimations"] then
		for j = 0, #self.characterdata["biganimations"] do
			self.biggraphic[j] = self.characterdata["biganimations"][j]
		end
	end

	if self.characterdata["fireanimations"] then
		self.firegraphic = {}
		for j = 0, #self.characterdata["fireanimations"] do
			self.firegraphic[j] = self.characterdata["fireanimations"][j]
		end
	end
	if self.characterdata["iceanimations"] then
		self.icegraphic = {}
		for j = 0, #self.characterdata["iceanimations"] do
			self.icegraphic[j] = self.characterdata["iceanimations"][j]
		end
	end
	if self.characterdata["superballanimations"] then
		self.superballgraphic = {}
		for j = 0, #self.characterdata["superballanimations"] do
			self.superballgraphic[j] = self.characterdata["superballanimations"][j]
		end
	end
	
	self.hammergraphic = {}
	if self.character and self.characterdata["hammeranimations"] then
		for j = 0, #self.characterdata["hammeranimations"] do
			self.hammergraphic[j] = self.characterdata["hammeranimations"][j]
		end
	end
	
	self.froggraphic = {}
	if self.character and self.characterdata["froganimations"] then
		for j = 0, #self.characterdata["froganimations"] do
			self.froggraphic[j] = self.characterdata["froganimations"][j]
		end
	end
	
	self.raccoongraphic = {}
	if self.character and self.characterdata["raccoonanimations"] then
		for j = 0, #self.characterdata["raccoonanimations"] do
			self.raccoongraphic[j] = self.characterdata["raccoonanimations"][j]
		end
	end
	
	self.tinygraphic = {}
	if self.character and self.characterdata["tinyanimations"] then
		for j = 0, #self.characterdata["tinyanimations"] do
			self.tinygraphic[j] = self.characterdata["tinyanimations"][j]
		end
	end
	
	self.tanookigraphic = {}
	if self.character and self.characterdata["tanookianimations"] then
		for j = 0, #self.characterdata["tanookianimations"] do
			self.tanookigraphic[j] = self.characterdata["tanookianimations"][j]
		end
	end
	
	self.skinnygraphic = {}
	if self.character and self.characterdata["skinnyanimations"] then
		for j = 0, #self.characterdata["skinnyanimations"] do
			self.skinnygraphic[j] = self.characterdata["skinnyanimations"][j]
		end
	end

	self.capegraphic = {}
	if self.character and self.characterdata["capeanimations"] then
		for j = 0, #self.characterdata["capeanimations"] do
			self.capegraphic[j] = self.characterdata["capeanimations"][j]
		end
	end

	self.shellgraphic = {}
	if self.character and self.characterdata["shellanimations"] then
		for j = 0, #self.characterdata["shellanimations"] do
			self.shellgraphic[j] = self.characterdata["shellanimations"][j]
		end
	end

	self.boomeranggraphic = {}
	if self.character and self.characterdata["boomeranganimations"] then
		for j = 0, #self.characterdata["boomeranganimations"] do
			self.boomeranggraphic[j] = self.characterdata["boomeranganimations"][j]
		end
	end
	
	self.drawable = true
	self.quad = self.characterdata["small"]["idle"][3]
	self.quadanim = "idle"
	self.quadframe = 3
	if self.characterdata.defaultsize then
		self.size = self.characterdata.defaultsize
	end
	self:setsize(self.size)
	
	if bigmario then
		self.offsetX = self.offsetX*scalefactor
		self.offsetY = self.offsetY*-scalefactor
	end
	
	--hat
	self.hats = mariohats[self.playernumber]
	self.drawhat = true
	
	--Change height according to hats
	
	--for i = 1, #self.hats do
		--self.height = self.height + (hat[self.hats[i]].height/16)
		--self.y = self.y - (hat[self.hats[i]].height/16)
		--self.offsetY = self.offsetY - hat[self.hats[i]].height
	--end
	
	self.customscissor = nil
	
	if (players == 1 and (not CustomPortalColors)) or self.playernumber > 4 then
		self.portal1color = {60, 188, 252}
		self.portal2color = {232, 130, 30}
	else
		self.portal1color = portalcolor[self.playernumber][1]
		self.portal2color = portalcolor[self.playernumber][2]
	end
	
	--OTHER STUFF!
	self.controlsenabled = true
	
	self.idleframe = 1
	self.idleanimationprogress = 1
	self.runframe = math.min(self.characterdata.runframes, 3)
	self.jumpframe = 1
	self.jumpanimationprogress = 1
	self.fallframe = 1
	self.fallanimationprogress = 1
	self.swimframe = 1
	self.swimpush = false
	self.climbframe = 1
	self.fenceframe = 1
	self.fenceanimationprogress = 1
	self.fencejumptimer = 0
	self.floatframe = 1
	self.spinframez = 1
	self.raccoonflyframe = 1
	self.runanimationprogress = 1
	self.runframes = self.characterdata.runframes--4
	self.swimanimationprogress = 1
	self.floatanimationprogress = 1
	self.spinanimationprogress = 1
	self.raccoonflyanimationprogress = 1
	self.animationstate = "idle" --idle, running, jumping, falling, swimming, sliding, climbing, dead
	self.animationdirection = "right" --left, right. duh
	self.combo = 1
	if not portals[self.playernumber] then
		portals[self.playernumber] = portal:new(self.playernumber, self.portal1color, self.portal2color)
	end
	self.portal = portals[self.playernumber]
	self.rotation = 0 --for portals
	self.portaldotstimer = 0
	self.pointingangle = -math.pi/2
	self.passivemoved = false
	self.ducking = false
	self.invincible = false
	self.rainboomallowed = true
	self.water = underwater
	self.yoshi = false
	self.yoshiquad = false
	self.yoshitounge = false
	self.yoshitoungewidth = 0
	self.yoshitoungespeed = yoshitoungespeed
	self.yoshitoungeenemy = false
	self.swimwing = false
	self.dkhammer = false
	self.dkhammeranim = 0
	self.dkhammerframe = 1
	self.groundfreeze = false
	self.noteblock = false
	self.noteblock2 = false
	self.ice = false
	self.shoe = false --goombashoe
	self.helmet = false
	self.helmetanimtimer = 1
	self.propellerjumping = false
	self.propellerjumped = false
	self.propellertime = 0
	self.cannontimer = 0
	self.blueshelled = false
	self.blueshellframe = 1
	self.blueshellanimationprogress = 1
	self.statue = false
	self.statuetimer = false
	self.capeframe = 1
	self.capeanim = 0
	self.capefly = false
	self.capeflyframe = 1
	self.capeflyanim = 0
	self.capeflybounce = false
	self.weight = 1
	self.mariolevel = mariolevel --level where mario is from
	self.groundpounding = false
	self.groundpoundcanceled = false
	
	self.animation = animation --pipedown, piperight, pipeupexit, pipeleft, flag, vine, intermission, pipeup, pipedownexit
	self.animationx = nil
	self.animationy = nil
	self.animationtimer = 0
	
	self.falling = false
	self.jumping = false
	self.starred = false
	self.dead = false
	self.vine = false
	self.fence = false
	self.spring = false
	self.springgreen = false
	self.startimer = mariostarduration
	self.starblinktimer = mariostarblinkrate
	self.starcolori = 1
	self.fireballcount = 0
	self.fireenemycount = {}
	self.fireanimationtimer = fireanimationtime
	self.spinanimationtimer = raccoonspintime
	
	--turrets
	self.hitpoints = maxhitpoints
	self.hitpointtimer = 0
	self.hitpointsdelay = 0

	--health
	self.health = self.characterdata.health
	
	--RACCOON STUFF
	self.float = false
	self.floattimer = 0
	self.ignoregravity = false
	self.planemode = false
	self.planetimer = 0
	self.playraccoonplanesound = true
	self.raccoonflyingtimer = 0
	self.raccoonfly = false
	
	--CAPPY
	if playertype == "cappy" then
		self.cappy = cappy:new(self)
		table.insert(objects["cappy"], self.cappy)
	end
	
	--LOOK UP/DOWN
	self.upkeytimer = 0
	self.downkeytimer = 0
	
	self.mazevar = 0

	self.light  = 3.5
	
	self.bubbletimer = 0
	self.bubbletime = bubblestime[math.random(#bubblestime)]
	
	if self.water then
		self.gravity = self.characterdata.uwgravity
	elseif currentphysics == 2 or currentphysics == 4 or currentphysics == 6 then --fall slow at start
		self.speedy = 0
		self.gravity = self.characterdata.yaccelerationjumping
	end
	
	self.controlsoverwrite = {}
	
	if self.animation == "intermission" and editormode then
		self.animation = nil
	end
	
	if mariolivecount ~= false and type(mariolives[self.playernumber]) == "number" and mariolives[self.playernumber] <= 0 then
		self.dead = true
		self.drawable = false
		self.active = false
		self.static = true
		self.controlsenabled = false
		self.animation = nil
	end
	
	if self.animation and self.animation:find("pipe") then
		local p = exitpipes[tilemap(pipestartx,pipestarty)]
		local dir = p.dir
		self.controlsenabled = false
		self.active = false
		self.drawable = false
		self.animationx = pipestartx
		self.animationy = pipestarty
		self.customscissor = p.scissor[dir]
		if dir == "up" then
			self.x = p.x-self.width/2
			self.animationstate = "idle"
		elseif dir == "down" then
			self.x = p.x-self.width/2
			self.animationstate = "idle"
		elseif dir == "left" then
			self.y = p.y-self.height
			self.animationstate = "running"
			self.pointingangle = math.pi/2
		elseif dir == "right" then
			self.y = p.y-self.height
			self.animationstate = "running"
			self.pointingangle = -math.pi/2
		end
		self:setquad()
	elseif self.animation == "intermission" then
		self.controlsenabled = false
		self.active = true
		self.gravity = self.characterdata.yacceleration
		self.animationstate = "running"
		self.speedx = 2.61
		self.pointingangle = -math.pi/2
	elseif self.animation == "vinestart" then
		self.controlsenabled = false
		self.active = false
		self.pointingangle = -math.pi/2
		self.animationdirection = "right"
		self.climbframe = 2
		self.animationstate = "climbing"
		self:setquad()
		self.x = 4-3/16
		self.y = mapheight+0.4*(self.playernumber-1)
		self.vineanimationclimb = false
		self.vineanimationdropoff = false
		self.vinemovetimer = 0
		playsound(vinesound)
		
		if #objects["vine"] == 0 then
			table.insert(objects["vine"], vine:new(5, mapheight+1, "start"))
		end
	end
	
	if properties and (not editormode) then
		--stay shoed
		if properties.shoe and properties.shoe ~= "cloud" then
			if type(properties.shoe) == "table" and properties.shoe[1] == "yoshi" then
				local obj = yoshi:new(self.x, self.y, properties.shoe[2])
				obj:ride(self)
				self.yoshi = obj
				table.insert(objects["yoshi"], obj)
				self:shoed("yoshi", true)
			else
				self:shoed(properties.shoe, true)
			end
		end
		--keep helmet
		if properties.helmet then
			self:helmeted(properties.helmet)
		end
		--keep keys (only if in the same level)
		if properties.key and properties.mariolevel then
			if mariolevel == properties.mariolevel then --only keep keys in the same level
				self.key = properties.key
			end
		end
		--custom powerup
		if properties.fireenemy then
			self.fireenemy = properties.fireenemy
			self.basecolors = properties.customcolors
			self.colors = self.basecolors
			self.customcolors = false
		end
		--health
		if properties.health and self.characterdata.health then
			self.health = properties.health
		end
	end

	if self.characterdata.spawnenemy then
		local obj = enemy:new(self.x+self.width/2, self.y+self.height/2, self.characterdata.spawnenemy)
		obj.parent = self
		table.insert(objects["enemy"], obj)
	end
	
	self:setquad()
end

function mario:update(dt)
	--RACCOON STUFF
	if self.float and not self.raccoonfly then
		if self.gravitydir == "up" then
			self.speedy = -3
		else
			self.speedy = 3
		end
		self.ignoregravity = true
		self.animationstate = "floating"
		self:setquad()
		self.floattimer = self.floattimer + dt
		if (self.size == 11 and self.floattimer > 0.3) or (self.size ~= 11 and self.floattimer > 0.25) then
			self.floattimer = 0
			self.float = false
			self.ignoregravity = false
		end
	end
	if (self.size == 6 or self.size == 9 or self.size == 10) and self.animationstate == "running" then --be able to fly when runing for whatever seconds
		if (self.animationdirection == "left" and self.speedx < -8.8) or (self.animationdirection == "right" and self.speedx > 8.9) then
			self.planetimer = self.planetimer + 1*dt
			if self.planetimer > 1.1 then
				if self.playraccoonplanesound and self.size ~= 10 then
					playsound(raccoonplanesound)
					self.playraccoonplanesound = false
				end
				self.planemode = true
			end
		end
	else
		if self.animationstate ~= "jumping" and self.raccoonfly == false then
			raccoonplanesound:stop()
			self.planemode = false
		end
		self.playraccoonplanesound = true
		self.planetimer = 0
	end
	
	if self.raccoonfly then
		if (self.size == 6 or self.size == 9) then --fly as raccoon Mario
			self.raccoonflyingtimer = self.raccoonflyingtimer + dt
			if self.raccoonflyingtimer < self.characterdata.raccoonflytime then
				if jumpkey(self.playernumber) and self.controlsenabled then
					if self.gravitydir == "up" then
						self.speedy = math.min(self.characterdata.raccoonflyjumpforce, self.speedy+100*dt)
					else
						self.speedy = math.max(-self.characterdata.raccoonflyjumpforce, self.speedy-100*dt)
					end
					if self.speedy < 0 then
						self.y = math.max(-4, self.y)
					end
				end
			else
				self.raccoonflyingtimer = 0
				self.raccoonfly = false
			end
			self.raccoonflyanimationprogress = self.raccoonflyanimationprogress + (math.abs(1)+4)/5*dt*self.characterdata.runanimationspeed
			while self.raccoonflyanimationprogress >= 4 do
				self.raccoonflyanimationprogress = self.raccoonflyanimationprogress - 3
			end
			if self.raccoonflyframe == 4 then
				self.raccoonflyframe = 1
			end
			self.raccoonflyframe = math.floor(self.raccoonflyanimationprogress)
		elseif self.size == 10 then--fly as cape mario
			if self.capefly and (not (runkey(self.playernumber) and self.controlsenabled)) then
				self.raccoonfly = false
				self.capefly = false
				self.planemode = false
				self.planetimer = 0
			elseif self.capefly then
				local speed = 4
				if (self.speedx > 0 and rightkey(self.playernumber)) or (self.speedx < 0 and leftkey(self.playernumber)) then
					speed = 8
				end
				self.capeflyanim = self.capeflyanim + speed*dt
				while self.capeflyanim > 1 do
					if ((self.speedx > 0 and leftkey(self.playernumber)) or (self.speedx < 0 and rightkey(self.playernumber))) and self.controlsenabled then
						self.capeflyframe = math.max(1, math.min(self.capeflyframe-1, 6))
					else
						self.capeflyframe = math.max(1, math.min(self.capeflyframe+1, 6))
					end
					--alsean!!!! cape mario doesnt correct!!!!! please fix!!!
					if self.capeflyframe == 1 and self.speedy > 0 and self.capeflybounce then
						self.speedy = -30
						self.capeflybounce = false
						playsound(capeflysound)
					elseif self.capeflyframe >= 2 then
						self.capeflybounce = true
					end
					self.capeflyanim = self.capeflyanim - 1
				end
				if self.capeflyframe < 5 then
					self.speedy = math.min(self.speedy, 6)
				end
				if self.speedy < 0 then
					self.y = math.max(-4, self.y)
				end
			elseif self.speedy > 0 then
				self.capefly = true
				self.capeflyframe = 1
			end
		end
	end
	if raccoonplanesound:isPlaying() and (self.planemode == false or (self.size ~= 6 and self.size ~= 9))	then
		raccoonplanesound:stop() --stops raccoon flying sound
	end
	
	--falling state fuck
	if (not self.falling) and (not self.jumping) then
		self.landed = true
	end
	--double jump?
	if self.hasdoublejumped and not (self.jumping or self.falling) then
		self.hasdoublejumped = false
	end
	if self.yoshiswallow then
		self.yoshiswallow = self.yoshiswallow + dt
		if self.yoshiswallow >= yoshiswallowtime then
			self.yoshiswallow = false
		else
			self.yoshiswallowframe = 1+math.floor((self.yoshiswallow/yoshiswallowtime)*5)
		end
	end
	if self.yoshispitting then
		self.yoshispitting = self.yoshispitting - dt
		if self.yoshispitting <= 0 then
			self.yoshispitting = false
		end
	end
	if self.yoshi and self.yoshitounge and not (self.yoshispitting) then
		self.yoshitoungewidth = math.max(0, math.min(yoshitoungemaxwidth, self.yoshitoungewidth + self.yoshitoungespeed*dt))
		
		local dirscale
		if self.animationdirection == "left" then
			dirscale = -scale
		else
			dirscale = scale
		end
		local w, h = self.yoshitoungewidth, yoshitoungeheight
		local x, y = self.x+(self.width/2), self.y+self.height
		local xoffset, yoffset = 12/16, -22/16
		if self.jumping then
			if dirscale < 0  then
				xoffset = -(7/16)-w
			else
				xoffset = 7/16
			end
		else
			if dirscale < 0 then
				xoffset = -(12/16)-w
			else
				xoffset = 12/16
			end
		end
		x, y = x+xoffset, y+yoffset
		
		if not self.yoshitoungeenemy then
			local dobreak = false
			for j, obj in pairs(yoshitoungekill) do
				for i, v in pairs(objects[obj]) do
					if (not v.shot) and v.width and (not v.delete) and aabb(x, y, w, h, v.x, v.y, v.width, v.height) and (not v.resistsyoshitongue) and (not v.resistsyoshitounge) and (not v.resistseverything) then
						--eat enemy
						if v and v.width <= 2 and v.height <= 2 then
							local pass = true
							if v.active and (v.shellanimal or v.small ~= nil or v.yoshispit) then
							elseif obj == "enemy" then
								if v.active or v.yoshitoungeifnotactive then
									local oldtransforms = v.transforms
									v.transforms = false
									if v:shotted("right", "tounge", false, true) ~= false then
										v:output()
										addpoints(v.firepoints or 200, self.x, self.y)
									else
										v.transforms = oldtransforms
										pass = false
									end
								else
									pass = false
								end
							else
								if v.shotted then
									addpoints(firepoints[obj], v.x, v.y)
									v:shotted(self.animationdirection)
								elseif v.use then
									v:use("player", self)
								end
							end
							if pass then
								self.yoshitoungespeed = -yoshitoungespeed
								if (v.shellanimal or v.small ~= nil or v.yoshispit) and v.active then
									self.yoshitoungeenemy = v
									v.eaten = true
									v.active = false
									v.drawable = false
								elseif v.drawable then
									--death frame
									self.yoshitoungeenemy = {graphic=v.graphic,quad=v.quad,width=v.width,height=v.height,
										offsetX=v.offsetX or 0,offsetY=v.offsetY or 0,quadcenterX=v.quadcenterX or 0,quadcenterY=v.quadcenterY or 0,
										animationscalex=v.animationscalex, animationscaley=v.animationscaley}
									if v.output then
										v:output()
									end
									v.instantdelete = true
								end
								local dobreak = true
								break
							end
						end
					end
				end
				if dobreak then
					break
				end
			end
		end
		
		if self.yoshitoungewidth == yoshitoungemaxwidth then
			self.yoshitoungespeed = -yoshitoungespeed
		elseif self.yoshitoungewidth == 0 then
			self.yoshitoungespeed = yoshitoungespeed
			self.yoshitounge = false
			local v = self.yoshitoungeenemy
			if v and v.eaten then
			else
				if self.yoshitoungeenemy then
					--swallow animation
					self.yoshiswallow = 0
					self.yoshiswallowframe = 1
				end
				self.yoshitoungeenemy = false
			end
		end
	end
	
	if self.size == 10 or (self.fireenemy and self.fireenemy.cape) then
		if self.speedy > 0 and jumpkey(self.playernumber) and (not self.groundpounding) then --float
			self.speedy = math.min(self.speedy, 6)
		end
		--update cape frame
		local delay = 0.1
		if self.fence then
			self.capeframe = 18
		elseif self.speedy > 0 then --falling
			if self.capeframe < 4 then
				delay = 0.05
				self.capeanim = self.capeanim + dt
				while self.capeanim > delay do
					self.capeframe = self.capeframe - 1
					if self.capeframe < 1 then
						self.capeframe = 10
					end
					self.capeanim = self.capeanim - delay
				end
			elseif self.capeframe < 10 or self.capeframe > 13 then
				self.capeframe = 10
			else
				self.capeanim = self.capeanim + dt
				while self.capeanim > delay do
					self.capeframe = self.capeframe + 1
					if self.capeframe > 13 then
						self.capeframe = 10
					end
					self.capeanim = self.capeanim - delay
				end
			end
		else
			if math.abs(self.speedx) >= maxwalkspeed then --walking/running
				self.capeanim = self.capeanim + dt
				while self.capeanim > delay do
					self.capeframe = self.capeframe + 1
					if self.capeframe >= 10 then
						self.capeframe = 6
					end
					self.capeanim = self.capeanim - delay
				end
			else --idle
				if self.capeframe > 3 then
					self.capeframe = 1
				else
					self.capeanim = self.capeanim + dt
					while self.capeanim > delay do
						self.capeframe = self.capeframe + 1
						if self.capeframe > 3 then
							self.capeframe = 3
						end
						self.capeanim = self.capeanim - delay
					end
				end
			end
		end
	end

	if self.size == 14 and self.ducking then
		self.blueshellanimationprogress = (((self.blueshellanimationprogress + (math.abs(self.speedx))/8*dt*(self.characterdata.runanimationspeed))-1)%(self.characterdata.blueshellframes))+1
		self.blueshellframe = math.floor(self.blueshellanimationprogress)
		self:setquad()
	end
	------------------------------------------------------------------------------------------
	if autoscrolling and not editormode and not self.customscissor then --autoscrolling stuff
		if autoscrollingy then
			if self.y < yscroll-4 and (not self.dead) then
				if starty >= mapheight/2 then
					self.y = yscroll-4
				else
					self:die("time")
				end
			elseif self.y > yscroll+height+1 and (not self.dead) then
				self:die("pit")
			end
		end
		if autoscrollingx then
			if self.x < xscroll and (not self.dead) then
				self.x = xscroll
			elseif self.x > xscroll+width-self.width and (not self.dead) then
				self.x = xscroll+width-self.width
			end
		end
	end
	if camerasetting == 3 and self.active and (not self.static) then
		if self.x < xscroll then
			self:die("time")
		end
	end
	if edgewrapping then --wrap around screen
		--teleport player
		local teleported = false
		local minx, maxx = -self.width, mapwidth
		if self.x < minx then
			self.x = maxx; teleported = true
		elseif self.x > maxx then
			self.x = minx; teleported = true
		end
		if teleported then
			local fastestplayer = self
			for i = 1, players do
				if not objects["player"][i].dead and objects["player"][i].x > fastestplayer.x then
					fastestplayer = objects["player"][i]
				end
			end
			if fastestplayer.playernumber == self.playernumber then
				xscroll = self.x-width/2
				if xscroll < 0 then xscroll = 0 end
				if xscroll > mapwidth-width-1 then
					xscroll = math.max(0, mapwidth-width-1)
					hitrightside()
				end
				splitxscroll = {xscroll}
			end	
		end
	end
	
	--looking up/down
	if upkey(self.playernumber) and self.controlsenabled then
		self.upkeytimer = self.upkeytimer + dt
	else
		self.upkeytimer = 0
	end
	if downkey(self.playernumber) and self.controlsenabled then
		self.downkeytimer = self.downkeytimer + dt
	else
		self.downkeytimer = 0
	end

	--button press controls joystick
	if controls[self.playernumber] then
		if controls[self.playernumber]["left"][1] == "joy" and controls[self.playernumber]["left"][3] ~= "but"
			and controls[self.playernumber]["right"][1] == "joy" and controls[self.playernumber]["right"][3] ~= "but" then
			local left, right = leftkey(self.playernumber), rightkey(self.playernumber)
			if not self.leftkeyjoystick and left then
				self:button("left")
				self:leftkey()
				animationsystem_buttontrigger(self.playernumber, "left")
			end
			if self.leftkeyjoystick and not left then
				self:buttonrelease("left")
				animationsystem_buttonreleasetrigger(self.playernumber, "left")
			end
			if not self.rightkeyjoystick and right then
				self:button("right")
				self:rightkey()
				animationsystem_buttontrigger(self.playernumber, "right")
			end
			if self.rightkeyjoystick and not right then
				self:buttonrelease("right")
				animationsystem_buttonreleasetrigger(self.playernumber, "right")
			end
			self.leftkeyjoystick = left
			self.rightkeyjoystick = right
		end
		if controls[self.playernumber]["up"][1] == "joy" and controls[self.playernumber]["up"][3] ~= "but"
			and controls[self.playernumber]["down"][1] == "joy" and controls[self.playernumber]["down"][3] ~= "but" then
			local up, down = upkey(self.playernumber), downkey(self.playernumber)
			if not self.upkeyjoystick and up then
				self:button("up")
				self:upkey()
				animationsystem_buttontrigger(self.playernumber, "up")
			end
			if self.upkeyjoystick and not up then
				self:buttonrelease("up")
				animationsystem_buttonreleasetrigger(self.playernumber, "up")
			end
			if not self.downkeyjoystick and down then
				self:button("down")
				self:downkey()
				animationsystem_buttontrigger(self.playernumber, "down")
			end
			if self.downkeyjoystick and not down then
				self:buttonrelease("down")
				animationsystem_buttonreleasetrigger(self.playernumber, "down")
			end
			self.upkeyjoystick = up
			self.downkeyjoystick = down
		end
	end

	--Idle Animation
	if self.characterdata.idleframes > 1 then
		local frames = self.characterdata.idleframes
		self.idleanimationprogress = ((self.idleanimationprogress+self.characterdata.idleanimationspeed*dt-1)%(frames))+1
		self.idleframe = math.floor(self.idleanimationprogress)
	end
	if self.characterdata.jumpframes > 1 then
		local frames = self.characterdata.jumpframes
		if self.characterdata.jumpanimationloop then
			self.jumpanimationprogress = ((self.jumpanimationprogress+self.characterdata.jumpanimationspeed*dt-1)%(frames))+1
		else
			self.jumpanimationprogress = math.min(frames,self.jumpanimationprogress+self.characterdata.jumpanimationspeed*dt)
		end
		self.jumpframe = math.floor(self.jumpanimationprogress)
	end
	if self.characterdata.fallframes > 1 and self.falling and self.speedy > 0 then
		local frames = self.characterdata.fallframes
		if self.characterdata.fallanimationloop then
			self.fallanimationprogress = ((self.fallanimationprogress+self.characterdata.fallanimationspeed*dt-1)%(frames))+1
		else
			self.fallanimationprogress = math.min(frames,self.fallanimationprogress+self.characterdata.fallanimationspeed*dt)
		end
		self.fallframe = math.floor(self.fallanimationprogress)
	end
	
	--clear pipe invincibility
	if self.clearpipeexitinvincibility and (not self.clearpipe) then
		self.clearpipeexitinvincibility = self.clearpipeexitinvincibility - 1
		if self.clearpipeexitinvincibility < 0 then
			self.invincible = false
			self.clearpipeexitinvincibility = false
		end
	end

	--Groundpounding
	if self.groundpounding then
		self.groundpounding = self.groundpounding + dt
		if (self.shoe ~= "drybonesshell" and self.groundpounding > groundpoundtime) or (self.shoe == "drybonesshell" and self.groundpounding > 0.2) then
			--start falling
			if self.static then
				self.static = false
				self.speedy = groundpoundforce
			end

			if downkey(self.playernumber) then
				
			end
		elseif self.shoe ~= "drybonesshell" then
			--begin animation
			self.rotation = (self.groundpounding/groundpoundtime)*math.pi*2
			if (self.portalgun and self.pointingangle > 0) or (not self.portalgun and self.animationdirection == "left") then self.rotation = -self.rotation end
		end

		if (not (self.falling or self.jumping)) and not downkey(self.playernumber) then
			self:groundpound(false)
		end
	end

	--swim wing
	if self.swimwing then
		self.swimwing = self.swimwing - dt
		if self.swimwing < 0 then
			self:dive(false)
			self.swimwing = false
		end
	end
	
	--dk hammer
	if self.dkhammer then
		self.dkhammeranim = self.dkhammeranim + dt
		while self.dkhammeranim > dkhammeranimspeed do
			if self.dkhammerframe == 2 then
				self.dkhammerframe = 1
			else
				self.dkhammerframe = 2
			end
			self.dkhammeranim = self.dkhammeranim - dkhammeranimspeed
		end
		
		self.dkhammer = self.dkhammer - dt
		if self.dkhammer < 0 then
			self.dkhammer = false
		end
		
		if self.dkhammer then
			local w, h = 1, 1
			local x, y = self.x+(self.width/2)-.5, self.y-1
			if self.dkhammerframe == 2 then
				if self.animationdirection == "right" then
					x, y = self.x+self.width, self.y+self.height-1
				else
					x, y = self.x-1, self.y+self.height-1
				end
			end
			
			local dobreak = false
			for j, obj in pairs(dkhammerkill) do
				for i, v in pairs(objects[obj]) do
					if v.active and (not v.shot) and v.width and aabb(x, y, w, h, v.x, v.y, v.width, v.height) then
						if obj == "enemy" then
							if v:shotted("right", "dkhammer", false, false) ~= false then
								addpoints(v.firepoints or 200, self.x, self.y)
							end
						else
							addpoints(firepoints[obj], v.x, v.y)
							v:shotted(self.animationdirection)
						end
						local dobreak = true
						break
					end
				end
				if dobreak then
					break
				end
			end
		end
	end
	
	--sledge bros
	if self.groundfreeze then
		self.controlsenabled = false
		self.groundfreeze = self.groundfreeze - dt
		if self.groundfreeze < 0 then
			self.controlsenabled = true
			self.groundfreeze = false
			self.frozen = false
		end
	end
	
	if underwater and not self.water then
		self.water = true
	end

	--laser fields
	if not self.dead then
		for h, u in pairs(laserfields) do
			if u.active then
				if u.dir == "hor" then
					if inrange(self.x+6/16, u.startx-1, u.endx, true) and inrange(u.y-14/16, self.y, self.y+self.speedy*dt, true) then
						self:die("laser")
					end
				else
					if inrange(self.y+6/16, u.starty-1, u.endy, true) and inrange(u.x-14/16, self.x, self.x+self.speedx*dt, true) then
						self:die("laser")
					end
				end
			end
		end
	end
	
	--big cloud
	if self.cloudtimer then
		self.cloudtimer = self.cloudtimer - dt
		if self.cloudtimer < 0 then
			self:shoed(false)
		end
	end

	--helmetanimation
	if (not self.clearpipe) then
		if self.helmet == "propellerbox" then
			local animspeed = (1/0.08)
			if self.propellerjumping then
				animspeed = (1/0.04)
			elseif jumpkey(self.playernumber) then
				animspeed = (1/0.06)
			end
			self.helmetanimtimer = (self.helmetanimtimer-1+animspeed*dt)%4+1
		elseif self.helmet == "cannonbox" then
			if (not noupdate) and self.active then
				if runkey(self.playernumber) then
					if type(self.cannontimer) == "table" then --charging
						local chargetime = 1.6
						self.cannontimer[1] = self.cannontimer[1] + dt
						self.helmetanimtimer = (self.helmetanimtimer-1+20*(self.cannontimer[1]/chargetime)*dt)%2+1
						if self.cannontimer[1] > chargetime then
							self.cannontimer = "charged"
						end
					elseif type(self.cannontimer) == "string" then --charged
						self.helmetanimtimer = 2
					else
						self.cannontimer = {0}
					end
				else
					if type(self.cannontimer) == "table" then --charging
						self.cannontimer = 0
						self.helmetanimtimer = 1
					elseif self.cannontimer == "charged" then
						local dir = "right"
						if (self.portalgun and self.pointingangle > 0) or (not self.portalgun and self.animationdirection == "left") then
							dir = "left"
						end
						local offsetx = 0.5
						if dir == "left" then offsetx = -0.5-(6/16) end
						table.insert(objects["cannonball"], cannonball:new(self.x+1+offsetx, self.y+4/16, dir, cannonballspeed*2.5, "mario"))
						self.cannontimer = 0
						self.helmetanimtimer = 1
					end
					if not FireButtonCannonHelmet then
						self.cannontimer = self.cannontimer + dt
					end
					while self.cannontimer > cannonboxdelay do
						local dir = "right"
						if (self.portalgun and self.pointingangle > 0) or (not self.portalgun and self.animationdirection == "left") then
							dir = "left"
						end
						local offsetx = 0.5
						if dir == "left" then offsetx = -0.5-(6/16) end
						table.insert(objects["cannonball"], cannonball:new(self.x+1+offsetx, self.y+4/16, dir, nil, "mario"))
						self.cannontimer = self.cannontimer - cannonboxdelay
					end
				end
			end
		end
	end
	
	--turrets
	self.hitpointsdelay = math.max(0, self.hitpointsdelay - dt)
	if self.hitpoints >= maxhitpoints and not self.dead then
		self.hitpointtimer = 0
	elseif not self.dead then
		self.hitpointtimer = self.hitpointtimer + dt
		if self.hitpointtimer > refillhitstime then
			self.hitpointtimer = self.hitpointtimer - refillhitstime
			self.hitpoints = self.hitpoints + 1
		end
	end
	
	self.passivemoved = false
	--rotate back to 0 (portals)
	if self.gravitydir == "left" then
		self.rotation = self.rotation - math.pi*0.5
	elseif self.gravitydir == "right" then
		self.rotation = self.rotation + math.pi*0.5
	end
	self.rotation = math.fmod(self.rotation, math.pi*2)
	
	if self.rotation < -math.pi then
		self.rotation = self.rotation + math.pi*2
	elseif self.rotation > math.pi then
		self.rotation = self.rotation - math.pi*2
	end
	
	if self.rotation > 0 then
		self.rotation = self.rotation - portalrotationalignmentspeed*dt
		if self.rotation < 0 then
			self.rotation = 0
		end
	elseif self.rotation < 0 then
		self.rotation = self.rotation + portalrotationalignmentspeed*dt
		if self.rotation > 0 then
			self.rotation = 0
		end
	end

	if self.gravitydir == "left" then
		self.rotation = self.rotation + math.pi*0.5
	elseif self.gravitydir == "right" then
		self.rotation = self.rotation - math.pi*0.5
	end
	
	if self.startimer < mariostarduration and not self.dead then
		self.startimer = self.startimer + dt
		self.starblinktimer = self.starblinktimer + dt
		
		local lmariostarblinkrate = mariostarblinkrate
		if self.startimer >= mariostarduration-mariostarrunout then
			lmariostarblinkrate = mariostarblinkrateslow
		end

		while self.starblinktimer > lmariostarblinkrate do
			self.starcolori = self.starcolori + 1
			if self.starcolori > 4 then
				self.starcolori = self.starcolori - 4
			end
			if self.size ~= 8 then
				self.colors = self.characterdata.starcolors[self.starcolori]
			end
			
			self.starblinktimer = self.starblinktimer - lmariostarblinkrate
		end
		
		if self.startimer >= mariostarduration-mariostarrunout and self.startimer-dt < mariostarduration-mariostarrunout then
			--check if another starman is playing
			local starstill = false
			for i = 1, players do
				if i ~= self.playernumber and objects["player"][i].starred then
					starstill = true
				end
			end
			
			if not starstill and not levelfinished then
				if self.size == 8 then
					--mega mushroom
					megamushroomsound:stop()
					if not music:playingmusic() then
						playmusic()
					end
				else
					playmusic()
					music:stop("starmusic")
				end
			end
		end
		
		if self.startimer >= mariostarduration then
			if (self.size == 8) then
				self.largeshrink = true --be big once shrinking is done
				self:shrink()
			else
				self.colors = self.basecolors
			end
			
			self.starred = false
			self.startimer = mariostarduration
		end
	end
	
	--animationS
	if self.animation == "animationwalk" and not self.spring and not self.greenspring then
		if self.animationmisc[2] then
			if self.animationmisc[1] == "right" then
				self.speedx = self.animationmisc[2]
			else
				self.speedx = -self.animationmisc[2]
			end
		end
		self:runanimation(dt)
		return
	elseif self.animation == "pipedown" then
		local dist = pipeanimationdistancedown
		self.animationtimer = self.animationtimer + dt
		if self.animationtimer < pipeanimationtime then
			local v = (self.animationtimer/pipeanimationtime)
			self.y = self.animationy-1 - self.height + v*dist
		else
			self.y = self.animationy-1 - self.height + dist
			
			if self.animationtimer >= pipeanimationtime+pipeanimationdelay then
				self:pipetravel()
			end
		end
		return
	elseif self.animation == "pipeup" then
		local dist = pipeanimationdistancedown
		self.animationtimer = self.animationtimer + dt
		if self.animationtimer < pipeanimationtime then
			local v = (self.animationtimer/pipeanimationtime)
			self.y = self.animationy - v*dist
		else
			self.y = self.animationy - dist
			
			if self.animationtimer >= pipeanimationtime+pipeanimationdelay then
				self:pipetravel()
			end
		end
		return
	elseif self.animation == "piperight" then
		local dist = pipeanimationdistanceright
		dist = dist+(math.floor(self.width))
		self.animationtimer = self.animationtimer + dt
		if self.animationtimer < pipeanimationtime then
			local v = (self.animationtimer/pipeanimationtime)
			self.x = self.animationx-1-self.width + v*dist
			
			--Run animation
			if self.animationstate == "running" then
				self:runanimation(dt, pipeanimationrunspeed, self.characterdata.piperunanimationspeed)
			end
		else
			self.x = self.animationx-1-self.width + dist
			
			if self.animationtimer >= pipeanimationtime+pipeanimationdelay then
				self:pipetravel()
			end
		end
		return
	elseif self.animation == "pipeleft" then
		local dist = pipeanimationdistanceright
		dist = dist+(math.floor(self.width))
		self.animationtimer = self.animationtimer + dt
		if self.animationtimer < pipeanimationtime then
			local v = (self.animationtimer/pipeanimationtime)
			self.x = self.animationx - v*dist
			
			--Run animation
			if self.animationstate == "running" then
				self:runanimation(dt, pipeanimationrunspeed, self.characterdata.piperunanimationspeed)
			end
		else
			self.x = self.animationx - dist
			
			if self.animationtimer >= pipeanimationtime+pipeanimationdelay then
				self:pipetravel()
			end
		end
		return
	elseif self.animation == "pipeupexit" then
		local dist = pipeanimationdistancedown
		self.animationtimer = self.animationtimer + dt
		if self.animationtimer < pipeupdelay then
			local v = 1
			self.y = self.animationy-1-self.height + v*dist
			self.drawable = true
		elseif self.animationtimer < pipeanimationtime+pipeupdelay then
			local v = (1-((self.animationtimer-pipeupdelay)/pipeanimationtime))
			self.y = self.animationy-1-self.height + v*dist
			self.drawable = true
		else
			self.y = self.animationy-1-self.height
			
			if self.animationtimer >= pipeanimationtime then
				self.active = true
				self.controlsenabled = true
				self.animation = nil
				self.customscissor = nil
				if self.pickup then
					self.pickup.customscissor = nil
				end
			end
		end
		return
	elseif self.animation == "pipedownexit" then
		local dist = pipeanimationdistancedown
		self.animationtimer = self.animationtimer + dt
		if self.animationtimer < pipeupdelay then
			local v = 1
			self.y = self.animationy - v*dist
			self.drawable = true
		elseif self.animationtimer < pipeanimationtime+pipeupdelay then
			local v = (1-((self.animationtimer-pipeupdelay)/pipeanimationtime))
			self.y = self.animationy - v*dist
			self.drawable = true
		else
			self.y = self.animationy
			
			if self.animationtimer >= pipeanimationtime then
				self.active = true
				self.controlsenabled = true
				self.animation = nil
				self.customscissor = nil
				if self.pickup then
					self.pickup.customscissor = nil
				end
			end
		end
		return
	elseif self.animation == "piperightexit" then
		local dist = pipeanimationdistanceright
		dist = dist+(math.floor(self.width))
		self.animationtimer = self.animationtimer + dt
		if self.animationtimer < pipeupdelay then
			local v = 1
			self.x = self.animationx - v*dist
			self.drawable = true
		elseif self.animationtimer < pipeanimationtime+pipeupdelay then
			local v = (1-((self.animationtimer-pipeupdelay)/pipeanimationtime))
			self.x = self.animationx - v*dist
			self.drawable = true
			
			--Run animation
			if self.animationstate == "running" then
				self:runanimation(dt, pipeanimationrunspeed, self.characterdata.piperunanimationspeed)
			end
		else
			self.x = self.animationx
			
			if self.animationtimer >= pipeanimationtime then
				self.active = true
				self.controlsenabled = true
				self.animation = nil
				self.customscissor = nil
				if self.pickup then
					self.pickup.customscissor = nil
				end
			end
		end
		return
	elseif self.animation == "pipeleftexit" then
		local dist = pipeanimationdistanceright
		dist = dist+(math.floor(self.width))
		self.animationtimer = self.animationtimer + dt
		if self.animationtimer < pipeupdelay then
			local v = 1
			self.x = self.animationx-1-self.width + v*dist
			self.drawable = true
		elseif self.animationtimer < pipeanimationtime+pipeupdelay then
			local v = (1-((self.animationtimer-pipeupdelay)/pipeanimationtime))
			self.x = self.animationx-1-self.width + v*dist
			self.drawable = true
			
			--Run animation
			if self.animationstate == "running" then
				self:runanimation(dt, pipeanimationrunspeed, self.characterdata.piperunanimationspeed)
			end
		else
			self.x = self.animationx-1-self.width
			
			if self.animationtimer >= pipeanimationtime then
				self.active = true
				self.controlsenabled = true
				self.animation = nil
				self.customscissor = nil
				if self.pickup then
					self.pickup.customscissor = nil
				end
			end
		end
		return
	elseif self.animation == "flag" then
		if self.animationtimer < flagdescendtime then 	
			flagimgy = flagy-10+1/16 + flagydistance * (self.animationtimer/flagdescendtime)
			self.y = self.y + flagydistance/flagdescendtime * dt
			
			self.animationtimer = self.animationtimer + dt
				
			if self.y > flagy-9+4/16 + flagydistance-self.height then
				self.y = flagy-9+4/16 + flagydistance-self.height
				self.climbframe = 2
			else
				self.climbframe = math.ceil(math.fmod(self.animationtimer, flagclimbframedelay*self.characterdata.climbframes)/flagclimbframedelay)
				self.climbframe = math.max(self.climbframe, 1)
				--[[if math.fmod(self.animationtimer, flagclimbframedelay*2) >= flagclimbframedelay then
					self.climbframe = 1
				else
					self.climbframe = 2
				end]]
			end
			
			self.animationdirection = "right"
			self.animationstate = "climbing"
			self:setquad()
			
			if self.animationtimer >= flagdescendtime then
				flagimgy = flagy-10+1/16 + flagydistance
				self.pointingangle = math.pi/2
				self.animationdirection = "left"
				self.x = flagx + 6/16
			end
			return
		elseif self.animationtimer < flagdescendtime+flaganimationdelay then
			self.animationtimer = self.animationtimer + dt
			
			if self.animationtimer >= flagdescendtime+flaganimationdelay then
				self.active = true
				self.gravity = self.characterdata.yacceleration
				self.animationstate = "running"
				self.animationdirection = "right"
				self.speedx = 4.27
				self.pointingangle = -math.pi/2
			end
		else
			self.animationtimer = self.animationtimer + dt
		end
		
		local add = 6

		self.flagtimer = self.flagtimer + dt
		if (self.flagtimer > 8 and (self.active or self.fireenemyride)) and not (subtractscore or castleflagmove) then
			self.fireenemyride = false
			self.active = false
			self:duck(true)
			if mariotime > 0 then
				playsound(scoreringsound)
				subtractscore = true
				subtracttimer = 0
			else
				castleflagmove = true
			end
		end
		
		if (self.x >= flagx + add and self.active) or (self.speedx == 0 and self.animationstate ~= "climbing" and self.active) then
			self.drawable = false
			self.active = false
			if mariotime > 0 then
				playsound(scoreringsound)
				subtractscore = true
				subtracttimer = 0
			else
				castleflagmove = true
			end
		end
		
		if subtractscore == true and mariotime >= 0 then
			subtracttimer = subtracttimer + dt
			while subtracttimer > scoresubtractspeed do
				subtracttimer = subtracttimer - scoresubtractspeed
				if mariotime > 0 then
					mariotime = math.ceil(mariotime - 1)
					marioscore = marioscore + 50
				end
				
				if mariotime <= 0 then
					subtractscore = false
					scoreringsound:stop()
					castleflagmove = true
					mariotime = 0
				end
			end
		end
		
		if castleflagmove then
			if self.animationtimer < castlemintime then
				castleflagtime = self.animationtimer
				return
			end
			castleflagy = castleflagy - castleflagspeed*dt
			
			if castleflagy <= 0 then
				castleflagy = 0
				castleflagmove = false
				firework = true
				castleflagtime = self.animationtimer
			end
		end
		
		if firework then
			local timedelta = self.animationtimer - castleflagtime
			for i = 1, fireworkcount do
				local fireworktime = i*fireworkdelay
				if timedelta >= fireworktime and timedelta - dt < fireworktime then
					table.insert(fireworks, fireworkboom:new(flagx+6, flagy-13))
				end
			end
			
			if timedelta > fireworkcount*fireworkdelay+endtime then
				nextlevel()
				return
			end
		end
		
		--500 points per firework, appear at 1 3 and 6 (Who came up with this?)
		
		--Run animation
		if self.animationstate == "running" then
			self:runanimation(dt)
		end
		return
		
	elseif self.animation == "axe" then
		self.animationtimer = self.animationtimer + dt
		
		if (not bowserfall) and self.animationtimer - dt < castleanimationchaindisappear and self.animationtimer >= castleanimationchaindisappear then
			bridgedisappear = true
		end
		
		if bridgedisappear then
			local v = self.axeboss
			if v then
				v.walkframe = round(math.fmod(self.animationtimer, castleanimationbowserframedelay*2)*(1/(castleanimationbowserframedelay*2)))+1
			end
			self.animationtimer2 = self.animationtimer2 + dt
			while self.animationtimer2 > castleanimationbridgedisappeardelay do
				self.animationtimer2 = self.animationtimer2 - castleanimationbridgedisappeardelay
				local removedtile = false
				for y = 1, mapheight do
					if inmap(self.animationbridgex, y) and (tilequads[map[self.animationbridgex][y][1]]:getproperty("bridge", self.animationbridgex, y) or map[self.animationbridgex][y][1] == 10) then
						removedtile = true
						map[self.animationbridgex][y][1] = 1
						objects["tile"][tilemap(self.animationbridgex, y)] = nil
					end
				end
				
				if removedtile then
					generatespritebatch()
					playsound(bridgebreaksound)
					self.axeforgivedistance = 0
					self.animationbridgex = self.animationbridgex - 1
				elseif self.axeforgivedistance and self.axeforgivedistance > 0 then
					self.axeforgivedistance = self.axeforgivedistance - 1
					self.animationbridgex = self.animationbridgex - 1
				else
					bowserfall = true
					bridgedisappear = false
				end
			end
		end
		
		if bowserfall then
			local v = self.axeboss
			if v and (not v.fall) then
				v.fall = true
				v.speedx = 0
				v.speedy = 0
				v.active = true
				v.gravity = 27.5
				playsound(bowserfallsound)
				self.animationtimer = 0
				return
			end
		end
		
		if bowserfall and self.animationtimer - dt < castleanimationmariomove and self.animationtimer >= castleanimationmariomove then
			self.active = true
			self.gravity = self.characterdata.yacceleration
			self.animationstate = "running"
			self.speedx = 4.27
			self.animationdirection = "right"
			self.pointingangle = -math.pi/2
		
			stopmusic()
			love.audio.stop()
			playsound(castleendsound)
		end
		
		if self.speedx > 0 and self.x >= mapwidth - 8 then
			self.x = mapwidth - 8
			self.animationstate = "idle"
			self.idleframe = 1
			self:setquad()
			self.speedx = 0
		end
		
		if levelfinishedmisc2 == 1 then
			if self.animationtimer - dt < castleanimationtextfirstline and self.animationtimer >= castleanimationtextfirstline then
				levelfinishedmisc = 1
			end
			
			if self.animationtimer - dt < castleanimationtextsecondline and self.animationtimer >= castleanimationtextsecondline then
				levelfinishedmisc = 2
			end
		
			if self.animationtimer - dt < castleanimationnextlevel and self.animationtimer >= castleanimationnextlevel then
				nextlevel()
			end
		else
			if self.animationtimer - dt < endanimationtextfirstline and self.animationtimer >= endanimationtextfirstline then
				levelfinishedmisc = 1
			end
			
			if self.animationtimer - dt < endanimationtextsecondline and self.animationtimer >= endanimationtextsecondline then
				levelfinishedmisc = 2
				stopmusic()
				love.audio.stop()
				music:play("princessmusic")
			end
		
			if self.animationtimer - dt < endanimationtextthirdline and self.animationtimer >= endanimationtextthirdline then
				levelfinishedmisc = 3
			end
			
			if self.animationtimer - dt < endanimationtextfourthline and self.animationtimer >= endanimationtextfourthline then
				levelfinishedmisc = 4
			end
			
			if self.animationtimer - dt < endanimationtextfifthline and self.animationtimer >= endanimationtextfifthline then
				levelfinishedmisc = 5
			end
		
			if self.animationtimer - dt < endanimationend and self.animationtimer >= endanimationend then
				endpressbutton = true
			end
		end
		
		--Run animation
		if self.animationstate == "running" and self.animationtimer >= castleanimationmariomove then
			self:runanimation(dt)
		end
		return
		
	elseif self.animation == "death" or self.animation == "deathpit" then
		self.animationtimer = self.animationtimer + dt
		self.animationstate = "dead"
		self:setquad()
		
		if self.animation == "death" then
			if self.animationtimer > deathanimationjumptime then
				if self.animationtimer - dt < deathanimationjumptime then
					self.speedy = -deathanimationjumpforce
				end
				self.speedy = self.speedy + deathgravity*dt
				self.y = self.y + self.speedy*dt
			end
		end

		if self.animationmisc == "everyonedead" and jumpkey(self.playernumber) and self.animationtimer > 1 then
			self.animationtimer = deathtotaltime+1
		end
		
		if self.animationtimer > deathtotaltime then
			if self.animationmisc == "everyonedead" then
				local sub = nil --mariosublevel
				if checkpointx then
					if checkpointsublevel then
						sub = checkpointsublevel
					end
				end
				if not editormode and testlevel then
					stoptestinglevel()
				else
					levelscreen_load("death", sub)
				end
			elseif not everyonedead then
				self:respawn()
			end
		end
		
		return
	elseif self.animation == "intermission" and not self.spring and not self.greenspring then
		--Run animation
		if self.animationstate == "running" then
			self:runanimation(dt, pipeanimationrunspeed, self.characterdata.piperunanimationspeed)
		end
		
		return
		
	elseif self.animation == "vine" then
		self.y = self.y - vinemovespeed*dt
		
		self.vinemovetimer = self.vinemovetimer + dt
		
		self.climbframe = math.ceil(math.fmod(self.vinemovetimer, self.characterdata.vineframedelay*self.characterdata.climbframes)/self.characterdata.vineframedelay)
		self.climbframe = math.max(self.climbframe, 1)
		self:setquad()
		
		if self.y < -4 then
			levelscreen_load("vine", self.animationmisc)
		end
		return
	elseif self.animation == "vinestart" then
		self.animationtimer = self.animationtimer + dt
		if self.vineanimationdropoff == false and self.animationtimer - dt <= vineanimationmariostart and self.animationtimer > vineanimationmariostart then
			self.vineanimationclimb = true
		end
		
		if self.vineanimationclimb then
			self.vinemovetimer = self.vinemovetimer + dt
			
			self.climbframe = math.ceil(math.fmod(self.vinemovetimer, self.characterdata.vineframedelay*self.characterdata.climbframes)/self.characterdata.vineframedelay)
			self.climbframe = math.max(self.climbframe, 1)
			
			self.y = self.y - vinemovespeed*dt
			if self.y <= mapheight-vineanimationgrowheight+vineanimationstop+0.4*(self.playernumber-1) then
				self.vineanimationclimb = false
				self.vineanimationdropoff = true
				self.animationtimer = 0
				self.y = mapheight-vineanimationgrowheight+vineanimationstop+0.4*(self.playernumber-1)
				self.climbframe = 2
				self.pointingangle = math.pi/2
				self.animationdirection = "left"
				self.x = self.x+9/16
			end
			self:setquad()
		end
		
		if self.vineanimationdropoff and self.animationtimer - dt <= vineanimationdropdelay and self.animationtimer > vineanimationdropdelay then
			self.active = true
			self.controlsenabled = true
			self.x = self.x + 7/16
			self.animation = false
		end
		
		return
	
	elseif self.animation == "shrink" then
		self.animationtimer = self.animationtimer + dt
		--set frame lol
		local frame = math.ceil(math.fmod(self.animationtimer, growframedelay*3)/shrinkframedelay)
		self:updateangle()
	
		if frame == 1 then
			self:setsize(2)
			self:setquad("idle", 2)
			self.animationstate = "idle"
		else
			self:setsize(1)
			if frame == 2 then
				self.animationstate = "grow"
				if self.portalgun == true and not (playertype and playertype == "minecraft") then
					self:setquad("grow")
				else
					self:setquad("grownogun")
				end
				self.quadcenterY = self.characterdata.shrinkquadcenterY2
			else
				self.animationstate = "idle"
				self:setquad()
				self.quadcenterY = self.characterdata.smallquadcenterY
			end
		end
		
		local invis = math.ceil(math.fmod(self.animationtimer, invicibleblinktime*2)/invicibleblinktime)
		
		if invis == 1 then
			self.drawable = true
		else
			self.drawable = false
		end
		
		if self.animationtimer - dt < shrinktime and self.animationtimer > shrinktime then
			self.animationstate = self.animationmisc
			self.animation = "invincible"
			self.invincible = true
			noupdate = false
			self.animationtimer = 0
			self.drawable = true
			if self.largeshrink then
				self.size = 2
				self:setsize(2)
				self.largeshrink = false
			else
				self:setsize(1)
			end
		end
		return
	elseif self.animation == "invincible" then
		self.animationtimer = self.animationtimer + dt
		
		local invis = math.ceil(math.fmod(self.animationtimer, invicibleblinktime*2)/invicibleblinktime)
		
		if invis == 1 then
			self.drawable = true
		else
			self.drawable = false
		end
		
		if self.animationtimer - dt < invincibletime and self.animationtimer > invincibletime then
			self.animation = false
			if not levelfinished then --stay invincible if level is finished
				self.invincible = false
			end
			self.drawable = true
		end
		
	elseif self.animation == "grow1" then
		self.animationtimer = self.animationtimer + dt
		--set frame lol
		local frame = math.ceil(math.fmod(self.animationtimer, growframedelay*3)/growframedelay)
		self:updateangle()
		
		if frame == 3 then
			self.animationstate = "idle"
			self:setsize(self.size)
			self:setquad("idle")
		else
			self:setsize(1)
			if frame == 2 and self.size ~= -1 then
				self.animationstate = "grow"
				if self.portalgun == true and not (playertype and playertype == "minecraft") then
					self:setquad("grow", 1)
				else
					self:setquad("grownogun", 1)
				end
				self.quadcenterY = self.characterdata.growquadcenterY
			else
				self.animationstate = "idle"
				self:setquad(nil, 1)
				self.quadcenterY = self.characterdata.smallquadcenterY
				--self.characterdata.growquadcenterY2
			end
		end
		
		if self.animationtimer - dt < growtime and self.animationtimer > growtime then
			self.animationstate = self.animationmisc
			self.animation = false
			noupdate = false
			self:setsize(self.size)
		end
		return
		
	elseif self.animation == "grow2" then
		self.animationtimer = self.animationtimer + dt
		--set frame lol
		local frame = math.ceil(math.fmod(self.animationtimer, growframedelay*3)/growframedelay)
		self:updateangle()
		
		self.colors = self.characterdata.starcolors[frame]
		
		if self.animationtimer - dt < growtime and self.animationtimer > growtime then
			self.animation = false
			noupdate = false
			self.animationtimer = 0
			self:setsize(self.size)
		end
		return
	elseif self.animation == "door" then
		self.animationtimer = self.animationtimer + dt
		local door = objects["doorsprite"][tilemap(self.animationx, self.animationy)]
		local exitdoor
		if door then
			door.frame = math.min(4, 1+math.max(1, math.ceil(self.animationtimer*10)))
			if door.exit then
				exitdoor = objects["doorsprite"][tilemap(door.exitx, door.exity)]
				if exitdoor then
					exitdoor.frame = door.frame
				end
			end
		end
		if self.animationtimer > 0.3 then
			if door and door.exit then
				--grant autodelete immunity to enemies by door
				for i, v in pairs(enemies) do
					if objects[v] then
						for j, w in pairs(objects[v]) do
							if w.active and w.autodelete and onscreen(w.x, w.y, w.width, w.height) then
								w.horautodeleteimmunity = true
							end
						end
					end
				end

				--door.frame = 2
				self.x = door.exitx-.5-self.width/2
				self.y = door.exity-self.height
				if self.pickup and self.pickup.portaled then
					self.pickup:portaled()
				end
				camerasnap()

				playsound(doorclosesound)
				self.animation = "doorexit"
				self.animationtimer = 0
				self.animationx = door.exitx
				self.animationy = door.exity
				self.animationmisc = door
			else
				updatesizes()
				updateplayerproperties()
				levelscreen_load("sublevel", self.animationmisc[1])
				pipeexitid = self.animationmisc[2]
			end
		end
		return
	elseif self.animation == "doorexit" then
		self.animationtimer = self.animationtimer + dt
		local door = objects["doorsprite"][tilemap(self.animationx, self.animationy)]
		if door then
			door.frame = math.min(4, 5-math.max(1, math.floor(self.animationtimer*10)))
		end
		if self.animationmisc then
			self.animationmisc.frame = math.min(4, 5-math.max(1, math.floor(self.animationtimer*10)))
		end

		if self.animationtimer > 0.3 then
			for i, v in pairs(enemies) do
				if objects[v] then
					for j, w in pairs(objects[v]) do
						if w.horautodeleteimmunity and onscreen(w.x, w.y, w.width, w.height) then
							w.horautodeleteimmunity = false
						end
					end
				end
			end

			if door then
				door.frame = 2
				if door.locked then
					door.frame = 1
				end
			end
			if self.animationmisc then
				self.animationmisc.frame = 2
				if self.animationmisc.locked then
					self.animationmisc.frame = 1
				end
			end
			self.active = true
			self.controlsenabled = true
			if not self.starred then
				self.invincible = false
			end
			self.animation = nil
		end
		return
	elseif self.animation == "noteblockwarp" then
		self.animationtimer = self.animationtimer + dt
		self.x = self.x + self.speedx*dt
		self.y = self.y + self.speedy*dt

		if self.animationtimer > 1 then
			updatesizes()
			updateplayerproperties()
			levelscreen_load("sublevel", self.animationmisc)
		end
		return
	end
	
	if noupdate then
		return
	end
	
	if self.fireanimationtimer < fireanimationtime then
		self.fireanimationtimer = self.fireanimationtimer + dt
		if self.fireanimationtimer > fireanimationtime then
			self.fireanimationtimer = fireanimationtime
			self.fireenemyfireanim = nil
		end
	end
	
	if self.spinanimationtimer < raccoonspintime then
		self.spinanimationprogress = self.spinanimationprogress + dt*raccoonspinanimationspeed
		while self.spinanimationprogress >= 4 do
			self.spinanimationprogress = self.spinanimationprogress - 3
		end
		if self.spinframez == 4 then
			self.spinframez = 1
		end
		self.spinframez = math.floor(self.spinanimationprogress)
		self.spinanimationtimer = self.spinanimationtimer + dt
		if self.spinanimationtimer > raccoonspintime then
			self.spinanimationtimer = raccoonspintime
		end
	end

	--coins
	if not editormode then
		if (self.size == 8 or self.size == 16) or bigmario then --collect coins as huge mario
			for x = math.ceil(self.x), math.ceil(self.x+self.width) do
				for y = math.ceil(self.y), math.ceil(self.y+self.height) do
					if inmap(x, y) then
						if tilequads[map[x][y][1]].coin then
							collectcoin(x, y)
						elseif objects["coin"][tilemap(x, y)] then
							collectcoinentity(x, y)
						elseif objects["collectable"][tilemap(x, y)] and not objects["collectable"][tilemap(x, y)].coinblock then
							getcollectable(x, y)
						end
					end
				end
			end
		else
			local x = math.floor(self.x+self.width/2)+1
			local y = math.floor(self.y+self.height)+1
			if inmap(x, y) then
				if tilequads[map[x][y][1]].coin then
					collectcoin(x, y)
				elseif objects["coin"][tilemap(x, y)] then
					collectcoinentity(x, y)
				elseif objects["collectable"][tilemap(x, y)] and not objects["collectable"][tilemap(x, y)].coinblock then
					getcollectable(x, y)
				end
			end
			local y = math.floor(self.y+self.height/2)+1
			if inmap(x, y) then
				if tilequads[map[x][y][1]].coin then
					collectcoin(x, y)
				elseif objects["coin"][tilemap(x, y)] then
					collectcoinentity(x, y)
				elseif objects["collectable"][tilemap(x, y)] and not objects["collectable"][tilemap(x, y)].coinblock then
					getcollectable(x, y)
				end
			end
			if self.size > 1 and not (self.ducking and self.size == 14) then
				if inmap(x, y-1) then
					if tilequads[map[x][y-1][1]].coin then
						collectcoin(x, y-1)
					elseif objects["coin"][tilemap(x, y-1)] then
						collectcoinentity(x, y-1)
					elseif objects["collectable"][tilemap(x, y-1)] and not objects["collectable"][tilemap(x, y-1)].coinblock then
						getcollectable(x, y-1)
					end
				end
			end
		end
	end
	
	--vine controls and shit
	if self.vine then
		self.animationstate = "climbing"
		if upkey(self.playernumber) and self.controlsenabled then
			self.vinemovetimer = self.vinemovetimer + dt
			
			self.climbframe = math.ceil(math.fmod(self.vinemovetimer, self.characterdata.vineframedelay*self.characterdata.climbframes)/self.characterdata.vineframedelay)
			self.climbframe = math.max(self.climbframe, 1)
			
			self.y = self.y-vinemovespeed*dt
			
			local t = checkrect(self.x, self.y, self.width, self.height, {"tile", "portalwall"}, nil, "ignoreplatforms")
			if #t ~= 0 then
				self.y = objects[t[1]][t[2]].y + objects[t[1]][t[2]].height
				self.climbframe = 2
			end
		elseif downkey(self.playernumber) and self.controlsenabled then
			self.vinemovetimer = self.vinemovetimer + dt
			
			self.climbframe = math.ceil(math.fmod(self.vinemovetimer, self.characterdata.vineframedelay*self.characterdata.climbframes)/self.characterdata.vineframedelay)
			self.climbframe = math.max(self.climbframe, 1)
			
			checkportalHOR(self, self.y+vinemovedownspeed*dt)
			
			self.y = self.y+vinemovedownspeed*dt
			
			local t = checkrect(self.x, self.y, self.width, self.height, {"tile", "portalwall"}, nil, "ignoreplatforms")
			if #t ~= 0 then
				self.y = objects[t[1]][t[2]].y - self.height
				self.climbframe = 2
			end
		else
			self.climbframe = 2
			self.vinemovetimer = 0
		end

		if self.vine == "entity" and self.vineb.moving and self.vineb.oldx then
			local fx = self.x+(self.vineb.x-self.vineb.oldx)
			local fy = self.y+(self.vineb.oy-self.vineb.oldy)
			if not checkintile(fx, fy, self.width, self.height, {}, self, "ignoreplatforms") then
				self.x = fx
				self.y = fy
			else
				self:dropvine(self.vineside)
			end
		end
			
		if self.vine == "entity" and self.y+self.height <= vineanimationstart and (not self.vineb.vinestop) and (not self.vineb.moving) then
			self:vineanimation()
		end
		
		--check if still on vine
		if self.vine == "tile" then
			--vine tile
			local x = math.floor(self.x+self.width/2)+1
			local y = math.floor(self.y+self.height/2)+1
			if (not inmap(x, y)) or (not tilequads[map[x][y][1]].vine) then
				self:dropvine(self.vineside)
			end
		elseif self.vine == "entity" then
			local t = checkrect(self.x, self.y, self.width, self.height, {"vine"})
			if #t == 0 then
				self:dropvine(self.vineside)
			end
		end
		
		self:setquad()
		return
	end
	--fence controls and shit :)
	if self.fence then
		self:updateangle()
		--no more fence flying, actually check if we're on a fence
		local x = math.floor(self.x+self.width/2)+1
		local y = math.floor(self.y+self.height/2)+1
		if not (inmap(x, y) and tilequads[map[x][y][1]]:getproperty("fence")) then
			self:dropfence()
			return
		end

		local targetspeedx = 0
		local targetspeedy = 0
		if not self.controlsenabled then
			self.speedx = 0
			self.speedy = 0
			return
		end
		local u,d,l,r,s = upkey(self.playernumber), downkey(self.playernumber), leftkey(self.playernumber), rightkey(self.playernumber), self.characterdata.fencespeed
		if u and not d then
			targetspeedy = -s
		elseif d and not u then
			targetspeedy = s
		end
		if l and not r then
			targetspeedx = -s
		elseif r and not l then
			targetspeedx = s
		end
		local tx = math.floor(self.x+self.width/2 + targetspeedx*dt)+1
		local ty = math.floor(self.y+self.height/2 + targetspeedy*dt)+1

		if (not inmap(tx,y)) or (not tilequads[map[tx][y][1]]:getproperty("fence")) then
			self.x = math.max(math.min(self.x + targetspeedx*dt, x-self.width/2-0.001), x-self.width/2-0.999)
			targetspeedx = 0
		end
		if (not inmap(x,ty)) or (not tilequads[map[x][ty][1]]:getproperty("fence")) then
			if targetspeedy <= 0 then
				self.y = math.max(self.y + targetspeedy*dt, y-self.height/2-1)
				targetspeedy = 0
			else
				self:dropfence()
			end	
		end

		self.speedx = targetspeedx
		self.speedy = targetspeedy
		if targetspeedx ~= 0 or targetspeedy ~= 0 then
			local frames = self.characterdata.fenceframes
			if frames == 0 then
				frames = 2
			end
			self.fenceanimationprogress = ((self.fenceanimationprogress+self.characterdata.fenceanimationspeed*dt-1)%(frames))+1
			self.fenceframe = math.floor(self.fenceanimationprogress)
		end
		self.animationstate = "fence"
		self:setquad()
		return
	else
		local x = math.floor(self.x+self.width/2)+1
		local y = math.floor(self.y+self.height/2)+1
		if self.fencejumptimer > 0 then
			self.fencejumptimer = self.fencejumptimer - dt
		elseif upkey(self.playernumber) and ismaptile(x,y) and tilequads[map[x][y][1]].fence then
			if self:grabfence() then
				return
			end
		end
	end
	
	--springs
	if self.spring then
		self.x = self.springx
		self.springtimer = self.springtimer + dt
		if self.springb.springytable then
			self.y = self.springy - self.height + self.springb.springytable[self.springb.frame]
		else
			self.y = self.springy - self.height - 31/16 + springytable[self.springb.frame]
		end
		if self.springtimer > springtime then
			self:leavespring()
		end
		return
	end
	
	--green springs
	if self.springgreen then
		self.x = self.springgreenx
		self.springgreentimer = self.springgreentimer + dt
		self.y = self.springgreeny - self.height - 31/16 + springgreenytable[self.springgreenb.frame]
		if self.springgreentimer > springtime then
			self:leavespringgreen()
		end
		return
	end
	
	--noteblock (a lot more complicated than I wanted it to be)
	if self.noteblock then
		--get block bounce (wish it didn't work like this)
		local bounceyoffset = 0
		local bounceyoffsetleft = false
		local bounceyoffsetright = false
		local timer = 0
		for i, v in pairs(blockbounce) do
			if (v.x == self.noteblock[1] or v.x == self.noteblock[1]-1 or v.x == self.noteblock[1]+1) and v.y == self.noteblock[2] then
				local oldtimer
				if v.x ~= self.noteblock[1] then
					oldtimer = timer
				end
				timer = math.abs(v.timer)
				local bounce
				if timer < blockbouncetime/2 then bounce = timer / (blockbouncetime/2) * blockbounceheight
				else bounce = (2 - timer / (blockbouncetime/2)) * blockbounceheight end
				if v.timer < 0 then
					bounce = -bounce
				end
				if v.x == self.noteblock[1] then
					bounceyoffset = bounce
				elseif v.x == self.noteblock[1]-1 then
					bounceyoffsetleft = bounce 
				elseif v.x == self.noteblock[1]+1 then
					bounceyoffsetright = bounce
				end
				if oldtimer then
					timer = oldtimer
				end
			end
		end
		if timer > blockbouncetime/2 then --jump off block
			local force = -self.characterdata.jumpforce - (math.abs(self.speedx) / self.characterdata.maxrunspeed)*self.characterdata.jumpforceadd
			force = math.max(-self.characterdata.jumpforce - self.characterdata.jumpforceadd, force)
			if self.water then
				force = force/3
			end
			self.speedy = force
			self.jumping = true
			self.animationstate = "jumping"
			self:setquad()
			if noupdate or not self.controlsenabled or not jumpkey(self.playernumber) then
				self:stopjump()
			elseif jumpkey(self.playernumber) then
				--noteblock warp
				local t = map[self.noteblock[1]][self.noteblock[2]][2]
				if t and entityquads[t] and entityquads[t].t == "pipe" then
					self:noteblockwarp(self.noteblock[1], self.noteblock[2], map[self.noteblock[1]][self.noteblock[2]][3])
					return
				end
			end
			local t = 0.5 --amount of time block is non-collidable (should be amount of time it takes to jump out of range)
			if self.water then
				t = 0.6
			end
			local x1 = self.noteblock[1]
			if (bounceyoffsetright and bounceyoffsetright == bounceyoffset) and self.x+self.width/2 > self.noteblock[1] then
				x1 = x1 + 1
			elseif (bounceyoffsetleft and bounceyoffsetleft == bounceyoffset) and self.x+self.width/2 < self.noteblock[1]-1 then
				x1 = x1 - 1
			end
			self.noteblock2 = {x1, self.noteblock[2], t}
			self.noteblock = false
		else --bounce with block (tile entity doesn't actually move so this is complicated)
			self.y = self.noteblock[2]-1-self.height-bounceyoffset
			--self.x = math.max(self.noteblock[1]-1-self.width, math.min(self.noteblock[1], self.x))
			if self.x+self.width > self.noteblock[1] and inmap(self.noteblock[1]+1, self.noteblock[2])
				and tilequads[map[self.noteblock[1]+1][self.noteblock[2]][1]]["collision"] 
				and not (bounceyoffsetright and bounceyoffsetright == bounceyoffset) then
				self.x = self.noteblock[1]-self.width
			elseif self.x < self.noteblock[1]-1 and inmap(self.noteblock[1]-1, self.noteblock[2])
				and tilequads[map[self.noteblock[1]-1][self.noteblock[2]][1]]["collision"]
				and not (bounceyoffsetleft and bounceyoffsetleft == bounceyoffset) then
				self.x = self.noteblock[1]-1
			end
			if ((self.x > self.noteblock[1] and not (bounceyoffsetright and bounceyoffsetright == bounceyoffset))
				or (self.x < self.noteblock[1]-1-self.width and not (bounceyoffsetleft and bounceyoffsetleft == bounceyoffset))) then
				self.noteblock = false
				self:stopjump()
				return
			end
			self.gravity = 0
			self.speedy = 0
			--friction
			local maxrunspeed = self.characterdata.maxrunspeed
			if self.speedx > 0 then
				if self.speedx > maxrunspeed then
					self.speedx = self.speedx - self.superfriction*dt
				else	
					self.speedx = self.speedx - self.friction*dt
				end
				if self.speedx < self.minspeed then
					self.speedx = 0
					self.runframe = 1
					self.animationstate = "idle"
				end
			else
				if self.speedx < -maxrunspeed then
					self.speedx = self.speedx + self.superfriction*dt
				else	
					self.speedx = self.speedx + self.friction*dt
				end
				if self.speedx > -self.minspeed then
					self.speedx = 0
					self.runframe = 1
					self.animationstate = "idle"
				end
			end
			self.animationstate = "idle"
			self:setquad()
			return
		end
	end
	if self.noteblock2 then
		--[[self.noteblock2[3] = self.noteblock2[3] - dt
		if self.noteblock2[3] < 0 then
			self.noteblock2 = false
		end]]
		if not aabb(self.x, self.y, self.width, self.height, self.noteblock2[1]-1, self.noteblock2[2]-1, 1, 1) then --is it in range?
			self.noteblock2 = false
		end
	end
	
	
	
	--mazegate
	local x = math.floor(self.x+self.width/2)+1
	local y = math.floor(self.y+self.height/2)+1
	if inmap(x, y) and map[x][y][2] and entityquads[map[x][y][2]] and entityquads[map[x][y][2]].t == "mazegate" then
		if map[x][y][3] == self.mazevar + 1 then
			self.mazevar = self.mazevar + 1
		elseif map[x][y][3] == self.mazevar then
			
		else
			self.mazevar = 0
		end
	end
	
	--axe
	local x = math.floor(self.x+self.width/2)+1
	local y = math.floor(self.y+self.height/2)+1
	
	if axex and x == axex and y == axey then
		self:axe()
	end
	
	if self.controlsenabled then
		if self.jumping then
			local grav = self.characterdata.yaccelerationjumping
			--GRAVITY SETTING
			if self.shoe == "cloud" then
				grav = 0
			elseif self.size == -1 then
				grav = self.characterdata.tinymariogravityjumping
			elseif self.size == 12 then
				grav = self.characterdata.skinnymariogravity
			end
			if self.water then
				self.gravity = self.characterdata.uwyaccelerationjumping
			else
				self.gravity = grav
			end
			
			if (self.gravitydir == "down" and self.speedy > 0) or (self.gravitydir == "up" and self.speedy < 0)
			or (self.gravitydir == "right" and self.speedx > 0) or (self.gravitydir == "left" and self.speedx < 0) then
				self.jumping = false
				self.falling = true
			end
		else
			local grav = self.characterdata.yacceleration
			if self.shoe == "cloud" then
				grav = 0
			elseif self.size == -1 then
				grav = self.characterdata.tinymariogravity
			end
			
			if self.water then
				self.gravity = self.characterdata.uwyacceleration
			else
				self.gravity = grav
			end
		end
		
		--check for pipe pipe pipe
		if downkey(self.playernumber) and self.falling == false and self.jumping == false then
			for i, p in pairs(pipes) do
				if p:inside("down", math.floor(self.y+self.height+20/16), self) then
					self:pipe(p.cox, p.coy, "down", i)
					net_action(self.playernumber, "pipe|" .. p.cox .. "|" .. p.coy .. "|down|" .. i)
					return
				end
			end
		end
		
		--door
		if inmap(x, y) and #map[x][y] > 1 and entityquads[map[x][y][2]] and entityquads[map[x][y][2]].t == "door" and self.controlsenabled and (not editormode) and upkey(self.playernumber) and self.falling == false and self.jumping == false then
			self:door(x, y, map[x][y][3])
			net_action(self.playernumber, "door|" .. x .. "|" .. y .. "|" .. map[x][y][3])
			return
		end
		
		--ice
		self.ice = false
		if self.tileice then --moving tiles i guess
			self.ice = true; self.tileice = nil
		end
		if (inmap(math.floor(self.x+1+self.width), math.floor(self.y+self.height+20/16)) or inmap(math.floor(self.x+1), math.floor(self.y+self.height+20/16))) and self.falling == false and self.jumping == false then
			local t, t2
			local cox, coy = math.floor(self.x+1), math.floor(self.y+self.height+20/16)
			local cox2 = math.floor(self.x+1+self.width)
			if (self.size == 8 or self.size == 16) then
				cox2 = math.floor(self.x+1+self.width/2)
			end
			if inmap(cox, coy) then
				t = map[cox][coy]
			end
			if inmap(cox2, coy) then
				t2 = map[cox2][coy]
			end
			if (t and ((t[2] and entityquads[t[2]] and entityquads[t[2]].t == "ice") or (t[1] and tilequads[t[1]] and tilequads[t[1]]:getproperty("ice", cox, coy)))) or
				(t2 and ((t2[2] and entityquads[t2[2]] and entityquads[t2[2]].t == "ice") or (t2[1] and tilequads[t2[1]] and tilequads[t2[1]]:getproperty("ice", cox2, coy)))) or
				objects["frozencoin"][tilemap(cox, coy)] or objects["frozencoin"][tilemap(cox2, coy)] then
				self.ice = true
				if not (self.size == 14 and self.ducking) then
					self.friction = self.characterdata.icefriction
				end
				if self.animationstate == "sliding" then
					if skidsound:isStopped() then
						playsound(skidsound)
					end
				end
			end
		end
		if (not self.ice) and self.friction == self.characterdata.icefriction then
			if size == 5 then --frog physics
				self.friction = 100
			else
				self.friction = self.characterdata.friction
			end
		end
		
		self:updateangle()
		
		--Portaldots
		self.portaldotstimer = self.portaldotstimer + dt
		while self.portaldotstimer > portaldotstime do
			self.portaldotstimer = self.portaldotstimer - portaldotstime
		end
		
		if self.size == 9 then --tanooki statue
			if (not self.ducking) and (not self.shoe) and (not self.yoshi) and downkey(self.playernumber) then
				if (not self.statue) and runkey(self.playernumber) then
					if self.statuetimer == false then
						self:statued(true)
						self.statuetimer = 8
					end
				end
				if self.statuetimer and self.statuetimer > 0 then
					self.statuetimer = self.statuetimer - dt
					if self.statuetimer < 0 then
						self:statued(false)
					end
				end
			else
				if self.statue then
					self:statued(false)
				end
				self.statuetimer = false
			end
		end
		
		if self.falling == false and self.jumping == false and self.groundpounding == false then
			if self.shoe == "drybonesshell" then
				if downkey(self.playernumber) then
					if self.ducking == false and (not self.lavasurfing) and (not self.risingwater) then
						self:drybonesduck(true)
					end
				elseif self.ducking and (not self.lavasurfing) and self.drybonesshelltimer > 0.8 then
					self.drybonesshelltimer = 0.8
				end
			elseif (self.size > 1 or self.characterdata.smallducking) and self.size ~= 5 and self.size ~= 8 and (self.size ~= 16 or self.characterdata.smallduckingframes > 0) and not self.shoe and not self.statue and not ((SERVER or CLIENT) and self.playernumber ~= 1) then
				if downkey(self.playernumber) then
					if self.ducking == false and (not (self.frog and self.water)) and (not (self.size == 14 and (self.pickup or self.helmet or self.shoe))) then
						self:duck(true)
					end
				elseif not (self.blueshelled and runkey(self.playernumber)) then
					if self.ducking then
						self:duck(false, nil, nil, "playercontrols")
					end
				end
			end
		end
		self.quicksand = false --stop checking for quicksand unducking

		if self.drybonesshellcooldown then
			self.drybonesshellcooldown = self.drybonesshellcooldown - dt
			if self.drybonesshellcooldown < 0 then
				self.drybonesshellcooldown = nil
			end
		end
		if self.shoe == "drybonesshell" and self.drybonesshelltimer > 0 then
			self.drybonesshelltimer = self.drybonesshelltimer - dt
			if self.drybonesshelltimer < 0 then
				if downkey(self.playernumber) then
					self.drybonesshellcooldown = 0.5
				end
				self:drybonesduck(false)
			end
		end

		--redseesaw falling
		if self.redseesaw and self.redseesaw < 0 then
			self.falloverride = false
			self.redseesaw = false
			self:startfall()
		end
		if self.falloverride then
			if type(self.falloverride) == "number" then --start falling after a few frames
				self.falloverride = self.falloverride - 1
				if self.falloverride <= 0 then
					self.falloverride = false
					self:startfall()
				end
			end
		end
		if self.falloverridestrict then
			if type(self.falloverridestrict) == "number" then --start falling after a few frames
				self.falloverridestrict = self.falloverridestrict - 1
				if self.falloverridestrict <= 0 then
					self.falloverridestrict = false
					self:startfall()
				end
			end
		end
		if self.redseesaw then
			self.redseesaw = self.redseesaw - dt
		end
		
		--self.water = underwater
		if not underwater then
			local x = math.floor(self.x+self.width/2)+1
			local y = math.floor(self.y+self.height/2)+1
			
			if inmap(x, y) then
				if tilequads[map[x][y][1]]:getproperty("water", x, y) then
					if not self.water then
						self:dive(true)
					end
				else
					if self.water and not self.swimwing and not self.risingwater then
						self:dive(false)
					end
				end
			else
				if self.water and not self.swimwing and not self.risingwater then
					self:dive(false)
				end
			end
		end
		self.risingwater = false
		
		if self.water == false then
			self:movement(dt)
		else
			self:underwatermovement(dt)
		end
		
		--lava
		local y2 = math.floor(self.y)+1
		if inmap(x, y) and tilequads[map[x][y][1]]:getproperty("lava", x, y) then
			if tilequads[map[x][y][1]]:getproperty("water", x, y) or tilequads[map[x][y][1]].spikesleft or tilequads[map[x][y][1]].spikesright or tilequads[map[x][y][1]].spikesup or tilequads[map[x][y][1]].spikesdown then
				if not (self.invincible or self.starred) then
					self:die("Enemy (floorcollide)")
				end
			else
				self:die("lava")
			end
		elseif self.height > 1 and inmap(x, y2) and tilequads[map[x][y2][1]]:getproperty("lava", x, y2) then
			if tilequads[map[x][y2][1]]:getproperty("water", x, y2) or tilequads[map[x][y2][1]].spikesleft or tilequads[map[x][y][1]].spikesright or tilequads[map[x][y2][1]].spikesup or tilequads[map[x][y2][1]].spikesdown then
				if not (self.invincible or self.starred) then
					self:die("Enemy (floorcollide)")
				end
			else
				self:die("lava")
			end
		end
		
		--vine tiles
		if (not self.vine) and (not self.yoshi) and self.size ~= 8 and self.size ~= 16 then
			local x = math.floor(self.x+self.width/2)+1
			local y = math.floor(self.y+self.height/2)+1
			if inmap(x, y) and tilequads[map[x][y][1]].vine then
				if aabb(self.x, self.y, self.width, self.height, (x-1)+(3/16), y-1, 10/16, 1) then
					self:grabvine({istile = true, cox = x, coy = y, x = (x-1)+(3/16), y = y-1, width = 10/16, height = 1})
				end
			end
		end
		
		if self.gravitydir == "up" and self.y < 0 then
			self:die("pit")
		elseif (self.gravitydir == "left" or self.gravitydir == "right") and (self.y < 0 or self.y >= mapheight) then
			self:die("pit")
		elseif self.y >= mapheight then
			self:die("pit")
		elseif flagx and self.x+self.width >= flagx+6/16 and (flagborder or (self.x <= flagx+10/16 and self.y < flagy+1)) and self.y > flagy-10.8 then
			self:flag()
		end
		
		if firestartx and self.x >= firestartx - 1 then
			firestarted = true
		end
		
		if flyingfishstartx and self.x >= flyingfishstartx - 1 then
			flyingfishstarted = true
		end
		
		if flyingfishendx and self.x >= flyingfishendx - 1 then
			flyingfishstarted = false
		end
		
		if meteorstartx and self.x >= meteorstartx - 1 then
			meteorstarted = true
		end
		
		if meteorendx and self.x >= meteorendx - 1 then
			meteorstarted = false
		end
		
		if bulletbillstartx and self.x >= bulletbillstartx - 1 then
			bulletbillstarted = true
		end
		
		if bulletbillendx and self.x >= bulletbillendx - 1 then
			bulletbillstarted = false
		end
		
		if windstartx and self.x >= windstartx - 1 then
			windstarted = true
		end
		
		if windendx and self.x >= windendx - 1 then
			windstarted = false
		end
		
		if lakitoendx and self.x >= lakitoendx then
			lakitoend = true
		end
		
		if angrysunendx and self.x >= angrysunendx then
			angrysunend = true
		end
	else
		if not self.underwater then
			self:movement(dt)
		else
			self:underwatermovement(dt)
		end
	end
	
	--checkpoints
	local checkx = checkpoints[checkpointi+1]
	if checkx then
		local linked = (checkpointpoints[checkx] and #map[checkx][checkpointpoints[checkx]] > 2) --is it linked?
		if not linked and self.x > checkx then
			checkpointi = checkpointi + 1
			checkpointx = checkpoints[checkpointi]
			checkpointsublevel = actualsublevel
		end
	end
	
	--drains
	local x = math.floor(self.x+self.width/2)+1
	
	if inmap(x, mapheight) and #map[x][mapheight] > 1 and map[x][mapheight][2] and entityquads[map[x][mapheight][2]].t and entityquads[map[x][mapheight][2]].t == "drain" then
		if self.speedy < drainmax then
			if self.frog then --frog
				self.speedy = math.min( drainmax, math.max(-3, self.speedy + drainspeed*.8*dt))
			else
				self.speedy = math.min( drainmax, self.speedy + drainspeed*dt)
			end
		end
	end
	
	self:setquad()
end

function mario:updateangle()
	--UPDATE THE PLAYER ANGLE
	if (self.portalgun == false) and (not self.characterdata.aimwithoutportalgun) and (not (playertype and playertype == "minecraft")) then
		--just point in direction facing
		if self.gravitydir == "left" then
			if self.animationdirection == "left" then
				self.pointingangle = 0
			else
				self.pointingangle = math.pi
			end
		elseif self.gravitydir == "right" then
			if self.animationdirection == "right" then
				self.pointingangle = 0
			else
				self.pointingangle = math.pi
			end
		else
			if upkey(self.playernumber) then
				self.pointingangle = 0
			elseif downkey(self.playernumber) and (self.size == 1 or self.size == -1) then
				self.pointingangle = math.pi
			elseif self.animationdirection == "left" then
				self.pointingangle = math.pi/2
			else
				self.pointingangle = -math.pi/2
			end
		end
		return
	end

	if self.disableaiming then
		return false
	end
	
	if self.playernumber == mouseowner then
		local scale = scale
		if shaders and shaders.scale then scale = shaders.scale end
		self.pointingangle = math.atan2(self.x+self.portalsourcex-xscroll-(love.mouse.getX()/screenzoom/16/scale), (self.y+self.portalsourcey-yscroll-.5)-(love.mouse.getY()/screenzoom/16/scale))
	elseif #controls[self.playernumber]["aimx"] > 0 then
		local x, y
		
		local s = controls[self.playernumber]["aimx"]
		if s[1] == "joy" then
			x = -love.joystick.getAxis(s[2], s[4])
			if s[5] == "neg" then
				x = -x
			end
		end
		
		s = controls[self.playernumber]["aimy"]
		if s[1] == "joy" then
			y = -love.joystick.getAxis(s[2], s[4])
			if s[5] == "neg" then
				y = -y
			end
		end
		
		if not x or not y then
			return
		end
		
		if math.abs(x) > joystickaimdeadzone or math.abs(y) > joystickaimdeadzone then
			self.pointingangle = math.atan2(x, y)
			if self.pointingangle == 0 then
				self.pointingangle = 0 --this is really silly, but will crash the game if I don't do this. It's because it's -0 or something. I'm not good with computers.
			end
		end
	end
end

function mario:movement(dt)
	local maxrunspeed = self.characterdata.maxrunspeed
	local maxwalkspeed = self.characterdata.maxwalkspeed
	local runacceleration = self.characterdata.runacceleration
	local walkacceleration = self.characterdata.walkacceleration
	--Orange gel & ice
	--not in air
	if self.falling == false and self.jumping == false then
		local orangegel = false
		local bluegel = false
		--bottom on grid
		if math.fmod(self.y+self.height, 1) == 0 then
			local x = round(self.x+self.width/2+.5)
			local y = self.y+self.height+1
			--x and y in map
			if inmap(x, y) then
				--top of block orange
				if map[x][y]["gels"]["top"] == 2 then
					orangegel = true
				elseif map[x][y]["gels"]["top"] == 1 then--run gel jump
					bluegel = true
				end
			end
		end
		
		--On Lightbridge
		local x = round(self.x+self.width/2+.5)
		local y = round(self.y+self.height+1)
		
		for i, v in pairs(objects["lightbridgebody"]) do
			if x == v.cox and y == v.coy and v.gels.top then
				if v.gels.top == 1 then
					bluegel = true
				elseif v.gels.top == 2 then
					orangegel = true
				end
			end
		end

		
		for i, v in pairs(objects["belt"]) do
			if y == v.y+1 then
				local id = v:getgel(math.floor(self.x+self.width/2)+1)
				if id == 1 then
					bluegel = true
				elseif id == 2 then
					orangegel = true
				end
			end
		end

		if orangegel then
			maxrunspeed = self.characterdata.gelmaxrunspeed
			maxwalkspeed = self.characterdata.gelmaxwalkspeed
			runacceleration = self.characterdata.gelrunacceleration
			walkacceleration = self.characterdata.gelwalkacceleration
		elseif bluegel then
			if self.gravitydir == "down" and math.abs(self.speedx) >= gelmaxwalkspeed then
				self.jumping = true
				self.falling = true
				self.animationstate = "jumping"
				self.speedy = -math.abs(self.speedx)/1.8
				self:setquad()
				return
			end
		end
		
		if self.ice then
			walkacceleration = self.characterdata.icewalkacceleration
			runacceleration = self.characterdata.icerunacceleration
		end
	end

	--Run animation
	if self.gravitydir == "left" or self.gravitydir == "right" then
		if self.animationstate == "running" then
			self:runanimation(dt, self.speedy)
		elseif self.animationstate == "floating" and self.float then
			self.floatanimationprogress = self.floatanimationprogress + (math.abs(10)+4)/5*dt*self.characterdata.runanimationspeed
			self.floatframe = math.floor(self.floatanimationprogress)
			while self.floatanimationprogress >= 4 do
				self.floatanimationprogress = self.floatanimationprogress - 3
			end
		end
	else
		if self.animationstate == "running" then
			self:runanimation(dt)
		elseif self.animationstate == "floating" and self.float then
			self.floatanimationprogress = self.floatanimationprogress + (math.abs(10)+4)/5*dt*self.characterdata.runanimationspeed
			self.floatframe = math.floor(self.floatanimationprogress)
			while self.floatanimationprogress >= 4 do
				self.floatanimationprogress = self.floatanimationprogress - 3
			end
		end
	end
		
	--HORIZONTAL MOVEMENT
	local runningkey = runkey(self.playernumber)
	local mariojumpkey = jumpkey(self.playernumber)
	local mariorightkey = rightkey(self.playernumber)
	local marioleftkey = leftkey(self.playernumber)
	if self.gravitydir == "right" then
		mariorightkey = leftkey(self.playernumber)
		marioleftkey = rightkey(self.playernumber)
	else
		mariorightkey = rightkey(self.playernumber)
		marioleftkey = leftkey(self.playernumber)
	end
	if android and editormode and (not autoscroll) then mariorightkey = false; marioleftkey = false end
	if self.reversecontrols then
		local oldmariorightkey = mariorightkey
		mariorightkey = marioleftkey
		marioleftkey = oldmariorightkey
	end
	local speedx, speedy = "speedx", "speedy"
	if self.gravitydir == "left" or self.gravitydir == "right" then
		speedx, speedy = "speedy", "speedx"
	end

	if self.size == 14 and self.ducking then --blueshell
		marioleftkey = false
		mariorightkey = false
		if self.speedx == 0 then
			self.blueshelled = false
		elseif self.friction == 0 then
			return
		end
	end
	if self.groundpounding then
		marioleftkey = false
		mariorightkey = false
	end

	--propeller box
	if self.controlsenabled and self.helmet == "propellerbox" then
		if mariojumpkey then
			if self.helmet == "propellerbox" and self.speedy > 5 and (not self.propellerjumped) and (not self.propellerjumping) and self.falling then
				self[speedy] = math.min(self[speedy], 8)
				self.propellerjumping = true
				self.animationstate = "jumping"
				self:setquad()
				playsound(propellersound)
			end
			if self.propellerjumping and self.propellertime < propellertime then
				self[speedy] = math.max(-propellerspeed, self[speedy] - propellerforce*dt)
				self.propellertime = self.propellertime + dt
			else
				self[speedy] = math.min(propellerfloatspeed, self[speedy])
			end
		end
	end
	
	
	if self.controlsenabled and self.shoe == "cloud" then
		if upkey(self.playernumber) and self.y > -4 then
			self.speedy = math.max(-cloudspeed, self.speedy - cloudacceleration*dt)
		elseif downkey(self.playernumber) then
			self.speedy = math.min(cloudspeed, self.speedy + cloudacceleration*dt)
		else
			if self.speedy > 0 then
				self.speedy = math.max(0, self.speedy - cloudacceleration*dt)
			elseif self.speedy < 0 then
				self.speedy = math.min(0, self.speedy + cloudacceleration*dt)
			end
		end
		if leftkey(self.playernumber) then
			self.speedx = math.max(-cloudspeed, self.speedx - cloudacceleration*dt)
			self.animationdirection = "left"
		elseif rightkey(self.playernumber) then
			self.speedx = math.min(cloudspeed, self.speedx + cloudacceleration*dt)
			self.animationdirection = "right"
		else
			if self.speedx > 0 then
				self.speedx = math.max(0, self.speedx - cloudacceleration*dt)
			elseif self.speedx < 0 then
				self.speedx = math.min(0, self.speedx + cloudacceleration*dt)
			end
		end
	elseif self.controlsenabled and self.capefly then
		if self.raccoonflydirection == "right" then
			self.speedx = self.characterdata.maxrunspeed
		else
			self.speedx = -self.characterdata.maxrunspeed
		end
	elseif self.controlsenabled and runningkey and self.size ~= 5 then --RUNNING
		if mariorightkey and not self.statue then --MOVEMENT RIGHT
			if self.jumping or self.falling then --IN AIR
				if self[speedx] < maxwalkspeed then
					if self[speedx] < 0 then
						self[speedx] = self[speedx] + self.characterdata.runaccelerationair*dt*self.characterdata.airslidefactor
					else
						self[speedx] = self[speedx] + self.characterdata.runaccelerationair*dt
					end
					
					self[speedx] = math.min(self[speedx], maxwalkspeed)
				elseif self[speedx] > maxwalkspeed and self[speedx] < maxrunspeed then
					if self[speedx] < 0 then
						self[speedx] = self[speedx] + self.characterdata.runaccelerationair*dt*self.characterdata.airslidefactor
					else
						self[speedx] = self[speedx] + self.characterdata.runaccelerationair*dt
					end
					
					self[speedx] = math.min(self[speedx], maxrunspeed)
				end
					
			elseif self.ducking == false then --ON GROUND
				if self[speedx] < 0 then
					if self[speedx] > maxrunspeed then
						self[speedx] = self[speedx] + self.superfriction*dt + runacceleration*dt
					else
						self[speedx] = self[speedx] + self.friction*dt + runacceleration*dt
					end
					self.animationstate = "sliding"
					if currentphysics == 3 or currentphysics == 4 or self.characterdata.skid then
						if skidsound:isStopped() then
							playsound(skidsound)
						end
					end
				else
					self[speedx] = self[speedx] + runacceleration*dt
					self.animationstate = "running"
				end
				if self.gravitydir == "right" then
					self.animationdirection = "left"
				else
					self.animationdirection = "right"
				end
				
				self[speedx] = math.min(self[speedx], maxrunspeed)
				if self.size == 14 and self[speedx] == maxrunspeed and (not self.shoe) and (not self.pickup) and (not self.helmet) then --get into blueshell
					self:duck(true)
				end
				if self.shoe and self.shoe ~= "yoshi" and self[speedy] == 0 then --goomba shoe
					self[speedy] = -goombashoehop; if self.shoe == "heel" then playsound(heelsound); heelsound:setPitch(1+(math.random(1,10)/20-.25)) end
				end
			end
			
		elseif marioleftkey and not self.statue then --MOVEMENT LEFT
			if self.jumping or self.falling then --IN AIR
				if self[speedx] > -maxwalkspeed then
					if self[speedx] > 0 then
						self[speedx] = self[speedx] - self.characterdata.runaccelerationair*dt*self.characterdata.airslidefactor
					else
						self[speedx] = self[speedx] - self.characterdata.runaccelerationair*dt
					end
					
					self[speedx] = math.max(self[speedx], -maxwalkspeed)
				elseif self[speedx] < -maxwalkspeed and self[speedx] > -maxrunspeed then
					if self[speedx] > 0 then
						self[speedx] = self[speedx] - self.characterdata.runaccelerationair*dt*self.characterdata.airslidefactor
					else
						self[speedx] = self[speedx] - self.characterdata.runaccelerationair*dt
					end
					
					self[speedx] = math.max(self[speedx], -maxrunspeed)
				end
				
			elseif self.ducking == false then --ON GROUND
				if self[speedx] > 0 then
					if self[speedx] < -maxrunspeed then
						self[speedx] = self[speedx] - self.superfriction*dt - runacceleration*dt
					else
						self[speedx] = self[speedx] - self.friction*dt - runacceleration*dt
					end
					self.animationstate = "sliding"
					if currentphysics == 3 or currentphysics == 4 or self.characterdata.skid then
						if skidsound:isStopped() then
							playsound(skidsound)
						end
					end
				else
					self[speedx] = self[speedx] - runacceleration*dt
					self.animationstate = "running"
				end
				if self.gravitydir == "right" then
					self.animationdirection = "right"
				else
					self.animationdirection = "left"
				end
				
				self[speedx] = math.max(self[speedx], -maxrunspeed)
				if self.size == 14 and self[speedx] == -maxrunspeed and (not self.shoe) and (not self.pickup) and (not self.helmet) then --get into blueshell
					self:duck(true)
				end
				if self.shoe and self.shoe ~= "yoshi" and self[speedy] == 0 then --goomba shoe
					self[speedy] = -goombashoehop; if self.shoe == "heel" then playsound(heelsound); heelsound:setPitch(1+(math.random(1,10)/20-.25)) end
				end
			end
		end

		if (not mariorightkey and not marioleftkey) or (self.ducking and self.falling == false and self.jumping == false) or (not self.controlsenabled) then  --NO MOVEMENT
			if self.jumping or self.falling then
				if self[speedx] > 0 then
					self[speedx] = self[speedx] - self.frictionair*dt
					if self[speedx] < self.minspeed then
						self[speedx] = 0
						self.runframe = 1
					end
				else
					self[speedx] = self[speedx] + self.frictionair*dt
					if self[speedx] > -self.minspeed then
						self[speedx] = 0
						self.runframe = 1
					end
				end
			else
				if self[speedx] > 0 then
					if self[speedx] > maxrunspeed then
						self[speedx] = self[speedx] - self.superfriction*dt
					else	
						self[speedx] = self[speedx] - self.friction*dt
					end
					if self[speedx] < self.minspeed then
						self[speedx] = 0
						self.runframe = 1
						--self.animationstate = "idle"
					end
				else
					if self[speedx] < -maxrunspeed then
						self[speedx] = self[speedx] + self.superfriction*dt
					else
						self[speedx] = self[speedx] + self.friction*dt
					end
					if self[speedx] > -self.minspeed then
						self[speedx] = 0
						self.runframe = 1
						--self.animationstate = "idle"
					end
				end
			end
		end
		
	else --WALKING
		if self.controlsenabled and mariorightkey and not self.statue then --MOVEMENT RIGHT
			if self.jumping or self.falling then --IN AIR
				if self[speedx] < maxwalkspeed then
					if self[speedx] < 0 then
						self[speedx] = self[speedx] + self.characterdata.walkaccelerationair*dt*self.characterdata.airslidefactor
					else
						self[speedx] = self[speedx] + self.characterdata.walkaccelerationair*dt
					end
					
					self[speedx] = math.min(self[speedx], maxwalkspeed)
				end
			elseif self.ducking == false then --ON GROUND
				if self[speedx] < maxwalkspeed then
					if self[speedx] < 0 then
						if self[speedx] < -maxrunspeed then
							self[speedx] = self[speedx] + self.superfriction*dt + runacceleration*dt
						else
							self[speedx] = self[speedx] + self.friction*dt + runacceleration*dt
						end
						self.animationstate = "sliding"
					else
						self[speedx] = self[speedx] + walkacceleration*dt
						self.animationstate = "running"
					end
					if self.gravitydir == "right" then
						self.animationdirection = "left"
					else
						self.animationdirection = "right"
					end
					
					self[speedx] = math.min(self[speedx], maxwalkspeed)
				else
					self[speedx] = self[speedx] - self.friction*dt
					self[speedx] = math.max(self[speedx], maxwalkspeed)
				end
				if self.shoe and self.shoe ~= "yoshi" and self[speedy] == 0 then --goomba shoe
					self[speedy] = -goombashoehop; if self.shoe == "heel" then playsound(heelsound); heelsound:setPitch(1+(math.random(1,10)/20-.25)) end
				end
			end
			
		elseif self.controlsenabled and marioleftkey and not self.statue then --MOVEMENT LEFT
			if self.jumping or self.falling then --IN AIR
				if self[speedx] > -maxwalkspeed then
					if self[speedx] > 0 then
						self[speedx] = self[speedx] - self.characterdata.walkaccelerationair*dt*self.characterdata.airslidefactor
					else
						self[speedx] = self[speedx] - self.characterdata.walkaccelerationair*dt
					end
					
					self[speedx] = math.max(self[speedx], -maxwalkspeed)
				end
			elseif self.ducking == false then --ON GROUND
				if self[speedx] > -maxwalkspeed then
					if self[speedx] > 0 then
						if self[speedx] > maxrunspeed then
							self[speedx] = self[speedx] - self.superfriction*dt - runacceleration*dt
						else
							self[speedx] = self[speedx] - self.friction*dt - runacceleration*dt
						end
						self.animationstate = "sliding"
					else
						self[speedx] = self[speedx] - walkacceleration*dt
						self.animationstate = "running"
					end
					if self.gravitydir == "right" then
						self.animationdirection = "right"
					else
						self.animationdirection = "left"
					end
					
					self[speedx] = math.max(self[speedx], -maxwalkspeed)
				else
					self[speedx] = self[speedx] + self.friction*dt
					self[speedx] = math.min(self[speedx], -maxwalkspeed)
				end
				if self.shoe and self.shoe ~= "yoshi" and self[speedy] == 0 then
					self[speedy] = -goombashoehop; if self.shoe == "heel" then playsound(heelsound); heelsound:setPitch(1+(math.random(1,10)/20-.25)) end
				end
			end
		end
		if (not mariorightkey and not marioleftkey) or (self.ducking and self.falling == false and self.jumping == false) or (not self.controlsenabled) then --no movement
			if self.jumping or self.falling then
				if self[speedx] > 0 then
					self[speedx] = self[speedx] - self.frictionair*dt
					if self[speedx] < 0 then
						self[speedx] = 0
						self.runframe = 1
					end
				else
					self[speedx] = self[speedx] + self.frictionair*dt
					if self[speedx] > 0 then
						self[speedx] = 0
						self.runframe = 1
					end
				end
			else
				if self[speedx] > 0 then
					if self[speedx] > maxrunspeed then
						self[speedx] = self[speedx] - self.superfriction*dt
					else	
						self[speedx] = self[speedx] - self.friction*dt
					end
					if self[speedx] < 0 then
						self[speedx] = 0
						self.runframe = 1
						--self.animationstate = "idle"
					end
				else
					if self[speedx] < -maxrunspeed then
						self[speedx] = self[speedx] + self.superfriction*dt
					else	
						self[speedx] = self[speedx] + self.friction*dt
					end
					if self[speedx] > 0 then
						self[speedx] = 0
						self.runframe = 1
						--self.animationstate = "idle"
					end
				end
			end
		end
	end
end

function mario:runanimation(dt, speed, animationspeed)
	self.runanimationprogress = self.runanimationprogress + (math.abs(speed or self.speedx)+4)/5*dt*(animationspeed or self.characterdata.runanimationspeed)
	while self.runanimationprogress >= self.characterdata.runframes+1 do
		self.runanimationprogress = self.runanimationprogress - self.characterdata.runframes
	end
	self.runframe = math.floor(self.runanimationprogress)
	self:setquad()
end

function mario:underwatermovement(dt)
	local runningkey = runkey(self.playernumber)
	local mariojumpkey = jumpkey(self.playernumber)
	local mariorightkey = rightkey(self.playernumber)
	local marioleftkey = leftkey(self.playernumber)
	if self.gravitydir == "right" then
		mariorightkey = leftkey(self.playernumber)
		marioleftkey = rightkey(self.playernumber)
	else
		mariorightkey = rightkey(self.playernumber)
		marioleftkey = leftkey(self.playernumber)
	end
	if android and editormode and (not autoscroll) then mariorightkey = false; marioleftkey = false end
	if self.reversecontrols then
		local oldmariorightkey = mariorightkey
		mariorightkey = marioleftkey
		marioleftkey = oldmariorightkey
	end
	local speedx, speedy = "speedx", "speedy"
	if self.gravitydir == "left" or self.gravitydir == "right" then
		speedx, speedy = "speedy", "speedx"
	end

	if self.jumping or self.falling then
		--Swim animation
		if self.animationstate == "jumping" or self.animationstate == "falling" and not self.float then
			self.swimanimationprogress = self.swimanimationprogress + self.characterdata.runanimationspeed*dt
			while self.swimanimationprogress >= 3 do
				self.swimanimationprogress = self.swimanimationprogress - 2
			end
			self.swimframe = math.floor(self.swimanimationprogress)
		end
		if self.swimpush then
			local i = math.floor((self.swimpush-1)%3+1)
			if i == 1 then
				self.swimframe = math.floor(self.swimanimationprogress)
			elseif i == 2 then
				self.swimframe = 2+math.floor(self.swimanimationprogress)
			else
				if self.characterdata.swimpushframes >= 2 then
					self.swimframe = 4+math.floor(self.swimanimationprogress)
				else
					self.swimframe = 5
				end
			end
			self.swimpush = self.swimpush + self.characterdata.runanimationspeed*dt
			if self.swimpush >= 7 then
				self.swimpush = false
			end
		end
	else
		--Run animation
		if self.animationstate == "running" then
			self:runanimation(dt)
		end
	end
	
	--bubbles
	self.bubbletimer = self.bubbletimer + dt
	while self.bubbletimer > self.bubbletime do
		self.bubbletimer = self.bubbletimer - self.bubbletime
		self.bubbletime = bubblestime[math.random(#bubblestime)]
		table.insert(bubbles, bubble:new(self.x+8/12, self.y+2/12))
	end
	
	--HORIZONTAL MOVEMENT	
	if self.controlsenabled and mariorightkey and not self.statue and not (self.ducking and not (self.jumping or self.falling)) then --MOVEMENT RIGHT
		self.animationdirection = "right"
		if self.jumping or self.falling then --IN AIR
			if not self.frog then
				local max = self.characterdata.uwmaxairwalkspeed
				if self.size == 14 then
					max = self.characterdata.uwmaxairshellwalkspeed
				end
				if self[speedx] < max then
					if self[speedx] < 0 then
						self[speedx] = self[speedx] + self.characterdata.uwwalkaccelerationair*dt*self.characterdata.uwairslidefactor
					else
						self[speedx] = self[speedx] + self.characterdata.uwwalkaccelerationair*dt
					end
					
					if self[speedx] > max then
						self[speedx] = max
					end
				end
			end
		else --ON GROUND
			if self[speedx] < self.characterdata.uwmaxwalkspeed then
				if self[speedx] < 0 then
					if self[speedx] < -self.characterdata.uwmaxrunspeed then
						self[speedx] = self[speedx] + self.uwsuperfriction*dt + self.characterdata.uwrunacceleration*dt
					else
						self[speedx] = self[speedx] + self.uwfriction*dt + self.characterdata.uwrunacceleration*dt
					end
					self.animationstate = "sliding"
					self.animationdirection = "right"
				else
					self[speedx] = self[speedx] + self.characterdata.uwwalkacceleration*dt
					self.animationstate = "running"
					self.animationdirection = "right"
				end
				
				if self[speedx] > self.characterdata.uwmaxwalkspeed then
					self[speedx] = self.characterdata.uwmaxwalkspeed
				end
			else
				self[speedx] = self[speedx] - self.uwfriction*dt
				if self[speedx] < self.characterdata.uwmaxwalkspeed then
					self[speedx] = self.characterdata.uwmaxwalkspeed
				end
			end
		end
		
	elseif self.controlsenabled and marioleftkey and not self.statue and not (self.ducking and not (self.jumping or self.falling)) then --MOVEMENT LEFT
		self.animationdirection = "left"
		if self.jumping or self.falling then --IN AIR
			if not self.frog then
				local max = self.characterdata.uwmaxairwalkspeed
				if self.size == 14 then
					max = self.characterdata.uwmaxairshellwalkspeed
				end
				if self[speedx] > -max then
					if self[speedx] > 0 then
						self[speedx] = self[speedx] - self.characterdata.uwwalkaccelerationair*dt*self.characterdata.uwairslidefactor
					else
						self[speedx] = self[speedx] - self.characterdata.uwwalkaccelerationair*dt
					end
				
					if self[speedx] < -max then
						self[speedx] = -max
					end
				end
			end
		else --ON GROUND
			if self[speedx] > -self.characterdata.uwmaxwalkspeed then
				if self[speedx] > 0 then
					if self[speedx] > self.characterdata.uwmaxrunspeed then
						self[speedx] = self[speedx] - self.uwsuperfriction*dt - self.characterdata.uwrunacceleration*dt
					else
						self[speedx] = self[speedx] - self.uwfriction*dt - self.characterdata.uwrunacceleration*dt
					end
					self.animationstate = "sliding"
					self.animationdirection = "left"
				else
					self[speedx] = self[speedx] - self.characterdata.uwwalkacceleration*dt
					self.animationstate = "running"
					self.animationdirection = "left"
				end
				
				if self[speedx] < -self.characterdata.uwmaxwalkspeed then
					self[speedx] = -self.characterdata.uwmaxwalkspeed
				end
			else
				self[speedx] = self[speedx] + self.uwfriction*dt
				if self[speedx] > -self.characterdata.uwmaxwalkspeed then
					self[speedx] = -self.characterdata.uwmaxwalkspeed
				end
			end
		end
	
	else --NO MOVEMENT
		if self.jumping or self.falling then
			if self[speedx] > 0 then
				self[speedx] = self[speedx] - self.uwfrictionair*dt
				if self[speedx] < 0 then
					self[speedx] = 0
					self.runframe = 1
				end
			else
				self[speedx] = self[speedx] + self.uwfrictionair*dt
				if self[speedx] > 0 then
					self[speedx] = 0
					self.runframe = 1
				end
			end
		else
			if self[speedx] > 0 then
				if self[speedx] > self.characterdata.uwmaxrunspeed then
					self[speedx] = self[speedx] - self.uwsuperfriction*dt
				else	
					self[speedx] = self[speedx] - self.uwfriction*dt
				end
				if self[speedx] < 0 then
					self[speedx] = 0
					self.runframe = 1
					--self.animationstate = "idle"
				end
			else
				if self[speedx] < -self.characterdata.uwmaxrunspeed then
					self[speedx] = self[speedx] + self.uwsuperfriction*dt
				else	
					self[speedx] = self[speedx] + self.uwfriction*dt
				end
				if self[speedx] > 0 then
					self[speedx] = 0
					self.runframe = 1
					--self.animationstate = "idle"
				end
			end
		end
	end
	
	if self.y+self.height < uwmaxheight and underwater then
		self.speedy = uwpushdownspeed
	end
	
	if self.frog then --frog movement
		if (self.jumping or self.falling) then
			self.gravity = 0
			if not (upkey(self.playernumber) or downkey(self.playernumber)) then
				if self.speedy > 0 then
					self.speedy = math.max(self.speedy - 30*dt, 0)
				elseif self.speedy < 0 then
					self.speedy = math.min(self.speedy + 30*dt, 0)
				end
			end
		end
		
		if self.controlsenabled and downkey(self.playernumber) then
			self.speedy = math.min(self.speedy + 20*dt, 5)
			self.gravity = 0
			self.falling = true
			self.animationstate = "falling"
			self:setquad()
		end

		if self.controlsenabled and upkey(self.playernumber) then
			if self.y+self.height > uwmaxheight then
				self.speedy = math.max(self.speedy - 20*dt, -5)
			end
			self.gravity = 0
			self.jumping = true
			self.animationstate = "jumping"
			self:setquad()
		end
		
		if self.controlsenabled and leftkey(self.playernumber) and self.frog then
			if self.jumping or self.falling then
				self.gravity = 0
				self.speedx = -5
				self.falling = true
				self.animationstate = "falling"
				self:setquad()
			end
		elseif self.controlsenabled and rightkey(self.playernumber) and self.frog then
			if self.jumping or self.falling then
				self.speedx =  5
				self.gravity = 0
				self.falling = true
				self.animationstate = "falling"
				self:setquad()
			end
		end

		if leftkey(self.playernumber) or rightkey(self.playernumber) or downkey(self.playernumber) or upkey(self.playernumber) then
			if self.characterdata.swimpushframes > 0 then
				if (not self.swimpush) then 
					self.swimpush = 1
				end
			end
		end
	end
end

function mario:setquad(anim, s)
	local angleframe = getAngleFrame(self.pointingangle+self.rotation, self)
	if playertype == "minecraft" then
		angleframe = 5
	end
	
	if self.shoe then
		if self.yoshi then
			local animationstate = anim or self.animationstate
			local frameoffset = 0
			if self.yoshitoungeenemy then
				frameoffset = 6
			end
			if self.yoshiswallow then
				self.yoshiquad = yoshiquad[self.yoshi.color][12+self.yoshiswallowframe]
			elseif self.yoshitounge or self.yoshispitting then
				if animationstate == "jumping" then
					self.yoshiquad = yoshiquad[self.yoshi.color][1+frameoffset]
				else
					self.yoshiquad = yoshiquad[self.yoshi.color][7+frameoffset]
				end
			elseif self.water and (self.animationstate == "jumping" or self.animationstate == "falling") then
				self.yoshiquad = yoshiquad[self.yoshi.color][6+frameoffset]
			elseif animationstate == "running" or animationstate == "falling" then
				self.yoshiquad = yoshiquad[self.yoshi.color][(((self.runframe-1)%3)+1)+2+frameoffset]
			elseif animationstate == "idle" then
				self.yoshiquad = yoshiquad[self.yoshi.color][2+frameoffset]
			elseif animationstate == "sliding" then
				self.yoshiquad = yoshiquad[self.yoshi.color][3+frameoffset]
			elseif animationstate == "jumping" then
				self.yoshiquad = yoshiquad[self.yoshi.color][6+frameoffset]
			elseif animationstate == "climbing" then
				self.yoshiquad = yoshiquad[self.yoshi.color][6+frameoffset]
			elseif animationstate == "dead" then
				self.yoshiquad = yoshiquad[self.yoshi.color][6+frameoffset]
			elseif animationstate == "grow" then
				self.yoshiquad = yoshiquad[self.yoshi.color][2+frameoffset]
			else
				self.yoshiquad = yoshiquad[self.yoshi.color][2+frameoffset]
			end
		else
			self.animationstate = "idle"
			anim = "idle"
		end
	end
	local animationstate = anim or self.animationstate
	local size = s or self.size
	local t = self.characterdata
	
	local set = "big"
	local smallset = false --dying animation, no ducking, etc.
	if size == 1 or size == 16 then
		set = "small"
		smallset = true
	elseif size == -1 then
		set = "tiny"
	elseif size == 4 then
		set = "hammer"
	elseif size == 5 then
		set = "frog"
	elseif (size == 6 or size == 9) and (self.graphic == self.raccoongraphic or self.graphic == self.tanookigraphic) then
		set = "raccoon"
	elseif size == 10 and self.graphic == self.capegraphic then
		set = "cape"
	elseif size == 14 and self.graphic == self.shellgraphic then
		set = "shell"
	elseif size == 15 and self.graphic == self.boomeranggraphic then
		set = "boomerang"
	end

	if self.yoshi then
		self:setquadframe(set,angleframe,"climb",math.min(self.characterdata.climbframes or 2,2))
	elseif self.statue and set == "raccoon" then
		self:setquadframe(set,angleframe,"statue")
	elseif self.shoe then
		self:setquadframe(set,angleframe,"shoe")
	elseif self.fireenemyanim and t[set][self.fireenemyanim] and t[set][self.fireenemyanim][angleframe] then
		self:setquadframe(set,angleframe,self.fireenemyanim,self.fireenemyquadi)
	elseif self.groundpounding then
		if self.characterdata.groundpoundframes > 0 then
			self:setquadframe(set,angleframe,"groundpound")
		else
			self:setquadframe(set,angleframe,"climb",math.min(self.characterdata.climbframes or 2,2))
		end
	elseif self.capefly and set == "cape" then
		self:setquadframe(set,angleframe,"fly",self.capeflyframe)
	elseif self.spinanimationtimer < raccoonspintime and (set == "raccoon" or set == "cape") then
		self:setquadframe(set,angleframe,"spin",self.spinframez)
	elseif self.water and (self.animationstate == "jumping" or self.animationstate == "falling") then
		self:setquadframe(set,angleframe,"swim",self.swimframe)
	elseif self.ducking and ((not smallset) or self.characterdata.smallduckingframes > 0) then
		if set == "shell" then
			self:setquadframe(set,angleframe,"duck",self.blueshellframe)
		else
			self:setquadframe(set,angleframe,"duck")
		end
	elseif self.fireanimationtimer < fireanimationtime and ((not (smallset or set == "tiny")) or self.fireenemyfireanim) then
		if self.fireenemyfireanim then
			self:setquadframe(set,angleframe,self.fireenemyfireanim,self.fireenemyfirequadi)
		elseif t[set]["fire"] then
			self:setquadframe(set,angleframe,"fire")
		else
			if self.characterdata.idleframes > 1 then
				self:setquadframe(set,angleframe,"idleanim",self.idleframe)
			else
				self:setquadframe(set,angleframe,"idle")
			end
		end
	else
		if animationstate == "fence" then
			if self.characterdata.fenceframes > 0 then
				self:setquadframe(set,angleframe,"fence",self.fenceframe)
			else
				self:setquadframe(set,angleframe,"climb",self.fenceframe)
			end
		elseif (set == "raccoon" or set == "cape") and animationstate == "running" and self.planemode then
			self:setquadframe(set,angleframe,"runfast",self.runframe)
		elseif animationstate == "running" or animationstate == "falling" then
			self:setquadframe(set,angleframe,"run",self.runframe)
		elseif animationstate == "idle" then
			if self.characterdata.idleframes > 1 then
				self:setquadframe(set,angleframe,"idleanim",self.idleframe)
			else
				self:setquadframe(set,angleframe,"idle")
			end
		elseif animationstate == "sliding" then
			self:setquadframe(set,angleframe,"slide")
		elseif animationstate == "climbing" then
			self:setquadframe(set,angleframe,"climb",self.climbframe)
		elseif animationstate == "jumping" then
			if set == "cape" and self.raccoonfly then
				self:setquadframe(set,angleframe,"fire")
			elseif set == "raccoon" and self.raccoonfly then
				self:setquadframe(set,angleframe,"fly",self.raccoonflyframe)
			elseif self.characterdata.fallframes > 0 and self.falling and self.speedy > 0 then
				self:setquadframe(set,angleframe,"fall",self.fallframe)
			else
				self:setquadframe(set,angleframe,"jump",self.jumpframe)
			end
		elseif animationstate == "floating" and set == "raccoon" then
			self:setquadframe(set,angleframe,"float",self.floatframe)
		elseif animationstate == "custom" and t[set]["custom"] then
			self:setquadframe(set,angleframe,"custom",self.customframe or 1)
		--small exclusives
		elseif animationstate == "dead" and (smallset or set == "tiny") then
			self:setquadframe(set,angleframe,"die")
		elseif animationstate == "grow" and smallset then
			self:setquadframe(set,angleframe,"grow")
		elseif animationstate == "grownogun" and smallset then
			self:setquadframe(set,angleframe,"grownogun")
		end
	end
end

function mario:setquadframe(set, angleframe, anim, frame)
	local t = self.characterdata
	local q = t[set][anim][angleframe]
	if frame and type(q) == "table" then
		self.quad = q[frame or 1]
	else
		self.quad = q
	end
	self.quadanim = anim
	self.quadanimi = anim
	if hatoffsetindex[anim] then
		self.quadanimi = hatoffsetindex[anim]
	end
	self.quadframe = frame
end

function mario:jump(force)
	if self.disablejumping then --animationS
		return false	
	end

	if self.statue or self.capefly or self.clearpipe or self.groundpounding then
		return
	end

	if ((not noupdate or self.animation == "grow1" or self.animation == "grow2") and self.controlsenabled) or force then
		if self.cappy then
			self.cappy:jump()
		end
		if self.shoe == "cloud" then
			return
		end
		if self.raccoonfly and (self.size == 6 or self.size == 9) then --fly as raccoon Mario
			self.speedy = math.min(-self.characterdata.raccoonflyjumpforce, self.speedy)
		end		
		self.redseesaw = false
		
		if not self.water then
			if (self.gravitydir == "left" or self.gravitydir == "right") and self.speedx ~= 0 then
				return false
			else
				if self.spring then
					self.springhigh = true
					return
				end
				if self.vine and mariomakerphysics then
					if self.vineside == "right" then
						self.x = self.x+1/16
					else
						self.x = self.x-1/16
					end
					self:dropvine(self.vineside)
					self.falling = false
				end
				
				if self.fence then
					self:dropfence()
					self.fencejumptimer = fencejumptime
					self.falling = false
				end
				
				if self.shoe and (((not lowgravity) and (self.speedy > 8 or self.speedy < -goombashoehop)) or (lowgravity and (self.speedy > 4.5 or self.speedy < -goombashoehop))) then
					return
				elseif self.shoe == "drybonesshell" and self.ducking then
					return
				end
				
				--[[if self.capefly and self.speedy > 0 and self.capeflyframe < 5 and self.capeflyframe ~= 1 then
					self.capeflyframe = 1
					self.capeflybounce = false
					self.speedy = -30
				end]]
				
				if ( ((self.animation ~= "grow1" and self.animation ~= "grow2") or self.falling)
					and (self.falling == false or self.animation == "grow1" or self.animation == "grow2" or (self.shoe and (not self.yoshi) and self.landed)) )
					or ( (self.characterdata.doublejump or self.characterdata.dbljmppls) and (not self.hasdoublejumped) ) then
					if self.animation ~= "grow1" and self.animation ~= "grow2" and (not self.characterdata.nojumpsound) then
						if self.size == 1 then
							playsound(jumpsound)
						elseif self.size == -1 then
							playsound(jumptinysound)
						elseif self.size == 12 then
							playsound(jumpskinnysound)
						else
							playsound(jumpbigsound)
						end
					end

					if (self.characterdata.doublejump or self.characterdata.dbljmppls) and (self.falling or self.jumping) then
						--double jump
						self.hasdoublejumped = true
					end

					self.falloverride = false
					self.falloverridestrict = false
					
					local jumpforce, jumpforceadd = self.characterdata.jumpforce, self.characterdata.jumpforceadd
					if currentphysics == 7 then -- portal physics; jump one block
						jumpforce, jumpforceadd = portalphysicsjumpforce, portalphysicsjumpforceadd
					end
					local force = -jumpforce - (math.abs(self.speedx) / self.characterdata.maxrunspeed)*jumpforceadd
					if self.planemode == true and (self.size == 6 or self.size == 9) then --plane mode
						jumpforce, jumpforceadd = self.characterdata.raccoonjumpforce, self.characterdata.raccoonjumpforceadd
					end
					force = math.max(-jumpforce - jumpforceadd, force)

					if (self.size == 6 or self.size == 9 or self.size == 10) and self.planemode and (not self.shoe) then
						if self.size == 10 then
							self.speedy = -self.characterdata.capejumpforce
						else
							self.speedy = -self.characterdata.raccoonjumpforce
						end
						self.raccoonfly = true
						if self.speedx < 0 then
							self.raccoonflydirection = "left"
						else
							self.raccoonflydirection = "right"
						end
					elseif self.gravitydir == "down" then
						self.speedy = force
					elseif self.gravitydir == "up" then
						self.speedy = -force
					elseif self.gravitydir == "right" then
						self.speedx = force
					elseif self.gravitydir == "left" then
						self.speedx = -force
					end
					self.jumping = true
					self.landed = false
					self.animationstate = "jumping"
					self.jumpframe = 1
					self.jumpanimationprogress = 1
					self.fallframe = 1
					self.fallanimationprogress = 1
					self:setquad()

					--high blue gel jump
					if portalphysics then
						if self.gravitydir == "down" and inmap(math.floor(self.x+1+self.width/2), math.floor(self.y+self.height+20/16)) then
							local coy = math.floor(self.y+self.height+20/16)
							local t1, t2
							local cox1 = math.floor(self.x)+1
							local cox2 = math.floor(self.x+self.width)+1
							if (self.size == 8 or self.size == 16) then
								cox2 = math.floor(self.x+self.width/2)+1
							end
							if inmap(cox1, coy) then t1 = map[cox1][coy] end
							if inmap(cox2, coy) then t2 = map[cox2][coy] end
							local onlightbridge = false
							for j, w in pairs(objects["lightbridgebody"]) do
								if (cox1 == w.cox or cox2 == w.cox) and coy == w.coy and w.dir == "hor" and w.gels.top and w.gels.top == 1 then
									onlightbridge = true
									break
								end
							end
							if ((t1 and t1["gels"]["top"] == 1) or (t2 and t2["gels"]["top"] == 1)) or onlightbridge then
								self.speedy = -portalphysicsbluegelminforce
								self:stopjump()
							end
						end
					end
				end
			end
		else --swim
			if self.vine then
				if mariomakerphysics then
					if self.vineside == "right" then
						self.x = self.x+1/16
					else
						self.x = self.x-1/16
					end
					self:dropvine(self.vineside)
					self.falling = false
				else
					return
				end
			end
			if self.fence then
				self:dropfence()
				self.falling = false
			end
			if self.ducking then
				self:duck(false)
			end
			if not self.frog then --don't use bad swimming when frog mario
				playsound(swimsound)
				
				local speedx = self.speedx
				if self.gravitydir == "right" or self.gravitydir == "left" then
					speedx = self.speedy
				end
				local force = self.characterdata.uwjumpforce + (math.abs(speedx) / self.characterdata.maxrunspeed)*self.characterdata.uwjumpforceadd
				print(force)
				if self.gravitydir == "up" then
					self.speedy = force
				elseif self.gravitydir == "down" then
					self.speedy = -force
				elseif self.gravitydir == "right" then
					self.speedx = -force
				elseif self.gravitydir == "left" then
					self.speedx = force
				end

				self.jumping = true
				if self.characterdata.swimpushframes > 0 then
					if (not self.swimpush) then 
						self.swimpush = 1
					else
						self.swimpush = ((self.swimpush-1)%3)+1
					end
				end
				self.animationstate = "jumping"
				self:setquad()
			end
		end
		--check if upper half is inside block
		if self.size > 1 then
			local x = round(self.x+self.width/2+.5)
			local y = round(self.y)
			
			if inmap(x, y) and tilequads[map[x][y][1]]:getproperty("collision", x, y) then
				if getPortal(x, y) then
					--self.speedy = 0
					--self.jumping = false
					--self.falling = true
				else
					--self:ceilcollide("tile", objects["tile"][tilemap(x, y)], "player", self)
				end
			end
		end
	end
	
	if not noupdate and self.controlsenabled then
		if not self.water then
			if self.springgreen then
				self.springgreenhigh = true
				return
			end
		end
	end
	net_action(self.playernumber, "jump")
end

function mario:stopjump()
	if self.controlsenabled then
		if self.helmet == "propellerbox" and self.propellerjumping then
			self.propellerjumping = false
			self.propellerjumped = true
			self.propellertime = 0
			propellersound:stop()
		end
		if self.jumping == true then
			self.jumping = false
			self.falling = true
		end
	end
end

function mario:wag() --raccoon
	if self.controlsenabled then
		if (self.size == 6 or self.size == 9 or self.size == 11) then
			if not self.water and (not self.noteblock) and (not self.noteblock2) and
				not self.statue and not self.fence and not self.vine and not self.spring and not self.groundpounding then
				if self.falling and self.speedy >= 0 then
					self.float = true
					self.floattimer = 0
					if not self.raccoonfly then
						playsound(raccoonswingsound)
					end
				end
			end
		end
	end
end

function mario:rightkey()
	if self.controlsenabled and self.vine then
		if self.vineside == "left" then
			if self.size == -1 then --mini mario
				self.x = self.x + 2/16
			else
				self.x = self.x + 8/16
			end
			self.pointingangle = math.pi/2
			self.animationdirection = "left"
			self.vineside = "right"
		else
			self:dropvine("right")
		end
	end
end

function mario:leftkey()
	if self.controlsenabled and self.vine then
		if self.vineside == "right" then
			if self.size == -1 then --mini mario
				self.x = self.x - 2/16
			else
				self.x = self.x - 8/16
			end
			self.pointingangle = -math.pi/2
			self.animationdirection = "right"
			self.vineside = "left"
		else
			self:dropvine("left")
		end
	end
end

function mario:upkey()
	if not self.controlsenabled then
		return
	end
	--groundpound
	if self.groundpounding and (not self.groundpoundcanceled) and self.groundpounding > groundpoundtime then
		self:groundpound(false)
	end
	--pdoor and keydoor
	local x = math.floor(self.x+self.width/2)+1
	local y = math.floor(self.y+self.height/2)+1

	if inmap(x, y) and #map[x][y] > 1 and entityquads[map[x][y][2]] and (entityquads[map[x][y][2]].t == "pdoor" or entityquads[map[x][y][2]].t == "keydoor") and self.falling == false and self.jumping == false then
		for j, w in pairs(objects["doorsprite"]) do
			if w.cox == x and w.coy == y then
				if not w.locked then
					self:door(x, y, map[x][y][3])
					net_action(self.playernumber, "door|" .. x .. "|" .. y .. "|" .. map[x][y][3])
					return
				elseif w.i == "keydoor" and self.key and self.key > 0 then
					w:lock(false)
					net_action(self.playernumber, "upkey")
					self.key = self.key - 1
					if self.key < 1 then
						self.key = false
					end
				end
			end
		end
	end
	--fence
	if (not self.fence) and inmap(x, y) and tilequads[map[x][y][1]]:getproperty("fence", x, y) then
		self:grabfence()
	end
end

function mario:downkey()
	if not self.controlsenabled then
		return
	end
	--groundpound
	if (self.shoe == "drybonesshell" or self.characterdata.groundpound) and (not self.groundpounding) and (not self.ducking) and (not self.vine) and (not self.yoshi) and (not self.fence) then
		if (self.jumping or self.falling) and (not self.groundpoundcanceled) and (not editormode) and self.size ~= 9 and (not self.animation) then
			self:groundpound(true)
		end
	end
end

function mario:groundpound(pound)
	if pound then
		self.groundpoundcanceled = false
		self.groundpounding = 0
		self.static = true
		self.speedx = 0
		self.speedy = 0.0001
		playsound(groundpoundsound)
	else
		self.static = false
		self.groundpounding = false
		self.speedy = 0
		self.groundpoundcanceled = true
	end
end

function mario:grow(update)
	net_action(self.playernumber, "grow|" .. (update or "")) --netplay die
	if (CLIENT or SERVER) and self.playernumber > 1 and not self.netaction then --netplay grow
		return
	end
	
	if self.characterdata.health then
		playsound(mushroomeatsound)
		self.health = math.min(self.characterdata.health, self.health + 1)
		return false
	end
	if self.animation and self.animation ~= "invincible" and self.animation ~= "intermission" then
		return
	end
	self.animationmisc = self.animationstate
	addpoints(1000, self.x+self.width/2, self.y)
	if update and update == 12 then
		playsound(weirdmushroomsound)
	elseif update and (update == 4 or update == 5 or update == 6 or update == 9) then
		playsound(suitsound)
	elseif update and update == 13 then
		playsound(superballeatsound)
	elseif update and (update == 8 or update == 16) then
		playsound(mushroombigeatsound)
	else
		playsound(mushroomeatsound)
	end
	
	if mariomakerphysics and (not update) and self.size >= 2 then
		--mushroom doesn't make big mario grow
		return
	end

	if bigmario or ((self.size == 8 or self.size == 16) and ((not update) or (update ~= self.size))) then
		return
	end

	if self.animation == "intermission" then
		if update and (update > self.size or update == -1) then
			self:setsize(update)
			self:setquad()
			self.size = update
		end
		return
	end
	
	if self.size > 2 then
		if update then
			self.size = update
			self:setsize(update)
		end
	else
		if self.ducking then --stop small mario ducking
			self:duck(false)
		end
		local oldsize = self.size
		if ((self.size == 1 and (not update or (update == 3 and (not mariomakerphysics)))) or (self.size == 2 and not update)) and update ~= -1 and update ~= 8 and update ~= 12 and update ~= 16 then
			self.size = self.size + 1
		else
			self.size = update or 2
		end
		self:setsize(self.size)
		
		self.drawable = true
		self.invincible = false
		self.animationtimer = 0
		noupdate = true
		
		if self.size == 2 or self.size == -1 or (oldsize <= 1 and self.size == 12) then
			self.animation = "grow1"
		elseif (self.size == 8 or self.size == 16) then
			self.animation = false
			noupdate = false
		else
			self:setsize(2)
			self.animation = "grow2"
		end
		if self.size ~= 6 then
			raccoonplanesound:stop() --stops raccoon flying sound
		end
	end
end

function mario:shrink()
	raccoonplanesound:stop() --stops raccoon flying sound
	
	if self.animation then
		return
	end
	if self.characterdata.health then
		playsound(shrinksound)
		self.health = self.health - 1
		self.invincible = true
		self.animationtimer = 0
		self.animation = "invincible"
		if self.health <= 0 then
			self:die("time")
		end
		return false
	end
	self.animationmisc = self.animationstate
	
	playsound(shrinksound)

	if self.size == 2 or (self.size > 2 and (not mariomakerphysics)) then
		if self.ducking then --stop small mario ducking
			self:duck(false)
		end
	end
	
	if mariomakerphysics and self.size > 2 and self.size ~= 12 and self.size ~= 8 then --shrink to big mario
		self.size = 2
		self:setsize(2)
		self.color = self.basecolors
		self.invincible = true
		self.animationtimer = 0
		self.animation = "invincible"
		return
	end
	
	self.size = 1
	self:setsize(1)
	
	self.animation = "shrink"
	self.drawable = true
	self.invincible = true
	self.animationtimer = 0

	self.fireenemy = false
	
	noupdate = true
end	

function mario:setsize(size, oldsize)
	if self.characterdata.health then
		self.size = self.characterdata.defaultsize or 1
		size = self.characterdata.defaultsize or 1
	end
	local oldsize = oldsize or false
	local ducking = self.ducking
	if ducking then
		self:duck(false, oldsize, "dontmove")
	end
	if self.statue then
		self:statued(false)
	end
	local width, height = self.width, self.height
	self.animationscalex = false
	self.animationscaley = false
	
	self.portalsourcex = 6/16
	self.portalsourcey = 6/16

	self.weight = 1

	if size == 1 then --small mario
		width, height = 12/16, 12/16
		self.basecolors = mariocolors[self.playernumber]
		self.graphic = self.smallgraphic
		self.quadcenterX = self.characterdata.smallquadcenterX
		self.quadcenterY = self.characterdata.smallquadcenterY
		self.offsetX = self.characterdata.smalloffsetX
		self.offsetY = self.characterdata.smalloffsetY
		self.weight = .5
	elseif size == 2 then --big mario
		width, height = 12/16, 24/16
		self.basecolors = mariocolors[self.playernumber]
		self.graphic = self.biggraphic
		self.quadcenterX = self.characterdata.bigquadcenterX
		self.quadcenterY = self.characterdata.bigquadcenterY
		self.offsetX = self.characterdata.bigoffsetX
		self.offsetY = self.characterdata.bigoffsetY
	elseif size == 3 then --fire mario
		width, height = 12/16, 24/16
		self:setbasecolors("flowercolor")
		if self.firegraphic then
			self.graphic = self.firegraphic
		else
			self.graphic = self.biggraphic
		end
		self.quadcenterX = self.characterdata.bigquadcenterX
		self.quadcenterY = self.characterdata.bigquadcenterY
		self.offsetX = self.characterdata.bigoffsetX
		self.offsetY = self.characterdata.bigoffsetY
	elseif size == 4 then --hammer mario
		width, height = 12/16, 24/16
		self:setbasecolors("hammersuitcolor")
		self.graphic = self.hammergraphic
		self.quadcenterX = self.characterdata.hammerquadcenterX
		self.quadcenterY = self.characterdata.hammerquadcenterY
		self.offsetX = self.characterdata.hammeroffsetX
		self.offsetY = self.characterdata.hammeroffsetY
	elseif size == 5 then --frog mario
		width, height = 12/16, 18/16
		self:setbasecolors("frogsuitcolor")
		self.graphic = self.froggraphic
		self.quadcenterX = self.characterdata.frogquadcenterX
		self.quadcenterY = self.characterdata.frogquadcenterY
		self.offsetX = self.characterdata.frogoffsetX
		self.offsetY = self.characterdata.frogoffsetY
	elseif size == 6 then --raccoon mario
		width, height = 12/16, 24/16
		self.basecolors = mariocolors[self.playernumber]
		self.graphic = self.raccoongraphic
		self.quadcenterX = self.characterdata.raccoonquadcenterX
		self.quadcenterY = self.characterdata.raccoonquadcenterY
		self.offsetX = self.characterdata.raccoonoffsetX
		self.offsetY = self.characterdata.raccoonoffsetY
	elseif size == 7 then --ice mario
		width, height = 12/16, 24/16
		self:setbasecolors("iceflowercolor")
		if self.icegraphic then
			self.graphic = self.icegraphic
		else
			self.graphic = self.biggraphic
		end
		self.quadcenterX = self.characterdata.bigquadcenterX
		self.quadcenterY = self.characterdata.bigquadcenterY
		self.offsetX = self.characterdata.bigoffsetX
		self.offsetY = self.characterdata.bigoffsetY
	elseif size == 8 then --huge mario
		width, height = 36/16, 90/16
		self.basecolors = mariocolors[self.playernumber]
		self.graphic = self.biggraphic
		self.quadcenterX = self.characterdata.hugequadcenterX
		self.quadcenterY = self.characterdata.hugequadcenterY
		self.offsetX = self.characterdata.hugeoffsetX
		self.offsetY = self.characterdata.hugeoffsetY
		
		self.animationscalex = 3
		self.animationscaley = 3
		
		if not oldsize or oldsize ~= self.size then
			self.drawable = true
			self.invincible = false
			self.animationtimer = 0
			self:star()
		end

		if self.yoshi then
			self:shoed(false)
			self.yoshi = false
		end
		self.weight = 2
		self.portalsourcex = 18/16
		self.portalsourcey = 40/16
		if self.helmet and self.helmet == "cannonbox" then
			self:helmeted(false)
		end
		if self.fence then
			self:dropfence()
		end
	elseif size == 9 then --tanooki mario
		width, height = 12/16, 24/16
		self:setbasecolors("tanookisuitcolor")
		self.graphic = self.tanookigraphic
		self.quadcenterX = self.characterdata.raccoonquadcenterX
		self.quadcenterY = self.characterdata.raccoonquadcenterY
		self.offsetX = self.characterdata.raccoonoffsetX
		self.offsetY = self.characterdata.raccoonoffsetY
	elseif size == 10 then --cape mario
		width, height = 12/16, 24/16
		self.basecolors = mariocolors[self.playernumber]
		self.graphic = self.capegraphic
		self.quadcenterX = self.characterdata.capequadcenterX
		self.quadcenterY = self.characterdata.capequadcenterY
		self.offsetX = self.characterdata.capeoffsetX
		self.offsetY = self.characterdata.capeoffsetY
		self.capeframe = 1
		self.capeanim = 0
		self.capefly = false
		self.capeflyframe = 1
		self.capeflyanim = 0
	elseif size == 11 then --bunny mario
		width, height = 12/16, 24/16
		self.basecolors = mariocolors[self.playernumber]
		self.graphic = self.biggraphic
		self.quadcenterX = self.characterdata.bigquadcenterX
		self.quadcenterY = self.characterdata.bigquadcenterY
		self.offsetX = self.characterdata.bigoffsetX
		self.offsetY = self.characterdata.bigoffsetY
	elseif size == 12 then --skinny mario
		width, height = 12/16, 24/16
		self.basecolors = mariocolors[self.playernumber]
		self.graphic = self.skinnygraphic
		self.quadcenterX = self.characterdata.bigquadcenterX
		self.quadcenterY = self.characterdata.bigquadcenterY
		self.offsetX = self.characterdata.bigoffsetX
		self.offsetY = self.characterdata.bigoffsetY
	elseif size == 13 then --superball mario
		width, height = 12/16, 24/16
		self:setbasecolors("superballcolor")
		if self.superballgraphic then
			self.graphic = self.superballgraphic
		else
			self.graphic = self.biggraphic
		end
		self.quadcenterX = self.characterdata.bigquadcenterX
		self.quadcenterY = self.characterdata.bigquadcenterY
		self.offsetX = self.characterdata.bigoffsetX
		self.offsetY = self.characterdata.bigoffsetY
	elseif size == 14 then --blue shell mario
		width, height = 12/16, 24/16
		self:setbasecolors("blueshellcolor")
		self.graphic = self.shellgraphic
		self.quadcenterX = self.characterdata.shellquadcenterX
		self.quadcenterY = self.characterdata.shellquadcenterY
		self.offsetX = self.characterdata.shelloffsetX
		self.offsetY = self.characterdata.shelloffsetY
	elseif size == 15 then --boomerang mario
		width, height = 12/16, 24/16
		self:setbasecolors("boomerangcolor")
		self.graphic = self.boomeranggraphic
		self.quadcenterX = self.characterdata.boomerangquadcenterX
		self.quadcenterY = self.characterdata.boomerangquadcenterY
		self.offsetX = self.characterdata.boomerangoffsetX
		self.offsetY = self.characterdata.boomerangoffsetY
	elseif size == 16 then --classic huge mario
		width, height = 24/16, 24/16
		self.basecolors = mariocolors[self.playernumber]
		self.graphic = self.smallgraphic
		self.quadcenterX = self.characterdata.hugeclassicquadcenterX
		self.quadcenterY = self.characterdata.hugeclassicquadcenterY
		self.offsetX = self.characterdata.hugeclassicoffsetX
		self.offsetY = self.characterdata.hugeclassicoffsetY
		
		self.animationscalex = 2
		self.animationscaley = 2
		
		if not oldsize or oldsize ~= self.size then
			self.drawable = true
		end

		if self.yoshi then
			self:shoed(false)
			self.yoshi = false
		end
		self.weight = 2

		self.portalsourcex = 12/16
		self.portalsourcey = 10/16
		if self.helmet and self.helmet == "cannonbox" then
			self:helmeted(false)
		end
	elseif size == -1 then --tiny mario
		width, height = 6/16, 6/16
		self.basecolors = mariocolors[self.playernumber]
		self.graphic = self.tinygraphic
		self.quadcenterX = self.characterdata.tinyquadcenterX
		self.quadcenterY = self.characterdata.tinyquadcenterY
		self.offsetX = self.characterdata.tinyoffsetX
		self.offsetY = self.characterdata.tinyoffsetY
		
		self.portalsourcex = 3/16
		self.portalsourcey = 3/16

		if self.helmet then
			self:helmeted(false)
		end
	end

	--custom powerups
	if self.fireenemy then
		self.fireenemy = false
		--self.fireballcount = 0 --breaks some stuff
	end
	if self.dofireenemy then
		self.fireenemy = self.dofireenemy
		self.dofireenemy = false
	end
	if self.customcolors then
		self.basecolors = self.customcolors
		self.customcolors = false
	end

	self.colors = self.basecolors
	
	self.raccoonfly = false
	self.blueshelled = false
	self.frog = false
	if size == 5 then --frog physics
		self.superfriction = 100
		self.frictionair = self.characterdata.frictionair
		self.friction = self.characterdata.frogfriction
		self.uwfriction = 100
		self.uwsuperfriction = 100
		self.uwfrictionair = 10
		self.minspeed = self.characterdata.frogminspeed
		self.frog = true
	else
		self.superfriction = self.characterdata.superfriction
		self.frictionair = self.characterdata.frictionair
		self.friction = self.characterdata.friction
		self.uwfriction = self.characterdata.uwfriction
		self.uwsuperfriction = self.characterdata.uwsuperfriction
		self.uwfrictionair = self.characterdata.uwfrictionair
		self.minspeed = self.characterdata.minspeed
		if size == 14 then
			self.uwfrictionair = 10
		end
	end
	
	if (not oldsize or oldsize ~= self.size) and not bigmario then
		self.x = self.x + self.width/2 - width/2
		if self.gravitydir == "down" then
			self.y = self.y + self.height - height
		end
		self.width = width
		self.height = height
	end
	
	if ducking and (size > 1 or self.characterdata.smallducking) and size ~= 5 and size ~= 8 and size ~= 16 then
		self:duck(true, size)
	end
	
	if self.shoe then
		self:shoed(self.shoe)
	end
	if self.pointingangle then
		self:setquad(nil, size)
	end

	if self.supersized then
		supersizeentity(self)
	end
end

function mario:floorcollide(a, b)
	self.rainboomallowed = true
	if self.jumping and (a == "platform" or a == "seesawplatform" or a == "donut") and self.speedy < -self.characterdata.jumpforce + 0.1 then
		return false
	end

	local anim = self.animationstate
	local jump = self.jumping
	local fall = self.falling
	
	if self:globalcollide(a, b) then
		return false
	end
	
	if a == "spring" then
		if b.green then
			self:hitspringgreen(b)
		else
			self:hitspring(b)
		end
		return false
	elseif a == "smallspring" and b.dir == "ver" and b.speedy == 0 then
		self:hitspring(b)
		return false
	end

	if self.size == 14 and self.ducking then --blueshell
		if a ~= "spring" and a ~= "donut" and a ~= "springgreen" and a ~= "bigmole" and a ~= "muncher" and a ~= "koopaling" and a ~= "bowser" and b.shotted then
			if b.shotted and (not (b.resistsenemykill or b.resistseverything)) then
				if self.blueshelled then
					if self.combo < #koopacombo then
						self.combo = self.combo + 1
						addpoints(koopacombo[self.combo], b.x, b.y)
					else
						for i = 1, players do if mariolivecount ~= false then
								mariolives[i] = mariolives[i]+1
								respawnplayers()
						end end
						table.insert(scrollingscores, scrollingscore:new("1up", b.x, b.y))
						playsound(oneupsound)
					end
					b:shotted("left")
					return false
				else return true
				end
			end
		end
	end

	if a == "tile" then
		local x, y = b.cox, b.coy

		if self.gravitydir ~= "down" and map[x][y]["gels"]["top"] == 4 then
			if self.gravitydir == "left" then
				self.speedx = math.max(self.speedx,0)
			elseif self.gravitydir == "right" then
				self.speedx = math.min(self.speedx,0)
			end
		end

		--check for invisible block
		if tilequads[map[x][y][1]].invisible then
			self.jumping = jump
			self.falling = fall
			self.animationstate = anim
			return false
		end

		if (not editormode) then
			if bigmario and self.speedy > 2 then
				destroyblock(x, y)
				self.speedy = self.speedy/10
			elseif self.size == 16 and self.speedy > 2 and (not self.destroyedblock) then
				local x1, x2 = math.floor(self.x)+1, math.floor(self.x+self.width)+1
				for x = x1, x2 do
					if inmap(x, y) then
						if (tilequads[map[x][y][1]].breakable or (tilequads[map[x][y][1]].debris and blockdebrisquads[tilequads[map[x][y][1]].debris])) then
							destroyblock(x, y)
							self.speedy = -hugemarioblockbounceforce
							self.destroyedblock = true
						else
							hitblock(x, y, self)
							self.speedy = self.speedy/10
						end
					end
				end
				if self.destroyedblock then
					return true
				end
			elseif self.size == 8 and self.speedy > 2 then
				if (tilequads[map[x][y][1]].breakable or (tilequads[map[x][y][1]].debris and blockdebrisquads[tilequads[map[x][y][1]].debris])) then
					destroyblock(x, y)
				else
					hitblock(x, y, self)
				end
				self.speedy = self.speedy/10
			end
		end
		self.destroyedblock = nil

		self.combo = 1
		
		--spikes
		if tilequads[map[x][y][1]]:getproperty("spikesup", x, y) then
			if self.invincible or self.starred or self.yoshi or (self.shoe and self.shoe ~= "bigcloud") then
				--uh
			else			
				self:die("Enemy (floorcollide)")
			end
		end
		
		--lava
		if tilequads[map[x][y][1]].lava then
			self:die("lava")
		end
		
		--run gel jump
		if map[x][y]["gels"]["top"] == 1  and self.gravitydir == "down" and math.abs(self.speedx) >= gelmaxwalkspeed then
			self.jumping = true
			self.falling = true
			self.animationstate = "jumping"
			self.speedy = -math.abs(self.speedx)/1.8
			self:setquad()
			return false
		end

		--groundpound
		if self.groundpounding then
			if (not editormode) then
				if map[x][y][2] and entityquads[map[x][y][2]] and entityquads[map[x][y][2]].t == "manycoins" and (tilequads[map[x][y][1]].breakable or tilequads[map[x][y][1]].coinblock) and #coinblockanimations == 0 then
					if not getblockbounce(x, y) then
						hitblock(x, y, self)
					end
				elseif self.speedy > 0.01 and self.falling then
					hitblock(x, y, self)
				end
			end
			self:stopgroundpound()
		end
		
		--noteblock
		if tilequads[map[x][y][1]].noteblock then
			if (not self.noteblock) and (not portalintile(x, y)) then
				if (not intermission) and (not editormode) and self.controlsenabled then
					self.noteblock = {x, y}
					if self.float then
						self.floattimer = 0
						self.float = false
						self.ignoregravity = false
					end
				else
					local force = -self.characterdata.jumpforce - (math.abs(self.speedx) / self.characterdata.maxrunspeed)*self.characterdata.jumpforceadd
					force = math.max(-self.characterdata.jumpforce - self.characterdata.jumpforceadd, force)
					if self.water then
						force = force/3
					end
					self.speedy = force
					self.jumping = true
					self.animationstate = "jumping"
					self:setquad()
					self:stopjump()
				end
				if not self.portalgun then
					if self.speedx > 0 then
						self.animationdirection = "right"
					elseif self.speedx < 0 then
						self.animationdirection = "left"
					end
				end
				hitblock(x, y, self, {dir="down"})
				if self.x < x-1 then
					for x1 = math.floor(self.x)+1, x-1 do
						if inmap(x1, y) and tilequads[map[x1][y][1]].noteblock then
							hitblock(x1, y, self, {dir="down"})
						end
					end
				end
				if self.x+self.width > x then
					for x1 = x+1, math.floor(self.x+self.width)+1 do
						if inmap(x1, y) and tilequads[map[x1][y][1]].noteblock then
							hitblock(x1, y, self, {dir="down"})
						end
					end
				end
				return false
			--else
				--return true
			end
		end
		
		if self.gravitydir ~= "down" then
			self.gravitydir = "down"
		end
		
		if map[x][y]["gels"] then
			local t1, t2
			local cox1 = math.floor(self.x)+1
			local cox2 = math.floor(self.x+self.width)+1
			if (self.size == 8 or self.size == 16) then
				cox2 = math.floor(self.x+self.width/2)+1
			end
			if inmap(cox1, y) then t1 = map[cox1][y] end
			if inmap(cox2, y) then t2 = map[cox2][y] end
			if ((t1 and t1["gels"]["top"] == 1) or (t2 and t2["gels"]["top"] == 1)) and self:bluegel("top") then
				return false
			end
		end
	end
	
	--star logic
	if self.starred or bigmario or self.statue then
		if self:starcollide(a, b) then
			if b.solidkill then
				return true
			else
				return false
			end
		end
	end
	
	if self.gravitydir == "down" then
		self.falling = false
		self.jumping = false
		self.landed = true

		if self.helmet == "propellerbox" then
			self.propellerjumping = false
			self.propellerjumped = false
			self.propellertime = 0
		end
		
		if self.float then
			self.floattimer = 0
			self.float = false
			self.ignoregravity = false
		end
		
		if self.capefly then
			self.raccoonfly = false
			self.capefly = false
			self.planemode = false
			self.planetimer = 0
		end
		
		if ((self.shoe and self.shoe ~= "yoshi") or self.statue) and self.animation == "flag" then
			self.speedy = -goombashoehop
		end
	end
	
	--Make mario snap to runspeed if at walkspeed.
	--[[if leftkey(self.playernumber) then
		if runkey(self.playernumber) then
			if self.speedx <= -maxwalkspeed then
				self.speedx = -maxrunspeed
				self.animationdirection = "left"
			end
		end
	elseif rightkey(self.playernumber) then
		if runkey(self.playernumber) then
			if self.speedx >= maxwalkspeed then
				self.speedx = maxrunspeed
				self.animationdirection = "right"
			end
		end
	end--]]
	
	if a == "mushroom" or a == "oneup" or a == "star" or a == "flower" or a == "poisonmush" or a == "threeup" or a == "smbsitem" or a == "hammersuit" or a == "frogsuit" or a == "leaf" or (a == "boomerang" and b.fireballthrower) then
		self.falling = true
		return false
	elseif a == "enemy" then
		if b.ignoreceilcollide or b.dontstopmario then
			self.jumping = jump
			self.falling = fall
			self.animationstate = anim
			return false
		elseif b.stompable then
			if b.stompbounce or (b.stompbounceifsmall and self.size ~= 16) then--bounce off of enemy
				self:stompbounce(a, b)
			else
				self:stompenemy(a, b)
			end
			return false
		elseif b.kills or b.killsontop then
			if self.invincible then
				if b.solidkill then
					return true
				else
					return false
				end
			elseif self.shoe and (not b.resistsshoe) and ((not b.resistsstar) or (b.resistsstarnotshoe)) then		
				if b:shotted("right", false, false, false) ~= false then
					addpoints(b.firepoints or 200, self.x, self.y)
				end
				self:stompbounce(a, b)
				if b.solidkill then
					return true
				else
					return false
				end
			elseif self.shoe and (b.resistsshoe or b.resistseverything) and b.walkonwithshoe then
				return true
			else
				if b.instantkill then
					self:die("lava")
				else
					self:die("enemy")
				end
				if b.solidkill then
					return true
				else
					return false
				end
			end
		elseif b.removeonmariocontact and not b.removeonmariocontactcollide then
			return false
		elseif b.bouncy or b.bouncyontop then
			self.speedy = -(b.bouncyforcey or b.bouncyforce)
			self.falling = true
			return true
		end
		if fall then
			animationsystem_playerlandtrigger(self.playernumber)
		end
	elseif a == "levelball" then
		net_action(self.playernumber, "levelball")
		return false
	elseif a == "pedestal" then
		b:get(self)
		self.jumping = jump
		self.falling = fall
		self.animationstate = anim
		return false
	elseif a == "regiontrigger" then
		self.jumping = jump
		self.falling = fall
		self.animationstate = anim
		return false
	elseif a == "yoshi" then
		if (not self.yoshi) and (not self.shoe) and self.size ~= 8 and self.size ~= 16 and (not self.pickup) and (not bigmario) then
			self.yoshi = b
			self.groundpounding = false
			self:shoed("yoshi")
			b:ride(self)
		end
		return false
	elseif (a == "plantfire" or a == "brofireball" or a == "castlefirefire" or a == "fire") and self.size == 4 and self.ducking then
		self.jumping = jump
		self.falling = fall
		self.animationstate = anim
		return false
	elseif (a == "goomba" and b.t ~= "spikey" and  b.t ~= "spikeyfall" and b.t ~= "spiketop" and b.t ~= "bigspikey" and (b.t ~= "shyguy" or self.groundpounding)) or a == "bulletbill" or a == "flyingfish" or a == "lakito" or a == "hammerbro" or (a == "koopa" and b.t ~= "downspikey" and b.t ~= "spikeyshell") or a == "bigbill" or a == "cannonball" or a == "splunkin" or a == "bigkoopa" or (a == "drybones" and not b.spiked) or a == "ninji" or a == "mole" or (a == "bomb" and not b.explosion)
		or (a == "boomboom" and b.ducking == false and b.stomped == false) or (a == "squid" and b.color == "pink") or (a == "pokey" and b.t == "snowpokey") or a == "rockywrench" or (a == "koopaling" and b.stompable) or a == "magikoopa" or a == "spike" or (a == "spikeball" and b.stompable) or (a == "plantcreeper" and b.stompable) then
		if b.stompbounce or (b.stompbounceifsmall and self.size ~= 16) then--bounce off of enemy
			self:stompbounce(a, b)
		else
			self:stompenemy(a, b)
		end
		return false
	elseif a == "plant" or a == "bowser" or a == "cheep" or a == "upfire" or (a == "goomba" and b.t ~= "shyguy") or a == "koopa" or a == "squid" or a == "hammer" or a == "downplant" or a == "sidestepper" or a == "barrel" or a == "angrysun" or a == "splunkin" or a == "biggoomba" or a == "brofireball" or a == "skewer" or a == "fishbone" or a == "meteor" or (a == "boomerang" and b.kills)
		or a == "ninji" or a == "boo" or a == "mole" or a == "bomb" or a == "fireplant" or a == "downfireplant" or a == "plantfire" or a == "torpedoted" or a == "torpedolauncher" or a == "boomboom" or a == "amp" or a == "fuzzy" or a == "longfire" or a == "turretrocket" or a == "glados" or a == "pokey" or a == "chainchomp" or a == "rockywrench" or a == "wrench" or (a == "drybones" and b.spiked) or a == "koopaling" or (a == "spikeball" and not b.stompable) or a == "plantcreeper" then --KILL
		if self.invincible then
			self.jumping = jump
			self.falling = fall
			self.animationstate = anim
			return false
		elseif self.shoe and (b.shotted and (not (a == "angrysun"))) then
			if b.shotted and (not b.shoestompbounce) and (not b.resistsshoe) then
				b:shotted(self.animationdirection)
			end
			if b.shoestompbounce then
				self:stompbounce(a, b)
			elseif b.shot then
				self:stompbounce(a, b)
				addpoints(firepoints[a] or 200, self.x, self.y)
			else
				self:die("Enemy (floorcollide)")
			end
			return false
		else			
			self:die("Enemy (floorcollide)")
			return false
		end
	elseif (a == "muncher" and not b.frozen) or a == "thwomp" or a == "plantcreepersegment" then
		if not (self.invincible or self.starred or self.shoe) then
			self:die("Enemy (floorcollide)")
		end
	elseif a == "energyball" then
		if self.pickup and not self.pickup.rigidgrab then
			if (self.pointingangle > math.pi/2 or self.pointingangle < -math.pi/2) then
				return false
			end
		end
		self:die("time")
	elseif a == "castlefirefire" or a == "fire" then
		if self.invincible then
			self.jumping = jump
			self.falling = fall
			self.animationstate = anim
			return false
		else
			self:die("castlefirefire")
			return false
		end
	elseif a == "tilemoving" and b.noteblock then
		local force = -self.characterdata.jumpforce - (math.abs(self.speedx) / self.characterdata.maxrunspeed)*self.characterdata.jumpforceadd
		force = math.max(-self.characterdata.jumpforce - self.characterdata.jumpforceadd, force)
		if self.water then
			force = force/3
		end
		if jumpkey(self.playernumber) then
			force = force*1.5
		end
		self.speedy = force
		self.jumping = true
		self.animationstate = "jumping"
		self:setquad()
		self:stopjump()
		playsound(blockhitsound)
		return true
	elseif (a == "lightbridgebody" or a == "tilemoving") then
		if b.gels.top == 1 and self:bluegel("top") then
			return false
		elseif b.gels.top == 4 and a == "lightbridgebody" then
			self:purplegel("down")
			return true
		end
	elseif (a == "belt") then
		if self.groundpounding then
			self:stopgroundpound()
		end
		if b:getgel(math.floor(self.x+self.width/2)+1) == 1 then
			if self:bluegel("top") then
				return false
			end
		end
	elseif a == "icicle" or (a == "tilemoving" and b.ice) or a == "ice" or (a == "muncher" and b.frozen) then
		self.friction = self.characterdata.icefriction
		if self.animationstate == "sliding" then
			if skidsound:isStopped() then
				playsound(skidsound)
			end
		end
		self.tileice = true
	elseif a == "box" or a == "core" then
		--check if box can even move
		if (b.gravitydir and (b.gravitydir == "left" or b.gravitydir == "right") and self.gravitydir == b.gravitydir) then
			if self.speedy > maxwalkspeed/2 then
				self.speedy = self.speedy - self.speedy * 6 * gdt
			end

			local out = checkrect(b.x, b.y+self.speedy*gdt, b.width, b.height, {"exclude", b}, true)
			if #out == 0 then
				b.speedy = self.speedy
				return false
			end
		end
	end

	--land on ground
	if self.gravitydir == "down" and (not self.fence) then
		if fall then
			animationsystem_playerlandtrigger(self.playernumber)
		end
		if self.speedx == 0 then
			self.animationstate = "idle"
		else
			if self.animationstate ~= "sliding" then
				self.animationstate = "running"
			end
		end
		self:setquad()
	end
	
	self.combo = 1
end

function mario:postfloorcollide(a, b)
	if a ~= "tile" then
		self.groundpounding = false
	end
	self.groundpoundcanceled = false
end

function mario:bluegel(dir)
	if dir == "top" then
		if downkey(self.playernumber) == false and ((self.speedy > gdt*yacceleration*10) or (portalphysics and (self.falling or self.jumping))) then
			local bluegelminforce = self.characterdata.bluegelminforce
			if portalphysics then
				bluegelminforce = portalphysicsbluegelminforce
			end
			self.speedy = math.min(-bluegelminforce, -self.speedy)
			self.falling = true
			self.animationstate = "jumping"
			self:setquad()
			self.speedy = self.speedy + (self.gravity or yacceleration)*gdt
			
			return true
		end
	elseif dir == "left" then
		if downkey(self.playernumber) == false and (self.falling or self.jumping) then
			if self.speedx > horbounceminspeedx then
				self.speedx = math.min(-horbouncemaxspeedx, -self.speedx*horbouncemul)
				self.speedy = math.min(self.speedy, -horbouncespeedy)
				
				return true
			end
		end
	elseif dir == "right" then
		if downkey(self.playernumber) == false and (self.falling or self.jumping) then
			if self.speedx < -horbounceminspeedx then
				self.speedx = math.min(horbouncemaxspeedx, -self.speedx*horbouncemul)
				self.speedy = math.min(self.speedy, -horbouncespeedy)
				
				return false
			end
		end
	end
end

function mario:purplegel(dir)
	self.gravitydir = dir
	self.falling = false
	self.jumping = false
end

function mario:stompenemy(a, b)
	local bounce = false
	if self.size ~= -1 or self.groundpounding or (a == "goomba" and b.t == "tinygoomba") then
		if self.yoshi and (a == "koopa" or b.shellanimal) then
			--yoshi instantly kills koopas
			local dir = "right"
			if self.speedx < 0 then
				dir = "left"
			end
			b:shotted(dir)
			if self.combo < #mariocombo then
				addpoints(mariocombo[self.combo], self.x, self.y)
			else
				if mariolivecount ~= false then
					mariolives[self.playernumber] = mariolives[self.playernumber]+1
				end
				table.insert(scrollingscores, scrollingscore:new("1up", self.x, self.y))
				playsound(oneupsound)
			end
			playsound(stompsound)
			
			bounce = true
		elseif a == "enemy" then --custom enemies
			if b.shellanimal then
				if b.small then	
					playsound(shotsound)
					if b.speedx == 0 then
						addpoints(500, b.x, b.y)
						self.combo = 1
					end
				else
					if not b.nostompsound then
						playsound(stompsound)
					end
				end
				
				b:stomp(self.x, self)
				
				if b.speedx == 0 or (b.flying and b.small == false) then
					addpoints(mariocombo[self.combo], self.x, self.y)
					if self.combo < #mariocombo then
						self.combo = self.combo + 1
					end
				
					local grav = self.gravity or yacceleration
					
					local bouncespeed = math.sqrt(2*grav*bounceheight)
					if mariomakerphysics and (not portalphysics) then
						bouncespeed = math.sqrt(2*grav*bounceheighthigh)
						self.jumping = true
						if not jumpkey(self.playernumber) then --bounce higher in mario maker physics
							bouncespeed = math.sqrt(2*grav*bounceheightmaker)
							self:stopjump()
						end
					end
					
					self.speedy = -bouncespeed
					
					self.falling = true
					self.animationstate = "jumping"
					self:setquad()
					if not side then
						if not checkintile(self.x, b.y - self.height-1/16, self.width, self.height, {}, self, "ignoreplatforms") then
							self.y = b.y - self.height-1/16
						end
					end
				elseif b.x > self.x then
					b.x = self.x + b.width + self.speedx*gdt + 0.05
					local col = checkrect(b.x, b.y, b.width, b.height, {"tile"})
					if #col > 1 then
						b.x = objects[col[1] ][col[2] ].x-b.width
						bounce = true
					end
				else
					b.x = self.x - b.width + self.speedx*gdt - 0.05
					local col = checkrect(b.x, b.y, b.width, b.height, {"tile"})
					if #col > 1 then
						b.x = objects[col[1] ][col[2] ].x+1
						bounce = true
					end
				end
			elseif b.stompable then
				b:stomp(self.x, self)
				if self.combo < #mariocombo then
					addpoints(mariocombo[self.combo], self.x, self.y)
					if not b.stompcombosuppressor then
						self.combo = self.combo + 1
					end
				else
					if mariolivecount ~= false then
						for i = 1, players do
							mariolives[i] = mariolives[i]+1
						end
					end
					table.insert(scrollingscores, scrollingscore:new("1up", self.x, self.y))
					playsound("oneup")
				end
				if not b.nostompsound then
					playsound(stompsound)
				end
				bounce = true
			end
		elseif a == "koopa" then
			if b.small then	
				playsound(shotsound)
				if b.speedx == 0 then
					addpoints(500, b.x, b.y)
					self.combo = self.combo + 1 --1
				end
			else
				playsound(stompsound)
			end
			
			b:stomp(self.x, self)
			
			if b.speedx == 0 or ((b.t == "redflying" or b.t == "flying" or b.t == "flying2") and b.small == false) then
				addpoints(mariocombo[self.combo], self.x, self.y)
				if self.combo < #mariocombo then
					self.combo = self.combo + 1
				end
			
				local grav = self.gravity or yacceleration
				if self.gravitydir == "up" then
					grav = -self.gravity or -yacceleration
				end
				
				local bouncespeed = math.sqrt(2*grav*bounceheight)
				if mariomakerphysics and (not portalphysics) then
					bouncespeed = math.sqrt(2*grav*bounceheighthigh)
					self.jumping = true
					if not jumpkey(self.playernumber) then --bounce higher in mario maker physics
						bouncespeed = math.sqrt(2*grav*bounceheightmaker)
						self:stopjump()
					end
				end
				
				self.speedy = -bouncespeed
				
				self.falling = true
				self.animationstate = "jumping"
				self:setquad()
				if not checkintile(self.x, b.y - self.height-1/16, self.width, self.height, {}, self, "ignoreplatforms") then
					self.y = b.y - self.height-1/16
				end
			elseif b.x > self.x then
				b.x = self.x + b.width + self.speedx*gdt + 0.05
				local col = checkrect(b.x, b.y, b.width, b.height, {"tile"})
				if #col > 1 then
					b.x = objects[col[1]][col[2]].x-b.width
					bounce = true
				end
			else
				b.x = self.x - b.width + self.speedx*gdt - 0.05
				local col = checkrect(b.x, b.y, b.width, b.height, {"tile"})
				if #col > 1 then
					b.x = objects[col[1]][col[2]].x+1
					bounce = true
				end
			end
		else
			b:stomp(self.x, self)
			if self.combo < #mariocombo then
				addpoints(mariocombo[self.combo], self.x, self.y)
				if a ~= "bulletbill" then
					self.combo = self.combo + 1
				end
			else
				if mariolivecount ~= false then
					mariolives[self.playernumber] = mariolives[self.playernumber]+1
				end
				table.insert(scrollingscores, scrollingscore:new("1up", self.x, self.y))
				playsound(oneupsound)
			end
			if not b.nostompsound then
				playsound(stompsound)
			end
			
			bounce = true
		end
	else
		bounce = true
	end
	
	if bounce and ((not self.groundpounding) or self.size == -1) then
		if self.groundpounding then
			self:stopgroundpound(true)
		end

		local grav = self.gravity or yacceleration
		--if self.gravitydir == "up" then
		--	grav = -self.gravity or -yacceleration
		--end
		if lowgravity then
			grav = grav*lowgravityjumpingmult
		end

		local bouncespeed = math.sqrt(2*grav*bounceheight)
		if mariomakerphysics and (not portalphysics) then
			bouncespeed = math.sqrt(2*grav*bounceheighthigh)
			self.jumping = true
			if not jumpkey(self.playernumber) then --bounce higher in mario maker physics
				bouncespeed = math.sqrt(2*grav*bounceheightmaker)
				self:stopjump()
			end
		end

		if self.gravitydir == "up" then
			bouncespeed = self.gravity
		end
		
		self.animationstate = "jumping"
		self.falling = true
		self:setquad()
		self.speedy = -bouncespeed
	end
end

function mario:stompbounce(a, b) --bounce off of enemy (koopaling in shell for example)
	local grav = self.gravity or yacceleration
	if self.gravitydir == "up" then
		grav = -self.gravity or -yacceleration
	end
	
	local multiplier = 2
	if a == "yoshi" then
		multiplier = 5
	end
	
	local bouncespeed = math.sqrt(multiplier*grav*bounceheight)
	if (not stompbouncex) and a ~= "yoshi" and mariomakerphysics and (not portalphysics) then
		bouncespeed = math.sqrt(2*grav*(b.stompbouncejump or bounceheighthigh))
		self.jumping = true
		if not jumpkey(self.playernumber) then --bounce higher in mario maker physics
			bouncespeed = math.sqrt(2*grav*(b.stompbouncenojump or bounceheightmaker))
			self:stopjump()
		end
	end
	
	self.animationstate = "jumping"
	self.falling = true
	self:setquad()
	self.speedy = -bouncespeed
	if b.stompbouncesound then
		playsound(stompsound)
	end
	
	if b.stompbouncex then
		self.speedx = ((self.x+self.width/2)-(b.x+b.width/2))*bounceheight*b.stompbouncex --bounce horizontally aswell, SMB3 style
	end
end

function mario:rightcollide(a, b, passive)
	if self:globalcollide(a, b) then
		return false
	end
	
	--star logic
	if self.starred or bigmario or self.statue then
		if self:starcollide(a, b) then
			if b.solidkill then
				return true
			else
				return false
			end
		end
	end
	
	if self.gravitydir == "right" then
		if self.speedy == 0 then
			self.animationstate = "idle"
		else
			if self.animationstate ~= "sliding" then
				self.animationstate = "running"
			end
		end
		self:setquad()
	end

	if self.size == 14 and self.ducking and (a ~= "mushroom") and self.blueshelled then --blueshell
		if a == "tile" then --shell go over gaps
			local x, y = b.cox, b.coy
			if inmap(x, y-1) and tilequads[map[x][y-1][1]].collision == false and self.speedy > 0 and self.y+self.height+1 < y+spacerunroom then
				self.y = b.y - self.height; self.speedy = 0; self.x = b.x-self.width+0.0001; self.falling = false
				return false
			end
		end
		if a == "tile" or a == "portalwall" or a == "spring" or a == "donut" or a == "springgreen" or a == "bigmole" or a == "muncher" or (a == "flipblock" and not b.flippable) or a == "frozencoin" or a == "buttonblock" or (a == "enemy" and (b.resistsenemykill or b.resistseverything)) then	
			self.speedx = -math.abs(self.speedx)
			local x, y = b.cox, b.coy
			if a == "tile" then
				hitblock(x, y, self)
			else
				playsound(blockhitsound)
			end
			return true
		end
		if a ~= "spring" and a ~= "donut" and a ~= "springgreen" and a ~= "bigmole" and a ~= "muncher" and a ~= "koopaling" and a ~= "bowser" and b.shotted then
			if b.shotted and (not (b.resistsenemykill or b.resistseverything)) then
				if self.blueshelled then
					if self.combo < #koopacombo then
						self.combo = self.combo + 1
						addpoints(koopacombo[self.combo], b.x, b.y)
					else
						for i = 1, players do
							if mariolivecount ~= false then
								mariolives[i] = mariolives[i]+1
								respawnplayers()
							end
						end
						table.insert(scrollingscores, scrollingscore:new("1up", b.x, b.y))
						playsound(oneupsound)
					end
					b:shotted("left")
					return false
				else
					return true
				end
			end
		end
		self.speedx = -math.abs(self.speedx)
		playsound(blockhitsound)
	end
	
	if a == "mushroom" or a == "oneup" or a == "star" or a == "flower" or a == "poisonmush" or a == "threeup" or a == "smbsitem" or (a == "platform" and (b.dir == "right" or b.dir == "justright")) or a == "donut" or a == "hammersuit" or a == "frogsuit" or a == "leaf" or (a == "boomerang" and b.fireballthrower) then
		return false
	elseif a == "enemy" then
		if b.ignoreleftcollide or b.dontstopmario then
			return false
		elseif (b.kills or b.killsonsides or b.killsonleft) then 
			if self.invincible then
				if b.shellanimal and b.small and b.speedx == 0 then
					b:stomp(self.x, self)
					playsound("shot")
					addpoints(500, b.x, b.y)
				end
				if b.solidkill then
					return true
				else
					return false
				end
			else
				if self.raccoonspinframe and b.shotted then
					b:shotted("left", true, true)
					addpoints(firepoints[b.t] or 100, self.x, self.y)
					return false
				end
				
				if b.shellanimal and b.small and b.speedx == 0 then
					b:stomp(self.x, self)
					playsound("shot")
					addpoints(500, b.x, b.y)
					return false
				end

				if self.speedy > 2 and b.stompable then --not in orignal SE, stomp if speed is high
					if b.stompbounce or (b.stompbounceifsmall and self.size ~= 16) then--bounce off of enemy
						self:stompbounce(a, b)
					else
						self:stompenemy(a, b)
					end
					return false
				end
					
				if b.instantkill then
					self:die("lava")
				else
					self:die("Enemy (rightcollide)")
				end
				
				if b.solidkill then
					return true
				else
					return false
				end
			end
		elseif b.removeonmariocontact and not b.removeonmariocontactcollide then
			return false
		elseif b.bouncy or b.bouncyonleft or b.bouncyonsides then
			self.speedx = -(b.bouncyforcex or b.bouncyforce)
			return true
		end
	elseif a == "levelball" then
		net_action(self.playernumber, "levelball")
		return false
	elseif a == "pedestal" then
		self.pickugun = true
		self.portals = b.portals
		self:updateportalsavailable()
		return false
	elseif a == "regiontrigger" or a == "yoshi" or (a == "bomb" and b.stomped and not b.explosion) or (a == "cannonball" and not b.kills) then
		return false
	elseif (a == "plantfire" or a == "brofireball" or a == "castlefirefire" or a == "fire") and self.size == 4 and self.ducking then
		return false
	elseif self.speedy > 2 and ((a == "goomba" and b.t ~= "spikey" and  b.t ~= "spikeyfall" and b.t ~= "spiketop" and b.t ~= "bigspikey" and b.t ~= "shyguy") or a == "bulletbill" or a == "flyingfish" or a == "lakito" or a == "hammerbro" or (a == "koopa" and b.t ~= "downspikey" and b.t ~= "spikeyshell") or a == "bigbill" or a == "cannonball" or a == "splunkin" or a == "bigkoopa" or (a == "drybones" and not b.spiked) or a == "ninji" or a == "mole"
		or (a == "bomb" and not b.explosion) or (a == "boomboom" and b.ducking == false and b.stomped == false) or (a == "squid" and b.color == "pink") or (a == "pokey" and b.t == "snowpokey") or (a == "koopaling" and b.stompable) or a == "magikoopa" or a == "spike" or (a == "spikeball" and b.stompable) or (a == "plantcreeper" and b.dir ~= "left")) then
		if b.stompbounce or (b.stompbounceifsmall and self.size ~= 16) then
			self:stompbounce(a, b)
		else
			self:stompenemy(a, b)
		end
		return false
	elseif self.size ~= -1 and (a == "goomba" and b.t == "tinygoomba") then
		return true
	elseif a == "castlefirefire" or a == "fire" or a == "koopa" or a == "goomba" or a == "bulletbill" or a == "plant" or a == "bowser" or a == "cheep" or a == "flyingfish" or a == "upfire" or a == "lakito" or a == "squid" or a == "hammer" or a == "hammerbro" or a == "downplant" or a == "bigbill" or (a == "cannonball" and b.kills) or (a == "kingbill" and not (levelfinished and not self.controlsenabled)) or a == "sidestepper" or a == "barrel" or a == "icicle" or a == "angrysun" or a == "splunkin" or a == "biggoomba" or a == "bigkoopa" or a == "brofireball"
		or a == "thwomp" or a == "skewer" or a == "fishbone" or a == "drybones" or a == "meteor" or (a == "boomerang" and b.kills) or a == "ninji" or a == "boo" or a == "mole" or a == "bigmole" or (a == "bomb" and (not b.stomped or b.explosion)) or a == "fireplant" or a == "downfireplant" or a == "plantfire" or a == "torpedoted" or a == "torpedolauncher" or a == "boomboom" or a == "amp" or a == "fuzzy" or a == "longfire" or a == "turretrocket" or a == "glados" or a == "pokey" or a == "chainchomp" or a == "rockywrench" or a == "wrench" or a == "koopaling" or a == "magikoopa" or a == "spike" or (a == "spikeball" and not b.stompable) or a == "plantcreeper" then --KILLS
		if b.stomp and self.size == 14 and self.ducking then
			b:leftcollide("_",b)
			return true
		elseif self.invincible then
			if (a == "koopa" and b.small and b.speedx == 0) then
				b:stomp(self.x, self)
				playsound(shotsound)
				addpoints(500, b.x, b.y)
			end
			return false
		else
			if (a == "koopa" and b.small and b.speedx == 0) then
				b:stomp(self.x, self)
				playsound(shotsound)
				addpoints(500, b.x, b.y)
				return false
			end
			
			if not (b.passivepass and b.passivepass == self.playernumber) then
				self:die("Enemy (rightcollide)")
			end
			return false
		end
	elseif a == "muncher" or a == "plantcreepersegment" then
		if self.invincible or self.starred or self.shoe or b.frozen then
			return true
		else
			self:die("Enemy (rightcollide)")
		end
	elseif a == "energyball" then
		if self.pickup and not self.pickup.rigidgrab then
			if passive then
				if b.x+b.width/2 > self.x+self.width/2 and self.pointingangle < 0 then --right
					return false
				elseif b.x+b.width/2 < self.x+self.width/2 and self.pointingangle > 0 then --left
					return false
				end
			else
				if self.pointingangle < 0 then --right
					return false
				end
			end
		end
		self:die("time")
	elseif a == "frozencoin" or a == "buttonblock" or a == "flipblock" then
		--Check if mario should run across a gap.
		local x, y = b.cox, b.coy
		if inmap(x, y-1) and tilequads[map[x][y-1][1]].collision == false and self.speedy > 0 and self.y+self.height+1 < y+spacerunroom then
			self.y = b.y - self.height
			self.speedy = 0
			self.x = b.x-self.width+0.0001
			self.falling = false
			self.animationstate = "running"
			self:setquad()
			return false
		end
	elseif a == "tile" then
		local x, y = b.cox, b.coy
		
		if map[x][y]["gels"]["left"] == 4 then
			if ((self.gravitydir == "up" or self.gravitydir == "down") and self.speedx < 0) or self.shoe then
			
			else
				if self.gravitydir == "up" then
					self.reversecontrols = not self.reversecontrols
				end
				self.gravitydir = "right"
				self.rotation = -math.pi/2
				self.falling = false
				self.jumping = false
			end
		elseif self.gravitydir == "right" then
			self.gravitydir = "down"
		end
		
		if self.gravitydir == "right" then
			self.falling = false
			self.jumping = false
		end
			
		if map[x][y]["gels"] then
			--right collide bounce gel
			if downkey(self.playernumber) == false and map[x][y]["gels"]["left"] == 1 and (self.falling or self.jumping) then
				if self.speedx > horbounceminspeedx then
					self.speedx = math.max(-horbouncemaxspeedx, -math.abs(self.speedx)*horbouncemul)
					self.speedy = math.min(self.speedy, -horbouncespeedy)
					
					return false
				end
			end
		end
		
		--check for invisible block
		if tilequads[map[x][y][1]].invisible then
			return false
		end
		
		--check for noteblocks
		if tilequads[map[x][y][1]]:getproperty("noteblock", x, y) then
			if self.noteblock then
				local bounce = getblockbounce(self.noteblock[1], self.noteblock[2])
				if bounce then
					local onbounce = getblockbounce(x, y)
					if onbounce and onbounce.timer == bounce.timer then
						return false
					end
				end
			elseif self.noteblock2 then
				local bounce = getblockbounce(self.noteblock2[1], self.noteblock2[2])
				if bounce then
					local onbounce = getblockbounce(x, y)
					if onbounce and onbounce.timer == bounce.timer then
						return false
					end
				end
			end
		end

		--spikes
		if tilequads[map[x][y][1]]:getproperty("spikesleft", x, y) then
			if self.invincible or self.starred or editormode then
				--uh
			else	
				self:die("Enemy (rightcollide)")
				--return false
			end
		end
		
		--lava
		if tilequads[map[x][y][1]].lava then
			self:die("lava")
		end
		
		--Check if it's a pipe with pipe pipe.
		if self.falling == false and self.jumping == false and (rightkey(self.playernumber) or intermission) then --but only on ground and rightkey
			for i, p in pairs(pipes) do
				if p:inside("right", x, self) then
					self.y = p.coy-self.height
					self:pipe(p.cox, p.coy, "right", i)
					net_action(self.playernumber, "pipe|" .. p.cox .. "|" .. p.coy .. "|right|" .. i)
					return
				end
			end
		end
		
		--Check if mario should run across a gap.
		if inmap(x, y-1) and tilequads[map[x][y-1][1]].collision == false and self.speedy > 0 and self.y+self.height+1 < y+spacerunroom then
			self.y = b.y - self.height
			self.speedy = 0
			self.x = b.x-self.width+0.0001
			self.falling = false
			self.animationstate = "running"
			self:setquad()
			return false
		end
		
		if autoscrolling and not editormode then
			if autoscrollingx then
				if autoscrollingx > 0 then
					if self.x < xscroll and not self.dead then
						self:die("time")
					end
				end
			end
		end
		
		if bigmario then
			destroyblock(x, y)
			return false
		elseif (self.size == 8 or self.size == 16) and (tilequads[map[x][y][1]].breakable or (tilequads[map[x][y][1]].debris and blockdebrisquads[tilequads[map[x][y][1]].debris])) then
			destroyblock(x, y)
			if self.size == 16 then
				self.speedx = self.speedx/10
			end
			return false
		end
	elseif a == "box" or a == "core" then
		--check if box can even move
		if not (b.gravitydir and (b.gravitydir ~= "down" and b.gravitydir ~= "up") and self.gravitydir == b.gravitydir) then
			if self.speedx > maxwalkspeed/2 then
				self.speedx = self.speedx - self.speedx * 6 * gdt
			end

			local out = checkrect(b.x+self.speedx*gdt, b.y, b.width, b.height, {"exclude", b}, true)
			if #out == 0 then
				b.speedx = self.speedx
				return false
			end
		end
	elseif a == "turret" then
		if self.starred then 
			b:explode() 
		end
		
		if self.speedx > maxwalkspeed/2 then
			self.speedx = self.speedx - self.speedx * 6 * gdt
		end
		
		--check if turret can even move
		local out = checkrect(b.x+self.speedx*gdt, b.y, b.width, b.height, {"exclude", b}, true)
		if #out == 0 then
			b.speedx = self.speedx
			return false
		end
	elseif a == "button" then
		self.y = b.y - self.height
		self.x = b.x - self.width+0.001
		if self.speedy > 0 then
			self.speedy = 0
		end
		return false
	elseif (a == "lightbridgebody" or a == "tilemoving") then
		if b.gels.left == 1 and self:bluegel("left") then
			return false
		elseif b.gels.left == 4 and a == "lightbridgebody" then
			self:purplegel("right")
			return true
		end
	end

	if self.gravitydir == "right" and a ~= "tile" and a ~= "portaltile" and (not b.doesntchangeplayergravity) then
		self.gravitydir = "down"
	end
	
	if (self.gravitydir == "down" or self.gravitydir == "up") and (not self.fence) then
		if self.falling == false and self.jumping == false then
			self.animationstate = "idle"
			self:setquad()
		end
	end
end

function mario:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	--star logic
	if self.starred or bigmario or self.statue then
		if self:starcollide(a, b) then
			if b.solidkill then
				return true
			else
				return false
			end
		end
	end
	
	if self.gravitydir == "left" then
		if self.speedy == 0 then
			self.animationstate = "idle"
		else
			if self.animationstate ~= "sliding" then
				self.animationstate = "running"
			end
		end
		self:setquad()
	end

	if self.size == 14 and self.ducking and (a ~= "mushroom") and self.blueshelled then --blueshell
		if a == "tile" then --shell go over gaps
			local x, y = b.cox, b.coy
			if inmap(x, y-1) and tilequads[map[x][y-1][1]].collision == false and self.speedy > 0 and self.y+self.height+1 < y+spacerunroom then
				self.y = b.y - self.height; self.speedy = 0; self.x = b.x+1-0.0001; self.falling = false
				return false
			end
		end
		if a == "tile" or a == "portalwall" or a == "spring" or a == "donut" or a == "springgreen" or a == "bigmole" or a == "muncher" or (a == "flipblock" and not b.flippable) or a == "frozencoin" or a == "buttonblock" or (a == "enemy" and (b.resistsenemykill or b.resistseverything)) then	
			self.speedx = math.abs(self.speedx)
			local x, y = b.cox, b.coy
			if a == "tile" then
				hitblock(x, y, self)
			else
				playsound(blockhitsound)
			end
			return true
		end
		
		if a ~= "spring" and a ~= "donut" and a ~= "springgreen" and a ~= "bigmole" and a ~= "muncher" and a ~= "koopaling" and a ~= "bowser" and b.shotted then
			if b.shotted and (not (b.resistsenemykill or b.resistseverything)) then
				if self.blueshelled then
					if self.combo < #koopacombo then
						self.combo = self.combo + 1
						addpoints(koopacombo[self.combo], b.x, b.y)
					else
						for i = 1, players do
							if mariolivecount ~= false then
								mariolives[i] = mariolives[i]+1
								respawnplayers()
							end
						end
						table.insert(scrollingscores, scrollingscore:new("1up", b.x, b.y))
						playsound(oneupsound)
					end
					b:shotted("left")
					return false
				else
					return true
				end
			end
		end
		self.speedx = -math.abs(self.speedx)
		playsound(blockhitsound)
	end
	
	if a == "mushroom" or a == "oneup" or a == "star" or a == "flower" or a == "poisonmush" or a == "threeup" or a == "smbsitem" or (a == "platform" and (b.dir == "right" or b.dir == "justright")) or a == "donut" or a == "hammersuit" or a == "frogsuit" or a == "leaf" or (a == "boomerang" and b.fireballthrower) then --NOTHING
		return false
	elseif a == "enemy" then
		if b.ignorerightcollide or b.dontstopmario then
			return false
		elseif (b.kills or b.killsonsides or b.killsonright) then 
			if self.invincible then
				if b.shellanimal and b.small and b.speedx == 0 then
					b:stomp(self.x, self)
					playsound("shot")
					addpoints(500, b.x, b.y)
				end
				if b.solidkill then
					return true
				else
					return false
				end
			else
				if self.raccoonspinframe and b.shotted then
					b:shotted("left", true, true)
					addpoints(firepoints[b.t] or 100, self.x, self.y)
					return false
				end
				
				if b.shellanimal and b.small and b.speedx == 0 then
					b:stomp(self.x, self)
					playsound("shot")
					addpoints(500, b.x, b.y)
					return false
				end

				if self.speedy > 2 and b.stompable then --not in orignal SE, stomp if speed is high
					if b.stompbounce or (b.stompbounceifsmall and self.size ~= 16) then--bounce off of enemy
						self:stompbounce(a, b)
					else
						self:stompenemy(a, b)
					end
					return false
				end
				
				if b.instantkill then
					self:die("lava")
				else
					self:die("Enemy (leftollide)")
				end
				if b.solidkill then
					return true
				else
					return false
				end
			end
		elseif b.removeonmariocontact and not b.removeonmariocontactcollide then
			return false
		elseif b.bouncy or b.bouncyonright or b.bouncyonsides then
			self.speedx = (b.bouncyforcex or b.bouncyforce)
			return true
		end
	elseif a == "levelball" then
		net_action(self.playernumber, "levelball")
		return false
	elseif a == "pedestal" then
		self.pickugun = true
		self.portals = b.portals
		self:updateportalsavailable()
		return false
	elseif a == "regiontrigger" or a == "yoshi" or (a == "bomb" and b.stomped and not b.explosion) or (a == "cannonball" and not b.kills) then
		return false
	elseif (a == "plantfire" or a == "brofireball" or a == "castlefirefire" or a == "fire") and self.size == 4 and self.ducking then
		return false
	elseif self.speedy > 2 and ((a == "goomba" and b.t ~= "spikey" and  b.t ~= "spikeyfall" and b.t ~= "spiketop" and b.t ~= "bigspikey" and b.t ~= "shyguy") or a == "bulletbill" or a == "flyingfish" or a == "lakito" or a == "hammerbro" or (a == "koopa" and b.t ~= "downspikey" and b.t ~= "spikeyshell") or a == "bigbill" or a == "cannonball" or a == "splunkin" or a == "bigkoopa" or a == "fireball" or a == "iceball" or (a == "drybones" and not b.spiked) or a == "ninji" or a == "mole" or (a == "bomb" and not b.explosion) or (a == "boomboom" and b.ducking == false and b.stomped == false)
		or (a == "squid" and b.color == "pink") or (a == "pokey" and b.t == "snowpokey") or (a == "koopaling" and b.stompable) or a == "magikoopa" or a == "spike" or (a == "spikeball" and b.stompable) or (a == "plantcreeper" and b.dir ~= "right")) then
		if b.stompbounce or (b.stompbounceifsmall and self.size ~= 16) then--bounce off of enemy
			self:stompbounce(a, b)
		else
			self:stompenemy(a, b)
		end
		return false
	elseif self.size ~= -1 and (a == "goomba" and b.t == "tinygoomba") then
		return true
	elseif a == "castlefirefire" or a == "fire" or a == "koopa" or a == "goomba" or a == "bulletbill" or a == "plant" or a == "bowser" or a == "cheep" or a == "flyingfish" or a == "upfire" or a == "lakito" or a == "squid" or a == "hammer" or a == "hammerbro" or a == "downplant" or a == "bigbill" or (a == "cannonball" and b.kills) or (a == "kingbill" and not (levelfinished and not self.controlsenabled)) or a == "sidestepper" or a == "barrel" or a == "icicle" or a == "angrysun" or a == "splunkin" or a == "biggoomba" or a == "bigkoopa" or a == "brofireball"
		or a == "thwomp" or a == "skewer" or a == "fishbone" or a == "drybones" or a == "meteor" or (a == "boomerang" and b.kills) or a == "ninji" or a == "boo" or a == "mole" or a == "bigmole" or a == "bomb" or a == "fireplant" or a == "downfireplant" or a == "plantfire" or a == "torpedolauncher" or a == "torpedoted" or a == "boomboom" or a == "amp" or a == "fuzzy" or a == "longfire" or a == "turretrocket" or a == "glados" or a == "pokey" or a == "chainchomp" or a == "rockywrench" or a == "wrench" or a == "koopaling" or a == "magikoopa" or a == "spike" or (a == "spikeball" and not b.stompable) or a == "plantcreeper" then --KILLS
		if b.stomp and self.size == 14 and self.ducking then
			b:rightcollide("_",self)
			return true
		elseif self.invincible then
			if ((a == "koopa" or a == "bigkoopa") and b.small and b.speedx == 0) then
				b:stomp(self.x, self)
				playsound(shotsound)
				addpoints(500, b.x, b.y)
			end
			return false
		else
			if ((a == "koopa" or a == "bigkoopa") and b.small and b.speedx == 0) then
				b:stomp(self.x, self)
				playsound(shotsound)
				addpoints(500, b.x, b.y)
				return false
			end
			
			if not (b.passivepass and b.passivepass == self.playernumber) then
				self:die("Enemy (leftcollide)")
			end
			return false
		end
	elseif a == "muncher" or a == "plantcreepersegment" then
		if self.invincible or self.starred or self.shoe or b.frozen then
			return true
		else
			self:die("Enemy (leftcollide)")
		end
	elseif a == "energyball" then
		if self.pickup and not self.pickup.rigidgrab then
			if self.pointingangle > 0 then --left
				return false
			end
		end
		self:die("time")
	elseif a == "frozencoin" or a == "buttonblock" or a == "flipblock" then
		--Check if mario should run across a gap.
		local x, y = b.cox, b.coy
		if inmap(x, y-1) and tilequads[map[x][y-1][1]].collision == false and self.speedy > 0 and self.y+self.height+1 < y+spacerunroom then
			self.y = b.y - self.height
			self.speedy = 0
			self.x = b.x+1-0.0001
			self.falling = false
			self.animationstate = "running"
			self:setquad()
			return false
		end
	elseif a == "tile" then
		local x, y = b.cox, b.coy
		
		if map[x][y]["gels"]["right"] == 4 then
			if ((self.gravitydir == "up" or self.gravitydir == "down") and self.speedx > 0) or self.shoe then

			else
				if self.gravitydir == "up" then
					self.reversecontrols = not self.reversecontrols
				end
				self.gravitydir = "left"
				self.rotation = math.pi/2
				self.falling = false
				self.jumping = false
			end
		elseif self.gravitydir == "left" then
			self.gravitydir = "down"
		end
		
		if map[x][y]["gels"] then
			--left collide bounce gel
			if downkey(self.playernumber) == false and map[x][y]["gels"]["right"] == 1 and (self.falling or self.jumping) then
				if self.speedx < -horbounceminspeedx then
					self.speedx = math.min(horbouncemaxspeedx, math.abs(self.speedx)*horbouncemul)
					self.speedy = math.min(self.speedy, -horbouncespeedy)
					
					return false
				end
			end
		end
		
		--check for invisible block
		if tilequads[map[x][y][1]].invisible then
			return false
		end

		--check for noteblocks
		if tilequads[map[x][y][1]]:getproperty("noteblock", x, y) then
			if self.noteblock then
				local bounce = getblockbounce(self.noteblock[1], self.noteblock[2])
				if bounce then
					local onbounce = getblockbounce(x, y)
					if onbounce and onbounce.timer == bounce.timer then
						return false
					end
				end
			elseif self.noteblock2 then
				local bounce = getblockbounce(self.noteblock2[1], self.noteblock2[2])
				if bounce then
					local onbounce = getblockbounce(x, y)
					if onbounce and onbounce.timer == bounce.timer then
						return false
					end
				end
			end
		end
		
		--spikes
		if tilequads[map[x][y][1]]:getproperty("spikesright", x, y) then
			if self.invincible or self.starred or editormode then
				--uh
			else			
				self:die("Enemy (leftcollide)")
				--return false
			end
		end
		
		--lava
		if tilequads[map[x][y][1]].lava then
			self:die("lava")
		end
		
		--Check if it's a pipe with pipe pipe.
		if self.falling == false and self.jumping == false and (leftkey(self.playernumber) or intermission) then --but only on ground and leftkey
			for i, p in pairs(pipes) do
				if p:inside("left", x, self) then
					self.y = p.coy-self.height
					self:pipe(p.cox, p.coy, "left", i)
					net_action(self.playernumber, "pipe|" .. p.cox .. "|" .. p.coy .. "|left|" .. i)
					return
				end
			end
		end
		
		if inmap(x, y-1) and tilequads[map[x][y-1][1]].collision == false and self.speedy > 0 and self.y+1+self.height < y+spacerunroom then
			self.y = b.y - self.height
			self.speedy = 0
			self.x = b.x+1-0.0001
			self.falling = false
			self.animationstate = "running"
			self:setquad()
			return false
		end
		
		if autoscrolling and not editormode then
			if autoscrollingx then
				if autoscrollingx < 0 then
					if self.x > xscroll+width-self.width and not self.dead then
						self:die("time")
					end
				end
			end
		end
	
		if bigmario then
			destroyblock(x, y)
			return false
		elseif (self.size == 8 or self.size == 16) and (tilequads[map[x][y][1]].breakable or (tilequads[map[x][y][1]].debris and blockdebrisquads[tilequads[map[x][y][1]].debris])) then
			destroyblock(x, y)
			if self.size == 16 then
				self.speedx = self.speedx/10
			end
			return false
		end
	elseif a == "box" or a == "core" then
		--check if box can even move
		if not (b.gravitydir and (b.gravitydir ~= "down" and b.gravitydir ~= "up") and self.gravitydir == b.gravitydir) then
			if self.speedx < -maxwalkspeed/2 then
				self.speedx = self.speedx + math.abs(self.speedx) * 6 * gdt
			end

			local out = checkrect(b.x+self.speedx*gdt, b.y, b.width, b.height, {"exclude", b}, true)
			if #out == 0 then
				b.speedx = self.speedx
				return false
			end
		end
	elseif a == "turret" then
		if self.starred then 
			b:explode() 
		end
		
		if self.speedx < -maxwalkspeed/2 then
			self.speedx = self.speedx + math.abs(self.speedx) * 6 * gdt
		end
		
		--check if turret can even move
		local out = checkrect(b.x+self.speedx*gdt, b.y, b.width, b.height, {"exclude", b}, true)
		if #out == 0 then
			b.speedx = self.speedx
			return false
		end
	elseif a == "button" then
		self.y = b.y - self.height
		self.x = b.x + b.width - 0.001
		if self.speedy > 0 then
			self.speedy = 0
		end
		return false
	elseif (a == "lightbridgebody" or a == "tilemoving") then
		if b.gels.right == 1 and self:bluegel("right") then
			return false
		elseif b.gels.right == 4 and a == "lightbridgebody" then
			self:purplegel("left")
			return true
		end
	end

	if self.gravitydir == "left" and a ~= "tile" and a ~= "portaltile" and (not b.doesntchangeplayergravity) then
		self.gravitydir = "down"
	end
	
	if (self.gravitydir == "down" or self.gravitydir == "up") and (not self.fence) then
		if self.falling == false and self.jumping == false then
			self.animationstate = "idle"
			self:setquad()
		end
	end
end

function mario:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	--star logic
	if self.starred or bigmario or self.statue then
		if self:starcollide(a, b) then
			if b.solidkill then
				return true
			else
				return false
			end
		end
	end
	
	if self.gravitydir == "up" and self.speedy <= 0 then
		if self.speedx == 0 then
			self.animationstate = "idle"
		else
			if self.animationstate ~= "sliding" then
				self.animationstate = "running"
			end
		end
		self:setquad()
	end

	if self.size == 14 and self.ducking then --blueshell
		if a ~= "spring" and a ~= "donut" and a ~= "springgreen" and a ~= "bigmole" and a ~= "muncher" and a ~= "koopaling" and a ~= "bowser" and b.shotted then
			if b.shotted and (not (b.resistsenemykill or b.resistseverything)) then
				return true
			end
		end
	end
	
	if a == "mushroom" or a == "oneup" or a == "star" or a == "flower" or a == "poisonmush" or a == "threeup" or a == "smbsitem" or a == "hammersuit" or a == "frogsuit" or a == "leaf" or (a == "boomerang" and b.fireballthrower) then --STUFF THAT SHOULDN'T DO SHIT
		return false
	elseif a == "enemy" then
		if b.ignorefloorcollide or b.dontstopmario then
			return false
		elseif (b.kills or b.killsonbottom) then
			if (not self.helmet) and b.helmetable and self:helmeted(b.helmetable) then
				b.kill = true
				return false
			end
			
			if b.shellanimal and b.small and b.speedx == 0 then
				self:stompenemy(a, b, c, d, true)
				return false
			end

			if self.invincible then
				if b.solidkill then
					return true
				else
					return false
				end
			else
				if self.helmet then
					--helmet hit
					if self.helmet == "beetle" and not b.static then
						if (not b.gravity) or b.gravity ~= 0 then
							b.speedy = math.min(-helmetbounceforce, self.speedy)
						end
						playsound(helmethitsound)
						return true
					elseif self.helmet == "spikey" and b.shotted then
						if b:shotted("right", nil, nil, false, true) then
							addpoints(firepoints[b.t] or 100, self.x, self.y)
						end
						return false
					end
				end
				if b.instantkill then
					self:die("lava")
				else
					self:die("Enemy (Ceilcollided)")
				end
				if b.solidkill then
					return true
				else
					return false
				end
			end
		elseif b.removeonmariocontact and not b.removeonmariocontactcollide then
			return false
		elseif b.bouncy or b.bouncyonbottom then
			self.speedy = (b.bouncyforcey or b.bouncyforce)
			return true
		end
	elseif a == "levelball" then
		net_action(self.playernumber, "levelball")
		return false
	elseif a == "pedestal" then
		self.pickugun = true
		self.portals = b.portals
		self:updateportalsavailable()
		return false
	elseif a == "regiontrigger" or a == "yoshi" or a == "donut" or (a == "bomb" and b.stomped and not b.explosion) or (a == "cannonball" and not b.kills) then
		return false
	elseif (a == "plantfire" or a == "brofireball" or a == "castlefirefire" or a == "fire") and self.size == 4 and self.ducking then
		return false
	elseif a == "castlefirefire" or a == "fire" or a == "plant" or a == "goomba" or a == "koopa" or a == "bulletbill" or a == "bowser" or a == "cheep" or a == "flyingfish" or a == "upfire" or a == "lakito" or a == "squid" or a == "hammer" or a == "hammerbro" or a == "downplant" or a == "bigbill" or (a == "cannonball" and b.kills) or (a == "kingbill" and not (levelfinished and not self.controlsenabled)) or a == "sidestepper" or a == "barrel" or a == "icicle" or a == "angrysun" or a == "splunkin" or a == "biggoomba" or a == "bigkoopa" or a == "brofireball"
		or a == "thwomp" or a == "skewer" or a == "fishbone" or a == "drybones" or a == "meteor" or (a == "boomerang" and b.kills) or a == "parabeetle" or a == "ninji" or a == "mole" or a == "bigmole" or a == "bomb" or a == "plantfire" or a == "fireplant" or a == "downfireplant" or a == "torpedoted" or a == "torpedolauncher" or a == "boo" or a == "boomboom" or a == "amp" or a == "fuzzy" or a == "longfire" or a == "turretrocket" or a == "glados" or a == "pokey" or a == "chainchomp" or a == "rockywrench" or a == "wrench" or a == "koopaling" or a == "magikoopa" or a == "spike" or (a == "spikeball" and not b.stompable) or a == "plantcreeper" then --STUFF THAT KILLS
		if self.invincible then
			if a == "koopa" and b.helmetable and self:helmeted(b.helmetable) then
				b:helmeted()
				return false
			end
			return false
		else
			if a == "koopa" and b.helmetable and self:helmeted(b.helmetable) then
				b:helmeted()
				return false
			end
			if self.helmet then
				--helmet hit
				if self.helmet == "beetle" and not b.static then
					if (not b.gravity) or b.gravity ~= 0 or a == "thwomp" then
						b.speedy = math.min(-helmetbounceforce, self.speedy)
					end
					playsound(helmethitsound)
					return true
				elseif self.helmet == "spikey" and b.shotted then
					b:shotted("right")
					if a ~= "bowser" then
						addpoints(firepoints[a], self.x, self.y)
					end
					return false
				end
			end
			self:die("Enemy (Ceilcollided)")
			return false
		end
	elseif a == "muncher" or a == "plantcreepersegment" then
		if self.invincible or self.starred or b.frozen then
			return true
		else
			if self.helmet then
				--helmet hit
				if self.helmet == "beetle" then
					b.speedy = math.min(-helmetbounceforce, self.speedy)
					playsound(helmethitsound)
					return true
				elseif self.helmet == "spikey" then
					if b.shotted then
						b:shotted("right")
						if a ~= "bowser" then
							addpoints(firepoints[a], self.x, self.y)
						end
						return false
					end
				end
			end
			self:die("Enemy (ceilcollide)")
		end
	elseif a == "energyball" then
		if self.pickup and not self.pickup.rigidgrab then
			if self.pointingangle > -math.pi/2 and self.pointingangle < math.pi/2 then
				return false
			end
		end
		self:die("time")
	elseif a == "box" or a == "core" then
		--check if box can even move
		if (b.gravitydir and (b.gravitydir == "left" or b.gravitydir == "right") and self.gravitydir == b.gravitydir) then
			if self.speedy < -maxwalkspeed/2 then
				self.speedy = self.speedy + math.abs(self.speedy) * 6 * gdt
			end

			local out = checkrect(b.x, b.y+self.speedy*gdt, b.width, b.height, {"exclude", b}, true)
			if #out == 0 then
				b.speedy = self.speedy
				return false
			end
		end
	elseif a == "flipblock" then
		if self.helmet == "spikey" then
			b:destroy()
		end
		if b.helmetable and self:helmeted(b.helmetable) then
			b:helmeted()
			return false
		end
	elseif a == "buttonblock" or a == "frozencoin" then
		--Check if it should bounce the block next to it, or push mario instead
		if self.gravitydir == "down" and self.size ~= 8 and self.size ~= 16 then
			local x, y = b.cox, b.coy
			if self.x < x-22/16 then
				--check if block left of it is a better fit
				if x > 1 and (tilequads[map[x-1][y][1]].collision == true or objects["buttonblock"][tilemap(x-1, y)] or objects["frozencoin"][tilemap(x-1, y)]) then
					x = x - 1
				else
					local col = checkrect(x-28/16, self.y, self.width, self.height, {"exclude", self}, true)
					if #col == 0 then
						self.x = x-28/16
						if self.speedx > 0 then
							self.speedx = 0
						end
						return false
					end					
				end
			elseif self.x > x-6/16 then
				--check if block right of it is a better fit
				if x < mapwidth and (tilequads[map[x+1][y][1]].collision == true or objects["buttonblock"][tilemap(x+1, y)] or objects["frozencoin"][tilemap(x+1, y)]) then
					x = x + 1
				else
					local col = checkrect(x, self.y, self.width, self.height, {"exclude", self}, true)
					if #col == 0 then
						self.x = x
						if self.speedx < 0 then
							self.speedx = 0
						end
						return false
					end	
				end
			end
		end
		if a == "frozencoin" then
			if self.helmet == "spikey" then
				b:meltice("destroy")
			end
		end
		playsound(blockhitsound)
	elseif a == "tile" then
		local x, y = b.cox, b.coy
		local r = map[x][y]
		
		if map[x][y]["gels"]["bottom"] == 4 and (not self.shoe) then
			if self.gravitydir == "left" then
				self.reversecontrols = true
				self.speedx = math.max(self.speedx,0)
			elseif self.gravitydir == "right" then
				self.reversecontrols = true
				self.speedx = math.min(self.speedx,0)
			end
			self.gravitydir = "up"
			self.falling = false
		elseif self.gravitydir == "up" then
			self.gravitydir = "down"
		end
				
		--spikes
		if tilequads[map[x][y][1]]:getproperty("spikesdown", x, y) then
			if self.invincible or self.starred then
				--uh
			else			
				self:die("Enemy (Ceilcollided)")
			end
		end
		
		--lava
		if tilequads[map[x][y][1]].lava then
			self:die("lava")
		end
		
		--Check if it's a pipe with pipe pipe.
		if upkey(self.playernumber) then --but only in midair and upkey
			for i, p in pairs(pipes) do
				if p:inside("up", y, self) then
					self:pipe(p.cox, p.coy, "up", i)
					net_action(self.playernumber, "pipe|" .. p.cox .. "|" .. p.coy .. "|up|" .. i)
					return
				end
			end
		end

		--dont spam blockhit
		if self.fence then
			return true
		end
		
		--check if it's an invisible block
		if tilequads[map[x][y][1]].invisible then
			if self.y-self.speedy <= y-1 then
				return false
			end
		else
			if bigmario then
				destroyblock(x, y)
				return false
			elseif (self.size == 8 or self.size == 16) and (tilequads[map[x][y][1]].breakable or (tilequads[map[x][y][1]].debris and blockdebrisquads[tilequads[map[x][y][1]].debris])) then
				destroyblock(x, y)
				if self.size == 16 then
					self.speedy = math.max(0, self.speedy)
				else
					return false
				end
			end
			
			--Check if it should bounce the block next to it, or push mario instead (Hello, devin hitch!)
			if self.gravitydir ~= "up" and self.size ~= 8 and self.size ~= 16 and not b.UPSIDEDOWNSLOPE then
				if self.x < x-22/16 then
					--check if block left of it is a better fit
					if x > 1 and tilequads[map[x-1][y][1]].collision == true then
						x = x - 1
					else
						local col = checkrect(x-28/16, self.y, self.width, self.height, {"exclude", self}, true, "ignoreplatforms")
						if #col == 0 then
							self.x = x-28/16
							if self.speedx > 0 then
								self.speedx = 0
							end
							return false
						end					
					end
				elseif self.x > x-6/16 then
					--check if block right of it is a better fit
					if x < mapwidth and tilequads[map[x+1][y][1]].collision == true then
						x = x + 1
					else
						local col = checkrect(x, self.y, self.width, self.height, {"exclude", self}, true, "ignoreplatforms")
						if #col == 0 then
							self.x = x
							if self.speedx < 0 then
								self.speedx = 0
							end
							return false
						end	
					end
				end
			end
		end

		if self.gravitydir ~= "up" then
			hitblock(x, y, self)
		end
	elseif (a == "belt") and b:getgel(math.floor(self.x+self.width/2)+1) == 4 then
		self.gravitydir = "up"
		self.falling = false
	elseif (a == "lightbridgebody" or a == "tilemoving") then
		if b.gels.bottom == 4 and a == "lightbridgebody" then
			self:purplegel("up")
			return true
		end
	end
	
	if self.gravitydir ~= "up" then
		self.jumping = false
		self.falling = true
		self.speedy = headforce
	elseif a ~= "tile" and a ~= "portaltile" and (not b.doesntchangeplayergravity) then
		self.gravitydir = "down"
	end
end

function mario:globalcollide(a, b)
	if a == "screenboundary" then
		if self.x+self.width/2 > b.x then
			self.x = b.x
		else
			self.x = b.x-self.width
		end
		self.speedx = 0
		if self.gravitydir == "left" or self.gravitydir == "right" then
			self.gravitydir = "down"
		end	
		return true
	elseif a == "grinder" or a == "checkpointflag" then
		return true
	elseif a == "regiontrigger" then
		return false
	elseif a == "vine" then
		if self.vine == false and (not self.yoshi) and self.size ~= 8 and self.size ~= 16 then
			self:grabvine(b)
		end
		
		return true
	elseif a == "cappy" then
		if b.thrown and b.holdtimer > 0 and self.speedy > 0 then
			self:jump()
			self:stopjump()
			return false
		end
		return true
	elseif a == "tilemoving" then
		if b.coin then
			b:hit()
			return true
		end
	elseif a == "enemy" then
		if b.marioused then
			return true
		elseif b.makesmariogrow then
			local oldfireenemy = self.fireenemy
			if tonumber(b.makesmariogrow) then
				self:grow(b.makesmariogrow)
			else
				self:grow()
			end
			if b.makesmarioshoot and self.size == 3 then
				--if not (oldfireenemy == b.makesmarioshoot) then
					self.fireenemy = b.makesmarioshoot
					self.dofireenemy = self.fireenemy
					if b.makesmariocolor then
						self.customcolors = b.makesmariocolor
						self.basecolors = self.customcolors
						self.colors = self.basecolors
					else
						self.customcolors = false
					end
				--end
			end
			b.marioused = true
			return true
		elseif b.givesalife then
			givelive(self.playernumber, b)
			b.marioused = true
			return true
		elseif b.makesmariostar then
			self:star()
			if b.makesmariostarduration then
				self.startimer = (mariostarduration-b.makesmariostarduration)
			end
			b.marioused = true
			return true
		elseif b.dontstopmario then
			return true
		end
	end
end

function mario:passivecollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end

	if self.size == 14 and self.ducking then --blueshell
		if a ~= "spring" and a ~= "donut" and a ~= "springgreen" and a ~= "bigmole" and a ~= "muncher" and a ~= "koopaling" and a ~= "bowser" and b.shotted then
			if self.blueshelled and b.shotted and (not (b.resistsenemykill or b.resistseverything)) then
				return true
			end
		end
	end
	
	if a == "platform" or a == "seesawplatform" or a == "portalwall" or a == "donut" or a == "icicle" or a == "ice" then
		return false
	elseif a == "tilemoving" and b.speedy < 0 then
		b:hit()
		return false
	elseif a == "box" or a == "core" then
		if not (b.gravitydir and (b.gravitydir ~= "down" and b.gravitydir ~= "up") and self.gravitydir == b.gravitydir) then
			if self.speedx < 0 then
				if self.speedx < -maxwalkspeed/2 then
					self.speedx = self.speedx - self.speedx * 6 * gdt
				end
				
			--check if box can even move
				local out = checkrect(b.x+self.speedx*gdt, b.y, b.width, b.height, {"exclude", b})
				if #out == 0 then	
					b.speedx = self.speedx
					return false
				end
			else
				if self.speedx > maxwalkspeed/2 then
					self.speedx = self.speedx - self.speedx * 6 * gdt
				end
				
				--check if box can even move
				local out = checkrect(b.x+self.speedx*gdt, b.y, b.width, b.height, {"exclude", b})
				if #out == 0 then	
					b.speedx = self.speedx
					return false
				end
			end
		end
	elseif a == "bigmole" then
		if self.y+self.height < b.y+0.2 then
			return true
		end
	elseif b.killsinsideclearpipes and self.clearpipe and self.clearpipeexitinvincibility and (not self.starred) and (not (self.animation and self.animation == "invincible"))then
		self:die("Enemy (rightcollide)")
		return false
	elseif a == "enemy" and b.killsonpassive then
		if (not self.invincible) or b.killsonpassiveignorestar then
			if b.instantkill then
				self:die("lava")
			else
				self:die("enemy")
			end
			if b.solidkill then
				return true
			else
				return false
			end
		end
	end
	if self.passivemoved == false then
		self.passivemoved = true
		if a == "tile" then
			local x, y = b.cox, b.coy
			local isinmap = inmap(x, y)
			
			--check for invisible block
			if isinmap and tilequads[map[x][y][1]].invisible then
				return false
			end
			
			--check for noteblock
			if ((self.noteblock and y == self.noteblock[2]) or (self.noteblock2 and self.speedy < 0)) and isinmap then--if self.noteblock and isinmap and tilequads[map[x][y][1]].noteblock and x == self.noteblock[1] and y == self.noteblock[2] then
				return false
			end

			if autoscrolling and not editormode then
				if autoscrollingx then
					if autoscrollingx > 0 then
						if self.x < xscroll+2/16 and not self.dead then
							self:die("time")
						end
					else
						if self.x >= xscroll+width-self.width and not self.dead then
							self:die("time")
						end
					end
				end
			end
			
			if (self.portalgun and self.pointingangle < 0) or (self.portalgun == false and self.animationdirection == "right") then
				self.x = self.x - self.characterdata.passivespeed*gdt
			else
				self.x = self.x + self.characterdata.passivespeed*gdt
			end
			self.speedx = 0
		elseif a == "frozencoin" or a == "buttonblock" or a == "movingtile" or a == "flipblock" or a == "belt" then
			if (self.portalgun and self.pointingangle < 0) or (self.portalgun == false and self.animationdirection == "right") then
				self.x = self.x - self.characterdata.passivespeed*gdt
			else
				self.x = self.x + self.characterdata.passivespeed*gdt
			end
			self.speedx = 0
		else
			--nothing, lol.
		end
	end
	
	if a == "buttonblock" or a == "flipblock" or a == "blocktogglebutton" or a == "door" then
		if autoscrolling and not editormode then
			if autoscrollingx then
				if autoscrollingx > 0 then
					if self.x < xscroll+2/16 and not self.dead then
						self:die("time")
					end
				else
					if self.x >= xscroll+width-self.width and not self.dead then
						self:die("time")
					end
				end
			end
		end
	end
	
	self:rightcollide(a, b, "passive")
end

function mario:starcollide(a, b)
	--enemies that die
	if a == "enemy" then
		if b.resistsstar then
			return true
		elseif b:shotted("right", nil, nil, false, true) then
			addpoints(firepoints[b.t] or 100, self.x, self.y)
			return true
		end
	elseif (a == "goomba" or a == "koopa" or a == "plant" or a == "bowser" or a == "squid" or a == "cheep" or a == "hammerbro" or a == "lakito" or a == "bulletbill" or a == "flyingfish" or a == "downplant" or a == "bigbill" or a == "cannonball" or (a == "kingbill" and not (levelfinished and not self.controlsenabled)) or a == "sidestepper" or a == "barrel" or a == "icicle" or a == "angrysun"
		or a == "splunkin" or a == "biggoomba" or a == "bigkoopa" or a == "fishbone" or a == "drybones" or a == "meteor" or a == "ninji" or a == "boo" or a == "mole" or a == "bomb" or a == "fireplant" or a == "downfireplant" or a == "plantfire" or a == "torpedoted" or a == "torpedolauncher" or a == "parabeetle" or a == "pokey" or a == "chainchomp" or a == "rockywrench" or a == "magikoopa" or a == "spike" or a == "spikeball" or a == "plantcreeper" or a == "fuzzy" or a == "thwomp")
		and (not b.resistsstar) then
		b:shotted("right")
		if a ~= "bowser" then
			addpoints(firepoints[a], self.x, self.y)
		end
		return true
	--enemies (and stuff) that don't do shit
	elseif a == "upfire" or a == "fire" or a == "hammer" or a == "fireball" or a == "iceball" or a == "castlefirefire" or a == "brofireball" or a == "thwomp" or a == "skewer" or (a == "boomerang" and b.kills) or a == "mariohammer" or a == "bigmole" or a == "boomboom" or a == "amp" or a == "longfire" or a == "turretrocket" or a == "glados" or a == "wrench"  or a == "koopaling" then
		return true
	elseif a == "muncher" or a == "plantcreepersegment" then
		--nothing
	end
end

function mario:hitspring(b)
	b:hit()
	self.springb = b
	self.springx = self.x
	if self.springb.springytable then
		self.springy = b.y
	else
		self.springy = b.coy
	end
	self.speedy = 0
	self.spring = true
	self.springhigh = false
	self.springtimer = 0
	self.gravity = 0
	self.mask[19] = true
	----self.animationstate = "idle"
	self:setquad()
end

function mario:leavespring()
	if self.springb.springytable then
		self.y = self.springy - self.height
	else
		self.y = self.springy - self.height-31/16
	end
	if self.springhigh then
		if self.springb.springytable then
			self.speedy = -smallspringhighforce
		else
			self.speedy = -springhighforce
		end
	else
		self.speedy = -springforce
	end
	self.animationstate = "falling"
	self:setquad()
	self.gravity = self.characterdata.yacceleration
	self.falling = true
	self.spring = false
	self.mask[19] = false
end

function mario:hitspringgreen(b)
	b:hit()
	self.springgreenb = b
	self.springgreenx = self.x
	self.springgreeny = b.coy
	self.speedy = 0
	self.springgreen = true
	self.springgreenhigh = false
	self.springgreentimer = 0
	self.gravity = 0
	self.mask[19] = true
	self.animationstate = "idle"
	self:setquad()
end

function mario:leavespringgreen()
	self.y = self.springgreeny - self.height-31/16
	if self.springgreenhigh then
		self.speedy = -springgreenhighforce
	else
		self.speedy = -springgreenforce
	end
	self.animationstate = "falling"
	self:setquad()
	self.gravity = self.characterdata.yacceleration
	self.falling = true
	self.springgreen = false
	self.mask[19] = false
end

function mario:dropvine(dir)
	if dir == "right" then
		self.x = self.x + 7/16
	else
		self.x = self.x - 7/16
	end
	self.animationstate = "falling"
	self:setquad()
	self.gravity = self.characterdata.yacceleration
	self.vine = false
	self.mask[18] = false
	self.ignoreplatform = false
end

function mario:grabvine(b)
	if self.ducking then
		local intile = checkintile(self.x, self.y, self.width, self.height, tileentities, self, "ignoreplatforms")
		local oldy = self.y
		self:duck(false)
		if (not intile) and checkintile(self.x, self.y, self.width, self.height, tileentities, self, "ignoreplatforms") then
			--push down if clipping on top
			self.y = oldy
		end
	end
	if self.fence then
		self:dropfence()
	end
	if insideportal(self.x, self.y, self.width, self.height) or self.statue or self.clearpipe then
		return
	end
	self.gravitydir = "down"
	self.mask[18] = true
	self.raccoonfly = false
	self.capefly = false
	self.ignoreplatform = true
	self.float = false
	self.floattimer = 0
	self.ignoregravity = false
	if b.istile then
		self.vine = "tile"
		self.gravity = 0
		self.speedx = 0
		self.speedy = 0
		self.animationstate = "climbing"
		self.climbframe = 2
		self.vinemovetimer = 0
		self:setquad()
		self.vinex = b.cox
		self.viney = b.coy
		if b.x > self.x then --left of vine
			self.x = b.x+b.width/2-self.width+2/16
			self.pointingangle = -math.pi/2
			self.animationdirection = "right"
			self.vineside = "left"
		else --right
			self.x = b.x+b.width/2 - 2/16
			self.pointingangle = math.pi/2
			self.animationdirection = "left"
			self.vineside = "right"
		end
	else
		self.vine = "entity"
		self.vineb = b
		self.gravity = 0
		self.speedx = 0
		self.speedy = 0
		self.animationstate = "climbing"
		self.climbframe = 2
		self.vinemovetimer = 0
		self:setquad()
		self.vinex = b.cox
		self.viney = b.coy
		if b.x > self.x then --left of vine
			self.x = b.x+b.width/2-self.width+2/16
			self.pointingangle = -math.pi/2
			self.animationdirection = "right"
			self.vineside = "left"
		else --right
			self.x = b.x+b.width/2 - 2/16
			self.pointingangle = math.pi/2
			self.animationdirection = "left"
			self.vineside = "right"
		end
	end
end

function mario:grabfence()
	if self.ducking or self.vine or self.shoe or self.clearpipe or self.statue or self.pickup or self.fireenemyride then
		return false
	end
	self.fence = true
	self.speedx = 0
	self.speedy = 0
	self.ignoregravity = true
	
	self.raccoonfly = false
	self.capefly = false
	self.planemode = false
	self.planetimer = 0
	self.ignoreplatform = true

	self.fenceframe = 1
	self.fenceanimationprogress = 1
	self.animationstate = "fence"
	self:setquad()
	self.jumping = false
	self.falling = true
	self.falloverride = true

	net_action(self.playernumber, "grabfence")
end

function mario:dropfence()
	self.fence = false

	self.ignoreplatform = false
	self.animationstate = "falling"
	self:setquad()
	self.ignoregravity = false
	net_action(self.playernumber, "dropfence")
end

function mario:doclearpipe(inpipe)
	if inpipe then
		if self.fence then
			self:dropfence()
		end
		self:setquad()
	end
end

function portalintile(x, y)
	for i = 1, players do
		local v = objects["player"][i].portal
		local x1 = v.x1
		local y1 = v.y1
		
		local x3 = x1
		local y3 = y1
		
		if v.facing1 == "up" then
			x3 = x3+1
		elseif v.facing1 == "right" then
			y3 = y3+1
		elseif v.facing1 == "down" then
			x3 = x3-1
		elseif v.facing1 == "left" then
			y3 = y3-1
		end
		
		local x2 = v.x2
		local y2 = v.y2
		
		local x4 = x2
		local y4 = y2
		
		if v.facing2 == "up" then
			x4 = x4+1
		elseif v.facing2 == "right" then
			y4 = y4+1
		elseif v.facing2 == "down" then
			x4 = x4-1
		elseif v.facing2 == "left" then
			y4 = y4-1
		end
		
		if (x == x1 and y == y1) or (x == x2 and y == y2) or (x == x3 and y == y3) or (x == x4 and y == y4) then
			return true
		end
	end
	return false
end

function hitblock(x, y, t, v)
	local size = (t and t.size) or 2
	local dir, nospritebatch = "up", false
	local hitsound = true
	if v then
		if type(v) == "table" then
			if v.dir then
				dir = v.dir
			end
			if v.nospritebatch then
				nospritebatch = true
			end
			if v.sound ~= nil then
				hitsound = v.sound
			end
		else --is koopa?
			size = 2
		end
	end
	if t then
		if (t.funnel or t.nohitsound) then
			hitsound = false
		end
		if t.hitsblocks and not t.breaksblocks then
			size = 1
		end
	end
	
	if size and not v then --net hit block
		net_action(1, "hitblock|" .. x .. "|" .. y .. "|" .. size)
	end
	
	if portalintile(x, y) then
		return
	end

	if editormode then
		return
	end

	if not inmap(x, y) then
		return
	end
	
	local r = map[x][y]
	if hitsound then
		playsound(blockhitsound)
	end

	if (not (t and t.group)) and r["group"] then
		--tile is grouped by tile tool
		local t = shallowcopy(t or {})
		t.group = true
		local x1, y1, x2, y2 = r["group"][1], r["group"][2], r["group"][3], r["group"][4]
		for tx = x1, x2 do
			for ty = y1, y2 do
				if not (x == tx and y == ty) then
					hitblock(tx, ty, t, v)
				end
			end
		end
	end
	
	if tilequads[r[1]].breakable or tilequads[r[1]].coinblock or tilequads[r[1]].noteblock then --Block should bounce!
		local blockbouncet = createblockbounce(x, y)
		if tilequads[r[1]].noteblock and dir == "down" then
			blockbouncet.timer = -0.000000001
		else
			blockbouncet.timer = 0.000000001 --yeah it's a cheap solution to a problem but screw it.
		end
		blockbouncet.x = x
		blockbouncet.y = y
		generatespritebatch()

		if (not tilequads[r[1]].noteblock) and t and t.helmet and t.helmet == "spikey" then
			--destroy blocks with spikeyhelmet
			destroyblock(x, y)
		elseif #r > 1 and entityquads[r[2]] and entityquads[r[2]].t ~= "manycoins" and entityquads[r[2]].t ~= "tiletool" and
			entityquads[r[2]].t ~= "ice" and (not ((tilequads[r[1]].breakable or tilequads[r[1]].coinblock) and entityquads[r[2]].t == "collectable")) 
			and (not (tilequads[r[1]].breakable and entityquads[r[2]].t == "coin")) then --block contained something!
			if enemiesdata[r[2]] then
				blockbouncet.content = {"customenemy", r[2]}
			else
				blockbouncet.content = entityquads[r[2]].t
			end
			blockbouncet.content2 = size
			if not tilequads[r[1]].noteblock then
				if tilequads[r[1]].invisible then
					if spriteset == 1 then
						map[x][y][1] = 113
					elseif spriteset == 2 then
						map[x][y][1] = 118
					elseif spriteset == 3 then
						map[x][y][1] = 112
					else
						map[x][y][1] = 113
					end
				else
					if spriteset == 1 then
						map[x][y][1] = 113
					elseif spriteset == 2 then
						map[x][y][1] = 114
					elseif spriteset == 3 then
						map[x][y][1] = 117
					else
						map[x][y][1] = 113
					end
				end
			end
			if entityquads[r[2]].t == "vine" then
				playsound(vinesound)
			elseif entityquads[r[2]].t ~= "pipe" then
				playsound(mushroomappearsound)
			end
			if tilequads[r[1]].noteblock then
				if entityquads[r[2]] and entityquads[r[2]].t ~= "pipe" then
					map[x][y][2] = nil
				end
			end
		elseif #r > 1 and tablecontains(customenemies, r[2]) then
			blockbouncet.content = r[2]
			blockbouncet.content2 = size
			playsound("mushroomappear")
			
			if tilequads[r[1]]:getproperty("invisible", x, y) then
				if spriteset == 1 then
					map[x][y][1] = 113
				elseif spriteset == 2 then
					map[x][y][1] = 118
				elseif spriteset == 3 then
					map[x][y][1] = 112
				else
					map[x][y][1] = 113
				end
			else
				if spriteset == 1 then
					map[x][y][1] = 113
				elseif spriteset == 2 then
					map[x][y][1] = 114
				elseif spriteset == 3 then
					map[x][y][1] = 117
				else
					map[x][y][1] = 113
				end
			end
		else
			blockbouncet.content = false
			blockbouncet.content2 = size
			
			if t and (size > 1 or t.helmet or (t.characterdata and t.characterdata.breaksblockssmall)) and (not tilequads[r[1]].coinblock)
				and (#r == 1 or (r[2] and entityquads[r[2]] and entityquads[r[2]].t and entityquads[r[2]].t ~= "manycoins" and entityquads[r[2]].t ~= "collectable") or r[2] == nil) then --destroy block!
				if tilequads[r[1]].noteblock then
					if entityquads[r[2]] and entityquads[r[2]].t ~= "pipe" then
						map[x][y][2] = nil
					end
				else
					destroyblock(x, y)
				end
			end
		end
		
		--empty coinblocks
		if ((#r == 1 or (entityquads[r[2]] and (entityquads[r[2]].t == "tiletool" or entityquads[r[2]].t == "ice"))) and tilequads[r[1]].coinblock) or
			(#r > 1 and (entityquads[r[2]] and entityquads[r[2]].t == "collectable") and (tilequads[r[1]].coinblock or tilequads[r[1]].breakable)) or
		 	((#r > 1 and (entityquads[r[2]] and entityquads[r[2]].t == "coin") and tilequads[r[1]].breakable)) then --coinblock
			playsound(coinsound)
			if tilequads[r[1]].invisible then
				if spriteset == 1 then
					map[x][y][1] = 113
				elseif spriteset == 2 then
					map[x][y][1] = 118
				elseif spriteset == 3 then
					map[x][y][1] = 112
				else
					map[x][y][1] = 113
				end
			else
				if not tilequads[r[1]].noteblock then
					if spriteset == 1 then
						map[x][y][1] = 113
					elseif spriteset == 2 then
						map[x][y][1] = 114
					elseif spriteset == 3 then
						map[x][y][1] = 117
					else
						map[x][y][1] = 113
					end
				end
			end
			if entityquads[r[2]] and entityquads[r[2]].t == "collectable" then
				local collectablet = getcollectable(x, y)
				if collectablet then --was there one to collect?
					table.insert(coinblockanimations, coinblockanimation:new(x-0.5, y-1, "collectable", collectablet))
				end
			else
				table.insert(coinblockanimations, coinblockanimation:new(x-0.5, y-1))
				mariocoincount = mariocoincount + 1
				if mariocoincount == 100 and (not nocoinlimit) then
					if mariolivecount ~= false then
						for i = 1, players do
							mariolives[i] = mariolives[i] + 1
							respawnplayers()
						end
					end
					mariocoincount = 0
					playsound(oneupsound)
				end
				addpoints(200)
			end
		end
		
		if #r > 1 and entityquads[r[2]] and entityquads[r[2]].t == "manycoins" then --block with many coins inside! yay $_$
			playsound(coinsound)
			table.insert(coinblockanimations, coinblockanimation:new(x-0.5, y-1))
			mariocoincount = mariocoincount + 1
			
			if mariocoincount == 100 and (not nocoinlimit) then
				if mariolivecount ~= false then
					for i = 1, players do
						mariolives[i] = mariolives[i] + 1
						respawnplayers()
					end
				end
				mariocoincount = 0
				playsound(oneupsound)
			end
			addpoints(200)
			
			local exists = false
			for i = 1, #coinblocktimers do
				if x == coinblocktimers[i][1] and y == coinblocktimers[i][2] then
					exists = i
				end
			end

			if exists then
				--keep track of how many coins have been collected
				coinblocktimers[exists][4] = coinblocktimers[exists][4] + 1
			end
			
			if not exists then
				table.insert(coinblocktimers, {x, y, coinblocktime, 0})
			elseif coinblocktimers[exists][3] <= 0 or coinblocktimers[exists][4] >= 20 then
				if tilequads[r[1]].noteblock then
					map[x][y][2] = nil
				else
					if spriteset == 1 then
						map[x][y][1] = 113
					elseif spriteset == 2 then
						map[x][y][1] = 114
					elseif spriteset == 3 then
						map[x][y][1] = 117
					else
						map[x][y][1] = 113
					end
				end
			end
		end
		
		if dir == "up" then
			hitontop(x, y)
		end
	else
		if t and t.helmet and t.helmet == "spikey" and tilequads[r[1]].debris and blockdebrisquads[tilequads[r[1]].debris] then
			--destroy blocks with spikeyhelmet
			destroyblock(x, y)
		end
	end
end

function hitontop(x, y)
	if breakoutmode then return end
	--kill enemies on top
	for i, v in pairs(enemies) do
		if objects[v] then
			for j, w in pairs(objects[v]) do
				if w.width and (w.active or w.killedfromblocksbelownotactive) then
					local cx = math.max(x-1,math.min(x,w.x))
					if inrange(cx, w.x, w.x+w.width, true) and inrange(w.y+w.height, y-1, y-1.125, true) then
						--get dir
						local dir = "right"
						if w.x+w.width/2 < x-0.5 then
							dir = "left"
						end
					
						if w.flipshell then
							w:flipshell(dir)
							addpoints(100, w.x+w.width/2, w.y)
						elseif w.hitbelow then
							w:hitbelow(dir)
							addpoints(100, w.x+w.width/2, w.y)
						elseif w.shotted then
							w:shotted(dir)
							addpoints(100, w.x+w.width/2, w.y)
						end
					end
				end
			end
		end
	end
	for j, w in pairs(objects["enemy"]) do --custom enemies
		if (not w.notkilledfromblocksbelow) and w.width and w.height and (w.active or w.killedfromblocksbelownotactive) then
			local centerX = w.x + w.width/2
			if inrange(centerX, x-1, x, true) and y-1 == w.y+w.height then
				--get dir
				local dir = "right"
				if w.x+w.width/2 < x-0.5 then
					dir = "left"
				end
			
				if w.shotted then
					w:shotted(dir, true)
					addpoints(100, w.x+w.width/2, w.y)
				end
			end
		end
	end
	for j, w in pairs(objects["powblock"]) do --custom enemies
		local centerX = w.x + w.width/2
		if w.active and inrange(centerX, x-1, x, true) and y-1 == w.y+w.height then
			w:hit()
		end
	end

	--make items jump
	for i, v in pairs(jumpitems) do
		for j, w in pairs(objects[v]) do
			local centerX = w.x + w.width/2
			if inrange(centerX, x-1, x, true) and y-1 == w.y+w.height then
				if w.jump then
					w:jump(x)
				end
			end
		end
	end
	for j, w in pairs(objects["enemy"]) do --custom enemies
		if w.jumpsfromblocksbelow and w.width and w.height then
			local centerX = w.x + w.width/2
			if inrange(centerX, x-1, x, true) and y-1 == w.y+w.height then
				w.falling = true
				w.speedy = -(w.jumpforce or mushroomjumpforce)
				if w.x+w.width/2 < x-0.5 then
					w.speedx = -math.abs(w.speedx)
				elseif w.x+w.width/2 > x-0.5 then
					w.speedx = math.abs(w.speedx)
				end
			end
		end
	end

	--check for coin on top
	if ismaptile(x, y-1) then
		if tilequads[map[x][y-1][1]].coin then
			collectcoin(x, y-1)
			table.insert(coinblockanimations, coinblockanimation:new(x-0.5, y-1))
		elseif objects["coin"][tilemap(x, y-1)] then
			collectcoinentity(x, y-1)
			table.insert(coinblockanimations, coinblockanimation:new(x-0.5, y-1))
		elseif objects["collectable"][tilemap(x, y-1)] and not objects["collectable"][tilemap(x, y-1)].coinblock then
			getcollectable(x, y-1)
		end
	end
end

function destroyblock(x, y, v) --v = true, "nopoints"
	if portalintile(x, y) or editormode then
		return
	end
	
	local debris = tilequads[map[x][y][1]].debris
	map[x][y][1] = 1
	objects["tile"][tilemap(x, y)] = nil
	map[x][y][2] = nil
	map[x][y][3] = nil
	map[x][y]["gels"] = {}
	playsound(blockbreaksound)
	if (not v) or not (v == "nopoints") then
		addpoints(50)
	end
	updateranges()
	
	if debris and blockdebrisquads[debris] then
		table.insert(blockdebristable, blockdebris:new(x-.5, y-.5, 3.5, -23, blockdebrisimage, blockdebrisquads[debris][spriteset]))
		table.insert(blockdebristable, blockdebris:new(x-.5, y-.5, -3.5, -23, blockdebrisimage, blockdebrisquads[debris][spriteset]))
		table.insert(blockdebristable, blockdebris:new(x-.5, y-.5, 3.5, -14, blockdebrisimage, blockdebrisquads[debris][spriteset]))
		table.insert(blockdebristable, blockdebris:new(x-.5, y-.5, -3.5, -14, blockdebrisimage, blockdebrisquads[debris][spriteset]))
	else
		table.insert(blockdebristable, blockdebris:new(x-.5, y-.5, 3.5, -23))
		table.insert(blockdebristable, blockdebris:new(x-.5, y-.5, -3.5, -23))
		table.insert(blockdebristable, blockdebris:new(x-.5, y-.5, 3.5, -14))
		table.insert(blockdebristable, blockdebris:new(x-.5, y-.5, -3.5, -14))
	end
	
	if (not v) or (v == "nopoints") then
		generatespritebatch()
	end
end

function mario:faithplate(dir)
	self.animationstate = "jumping"
	self.falling = true
	self:setquad()
end

function mario:startfall()
	if self.falloverride then
		self.falloverride = false
	elseif self.falloverridestrict then
	elseif self.falling == false then
		self.falling = true
		self.animationstate = "falling"
		self:setquad()
	end
end

function mario:die(how)
	--print("Death cause: " .. how)

	net_action(self.playernumber, "die|" .. how) --netplay die
	if (CLIENT or SERVER) and self.playernumber > 1 and not self.netaction then
		return
	end
	
	if how ~= "pit" and how ~= "time" and how ~= "lava" and how ~= "killscript" and not self.dead then
		animationsystem_playerhurttrigger(self.playernumber)

		if how == "Laser" then
			if self.size >= 2 and (not ((self.size == 8 or self.size == 16) or bigmario)) then
				self.size = 2
				self:setsize(2)
			else
				self.size = 1
				self:setsize(1)
			end
			--[[self.quadcenterY = 10
			self.graphic = self.smallgraphic
			self.size = 1
			self.quadcenterX = self.characterdata.smallquadcenterX
			self.offsetY = self.characterdata.smalloffsetX]]
		end
		
		if self.shoe then
			self.invincible = true
			self.animationtimer = 0
			self.animation = "invincible"
			self:shoed(false)
			if self.fireenemy then
				self.customcolors = self.colors
				self.dofireenemy = self.fireenemy
			end
			self:setsize(self.size)
			return
		end

		if self.helmet then
			self.invincible = true
			self.animationtimer = 0
			self.animation = "invincible"
			self:helmeted(false)
			return
		end
		
		if self.yoshi then
			self.yoshi = false
			self:shoed(false)
			return
		end

		if self.characterdata.health then
			playsound(shrinksound)
			self.health = self.health - 1
			self.invincible = true
			self.animationtimer = 0
			self.animation = "invincible"
			if self.health <= 0 then
				self:die("time")
			end
			return false
		end
		
		if self.size > 1 then
			self:shrink()
			return
		else

		end
	elseif how ~= "time" and how ~= "lava" and how ~= "killscript" then
		if bonusstage then
			levelscreen_load("sublevel", 0)
			return
		end
	end

	if self.cappy then
		self.cappy:release()
	end
	if self.yoshi then
		self.yoshi = false
		self:shoed(false)
	end
	if self.fence then
		self:dropfence()
	end
	if self.ducking then
		self:duck(false)
	end
	
	if editormode then
		self.y = 0
		self.speedy = 0
		return
	end
	self.dead = true
	
	everyonedead = true
	for i = 1, players do
		if not objects["player"][i].dead then
			everyonedead = false
		end
	end
	
	self.animationmisc = nil
	if everyonedead then
		self.animationmisc = "everyonedead"
		stopmusic()
		love.audio.stop()
		updatesizes("reset")
		updateplayerproperties("reset")
	end
	
	playsound(deathsound)
	
	if how == "time" or how == "lava" or how == "killscript" then
		noupdate = false
		self.graphic = self.smallgraphic
		self.size = 1
		self.offsetX = self.characterdata.smalloffsetX
		self.quadcenterX = self.characterdata.smallquadcenterX
		self.offsetY = self.characterdata.smalloffsetY
		self.quadcenterY = self.characterdata.smallquadcenterY
		self.drawable = true
		self.colors = mariocolors[self.playernumber]
	end
	
	if how == "pit" then
		self.animation = "deathpit"
		self.size = 1
		self.drawable = false
		self.invincible = false
	else
		self.animation = "death"
		self.ignoresize = true --don't return as mini-mario
		self.drawable = true
		self.invincible = false
		self.animationstate = "dead"
		self:setquad()
		self.speedy = 0
	end
	
	self.y = self.y - 1/16
	
	self.animationx = self.x
	self.animationy = self.y
	self.animationtimer = 0
	self.controlsenabled = false
	self.active = false
	prevsublevel = nil
	self.dkhammer = false
	self.groundfreeze = false
	self.shoe = false
	self.helmet = false
	self.statue = false
	self.statuetimer = false
	self.key = 0
	
	if not levelfinished and not testlevel and not infinitelives and mariolivecount ~= false then
		mariolives[self.playernumber] = mariolives[self.playernumber] - 1
	end
	
	return
end

function mario:laser(dir)
	if self.pickup and not self.pickup.rigidgrab then
		if dir == "right" and self.pointingangle < 0 then
			return
		elseif dir == "left" and self.pointingangle > 0 then
			return
		elseif dir == "up" and self.pointingangle > -math.pi/2 and self.pointingangle < math.pi/2 then
			return
		elseif dir == "down" and (self.pointingangle > math.pi/2 or self.pointingangle < -math.pi/2) then
			return
		end
	end
	self:die("Laser")
end

function getAngleFrame(angle, b)
	local mouseabs = math.abs(angle)
	local angleframe
	
	if (b and b.portalgun == false) and (not (playertype and playertype == "minecraft")) then
		angleframe = 5
	elseif b and b.gravitydir == "up" and b.portalgun then
		if mouseabs < math.pi/8 then
			angleframe = 4
		elseif mouseabs >= math.pi/8 and mouseabs < math.pi/8*3 then
			angleframe = 4
		elseif mouseabs >= math.pi/8*3 and mouseabs < math.pi/8*5 then
			angleframe = 3
		elseif mouseabs >= math.pi/8*5 and mouseabs < math.pi/8*7 then
			angleframe = 2
		else
			angleframe = 1
		end
	else
		if mouseabs < math.pi/8 then
			angleframe = 1
		elseif mouseabs >= math.pi/8 and mouseabs < math.pi/8*3 then
			angleframe = 2
		elseif mouseabs >= math.pi/8*3 and mouseabs < math.pi/8*5 then
			angleframe = 3
		elseif mouseabs >= math.pi/8*5 and mouseabs < math.pi/8*7 then
			angleframe = 4
		elseif mouseabs >= math.pi/8*7 then
			angleframe = 4
		end
	end
	
	return angleframe
end

function mario:emancipate(a)
	self:removeportals()
	
	local delete = {}
	
	for i, v in pairs(portalprojectiles) do
		if v.plnumber and v.plnumber == self.playernumber then
			table.insert(delete, i)
		end
	end
	
	table.sort(delete, function(a,b) return a>b end)
	
	for i, v in pairs(delete) do
		table.remove(portalprojectiles, v) --remove
	end
end

function mario:shootportal(i)
	if (not self.controlsenabled) or self.vine or self.fence then
		return false
	end

	--knockback
	if portalknockback and self.portalgun then
		local xadd = math.sin(self.pointingangle)*30
		local yadd = math.cos(self.pointingangle)*30
		self.speedx = self.speedx + xadd
		self.speedy = self.speedy + yadd
		self.falling = true
		self.animationstate = "falling"
		self:setquad()
	end
	
	if playertype == "portal" and self.portalgun and (self.portals == "both" or self.portals == i .. " only") then
		local sourcex, sourcey = self.x+self.portalsourcex, self.y+self.portalsourcey
		local direction = self.pointingangle
		
		net_action(self.playernumber, "portal|" .. i .. "|" .. sourcex .. "|" .. sourcey .. "|" .. direction)
		shootportal(self.playernumber, i, sourcex, sourcey, direction)
	elseif playertype == "minecraft" then
		local v = self
		local sourcex, sourcey = self.x+self.portalsourcex, self.y+self.portalsourcey
		local cox, coy, side, tend, x, y = traceline(sourcex, sourcey, v.pointingangle)
		
		if i == 1 then
			if cox then
				local dist = math.sqrt((v.x+v.width/2 - x)^2 + (v.y+v.height/2 - y)^2)
				if dist <= minecraftrange then
					breakingblockX = cox
					breakingblockY = coy
					breakingblockprogress = 0
				end
			end
		elseif i == 2 then
			if cox then
				local dist = math.sqrt((v.x+v.width/2 - x)^2 + (v.y+v.height/2 - y)^2)
				if dist <= minecraftrange then
					placeblock(cox, coy, side)
				end
			end
		end
	end
end

function mario:removeportal(i, preplaced)
	if (not preplaced) then
		playsound(portalfizzlesound)
	end
	self.portal:removeportal(i, true)
end

function mario:removeportals(i, preplaced)
	if (not preplaced) and ((self.portal.x1) or (self.portal.x2)) then
		playsound(portalfizzlesound)
	end

	if self.portalsavailable[1] then
		self.portal:removeportal(1)
	end
	if self.portalsavailable[2] then
		self.portal:removeportal(2)
	end

	net_action(self.playernumber, "removeportals")
end

function mario:use()
	if (not self.controlsenabled) or (self.fence) then
		return false
	end
	net_action(self.playernumber, "use|" .. self.pointingangle)

	if self.cappy and UseButtonCappy then
		self.cappy:trigger(self.animationdirection, "use")
	end
	
	if self.pickup then
		if self.pickup.destroying then
			self.pickup = false
		elseif self.pickup.carryable then
			local out = checkrect(self.pickup.x, self.pickup.y, self.pickup.width, self.pickup.height, {"exclude", self.pickup, {"player"}}, true)
			if #out == 0 then
				self:dropbox()
			end
			return
		else
			self:dropbox()
			return
		end
	end
	local xcenter = self.x + 6/16 - math.sin(self.pointingangle)*userange
	local ycenter = self.y + 6/16 - math.cos(self.pointingangle)*userange
	
	local col = userect(xcenter-usesquaresize/2, ycenter-usesquaresize/2, usesquaresize, usesquaresize)
	for i, c in pairs(col) do
		if not (c.active and c.y+c.height < self.y-4/16 and c.speedy == 0 and c.speedx == 0) then
			if not c.carryonlywithrunbutton then
				c:used(self.playernumber)
				break
			end
		end
	end
end

function mario:pickupbox(box)
	self.pickup = box
end

function mario:dropbox() --uploading...
	self.pickup:dropped(self.gravitydir)

	if self.pickup.rigidgrab then
		self.pickup = nil
		return
	end
	
	local set = false
	
	local boxx = self.x+math.sin(-self.pointingangle)*0.3
	local boxy = self.y-math.cos(-self.pointingangle)*0.3
	
	if self.pointingangle < 0 then
		if #checkrect(self.x+self.width, self.y+self.height-12/16, 12/16, 12/16, {"exclude", self.pickup}, true, "ignoreplatforms") == 0 then
			self.pickup.x = self.x+self.width
			self.pickup.y = self.y+self.height-12/16
			set = true
		end
	else
		if #checkrect(self.x-12/16, self.y+self.height-12/16, 12/16, 12/16, {"exclude", self.pickup}, true, "ignoreplatforms") == 0 then
			self.pickup.x = self.x-12/16
			self.pickup.y = self.y+self.height-12/16
			set = true
		end
	end
	
	if set == false then
		if #checkrect(self.x+self.width, self.y+self.height-12/16, 12/16, 12/16, {"exclude", self.pickup}, true, "ignoreplatforms") == 0 then
			self.pickup.x = self.x+self.width
			self.pickup.y = self.y+self.height-12/16
		elseif #checkrect(self.x-12/16, self.y+self.height-12/16, 12/16, 12/16, {"exclude", self.pickup}, true, "ignoreplatforms") == 0 then
			self.pickup.x = self.x-12/16
			self.pickup.y = self.y+self.height-12/16
		elseif #checkrect(self.x, self.y+self.height, 12/16, 12/16, {"exclude", self.pickup}, true) == 0 then
			self.pickup.x = self.x
			self.pickup.y = self.y+self.height
		elseif #checkrect(self.x, self.y-12/16, 12/16, 12/16, {"exclude", self.pickup}, true) == 0 then
			self.pickup.x = self.x
			self.pickup.y = self.y-12/16
		else
			self.pickup.x = self.x
			self.pickup.y = self.y
		end
	end
	
	if self.pickup.emancipatecheck then
		for h, u in pairs(emancipationgrills) do
			if u.active then
				if u.dir == "hor" then
					if inrange(self.pickup.x+6/16, u.startx-1, u.endx, true) and inrange(u.y-14/16, boxy, self.pickup.y, true) then
						self.pickup:emancipate(h)
					end
				else
					if inrange(self.pickup.y+6/16, u.starty-1, u.endy, true) and inrange(u.x-14/16, boxx, self.pickup.x, true) then
						self.pickup:emancipate(h)
					end
				end
			end
		end
	end
	self.pickup = nil
end

function mario:cubeemancipate()
	self.pickup = nil
end

function mario:duck(ducking, size, dontmove, playercontrols) --goose
	if self.ducking and (self.quicksand or mariomakerphysics) and self.gravitydir == "down" and playercontrols then
		--[[dont unduck if clipping
		if self.size ~= 14 and
			checkintile(self.x, self.y-self.height, self.width, self.height, tileentities, self, "ignoreplatforms") then
			return false
		end]]
	end
	if self.ducking and playercontrols then
		--dont unduck if under clearpipe
		if checkinclearpipesegment(self.x, self.y-self.height, self.width, self.height) then
			return false
		end
	end
	--dont duck if small ducking is disabled
	if ducking and (self.size <= 1 and not self.characterdata.smallducking) then
		return false
	end
	self.ducking = ducking
	if (size or self.size) > 1 then
		if not dontmove then
			if self.gravitydir == "up" then
				if self.ducking then
					self.height = 12/16
				else
					self.height = 24/16
				end
			else
				if self.ducking then
					self.y = self.y + 12/16
					self.height = 12/16
				else
					self.y = self.y - 12/16
					self.height = 24/16
				end
			end
		end

		if self.ducking then
			if self.size == 16 then
				self.quadcenterY = self.characterdata.hugeclassicquadcenterY
				self.offsetY = self.characterdata.hugeclassicoffsetY+12
			else
				self.quadcenterY = self.characterdata.duckquadcenterY
				self.offsetY = self.characterdata.duckoffsetY
			end
			if self.size == 14 then --shell mario
				if math.abs(self.speedx) >= maxrunspeed then
					if self.speedx > 0 then
						self.speedx = koopasmallspeed
					else
						self.speedx = -koopasmallspeed
					end
					self.friction = 0
					self.blueshelled = true
				end
			end
			self.raccoonfly = false
			self.capefly = false
			self.planemode = false
			self.planetimer = 0
		else
			if self.size == 16 then
				self.quadcenterY = self.characterdata.hugeclassicquadcenterY
				self.offsetY = self.characterdata.hugeclassicoffsetY
			elseif self.size == 4 then --call me yandere dev cause imma copypaste a whole lot of else ifs
				self.quadcenterY = self.characterdata.hammerquadcenterY
				self.offsetY = self.characterdata.hammeroffsetY
			elseif self.size == 6 or self.size == 9 then
				self.quadcenterY = self.characterdata.raccoonquadcenterY
				self.offsetY = self.characterdata.raccoonoffsetY
			elseif self.size == 10 then
				self.quadcenterY = self.characterdata.capequadcenterY
				self.offsetY = self.characterdata.capeoffsetY
			elseif self.size == 14 then
				self.quadcenterY = self.characterdata.shellquadcenterY
				self.offsetY = self.characterdata.shelloffsetY
			elseif self.size == 15 then
				self.quadcenterY = self.characterdata.boomerangquadcenterY
				self.offsetY = self.characterdata.boomerangoffsetY
			else
				self.quadcenterY = self.characterdata.bigquadcenterY
				self.offsetY = self.characterdata.bigoffsetY
			end
			if self.size == 14 then
				self.friction = self.characterdata.friction
				self.blueshelled = false
			end
			
			if self.supersized then
				self:setsize(self.size)
			end
		end
	end
	if ducking then --netplay
		net_action(self.playernumber, "duck")
	else
		net_action(self.playernumber, "unduck")
	end
end

function mario:drybonesduck(ducking)
	if ducking then
		if self.drybonesshellcooldown then
			return false
		end
		playsound(blockbreaksound)
		self.drybonesshelltimer = drybonesshelltime
		self.ducking = ducking
		self.invincible = true
		self.speedx = 0
		self.speedy = 0
		self.oldportalgun = self.portalgun
		self.portalgun = false
	else
		self.ducking = ducking
		self.invincible = false
		self.portalgun = self.oldportalgun
		self.oldportalgun = false
	end
end

function mario:pipe(x, y, dir, i)--, warppipe)
	if not i then
		return false
	end
	if self.clearpipe then
		return false
	end
	local p = pipes[i]
	if not p then
		return false
	end

	if p.t == "pipe" then
		self.animationmisc = {"sub", p.sub, p.exitid, dir}
	elseif p.t == "warppipe" then
		self.animationmisc = {"warppipe", p.world, p.level, dir}
	end

	self.active = false
	self.animation = "pipe" .. dir
	self.invincible = false
	self.drawable = true
	self.animationx = x
	self.animationy = y
	self.animationtimer = 0
	self.controlsenabled = false
	playsound(pipesound)

	--travel to another pipe in same sublevel
	local linked = false
	if inmap(x, y) and map[x][y][7] and map[x][y][7] == "exit" then
		local tx, ty = map[x][y][5], map[x][y][6]
		if inmap(tx, ty) and map[tx][ty][2] and entityquads[map[tx][ty][2]].t then
			local tentity = entityquads[map[tx][ty][2]].t
			local exitdir = "up"
			local ex, ey = tx, ty --exit x, y
			--cool pipe entity exits
			if pipes[tilemap(tx,ty)] and not pipes[tilemap(tx,ty)].legacy then
				local pe = pipes[tilemap(tx,ty)]
				exitdir = pe:opp(pe.dir)
				if pe.dir == "down" then
					ex = pe.x
				elseif pe.dir == "up" then
					ex = pe.x
				elseif pe.dir == "left" then
					ex = tx
				elseif pe.dir == "right" then
					ex = tx-1
				end
				ey = pe.y
			elseif exitpipes[tilemap(tx,ty)] then
				local pe = exitpipes[tilemap(tx,ty)]
				exitdir = pe.dir
				if pe.dir == "down" then
					ex = pe.x
				elseif pe.dir == "up" then
					ex = pe.x
				end
			--nasty nasty ew old pipes
			elseif tentity == "pipespawn" then
				exitdir = "up"
			elseif tentity == "pipespawndown" then
				exitdir = "down"
			elseif (inmap(tx, ty-1) and tilequads[map[tx][ty-1][1]]:getproperty("collision", tx, ty-1)) or tentity == "pipespawnhor" then
				--top is blocked!
				local lblocked = (inmap(tx-1, ty) and tilequads[map[tx-1][ty][1]]:getproperty("collision", tx-1, ty))
				local rblocked = (inmap(tx+1, ty) and tilequads[map[tx+1][ty][1]]:getproperty("collision", tx+1, ty))
				if (lblocked and not rblocked) or (tentity == "pipespawnhor" and not rblocked) then
					exitdir = "right"
					if tentity == "pipe2" then
						local dblocked1 = (inmap(tx-1, ty+1) and tilequads[map[tx-1][ty+1][1]]:getproperty("collision", tx-1, ty))
						local dblocked2 = (inmap(tx, ty+1) and tilequads[map[tx][ty+1][1]]:getproperty("collision", tx-1, ty))
						if (not dblocked1) and (not dblocked2) then
							exitdir = "down"
						end
					end
				elseif (rblocked and not lblocked) or tentity == "pipespawnhor" then
					exitdir = "left"
				else
					exitdir = "down"
				end
			end
			linked = true
			self.animationmisc = {"linked", tx, ty, exitdir}
		end
	end

	
	if self.animationmisc[1] ~= "linked" and intermission then
		respawnsublevel = self.animationmisc[2] --respawn in sublevel
	end
	
	self.customscissor = p.scissor[p:opp(dir)]
	if self.pickup then
		self.pickup.customscissor = p.scissor[p:opp(dir)]
	end
	if dir == "down" then
		self.animationstate = "idle"
	elseif dir == "left" then
		self.animationstate = "running"
	elseif dir == "up" then
		self.animationstate = "jumping"
	elseif dir == "left" then
		self.animationstate = "running"
	end
	
	self:setquad()
end

function mario:pipetravel()
	--number: sublevel
	--string: warpzone
	--table: linked pipe
	local traveltype = self.animationmisc[1]
	if traveltype == "sub" then --sublevel
		if editormode then
			savelevel()
		end
		updatesizes()
		updateplayerproperties()
		levelscreen_load("sublevel", self.animationmisc[2])
		pipeexitid = self.animationmisc[3]
	elseif traveltype == "linked" then --link
		local x, y, dir = self.animationmisc[2], self.animationmisc[3], self.animationmisc[4]

		--[[offsets i guess
		if dir == "up" then x = x-1; y = y-1
		elseif dir == "down" then x = x-1; y = y-1
		elseif dir == "left" then x = x-1-(6/16); y = y -1
		elseif dir == "right" then x = x-1-(6/16); y = y -1
		end]]
		local p = pipes[tilemap(x,y)]
		if not p then
			p = exitpipes[tilemap(x,y)]
		end
		if not p then
			p = {
				x = x-1,
				y = y-1,
				scissor = {},
			}
			p.scissor["up"] = {x-4, y-1-4, 5, 4}
			p.scissor["down"] = {x-4, y, 5, 4}
			p.scissor["left"] = {x-1-4, y-4, 4, 5}
			p.scissor["right"] = {x, y-4, 4, 5}
			print("pipe not found ", x, y)
		end
		if (x and y and inmap(x,y) and (map[x][y][1] and tilequads[map[x][y][1]] and not tilequads[map[x][y][1]]:getproperty("collision", x,y))) then
			--just teleport
			self.x = x-.5-self.width/2
			self.y = y-self.height
			self.speedx = 0
			self.speedy = 0
			self.active = true
			self.controlsenabled = true
			self.animation = nil
			self.customscissor = nil
			if self.pickup then
				self.pickup.customscissor = nil
			end
			self:setquad()
			camerasnap()
			if self.pickup and self.pickup.portaled then
				self.pickup:portaled()
			end
			return
		end
		
		self.controlsenabled = false
		self.active = false
		self.drawable = false
		self.animationx = x
		self.animationy = y
		self.speedx = 0
		self.speedy = 0
		self.animationtimer = pipeupdelay
		
		self.customscissor = p.scissor[dir]
		if self.pickup then
			self.pickup.customscissor = p.scissor[dir]
		end

		if dir == "up" then
			self.animation = "pipeupexit"
			self.x = p.x-self.width/2
			self.y = self.animationy + 20/16
			
			self.animationstate = "idle"
		elseif dir == "down" then
			self.animation = "pipedownexit"
			self.x = p.x-self.width/2
			self.y = (self.animationy+8/16) - 20/16
			
			self.animationstate = "idle"
		elseif dir == "left" then
			self.animation = "pipeleftexit"
			self.x = self.animationx+10/16
			self.y = self.animationy - self.height
			
			self.animationstate = "running"
			self.pointingangle = math.pi/2
			self.animationdirection = "left"
		elseif dir == "right" then
			self.animation = "piperightexit"
			self.x = self.animationx + 6/16
			self.y = self.animationy - self.height
			
			self.animationstate = "running"
			self.pointingangle = -math.pi/2
			self.animationdirection = "right"
		end
		self:setquad()
		camerasnap()
		if self.pickup and self.pickup.portaled then
			self.pickup:portaled()
		end
	else --warpzone
		updatesizes()
		updateplayerproperties()
		if editormode then
			savelevel()
		end
		warpzone(self.animationmisc[2], self.animationmisc[3])
	end
end

function mario:door(x, y, i)
	if self.clearpipe then
		return false
	end
	playsound(dooropensound)
	self.active = false
	self.animation = "door"
	self.invincible = false
	self.drawable = true
	self.animationx = x or math.ceil(self.x+self.width/2)
	self.animationy = y or math.floor(self.y+self.height)
	self.animationtimer = 0
	local s = tostring(i)
	local s2 = s:split("|")
	local targetsublevel = tonumber(s2[1]) or 0
	local exitid = tonumber(s2[2]) or 1
	self.animationmisc = {targetsublevel, exitid}

	self.controlsenabled = false
end

function mario:noteblockwarp(x, y, i)
	playsound(vinesound)
	self.active = false
	self.animation = "noteblockwarp"
	self.invincible = true
	self.drawable = true
	self.animationx = x
	self.animationy = y
	self.animationtimer = 0
	local s = tostring(i)
	local s2 = s:split("|")
	local targetsublevel = tonumber(s2[1]) or 0
	local exitid = tonumber(s2[2]) or 1
	self.animationmisc = targetsublevel

	self.active = false
	self.speedy = -20
	self.speedx = 0

	self.controlsenabled = false
end

function mario:flag()
	if levelfinished then
		return
	end
	if self.size == 8 then
		--mega mushroom
		megamushroomsound:stop()
		self.size = 2
		self:setsize(2)
		self.largeshrink = true
		self.starred = false
		self.startimer = mariostarduration
	end
	self.static = false
	if self.ducking then
		self:duck(false)
	end
	--self.ducking = false
	self.animation = "flag"
	self.flagtimer = 0
	self.invincible = true--false
	self.drawable = true
	self.controlsenabled = false
	self.animationstate = "climbing"
	self.fireanimationtimer = fireanimationtime
	self.spinanimationtimer = raccoonspintime
	self.pointingangle = -math.pi/2
	self.animationtimer = 0
	self.speedx = 0
	self.speedy = 0
	self.x = flagx-2/16
	self.gravity = 0
	self.climbframe = 2
	self.active = false
	self:setquad()
	levelfinished = true
	levelfinishtype = "flag"
	subtractscore = false
	firework = false
	castleflagy = castleflagstarty
	objects["screenboundary"]["flag"].active = false
	
	--get score
	flagscore = flagscores[1]
	for i = 1, #flagvalues do
		if self.y < flagvalues[i]-13+flagy then
			flagscore = flagscores[i+1]
		else
			break
		end
	end
	
	addpoints(flagscore)
	
	--get firework count
	fireworkcount = tonumber(string.sub(math.ceil(mariotime), -1, -1))
	if fireworkcount ~= 1 and fireworkcount ~= 3 and fireworkcount ~= 6 then
		fireworkcount = 0
	end
	
	if portalbackground then
		fireworkcount = 0
	end
	
	stopmusic()
	love.audio.stop()
	
	--one up at the top of the flag
	if mariomakerphysics and self.y < flagvalues[#flagvalues]-13+flagy then
		if mariolivecount ~= false then
			for i = 1, players do
				mariolives[i] = mariolives[i]+1
			end
		end
		table.insert(scrollingscores, scrollingscore:new("1up", self.x, self.y))
		playsound(oneupsound)
	end

	if self.largeshrink then
		playsound(shrinksound)
	end
	
	--time level completed in
	realmariotime = mariotime

	--kill shit
	for i, v in pairs(objects["enemy"]) do
		if v.deleteonflagpole then
			v:output()
			v.instantdelete = true
		end
	end
	
	playsound(levelendsound)
end

function mario:axe()
	if levelfinished then
		return
	end
	self.ducking = false
	for i = 1, players do
		objects["player"][i]:removeportals()
	end
	
	for i, v in pairs(objects["platform"]) do
		objects["platform"][i] = nil
	end

	self.static = false
	self.animation = "axe"
	self.fireanimationtimer = fireanimationtime
	self.invincible = true--false
	self.drawable = true
	self.animationx = axex
	self.animationy = axey
	self.animationbridgex = axex-1
	self.animationbridgey = axey+2
	self.controlsenabled = false
	self.animationdirection = "right"
	self.animationtimer = 0
	self.speedx = 0
	self.speedy = 0
	self.gravity = 0
	self.active = false
	levelfinished = true
	levelfinishtype = "castle"
	levelfinishedmisc = 0
	levelfinishedmisc2 = 1
	if marioworld >= 8 and not love.filesystem.exists(mappackfolder .. "/" .. mappack .. "/" .. marioworld+1 .. "-1.txt") then --changed  since 
		levelfinishedmisc2 = 2
	end
	bridgedisappear = false
	self.animationtimer2 = castleanimationbridgedisappeardelay
	self.axeforgivedistance = 2 --how far the axe can be away from the bridge and still destroy it
	bowserfall = false
	objects["screenboundary"]["axe"] = nil
	
	self.axeboss = false
	if objects["bowser"] and objects["bowser"]["boss"] then
		self.axeboss = objects["bowser"]["boss"]
	else
		local checktable = {"koopaling", "boomboom", "enemy"}
		for i2, v2 in pairs(checktable) do
			local dobreak = false
			for i, v in pairs(objects[v2]) do
				if i == "enemy" then
					if v.boss and (not v.shot) then
						self.axeboss = v
						dobreak = true
						break
					end
				elseif (not v.enemy) and (not v.dead) then
					self.axeboss = v
					dobreak = true
					break
				end
			end
			if dobreak then
				break
			end
		end
	end
	if self.axeboss and (not self.axeboss.shot) then
		local v = self.axeboss
		v.speedx = 0
		v.speedy = 0
		v.active = false
		v.gravity = 0
		v.category = 1
	else
		self.animationtimer = castleanimationmariomove
		self.active = true
		self.gravity = self.characterdata.yacceleration
		self.animationstate = "running"
		self.speedx = 4.27
		self.pointingangle = -math.pi/2
		
		stopmusic()
		love.audio.stop()
		playsound(castleendsound)
	end
	
	axex = false
	axey = false
end

function mario:vineanimation()
	if not (self.vinex and self.viney) then
		return
	end
	self.animation = "vine"
	self.invincible = false
	self.drawable = true
	self.controlsenabled = false
	self.animationx = self.x
	self.animationy = vineanimationstart
	self.animationmisc = map[self.vinex][self.viney][3]
	self.active = false
	self.vine = false
end

function mario:star()
	--made more accurate
	if self.size ~= 8 then
		addpoints(1000, self.x+self.width/2, self.y)
		self.colors = self.characterdata.starcolors[1]
		playsound(mushroomeatsound)
	end
	
	self.startimer = 0
	self.starred = true
	stopmusic()
	music:stop(custommusic)
	if self.size == 8 then
		--mega mushroom
		playsound(megamushroomsound)
	else
		music:play("starmusic")
	end
end

--get value from table, return value if not table
local function gettable(v, i)
	if type(v) == "table" then
		return v[i]
	else
		return v
	end
end

function mario:button(b)
	if noupdate or (not self.controlsenabled) then
		return false
	end
	--custom enemy fire bindings
	if self.fireenemy or self.characterdata.fireenemy then
		local f = self.fireenemy or self.characterdata.fireenemy
		if f.enemy then
			local checktable = {f.enemy}
			if type(f.enemy) == "table" then
				checktable = f.enemy
			end
			--check for what enemy can get fired
			for i, n in pairs(checktable) do
				local held = true
				if gettable(f.holdbutton, i) then
					--check if button is held down
					local holdchecktable = {gettable(f.holdbutton, i)}
					if type(gettable(f.holdbutton, i)) == "table" then
						holdchecktable = gettable(f.holdbutton, i)
					end
					for bi, button in pairs(holdchecktable) do
						if not keydown(button, self.playernumber) then
							held = false
							break
						end
					end
				end
				local sizepass = true
				if gettable(f.size, i) then
					if type(gettable(f.size, i)) == "table" then
						if not tablecontains(gettable(f.size, i)) then
							sizepass = false
						end
					elseif self.size ~= gettable(f.size, i) then
						sizepass = false
					end
				end
				if held and b == (gettable(f.button, i) or "run") and sizepass then
					local pass = true
					if (gettable(f.firewhenfalling, i) and not self.falling) and not (gettable(f.firewhenjumping, i) and self.jumping) then
						pass = false
					elseif (gettable(f.firewhennotfalling, i) and self.falling) then
						pass = false
					elseif (gettable(f.firewhennotjumping, i) and self.jumping) then
						pass = false
					elseif (gettable(f.firewhenjumping, i) and not self.jumping) and not (gettable(f.firewhenfalling, i) and self.falling) then
						pass = false
					end
					if (gettable(f.dontfirewhenriding, i)) and self.fireenemyride then
						pass = false
					end
					if (gettable(f.firewhenswimming, i) and (not self.water)) or (gettable(f.firewhennotswimming, i) and self.water) then
						pass = false
					end
					if ((gettable(f.firewhennotonvine, i) or gettable(f.firewhennotclimbing, i)) and self.vine) then
						pass = false
					end
					if ((gettable(f.firewhennotonfence, i) or gettable(f.firewhennotclimbing, i)) and self.fence) then
						pass = false
					end
					if pass then
						self:firecustomenemy(i)
						if not gettable(f.fireallenemies, i) then
							break
						end
					end
				end
			end
		else
			--old format
			if b == "run" then
				self:firecustomenemy(1)
			end
		end
	end
end

function mario:buttonrelease(b)
	if noupdate or (not self.controlsenabled) then
		return false
	end
	--un-reverse controls for purple gel
	if self.reversecontrols and (b == "left" or b == "right") then
		self.reversecontrols = false
	end
	--custom enemy fire bindings
	if self.fireenemy or self.characterdata.fireenemy then
		local f = self.fireenemy or self.characterdata.fireenemy
		if f.enemy then
			local checktable = {f.enemy}
			if type(f.enemy) == "table" then
				checktable = f.enemy
			end
			--kill enemies that get killed when buttons were released
			for i, n in pairs(checktable) do
				local button = gettable(f.button, i)
				if button and gettable(f.killonbuttonrelease, i) and b == button then
					if self.fireenemykillonbuttonrelease and self.fireenemykillonbuttonrelease[n] then
						for enemyi, obj in pairs(self.fireenemykillonbuttonrelease[n]) do
							if not (obj.delete or obj.dead) then
								if obj.transforms and obj:gettransformtrigger("buttonrelease") then
									obj:transform(obj:gettransformsinto("buttonrelease"))
								end
								obj:output()
								obj.instantdelete = true
							end
						end
						self.fireenemykillonbuttonrelease[n] = false
						self.fireenemyanim = false
					end
				end
			end
		end
	end
end

function mario:firecustomenemy(i)
	local f = self.fireenemy or self.characterdata.fireenemy
	local t = (gettable(f.enemy, i) or f[1])

	if editormode or (self.ducking and (not gettable(f.fireifducking, i))) or self.statue or self.clearpipe then
		return false
	end
	if self.shoe or self.fence or self.pickup then
		return false
	end
	if (not self.fireenemycount[t]) or self.fireenemycount[t] < (gettable(f.max, i) or f[2] or math.huge) then
		local dir = "right"
		local ox = (gettable(f.offsetx, i) or 0)
		local oy = (gettable(f.offsety, i) or 0)
		if (self.portalgun and self.pointingangle > 0) or (self.portalgun == false and self.animationdirection == "left") then
			dir = "left"
			ox = -(gettable(f.offsetx, i) or 0)
		end
		local spawny = self.y+self.height+oy
		if not gettable(f.enemy, i) then
			spawny = self.y+1 --backwards compatibility
		end
		local obj = enemy:new(self.x+self.width/2+.5+ox, spawny, t)
		table.insert(objects["enemy"], obj)
		if gettable(f.fireatangle, i) then
			--fire at an angle
			local angle = self.pointingangle
			if self.portalgun == false and (not self.characterdata.aimwithoutportalgun) then --aim with keys
				if upkey(self.playernumber) then
					angle = 0
				elseif self.animationdirection == "left" then
					angle = math.pi/2
				else
					angle = -math.pi/2
				end
			end
			obj.speedx = -math.sin(angle)*(gettable(f.speed, i) or 10)
			obj.speedy = -math.cos(angle)*(gettable(f.speed, i) or 10)
		else
			if dir == "right" then
				obj.speedx = gettable(f.speed, i) or 10
			else
				obj.speedx = -(gettable(f.speed, i) or 10)
			end
		end
		if gettable(f.makefriendly, i) then
			obj.killsenemies = true
			obj.category = 13
			obj.mask[3] = obj.mask[1]
			obj.mask[4] = not obj.mask[1]
		end
		if gettable(f.addplayerspeedx, i) then
			obj.speedx = obj.speedx+self.speedx
		end
		if gettable(f.addplayerspeedy, i) then
			obj.speedy = obj.speedy+self.speedy
		end
		if gettable(f.playerspeedx, i) then
			self.speedx = gettable(f.playerspeedx, i)
		end
		if gettable(f.playerspeedy, i) then
			self.speedy = gettable(f.playerspeedy, i)
		end

		obj.fireballthrower = self

		if not self.fireenemycount[t] then
			self.fireenemycount[t] = 0
		end
		self.fireenemycount[t] = self.fireenemycount[t] + 1
		if gettable(f.killonbuttonrelease, i) then
			if not self.fireenemykillonbuttonrelease then
				self.fireenemykillonbuttonrelease = {}
			end
			if not self.fireenemykillonbuttonrelease[t] then
				self.fireenemykillonbuttonrelease[t] = {}
			end
			table.insert(self.fireenemykillonbuttonrelease[t], obj)
		end
		if gettable(f.killonbuttonrelease, i) then
			if not self.fireenemykillonbuttonrelease then
				self.fireenemykillonbuttonrelease = {}
			end
			if not self.fireenemykillonbuttonrelease[t] then
				self.fireenemykillonbuttonrelease[t] = {}
			end
			table.insert(self.fireenemykillonbuttonrelease[t], obj)
		end
		if gettable(f.ride, i) then
			self.fireenemyride = obj
			self.fireenemyoffsetx = gettable(f.rideoffsetx, i) or 0
			self.fireenemyoffsety = gettable(f.rideoffsety, i) or 0
			self.fireenemyduckingoffsetx = gettable(f.rideduckingoffsetx, i)
			self.fireenemyduckingoffsety = gettable(f.rideduckingoffsety, i)
			self.fireenemyactive = (gettable(f.rideactive, i) == true)
			self.fireenemydrawable = gettable(f.ridedrawable, i)
			if gettable(f.rideaftertransform, i) then
				obj.fireenemyrideaftertransform = self
			end
			self.fireenemycopyquadi = gettable(f.ridecopyquadi, i)
			self.fireenemyanim = gettable(f.rideanim, i)
			self.fireenemyquadi = gettable(f.ridequad, i)
		end
		if gettable(f.sticktoplayer, i) then
			obj.sticktoplayer = self.playernumber
			obj.sticktoplayeroffsetx = gettable(f.stickoffsetx, i)
			obj.sticktoplayeroffsety = gettable(f.stickoffsety, i)
			if gettable(f.flipstickoffsetx, i) and dir == "left" and obj.sticktoplayeroffsetx then
				obj.sticktoplayeroffsetx = -obj.sticktoplayeroffsetx
			end
			self.fireenemyanim = gettable(f.stickanim, i)
			self.fireenemyquadi = gettable(f.stickquad, i)
		end
		self.fireenemyfireanim = gettable(f.fireanim, i)
		self.fireenemyfirequadi = gettable(f.firequad, i)

		self.fireanimationtimer = 0
		self:setquad()
		if (not obj.spawnsound) and (not gettable(f.nofiresound, i)) then
			playsound(fireballsound)
		end
		net_action(self.playernumber, "fire")
	end
end

function mario:fire()
	if (not noupdate) and self.controlsenabled and self.ducking == false and (not self.statue) and (not self.groundpounding) and (not self.clearpipe) then
		if self.yoshi then
			if upkey(self.playernumber) then
				if not self.jumping and not self.falling then
					if self.animationdirection == "right" then
						self.speedx = -3
					else
						self.speedx = 3
					end
				end
				self:stompbounce("yoshi", self.yoshi)
				self:shoed(false)
			elseif self.yoshiswallow or self.yoshispitting then
			elseif self.size ~= 8 and self.size ~= 16 then --no giant yoshi tounge
				if self.yoshitoungeenemy then
					--spit enemy
					local v = self.yoshitoungeenemy
					if v.eaten then
						v.active = true
						v.drawable = true
						v.y = self.y+self.height-1.5
						if self.animationdirection == "left" then
							v.x = self.x-v.width
							if v.yoshispit then
								v.speedx = -(v.yoshispitspeedx or 0)
							end
						else
							v.x = self.x+self.width
							if v.yoshispit then
								v.speedx = (v.yoshispitspeedx or 0)
							end
						end
						--spit shell
						if v.yoshispit then
							v.speedy = (v.yoshispitspeedy or 0)
							if v.transforms and v.gettransformtrigger and v:gettransformtrigger("yoshispit") then
								v:transform(v:gettransformsinto("yoshispit"))
								v:output("transformed")
								v.dead = true
							end
						elseif v.stomp then
							v.speedx = 0
							if v.small then
								v:stomp(self.x, self)
							else
								v:stomp(self.x, self)
								if not v.small then
									v:stomp(self.x, self)
								end
								v:stomp(self.x, self)
							end
						end
						playsound(shotsound)
					end
					self.yoshitoungeenemy = false
					self.yoshispitting = 0.2
				else
					self.yoshitounge = true
				end
				net_action(self.playernumber, "fire")
			end
			return
		end

		if self.cappy and (not UseButtonCappy) then
			self.cappy:trigger(self.animationdirection, "run")
		end

		if self.shoe then
			if upkey(self.playernumber) then
				self:shoed(false, false, true)
				return
			end
		end

		--pick up
		if self.pickupready and self.pickupready.pickupready and ((not self.pickupready.pickupreadyplayers) or self.pickupready.pickupreadyplayers[self.playernumber]) and (not self.pickupready.parent) and (not self.pickupready.carryonlywithrunbutton) then
			if self.pickup then
				if self.pickup.destroying then
					self.pickup = false
				else
					self:dropbox()
					return
				end
			end
			self.pickupready:used(self.playernumber)
			self.pickupready = false
		elseif self.pickup and self.pickup.rigidgrab then
			if self.pickup.carryable then
				local out = checkrect(self.pickup.x, self.pickup.y, self.pickup.width, self.pickup.height, {"exclude", self.pickup, {"player"}}, true)
				if #out == 0 then
					self:dropbox()
					return false
				end
			else
				self:dropbox()
				return false
			end
		end

		--fence
		if self.fence then
			return
		end

		if self.helmet == "cannonbox" and FireButtonCannonHelmet then
			if #objects["cannonball"] < 4 then
				self.cannontimer = cannonboxdelay+0.1
			end
			return false
		end
		
		if self.fireenemy or self.characterdata.fireenemy then
			
		elseif (self.size == 6 or self.size == 9 or self.size == 10) and self.animation ~= "grow2" and not self.fence and not self.vine then
			if self.spinanimationtimer >= raccoonspintime and (not (self.speedy ~= 0 and self.raccoonfly)) then
				local dir = "right"
				if self.animationdirection == "left" then
					dir = "left"
				end
				table.insert(objects["mariotail"], mariotail:new(self.x, self.y, dir, self)) --spawn a tail. It's strange but it works.
				self.spinanimationtimer = 0
				self.spinanimationprogress = 1
				self:setquad()
				playsound(raccoonswingsound)
				net_action(self.playernumber, "fire")
			end
		elseif (self.size == 3 or self.size == 7 or self.size == 13) then
			if self.fireballcount < maxfireballs then
				local dir = "right"
				if (self.portalgun and self.pointingangle > 0) or (self.portalgun == false and self.animationdirection == "left") then
					dir = "left"
				end
				local add = .5
				if dir == "left" then
					add = -.5
				end
				if self.size == 7 then
					table.insert(objects["fireball"], fireball:new(self.x+add, self.y, dir, self, "iceball"))
					playsound(fireballsound)
				elseif self.size == 13 then
					table.insert(objects["fireball"], fireball:new(self.x+add, self.y, dir, self, "superball"))
					playsound(superballsound)
				else
					table.insert(objects["fireball"], fireball:new(self.x+add, self.y, dir, self))
					playsound(fireballsound)
				end
				self.fireballcount = self.fireballcount + 1
				self.fireanimationtimer = 0
				self:setquad()
				net_action(self.playernumber, "fire")
			end
		elseif self.size == 4 then --hammer
			if self.fireballcount < maxfireballs then
				local dir = "right"
				if (self.portalgun and self.pointingangle > 0)  or (self.portalgun == false and self.animationdirection == "left") then
					dir = "left"
				end
				table.insert(objects["mariohammer"], mariohammer:new(self.x+.5, self.y, dir, self))
				self.fireballcount = self.fireballcount + 1
				self.fireanimationtimer = 0
				self:setquad()
				playsound(fireballsound)
				net_action(self.playernumber, "fire")
			end
		elseif self.size == 15 then --boomerang
			if self.fireballcount < maxfireballs then
				local dir = "right"
				if (self.portalgun and self.pointingangle > 0)  or (self.portalgun == false and self.animationdirection == "left") then
					dir = "left"
				end
				table.insert(objects["boomerang"], boomerang:new(self.x, self.y+2/16, dir, self))
				self.fireballcount = self.fireballcount + 1
				self.fireanimationtimer = 0
				self:setquad()
				playsound(boomerangsound)
				net_action(self.playernumber, "fire")
			end
		end
	end
end

function mario:fireballcallback(t) --name of enemy
	if t then
		self.fireenemycount[t] = self.fireenemycount[t] - 1
	else
		self.fireballcount = self.fireballcount - 1
	end
end

function mario:mariohammercallback()
	self.fireballcount = self.fireballcount - 1
end

function collectcoin(x, y, amount, group)
	if x and y then
		map[x][y][1] = 1

		if (not group) and map[x][y]["group"] then
			--tile is grouped by tile tool
			local r = map[x][y]
			local x1, y1, x2, y2 = r["group"][1], r["group"][2], r["group"][3], r["group"][4]
			for tx = x1, x2 do
				for ty = y1, y2 do
					if (not (x == tx and y == ty)) and tilequads[map[tx][ty][1]].coin then
						collectcoin(tx, ty, amount, "group")
					end
				end
			end
		end
	end
	addpoints(200)
	playsound(coinsound)
	mariocoincount = mariocoincount + (amount or 1)
	while mariocoincount >= 100 and (not nocoinlimit) do
		if mariolivecount ~= false then
			for i = 1, players do
				mariolives[i] = mariolives[i] + 1
				respawnplayers()
			end
		end
		mariocoincount = mariocoincount - 100
		playsound(oneupsound)
	end
end

function collectcoinentity(x, y) --DONT MIND ME OK
	objects["coin"][tilemap(x, y)] = nil
	addpoints(200)
	playsound(coinsound)
	mariocoincount = mariocoincount + 1
	while mariocoincount >= 100 and (not nocoinlimit) do
		if mariolivecount ~= false then
			for i = 1, players do
				mariolives[i] = mariolives[i] + 1
				respawnplayers()
			end
		end
		mariocoincount = 0
		playsound(oneupsound)
	end
end

function mario:portaled(dir)
	if self.pickup and self.pickup.portaled then
		self.pickup:portaled()
	end
	if not sonicrainboom or not self.rainboomallowed then
		return
	end
	
	local didrainboom = false
	
	if dir == "up" then
		if self.speedy < -rainboomspeed then
			didrainboom = true
		end
	elseif dir == "left" then
		if self.speedx < -rainboomspeed then
			didrainboom = true
		end
	elseif dir == "right" then
		if self.speedx > rainboomspeed then
			didrainboom = true
		end
	end
	
	if didrainboom then
		table.insert(rainbooms, rainboom:new(self.x+self.width/2, self.y+self.height/2, dir))
		earthquake = rainboomearthquake
		self.rainboomallowed = false
		playsound(rainboomsound)
		
		for i, v in pairs(enemies) do
			if objects[v] then
				for j, w in pairs(objects[v]) do
					w:shotted()
					if v ~= "bowser" then
						addpoints(firepoints[v], w.x, w.y)
					else
						for i = 1, 6 do
							w:shotted()
						end
					end
				end
			end
		end
		
		self.hats = {33}
	end
end

function mario:shootgel(i)
	table.insert(objects["gel"], gel:new(self.x+self.width/2+8/16, self.y+self.height/2+6/16, i))
	
	local xspeed = math.cos(-self.pointingangle-math.pi/2)*gelcannonspeed
	local yspeed = math.sin(-self.pointingangle-math.pi/2)*gelcannonspeed
	
	objects["gel"][#objects["gel"]].speedy = yspeed
	objects["gel"][#objects["gel"]].speedx = xspeed
end

function mario:respawn()
	if mariolivecount ~= false and (mariolives[self.playernumber] == 0 or levelfinished) then
		return
	end
	
	local i = 1
	while i <= players and (objects["player"][i].dead or self.playernumber == i) do
		i = i + 1
	end
	
	local fastestplayer = objects["player"][i]
	
	if fastestplayer then
		if mapwidth <= width then
			for i = 2, players do
				if not objects["player"][i].dead and math.abs(starty-objects["player"][i].y) > math.abs(fastestplayer.y) then
					fastestplayer = objects["player"][i]
				end
			end
		else
			for i = 2, players do
				if not objects["player"][i].dead and objects["player"][i].x > fastestplayer.x then
					fastestplayer = objects["player"][i]
				end
			end
		end
	end
	
	self.speedy = 0
	self.speedx = 0
	self.dead = false
	self.size = 1
	self.health = self.characterdata.health
	self:setsize(1)
	self.drawable = true
	self.animationstate = "idle"
	self:setquad()
	
	self.animation = "invincible"
	self.invincible = true
	self.animationtimer = 0
	
	if (not fastestplayer) or (fastestplayer.y >= mapheight) then
		self.x = startx
		self.y = starty-1-self.height
	else
		self.y = fastestplayer.y + fastestplayer.height-self.height
		self.x = fastestplayer.x
	end
	
	self.jumping = false
	self.falling = true
	
	self.controlsenabled = true
	self.active = true
end

function mario:dive(water)
	if water then
		self.gravity = self.characterdata.uwyacceleration
		self.water = true
		self.speedx = self.speedx*waterdamping
		self.speedy = self.speedy*waterdamping

		if self.capefly then
			self.raccoonfly = false
			self.capefly = false
			self.planemode = false
			self.planetimer = 0
		end
		if self.float then
			self.floattimer = 0
			self.float = false
			self.ignoregravity = false
		end
	else
		self.gravity = self.characterdata.yacceleration
		self.water = false
		if self.speedy < 0 then
			self.speedy = -self.characterdata.waterjumpforce
		end
	end
end

function mario:turretshot(tx, ty, sx, sy, knockback) --turret
	if self.pickup and not self.pickup.rigidgrab then
		if tx > self.x+self.width/2 and self.pointingangle < 0 then --right
			return false
		elseif tx < self.x+self.width/2 and self.pointingangle > 0 then --left
			return false
		end
	end
	if self.hitpointsdelay > 0 then
		return false
	end
	if self.dead or self.starred then 
		return false
	end
	if knockback then
		if (self.speedx < 0) ~= (sx < 0) then
			self.speedx = self.speedx + (sx/math.abs(sx))*9 --push back
		end
	end
	if self.invincible then 
		return false
	end
	self.hitpointsdelay = turrethitdelay
	self.hitpoints = self.hitpoints - 1
	self.hitpointtimer = 0 -- reset refill timer
	if self.hitpoints <= 0 then
		self:die("turret shots")
		self.hitpoints = maxhitpoints / 2
	end
	local v = math.max(0, self.hitpoints/maxhitpoints)*255
	makepoof(self.x+self.width/2+(8*(math.random()-.5))/16, self.y+self.height/2+(8*(math.random()-.5))/16, "turretshot", {v,v,v})

	
	return true
	--print(self.hitpoints)
end

function mario:groundshock()--for sledge bros
	if self.speedy == 0 and not self.groundfreeze and (not self.vine) and (not self.fence) and (not self.clearpipe) then
		self.groundfreeze = groundfreezetime
		self.speedx = 0
		self.animationstate = "idle"
		self:setquad()
	end
end

function mario:freeze() --ice ball
	if not self.frozen then
		self.groundfreeze = 4
		self.frozen = true
		self.speedx = 0
		self.animationstate = "idle"
		self:setquad()
	end
end

function mario:shoed(shoe, initial, drop) --get in shoe (type, make sound?, drop shoe?)
	if shoe then
		self.shoeoffsetY = 0
		if self.ducking then
			self:duck(false)
		end
		if self.fence then
			self:dropfence()
		end
		self.raccoonfly = false
		self.capefly = false
		self.planemode = false
		self.planetimer = 0
		if shoe == "yoshi" then
			if self.size == 1 then
				self.shoeoffsetY = self.characterdata.smallyoshioffsetY
			elseif self.size == 8 then
				self.shoeoffsetY = self.characterdata.hugeyoshioffsetY
			elseif self.size == -1 then
				self.shoeoffsetY = self.characterdata.tinyyoshioffsetY
			elseif self.size == 16 then
				self.shoeoffsetY = self.characterdata.hugeclassicyoshioffsetY
			elseif self.size > 1 then
				self.shoeoffsetY = self.characterdata.bigyoshioffsetY
			end
		else
			if self.size == 1 then
				self.shoeoffsetY = self.characterdata.smallshoeoffsetY
			elseif self.size == 8 then
				self.shoeoffsetY = self.characterdata.hugeshoeoffsetY
			elseif self.size == -1 then
				self.shoeoffsetY = self.characterdata.tinyshoeoffsetY
			elseif self.size == 16 then
				self.shoeoffsetY = self.characterdata.hugeclassicshoeoffsetY
			elseif self.size > 1 then
				self.shoeoffsetY = self.characterdata.bigshoeoffsetY
			end
			self.weight = 2
		end
		if self.shoe then
			return false
		else
			self.shoe = shoe
			if not initial then
				playsound(stompsound)
			end
		end
		if shoe == "cloudinfinite" then
			self.shoe = "cloud"
			self.gravity = 0
			self.cloudtimer = 999999
		elseif shoe == "cloud" then
			self.gravity = 0
			self.cloudtimer = cloudtime
		elseif shoe == "drybonesshell" then
			self.drybonesshelltimer = 0
		end
		self.gravitydir = "down"
	else
		self.shoeoffsetY = 0
		if self.shoe == "cloud" then
			self.gravity = self.characterdata.yacceleration
			self.cloudtimer = false
		elseif self.shoe == "yoshi" then
			if self.yoshi then
				local panic = true
				if self.animation ~= "invincible" then
					panic = false
				end
				self.yoshi:ride(false, panic)
				self.yoshi = false
			end
		elseif drop then
			local t = "goombashoe"
			if self.shoe == "drybonesshell" then
				t = "drybonesshell"
			end
			local obj = mushroom:new(self.x+self.width/2, self.y+self.height-1/16, t)
			obj.uptimer = mushroomtime+0.00001
			if self.animationdirection == "right" then
				obj.animationdirection = "left"
			else
				obj.animationdirection = "right"
			end
			obj.heel = (self.shoe == "heel")
			if self.helmet == "propellerbox" and (self.jumping or self.falling) then
				if not checkintile(obj.x, self.y+self.height+2/16, obj.width, obj.height, tileentities, obj, "ignoreplatforms") then
					obj.y = self.y+self.height+2/16
				end
				obj.speedy = 12
			end
			table.insert(objects["mushroom"], obj)
		end
		self.shoe = false
		if self.fireenemy then
			self.customcolors = self.colors
			self.dofireenemy = self.fireenemy
		end
		--self:setsize(self.size)
		playsound(shotsound)
		net_action(self.playernumber, "shoed|" .. tostring(shoe) .. "|" .. tostring(initial) .. "|" .. tostring(drop))
	end
	return true
end

function mario:helmeted(helmet)
	if helmet then
		if self.helmet or self.size == -1 or (helmet == "cannonbox" and (self.size == 8 or self.size == 16)) then
			return false
		else
			self.helmet = helmet
			self.helmetanimtimer = 1
			playsound(helmetsound)
			return true
		end
	else
		self.helmet = false
		playsound(shotsound)
		return false
	end
end

function mario:statued(statue) --tanooki statue
	if statue then
		self.speedx = 0
		playsound(suitsound)
		self.statue = true
		self.colors = self.characterdata.statuecolor
		self.invincible = true
		
		self.raccoonfly = false
		self.capefly = false
		self.planemode = false
		self.planetimer = 0
	else
		playsound(suitsound)
		self.statue = false
		self.colors = self.basecolors
		self.invincible = false
	end
	return true
end

function mario:animationwalk(dir, speed)
	self.animation = "animationwalk"
	self.animationstate = "running"
	self.animationmisc = {dir, math.max(0, math.min(40, (speed or maxwalkspeed)))}
	self.animationdirection = dir
end

function mario:stopanimation()
	self.animation = false
	self.drawable = true
end

function mario:stopgroundpound(force)
	if self.shoe == "drybonesshell" then
		if not self.lavasurfing then
			self:drybonesduck(true)
		end
		self.groundpounding = false
		self.groundpoundcanceled = false
	elseif (not downkey(self.playernumber)) or force then
		self.groundpounding = false
		self.groundpoundcanceled = false
	end
end

function mario:updateportalsavailable()
	if self.portals == "none" then
		self.portalsavailable = {false, false}
	elseif self.portals == "1 only" then
		self.portalsavailable = {true, false}
	elseif self.portals == "2 only" then
		self.portalsavailable = {false, true}
	elseif self.portals == "gel" then
		self.portalsavailable = {false, false}
	else --both
		self.portalsavailable = {true, true}
	end
end

function mario:setbasecolors(color)
	if self.character and self.characterdata then
		if self.characterdata[color] then
			self.basecolors = self.characterdata[color]
		else
			self.basecolors = _G[color]
		end
	else
		self.basecolors = _G[color]
	end
end
