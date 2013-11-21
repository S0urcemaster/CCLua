-- startUI limited to Standard Computer (39 x 13)
os.loadAPI("commonAPI")
local capi = commonAPI
assert(capi ~= nil)

local appDir = "_apps"

local apps = {}
local currentApp = {

	getArgs = function() return {} end,
	validateArgs = function() return true end,
	getFuel = function() return 10 end,
	getSlots = function() return {} end,
	validateSlots = function() return {} end,

}

currentApp.name = "No app selected"
currentApp.params = {}
currentApp.reqs = {}

local currentPage = nil

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











]]
	sprint(screen, 1, 1)
  sprint("Start", 2, 1)
  sprint("Apps", 15, 1)
  sprint("Misc", 28, 1)

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
	
	cursorStops = {}
	
	local x = 0
	local y = 3

	for key, value in ipairs(attributes) do
		
		local keytext, keyx = ajustParameter(key)
		sprint(keytext..">", x + keyx, y)
		if value ~= nil then io.write(value) end
		
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

	sprint("[",  1, 1)
	sprint("]", 14, 1)
	sprint("|", 27, 1)
	sprint("|", 39, 1)
	
	local screen = [[[  ]      [  ]      [  ]      [  ]
[  ]      [  ]      [  ]      [  ]
[  ]      [  ]      [  ]      [  ]
[  ]      [  ]      [  ]      [  ]
]]
	sprint(screen, 1, 9)
	sprint("App: ", 1, 2)
	if currentApp ~= nil then
		io.write(currentApp.name)
		drawAttributeList(currentApp.params)
		local x = 0
		local y = 9
		for req in ipairs(currentApp.reqs) do
		
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
	
end


local appPage = function()

	sprint("|",  1, 1)
	sprint("[", 14, 1)
	sprint("]", 27, 1)
	sprint("|", 39, 1)
	
	local appNames = {}
	for app in ipairs(apps) do
		table.insert(appNames, app.name)
	
	end
	
	drawSelectionList(appNames)
	
	
	
end


local miscPage = function()

	sprint("|",  1, 1)
	sprint("|", 14, 1)
	sprint("[", 27, 1)
	sprint("]", 39, 1)

end

-- set cursorStop
local setCursor = function(pos)
  
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
	table.insert(cursorStops, {x = 1, y = 13})
	
	cursorStop = 1
	local key = nil
	
	repeat
	
		setCursor(cursorStop)
		key = capi.pullKey()
		
		if false then
		
		elseif key == capi.getKeyTable().TAB then
      if currentPage == startPage then
      	currentPage = appPage
      elseif currentPage == appPage then
      	currentPage = miscPage
      elseif currentPage == miscPage then
      	currentPage = startPage
      end
      currentPage()

			table.insert(cursorStops, {x = 1, y = 13})
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
			
				if not currentApp.validateArgs(currentApp.params) then
					printStatus("Wrong or missing parameters")
					
				else
					local validSlots = currentApp.validateSlots()
					if currentApp.getFuel() > turtle.getFuelLevel() then
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
						term.clear()
						sprint("Running "..currentApp.name..">", 1, 1)
						currentApp.run()
						sprint(currentApp.name.." has finished. Press key")
					end

				end
			
			elseif currentPage == appPage then
			
				
			
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

	-- read app location
	local list = fs.list("")
	for l in ipairs(list) do
		io.write(l)
	end
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

	
	start()

end

main()

--