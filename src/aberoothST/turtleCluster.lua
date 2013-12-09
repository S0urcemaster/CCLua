-- redstoneTest

local capi = commonAPI
local gui = guiAPI

local clientserver = "server"
local monitorLoc = "top"
local modemLoc = "left"
local activaLoc = "back"
local switchLoc = "right"

local actionBuffer = {}


local remoteAction = 1
local remoteActions = {
	forward = 1, left = 2, right = 3, up = 4, down = 5, back = 6,
	[1] = "forward", [2] = "left", [3] = "right", [4] = "up", [5] = "down", [6] = "back"
}

local buttonToServerActionMapping = {
	[1] = 3, [2] = 4, [3] = 6, [4] = 5, [5] = 8, [6] = 7
}

local serverMessage = function(action, data1, data2)
	return textutils.serialize({action = action, data1 = data1, data2 = data2})
end

local serverAction = {logon = 1, switchState = 2, forward = 3, left = 4, right = 5, up = 6, down = 7, back = 8, install = 9}


local getServerActionFromRemote = function(remote)
	return serverAction[remoteActions[remote]]
end


local clientMessage = function(action, data1)
	return textutils.serialize({action = action, data1 = data1})
end

local clientAction = {logon = 1, onoff = 2, solo = 4, allOn = 5, setPivot = 6, rotate = 7, ready = 8}

local turtleStates = {on = 1, solo = 2, pivot = 4}

local turtleState = turtleStates.on


local toggleState = function(state, flag)
	state = bit.band(state, flag) == 0 and state +flag or state -flag
	return state
end

local hasState = function(state, flag)
print("state: "..state..", flag: "..flag)
	return bit.band(state, flag) == flag
end


local cluster = {}
local clusterSize = 0
local clusterBusyCounter = clusterSize

local addToCluster = function(turtleId, state)
	state = state or turtleStates.on
	cluster[turtleId] = state
	clusterSize = clusterSize +1
end


local pushCluster = function(modem)

	while true do
		if #actionBuffer > 0 then
			clusterBusyCounter = clusterSize
print("coroutine pushing cluster")
			for id,_ in pairs(cluster) do
				modem.transmit(id, 0, actionBuffer[1])
			end
			
			local event, modemSide, senderChannel, replyChannel, message, senderDistance
print(clusterBusyCounter)
			while clusterBusyCounter > 0 do
				coroutine.yield()
			end
			table.remove(actionBuffer, 1)
		else
print("Coroutine yielding")
			coroutine.yield()
		end
	end

end


local sleeptime = 0.3

local sprint = function(text, x, y)

	term.setCursorPos(x, y)
	io.write(text)

end


local printClientScreen = function(connected, status)

	term.clear()
	term.setCursorPos(1, 1)
	print("Here Turtle "..os.getComputerID())
	print()
	print("Connected to server: ", connected)
	print()
	local onoff, solo, pivot
	if bit.band(turtleState, turtleStates.on) == turtleStates.on then onoff = "on"
	elseif bit.band(turtleState, turtleStates.on) == 0 then onoff = "off"
	end
	if bit.band(turtleState, turtleStates.solo) == turtleStates.solo then solo = "true"
	elseif bit.band(turtleState, turtleStates.solo) == 0 then solo = "false"
	end
	if bit.band(turtleState, turtleStates.pivot) == turtleStates.pivot then pivot = "true"
	elseif bit.band(turtleState, turtleStates.pivot) == 0 then pivot = "false"
	end
	print("1 - On/Off ("..onoff..")")
	print("2 - Solo ("..solo..")")
	print("3 - All on")
	print("4 - Pivot ("..pivot..")")
	print()
	print(status)

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
you do for (a)activator and (s)switch:
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
	activaLoc = args.activaLoc
	switchLoc = args.switchLoc
	
	return true
	
end



runApp = function()

	if clientserver == "s" then
	
		print("Here Server :)")
		print("You can stop the server with 'x'")
		local monitor = peripheral.wrap(monitorLoc)
		if monitor then
			gui.writeln("Monitor wrapped to "..monitorLoc)
		end
		local modem = peripheral.wrap(modemLoc)
		if modem then
			gui.writeln("Modem wrapped to "..modemLoc)
		else
			gui.writeln("No modem found at "..monitorLoc)
			gui.writeln("Press key to return")
			capi.pullKey()
		end
		
		local buttons = {}
		if monitor then
			
			table.insert(buttons, gui.make4x4Button(gui.preDefButtons.forward, remoteActions.forward, colors.white, colors.blue, 6, 1))
			table.insert(buttons, gui.make4x4Button(gui.preDefButtons.left, remoteActions.left, colors.white, colors.blue, 1, 5))
			table.insert(buttons, gui.make4x4Button(gui.preDefButtons.up, remoteActions.up, colors.white, colors.blue, 6, 5))
			table.insert(buttons, gui.make4x4Button(gui.preDefButtons.right, remoteActions.right, colors.white, colors.blue, 11, 5))
			table.insert(buttons, gui.make4x4Button(gui.preDefButtons.back, remoteActions.back, colors.white, colors.blue, 6, 9))
			table.insert(buttons, gui.make4x4Button(gui.preDefButtons.down, remoteActions.down, colors.white, colors.blue, 11, 9))
			
			term.redirect(monitor)
			monitor.setTextScale(0.5)
			gui.draw4x4Buttons(buttons)
			term.restore()
		end
		
		local pushThread = coroutine.create(pushCluster)
		
		modem.open(2)
		
		repeat
		
			local event = {os.pullEvent()}
			
			local x, y
			if event[1] == "key" then
				if event[2] == keys.x then break end

			elseif event[1] == "modem_message" then
