-- http://developer.yahoo.com/weather/#terms
-- 12835812
-- 2459115

local capi = commonAPI
if capi == nil then
	os.loadAPI("commonAPI")
	capi = commonAPI
end

local woeid, degreesUnit

getArgs = function()

	return {"woeid", "unit"}

end

validateArgs = function(args)

	if tonumber(args.woeid) == nil then
		return "woeid must be a number" end
	if args.unit ~= "c" and args.unit ~= "f" then
		return "unit must be 'c' or 'f'" end
	woeid = args.woeid
	degreesUnit = args.unit
	return true

end


runApp = function()

local conditionCodes = {}
conditionCodes.en = {
[0] = "tornado",
"tropical storm",
"hurricane",
"severe thunderstorms",
"thunderstorms",
"mixed rain and snow",
"mixed rain and sleet",
"mixed snow and sleet",
"freezing drizzle",
"drizzle",
"freezing rain",
"showers",
"showers",
"snow flurries",
"light snow showers",
"blowing snow",
"snow",
"hail",
"sleet",
"dust",
"foggy",
"haze",
"smoky",
"blustery",
"windy",
"cold",
"cloudy",
"mostly cloudy (night)",
"mostly cloudy (day)",
"partly cloudy (night)",
"partly cloudy (day)",
"clear (night)",
"sunny",
"fair (night)",
"fair (day)",
"mixed rain and hail",
"hot",
"isolated thunderstorms",
"scattered thunderstorms",
"scattered thunderstorms",
"scattered showers",
"heavy snow",
"scattered snow showers",
"heavy snow",
"partly cloudy",
"thundershowers",
"snow showers",
"isolated thundershowers"
}
conditionCodes.de = {
[0] = "Tornado",
"Tropischer Sturm",
"Hurricane",
"Schwere Gewitter",
"Gewitter",
"Schneeregen",
"Regen und Graupel",
"Schnee und Graupel",
"Gefrierender Nieselregen",
"Nieselregen",
"Gefrierender Regen",
"Schauer",
"Schauer",
"Schneegestoeber",
"Leichte Schneeschauer",
"Schneetreiben",
"Schneefall",
"Hagel",
"Graupel",
"Nebel",
"Neblig",
"Dunst",
"Rauchig",
"Stuermisch",
"Windig",
"Frost",
"Wolkig",
"Meist bewoelkt (Nacht)",
"Meist bewoelkt (Tag)",
"Teilweise bewoelkt (Nacht)",
"Teilweise bewoelkt (Tag)",
"Klar (Nacht)",
"Sonnig",
"Heiter (Nacht)",
"Heiter (Tag)",
"Regen mit Graupel",
"Heiss",
"Oertliche Gewitter",
"Vereinzelte Gewitter",
"Vereinzelte Gewitter",
"Vereinzelte Schauer",
"Starker Schneefall",
"Vereinzelte Schneeschauer",
"Starker Schneefall",
"Teilweise bewoelkt",
"Gewitterschauer",
"Schneeschauer",
"Vereinzelte Gewitterschauer"
}
local response = http.get(
		"http://weather.yahooapis.com/forecastrss?w="..woeid.."&u="..degreesUnit
		) 

local forecastrss = {}

local fc = forecastrss

local resp = response.readAll()

local _, x, attr = 1
x = 1
_, x, fc.city = string.find(resp, "<yweather:location city=[\"](.-)[\"]", x)
fc.city = fc.city
_, x, fc.region = string.find(resp, "region=[\"](.-)[\"]", x)
_, x, fc.country = string.find(resp, "country=[\"](.-)[\"]", x)

_, x, fc.unitTemperature = string.find(resp, "temperature=[\"](.-)[\"]", x)
_, x, fc.unitDistance = string.find(resp, "distance=[\"](.-)[\"]", x)
_, x, fc.unitPressure = string.find(resp, "pressure=[\"](.-)[\"]", x)
_, x, fc.unitSpeed = string.find(resp, "speed=[\"](.-)[\"]", x)

