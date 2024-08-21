track = class:new()

function track:init(x, y, r, switch)
	--path
	self.cox = x
	self.coy = y

	self.switch = switch
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)

	local paths = 1
	if self.switch then --switch tracks have to store two alternate paths
		paths = 2
		
		self.timer = 0
		self.color = 1
	end

	self.path = {}
	for path = 1, paths do
		self.path[path] = {}
	end
	self.activepath = 1

	self.static = true
	self.active = false
	self.visible = true

	self.on = true
	
	if #self.r > 0 and self.r[1] ~= "link" then
		--rightclick things
		local v
		if self.switch then
			v = convertr(self.r[1], {"string", "string", "bool", "num"}, true)
		else
			v = convertr(self.r[1], {"string", "bool"}, true)
		end
		
		--visible?
		if self.switch then
			if v[3] ~= nil then	
				self.visible = v[3]
			end
		else
			if v[2] ~= nil then	
				self.visible = v[2]
			end
		end
		--color?
		if self.switch then
			if v[4] ~= nil then	
				self.color = v[4]
			end
		end
		--path
		for path = 1, paths do
			if v[path] ~= nil then	
				local s = v[path]:gsub("n", "-")
				local s2 = s:split("`")
				
				local s3
				for i = 1, #s2 do
					s3 = s2[i]:split(":")
					local x, y = tonumber(s3[1]), tonumber(s3[2])
					local start, ending, grab = s3[3], s3[4], s3[5]
					
					if x and y then
						local tx, ty = self.cox+x, self.coy+y
						if ismaptile(tx,ty) and ((not map[tx][ty]["track"]) or map[tx][ty]["track"].switch or self.switch) then
							table.insert(self.path[path], {tx, ty, start, ending, grab})
						else
							break
						end
					else
						break
					end
				end
			end
		end
		table.remove(self.r, 1)
	end
	self:makepath(self.activepath, "initial")
	--self.delete = true
end

function track:makepath(path, initial)
	if not initial then
		for i = 1, #self.path[self.activepath] do
			local t = self.path[self.activepath][i]
			local ctrack = map[t[1]][t[2]]["track"]
			if i == 1 and ctrack and ctrack.start ~= "c" and ctrack.start ~= "o" then --connect to the end of another track
				map[t[1]][t[2]]["track"].ending = "o"
			elseif i == #self.path[self.activepath] and ctrack and (ctrack.ending ~= "c" and ctrack.ending ~= "o") then
				map[t[1]][t[2]]["track"].start = "o"
			else
				map[t[1]][t[2]]["track"] = nil
				local s = objects["tracksegment"][tilemap(t[1], t[2])]
				if s then
					s.active = false
					s.delete = true
					s = nil
					objects["tracksegment"][tilemap(t[1], t[2])] = nil 
				end
			end
		end
	end
	self.activepath = path
	for i = 1, #self.path[self.activepath] do
		local t = self.path[self.activepath][i]
		if map[t[1]][t[2]] == emptytile then map[t[1]][t[2]] = shallowcopy(emptytile) end
		--if switch track exists in current tile, connect
		local ctrack = map[t[1]][t[2]]["track"]
		if i == 1 and ctrack and (ctrack.switch or self.switch) and (ctrack.ending == "c" or ctrack.ending == "o") then --connect to the end of another track
			map[t[1]][t[2]]["track"].ending=t[4]
		elseif i == #self.path[self.activepath] and ctrack and (ctrack.switch or self.switch) and (ctrack.start == "c" or ctrack.start == "o") then --connect to the end of another track
			map[t[1]][t[2]]["track"].start=t[3]
		--otherwise, overwrite empty tile with track
		else
			map[t[1]][t[2]]["track"] = {start=t[3], ending=t[4], grab=t[5]}
			if self.switch then
				map[t[1]][t[2]]["track"].switch = true
			end
		end
		if self.visible == false then
			map[t[1]][t[2]]["track"].invisible = true
		end
		objects["tracksegment"][tilemap(t[1], t[2])] = tracksegment:new(t[1], t[2], t[3], t[4], t[5], self)

		--MOVING TILES!!!
		if initial and (t[5] == "t" or t[5] == "tr" or t[5] == "tf" or t[5] == "tfr") then
			local x, y = t[1], t[2]
			if ismaptile(x,y) and (tilequads[map[x][y][1]].collision or tilequads[map[x][y][1]].coin) then
				local obj = tilemoving:new(t[1], t[2])
				local dir, fast = "forward", false
				if t[5]:find("r") then --reverse
					dir = "backwards"
				end
				if t[5]:find("f") then --fast
					obj.trackedfast = true
					fast = true
				end
				table.insert(objects["tilemoving"], obj)
				table.insert(objects["trackcontroller"], trackcontroller:new(t[1], t[2],"tilemoving",obj,dir,fast))
			end
		end
	end
