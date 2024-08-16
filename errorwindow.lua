--im sick of mari0
--so maybe ill finish this later
--this is just some simple framework so i can get it ready faster
--TODO!

errorwindow = class:new()
local padding = 6

function errorwindow:init(title, text)
	self.width = 360
	self.height = 180
	self.x = (width*16-self.width)/2
	self.y = (height*16-self.height)/2

	self.title = title
	self.text = text

	self.button = {}
	self.button["ignore"] = guielement:new("button", self.x+padding, self.y+self.height-15-padding, "ignore", function() end, 2)
	self.button["retry"] = guielement:new("button", self.x+self.width-8-padding, self.y+self.height-15-padding, "retry", function() end, 2)
	self.button["retry"].x = self.button["retry"].x - self.button["retry"].width

	self.a = 255
	self.opened = false
end

function errorwindow:update(dt)
	self.a = math.min(255, self.a + 3000*dt)
	self.button["ignore"]:update(dt)
	self.button["retry"]:update(dt)
end

function errorwindow:draw(a)
	a = a or self.a
	--window
	love.graphics.setColor(0,0,0,230*(a/255))
	love.graphics.rectangle("fill", self.x*scale, self.y*scale, self.width*scale, self.height*scale)
	love.graphics.setColor(255,255,255,a)
	drawrectangle(self.x, self.y, self.width, 19)
	drawrectangle(self.x, self.y+18, self.width, self.height-18)
	--text
	love.graphics.setScissor(self.x*scale, self.y*scale, self.width*scale, (self.height-padding-15)*scale)
	love.graphics.setColor(255,255,255,a)
	properprintfast(self.title, (self.x+padding)*scale, (self.y+padding)*scale)
	
	love.graphics.setColor(255,255,255,a)
	properprintfastf(self.text, (self.x+padding)*scale, (self.y+padding+20)*scale, self.width-padding*2)
	love.graphics.setScissor()

	--buttons
	self.button["ignore"]:draw(a)
	self.button["retry"]:draw(a)
end

function errorwindow:keypressed(k)
	if k == "escape" then
		self:close()
		self.retry()
	end
end

function errorwindow:mousepressed(x, y, button)
	for i, v in pairs(self.button) do
		if v:click(x, y, button) then
			if i == "ignore" then
				self:close()
			elseif i == "retry" then
				self:close()
				self.retry()
			end
			return
		end
	end
end

function errorwindow:mousereleased(x, y, button)
	for i, v in pairs(self.button) do
		v:unclick(x, y, button)
	end
end

function errorwindow:open(title, text, retry)
	if blockhitsound then
		playsound(blockhitsound)
	end
	self.title = title
	self.text = text
	self.retry = retry
	self.opened = true
	self.a = 0
end

function errorwindow:close()
	self.opened = false
end
