boomboom = class:new()

local duckspeed = 9
local jumpspeed = 8
local slowspeed = 2.5
local normalspeed = 4.5
local fastspeed = 7
local flyingspeed  = 6
local speedupdelay = 1
local speedupfastdelay = 0.6

local ducktime = 1

function boomboom:init(x, y, r)
	--PHYSICS STUFF
	self.x = x-12/16
	self.y = y-23/16
	self.speedy = 0
	self.speedx = 0
	self.speed = normalspeed
	self.width = 24/16
	self.height = 24/16
	self.static = false
	self.active = true
	self.category = 16
	
	self.mask = {	true, 
					false, false, false, false, true,
					true, true, false, true, false,
					false, false, true, false, false,
					true, true, false, false, false,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	
	self.autodelete = false
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = boomboomimg
	self.quad = boomboomquad[1][1]
	self.offsetX = 12
	self.offsetY = -1
	self.quadcenterX = 16
	self.quadcenterY = 16
	self.quadi = 1
	
	self.rotation = 0 --for portals
	
	self.animationdirection = "right"
	self.direction = "left"
	self.animationtimer = 0
	self.animationtimer2 = 0
	
	self.falling = false
	
	self.dead = false
	self.deathtimer = 0

	self.stomped = false
	self.stompedtimer = 0

	self.ducking = true
	self.duckingtimer = 0
	self.startduckingtimer = 0
	self.justducked = false

	self.jumping = false
	self.jumptimer = 0
	self.smalljumping = false
	self.duckdelay = 5
	self.skipduckinganim = true
	
	local v = convertr(r, {"string", "bool"})
	self.enemy = false
	if v and v[1] then
		self.enemy = (v[1] ~= "boss")
		self.key = (v[1] == "key")
	end
	self.flying = false
	if v and v[2] and v[2] == true then
		self.flying = v[2]
		self.dive = false
		self.divedirection = false
		self.divetargetx = false
		self.divetargety = false
		self.speed = flyingspeed
		self.startdivetimer = -math.random(0, 2)
		self.graphic = boomboomflyingimg

		local cox, coy = math.floor(x+0.5), math.floor(y+1/16)
		if map[cox] and map[cox][coy] and tilequads[map[cox][coy][1]].collision then
			self.inblock = true
		end
	end
	
	self.shot = false
	self.hp = boomboomhp
	self.firehp = 5

	self:duck(true)
end

function boomboom:update(dt)
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

	if edgewrapping then --wrap around screen
		local minx, maxx = -self.width, mapwidth
		if self.x < minx then
			self.x = maxx
		elseif self.x > maxx then
			self.x = minx
		end
	end

	local closestplayer = 1 --find closest player
	for i = 2, players do
		local v = objects["player"][i]
		if math.abs(self.x - v.x) < math.abs(self.x - objects["player"][closestplayer].x) then
			closestplayer = i
		end
	end

	if self.y > mapheight then
		if (not self.enemy) and #objects["boomboom"] < 2 then
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
	end
	
	if self.dead then
		self.deathtimer = self.deathtimer + dt
		if self.deathtimer > 1 then
			if (not self.enemy) and #objects["boomboom"] < 2 then
				table.insert(objects["levelball"], levelball:new(self.x+12/16*(self.supersized or 1), self.y))
				playsound(bulletbillsound)
				makepoof(self.x+self.width/2, self.y+self.height/2, "boom")
			elseif self.key then
				objects["player"][closestplayer].key = (objects["player"][closestplayer].key or 0) + 1
				playsound(keysound)
			end
			return true
		end
		return false
	elseif self.ducking then
		self.duckingtimer = self.duckingtimer + dt
		if self.duckingtimer > ducktime then
			if self.x > objects["player"][closestplayer].x then
				self.direction = "left"
				self.speedx = -self.speed
			else
				self.direction = "right"
				self.speedx = self.speed
			end
			self:duck(false)
		elseif self.flying and self.duckingtimer > ducktime-0.1 then --unduck animation works differently when flying
			self.quad = boomboomquad[spriteset][9]
		elseif self.duckingtimer < 0.1 and not self.skipduckinganim then
			self.quad = boomboomquad[spriteset][9]
		else
			self.quad = boomboomquad[spriteset][8]
		end
	elseif self.stomped then
		self.stompedtimer = self.stompedtimer + dt
		if self.stompedtimer > 1 then
			self:duck(true)
			if self.flying and self.inblock then
				self.speedy = -boomboomjumpforce
			end
		end
	elseif self.jumping then
		self.jumptimer = self.jumptimer + dt
		if self.jumptimer > 1 then
			self:bigjump()
			if self.x > objects["player"][closestplayer].x then
				self.direction = "left"
				self.speedx = -self.speed
			else
				self.direction = "right"
				self.speedx = self.speed
			end
		else
			self.speedx = 0
			self.quad = boomboomquad[spriteset][10]
		end
	end
		
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
		
	else
		if self.ducking == false and self.jumping == false then
			--find player
			if not self.stomped and not self.bigjumping then
				if self.direction == "right" then
					if self.x > objects["player"][closestplayer].x + 3 then
						self.direction = "left"
					end
				else
					if self.x < objects["player"][closestplayer].x - 3 then
						self.direction = "right"
					end
				end
			end

			--move
			if self.flying then
				local targety = yscroll+4
				local targetx = objects["player"][closestplayer].x+objects["player"][closestplayer].width/2-self.width/2
				local sx, sy = self.speed+1, self.speed --speed
				--diving!
				self.startduckingtimer = self.startduckingtimer + dt
				if self.startduckingtimer > 3.4 then
					if not self.dive then
						self.static = false
						self.dive = true
						self.speedy = 0
						--self.speedx = 0
						self.divetargety = objects["player"][closestplayer].y-self.height
						self.divetargetx = targetx
						if self.y > self.divetargety then
							self.divedirection = "up"
						else
							self.divedirection = "down"
						end
					end
					
					targety = self.divetargety
					targetx = self.divetargetx
					sx = self.speed+3
					sy = self.speed+4
				elseif self.startduckingtimer > 3 then
					self.static = true
				end
				--go towards target
				if self.y > targety then
					self.speedy = math.max(-sy, self.speedy - friction*dt*1.8)
				else
					self.speedy = math.min(sy, self.speedy + friction*dt*1.8)
				end
				if self.x > targetx then
					self.speedx = math.max(-sx, self.speedx - 7*dt)
				else
					self.speedx = math.min(sx, self.speedx + 7*dt)
				end
				if self.dive then
					if (self.divedirection == "down" and self.y > targety) or (self.divedirection == "up" and self.y < targety) or (self.startduckingtimer > 6) then
						self.dive = false
						if math.random(1, 3) == 1 then
							self:duck(true)
						else
							self.startduckingtimer = -math.random(1, 3)
						end
					end
				end
			else
				if not self.stomped and not self.bigjumping then
					if self.direction == "right" then
						if self.speedx > self.speed then
							self.speedx = self.speedx - friction*dt*5
							if self.speedx < self.speed then
								self.speedx = self.speed
							end
						elseif self.speedx < self.speed then
							self.speedx = self.speedx + friction*dt*5
							if self.speedx > self.speed then
								self.speedx = self.speed
							end
						end
					else
						if self.speedx < -self.speed then
							self.speedx = self.speedx + friction*dt*5
							if self.speedx > -self.speed then
								self.speedx = -self.speed
							end
						elseif self.speedx > -self.speed then
							self.speedx = self.speedx - friction*dt*5
							if self.speedx < -self.speed then
								self.speedx = -self.speed
							end
						end
					end
				end
			end

			--animation
			self.animationtimer = self.animationtimer + dt
			local animspeed = 0.065
			if self.flying and (self.dive or self.startduckingtimer > 3) then
				animspeed = 0.045
			end
			while self.animationtimer > animspeed do
				if not self.stomped then
					self.quadi = self.quadi + 1
					if self.quadi == 7 then
						self.quadi = 1
					end
					self.quad = boomboomquad[spriteset][self.quadi]
				else
					if self.animationdirection == "left" then
						self.animationdirection = "right"
					else
						self.animationdirection = "left"
					end
				end
				self.animationtimer = self.animationtimer - animspeed
			end

			--start ducking
			if not self.flying then
				self.startduckingtimer = self.startduckingtimer + dt
				if self.startduckingtimer > self.duckdelay then
					if self.hp == 3 then
						if self.direction == "right" then
							self.speedx = duckspeed
						else
							self.speedx = -duckspeed
						end
						self:duck(true)
					elseif self.hp == 2 then
						self.jumping = true
					elseif self.hp == 1 then
						
					end
					self.startduckingtimer = 0
				elseif self.startduckingtimer > speedupdelay and not (self.hp == 1) then
					self.speed = normalspeed
				elseif self.startduckingtimer > speedupfastdelay and self.hp == 1 then
					self.speed = fastspeed
				end
			end
		elseif self.ducking then --cha cha slide
			if self.speedx > 0 then
				self.speedx = math.max(0, self.speedx - friction*dt)
			elseif self.speedx < 0 then
				self.speedx = math.min(0, self.speedx + friction*dt)
			end
		end

		return false
	end
end

function boomboom:stomp()
	self.trackable = false
	self.speedy = 0
	self.gravity = 0
	self.active = false
	self.quad = boomboomquad[spriteset][7]
	self.startduckingtimer = 0
	self.speedx = 0
	self.active = false
	self.stomped = true
	self.skipduckinganim = true
	self:hurt()
end

function boomboom:shotted(dir) --fireball, star, turtle
	self.firehp = self.firehp - 1
	if self.firehp <= 0 then
		self:die()
	end
end

function boomboom:hurt()
	self.hp = self.hp - 1
	if not self.flying then
		self.speed = normalspeed
	end
	if self.hp == 2 then
		self.duckdelay = 2
	else
		self.duckdelay = 5
	end
	if self.hp <= 0 then
		self:die()
	end
end

function boomboom:duck(duck)
	if duck then
		if self.flying and self.inblock then
			self.mask[2] = false
		end
		self.active = true
		self.gravity = yacceleration
		self.quad = boomboomquad[spriteset][8]
		--self.speedx = 0

		self.ducking = true
		self.duckingtimer = 0

		self.stomped = false
		self.stompedtimer = 0
	else
		if self.flying and self.inblock then
			self.mask[2] = true
		end
		self.active = true
		if self.flying then
			self.gravity = 0
		else
			self.gravity = yacceleration
		end
		self.duckingtimer = 0
		self.startduckingtimer = 0
		self.speedy = -boomboomjumpforce
		self.quad = boomboomquad[spriteset][9]
		self.duckingtimer = 0
		self.ducking = false

		self.justducked = true
		self.skipduckinganim = false
	end
end

function boomboom:die()
	self.speedx = 0
	self.speedy = 0
	self.gravity = 0
	self.dead = true
	self.active = false
	self.quad = boomboomquad[spriteset][7]
end

function boomboom:bigjump()
	self.speedy = -boomboomhighjumpforce
	self.quad = boomboomquad[spriteset][self.quadi]
	self.jumping = false
	self.bigjumping = true
	self.jumptimer = 0
	self.speed = jumpspeed
end

function boomboom:smalljump()
	self.smalljumping = true
	self.speedy = -boomboomjumpforce
	self.quad = boomboomquad[spriteset][self.quadi]
end

function boomboom:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	if self.direction == "left" and not self.bigjumping and not self.smalljumping and not self.ducking and b.y > self.y and self.speedy == 0 then
		self:smalljump()
		return true
	end

	if (not self.smalljumping) and (not (self.flying and self.ducking)) then
		self.speedx = self.speed
		self.direction = "right"
	end
	
	return true
end

function boomboom:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	if self.direction == "right" and not self.bigjumping and not self.smalljumping and not self.ducking and b.y > self.y and self.speedy == 0 then
		self:smalljump()
		return true
	end
	
	if (not self.smalljumping) and (not (self.flying and self.ducking)) then
		self.speedx = -self.speed
		self.direction = "left"
	end
	
	return true
end

function boomboom:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end

	if (not self.smalljumping) and self.flying then
		self.speedy = self.speed
		self.direction = "right"
	end
end

function boomboom:globalcollide(a, b)
	if a == "bulletbill" or a == "bigbill" then
		if b.killstuff ~= false then
			return true
		end
	end
	
	if a == "fireball" or a == "player" then
		return true
	end
end

function boomboom:startfall()

end

function boomboom:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	self.speedy = 0
	self.smalljumping = false
	if self.bigjumping then
		if self.hp == 1 then
			self.speed = fastspeed
		else
			self.speed = normalspeed
		end
		self.bigjumping = false
	end
	if self.justducked then
		if not self.flying then
			self.speed = slowspeed
		end
		self.justducked = false
	end
end

function boomboom:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end