end

function track:update(dt)
	--lazy, update any newly spawned trackcontrollers
	if self.on == false and self.trackcontrollernum and self.trackcontrollernum ~= #objects["trackcontroller"] then
		self:tellcontrollers()
	end
	self.trackcontrollernum = #objects["trackcontroller"]

	if self.delete then
		return true
	end
end

function track:draw()
	if self.switch then
		--draw switch light
		love.graphics.draw(trackimg, trackquad["switch"][self.color][self.activepath], math.floor(((self.cox-xscroll-.5)*16)*scale), math.floor(((self.coy-yscroll-1.5)*16+8)*scale), 0, scale, scale, 8, 8)
	end
end

function track:link()
	if self.switch then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[2]) == v.cox and tonumber(self.r[3]) == v.coy then
					local t = self.r[4] or "switch"
					if t == "switch" then
						self.color = 5 --linked, so no color
					end
					v:addoutput(self, t)
				end
			end
		end
		
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
		table.remove(self.r, 1)
	else
		if #self.r >= 3 then
			for j, w in pairs(outputs) do
				for i, v in pairs(objects[w]) do
					if tonumber(self.r[2]) == v.cox and tonumber(self.r[3]) == v.coy then
						v:addoutput(self)
					end
				end
			end
		end
	end
end

function track:change()
	self:input("toggle", "switch")
end

function track:input(t, input)
	if input == "switch" then
		local newpath
		if t == "on" then
			newpath = 2
		elseif t == "off" then
			newpath = 1
		elseif t == "toggle" then
			newpath = 2
			if self.activepath == 2 then
				newpath = 1
			end
		end
		if self.activepath ~= newpath then
			self:makepath(newpath)
		end
	else--if input == "power" then
		if t == "on" then
			self.on = false
		elseif t == "off" then
			self.on = true
		elseif t == "toggle" then
			self.on = not self.on
		end
	end
	self:tellcontrollers()
end

function track:tellcontrollers()
	local trackcontrollers = {}
	for i, v in pairs(objects["trackcontroller"]) do
		if not trackcontrollers[v.x .. "-" .. v.y] then
			trackcontrollers[v.x .. "-" .. v.y] = {}
		end
		table.insert(trackcontrollers[v.x .. "-" .. v.y], v)
	end
	for i = 1, #self.path[self.activepath] do
		local t = self.path[self.activepath][i]
		local t = trackcontrollers[t[1] .. "-" .. t[2]]
		if t then
			for i, v in pairs(t) do
				v.on = self.on
			end
		end
	end
end

function oppositetrackdirection(dir, dontflipend)
	if dir == "l" then
		return "r"
	elseif dir == "r" then
		return "l"
	elseif dir == "u" then
		return "d"
	elseif dir == "d" then
		return "u"
	elseif dir == "lu" then
		return "rd"
	elseif dir == "ld" then
		return "ru"
	elseif dir == "ru" then
		return "ld"
	elseif dir == "rd" then
		return "lu"
	elseif dir == "o" and not dontflipend then
		return "c"
	elseif dir == "c" and not dontflipend then
		return "o"
	end
	return dir
end

