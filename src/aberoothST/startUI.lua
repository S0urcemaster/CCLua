-- startUI limited to Standard Computer (39 x 13)
--
-- App Interface
-- All apps in the "/_app" directory will be accessible in the ui.
-- Following functions can be implemented:
--
-- getArgs()
-- Return a table of strings that should be queried
-- Example: {"Length", "Direction"}
-- Can be left out if no args are required.
-- validateArgs will then also be ignored.
--
-- validateArgs(args)
-- Validate the args the user has typed in allready (or not)
-- and return an error message or true if all args are valid
-- Example:
-- if tonumber(args.Length) == nil then return "Length must be a number" end
-- if args.Direction ~= "north" and args.Direction ~="south" then
-- 		return "Direction must be 'north' or 'south'" end
-- return true -- if it passes here
-- If left out, true will be assumed as result.
--
-- getFuel()
-- Return the amount of fuel your operation needs (1 per movement).
-- The value will be checked against the actual fuel level of
-- the turtle and a message will be displayed if its insufficient.
-- Can be left out if no calculation is required.
-- 
-- getSlots()
-- Return a table of amount and item descriction to display in the ui.
-- Example: 
-- slots = {}
-- table.insert(slots, {64, "Stone"})
-- table.insert(slots, {20, "Wood"})
-- return slots
-- Can be left out.
-- 
-- validateSlots()
-- Return true or false if your calculation is not met or
-- return "builtInExact" or "builtInSum" if you want to check
-- with the built-in mechanism.
-- "builtInExact" checks for exact amounts in each slot where
-- "builtInSum" checks for the total amount of items in all slots.
-- There is no check against the item type, only amount.
-- Will be ignored when getSlots isn't present.
--
-- runApp()
-- After all checks have passed you can finally run your app.
-- All app code should be placed inside this function.
-- 

os.loadAPI("commonAPI")
os.loadAPI("turtleAPI")
local capi = commonAPI

capi.setLog(false)
capi.createNewLog()

local configFilename = "startui.cfg"

local system = {}
system.type = "Computer"
system.coords = {x = 0, z = 0, y = 0}
system.fuel = nil

local appDir = "_apps"

local apps = {}
local currentApp = nil

local miscFunctions = {}

local currentPage = nil

local pageItems = {}

local cursorStops = {}
local cursorStop = 1


local loadConfig = function()
  local config = capi.loadKeyValueTable(configFilename)
  if config ~= nil and config[1][2] ~= "" then
	  currentApp = config[1][2]
--	  local app = _G[currentApp]
--	  system.coords.x = config[2][2]
--	  system.coords.z = config[3][2]
--	  system.coords.y = config[4][2]
--	  for i = 2, #config do
--      table.insert(app.params, {config[i][1], config[i][2]})
--    end
  end
  return config
end

local saveConfig = function()
  local config = {}
  local app = _G[currentApp]
  table.insert(config, {"lastProgram", app.name})
--  table.insert(config, {"systemx", system.coords.x})
--  table.insert(config, {"systemz", system.coords.z})
--  table.insert(config, {"systemy", system.coords.y})
--  for k,v in ipairs(app.params) do
--    table.insert(config, {v[1], v[2]})
--  end
  capi.saveKeyValueTable(config, configFilename)
end

local saveAppConfig = function(app)

	local config = {}
	local file = fs.combine(appDir, app.name..".cfg")
	for k,v in pairs(app.params) do
		table.insert(config, {v[1], v[2]})
	end
	capi.saveKeyValueTable(config, file)

end

local loadAppConfig = function(app)
	
	local app = _G[currentApp]
	
	local filename = fs.combine(appDir, app.name..".cfg")
	if not fs.exists(filename) then return end
	local config = capi.loadKeyValueTable(filename)
	
	-- check if app params have changed (new app version)
	local allmatch = true
	for k, v in pairs(app.params) do
		local match = false
		for l, u in pairs(config) do
			if v[1] == u[1] then
				match = true
			end
		end
		if not match then allmatch = false break end
	end
	
	if allmatch then
		for k, v in pairs(app.params) do
			for l, u in pairs(config) do
				if v[1] == u[1] then
					if tonumber(u[2]) ~= nil then
						v[2] = tonumber(u[2])
					else
						v[2] = u[2]
					end
				end
			end	
		end
	end
	
end


local sprint = function(text, x, y)

	term.setCursorPos(x, y)
	io.write(text)

