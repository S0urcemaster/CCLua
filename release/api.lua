local maxmoblife = 20
local dmgpickaxe = 3
local maxAttackCount = math.ceil(maxmoblife/dmgpickaxe) + 1 -- just to be safe

local maxFloatingBlockCount = 15

local orientierung = true -- ist nderbar mit setzRichtung("l" oder "r")

local coords = {x=1, y=1, z=1, v=1}
-- lokales Koordinatensystem der Turtle
-- v ist blickrichtung 0:Nord/+y, 270:West/+x, 180:Sd/-y, 90:Ost/-x
coords.y = 0 -- Annahme: turtle steht am Anfang 1 auerhalb des Bereichs

function getCoords()

	return coords

end

-- Stellt sicher, dass turtle.forward() tatschlich ausgefhrt wird
function vor()
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
	-- erhhe richtige Koordinate um +/- 1
	coords.x = coords.v == 0 and 1 or coords.v == 180 and -1 or coords.v == 0 and 0
	coords.y = coords.v == 270 and 1 or coords.v == 90 and -1 or coords.v == 0 and 0

end


-- Stellt sicher, dass turtle.up() tatschlich ausgefhrt wird
function hoch()
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
function runter()
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
function zurck()
	if not turtle.back() then
		local counter = 0
		turtle.turnLeft()
		turtle.turnLeft()
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
					turtle.turnLeft()
					turtle.turnLeft()
					error("Cannot move back")
				end
			end
		end
	end
	coords.x = coords.v == 0 and 1 or coords.v == 180 and -1 or coords.v == 0 and 0
	coords.y = coords.v == 270 and 1 or coords.v == 90 and -1 or coords.v == 0 and 0
end

function setzOrientierung(lr)

	orientierung = lr

end

-- Drehung ohne Bercksichtigung der Orientierung
local function dreheLinks()

		turtle.turnLeft()
		coords.v = (coords.v - 90) % 360

end

local function dreheRechts()

		turtle.turnRight()
		coords.v = (coords.v + 90) % 360
		
end

-- Drehung unter Bercksichtigung der Orientierung
function links()

	if orientierung == "l" then
		dreheLinks()
	else
		dreheRechts()
	end
	
end

function rechts()

	if orientierung == "l" then
		dreheRechts()
	else
		dreheLinks()
	end

end


-- Stellt sicher, dass turtle.place() den Block gesetzt hat
function setz()
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
function setzOben()
	if not turtle.placeUp() then
		local counter = 0
		
		repeat
			turtle.digUp()
			counter = counter + 1
			if counter == maxFloatingBlockCount then break end
		until turtle.placeUp()
		
		if counter == maxFloatingBlockCount then
			counter = 0
			while not turtle.placeUp() do
				turtle.attackUp()
				counter = counter + 1
				if counter == maxAttackCount then error("Could not place block upside") end
			end
		end
	end
end


-- Stellt sicher, dass turtle.placeDown() den Block gesetzt hat
function setzUnten()
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