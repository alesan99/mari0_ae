vine = class:new()

function vine:init(x, y, t)
	self.cox = math.floor(x)
	self.coy = math.floor(y)
	self.ox = x--origin
	self.oy = y
	self.t = t
	
	self.blockscissor = false --make it look like vine is in a block when using a vine stop
	self.vinestop = false
	if self.t == "start" then
		self.limit = mapheight-6+1/16
	else
		self.limit = -1
		--vine stop
		for y = self.coy, 1, -1 do
			if map[self.cox][y][2] == 219 then
				self.limit = y-1
				if tilequads[map[self.cox][y][1]].collision then
					self.limit = y-8/16
					self.blockscissor = y
				end
				self.vinestop = true
				break
			end
		end
	end
	
	self.timer = 0
	
	self.width = 10/16
	self.height = 0
	
	self.x = x-0.5-self.width/2
	self.y = y-1

	self.length = 0
	self.maxlength = self.y-self.limit
	
	self.static = true
	self.active = true
	
	self.category = 18
	
	self.mask = {true}
	
	--IMAGE STUFF
	self.drawable = false
end

function vine:update(dt)
	if self.length < self.maxlength or self.moving then
		self.length = self.length + vinespeed*dt
		if self.length >= self.maxlength then
			self.length = self.maxlength
		end
		self.y = self.oy-self.length-1
		self.height = self.oy-self.y-1.7
		self.height = math.max(self.height, 0)
	end
end

function vine:draw()
	if self.blockscissor then
		love.graphics.setScissor(0, math.floor((self.blockscissor-yscroll-.5)*16*scale), width*16*scale, (self.oy-self.blockscissor-1)*16*scale)
	else
		love.graphics.setScissor(0, 0, width*16*scale, math.max(0, (self.oy-1.5-yscroll)*16*scale))
	end
	
	love.graphics.draw(vineimg, vinequad[spriteset][1], math.floor((self.x-xscroll-((1-self.width)/2))*16*scale), (self.y-0.5-2/16-yscroll)*16*scale, 0, scale, scale)
	for i = 1, math.ceil(self.height-14/16+.7) do
		love.graphics.draw(vineimg, vinequad[spriteset][2], math.floor((self.x-xscroll-((1-self.width)/2))*16*scale), (self.y-0.5-2/16+i-yscroll)*16*scale, 0, scale, scale)
	end
	
	love.graphics.setScissor()
end