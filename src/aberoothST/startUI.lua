-- startUI limited to Standard Computer (39 x 13)

local appDir = "_apps"

local apps = {}
local currentApp = 0

local pages = {}
local currentPage = 0 

local pageItems = {}

local cursorStops = {}
local cursorStop = 1


local sprint = function(text, x, y)

	term.setCursorPos(x, y)
	io.write(text)

end


local printStatus = function(text)

	local x, y = term.getCursorPos()
	sprint(text, 1, 13)
	term.setCursorPos(x, y)

end


local drawBlankPage = function()

	local screen = [[|            |            |           |







[  ]      [  ]      [  ]      [  ]
[  ]      [  ]      [  ]      [  ]
[  ]      [  ]      [  ]      [  ]
[  ]      [  ]      [  ]      [  ]
]]
	sprint(screen, 1, 1)
  sprint("Start", 2, 1)
  sprint("Apps", 15, 1)
  sprint("Misc", 28, 1)

end



local start = function()


	

end


local drawSelectionList = function(items)
	
	local x = 0
	local y = 3
	
	for key, item in ipairs(items) do
	
		text = ""
		if #item > 18 then
			text = string.sub(item, 1, 18)
		else
			text = item
		end
		sprint(text, x + 1, y)
		table.insert(cursorStops, {x + 1, y})
		
		if x == 0 then
			x = 20
		else
			x = 0
			y = y + 1
		end
	
	end

end


local adjustParameter = function(parameter)
  x = 9 - #parameter
  if x < 1 then x = 1 end
  par = ""
  if #parameter > 8 then
    par = string.sub(parameter, 1, 8)
  else
    par = parameter
  end
  return par, x
end


local drawAttributeList = function(attributes)
	
	cursorStops = {}
	
	local x = 0
	local y = 3

	for key, value in ipairs(attributes) do
		
		local keytext, keyx = ajustParameter(key)
		sprint(keytext..">", x + keyx, y)
		if value ~= nil then io.write(value) end
		
		table.insert(cursorStops, {x + 10, y})
		
		if x == 0 then
			x = 20
		else
			x = 0
			y = y + 1
		end
	
	end

end


local startPage = function()

	sprint("[",  1, 1)
	sprint("]", 14, 1)
	sprint("|", 27, 1)
	sprint("|", 39, 1)
	
	sprint("App: "..apps[currentApp].name)
	
	
	drawAttributeList()

end


local appPage = function()

	sprint("|",  1, 1)
	sprint("[", 14, 1)
	sprint("]", 27, 1)
	sprint("|", 39, 1)
	
end


local miscPage = function()

	sprint("|",  1, 1)
	sprint("|", 14, 1)
	sprint("[", 27, 1)
	sprint("]", 39, 1)

end


local main = function()

	-- read app location
	if not fs.exists(appDir) then
		error("App directory '"..appDir.."' not found")
	end
	local files = fs.list(appDir)
	for _, file in ipairs(files) do
		if _G[file] ~= nil then
			print("App name '"..file.."' collides with existing library name. Please change.")
		else
			local app, err = loadfile(file)
			if app then
				local tEnv = {}
				setmetatable(tEnv, {__index = _G})
				setfenv(app, tEnv)
				app()
				local tApi = {}
				for k,v in ipairs(tEnv) do
					tApi[k] = v
				end
				_G[file] = tApi
				table.insert(apps, {name = file, params = {}, reqs = {}})
			else
				print(err)
			end
		end
		
	end
	
	table.insert(pages, startPage)
	table.insert(pages, appPage)
	table.insert(pages, miscPage)
	
	start()

end

main()

--