-- wall

local tapi = turtleAPI

local args = {}

getInfo = function()
	
	local info = {}
--3456789012345678901234567890123456789
info[1] =
[[Build a wall moving backwards without
leaving the walls boundaries except for
the last block: the turtle will move
to the side that is not blocked or to
a random side.
Place turtle on place of the first wall
block heading forward.]]
	
	return info

end


getArgs = function()

  return {"length", "height"}
  
end


validateArgs = function(argse)
	
	args.height = tonumber(argse.height)
	args.length = tonumber(argse.length)
	
	return true
	
end


getFuel = function()
  
  return args.length *args.height +5
  
end


getSlots = function()
  
  local slots = {}
  
  local blocks = args.length *args.height
  
  local blocksi = math.floor(blocks /64)
  local blocksf = blocks %64
  
  for i = 1, blocksi do
  	table.insert(slots, {64, "And"})
  end
  if blocksf ~= 0 then
  	table.insert(slots, {blocksf, "Any"})
  end
  
  return slots
  
end


validateSlots = function()

	--return "builtInExact"
	return "builtInSum"
	-- return true/false (own calculation)

end


runApp = function()
	
	tapi.turnLeft()
	tapi.turnLeft()
	
	for h = 1, args.height do
		for l = 1, args.length -1 do
		
			tapi.back()
			tapi.nextSlot()
			tapi.place()
		
		end
		if h < args.height then
			tapi.up()
			tapi.nextSlot()
			tapi.placeDown()
			tapi.turnLeft()
			tapi.turnLeft()
		end
	end
	
	tapi.turnLeft()
	if not turtle.back() then
		tapi.turnRight()
		tapi.turnRight()
		turtle.back()
	end
	tapi.nextSlot()
	tapi.place()

end

--