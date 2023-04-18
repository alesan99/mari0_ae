--[[
	PHYSICS LIBRARY THING
	WRITTEN BY MAURICE GU�GAN FOR MARI0
	DON'T STEAL MY SHIT
	Licensed under the same license as the game itself.
]]--

--MASK REFERENCE LIST
---1: *ALWAYS NOT COLLIDE*

---2: WORLD
---3: MARIO
---4: GOOMBA
---5: KOOPA
---6: MUSHROOM/ONEUP/FLOWER/STAR

---7: GEL DISPENSER
---8: GEL
---9: BOX
--10: SCREENBOUNDARIES
--11: BULLETBILL

--12: PORTALWALLS
--13: FIREBALLS
--14: HAMMERS
--15: PLATFORMS/SEESAWS
--16: BOWSER

--17: FIRE
--18: VINE
--19: SPRING
--20: HAMMERBROS
--21: LAKITO

--22: BUTTON --Not used anymore
--23: CASTLEFIRE
--24: CHEEP CHEEP
--25: DOOR
--26: FAITHPLATE

--27: FLYINGFISH
--28: LIGHTBRIDGE
--29: PLANT
--30: SQUID
--31: UPFIRE

--32: BOMB-OMB/FROZENCOIN
--33: TRACK
local rotatepoint, getslopey

