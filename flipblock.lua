flipblock = class:new()

local switchblockswitched = {false,false,false,false} --should only activate once per frame
function flipblock:init(x, y, t, r)
	--PHYSICS STUFF
	self.cox = x
	self.coy = y
	self.x = x-1
	self.y = y-1
	self.speedy = 0
	self.speedx = 0
	self.width = 1
	self.height = 1
	self.static = true
	self.active = true
	self.category = 2
	self.gravity = 0
	self.portalable = false
	--fliptime = 7
	
	self.mask = {	true, 
					false, false, false, false, false,
					false, false, false, true, false,
					false, false, true, false, false,
					true, true, false, false, false,
					false, true, true, false, false,
					true, false, true, true, true,
					false, true}
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = flipblockimage
	self.quad = flipblockquad[spriteset][1]
	self.offsetX = 8
	self.offsetY = 0
	self.quadcenterX = 8
	self.quadcenterY = 8
	self.quadi = 1
	
	self.t = t or "flipblock"
	if self.t == "actionblock" then
		self.on = false
		self.graphic = actionblockimg
		self.quad = goombaquad[spriteset][1]
		self.outtable = {}
	elseif self.t == "switchblock" then
		self.on = true
		self.graphic = switchblockimg
		self.color = r or 1
		self.animtimer = 0
		self.quadi = 1
		self.quad = flipblockquad[self.color][1]
	elseif self.t == "propellerbox" then
		self.graphic = helmetpropellerimg
		self.quad = helmetpropellerquad[1]
		self.animtimer = 0
		self.quadi = 1
		self.quadcenterY = 16
		self.helmetable = "propellerbox"
	elseif self.t == "cannonbox" then
		self.graphic = helmetcannonimg
		self.quad = helmetcannonquad.box
		self.helmetable = "cannonbox"
	else
		self.rotatetimer = 0
		self.flippable = true
	
		self.checktable = deepcopy(enemies)
		table.insert(self.checktable, "player")
		table.insert(self.checktable, "enemy")
	end
	
	self.flip = false
	self.timer = 0
	self.blockbouncetimer = blockbouncetime
end

function flipblock:update(dt)
	--delete
	if self.delete then
		return true
	end

	if self.blockbouncetimer < blockbouncetime then
		self.blockbouncetimer = self.blockbouncetimer + dt
		if self.blockbouncetimer > blockbouncetime then
			self.blockbouncetimer = blockbouncetime
		end
	end
	if self.blockbouncetimer < blockbouncetime/2 then
		self.offsetY = self.blockbouncetimer / (blockbouncetime/2) * blockbounceheight * 16
	else
		self.offsetY = (2 - self.blockbouncetimer / (blockbouncetime/2)) * blockbounceheight * 16
	end

	if self.t == "switchblock" then
		switchblockswitched[self.color] = false
		self.animtimer = self.animtimer + dt
		while self.animtimer > goombaanimationspeed do
			if self.quadi == 2 then
				self.quadi = 1
			else
				self.quadi = 2
			end
			if self.on then
				self.quad = flipblockquad[self.color][self.quadi]
			else
				self.quad = flipblockquad[self.color][self.quadi+2]
			end
			self.animtimer = self.animtimer - goombaanimationspeed
		end
	elseif self.t == "propellerbox" then
		self.animtimer = self.animtimer + dt
		while self.animtimer > 0.08 do
			self.quadi = self.quadi + 1
			if self.quadi > 4 then
				self.quadi = 1
			end
			self.quad = helmetpropellerquad[self.quadi]
			self.animtimer = self.animtimer - 0.08
		end
	end

	if self.flippable then
		if self.flip then
			self.active = false
			self.rotatetimer = self.rotatetimer + dt
			if self.rotatetimer > 6.6 and self.quadi == 1 and #checkrect(self.x, self.y, self.width, self.height, self.checktable) == 0 then --how long the rotation lasts
				self.quad = flipblockquad[spriteset][1]
				self.rotatetimer = 0
				self.flip = false
			else
				self.timer = self.timer + dt
				while self.timer > 0.3 do
					self.quadi = self.quadi + 1
					if self.quadi == 5 then
						self.quadi = 1
					end
					self.quad = flipblockquad[spriteset][self.quadi]
					self.timer = self.timer - 0.3
				end
			end
		else
			self.active = true
		end
		
		if self.flip then
			self.timer = self.timer + dt
			if self.portalable == false then
				while self.timer > 0.3 do
					self.quadi = self.quadi + 1
					if self.quadi == 5 then
						self.quadi = 1
					end
					self.quad = flipblockquad[spriteset][self.quadi]
					self.timer = self.timer - 0.3
				end
			end
		end
	end
