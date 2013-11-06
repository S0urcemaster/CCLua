-- Mauer
-- K1Y9grGT

write("Mauer - Turtle auf Anfangspunkt setzen\n")

input = mapi.getInput({"Start x: ", "Start y: ", "End x: ", "End y: ", "Hoehe: "})

x1 = tonumber(input[1])
y1 = tonumber(input[2])
x2 = tonumber(input[3])
y2 = tonumber(input[4])
hoehe = tonumber(input[5])

linie = geom.line({x = x1, y = y1}, {x = x2, y = y2})

bloecke = hoehe * #linie
stacksI = math.floor(bloecke / 64)
stacksF = bloecke % 64

mapi.getInput({"Stacks benoetigt: "..stacksI.."'"..stacksF..". Weiter mit Enter"})

currentBlock = {}

local function vor()
  
  while turtle.detect() do
    
    tapi.hoch()
    
  end
  
  tapi.vor()
  
  while not turtle.detectDown() do
    
    tapi.runter()
    
  end
  
end



for i = 1, #linie do
  
  tapi.gehezu(linie[i].x, linie[i].y, tapi.coords.z, vor)
  linie[i] = {x = linie[i].x, y = linie[i].y, z = tapi.coords.z}
  
end


for z = 1, hoehe do

  if capi.zahlGerade(z) then
    
    for i = 1, #linie do
      
      tapi.softMoveTo(linie[i].x, linie[i].y, z + linie[i].z)
      
      tapi.setzUnten()
      
    end
  
  else
    
    for i = #linie, 1, -1 do
      
      tapi.softMoveTo(linie[i].x, linie[i].y, z + linie[i].z)
      tapi.setzUnten()
      
    end
  
  end
  
  
end