function physicsupdate(dt)
	local lobjects = objects
	
	for j, w in pairs(lobjects) do
		if j ~= "tile" and j ~= "buttonblock" and j ~= "tracksegment" then
			for i, v in pairs(w) do
				local oldspeedx = v.speedx
				local oldspeedy = v.speedy
				if ((v.static == false) or (v.activestatic == true)) and v.active then
					--GRAVITY
					local oldx = v.x
					local oldy = v.y
					local oldgravity
					if (not v.activestatic) and (not v.ignoregravity) then
						--low gravity
						if lowgravity and not v.ignorelowgravity then
							oldgravity = v.gravity
							if v.jumping or (v.falling and v.speedy < 0) then
								v.gravity = (v.gravity or yacceleration)*lowgravityjumpingmult
							else
								v.gravity = (v.gravity or yacceleration)*lowgravitymult
							end
						end
						if j == "player" or v.gravitydir then
							if v.gravitydir == "up" then
								v.speedy = v.speedy - (v.gravity or yacceleration)*dt
								v.speedy = math.max(-maxyspeed, v.speedy)
							elseif v.gravitydir == "right" then
								v.speedx = v.speedx + (v.gravity or yacceleration)*dt
								v.speedx = math.max(-maxyspeed, v.speedx)
							elseif v.gravitydir == "left" then
								v.speedx = v.speedx - (v.gravity or yacceleration)*dt
								v.speedx = math.min(maxyspeed, v.speedx)
							else
								v.speedy = v.speedy + (v.gravity or yacceleration)*dt
								v.speedy = math.min(maxyspeed, v.speedy)
							end
						elseif (j == "goomba" and v.t == "spiketop") or (j == "enemy" and v.movement == "crawl") then
							v.speedy = math.max(-maxyspeed, math.min(maxyspeed, v.speedy + (v.gravity or 0)*dt))
							v.speedx = math.max(-maxyspeed, math.min(maxyspeed, v.speedx + (v.gravityx or 0)*dt))
						else
							v.speedy = v.speedy + (v.gravity or yacceleration)*dt
							v.speedy = math.min(v.maxyspeed or maxyspeed, v.speedy)
							if v.minyspeed then
								v.speedy = math.max(v.minyspeed, v.speedy)
							end
							if v.maxxspeed then
								v.speedx = math.min(v.maxxspeed, v.speedx)
							end
							if v.minxspeed then
								v.speedx = math.max(v.minxspeed, v.speedx)
							end
						end
					end
					v.slopeangle = nil
					
					--PORTALS LOL
					local passed = false
					if v.portalable ~= false then
						if not checkportalVER(v, v.x+v.speedx*dt) then
							if checkportalHOR(v, v.y+v.speedy*dt) then
								passed = true
							end
						else
							passed = true
						end
						
						if passed and j == "player" then
							playsound(portalentersound)
						end
					end
					
					--COLLISIONS ROFL
					local horcollision = false
					local vercollision = false

					
					local latetable = {"portalwall", "castlefirefire", "platform"}
					
					--VS OTHER OBJECTS --but not portalwall
					for h, u in pairs(lobjects) do
						if h ~= "tile" and h ~= "buttonblock" and h ~= "tracksegment" then
							local pass = true
							for k, l in pairs(latetable) do
								if h == l then
									pass = false
									break
								end
							end

							if pass then
								local hor, ver = handlegroup(i, h, u, v, j, dt, passed)
								if hor then
									horcollision = true
								end
								if ver then
									vercollision = true
								end
							end
						end
					end
					
					--VS TILES (Because I only wanna check close ones)
					local xstart = math.ceil(v.x+v.speedx*dt)
					local ystart = math.ceil(v.y+v.speedy*dt)
					
					local xfrom = xstart
					local xto = math.floor(v.x+v.width+v.speedx*dt)+1
					local yto = math.floor(v.y+v.height+v.speedy*dt)+1
					local dir = 1
					
					if v.speedx < 0 then
						xfrom, xto = xto, xfrom
						dir = -1
					end
					for x = xfrom, xto, dir do
						for y = ystart, yto do
							--check if invisible block
							if inmap(x, y) and ((not tilequads[map[x][y][1]]:getproperty("invisible", x, y)) or j == "player") then
								local t = lobjects["tile"][tilemap(x, y)]
								if t then
									--    Same object             Active                  Not masked
									if (i ~= g or j ~= h) and (t.active or t.SLOPE) and v.mask[t.category] ~= true then
										--slants
										local collision1, collision2
										if t.SLOPE then
											collision1, collision2 = checkcollisionslope(v, t, "tile", tilemap(x, y), j, i, dt, passed)
										else
											collision1, collision2 = checkcollision(v, t, "tile", tilemap(x, y), j, i, dt, passed)
										end
										if collision1 then
											horcollision = true
										elseif collision2 then
											vercollision = true
										end
									end
								end
							end
							--check for button blocks
							local t = lobjects["buttonblock"][tilemap(x, y)]
							if t then
								if (i ~= g or j ~= h) and t.active and v.mask[t.category] ~= true then
									local collision1, collision2 = checkcollision(v, t, "buttonblock", tilemap(x, y), j, i, dt, passed)
									if collision1 then horcollision = true
									elseif collision2 then vercollision = true end
								end
							end
							--check for tracks
							local t = lobjects["tracksegment"][tilemap(x, y)]
							if t then
								if (i ~= g or j ~= h) and t.active and v.mask[t.category] == false and (not v.tracked) then
									local collision1, collision2 = checkcollision(v, t, "tracksegment", tilemap(x, y), j, i, dt, passed)
									if collision1 then horcollision = true
									elseif collision2 then vercollision = true end
								end
							end
						end
					end

					--Track Carrying
					if v.trackplatformcarriedx then
						v.trackplatformcarriedx = nil
					end
					
					--VS: LATE OBJECTS
					for g, h in pairs(latetable) do
						local u = objects[h]
						local hor, ver = handlegroup(i, h, u, v, j, dt, passed)
						if hor then
							horcollision = true
						end
						if ver then
							vercollision = true
						end
					end
					
					--Check for emancipation grill
					if v.emancipatecheck then
						for h, u in pairs(emancipationgrills) do
							if u.active and v.emancipate then
								if u.dir == "hor" then
									if inrange(v.x+6/16, u.startx-1, u.endx, true) and inrange(u.y-14/16, oldy, v.y+v.speedy*dt, true) then
										v:emancipate(h)
									end
								else
									if inrange(v.y+6/16, u.starty-1, u.endy, true) and inrange(u.x-14/16, oldx, v.x+v.speedx*dt, true) then
										v:emancipate(h)
									end
								end
							end
						end
					end

					--Stick to slopes
					local fx = v.x + v.speedx*dt --future x
					local fy = v.y + v.speedy*dt --future x
					local stucktoslope = false
					if (not v.activestatic) and v.mask[2] ~= true and ((not v.gravity) or v.gravity > 0) and v.speedy >= 0 and math.abs(v.speedx) > 0.0001 and horcollision == false then
						local leftedge = v.x
						local rightedge = v.x+v.width
						local fleftedge = fx
						local frightedge = fx+v.width

						local y1 = math.floor(v.y+v.height)+1
						local x1, x2 = math.floor(frightedge)+1, math.floor(fleftedge)+1

						local x
						local y = y1

						--TODO: Clean up code
						local stick = false
						if ismaptile(x1, y1) and v.speedx < 0 then --check for left slope under right edge
							local tq = tilequads[map[x1][y1][1] ]
							if tq:getproperty("collision", x1, y1) and tq.leftslant and not tq.downslant then
								x = x1
								stick = true
							end
						end
						if ismaptile(x2, y1) and v.speedx > 0 then --check for right slope under left edge
							local tq = tilequads[map[x2][y1][1] ]
							if tq:getproperty("collision", x2, y1) and tq.rightslant and not tq.downslant then
								x = x2
								stick = true
							end
						end
						if ismaptile(x1, y1+1) and v.speedx < 0 and not x then --check for left slope under right edge
							local tq = tilequads[map[x1][y1+1][1] ]
							if tq:getproperty("collision", x1, y1+1) and tq.leftslant and not tq.downslant then
								x = x1
								y = y1+1
								stick = true
							end
						end
						if ismaptile(x2, y1+1) and v.speedx > 0 and not x then --check for right slope under left edge
							local tq = tilequads[map[x2][y1+1][1] ]
							if tq:getproperty("collision", x2, y1+1) and tq.rightslant and not tq.downslant then
								x = x2
								y = y1+1
								stick = true
							end
						end
						local t
						if x then --try to stick
							if ismaptile(x, y) then
								t = objects["tile"][tilemap(x,y)]
								if t and t.SLOPE then
									local tq = tilequads[map[x][y][1] ]
									local inside, diff, angle, realangle = insideslope(v.x,v.y,v.width,v.height, t.x,t.y+t.y1,t.x+t.width,t.y+t.y2, t.UPSIDEDOWNSLOPE)
									local location, flocation
									if tq.leftslant then
										location = rightedge-t.x
										flocation = frightedge-t.x
									elseif tq.rightslant then
										location = leftedge-t.x
										flocation = fleftedge-t.x
									end
									--location = math.max(0, math.min(1, location))
									flocation2 = flocation --unbounded
									--flocation = math.max(0, math.min(1, flocation)) --bounded to tile
									local targety = t.y+getslopey(flocation, t.y1, t.y2)
									local targety2 = t.y+getslopey(flocation2, t.y1, t.y2)
									local currentground = (t.y+getslopey(location, t.y1, t.y2))
									local rangey = targety2-currentground --make sure it only sticks if reasonably close to slope
									local platformpass = true
									local onlyplatform = (t.PLATFORM == true and t.PLATFORMDOWN == nil and t.PLATFORMLEFT == nil and t.PLATFORMRIGHT == nil)
									if onlyplatform and not (diff <= 1e-1) then
										platformpass = false
									end
									if v.y+v.height >= currentground-rangey-0.00001 and platformpass then
										stucktoslope = targety-v.height
										v.slopeangle = realangle
									end
								end
							end
						end
						if stucktoslope then
							if v.floorcollide then
								v:floorcollide("tile", t, dt)
							end
							if v.speedy > 0 then
								v.speedy = 0
							end
						end
					end
					
					--Move the object
					if vercollision == false and not v.activestatic then
						v.y = v.y + v.speedy*dt
						--if not stucktoslope then
							if v.gravity then
								if v.startfall then
									if (not (v.stopjump and v.jumping)) and (not v.quicksand) then
										if v.gravitydir then
											if (v.gravitydir == "down" and v.speedy == oldspeedy + v.gravity*dt) or (v.gravitydir == "up" and v.speedy == oldspeedy - v.gravity*dt) then
												v:startfall(i)
											end
										elseif v.speedy == oldspeedy + v.gravity*dt then
											v:startfall(i)
										end
									end
								end
							else
								if v.speedy == oldspeedy + yacceleration*dt and v.startfall then
									v:startfall(i)
								end
							end
						--end
					end
					
					if horcollision == false and not v.activestatic then
						if v.slopeangle then
							rotspeedx, _ = rotatepoint(v.speedx, 0, -v.slopeangle-math.pi)
							v.x = v.x + rotspeedx*dt
							if v.slopeposty then
								v.y = v.slopeposty
							end
						else
							v.x = v.x + v.speedx*dt
						end
						
						if stucktoslope then
							v.y = stucktoslope
						end
						if v.gravity then
							if v.startfall then
								if (not (v.stopjump and v.jumping)) and (not v.quicksand) then
									if v.gravitydir then
										if (v.gravitydir == "right" and v.speedx == oldspeedx + v.gravity*dt) or (v.gravitydir == "left" and v.speedx == oldspeedx - v.gravity*dt) then
											v:startfall(i)
										end
									end
								end
							end
						end
					end
					
					--check if object is inside portal
					if v.portalable ~= false then
						inportal(v)
					end

					--low gravity
					if not v.activestatic then
						if lowgravity and not v.ignorelowgravity then
							v.gravity = oldgravity
						end
					end
				end
			end
		end
	end
end

function handlegroup(i, h, u, v, j, dt, passed)
	local horcollision = false
	local vercollision = false
	for g, t in pairs(u) do
		--    Same object?          Active                 Not masked
		if (i ~= g or j ~= h) and t.active and (v.mask == nil or v.mask[t.category] ~= true) and (t.mask == nil or t.mask[v.category] ~= true) then
			local collision1, collision2 = checkcollision(v, t, h, g, j, i, dt, passed)
			if collision1 then
				horcollision = true
			elseif collision2 then
				vercollision = true
			end
		end
	end
	
	return horcollision, vercollision
end

