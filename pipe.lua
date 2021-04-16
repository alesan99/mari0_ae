pipe = class:new()

function pipe:init(t, x, y, r)
	self.cox = x
	self.coy = y
	self.x = x-1
	self.y = y-1
	self.width = 28/16 --smb: 22/16
	self.height = 26/16
	
	self.active = false
	self.static = true

	self.r = {unpack(r)}
	table.remove(self.r, 1)
	table.remove(self.r, 1)

	self.world = 1
	self.level = 1
	self.sub = 0
	self.exitid = 1

	--defaults
	self.dir = "down"
	self.dir2 = false
	self.exit = false
	self.t = "pipe"
	self.size = "big"
	self.legacy = true
	if t == "pipe" then
		self.dir = "down"
		self.dir2 = "right"
		self.t = "pipe"
	elseif t == "pipe2" then
		self.dir = "up"
		self.dir2 = "left"
		self.t = "pipe"
	elseif t == "pipespawn" then
		self.dir = "up"
		self.dir2 = false
		self.t = "pipespawn"
	elseif t == "pipespawndown" then
		self.dir = "down"
		self.dir2 = false
		self.t = "pipespawn"
	elseif t == "pipespawnhor" then
		self.dir = "right"
		if inmap(x+1, y) and tilequads[map[x+1][y][1]] and tilequads[map[x+1][y][1]]["collision"] then
			self.dir = "left"
		end
		self.dir2 = false
		self.t = "pipespawn"
	elseif t == "warppipe" then
		self.dir = "down"
		self.t = "warppipe"
	end
	
	--right click menu
	if #self.r > 0 and self.r[1] ~= "link" then
		if self.t == "pipe" then
			--target sub, exitid, direction
			local v = convertr(self.r[1], {"num", "num", "string", "string"}, true)
			self.sub = v[1]
			self.exitid = v[2] or 1
			if v[3] then
				self.dir2 = false
				self.dir = v[3]
				self.size = v[4]
				self.legacy = false
			end
		elseif self.t == "pipespawn" then
			--entry sub, exitid, direction
			local v = convertr(self.r[1], {"num", "num", "string", "string"}, true)
			self.sub = v[1]
			self.exitid = v[2] or 1
			if v[3] then
				self.dir = v[3]
				self.size = v[4]
				self.legacy = false
			end
		elseif self.t == "warppipe" then
			--world, level, direction
			local v = convertr(self.r[1], {"string", "num", "string", "string"}, true)

			local world = tonumber(v[1]) or 1
			if not tonumber(v[1]) then
				local f1 = alphabet:find(tostring(v[1]))
				if f1 then
					world = 9+f1
				else
					world = 1
				end
			end
			local worldstring = world
			if hudworldletter and tonumber(world) and world > 9 and world <= 9+#alphabet then
				worldstring = alphabet:sub(world-9, world-9)
			end

			self.worldstring = worldstring
			self.world = world
			self.level = v[2] or 1
			if v[3] then
				self.dir = v[3]
				self.size = v[4]
				self.legacy = false
			end
		end
		table.remove(self.r, 1)
	end

	--set type
	if self.t == "pipe" then
		self.quad = pipesquad[1][self.dir]
	elseif self.t == "pipespawn" then
		--decide if it should be exited from
		local targetsublevel = self.sub or 0
		local exitid = self.exitid or 1
		--testing sublevels (I KNOW YOULL ALSO NEED THIS)
		--print(prevsublevel, mariosublevel, pipeexitid)
		--print(targetsublevel, targetsublevel, exitid)
		if (prevsublevel == targetsublevel or
			(mariosublevel == targetsublevel and blacktime == sublevelscreentime)) and (((not pipeexitid) and exitid == 1) or 
			(pipeexitid == exitid)) then
			pipestartx = x
			pipestarty = y
			pipestartdir = self.dir
		end
		self.exit = true
		self.quad = pipesquad[2][self.dir]
	elseif self.t == "warppipe" then
		--insert warp pipe numbers
		table.insert(warpzonenumbers, {x, y, self.worldstring})
		self.quad = pipesquad[3][self.dir]
	end

	--dir
	self.scissor = {}
	self.scissor["up"] = {self.cox-4, self.coy-1-4, 5, 4}
	self.scissor["down"] = {self.cox-4, self.coy, 5, 4}
	self.scissor["left"] = {self.cox-1-4, self.coy-4, 4, 5}
	self.scissor["right"] = {self.cox, self.coy-4, 4, 5}

	--set size
	if self.size == "big" then
		self.x = x-1
		self.y = y
	elseif self.size == "giant" then
		self.width = self.width*2
		self.height = self.height*2
		self.x = x-2
		self.y = y
	elseif self.size == "small" then
		self.width = 1
		self.height = 1
		self.x = x-.5
		self.y = y
	elseif self.size == "tiny" then
		self.width = 10/16
		self.height = 10/16
		self.x = x-.5
		self.y = y
	end
end

function pipe:draw()
	love.graphics.draw(pipesimg, self.quad, math.floor((self.cox-1-xscroll)*16*scale), ((self.coy-1-yscroll)*16-8)*scale, 0, scale, scale)
end

function pipe:inside(dir, c, b) --direction of entrance, cox or coy, player
	if (not self.exit) then
		local p = b.x+b.width/2
		local px, pw, py, ph = b.x, b.width, b.y, b.height
		if hugemario then --hugemario cheat should still enter pipes i guess
			pw, ph = 24/16, 24/16
			px = b.x+b.width/2-pw/2
			py = b.y+b.height-ph
		end

		local enterdir = false
		if dir == self.dir then --multiple enter directions for backwards compatibility
			enterdir = self.dir
		elseif dir == self.dir2 then
			enterdir = self.dir2
		end

		if enterdir then
			if enterdir == "up" or enterdir == "down" then
				if c == self.coy then
					if (px >= self.x-self.width/2 and px+pw <= self.x+self.width/2) or bigmario then
						return true
					end
				end
			elseif enterdir == "left" or enterdir == "right" then
				if c == self.cox then
					--accurate pipe entering
					--[[if py >= self.y-self.height and py+ph <= self.y then
						return true
					end]]

					--mari0 1.6 pipe entering
					--all it needs is a collision
					if ((ph <= self.height) or bigmario) and --should he fit at all?
						py+ph > self.coy-1 and py < self.coy and --is the player touching the pipe entity
						py+ph*.5 < self.coy then --is the middle of the player within the pipe? (just to make it resonable)
						return true
					end
				end
			end
		end
	end
	return false
end

function pipe:opp(dir)
	if dir == "down" then
		return "up"
	elseif dir == "up" then
		return "down"
	elseif dir == "left" then
		return "right"
	elseif dir == "right" then
		return "left"
	end
end