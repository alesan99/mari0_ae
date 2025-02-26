tilemoving = class:new()

function tilemoving:init(x, y, t)
	--Get Tile
	self.cox = x
	self.coy = y
	self.t = t or map[x][y][1]
	self.item = false
	if not t then
		if map[x][y][2] and ((entitylist[map[x][y][2]] and entitylist[map[x][y][2]].block and (tilequads[self.t]["breakable"] or (not tilequads[self.t]["breakable"]) and tilequads[self.t]["coinblock"]))
			or (tablecontains(customenemies, map[x][y][2]) and (tilequads[self.t]["breakable"] or tilequads[self.t]["coinblock"]))) then
			--item in block
			self.item = map[x][y][2]
			map[x][y][2] = nil
		end
		--firebar in block
		if map[x][y][2] and entitylist[map[x][y][2]] then
			local t = entitylist[map[x][y][2]].t
			if t == "castlefirecw" or t == "castlefireccw" or t == "rotodisc" or t == "boocircle" then
				local obj = spawnenemy(t, x, y, map[x][y], "spawner")
				self.firebar = obj
				obj.onmovingtile = true
				map[x][y][2] = nil
			elseif t == "longfire" then
				local obj = longfire:new(x, y, map[x][y][3])
				table.insert(objects["longfire"], obj)
				self.burner = obj
				obj.onmovingtile = true
				map[x][y][2] = nil
			elseif t == "longfireoff" then
				local obj = longfire:new(x, y, map[x][y][3], true)
				table.insert(objects["longfire"], obj)
				self.burner = obj
				obj.onmovingtile = true
				map[x][y][2] = nil
			end
		end

		objects["tile"][tilemap(x, y)] = nil
		map[x][y][1] = 1
	end

	--PHYSICS STUFF
	self.x = x-1
	self.y = y-1
	self.speedy = 0
	self.speedx = 0
	self.width = 1
	self.height = 1
	self.static = false
	self.active = true
	self.category = 2
	self.gravity = 0
	self.portalable = false
	
	self.mask = {true}
	self.dontchangetilemask = true
	
	self.extremeautodelete = true

	self.quad = tilequads[self.t].quad
	self.breakable = tilequads[self.t].breakable
	self.coinblock = tilequads[self.t].coinblock
	self.coin = tilequads[self.t].coin
	self.invisible = tilequads[self.t].invisible
	self.platform = tilequads[self.t].platform
	self.ice = tilequads[self.t].ice
	self.noteblock = tilequads[self.t].noteblock
	self.offsetX = 8
	self.offsetY = 0
	self.quadcenterX = 8
	self.quadcenterY = 8

	self.gels = {}

	self.bounce = false
	self.timer = 0
	self.blockbouncetimer = blockbouncetime
	
	self.rotation = 0 --for portals
	self.trackplatform = true
	self.trackplatformpush = true

	self.hardblock = (tilequads[self.t] and tilequads[self.t].debris)
	if self.platform then
		self.PLATFORM = true
	elseif self.invisible then
		self.PLATFORMDOWN = true
		self.trackplatform = false
		self.trackplatformpush = false
		self.hollow = true
	end
	if self.coin then
		self.trackplatform = false
		self.trackplatformpush = false
		self.noclearpipesound = true
	end

	self.moveobject = false
end

function tilemoving:update(dt)
	if self.delete then
		return true
	end

	--move items coming out of block
	if self.moveobject then
		if self.moveobject.delete then
			self.moveobject = nil
			if self.moveobjectitem then
				if not (self.moveobjectitem.static or self.moveobjectitem.movealongtrackblock) then
					self.moveobjectitem = nil
				else
					self.moveobject = self.moveobjectitem
					self.moveobjectitem = nil
					local syncobj = self.moveobject
					self.moveobjectoffsetx = syncobj.x-self.x
					self.moveobjectoffsety = syncobj.y-self.y
				end
			end
		else
			local obj = self.moveobject
			if self.moveobjectvine then
				obj.oldx = obj.x
				obj.oldy = obj.oy
				obj.x = self.x+self.moveobjectoffsetx
				--obj.y = self.y+self.moveobjectoffsety
				obj.ox = self.x+self.moveobjectoffsetox
				obj.oy = self.y+self.moveobjectoffsetoy
			else
				obj.x = self.x+self.moveobjectoffsetx
				obj.y = self.y+self.moveobjectoffsety
			end
		end
	end
	--move firebar on block
	if self.firebar then
		self.firebar.x = self.x+1
		self.firebar.y = self.y+1
	elseif self.burner then --move longfire on block
		local dir = self.burner.dir
		if dir == "right" then
			self.burner.x = self.x+1
		elseif dir == "left" then
			self.burner.x = self.x-self.burner.width
		else
			self.burner.x = self.x+.5-self.burner.width/2
		end
		if dir == "up" then
			self.burner.y = self.y-self.burner.height
		elseif dir == "down" then
			self.burner.y = self.y+1
		else
			self.burner.y = self.y+.5-self.burner.height/2
		end
	end

	self.leavemarioalone = (self.gels["top"] == 1 or self.noteblock)

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
end

