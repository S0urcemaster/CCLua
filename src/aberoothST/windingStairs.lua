-- windingStairs

local length, width, height, orientation, upDown, innerWall, outerWall

getArgs = function()

	return {"length", "width", "height", "orientation", 
		"upDown", "innerWall", "outerWall"}

end

validateArgs = function(args)

  if tonumber(args.length) == nil then return "length must be a number" end
  if tonumber(args.width) == nil then return "width must be a number" end
  if tonumber(args.height) == nil then return "width must be a number" end
  if args.orientation ~= "l" and args.orientation ~= "r" then
    return "orientation must be 'l' or 'r'" end
  if args.upDown ~= "u" and args.upDown ~= "d" then
    return "upDown must be 'u' or 'd'" end
  if args.innerWall ~= "y" and args.innerWall ~= "n" then
    return "innerWall must be 'y' or 'n'" end
  if args.outerWall ~= "y" and args.outerWall ~= "n" then
    return "outerWall must be 'y' or 'n'" end
	
	length = args.length
	width = args.width
	height = args.height
	orientation = args.orientation
	upDown = args.upDown
	innerWall = args.innerWall
	outerWall = args.outerWall
	
end

getFuel = function()

	return length * width * height * 2 -- estimation

end

getSlots = function()

	local stairs = height
	local inner = innerWall == "y" and 1 or 0
	local outer = outerWall == "y" and 1 or 0
	-- lol estimation, takes too much time
	local blocks = (height / 4) * (inner * ((width - 2) + (length - 2)) + outer * ((width - 2) + (length - 2)))
	
	-- rounding up
	local slots = {}
	local stairsi = math.ceil(stairs/64)
	local blocksi = math.ceil(blocks/64)
	
	for i = 1, stairsi do
		table.insert({64, "Stairs"})
	end
	for i = 1, blocksi do
		table.insert({64, "Wall"})
	end
	
end

validateSlots = function()

	--return "builtInExact"
	return "builtInSum"
	-- return true/false (own calculation)

end

runApp = function()

	laenge = length
	breite = width
	hoehe = height
	
	tapi.setzOrientierung(orientation)
	obenunten = upDown
	innen = innerWall == "y" and true or false
	aussen = outerWall == "y" and true or false
	
	function setzInnen()
	  
	  if innen then
	    tapi.links()
	    tapi.nextSlot(5)
	    tapi.setz()
	    tapi.rechts()
	  end
	  
	end
	
	function setzAussen()
	  
	  if aussen then
	    tapi.rechts()
	    tapi.nextSlot(5)
	    tapi.setz()
	    tapi.links()
	  end
	  
	end
	
	function hoch()
	  while tapi.getCoords().z < hoehe do
	    
	    coords = tapi.getCoords()
	    length = 0
	    if coords.v == 0 or coords.v == 180 then
	      length = laenge
	    else
	      length = breite
	    end
	    
	    setzAussen()
	    
	    tapi.vor()
	    
	    for i = 1, length - 2 do
	      
	      setzInnen()
	      
	      setzAussen()
	      
	      
	      if coords.z == 2 then
	        tapi.nextSlot(5)
	        tapi.setzUnten()
	      elseif not turtle.detectDown() then
	        tapi.nextSlot(1)
	        tapi.umdrehen()
	        tapi.setzUnten()
	        tapi.umdrehen()
	      end
	      
	      tapi.nextSlot(1)      
	      tapi.hoch()
	      tapi.setzUnten()
	      
	      setzInnen()
	      setzAussen()
	      
	      tapi.vor()
	      
	    end
	    
	    tapi.nextSlot(5)
	    tapi.setzUnten()
	    setzAussen()
	    tapi.links()
	    
	  end
	
	end
	
	function runter()
	  
	  
	  
	end
	
	if obenunten == "o" then
	  hoch()
	else
	  runter()
	end

end

--