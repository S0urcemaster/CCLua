-- boden
-- 7nawh1wK

input = mapi.getInput({"Laenge: ", "Breite: ", "Orientierung: "})

lnge = tonumber(input[1])
breite = tonumber(input[2])
tapi.setzOrientierung(input[3])

stacks = (lnge*breite)/64

benzin = lnge * breite + lnge + breite

if turtle.getFuelLevel() < benzin then
	write("Nicht genug Treibstoff. Benoetigt: "..benzin)
	return
end

mapi.getInput({"Stacks benoetigt: "..stacks..". Weiter mit Enter"})

tapi.vor()

for x = 1, breite do
  for y = 1, lnge-1 do
    
    tapi.nextSlot()
    tapi.setzUnten()
    tapi.vor()
    
  end
  
  if x < breite then
    tapi.nextSlot()
    tapi.setzUnten()
    tapi.ausrichtenMitOrientierung(270)
    tapi.vor()
    if capi.zahlGerade(x) then
      tapi.ausrichten(0)
    else
      tapi.ausrichten(180)
    end
  end
  
end

tapi.nextSlot()
tapi.setzUnten()


if capi.zahlUngerade(breite) then
  tapi.ausrichten(180)
  for y = 1, lnge-1 do
    
    tapi.vor()
    
  end
end

tapi.ausrichtenMitOrientierung(90)

for x = 1, breite-1 do
  
  tapi.vor()
  
end

tapi.ausrichten(0)
tapi.zurck()