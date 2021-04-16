bubble = class:new()

--"FUCKING BUBBLES!!!!"
--          -The Nostalgia Critic

function bubble:init(x, y)
	self.x = x
	self.y = y
	
	self.speedy = -bubblesspeed
end

function bubble:update(dt)
	self.speedy = self.speedy + (math.random()-0.5)*dt*100
	
	if self.speedy < -bubblesspeed-bubblesmargin then
		self.speedy = -bubblesspeed-bubblesmargin
	elseif self.speedy > -bubblesspeed+bubblesmargin then
		self.speedy = -bubblesspeed+bubblesmargin
	end
	
	self.y = self.y + self.speedy*dt
	
	if self.y < bubblesmaxy and underwater then
		return true
	end
	
	if not underwater then
		local water = false

		local x = math.floor(self.x)+1
		local y = math.floor(self.y)+1
		
		--water tiles
		if inmap(x, y) then
			if tilequads[map[x][y][1]]:getproperty("water", x, y) then
				water = true
			end
		end

		--rising water
		if not water then
			for i, v in pairs(objects["risingwater"]) do
				if v.water then
					water = v:inside(self.x, self.y)
					if water then
						break
					end
				end
			end
		end
		
		if not water then
			return true
		end
	end

	
	return false
end

function bubble:draw()
	love.graphics.draw(bubbleimg, math.floor((self.x-xscroll)*16*scale), math.floor((self.y-yscroll-.5)*16*scale), 0, scale, scale, 2, 2)
end