function checkcollision(v, t, h, g, j, i, dt, passed) --v: b1table | t: b2table | h: b2type | g: b2id | j: b1type | i: b1id
	local hadhorcollision = false
	local hadvercollision = false
	
	if math.abs(v.x-t.x) < math.max(v.width, t.width)+1 and math.abs(v.y-t.y) < math.max(v.height, t.height)+1 then
		--check if it's a passive collision (Object is colliding anyway)
		if not passed and aabb(v.x, v.y, v.width, v.height, t.x, t.y, t.width, t.height) then --passive collision! (oh noes!)
			if passivecollision(v, t, h, g, j, i, dt) then
				hadvercollision = true
			end
			
		elseif aabb(v.x + v.speedx*dt, v.y + v.speedy*dt, v.width, v.height, t.x, t.y, t.width, t.height) then
			if aabb(v.x + v.speedx*dt, v.y, v.width, v.height, t.x, t.y, t.width, t.height) then --Collision is horizontal!
				if horcollision(v, t, h, g, j, i, dt) then
					hadhorcollision = true
				end
				
			elseif aabb(v.x, v.y+v.speedy*dt, v.width, v.height, t.x, t.y, t.width, t.height) then --Collision is vertical!
				if vercollision(v, t, h, g, j, i, dt) then
					hadvercollision = true
				end
				
			else 
				--We're fucked, it's a diagonal collision! run!
				--Okay actually let's take this slow okay. Let's just see if we're moving faster horizontally than vertically, aight?
				local grav = yacceleration
				if self and self.gravity then
					grav = self.gravity
				end
				if math.abs(v.speedy-grav*dt) < math.abs(v.speedx) then
					--vertical collision it is.
					if vercollision(v, t, h, g, j, i, dt) then
						hadvercollision = true
					end
				else 
					--okay so we're moving mainly vertically, so let's just pretend it was a horizontal collision? aight cool.
					if horcollision(v, t, h, g, j, i, dt) then
						hadhorcollision = true
					end
				end
			end
		end
	end
	
	return hadhorcollision, hadvercollision
end

function cancollideside(t, side, v)
	local safe = (not t.PLATFORM) and (not t.PLATFORMDOWN) and (not t.PLATFORMLEFT) and (not t.PLATFORMRIGHT) --no platform collisions
	if v then
		if v.overridesemisolids then
			return true
		elseif v.ignoresemisolids then
			return not (t.PLATFORM or t.PLATFORMDOWN or t.PLATFORMLEFT or t.PLATFORMRIGHT or t.NOEXTERNALHORCOLLISIONS or t.NOEXTERNALVERCOLLISIONS)
		end
	end
	if side == "up" then --top
		return (safe or t.PLATFORM)
	elseif side == "down" then
		return (safe or t.PLATFORMDOWN)
	elseif side == "left" then
		return (safe or t.PLATFORMLEFT)
	elseif side == "right" then
		return (safe or t.PLATFORMRIGHT)
	elseif side =="passive" then
		return safe
	end
end

function checkcollisionslope(v, t, h, g, j, i, dt, passed) --v: b1table | t: b2table | h: b2type | g: b2id | j: b1type | i: b1id
	local hadhorcollision = false
	local hadvercollision = false
	
	--if math.abs(v.x-t.x) < math.max(v.width, t.width)+1 and math.abs(v.y-t.y) < math.max(v.height, t.height)+1 then
		local insideaabb = aabb(v.x, v.y, v.width, v.height, t.x, t.y, t.width, t.height)
		local finsideaabb = aabb(v.x+v.speedx*dt, v.y+v.speedy*dt, v.width, v.height, t.x, t.y, t.width, t.height)
		local inside, diff, angle, realangle = insideslope(v.x,v.y,v.width,v.height, t.x,t.y+t.y1,t.x+t.width,t.y+t.y2, t.UPSIDEDOWNSLOPE)
		local finside, fdiff, fangle, frealangle = insideslope(v.x + v.speedx*dt,v.y + v.speedy*dt,v.width,v.height, t.x,t.y+t.y1,t.x+t.width,t.y+t.y2, t.UPSIDEDOWNSLOPE)
		local sright, sleft = t.slant == "right", t.slant == "left"
		--is it on the slope part of the block?
		local inslantrange = false
		if sright then
			if v.x > t.x or v.x+v.speedx*dt > t.x then
				inslantrange = true
			end
		elseif sleft then
			if v.x+v.width < t.x+t.width or v.x+v.width+v.speedx*dt < t.x+t.width then
				inslantrange = true
			end
		end
		--is it going in a direction that should intersect with the slope?
		local rotx, roty = rotatepoint(v.x, v.y, realangle)
		local rotfx, rotfy = rotatepoint(v.x+v.speedx*dt, v.y+v.speedy*dt, realangle)
		local diffy = rotfy-roty
		--Check if movement ray intersects slope line
		local inslopedirection = false
		if (not t.UPSIDEDOWNSLOPE) then
			inslopedirection = (diffy <= 0)
		else
			inslopedirection = (diffy >= 0)
		end

		--Check if slopes should act like platform tile (only up collision enabled)
		local onlyplatform = cancollideside(t, "up") and (not cancollideside(t, "down")) and (not cancollideside(t, "left")) and (not cancollideside(t, "right"))
		local platformpass = true
		if onlyplatform and not inslantrange then
			platformpass = false
		end
		
		--target y position
		local location = v.x-t.x
		if sleft then location = v.x+v.width-t.x end
		location = math.max(0, math.min(1, location))
		local ty = t.y+getslopey(location, t.y1, t.y2) --, v.y+v.speedy*dt)
		if not t.UPSIDEDOWNSLOPE then
			ty = ty - v.height
		else
			ty = ty
		end

		local docollide = inslopedirection and (insideaabb) and finside and (diff >= -math.max(0.1,math.abs(diffy)) or math.abs((ty-v.y)) < v.height)
		--there's no mathematical basis for the last comparison, (diff > diffy) but it solves weird bottom slope collision when a normal slope is above it for now
		if onlyplatform then --use more complicated (and unreliable) method to check platform slope intersections
			docollide = inslopedirection and ((insideaabb or finsideaabb) and finside) and (diff <= 1e-1 or (not insideaabb)) and platformpass
		end
		
		if not passed and docollide then
			--sloped side collision

			local collided = false
			if (not t.UPSIDEDOWNSLOPE) and ty-v.height < v.y+v.speedy*dt then
				collided = true
			elseif t.UPSIDEDOWNSLOPE and ty > v.y+v.speedy*dt then
				collided = true
			end

			if collided then
				local ydir = 1
				if t.UPSIDEDOWNSLOPE then ydir = -1 end
				t.ignorecheckintile = true
				local insidetile = checkintile(v.x, v.y, v.width, v.height, nil, v, "ignoreslopes")
				t.ignorecheckintile = false
				if v.activestatic then --Don't push at all
					passivecollision(v, t, h, g, j, i, dt) 
				elseif checkintile(v.x, ty, v.width, v.height, nil, v, "ignoreslopes") and ((sleft and v.speedx > 0) or (sright and v.speedx < 0)) then
					if horcollision(v, t, h, g, j, i, dt, "dontpush", ydir) then
						hadhorcollision = true
						hadvercollision = true
						v.speedy = 0
					end
				elseif vercollision(v, t, h, g, j, i, dt, "dontpush", ydir) then
					hadvercollision = true
					if v.slopeangle and ty > v.y then --don't move object down if its already on a higher slope
						return hadhorcollision, hadvercollision
					end
					v.y = ty
					v.slopeangle = realangle

					--Object has just been pushed out of the slope vertically, but will need to be pushed vertically again later after it moves
					--Unfortunately needed for slopes to work with fast objects at low framerates
					local rotspeedx, _ = rotatepoint(v.speedx, 0, -v.slopeangle-math.pi)
					local postx = v.x+rotspeedx*dt
					local postlocation = postx-t.x
					if sleft then
						postlocation = postx+v.width-t.x
					end
					postlocation = math.max(0, math.min(1, postlocation))
					local postty = t.y+getslopey(postlocation, t.y1, t.y2) --, v.y+v.speedy*dt)
					if not t.UPSIDEDOWNSLOPE then
						v.slopeposty = postty-v.height
					else
						v.slopeposty = postty
					end
					 --TODO: Calculate a lower speedy incase the object will still be inside the slope next frame (aka sliding along ceiling slopes)
				end
			end
		elseif aabb(v.x + v.speedx*dt, v.y + v.speedy*dt, v.width, v.height, t.x, t.y, t.width, t.height) then
			--flat side collision
			local boundingy      = t.y+math.min(t.y1,t.y2)
			local boundingheight = 1-math.min(t.y1,t.y2)
			local lefty = t.y+t.y1
			local leftheight = 1-t.y1
			local righty = t.y+t.y2
			local rightheight = 1-t.y2
			if t.UPSIDEDOWNSLOPE then
				boundingy = t.y
				boundingheight = math.max(t.y1,t.y2)
				lefty = t.y
				leftheight = t.y1
				righty = t.y
				rightheight = t.y2
			end

			local i01 = aabb(v.x+v.speedx*dt, v.y+v.speedy*dt, v.width, v.height, t.x, boundingy, t.width, boundingheight)

			local i11 = aabb(v.x + v.speedx*dt, v.y, v.width, v.height, t.x, lefty, t.width, leftheight)
			local i12 = not aabb(v.x, v.y, v.width, v.height, t.x, lefty, t.width, leftheight)

			local i21 = aabb(v.x + v.speedx*dt, v.y, v.width, v.height, t.x, righty, t.width, rightheight)
			local i22 = not aabb(v.x, v.y, v.width, v.height, t.x, righty, t.width, rightheight)

			local i31 = aabb(v.x, v.y+v.speedy*dt, v.width, v.height, t.x, boundingy, t.width, boundingheight)

			if not t.UPSIDEDOWNSLOPE then --Diagonal Collisions
				if v.speedx > 0 and v.speedy > 0 then
					if (not i11) and (not i31) and i01 then
						if math.abs(v.speedx) > math.abs(v.speedy) then
							i31 = true
						else
							i11 = true
						end
					end
				elseif v.speedx > 0 and v.speedy < 0 then
					if (not i11) and (not i31) and i01 then
						if math.abs(v.speedx) > math.abs(v.speedy) then
							i31 = true
						else
							i11 = true
						end
					end
				elseif v.speedx < 0 and v.speedy > 0 then
					if (not i21) and (not i31) and i01 then
						if math.abs(v.speedx) > math.abs(v.speedy) then
							i31 = true
						else
							i21 = true
						end
					end

				elseif v.speedx < 0 and v.speedy < 0 then
					if (not i21) and (not i31) and i01 then
						if math.abs(v.speedx) > math.abs(v.speedy) then
							i31 = true
						else
							i21 = true
						end
					end
				end
			end

			if sright and v.speedx > 0 and i11 and i12 then --Collision is horizontal!
				if horcollision(v, t, h, g, j, i, dt) then
					hadhorcollision = true
				end
			elseif sleft and v.speedx < 0 and i21 and i22 then --Collision is horizontal!
				if horcollision(v, t, h, g, j, i, dt) then
					hadhorcollision = true
				end
			elseif v.speedy > 0 and i31 and ((t.UPSIDEDOWNSLOPE and v.y+v.height <= t.y) or ((not t.UPSIDEDOWNSLOPE) and not inslantrange)) then --Collision is vertical!
				local platformpass = true
				if onlyplatform and ((v.y+v.height > boundingy) or t.platformslopenotopcollision) then
					platformpass = false
				end
				if platformpass and vercollision(v, t, h, g, j, i, dt, "dontpush") then
					v.y = boundingy - v.height
					hadvercollision = true
				end
			elseif v.speedy < 0 and i31 and v.y > t.y+t.height and ((not t.UPSIDEDOWNSLOPE) or (not inslantrange)) then --Collision is vertical!
				if vercollision(v, t, h, g, j, i, dt, "dontpush") then
					v.y = boundingy + boundingheight
					hadvercollision = true
				end
			end
		end
	--end
	
	return hadhorcollision, hadvercollision