end

function flipblock:leftcollide(a, b)
	if (a == "thwomp" and b.t == "right") or ((a == "koopa" or b.shellanimal) and b.small) or (a == "bigkoopa" and b.small) or a == "shell" or a == "spikeball" then
		self:hit()
	end
end

function flipblock:rightcollide(a, b)
	if (a == "thwomp" and b.t == "left") or ((a == "koopa" or b.shellanimal) and b.small) or (a == "bigkoopa" and b.small) or a == "shell" or a == "spikeball" then
		self:hit()
	end
end

function flipblock:ceilcollide(a, b)
	if (a == "thwomp" and b.t == "down") or a == "skewer" or a == "icicle" or a == "spikeball" then
		self:hit()
	end
end

function flipblock:globalcollide(a, b)
end

function flipblock:hit()
	self.blockbouncetimer = 0
	if self.flippable then
		self.flip = true
	end

	if self.t == "actionblock" then
		playsound(blockhitsound)
		self.on = not self.on
		if self.on then
			self:out("on")
			self.quad = goombaquad[spriteset][2]
		else
			self:out("off")
			self.quad = goombaquad[spriteset][1]
		end
	elseif self.t == "switchblock" then
		if not switchblockswitched[self.color] then --only switch once if many were hit at the same time
			self.on = not self.on
			if self.on then
				self.quad = flipblockquad[self.color][self.quadi]
			else
				self.quad = flipblockquad[self.color][self.quadi+2]
			end

			playsound(switchsound)
			changeswitchstate(self.color, false)
			for j, w in pairs(objects["flipblock"]) do
				if w.t == "switchblock" and w.color == self.color and not (w.cox == self.cox and w.coy == self.coy) then
					w.on = self.on
					if self.on then
						w.quad = flipblockquad[self.color][w.quadi]
					else
						w.quad = flipblockquad[self.color][w.quadi+2]
					end
				end
			end
		end

		switchblockswitched[self.color] = true
	else
		playsound(blockhitsound)
	end

	--kill enemies on top
	hitontop(self.cox, self.coy)
end

function flipblock:floorcollide(a, b)
	if a == "player" or a == "spikeball" then
		self:hit()
	end
end

function flipblock:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end

function flipblock:out(out)
	for i = 1, #self.outtable do
		if self.outtable[i][1].input then
			self.outtable[i][1]:input(out or "toggle", self.outtable[i][2])
		end
	end
end

function flipblock:destroy()
	if self.t ~= "flipblock" then
		return false
	end
	playsound(blockbreaksound)
	local debris = rgbaToInt(252, 152, 56, 255)
	if blockdebrisquads[debris] then
		table.insert(blockdebristable, blockdebris:new(self.cox-.5, self.coy-.5, 3.5, -23, blockdebrisimage, blockdebrisquads[debris][spriteset]))
		table.insert(blockdebristable, blockdebris:new(self.cox-.5, self.coy-.5, -3.5, -23, blockdebrisimage, blockdebrisquads[debris][spriteset]))
		table.insert(blockdebristable, blockdebris:new(self.cox-.5, self.coy-.5, 3.5, -14, blockdebrisimage, blockdebrisquads[debris][spriteset]))
		table.insert(blockdebristable, blockdebris:new(self.cox-.5, self.coy-.5, -3.5, -14, blockdebrisimage, blockdebrisquads[debris][spriteset]))
	end
	self.delete = true
	self.drawable = false
	objects["flipblock"][tilemap(self.cox, self.coy)] = nil
end

function flipblock:helmeted()
	self.delete = true
	self.drawable = false
	objects["flipblock"][tilemap(self.cox, self.coy)] = nil
end
