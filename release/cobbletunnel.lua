-- CobbleTunnel
-- 

write("CobbleTunnel\n")

input = mapi.getInput({"Laenge: ", "Rechte/Linke Turtle r/l: "})

length = tonumber(input[1])
lr = input[2]

bloecke = length * 5
stacksI = math.floor(bloecke / 64)
stacksF = bloecke % 64

mapi.getInput({"Stacks benoetigt: "..stacksI.."'"..stacksF..". Weiter mit Enter"})

benzin = length * 5

if turtle.getFuelLevel() < benzin then
	write("Nicht genug Treibstoff. Vorhanden: "..turtle.getFuelLevel()..", Benoetigt: "..benzin)
	return
end

for i = 1, length do
  
  tapi.vor()
  tapi.setzUnten()
  if lr == "l" then
    turtle.turnLeft()
  else
    turtle.turnRight()
  end
  tapi.setz()
  tapi.hoch()
  tapi.setz()
  tapi.hoch()
  tapi.setz()
  tapi.setzOben()
  for h = 1, 2 do tapi.runter() end
  if lr == "l" then
    turtle.turnRight()
  else
    turtle.turnLeft()
  end  
end