end

function passivecollision(v, t, h, g, j, i, dt)
	if not cancollideside(t,"passive",v) then
		return false
	end
	if v.passivecollide then
		if not t.hollow then
			if v:passivecollide(h, t) ~= false and v.movetotoponpassivecollide then
				if v.speedy > 0 then
					v.speedy = 0
				end
				v.y = t.y - v.height
				return true
			end
		end
		if t.passivecollide and not v.hollow then
			t:passivecollide(j, v)
		end
	else
		if not t.hollow then
			if v.floorcollide then
				if v:floorcollide(h, t, dt) ~= false then
					if v.speedy > 0 then
						v.speedy = 0
					end
					v.y = t.y - v.height
					return true
				end
			else
				if v.speedy > 0 then
					v.speedy = 0
				end
				v.y = t.y - v.height
				return true
			end
		end
	end
	
	return false
end

function horcollision(v, t, h, g, j, i, dt, dontpush)
	if v.speedx < 0 then
		--move object RIGHT (because it was moving left)
		if not (cancollideside(v, "left", t) and ((not t.nointernalplatform) or cancollideside(t, "right"))) then
		elseif t.rightcollide then
			if t:rightcollide(j, v) ~= false then
				if t.postrightcollide then
					t:postrightcollide(j,v)
				end
				if t.speedx and t.speedx > 0 then
					t.speedx = 0
				end
			end
		else
			if t.speedx and t.speedx > 0 then
				t.speedx = 0
			end
		end

		if not (cancollideside(t, "right", v) and ((not v.nointernalplatform) or cancollideside(v, "left")) and (not t.NOEXTERNALHORCOLLISIONS)) then
			return false
		elseif v.leftcollide then
			if v:leftcollide(h, t) ~= false then
				if v.postleftcollide then
					v:postleftcollide(h,t)
				end
				if v.speedx < 0 then
					v.speedx = 0
				end
				if not dontpush then
					v.x = t.x + t.width
				end
				return true
			end
		else
			if v.speedx < 0 then
				v.speedx = 0
			end
			if not dontpush then
				v.x = t.x + t.width
			end
			return true
		end
	else
		--move object LEFT (because it was moving right)
		if not (cancollideside(v, "right", t) and ((not t.nointernalplatform) or cancollideside(t, "left"))) then
		elseif t.leftcollide then
			if t:leftcollide(j, v) ~= false then
				if t.postleftcollide then
					t:postleftcollide(j,v)
				end
				if t.speedx and t.speedx < 0 then
					t.speedx = 0
				end
			end
		else
			if t.speedx and t.speedx < 0 then
				t.speedx = 0
			end
		end
		
		if not (cancollideside(t, "left", v) and ((not v.nointernalplatform) or cancollideside(v, "right")) and (not t.NOEXTERNALHORCOLLISIONS)) then
			return false
		elseif v.rightcollide then
			if v:rightcollide(h, t) ~= false then
				if v.postrightcollide then
					v:postrightcollide(h,t)
				end
				if v.speedx > 0 then
					v.speedx = 0
				end
				if not dontpush then
					v.x = t.x - v.width
				end
				return true
			end
		else
			if v.speedx > 0 then
				v.speedx = 0
			end
			if not dontpush then
				v.x = t.x - v.width
			end
			return true
		end
	end
	
	return false
