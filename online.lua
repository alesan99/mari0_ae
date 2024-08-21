local asseturl = "https://raw.githubusercontent.com/qixils/mari0pository/v1/data.json"
local mounted = {}

--- Mounts a file to a folder.
---@param filename string The path to the file to mount.
---@param folder string The folder to mount the file to.
function mountto(filename, folder)
    if mounted[filename] then
        return false
    end
    local success = love.filesystem.mount(filename, folder, true)
    if success then
        mounted[filename] = true
    end
    return success
end

--- Mounts a mappack from the online repository.
---@param filename string The filename of the mappack.
---@return boolean success Whether the mappack was mounted successfully.
function mountmappack(filename)
    return mountto("alesans_entities/onlinemappacks/" .. filename, mappackfolder)
end

--- Mounts a character from the online repository.
---@param filename string The filename of the character.
---@return boolean success Whether the character was mounted successfully.
function mountcharacter(filename)
    return mountto("alesans_entities/characters/" .. filename, "alesans_entities/characters")
end

--- Mounts an asset from the online repository.
---@param asset table<string, boolean|string|number|table|nil> The asset to mount.
---@return boolean success Whether the asset was mounted successfully.
function mountasset(asset)
    if asset.type == "mappack" then
        return mountmappack(asset.download.filename)
    elseif asset.type == "character" then
        return mountcharacter(asset.download.filename)
    end
    return false
end

--- Mounts all downloaded assets from a folder.
---@param from string The folder to mount assets from.
---@param target string The folder to mount assets to.
---@param mountfunc function The function to mount assets with.
local function mountallfrom(from, target, mountfunc)
    -- todo: this could be improved further (mountfunc probably not necessary)
    local zips = love.filesystem.getDirectoryItems(from)
    if #zips > 0 then
        for j, w in pairs(zips) do
            local extensionless = w:sub(1, -5)
            if not love.filesystem.getInfo(target .. "/" .. w) and not love.filesystem.getInfo(target .. "/" .. extensionless) then
                --mountfunc(w)
                mountto(from .. "/" .. w, target)
            end
        end
    end
end

--- Mounts all downloaded assets from the online repository.
function mountalldlc()
    mountallfrom("alesans_entities/onlinemappacks", mappackfolder, mountmappack)
    mountallfrom("alesans_entities/characters", "alesans_entities/characters", mountcharacter)
end

--- Download the asset list from the online repository.
---@return table<string, boolean|string|number|table|nil> assetdata The asset list.
function downloadassetdata()
    if not https then
        onlinemappacklisterror = true
        return {}
    end
    local code, body = https.request(asseturl)
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
    local code, body = https.request(asset.download.url)
    if code ~= 200 then
        notice.new(body, notice.red, 4)
        return false
    end
    local filename = asset.download.filename
    if asset.type == "mappack" then
        filename = "alesans_entities/onlinemappacks/" .. filename
    elseif asset.type == "character" then
        filename = "alesans_entities/characters/" .. filename
    end
    love.filesystem.write(filename, body)
    return true
end
