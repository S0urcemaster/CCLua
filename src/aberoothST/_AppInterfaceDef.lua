-- _AppInterfaceDef
-- Description of the app interface for startUI.
-- If you make changes to your app, be sure
-- to reboot the computer so that startUI
-- reloads the app.
-- Common and Turtle API are getting loaded over startUI
-- and are accessible through the variables
-- commonAPI and turtleAPI.


-- Return a table of strings to describe your app's functionality.
-- Each string must have 12 lines and 39 chars per line.
-- Each string produces a new page and a prompt to continue. 
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


-- Return a table of names of required args that will be prompted to the user.
-- This is the first call after the user called the app.
getArgs = function()

  return {"arg1", "arg2"}
  
end

-- Check if the user has done well.
-- Return a string to be shown to the user if he did not.
-- Return true if he'd done right.
-- This is the second call. After it goes getSlots()/getDetailedSlots()
-- and validateSlots()
validateArgs = function(args)
	
	if args.arg1 ~= "what it should be" then return "error message" end
	
	if args.arg2 == "you're stupid" then return "I'm not stupid" end
	
	return true
	
end


-- Return the amount of fuel required for your operation.
-- A message will be shown to the user to refuel if the turtle has less.
getFuel = function()
  
  return #"of movements"
  
end

-- Return a table of slots to be shown to the user.
-- The maximum description length is 6 chars.
-- If you implement getSlots() or getDetailedSlots() or both
-- you have to implement validateSlots() as well.
getSlots = function()
  
  local slots = {}
  
  table.insert(slots, {64, "Stone"})
  table.insert(slots, {56, "Wood"})
  table.insert(slots, {32, "Sand"})
  
  return slots
  
end

-- Return a detailed slots description the user can request.
-- You can pass 3 strings, 6, 9 and 9 chars, to be displayed
-- in 3 rows.
-- The getSlots() function is always being shown as a short
-- description. You have to implement getSlots() as well
-- to pass the amount of items.
-- Slots 4, 8, 12 and 16 only have space for 5, 8 chars
-- respectively. The 6th and 9th char will be cut off here.
-- To make it even you could only use 5 and 8 chars which
-- leaves a space in-between making it a bit better readable.
getDetailedSlots = function()

	local slots = {}
	
	table.insert(slots, {"123456", "123456789", "123456789"})
	table.insert(slots, {"123456", "123456789", "123456789"})
	table.insert(slots, {"123456", "123456789", "123456789"})
	table.insert(slots, {"12345", "12345678", "12345678"})
	
	return slots

end

-- Check if the user has put in enough items thus preventing
-- the turtle from starting with too few items.
-- Return true or false if you check the slots on your own or
-- "builtInExact" for a built-in check slot by slot or
-- "builtInSum" for a built-in check of the total amount of
-- items.
validateSlots = function()

	return "builtInExact"
	--return "builtInSum"
	-- return true/false (own calculation)

end

-- Put your app code inside here.
-- It will be executed once all lights are green.
runApp = function()

	print("All checks passed")

end