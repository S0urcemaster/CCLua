-- loadLibs
-- for eclipse execution

local dir = "C:/Users/adm9/Documents/GitHub/CCLua/src/aberoothST/"

local libs = {
"commonAPI",
"turtleAPI"
}

loadLibs = function()
	
	for _, lib in ipairs(libs) do
		local app, err = loadfile(dir..lib..".lua")
		if app then
			local tEnv = {}
			setmetatable(tEnv, {__index = _G})
			setfenv(app, tEnv)
			app()
	
			local tApi = {}
			for k,v in pairs(tEnv) do
				tApi[k] = v
			end
			tApi.name = lib
			_G[lib] = tApi
		else
			print(err)
		end
	end
end