function drawtrack(x, y, start, ending)
	--draw start, unless it has to go over end
	local quadid = start
	if trackquadids[quadid] and start ~= "c" and start ~= "o" then
		local qx, qy = trackquadids[quadid][1], trackquadids[quadid][2]
		love.graphics.draw(trackimg, trackquad[qx][qy], math.floor(((x-xscroll-.5)*16)*scale), math.floor(((y-yscroll-1.5)*16+8)*scale), 0, scale, scale, 8, 8)
	end
	--draw end if it isn't the same as start
	if ending ~= start then
		local quadid = ending
		if trackquadids[quadid] then
			local qx, qy = trackquadids[quadid][1], trackquadids[quadid][2]
			love.graphics.draw(trackimg, trackquad[qx][qy], math.floor(((x-xscroll-.5)*16)*scale), math.floor(((y-yscroll-1.5)*16+8)*scale), 0, scale, scale, 8, 8)
		end
	end
	--draw start if it has to go over end
	if start == "c" or start == "o" then
		local qx, qy = trackquadids[start][1], trackquadids[start][2]
		love.graphics.draw(trackimg, trackquad[qx][qy], math.floor(((x-xscroll-.5)*16)*scale), math.floor(((y-yscroll-1.5)*16+8)*scale), 0, scale, scale, 8, 8)
	end
end

