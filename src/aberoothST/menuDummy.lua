
local value1, value2

getArgs = function()

  return {"intValue", "strValue"}
  
end

validateArgs = function(args)
	
  if tonumber(args.intValue) == nil then return "intValue must be a number" end
  if args.strValue ~= "left" and args.strValue ~= "right" then
    return "strValue must be 'left' or 'right'" end
  
  value1 = tonumber(args.intValue)
  value2 = value2
	return true
end

getFuel = function()
  
  return value1 * 5
  
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
	table.insert(slots, {64, "123456", "123456789", "123456789"})

end

validateSlots = function()

	return "builtInExact"
	--return "builtInSum"
	-- return true/false (own calculation)

end

runApp = function()

	print("MenuDummy3 will do something now")
	
	print("MenuDummy3 is working")
	
	print("MenuDummy3 finished")

end