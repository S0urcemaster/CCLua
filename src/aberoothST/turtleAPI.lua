-- Turtle API
-- Functions for controlling turtles.

local capi = commonAPI

local maxmoblife = 20
local dmgpickaxe = 3
local maxAttackCount = math.ceil(maxmoblife/dmgpickaxe) + 1 -- just to be safe

local maxFloatingBlockCount = 15

local orientation = "l" -- "l" left / "r" right

makeBlankCoords = function()

	return {x = 0, z = 0, y = 0, v = 0}

end

coords = makeBlankCoords()

mccoords = {south = 0, west = 1, north = 2, east = 3,
						[0] = "south", [1] = "west", [2] = "north", [3] = "east",
						eastsign = 1, westsign = -1, southsign = 1, northsign = -1}
--     -
--   - o +
--     +
						
dir2deg = {north = 0, east = 90, south = 180, west = 270}

deg2sign = {[dir2deg.north] = mccoords.northsign, 
							[dir2deg.east] = mccoords.eastsign,
							[dir2deg.south] = mccoords.southsign,
							[dir2deg.west] = mccoords.westsign}
deg2axis = {[dir2deg.north] = "z",
							[dir2deg.south] = "z",
							[dir2deg.east] = "x",
							[dir2deg.west] = "x"}

-- simple turtle.turnLeft storing the angle in coords.v
turnLeft = function()

		turtle.turnLeft()
		coords.v = (coords.v - 90) % 360

end

-- simple turtle.turnRight storing the angle in coords.v
turnRight = function()

		turtle.turnRight()
		coords.v = (coords.v + 90) % 360
		
end

-- turtle.forward() using dig and attack to clear the way.
-- If that doesn't help, fuel is also being checkd.
forward = function()
	if not turtle.forward() then
		local counter = 0
		
		repeat
			turtle.dig()
			counter = counter + 1
			if counter == maxFloatingBlockCount then break end
		until turtle.forward()
		
		if counter == maxFloatingBlockCount then
			counter = 0
			while not turtle.forward() do
				turtle.attack()
				counter = counter + 1
				if counter == maxAttackCount then
					if turtle.getFuelLevel() == 0 then
						print("No fuel.")
						print("Put fuel in active slot and press key")
						capi.pullKey()
						turtle.refuel()
					else
						error("Cannot move forward")
					end
				end
			end
		end
	end
print("x:"..coords.x.." z:"..coords.z.." v:"..coords.v.." ->forward")
	local axis = deg2axis[coords.v]
	coords[axis] = coords[axis] + deg2sign[coords.v]
print("-> x:"..coords.x.." z:"..coords.z.." v:"..coords.v)
end


-- turtle.back() using dig and attack to clear the way
-- If that doesn't help, fuel is also being checkd.
back = function()
	if not turtle.back() then
		local counter = 0
		turnLeft()
		turnLeft()
		repeat
			turtle.dig()
			counter = counter + 1
			if counter == maxFloatingBlockCount then break end
		until turtle.forward()
		
		if counter == maxFloatingBlockCount then
			counter = 0
			while not turtle.forward() do
				turtle.attack()
				counter = counter + 1
				if counter == maxAttackCount then
					if turtle.getFuelLevel() == 0 then
						print("No fuel.")
						print("Put fuel in active slot and press key")
						capi.pullKey()
						turtle.refuel()
					else
						error("Cannot move backward")
					end
				end
			end
		end
		turnRight()
		turnRight()
	end
	
	local axis = deg2axis[coords.v]
	coords[axis] = coords[axis] - deg2sign[coords.v]

end


-- turtle.up() using dig and attack to clear the way
up = function()
	if not turtle.up() then
		local counter = 0
		
		repeat
			turtle.digUp()
			counter = counter + 1
			if counter == maxFloatingBlockCount then break end
		until turtle.up()
		
		if counter == maxFloatingBlockCount then
			counter = 0
			while not turtle.up() do
				turtle.attackUp()
				counter = counter + 1
				if counter == maxAttackCount then
					if turtle.getFuelLevel() == 0 then
						print("No fuel.")
						print("Put fuel in active slot and press key")
						capi.pullKey()
						turtle.refuel()
					else
						error("Cannot move up")
					end
				end
			end
		end
	end
	coords.z = coords.z + 1