end

function vercollision(v, t, h, g, j, i, dt, dontpush, ydir)
	if (ydir or v.speedy) < 0 then
		--move object DOWN (because it was moving up)
		if not (cancollideside(v, "up", t) and ((not t.nointernalplatform) or cancollideside(t, "down"))) then
		elseif t.floorcollide then
			if t:floorcollide(j, v) ~= false then
				if t.postfloorcollide then
					t:postfloorcollide(j, v)
				end
				if t.speedy and t.speedy > 0 then
					t.speedy = 0
				end
			end
		else
			if t.speedy and t.speedy > 0 then
				t.speedy = 0
			end
		end
		
		if not (cancollideside(t, "down", v) and ((not v.nointernalplatform) or cancollideside(v, "up")) and (not t.NOEXTERNALVERCOLLISIONS)) then
			return false
		elseif v.ceilcollide then
			if v:ceilcollide(h, t) ~= false then
				if v.postceilcollide then
					v:postceilcollide(h, t)
				end
				if v.speedy < 0 then
					v.speedy = 0
				end
				if not dontpush then
					v.y = t.y  + t.height
				end
				return true
			end
		else
			if v.speedy < 0 then
				v.speedy = 0
			end
			if not dontpush then
				v.y = t.y  + t.height
			end
			return true
		end
	else					
		--move object UP (because it was moving down)
		if not (cancollideside(v, "down", t) and ((not t.nointernalplatform) or cancollideside(t, "up"))) then
		elseif t.ceilcollide then
			if t:ceilcollide(j, v) ~= false then
				if t.postceilcollide then
					t:postceilcollide(j, v)
				end
				if t.speedy and t.speedy < 0 then
					t.speedy = 0
				end
			end
		else
			if t.speedy and t.speedy < 0 then
				t.speedy = 0
			end
		end

		if not (cancollideside(t, "up", v) and ((not v.nointernalplatform) or cancollideside(v, "down")) and (not t.NOEXTERNALVERCOLLISIONS)) then
			return false
		elseif v.floorcollide then
			if v:floorcollide(h, t, dt) ~= false then
				if v.postfloorcollide then
					v:postfloorcollide(h, t, dt)
				end
				if v.speedy > 0 then
					v.speedy = 0
				end
				if not dontpush then
					v.y = t.y - v.height
				end
				return true
			end
		else
			if v.speedy > 0 then
				v.speedy = 0
			end
			if not dontpush then
				v.y = t.y - v.height
			end
			return true
		end
	end
	return false
end

function aabb(ax, ay, awidth, aheight, bx, by, bwidth, bheight)
	return ax+awidth > bx and ax < bx+bwidth and ay+aheight > by and ay < by+bheight
end

function rotatepoint(x,y,a)
	return (x*math.cos(a)-y*math.sin(a)), (x*math.sin(a)+y*math.cos(a))
end
function getslopeangle(sx1,sy1,sx2,sy2)
	local realangle = math.atan2(-(sy1-sy2), (sx1-sx2))
	local angle = realangle+math.pi*0.5 --find angle of slope
	return angle, realangle
end
function getslopey(location, y1, y2)
	return y1+((y2-y1)*location)
end
function insideslope(x,y,w,h, sx1,sy1,sx2,sy2, upsidedown)
	--check if rectangle is below or above an infinite sloped line
	local angle, realangle = getslopeangle(sx1,sy1,sx2,sy2)
	local linex, liney = rotatepoint(sx1,sy1, angle) --rotate line to create a flat level ground
	local p = {x,y, x+w,y, x+w,y+h, x,y+h}
	local pmin, pmax = math.huge, -math.huge
	for pi = 1, #p, 2 do --rotate all rectangle points to match the new flat level ground
		local px1,py1 = rotatepoint(p[pi],p[pi+1], angle)
		pmin=math.min(pmin,px1)
		pmax=math.max(pmax,px1)
	end
	--check if rectangle is below (or above) the flat level ground
	if upsidedown then
		return pmin < linex, pmin-linex, angle, realangle
	else
		return pmax > linex, pmax-linex, angle, realangle --inside?, diff, angle of slope
	end
end

function checkrect(x, y, width, height, list, statics, condition)
	local out = {}
	
	local inobj
	
	if type(list) == "table" and list[1] == "exclude" then
		inobj = list[2]
		if list[3] then
			list = list[3] --exlude more objects named
		else
			list = "all"
		end
	end

	for i, v in pairs(objects) do
		local contains = false
		
		if list and list ~= "all" then	
			if inobj then
				--exlude more objects rather than include
				contains = true
			end
			for j = 1, #list do
				if list[j] == i then
					if inobj then
						contains = false
					else
						contains = true
					end
				end
			end
		end
		
		if list == "all" or contains then
			for j, w in pairs(v) do
				if statics or w.static ~= true or list ~= "all" then
					local skip = false
					if inobj then
						if w.x == inobj.x and w.y == inobj.y then
							skip = true
						end
						--masktable
						if (inobj.mask ~= nil and inobj.mask[w.category] == true) or (w.mask ~= nil and w.mask[inobj.category] == true) or (w.ignorecheckrect and w.ignorecheckrect[w.category]) then
							skip = true
						end
					end
					if condition then
						if condition == "regiontrigger" then
							if w.regiontriggerexclude then
								skip = true
							end
						elseif condition == "ignoreplatforms" then
							if w.PLATFORM or w.PLATFORMDOWN or w.PLATFORMLEFT or w.PLATFORMRIGHT then
								skip = true
							end
						elseif condition == "donut" then
							if inobj then
								if w.y < inobj.y+inobj.height then
									skip = true
								end
							else
								if w.y < y then
									skip = true
								end
							end
						elseif condition == "laser" then
							if w.dontstoplasers then
								skip = true
							end
						end
					end
					if not skip then
						if w.active then
							local inside = aabb(x, y, width, height, w.x, w.y, w.width, w.height)
							if w.SLOPE then
								inside = inside and insideslope(x,y,width,height, w.x,w.y+w.y1,w.x+w.width,w.y+w.y2, w.UPSIDEDOWNSLOPE)
							end
							if inside then
								table.insert(out, i)
								table.insert(out, j)
							end
						end
					end
				end
			end
		end
	end
	
	return out
end