function tilemoving:draw()
	if self.invisible then
		return false
	end
	if onscreen(self.x, self.y, self.width, self.height) then
		if self.customscissor then
			love.graphics.setScissor(math.floor((self.customscissor[1]-xscroll)*16*scale), math.floor((self.customscissor[2]-.5-yscroll)*16*scale), self.customscissor[3]*16*scale, self.customscissor[4]*16*scale)
		end
		if tilequads[self.t].coinblock and self.t < 90000 then --coinblock
			love.graphics.draw(coinblockimage, coinblockquads[spriteset][coinframe], math.floor(((self.x-xscroll)*16+self.offsetX)*scale), ((self.y-yscroll)*16-self.offsetY)*scale, 0, scale, scale, self.quadcenterX, self.quadcenterY)
		elseif tilequads[self.t].coin and self.t < 90000 then --coin
			love.graphics.draw(coinimage, coinquads[spriteset][coinframe], math.floor(((self.x-xscroll)*16+self.offsetX)*scale), ((self.y-yscroll)*16-self.offsetY)*scale, 0, scale, scale, self.quadcenterX, self.quadcenterY)
		else
			love.graphics.draw(tilequads[self.t].image, tilequads[self.t].quad, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), ((self.y-yscroll)*16-self.offsetY)*scale, 0, scale, scale, self.quadcenterX, self.quadcenterY)
		end

		for i = 1, 4 do
			local dir = "top"
			local r = 0
			if i == 2 then
				dir = "right"; r = math.pi/2
			elseif i == 3 then
				dir = "bottom"; r = math.pi
			elseif i == 4 then
				dir = "left"; r = math.pi*1.5
			end
			
			if self.gels[dir] == 1 then
				love.graphics.draw(gel1ground, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), ((self.y-yscroll)*16-self.offsetY)*scale, r, scale, scale, self.quadcenterX, self.quadcenterY)
			elseif self.gels[dir] == 2 then
				love.graphics.draw(gel2ground, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), ((self.y-yscroll)*16-self.offsetY)*scale, r, scale, scale, self.quadcenterX, self.quadcenterY)
			elseif self.gels[dir] == 3 then
				love.graphics.draw(gel3ground, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), ((self.y-yscroll)*16-self.offsetY)*scale, r, scale, scale, self.quadcenterX, self.quadcenterY)
			elseif self.gels[dir] == 4 then
				love.graphics.draw(gel4ground, math.floor(((self.x-xscroll)*16+self.offsetX)*scale), ((self.y-yscroll)*16-self.offsetY)*scale, r, scale, scale, self.quadcenterX, self.quadcenterY)
			end
		end

		love.graphics.setScissor()
	end
end

