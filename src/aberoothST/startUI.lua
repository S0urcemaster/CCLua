-- startUI limited to Standard Computer (39 x 13)
--
-- All apps in the "/_app" directory will be accessible in the ui.
-- For a description of the interface to developing own apps
-- refer to _AppInterfaceDef.lua on github.com/snhub/cclua.

local logging = true

--3456789012345678901234567890123456789
local helpPages = {}
helpPages[1] = 
[[Hi, this is startUI, a user interface
for running apps and managing user
input. After installation, you can
start with the command "startui".
There are 3 pages you can switch with
the TAB key. The first is the start
page, which displays the currently
active app, the second is the app
page where you can select one of the
available programs, the third is the
misc page with tools like refuel.
]]
--3456789012345678901234567890123456789
helpPages[2] = 
[[Selecting Apps
From the start page hit TAB to go to
the app page. A list of all available
apps is being displayed. Use the ARROW
keys to select an app and hit ENTER.
You will be returned to the start page
and the parameters required for input
are being displayed.
If you have run this app before, the
last values are loaded from its config
file.
]]
--3456789012345678901234567890123456789
helpPages[3] =
[[Starting Apps
After selecting an app, access each
parameter with the ARROW keys, edit it
with just typing letters or numbers.
Complete input with an ARROW key or
ENTER. If you typed in the required
values move to the bottom line with the
ARROW keys and hit ENTER to start the
app. If anything went wrong, a status
message is displayed in the bottom
line. Change the parameter that is
wrong and hit enter to see the result.
]]
--3456789012345678901234567890123456789
helpPages[4] =
[[If all parameters are correct, the
slots that need to be filled are
displayed. Fill the slots with the
denoted blocks until the requirements
are met. If the active app no longer
reports errors, it will run.
Additionally the input parameters are
stored in a config file and are loaded
when you start the app again later.
Also the last used app is stored and
loaded after reboot or logout.
]]
--3456789012345678901234567890123456789
helpPages[5] =
[[Any time you install or update, the
"_app" folder will be cleared to remove
deprecated files.
If you do not want this, install
manually or make a backup.]]

os.loadAPI("commonAPI")
os.loadAPI("turtleAPI")
local capi = commonAPI
os.loadAPI("guiAPI")

shell.run("globals")

capi.setLog(logging)
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
local paramsOffset = 1


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
	for k,v in ipairs(app.params) do
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
	for k, v in ipairs(app.params) do
		local match = false
		for l, u in ipairs(config) do
			if v[1] == u[1] then
				match = true
			end
		end
		if not match then allmatch = false break end
	end
	
	if allmatch then
		for k, v in ipairs(app.params) do
			for l, u in ipairs(config) do
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


