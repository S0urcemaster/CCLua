-- Common API

local keytable = {
  [2] = 1, [3] = 2, [4] = 3, [5] = 4, [6] = 5, [7] = 6, [8] = 7,  
  [9] = 8, [10] = 9, [11] = 0, [16] = "q", [17] = "w", [18] = "e",
  [19] = "r", [20] = "t", [21] = "y", [22] = "u", [23] = "i", 
  [24] = "o", [25] = "p", [30] = "a", [31] = "s", [32] = "d", 
  [33] = "f", [34] = "g", [35] = "h", [36] = "j", [37] = "k", 
  [38] = "l", [44] = "z", [45] = "x", [46] = "c", [47] = "v", 
  [48] = "b", [49] = "n", [50] = "m", 
  ENTER = 28,
  BACKSPACE = 14, 
  LSHIFT = 42, 
  RSHIFT = 54, 
  TAB = 15, 
  ESCAPE = 1, 
  DELETE = 211, 
  UP = 200, 
  DOWN = 208, 
  LEFT = 203, 
  RIGHT = 205,
  MINUS = 12,
  SPACE = 57
}

local logFlag = false
-- do the logging
setLog = function(tf)
  logFlag = tf
end

-- append text line to log.cc
cclog = function(text)
  if logFlag then
    file = fs.open("log.cc", "a")
    file.write(os.time().." "..text.."\n")
    file.close()
  end
end

-- recursive function needed
cclogtable = function(text, t)
  if logFlag then
    file = fs.open("log.cc", "a")
    log = ""
    for k,v in pairs(t) do
      sub = v
      if type(v) == "table" then
        sub = "{"
        for d, t in pairs(v) do
          sub = sub.."{k:"..d.." v:"..t.."}"
        end
        sub = sub.."}"
      end
      log = log.."{k:"..k.." v:"..sub.."}"
    end
    file.write(os.time().." "..text.." "..log.."\n")
    file.close()
    file = nil
  end
end

-- returns the ComputerCraft keyboard codes as a table
getKeyTable = function()
  return keytable
end

-- checks if the ComputerCraft keycode letter is a number
-- returns true/false
isNumberKey = function(key)
  return key > 1 and key <11
end

-- checks if the ComputerCraft keycode letter is a letter
-- returns true/false
isLetterKey = function(key)
  return key > 15 and key < 26 or key > 29 and key < 39
    or key > 43 and key < 53 -- < 51 with standard keyboard layout
    or key == keytable.SPACE -- not with standard layout
end

-- checks if the ComputerCraft keycode letter is one of the arrow keys
-- returns true/false
isArrowKey = function(key)
  return key == keytable.UP or
      key == keytable.DOWN or
      key == keytable.LEFT or
      key == keytable.RIGHT
end

-- a loadstring procedure
-- Thanks, BigSHinyToys
-- returns code chunk or error
run = function(path, ...)
    if fs.exists(path) and not fs.isDir(path) then
            file = fs.open(path,"r")
            if file then
                    local sFunk = file.readAll()
                    file.close()
                    local prog,err = loadstring(sFunk)
                    if prog then
                            return prog(...)
                    else
                            return err
                    end
            else
                    return "Unable to open file"
            end
    else
            return "File not found"
    end
    return nil
end

-- reads the keyboard directly using os.pullEvent
-- Thanks, ComputerCraft Wiki
-- returns key
rawread = function()
    while true do
        local sEvent, param = os.pullEvent("key")
        if sEvent == "key" then
          return param
        end
    end
end

-- wrapper around os.pullEvent "char"
-- returns char
pullChar = function()
  event, char = os.pullEvent "char"
  return char
end

-- evaluates os.pullEvent "key" and does os.pullEvent "char" if key was a letter or number
-- returns the char
rawreadKeyChar = function()
  event, key = os.pullEvent "key"
  if isLetterKey(key) or isNumberKey(key) then
    event, char = os.pullEvent "char"
    return char
  end
  return key
end

-- a specialized function for the startUI. Emulates io.input.
-- returns string
rawInput = function(firstLetter)
  
  x0, y0 = term.getCursorPos()
  
  io.write(firstLetter)
  input = firstLetter
  
  key = ""

  repeat
    
    key = rawread()
    
    if key == keytable.BACKSPACE then
      
      if #input > 0 then
        x,y = term.getCursorPos()
        term.setCursorPos(x-1, y)
        io.write(" ")
        term.setCursorPos(x-1, y)
        input = string.sub(input, 1, #input-1)..""
      end
      
    elseif isNumberKey(key) or isLetterKey(key) 
      or key == keytable.MINUS then
      
      char = pullChar()
      io.write(char)
      input = input..char
      
    end
    
  until key == keytable.ENTER or isArrowKey(key)
  
  term.setCursorPos(x0, y0)
  
  if isArrowKey(key) then
    os.queueEvent("key", key)
    --os.queueEvent("key", key)
  end
  
  return input
  
end


-- not updated/ tested
rawInputNumber = function(firstDigit)
  
  x0, y0 = term.getCursorPos()
  
  io.write(firstDigit)
  input = firstDigit
  
  key = ""
  
  repeat
    
    key = rawread()
    
    if key == keytable.BACKSPACE then
      
      if #input > 0 then
        x,y = term.getCursorPos()
        term.setCursorPos(x-1, y)
        io.write(" ")
        term.setCursorPos(x-1, y)
        input = string.sub(input, 1, #input-1)..""
      end
      
    elseif isNumberKey(key) or key == keytable.MINUS then
      
      io.write(keytable[key])
      input = input..keytable[key]
      
    end
    
  until key == keytable.ENTER or isArrowKey(key)
  
  term.setCursorPos(x0, y0)
  
  if key == isArrowKey(key) then
    os.queueEvent("key", key)
  end
  
  return input
  
end

-- simple save for 1-dimensional array (properties)
saveKeyValueTable = function(table, filename)
  
  file = fs.open(filename, "w")
  
  for i = 1, #table do
    
    file.write(table[i][1].."=")
    file.writeLine(table[i][2])
    
  end
  
  file.close()
  
end

-- loads a properties file in a table
-- returns table
loadKeyValueTable = function(filename)
  
  file = fs.open(filename, "r")
  
  if file == nil then return nil end
  
  line = file.readLine()
  
  kvTable = {}
  
  while line ~= nil do
    
    equalsPos = string.find(line, "=", 1, true)
    key = string.sub(line, 1, equalsPos - 1)
    value = string.sub(line, equalsPos + 1, #line)
    table.insert(kvTable, {key, value})
    line = file.readLine()
    
  end
  
  file.close()
  
  return #kvTable > 0 and kvTable or nil
  
end

-- returns true if the number is even
isEven = function(n)
  return n % 2 == 0
end

-- returns true if the number is odd
isOdd = function(n)
	return n % 2 ~= 0
end

-- return true if the number is an integer
isInteger = function(n)
  return n == math.floor(n)
end

-- returns -1 for numbers < 0 and 1 for 0 and < 0  
-- Thx to rv55
sign = function(x)
  return (x<0 and -1) or 1
end

--gibt einen drehwinkel von -90deg bis +180deg zurueck
drehung = function(start, ziel)
	
  if start == ziel then return 0 end
  
  if start == 0 then start = 360 end
  if ziel == 0 then ziel = 360 end
  
  diff = ziel - start
  
  if math.abs(diff) == 180 then return 180 end
  
  if math.abs(diff) == 270 then return -diff/3 end
  
  
  return diff

end