_, x, fc.windChill = string.find(resp, "chill=[\"](.-)[\"]", x)
_, x, fc.windDirection = string.find(resp, "direction=[\"](.-)[\"]", x)
_, x, fc.windSpeed = string.find(resp, "speed=[\"](.-)[\"]", x)

_, x, fc.humidity = string.find(resp, "humidity=[\"](.-)[\"]", x)
_, x, fc.visibility = string.find(resp, "visibility=[\"](.-)[\"]", x)
_, x, fc.pressure = string.find(resp, "pressure=[\"](.-)[\"]", x)
_, x, fc.rising = string.find(resp, "rising=[\"](.-)[\"]", x)

_, x, fc.sunrise = string.find(resp, "sunrise=[\"](.-)[\"]", x)
_, x, fc.sunset = string.find(resp, "sunset=[\"](.-)[\"]", x)

_, x, fc.title = string.find(resp, "<title>Conditions for (.-)</title>", x)
_, x, fc.latitude = string.find(resp, "<geo:lat>(.-)</geo:lat>", x)
_, x, fc.longditude = string.find(resp, "<geo:long>(.-)</geo:long>", x)
_, x, fc.pubDate = string.find(resp, "<pubDate>(.-)</pubDate>", x)
_, x, fc.conditionText = string.find(resp, "text=[\"](.-)[\"]", x)
_, x, fc.conditionCode = string.find(resp, "code=[\"](.-)[\"]")
_, x, fc.conditionTemp = string.find(resp, "temp=[\"](.-)[\"]", x)
_, x, fc.conditionDate = string.find(resp, "date=[\"](.-)[\"]", x)

local forecast = {}
for i = 1, 5 do
  forecast[i] = {}
  _, x, forecast[i].day = string.find(resp, "day=\"(%a+)\"", x)
  _, x, forecast[i].date = string.find(resp, "date=\"(.+)\"", x)
  _, x, forecast[i].low = string.find(resp, "low=\"(%d+)\"", x)
  _, x, forecast[i].high = string.find(resp, "high=\"(%d+)\"", x)
  _, x, forecast[i].text = string.find(resp, "text=\"(%a+)\"", x)
  _, x, forecast[i].code = string.find(resp, "code=\"(%d+)\"", x)
end

fc.forecast = forecast

-- cclogtable("", forecastrss)


local monitor = peripheral.wrap("left")
while true do
  local y = 0
  local monitorIncy = function()
    y = y + 1
    monitor.setCursorPos(1, y)
  end

  monitor.clear()
  monitor.setTextColor(colors.white)
  monitorIncy()
  --monitor.setTextScale(1)
  monitor.write("Wetter fuer")
  monitorIncy()
  monitor.write(fc.city..",")
  monitorIncy()
  local _, _, date = string.find(fc.pubDate, "(%a%a%a,%s%d+%s%a%a%a%s20%d%d)")
  monitor.write(date..",")
  monitorIncy()
  local _, _, time = string.find(fc.pubDate, "(%d+:%d%d %a%a %a%a%a)")
  monitor.write(time..":")
  monitorIncy()
  monitorIncy()
  monitor.write("Temperatur: ")
  local temp = tonumber(fc.conditionTemp)
  if temp < 10 then monitor.setTextColor(colors.blue)
  elseif temp >= 10 and temp < 20 then monitor.setTextColor(colors.yellow)
  else monitor.setTextColor(colors.red) end
  monitor.write(fc.conditionTemp.." "..fc.unitTemperature)
  monitor.setTextColor(colors.white)
  monitorIncy()
  local cond = tonumber(fc.conditionCode)
  monitor.write(conditionCodes.de[cond])
  monitorIncy()
  monitorIncy()
  monitor.write("Sonnenaufg.: "..fc.sunrise)
  monitorIncy()
  monitor.write("Sonnenunte.: "..fc.sunset)
  local seconds = 1
  print "Press key to quit"
  repeat
  	local event = {os.pullEvent()}
  	if event[1] == "key" then return end
  	seconds = seconds + 1
  	sleep(1)
  until seconds == 300
  print "tick"
end

end