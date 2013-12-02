-- loadLibs
-- for eclipse execution

local dir = "C:/Users/adm9/Documents/GitHub/CCLua/src/aberoothST/"

local libs = {
"commonAPI"
}

loadLibs = function()

	local app, err = loadfile(dir..libs[1]..".lua")
			if app then
				local tEnv = {}
				setmetatable(tEnv, {__index = _G})
				setfenv(app, tEnv)
				app()

				local tApi = {}
				for k,v in pairs(tEnv) do
					tApi[k] = v
				end
				tApi.name = libs[1]
				_G[libs[1]] = tApi
			else
				print(err)
			end

end