function tilemoving:hit(a, b, getbroken)
	if getbroken then
		self.getbroken = true
	end
	if a == "player" and (b.size == 8 or b.size == 16) then
		--big mario destroy
		self.getbroken = true
	end

	if self.coin then --collect coin tile
		addpoints(200)
		playsound(coinsound)
		mariocoincount = mariocoincount + (amount or 1)
		while mariocoincount >= 100 and (not nocoinlimit) do
			if mariolivecount ~= false then
				for i = 1, players do
					mariolives[i] = mariolives[i] + 1
					respawnplayers()
				end
			end
			mariocoincount = mariocoincount - 100
			playsound(oneupsound)
		end
		self.delete = true
		self.active = false
	elseif self.item and entitylist[self.item] and entitylist[self.item].t == "manycoins" and (not self.getbroken) then
		--block with many coins inside! yay $_$
		playsound(blockhitsound)
		playsound(coinsound)
		table.insert(coinblockanimations, coinblockanimation:new(self.x+1-0.5, self.y+1-1))
		mariocoincount = mariocoincount + 1
		if mariocoincount == 100 and (not nocoinlimit) then
			if mariolivecount ~= false then
				for i = 1, players do
					mariolives[i] = mariolives[i] + 1
					respawnplayers()
				end
			end
			mariocoincount = 0
			playsound(oneupsound)
		end
		addpoints(200)
		local exists = false
		for i = 1, #coinblocktimers do
			if self.cox == coinblocktimers[i][1] and self.coy == coinblocktimers[i][2] then
				exists = i
			end
		end
		if not exists then
			table.insert(coinblocktimers, {self.cox, self.coy, coinblocktime})
		elseif coinblocktimers[exists][3] <= 0 then
			self.item = false
			if not self.noteblock then
				if spriteset == 1 then
					self.t = 113
				elseif spriteset == 2 then
					self.t = 114
				elseif spriteset == 3 then
					self.t = 117
				else
					self.t = 113
				end
				self.coinblock = false
				self.breakable = false
				self.invisible = false
			end
		end
		self.blockbouncetimer = 0
	elseif (self.coinblock or self.item) and (not self.getbroken) then
		playsound(blockhitsound)
		--item block
		if self.item then
			local t
			local spawnitem = true
			if tablecontains(customenemies, self.item) then
				--custom enemy
				t = {"customenemy", self.item}
			elseif entitylist[self.item] then
				t = entitylist[self.item].t
			else --entity does not exist
				spawnitem = false
			end
			
			local syncobj
			if t == "vine" then
				syncobj = vine:new(self.x+1, self.y+1)
				syncobj.moving = true
				syncobj.maxlength = mapheight+1
				syncobj.blockscissor = false
				syncobj.vinestop = false
				playsound(vinesound)
				table.insert(objects["vine"], syncobj)
			end

			if spawnitem and t then
				local obj = spawnenemy(t, self.x+1, self.y, false, "spawner")

				if obj then
					if obj.static or obj.movealongtrackblock then
						--move flowers along with block
						self.moveobjectitem = obj
					end
					if obj.width and obj.height and (not obj.children) and (not obj.child) then
						syncobj = spawnanimation:new(self.x+1, self.y, "block", obj)
						table.insert(spawnanimations, syncobj)
					end
				end
				playsound(mushroomappearsound)
			end

			if syncobj and syncobj.x and syncobj.y then
				self.moveobject = syncobj
				if t == "vine" then
					self.moveobjectvine = true
					self.moveobjectoffsetx = syncobj.x-self.x
					self.moveobjectoffsety = syncobj.y-self.y
					self.moveobjectoffsetox = syncobj.ox-self.x
					self.moveobjectoffsetoy = syncobj.oy-self.y
				else
					self.moveobjectoffsetx = syncobj.x-self.x
					self.moveobjectoffsety = syncobj.y-self.y
				end
			end
		else
			playsound(coinsound)
			table.insert(coinblockanimations, coinblockanimation:new(self.x+1-0.5, self.y+1-1))
			mariocoincount = mariocoincount + 1
			if mariocoincount == 100 and (not nocoinlimit) then
				if mariolivecount ~= false then
					for i = 1, players do
						mariolives[i] = mariolives[i] + 1
						respawnplayers()
					end
				end
				mariocoincount = 0
				playsound(oneupsound)
			end
			addpoints(200)
		end
		if spriteset == 1 then
			self.t = 113
		elseif spriteset == 2 then
			self.t = 114
		elseif spriteset == 3 then
			self.t = 117
		else
			self.t = 113
		end

		self.coinblock = false
		self.item = false
		self.breakable = false
		self.invisible = false
		self.PLATFORMDOWN = false
		self.PLATFORMLEFT = false
		self.PLATFORMRIGHT = false
		self.blockbouncetimer = 0
		--self.trackable = false
		--self.static = true
		
		hitontop(self.x+1, self.y+1)
	elseif self.breakable or self.getbroken then
		playsound(blockhitsound)
		if ((not b.size) or b.size >= 2) then
			self:breakblock()
		else
			self.blockbouncetimer = 0
		end
	else
		playsound(blockhitsound)
	end
end

function tilemoving:breakblock(a, b)
	playsound(blockbreaksound)
	addpoints(50)
	local debris = tilequads[self.t].debris
	local x, y = self.x+1, self.y+1
	if debris and blockdebrisquads[debris] then
		table.insert(blockdebristable, blockdebris:new(x-.5, y-.5, 3.5, -23, blockdebrisimage, blockdebrisquads[debris][spriteset]))
		table.insert(blockdebristable, blockdebris:new(x-.5, y-.5, -3.5, -23, blockdebrisimage, blockdebrisquads[debris][spriteset]))
		table.insert(blockdebristable, blockdebris:new(x-.5, y-.5, 3.5, -14, blockdebrisimage, blockdebrisquads[debris][spriteset]))
		table.insert(blockdebristable, blockdebris:new(x-.5, y-.5, -3.5, -14, blockdebrisimage, blockdebrisquads[debris][spriteset]))
	else
		table.insert(blockdebristable, blockdebris:new(x-.5, y-.5, 3.5, -23))
		table.insert(blockdebristable, blockdebris:new(x-.5, y-.5, -3.5, -23))
		table.insert(blockdebristable, blockdebris:new(x-.5, y-.5, 3.5, -14))
		table.insert(blockdebristable, blockdebris:new(x-.5, y-.5, -3.5, -14))
	end
	self.delete = true
	self.active = false
	return true
end

function tilemoving:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "thwomp" or a == "skewer" or (a == "koopa" and b.small) then
		self:hit(a, b)
	end
	return false
end

function tilemoving:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "thwomp" or a == "skewer" or (a == "koopa" and b.small) then
		self:hit(a, b)
	end
	return false
end

function tilemoving:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if a == "thwomp" or a == "skewer" or a == "icicle" then
		self:hit(a, b)
	end
	return false
end

function tilemoving:globalcollide(a, b)
	if a == "tile" then
		return true
	end

	if (self.breakable or self.hardblock) and a == "player" and (b.size == 8 or b.size == 16) then
		--big mario destroy
		self:breakblock()
		return true
	end
end

function tilemoving:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if (a == "player" and b.gravitydir == "down") or a == "skewer" then
		self:hit(a, b)
	end
	return false
end

function tilemoving:passivecollide(a, b)
	if a == "player" and b.speedy < 0 and self.trackable then
		self:hit(a, b)
	end
	return false
end