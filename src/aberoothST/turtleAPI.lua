-- Turtle API

local maxmoblife = 20
local dmgpickaxe = 3
local maxAttackCount = math.ceil(maxmoblife/dmgpickaxe) + 1 -- just to be safe

local maxFloatingBlockCount = 15

local orientation = "l" -- "l" left / "r" right

local coords = {x=1, y=1, z=1, v=0}
-- lokales Koordinatensystem der Turtle
-- v ist blickrichtung 0:Nord/+y, 270:West/+x, 180:sued/-y, 90:Ost/-x
coords.y = 1 -- Annahme: turtle steht am Anfang 1 ausserhalb des Bereichs
-- xxx|
-- xxx|
-- --T--- y=0
--    |
--    |
--   x=0

getCoords = function()

	return coords

end


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

-- turtle.forward() using dig and attack to clear the way
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
					error("Cannot move forward")
				end
			end
		end
	end
	local d = coords.v == 0 and 1 or coords.v == 180 and -1 or 0
	coords.y = coords.y + d
	d = coords.v == 270 and 1 or coords.v == 90 and -1 or 0
	coords.x = coords.x + d

end


-- turtle.up() using dig and attack to clear the way
hoch = function()
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
				if counter == maxAttackCount then error("Cannot move up") end
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
				if counter == maxAttackCount then error("Cannot move down") end
			end
		end
	end
	coords.z = coords.z - 1
end

-- turtle.back() using dig and attack to clear the way
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
					turnLeft()
					turnLeft()
					error("Cannot move back")
				end
			end
		end
		turnRight()
		turnRight()
	end
	local d = coords.v == 0 and 1 or coords.v == 180 and -1 or 0
	coords.y = coords.y - d
	d = coords.v == 270 and 1 or coords.v == 90 and -1 or 0
	coords.x = coords.x - d
end

-- turtle.digUp() clearing floating blocks
digUp = function()

	while turtle.detectUp() do
    turtle.digUp()
    os.sleep(0.2)
  end

end

-- till now only wraps turtle.digDown()
digDown = function()

	turtle.digDown()

end

-- Enforces turtle.place()
place = function(slot)
  slot = slot or 1
  nextSlot(slot)
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
  nextSlot(slot)
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
  nextSlot(slot)
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

-- ??? function uncommon
selectSlotNotEmpty = function(n)

	turtle.select(n)
	if turtle.getItemCount(n) == 0 then return false end
	return true

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

-- turn to 0/90/180/270 degrees
justify = function(richtung)
	local drehung = rotation(coords.v, richtung)
	if drehung > 0 then	turnRight()
		if drehung > 90 then turnRight()
		end
	elseif drehung < 0 then turnLeft()
		if drehung < -90 then turnLeft()
		end
	end
end

-- ??? relic?
faceWithOrientation = function(richtung)

	if orientation == "r" then
		if richtung == 90 then richtung = 270
		elseif richtung == 270 then richtung = 90 end
	end
	justify(richtung)

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


-- move to x,y,z with the turtle placment block as origin (0,0,0)
-- fForward, fUp, fDown are the functions to use when moving
-- if nil, forward(), up(), down() are used
moveTo = function(x, y, z, fForward, fUp, fDown)
  z = z or 1
  fForward = fForward or forward
  fUp = fUp or up
  fDown = fDown or down
  
	local nach = vector.new(x, y, z)
	local von = vector.new(coords.x, coords.y, coords.z)
	delta = nach - von
--print("Coords: "..coords.x.." "..coords.y.." "..coords.z.."  Delta: "..delta.x.." "..delta.y.." "..delta.z)
	if delta.y ~= 0 then
		if capi.sign(delta.y) == 1 then
			justify(0)
		else
			justify(180)
		end
		for b = capi.sign(delta.y), delta.y, capi.sign(delta.y) do
			fForward()
		end
	end
	if delta.x ~= 0 then
		if capi.sign(delta.x) == 1 then
			justifj(270)
		else
			justify(90)
		end
		for a = capi.sign(delta.x), delta.x, capi.sign(delta.x) do
			fForward()
		end
	end
	
	if delta.z ~= 0 then
		for c = capi.sign(delta.z), delta.z, capi.sign(delta.z) do
			if delta.z > 0 then
				fUp()
			else
				fDown()
			end
		end
	end
end

-- moveTo without damaging anything and simple way finder
softMoveTo = function(x, y, z)
  z = z or 1
  
	local to = vector.new(x, y, z)
	local from = vector.new(coords.x, coords.y, coords.z)
	delta = to - from
print("Coords: "..coords.x.." "..coords.y.." "..coords.z.."  Delta: "..delta.x.." "..delta.y.." "..delta.z)

  
  while delta.x ~= 0 or delta.y ~= 0 or delta.z ~= 0 do
    
    moved = false
    
    if delta.x ~= 0 then
      
      if capi.sign(delta.x) == 1 then
        justify(270)
      else
        justify(90)
      end
      
      if turtle.forward() then
        moved = true
        coords.x = coords.x + capi.sign(delta.x)
        delta.x = delta.x - capi.sign(delta.x)
      end
      
    end
    if not moved and delta.y ~= 0 then
      
      if capi.sign(delta.y) == 1 then
        justify(0)
      else
        justify(180)
      end
      
      if turtle.forward() then
        moved = true
        coords.y = coords.y + capi.sign(delta.y)
        delta.y = delta.y - capi.sign(delta.y)
      end
      
    end
    if not moved and delta.z ~= 0 then
      
      if delta.z > 0 then
        if turtle.up() then
          moved = true
          coords.z = coords.z + capi.sign(delta.z)
          delta.z = delta.z - capi.sign(delta.z)
        end
      else
        if turtle.down() then
          moved = true
          coords.z = coords.z + capi.sign(delta.z)
          delta.z = delta.z - capi.sign(delta.z)
        end
      end
    end
    
    if not moved then
      error("Cannot reach destination")
    end
    
  end

end

