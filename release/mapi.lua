-- Menu API
-- NDiBMMbh

function getInput(query)

	local input = {}
	for i = 1, #query do
		write(query[i])
		typed = read()
		table.insert(input, typed)
	end
	return input
end

-- zeige Menue und gib zurueck welcher Menuepunkt ausgewaehlt wurde
-- items[0] ist der Titel
function showMenu(items)
	write(items[0].."\n")
	write("\n")
	for key, value in pairs(items) do
		write(key.."  "..value.."\n")
	end
	write("\n")
	write("(Enter)  Abbrechen\n")
	write("\n")
	input = read()
	if input == "" then
		return nil
	end
	input = tonumber(input)
	return input
end