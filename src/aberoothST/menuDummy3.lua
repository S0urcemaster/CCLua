
local value1, value2

getArgs = function()

  return {"intValue", "strValue"}
  
end

validateArgs = function(args)
	
  if tonumber(args.intValue) == nil then return "intValue must be a number" end
  if args.strValue ~= "left" or value2 ~= "right" then
    return "strValue must be 'left' or 'right'" end
  
  value1 = tonumber(value1)
  value2 = value2
	return "ok"
end

getFuel = function()
  
  return value1 * 5
  
end

getSlots = function()
  
  slots = {}
  table.insert(slots, {64, "Iron"})
  table.insert(slots, {56, "Iron"})
  table.insert(slots, {32, "Stone"})
  return slots
  
end

validateSlots = function()

	return "builtInExact"
	--return "builtInSum"
	-- return true/false (own calculation)

end

runApp = function()



end