--CONTROLLER (controls entities when they're on the track)--
trackcontroller = class:new()

function trackcontroller:init(x, y, a, b, travel, fast, on)
	--PHYSICS STUFF
	self.x = x
	self.y = y
	self.travel = travel or "forward"
	self.active = false
	self.v = 0.5 --progress (0-1)
	self.a = a -- object name
	self.b = b --object

	if (not self.b) or (((not self.b.active) and (not b.trackable)) and (not b.trackspeed)) or (b.width and (self.x-.5)-(b.x+b.width/2) > 2) or (b.trackable == false) then
		--reject enemy
		self.delete = true
		return false
	end

	self.b.trackcontroller = self

	self.on = true
	if on ~= nil then
		self.on = on
	end
	self.trackspeed = trackspeed
	if fast or self.b.trackedfast then
		self.trackspeed = trackfastspeed
	end

	--get start travel
	local speedx, speedy = self.b.speedx, self.b.speedy
	if travel == "forward" then
		speedx = -1
		speedy = 1
	elseif travel == "backwards" then
		speedx = 1
		speedy = -1
	end
	local t = map[self.x][self.y]["track"]
	--get starting position
	if speedx > 0 then
		local dir = t.start
		if travel == nil then --start somewhere within the track
			if t.start ~= "o" then
				self.v = math.max(0, math.min(1, (self.b.x+self.b.width/2)%1))
			end
		end
		if dir == "o" or dir == "c" then dir = oppositetrackdirection(t.ending) end
		if dir == "l" or dir == "lu" or dir == "ld" then
			self.travel = "forward"
		else
			self.travel = "backwards"
			self.v = 1-self.v
		end
	else
		local dir = t.start
		if travel == nil then --start somewhere within the track
			if t.ending ~= "o" then
				self.v = (self.b.x+self.b.width/2)%1
			end
		end
		if dir == "o" or dir == "c" then dir = oppositetrackdirection(t.ending) end
		if dir == "l" or dir == "lu" or dir == "ld" then
			self.travel = "backwards"
		else
			self.travel = "forward"
			self.v = 1-self.v
		end
	end
	if (t.start == "u" or t.ending == "u" or t.ending == "o") and (t.start == "d" or t.ending == "d") then
		if travel == nil then --start somewhere within the track
			self.v = (self.b.x+self.b.width/2)%1
		end
		if speedy >= 0 then
			if t.start == "u" then
				self.travel = "forward"
			else
				self.travel = "backwards"
			end
		else
			if t.start == "u" then
				self.travel = "backwards"
			else
				self.travel = "forward"
			end
		end
	end

	--hold in place
	self:initialhold(self.b)
end

function trackcontroller:update(dt)
	if self.b.transformkill and (not self.b.dontpasstracked) then
		--if then enemy transformed switch to the new one
		self.b = self.b.transformedinto
		if (not self.b) then
			return true
		else
			self:initialhold()
		end
		return false
	end
	if self.delete or (not self.b) or self.b.delete or self.b.dead or self.b.shot or self.b.destroy then
		return true
	end
	if self.b.trackable == false then
		self:release(nil, "soft")
		return true
	end
	--[[if not self.on then
		return false
	end]]
	local a, b = self.a, self.b
	local remainder = 0
	local oldv = self.v
	--old pos
	local oldx, oldy = b.x, b.y
	--progress
	local multiplier = 1
	local dir = self:getdirection(map[self.x][self.y]["track"], self.v)
	if dir == "lu" or dir == "ld" or dir == "ru" or dir == "rd" then
		multiplier = 0.70711 --diagonal speed
	end
	if self.on then
		self.speed = self.b.trackspeed or self.trackspeed
		if self.travel == "forward" then
			self.v = self.v + multiplier*self.speed*dt
			remainder = self.v%1
			self.v = math.min(1,self.v)
		else
			self.v = self.v - multiplier*self.speed*dt
			remainder = 1-(math.abs(self.v)%1)
			self.v = math.max(0,self.v)
		end
	end
	--hold object in place
	local x, y = self.x, self.y
	local offx, offy = 0, 0
	local addx, addy = 0, 0
	local t = map[x][y]["track"]
	if (not t) then
		local releasedir = "r"
		if self.oldxdiff then
			if self.oldxdiff < 0 then releasedir = "l"
			elseif self.oldxdiff == 0 then releasedir = "d" end
		end
		self:release(releasedir)
		return true
	end
	self.oldstart = t.start
	self.oldending = t.ending
	local dir, sdir, edir, v = self:getdirection(t, self.v) --start direction, end direction
	--get offset
	if dir == "l" then
		addx = -1
		offx = .5
	elseif dir == "r" then
		addx = 1
		offx = -.5
	elseif dir == "u" then
		addy = -1
		offy = .5
	elseif dir == "d" then
		addy = 1
		offy = -.5
	elseif dir == "lu" then
		addx = -1
		addy = -1
		offx = .5
		offy = .5
	elseif dir == "ld" then
		addx = -1
		addy = 1
		offx = .5
		offy = -.5
	elseif dir == "ru" then
		addx = 1
		addy = -1
		offx = -.5
		offy = .5
	elseif dir == "rd" then
		addx = 1
		addy = 1
		offx = -.5
		offy = -.5
	end
	local width, height = b.width, b.height
	if not width then
		width = 0
		height = 0
	end
	b.x = x-.5-width/2+(addx*v)+offx+(b.trackoffsetx or 0)
	b.y = y-.5-height/2+(addy*v)+offy+(b.trackoffsety or 0)
	if b.rotatetowardstrackpath then
		local angle = -math.atan2(b.x-oldx, b.y-oldy)-math.pi/2
		b.rotation = angle+(b.rotatetowardstrackpathoffset or 0)
	end
	self.oldxdiff = b.x-oldx--used to release entity in the correct direction if track dissapears
	--Update Speed
	if b.trackplatform and b.active then --hold enemies
		local checktable = {"player", "mushroom", "oneup"}
		if b.trackplatformchecktable or b.platformchecktable then
			checktable = b.trackplatformchecktable or b.platformchecktable
		end
		local xdiff = b.x-oldx
		local ydiff = b.y-oldy
		local condition = false
		if ydiff < 0 then
			condition = "ignoreplatforms"
		end
		for i, v in pairs(checktable) do
			for j, w in pairs(objects[v]) do
				if (not w.ignoreplatform) then
					if (not b.noplatformcarrying) and inrange(w.x, b.x-w.width, b.x+b.width) then --vertical carry
						if ( (w.y == b.y - w.height) or 
							( (w.y+w.height >= b.y-0.1-math.max(0,math.abs(ydiff)) and w.y+w.height-math.max(0,w.speedy*dt) <= b.y+0.2-math.min(0,ydiff)) ) )
							and (not w.jumping) and (not w.vine) then
							if #checkrect(w.x+xdiff, b.y-w.height, w.width, w.height, {"exclude", w}, true, condition) == 0 then
								if (not w.trackplatformcarriedx) or math.abs(xdiff) > math.abs(w.trackplatformcarriedx) then --don't move if already moved by another platform
									w.oldxplatform = w.x
									w.x = w.x + xdiff
									w.trackplatformcarriedx = xdiff
								end
								if (not b.leavemarioalone) then
									w.y = b.y-w.height
									w.falling = false
									w.jumping = false
									w.speedy = 0
								elseif ydiff < 0 then
									w.y = math.min(w.y+w.speedy*dt, b.y-w.height)
								end
								--w.speedy = b.speedy
							end
						elseif (w.y >= b.y+b.height-0.1 and w.y <= b.y+b.height+0.1) and w.speedy < 0 and (not b.PLATFORM) then --bottom
							if ydiff ~= 0 and #checkrect(w.x, b.y+b.height, w.width, w.height, {"exclude", w}, true, condition) == 0 then
								w.y = b.y+b.height
							end
						end
					end
					if b.trackplatformpush and xdiff ~= 0 and (not b.PLATFORM) then --horizontal push
						if inrange(w.y+w.height/2, b.y, b.y+b.height) then
							if xdiff > 0 and w.x < b.x+b.width and w.x+w.width > b.x+b.width then --right
								if #checkrect(b.x+b.width, w.y, w.width, w.height, {"exclude", w}, true, "ignoreplatforms") == 0 then
									w.x = b.x+b.width
								end
							elseif xdiff < 0 and w.x+w.width > b.x and w.x < b.x then
								if #checkrect(b.x-w.width, w.y, w.width, w.height, {"exclude", w}, true, "ignoreplatforms") == 0 then
									w.x = b.x-w.width
								end
							end
						end
					end
				end
			end
		end
	end
	--Continue onwards
	if (self.v == 1 and self.travel == "forward") or (self.v == 0 and self.travel == "backwards") or dir == "o" or dir == "c" then
		if dir == "l" and map[x-1][y]["track"] then
			self.x = self.x - 1
		elseif dir == "r" and map[x+1][y]["track"] then
			self.x = self.x + 1
		elseif dir == "u" and map[x][y-1]["track"] then
			self.y = self.y - 1
		elseif dir == "d" and map[x][y+1]["track"] then
			self.y = self.y + 1
		elseif dir == "lu" and map[x-1][y-1]["track"] then
			self.x = self.x - 1
			self.y = self.y - 1
		elseif dir == "ld" and map[x-1][y+1]["track"] then
			self.x = self.x - 1
			self.y = self.y + 1
		elseif dir == "ru" and map[x+1][y-1]["track"] then
			self.x = self.x + 1
			self.y = self.y - 1
		elseif dir == "rd" and map[x+1][y+1]["track"] then
			self.x = self.x + 1
			self.y = self.y + 1
		--[[elseif self.dontgetfuckingstuckyoufuckingabsolutelogiclessentity then
			self.dontgetfuckingstuckyoufuckingabsolutelogiclessentity = false]]
		else
			if t.start == "o" or t.ending == "o" then
				local releasedir = oppositetrackdirection(t.start)
				if t.start == "o" then
					releasedir = oppositetrackdirection(t.ending)
				end
				self:release(releasedir)
			elseif (self.v > 0.5 and self.travel == "forward") or (self.v <= 0.5 and self.travel == "backwards") then --ok so
				--it took me hours to figure out the issue here
				--apparently, there is this odd thing where an entity has a small chance of turning around twice when reaching an edge
				--this can make it become stuff
				--so basically this checks if its actually in the "closed" stage of the track
				--didn't think this would work, but it does as far as i can tell
				--ill leave it like this for now, if you found out its still broken... god speed
				--well actually enable the elegantly named variable below

				--turn around
				if self.a == "enemy" and self.b.transforms and self.b:gettransformtrigger("trackturnaround") and (not self.b.dontpasstracked) then
					self.b:transform(self.b:gettransformsinto("trackturnaround"), "returntransform")
					self.b:output("transformed")
					self.b.dead = true
					--self.dontgetfuckingstuckyoufuckingabsolutelogiclessentity = true
				end
				if self.travel == "forward" then
					self.travel = "backwards"
				else
					self.travel = "forward"
				end
			end
		end
		self.v = remainder
	end
end

function trackcontroller:initialhold()
	if (not self.b) then
		return false
	end
	self.b.tracked = true
	if self.b.dotrack then
		self.b:dotrack(true, self.b.trackedfast)
	end
	self.oldb = {static = self.b.static,gravity = self.b.gravity or false,mask = shallowcopy(self.b.mask),platform = self.b.platform}

	if self.b.width and self.b.width >= 1.5 and (not self.b.ignoretrackgraboncenterofobject) then
		self.b.trackgraboncenterofobject = true
	end

	self.b.speedx = 0
	self.b.speedy = 0
	self.b.static = true
	self.b.gravity = 0
	if self.b.platform then
		self.b.platform = false
		self.b.trackplatform = true
	end
	if self.b.mask then
		if self.a == "enemy" then
			--duplicate mask if custom enemy, so it doesn't change every other mask
			local t = shallowcopy(self.b.mask)
			t[23] = self.b.mask[1] --don't collide with tracks
			if not self.b.dontchangetilemask then
				t[2] = self.b.mask[1] --don't collide with tiles
			end
			self.b.mask = t
		else
			self.b.mask[33] = self.b.mask[1] --don't collide with tracks
			if not self.b.dontchangetilemask then
				self.b.mask[2] = self.b.mask[1] --don't collide with tiles
			end
		end
	end
end

function trackcontroller:release(dir, soft)
	--release object from being grabbed
	self.delete = true
	self.b.tracked = false
	if (not self.oldb.gravity) or self.b.returngravityaftertrack then --return gravity
		--unquote this if enemies start floating after falling
		--find a solution if enemies with pre-defined gravity become static after releasing from track
		self.b.gravity = self.oldb.gravity
	end
	if not soft then --dont do this if object is ejecting itself from the track
		for name, value in pairs(self.oldb) do
			if name ~= "mask" then
				self.b[name] = value
			end
		end
		self.b.static = false
		self.b.gravity = self.b.trackgravity or trackgravity
		self.b.maxyspeed = trackmaxyspeed
		if dir == "u" or dir == "lu" or dir == "ru" then
			self.b.speedy = -math.max(self.speed, math.abs(self.b.speedy))-8
			self.b.speedx = 0
		elseif dir == "d" or dir == "ld" or dir == "rd" then
			self.b.speedy = math.abs(self.b.speedy)
			self.b.speedx = 0
		end
		if dir == "l" or dir == "lu" or dir == "ld" then
			self.b.speedx = -math.max(self.speed, math.abs(self.b.speedx))
		elseif dir == "r" or dir == "ru" or dir == "rd" then
			self.b.speedx = math.max(self.speed, math.abs(self.b.speedx))
		end
	
		if self.b.mask then
			self.b.mask[33] = not self.b.mask[1] --collide with tracks
		end
	else
		self.b.static = false
		
		if not self.b.dontreturnmaskontrackrelease then
			--if self.oldb.mask then
				self.b.mask[2] = self.oldb.mask[2]--false--not self.b.mask[1]
			--end
			--change this maybe if it breaks?
			--koopas fall if it uses the commented one because they change masks when shelled
		end
	end
	if self.b.dotrack then
		self.b:dotrack(false)
	end
end

function trackcontroller:getdirection(t, v)
	--get current directions
	--tracks are defined as: start direction, end direction
	if not t then
		return "c", "c", "c", 1
	end
	local v = v
	local sdir, edir = oppositetrackdirection(t.start, "dontflipend"), t.ending --start direction, end direction
	if self.travel == "backwards" then
		sdir, edir = oppositetrackdirection(t.ending, "dontflipend"), t.start
		v = 1-v
	end

	local dir = sdir
	if (self.v > 0.5 and self.travel == "forward") or (self.v <= 0.5 and self.travel == "backwards") then
		dir = edir
	end
	return dir, sdir, edir, v
end

function trackcontroller:draw()
	love.graphics.setColor(255,0,0,100)
	love.graphics.rectangle("line", (self.x-1-xscroll)*16*scale, (self.y-1.5-yscroll)*16*scale, 16*scale, 16*scale)
end

--SEGMENT--
tracksegment = class:new()

function tracksegment:init(x, y, start, ending, grab, parent)
	--PHYSICS STUFF
	self.cox = x
	self.coy = y
	self.x = x-.75
	self.y = y-.75
	self.speedx = 0
	self.speedy = 0
	self.width = .5
	self.height = .5
	self.active = true
	self.static = true
	self.category = 33
	self.mask = {true}
	
	self.emancipatecheck = false
	self.autodelete = false
	self.drawable = false
	self.portalable = false
	self.parent = parent

	self.hollow = true

	self.overridesemisolids = true
	self.NOEXTERNALHORCOLLISIONS = true
	self.NOEXTERNALVERCOLLISIONS = true
	
	self.start = start
	self.ending = ending
	--more accurate collision boxes
	if self.start == "l" or self.ending == "l" or self.start == "lu" or self.ending == "lu" or self.start == "ld" or self.ending == "ld" then
		self.width = self.width + .25
		self.x = self.x - .25
	end
	if self.start == "r" or self.ending == "r" or self.start == "ru" or self.ending == "ru" or self.start == "rd" or self.ending == "rd" then
		self.width = self.width + .25
	end
	if self.start == "u" or self.ending == "u"  or self.start == "lu" or self.ending == "lu" or self.start == "ru" or self.ending == "ru" then
		self.height = self.height + .25
		self.y = self.y - .25
	end
	if self.start == "d" or self.ending == "d"  or self.start == "ld" or self.ending == "ld" or self.start == "rd" or self.ending == "rd" then
		self.height = self.height + .25
	end
end

function tracksegment:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function tracksegment:rightcollide(a, b, redirect)
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function tracksegment:ceilcollide(a, b, redirect)
	if (not redirect) and (not b.tracked) and (b.trackable ~= false) then
		local x = b.x+b.width/2-(b.trackoffsetx or 0)
		local t = objects["tracksegment"][tilemap(math.floor(x)+1, self.coy)]
		if t then
			t:ceilcollide(a, b, "redirect")
			return false
		elseif b.trackgraboncenterofobject then
			--kill me now, this fixes platforms not grabbint diagonal tracks EDIT: nvm this wasn't the issue. ill keep this, itll probs break
			local threshold = 0.2
			local t1 = objects["tracksegment"][tilemap(math.floor(x)-threshold+1, self.coy)]
			local t2 = objects["tracksegment"][tilemap(math.floor(x)+threshold+1, self.coy)]
			if t1 then
				t:ceilcollide(a, b, "redirect")
			elseif t2 then
				t:ceilcollide(a, b, "redirect")
			end
			return false
		end
	end
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function tracksegment:globalcollide(a, b)
	if (not b.tracked) and (b.trackable ~= false) then
		local dir = "forward"
		table.insert(objects["trackcontroller"], trackcontroller:new(self.cox, self.coy, a, b, nil, nil, self.parent.on))
	end
end

function tracksegment:floorcollide(a, b, redirect)
	if (not redirect) and (not b.tracked) and (b.trackable ~= false) then
		local x = b.x+b.width/2-(b.trackoffsetx or 0)
		local t = objects["tracksegment"][tilemap(math.floor(x)+1, self.coy)]
		if t then
			t:ceilcollide(a, b, "redirect")
			return false
		elseif b.trackgraboncenterofobject then
			local threshold = 0.2
			local t1 = objects["tracksegment"][tilemap(math.floor(x)-threshold+1, self.coy)]
			local t2 = objects["tracksegment"][tilemap(math.floor(x)+threshold+1, self.coy)]
			if t1 then
				t:ceilcollide(a, b, "redirect")
			elseif t2 then
				t:ceilcollide(a, b, "redirect")
			end
			return false
		end
	end
	if self:globalcollide(a, b) then
		return false
	end
	return false
end

function tracksegment:passivecollide(a, b)
	--[[if self:globalcollide(a, b) then
		return false
	end]]
	return false
end
