require("utils")
softloadhttps()

require("love.image")
require("love.filesystem")
require("love.graphics")
require("love.data")

local input = love.thread.getChannel("image_input")
local output = love.thread.getChannel("image_output")
---@type table<string, love.ImageData>
local cache = {}

--- Downloads an image to an ImageData object.
---@param url string The URL of the image.
---@return love.ImageData|nil image The image data.
local function createImageData(url)
	local code, body = https.request(url)
	if code ~= 200 or not body then return nil end

    local success, bytedata = pcall(love.data.newByteData, body)
    if not success then return nil end

    local success, imagedata = pcall(love.image.newImageData, bytedata)
    if not success then return nil end

    -- note: love.graphics.newImage does not work in threads
    return imagedata
end

while true do
    local asset = input:demand()
    if asset == "stop" then
        --stop the thread
        break
    elseif asset then
        --load image
        local url = asset.icon_url
        if cache[url] then
            output:supply({"img", url, cache[url]})
            return
        end
        local image = createImageData(url)
        if image then
            cache[url] = image
            output:supply({"img", url, image})
        else
            output:supply({"error"})
        end
    end
end
