local intro_finish

function intro_load()
	gamestate = "intro"
	
	introduration = 2.5
	blackafterintro = 0.3
	introfadetime = 0.5
	introprogress = 0.5
	
	screenwidth = width*16*scale
	screenheight = 224*scale
	allowskip = false
end

function intro_update(dt)
	allowskip = true
	if introprogress < introduration+blackafterintro then
		introprogress = introprogress + dt
		if introprogress > introduration+blackafterintro then
			introprogress = introduration+blackafterintro
		end
		
		if introprogress > 0.5 and playedwilhelm == nil then
			if math.random(300) == 1 then
				playsound(babysound)
			else
				playsound(stabsound)
			end
			
			playedwilhelm = true
		end
		
		if introprogress == introduration + blackafterintro then
			intro_finish()
		end
	end
end

function intro_draw()
	local logoscale = scale
	if logoscale <= 1 then
		logoscale = 0.5
	else
		logoscale = 1
	end
	if introprogress >= 0 and introprogress < introduration then
		local a = 1
		if introprogress < introfadetime then
			a = introprogress/introfadetime
		elseif introprogress >= introduration-introfadetime then
			a = 1-(introprogress-(introduration-introfadetime))/introfadetime
		end
		
		love.graphics.setColor(1, 1, 1, a)
		
		if FamilyFriendly then
			--"If you create a minor update that's in game options make you remove the stabyourself logo?????"
			--"Stabyourself logo is not rated for everyone"
			--"If make a really free for everyone version for mari0 AE many kids will like this news"
			--"The stick man dies in the screen"
			
			if introprogress > introfadetime+0.3 and introprogress < introduration - introfadetime then
				local y = (introprogress-0.2-introfadetime) / (introduration-2*introfadetime) * 206 * 5
				properprint("stys.eu", ((width*16)*scale)/2-string.len("stys.eu")*4*scale, 110*scale)
				love.graphics.setScissor(0, screenheight/2+150*logoscale - y, screenwidth, y)
				love.graphics.setColor(100/255, 100/255, 100/255, a)
				properprint("stys.eu", ((width*16)*scale)/2-string.len("stys.eu")*4*scale, 110*scale)
				love.graphics.setColor(1, 1, 1, a)
				properprint("stys.eu", ((width*16)*scale)/2-string.len("stys.eu")*4*scale, 109*scale)
				love.graphics.setScissor()
			elseif introprogress >= introduration - introfadetime then
				love.graphics.setColor(100/255, 100/255, 100/255, a)
				properprint("stys.eu", ((width*16)*scale)/2-string.len("stys.eu")*4*scale, 110*scale)
				love.graphics.setColor(1, 1, 1, a)
				properprint("stys.eu", ((width*16)*scale)/2-string.len("stys.eu")*4*scale, 109*scale)
			else
				properprint("stys.eu", ((width*16)*scale)/2-string.len("stys.eu")*4*scale, 110*scale)
			end
		else
			if introprogress > introfadetime+0.3 and introprogress < introduration - introfadetime then
				local y = (introprogress-0.2-introfadetime) / (introduration-2*introfadetime) * 206 * 5
				love.graphics.draw(logo, screenwidth/2, screenheight/2, 0, logoscale, logoscale, 142, 150)
				love.graphics.setScissor(0, screenheight/2+150*logoscale - y, screenwidth, y)
				love.graphics.draw(logoblood, screenwidth/2, screenheight/2, 0, logoscale, logoscale, 142, 150)
				love.graphics.setScissor()
			elseif introprogress >= introduration - introfadetime then
				love.graphics.draw(logoblood, screenwidth/2, screenheight/2, 0, logoscale, logoscale, 142, 150)
			else
				love.graphics.draw(logo, screenwidth/2, screenheight/2, 0, logoscale, logoscale, 142, 150)
			end
		end
		
		local a2 = math.max(0, 1-(introprogress-.5)/0.3)
		love.graphics.setColor(150/255, 150/255, 150/255, a2)
		properprint("loading mari0..", love.graphics.getWidth()/2-string.len("loading mari0..")*4*scale, 20*scale)
		love.graphics.setColor(50/255, 50/255, 50/255, a2)
		properprint(loadingtext, love.graphics.getWidth()/2-string.len(loadingtext)*4*scale, love.graphics.getHeight()/2+165*logoscale)

		love.graphics.setColor(1, 1, 1, a2)
		love.graphics.rectangle("fill", 0, (height*16-3)*scale, (width*16)*scale, 3*scale)
	end
end

function intro_mousepressed()
	if not allowskip then
		return
	end
	stabsound:stop()
	intro_finish()
end

function intro_keypressed()
	if not allowskip then
		return
	end
	stabsound:stop()
	intro_finish()
end

function intro_finish()
	menu_load()
	logo = nil
	logoblood = nil
end