end


local printStatus = function(text)

	local x, y = term.getCursorPos()
	sprint("                                       ", 1, 13)
	sprint(text, 1, 13)
	term.setCursorPos(x, y)

end


local drawBlankPage = function()

	sprint("|            |            |           |", 1, 1)
	sprint("                                       ", 1, 2)
	sprint("                                       ", 1, 3)
	sprint("                                       ", 1, 4)
	sprint("                                       ", 1, 5)
	sprint("                                       ", 1, 6)
	sprint("                                       ", 1, 7)
	sprint("                                       ", 1, 8)
	sprint("                                       ", 1, 9)
	sprint("                                       ", 1, 10)
	sprint("                                       ", 1, 11)
	sprint("                                       ", 1, 12)
	sprint("                                       ", 1, 13)
  sprint("Start", 2, 1)
  sprint("Apps", 15, 1)
  sprint("Misc", 28, 1)
  cursorStop = 1

end


local isRequirementsExact = function()
  
  local app = _G[currentApp]
  for i = 1, #app.slots do
    if turtle.getItemCount(i) < app.slots[i][1] then
      return false
    end
  end
  return true
  
end

-- check turtle slots
local isRequirementsMinimum = function()
  
  local app = _G[currentApp]
  local sumReq = 0
  for i = 1, #app.slots do
    sumReq= sumReq + app.slots[i][1]
  end
  
  local sumTur = 0
  for i = 1, 16 do
    sumTur = sumTur + turtle.getItemCount(i)
  end
  return sumTur >= sumReq
  
end


local drawSelectionList = function(items, line)
	
	local x = 0
	local y = line
capi.cclogtable("drawSelectionList-> ", items)
	for key, item in ipairs(items) do
	
		local text = ""
		if #item > 18 then
			text = string.sub(item, 1, 18)
		else
			text = item
		end
		sprint(text, x + 1, y)
		table.insert(cursorStops, {x = x + 1, y = y})
		
		if x == 0 then
			x = 20
		else
			x = 0
			y = y + 1
		end
	
	end

end


local adjustParameter = function(parameter)
  local x = 9 - #parameter
  if x < 1 then x = 1 end
  local par = ""
  if #parameter > 8 then
    par = string.sub(parameter, 1, 8)
  else
    par = parameter
  end
  return par, x
end


local drawAttributeList = function(attributes, line)
capi.cclogtable("drawAttributeList-> ", attributes)
	cursorStops = {}
	
	local x = 0
	local y = line

	for key, value in ipairs(attributes) do
		
		local keytext, keyx = adjustParameter(value[1])
		sprint(keytext..">", x + keyx, y)
		if value[2] ~= nil then 
			if type(value[2]) == "numberx" then
				io.write(math.floor(value[2]))
			else	
				io.write(value[2])
			end
		end
		
		table.insert(cursorStops, {x = x + 10, y = y})
		
		if x == 0 then
			x = 20
		else
			x = 0
			y = y + 1
		end
	
	end

end


local drawSlots = function(slots)

	local x = 0
	local y = 9
	for _, slot in ipairs(slots) do
	
		local digit = slot[1] > 9 and 2 or 3
    term.setCursorPos(x*10 + digit, y)
    io.write(slot[1])
    term.setCursorPos(x*10 + 5, y)
    local item = slot[2]
    if #item > 5 then
      item = string.sub(item, 1, 5)
    end
    io.write(item)
		x = x + 1
		if x > 3 then 
			x = 0
			y = y + 1
			if y > 12 then break end
		end
	
	end

end


local startPage = function()
capi.cclog("startPage->")
	sprint("[",  1, 1)
	sprint("]", 14, 1)
	sprint("|", 27, 1)
	sprint("|", 39, 1)
	
	cursorStops = {}
	
	local screen = [[[  ]      [  ]      [  ]      [  ]
[  ]      [  ]      [  ]      [  ]
[  ]      [  ]      [  ]      [  ]
[  ]      [  ]      [  ]      [  ]
]]
	sprint(screen, 1, 9)
	sprint("App: ", 1, 2)
	if currentApp ~= nil then
capi.cclog("startPage->currentApp "..currentApp)
		local app = _G[currentApp]
		io.write(app.name)
