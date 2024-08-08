require("love.system")

---------------------
---- https stuff ----
---------------------

function hardpreload(module, path)
	local full_path = module .. "/" .. path
	-- read from .love
	local data = love.filesystem.read("libs/" .. full_path)
	-- write to save directory
	love.filesystem.setIdentity("mari0_libs")
	if not love.filesystem.getInfo(module) then
		love.filesystem.createDirectory(module)
	end
	love.filesystem.write(full_path, data)
	-- preload module
	package.preload[module] = package.loadlib(love.filesystem.getSaveDirectory() .. "/" .. full_path, "luaopen_" .. module)
	love.filesystem.setIdentity("mari0")
end

function softpreload(module, path)
	love.filesystem.setIdentity("mari0_libs")
    local full_path = module .. "/" .. path
    package.preload[module] = package.loadlib(love.filesystem.getSaveDirectory() .. "/" .. full_path, "luaopen_" .. module)
    love.filesystem.setIdentity("mari0")
end

local function loadhttps(loadfunc)
    -- preload https module from bundled libs folder
    -- to be removed in LÖVE 12.0
    local system_os = love.system.getOS()
    if system_os == "Windows" and jit.arch == "x64" then
        loadfunc("https", "win64.dll")
    elseif system_os == "Windows" and jit.arch == "x86" then
        loadfunc("https", "win32.dll")
    elseif system_os == "Linux" then
        loadfunc("https", "linux.so")
    elseif system_os == "OS X" then
        loadfunc("https", "osx.so")
    end

    https_status, https = pcall(require, "https")
    if not https_status then
        https = nil
    end
end

function hardloadhttps()
    loadhttps(hardpreload)
end

function softloadhttps()
    loadhttps(softpreload)
end

--------------
---- misc ----
--------------

function hasvalue(tab, val)
    for i, value in pairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function kpairs(t, keys)
	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

function isPaused(source)
    return pausedaudio and hasvalue(pausedaudio, source)
end

function isStopped(source)
    return not source:isPlaying() and not isPaused(source)
end

function isActive(source)
    return source:isPlaying() or isPaused(source)
end
