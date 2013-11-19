-- startUI limited to Standard Computer (39 x 13)

local appDir = "_apps"

local apps = {}

local page = {start = 0, programs = 1, misc = 2}

local pageItems = {}



local drawEmptyPage = function()

--io.write("123456789012345678901234567890123456789\n")
  term.clear()
  term.setCursorPos(1,1)
  io.write("|            |            |            \n")
  io.write("|            |            |\n")
  io.write("\n")
  io.write("\n")
  io.write("\n")
  io.write("\n")
  io.write("\n")
  io.write("\n")
  io.write("[  ]      [  ]      [  ]      [  ]     \n")
  io.write("[  ]      [  ]      [  ]      [  ]\n")
  io.write("[  ]      [  ]      [  ]      [  ]\n")
  io.write("[  ]      [  ]      [  ]      [  ]\n")
  io.write("")

  term.setCursorPos(2, 1)
  io.write("Start")
  term.setCursorPos(15, 1)
  io.write("Porgrams")
  term.setCursorPos(28, 1)
  io.write("Misc")

end

local drawPageItems = function(n)

	

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
				tApi = {}
				for k,v in ipairs(tEnv) do
					tApi[k] = v
				end
				_G[file] = tApi
			else
				print(err)
			end
		end
		
	end
	
	start()

end

main()

--