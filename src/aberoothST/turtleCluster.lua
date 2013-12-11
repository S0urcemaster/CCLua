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

local switchStateAction = {on = 1, off = 2, onoff = 3, solo = 4, pivot = 5}

local getServerActionFromRemote = function(remote)
	return serverAction[remoteActions[remote]]
end


local clientMessage = function(action, data1)
	return textutils.serialize({action = action, data1 = data1})
end

local clientAction = {logon = 1, onoff = 2, solo = 4, allOn = 5, setPivot = 6, rotate = 7, ready = 8}

local turtleStates = {on = 1, solo = 2, pivot = 4}

local turtleState = turtleStates.on


local stateToggle = function(state, flag)
	return bit.band(state, flag) == 0 and state +flag or state -flag
end


local stateFlagOn = function(state, flag)
	return bit.band(state, flag) == 0 and state +flag or state
end


local stateFlagOff = function(state, flag)
	return bit.band(state, flag) == 1 and state -flag or state
end


local hasState = function(state, flag)
	return bit.band(state, flag) == flag
end


local cluster = {}
local clusterSize = 0
local clusterBusyCounter = 0

local addToCluster = function(turtleId, state)
	state = state or turtleStates.on
	cluster[turtleId] = state
	clusterSize = clusterSize +1
end


local pushCluster = function(modem)

	while true do
		
		local a1 = actionBuffer[1]
		
		if a1 ~= nil then
