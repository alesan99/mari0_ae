energycatcher = class:new()

function energycatcher:init(x, y, dir, r)
	--PHYSICS STUFF
	self.cox = x
	self.coy = y
	self.x = x-1
	self.y = y-1
	self.width = 8/16
	self.height = 16/16
	self.static = true
	self.active = true
	self.category = 4
	self.gravity = 0
	self.portalable = false
	self.dir = dir or "right"

	self.r = r
	if self.r and self.r ~= "link" then
		local v = convertr(self.r, {"string", "bool"}, true)
		--DIR
		self.dir = v[1]

		--OFFSET?
		self.offset = v[2]
	
		if self.offset then
			if self.dir == "left" or self.dir == "right" then
				self.y = self.y + .5
			else
				self.x = self.x + .5
			end
		end
	end

	self.rotation = 0
	
	self.mask = {true}
	
	--IMAGE STUFF
	self.drawable = true
	self.graphic = energylauncherimage
	self.quad = energylauncherquad[2][1]
	self.offsetX = 8
	self.offsetY = 0
	self.quadcenterX = 8
	self.quadcenterY = 8
	if self.dir == "right" then --multiple directions. This code is so bad I feel bad :(
		self.animationdirection = "right"
	elseif self.dir == "left" then
		self.animationdirection = "left"
		self.offsetX = 0
		self.x = self.x + 8/16
	elseif self.dir == "up" then
		self.rotation = -math.pi/2
		self.y = self.y + 8/16
		self.offsetY = 8
		self.width = 16/16
		self.height = 8/16
	elseif self.dir == "down" then
		self.rotation = math.pi/2
		self.width = 16/16
		self.height = 8/16
	end
	
	self.out = false
	self.outtable = {}
	self.colls = nil
	
	self.falling = false
end

function energycatcher:addoutput(a, t)
	table.insert(self.outtable, {a, t})
end

function energycatcher:update(dt)
	
end

function energycatcher:activate()
	if self.activated then
		return false
	end
	self.quad = energylauncherquad[2][2]
	for i = 1, #self.outtable do
		if self.outtable[i][1].input then
			self.outtable[i][1]:input("on", self.outtable[i][2])
		end
	end
	self.activated = true
end


function energycatcher:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "energyball" and self.dir == "left" then
		self:activate()
	end
	return false
end

function energycatcher:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "energyball" and self.dir == "right" then
		self:activate()
	end
	return false
end

function energycatcher:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "energyball" and self.dir == "up" then
		self:activate()
	end
end

function energycatcher:globalcollide(a, b)

end

function energycatcher:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "energyball" and self.dir == "down" then
		self:activate()
	end
	if a == "player" then
		playsound(blockhitsound) --make sound when hit by mario
	end
end

function energycatcher:passivecollide(a, b)
	self:leftcollide(a, b)
	return false
end