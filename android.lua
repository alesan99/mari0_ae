require "androidbutton"
buttons = {}

local controllingPlayer = 1

local editorButtonsSize = 24
local editorButtons = {
	{function() HIDEANDROIDBUTTONS = not HIDEANDROIDBUTTONS end, function() return HIDEANDROIDBUTTONS end},
	{function() editentities = false; currenttile = 1 end},
	{function() editentities = true; currenttile = 1 end},
	{function() ANDROIDRIGHTCLICK = not ANDROIDRIGHTCLICK end, function() return ANDROIDRIGHTCLICK end},
	{function() backgroundtilemode = not backgroundtilemode end, function() return backgroundtilemode end},
	{function() undo_undo() end}
}

function androidLoad()
	--Game controls
	buttons["jump"] = touchButton:new("jump", "A", 346, 159, 50, 50, "round")
	buttons["jump"].autoscrollGone = true
	buttons["run"] = touchButton:new("run", "B", 292, 169, 50, 50, "round")
	buttons["run"].autoscrollGone = true
	buttons["run"].highlightFunc = function() return touchRunLock end
	buttons["runlock"] = touchButton:new("runlock", "+", 267, 194, 25, 25, "round")
	buttons["runlock"].autoscrollGone = true
	buttons["runlock"].highlightFunc = buttons["run"].highlightFunc
	buttons["use"] = touchButton:new("use", "U", 267, 169, 25, 25, "round")
	buttons["use"].autoscrollGone = true
	buttons["use"].gameOnly = true

	buttons["left"] = touchButton:new("left", "", 5+5, 159, 30, 30)
	buttons["right"] = touchButton:new("right", "", 65+5, 159, 30, 30)
	buttons["up"] = touchButton:new("up", "", 35+5, 129, 30, 30)
	buttons["down"] = touchButton:new("down", "", 35+5, 189, 30, 30)

	buttons["start"] = touchButton:new("start", "START", 352, 5, 43, 16)

	buttons["portal1"] = touchButton:new("l", "1", 6, 73, 25, 25, "round")
	buttons["portal1"].portal = true
	buttons["portal2"] = touchButton:new("r", "2", 6, 73+27*1, 25, 25, "round")
	buttons["portal2"].portal = true
	buttons["portal1"].color = {60, 188, 252}
	buttons["portal2"].color = {232, 130, 30}
	buttons["reload"] = touchButton:new("reload", "R", 6, 73+27*2, 25, 25, "round")
	buttons["reload"].autoscrollGone = true
	buttons["reload"].gameOnly = true

	--Level Editor
	local editorButtonsimg = love.graphics.newImage("graphics/GUI/androideditorbuttons.png")
	local editorButtonsq = {}
	for i = 1, math.floor(editorButtonsimg:getWidth()/editorButtonsimg:getHeight()) do
		editorButtonsq[i] = love.graphics.newQuad(editorButtonsimg:getHeight()*(i-1),0,
		editorButtonsimg:getHeight(),editorButtonsimg:getHeight(),
		editorButtonsimg:getWidth(),editorButtonsimg:getHeight())
	end
	local bx, by = 2, 2
	for i = 1, #editorButtons do
		buttons["editor" .. i] = touchButton:new(editorButtons[i][1], {editorButtonsimg,editorButtonsq[i]}, bx+(editorButtonsSize+2)*(i-1), by, editorButtonsSize, editorButtonsSize)
		buttons["editor" .. i].editor = true
		if i == 1 then
			buttons["editor" .. i].hideButton = true
		end
		if editorButtons[i][2] then
			buttons["editor" .. i].highlightFunc = editorButtons[i][2]
		end
	end

	for _, b in pairs(buttons) do

	end
end

function androidUpdate(dt)
	for i, b in pairs(buttons) do
		b:update(dt)
	end

	--update portal colors
	if objects and objects["player"] and objects["player"][controllingPlayer] then
		buttons["portal1"].color = objects["player"][controllingPlayer].portal1color
		buttons["portal2"].color = objects["player"][controllingPlayer].portal2color
	end
end