function checkintile(x, y, width, height, list, inobj, condition)
	--local out = {}
	local inobj = inobj

	if list then
		for i, v in pairs(list) do
			if v ~= "tile" and v ~= "buttonblock" and v ~= "clearpipesegment" and v ~= "flipblock" and v ~= "frozencoin" then
				for j, w in pairs(objects[v]) do
					local skip = false
					if inobj then
						--[[if w.x == inobj.x and w.y == inobj.y then
							skip = true
						end]]
						--masktable
						if (inobj.mask ~= nil and inobj.mask[w.category] == true) or (w.mask ~= nil and w.mask[inobj.category] == true) then
							skip = true
						end
					end
					if condition then
						if condition == "ignoreplatforms" then
							if w.PLATFORM or w.PLATFORMDOWN or w.PLATFORMLEFT or w.PLATFORMRIGHT then
								skip = true
							end
						elseif condition == "ignorehorplatforms" then
							if w.PLATFORM or w.PLATFORMDOWN then
								skip = true
							end
						end
					end
					if not skip then
						if w.active then
							local inside = aabb(x, y, width, height, w.x, w.y, w.width, w.height)
							if inside then
								return w
							end
						end
					end
				end
			end
		end
	end

	local xfrom, xto = math.floor(x-1), math.floor(x+width+1)
	local yfrom, yto = math.floor(y-1), math.floor(y+height+1)
	for tx = xfrom, xto do
		for ty = yfrom, yto do
			if inmap(tx, ty) then
				local t = objects["tile"][tilemap(tx, ty)]
				if t and t.active then
					local skip = false
					if condition then
						if condition == "ignoreplatforms" or condition == "clearpipe" then
							if t.PLATFORM or t.PLATFORMDOWN or t.PLATFORMLEFT or t.PLATFORMRIGHT then
								skip = true
							end
						elseif condition == "ignorehorplatforms" then
							if t.PLATFORM or t.PLATFORMDOWN then
								skip = true
							end
						elseif condition == "ignoreslopes" then
							if (t.SLOPE and (not t.UPSIDEDOWNSLOPE) and y+height < t.y+t.height) or (t.ignorecheckintile) or (t.PLATFORM or t.PLATFORMDOWN or t.PLATFORMLEFT or t.PLATFORMRIGHT) then
								skip = true
							end
						end
						if condition == "clearpipe" and objects["clearpipesegment"][tilemap(tx, ty)] then
							skip = true
						end
					end
					if not skip then
						local inside = aabb(x, y, width, height, t.x, t.y, t.width, t.height)
						if t.SLOPE then
							inside = inside and insideslope(x,y,width,height, t.x,t.y+t.y1,t.x+t.width,t.y+t.y2, t.UPSIDEDOWNSLOPE)
						end
						if inside then
							return t
						end
					end
				end
				local t = objects["buttonblock"][tilemap(tx, ty)]
				if t and t.active then
					if aabb(x, y, width, height, t.x, t.y, t.width, t.height) then
						return t
					end
				end
				local t = objects["flipblock"][tilemap(tx, ty)]
				if t and t.active then
					if aabb(x, y, width, height, t.x, t.y, t.width, t.height) then
						return t
					end
				end
				local t = objects["frozencoin"][tilemap(tx, ty)]
				if t and t.active then
					if aabb(x, y, width, height, t.x, t.y, t.width, t.height) then
						return t
					end
				end
				if condition and condition == "clearpipe" then
				else
					local t = objects["clearpipesegment"][tilemap(tx, ty)]
					if t and t.active then
						if aabb(x, y, width, height, t.x, t.y, t.width, t.height) then
							return t
						end
					end
				end
			end
		end
	end

	return false
	--return out
end

function checkinclearpipesegment(x, y, width, height)
	local xfrom, xto = math.floor(x-1), math.floor(x+width+1)
	local yfrom, yto = math.floor(y-1), math.floor(y+height+1)
	for tx = xfrom, xto do
		for ty = yfrom, yto do
			if inmap(tx, ty) then
				local t = objects["clearpipesegment"][tilemap(tx, ty)]
				if t and t.active then
					if aabb(x, y, width, height, t.x, t.y, t.width, t.height) then
						return t
					end
				end
			end
		end
	end
end

function inportal(self)
	if self.mask[2] then
		return
	end
	for i, v in pairs(portals) do
		if v.x1 ~= false and v.x2 ~= false then
			local portal1xplus = 0
			local portal2xplus = 0
			local portal1Y = v.y1
			local portal2Y = v.y2
			local portal1yplus = 0
			local portal2yplus = 0
			local portal1X = v.x1
			local portal2X = v.x2
			
			--Get the extra block of each portal
			if v.facing1 == "up" then
				portal1xplus = 1
			elseif v.facing1 == "down" then
				portal1xplus = -1
			end
			
			if v.facing2 == "up" then
				portal2xplus = 1
			elseif v.facing2 == "down" then
				portal2xplus = -1
			end
			
			if v.facing1 == "right" then
				portal1yplus = 1
			elseif v.facing1 == "left" then
				portal1yplus = -1
			end
			
			if v.facing2 == "right" then
				portal2yplus = 1
			elseif v.facing2 == "left" then
				portal2yplus = -1
			end
			
			local x = math.floor(self.x+self.width/2)+1
			local y = math.floor(self.y+self.height/2)+1
			
			if (x == portal1X or x == portal1X + portal1xplus) and (y == portal1Y or y == portal1Y + portal1yplus) then
				local entryportalX = v.x1
				local entryportalY = v.y1
				local entryportalfacing = v.facing1
				
				local exitportalX = v.x2
				local exitportalY = v.y2
				local exitportalfacing = v.facing2
				
				self.x, self.y, self.speedx, self.speedy, self.rotation = portalcoords(self.x, self.y, self.speedx, self.speedy, self.width, self.height, self.rotation, self.animationdirection, entryportalX, entryportalY, entryportalfacing, exitportalX, exitportalY, exitportalfacing, self, true)

			elseif (x == portal2X or x == portal2X + portal2xplus) and (y == portal2Y or y == portal2Y + portal2yplus) then
				local entryportalX = v.x2
				local entryportalY = v.y2
				local entryportalfacing = v.facing2
				
				local exitportalX = v.x1
				local exitportalY = v.y1
				local exitportalfacing = v.facing1
				
				self.x, self.y, self.speedx, self.speedy, self.rotation = portalcoords(self.x, self.y, self.speedx, self.speedy, self.width, self.height, self.rotation, self.animationdirection, entryportalX, entryportalY, entryportalfacing, exitportalX, exitportalY, exitportalfacing, self)

			end
		end
	end
	
	return false
end

