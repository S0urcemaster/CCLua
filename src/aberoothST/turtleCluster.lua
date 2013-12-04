-- redstoneTest

local capi = commonAPI
local gui = guiAPI

local clientserver = "server"
local monitorLoc = "top"
local modemLoc = "left"
local activaLoc = "back"
local switchLoc = "right"

local buttonActiveIndex = 1

-- quick solution to avoid greater changes
local remoteActionsList = {
	[1] = 1, [2] = 2, [3] = 4, [4] = 3, [5] = 6, [6] = 5
}

local sleeptime = 0.3

local sprint = function(text, x, y)

	term.setCursorPos(x, y)
	io.write(text)

end


getInfo = function()
	
	local info = {}
--3456789012345678901234567890123456789
info[1] =
[[Sets up a client-server system where
you can control multiple turtles at the
same time.
Input monitorLoc and modemLoc on the
server. The client does not need that.
clientserver = 'c' or 's' for client or
server
...Loc = location of peripherals: 'top'
'left' 'right' 'front' 'back' 'bottom'
Leave out if not present
moninitorLoc = monitor location
modemLoc = modem location]]

info[2] =
[[activaLoc = location of the wireless
reciever to activate an action
switchLoc = location of the wireless
reciever to switch actions
To use a wireless remote, you take 2
of them. One is the activator to move
the turtles, the other switches the
commands in this order: forward>left>
>right>up>down>back. If you activate
the switch remote you move one step in
the list. When you activate the activ
ator then the list jumps back to]]

info[3] = 
[['forward' because you will need forw
ard most. If you want to move the
turtles forward>down>left>forward then
you do for (a)activator and (s) switch:
a>s>s>s>s>a>s>a>a.
]]
	
	return info

end


getArgs = function()

  return {"clientserver", "monitorLoc", "modemLoc", "activaLoc", "switchLoc"}
  
end


validateArgs = function(args)
	
	if args.clientserver ~= "c" and args.clientserver ~= "s" 
	then return "Client/Server must be 'c' or 's'" end
	
	if args.clientserver == "s" then
		if args.monitorLoc ~= "top" and args.monitorLoc ~= "left" 
		and args.monitorLoc ~= "right" and args.monitorLoc ~= "front" 
		and args.monitorLoc ~= "back" and args.monitorLoc ~= "bottom" 
		then return "top/left/right/front/back/bottom" end
		
		if args.modemLoc ~= "top" and args.modemLoc ~= "left" 
		and args.modemLoc ~= "right" and args.modemLoc ~= "front" 
		and args.modemLoc ~= "back" and args.modemLoc ~= "bottom" 
		then return "top/left/right/front/back/bottom" end
	end
	
	clientserver = args.clientserver
	monitorLoc = args.monitorLoc
	
	return true
	
end


local cluster = {}
local nextChannel = 10


local addToCluster = function(turtleId, channel)

	table.insert(cluster, {id = turtleId, channel = channel})

end