capi.cclog("T: actions there: "..#actionBuffer)
			clusterBusyCounter = 0
			
			local anySolo = false
			for id, _ in pairs(cluster) do
				if hasState(cluster[id], turtleStates.solo) then
					anySolo = true
					modem.transmit(id, 0, serverMessage(a1.action, a1.data1))
					clusterBusyCounter = clusterBusyCounter +1
				end
			end
			
			if not anySolo then
			
				for id, _ in pairs(cluster) do
capi.cclog("T: sending to "..id.." : "..a1.action)
					if hasState(cluster[id], turtleStates.on) then
capi.cclog("T: turtle "..id.." ready to rumble")
						modem.transmit(id, 0, serverMessage(a1.action, a1.data1))
						clusterBusyCounter = clusterBusyCounter +1
					end
				end
			end
			
			local event, modemSide, senderChannel, replyChannel, message, senderDistance
capi.cclog("T: Waiting for response")
			while clusterBusyCounter > 0 do
capi.cclog("T: Still busy: "..clusterBusyCounter)
				coroutine.yield()
				clusterBusyCounter = clusterBusyCounter -1
			end
			table.remove(actionBuffer, 1)
capi.cclog("T: Action complete")
		else
capi.cclog("T: Nothing to do")
			coroutine.yield()
		end
	end

end


local sleeptime = 0.3

local sprint = function(text, x, y)

	term.setCursorPos(x, y)
	io.write(text)

end


local printServerScreen = function()

	term.clear()
	term.setCursorPos(1, 1)
	print("TurtleCluster Server "..os.getComputerID())
	print()
	print("Cluster ids:")
	for id, state in pairs(cluster) do
		io.write(id.."("..state.."), ")
	end
	print()
	print()
	print("1 Broadcast relog")
	print()


end


local printClientScreen = function(connected)

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
Only use turtles with id >2 since the
turtles are being assigned a channel
according to their id and channels
1 and 2 are used for broadcasting.
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
	capi.setLog(true)
capi.cclog("Stay alive logfile")
	if clientserver == "s" then
	
		print("Here Server :)")
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
			
			printServerScreen()
			
			local event = {os.pullEvent()}
			
			if event[1] == "key" then
				
				if event[2] == keys.one then
capi.cclog("S: broadcasting relog")
					modem.transmit(1, 0, serverMessage(serverAction.logon))
					cluster = {}
				end

			elseif event[1] == "modem_message" then
capi.cclog("S: modem message: "..event[5])
				local modemSide = event[2]
				local senderChannel = event[3]
				local replyChannel = event[4]
				local message = event[5]
				local senderDistance = event[6]
				message = textutils.unserialize(message)
				
				if senderChannel == 2 then
capi.cclog("S: client broadcast response "..message.data1)
					if message.action == clientAction.logon then
						addToCluster(message.data1, turtleStates.on)
						modem.open(message.data1)
					end
				else
				
					if message.action == clientAction.ready then
					
						coroutine.resume(pushThread, modem)
						
					elseif message.action == clientAction.onoff then
capi.cclog("S: client request on/off: "..senderChannel)
						for id, _ in pairs(cluster) do
							if id == senderChannel then
								cluster[id] = stateToggle(cluster[id], turtleStates.on)
								break
							end
						end
capi.cclog("S: sending on/off")
						modem.transmit(senderChannel, 0, serverMessage(serverAction.switchState, switchStateAction.onoff))
						
					elseif message.action == clientAction.solo then

						cluster[senderChannel] = stateToggle(cluster[senderChannel], turtleStates.solo)
						modem.transmit(senderChannel, 0, serverMessage(serverAction.switchState, switchStateAction.solo))
						
					elseif message.action == clientAction.allOn then
						
						for id, _ in pairs(cluster) do
						
							cluster[id] = stateFlagOn(cluster[id], turtleStates.on)
							modem.transmit(id, 0, serverMessage(serverAction.switchState, switchStateAction.on))
						
						end
						
					elseif message.action == clientAction.setPivot then
						
						for id, _ in pairs(cluster) do
						
							if id ~= senderChannel then
								cluster[id] = stateFlagOff(cluster[id], turtleStates.pivot)
								modem.transmit(id, 0, serverMessage(serverAction.switchState, switchStateAction.pivotOff))
							end
						
						end
						cluster[senderChannel] = stateFlagOn(cluster[senderChannel], turtleStates.pivot)
						modem.transmit(senderChannel, 0, serverMessage(serverAction.switchState, switchStateAction.pivotOn))
						
					elseif message.action == clientAction.rotate then
						

						
					end
				
				end
			elseif event[1] == "redstone" then
capi.cclog("S: redstone incoming")
				if rs.getInput(switchLoc) then
					remoteAction = (remoteAction +1) %7
					if remoteAction == 0 then remoteAction = 1 end
capi.cclog("S: switch action: "..remoteAction)
					
				elseif rs.getInput(activaLoc) then
					
capi.cclog("S: activator action: "..remoteAction)
					local timeout = clusterSize
					table.insert(actionBuffer, {action = getServerActionFromRemote(remoteAction), data1 = timeout})
					remoteAction = 1
					
				end
				
			elseif event[1] == "monitor_touch" then
capi.cclog("S: monitor touch"..event[3].."/"..event[4])
				local bIndex = gui.getButtonClickedIndex(buttons, event[3], event[4])
				if bIndex ~= nil then
					term.redirect(monitor)
					gui.drawClickedButton(buttons[bIndex])
					term.restore()
					local serverAction = buttonToServerActionMapping[bIndex]
capi.cclog("S: Queuing serverAction "..serverAction)
					local timeout = clusterSize
					table.insert(actionBuffer, {action = serverAction, data1 = timeout})
					
sleep(sleeptime)
					term.redirect(monitor)
					gui.drawUnclickedButton(buttons[bIndex])
					term.restore()
				end
				
			end
			
			if #actionBuffer > 0 then
capi.cclog("S: items in action buffer, resuming pushThread")
				coroutine.resume(pushThread, modem)
			
			end
			
		
		until false
		
		
		
	elseif clientserver == "c" then
		
		print("To your service :)")
		print("Waiting for server...")
		local modem = peripheral.wrap("right")
		local channel = os.getComputerID()
		
		modem.open(channel)
		modem.open(1) -- broadcast messages
		
		local connected = false
		
		
		repeat
			printClientScreen(connected)

			local event = {os.pullEvent()}
			
			if event[1] == "key" then
				local key = event[2]
				
				if key == keys.one then
capi.cclog("C: user requests on/off")
					modem.transmit(channel, 0, clientMessage(clientAction.onoff))
				elseif key == keys.two then
capi.cclog("C: user requests solo")
					modem.transmit(channel, 0, clientMessage(clientAction.solo))
				elseif key == keys.three then
capi.cclog("C: user requests allOn")
					modem.transmit(channel, 0, clientMessage(clientAction.allOn))
				elseif key == keys.four then
capi.cclog("C: user requests pivot")
					modem.transmit(channel, 0, clientMessage(clientAction.pivot))
				end
			
			elseif event[1] == "modem_message" then
capi.cclog("C: modem message "..event[5])
				local message = textutils.unserialize(event[5])
	
				local timeout = message.data1
				
				
				
				if false then
				
				elseif message.action == serverAction.logon then
capi.cclog("C: Returning id "..channel)
					modem.transmit(2, 0, clientMessage(clientAction.logon, channel))
					connected = true
				
				elseif message.action == serverAction.switchState then
capi.cclog("C: request switch on/off")
					if message.data1 == switchStateAction.onoff then
						
						turtleState = stateToggle(turtleState, turtleStates.on)
capi.cclog("C: turtleState now: "..turtleState)
					
					elseif message.data1 == switchStateAction.on then
						
						turtleState = stateFlagOn(turtleState, turtleStates.on)
												
					elseif message.data1 == switchStateAction.off then
					
						turtleState = stateFlagOff(turtleState, turtleStates.on)
											
					elseif message.data1 == switchStateAction.solo then
					
						turtleState = stateToggle(turtleState, turtleStates.solo)
					
					elseif message.data1 == switchStateAction.pivotOn then
					
						turtleState = stateFlagOn(turtleState, turtleStates.pivot)
					
					elseif messag.data1 == switchStateAction.pivotOff then
					
						turtleState = stateFlagOff(turtleState, turtleStates.pivot)
					
					end
				
				elseif message.action == serverAction.forward then
capi.cclog("C: receiving forward")
					while not turtle.forward() and timeout > 0 do
						sleep(sleeptime)
						timeout = timeout -sleeptime
					end
					
				elseif message.action == serverAction.back then
capi.cclog("C: receiving back")
					while not turtle.back() and timeout > 0 do
						sleep(sleeptime)
						timeout = timeout -sleeptime
					end
					
				elseif message.action == serverAction.left then
capi.cclog("C: receiving left")
					turtle.turnLeft()
					
				elseif message.action == serverAction.right then
capi.cclog("C: receiving right")
					turtle.turnRight()
					
				elseif message.action == serverAction.up then
capi.cclog("C: receiving up")
					while not turtle.up() and timeout > 0 do
						sleep(sleeptime)
						timeout = timeout -sleeptime
					end
					
				elseif message.action == serverAction.down then
capi.cclog("C: receiving down")
					while not turtle.down() and timeout > 0 do
						sleep(sleeptime)
						timeout = timeout -sleeptime
					end
					
				end
				
capi.cclog("C: Returning ready: "..clientMessage(clientAction.ready))
				modem.transmit(channel, 0, clientMessage(clientAction.ready))
			end
			
			
		until false
		
	end
	capi.setLog(false)
end

-- 