function checkportalHOR(self, nextY) --handles horizontal (up- and down facing) portal teleportation
	for i, v in pairs(portals) do
		if v.x1 ~= false and v.x2 ~= false then
		
			local portal1xplus = 0
			local portal2xplus = 0
			local portal1Y = v.y1
			local portal2Y = v.y2
			
			--Get the extra block of each portal
			if v.facing1 == "up" then
				portal1xplus = 1
				portal1Y = portal1Y - 1
			elseif v.facing1 == "down" then
				portal1xplus = -1
			end
			
			if v.facing2 == "up" then
				portal2xplus = 1
				portal2Y = portal2Y - 1
			elseif v.facing2 == "down" then
				portal2xplus = -1
			end
			
			--first part checks whether object is in the portal's x range,                                  second part whether object just moved through the portal's Y value
			if ((v.x1 == math.floor(self.x+1) or v.x1+portal1xplus == math.floor(self.x+1)) and inrange(portal1Y, self.y+self.height/2, nextY+self.height/2))
			or ((v.x2 == math.floor(self.x+1) or v.x2+portal2xplus == math.floor(self.x+1)) and inrange(portal2Y, self.y+self.height/2, nextY+self.height/2)) then
			
				--check which portal is entry
				local entryportalX, entryportalY, entryportalfacing
				local exitportalX, exitportalY, exitportalfacing
				local entryportalxplus, entryportalyplus, exitportalxplus, exitportalyplus
				if (v.x1 == math.floor(self.x+1) or v.x1+portal1xplus == math.floor(self.x+1)) and inrange(portal1Y, self.y+self.height/2, nextY+self.height/2) then
					entryportalX = v.x1
					entryportalY = v.y1
					entryportalfacing = v.facing1
					entryportalxplus = portal1xplus
					
					exitportalX = v.x2
					exitportalY = v.y2
					exitportalfacing = v.facing2
					exitportalxplus = portal2xplus
				else
					entryportalX = v.x2
					entryportalY = v.y2
					entryportalfacing = v.facing2	
					entryportalxplus = portal2xplus
					
					exitportalX = v.x1
					exitportalY = v.y1
					exitportalfacing = v.facing1
					exitportalxplus = portal1xplus
				end
				
				--check if movement makes that portal even a possibility
				if entryportalfacing == "up" then
					if self.speedy < 0 then
						return false
					end
				elseif entryportalfacing == "down" then
					if self.speedy > 0 then
						return false
					end
				end
				
				if entryportalfacing == "left" or entryportalfacing == "right" then
					return false
				end
				
				local testx, testy, testspeedx, testspeedy, testrotation = portalcoords(self.x, self.y, self.speedx, self.speedy, self.width, self.height, self.rotation, self.animationdirection, entryportalX, entryportalY, entryportalfacing, exitportalX, exitportalY, exitportalfacing, self, true)
			
				if self.ignoreportalspacecheck or #checkrect(testx, testy, self.width, self.height, {"exclude", self}, false) == 0 then --Check if exit position is free
					self.x, self.y, self.speedx, self.speedy, self.rotation = testx, testy, testspeedx, testspeedy, testrotation
				else
					self.speedy = -self.speedy*0.95
					if math.abs(self.speedy) < 2 then
						if self.speedy > 0 then
							self.speedy = 2
						else
							self.speedy = -2
						end
					end
				end
				
				
				if (entryportalfacing == "down" and exitportalfacing == "up") or (entryportalfacing == "up" and exitportalfacing == "down") then
					
				else
					self.jumping = false
					self.falling = true
				end
				
				if self.portaled then
					self:portaled(exitportalfacing)
				end
				
				return true
			end
		end
	end
	return false
end

function checkportalVER(self, nextX) --handles vertical (left- and right facing) portal teleportation
	for i, v in pairs(portals) do
		if v.x1 ~= false and v.x2 ~= false then
			local portal1yplus = 0
			local portal2yplus = 0
			local portal1X = v.x1
			local portal2X = v.x2
			
			--Get the extra block of each portal
			if v.facing1 == "right" then
				portal1yplus = 1
			elseif v.facing1 == "left" then
				portal1yplus = -1
				portal1X = portal1X - 1
			end
			
			if v.facing2 == "right" then
				portal2yplus = 1
			elseif v.facing2 == "left" then
				portal2yplus = -1
				portal2X = portal2X - 1
			end
			
			if ((v.y1 == math.floor(self.y+1) or v.y1+portal1yplus == math.floor(self.y+1)) and inrange(portal1X, self.x+self.width/2, nextX+self.width/2))
			or ((v.y2 == math.floor(self.y+1) or v.y2+portal2yplus == math.floor(self.y+1)) and inrange(portal2X, self.x+self.width/2, nextX+self.width/2)) then
				--check which portal is entry
				local entryportalX, entryportalY, entryportalfacing
				local exitportalX, exitportalY, exitportalfacing
				local entryportalxplus, entryportalyplus, exitportalxplus, exitportalyplus
				if (v.y1 == math.floor(self.y+1) or v.y1+portal1yplus == math.floor(self.y+1)) and inrange(portal1X, self.x+self.width/2, nextX+self.width/2) then
					entryportalX = v.x1
					entryportalY = v.y1
					entryportalfacing = v.facing1
					entryportalyplus = portal1yplus
					
					exitportalX = v.x2
					exitportalY = v.y2
					exitportalfacing = v.facing2
					exitportalyplus = portal2yplus
				else
					entryportalX = v.x2
					entryportalY = v.y2
					entryportalfacing = v.facing2
					entryportalyplus = portal2yplus
					
					exitportalX = v.x1
					exitportalY = v.y1
					exitportalfacing = v.facing1
					exitportalyplus = portal1yplus
				end
				
				--check if movement makes that portal even a possibility
				if entryportalfacing == "right" then
					if self.speedx > 0 then
						return false
					end
				elseif entryportalfacing == "left" then
					if self.speedx < 0 then
						return false
					end
				end
				
				if entryportalfacing == "up" or entryportalfacing == "down" then
					return false
				end
				
				local testx, testy, testspeedx, testspeedy, testrotation = portalcoords(self.x, self.y, self.speedx, self.speedy, self.width, self.height, self.rotation, self.animationdirection, entryportalX, entryportalY, entryportalfacing, exitportalX, exitportalY, exitportalfacing, self, true)
			
				if self.ignoreportalspacecheck or #checkrect(testx, testy, self.width, self.height, {"exclude", self}, false) == 0 then
					self.x, self.y, self.speedx, self.speedy, self.rotation = testx, testy, testspeedx, testspeedy, testrotation
				else
					self.speedx = -self.speedx
				end
				
				self.jumping = false
				self.falling = true
				
				if self.portaled then
					self:portaled(exitportalfacing)
				end
				
				return true
			end
		end
	end
	return false
end

