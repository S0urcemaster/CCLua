-- floor

local length, width, orientation

getArgs = function()

  return {"length", "width", "Orientation"}
  
end

validateArgs = function(args)
	
  if tonumber(args.length) == nil then return "length must be a number" end
  if tonumber(args.width) == nil then return "width must be a number" end
  if args.orientation ~= "l" and args.strValue ~= "r" then
    return "orientation must be 'l' or 'r'" end
  
  length = tonumber(args.lenght)
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
	print("floor running")
--	tapi.vor()
--	
--	for x = 1, breite do
--	  for y = 1, lnge-1 do
--	    
--	    tapi.nextSlot()
--	    tapi.setzUnten()
--	    tapi.vor()
--	    
--	  end
--	  
--	  if x < breite then
--	    tapi.nextSlot()
--	    tapi.setzUnten()
--	    tapi.ausrichtenMitOrientierung(270)
--	    tapi.vor()
--	    if capi.zahlGerade(x) then
--	      tapi.ausrichten(0)
--	    else
--	      tapi.ausrichten(180)
--	    end
--	  end
--	  
--	end
--	
--	tapi.nextSlot()
--	tapi.setzUnten()
--	
--	
--	if capi.zahlUngerade(breite) then
--	  tapi.ausrichten(180)
--	  for y = 1, lnge-1 do
--	    
--	    tapi.vor()
--	    
--	  end
--	end
--	
--	tapi.ausrichtenMitOrientierung(90)
--	
--	for x = 1, breite-1 do
--	  
--	  tapi.vor()
--	  
--	end
--	
--	tapi.ausrichten(0)
--	tapi.zurck()

end