print("modem message")
				local modemSide = event[2]
				local senderChannel = event[3]
				local replyChannel = event[4]
				local message = event[5]
				local senderDistance = event[6]
print(message)
				message = textutils.unserialize(message)
				if senderChannel == 2 then
					if message.action == clientAction.logon then
						print("Hello turtle "..message.data1)
						addToCluster(message.data1, turtleStates.on)
						modem.transmit(message.data1, 0, serverMessage(serverAction.logon, true))
						modem.open(message.data1)
					end
				else
				
					if message.action == clientAction.onoff then
						
						for id, _ in pairs(cluster) do
							if id == senderChannel then
								cluster[id] = toggleState(cluster[id], turtleStates.on)
								break
							end
						end
print("Sending switch onoff")
						modem.transmit(senderChannel, 0, serverMessage(serverAction.switchState, turtleStates.on))
						
					elseif message.action == clientAction.solo then
						
						
						
					elseif message.action == clientAction.allOn then
						
						
						
					elseif message.action == clientAction.setPivot then
						
						
						
					elseif message.action == clientAction.rotate then
						
						
						
						
					elseif message.action == clientAction.ready then
					
						clusterBusyCounter = clusterBusyCounter -1
						coroutine.resume(pushThread, modem)
						
					end
				
				end
			elseif event[1] == "redstone" then
			
				if rs.getInput(switchLoc) then
					
					remoteAction = (remoteAction +1) %7
					if remoteAction == 0 then remoteAction = 1 end
					
				elseif rs.getInput(activaLoc) then
					
					io.write("Sending "..getServerActionFromRemote(remoteAction).." to channels: ")
					for id, _ in pairs(cluster) do
						io.write(id..", ")
						local timeout = clusterSize
						table.insert(actionBuffer, serverMessage(getServerActionFromRemote(remoteAction), timeout))
					end
					print()
					remoteAction = 1
					
				end
				
			elseif event[1] == "monitor_touch" then
				print("monitor touch at "..event[3].."/"..event[4])
				local bIndex = gui.getButtonClickedIndex(buttons, event[3], event[4])
				if bIndex ~= nil then
					term.redirect(monitor)
					gui.drawClickedButton(buttons[bIndex])
					term.restore()
					local serverAction = buttonToServerActionMapping[bIndex]
					for channel, _ in pairs(cluster) do
						print("Sending '"..serverAction.."' to channel "..channel)
						local timeout = clusterSize
						table.insert(actionBuffer, serverMessage(serverAction, timeout))
					end
					
sleep(sleeptime)
					term.redirect(monitor)
					gui.drawUnclickedButton(buttons[bIndex])
					term.restore()
				end
				
			end
			
			if #actionBuffer > 0 then
			
				coroutine.resume(pushThread, modem)
			
			end
			
		
		until false
		
		
		
	elseif clientserver == "c" then
		
		print("To your service :)")
		print("Calling server...")
		local modem = peripheral.wrap("right")
		local channel = os.getComputerID()
		
		modem.open(channel)
		local connected = false
		
		-- login to the server
		while true do
	
			modem.transmit(2, 0, clientMessage(clientAction.logon, channel))
		
			local event = {os.pullEvent("modem_message")}
			
			if event[5] ~= nil then
				local message = textutils.unserialize(event[5])
				
				if message.data1 == true then
					print("Server accepted")
					connected = true
					break
				else
					print("Server declined")
					return
				end
			end
		end
		
		local printmess
		repeat
		
			printClientScreen(connected, printmess)
			printmess = ""
			local event = {os.pullEvent()}
			
			if event[1] == "key" then
			
				local key = event[2]
				
				if key == keys.one then
					modem.transmit(channel, 0, clientMessage(clientAction.onoff))
				elseif key == keys.two then
					modem.transmit(channel, 0, clientMessage(clientAction.solo))
				elseif key == keys.three then
					modem.transmit(channel, 0, clientMessage(clientAction.allOn))
				elseif key == keys.four then
					modem.transmit(channel, 0, clientMessage(clientAction.pivot))
				end
			
			elseif event[1] == "modem_message" then
printmess = printmess.."modem message "..event[5]
				local message = textutils.unserialize(event[5])
	
				local timeout = message.data1
				
				local isOn = hasState(turtleState, turtleStates.on)
				
				if false then
				
				elseif message.action == serverAction.switchState then
					
					if message.data1 == turtleStates.on then
						
						turtleState = toggleState(turtleState, turtleStates.on)
						
					end
				
				elseif isOn and message.action == serverAction.forward then
				
					while not turtle.forward() and timeout > 0 do
						sleep(sleeptime)
						timeout = timeout -sleeptime
					end
					
				elseif isOn and message.action == serverAction.back then
				
					while not turtle.back() and timeout > 0 do
						sleep(sleeptime)
						timeout = timeout -sleeptime
					end
					
				elseif isOn and message.action == serverAction.left then
				
					turtle.turnLeft()
					
				elseif isOn and message.action == serverAction.right then
				
					turtle.turnRight()
					
				elseif isOn and message.action == serverAction.up then
				
					while not turtle.up() and timeout > 0 do
						sleep(sleeptime)
						timeout = timeout -sleeptime
					end
					
				elseif isOn and message.action == serverAction.down then
				
					while not turtle.down() and timeout > 0 do
						sleep(sleeptime)
						timeout = timeout -sleeptime
					end
					
				end
				
printmess = printmess.."/nSending ready: "..clientMessage(clientAction.ready)
				modem.transmit(channel, 0, clientMessage(clientAction.ready))
			end
			
			
		until false
		
	end

end

-- 