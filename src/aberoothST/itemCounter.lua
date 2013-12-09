-- itemCounter

local capi = commonAPI

local sortapi = sorterAPI

local filename = "itemData"
local saveDelay = 60
local delayCount = 0

local args = {}

local createItem = function(name, id, meta, count)

	return {name = name, id = id, meta = meta, count = count}

end

local itemData = {
	createItem("TimeTrap", 0, 0, 0),
	createItem("Arrow", 262, 0, 0),
	createItem("Bone", 352, 0, 0),
	createItem("Creeper Head", 397, 4, 0),
	createItem("Gunpowder", 289, 0, 0),
	createItem("Rotten Flesh", 367, 0, 0),
	createItem("Shard of Minium", 27000, 0, 0),
	createItem("Spider Eye", 375, 0, 0),
	createItem("String", 287, 0, 0),
	createItem("Zombie Brain", 25263, 5, 0),
	createItem("Other", 0, 0, 0)
}

local sessionTime = 0

getInfo = function()
	
	local info = {}
--3456789012345678901234567890123456789
info[1] =
[[This is the first line. Line breaks
will be produced as written here.
Explain what is important to know.]]

info[2] =
[[To the point that even a total noob
can understand it.]]
	
	return info

end


getArgs = function()

  return {"sorterLoc", "inLoc", "outLoc"}
  
end


validateArgs = function(argse)
	
	args.sorterLoc = argse.sorterLoc
	args.inLoc = tonumber(argse.inLoc)
	args.outLoc = tonumber(argse.outLoc)
	
	return true
	
end


local function printScreen()
	
	term.clear()
	term.setCursorPos(1, 1)
	
	local hrs, min, mins, sec
	
	print("Item Counter")
	print()
	hrs = math.floor(itemData[1].count / 3600)
	mins = itemData[1].count % 3600
	min = math.floor(mins / 60)
	sec = mins % 60
	
	print("Total Time Running: ", hrs, "h ",min, "m ", sec, "s")
	
	hrs = math.floor(sessionTime / 3600)
	mins = sessionTime % 3600
	min = math.floor(mins / 60)
	sec = mins % 60
	
	print("Time this session > ", hrs, "h ",min, "m ", sec, "s")
	print()
	
	local totalItems = 0
	
	for i = 2, #itemData do
		local s = string.format("%20s %6u", itemData[i].name, itemData[i].count)
		print(s)
		totalItems = totalItems +itemData[i].count
	end
	print()
	
	
	print("Items/Min: ", totalItems /itemData[1].count *60)
	

end


local save = function()
	
	while true do
	
		if delayCount == saveDelay then
			
			local file = fs.open(filename, "w")
			file.write(textutils.serialize(itemData))
			file.close()
			itemData[1].count = itemData[1].count + saveDelay
			
			delayCount = 0
		else
			delayCount = delayCount +1
			sessionTime = sessionTime +1
		end
		coroutine.yield()	
	end

end


runApp = function()
	
	local sorter = peripheral.wrap(args.sorterLoc)
	
	local uuid = sortapi.getUUID(3, 0)
	
	local file
	if fs.exists(filename) then
	
		file = fs.open(filename, "r")
	
		local fileContent = file.readAll()
		
		itemData = textutils.unserialize(fileContent)
		
		file.close()
	
	end
	
	local saveThread = coroutine.create(save)
	coroutine.resume(saveThread)
	
	printScreen()
				
	repeat
		
		local itemsInChest = sorter.list(args.inLoc)
		
		local itemsThere = false
		for uuid, count in pairs(itemsInChest) do
			itemsThere = true
			break
		end
		
		if itemsThere then
			for uuid, count in pairs(itemsInChest) do
				printScreen()
				local found = false
				for i = 2, #itemData -1 do
					if sortapi.getUUID(itemData[i].id, itemData[i].meta) == uuid then
						sorter.extract(args.inLoc, uuid, args.outLoc, count)
						itemData[i].count = itemData[i].count +count
						found = true
						break
					end
				end
				if not found then
					sorter.extract(args.inLoc, uuid, args.outLoc, count)
					itemData[#itemData].count = itemData[#itemData].count +count
				end
			end
			
		else
			os.sleep(1)
			coroutine.resume(saveThread)
		end
	
	until false
	

end

--