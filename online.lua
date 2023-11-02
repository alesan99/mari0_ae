local url = "https://raw.githubusercontent.com/qixils/mari0pository/main/data.json"
local mountedmappacks = {}

--- Mounts a mappack from the online repository.
---@param filename string The filename of the mappack.
---@return boolean success Whether the mappack was mounted successfully.
function mountmappack(filename)
	if mountedmappacks[filename] then
		return false
	end
	local success = love.filesystem.mount("alesans_entities/onlinemappacks/" .. filename, mappackfolder, true)
	if success then
		mountedmappacks[filename] = true
	end
	return success
end

--- Download the asset list from the online repository.
---@return table<string, boolean|string|number|table|nil> assetdata The asset list.
function downloadassetdata()
    if not https then
        onlinemappacklisterror = true
        return {}
    end
    local code, body = https.request(url)
    if code ~= 200 then
        notice.new(body, notice.red, 4)
        onlinemappacklisterror = true
        return {}
    end
    return JSON:decode(body)
end

--- Downloads an asset from the online repository.
---@param asset table<string, boolean|string|number|table|nil> The asset to download.
---@return boolean success Whether the asset was downloaded successfully.
function downloadasset(asset)
    local code, body = https.request(asset.download)
    if code ~= 200 then
        notice.new(body, notice.red, 4)
        return false
    end
    local filename = asset.filename
    if asset.type == "mappack" then
        filename = "alesans_entities/onlinemappacks/" .. filename
    end
    love.filesystem.write(filename, body)
    return true
end
