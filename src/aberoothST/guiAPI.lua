-- guiAPI
-- Functions for (Advanced) Computers and Monitors

preDefButtons = {
forward =
{"    ",
"fwrd",
"    "},
back = 
{"    ",    
"back",
"    "},
left = 
{"    ",
"left",
"    "},
right = 
{"    ",
"rght",
"    "},
up = 
{"    ",
" up ",
"    "},
down = 
{"    ",
"down",
"    "}
}

print = function(text, x, y)

	term.setCursorPos(x, y)
	io.write(text)

end


println = function(text, x, y)

	print(text, x, y)
	io.write("\n")

end


writeln = function(text)

	io.write(text.."\n")

end


drawFrame = function(x1, y1, x2, y2)

	

end


fillSquare = function(color, x1, y1, x2, y2)

	local height = y2 - y1
	for i = 0, height - 1 do
		paintutils.drawLine(x1, y1 +i, x2, y1 +i, color)
	end

end


make4x4Button = function(button, action, textColor, buttonColor, x, y)

	return {button = button, action = action, textColor = textColor, buttonColor = buttonColor, x = x, y = y}

end


makeButton = function(name, textColor, buttonColor, x1, y1, x2, y2)

	return {name = name, textColor = textColor, buttonColor = buttonColor, x1 = x1, y1 = y1, x2 = x2, y2 = y2}

end


drawClickedButton = function(button)

		term.setTextColor(button.textColor)
		term.setBackgroundColor(colors.combine(button.buttonColor, colors.black))
		term.setCursorPos(button.x, button.y)
		for i = 1, 3 do
			io.write(button.button[i])
			term.setCursorPos(button.x, button.y + i)
		end
		
end


drawUnclickedButton = function(button)

		term.setTextColor(button.textColor)
		term.setBackgroundColor(button.buttonColor)
		term.setCursorPos(button.x, button.y)
		for i = 1, 3 do
			io.write(button.button[i])
			term.setCursorPos(button.x, button.y + i)
		end

end


draw4x4Buttons = function(buttons)

	for _, button in ipairs(buttons) do
	
		drawUnclickedButton(button)
	
	end

end


drawButtons = function(buttons)

	local x1, y1, x2, y2
	
	for _, v in ipairs(buttons) do
		fillSquare(v.buttonColor, v.x1, v.y1, v.x2, v.y2)
		term.setTextColor(v.textColor)
		print(v.name, v.x1/5, v.y1/5)
	
	end

end


getButtonClickedIndex = function(buttons, x, y)

	for k,v in pairs(buttons) do
		if x >= v.x and x <= v.x +3 and y >= v.y and y <= v.y +2 then
			return k
		end
	end
	return nil
end

--