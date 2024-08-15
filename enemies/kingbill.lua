kingbilllauncher = class:new()

function kingbilllauncher:init(x, y, speed, r)
	self.x = x
	self.y = y
	self.dir = "right"
	if speed and type(speed) == "string" and speed:find("|") then
		local s = speed:split("|")
		self.speed = tonumber(s[1]) or kingbillspeed
		self.dir = s[2]
	else
		self.speed = speed or kingbillspeed
	end
	self.r = r
	self.autodelete = true

	self.bullets = 0

	self.linked = false
end

function kingbilllauncher:update(dt)
	if self.bullets >= 1 or self.linked then
		return
	end
	
	--get nearest player
	local pl = 1
	for i = 2, players do
		if math.abs(objects["player"][i].x - self.x) < math.abs(objects["player"][pl].x - self.x) then
			pl = i
		end
	end
	
	if self.dir == "right" then
		if objects["player"][pl].x > self.x then
			self:fire()
		end
	elseif self.dir == "left" then
		if objects["player"][pl].x < self.x then
			self:fire()
		end
	elseif self.dir == "up" then
		if objects["player"][pl].y < self.y then
			self:fire()
		end
	elseif self.dir == "down" then
		if objects["player"][pl].y > self.y then
			self:fire()
		end
	end
end

function kingbilllauncher:fire()
	if self.bullets >= 1 then
		return
	end
	if editormode then --!
		return
	end
	if self.dir == "right" then
		table.insert(objects["kingbill"], kingbill:new(xscroll-200/16, self.y, self.speed, self.dir, self))
	elseif self.dir == "left" then
		table.insert(objects["kingbill"], kingbill:new(xscroll+width+100/16, self.y, self.speed, self.dir, self))
	elseif self.dir == "up" then
		table.insert(objects["kingbill"], kingbill:new(self.x, yscroll+height+100/16, self.speed, self.dir, self))
	elseif self.dir == "down" then
		table.insert(objects["kingbill"], kingbill:new(self.x, yscroll-200/16, self.speed, self.dir, self))
	end
	self.bullets = self.bullets + 1
end

function kingbilllauncher:callback()
	self.bullets = self.bullets - 1
end

function kingbilllauncher:link()
	if #self.r > 3 then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[5]) == v.cox and tonumber(self.r[6]) == v.coy then
					self.linked = true
					v:addoutput(self)
				end
			end
		end
	end
end

function kingbilllauncher:input(t)
	if t == "on" or t == "toggle" then
		self:fire()
	end
end

----------------------
kingbill = class:new()
function kingbill:init(x, y, speed, dir, parent)
	self.startx = x
	--PHYSICS STUFF
	self.x = self.startx
	self.y = y-200/16
	self.oldx = self.x
	self.oldy = self.y
	self.speedy = 0
	self.speedx = speed or kingbillspeed
	self.width = 100/16--200/16
	self.height = 200/16
	self.static = false
	self.active = true
	self.gravity = 0
	self.rotation = 0
	self.extremeautodelete = true
	self.extremeautodeletedist = 100/16+0.1
	self.killstuff = true
	self.portalable = false
	self.dir = dir or "right"
	self.parent = parent
	self.ignoreplatform = true
	
	self.killzonex = 100/16--x or kill circle (middle of sprite)
	self.killzoney = 100/16--y
	self.killzoner = (100/16)^2--radius
	self.killtable = {"player", "goomba", "koopa", "hammerbro"}
	
	--IMAGE STUFF
	self.drawable = true
	self.quad = kingbillquad[spriteset]
	self.offsetX = 100
	self.offsetY = -92
	self.quadcenterX = 100
	self.quadcenterY = 100
	self.graphic = kingbillimg
	self.drawable = false
	
	self.category = 11

	if self.dir == "left" then
		self.killzonex = 0
		self.offsetX = 0
		self.speedx = -self.speedx
	elseif self.dir == "up" then
		self.y = y
		self.width = 200/16
		self.height = 100/16
		self.offsetY = 8
		self.killzoney = 0
		self.rotation = math.pi*1.5
		self.speedy = -self.speedx
		self.speedx = 0
		if self.y > mapheight then
			self.autodelete = false
		end
	elseif self.dir == "down" then
		self.y = y
		self.width = 200/16
		self.height = 100/16
		self.offsetY = -100
		self.rotation = math.pi*1.5
		self.speedy = self.speedx
		self.speedx = 0
	end
	
	self.mask = {	true, 
					true, false, false, false, true,
					true, true, true, true, true,
					true, false, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					true, true, true, true, true,
					false, true}
					
	self.shot = false
	
	playsound(thwompbigsound)
	--playsound(bulletbillsound)
