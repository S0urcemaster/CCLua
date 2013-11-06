-- Common API
-- Tx2FQVmi


function zahlGerade(n)
  return n % 2 == 0
end

function zahlUngerade(n)
	return n % 2 ~= 0
end

function istGanzzahlig(n)
  return n == math.floor(n)
end

-- Thx to "rv55"
function sign(x)
  return (x<0 and -1) or 1
end

--gibt einen drehwinkel von -90deg bis +180deg zurueck
function drehung(start, ziel)
	
  if start == ziel then return 0 end
  
  if start == 0 then start = 360 end
  if ziel == 0 then ziel = 360 end
  
  diff = ziel - start
  
  if math.abs(diff) == 180 then return 180 end
  
  if math.abs(diff) == 270 then return -diff/3 end
  
  
  return diff

end

