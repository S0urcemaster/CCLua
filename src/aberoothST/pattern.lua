-- pattern
-- For now draws a checkboard of empty or filled squares

getInfo = function()
	
	local info = {}
--3456789012345678901234567890123456789
info[1] =
[[Draws a checkboard of outlined or
filled squares.
slength/swidth = length/width of each
sqare.
replength/repwidth = repetitions in
length and width.
outfill = outlined or filled]]

info[2] =
[[To the point that even a total noob
can understand it.]]
	
	return info

end


getArgs = function()

  return {"slength", "swidth", "replength", "repwidth", "outfill"}
  
end


validateArgs = function(args)
	
	if args.arg1 ~= "what it should be" then return "error message" end
	
	if args.arg2 == "you're stupid" then return "I'm not stupid" end
	
	return true
	
end


getFuel = function()
  
  return #"of movements"
  
end


getSlots = function()
  
  local slots = {}
  
  table.insert(slots, {64, "Stone"})
  table.insert(slots, {56, "Wood"})
  table.insert(slots, {32, "Sand"})
  
  return slots
  
end


getDetailedSlots = function()

	local slots = {}
	
	table.insert(slots, {"123456", "123456789", "123456789"})
	table.insert(slots, {"123456", "123456789", "123456789"})
	table.insert(slots, {"123456", "123456789", "123456789"})
	table.insert(slots, {"12345", "12345678", "12345678"})
	
	return slots

end


validateSlots = function()

	return "builtInExact"
	--return "builtInSum"
	-- return true/false (own calculation)

end


runApp = function()

	

end