end

-- turtle.down() using dig and attack to clear the way
down = function()
	if not turtle.down() then
		local counter = 0
		
		repeat
			turtle.digDown()
			counter = counter + 1
			if counter == maxFloatingBlockCount then break end
		until turtle.down()
		
		if counter == maxFloatingBlockCount then
			counter = 0
			while not turtle.down() do
				turtle.attackDown()
				counter = counter + 1
				if counter == maxAttackCount then
					if turtle.getFuelLevel() == 0 then
						print("No fuel.")
						print("Put fuel in active slot and press key")
						capi.pullKey()
						turtle.refuel()
					else
						error("Cannot move down")
					end
				end
			end
		end
	end
	coords.z = coords.z - 1
end

-- turtle.digUp() clearing floating blocks
digUp = function()

	while turtle.detectUp() do
    turtle.digUp()
    os.sleep(0.2)
  end

end

-- Nothing to worry about turtle.digDown()
digDown = function()

	turtle.digDown()

end

-- Enforces turtle.place()
place = function(slot)
  slot = slot or 1
	if not turtle.place() then
		local counter = 0
		
		repeat
			turtle.dig()
			counter = counter + 1
			if counter == maxFloatingBlockCount then break end
		until turtle.place()
		
		if counter == maxFloatingBlockCount then
			counter = 0
			while not turtle.place() do
				turtle.attack()
				counter = counter + 1
				if counter == maxAttackCount then error("Could not place block in front") end
			end
		end
	end
end


-- Enforces turtle.placeUp()
placeUp = function(slot)
  slot = slot or 1
	if not turtle.placeUp() then
		local counter = 0
		nextSlot(slot)
		repeat
			turtle.digUp()
			counter = counter + 1
			if counter == maxFloatingBlockCount then break end
		until turtle.placeUp()
		
		if counter == maxFloatingBlockCount then
			counter = 0
			while not turtle.placeUp() do
        nextSlot(slot)
				turtle.attackUp()
				counter = counter + 1
				if counter == maxAttackCount then error("Could not place block upside") end
			end
		end
	end
end


-- Enforces turtle.placeDown()
placeDown = function(slot)
  slot = slot or 1
	if not turtle.placeDown() then
		local counter = 0
		
		repeat
			turtle.digDown()
			counter = counter + 1
			if counter == maxFloatingBlockCount then break end
		until turtle.placeDown()
		
		if counter == maxFloatingBlockCount then
			counter = 0
			while not turtle.placeDown() do
				turtle.attackDown()
				counter = counter + 1
				if counter == maxAttackCount then error("Could not place block") end
			end
		end
	end
end

-- Select next slot not empty
nextSlot = function(n)

	if n == nil then n = 1 end
	
	for i = n, 16 do
		if turtle.getItemCount(i) ~= 0 then
			turtle.select(i)
			return
		end
	end
end


-- sets the orientation on which left() and right() operate on
setOrientation = function(lr)

	orientation = lr

end

-- l->r, r->l
flipOrientation = function()
	orientation = orientation == r and "l" or "r"
end


-- turnLeft() taking orientation into account
leftO = function()

	_ = orientation == "l" and turnLeft() or turnRight()
	
end

-- turnRight() taking orientation into account
rightO = function()

	_ = orientation == "l" and turnRight() or turnLeft()

end

-- turn to direction, 0/90/180/270 degrees
justify = function(dir)
	local rot = rotation(coords.v, dir)
	if rot > 0 then	turnRight()
		if rot > 90 then turnRight()
		end
	elseif rot < 0 then turnLeft()
		if rot < -90 then turnLeft()
		end
	end
end

-- used with 180 degrees turn in relative x direction
faceWithOrientation = function(dir)

	if orientation == "r" then
		if dir == 90 then dir = 270
		elseif dir == 270 then dir = 90 end
	end
	justify(dir)