capi.cclogtable("startPage->app", app)
		if app.getArgs ~= nil then
			local args = app.getArgs()
			app.params = {}
			for k,v in pairs(args) do
				table.insert(app.params, {v, 0})
			end
			loadAppConfig(app)
	capi.cclogtable("startPage->app.params", app.params)
	
			drawAttributeList(app.params, 3)
		end
		drawSlots(app.slots)
	end
	table.insert(cursorStops, {x = 1, y = 13})
end


local appPage = function()
capi.cclog("appPage->")
	sprint("|",  1, 1)
	sprint("[", 14, 1)
	sprint("]", 27, 1)
	sprint("|", 39, 1)
	cursorStops = {}
	
	drawSelectionList(apps, 3)
	
	table.insert(cursorStops, {x = 1, y = 13})
capi.cclogtable("appPage->cursorStops: ", cursorStops)
end


refuel = function()

	turtle.refuel()

end


local miscPage = function()
capi.cclog("miscPage->")
	sprint("|",  1, 1)
	sprint("|", 14, 1)
	sprint("[", 27, 1)
	sprint("]", 39, 1)
	
	if system.type == "Turtle" then system.fuel = turtle.getFuelLevel() end
	
	sprint(system.type.."("..os.getComputerID()..") \""..os.getComputerLabel().."\"", 1, 2)
	local coords = {}
	coords[1] = {"x", system.coords.x}
	coords[2] = {"z", system.coords.z}
	coords[3] = {"y", system.coords.y}
	drawAttributeList(coords, 3)

	drawSelectionList(miscFunctions, 5)
	
	sprint("exit", 36, 12)
	table.insert(cursorStops, {x = 36, y = 12})
		
	table.insert(cursorStops, {x = 1, y = 13})

end

-- set cursorStop
local setCursor = function(pos)
capi.cclog("setCursor-> "..pos)
  term.setCursorPos(cursorStops[pos].x, cursorStops[pos].y)
  if pos == #cursorStops then
    if currentPage == 0 then  
      printStatus("hit ENTER to start program")
    elseif currentPage == 1 then
      printStatus("Select Program and ENTER to setup")
    end
  end
  
end

local start = function()

	term.setCursorBlink(true)
	drawBlankPage()
	currentPage = startPage
	currentPage()
	
	cursorStop = 1
	local key = nil
	
	repeat
	
		setCursor(cursorStop)
		key = capi.pullKey()
capi.cclog("pullKey: "..(true and capi.getKeyTable()[key] or key))
		if false then
		
		elseif key == capi.getKeyTable().TAB then
      if currentPage == startPage then
      	currentPage = appPage
      elseif currentPage == appPage then
      	currentPage = miscPage
      elseif currentPage == miscPage then
      	currentPage = startPage
      end
      drawBlankPage()
      currentPage()

	    cursorStop = 1
      
		elseif key == capi.getKeyTable().UP then
			cursorStop = cursorStop - 2
			if cursorStop == 0 then
				cursorStop = 1
			elseif cursorStop == -1 then
				cursorStop = #cursorStops
			end
			
		elseif key == capi.getKeyTable().LEFT then
			cursorStop = cursorStop - 1
			if cursorStop == 0 then
				cursorStop = #cursorStops
			end
			
		elseif key == capi.getKeyTable().DOWN then
			cursorStop = cursorStop + 2
			if cursorStop == #cursorStops + 1 then
				cursorStop = #cursorStops
			elseif cursorStop == #cursorStops + 2 then
				cursorStop = 1
			end
			
		elseif key == capi.getKeyTable().RIGHT then
			cursorStop = cursorStop + 1
			if cursorStop == #cursorStops + 1 then
				cursorStop = 1
			end
			
		elseif key == capi.getKeyTable().ENTER then
			if currentPage == startPage and currentApp ~= nil and cursorStop == #cursorStops then
				local app = _G[currentApp]
				local params = {}
				for k,v in ipairs(app.params) do
					params[v[1]] = v[2]
				end
