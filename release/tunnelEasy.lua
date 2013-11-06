-- tunnelEasy
-- grab tunnel 3 hoch 1 breit 50 lang
-- wXVk2dng

length = 50

for i = 1, length, 1 do
  
  if turtle.forward() == false then
    
    local counter = 0
    
    repeat
      turtle.dig()
      counter = counter + 1
    until turtle.forward() or counter == 10
    
    if counter == 10 then
      return
    end
    
  end
  
  turtle.digUp()
  turtle.digDown()
  
end