function portalcoords(x, y, speedx, speedy, width, height, rotation, animationdirection, entryportalX, entryportalY, entryportalfacing, exitportalX, exitportalY, exitportalfacing, self, live)
	x = x + width/2
	y = y + height/2
	
	local directrange --vector orthogonal to portal vector T
	local relativerange --vector symmetrical to portal vector =
	
	if entryportalfacing == "up" then
		directrange = entryportalY - y - 1
		if width == 2 then
			relativerange = 0
		else
			relativerange = ((x-width/2) - entryportalX + 1) / (2-width)
		end
	elseif entryportalfacing == "right" then
		directrange = x - entryportalX
		if height == 2 then
			relativerange = 0
		else
			relativerange = ((y-height/2) - entryportalY + 1) / (2-height)
		end
	elseif entryportalfacing == "down" then
		directrange = y - entryportalY	
		if width == 2 then
			relativerange = 0
		else
			relativerange = ((x-width/2) - entryportalX + 2) / (2-width)
		end
	elseif entryportalfacing == "left" then
		directrange = entryportalX - x - 1
		if height == 2 then
			relativerange = 0
		else
			relativerange = ((y-height/2) - entryportalY + 2) / (2-height)
		end
	end
	
	relativerange = math.min(1, math.max(0, relativerange))
	
	if entryportalfacing == "up" and exitportalfacing == "up" then --up -> up
		newx = x + (exitportalX - entryportalX)
		newy = exitportalY + directrange - 1
		speedy = -speedy
		
		rotation = rotation - math.pi
		
		if live then
			local grav = yacceleration
			if self and self.gravity then
				grav = self.gravity
			end

			--keep it from bugging out by having a minimum exit speed
			
			local minspeed = math.sqrt(2*grav*(height))
			
			if speedy > -minspeed then
				speedy = -minspeed
			end
		end
	elseif (entryportalfacing == "down" and exitportalfacing == "down") then --down -> down
		newx = x + (exitportalX - entryportalX)
		newy = exitportalY - directrange
		speedy = -speedy
		
		rotation = rotation - math.pi
		
	elseif entryportalfacing == "up" and exitportalfacing == "right" then --up -> right
		newy = exitportalY - relativerange*(2-height) - height/2 + 1
		newx = exitportalX - directrange
		
		speedx, speedy = speedy, -speedx
		
		rotation = rotation - math.pi/2
		
	elseif entryportalfacing == "up" and exitportalfacing == "left" then --up -> left
		newy = exitportalY + relativerange*(2-height) + height/2 - 2
		newx = exitportalX + directrange - 1
		
		speedx, speedy = -speedy, speedx
		
		rotation = rotation + math.pi/2
		
	elseif (entryportalfacing == "up" and exitportalfacing == "down") then --up -> down
		newx = x + (exitportalX - entryportalX) - 1
		newy = exitportalY - directrange
		
	
		--prevent low-fps bugs in a cheap way:
		if entryportalY > exitportalY then
			while newy+.5 + speedy*gdt > entryportalY do
				newy = newy - 0.01
			end
			
			while newy+.5 < exitportalY do
				newy = newy + 0.01
			end
		end
		
		--prevent porting into block by limiting X, yo
		if newx <= exitportalX - 2 + width/2 then
			newx = exitportalX - 2 + width/2
		elseif newx > exitportalX - width/2 then
			newx = exitportalX - width/2
		end
		
	elseif (entryportalfacing == "down" and exitportalfacing == "up") then --down -> up
		newx = x + (exitportalX - entryportalX) + 1
		newy = exitportalY + directrange - 1
		
	elseif (entryportalfacing == "down" and exitportalfacing == "left") then --down -> left
		newy = exitportalY - relativerange*(2-height) - height/2
		newx = exitportalX + directrange - 1
		
		speedx, speedy = speedy, -speedx
		
		rotation = rotation - math.pi/2
		
	elseif (entryportalfacing == "down" and exitportalfacing == "right") then --down -> right
		newy = exitportalY + relativerange*(2-height) + height/2 - 1
		newx = exitportalX - directrange
		
		speedx, speedy = -speedy, speedx
		
		rotation = rotation + math.pi/2
		
	--LEFT/RIGHT CODE!
	elseif (entryportalfacing == "left" and exitportalfacing == "right") then --left -> right
		newx = exitportalX - directrange
		newy = y + (exitportalY - entryportalY)+1
	elseif (entryportalfacing == "right" and exitportalfacing == "left") then --right -> left
		newx = exitportalX + directrange - 1
		newy = y + (exitportalY - entryportalY)-1
	elseif (entryportalfacing == "right" and exitportalfacing == "right") then --right -> right
		newx = exitportalX - directrange
		newy = y + (exitportalY - entryportalY)
		
		speedx = -speedx
		if animationdirection == "left" then
			animationdirection = "right"
		elseif animationdirection == "right" then
			animationdirection = "left"
		end
		
	elseif (entryportalfacing == "left" and exitportalfacing == "left") then --left -> left
		newx = exitportalX + directrange - 1
		newy = y + (exitportalY - entryportalY)
		
		speedx = -speedx
		if animationdirection == "left" then
			animationdirection = "right"
		elseif animationdirection == "right" then
			animationdirection = "left"
		end
		
	elseif (entryportalfacing == "left" and exitportalfacing == "up") then --left -> up
		newx = exitportalX + relativerange*(2-width) + width/2 - 1
		newy = exitportalY + directrange - 1
		
		speedx, speedy = speedy, -speedx
		
		rotation = rotation - math.pi/2
		
		if live then		
			--keep it from bugging out by having a minimum exit speed
			local grav = yacceleration
			if self and self.gravity then
				grav = self.gravity
			end
			
			local minspeed = math.sqrt(2*grav*(height))
			
			if speedy > -minspeed then
				speedy = -minspeed
			end
		end
		
	elseif (entryportalfacing == "right" and exitportalfacing == "up") then --right -> up
		newx = exitportalX - relativerange*(2-width) - width/2 + 1
		newy = exitportalY + directrange - 1
		
		speedx, speedy = -speedy, speedx
		
		rotation = rotation + math.pi/2
		
		if live then
			--keep it from bugging out by having a minimum exit speed
			local grav = yacceleration
			if self and self.gravity then
				grav = self.gravity
			end
			
			local minspeed = math.sqrt(2*grav*(height))
			
			if speedy > -minspeed then
				speedy = -minspeed
			end
		end
		
	elseif (entryportalfacing == "left" and exitportalfacing == "down") then --left -> down
		newx = exitportalX - relativerange*(2-width) - width/2
		newy = exitportalY - directrange
		
		speedx, speedy = -speedy, speedx
		
		rotation = rotation + math.pi/2
		
	elseif (entryportalfacing == "right" and exitportalfacing == "down") then --right -> down
		newx = exitportalX + relativerange*(2-width) + width/2 - 2
		newy = exitportalY - directrange
		
		speedx, speedy = speedy, -speedx
		
		rotation = rotation - math.pi/2
	end
	
	newx = newx - width/2
	newy = newy - height/2
	
	return newx, newy, speedx, speedy, rotation, animationdirection
end

function converttostandard(obj, speedx, speedy)
	--Convert speedx and speedy to horizontal values
	local speed = math.sqrt(speedx^2+speedy^2)
	local speeddir = math.atan2(speedy, speedx)
	
	local speedx, speedy = math.cos(speeddir-obj.gravitydirection+math.pi/2)*speed, math.sin(speeddir-obj.gravitydirection+math.pi/2)*speed
				
	if math.abs(speedy) < 0.00001 then
		speedy = 0
	end
	if math.abs(speedx) < 0.00001 then
		speedx = 0
	end
	
	return speedx, speedy
end

function convertfromstandard(obj, speedx, speedy)
	--reconvert speedx and speedy to actual directions
	local speed = math.sqrt(speedx^2+speedy^2)
	local speeddir = math.atan2(speedy, speedx)
	
	local speedx, speedy = math.cos(speeddir+obj.gravitydirection-math.pi/2)*speed, math.sin(speeddir+obj.gravitydirection-math.pi/2)*speed
	
	if math.abs(speedy) < 0.00001 then
		speedy = 0
	end
	if math.abs(speedx) < 0.00001 then
		speedx = 0
	end
	
	return speedx, speedy
end

function unrotate(rotation, gravitydirection, dt)
	local rotation, gravitydirection = rotation or 0, gravitydirection or 0
	--rotate back to gravitydirection (portals)
	rotation = math.fmod(rotation, math.pi*2)
	
	if rotation < -math.pi then
		rotation = rotation + math.pi*2
	elseif rotation > math.pi then
		rotation = rotation - math.pi*2
	end
	
	if rotation == math.pi and gravitydirection == 0 then
		rotation = rotation + portalrotationalignmentspeed*dt
	elseif rotation <= -math.pi/2 and gravitydirection == math.pi*1.5 then
		rotation = rotation - portalrotationalignmentspeed*dt
	elseif rotation > (gravitydirection-math.pi/2) then
		rotation = rotation - portalrotationalignmentspeed*dt
		if rotation < (gravitydirection-math.pi/2) then
			rotation = (gravitydirection-math.pi/2)
		end
	elseif rotation < (gravitydirection-math.pi/2) then
		rotation = rotation + portalrotationalignmentspeed*dt
		if rotation > (gravitydirection-math.pi/2) then
			rotation = (gravitydirection-math.pi/2)
		end
	end
	
	return rotation
end