end


--calculates the closest rotation angle from -90deg to +180deg
rotation = function(start, ziel)
	
  if start == ziel then return 0 end
  
  if start == 0 then start = 360 end
  if ziel == 0 then ziel = 360 end
  
  diff = ziel - start
  
  if math.abs(diff) == 180 then return 180 end
  
  if math.abs(diff) == 270 then return -diff/3 end
  
  return diff

end


-- move to x,y,z with the turtle bottom block as origin (0,0,0)
-- fForward, fUp, fDown are the functions to use when moving
-- if nil, tapi.forward()/ up()/ down() are used
-- z can be left out when only moving on x/z
moveTo = function(x, z, y, fForward, fUp, fDown)
  y = y or 0
  fForward = fForward or forward
  fUp = fUp or up
  fDown = fDown or down
--print(x.." "..z.." "..y)
	local vTo = vector.new(x, z, y)
	local vFrom = vector.new(coords.x, coords.z, coords.y)
--print(vTo)
--print(vFrom)
	local vSub = vTo - vFrom
	local vDelta = vector.new(vSub.x, vSub.z, vSub.y)
--print("Coords: "..coords.x.." "..coords.z.." "..coords.y.."  Delta: "..vDelta.x.." "..vDelta.z.." "..vDelta.y)
	if vDelta.z ~= 0 then
		if capi.sign(vDelta.z) == 1 then
			justify(180)
		else
			justify(0)
		end
		for b = capi.sign(vDelta.z), vDelta.z, capi.sign(vDelta.z) do
			fForward()
		end
	end
	if vDelta.x ~= 0 then
		if capi.sign(vDelta.x) == 1 then
			justify(90)
		else
			justify(270)
		end
		for a = capi.sign(vDelta.x), vDelta.x, capi.sign(vDelta.x) do
			fForward()
		end
	end
	
	if vDelta.y ~= 0 then
		for c = capi.sign(vDelta.y), vDelta.y, capi.sign(vDelta.y) do
			if vDelta.y > 0 then
				fUp()
			else
				fDown()
			end
		end
	end
end

-- moveTo without damaging anything and simple way finder
-- will no more work. out of focus.
softMoveTo = function(x, y, z)
  z = z or 1
  
	local vTo = vector.new(x, y, z)
	local vFrom = vector.new(coords.x, coords.y, coords.z)
	local vDelta = vTo - vFrom
--print("Coords: "..coords.x.." "..coords.y.." "..coords.z.."  Delta: "..delta.x.." "..delta.y.." "..delta.z)

  
  while vDelta.x ~= 0 or vDelta.y ~= 0 or vDelta.z ~= 0 do
    
    local moved = false
    
    if vDelta.x ~= 0 then
      
      if capi.sign(vDelta.x) == 1 then
        justify(270)
      else
        justify(90)
      end
      
      if turtle.forward() then
        moved = true
        coords.x = coords.x + capi.sign(vDelta.x)
        vDelta.x = vDelta.x - capi.sign(vDelta.x)
      end
      
    end
    if not moved and vDelta.y ~= 0 then
      
      if capi.sign(vDelta.y) == 1 then
        justify(0)
      else
        justify(180)
      end
      
      if turtle.forward() then
        moved = true
        coords.y = coords.y + capi.sign(vDelta.y)
        vDelta.y = vDelta.y - capi.sign(vDelta.y)
      end
      
    end
    if not moved and vDelta.z ~= 0 then
      
      if vDelta.z > 0 then
        if turtle.up() then
          moved = true
          coords.z = coords.z + capi.sign(vDelta.z)
          vDelta.z = vDelta.z - capi.sign(vDelta.z)
        end
      else
        if turtle.down() then
          moved = true
          coords.z = coords.z + capi.sign(vDelta.z)
          vDelta.z = vDelta.z - capi.sign(vDelta.z)
        end
      end
    end
    
    if not moved then
      error("Cannot reach destination")
    end
    
  end

end