capi.cclogtable("start->enter->params", params)
				local valid = true
				if app.getArgs ~= nil and app.validateArgs ~= nil then
					valid = app.validateArgs(params)
				end
				if valid ~= true then
					printStatus(valid)
					
				else
					local validSlots = true
					if app.getSlots ~= nil and app.validateSlots ~= nil then
						app.slots = app.getSlots()
						drawSlots(app.slots)
						validSlots = app.validateSlots()
					end
					local fuel = 0
					if app.getFuel ~= nil then
						fuel = app.getFuel()
					end
					if fuel > turtle.getFuelLevel() then
						printStatus("Turtle needs "..fuel-turtle.getFuelLevel().." more fuel")
					
					elseif validSlots == "builtInExact" and
					not isRequirementsExact() then
						printStatus("Exact slot supply needed")
					elseif validSlots == "builtInSum" and
					not isRequirementsMinimum() then
						printStatus("More Items needed in sum")
					elseif validSlots == false then
						printStatus("App reports invalid slot supply")
					else
						saveConfig()
						saveAppConfig(app)
						term.clear()
						sprint("Running "..app.name..">\n", 1, 1)
						if app.runApp ~= nil then
							app.runApp()
						else
							print("No runApp() function. No code to execute.")
						end
						print(app.name.." has finished. Press key")
						capi.pullKey()
						drawBlankPage()
						currentPage()
					end

				end
			
			elseif currentPage == appPage then
			
				currentApp = apps[cursorStop]
				loadAppConfig(currentApp)
				currentPage = startPage
				drawBlankPage()
				currentPage()
			
			elseif currentPage == miscPage then
capi.cclogtable("start->miscPage->miscFunctions", miscFunctions)
				if cursorStop == #cursorStops - 1 then
					term.clear()
					term.setCursorPos(1, 1)
					return
				elseif cursorStop == #cursorStops then
					
				elseif cursorStop > 3 and cursorStop < #cursorStops-1 then
					_G[miscFunctions[cursorStop-3]]()
				end
			end
			
		-- parameter input
		elseif currentPage == startPage and cursorStop ~= #cursorStops and
		(capi.isNumberKey(key) or capi.isLetterKey(key)
		or key == capi.getKeyTable().MINUS) then
			if currentPage == startPage then
				local app = _G[currentApp]
				local char = capi.pullChar()
				setCursor(cursorStop)
				io.write("        ")
				setCursor(cursorStop)
				printStatus("Input value for '"..app.params[cursorStop][1].."'")
				local input = capi.rawInput(char)
				app.params[cursorStop][2] = input
				setCursor(cursorStop)
				printStatus("Param set to: "..app.params[cursorStop][2])
			
			elseif currentPage == miscPage then
				if cursorStop < 4 then
					setCursor(cursorStop)
					io.write("        ")
					setCursor(cursorStop)
					local input = capi.rawInput(char)
					if tonumber(input) == nil then
						printStatus("Must be a number")
						drawBlankPage()
						currentPage()
					else
						if cursorStop == 1 then
							system.coords.x = tonumber(input)
						elseif cursorStop == 2 then
							system.coords.z = tonumber(input)
						elseif cursorStop == 3 then
							system.coords.y = tonumber(input)
						end
					end
					setCursor(cursorStop)
				end
			end
			
		end
		
	
	until key == capi.getKeyTable().HOME
	

end


local main = function()
capi.cclog("-> main()")
	-- read app location
	local list = fs.list("")
	if not fs.exists(appDir) then
		error("App directory '"..appDir.."' not found")
	end
	local files = fs.list(appDir)
capi.cclogtable("Files: ", files)
	for _, file in ipairs(files) do
		local iscfg = string.find(file, ".-%.cfg")
		if _G[file] ~= nil then
			print("App name '"..file.."' collides with existing library name. Please change.")
capi.cclog("App name '"..file.."' collides with existing library name. Please change.")
		elseif not iscfg then
			local app, err = loadfile("_apps\\"..file)
			if app then
				local tEnv = {}
				setmetatable(tEnv, {__index = _G})
				setfenv(app, tEnv)
				app()

				local tApi = {}
				for k,v in pairs(tEnv) do
					tApi[k] = v
				end
capi.cclogtable("tApi", tApi)
				tApi.name = file
				tApi.params = {}
				tApi.slots = {}
				_G[file] = tApi
				table.insert(apps, file)
capi.cclog("app '"..file.."' loaded")
			else
				print(err)
capi.cclog("loadfile('"..file.."'), "..err)
			end
		end
		
	end
capi.cclogtable("Apps: ", apps)
	
	loadConfig()
	
	if _G["turtle"] ~= nil then	system.type = "Turtle"
	else system.type = "Computer" end
	if system.type == "Turtle" then system.fuel = turtle.getFuelLevel() end
	
	miscFunctions = {
		"refuel"
	}

	_G["refuel"] = refuel
	
	start()

end

main()

--