local lastTouchX, lastTouchY = 0,0
local lastReleaseX, lastReleaseY = 0,0
function androidDraw()
	love.graphics.push()
	love.graphics.scale(winwidth/gamewidth,winheight/gameheight)

	for i, b in pairs(buttons) do
		b:draw()
	end

	--[[
	--touch debug
	love.graphics.setColor(255,0,0)
	local mx,my= androidGetCoords(mouseTouchX,mouseTouchY)
	love.graphics.circle("fill",mx,my,2)
	love.graphics.setColor(255,255,0)
	love.graphics.circle("fill",lastTouchX,lastTouchY,1)
	love.graphics.setColor(0,255,255)
	love.graphics.circle("fill",lastReleaseX,lastReleaseY,1)]]

	love.graphics.pop()
end

mouseTouchX = gamewidth/2
mouseTouchY = gameheight/2
mouseTouchId = false

touchRunLock = false

local touchKey = {} --which touch is a button being touched by?
local touches = {} --what button is a touch on?
local touchesStillDrag = {} --touch is on button, but it should still move the mouse

local function getButton(id, x, y)
	for i, b in pairs(buttons) do
		if b.active and b:over(x,y) then
			return b,i
		end
	end
	return false
end

function androidGetCoords(tx,ty)
	return tx/(winwidth/gamewidth), ty/(winheight/gameheight)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
	local ox, oy = x, y
	local x, y = androidGetCoords(x,y)

	local button = getButton(id, x, y)
	if button then
		if button:testPress(id, x, y) then
			if button.key then
				touchKey[button.i] = id
			end
			touches[id] = button
			return
		end
		return
	end
	
	--rightclick
	if editormode and (not editormenuopen) and ((not rightclickmenuopen) or (customrcopen and customrcopen == "trackpath")) and ANDROIDRIGHTCLICK then
		mouseTouchX = ox
		mouseTouchY = oy
		editor_mousepressed(x, y, "r","simulated")
		return
	end

	
	--set mouse position
	mouseTouchX = ox
	mouseTouchY = oy
	mouseTouchId = id
	if (gamestate ~= "game") or editormode then
		--make sure buttons are aware of the change before "clicking"
		for i, v in pairs(guielements) do
			v:update(0)
		end
		love.mousepressed(ox,oy,1,"simulated")
		lastTouchX, lastTouchY = x,y
	end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
	local ox, oy = x, y
	local x, y = androidGetCoords(x,y)

	if mouseTouchId == id and ((not touches[id]) or touchesStillDrag[id]) then
		mouseTouchX = ox
		mouseTouchY = oy
	end

	--Slide finger to different button
	local button1 = getButton(id, x, y)
	if button1 and (not button1.held) then
		for i, b in pairs(buttons) do
			if b.id == id then
				b:release(id,x,y)
				if b.key then
					touchKey[b.i] = false
				end
				touches[id] = false
				break
			end
		end
		button1:press(id,x,y)
		if button1.key then
			touchKey[button1.i] = id
		end
		touches[id] = button1
		touchesStillDrag[id] = true
	end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
	local ox, oy = x, y
	local x, y = androidGetCoords(x,y)

	--find and release button
	for i, b in pairs(buttons) do
		if b.id == id then
			b:release(id,x,y)
			if b.key then
				touchKey[b.i] = false
			end
			touches[id] = false
			touchesStillDrag[id] = false
			break
		end
	end

	if ((gamestate ~= "game") or editormode) and mouseTouchId == id then
		mouseTouchX = ox
		mouseTouchY = oy
		mouseTouchId = false
		love.mousereleased(ox,oy,1,"simulated")
		lastReleaseX, lastReleaseY = x,y
	end
end

function androidButtonDown(i,n)
	if n == "run" and touchRunLock then
		return true
	end
	if buttons[n] and buttons[n].held then
		return true
	end
	return false
end

function androidMouseDown(b)
	if mouseTouchId then
		if ANDROIDRIGHTCLICK and b == 2 then
			return true
		elseif b == 1 then
			return true
		end
	end
	return false
end

function androidGetMouse()
	if resizable and letterboxfullscreen then
		local cw, ch = gamewidth, gameheight--current size
		local tw, th = winwidth, winheight--target size
		local s
		if cw/tw > ch/th then s = tw/cw
		else s = th/ch end
		return math.max(0, math.min(cw*s, mouseTouchX - ((tw*0.5)-(cw*s*0.5))))/s, math.max(0, math.min(ch*s, mouseTouchY - ((th*0.5)-(ch*s*0.5))))/s
	else
		return mouseTouchX/(winwidth/gamewidth), mouseTouchY/(winheight/gameheight)
	end
end