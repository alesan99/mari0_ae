entitytooltip = class:new()

local theight = 64
local twidth = 64
local descwidth = 0
twidth = twidth + descwidth*8

function entitytooltip:init(ent)
	self.ent = ent
	if tooltipimages[self.ent] then
		if not tooltipimages[self.ent].image then
			tooltipimages[self.ent].image = love.graphics.newImage(tooltipimages[self.ent].path)
		end
		self.graphic = tooltipimages[self.ent].image
		if self.graphic:getWidth() > 64 then
			self.timer = 0
		end
	else
		self.customenemy = true
		self.v = enemiesdata[self.ent]
		if self.v.tooltipgraphic then
			self.graphic = self.v.tooltipgraphic
			if self.graphic:getWidth() > 64 then
				self.timer = 0
			end
		else
			self.graphic = self.v.graphic
			self.quad = self.v.quad
		end
	end
end

function entitytooltip:update(dt)
	self.x = math.min(love.mouse.getX(), width*16*scale-(twidth+4)*scale)
	self.y = math.max(0, love.mouse.getY()-(theight+4)*scale)
	
	if self.timer then
		self.timer = (self.timer+dt)%2
	end
end

function entitytooltip:draw(a)
	if (tooltipimages[self.ent] and tooltipimages[self.ent].image) or self.customenemy then
		love.graphics.setColor(255, 255, 255, a)
		local s = self.ent
		if not self.customenemy then
			s = entitylist[self.ent].name or entitylist[self.ent].t
		end
		properprintFbackground(s, self.x, self.y, true)
		love.graphics.setColor(0, 0, 0, a)
		drawrectangle(self.x/scale, self.y/scale+8, (twidth+4), (theight+4))
		love.graphics.setColor(255, 255, 255, a)
		drawrectangle(self.x/scale+1, self.y/scale+9, 66, theight+2)
		
		local r, g, b = love.graphics.getBackgroundColor()
		love.graphics.setColor(r, g, b, a)
		love.graphics.rectangle("fill", self.x+2*scale, self.y+10*scale, 64*scale, 64*scale)
		love.graphics.setColor(255, 255, 255, a)
		if self.customenemy and (not self.v.tooltipgraphic) then
			love.graphics.setScissor(self.x+2*scale, self.y+10*scale, 64*scale, 64*scale)
			local v = self.v
			if v.width and v.height then
				local xoff, yoff = ((0.5-v.width/2+(v.spawnoffsetx or 0))*16 + v.offsetX - v.quadcenterX)*scale, (((v.spawnoffsety or 0)-v.height+1)*16-v.offsetY - v.quadcenterY)*scale
				love.graphics.setColor(255, 0, 0, 150*(a/255))
				love.graphics.rectangle("fill", self.x+(2+32-8)*scale, self.y+(10+32-8)*scale, 16*scale, 16*scale)
				love.graphics.setColor(255, 255, 255, a)
				if self.graphic and self.quad then
					love.graphics.draw(self.graphic, self.quad, self.x+(2+32-8)*scale+xoff, self.y+(10+32)*scale+yoff, 0, scale, scale)
				else
					local s = "broken\nsprite"
					if self.graphic and (not self.quad) then
						s = "no\n quad "
					elseif (not self.graphic) and self.quad then
						s = "no\ngraphic"
					end
					love.graphics.setColor(216, 40, 0, a)
					properprintFbackground(s, self.x+(2+32-#("broken")*4)*scale+xoff, self.y+(10+32)*scale+yoff, true)
				end
			end
			love.graphics.setScissor()
		else
			if self.timer then
				love.graphics.draw(self.graphic, tooltipquad[math.floor(self.timer)+1], self.x+2*scale, self.y+10*scale, 0, scale, scale)
				if self.timer%1 > 0.9 then
					local alpha = (((self.timer%1)-0.9)/0.1)
					love.graphics.setColor(r, g, b, (1-math.sqrt(1-(alpha*alpha)))*a)
					love.graphics.rectangle("fill", self.x+2*scale, self.y+10*scale, 64*scale, 64*scale)
					love.graphics.setColor(255, 255, 255, alpha*a)
					love.graphics.draw(self.graphic, tooltipquad[math.floor((self.timer+1)%2)+1], self.x+2*scale, self.y+10*scale, 0, scale, scale)
				end
			else
				love.graphics.draw(self.graphic, self.x+2*scale, self.y+10*scale, 0, scale, scale)
			end
		end
	end
end
