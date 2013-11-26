-- floor
local tapi = turtleAPI
local capi = commonAPI
assert(tapi~=nil)
local length, width, orientation

getArgs = function()

  return {"length", "width", "orientation"}
  
end

validateArgs = function(args)
	
  if tonumber(args.length) == nil then return "length must be a number" end
  if tonumber(args.width) == nil then return "width must be a number" end
  if args.orientation ~= "l" and args.orientation ~= "r" then
    return "orientation must be 'l' or 'r'" end
  
  length = tonumber(args.length)
  width = tonumber(args.width)
  orientation = args.orientation
	return true
end

getFuel = function()
  
  return length * width
  
end

getSlots = function()
  
  local blocks = length * width
  local blocksi = math.floor(blocks/64)
  local blocksf = blocks % 64
  
  local slots = {}
  
  for i = 1, blocksi do
  	table.insert(slots, {64, "Any"})
  end
  table.insert(slots, {blocksf, "Any"})
  return slots
  
end

validateSlots = function()

	--return "builtInExact"
	return "builtInSum"
	-- return true/false (own calculation)

end

runApp = function()
	--print("floor running")
	tapi.forward()
	
	for x = 1, width do
	  for y = 1, length-1 do
	    
	    tapi.nextSlot()
	    tapi.placeDown()
	    tapi.forward()
	    
	  end
	  
	  if x < width then
	    tapi.nextSlot()
	    tapi.placeDown()
	    tapi.faceWithOrientation(270)
	    tapi.forward()
	    if capi.isEven(x) then
	      tapi.justify(0)
	    else
	      tapi.justify(180)
	    end
	  end
	  
	end
	
	tapi.nextSlot()
	tapi.placeDown()
	
	
	if capi.isOdd(breite) then
	  tapi.justify(180)
	  for y = 1, length-1 do
	    
	    tapi.forward()
	    
	  end
	end
	
	tapi.faceWithOrientation(90)
	
	for x = 1, width-1 do
	  
	  tapi.forward()
	  
	end
	
	tapi.justify(0)
	tapi.back()

end