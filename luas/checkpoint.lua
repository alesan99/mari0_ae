--record holder for the 2nd most simple entity ever

checkpointentity = class:new()

function checkpointentity:init(x, y, r, i)
	self.cox = x
	self.coy = y
	self.r = r
	self.i = i
	
	self.active = false
	self.static = true
end

function checkpointentity:link()
	self.outtable = {}
	if #self.r > 2 then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				if tonumber(self.r[4]) == v.cox and tonumber(self.r[5]) == v.coy then
					v:addoutput(self)
				end
			end
		end
	end
end

function checkpointentity:input(t)
	if t == "on" then
		self:activate()
	--elseif t == "off" then
	elseif t == "toggle" then
		self:activate()
	end
end

function checkpointentity:activate()
	checkpointi = self.i
	checkpointx = self.cox--checkpoints[checkpointi]
	checkpointsublevel = actualsublevel
end