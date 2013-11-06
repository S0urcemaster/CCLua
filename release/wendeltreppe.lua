-- Wendeltreppe
-- Ecken bleiben ohne Stufen
-- bACqDJW3

write("Wendeltreppe - Turtle auf die Ecke setzen\n")
write("Setzt Stufen gegeneinander unten und oben\n")
write("Slots: 1-4 = Stufen, 5-16 = Wandblock\n")
write("Minimum Laenge, Breite: 3\n")

input = mapi.getInput({"Laenge: ", "Breite: ", "Hoehe: ", "Orientierung: ", "Nach oben/unten (o/u): ", "Innenwand (y/n): ", "Aussenwand (y/n): "})

laenge = tonumber(input[1])
breite = tonumber(input[2])
hoehe = tonumber(input[3])

tapi.setzOrientierung(input[4])
obenunten = input[5]
innen = input[6] == "y" and true or false
aussen = input[7] == "y" and true or false

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