end

function kingbill:update(dt)
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		--check if offscreen
		if self.y > mapheight+3 then
			return true
		else
			return false
		end
	else
		if self.speedx < 0 then
			self.animationdirection = "left"
		elseif self.speedx > 0 then
			self.animationdirection = "right"
		elseif self.speedy < 0 then
			self.animationdirection = "right"
		elseif self.speedy > 0 then
			self.animationdirection = "left"
		end
	
		if math.ceil(self.x) ~= math.ceil(self.oldx) or math.ceil(self.y) ~= math.ceil(self.oldy) then --only check if its on new blocks
			local tx, ty = self.x, self.y
			local w, h = self.width*2, self.height
			if self.dir == "down" then
				w = self.width
				h = self.height*2
			elseif self.dir == "up" then
				w = self.width
				h = self.height*2
				ty = self.y-self.height
			elseif self.dir == "left" then
				tx = self.x-self.width
			end
			for x = math.floor(tx), math.ceil(tx+w) do
				for y = math.floor(ty), math.ceil(ty+h) do
					--only destroy blocks in a circle
					if ((x-(self.x+self.killzonex))*(x-(self.x+self.killzonex))+(y-(self.y+self.killzoney))*(y-(self.y+self.killzoney)))-2 <= self.killzoner then
						local inmap = true
						if x < 1 or x > mapwidth or y < 1 or y > mapheight then
							inmap = false
						end
						if inmap then
							local r = map[x][y]
							if r then
								if tilequads[r[1]].breakable then
									destroyblock(x, y, "nopoints")
								end
							end
						end
					end
				end
			end
			for i = 1, 2 do
				local x, y = self.x, self.y+math.random()*self.height
				if self.dir == "down" then
					x = self.x+math.random()*self.width
					y = self.y
				elseif self.dir == "up" then
					x = self.x+math.random()*self.width
					y = self.y+self.height
				elseif self.dir == "left" then
					x = self.x+self.width
				end
				makepoof(x, y, "poof")
			end
		end
		
		--kill radius
		for __, a in pairs(self.killtable) do
			for i, b in pairs(objects[a]) do
				if b.active and (not b.dead) and (((b.x+b.width/2)-(self.x+self.killzonex))*((b.x+b.width/2)-(self.x+self.killzonex))+((b.y+b.height/2)-(self.y+self.killzoney))*((b.y+b.height/2)-(self.y+self.killzoney))) <= self.killzoner then
					if a == "player" then
						if not (levelfinished and not b.controlsenabled) then
							b:die("time")
						end
					else
						b:shotted("left")
					end
				end
			end
		end
		
		self.oldx = self.x
		self.oldy = self.y
	end
end

function kingbill:draw()
	local dirscale
	if self.animationdirection == "left" then
		dirscale = -scale
	else
		dirscale = scale
	end
	local horscale = scale
	if self.shot or self.flipped then
		horscale = -scale
	end
	
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.graphic, self.quad, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), self.rotation, dirscale, horscale, self.quadcenterX, self.quadcenterY)
end

function kingbill:stomp(dir) --fireball, star, turtle
	playsound(blockhitsound)
end

function kingbill:shotted(dir)
	self:stomp(dir)
end

function kingbill:rightcollide(a, b)
	self:globalcollide(a, b)
	return false
end

function kingbill:leftcollide(a, b)
	self:globalcollide(a, b)
	return false
end

function kingbill:ceilcollide(a, b)
	self:globalcollide(a, b)
	return false
end

function kingbill:floorcollide(a, b)
	self:globalcollide(a, b)
	return false
end

function kingbill:globalcollide(a, b)
	if self.killstuff then
		if a == "goomba" or a == "koopa" or a == "hammerbro" or a == "cheepcheep" or a == "lakito" or a == "paragoomba" or a == "flyingfish" or a == "plant" or a == "downplant" or a == "sidestepper" or a == "biggoomba" or a == "bigkoopa" or a == "shell" or a == "goombrat" or a == "firebro" or a == "drygoomba" or a == "boomerangbro" then
			b:shotted("left")
			return true
		end
		if a == "player" then
			if not (levelfinished and not b.controlsenabled) then
				b:die("time")
				return true
			end
		end
	else
		return true
	end
end

function kingbill:autodeleted()
	if self.parent then
		self.parent:callback()
	end
end

function kingbill:dospawnanimation(a)
	if a == "pipe" then
		self.customscissor = false
		self.active = true
	end
end
