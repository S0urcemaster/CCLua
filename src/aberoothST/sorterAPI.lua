--[[ Original code by NeverCast, revised for v3.0 by lost_RD
     This should be loaded like a typical api
     Feel free to name it what you like
     This paste created for http://ftbwiki.org/Interactive_Sorter
--]]
local directions = { [0]=0,[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,["down"] = 0, ["up"] = 1, ["-Z"] = 2, ["+Z"] = 3, ["-X"] = 4, ["+X"] = 5, ["+Y"] = 1, ["-Y"] = 0}
directions.south = directions["+Z"]
directions.east = directions["+X"]
directions.north = directions["-Z"]
directions.west = directions["-X"]
 
-- Gets the Unique ID based on the ID and Meta
function getUUID(id, meta)
  uuid = id + meta * 32768
  return uuid
end
 
-- Get a stack table from a single uuid and amount
-- Valid for version 3.0
function getID(uuid)
  id = uuid
  meta = 0
  if uuid > 32768 then
    meta = uuid%32768
    id = id - (meta * 32768)
  end
end
 
-- Get stacks from an Interactive Sorter
-- direction   : the direction of the Interactive Sorter Peripheral
-- invDirection: the direction of the inventory from the peripheral
-- valid options for invDirection are 0,1,2,3,4,5 ( original values),
-- north, south, east, west, up, down, and the +/-X,Y,Z strings.
-- (see directions variable)
function getStacks(direction, invDirection)
  if not peripheral.isPresent(direction) then
    return false, "No Peripheral"
  end
  if peripheral.getType(direction) ~= "interactiveSorter" then
    return false, "Not a sorter"
  end
  local stacks = {}
  for uuid,count in pairs(peripheral.call(direction, "list", directions[invDirection])) do
    table.insert(stacks, getStack(uuid))
  end
  return true, stacks
end