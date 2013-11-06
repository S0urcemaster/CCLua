-- vierwaende
-- DnNEqrn8

write("Vierwaende : Turtle auf die Ecke setzen")

input = mapi.getInput({"Laenge: ", "Breite: ", "Hoehe: ", "Orientierung (l/r): "})

lnge = tonumber(input[1])
breite = tonumber(input[2])
hhe = tonumber(input[3])
tapi.setzOrientierung(input[4])

stacks = ((lnge + breite) *2 *hhe) /64

benzin = (lnge + breite) *2 * hhe + lnge + breite + hhe

if turtle.getFuelLevel() < benzin then
	write("Nicht genug Treibstoff. Vorhanden: "..turtle.getFuelLevel()..", Benoetigt: "..benzin)
	return
end

mapi.getInput({"Stacks benoetigt: "..stacks..". Weiter mit Enter"})

tapi.umdrehen()


for z = 1, hhe do

	for n = 1, 4 do
		length = 0
		if n == 1 or n == 3 then length = lnge
		elseif n == 2 then length = breite
		else length = breite - 1
		end
		for y = 1, length-1 do

			tapi.zurck()
			tapi.nextSlot()		
			tapi.setz()
		
		end
		if n < 4 then tapi.links()
		elseif z < hhe then
			tapi.hoch()
			tapi.nextSlot()
			tapi.setzUnten()
			tapi.zurck()
			tapi.links()
		else
			tapi.rechts()
			tapi.zurck()
			tapi.nextSlot()
			tapi.setz()
			tapi.links()
			tapi.zurck()
			tapi.rechts()
		end
		
	end
	
end
