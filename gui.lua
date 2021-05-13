guielement = class:new()

local android_key_repeat = false --bugfix: keep track of last pressed key to prevent glitchy keyboards from inputing letter twice

function guielement:init(...)
	local arg = {...}
	self.active = true
	self.priority = false
	if arg[1] == "checkbox" then --checkbox(x, y, func, start, text)
		self.type = arg[1]
		self.x = arg[2]
		self.y = arg[3]
		self.func = arg[4]
		if arg[5] or arg[5] == false then
			self.var = arg[5]
		else
			self.var = true
		end
		self.text = arg[6]
	elseif arg[1] == "dropdown" then --dropdown(x, y, width (in chars), func, start, {entries})
		self.type = arg[1]
		self.x = arg[2]
		self.y = arg[3]
		self.width = arg[4]
		self.func = arg[5]
		self.var = arg[6] or 1
		self.entries = {}
		for i = 7, #arg do
			table.insert(self.entries, arg[i])
		end
		--self.dropup = ((self.x+(10*#self.entries))(height*16))--the opposite direction so you can see all the options
		self.extended = false
		self.timer = 0--[DROID]

		self:updatePos()
	elseif arg[1] == "rightclick" then --rightclick(x, y, width (in chars), func, start, {entries})
		self.type = arg[1]
		self.x = arg[2]
		self.y = arg[3]
		self.width = arg[4]
		self.func = arg[5]
		self.var = arg[6] or nil
		self.entries = {}
		for i = 7, #arg do
			table.insert(self.entries, arg[i])
		end
		self.priority = true
		
		if self.y+10*#self.entries > height*16 then
			self.direction = "up"
		else
			self.direction = "down"
		end
		self:updatePos()
	elseif arg[1] == "button" then --button(x, y, text, func, space, arguments (in a table), height (in lines), width, center text)
		self.type = arg[1]
		self.x = arg[2]
		self.y = arg[3]
		self.text = arg[4]
		self.func = arg[5]
		self.space = arg[6] or 0
		if type(arg[7]) ~= "table" then
			self.arguments = {}
		else
			self.arguments = arg[7]
		end
		self.height = arg[8] or 1
		self.width = arg[9] or utf8.len(self.text)*8
		if arg[10] and tonumber(arg[10]) then
			self.autorepeat = arg[10] or false
			self.repeatwait = 0.3
			self.repeatdelay = arg[10] or 0.05
		else
			self.centertext = arg[10]
		end
		
		self.bordercolorhigh = {255, 255, 255}
		self.bordercolor = {127, 127, 127}
		
		self.fillcolor = {0, 0, 0}
		self.textcolor = {255, 255, 255}
	elseif arg[1] == "scrollbar" then --scrollbar(x, y, yrange, width, height, start, dir)
		self.type = arg[1]
		self.x = arg[2]
		self.y = arg[3]
		self.range = arg[4]
		self.width = arg[5]
		self.height = arg[6]
		self.value = arg[7] or 0
		self.dir = arg[8] or "ver"
		
		if self.dir == "ver" then
			self.yrange = self.range - self.height
		else
			self.xrange = self.range - self.width
		end	
		
		self.backgroundcolor = {127, 127, 127}
		self.bordercolorhigh = {255, 255, 255}
		self.bordercolor = {127, 127, 127}
		
		self.fillcolor = {0, 0, 0}

		self.displayfunction = false
	elseif arg[1] == "input" then --input(x, y, width, enterfunc, start, maxlength, rightclick, height, extra, spacing)
		self.type = arg[1]
		self.x = arg[2]
		self.y = arg[3]
		self.width = arg[4]
		self.func = arg[5]
		self.value = tostring(arg[6]) or ""
		self.maxlength = arg[7] or 0
		self.height = arg[8] or 1
		self.extra = arg[9] or "none"
		self.spacing = arg[10] or 1
		
		self.timer = 0
		self.cursorblink = true
		self.inputting = false
		self.cursorpos = string.len(self.value)+1
		self.offset = 0
		self.textoffset = 0
		
		self.bordercolorhigh = {255, 255, 255}
		self.bordercolor = {127, 127, 127}
		
		self.fillcolor = {0, 0, 0}
		self.textcolor = {255, 255, 255}
		
		self:updatePos()
		--[[while string.len(self.value)-self.textoffset > self.width-1 and self.width ~= 1 and self.width ~= self.maxlength do
			self.textoffset = self.textoffset + 1
		end]]
	elseif arg[1] == "text" then --text(x, y, text, color)
		self.type = arg[1]
		self.x = arg[2]
		self.y = arg[3]
		self.text = arg[4]
		self.color = arg[5]
	end
end

function guielement:update(dt)
	if self.active then
		if self.type == "scrollbar" then
			if self.dragging then
				if self.dir == "ver" then
					local y = (love.mouse.getY()-self.draggingy) - self.y*scale
					local actualyrange = self.yrange*scale
					
					self.value = math.min(math.max(y / actualyrange, 0), 1) --clamp
				else
					local x = (love.mouse.getX()-self.draggingx) - self.x*scale
					local actualxrange = self.xrange*scale
					
					self.value = math.min(math.max(x / actualxrange, 0), 1) --clamp
				end
				if self.updatefunc then
					self:updatefunc(self.value)
				end
			end
		elseif self.type == "input" then
			self.timer = self.timer + dt
			while self.timer > blinktime do
				self.cursorblink = not self.cursorblink
				self.timer = self.timer - blinktime
			end
			if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
				self.shift = true
			else
				self.shift = false
			end

			--drag number without typing
			if self.numdraggingstart then
				local dx = (love.mouse.getX()-self.oldmousex)/scale
				if math.abs(dx) > 2 then
					--start dragging number
					self.numdragging = true
					self.numdraggingstart = false
					self.inputting = false
				end
				--self.oldmousex, self.oldmousey = love.mouse.getPosition()
			end
			if self.numdragging then
				local dx = (love.mouse.getX()-self.oldmousex)/scale
				local add = math.ceil(dx*2)
				if dx < 0 then
					add = math.floor(dx*2)
				end
				self.value = math.max(self.numdrag[1], math.min(self.numdrag[2], tonumber(self.value) + add))
				self:func()
				self.oldmousex, self.oldmousey = love.mouse.getPosition()
			end
			
			--[[DROID]]
			if android then
				android_key_repeat = false
			end
		elseif self.type == "button" then
			if self.autorepeat then
				if self.holding then
					if self.repeatwaittimer <= 0 then
						self.repeatdelaytimer = self.repeatdelaytimer - dt
						while self.repeatdelaytimer <= 0 do
							if self.func then
								self.func(unpack(self.arguments))
							end
							self.repeatdelaytimer = self.repeatdelaytimer + self.repeatdelay
						end
					else
						self.repeatwaittimer = self.repeatwaittimer - dt
					end
				else
					self.repeatwaittimer = self.repeatwait
					self.repeatdelaytimer = self.repeatdelay
				end
			end
		elseif self.type == "dropdown" then
			if self.scrollbar then
				self.scrollbar:update(dt)
				self.scroll = self.scrollbar.value*(((#self.entries+1)*10)-(height*16)+1)
			end
			if self.multiy then
				if self.extended and not self.dropup then
					self.y = self.multiy[2]
				else
					self.y = self.multiy[1]
				end
			end
			--[DROID]
			if self.timer and self.timer > 0 then
				self.timer = self.timer - dt
			end
		end
	end
end

function guielement:draw(a, offx, offy)
	love.graphics.setColor(255, 255, 255)
	if self.type == "checkbox" then
		local quad = 1
		if self.var == true then
			quad = 2
		end
		local high = 1
		if self:inhighlight(love.mouse.getPosition()) then
			high = 2
		end
		
		love.graphics.draw(checkboximg, checkboxquad[high][quad], self.x*scale, self.y*scale, 0, scale, scale)
		
		if self.text then
			properprintF(self.text, (self.x+10)*scale, (self.y+1)*scale)
		end
	elseif self.type == "dropdown" then
		local high = self:inhighlight(love.mouse.getPosition())
		
		if self.extended and not self.cutoff then
			love.graphics.setColor(127, 127, 127)
			local y = self.y
			if self.dropup then
				y = (self.y-(10*#self.entries))
			end
			love.graphics.rectangle("fill", (self.x+2)*scale, (y+2)*scale, (13+self.width*8)*scale, (10*(#self.entries+1)+1)*scale)
		end
	
		love.graphics.setColor(127, 127, 127)
		if high then
			love.graphics.setColor(255, 255, 255)
		end
		
		love.graphics.rectangle("fill", self.x*scale, self.y*scale, (3+self.width*8)*scale, 11*scale)
		if self.dropup then
			love.graphics.draw(dropdownarrowimg, (self.x+2+self.width*8)*scale, (self.y+11)*scale, 0, scale, -scale)
		else
			love.graphics.draw(dropdownarrowimg, (self.x+2+self.width*8)*scale, self.y*scale, 0, scale, scale)
		end
		
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", (self.x+1)*scale, (self.y+1)*scale, (1+self.width*8)*scale, 9*scale)
		
		love.graphics.setColor(255, 255, 255)
		if self.extended then
			love.graphics.setColor(127, 127, 127)
		end
			
		local s = self.entries[self.var]
		if self.displayentries then s = self.displayentries[self.var];
			if s and s:sub(1, 6) == "_ENEMY" then s = " " .. s:sub(7, -1); love.graphics.draw(customenemyiconimg, (self.x+1)*scale, (self.y+2)*scale, 0, scale, scale) end end
		if type(s) == "string" then s = s:sub(1, self.width) end
		properprint(s, (self.x+1)*scale, (self.y+2)*scale)
	
		if self.extended then
			love.graphics.setColor(127, 127, 127)
			if high then
				love.graphics.setColor(255, 255, 255)
			end
			
			if self.cutoff then --have a scrollbar
				love.graphics.rectangle("fill", self.x*scale, -self.scroll*scale, (13+self.width*8)*scale, (10*(#self.entries+1)+1)*scale)
				
				love.graphics.setColor(127, 127, 127)
				if high then
					love.graphics.setColor(255, 255, 255)
				end
				love.graphics.draw(dropdownarrowimg, (self.x+2+self.width*8)*scale,-self.scroll*scale, 0, scale, scale)
				love.graphics.setColor(0, 0, 0)
				love.graphics.rectangle("fill", (self.x+1)*scale, (-self.scroll+1)*scale, (1+self.width*8)*scale, 9*scale)
				love.graphics.setColor(255, 255, 255)
				if self.extended then
					love.graphics.setColor(127, 127, 127)
				end
				local s = self.entries[self.var]
				if self.displayentries then s = self.displayentries[self.var];
					if s and s:sub(1, 6) == "_ENEMY" then s = " " .. s:sub(7, -1); love.graphics.draw(customenemyiconimg, (self.x+1)*scale, (-self.scroll+2)*scale, 0, scale, scale) end end
				if type(s) == "string" then s = s:sub(1, self.width) end
				properprint(s, (self.x+1)*scale, (-self.scroll+2)*scale)
				
				love.graphics.setColor(127, 127, 127)
				if high then
					love.graphics.setColor(255, 255, 255)
				end
				
				for i = 1, #self.entries do
					local y = ((2+10*i)-self.scroll)
					if y+10*scale > 0 and y < height*16 then
						if high ~= i then
							love.graphics.setColor(0, 0, 0)
							love.graphics.rectangle("fill", (self.x+1)*scale, ((1+i*10)-self.scroll)*scale, (11+self.width*8)*scale, 9*scale)
							love.graphics.setColor(255, 255, 255)
									
							local s = self.entries[i]
							if self.displayentries then s = self.displayentries[i];
								if s:sub(1, 6) == "_ENEMY" then s = " " .. s:sub(7, -1); love.graphics.draw(customenemyiconimg, (self.x+1)*scale, ((2+10*i)-self.scroll)*scale, 0, scale, scale) end end
							if type(s) == "string" then s = s:sub(1, self.width+1) end
							properprint(s, (self.x+1)*scale, y*scale)
						else
							love.graphics.setColor(0, 0, 0)
							local s = self.entries[i]
							if self.displayentries then s = self.displayentries[i];
								if s:sub(1, 6) == "_ENEMY" then s = " " .. s:sub(7, -1); love.graphics.draw(customenemyiconimg, (self.x+1)*scale, ((2+10*i)-self.scroll)*scale, 0, scale, scale) end end
							if type(s) == "string" then s = s:sub(1, self.width+1) end
							properprint(s, (self.x+1)*scale, y*scale)
						end
					end
				end
				
				self.scrollbar:draw()
			elseif self.dropup then
				love.graphics.rectangle("fill", self.x*scale, (self.y-(10*#self.entries))*scale, (13+self.width*8)*scale, (10*#self.entries)*scale)
				
				for i = 1, #self.entries do
					if high ~= i then
						love.graphics.setColor(0, 0, 0)
						love.graphics.rectangle("fill", (self.x+1)*scale, ((self.y+2+i*10)-(11+(10*#self.entries)))*scale, (11+self.width*8)*scale, 9*scale)
						love.graphics.setColor(255, 255, 255)
						local s = self.entries[i]
						if self.displayentries then s = self.displayentries[i] end
						if type(s) == "string" then s = s:sub(1, self.width+1) end
						properprint(s, (self.x+1)*scale, ((self.y+3+10*i)-(11+(10*#self.entries)))*scale)
					else
						love.graphics.setColor(0, 0, 0)
						local s = self.entries[i]
						if self.displayentries then s = self.displayentries[i] end
						if type(s) == "string" then s = s:sub(1, self.width+1) end
						properprint(s, (self.x+1)*scale, ((self.y+3+10*i)-(11+(10*#self.entries)))*scale)
					end
				end
			else
				love.graphics.rectangle("fill", self.x*scale, (self.y+11)*scale, (13+self.width*8)*scale, (10*#self.entries)*scale)
				
				for i = 1, #self.entries do
					if high ~= i then
						love.graphics.setColor(0, 0, 0)
						love.graphics.rectangle("fill", (self.x+1)*scale, (self.y+1+i*10)*scale, (11+self.width*8)*scale, 9*scale)
						love.graphics.setColor(255, 255, 255)
						local s = self.entries[i]
						if self.coloredtext then
							if s == "black" then
								love.graphics.setColor(80,80,80)
							else
								love.graphics.setColor(textcolors[s])
							end
						end
						if self.displayentries then s = self.displayentries[i] end
						if type(s) == "string" then s = s:sub(1, self.width+1) end
						properprint(s, (self.x+1)*scale, (self.y+2+10*i)*scale)
					else
						love.graphics.setColor(0, 0, 0)
						local s = self.entries[i]
						if self.displayentries then s = self.displayentries[i] end
						if type(s) == "string" then s = s:sub(1, self.width+1) end
						properprint(s, (self.x+1)*scale, (self.y+2+10*i)*scale)
					end
				end
			end
		end
	elseif self.type == "rightclick" then
		local high = self:inhighlight(love.mouse.getPosition())
	
		love.graphics.setColor(255, 255, 255)
		
		love.graphics.rectangle("fill", self.x*scale, self.y*scale, (3+self.width*8)*scale, 11*scale)
		
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", (self.x+1)*scale, (self.y+1)*scale, (1+self.width*8)*scale, 9*scale)
		
		love.graphics.setColor(180, 180, 180)
			
		properprint(self.entries[1], (self.x+1)*scale, (self.y+2)*scale)
	
		love.graphics.setColor(127, 127, 127)
		if high then
			love.graphics.setColor(255, 255, 255)
		end
		
		if self.direction == "down" then
			love.graphics.rectangle("fill", self.x*scale, (self.y+11)*scale, (3+self.width*8)*scale, (10*(#self.entries-1))*scale)
		else
			love.graphics.rectangle("fill", self.x*scale, (self.y+10-(#self.entries)*10)*scale, (3+self.width*8)*scale, (10*(#self.entries-1))*scale)
		end
		
		for i = 2, #self.entries do
			if high ~= i then
				if ((not self.trustWhatStartWasSetAs) and self.var == self.entries[i]) or (self.trustWhatStartWasSetAs and i == self.var) then
					love.graphics.setColor(0, 127, 0)
				else
					love.graphics.setColor(0, 0, 0)
				end
				if self.direction == "down" then
					love.graphics.rectangle("fill", (self.x+1)*scale, (self.y+1+(i-1)*10)*scale, (1+self.width*8)*scale, 9*scale)
					love.graphics.setColor(255, 255, 255)
					properprint(self.entries[i], (self.x+1)*scale, (self.y+2+10*(i-1))*scale)
				else
					love.graphics.rectangle("fill", (self.x+1)*scale, (self.y+1-(i-1)*10)*scale, (1+self.width*8)*scale, 9*scale)
					love.graphics.setColor(255, 255, 255)
					properprint(self.entries[i], (self.x+1)*scale, (self.y+2-10*(i-1))*scale)
				end
			else
				if self.var == self.entries[i] then
					love.graphics.setColor(0, 127, 0)
				else
					love.graphics.setColor(0, 0, 0)
				end
				
				if self.direction == "down" then
					properprint(self.entries[i], (self.x+1)*scale, (self.y+2+10*(i-1))*scale)
				else
					properprint(self.entries[i], (self.x+1)*scale, (self.y+2-10*(i-1))*scale)
				end
			end
		end
	elseif self.type == "button" then
		local high = self:inhighlight(love.mouse.getPosition())
	
		love.graphics.setColor(self.bordercolor)
		if high then
			love.graphics.setColor(self.bordercolorhigh)
		end
		
		love.graphics.rectangle("fill", self.x*scale, self.y*scale, (3+self.width+self.space*2)*scale, (1+self.height*10+self.space*2)*scale)
		
		love.graphics.setColor(self.fillcolor)
		love.graphics.rectangle("fill", (self.x+1)*scale, (self.y+1)*scale, (1+self.width+self.space*2)*scale, (-1+self.height*10+self.space*2)*scale)

		if self.image then
			if self.imagecolor then
				love.graphics.setColor(self.imagecolor)
			else
				love.graphics.setColor(255,255,255)
			end
			love.graphics.draw(self.image, (self.x+self.imageoffsetx)*scale, (self.y+self.imageoffsety)*scale, 0, scale, scale)
		end
		
		love.graphics.setColor(self.textcolor)
		if type(self.text) == "table" then
			love.graphics.draw(self.text[1], self.text[2], (self.x+2+self.space)*scale, (self.y+2+self.space)*scale, 0, scale, scale)
		else
			if self.centertext then
				if self.image then
					properprintFbackground(self.text, math.floor((self.x+(self.width/2)-(utf8.len(self.text)*4))*scale), math.floor((self.y+((self.height*10)/2)-3)*scale))
				else
					if utf8.len(self.text) ~= string.len(self.text) then
						properprintF(self.text, math.floor((self.x+(self.width/2)-(utf8.len(self.text)*4))*scale), math.floor((self.y+((self.height*10)/2)-3)*scale))
					else
						properprint(self.text, math.floor((self.x+(self.width/2)-(utf8.len(self.text)*4))*scale), math.floor((self.y+((self.height*10)/2)-3)*scale))
					end
				end
			else
				properprintF(self.text, (self.x+1+self.space)*scale, (self.y+2+self.space)*scale)
			end
		end
		
	elseif self.type == "scrollbar" then
		if self.dir == "ver" then
			local high = self:inhighlight(love.mouse.getPosition())
			
			love.graphics.setColor(self.backgroundcolor)
			love.graphics.rectangle("fill", self.x*scale, self.y*scale, self.width*scale, (self.yrange+self.height)*scale)
		
			love.graphics.setColor(self.bordercolor)
			if self.dragging or high then
				love.graphics.setColor(self.bordercolorhigh)
			end
			
			love.graphics.rectangle("fill", self.x*scale, (self.y+self.yrange*self.value)*scale, (self.width)*scale, (self.height)*scale)
			
			love.graphics.setColor(self.fillcolor)
			love.graphics.rectangle("fill", (self.x+1)*scale, (self.y+1+self.yrange*self.value)*scale, (self.width-2)*scale, (self.height-2)*scale)
		else
			local high = self:inhighlight(love.mouse.getPosition())
			
			love.graphics.setColor(self.backgroundcolor)
			love.graphics.rectangle("fill", self.x*scale, self.y*scale, (self.xrange+self.width)*scale, self.height*scale)
		
			love.graphics.setColor(self.bordercolor)
			if self.dragging or high then
				love.graphics.setColor(self.bordercolorhigh)
			end
			
			love.graphics.rectangle("fill", (self.x+self.xrange*self.value)*scale, self.y*scale, (self.width)*scale, (self.height)*scale)
			
			love.graphics.setColor(self.fillcolor)
			love.graphics.rectangle("fill", (self.x+1+self.xrange*self.value)*scale, (self.y+1)*scale, (self.width-2)*scale, (self.height-2)*scale)

			if self.displayfunction then
				love.graphics.setColor(self.bordercolorhigh)
				local s = self.displayfunction(self.value)
				properprint(s, (self.x+self.xrange*self.value)*scale, (self.y+math.ceil((self.height-8)/2))*scale)
			end
		end
	elseif self.type == "input" then
		local high = self:inhighlight(love.mouse.getPosition())
	
		love.graphics.setColor(self.bordercolor)
		if self.inputting or high then
			love.graphics.setColor(self.bordercolorhigh)
		end
		
		love.graphics.rectangle("fill", self.x*scale, self.y*scale, (3+self.width*8+2*self.spacing)*scale, (1+self.height*10+2*self.spacing)*scale)
		
		love.graphics.setColor(self.fillcolor)
		love.graphics.rectangle("fill", (self.x+1)*scale, (self.y+1)*scale, (1+self.width*8+2*self.spacing)*scale, (-1+self.height*10+2*self.spacing)*scale)
		
		love.graphics.setColor(self.textcolor)
		--format string
		local oldstring = self.value--string.sub(self.value, self.textoffset+1, self.textoffset+self.width)  --old offsets
		local newstring = {}
		for i = 1, string.len(oldstring), self.width do
			if math.ceil(i/self.width) > self.height then
				break
			end
			table.insert(newstring, string.sub(oldstring, i, i+self.width-1))
		end
		
		if self.height == 1 then
			local s = tostring(self.value)
			properprint(s:sub(self.textoffset+1, self.textoffset+self.width), (self.x+1+self.spacing)*scale, (self.y+2+self.spacing)*scale)
		else
			for i = 1, #newstring do
				properprint(newstring[i], (self.x+2)*scale, (self.y+2+self.spacing+(i-1)*10)*scale)
			end
		end
		
		--cursor
		if self.inputting and self.cursorblink then
			local x, y = math.ceil((self.cursorpos-1-self.textoffset) % self.width)+1, math.min(math.ceil(self.cursorpos/self.width), self.height) --bookmark
			
			if (self.cursorpos == self.maxlength+1) and (self.height > 1 or self.width >= self.maxlength) then
				x = self.width+1
			end
			--print(x)
			love.graphics.rectangle("fill", (self.x+1+self.spacing+(x-1)*8)*scale, (self.y+2+self.spacing+(y-1)*10)*scale, 1*scale, 7*scale)
		end
		if self.width >= self.maxlength or self.height > 1 then
			self.textoffset = 0
		end
	elseif self.type == "text" then
		love.graphics.setColor(self.color)
		properprint(self.text, self.x*scale, self.y*scale)
	end
	love.graphics.setColor(255, 255, 255)
end

function guielement:click(x, y, button)
	if self.active then
		if self.type == "checkbox" then
			if self:inhighlight(x, y) and button ~= "wd" and button ~= "wu" then
				self.func(not self.var)
			end
		elseif self.type == "dropdown" then
			if self.extended == false then
				if self:inhighlight(x, y) and button ~= "wd" and button ~= "wu" then
					self:updatePos()
					self.extended = true
					self.priority = true
					if self.scrollbar then
						self.scrollbar.active = true
					end
					self.timer = 0.1--[DROID]
				end
			elseif (not android) or self.timer <= 0 then--[DROID]
				if self.scrollbar then
					self.scrollbar:click(x, y, button)
					if x > (self.x+(13+self.width*8))*scale and x < (self.x+(13+self.width*8)+8)*scale then
						return true
					end
				end
				
				if button ~= "wu" and button ~= "wd" then
					local high = self:inhighlight(x, y)
					self.extended = false
					self.priority = false
					if self.scrollbar then
						self.scrollbar.active = false
					end
					
					if high then
						if high ~= 0 then
							self.func(high)
						end
						return true
					end
				end
			end
		elseif self.type == "rightclick" then
			local high = self:inhighlight(x, y)
			
			if high then
				if high ~= 0 then
					self.func(high)
				end
				return true
			end
		elseif self.type == "button" then
			if button ~= "wd" and button ~= "wu" and button ~= "r" then
				if self:inhighlight(x, y) then
					self.holding = true
					if self.func then
						self.func(unpack(self.arguments))
						return true
					end
				end
			end
		elseif self.type == "scrollbar" then
			if button ~= "wd" and button ~= "wu" then
				if self.dir == "ver" then
					if self:inhighlight(x, y) then
						self.dragging = true
						self.draggingy = y-(self.y+self.yrange*self.value)*scale
					end
				else
					if self:inhighlight(x, y) then
						self.dragging = true
						self.draggingx = x-(self.x+self.xrange*self.value)*scale
					end
				end
			end
			if not self.scrollstepdisabled then
				if button == "wd" then
					self.value = math.min(1, self.value+(self.scrollstep or 0.2))
				elseif button == "wu" then
					self.value = math.max(0, self.value-(self.scrollstep or 0.2))
				end
			end
		elseif self.type == "input" then
			if button ~= "wd" and button ~= "wu" then
				if self:inhighlight(x, y) then
					self.inputting = true
					self.cursorpos = math.max(math.min(round(((love.mouse.getX()/scale-self.x)+6.5)/8) + self.textoffset + math.max((math.min(math.ceil(((love.mouse.getY()/scale-self.y)-1)/10),self.height)-1)*self.width,0), #self.value+1),0) --bookmark
					self.timer = 0
					self.cursorblink = true
					if self.numdrag and (not android) and tonumber(self.value) then
						self.numdraggingstart = true
						self.oldmousex, self.oldmousey = love.mouse.getPosition()
						if not android then
							love.mouse.setCursor(mousecursor_sizewe)
						end
					end
					if android then
						love.keyboard.setTextInput(true, self.x*scale, self.y*scale, (3+self.width*8+2)*scale, (1+self.height*10+2)*scale) --[DROID]
					end
					love.keyboard.setKeyRepeat(true)
				else
					if self.inputting then
						love.keyboard.setKeyRepeat(false)
					end
					self.inputting = false
				end
			end
		end
	end
end

function guielement:keypress(key)
	if self.active then
		if self.type == "input" then
			if self.inputting then
				--[[DROID]]
				if android then
					if android_key_repeat == key then
						return
					end
					android_key_repeat = key
				end

				if key == ":" or key == ";" then
					return
				elseif key == "," and (not self.bypassspecialcharacters) then
					key = "A"
				elseif key == "-" and (not self.bypassspecialcharacters) then
					key = "B"
				end
				if key == "escape" and not android then
					self.inputting = false
					love.keyboard.setKeyRepeat(false)
				elseif (key == "return" or key == "enter" or key == "kpenter") or (android and key == "escape") then
					if self.func then
						if self.extra == "music" then
							changemusic(musici)
							self.inputting = false
							love.keyboard.setKeyRepeat(false)
							if android then
								love.keyboard.setTextInput(false)--[DROID]
							end
						elseif self.extra == "rightclick" then
							self.func(self.value)
							self.inputting = false
							love.keyboard.setKeyRepeat(false)
							if android then
								love.keyboard.setTextInput(false)--[DROID]
							end
						else
							self:func()
						end
					else
						self.inputting = false
						love.keyboard.setKeyRepeat(false)
						if android then
							love.keyboard.setTextInput(false)--[DROID]
						end
					end
				elseif key == "left" then --bookmark
					self.cursorpos = math.max(1, self.cursorpos - 1)
					if self.cursorpos-1 <= self.textoffset then
						self.textoffset = math.max(self.textoffset - 1, 0)
					end
					self.cursorblink = true
					self.timer = 0

					print(self.cursorpos)
					print(self.textoffset)
					print("")
				elseif key == "right" then
					self.cursorpos = math.min(#self.value + 1, self.cursorpos + 1)
					if self.cursorpos-1 >= self.textoffset+self.width then
						self.textoffset = math.min(self.textoffset + 1, self.maxlength - self.width)
					end
					self.cursorblink = true
					self.timer = 0

					print(self.cursorpos)
					print(self.textoffset)
					print("")
				elseif key == "up" and self.height > 1 then
					self.cursorpos = math.max(1, self.cursorpos - self.width)
					self.cursorblink = true
					self.timer = 0

					print(self.cursorpos)
					print(self.textoffset)
					print("")
				elseif key == "down" and self.height > 1 then
					self.cursorpos = math.min(#self.value + 1, self.cursorpos + self.width)
					self.cursorblink = true
					self.timer = 0

					print(self.cursorpos)
					print(self.textoffset)
					print("")
				elseif key == "backspace" then
					self.value = self.value:sub(1,self.cursorpos-2)..self.value:sub(self.cursorpos) --self.value = string.sub(self.value, 1, string.len(self.value)-1)

					if self.cursorpos > 1 then --and self.cursorpos > string.len(self.value)+1 then
						self.cursorpos = self.cursorpos - 1
					end

					self.textoffset = math.max(self.textoffset - 1, 0)

					self.cursorblink = true
					self.timer = 0
				else
					if string.len(self.value) < self.maxlength or self.maxlength == 0 then
						local found = false
						local targetkey = key
						
						if self.shift then
							if key == "1" then
								targetkey = "!"
							elseif key == "2" then
								targetkey = "@"
							elseif key == "3" then
								targetkey = "#"
							elseif key == "4" then
								targetkey = "^"
							elseif key == "5" then
								targetkey = "%"
							elseif key == "7" then
								targetkey = "&"
							elseif key == "8" then
								targetkey = "*"
							elseif key == "9" then
								targetkey = "("
							elseif key == "0" then
								targetkey = ")"
							elseif key == "/" then
								targetkey = "?"
							elseif key == "]" then
								targetkey = "}"
							elseif key == "[" then
								targetkey = "{"
							elseif key == "-" then
								targetkey = "_"
							elseif key == "=" then
								targetkey = "+"
							elseif key == "B" and not self.bypassspecialcharacters then
								targetkey = "_"
							end
						end
						
						found = (targetkey == " ")
						if not found then
							for char, quad in pairs(fontquads) do
								if targetkey == char then
									found = true
									break
								end
							end
						end
						
						if found then
							self.value = self.value:sub(1,self.cursorpos-1)..targetkey..self.value:sub(self.cursorpos)
							if self.cursorpos <= self.maxlength then
								self.cursorpos = self.cursorpos + 1
							end
							if self.cursorpos > self.textoffset+self.width then  --old offsets
								self.textoffset = self.textoffset + 1  --old offsets
							end
							self.cursorblink = true
							self.timer = 0

							print(self.cursorpos)
							print(self.textoffset)
							print("")
						end
					end
				end
				
				return true
			end
		end
	end
end

function guielement:unclick(x, y)
	if self.active then
		if self.type == "input" then
			if self.numdrag then
				self.numdraggingstart = false
				self.numdragging = false
				if not android then
					love.mouse.setCursor()
				end
			end
		elseif self.type == "scrollbar" then
			self.dragging = false
		elseif self.type == "dropdown" then
			if self.scrollbar then
				self.scrollbar:unclick(x, y)
			end
		elseif self.type == "button" then
			self.holding = false
		end
	end
end

function guielement:inhighlight(x, y)
	if self.type == "checkbox" then
		local xadd = 0
		if self.text then
			xadd = utf8.len(self.text)*8+1
		end
		if x >= self.x*scale and x < (self.x+9+xadd)*scale and y >= self.y*scale and y < (self.y+9)*scale then
			return true
		end
	elseif self.type == "dropdown" then
		if self.extended == false then
			if x >= self.x*scale and x < (self.x+13+self.width*8)*scale and y >= self.y*scale and y < (self.y+11)*scale then
				return true
			end
		else
			if self.cutoff then
				if x >= self.x*scale and x < (self.x+13+self.width*8)*scale and y >= -self.scroll*scale and y < ((10*#self.entries+11)-self.scroll)*scale then
					--get which entry
					return math.max(0, math.min(#self.entries, math.floor((y+self.scroll*scale) / (10*scale))))
				end
			elseif self.dropup then
				--(11+))
				if x >= self.x*scale and x < (self.x+13+self.width*8)*scale and y >= (self.y-(10*#self.entries))*scale and y < (self.y+11)*scale then
					--get which entry
					local i = math.max(0, math.floor((y-(self.y-10-(10*#self.entries))*scale) / (10*scale)))
					if i > #self.entries then
						i = 0
					end
					return i
				end
			else
				if x >= self.x*scale and x < (self.x+13+self.width*8)*scale and y >= self.y*scale and y < (self.y+10*#self.entries+11)*scale then
					--get which entry
					return math.max(0, math.floor((y-(self.y+1)*scale) / (10*scale)))
				end
			end
		end
	elseif self.type == "rightclick" then
		if self.direction == "down" then
			if x > self.x*scale and x < (self.x+3+self.width*8)*scale and y >= self.y*scale and y < (self.y+10*#self.entries+1)*scale then
				--get which entry
				return math.max(0, math.floor((y-(self.y+1)*scale) / (10*scale))+1)
			end
		else
			if x > self.x*scale and x < (self.x+3+self.width*8)*scale and y >= (self.y-10*(#self.entries-1))*scale and y < (self.y+11)*scale then
				--get which entry
				return math.max(0, math.floor((self.y*scale-y) / (10*scale))+2)
			end
		end
	elseif self.type == "button" then
		if self.clickswithinyrange and (y < self.clickswithinyrange[1]*scale or y > self.clickswithinyrange[2]*scale) then
			--ignore clicks outside y range
			return false
		end
		if x >= self.x*scale and x < (self.x+3+self.width+self.space*2)*scale and y >= self.y*scale and y < (self.y+1+self.height*10+self.space*2)*scale then
			return true
		end
	elseif self.type == "scrollbar" then
		if self.dir == "ver" then
			if x >= self.x*scale and x < (self.x+self.width)*scale and y >= (self.y+self.yrange*self.value)*scale and y < (self.height+self.y+self.yrange*self.value)*scale then
				return true
			end
		else
			if x >= (self.x+self.xrange*self.value)*scale and x < (self.x+self.width+self.xrange*self.value)*scale and y >= self.y*scale and y < (self.height+self.y)*scale then
				return true
			end
		end
	elseif self.type == "input" then
		if x >= self.x*scale and x < (self.x+3+self.width*8+2*self.spacing)*scale and y >= self.y*scale and y < (self.y+1+self.height*10+2*self.spacing)*scale then
			return true
		end
	end
	
	return false
end

function guielement:updatePos()
	if self.type == "dropdown" then
		if 10*(#self.entries+1) > height*16 then
			local yrange = (((#self.entries+1)*10)-(height*16)+1)
			self.cutoff = true
			self.scroll = 0
			self.scrollbar = guielement:new("scrollbar", self.x+(self.width*8+13), 0, height*16, 8, 40, 0, "ver")
			self.scrollbar.active = false
			self.scrollbar.yrange = self.scrollbar.yrange + self.scrollbar.height
			self.scrollbar.height = math.max(30, math.min(1, (height*16)/(yrange+(height*16)))*(height*16))
			self.scrollbar.yrange = self.scrollbar.yrange - self.scrollbar.height
			self.scrollbar.scrollstep = math.max(0.0001, 73/yrange)
		end
		if not self.cutoff and self.y+10*(#self.entries+1) > height*16 then
			self.multiy = {self.y, height*16-(10*(#self.entries+1))}
		else
			self.multiy = false
		end
	elseif self.type == "rightclick" then
		if self.direction == "up" and self.y-#self.entries*10-10 < 0 then
			self.y = #self.entries*10-10
		elseif self.direction == "down" and self.y+#self.entries*10 > height*16 then
			self.y = math.max(0, height*16-(#self.entries*10))
		end
		
		if self.x+self.width*8 > width*16 then
			self.x = (width*16)-self.width*8
		end
	elseif self.type == "input" then
		self.textoffset = 0
		while string.len(self.value)-self.textoffset > self.width-1 and self.width ~= 1 and self.width ~= self.maxlength do
			self.textoffset = self.textoffset + 1
		end
	end
end
