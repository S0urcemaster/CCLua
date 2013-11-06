-- startup

io.write("Hello, I am " .. os.computerLabel() .. " (id:" .. os.computerID() .. ") Fuel: "..turtle.getFuelLevel().."\n")

os.loadAPI("capi")
os.loadAPI("tapi")
os.loadAPI("mapi")
os.loadAPI("geom")


--mainMenu = {
--[0] = "Turtle Main Menu",
--[1] = "Tunnel50",
--[2] = "Tunnel X",
--[9] = "Service"
--}
--tunnelMenu = {
--  [0] = "Tunnel",
--  [1] = "",
--  [2] = ""
--}
--serviceMenu = {
--[0] = "Service",
--[1] = "getFuelLevel",
--[2] = "refuel"
--}

--input = nil
--repeat
--	input = mapi.showMenu(mainMenu)
--	if input == 1 then dofile("tunnel50")
--	elseif input == 2 then dofile("tunnelx")
--	elseif input == 9 then
--		repeat
--			input = mapi.showMenu(serviceMenu)
--			if input == 1 then write("FuelLevel: "..turtle.getFuelLevel().."\n")
--			elseif input == 2 then
--				turtle.select(1)
--				turtle.refuel()
--			end
--		until input == nil
--		input = 9
--	end

--until input == nil