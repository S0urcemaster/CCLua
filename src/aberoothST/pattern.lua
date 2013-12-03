-- pattern
-- For now draws a checkboard of empty or filled squares

local capi = commonAPI
local tapi = turtleAPI

getInfo = function()
	
	local info = {}
--3456789012345678901234567890123456789
info[1] =
[[Draws a checkboard of outlined or
filled squares.
slength/swidth = length/width of each
sqare.
replength/repwidth = distance from one
squares start corner to the next
lCount/wCount = repetitions in
length and width.
outfill = outlined or filled
orientation = bild left hand or right]]

info[2] =
[[The turtle will start moving up one
block and place blocks at the level it
was placed.]]
	
	return info

end


local sLength, sWidth, repLength, repWidth, lCount, wCount, outfill, orientation

local blocks, stacks, remain

getArgs = function()

  return {"sLength", "sWidth", "repLength", "repWidth", "lCount", "wCount", "out_fill", "orientation"}
  
end


validateArgs = function(args)
	
	if args.out_fill ~= "o" and args.out_fill ~= "f" then
		return "out_fill must be 'o' or 'f'"
	elseif args.orientation ~= "r" and args.orientation ~= "l" then
		return "orientation must be 'r' or 'l'"
	end
	
	sLength = args.sLength
	sWidth = args.sWidth
	repLength = args.repLength
	repWidth = args.repWidth
	lCount = args.lCount
	wCount = args.wCount
	outfill = args.out_fill
	tapi.setOrientation(args.orientation)
	
  local squareBlocks
  if outfill == "f" then
  	squareBlocks = sLength * sWidth
  else
  	squareBlocks = 2 *(sLength -1) + 2 *(sWidth -1)
  end
  
  blocks = squareBlocks *lCount *wCount
  stacks = math.floor(blocks /64)
  remain = blocks % 64
  	
	return true
	
end


getFuel = function()
  
  local fuel = blocks
  
  -- just round about  
  fuel = fuel + sLength * lCount + sWidth *wCount
  
  return fuel
  
end


getSlots = function()
  
  local slots = {}
  
  for i = 1, stacks do
  	table.insert(slots, {64, "Any"})
  end
  table.insert(slots, {remain, "Any"})
  return slots
  
end


validateSlots = function()

	--return "builtInExact"
	return "builtInSum"
	-- return true/false (own calculation)

end


runApp = function()

	turtle.up()
	
	local xsign = tapi.orientation == "l" and -1 or 1
	
	for x = 0, xsign *wCount -xsign do
		for z = 0, lCount-1 do
			
			local x1 = x *repWidth *xsign
			local z1 = -z *repLength
			
			local x2 = x1 +xsign *sWidth -xsign
			local z2 = z1 -sLength +1
			local squarePoints
			
			if outfill == "o" then
				squarePoints = geom.square2dOutline(geom.make2dPoint(x1, z1), geom.make2dPoint(x2, z2))
			else
				squarePoints = geom.square2dFill(geom.make2dPoint(x1, z1), geom.make2dPoint(x2, z2))
			end
capi.cclogtable(capi.tableToString(squarePoints))
			for _, point in ipairs(squarePoints) do
				tapi.moveTo(point.x, point.z)
				tapi.nextSlot()
				tapi.placeDown()
			end
			
		end
	end
end

-- 