runApp = function()

	if clientserver == "s" then
	
		print("Here Server :)")
		local monitor = peripheral.wrap(monitorLoc)
		if monitor then
			gui.writeln("Monitor wrapped to "..monitorLoc)
		else
			gui.writeln("No monitor found at "..monitorLoc)
			gui.writeln("Press key to return")
			capi.pullKey()
			return
		end
		local modem = peripheral.wrap(modemLoc)
		if modem then
			gui.writeln("Modem wrapped to "..modemLoc)
		else
			gui.writeln("No modem found at "..monitorLoc)
			gui.writeln("Press key to return")
			capi.pullKey()
		end
		
		-- print buttons
		local buttons = {}
		table.insert(buttons, gui.make4x4Button(gui.preDefButtons.forward, "forward", colors.white, colors.blue, 6, 1))
		table.insert(buttons, gui.make4x4Button(gui.preDefButtons.left, "left", colors.white, colors.blue, 1, 5))
		table.insert(buttons, gui.make4x4Button(gui.preDefButtons.up, "up", colors.white, colors.blue, 6, 5))
		table.insert(buttons, gui.make4x4Button(gui.preDefButtons.right, "right", colors.white, colors.blue, 11, 5))
		table.insert(buttons, gui.make4x4Button(gui.preDefButtons.back, "back", colors.white, colors.blue, 6, 9))
		table.insert(buttons, gui.make4x4Button(gui.preDefButtons.down, "down", colors.white, colors.blue, 11, 9))
		
		term.redirect(monitor)
		monitor.setTextScale(0.5)
		gui.draw4x4Buttons(buttons)
		term.restore()
		
		modem.open(2)
		
		repeat
		
			local event = {os.pullEvent()}
			
			local x, y
			if event[1] == "key" then
				if event[2] == 45 then break end
			elseif event[1] == "monitor_touch" then
				print("monitor touch at "..event[3].."/"..event[4])
				local bIndex = gui.getButtonClickedIndex(buttons, event[3], event[4])
				if bIndex ~= nil then
					term.redirect(monitor)
					gui.drawClickedButton(buttons[bIndex])
					term.restore()
					
					for _, turtle in ipairs(cluster) do
						print("Sending '"..buttons[bIndex].action.."' to channel "..turtle.channel)
						local action = buttons[bIndex].action
						local timeout = #cluster
						modem.transmit(turtle.channel, 0, textutils.serialize({action = action, timeout = timeout}))
					end
					
					sleep(sleeptime)
					term.redirect(monitor)
					gui.drawUnclickedButton(buttons[bIndex])
					term.restore()
				end
			elseif event[1] == "modem_message" then
				print("modem message")
				local modemSide = event[2]
				local senderChannel = event[3]
				local replyChannel = event[4]
				local message = event[5]
				local senderDistance = event[6]
				if senderChannel == 2 then
					local tab = textutils.unserialize(message)
					if tab[1] == "give channel" then
						print("Channel request from turtle "..tab[2]..". Returning->"..nextChannel)
						addToCluster(tab[2], nextChannel)
						modem.transmit(1, nextChannel, "")
						nextChannel = nextChannel +1
					end

				end
				
			elseif event[1] == "redstone" then
				if rs.getInput(switchLoc) then
					
					buttonActiveIndex = (buttonActiveIndex +1) %7
					if buttonActiveIndex == 0 then buttonActiveIndex = 1 end
				elseif rs.getInput(activaLoc) then
					
					for _, turtl in ipairs(cluster) do
						print("Sending '"..buttons[remoteActionsList[buttonActiveIndex]].action.."' to channel "..turtl.channel)
						local action = buttons[remoteActionsList[buttonActiveIndex]].action
						local timeout = #cluster
						modem.transmit(turtl.channel, 0, textutils.serialize({action = action, timeout = timeout}))
					end
					buttonActiveIndex = 1
					
				end
				
			end
			
		
		until false
		
		
		
	elseif clientserver == "c" then
	
		print("To your service :)")
		print("Calling server...")
		local modem = peripheral.wrap("right")
		modem.transmit(2, 0, textutils.serialize({"give channel", os.getComputerID()}))
		modem.open(1)
		local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
		print("Answer: Listen to channel "..replyChannel)
		modem.close(1)
		modem.open(replyChannel)
		repeat
			event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
			local mess = textutils.unserialize(message)

			local timeout = mess.timeout
			
			if mess.action == "forward" then
				while not turtle.forward() and timeout > 0 do
					sleep(sleeptime)
					timeout = timeout -sleeptime
				end
				
			elseif mess.action == "back" then
				while not turtle.back() and timeout > 0 do
					sleep(sleeptime)
					timeout = timeout -sleeptime
				end
			elseif mess.action == "left" then
				turtle.turnLeft()
			elseif mess.action == "right" then
				turtle.turnRight()
			elseif mess.action == "up" then
				while not turtle.up() and timeout > 0 do
					sleep(sleeptime)
					timeout = timeout -sleeptime
				end
			elseif mess.action == "down" then
				while not turtle.down() and timeout > 0 do
					sleep(sleeptime)
					timeout = timeout -sleeptime
				end
			end
		until false
		modem.close(replyChannel)
		capi.pullKey()
	end

end

-- 