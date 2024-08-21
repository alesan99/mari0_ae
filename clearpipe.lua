clearpipe = class:new()

local addsegment

function clearpipe:init(x, y, r, t)
	--path
	self.x = x
	self.y = y

	self.t = t or "clearpipe"
	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)

	self.path = {{self.x, self.y}}
	if self.t == "pneumatictube" then
		self.dusttimer = 0
		self.dusttable = {}
		self.suck = true
		self.suckspeed = 14 --owo
		self.sucklen = 4
		self.sucktable = {"player","box","core","turret"}

		self.suckentranceportalx = false
		self.suckentranceportaly = false
		self.suckentranceportalfacing = false
		self.suckexitportalx = false
		self.suckexitportaly = false
		self.suckexitportalfacing = false
	end
	
	if #self.r > 0 and self.r[1] ~= "link" then
		--rightclick things
		--if self.r[1]:find("|") then
			--n1:2`0:2`1:2`1:1
			local v = convertr(self.r[1], {"string","bool","bool"})
			--path
			local s = v[1]:gsub("n", "-")
			local s2 = s:split("`")
			local s3
			for i = 1, #s2 do
				s3 = s2[i]:split(":")
				local x, y = tonumber(s3[1]), tonumber(s3[2])
				if x and y then
					table.insert(self.path, {self.x+x, self.y+y})
				else
					break
				end
			end
			self.intersection = v[2]
			if self.t == "pneumatictube" then
				self.suck = v[3]
			end
		--end
		table.remove(self.r, 1)
	end

	self.quadi = 1
	self.graphic = clearpipeimg
	if self.t == "pneumatictube" then
		self.graphic = pneumatictubeimg
	end

	self.checktable = {"player", "goomba", "koopa", "mole", "enemy", "box", "smallspring", "blocktogglebutton", "powblock", "thwomp"} --can enter pipe

	if not self.intersection then
		--so here's this giant tumor
		self.child = {}
		local dir = "right"
		local exitdir, enterdir = false, false
		for i = 1, #self.path do
			local tx, ty = self.path[i][1], self.path[i][2]
			local quadi = 2
			local ignore, turn = false, false
			--get direction
			if self.path[i+1] then
				if self.path[i+1][2] < ty then
					dir = "up"
				elseif self.path[i+1][2] > ty then
					dir = "down"
				end
				if self.path[i+1][1] < tx then
					dir = "left"
				elseif self.path[i+1][1] > tx then
					dir = "right"
				end
			end
			self.path[i].dir = dir
			if (self.path[i-1] and self.path[i+1] and i ~= #self.path) and not 
				((self.path[i+1][1] ~= self.path[i-1][1] and self.path[i+1][2] == self.path[i-1][2])
				or (self.path[i+1][2] ~= self.path[i-1][2] and self.path[i+1][1] == self.path[i-1][1]))	then

				if (self.path[i+1][1] == tx+1 and self.path[i+1][2] == ty and self.path[i-1][1] == tx and self.path[i-1][2] == ty+1)
				or (self.path[i+1][1] == tx and self.path[i+1][2] == ty+1 and self.path[i-1][1] == tx+1 and self.path[i-1][2] == ty) then
					turn = "c1"
				elseif (self.path[i+1][1] == tx-1 and self.path[i+1][2] == ty and self.path[i-1][1] == tx and self.path[i-1][2] == ty+1)
				or (self.path[i+1][1] == tx and self.path[i+1][2] == ty+1 and self.path[i-1][1] == tx-1 and self.path[i-1][2] == ty) then
					turn = "c2"
				elseif (self.path[i+1][1] == tx and self.path[i+1][2] == ty-1 and self.path[i-1][1] == tx+1 and self.path[i-1][2] == ty)
				or (self.path[i+1][1] == tx+1 and self.path[i+1][2] == ty and self.path[i-1][1] == tx and self.path[i-1][2] == ty-1) then
					turn = "c3"
				else
					turn = "c4"
				end
			elseif (self.path[i-1] and self.path[i-2] and i ~= #self.path) and 
				((dir == "right" and self.path[i][2] ~= self.path[i-1][2]) 
				or (dir == "left" and self.path[i][2] == self.path[i-1][2] and self.path[i][2] ~= self.path[i-2][2]) 
				or (dir == "down" and self.path[i][1] ~= self.path[i-1][1]) 
				or (dir == "up" and self.path[i][1] == self.path[i-1][1] and self.path[i][1] ~= self.path[i-2][1])) then
				--is the path 2 tiles ago in a different direction?
				ignore = true
			elseif (self.path[i+1] and self.path[i+2] and i ~= #self.path) and
				((dir == "left" and self.path[i][2] ~= self.path[i+1][2]) 
				or (dir == "right" and self.path[i][2] == self.path[i+1][2] and self.path[i][2] ~= self.path[i+2][2]) 
				or (dir == "up" and self.path[i][1] ~= self.path[i+1][1]) 
				or (dir == "down" and self.path[i][1] == self.path[i+1][1] and self.path[i][1] ~= self.path[i+2][1])) then
				--is the path 2 tiles ahead in a different direction?
				ignore = true
			end
			--create segment
			if not ignore then
				if not turn then
					local verquad = {{1,4},{2,4}}
					local horquad = {{2,1},{2,2}}
					if self.t == "pneumatictube" then
						if i/2 ~= math.floor(i/2) then
							verquad = {{3,5},{4,5}}
							horquad = {{4,1},{4,2}}
						end
					end
					if dir == "right" then
						if i == 1 then
							addsegment(tx, ty-1, self, {1,1}, i, dir, dir, false, self.graphic)
							addsegment(tx, ty, self, {1,2}, i, dir, dir, false, self.graphic)
							enterdir = "right"
						elseif i == #self.path then
							addsegment(tx, ty-1, self, {3,1}, i, dir, false, dir, self.graphic)
							addsegment(tx, ty, self, {3,2}, i, dir, false, dir, self.graphic)
							exitdir = "right"
						else
							addsegment(tx, ty-1, self, horquad[1], i, dir, false, false, self.graphic)
							addsegment(tx, ty, self, horquad[2], i, dir, false, false, self.graphic)
						end
					elseif dir == "up" then
						if i == 1 then
							addsegment(tx-1, ty, self, {1,5}, i, dir, dir, false, self.graphic)
							addsegment(tx, ty, self, {2,5}, i, dir, dir, false, self.graphic)
							enterdir = "up"
						elseif i == #self.path then
							addsegment(tx-1, ty, self, {1,3}, i, dir, false, dir, self.graphic)
							addsegment(tx, ty, self, {2,3}, i, dir, false, dir, self.graphic)
							exitdir = "up"
						else
							addsegment(tx-1, ty, self, verquad[1], i, dir, false, false, self.graphic)
							addsegment(tx, ty, self, verquad[2], i, dir, false, false, self.graphic)
						end
					elseif dir == "left" then
						if i == 1 then
							addsegment(tx, ty-1, self, {3,1}, i, dir, dir, false, self.graphic)
							addsegment(tx, ty, self, {3,2}, i, dir, dir, false, self.graphic)
							enterdir = "left"
						elseif i == #self.path then
							addsegment(tx, ty-1, self, {1,1}, i, dir, false, dir, self.graphic)
							addsegment(tx, ty, self, {1,2}, i, dir, false, dir, self.graphic)
							exitdir = "left"
						else
							addsegment(tx, ty-1, self, horquad[1], i, dir, false, false, self.graphic)
							addsegment(tx, ty, self, horquad[2], i, dir, false, false, self.graphic)
						end
					elseif dir == "down" then
						if i == 1 then
							addsegment(tx-1, ty, self, {1,3}, i, dir, dir, false, self.graphic)
							addsegment(tx, ty, self, {2,3}, i, dir, dir, false, self.graphic)
							enterdir = "down"
						elseif i == #self.path then
							addsegment(tx-1, ty, self, {1,5}, i, dir, false, dir, self.graphic)
							addsegment(tx, ty, self, {2,5}, i, dir, false, dir, self.graphic)
							exitdir = "down"
						else
							addsegment(tx-1, ty, self, verquad[1], i, dir, false, false, self.graphic)
							addsegment(tx, ty, self, verquad[2], i, dir, false, false, self.graphic)
						end
					end
				elseif turn == "c1" then
					addsegment(tx, ty, self, {6,2}, i, dir, false, false, self.graphic)
					addsegment(tx-1, ty, self, {5,2}, i, dir, false, false, self.graphic)
					addsegment(tx-1, ty-1, self, {5,1}, i, dir, false, false, self.graphic)
					addsegment(tx, ty-1, self, {6,1}, i, dir, false, false, self.graphic)
				elseif turn == "c2" then
					addsegment(tx, ty, self, {8,2}, i, dir, false, false, self.graphic)
					addsegment(tx-1, ty, self, {7,2}, i, dir, false, false, self.graphic)
					addsegment(tx-1, ty-1, self, {7,1}, i, dir, false, false, self.graphic)
					addsegment(tx, ty-1, self, {8,1}, i, dir, false, false, self.graphic)
				elseif turn == "c3" then
					addsegment(tx, ty, self, {6,4}, i, dir, false, false, self.graphic)
					addsegment(tx-1, ty, self, {5,4}, i, dir, false, false, self.graphic)
					addsegment(tx-1, ty-1, self, {5,3}, i, dir, false, false, self.graphic)
					addsegment(tx, ty-1, self, {6,3}, i, dir, false, false, self.graphic)
				elseif turn == "c4" then
					addsegment(tx, ty, self, {8,4}, i, dir, false, false, self.graphic)
					addsegment(tx-1, ty, self, {7,4}, i, dir, false, false, self.graphic)
					addsegment(tx-1, ty-1, self, {7,3}, i, dir, false, false, self.graphic)
					addsegment(tx, ty-1, self, {8,3}, i, dir, false, false, self.graphic)
				end
			end
		end
		--extend path because actual movementpath is offset by -.5,-.5 to make up for the 2 tile width of pipes
		if #self.path == 1 then
			exitdir = "right"
		end
		self.pathoffset = 0
		if exitdir == "right" then
			table.insert(self.path, {self.path[#self.path][1]+1, self.path[#self.path][2], dir="right"})
		elseif exitdir == "down" then
			table.insert(self.path, {self.path[#self.path][1], self.path[#self.path][2]+1, dir="down"})
		end
		if enterdir == "left" then
			self.pathoffset = 1 --path actually starts a little ahead
			table.insert(self.path, 1, {self.path[1][1]+1, self.path[1][2], dir="left"})
		elseif enterdir == "up" then
			self.pathoffset = 1
			table.insert(self.path, 1, {self.path[1][1], self.path[1][2]+1, dir="up"})
		end
		self.entrance = enterdir
		self.exit = exitdir
	end

	self.updatetable = {}
end

function clearpipe:update(dt)
	if self.delete then
		return true
	end
	if self.t == "pneumatictube" then
		local delete = {}
		for i = 1, #self.dusttable do
			local t = self.dusttable[i]

			t[2] = t[2] + self.suckspeed*dt
			t[3] = t[3] + t[4]*9*dt--rotation
			if t[2] > self.sucklen then
				table.insert(delete, i)
			end
		end
		table.sort(delete, function(a,b) return a>b end)
		
		for i, v in pairs(delete) do
			table.remove(self.dusttable, v) --remove
		end
	
		self.dusttimer = self.dusttimer - dt
		if self.dusttimer < 0 then
			self.dusttimer = math.random(1,4)/20
			table.insert(self.dusttable, {math.random()*2, 0, 0, math.random()*2-1, math.random(1,2)})
		end

		if self.suck then
			--Search portals
			if not self.intersectentrance then
				self.suckentranceportalx = false
				self.suckentranceportaly = false
				self.suckentranceportalfacing = false
				local dir = self.entrance
				local cx, cy = self.path[1][1]-1, self.path[1][2]-1
				local cx, cy, cw, ch, dx, dy = self:getsuck(dir,"entrance",cx,cy)
				for x = cx+1, cx+cw do
					for y = cy+1, cy+ch do
						local portalx, portaly, portalfacing, infacing = getPortal(x, y, dir)
						if portalx then
							if portalfacing == "left" then
								portalfacing = "right"
								if infacing == "up" then
									portaly = portaly
								else portaly = portaly+1
								end
							elseif portalfacing == "right" then
								portalfacing = "left"
								if infacing == "down" then
									portalx,portaly = portalx+1,portaly
								else portalx,portaly = portalx+1,portaly+1
								end
							elseif portalfacing == "up" then
								portalfacing = "down"
								if infacing == "left" then
									portalx,portaly = portalx+1,portaly
								end
							else
								portalfacing = "up"
								if infacing == "right" then
									portalx,portaly = portalx+1,portaly+1
								else portalx,portaly = portalx,portaly+1
								end
							end
							self.suckentranceportalx = portalx
							self.suckentranceportaly = portaly
							self.suckentranceportalfacing = portalfacing
							break
						end
					end
				end
			end
			if not self.intersectexit then
				self.suckexitportalx = false
				self.suckexitportaly = false
				self.suckexitportalfacing = false
				local dir = self.exit
				local cx, cy = self.path[#self.path][1]-1, self.path[#self.path][2]-1
				local cx, cy, cw, ch, dx, dy = self:getsuck(dir,"exit",cx,cy)
				if dir == "left" then dir = "right"
				elseif dir == "right" then dir = "left"
				elseif dir == "up" then dir = "down"
				else dir = "up" end
				local portalx, portaly, portalfacing, infacing
				for x = cx+1, cx+cw do
					for y = cy+1, cy+ch do
						portalx, portaly, portalfacing, infacing = getPortal(x, y, dir)
						if portalx then
							if portalfacing == "left" then
								if infacing == "up" then
									portaly = portaly
								else portaly = portaly+1
								end
							elseif portalfacing == "right" then
								if infacing == "down" then
									portalx,portaly = portalx+1,portaly
								else portalx,portaly = portalx+1,portaly+1
								end
							elseif portalfacing == "up" then
								if infacing == "left" then
									portalx,portaly = portalx+1,portaly
								end
							else
								if infacing == "right" then
									portalx,portaly = portalx+1,portaly+1
								else portalx,portaly = portalx,portaly+1
								end
							end
							self.suckexitportalx = portalx
							self.suckexitportaly = portaly
							self.suckexitportalfacing = portalfacing
							break
						end
					end
				end
			end

			--Suck in entities
			for j, w in pairs(self.sucktable) do
				for i, v in pairs(objects[w]) do
					if v.active then
						if not self.intersectentrance then
							local dir = self.entrance
							local cx, cy = self.path[1][1]-1, self.path[1][2]-1
							self:suckrange(dir,"entrance",cx,cy,v,dt)
							if self.suckentranceportalx then
								local cx, cy = self.suckentranceportalx-1, self.suckentranceportaly-1
								self:suckrange(self.suckentranceportalfacing,"entrance",cx,cy,v,dt)
							end
						end
						if not self.intersectexit then
							local dir = self.exit
							local cx, cy = self.path[#self.path][1]-1, self.path[#self.path][2]-1
							self:suckrange(dir,"exit",cx,cy,v,dt)
							if self.suckexitportalx then
								local cx, cy = self.suckexitportalx-1, self.suckexitportaly-1
								self:suckrange(self.suckentranceportalfacing,"exit",cx,cy,v,dt)
							end
						end
					end
				end
			end
		end
	end
	local delete = {}
	for j, w in pairs(self.updatetable) do
		local a = w[1]
		local b = w[2]
		local dir
		local pass = true
		if not b.clearpipe then
			--if for some reason the clearpipe table dissapeared
			if self:release(a,b,"forward","forcefinish") then
				table.insert(delete, j)
			end
			pass = false
		end
		if pass then
			if self.intersection then
				dir = b.clearpipe.travel
			else
				dir = self.path[self:getstage(b.clearpipe.stage)].dir
			end
			--rotation
			if not b.noclearpiperotation then
				if dir == "left" then
					if b.clearpipe.dir == "forward" then
						b.rotation = math.pi*1.5
					else
						b.rotation = math.pi*.5
					end
				elseif dir == "right" then
					if b.clearpipe.dir == "forward" then
						b.rotation = math.pi*.5
					else
						b.rotation = math.pi*1.5
					end
				elseif dir == "up" then
					if b.clearpipe.dir == "backwards" then
						b.rotation = math.pi
					end
				elseif dir == "down" then
					if b.clearpipe.dir == "forward" then
						b.rotation = math.pi
					end
				end
			end
			--movement handling
			local finished, forcefinish = false, false
			if self.intersection then --mutliple paths
				local oldstage = b.clearpipe.stage
				b.clearpipe.stage = b.clearpipe.stage + (b.clearpipespeed or clearpipespeed)*dt
				--change direction
				if oldstage < 2 and b.clearpipe.stage > 2 then
					local uphold = (a == "player" and upkey(b.playernumber)) and self.crossup
					local downhold = (a == "player" and downkey(b.playernumber)) and self.crossdown
					local lefthold = (a == "player" and leftkey(b.playernumber)) and self.crossleft
					local righthold = (a == "player" and rightkey(b.playernumber)) and self.crossright
					if dir == "right" then
						if self.crossright and (not (uphold)) and (not (downhold)) then
						elseif self.crossup and not (downhold) then
							b.clearpipe.travel = "up"
						elseif self.crossdown then
							b.clearpipe.travel = "down"
						else
							b.clearpipe.travel = "left"
						end
					elseif dir == "left" then
						if self.crossleft and (not (uphold)) and (not (downhold)) then
						elseif self.crossup and not (downhold) then
							b.clearpipe.travel = "up"
						elseif self.crossdown then
							b.clearpipe.travel = "down"
						else
							b.clearpipe.travel = "right"
						end
					elseif dir == "down" then
						if self.crossdown and (not (lefthold)) and (not (righthold)) then
						elseif self.crossleft and not (righthold) then
							b.clearpipe.travel = "left"
						elseif self.crossright then
							b.clearpipe.travel = "right"
						else
							b.clearpipe.travel = "up"
						end
					elseif dir == "up" then
						if self.crossup and (not (lefthold)) and (not (righthold)) then
						elseif self.crossleft and not (righthold) then
							b.clearpipe.travel = "left"
						elseif self.crossright then
							b.clearpipe.travel = "right"
						else
							b.clearpipe.travel = "down"
						end
					end
					dir = b.clearpipe.travel
				end
				--keep object in position
				self:hold(a, b)
				--check if finished with path
				if b.clearpipe.stage > 3 then
					finished = true
				end
			else --singular path
				--next stage
				if b.clearpipe.dir == "forward" then
					b.clearpipe.stage = b.clearpipe.stage + (b.clearpipespeed or clearpipespeed)*dt
				else
					b.clearpipe.stage = b.clearpipe.stage - (b.clearpipespeed or clearpipespeed)*dt
				end
				--keep object in position
				self:hold(a, b)
				--check if finished with path
				if b.clearpipe.dir == "forward" then
					if b.clearpipe.stage >= #self.path then
						finished = true
					end
				elseif b.clearpipe.dir == "backwards" then
					if b.clearpipe.stage <= 1 then
						finished = true
					end
				end
			end
			if b.transformkill and (not b.dontpassclearpipe) then
				--if then enemy transformed switch to the new one
				local clearpipedata = shallowcopy(b.clearpipe)
				w[2] = b.transformedinto
				if (not w[2]) then
					finished = true
					forcefinish = true
				else
					self:initialhold(a, w[2], clearpipedata)
					finished = true
					forcefinish = true
				end
			elseif b.shot or b.delete then
				finished = true
			end
			--push object outside pipe
			if finished then
				if self:release(a,b,dir,forcefinish) then
					table.insert(delete, j)
				end
			end
		end
	end
	table.sort(delete, function(a,b) return a>b end)
	for i, v in pairs(delete) do
		table.remove(self.updatetable, v)
	end
end

function clearpipe:grab(a, b, dir, stage, pipedir, entrance, exit)
	--reject big enemies
	if b.width > 2 or b.height > 2 or b.dontenterclearpipes then
		return false
	end

	if self.intersection then
		local ox, oy = math.max(self.x-1, math.min(self.x+1, b.x+1+b.width/2)), math.max(self.y-1, math.min(self.y+1, b.y+1+b.height/2))
		--reject enemies in wrong intersection direction
		local travel = nil
		if ox >= self.x and oy >= self.y-(ox%1) and oy <= self.y+(ox%1) then --to left
			if self.crossright then
				travel = "left"
			else
				return false
			end
		elseif ox < self.x and oy >= self.y-(1-(ox%1)) and oy <= self.y+(1-(ox%1))then --to right
			if self.crossleft then
				travel = "right"
			else
				return false
			end
		elseif oy >= self.y and ox >= self.x-(oy%1) and ox <= self.x+(oy%1) then --to up
			if self.crossdown then
				travel = "up"
			else
				return false
			end
		elseif oy < self.y and ox >= self.x-(1-(oy%1)) and oy <= self.x+(1-(oy%1)) then --to down
			if self.crossup then
				travel = "down"
			else
				return false
			end
		end
		b.clearpipe = {stage = 1, dir = "forward", travel = travel}
		--get offset
		local addx, addy = 0, 0
		if travel == "right" then
			addx = -1+(b.clearpipe.stage-1)
			b.clearpipe.speed = math.abs(b.speedx)
		elseif travel == "left" then
			addx = 1-(b.clearpipe.stage-1)
			b.clearpipe.speed = math.abs(b.speedx)
		elseif travel == "down" then
			addy = -1+(b.clearpipe.stage-1)
			b.clearpipe.speed = math.abs(b.speedy)
		elseif travel == "up" then
			addy = 1-(b.clearpipe.stage-1)
			b.clearpipe.speed = math.abs(b.speedy)
		end
		--keep object in position
		self:hold(a,b)
	else
		b.clearpipe = {stage = 1, dir = dir}
		if dir == "backwards" then
			if self.t == "pneumatictube" and not self.intersectexit then
				--can't go in the wrong way on a pnematic tube
				b.clearpipe = nil
				return false
			end
			b.clearpipe.stage = #self.path
		end

		if not ((dir == "forward" and self.intersectentrance and (stage and stage <= 2)) or (dir == "backwards" and self.intersectexit and (stage and stage+self.pathoffset >= #self.path-1))) then
			if stage then --start midpipe
				if pipedir == "left" or pipedir == "up" then
					b.clearpipe.stage = stage - self.pathoffset + 1.5--if starting from the middle of the pipe, go to the middle of the stage
				else
					b.clearpipe.stage = stage + self.pathoffset + .5-- + 1.5 --if starting from the middle of the pipe, go to the middle of the stage
				end
			end
			if self.t ~= "pneumatictube" and (not b.noclearpipesound) then
				playsound(clearpipesound)
			end
		end
		if pipedir == "up" or pipedir == "down" then
			b.clearpipe.speed = math.abs(b.speedy)
		else
			b.clearpipe.speed = math.abs(b.speedx)
		end
	end

	table.insert(self.updatetable, {a, b})

	self:initialhold(a, b)
	return true
end

function clearpipe:initialhold(a, b, clearpipedata)
	if clearpipedata then
		b.clearpipe = clearpipedata
		table.insert(self.updatetable, {a, b})
	end

	if a == "player" and not b.invincible then
		b.invincible = true
		b.clearpipeexitinvincibility = 2
	end

	b.clearpipe.gravity = b.gravity
	b.clearpipe.static = b.static
	b.clearpipe.speedx = b.speedx
	b.clearpipe.speedy = b.speedy
	b.gravity = 0
	b.static = true
	if a == "player" then
		b.falling = true
	end
	if b.doclearpipe then
		b:doclearpipe(true)
	end
end

function clearpipe:hold(a, b)
	local addx, addy = 0, 0
	if self.intersection then
		--get offset
		if b.clearpipe.travel == "right" then
			addx = -1+(b.clearpipe.stage-1)
		elseif b.clearpipe.travel == "left" then
			addx = 1-(b.clearpipe.stage-1)
		elseif b.clearpipe.travel == "down" then
			addy = -1+(b.clearpipe.stage-1)
		elseif b.clearpipe.travel == "up" then
			addy = 1-(b.clearpipe.stage-1)
		end
		--keep object in position
		b.x = self.x-1-b.width/2 + addx
		b.y = self.y-1-b.height/2 + addy
	else
		local nextstage
		if b.clearpipe.dir == "forward" then
			nextstage = self.path[self:getstage(b.clearpipe.stage,b.clearpipe.dir)+1]
		else
			nextstage = self.path[self:getstage(b.clearpipe.stage,b.clearpipe.dir)-1]
		end
		local v = (b.clearpipe.stage%1)
		--get offset
		if nextstage and self.path[self:getstage(b.clearpipe.stage,b.clearpipe.dir)] then
			if b.clearpipe.dir == "backwards" then
				addx = nextstage[1]-self.path[self:getstage(b.clearpipe.stage,b.clearpipe.dir)][1]
				addy = nextstage[2]-self.path[self:getstage(b.clearpipe.stage,b.clearpipe.dir)][2]
				v = 1-v
			else
				addx = nextstage[1]-self.path[self:getstage(b.clearpipe.stage,b.clearpipe.dir)][1]
				addy = nextstage[2]-self.path[self:getstage(b.clearpipe.stage,b.clearpipe.dir)][2]
			end
		end
		--keep object in position
		b.x = self.path[self:getstage(b.clearpipe.stage,b.clearpipe.dir)][1]-1-b.width/2 + addx*v
		b.y = self.path[self:getstage(b.clearpipe.stage,b.clearpipe.dir)][2]-1-b.height/2 + addy*v
	end
end

function clearpipe:release(a, b, dir, force)
	if not b then
		return false
	elseif not b.clearpipe then
		
	elseif (dir == "up" and b.clearpipe.dir == "forward") or (dir == "down" and b.clearpipe.dir == "backwards") then
		if self.intersection then
			b.y = self.y-2-b.height
		else
			b.y = self.path[self:getstage(b.clearpipe.stage,b.clearpipe.dir)][2]-1-b.height
		end
		if a ~= "player" then
			if (b.gravity and b.gravity == 0) then
				b.speedx = b.releasespeedx or 0
			else
				b.speedx = b.clearpipe.speedx
			end
		end
		b.speedy = -math.max(clearpipereleasespeed, math.abs(b.clearpipe.speed or b.speedy))
	elseif (dir == "down" and b.clearpipe.dir == "forward") or (dir == "up" and b.clearpipe.dir == "backwards") then
		if self.intersection then
			b.y = self.y
		else
			b.y = self.path[self:getstage(b.clearpipe.stage,b.clearpipe.dir)][2]-1
		end
		if a ~= "player" then
			if (b.gravity and b.gravity == 0) then
				b.speedx = b.releasespeedx or 0
			else
				b.speedx = b.clearpipe.speedx
			end
		end
		b.speedy = math.max(clearpipereleasespeed, math.abs(b.clearpipe.speed or b.speedy))
	elseif (dir == "left" and b.clearpipe.dir == "forward") or (dir == "right" and b.clearpipe.dir == "backwards") then
		if self.intersection then
			b.x = self.x-2-b.width
		else
			b.x = self.path[self:getstage(b.clearpipe.stage,b.clearpipe.dir)][1]-1-b.width
		end
		b.speedy = 0
		if a ~= "player" then
			b.speedx = -math.max(b.releasespeedx or clearpipereleasespeed, math.abs(b.clearpipe.speed or b.speedx))
		else
			b.speedx = -0.1
		end
	elseif (dir == "right" and b.clearpipe.dir == "forward") or (dir == "left" and b.clearpipe.dir == "backwards") then
		if self.intersection then
			b.x = self.x
		else
			b.x = self.path[self:getstage(b.clearpipe.stage,b.clearpipe.dir)][1]-1
		end
		b.speedy = 0
		if a ~= "player" then
			b.speedx = math.max(b.releasespeedx or clearpipereleasespeed, math.abs(b.clearpipe.speed or b.speedx))
		else
			b.speedx = 0.1
		end
	end
	if (not force) and checkintile(b.x+0.1, b.y+0.1, b.width-0.2, b.height-0.2, {}, b, "clearpipe") then
		if b.clearpipe.dir == "forward" then
			b.clearpipe.dir = "backwards"
		else
			b.clearpipe.dir = "forward"
		end
		return false
	end
	if b.clearpipe then
		if not (self.intersection or (b.clearpipe.dir == "backwards" and self.intersectentrance) or (b and b.clearpipe and b.clearpipe.dir == "forward" and self.intersectexit)) then	
			if self.t ~= "pneumatictube" and (not b.noclearpipesound) and (not b.shot) and (not b.delete) then
				playsound(clearpipesound)
			end
		end
		b.gravity = b.clearpipe.gravity
		b.static = b.clearpipe.static
	end
	b.clearpipe = false
	b.static = false

	if b.doclearpipe then
		b:doclearpipe(false)
	end

	return true
end

function clearpipe:draw()
	--Dust
	if self.t == "pneumatictube" and (not self.intersection) and self.suck then
		for i = 1, #self.dusttable do
			local t = self.dusttable[i]
			if not self.intersectentrance then
				local dir = self.entrance
				local cx, cy = self.path[1][1]-1, self.path[1][2]-1
				local x, y, cw, ch, dx, dy = self:getsuck(dir,"entrance",cx,cy)
				local ox, oy = t[1], t[2]*dy+self.sucklen*math.max(0,-dy)
				if dir == "left" or dir == "right" then
					ox, oy = t[2]*dx+self.sucklen*math.max(0,-dx), t[1]
				end
				local v = (t[2]/self.sucklen)
				love.graphics.setColor(255,255,255,255*v)
				love.graphics.draw(dustimg, dustquad[t[5]], (x+ox-xscroll)*16*scale, (y+oy-.5-yscroll)*16*scale, t[3], scale, scale, 8, 8)
				if self.suckentranceportalx then
					local dir = self.suckentranceportalfacing
					local cx, cy = self.suckentranceportalx-1, self.suckentranceportaly-1
					local x, y, cw, ch, dx, dy = self:getsuck(dir,"entrance",cx,cy)
					local ox, oy = t[1], t[2]*dy+self.sucklen*math.max(0,-dy)
					if dir == "left" or dir == "right" then
						ox, oy = t[2]*dx+self.sucklen*math.max(0,-dx), t[1]
					end
					local v = (t[2]/self.sucklen)
					love.graphics.setColor(255,255,255,255*v)
					love.graphics.draw(dustimg, dustquad[t[5]], (x+ox-xscroll)*16*scale, (y+oy-.5-yscroll)*16*scale, t[3], scale, scale, 8, 8)
				end
			end
			if not self.intersectexit then
				local dir = self.exit
				local cx, cy = self.path[#self.path][1]-1, self.path[#self.path][2]-1
				local x, y, cw, ch, dx, dy = self:getsuck(dir,"exit",cx,cy)
				local ox, oy = t[1], t[2]*dy+self.sucklen*math.max(0,-dy)
				if dir == "left" or dir == "right" then
					ox, oy = t[2]*dx+self.sucklen*math.max(0,-dx), t[1]
				end
				local v = 1-(t[2]/self.sucklen)
				love.graphics.setColor(255,255,255,255*v)
				love.graphics.draw(dustimg, dustquad[t[5]], (x+ox-xscroll)*16*scale, (y+oy-.5-yscroll)*16*scale, t[3], scale, scale, 8, 8)
				if self.suckexitportalx then
					local dir = self.suckexitportalfacing
					local cx, cy = self.suckexitportalx-1, self.suckexitportaly-1
					local x, y, cw, ch, dx, dy = self:getsuck(dir,"exit",cx,cy)
					local ox, oy = t[1], t[2]*dy+self.sucklen*math.max(0,-dy)
					if dir == "left" or dir == "right" then
						ox, oy = t[2]*dx+self.sucklen*math.max(0,-dx), t[1]
					end
					local v = 1-(t[2]/self.sucklen)
					love.graphics.setColor(255,255,255,255*v)
					love.graphics.draw(dustimg, dustquad[t[5]], (x+ox-xscroll)*16*scale, (y+oy-.5-yscroll)*16*scale, t[3], scale, scale, 8, 8)
				end
			end
		end
		--[[SUCK DEBUG
		love.graphics.setLineWidth(2*scale)
		local dir = self.entrance
		local cx, cy = self.path[1][1]-1, self.path[1][2]-1
		local cx, cy, cw, ch, dx, dy = self:getsuck(dir,"entrance",cx,cy)
		love.graphics.setColor(255,255,255,180) if self.suckentranceportalx then love.graphics.setColor(255,0,0,180) end
		love.graphics.rectangle("line",(cx-xscroll)*16*scale, (cy-0.5-yscroll)*16*scale, cw*16*scale, ch*16*scale)
		if self.suckentranceportalx then
			local cx, cy = self.suckentranceportalx-1, self.suckentranceportaly-1
			local cx, cy, cw, ch, dx, dy = self:getsuck(self.suckentranceportalfacing,"entrance",cx,cy)
			love.graphics.rectangle("line",(cx-xscroll)*16*scale, (cy-0.5-yscroll)*16*scale, cw*16*scale, ch*16*scale)
		end
		local dir = self.exit
		local cx, cy = self.path[#self.path][1]-1, self.path[#self.path][2]-1
		local cx, cy, cw, ch, dx, dy = self:getsuck(dir,"exit",cx,cy)
		love.graphics.setColor(255,255,255,180) if self.suckexitportalx then love.graphics.setColor(255,0,0,180) end
		love.graphics.rectangle("line",(cx-xscroll)*16*scale, (cy-0.5-yscroll)*16*scale, cw*16*scale, ch*16*scale)
		if self.suckexitportalx then
			local cx, cy = self.suckexitportalx-1, self.suckexitportaly-1
			local cx, cy, cw, ch, dx, dy = self:getsuck(self.suckexitportalfacing,"exit",cx,cy)
			love.graphics.rectangle("line",(cx-xscroll)*16*scale, (cy-0.5-yscroll)*16*scale, cw*16*scale, ch*16*scale)
		end]]
	end

	--[[DEBUG
	for i = 1, #self.path do
		love.graphics.setColor(255, 0, 0, 100)
		love.graphics.rectangle("fill", (self.path[i][1]-1-xscroll)*16*scale, (self.path[i][2]-1.5-yscroll)*16*scale, 16*scale, 16*scale)
		love.graphics.setColor(0, 0, 0, 210)
		love.graphics.circle("fill", (self.path[i][1]-1-xscroll)*16*scale, (self.path[i][2]-1.5-yscroll)*16*scale, 2*scale)
	end]]
end

addsegment = function(x, y, parent, quad, stage, dir, entrance, exit, graphic)
	if not objects["clearpipesegment"][tilemap(x, y)] then
		objects["clearpipesegment"][tilemap(x, y)] = clearpipesegment:new(x, y, parent, quad, stage, dir, entrance, exit, graphic)
	else
		--just add the sprite if a segment already exists
		table.insert(objects["clearpipesegment"][tilemap(x, y)].quad, clearpipequad[quad[1]][quad[2]])
		table.insert(objects["clearpipesegment"][tilemap(x, y)].graphic, graphic)
	end
end
function clearpipe:getstage(v,dir)
	if dir == "forward" then
		return math.max(1, math.min(#self.path, math.floor(v)))
	else
		return math.max(1, math.min(#self.path, math.ceil(v)))
	end
end

function clearpipe:createintersection()
	if self.intersection then
		--intersection
		local tx, ty = self.x, self.y
		local tiles = {
			{5,1},
			{8,1},
			{5,4},
			{8,4}
		}
		self.crossleft = false
		self.crossright = false
		self.crossup = false
		self.crossleft = false
		self.suck = false
		--up
		local s = objects["clearpipesegment"][tilemap(tx-1, ty-2)] --segment
		local s2 = objects["clearpipesegment"][tilemap(tx, ty-2)]
		if s and s2 and (s.dir == "down" or s.dir == "up") then
			if self.crossleft then
				tiles[1] = {3,3}
			else
				tiles[1] = {1,4}
			end
			if self.crossright then
				tiles[2] = {4,3}
			else
				tiles[2] = {2,4}
			end
			if s.entrance then
				s.parent.intersectentrance = true
				s2.parent.intersectentrance = true
			elseif s.exit then
				s.parent.intersectexit = true
				s2.parent.intersectexit = true
			end
			s.quad = {clearpipequad[1][4]}
			s2.quad = {clearpipequad[2][4]}
			self.crossup = true
		end
		--down
		local s = objects["clearpipesegment"][tilemap(tx-1, ty+1)] --segment
		local s2 = objects["clearpipesegment"][tilemap(tx, ty+1)]
		if s and s2 and (s.dir == "up" or s.dir == "down") then
			if self.crossleft then
				tiles[3] = {3,4}
			else
				tiles[3] = {1,4}
			end
			if self.crossright then
				tiles[4] = {4,4}
			else
				tiles[4] = {2,4}
			end
			if s.entrance then
				s.parent.intersectentrance = true
				s2.parent.intersectentrance = true
			elseif s.exit then
				s.parent.intersectexit = true
				s2.parent.intersectexit = true
			end
			s.quad = {clearpipequad[1][4]}
			s2.quad = {clearpipequad[2][4]}
			self.crossdown = true
		end
		--left
		local s = objects["clearpipesegment"][tilemap(tx-2, ty)] --segment
		local s2 = objects["clearpipesegment"][tilemap(tx-2, ty-1)]
		if s and s2 and (s.dir == "right" or s.dir == "left") then
			if self.crossup then
				tiles[1] = {3,3}
			else
				tiles[1] = {2,1}
			end
			if self.crossdown then
				tiles[3] = {3,4}
			else
				tiles[3] = {2,2}
			end
			if s.entrance then
				s.parent.intersectentrance = true
				s2.parent.intersectentrance = true
			elseif s.exit then
				s.parent.intersectexit = true
				s2.parent.intersectexit = true
			end
			s.quad = {clearpipequad[2][2]}
			s2.quad = {clearpipequad[2][1]}
			self.crossleft = true
		end
		--right
		local s = objects["clearpipesegment"][tilemap(tx+1, ty)] --segment
		local s2 = objects["clearpipesegment"][tilemap(tx+1, ty-1)]
		if s and s2 and (s.dir == "left" or s.dir == "right") then
			if self.crossup then
				tiles[2] = {4,3}
			else
				tiles[2] = {2,1}
			end
			if self.crossdown then
				tiles[4] = {4,4}
			else
				tiles[4] = {2,2}
			end
			if s.entrance then
				s.parent.intersectentrance = true
				s2.parent.intersectentrance = true
			elseif s.exit then
				s.parent.intersectexit = true
				s2.parent.intersectexit = true
			end
			s.quad = {clearpipequad[2][2]}
			s2.quad = {clearpipequad[2][1]}
			self.crossright = true
		end
		addsegment(tx-1, ty-1, self, tiles[1], i, "intersection", false, false, self.graphic)
		addsegment(tx, ty-1, self, tiles[2], i, "intersection", false, false, self.graphic)
		addsegment(tx-1, ty, self, tiles[3], i, "intersection", false, false, self.graphic)
		addsegment(tx, ty, self, tiles[4], i, "intersection", false, false, self.graphic)
		self.path = {{self.x, self.y, dir = "right"}}
	end
end

function clearpipe:getsuck(dir,tubeend,cx,cy)
	local dx, dy = 0, 0
	local cw, ch = 2, 2
	
	if dir == "right" then
		dx = 1
		cw = self.sucklen
		cy = cy-1
	elseif dir == "left" then
		dx = -1
		cw = self.sucklen
		cy = cy-1
	elseif dir == "up" then
		dy = -1
		ch = self.sucklen
		intensity = 9
		cx = cx-1
	else
		dy = 1
		ch = self.sucklen
		cx = cx-1
	end
	if tubeend == "entrance" then
		if dir == "right" then
			cx = cx-self.sucklen
		elseif dir == "down" then
			cy = cy-self.sucklen
		end
	else
		if dir == "left" then
			cx = cx-self.sucklen
		elseif dir == "up" then
			cy = cy-self.sucklen
		end
	end
	return cx, cy, cw, ch, dx, dy
end

function clearpipe:suckrange(dir,tubeend,cx,cy,v,dt)
	local cx, cy, cw, ch, dx, dy = self:getsuck(dir,tubeend,cx,cy)
	local intensity = 4
	if dir == "up" then
		intensity = 9
	end
	if inrange(v.x, cx, cx+cw) and inrange(v.y, cy, cy+ch) then
		v.speedx = v.speedx + self.suckspeed*intensity*dx*dt
		v.speedy = v.speedy + self.suckspeed*intensity*dy*dt
	end
end
----------------------------------------------------------------------------------------------
clearpipesegment = class:new()

function clearpipesegment:init(x, y, parent, quad, stage, dir, entrance, exit, graphic)
	--PHYSICS STUFF
	self.cox = x
	self.coy = y
	self.x = x-1
	self.y = y-1
	self.speedx = 0
	self.speedy = 0
	self.width = 1
	self.height = 1
	self.active = true
	self.static = true
	self.category = 2
	self.mask = {true}

	self.emancipatecheck = false
	self.autodelete = false
	self.drawable = false
	self.portalable = false

	self.rotation = 0 --for portals
	self.graphic = {graphic or clearpipeimg}
	self.quadi = {quad[1], quad[2]}
	self.quad = {clearpipequad[quad[1]][quad[2]]}
	self.offsetX = 8
	self.offsetY = 0
	self.quadcenterX = 8
	self.quadcenterY = 8

	self.dir = dir
	self.entrance = entrance or false
	self.exit = exit or false
	self.stage = stage

	if self.entrance or self.exit then
		self.hollow = true
	end
	self.initial = 2

	self.parent = parent
end

function clearpipesegment:update(dt)
	if self.delete then
		return true
	end
	return false
end

function clearpipesegment:draw(drop)
	if onscreen(self.x, self.y, 1, 1) then
		--love.graphics.setColor(255, 255, 255)
		for i = 1, #self.quad do
			love.graphics.draw(self.graphic[i], self.quad[i], math.floor(((self.x-xscroll)*16+self.offsetX)*scale), math.floor(((self.y-yscroll)*16-self.offsetY)*scale), 0, scale, scale, self.quadcenterX, self.quadcenterY)
		end
		if (not drop) and self.initial then
			--convert coin entities into moving tiles
			local x, y = self.cox, self.coy
			if objects["coin"][tilemap(x, y)] then
				objects["coin"][tilemap(x, y)] = nil
				local obj = tilemoving:new(x, y, 116)
				obj.clearpipespeed = 0
				obj.activestatic = true
				table.insert(objects["tilemoving"], obj)
				self:passivecollide("tilemoving", obj)
			end
			self.initial = self.initial - 1
			if self.initial < 1 then
				self.initial = nil
			end
		end
	end
end

function clearpipesegment:hit()
	playsound(blockhitsound)
end

function clearpipesegment:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if (not b.clearpipe) and ((a ~= "player") or (b.falling == false and b.jumping == false )) then
		if self.entrance == "right" then
			self.parent:grab(a, b, "forward")
		elseif self.exit == "left" then
			self.parent:grab(a, b, "backwards")
		end
	end
	return false
end

function clearpipesegment:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if (not b.clearpipe) and ((a ~= "player") or (b.falling == false and b.jumping == false )) then
		if self.entrance == "left" then
			self.parent:grab(a, b, "forward")
		elseif self.exit == "right" then
			self.parent:grab(a, b, "backwards")
		end
	end
	return false
end

function clearpipesegment:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if (not b.clearpipe) and (((a == "player" and downkey(b.playernumber))) or (a ~= "player" and b.speedy > clearpipeenterspeed)) and
		((b.x+b.width/2 > self.x and self.quadi[1] == 1 and self.quadi[2] == 3) 
		or (b.x+b.width/2 < self.x+self.width and self.quadi[1] == 2 and self.quadi[2] == 3)) then
		if self.entrance == "down" then
			self.parent:grab(a, b, "forward")
		elseif self.exit == "up" then
			self.parent:grab(a, b, "backwards")
		end
	end
	return false
end

function clearpipesegment:globalcollide(a, b)
	if not (self.entrance or self.exit or self.dir == "intersection" or self.initial) then
		--don't enter clear pipe if body part
		return true
	end
end

function clearpipesegment:floorcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if (not b.clearpipe) and ((b.x+b.width/2 > self.x and self.quadi[1] == 1 and self.quadi[2] == 5) 
		or (b.x+b.width/2 < self.x+self.width and self.quadi[1] == 2 and self.quadi[2] == 5)) then
		if self.entrance == "up" then
			self.parent:grab(a, b, "forward")
		elseif self.exit == "down" then
			self.parent:grab(a, b, "backwards")
		end
		return false
	end
	if a == "player" and b.speedy < 0 then
		playsound(blockhitsound)
	end
	return false
end

function clearpipesegment:passivecollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	if not b.clearpipe then
		--usually an entity entering from spawn inside a pipe
		local dir = "forward"
		if self.dir == "right" then
			if b.speedx < 0 then
				dir = "backwards"
			end
		elseif self.dir == "left" then
			if b.speedx > 0 then
				dir = "backwards"
			end
		elseif self.dir == "down" then
			if b.speedy < 0 then
				dir = "backwards"
			end
		elseif self.dir == "up" then
			if b.speedy > 0 then
				dir = "backwards"
			end
		end
		--entity entering from intesection
		if self.exit and self.parent.intersectexit then
			dir = "backwards"
		elseif self.entrance and self.parent.intersectentrance then
			dir = "forward"
		end
		self.parent:grab(a, b, dir, self.stage, self.dir)
	end
	return false
end
