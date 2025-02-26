levelball = class:new()

function levelball:init(x, y)
	--PHYSICS STUFF
	self.x = x-6/16
	self.y = y-11/16
	self.speedy = 0
	self.speedx = 0
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.category = 6
	
	self.mask = {	true,
					false, false, true, true, true,
					false, true, false, true, true,
					false, true, true, false, true,
					true, true, false, true, true,
					false, true, true, false, false,
					true, false, true, true, true,
					true}
	
	self.destroy = false
	self.autodelete = true
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = levelballimg
	self.quad = levelballquad[1]
	self.offsetX = 6
	self.offsetY = 3
	self.quadcenterX = 8
	self.quadcenterY = 8
	
	self.rotation = 0 --for portals
	self.uptimer = 0
	
	self.falling = false
	
	self.finish = false
	self.finishwait = false
end

function levelball:update(dt)
	if self.finishwait then
		self.finishwait = self.finishwait - dt
		if self.finishwait < 0 then
			--next level
			nextlevel()
			subrtactscore = false
			subtracttimer = 0
			levelballfinish = false
		end
		return
	elseif self.finish then
		self.finish = self.finish + dt
		if levelballfinishback[math.floor(self.finish*10)] then
			love.graphics.setBackgroundColor(levelballfinishback[math.floor(self.finish*10)])
		else
			love.graphics.setBackgroundColor(backgroundcolor[background])
		end
		if (not self.sound and self.finish > 6.9) or (self.sound and not self.sound:isPlaying()) then
			--subtract score but it takes too long
			if mariotime > 0 then
				if subtractscore then
					subtracttimer = subtracttimer + dt
					while subtracttimer > scoresubtractspeed do
						subtracttimer = subtracttimer - scoresubtractspeed
						if mariotime > 0 then
							mariotime = math.max(0, math.ceil(mariotime - 4))
							marioscore = marioscore + 50
						end
						
						if mariotime <= 0 then
							scoreringsound:stop()
							subtractscore = false
							subtracttimer = 0
							mariotime = 0
						end
					end
				else
					playsound(scoreringsound)
					subtractscore = true
					subtracttimer = 0
				end
			else
				scoreringsound:stop()
				self.finishwait = 0.2
			end
		end
		return
	end
	
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
	
	--check if offscreen
	if self.x < xscroll - width+3 or self.y > mapheight+3 then
		return true
	end
	
	if self.destroy then
		return true
	else
		return false
	end
end

function levelball:get()
	self.static = true
	self.active = false
	self.drawable = false
	if levelfinished then
		return
	end
	
	levelfinished = true

	stopmusic()
	love.audio.stop()
	if self.sound then
		playsound(self.sound)
	else
		playsound(castleendsound)
	end
	self.finish = 0
	
	for i = 1, players do
		local p = objects["player"][i]
		p.controlsenabled = false
		p.invincible = true
		p.speedx = 0
	end
end

function levelball:leftcollide(a, b)
	self.speedx = 0
	
	if a == "player" then
		self:get()
	end
	
	return false
end

function levelball:rightcollide(a, b)
	self.speedx = 0
	
	if a == "player" then
		self:get()
	end
	
	return false
end

function levelball:floorcollide(a, b)
	if a == "player" then
		self:get()
	end
	
	if self.activatey then
		if self.y > self.activatey then
			self.activatey = false
		else
			return false
		end
	end
end

function levelball:ceilcollide(a, b)
	if a == "player" then
		self:get()
	end	
end

function levelball:passivecollide(a, b)
	if a == "player" then
		self:get()
		return false
	end	
end
