-- startUI limited to Standard Computer (39 x 13)
os.loadAPI("commonAPI")
local capi = commonAPI

capi.setLog(true)
capi.createNewLog()

local configFilename = "startui.cfg"

local appDir = "_apps"

local apps = {}
local currentApp = nil

local currentPage = nil

local pageItems = {}

local cursorStops = {}
local cursorStop = 1

local loadConfig = function()
  local config = capi.loadKeyValueTable(configFilename)
  if config ~= nil then
    for k,v in pairs(config) do
      if v[1] == "lastProgram" then
        currentProgram = v[2]
      else
        table.insert(params, {v[1], v[2]})
      end
    end
  end
  return config
end

local saveConfig = function()
  local config = {}
  table.insert(config, {"lastProgram", currentApp.name})
  for k,v in pairs(currentApp.params) do
    table.insert(config, {v[1], v[2]})
  end
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
					v[2] = u[2]
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


local drawSelectionList = function(items)
	
	local x = 0
	local y = 3
capi.cclogtable("drawSelectionList-> ", items)
	for key, item in ipairs(items) do
	
		text = ""
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
capi.cclogtable("drawAttributeList-> ", attributes)
	cursorStops = {}
	
	local x = 0
	local y = 3

	for key, value in pairs(attributes) do
		
		local keytext, keyx = adjustParameter(value[1])
		sprint(keytext..">", x + keyx, y)
		if value[2] ~= nil then io.write(value[2]) end
		
		table.insert(cursorStops, {x = x + 10, y = y})
		
		if x == 0 then
			x = 20
		else
			x = 0
			y = y + 1
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
		local app = _G[currentApp]
		io.write(app.name)
capi.cclog("startPage->currentApp "..currentApp)
capi.cclogtable("startPage->app", app)
		local args = app.getArgs()
		app.params = {}
		for k,v in pairs(args) do
			table.insert(app.params, {v, 0})
		end
		loadAppConfig(app)
capi.cclogtable("startPage->app.params", app.params)

		drawAttributeList(app.params)
		local x = 0
		local y = 9
		for _, req in ipairs(app.reqs) do
		
			local digit = req[1] > 9 and 2 or 3
	    term.setCursorPos(x*10 + digit, y)
	    io.write(req[1])
	    term.setCursorPos(x*10 + 5, y)
	    local item = req[2]
	    if #item > 5 then
	      item = string.sub(item, 1, 5)
	    end
	    io.write(item)
			x = x + 1
			if x > 3 then x = 0 end
			y = y + 1
			if y > 12 then break end
		
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
	
	drawSelectionList(apps)
	
	table.insert(cursorStops, {x = 1, y = 13})
capi.cclogtable("appPage->cursorStops: ", cursorStops)
end


local miscPage = function()
capi.cclog("miscPage->")
	sprint("|",  1, 1)
	sprint("|", 14, 1)
	sprint("[", 27, 1)
	sprint("]", 39, 1)

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
			if currentPage == startPage then
				local app = _G[currentApp]
				local params = {}
				for k,v in ipairs(app.params) do
					params[v[1]] = v[2]
				end
				local valid = app.validateArgs(params)
				if valid ~= "ok" then
					printStatus(valid)
					
				else
					local validSlots = app.validateSlots()
					if app.getFuel() > 
					turtle.getFuelLevel() then
						printStatus("Turtle needs "..currentApp.getFuel().." fuel")
					
					elseif validSlots == "builtInExact" and
					not isRequirementsExact() then
						printStatus("Exact slot supply needed")
					elseif validSlots == "builtInSum" and
					not isRequirementsMinimum then
						printStatus("More Items needed in sum")
					elseif validSlots == false then
						printStatus("App reports invalid slot supply")
					else
						saveAppConfig(app)
						term.clear()
						sprint("Running "..currentApp.name..">", 1, 1)
						currentApp.run()
						sprint(currentApp.name.." has finished. Press key")
					end

				end
			
			elseif currentPage == appPage then
			
				currentApp = apps[cursorStop]
				currentPage = startPage
				drawBlankPage()
				currentPage()
			
			end
			
		elseif currentPage == startPage and cursorStop ~= #cursorStops and
		(capi.isNumberKey(key) or capi.isLetterKey(key)
		or key == capi.getKeyTable().MINUS) then
			local char = capi.pullChar()
			setCursor(cursorStop)
			io.write("        ")
			setCursor(cursorStop)
			printStatus("Input value for '"..
				currentApp.params[cursorStop].."'")
			local input = capi.rawInput(char)
			currentApp.params[cursorStop] = input
			term.setCursor(cursorStop)
			printStatus("Param set to: "..currentApp.params[cursorStop])
			
		end
		
	
	until key == capi.getKeyTable().ESCAPE
	

end


local main = function()
capi.cclog("-> main()")
	-- read app location
	local list = fs.list("")
	for l in ipairs(list) do
		io.write(l)
	end
	if not fs.exists(appDir) then
		error("App directory '"..appDir.."' not found")
	end
	local files = fs.list(appDir)
capi.cclogtable("Files: ", files)
	for _, file in ipairs(files) do
		if _G[file] ~= nil then
			print("App name '"..file.."' collides with existing library name. Please change.")
capi.cclog("App name '"..file.."' collides with existing library name. Please change.")
		else
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
				tApi.reqs = {}
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
	
	-- load configs
	
	
	start()

end

main()

--