local drawInfoPage = function()

	local app = _G[currentApp]
	local info = app.getInfo()
	
	
	for i = 1, #info do
		term.clear()
		sprint(info[i], 1, 1)
		if i < #info then
			sprint("Page "..i.."/"..#info.." Press any key to continue", 1, 13)
			capi.pullKey()
		end
	end
	
	sprint("Press any key to return to menu", 1, 13)
	capi.pullKey()

end


local drawHelpPage = function()

	for i = 1, #helpPages do
		term.clear()
		sprint(helpPages[i], 1, 1)
		if i < #helpPages then
			sprint("Page "..i.."/"..#helpPages.." Press any key to continue", 1, 13)
			capi.pullKey()
		end
	end
	
	sprint("Press any key to return to menu", 1, 13)
	capi.pullKey()

end


local drawDetailSlotsPage = function()

	sprint("[  ]      [  ]      [  ]      [  ]     ", 1, 1)
	sprint("|         |         |         |        ", 1, 2)
	sprint("|         |         |         |        ", 1, 3)
	sprint("[  ]      [  ]      [  ]      [  ]     ", 1, 4)
	sprint("|         |         |         |        ", 1, 5)
	sprint("|         |         |         |        ", 1, 6)
	sprint("[  ]      [  ]      [  ]      [  ]     ", 1, 7)
	sprint("|         |         |         |        ", 1, 8)
	sprint("|         |         |         |        ", 1, 9)
	sprint("[  ]      [  ]      [  ]      [  ]     ", 1, 10)
	sprint("|         |         |         |        ", 1, 11)
	sprint("|         |         |         |        ", 1, 12)
	sprint("Press key to return                    ", 1, 13)
	term.setCursorPos(21, 13)
	
	local app = _G[currentApp]
	
	local x = 0
	local y = 1
	for i = 1, #app.slots do
	
		local digit = app.slots[i][1] > 9 and 2 or 3
    term.setCursorPos(x *10 +digit, y)
    io.write(app.slots[i][1])
    term.setCursorPos(x *10 +5, y)
    local item = app.detailSlots[i][1]
    
    if item ~= nil and #item ~= 0 then
	    if #item > 6 then
	      item = string.sub(item, 1, 6)
	    end
	    io.write(item)
	  end
    
    for j = 1, 2 do
	    item = app.detailSlots[i][j+1]
	    if item ~= nil and #item ~= 0 then
	    	if #item > 9 then
	    		item = string.sub(item, 1, 9)
	    	end
	    	sprint(item, x *10 +2, y +j)
			end
		end
		x = x +1
		if x > 3 then 
			x = 0
			y = y +3
			if y > 12 then break end
		end
	
	end
	
	capi.pullKey()
	sprint("Press any key to return", 1, 13)

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
    if #item > 6 then
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
		
		if app.getInfo ~= nil then
			sprint("Info / ", 29, 2)
			table.insert(cursorStops, {x = 29, y = 2})
			paramsOffset = 2
		else
			paramsOffset = 1
		end
		
		sprint("Help", 36, 2)
		table.insert(cursorStops, {x = 36, y = 2})
		
capi.cclogtable("startPage->app", app)
		if #app.params == 0 then -- no user input yet
			if app.getArgs ~= nil then
				local args = app.getArgs()
				app.params = {}
				for k,v in pairs(args) do
					table.insert(app.params, {v, 0})
				end
				loadAppConfig(app)
capi.cclogtable("startPage->app.params", app.params)
		
			end
		end
		drawAttributeList(app.params, 3)
		drawSlots(app.slots)
		if app.detailSlots ~= nil then
			table.insert(cursorStops, {x = 1, y = 9})
		end
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


local refuel = function()

	turtle.refuel()

end


local miscPage = function()
capi.cclog("miscPage->")
	sprint("|",  1, 1)
	sprint("|", 14, 1)
	sprint("[", 27, 1)
	sprint("]", 39, 1)
	
	cursorStops = {}
	local id = os.getComputerID() ~= nil and os.getComputerID() or "no_id"
	local label = os.getComputerLabel() ~= nil and os.getComputerLabel() or "no_label"
	sprint(system.type.."("..id..") \""..label.."\"", 1, 2)
	if system.type == "Turtle" then
		system.fuel = turtle.getFuelLevel()
		io.write(", Fuel: "..system.fuel)
	end
	
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
					local slotsValid = true
					if app.getSlots and app.validateSlots then
						app.slots = app.getSlots()
						if app.getDetailSlots ~= nil then
							app.detailSlots = app.getDetailSlots()
						end 
						currentPage()
						slotsValid = app.validateSlots()
					end
					local fuel = 0
					if app.getFuel then
						fuel = app.getFuel()
					end
					if turtle then
						if fuel > turtle.getFuelLevel() then
							printStatus("Turtle needs "..fuel -turtle.getFuelLevel().." more fuel")
						end
					end
					if slotsValid == "builtInExact" and	not isRequirementsExact() then
						printStatus("Exact slot supply needed")
					elseif slotsValid == "builtInSum" and	not isRequirementsMinimum() then
						printStatus("More Items needed in sum")
					elseif slotsValid == false then
						printStatus("App reports invalid slot supply")
					else
capi.cclogtable("start->enter->save config->app", app)
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
			
			elseif currentPage == startPage and currentApp ~= nil
			and (cursorStop == 1 or (cursorStop == 2 and _G[currentApp].getInfo ~= nil) 
			or cursorStop == #cursorStops -1) then
			
				if cursorStop == 1 then
					if _G[currentApp] == nil then
						drawHelpPage()
					else
						drawInfoPage()
					end
				elseif cursorStop == #cursorStops -1 then
					drawDetailSlotsPage()
				else
					drawHelpPage()
				end
				drawBlankPage()
				currentPage()
				
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
				printStatus("Input value for '"..app.params[cursorStop -paramsOffset][1].."'")
				local input = capi.rawInput(char)
				app.params[cursorStop -paramsOffset][2] = input
				setCursor(cursorStop)
				printStatus("Param set to: "..app.params[cursorStop -paramsOffset][2])
capi.cclog("start->input->"..app.params[cursorStop -paramsOffset][1].."->'"..input.."'")
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
			table.insert(apps, file)
capi.cclog("App name '"..file.."' possibly collides with existing library name.")
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
				tApi.detailSlots = {}
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