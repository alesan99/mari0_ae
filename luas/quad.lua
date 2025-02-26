quad = class:new()

--I ADDED EVERY TILE PROPERTY FROM SE BONUS POINTS FOR ME!

--COLLIDE?
--INVISIBLE?
--BREAKABLE?
--COINBLOCK?
--COIN?
--_NOT_ PORTALABLE?
--JUMP_THROUGH?
--SPIKES_UP?
--SPIKES_DOWN?
--SPIKES_LEFT?
--SPIKES_RIGHT?
--GRATE?
--WATERTILE?
--MIRROR?
--FOREGROUND?
--BRIDGE?
--LAVA?
--LEFT_SLANT?
--RIGHT_SLANT?
--NOTE_BLOCK?
--VINE?
--ICE?

function quad:init(img, imgdata, x, y, width, height)
	--get if empty?

	self.image = img
	self.quad = love.graphics.newQuad((x-1)*17, (y-1)*17, 16, 16, width, height)
	
	getquadprops(imgdata, x, y, self)
end

function getquadprops(imgdata, x, y, self)
	--local self = {}
	local minalpha = 127
	
	--get collision
	self.collision = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17)
	if a > minalpha then
		self.collision = true
		self.debris = rgbaToInt(r,g,b,a)
	end
	
	--get invisible
	self.invisible = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+1)
	if a > minalpha then
		self.invisible = true
	end
	
	--get breakable
	self.breakable = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+2)
	if a > minalpha then
		self.breakable = true
	end
	
	--get coinblock
	self.coinblock = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+3)
	if a > minalpha then
		self.coinblock = true
	end
	
	--get coin
	self.coin = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+4)
	if a > minalpha then
		self.coin = true
	end
	
	self.portalable = true
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+5)
	if a > minalpha then
		self.portalable = false
	end
	
	--get platform
	self.platform = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+6)
	if a > minalpha then
		self.platform = true
	end
	
	--get spikes
	self.spikesup = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+7)
	if a > minalpha then
		self.spikesup = true
	end
	self.spikesdown = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+8)
	if a > minalpha then
		self.spikesdown = true
	end
	self.spikesleft = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+9)
	if a > minalpha then
		self.spikesleft = true
	end
	self.spikesright = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+10)
	if a > minalpha then
		self.spikesright = true
	end
	
	--get grate
	self.grate = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+11)
	if a > minalpha then
		self.grate = true
	end
	
	--get watertile
	self.water = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+12)
	if a > minalpha then
		self.water = true
	end
	
	--get mirror
	self.mirror = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+13)
	if a > minalpha then
		self.mirror = true
	end
	
	--get foreground
	self.foreground = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+14)
	if a > minalpha then
		self.foreground = true
	end
	
	--get bridge
	self.bridge = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+15)
	if a > minalpha then
		self.bridge = true
	end
	
	--get lava
	self.lava = false
	local r, g, b, a = imgdata:getPixel(x*17-1, (y-1)*17+16)
	if a > minalpha then
		self.lava = true
	end
	
	--get left slant
	self.leftslant = false
	local r, g, b, a = imgdata:getPixel(x*17-2, (y-1)*17+16)
	if a > minalpha then
		self.leftslant = true
		if g == 0 and b == 100 then
			self.halfleftslant1 = true
		elseif g == 0 and b == 200 then
			self.halfleftslant2 = true
		else
			self.fullleftslant = true
		end
		if g == 0 and r == 100 then
			self.downslant = true
		end
	end
	
	--get right slant
	self.rightslant = false
	local r, g, b, a = imgdata:getPixel(x*17-3, (y-1)*17+16)
	if a > minalpha then
		self.rightslant = true
		if g == 0 and b == 100 then
			self.halfrightslant1 = true
		elseif g == 0 and b == 200 then
			self.halfrightslant2 = true
		else
			self.fullrightslant = true
		end
		if g == 0 and r == 100 then
			self.downslant = true
		end
	end

	--get slab
	if self.leftslant and self.rightslant then
		self.slab = true
	end
	
	--get note block
	self.noteblock = false
	local r, g, b, a = imgdata:getPixel(x*17-4, (y-1)*17+16)
	if a > minalpha then
		self.noteblock = true
	end
	
	--get vine
	self.vine = false
	local r, g, b, a = imgdata:getPixel(x*17-5, (y-1)*17+16)
	if a > minalpha then
		self.vine = true
	end

	--get ice
	self.ice = false
	local r, g, b, a = imgdata:getPixel(x*17-6, (y-1)*17+16)
	if a > minalpha then
		self.ice = true
	end

	--get fence
	self.fence = false
	local r, g, b, a = imgdata:getPixel(x*17-7, (y-1)*17+16)
	if a > minalpha then
		self.fence = true
	end

	--get platform down
	self.platformdown = false
	local r, g, b, a = imgdata:getPixel(x*17-8, (y-1)*17+16)
	if a > minalpha then
		self.platformdown = true
	end
	
	--get platform left
	self.platformleft = false
	local r, g, b, a = imgdata:getPixel(x*17-9, (y-1)*17+16)
	if a > minalpha then
		self.platformleft = true
	end

	--get platform right
	self.platformright = false
	local r, g, b, a = imgdata:getPixel(x*17-10, (y-1)*17+16)
	if a > minalpha then
		self.platformright = true
	end
	
	--return self
end

local function getquadprops(self)
	local list = {"collision",
	"invisible",
	"breakable",
	"coinblock",
	"coin",
	"portalable",
	"platform",
	"spikesup",
	"spikesdown",
	"spikesleft",
	"spikesright",
	"grate",
	"water",
	"mirror",
	"foreground",
	"bridge",
	"lava",
	"leftslant",
	"rightslant",
	"noteblock",
	"vine",
	"ice",
	"fence",
	"platformdown",
	"platformleft",
	"platformright"}
	local t = {}
	for i, w in pairs(list) do
		t[w] = self[w]
	end
	return t
end

function quad:getproperty(s)
	if not self.props then
		self.props = getquadprops(self)
	end
	return self.props[s]
end
