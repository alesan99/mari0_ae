koopa = class:new()

--combo: 500, 800, 1000, 2000, 4000, 5000

function koopa:init(x, y, t)
	--PHYSICS STUFF
	self.x = x-6/16
	self.y = y-11/16
	self.speedy = 0
	self.speedx = -koopaspeed
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.category = 5
	
	self.mask = {	true, 
					false, false, false, false, true,
					false, true, false, true, false,
					false, false, true, false, false,
					true, true, false, false, true,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	
	self.autodelete = true
	self.t = t
	self.flying = false
	self.startx = self.x
	self.starty = self.y
	self.quad = koopaquad[spriteset][1]
	self.combo = 1
	self.freezable = true
	self.frozen = false
	
	--IMAGE STUFF
	self.drawable = true
	self.offsetX = 6
	self.offsetY = 0
	self.quadcenterX = 8
	self.quadcenterY = 19
	if self.t == "red" then
		self.graphic = kooparedimage
	elseif self.t == "redflying" then
		self.graphic = kooparedimage
		self.flying = true
		self.gravity = 0
		self.quad = koopaquad[spriteset][4]
		self.speedx = 0
		self.timer = 0
		self.dontenterclearpipes = true
		self.ignoreplatform = true
	elseif self.t == "flying2" then
		self.graphic = koopaimage
		self.flying = true
		self.gravity = 0
		self.quad = koopaquad[spriteset][4]
		self.speedx = 0
		self.timer = 0
		self.dontenterclearpipes = true
		self.pipespawnmax = 1
		self.ignoreplatform = true
		--self.timer2 = 0
	elseif self.t == "flying" then
		self.flying = true
		self.quad = koopaquad[spriteset][4]
		self.graphic = koopaimage
		self.gravity = koopaflyinggravity
		self.pipespawnmax = 1
	elseif self.t == "beetle" or self.t == "beetleshell" then
		self.graphic = beetleimage
	elseif self.t == "downbeetle" then
		self.graphic = beetleimage
		self.gravity = -yacceleration
		self.upsidedown = true
		self.quadcenterY = 15
	elseif self.t == "downspikey" then
		self.graphic = spikeyshellimg
		self.gravity = -yacceleration
		self.upsidedown = true
		self.quadcenterY = 15
	elseif self.t == "spikeyshell" then
		self.graphic = spikeyshellimg
	elseif self.t == "blue" then
		self.graphic = koopablueimage
	else
		self.graphic = koopaimage
	end
	
	self.rotation = 0
	self.direction = "left"
	self.animationdirection = "right"
	self.animationtimer = 0
	self.freezetimer = 0
	
	--self.returntilemaskontrackrelease = true
	if self.t == "shell" or self.t == "beetleshell" or self.t == "spikeyshell" then
		self.small = true
		--self.trackable = false
		self.moving = false
		self.speedx = 0
		self.quad = koopaquad[spriteset][3]
		self.wakeuptimer = math.huge --don't wake up if using shell entity
		if self.t == "spikeyshell" then
			self.helmetable = "spikey"
		elseif self.t == "beetleshell" then
			self.helmetable = "beetle"
		end
		self.empty = true
		self.pipespawnmax = 1
	else
		self.small = false
		self.moving = true
		self.wakeuptimer = koopawakeup
	end
	
	if self.t == "bigkoopa" or self.t == "bigbeetle" then
		self.x = x-12/16
		self.y = y-23/16
		self.width = 24/16
		self.height = 24/16
		self.offsetX = 12
		self.offsetY = -7
		self.quadcenterX = 16
		self.quadcenterY = 38
		self.quad = bigkoopaquad[spriteset][1]
		if self.t == "bigbeetle" then
			self.graphic = bigbeetleimage
		else
			self.graphic = bigkoopaimage
		end
		self.weight = 2
		self.dontenterclearpipes = true
	end
	
	self.shellanimal = true
	self.flipped = false
	
	self.falling = false
	
	self.shot = false
end	

function koopa:func(i) -- 0-1 in please
	return (-math.cos(i*math.pi*2)+1)/2
end

function koopa:update(dt)
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

	if self.delete then
		return true
	end
	
	if self.funnel then
		if self.t ~= "redflying" and self.t ~= "flying2" then
			self.gravity = yacceleration
		end
		self.funnel = false
	end
	
	if edgewrapping then --wrap around screen
		local minx, maxx = -self.width, mapwidth
		if self.x < minx then
			self.x = maxx
		elseif self.x > maxx then
			self.x = minx
		end
	end
	
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
		
	else
		if self.speedx > 0 then
			self.animationdirection = "left"
		else
			self.animationdirection = "right"
		end
		--red koopa turn around
		if self.falling == false and self.flying == false and (self.t == "red" or self.t == "redflying" or self.t == "blue" or self.t == "downbeetle" or self.t == "downspikey") and self.small == false and self.active then
			--check if nothing below
			local x = math.floor(self.x + self.width/2+1)
			local y = math.floor(self.y + self.height+1.5)
			if self.t == "downbeetle" or self.t == "downspikey" then
				y = math.floor(self.y)
			end
			if inmap(x, y) and (not checkfortileincoord(x, y)) and ((inmap(x+.5, y) and checkfortileincoord(math.ceil(x+.5), y)) or (inmap(x-.5, y) and checkfortileincoord(math.floor(x-.5), y))) and (not (inmap(x,y-1) and objects["tile"][tilemap(x, y-1)] and objects["tile"][tilemap(x, y-1)].SLOPE)) then
				if self.speedx < 0 then
					self.animationdirection = "left"
					self.x = x-self.width/2
				else
					self.animationdirection = "right"
					self.x = x-1-self.width/2
				end
				self.speedx = -self.speedx
			end
		end
		
		if self.t == "downbeetle" or self.t == "downspikey" then
			local fall = false
			for i = 1, players do
				local v = objects["player"][i]
				if inrange(v.x+v.width/2, self.x+self.width/2-3, self.x+self.width/2+3) then --no player near
					if v.x+v.width/2 > self.x+self.width/2 then
						fall = "right"
					else
						fall = "left"
					end
				end
			end
			if self.speedy < -4 then
				fall = "fall"
			end
			if fall then
				if self.t == "downspikey" then
					self.t = "spikeyshell"
					self.quadcenterY = 19
					self.offsetY = 4
				else
					self.t = "beetle"
					self.quadcenterY = 19
					self.offsetY = 6
				end
				self.small = true
				self.trackable = false
				self.moving = false
				self.upsidedown = false
				self.flipped = true
				self.floormove = fall
				self.gravity = yacceleration
				self.speedx = 0
				self.quad = koopaquad[spriteset][3]
			end
		end
	
		if self.flying == true and self.t == "redflying" and not self.frozen then
			self.timer = self.timer + dt
			
			while self.timer > koopaflyingtime do
				self.timer = self.timer - koopaflyingtime
			end
			local newy = self:func(self.timer/koopaflyingtime)*koopaflyingdistance + self.starty
			self.y = newy
		end
		
		if self.flying == true and self.t == "flying2" and (not self.frozen) and self.active then --fly left and right (and a slightly up and down)
			self.timer = self.timer + dt
			
			if self.timer < koopaflyingtime/2 then
				self.animationdirection = "right"
			else
				self.animationdirection = "left"
			end
			
			while self.timer > koopaflyingtime do
				self.timer = self.timer - koopaflyingtime
			end
			local newx = self.startx - self:func(self.timer/koopaflyingtime)*koopaflyingdistance
			self.x = newx
			
			--[[self.timer2 = self.timer2 + dt
			
			while self.timer2 > 3 do
				self.timer2 = self.timer2 - 3
			end
			local newy = self:func(self.timer2/3)*0.8 + self.starty
			self.y = newy]]
			local newy = self:func(self.timer/(koopaflyingtime/2))*0.8  + self.starty --self:func(self.timer2/3)*0.8 + self.starty
			self.y = newy
		end
		
		if not self.frozen then
			if not self.small then
				if self.t == "blue" then
					self.animationtimer = self.animationtimer + 1.5*dt
				else
					self.animationtimer = self.animationtimer + dt
				end
				while self.animationtimer > koopaanimationspeed do
					self.animationtimer = self.animationtimer - koopaanimationspeed
					if self.t == "bigkoopa" or self.t == "bigbeetle" then
						if self.quad == bigkoopaquad[spriteset][1] then
							self.quad = bigkoopaquad[spriteset][2]
						else
							self.quad = bigkoopaquad[spriteset][1]
						end
					elseif not self.flying then
						if self.quad == koopaquad[spriteset][1] then
							self.quad = koopaquad[spriteset][2]
						else
							self.quad = koopaquad[spriteset][1]
						end
					else
						if self.quad == koopaquad[spriteset][4] then
							self.quad = koopaquad[spriteset][5]
						else
							self.quad = koopaquad[spriteset][4]
						end
					end
				end
			else
				if self.shellwakingup then
					self.animationtimer = self.animationtimer + dt
					while self.animationtimer > koopawakeupanimationspeed do
						self.animationtimer = self.animationtimer - koopawakeupanimationspeed
						if self.t == "bigkoopa" or self.t == "bigbeetle" then
							if self.quad == bigkoopaquad[spriteset][3] then
								self.quad = bigkoopaquad[spriteset][6]
								if self.flipped then
									if self.t == "bigbeetle" then
										self.offsetY = 1
									else
										self.offsetY = -3
									end
									
								else
									self.offsetY = -2
								end
							else
								self.quad = bigkoopaquad[spriteset][3]
								if self.flipped then
									if self.t == "bigbeetle" then
										self.offsetY = -1
									else
										self.offsetY = -5
									end
								else
									self.offsetY = 0
								end
							end
						else
							if self.quad == koopaquad[spriteset][3] then
								self.quad = koopaquad[spriteset][6]
								if self.flipped then
									self.offsetY = 5
								else
									self.offsetY = -1
								end
							else
								self.quad = koopaquad[spriteset][3]
								if self.flipped then
									if self.t == "beetle" or self.t == "beetleshell" then
										self.offsetY = 6
									else
										self.offsetY = 4
									end
								else
									self.offsetY = 0
								end
							end
						end
					end
				end
			end
		end
		
		if self.small and self.shellwakingup and self.speedx ~= 0 then
			self.shellwakingup = false
		end

		if self.passivepass then
			self.passivepasstimer = self.passivepasstimer - dt
			if self.passivepasstimer < 0 then
				self.passivepass = false
			end
		end
		
		if self.small and self.speedx == 0 and not self.frozen then
			self.wakeuptimer = self.wakeuptimer - dt
			if not self.shellwakingup and not (self.t == "beetle" or self.t == "beetleshell" or self.t == "bigbeetle") and self.wakeuptimer <= koopawakeupanimlen then
				self.shellwakingup = true
				self.animationtimer = 0
			elseif self.wakeuptimer <= 0 then
				self.shellwakingup = false
				self.small = false
				self.flipped = false
				self.offsetY = 0
				self.animationtimer = 0
				if self.t == "bigkoopa" or self.t == "bigbeetle" then
					self.quad = bigkoopaquad[spriteset][1]
					self.offsetY = -7
					self.quadcenterY = 38
				else
					self.quad = koopaquad[spriteset][1]
				end
				self.wakeuptimer = koopawakeup
				if self.animationdirection == "left" then
					self.speedx = koopaspeed
				else
					self.speedx = -koopaspeed
				end
				self.helmetable = false
			elseif self.wakeuptimer > koopawakeupanimlen then
				self.shellwakingup = false
			end
		end

		--collectable
		if self.small then
			local x = math.floor(self.x+self.width/2)+1
			local y = math.floor(self.y+self.height)+1
			if inmap(x, y) then
				if objects["collectable"][tilemap(x, y)] then
					getcollectable(x, y)
				end
			end
			local y = math.floor(self.y+self.height/2)+1
			if inmap(x, y) then
				if objects["collectable"][tilemap(x, y)] then
					getcollectable(x, y)
				end
			end
		end
		
		if (self.t ~= "redflying" and self.t ~= "flying2" or self.flying == false) then
			if (not self.frozen) or self.small then
				if not self.small then
					local speed = koopaspeed
					if self.t == "blue" then
						speed = koopabluespeed
					end
					if self.speedx > 0 then
						if self.speedx > speed then
							self.speedx = self.speedx - friction*dt*2
							if self.speedx < speed then
								self.speedx = speed
							end
						elseif self.speedx < speed then
							self.speedx = self.speedx + friction*dt*2
							if self.speedx > speed then
								self.speedx = speed
							end
						end
					else
						if self.speedx < -speed then
							self.speedx = self.speedx + friction*dt*2
							if self.speedx > -speed then
								self.speedx = -speed
							end
						elseif self.speedx > -speed then
							self.speedx = self.speedx - friction*dt*2
							if self.speedx < -speed then
								self.speedx = -speed
							end
						end
					end
				elseif not self.staystillfall then
					if self.speedx > 0 then
						if self.speedx > koopasmallspeed then
							self.speedx = self.speedx - friction*dt*2
							if self.speedx < koopasmallspeed then
								self.speedx = koopasmallspeed
							end
						elseif self.speedx < koopasmallspeed then
							self.speedx = self.speedx + friction*dt*2
							if self.speedx > koopasmallspeed then
								self.speedx = koopasmallspeed
							end
						end
					elseif self.speedx < 0 then
						if self.speedx < -koopasmallspeed then
							self.speedx = self.speedx + friction*dt*2
							if self.speedx > -koopasmallspeed then
								self.speedx = -koopasmallspeed
							end
						elseif self.speedx > -koopasmallspeed then
							self.speedx = self.speedx - friction*dt*2
							if self.speedx < -koopasmallspeed then
								self.speedx = -koopasmallspeed
							end
						end
					end
				end
			else
				self.speedx = 0
			end
		end
		
		return false
	end
end

function koopa:stomp(x, b)
	self.trackable = false
	if self.t == "flying" and self.flying then
		--dont kill mayro
		if b then
			self.passivepass = b.playernumber or 1
			self.passivepasstimer = 0.1
		else
			self.passivepass = false
		end
	end
	if self.flying then
		self.flying = false
		self.quad = koopaquad[spriteset][1]
		if self.speedx == 0 then
			self.speedx = -koopaspeed
		end
		self.gravity = yacceleration
		return false
	elseif self.small == false then
		if self.t == "bigkoopa" or self.t == "bigbeetle" then
			self.quadcenterY = 31
			self.offsetY = 0
			self.quad = bigkoopaquad[spriteset][3]
		else
			self.quadcenterY = 19
			self.offsetY = 0
			self.quad = koopaquad[spriteset][3]
		end
		self.small = true
		self.trackable = false
		self.mask = {false, false, false, false, false, true, false, false, false, true}
		self.speedx = 0
	elseif self.speedx == 0 then
		if self.t == "bigkoopa" or self.t == "bigbeetle" then
			self.quadcenterY = 31
			self.offsetY = 0
			self.quad = bigkoopaquad[spriteset][3]
		else
			self.quadcenterY = 19
			self.offsetY = 0
			self.quad = koopaquad[spriteset][3]
		end
		if self.flipped then
			if self.t == "bigkoopa" then
				self.offsetY = -5
			elseif self.t == "bigbeetle" then
				self.offsetY = -1
			elseif self.t == "beetle" or self.t == "beetleshell" then
				self.offsetY = 6
			else
				self.offsetY = 4
			end
		end
		if self.x > x then
			self.speedx = koopasmallspeed
			--self.x = x+12/16+koopasmallspeed*gdt
		else
			self.speedx = -koopasmallspeed
			--self.x = x-self.width-koopasmallspeed*gdt
		end
		if b then
			self.passivepass = b.playernumber or 1
			self.passivepasstimer = 0.2
		else
			self.passivepass = false
		end
	else
		self.speedx = 0
		self.combo = 1
	end
end

function koopa:shotted(dir) --fireball, star, turtle
	playsound(shotsound)
	self.shot = true
	self.small = true
	if self.t == "bigkoopa" or self.t == "bigbeetle" then
		self.quad = bigkoopaquad[spriteset][3]
		self.quadcenterY = 38
		self.offsetY = 0
	else
		self.quad = koopaquad[spriteset][3]
		self.quadcenterY = 19
		self.offsetY = 0
	end
	self.speedy = -shotjumpforce
	self.direction = dir or "right"
	self.active = false
	self.gravity = shotgravity
	if self.direction == "left" then
		self.speedx = -shotspeedx
	else
		self.speedx = shotspeedx
	end
end

function koopa:freeze()
	self.frozen = true
end

function koopa:flipshell(dir)
	self.quadcenterY = 19
	if self.t == "bigkoopa" then
		self.quadcenterY = 32
		self.offsetY = -5
		self.quad = bigkoopaquad[spriteset][3]
	elseif self.t == "bigbeetle" then
		self.quadcenterY = 32
		self.offsetY = -1
		self.quad = bigkoopaquad[spriteset][3]
	elseif self.t == "beetle" or self.t == "beetleshell" then
		self.offsetY = 6
		self.quad = koopaquad[spriteset][3]
	else
		self.offsetY = 4
		self.quad = koopaquad[spriteset][3]
		if not self.small then
			self.shellwakingup = true
		end
	end
	if self.flying then
		self.flying = false
		self.gravity = yacceleration
	end
	self.helmetable = false
	self.staystillfall = true
	self.small = true
	self.trackable = false
	self.mask = {false, false, false, false, false, true, false, false, false, true}
	if not self.empty then
		self.wakeuptimer = koopawakeup
	end
	self.speedy = -koopahitjumpforce
	self.gravity = shotgravity
	self.flipped = true
	self.direction = dir or "right"
	if self.direction == "left" then
		self.speedx = -shotspeedx
	else
		self.speedx = shotspeedx
	end
end

function koopa:leftcollide(a, b, passive)
	if self:globalcollide(a, b) then
		return false
	end
	
	if self:hitwall(a, b, "left") then
		return false
	end
	
	self:hitenemy(a, b, "left")

	if self.small == false and not self.frozen then
		if self.t ~= "flying2" then
			self.animationdirection = "left"
		end
		self.speedx = math.abs(self.speedx)
	else
		return false
	end
end

function koopa:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	if self:hitwall(a, b, "right") then
		return false
	end
	
	self:hitenemy(a, b, "right")

	if self.small == false and not self.frozen then
		if self.t ~= "flying2" then
			self.animationdirection = "left"
		end
		self.speedx = -math.abs(self.speedx)
	else
		return false
	end
end

function koopa:hitwall(a, b, dir)
	if a == "tile" or a == "portalwall" or a == "spring" or a == "donut" or a == "springgreen" or a == "bigmole" or a == "muncher" or (a == "flipblock" and not b.flippable) or a == "frozencoin" or a == "buttonblock" or (a == "enemy" and (b.resistsenemykill or b.resistseverything)) or a == "clearpipesegment" or a == "tilemoving" then	
		if self.small then
			if not self.staystillfall then
				if self.t == "bigkoopa" or self.t == "bigbeetle" then
					self.quad = bigkoopaquad[spriteset][3]
				else
					self.quad = koopaquad[spriteset][3]
				end
				if self.flipped then
					if self.t == "bigkoopa" then
						self.offsetY = -5
					elseif self.t == "bigbeetle" then
						self.offsetY = -1
					elseif self.t == "beetle" or self.t == "beetleshell" then
						self.offsetY = 6
					else
						self.offsetY = 4
					end
				else
					self.offsetY = 0
				end
				if not self.empty then
					self.wakeuptimer = koopawakeup
				end
				
				if a == "tile" then
					local x, y1, y2 = b.cox, b.coy, b.coy
					local big = self.width > 1
					local pass = true
					if big then y1, y2 = math.floor(self.y)+1, math.floor(self.y+self.height-0.1)+1 end
					for y = y1, y2 do
						if ismaptile(x,y) and tilequads[map[x][y][1]].collision then
							if big and (tilequads[map[x][y][1]].coinblock or (tilequads[map[x][y][1]].debris and blockdebrisquads[tilequads[map[x][y][1]].debris])) then -- hard block
								destroyblock(x, y)
							elseif tilequads[map[x][y][1]].collision then
								hitblock(x, y, {size=2}, {sound = onscreen(x-2.5,y-2.5,5,5)})
								if big and tilequads[map[x][y][1]].collision then
									pass = false
								end
							end
						end
					end
					if big and pass then
						return "pass"
					end
				elseif a == "tilemoving" then
					b:hit("koopa", self)
				else
					playsound(blockhitsound)
				end
			end
			if dir == "right" then
				self.speedx = -math.abs(self.speedx)
			else
				self.speedx = math.abs(self.speedx)
			end
			self.passivepass = false
		end
	end
end

function koopa:hitenemy(a, b, dir)
	if a ~= "tile" and a ~= "portalwall" and a ~= "platform" and (self.active or b.shellanimal) and self.small and self.speedx ~= 0 and a ~= "player" and a ~= "spring" and a ~= "donut" and a ~= "springgreen" and a ~= "bigmole" and a ~= "muncher" and a ~= "koopaling" and a ~= "bowser" then
		if b.shotted and (not self.staystillfall) and (not (b.resistsenemykill or b.resistseverything)) then
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
			b:shotted(dir)
		end
	end
end

function koopa:passivecollide(a, b)
	if a ~= "clearpipesegment" then
		if self.speedx < 0 then
			self:leftcollide(a, b, "passive")
		else
			self:rightcollide(a, b, "passive")
		end
	end
	return false
end

function koopa:globalcollide(a, b)
	if a == "bulletbill" or a == "bigbill" then
		if b.killstuff ~= false then
			return true
		end
	end
	if a == "fireball" or a == "player" or (a == "snakeblock" and self.t == "redflying" and self.flying) then
		return true
	end
end

function koopa:emancipate(a)
	self:shotted()
end

function koopa:floorcollide(a, b)
	self.falling = false
	if self.small and self.staystillfall then
		self.staystillfall = false
		self.speedx = 0
		self.gravity = yacceleration
		self.shellwakingup = false
		if self.t == "bigkoopa" then
			self.offsetY = -5
			self.quad = bigkoopaquad[spriteset][3]
		elseif self.t == "bigbeetle" then
			self.offsetY = -1
			self.quad = bigkoopaquad[spriteset][3]
		elseif self.t == "beetle" or self.t == "beetleshell" then
			self.offsetY = 6
			self.quad = koopaquad[spriteset][3]
		else
			self.offsetY = 4
			self.quad = koopaquad[spriteset][3]
		end
	end
	
	if self.small and self.floormove then
		if math.abs(self.speedx) > 5 then
		elseif self.floormove == "right" then
			self.speedx = koopasmallspeed
		else
			self.speedx = -koopasmallspeed
		end
		self.floormove = false
	end
	
	if self.t == "flying" and self.flying then
		if self:globalcollide(a, b) then
			return false
		end
		if self.frozen == false then
			self.speedy = -koopajumpforce
		end
	end
end

function koopa:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if self.t == "downbeetle" or self.t == "downspikey" then
		self.falling = false
	end
end

function koopa:laser()
	self:shotted()
end

function koopa:startfall()
	self.falling = true
end

function koopa:helmeted()
	self.delete = true
end