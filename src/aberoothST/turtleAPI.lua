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


-- Drehung ohne Beruecksichtigung der Orientation
dreheLinks = function()

		turtle.turnLeft()
		coords.v = (coords.v - 90) % 360

end

dreheRechts = function()

		turtle.turnRight()
		coords.v = (coords.v + 90) % 360
		
end

umdrehen = function()
	dreheLinks()
	dreheLinks()
end

-- Stellt sicher, dass turtle.forward() tatschlich ausgefhrt wird
vor = function()
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
					-- alle Berechnungen kann man jetzt wegwerfen :(
					error("Cannot move forward")
				end
			end
		end
	end
	-- erhoehe richtige Koordinate um +/- 1
	local d = coords.v == 0 and 1 or coords.v == 180 and -1 or 0
	coords.y = coords.y + d
	d = coords.v == 270 and 1 or coords.v == 90 and -1 or 0
	coords.x = coords.x + d

end


-- Stellt sicher, dass turtle.up() tatschlich ausgefhrt wird
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

-- Stellt sicher, dass turtle.down() tatschlich ausgefhrt wird
runter = function()
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

-- Stellt sicher, dass turtle.back() tatschlich ausgefhrt wird
zurck = function()
	if not turtle.back() then
		local counter = 0
		dreheLinks()
		dreheLinks()
		-- im Prinzip dasselbe wie bei vor(), auer der Fehlermeldung
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
					dreheLinks()
					dreheLinks()
					error("Cannot move back")
				end
			end
		end
		dreheRechts()
		dreheRechts()
	end
	local d = coords.v == 0 and 1 or coords.v == 180 and -1 or 0
	coords.y = coords.y - d
	d = coords.v == 270 and 1 or coords.v == 90 and -1 or 0
	coords.x = coords.x - d
end

-- stellt sicher, dass oben kein Block mehr ist
grabOben = function()

	while turtle.detectUp() do
    turtle.digUp()
    os.sleep(0.2)
  end

end

grabUnten = function()

	turtle.digDown()

end

setOrientation = function(lr)

	orientation = lr

end

-- dient dazu bei mehreren ebenen dieselbe schleife von der anderen seite verwenden
-- zu knnen ohne umzurechnen
flipOrientation = function()
	if orientation == "r" then orientation = "l"
	else orientation = "r" end
end


-- Drehung unter Bercksichtigung der Orientation
links = function()

	if orientation == "l" then
		dreheLinks()
	else
		dreheRechts()
	end
	
end

rechts = function()

	if orientation == "l" then
		dreheRechts()
	else
		dreheLinks()
	end

end

-- dreh dich in richtung 0/90/180/270
ausrichten = function(richtung)
	local drehung = capi.drehung(coords.v, richtung)
	if drehung > 0 then	dreheRechts()
		if drehung > 90 then dreheRechts()
		end
	elseif drehung < 0 then dreheLinks()
		if drehung < -90 then dreheLinks()
		end
	end
end

faceWithOrientation = function(richtung)

	if orientation == "r" then
		if richtung == 90 then richtung = 270
		elseif richtung == 270 then richtung = 90 end
	end
	ausrichten(richtung)

end

getAusrichtung = function()
	return coords.v
end


-- Stellt sicher, dass turtle.place() den Block gesetzt hat
setz = function(slot)
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


-- Stellt sicher, dass turtle.placeUp() den Block gesetzt hat
setzOben = function(slot)
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


-- Stellt sicher, dass turtle.placeDown() den Block gesetzt hat
setzUnten = function(slot)
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

-- wähle slot n
-- wenn dieser leer ist, nimm den nächsten
-- wenn n nicht angegeben ist, fang bei 1 an
nextSlot = function(n)

	if n == nil then n = 1 end
	
	for i = n, 16 do
		if turtle.getItemCount(i) ~= 0 then
			turtle.select(i)
			return
		end
	end
end

-- wählt den slot aus und gibt true zurück wenn items vorhanden sind
-- sonst false
selectSlotNotEmpty = function(n)

	turtle.select(n)
	if turtle.getItemCount(n) == 0 then return false end
	return true

end

gehezu = function(x, y, z, fForward, fUp, fDown)
  z = z or 1
  fForward = fForward or vor
  fUp = fUp or hoch
  fDown = fDown or runter
  
	local nach = vector.new(x, y, z)
	local coords = tapi.getCoords()
	local von = vector.new(coords.x, coords.y, coords.z)
	delta = nach - von
--print("Coords: "..coords.x.." "..coords.y.." "..coords.z.."  Delta: "..delta.x.." "..delta.y.." "..delta.z)
	if delta.y ~= 0 then
		if capi.sign(delta.y) == 1 then
			ausrichten(0)
		else
			ausrichten(180)
		end
		for b = capi.sign(delta.y), delta.y, capi.sign(delta.y) do
			fForward()
		end
	end
	if delta.x ~= 0 then
		if capi.sign(delta.x) == 1 then
			ausrichten(270)
		else
			ausrichten(90)
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
        ausrichten(270)
      else
        ausrichten(90)
      end
      
      if turtle.forward() then
        moved = true
        coords.x = coords.x + capi.sign(delta.x)
        delta.x = delta.x - capi.sign(delta.x)
      end
      
    end
    if not moved and delta.y ~= 0 then
      
      if capi.sign(delta.y) == 1 then
        ausrichten(0)
      else
        ausrichten(180)
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

