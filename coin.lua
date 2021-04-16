--most simple entity ever

coin = class:new()

function coin:init(x, y)
	self.cox = x
	self.coy = y
	
	self.active = false
	self.static = true
end

function coin:draw()
	love.graphics.draw(coinimage, coinquads[spriteset][coinframe], math.floor((self.cox-1-xscroll)*16*scale), ((self.coy-1-yscroll)*16-8)*scale, 0, scale, scale)
end