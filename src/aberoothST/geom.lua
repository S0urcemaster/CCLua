-- geom
-- functions produce tables of points in 2nd or 3rd Dimension

local capi = commonAPI


function make3dPoint(x, z, y)
  return {x = x, z = z, y = y}
end


make2dPoint = function(x, z)
	return {x = x, z = z}
end


-- get line points from starting p1 to p2
-- ftp://ftp.isc.org/pub/usenet/comp.sources.unix/volume26/line3d
-- So glad i found this. Even if it's simple :p
function line3dBres(p1, p2)

	local points = {}
	
	local x1 = p1.x
	local x2 = p2.x
	local z1 = p1.z
	local z2 = p2.z
	local y1 = p1.y
	local y2 = p2.y
	local xd, yd, zd
	local x, y, z
	local ax, ay, az
	local sx, sy, sz
	local dx, dy, dz
	
	dx = x2 - x1
	dy = y2 - y1
	dz = z2 - z1
	
	ax = math.abs(dx) *2
	ay = math.abs(dy) *2
	az = math.abs(dz) *2
	
	sx = capi.sign(dx)
	sy = capi.sign(dy)
	sz = capi.sign(dz)
	
	x = x1
	y = y1
	z = z1
	
	if ax >= capi.max(ay, az) then
	
		yd = ay - (ax/2)
		zd = az - (ax/2)
		
		while true do
		
			table.insert(points, make3dPoint(x, z, y))
			if x == x2 then return points end
			
			if yd >= 0 then
				y = y +sy
				yd = yd -ax
			end
			
			if zd >= 0 then
				z = z + sz
				zd = zd - ax
			end
			
			x = x +sx
			yd = yd +ay
			zd = zd +az
			
		end
		
	elseif ay >= capi.max(ax, az) then
	
		xd = ax - ay /2
		zd = az - ay /2
		
		while true do
		
			table.insert(points, make3dPoint(x, z, y))
			if y == y2 then return points end
			
			if xd >= 0 then
				x = x +sx
				xd = xd -ay
			end
			
			if zd >= 0 then
				z = z +sz
				zd = zd -ay
			end
			
			y = y +sy
			xd = xd + ax
			zd = zd + az
		
		end
	
	elseif az >= capi.max(ax, ay) then
	
		xd = ax - az /2
		yd = ay - az /2
		
		while true do
		
			table.insert(points, make3dPoint(x, z, y))
			if z == z2 then return points end
			
			if xd >= 0 then
				x = x +sx
				xd = xd - az
			end
			
			if yd >= 0 then
				y = y +sy
				yd = yd -az
			end
			
			z = z +sz
			xd = xd + ax
			yd = yd + ay
		
		end
	
	end

end


-- get line points from starting p1 to p2
-- http://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm#Simplification
line2dBres = function(p1, p2)

	local points = {}
	
	local x1 = p1.x
	local x2 = p2.x
	local z1 = p1.z
	local z2 = p2.z
	
	local dx = math.abs(x2 - x1)
	local dz = math.abs(z2 - z1)
	
	local sx, sz
	
	if x1 < x2 then sx = 1 else sx = -1 end
	if z1 < z2 then sz = 1 else sz = -1 end
	
	local err = dx -dz
	
	while true do
	
		table.insert(points, make2dPoint(x1, z1))
		
		if x1 == x2 and z1 == z2 then break end
		
		local e2 = 2*err
		if e2 > -dz then
			err = err - dz
			x1 = x1 + sx
		end
		
		if x1 == x2 and z1 == z2 then
			table.insert(points, make2dPoint(x1, z1))
			break
		end
		
		if e2 < dx then
			err = err +dx
			z1 = z1 +sz
		end
	
	end


	return points
	
end


-- returns table of line points {{x = x, y = y}, ...}
-- p1, p2: start-/end point {x = x, y = y}
-- worked once but not last time
function myLineAlg(p1, p2)
  
  local points = {}
  local x1 = p1.x
  local y1 = p1.y
  local x2 = p2.x
  local y2 = p2.y
  
  local v1x = x1
  local v1y = y1
  x1 = 0
  y1 = 0
  x2 = x2 - v1x
  y2 = y2 - v1y
  
  local dx = math.abs(x2)
  local dy = math.abs(y2)
  local m = dy / dx
  if m > 1 then
    m = dx / dy
  end
  
  if dx > dy then
    
    for x = 0, x2, capi.sign(x2) do
      
      local y = m * math.abs(x) * capi.sign(y2)
      table.insert(points, {x = x + v1x, y = math.floor(y + 0.5) + v1y})
      
    end
    
  elseif dy > dx then

    for y = 0, y2, capi.sign(y2) do
      
      x = m * math.abs(y) * capi.sign(x2)
      table.insert(points, {x = math.floor(x + 0.5) + v1x, y = y + v1y})
      
    end
    
  else
    
    for y = y1, y2, capi.sign(y2 - y1) do
      
      x = math.abs(y) * capi.sign(x2)
      table.insert(points, {x = x + v1x, y = y + v1y})
      
    end
    
  end
  return points
  
end


-- draw lines from point to point
function polygon(points)
  
  
  
end


-- Get points table forming the outline of a square.
-- The points are ordered circular from p1 back to p1
-- following p1->z->x->p2->z->x.
-- Minimum size: 2x2
function square2dOutline(p1, p2)
  
  local points = {}
  
  local linePoints = {}
  
  -- 1
  local subx = capi.sign(p2.x - p1.x)
  local subz = capi.sign(p2.z - p1.z)
  
  linePoints = line2dBres(p1, make2dPoint(p1.x, p2.z -subz))
  
  for _, v in ipairs(linePoints) do
  
  	table.insert(points, v)
  
  end
  
  -- 2
  linePoints = line2dBres(make2dPoint(p1.x, p2.z), make2dPoint(p2.x -subx, p2.z))
  
  for _, v in ipairs(linePoints) do
  
  	table.insert(points, v)
  
  end
  
  -- 3
  linePoints = line2dBres(p2, make2dPoint(p2.x, p1.z +subz))
  
  for _, v in ipairs(linePoints) do
  	table.insert(points, v)
  
  end
  
  -- 4
  linePoints = line2dBres(make2dPoint(p2.x, p1.z), make2dPoint(p1.x +subx, p1.z))
  
  for _, v in ipairs(linePoints) do
  	table.insert(points, v)
  
  end
  
  return points  
  
end


-- return table
function squareFill(length, width, orientation, doFill)
  
  
  
end


function plane(length, width)
  
  
  
end


function box(length, width, height, isFloor, isCeiling, doFill)
  
  
  
end


function circle(diameter, doFill)
  
  
  
end


function disc(diameter)
  
  
  
end


function tube(diameter, height)
  
  
  
end


function cone(diameter1, diameter2, height, doFill)
  
  
  
end


function sphere(diameter, doFill)
  
  
  
end


