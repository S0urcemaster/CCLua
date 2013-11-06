src = "c:\\users\\adm9\\desktop\\cc\\"

dest = "c:\\users\\adm9\\desktop\\ftb\\unleashed\\minecraft\\saves\\"

world = "World\\"

files = {
--  ["tunnelEasy.lua"] = "tunnel",
--  ["vierwaende.lua"] = "vierwaende",
  ["capi.lua"] = "capi",
  ["tapi.lua"] = "tapi",
--  ["mapi.lua"] = "mapi",
  ["startup.lua"] = "startup",
  ["geom.lua"] = "geom",
--  ["boden.lua"] = "boden",
--  ["clearFloor.lua"] = "clearfloor",
  ["mauer.lua"] = "mauer",
  ["wendeltreppe.lua"] = "wendeltreppe",
  ["cobbletunnel.lua"] = "cobbletunnel",
  ["treppe.lua"] = "treppe"
}

computers = {
  "0",
  "1",
  "2",
  "3"
}

for srcFile,destFile in pairs(files) do
  for k,computer in pairs(computers) do
    io.write(computer.."  "..srcFile.." -> "..destFile.." ")
    os.execute("copy "..src..srcFile.." "..dest..world.."computer\\"..computer.."\\"..destFile)
  end
end