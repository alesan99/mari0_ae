goomba = class:new()

function goomba:init(x, y, t)
	--PHYSICS STUFF
	self.x = x-6/16
	self.y = y-11/16
	self.speedy = 0
	self.speedx = -goombaspeed
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.category = 4
	
	self.mask = {	true, 
					false, false, false, false, true,
					false, true, false, true, false,
					false, false, true, false, false,
					true, true, false, false, false,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	
	self.emancipatecheck = true
	self.autodelete = true
	self.freezable = true
	self.frozen = false
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = goombaimage
	self.quad = goombaquad[spriteset][1]
	self.offsetX = 6
	self.offsetY = 3
	self.quadcenterX = 8
	self.quadcenterY = 8
	
	self.rotation = 0 --for portals
	
	self.direction = "left"
	self.animationtimer = 0
	self.t = t or "goomba"
	
	if self.t == "spikeyair" then
		self.air = true
		self.t = "spikey"
	end
	
	self.speed = goombaspeed
	if self.t == "goomba" then
		self.animationdirection = "left"
		self.quadi = 1
	elseif self.t == "goombrat" then
		self.graphic = goombratimage
		self.animationdirection = "left"
	elseif self.t == "drygoomba" then
		self.graphic = drygoombaimage
	elseif self.t == "paragoomba" then
		self.graphic = paragoombaimage
		self.quad = paragoombaquad[spriteset][1]
		self.quadcenterY = 16
		self.gravity = 30
	elseif self.t == "spikey" or self.t == "spikeyfall" then
		self.graphic = spikeyimg
		self.fall = true
		if self.t == "spikey" then
			self.quadi = 1
		else
			self.mask[21] = true
			self.starty = self.y
			self.gravity = 30
			self.speedy = -10
			self.quadi = 3
			self.speedx = 0
			self.ignoreplatform = true
		end
		self.quad = spikeyquad[self.quadi]
	elseif self.t == "shyguy" then
		self.graphic = shyguyimg
		self.quadi = 1
		self.width = 12/16
		self.height = 14/16
		self.x = x-8/16
		self.y = y-13/16
		self.offsetX = 6
		self.offsetY = 1
		self.quadcenterX = 8
		self.quadcenterY = 8
		self.rigidgrab = true --limit angles mario can use
		self.userect = adduserect(self.x, self.y, 2, 2, self)
		self.pickupready = false
		self.pickupreadyplayers = {}
		--self.returntilemaskontrackrelease = true
	elseif self.t == "spiketop" or self.t == "spiketopup" then
		self.graphic = spiketopimg
		self.gravity = yacceleration
		self.gravityx = 0
		self.quadi = 1
		self.mask = {	true, 
					false, false, true, true, true,
					true, true, true, true, true,
					true, false, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true}
		self.animationdirection = "right"
		
		if self.t == "spiketopup" then
			self.y = self.y - 3/16
			self.gravity = -yacceleration
			self.animationdirection = "left"
			self.speedx = -goombaspeed
			self.t = "spiketop"
		end
		self.ignorelowgravity = true
		self.dontenterclearpipes = true
	elseif self.t == "fighterfly" then
		self.graphic = fighterflyimg
		self.quad = paragoombaquad[spriteset][1]
		self.quadcenterY = 15
		self.gravity = 30
		self.jumptimer = 0
	elseif self.t == "biggoomba" then
		self.x = x-12/16
		self.y = y-23/16
		self.speedy = 0
		self.speedx = -goombaspeed
		self.width = 24/16
		self.height = 24/16
		self.graphic = biggoombaimage
		self.quad = biggoombaquad[spriteset][1]
		self.offsetX = 13
		self.offsetY = -1
		self.quadcenterX = 16
		self.quadcenterY = 16
		self.animationdirection = "left"
		self.weight = 2
	elseif self.t == "tinygoomba" then
		self.x = x-12/16
		self.y = y-23/16
		self.speedy = 0
		self.speedx = -goombaspeed
		self.width = 8/16
		self.height = 8/16
		self.graphic = tinygoombaimage
		self.quad = tinygoombaquad[spriteset][1]
		self.offsetX = 4
		self.offsetY = 3
		self.quadcenterX = 4
		self.quadcenterY = 4
		self.animationdirection = "left"
		self.weight = .5
	elseif self.t == "goombashoe" or self.t == "goombaheel" then
		self.y = y-23/16
		self.height = 24/16
		self.graphic = goombashoeimg
		if self.t == "goombaheel" then
			self.quad = goombashoequad[spriteset][3]
			self.heel = true
			self.t = "goombashoe"
		else
			self.quad = goombashoequad[spriteset][1]
		end
		self.offsetY = -5
		self.quadcenterY = 12
		self.animationdirection = "right"
		self.jumptimer = 0
		self.speed = goombaspeed*2.5
		self.weight = 2
	elseif self.t == "wiggler" or self.t == "wigglerchild" or self.t == "wigglerangry" then
		self.graphic = wigglerimg
		self.quad = wigglerquad[1][1]
		self.angry = false
		if self.t == "wiggler" or self.t == "wigglerangry" then
			self.child = {}
			for i = 4, 1, -1 do
				self.child[i] = goomba:new(x, y, "wigglerchild")
				self.child[i].parent = self
				self.child[i].i = i
				self.child[i].quad = wigglerquad[1][i+1]
				self.child[i].quadi = i+1
				table.insert(objects["goomba"], self.child[i])
			end
			self.speed = wigglerspeed
			self.angrywait = false
			if self.t == "wigglerangry" then
				self.t = "wiggler"
				self.angry = true
				self.quad = wigglerquad[2][1]
				for i = 1, 4 do
					self.child[i].angry = true
					self.child[i].stompbounce = true
					self.child[i].speed = wigglerspeedangry
					self.child[i].quad = wigglerquad[2][self.child[i].quadi]
				end
				self.stompbounce = true
				self.speed = wigglerspeedangry
			end
		else
			self.speedx = 0
			self.speed = 0
			self.chase = false
			self.chasex = false
			self.chasey = false
		end
		self.quadi = 1
		self.quadcenterY = 20
		self.stompbouncesound = true
		self.trackable = false
		self.dontenterclearpipes = true
		self.freezable = false
	elseif self.t == "bigspikey" then
		self.x = x-12/16
		self.y = y-23/16
		self.speedy = 0
		self.speedx = -goombaspeed
		self.width = 24/16
		self.height = 24/16
		self.graphic = biggoombaimage
		self.quad = biggoombaquad[spriteset][1]
		self.offsetX = 13
		self.offsetY = -1
		self.quadcenterX = 16
		self.quadcenterY = 16
		self.graphic = bigspikeyimg
		self.fall = true
		self.quadi = 1
		self.quad = bigspikeyquad[self.quadi]
		self.weight = 2
	end
	if lowgravity then
		self.speed = self.speed*lovgravityxmult
	end
	if breakoutmode then
		self.speed = 14
		self.speedy = self.speed*0.8
		self.gravity = 0
	end
	
	self.falling = false
	
	self.dead = false
	self.deathtimer = 0
	self.freezetimer = 0
	
	self.shot = false
	
	self.aroundcorner = true
end

function goomba:update(dt)
	--rotate back to 0 (portals)
	if breakoutmode then
	elseif self.t == "spikeyfall" then
		self.rotation = 0
	else
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
	end
	
	if self.funnel then
		if self.t == "fighterfly" or self.t == "spikeyfall" or self.t == "paragoomba" or self.t == "goombashoe" then
			self.gravity = 30
		elseif self.t ~= "spiketop" then
			self.gravity = yacceleration
		end
		self.funnel = false
	end

	if self.passivepass then
		self.passivepasstimer = self.passivepasstimer - dt
		if self.passivepasstimer < 0 then
			self.passivepass = false
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
	
	if self.dead then
		self.deathtimer = self.deathtimer + dt
		if self.deathtimer > goombadeathtime then
			return true
		else
			return false
		end
		
	elseif self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
		
	elseif breakoutmode then
		self.rotation = self.rotation + ((self.speedx*math.pi)/(self.supersized or 1))*dt
		self.x = math.max(1, math.min(mapwidth-1-self.width, self.x))
	else
		if not self.frozen then
			self.animationtimer = self.animationtimer + dt
			while self.animationtimer > goombaanimationspeed do
				self.animationtimer = self.animationtimer - goombaanimationspeed
				if self.t == "goomba" or self.t == "goombrat" or self.t == "drygoomba" or self.t == "biggoomba" or self.t == "tinygoomba" then
					if self.animationdirection == "left" then
						self.animationdirection = "right"
					else
						self.animationdirection = "left"
					end
				elseif self.t == "paragoomba" or (self.t == "fighterfly" and self.jumptimer == 0) then
					if self.quad == paragoombaquad[spriteset][1] then
						self.quad = paragoombaquad[spriteset][2]
					else
						self.quad = paragoombaquad[spriteset][1]
					end
				
				elseif self.t == "goombashoe" then
					if self.quad == goombashoequad[spriteset][1] then
						self.quad = goombashoequad[spriteset][2]
					elseif not self.heel then
						self.quad = goombashoequad[spriteset][1]
					end
				elseif self.t == "wigglerchild" then
					local i = 1
					if self.angry then i = 2 end
					self.quadi = self.quadi + 1
					if self.quadi > 5 then
						self.quadi = 2
					end
					self.quad = wigglerquad[i][self.quadi]
				elseif self.t == "spikey" or self.t == "shyguy" or self.t == "spiketop" or self.t == "bigspikey" then
					if self.quadi == 1 then
						self.quadi = 2
					else
						self.quadi = 1
					end
					if self.t == "spikey" then
						self.quad = spikeyquad[self.quadi]
					elseif self.t == "shyguy" or self.t == "spiketop" then
						self.quad = goombaquad[spriteset][self.quadi]
					elseif self.t == "bigspikey" then
						self.quad = bigspikeyquad[self.quadi]
					end
				elseif self.t == "spikeyfall" then
					if self.quadi == 3 then
						self.quadi = 4
					else
						self.quadi = 3
					end
					self.quad = spikeyquad[self.quadi]
					
					if self.mask[21] and self.y > self.starty+2 then
						self.mask[21] = false
					end
				end
			end
		end
		
		if self.t == "spiketop" then
			if self.gravity == yacceleration then
				self.offsetX = 6
				self.offsetY = 3
				self.quadcenterX = 8
				self.quadcenterY = 8
				self.rotation = 0
			elseif self.gravity == -yacceleration then
				self.offsetX = 6
				self.offsetY = 1
				self.quadcenterX = 8
				self.quadcenterY = 8
				self.rotation = math.pi
			elseif self.gravityx == yacceleration then
				self.offsetX = 5
				self.offsetY = 3
				self.quadcenterX = 8
				self.quadcenterY = 8
				self.rotation = math.pi*1.5
			elseif self.gravityx == -yacceleration then
				self.offsetX = 7
				self.offsetY = 3
				self.quadcenterX = 8
				self.quadcenterY = 8
				self.rotation = math.pi*.5
			end
			
			if not self.aroundcorner then
				--go around corner?
				if self.animationdirection == "right" then
					if self.gravity == 0 then
						if self.speedx > 0 and self.gravityx == yacceleration then
							self.speedx = goombaspeed
							self.speedy = 0
							self.gravity = -yacceleration
							self.gravityx = 0
							self.aroundcorner = true
						elseif self.speedx < 0 and self.gravityx == -yacceleration then
							self.speedx = -goombaspeed
							self.speedy = 0
							self.gravity = yacceleration
							self.gravityx = 0
							self.aroundcorner = true
						end
					elseif self.gravityx == 0 then
						if self.speedy > 0 and self.gravity == yacceleration then
							self.speedy = goombaspeed
							self.speedx = 0
							self.gravity = 0
							self.gravityx = yacceleration
							self.aroundcorner = true
						elseif self.speedy < 0 and self.gravity == -yacceleration then
							self.speedy = -goombaspeed
							self.speedx = 0
							self.gravity = 0
							self.gravityx = -yacceleration
							self.aroundcorner = true
						end
					end
				else
					if self.gravity == 0 then
						if self.speedx > 0 and self.gravityx == yacceleration then
							self.speedx = goombaspeed
							self.speedy = 0
							self.gravity = yacceleration
							self.gravityx = 0
							self.aroundcorner = true
						elseif self.speedx < 0 and self.gravityx == -yacceleration then
							self.speedx = -goombaspeed
							self.speedy = 0
							self.gravity = -yacceleration
							self.gravityx = 0
							self.aroundcorner = true
						end
					elseif self.gravityx == 0 then
						if self.speedy > 0 and self.gravity == yacceleration then
							self.speedy = goombaspeed
							self.speedx = 0
							self.gravity = 0
							self.gravityx = -yacceleration
							self.aroundcorner = true
						elseif self.speedy < 0 and self.gravity == -yacceleration then
							self.speedy = -goombaspeed
							self.speedx = 0
							self.gravity = 0
							self.gravityx = yacceleration
							self.aroundcorner = true
						end
					end
				end
			end
		end
		
		if (self.t == "goombrat" or self.t == "wiggler" or self.t == "wigglerchild" or self.t == "spiketop") and self.y+self.height == math.floor(self.y+self.height) then
			local x = math.floor(self.x + self.width/2+1)--turn around on edge (yeah, goombrats do that)
			local y = math.floor(self.y + self.height+1.5)
			
			if inmap(x, y) and (not checkfortileincoord(x, y)) and ((inmap(x+.5, y) and checkfortileincoord(math.ceil(x+.5), y)) or (inmap(x-.5, y) and checkfortileincoord(math.floor(x-.5), y))) and (not (inmap(x,y-1) and objects["tile"][tilemap(x, y-1)] and objects["tile"][tilemap(x, y-1)].SLOPE)) then
				if (not (self.t == "spiketop")) or (((inmap(x+.5, y) and tilequads[map[math.ceil(x+.5)][y][1]].platform) or (inmap(x-.5, y) and tilequads[map[math.floor(x-.5)][y][1]].platform))) then
					if self.speedx < 0 then
						if self.t ~= "goombrat" then
							self.animationdirection = "left"
						end
						self.x = x-self.width/2
					else
						if self.t ~= "goombrat" then
							self.animationdirection = "right"
						end
						self.x = x-1-self.width/2
					end
					self.speedx = -self.speedx
					if self.t == "wigglerchild" or self.t == "wiggler" then
						self.turneddirection = true
						if self.t == "wiggler" and self.angry then
							self.angrywait = .8
						end
					end
				end
			end
		end
		
		if (self.t == "fighterfly" or self.t == "goombashoe") and not self.frozen and self.jumptimer > 0 then
			self.jumptimer = math.max(0, self.jumptimer - dt)
			if self.jumptimer == 0 then
				if self.t == "goombashoe" then
					if lowgravity then
						self.speedy = -goombashoejumpforce*0.4
					else
						self.speedy = -goombashoejumpforce
					end
					local closestplayer = 1 --find closest player
					for i = 2, players do
						local v = objects["player"][i]
						if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
							closestplayer = i
						end
					end
					if self.x+self.width/2 > objects["player"][closestplayer].x+objects["player"][closestplayer].width/2 then
						self.speedx = -goombaspeed
						self.animationdirection = "right"
					else
						self.speedx = goombaspeed
						self.animationdirection = "left"
					end
				else
					self.speedy = -fighterflyjumpforce
					self.quad = paragoombaquad[spriteset][1]
					self.speedx = self.oldspeedx
				end
			end
		end

		if self.t == "shyguy" then
			if self.thrown then
				self.throwntimer = self.throwntimer - dt
				if self.throwntimer < 0 then
					self.mask[3] = false
					self.flipped = false
					self.thrown = false
					if self.speedx > 0 then
						self.animationdirection = "right"
						self.speedx = -goombaspeed
					else
						self.animationdirection = "left"
						self.speedx = goombaspeed
					end
				end
			else
				if self.parent then
					local oldx = self.x
					local oldy = self.y
					
					self.x = self.parent.x+self.parent.width/2-self.width/2
					self.y = self.parent.y-self.height
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
				else
					self.pickupready = false
					for j, w in ipairs(objects["player"]) do --Make mario stay on shyguy
						self.pickupreadyplayers[w.playernumber] = false
						if not w.jumping and inrange(w.x, self.x-w.width, self.x+self.width) then
							if w.y == self.y - w.height then
								w.pickupready = self
								self.pickupready = true
								self.pickupreadyplayers[w.playernumber] = true
								if not self.tracked then
									if #checkrect(w.x+self.speedx*dt, w.y, w.width, w.height, {"exclude", w}, true) == 0 then
										w.oldxplatform = w.x
										w.x = w.x + self.speedx*dt
									end
								end
							end
						end
					end
				end
				self.userect.x = self.x
				self.userect.y = self.y
			end
		end
		
		if self.t == "wiggler" then
			if self.angry then
				if self.angrywait then
					self.angrywait = self.angrywait - dt
					if self.angrywait < 0 then
						self.angrywait = false
					end
				else
					local closestplayer = 1 --find closest player
					for i = 2, players do
						local v = objects["player"][i]
						if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
							closestplayer = i
						end
					end
					if self.x > objects["player"][closestplayer].x + 3 then
						self.animationdirection = "right"
						
						self.speedx = -wigglerspeedangry
					elseif self.x < objects["player"][closestplayer].x - 3 then
						self.animationdirection = "left"
						
						self.speedx = wigglerspeedangry
					end
				end
			end
		elseif self.t == "wigglerchild" then
			if not self.parent or self.parent.shot then
				self:shotted(dir)
				return false
			end
			local i = self.i-1
			local v = self.parent.child[i] --target
			if self.i == 1 then
				v = self.parent
			end
			while ((not v) or v.shot) and i > 0 do
				i = i-1
				if i < 1 then
					v = self.parent
					break
				else
					v = self.parent.child[i]
				end
			end
			
			local relativex, relativey = ((v.x+v.width/2)-(self.x+self.width/2)), ((v.y+v.height/2)-(self.y+self.height/2))
			local distance = math.sqrt(relativex*relativex+relativey*relativey)
			local angle = math.atan2((v.x+v.width/2)-(self.x+self.width/2), (v.y+v.height/2)-(self.y+self.height/2))-math.pi/2
			if distance ~= distance then --i don't know what this is, sometimes distance comes out as nan
				distance = 1
			end
			--[[if distance > 0.8 then
				self.x = ((v.x+v.width/2)+math.sin(angle-math.pi*.5)*0.8) -self.width/2
				self.y = ((v.y+v.height/2)+math.cos(angle-math.pi*.5)*0.8)-self.height/2
			end]]
			local scaled = 1
			if self.supersized then
				scaled = self.supersized
			end
			if not self.chase then
				if distance > 3*scaled then
					self:shotted()
					return false
				elseif distance > 1*scaled then
					self.x = ((v.x+v.width/2)+math.sin(angle-math.pi*.5)*(10/16*scaled)) -self.width/2
					self.y = ((v.y+v.height/2)+math.cos(angle-math.pi*.5)*(10/16*scaled))-self.height/2
					--self:shotted()
					--return false
				end
				self.chase = (distance > (10/16*scaled))
				if self.chase then
					if self.angry then
						self.speed = wigglerspeedangry
					else
						self.speed = wigglerspeed
					end
					self.chasex = v.x
					self.chasey = v.y
				else
					self.speed = 0
				end
			else
				if distance > 3*scaled then
					self:shotted()
					return false
				elseif distance > 1*scaled then
					self.x = ((v.x+v.width/2)+math.sin(angle-math.pi*.5)*(10/16*scaled)) -self.width/2
					self.y = ((v.y+v.height/2)+math.cos(angle-math.pi*.5)*(10/16*scaled))-self.height/2
					self.chasex = v.x
					self.chasey = v.y
					self.chase = true
					--self:shotted()
					--return false
				end
				if v.turneddirection then
					self.chasex = v.x
					self.chasey = v.y
					self.chase = true
					self.turneddirection = true
					v.turneddirection = false
				end
				local nrelativex, nrelativey = (self.chasex+ -self.x), (self.chasey + -self.y)
				local ndistance = math.sqrt(nrelativex*nrelativex+nrelativey*nrelativey)
				--self.speedx, self.speedy = (nrelativex)/ndistance*(self.speed), (nrelativey)/ndistance*(self.speed)
				if self.x > self.chasex then self.speedx = -self.speed
				elseif self.speedx < self.chasex then self.speedx = self.speed end
				if (self.x < self.chasex and self.x+self.speedx*dt > self.chasex) or (self.x > self.chasex and self.x+self.speedx*dt < self.chasex) 
					or  (self.y < self.chasey and self.y+self.speedy*dt > self.chasey) or (self.y > self.chasey and self.y+self.speedy*dt < self.chasey) then--ndistance < 1/16 then
					self.chase = false
					self.speed = 0
				end
				if self.speedx > 0 then
					self.animationdirection = "left"
				else
					self.animationdirection = "right"
				end
			end
		end
		
		if self.t ~= "spikeyfall" and self.t ~= "spiketop" and not ((self.t == "fighterfly" or self.t == "goombashoe") and self.jumptimer > 0) then
			if not self.frozen then
				if self.speedx > 0 then
					if self.speedx > self.speed then
						self.speedx = self.speedx - friction*dt*2
						if self.speedx < self.speed then
							self.speedx = self.speed
						end
					elseif self.speedx < self.speed then
						self.speedx = self.speedx + friction*dt*2
						if self.speedx > self.speed then
							self.speedx = self.speed
						end
					end
				else
					if self.speedx < -self.speed then
						self.speedx = self.speedx + friction*dt*2
						if self.speedx > -self.speed then
							self.speedx = -self.speed
						end
					elseif self.speedx > -self.speed then
						self.speedx = self.speedx - friction*dt*2
						if self.speedx < -self.speed then
							self.speedx = -self.speed
						end
					end
				end
				if self.t == "spikey" or self.t == "shyguy" or self.t == "bigspikey" or self.t == "goombashoe" or self.t == "wiggler" or self.t == "wigglerchild" then
					if self.speedx > 0 then
						self.animationdirection = "left"
					else
						self.animationdirection = "right"
					end
				end
			else
				self.speedx = 0
			end
		end
		
		--check if goomba offscreen		
		return false
	end
end

function goomba:stomp(x, b)--hehe goomba stomp
	if self.t == "paragoomba" then
		self.t = "goomba"
		self.graphic = goombaimage
		self.quad = goombaquad[spriteset][1]
		self.offsetX = 6
		self.offsetY = 3
		self.quadcenterX = 8
		self.quadcenterY = 8
		self.gravity = false
		self.trackable = false
		if b then
			if not checkintile(b.x, self.y - b.height-1/16, b.width, b.height, {}, b, "ignoreplatforms") then
				b.y = self.y - b.height-1/16
			end
			self.passivepass = b.playernumber or 1
			self.passivepasstimer = 0.1
		else
			self.passivepass = false
		end
		return
	end
	if self.t == "shyguy" or self.t == "spiketop" or self.t == "spikey" or self.t == "bigspikey" or self.t == "spikeyfall" or self.t == "fighterfly" or self.t == "goombashoe" then
		self:shotted(self.animationdirection)
		return false
	elseif self.t == "wiggler" or self.t == "wigglerchild" then
		self.angry = true
		if self.t == "wiggler" then
			self.quad = wigglerquad[2][1]
			for i = 1, 4 do
				if self.child[i] then
					self.child[i].angry = true
					self.child[i].stompbounce = true
					self.child[i].speed = wigglerspeedangry
					self.child[i].quad = wigglerquad[2][self.child[i].quadi]
				end
			end
		else
			if not self.parent then
				return false
			end
			self.quad = wigglerquad[2][self.quadi]
			self.parent.angry = true
			self.parent.stompbounce = true
			self.parent.speed = wigglerspeedangry
			self.parent.quad = wigglerquad[2][1]
			for i = 1, 4 do
				if i ~= self.i and self.parent.child[i] then
					self.parent.child[i].angry = true
					self.parent.child[i].stompbounce = true
					self.parent.child[i].speed = wigglerspeedangry
					self.parent.child[i].quad = wigglerquad[2][self.parent.child[i].quadi]
				end
			end
		end
		self.stompbounce = true --causes mario to bounce
		self.speed = wigglerspeedangry
		return false
	end
	
	self.dead = true
	self.active = false
	if self.t == "paragoomba" then
		self.quad = paragoombaquad[spriteset][3]
	elseif self.t == "biggoomba" then
		self.quad = biggoombaquad[spriteset][2]
	elseif self.t == "tinygoomba" then
		self.quad = tinygoombaquad[spriteset][2]
	else
		self.quad = goombaquad[spriteset][2]
	end

	if self.supersized and (self.t == "goomba" or self.t == "biggoomba" or self.t == "goombrat") then
		local obj = goomba:new(self.x-0.5, self.y-1/16, self.t)
		obj.x = self.x
		obj.y = self.y+self.height/4
		obj.speedx = -12
		obj.speedy = -10
		table.insert(objects["goomba"], obj)
		local obj = goomba:new(self.x-0.5, self.y-1/16, self.t)
		obj.x = self.x+self.width-obj.width
		obj.y = self.y+self.height/4
		obj.speedx = 12
		obj.speedy = -10
		table.insert(objects["goomba"], obj)
		if self.t == "biggoomba" then
			makepoof(self.x+self.width/2, self.y+self.height/2-7/16, "makerpoofbigger")
		else
			makepoof(self.x+self.width/2, self.y+self.height/2-3/16, "makerpoofbig")
		end
		self.instantdelete = true
		playsound(stompbigsound)
	end
end

function goomba:shotted(dir) --fireball, star, turtle
	playsound(shotsound)
	self.shot = true
	self.speedy = -shotjumpforce
	self.direction = dir or "right"
	self.active = false
	self.gravity = shotgravity
	if self.direction == "left" then
		self.speedx = -shotspeedx
	else
		self.speedx = shotspeedx
	end
	if self.t == "goombashoe" then
		if self.quad ~= goombaquad[spriteset][1] then
			self.quad = goombaquad[spriteset][1]
			self.graphic = goombaimage
			local obj = mushroom:new(self.x+6/16, self.y+23/16, "goombashoe")
			obj.uptimer = mushroomtime+0.00001
			obj.animationdirection = self.animationdirection
			obj.heel = self.heel
			table.insert(objects["mushroom"], obj)
		end
	elseif self.t == "wiggler" then
		for i = 1, 4 do
			if self.child[i] and not self.child[i].shot then
				self.child[i]:shotted()
			end
		end
	elseif self.t == "wigglerchild" then
		if self.parent and not self.parent.shot then
			self.parent:shotted()
		end
	end
end

function goomba:freeze()
	self.frozen = true
	if self.t == "spiketop" then
		self.static = true
	end
end

function goomba:leftcollide(a, b, passive)
	if self:globalcollide(a, b) then
		return false
	end
	
	if self.t == "spiketop" and (a == "tile" or a == "buttonblock" or a == "flipblock" or a == "frozencoin") then
		if self.animationdirection == "right" then
			self.speedy = -goombaspeed
		else
			self.speedy = goombaspeed
		end
		self.speedx = 0
		self.gravity = 0
		self.gravityx = -yacceleration
		self.aroundcorner = false
		return false
	end

	if a == "smallspring" then
		self.speedx = math.abs(self.speedx)
		return false
	end

	if breakoutmode then
		self.speedx = math.max(b.speedx, math.abs(self.speedx))
		if a == "platform" then self.speedy = -math.abs(self.speedy) end
		return false
	end
	
	if (not (passive and a == "clearpipesegment")) and (not self.frozen) and not (((self.t == "fighterfly" or self.t == "goombashoe") and self.jumptimer > 0)) then
		self.speedx = self.speed
		if self.t == "wiggler" then
			self.turneddirection = true
		end
	end
	
	if self.t == "wiggler" and self.angry then
		self.angrywait = .8
	end
	
	if self.t == "spikey" or self.t == "shyguy" or self.t == "bigspikey" or self.t == "goombashoe" or self.t == "wiggler" or self.t == "wigglerchild" then
		self.animationdirection = "left"
	end
	
	return false
end

function goomba:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	if self.t == "spiketop" and (a == "tile" or a == "buttonblock" or a == "flipblock" or a == "frozencoin") then
		if self.animationdirection == "right" then
			self.speedy = goombaspeed
		else
			self.speedy = -goombaspeed
		end
		self.speedx = 0
		self.gravity = 0
		self.gravityx = yacceleration
		self.aroundcorner = false
		return false
	end

	if a == "smallspring" then
		self.speedx = -math.abs(self.speedx)
		return false
	end

	if breakoutmode then
		self.speedx = math.min(b.speedx, -math.abs(self.speedx))
		if a == "platform" then self.speedy = -math.abs(self.speedy) end
		return false
	end
	
	if (not (passive and a == "clearpipesegment")) and (not self.frozen) and (not ((self.t == "fighterfly" or self.t == "goombashoe") and self.jumptimer > 0)) then
		self.speedx = -self.speed
		if self.t == "wiggler" then
			self.turneddirection = true
		end
	end
	
	if self.t == "wiggler" and self.angry then
		self.angrywait = .8
	end
	
	if self.t == "spikey" or self.t == "shyguy" or self.t == "bigspikey" or self.t == "goombashoe" or self.t == "wiggler" or self.t == "wigglerchild"  then
		self.animationdirection = "right"
	end
	
	return false
end

function goomba:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	if self.t == "spiketop" and (a == "tile" or a == "buttonblock" or a == "flipblock" or a == "frozencoin") then
		if self.animationdirection == "right" then
			self.speedx = goombaspeed
		else
			self.speedx = -goombaspeed
		end
		self.speedy = 0
		self.gravity = -yacceleration
		self.gravityx = 0
		self.aroundcorner = false
		return false
	end

	
	if breakoutmode then
		if a == "tile" then
			self.speedy = math.abs(self.speedy)
			return false
		end
	end
end

function goomba:globalcollide(a, b)
	if a == "bulletbill" or a == "bigbill" or a == "hammer" then
		if b.killstuff ~= false then
			return true
		end
	end
	
	if a == "fireball" or a == "player" then
		return true
	end
	
	if self.t == "spikeyfall" and a == "lakito" then
		return true
	end
	
	if (self.t == "wiggler" or self.t == "wigglerchild") and a == "goomba" and (b.t == "wiggler" or b.t == "wigglerchild") then
		return true
	end

	if self.thrown then
		if a == "enemy" then
			if b:shotted("right", false, false, true) ~= false then
				addpoints(b.firepoints or 200, self.x, self.y)
			end
			self.thrown = false
			self:shotted(self.animationdirection)
		elseif fireballkill[a] then
			b:shotted("right")
			if a ~= "bowser" then
				addpoints(firepoints[a] or 200, self.x, self.y)
			end
			self:shotted(self.animationdirection)
		end
	end

	if breakoutmode then
		if a == "tile" then
			for x = math.min(b.cox, math.floor(self.x)+1), math.max(b.cox, math.floor(self.x+self.width)+1) do
				for y = math.min(b.coy, math.floor(self.y)+1), math.max(b.coy, math.floor(self.y+self.height)+1) do
					local ti = 1
					if ismaptile(x, y) and map[x][y][1] then ti = map[x][y][1] end
					if (tilequads[ti].coinblock or (tilequads[ti].debris and blockdebrisquads[tilequads[ti].debris])) then -- hard block
						destroyblock(x, y); playsound(coinsound); mariocoincount = mariocoincount - 1
						if tilequads[ti].coinblock then
							mariotime = mariotime + 20
							local item = math.random(1, 4)
							if item == 1 then
								spawnenemy("goomba", self.x+1, self.y+1, false, "spawner")
							elseif item == 2 then
								if not self.supersized then
									supersizeentity(self)
								end
							elseif item == 3 then
								objects["platform"][1].size = objects["platform"][1].size+1
								objects["platform"][1].width = objects["platform"][1].width+1
								objects["platform"][1].x = math.min(mapwidth-1-objects["platform"][1].width, objects["platform"][1].x)
							elseif item == 4 then
								spawnenemy("spikeyfall", self.x+1, self.y+1, false, "spawner")
							end
							addpoints(1000, self.x+self.width/2, self.y)
							playsound(mushroomeatsound)
						end
					elseif tilequads[ti].breakable then
						hitblock(x, y, {size=2}); playsound(coinsound); mariocoincount = mariocoincount - 1
					end
				end
			end
		elseif a == "goomba" then
			return true
		end
	end
end

function goomba:startfall()

end

function goomba:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	if self.t == "paragoomba" and not self.frozen then
		self.speedy = -goombajumpforce
	end
	
	if (self.t == "fighterfly" or self.t == "goombashoe") and not self.frozen and self.jumptimer == 0 then
		self.speedy = 0
		self.oldspeedx = self.speedx
		self.speedx = 0
		
		if self.t == "goombashoe" then
			self.jumptimer = goombashoejumpdelay
		else
			self.quad = paragoombaquad[spriteset][3]
			self.jumptimer = fighterflyjumpdelay
		end
	end
	
	if self.t == "spiketop" and (a == "tile" or a == "buttonblock" or a == "flipblock" or a == "frozencoin") then
		if not b.SLOPE then
			self.speedy = 0
			if self.animationdirection == "right" then
				self.speedx = -goombaspeed
			else
				self.speedx = goombaspeed
			end
			self.gravityx = 0
			self.gravity = yacceleration
			self.aroundcorner = false
			return false
		end
	end
	
	if self.t == "spikeyfall" and (not breakoutmode) then
		self.t = "spikey"
		self.fall = false
		self.ignoreplatform = nil
		self.quadi = 1
		self.quad = spikeyquad[self.quadi]
		self.gravity = nil
		local nearestplayer = 1
		local nearestplayerx = objects["player"][1].x
		for i = 2, players do
			local v = objects["player"][i]
			if math.abs(self.x - v.x) < nearestplayerx then
				nearestplayer = i
				nearestplayerx = v.x
			end
		end
		
		if self.x >= nearestplayerx then
			self.speedx = -goombaspeed
		else
			self.speedx = goombaspeed
			self.animationdirection = "left"
		end
	end

	if self.thrown then
		self.speedy = -math.abs(self.speedy)*0.7
		self.speedx = self.speedx*0.7
	end

	if breakoutmode then
		if a == "platform" then
			local v = ((self.x+self.width/2)-(b.x+b.width/2))/(b.width/2)
			self.speedx = self.speed*v
			self.speedy = math.min(-3, -math.abs(self.speed)*(1-math.abs(v)))
		elseif a == "tile" then
			self.speedy = -self.speedy
		else
			self.speedy = -self.speedy
		end
	end
end

function goomba:passivecollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self:leftcollide(a, b, "passive")
	return false
end

function goomba:emancipate(a)
	self:shotted()
	
	if self.t == "shyguy" and self.parent then
		self.parent:cubeemancipate()
	end
end

function goomba:laser()
	self:shotted()
end

--shyguy grabbing
function goomba:used(id)
	if self.thrown then
		return
	end

	self.trackable = false
	self.parent = objects["player"][id]
	self.active = false
	self.static = true
	self.flipped = true
	objects["player"][id]:pickupbox(self)
	self.pickupready = false

	playsound(grabsound)
end

function goomba:dropped(gravitydir)
	local gravitydirection = gravitydir
	self.static = false
	self.active = true
	
	if gravitydirection then
		if gravitydirection == "up" then
			self.gravity = -yacceleration
			self.speedx = 0
		else
			self.gravity = yacceleration
			self.speedx = 0
		end
	end
	self.mask[3] = true --no player collision

	self.thrown = true
	self.throwntimer = 1.3
	self.speedy = -15
	if self.parent.pointingangle > 0 then --left
		self.speedx = self.parent.speedx-9
	else
		self.speedx = self.parent.speedx+9
	end
	self.x = self.parent.x+self.parent.width/2-self.width/2
	self.y = self.parent.y-self.height

	self.parent = nil

	playsound(throwsound)
end

function goomba:autodeleted()
	if self.userect then
		self.userect.delete = true
	end
end

function goomba:dotrack(track)
	self.tracked = track
	if self.t == "shyguy" then
		self.trackplatform = true
	end
end


function goomba:dosupersize()
	if (self.t == "goomba" or self.t == "biggoomba" or self.t == "goombrat") then
		self.nostompsound = true
	elseif self.t == "wiggler" then
		for i = 1, 4 do
			supersizeentity(self.child[i])
		end
	end
end