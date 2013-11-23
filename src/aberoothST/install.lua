--3456789012345678901234567890123456789
local pages = {}
pages[1] = 
[[Hi, this is startUI, a user interface
for running apps and managing user
input. After installation, you can
start with the command "startui".
There are 3 pages you can switch with
the TAB key. The first is the start
page, which displays the currently
active app, the second is the app
page where you can select one of the
available programs, the third is the
misc page with tools like refuel.
]]
--3456789012345678901234567890123456789
pages[2] = 
[[Selecting Apps
From the start page hit TAB to go to
the app page. A list of all available
apps is being displayed. Use the ARROW
keys to select an app and hit ENTER.
You will be returned to the start page
and the parameters required for input
are being displayed.
If you have run this app before, the
last values are loaded from its config
file.
]]
--3456789012345678901234567890123456789
pages[3] =
[[Starting Apps
After selecting an app, access each
parameter with the ARROW keys, edit it
with just typing letters or numbers.
Complete input with an ARROW key or
ENTER. If you typed in the required
values move to the bottom line with the
ARROW keys and hit ENTER to start the
app. If anything went wrong, a status
message is displayed in the bottom
line. Change the parameter that is
wrong and hit enter to see the result.
]]
--3456789012345678901234567890123456789
pages[4] =
[[If all parameters are correct, the
slots that need to be filled are
displayed. Fill the slots with the
denoted blocks until the requirements
are met. If the active app no longer
reports errors, it will run.
Additionally the input parameters are
stored in a config file and are loaded
when you start the app again later.
Also the last used app is stored and
loaded after reboot or logout.
]]
--3456789012345678901234567890123456789
pages[5] =
[[Any time you install or update, the
"_app" folder will be cleared to remove
deprecated files.
If you do not want this, install
manually or make a backup.

Press 'y' to install now
or any key to cancel    >]]

local apis = {
	{"commonAPI", "https://raw.github.com/snhub/CCLua/master/src/aberoothST/commonAPI.lua"},
	{"startUI", "https://raw.github.com/snhub/CCLua/master/src/aberoothST/startUI.lua"},
	{"turtleAPI", "https://raw.github.com/snhub/CCLua/master/src/aberoothST/turtleAPI.lua"}
}

local apps = {
	{"menuDummy", "https://raw.github.com/snhub/CCLua/master/src/aberoothST/menuDummy.lua"},
	{"weather", "https://raw.github.com/snhub/CCLua/master/src/aberoothST/weather.lua"},
	{"floor", "https://raw.github.com/snhub/CCLua/master/src/aberoothST/floor.lua"},
	{"windingStairs", "https://raw.github.com/snhub/CCLua/master/src/aberoothST/windingStairs.lua"}
}

for i = 1, #pages do
	term.clear()
	term.setCursorPos(1, 1)
	io.write(pages[i])
	if i < #pages then
		io.write("Page "..i.."/5 Press any key to continue")
		local event, char = os.pullEvent "char"
	end
end

local event, char = os.pullEvent "char"

term.clear()
term.setCursorPos(1, 1)

if char == "y" then

	for i = 1, #apis do
		io.write("downloading "..apis[i][1])
		local response = http.get(apis[i][2])
		io.write("..writing")
		local file = fs.open(apis[i][1], "w")
		file.write(response.readAll())
		file.close()
		print("..done")
	
	end
	print()
	
	fs.delete("_apps")
	fs.makeDir("_apps")	
	for i = 1, #apps do
		io.write("downloading "..apps[i][1])
		local response = http.get(apps[i][2])
		io.write("..writing")
		local file = fs.open(fs.combine("_apps", apps[i][1]), "w")
		file.write(response.readAll())
		file.close()
		print("..done")
	
	end
	
	print()
	print("Installation complete")
	print("You can run startUI by typing \"startui\"")
	print("(You maybe need to reboot)") 
	print("Have fun")
	

end

--