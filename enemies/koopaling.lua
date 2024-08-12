koopaling = class:new()

function koopaling:init(x, y, t, r)
	--PHYSICS STUFF
	self.x = x-12/16
	self.y = y-23/16
	self.speedy = 0
	self.speedx = -koopalingspeed
	self.width = 24/16
	self.height = 24/16
	self.static = false
	self.active = true
	self.category = 16
	
	self.mask = {	true, 
					false, false, false, false, true,
					false, true, false, false, false,
					false, false, true, false, false,
					true, true, false, false, false,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	
	self.emancipatecheck = false
	self.autodelete = false
	self.freezable = true
	self.frozen = false
	
	self.t = t or 1
	self.enemy = false
	if type(t) == "string" then
		--right click menu
		local v = convertr(t, {"num", "string"}, true)

		self.t = v[1]
		self.enemy = (v[2] ~= "boss")
		self.key = (v[2] == "key")
	end
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = koopalingimg
	self.quad = koopalingquad[self.t][1]
	self.offsetX = 12
	self.offsetY = -1
	self.quadcenterX = 14
	self.quadcenterY = 20
	self.frame = 1
	
	self.rotation = 0 --for portals
	
	self.direction = "left"
	self.animationdirection = "left"
	self.animationtimer = 0
	
	self.jumping = false --is jumping
	self.jumpdelay = math.random(#koopalingjumpdelay)
	self.jumptimer = 0
	self.jumpthrough = false
	self.shootdelay = math.random(#koopalingshootdelay)
	self.shoottimer = 0
	self.shooting = false
	
	self.hp = 3
	
	self.stomped = false
	self.stompedjump = false
	self.stomptimer = 0
	self.stompbounce = false--causes mario to bounce
	self.stompbouncex = 20
	
	self.falling = false
	
	self.dead = false
	self.deadpos = false --where died
	self.deathtimer = 0
	self.freezetimer = 0
	
	self.stompable = true
	
	if self.t == 3 then
		self.projectiletable = {}
	elseif self.t == 8 then
		self.width = 20/16
		self.height = 20/16
		self.y = self.y+4/16
		self.offsetX = 10
		self.offsetY = 3
		self.shothealth = 5
		self.shothp = self.shothealth
		self.stompbounce = false
		self.stompwait = 0

		self.movedirection = "left"
		self.speedx = 0
		self.shelltimer = 0

		if r and type(r) == "string" then
			self.enemy = (r ~= "boss")
			self.key = (r == "key")
		end
	elseif self.t == 9 then
		self.hp = 40
		
		self.speedx = 0
		self.height = 36/16
		self.y = self.y - 12/16
		
		self.offsetX = 12
		self.offsetY = -8
		self.quadcenterX = 18
		self.quadcenterY = 21
		self.frame = 2
		self.quad = koopalingquad[self.t][self.frame]
		
		self.jumpcount = 1
		
		self.bigjumptimer = 0
		self.bigjumptime = 0.5
		
		self.landtimer = false
		
		self.stompable = false
		self.bigjump = false

		if r and type(r) == "string" then
			self.enemy = (r ~= "boss")
			self.key = (r == "key")
		end

		self.jumppos = {1,1}
		self.playerpos = {1,1}
	end
	
	--self.returntilemaskontrackrelease = true
	self.shot = false
end

function koopaling:update(dt)
	--rotate back to 0 (portals)
	self.rotation = math.fmod(self.rotation, math.pi*2)
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
	
	local closestplayer = 1 --find closest player
	for i = 2, players do
		local v = objects["player"][i]
		if (not v.dead) and math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
			closestplayer = i
		end
	end
	local distance = math.abs(self.x - objects["player"][closestplayer].x)
	
	self.jumping = (not (self.speedy == 0)) or self.bigjumpwait
	--self.stompable = (not self.shell)
	if self.t ~= 8 then
		self.stompbounce = self.shell
	end

	if self.hittimer then
		self.hittimer = math.max(0, self.hittimer - dt)
	end
	
	--falling
	if self.t == 9 then
		if self.y > mapheight+5 then
			if #objects["koopaling"] < 2 and (not self.enemy) then
				for i = 1, players do
					local obj = levelball:new(objects["player"][i].x+6/16, objects["player"][i].y+11/16)
					table.insert(objects["levelball"], obj)
					obj.drawable = false
					obj.sound = bowserendsound
					obj.autodelete = false
				end
			elseif self.key then
				objects["player"][closestplayer].key = (objects["player"][closestplayer].key or 0) + 1
				playsound(keysound)
			end
			return true
		else
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
	else
		if self.y > mapheight+5 then
			if #objects["koopaling"] < 2 and (not self.enemy) then
				for i = 1, players do
					local obj = levelball:new(objects["player"][i].x+6/16, objects["player"][i].y+11/16)
					table.insert(objects["levelball"], obj)
					obj.drawable = false
					obj.sound = koopalingendsound
					obj.autodelete = false
				end
			elseif self.key then
				objects["player"][closestplayer].key = (objects["player"][closestplayer].key or 0) + 1
				playsound(keysound)
			end
			return true
		end
	end
	
	if self.dead then
		if self.t == 9 then
			self.speedy = self.speedy + shotgravity*dt
		
			self.y = self.y+self.speedy*dt
			
			if self.speedy > bowserfallspeed then
				self.speedy = bowserfallspeed
			end
			return false
		elseif self.t == 8 then
			self.speedy = self.speedy + shotgravity*dt
			
			self.x = self.x+self.speedx*dt
			self.y = self.y+self.speedy*dt
			
			return false
		else
			self.animationtimer = self.animationtimer + dt
			while self.animationtimer > koopalinganimationdelay3 do --death animation
				self.frame = 10+((self.frame-9)%4)
				self.quad = koopalingquad[self.t][self.frame]
				self.animationtimer = self.animationtimer - koopalinganimationdelay3
			end
			
			self.deathtimer = self.deathtimer + dt
			if self.deathtimer > koopalingdeathtime then
				if #objects["koopaling"] < 2 and (not self.enemy) then
					local obj = levelball:new(self.x+12/16, self.y)
					table.insert(objects["levelball"], obj)
					--obj.x = self.deadpos[1]+(self.width/2)-(obj.width/2) --drop from death spot
					obj.quad = levelballquad[self.t+1]
					obj.activatey = self.deadpos[2]-5
					obj.sound = koopalingendsound
				elseif self.key then
					objects["player"][closestplayer].key = (objects["player"][closestplayer].key or 0) + 1
					playsound(keysound)
				end
				shufflesound:stop()
				return true
			elseif self.deathtimer > 1 then --jump into air
				local t = (self.deathtimer-1)/(koopalingdeathtime-1)
				local tox = self.deadpos[1]--(xscroll+(width/2))
				self.x = self.deadpos[1]*(1-t)+(tox*t)
				self.y = self.deadpos[2]*(1-t)+(-self.height*t)
				return false
			else
				return false
			end
		end
	elseif self.frozen then
		return false
	elseif self.jumping and not self.landtimer and not (self.t == 9 and self.shooting) then --jumping
		if self.t == 9 then
			--bowser 3 (jesus so much uncommented code)
			if self.bigjump then
				local wait = 0.4
				local fallwait = 0.4
				local ydist = 8*(self.supersized or 1)
				if self.bigjumptimer < wait then
					--stand still for a while
					self.bigjumptimer = self.bigjumptimer + dt
					self.frame = 2
				elseif self.bigjumptimer-wait < self.bigjumptime then
					--curved jump
					self.bigjumpwait = false
					self.frame = 1
					self.bigjumptimer = self.bigjumptimer + dt
					local t = math.min(1, self.bigjumptimer-wait)/(self.bigjumptime)
					self.x = self.jumppos[1]*(1-t)+((self.playerpos[1])*t)
					self.y = self.jumppos[2]*(1-t)+((self.playerpos[2]-ydist)*t)
				elseif self.bigjumptimer-wait < self.bigjumptime+fallwait then
					--stay still for a bit
					self.bigjumptimer = self.bigjumptimer + dt
					self.frame = 7
					self.speedy = 0
					local v = math.min(1,(self.bigjumptimer-wait-self.bigjumptime-0.1)/(fallwait-0.1))
					if v > 0 then
						self.y = (self.playerpos[2]-ydist) + math.sin(math.pi*(1+v))*0.5
					end
					if not (self.bigjumptimer-wait < self.bigjumptime+fallwait) then
						self.speedy = 8
					end
				else
					self.bigjumpwait = false
					self.frame = 7
				end
			else
				self.frame = 1
				self.shoottimer = self.shoottimer + dt
				if self.shoottimer > koopalingshootdelay[self.shootdelay] then --shoot
					self.speedx = 0
					self.frame = 3
					self.shootdelay = math.random(#koopalingshootdelay)
					self.shoottimer = 0
					self.shooting = koopalingshoottime
					return
				end
			end
			self.quad = koopalingquad[self.t][self.frame]
		elseif self.shell and self.t ~= 8 then --jumping in shell (bowser jr doesn't)
			if self.stompedjump and self.speedy > 14 and (not self.surprisejump) then
				if math.random(1,9) == 1 then
					self.surprisejump = true
					self.stomptimer = koopalingstomptime
				else
					self:unshell()
				end
			else
				self.animationtimer = self.animationtimer + dt
				while self.animationtimer > koopalinganimationdelay2 do --shell animation
					self.frame = 5+((self.frame-4)%4) --super mario maker 2
					self.quad = koopalingquad[self.t][self.frame]
					self.animationtimer = self.animationtimer - koopalinganimationdelay2
				end
			end
			self.quad = koopalingquad[self.t][self.frame]
		else
			if self.jumpthrough then
				if self.animationdirection == "left" then
					self.speedx = -koopalingjumpspeed
				elseif self.animationdirection == "right"  then
					self.speedx = koopalingjumpspeed
				end
			end
		end
	elseif self.shell then --in shell
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > koopalinganimationdelay2 do --shell animation
			self.frame = 5+((self.frame-4)%4)
			self.quad = koopalingquad[self.t][self.frame]
			self.animationtimer = self.animationtimer - koopalinganimationdelay2
		end
		if self.t == 8 then
			--bowser jr
			--follow mario
			if self.stompwait > 0 then
				self.stompwait = self.stompwait - dt
			else
				if self.x > objects["player"][closestplayer].x + 2 then
					self.animationdirection = "left"
					self.movedirection = "right"
				elseif self.x < objects["player"][closestplayer].x - 2 then
					self.animationdirection = "right"
					self.movedirection = "left"
				end
				if self.movedirection == "left" then
					if self.speedx > koopalingshellspeed then
						self.speedx = self.speedx - friction*dt
						if self.speedx < koopalingshellspeed then
							self.speedx = koopalingshellspeed
						end
					elseif self.speedx < koopalingshellspeed then
						self.speedx = self.speedx + friction*dt
						if self.speedx > koopalingshellspeed then
							self.speedx = koopalingshellspeed
						end
					end
				else
					if self.speedx < -koopalingshellspeed then
						self.speedx = self.speedx + friction*dt
						if self.speedx > -koopalingshellspeed then
							self.speedx = -koopalingshellspeed
						end
					elseif self.speedx > -koopalingshellspeed then
						self.speedx = self.speedx - friction*dt
						if self.speedx < -koopalingshellspeed then
							self.speedx = -koopalingshellspeed
						end
					end
				end
			end
			if self.jumpthrough then
				if self.animationdirection == "left" then
					self.speedx = -koopalingjumpspeed
				elseif self.animationdirection == "right"  then
					self.speedx = koopalingjumpspeed
				end
				if self.supersized then
					self.speedy = -19
				else
					self.speedy = -16
				end
			end
			--shell time
			if math.abs(self.x-objects["player"][closestplayer].x) < koopalingshelldistance then
				self.shelltimer = self.shelltimer - dt
				if self.shelltimer < 0 then
					self:unshell()
					for x = math.floor(self.x)+1, math.floor(self.x+self.width-0.1)+1 do
						for y = math.floor(self.y)+1, math.floor(self.y+self.height-0.1)+1 do
							if ismaptile(x, y) then
								local r = map[x][y]
								if r then
									if self.supersized and (tilequads[r[1]].coinblock or (tilequads[r[1]].debris and blockdebrisquads[tilequads[r[1]].debris])) then
										destroyblock(x, y, "nopoints")
									elseif tilequads[r[1]].breakable then
										destroyblock(x, y, "nopoints")
									elseif tilequads[r[1]].collision then
										broke = false
									end
								end
							end
						end
					end
				end
			end
		else
			self.stomptimer = self.stomptimer + dt
			if self.stomptimer > koopalingstomptime then
				if self.t ~= 7 then
					self.stompedjump = true
				end
				self.speedy = -koopalingshelljumpforce[self.t]
				self.stomptimer = 0
				self.gravity = koopalingjumpgravity
				--jump towards player
				if self.x > objects["player"][closestplayer].x then
					self.animationdirection = "left"
					self.speedx = -koopalingjumpspeed
				elseif self.x < objects["player"][closestplayer].x then
					self.animationdirection = "right"
					self.speedx = koopalingjumpspeed
				end
			end
		end
	elseif self.shooting then--shooting
		if self.shooting < koopalingshoottime/2 then
			if self.frame == 3 then
				local speedx, speedy = 4, 0
				if self.t == 3 then
					--wendy
					speedx = 4
					speedy = -4
					local offsetx, offsety = -12/16, 2/16
					if self.animationdirection == "right" then
						offsetx = self.width
					else
						speedx = -speedx
					end

					if #self.projectiletable < 4 then
						local obj = plantfire:new(self.x+offsetx, self.y+offsety, {speedx, speedy, 2, 0})
						if self.supersized then
							supersizeentity(obj)
						end
						obj.parent = self
						table.insert(self.projectiletable, obj)
						obj.idforparent = #self.projectiletable
						table.insert(objects["plantfire"], obj)
					end
					playsound(suitsound)
				elseif self.t == 6 then
					speedx = 4
					speedy = -4
					local offsetx, offsety = -12/16, 2/16
					if self.animationdirection == "right" then
						offsetx = self.width
					else
						speedx = -speedx
					end
					if #objects["plantfire"] < 4 then
						local obj = plantfire:new(self.x+offsetx, self.y+offsety, {speedx, speedy, 3, 0})
						if self.supersized then
							supersizeentity(obj)
						end
						table.insert(objects["plantfire"], obj)
					end
					playsound(suitsound)
				elseif self.t == 8 then
					local offsetx, offsety = self.width/2, 12/16
					local obj = plantfire:new(self.x+offsetx, self.y+offsety)
					if self.supersized then
						supersizeentity(obj, 3)
					else
						supersizeentity(obj, 1.5)
					end
					if self.animationdirection == "right" then
						obj.speedx = math.abs(obj.speedx)
					else
						obj.speedx = -math.abs(obj.speedx)
					end
					table.insert(objects["plantfire"], obj)
					playsound(fireballsound)
				elseif self.t == 9 then
					speedx = 4
					speedy = 0
					local offsetx, offsety = -12/16, 2/16
					if self.animationdirection == "right" then
						offsetx = self.width
					else
						speedx = -speedx
					end
					local obj = plantfire:new(self.x+offsetx, self.y+offsety, {speedx, speedy, 4, 0})
					if self.supersized then
						supersizeentity(obj)
					end
					table.insert(objects["plantfire"], obj)
					playsound(firesound)
				else
					local p = objects["player"][closestplayer]
					local relativex, relativey = ((p.x+p.width/2) + -(self.x+self.width/2)), ((p.y+p.height) + -(self.y+self.height))--((p.x+p.width/2) - (self.x+self.width/2)), ((p.y+p.height) - (self.y+height))
					local distance = math.sqrt(relativex*relativex+relativey*relativey)
					local speed = 4
					speedx, speedy = (relativex)/distance*(speed), (relativey)/distance*(speed)
					
					local offsetx, offsety = -8/16, 5/16
					if self.animationdirection == "right" then
						offsetx = self.width
						speedx = math.abs(speedx)
					else
						speedx = -math.abs(speedx)
					end
					for i = 1, 3 do
						local obj = plantfire:new(self.x+offsetx, self.y+offsety, {speedx, speedy, 1, koopalingshootspread*(i-1)})
						if self.supersized then
							supersizeentity(obj)
						end
						table.insert(objects["plantfire"], obj)
					end
					playsound(suitsound)
				end
			end
			self.frame = 4
		else
			self.frame = 3
		end
	
		self.shooting = self.shooting - dt
		if self.shooting < 0 then
			if self.t ~= 8 and self.t ~= 9 then
				if self.x > objects["player"][closestplayer].x then
					self.animationdirection = "left"
					self.speedx = -koopalingspeed
				else
					self.animationdirection = "right"
					self.speedx = koopalingspeed
				end
			end
			self.shooting = false
			self.frame = 1
		end
		self.quad = koopalingquad[self.t][self.frame]
	elseif self.landtimer then
		self.landtimer = self.landtimer + dt
		local delay = 0.2
		if self.landtimer > delay*4 then
			self.landtimer = false
			self.frame = 1
		elseif self.landtimer > delay*3 then
			self.frame = 5
		elseif self.landtimer > delay*2 then
			self.frame = 6
		elseif self.landtimer > delay*1 then
			self.frame = 9
		else
			self.frame = 8
		end
		self.quad = koopalingquad[self.t][self.frame]
	elseif self.t == 9 then
		if self.x > objects["player"][closestplayer].x then --face player
			self.animationdirection = "left"
		elseif self.x < objects["player"][closestplayer].x - 2 then
			self.animationdirection = "right"
		end
		
		self.shoottimer = self.shoottimer + dt
		if self.shoottimer > koopalingshootdelay[self.shootdelay] then --shoot
			self.speedx = 0
			self.frame = 3
			self.quad = koopalingquad[self.t][self.frame]
			self.shootdelay = math.random(#koopalingshootdelay)
			self.shoottimer = 0
			self.shooting = koopalingshoottime
			return
		end
		
		if (not self.track) then
			self.jumptimer = self.jumptimer + dt
			if self.jumptimer > 0.6 then --jump
				self.jumpcount = self.jumpcount + 1
				if self.jumpcount > 5 and distance < 20 then
					self.bigjump = true
					self.bigjumpwait = true
					self.bigjumptimer = 0
					self.jumppos = {self.x, self.y}
					if objects["player"][closestplayer].dead then
						self.jumppos = {self.x, self.y-10}
						self.playerpos = {self.x, self.y-10}
					else
						self.playerpos = {objects["player"][closestplayer].x+objects["player"][closestplayer].width/2-self.width/2, objects["player"][closestplayer].y}
					end
					self.frame = 2
				else
					self.frame = 1
					self.speedy = -koopalinghopjumpforce[self.t]
				end
				self.gravity = koopalingjumpgravity
				self.quad = koopalingquad[self.t][self.frame]
				self.jumptimer = 0
				self.jumping = true
				return
			end
		end
		
		self.frame = 2
		self.quad = koopalingquad[self.t][self.frame]
	else --walking
		self.gravity = yacceleration
		if self.x > objects["player"][closestplayer].x + 2 then --face player
			if self.animationdirection ~= "left" or self.speedx < 0 then
				self.animationdirection = "left"
				if self.t ~= 8 then
					self.speedx = -koopalingspeed
				end
			end
		elseif self.x < objects["player"][closestplayer].x - 2 then
			if self.animationdirection ~= "right" or self.speedx > 0 then
				self.animationdirection = "right"
				if self.t ~= 8 then
					self.speedx = koopalingspeed
				end
			end
		end
		
		self.animationtimer = self.animationtimer + dt
		while self.animationtimer > koopalinganimationdelay do --dance animation
			if self.frame == 1 then
				self.frame = 2
			else
				self.frame = 1
			end
			self.quad = koopalingquad[self.t][self.frame]
			self.animationtimer = self.animationtimer - koopalinganimationdelay
		end
		
		self.shoottimer = self.shoottimer + dt
		if self.shoottimer > koopalingshootdelay[self.shootdelay] then --shoot
			self.speedx = 0
			self.frame = 3
			self.quad = koopalingquad[self.t][self.frame]
			self.shootdelay = math.random(#koopalingshootdelay)
			self.shoottimer = 0
			self.shooting = koopalingshoottime
			return
		end
		
		if (not self.track) then
			self.jumptimer = self.jumptimer + dt
			if (self.t ~= 8 and self.jumptimer > koopalingjumpdelay[self.jumpdelay]) or (self.t == 8 and self.jumptimer > koopalingjrjumpdelay[self.jumpdelay]) then --jump
				--shell if player is too far away
				if self.t == 8 and math.abs(self.x-objects["player"][closestplayer].x) > koopalingshelldistance then
					self:doshell()
					self.speedy = -10
					return
				end
				if self.t == 8 then
					--bowser jr.
					if not self.jumpthrough and math.random(1, 8) == 1 then --jump higher if player jumping
						self.speedy = -koopalingjumpforce[self.t]
						self.heavyjump = true
					else
						self.speedy = -koopalinghopjumpforce[self.t]
					end
				else
					if not self.jumpthrough and math.random(1, 3) == 1 then --jump higher if player jumping
						self.speedy = -koopalingjumpforce[self.t]
					else
						self.speedy = -koopalinghopjumpforce[self.t]
					end
				end
				self.gravity = koopalingjumpgravity
				--jump towards player
				if self.x > objects["player"][closestplayer].x then
					self.animationdirection = "left"
					self.speedx = -koopalingjumpspeed
				elseif self.x < objects["player"][closestplayer].x  then
					self.animationdirection = "right"
					self.speedx = koopalingjumpspeed
				end
				if self.t == 8 then
					if self.heavyjump then
						self.speedx = 0
					elseif math.random(1, 3) == 1 then
						self.speedx = -self.speedx
					end
				end
				self.frame = 2
				self.quad = koopalingquad[self.t][self.frame]
				self.jumpdelay = math.random(#koopalingjumpdelay)
				self.jumptimer = 0
				self.jumping = true
				return
			end
		end
		
		return false
	end
end

function koopaling:stomp(cause)--hehe koopaling stomp
	self.trackable = false
	self.hp = self.hp - 1
	if self.hp < 1 then
		self.dead = true
		self:die()
		return
	end
	
	self.speedy = math.max(self.speedy, 0)
	if self.t == 8 then
		self.stompwait = 0.2
	end
	self:doshell()
end

function koopaling:shotted(dir) --fireball, star, turtle
	if self.t == 9 then
		if self.hittimer and self.hittimer > 0 then
			--don't get hit multiple times in a row
			return
		end
		--bowser 3
		self.hp = self.hp - 1
		self.hittimer = 0.1
		if self.hp < 0 then
			playsound(shotsound)
			playsound(bowserfallsound)
			self.shot = true
			self.dead = true
			self.speedy = -shotjumpforce
			self.direction = dir or "right"
			self.active = false
			self.gravity = shotgravity
			self.speedx = 0
			
			addpoints(firepoints["bowser"], self.x+self.width/2, self.y)
		end
	elseif self.t == 8 then
		--bowser jr.
		if not self.shell then
			self.shothp = self.shothp - 1
			playsound(shotsound)
			if self.shothp < 0 then
				self.shothp = self.shothealth
				self:stomp()
				return true
			end
		end
	elseif not self.shell and not self.dead then
		--koopaling
		playsound(shotsound)
		self:stomp()
		return true
	end
end

function koopaling:freeze()
	self.frozen = true
	self.speedx = 0
	self.speedy = 0
end

function koopaling:die()
	self.dead = true
	self.deadpos = {self.x, self.y}
	self.animationtimer = 0
	self.active = false
	
	if self.t == 8 then
		--bowser jr
		self.offsetX = 12
		self.offsetY = 3
		self.quadcenterX = 14
		self.quadcenterY = 20
		self.frame = 1
		self.quad = koopalingquad[self.t][self.frame]
		self.shot = true
		playsound(shotsound)
	else
		self.offsetX = 12
		self.offsetY = -5
		self.quadcenterX = 12
		self.quadcenterY = 12
		self.frame = 10
		self.quad = koopalingquad[self.t][self.frame]

		if self.t == 3 then
			self:projectilekill()
		end
	end
	
	if self.t ~= 9 then
		if self.t ~= 8 then
			makepoof(self.x+self.width/2, self.y+self.height/2, "sweat")
		end
		if not self.shot then
			playsound(shufflesound)
		end
	end
end

function koopaling:doshell()
	--get into shell
	self.shell = true
	self.stompedjump = false
	self.shooting = false
	self.stomptimer = 0
	self.speedx = 0
	
	local oy = self.y+self.height
	self.height = 12/16
	if self.supersized then
		self.height = self.height*self.supersized
	end
	self.y = oy-self.height

	if self.t == 8 then
		--bowser jr
		local ox = self.x+self.width/2
		self.width = 12/16
		if self.supersized then
			self.width = self.width*self.supersized
		end
		self.x = ox-self.width/2
		self.offsetX = 6
		self.offsetY = 7
		self.quadcenterX = 12
		self.quadcenterY = 12
		self.heavyjump = nil

		self.stompable = false

		self.shelltimer = koopalingshelltime
		self.movedirection = self.animationdirection
	else
		self.offsetX = 12
		self.offsetY = 7
		self.quadcenterX = 12
		self.quadcenterY = 12
	end
	self.frame = 5
	self.quad = koopalingquad[self.t][self.frame]
	
	if self.t ~= 8 then
		if self.speedy == 0 then
			makepoof(self.x+self.width/2, self.y-6/16, "sweat")
		end
	end
	playsound(shufflesound)
end

function koopaling:unshell()
	--come out of shell
	self.shell = false
	self.jumpthrough = false
	
	local oy = self.y+self.height
	if self.t == 8 then
		self.height = 20/16
	else
		self.height = 24/16
	end
	if self.supersized then
		self.height = self.height*self.supersized
	end
	self.y = oy-self.height

	if self.t == 8 then
		--bowser jr
		local ox = self.x+self.width/2
		self.width = 20/16
		if self.supersized then
			self.width = self.width*self.supersized
		end
		self.x = ox-self.width/2
		self.offsetX = 10
		self.offsetY = 3
		self.quadcenterX = 14
		self.quadcenterY = 20
		self.speedx = 0

		self.stompable = true
	else
		self.offsetX = 12
		self.offsetY = -1
		self.quadcenterX = 14
		self.quadcenterY = 20
	end
	self.frame = 1
	self.quad = koopalingquad[self.t][self.frame]
	
	shufflesound:stop()
end

function koopaling:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end

	if self.t == 8 and self.shell and a == "tile" then--bowser jr
		local broke = true
		local x = b.cox
		for y = math.floor(self.y)+1, math.max(b.coy, math.floor(self.y+self.height-0.1)+1) do
			if ismaptile(x, y) then
				local r = map[x][y]
				if r then
					if self.supersized and (tilequads[r[1]].coinblock or (tilequads[r[1]].debris and blockdebrisquads[tilequads[r[1]].debris])) then
						destroyblock(x, y, "nopoints")
					elseif tilequads[r[1]].breakable then
						destroyblock(x, y, "nopoints")
					elseif tilequads[r[1]].collision then
						broke = false
					end
				end
			end
		end
		if broke then return false end
	end
	
	if self.jumping then
		if not self.jumpthrough then
			self.speedx = -self.speedx
		else
			self.speedx = 0
		end
	elseif a == "tile" and self.animationdirection == "left" then
		self.speedx = 0
		self.jumpthrough = true
		--self.x = self.x + 7/16
		--self.jumptimer = koopalingjumpdelay[self.jumpdelay]
	end
	
	if not self.jumpthrough then
		self.animationdirection = "left"
	end
	
	return false
end

function koopaling:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if self.t == 8 and self.shell and a == "tile" then--bowser jr
		local broke = true
		local x = b.cox
		for y = math.floor(self.y)+1, math.max(b.coy, math.floor(self.y+self.height-0.1)+1) do
			if ismaptile(x, y) then
				local r = map[x][y]
				if r then
					if self.supersized and (tilequads[r[1]].coinblock or (tilequads[r[1]].debris and blockdebrisquads[tilequads[r[1]].debris])) then
						destroyblock(x, y, "nopoints")
					elseif tilequads[r[1]].breakable then
						destroyblock(x, y, "nopoints")
					elseif tilequads[r[1]].collision then
						broke = false
					end
				end
			end
		end
		if broke then return false end
	end
	
	if self.jumping then
		if not self.jumpthrough then
			self.speedx = -self.speedx
		else
			self.speedx = 0
		end
	elseif a == "tile" and self.animationdirection == "right" then
		self.speedx = 0
		self.jumpthrough = true
		--self.x = self.x - 7/16
		--self.jumptimer = koopalingjumpdelay[self.jumpdelay]
	end
	
	if not self.jumpthrough then
		self.animationdirection = "right"
	end
	
	return false
end

function koopaling:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.speedy = 0.01
end

function koopaling:globalcollide(a, b)
	if a == "fireball" or a == "player" then
		return true
	end

	if (a == "bulletbill" or a == "cannonball") and not b.killsenemies then
		return true
	end
end

function koopaling:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end

	
	if self.t ~= 8 then
		if a == "tile" and self.shell and self.jumping and self.stompedjump then
			if self.surprisejump then
				self.surprisejump = false
			else
				self:unshell()
			end
		end
	end
	
	if self.jumping then
		self.jumpthrough = false
		if self.t == 5 or self.t == 7 or (self.t == 8 and self.heavyjump) then
			for i = 1, players do
				objects["player"][i]:groundshock()
			end
			self.heavyjump = nil
			earthquake = 4
			playsound(thwompsound)
			if self.t == 7 and self.shell then
				self.jumptimer = koopalingjumpdelay[self.jumpdelay]
				self.stompedjump = true
			end
		end
		if self.t == 9 then --bowser
			if insideportal(self.x, self.y, self.width, self.height) then
				return false
			end
			if self.bigjump and mariohammerkill[a] and (not b.resistsenemykill) then
				b:shotted("right")
				if a ~= "bowser" then
					addpoints(firepoints[a], self.x, self.y)
				end
				return false
			end
			if a == "tile" and self.bigjump and (not self.bigjumpwait) then
				for x = math.ceil(self.x), math.ceil(self.x+self.width) do
					for y = math.ceil(self.y+.5), math.max(b.coy, math.ceil(self.y+self.height+.5)) do
						if ismaptile(x, y) then
							local r = map[x][y]
							if r then
								if self.supersized and (tilequads[r[1]].coinblock or (tilequads[r[1]].debris and blockdebrisquads[tilequads[r[1]].debris])) then
									destroyblock(x, y, "nopoints")
								elseif tilequads[r[1]].breakable or tilequads[map[x][y][1]].bridge then
									destroyblock(x, y, "nopoints")
								end
							end
						end
					end
				end
			end
			self.gravity = yacceleration
			if self.bigjump and (not self.bigjumpwait) then
				playsound(thwompsound)
				self.jumpcount = 0
				self.landtimer = 0
				self.frame = 8
				local closestplayer = 1 --find closest player
				for i = 2, players do
					local v = objects["player"][i]
					if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
						closestplayer = i
					end
				end
				if self.x > objects["player"][closestplayer].x then --face player
					self.animationdirection = "left"
				elseif self.x < objects["player"][closestplayer].x - 2 then
					self.animationdirection = "right"
				end
				self.bigjump = false
				self.bigjumptimer = 0
			end
		elseif self.t == 8 then --bowser jr
			if not self.shell then
				self.speedx = 0
			end
			self.gravity = yacceleration
		elseif not self.shell then
			local closestplayer = 1 --find closest player
			for i = 2, players do
				local v = objects["player"][i]
				if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
					closestplayer = i
				end
			end
			if self.x > objects["player"][closestplayer].x then --face player
				self.animationdirection = "left"
				self.speedx = -koopalingspeed
			elseif self.x < objects["player"][closestplayer].x then
				self.animationdirection = "right"
				self.speedx = koopalingspeed
			end
			self.gravity = yacceleration
		end
	end
end

function koopaling:passivecollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if self.t ~= 9 then
		if self.speedx > 0 then
			self:leftcollide(a, b)
		else
			self:rightcollide(a, b)
		end
	end
	return false
end

function koopaling:emancipate(a)
	self:shotted()
end

function koopaling:laser()
	self:shotted()
end

function koopaling:autodeleted()
	shufflesound:stop()
end

function koopaling:dotrack()
	self.track = true
end

function koopaling:dosupersize()
	if self.shothealth and self.shothp then
		self.shothealth = self.shothealth*self.supersized
		self.shothp = self.shothealth
	end
end

function koopaling:projectilecallback(i)
	table.remove(self.projectiletable, i)
end

function koopaling:projectilekill(i)
	for i, p in pairs(self.projectiletable) do
		if p.x and p.width then --just to make sure
			p.instantdelete = true
			makepoof(p.x+p.width/2, p.y+p.height/2, "makerpoof")
		end
	end
	table.remove(self.projectiletable, i)
end