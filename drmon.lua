local reactorSide, igateName, ogateName, monName, oFlow, iFlow, mon, monitor, monX, monY, reactor, outflux, influx, ri, monType, modem, message

local targetStrength = 25
local maxTemperature = 7900
local safeTemperature = 3000
local targetTemperature = 7000
local lowestFieldPercent = 15

local activateOnCharged = 1
local identify = false

-- please leave things untouched from here on
os.loadAPI("lib/f")

local version = "4.1"

-- last performed action
local action = "None since reboot"
local emergencyCharge = false
local emergencyTemp = false

--write settings to config file
function save_config()
  sw = fs.open("config.txt", "w")
  sw.writeLine(version)
  sw.writeLine(monType)
  sw.writeLine(reactorSide)
  sw.writeLine(igateName)
  sw.writeLine(ogateName)
  sw.writeLine(monName)
  sw.writeLine(oFlow)
  sw.writeLine(iFlow)
  sw.close()
end

--read settings from file
function load_config()
  sr = fs.open("config.txt", "r")
  version = sr.readLine()
  monType = sr.readLine()
  reactorSide = sr.readLine()
  igateName = sr.readLine()
  ogateName = sr.readLine()
  monName = sr.readLine()
  oFlow = tonumber(sr.readLine())
  iFlow = tonumber(sr.readLine())
  sr.close()
end

function pad(str, len, char)
    if char == nil then char = ' ' end
    return string.rep(char, len - #str) .. str
end

function update()
  while true do 
    term.clear()
    term.setCursorPos(1,1)
    ri = reactor.getReactorInfo()
    -- print out all the infos from .getReactorInfo() to term
    if ri == nil then
      error("reactor has an invalid setup")
    end
    for k, v in pairs (ri) do
      if k == "failSafe" then
        print(k.. ": ".. tostring(v))
      else
        print(k.. ": ".. v)
      end
    end
    local outFlow
    outFlow = outflux.getSignalLowFlow()
    print("Output Gate: ", outFlow)
    local inFlow
    inFlow = influx.getSignalLowFlow()
    print("Input Gate: ", inFlow)
    print("Last Message: ", message)
    -- monitor output
    local statusColor
    statusColor = colors.red
    if ri.status == "running" then
      statusColor = colors.green
    elseif ri.status == "offline" then
      statusColor = colors.gray
    elseif ri.status == "warming_up" then
      statusColor = colors.orange
    end
    f.draw_text_lr(mon, 2, 2, 1, "Reactor Status", pad(string.upper(ri.status),12," "), colors.white, statusColor, colors.black)
    f.draw_text_lr(mon, 2, 4, 1, "Generation", pad(f.format_int(ri.generationRate), 10, " ") .. " rf/t", colors.white, colors.lime, colors.black)
    local tempColor = colors.red
    if ri.temperature <= 5000 then tempColor = colors.gray end
    if ri.temperature > 5000 and ri.temperature <= 6500 then tempColor = colors.green end
    if ri.temperature > 6500 and ri.temperature <= 7900 then tempColor = colors.lime end
    if ri.temperature > 7900 and ri.temperature <= 8100 then tempColor = colors.orange end
    f.draw_text_lr(mon, 2, 5, 1, "Temperature", pad(f.format_int(ri.temperature),13," ") .. " C", colors.white, tempColor, colors.black)
    local eta, ets
	ets = ri.maxFuelConversion - ri.fuelConversion
    eta = ri.fuelConversionRate * ets / 20
	print("ETA: ", round2(eta))
    f.draw_text_lr(mon, 2, 6, 1, "ETA", pad(tostring(round2(eta)),11," ") .. "", colors.white, colors.blue, colors.black)
    f.draw_text_lr(mon, 2, 8, 1, "Output Gate", pad(f.format_int(outFlow),10," ") .. " rf/t", colors.white, colors.blue, colors.black)
    f.draw_text_lr(mon, 2, 9, 1, "Input Gate", pad(f.format_int(inFlow),11," ") .. " rf/t", colors.white, colors.blue, colors.black)

    local satPercent
    satPercent = math.ceil(ri.energySaturation / ri.maxEnergySaturation * 10000)*.01
    f.draw_text_lr(mon, 2, 11, 1, "Energy Saturation", pad(tostring(satPercent),8," ") .. "%", colors.white, colors.white, colors.black)
    f.progress_bar(mon, 2, 12, mon.X-2, satPercent, 100, colors.blue, colors.gray)
    local fieldPercent, fieldColor
    fieldPercent = math.ceil(ri.fieldStrength / ri.maxFieldStrength * 10000)*.01
    fieldColor = colors.red
    if fieldPercent >= 50 then fieldColor = colors.green end
    if fieldPercent < 50 and fieldPercent > 30 then fieldColor = colors.orange end
    f.draw_text_lr(mon, 2, 14, 1, "Field Strength T:" .. targetStrength, fieldPercent .. "%", colors.white, fieldColor, colors.black)
    f.progress_bar(mon, 2, 15, mon.X-2, fieldPercent, 100, fieldColor, colors.gray)

    local fuelPercent, fuelColor
    fuelPercent = 100 - math.ceil(ri.fuelConversion / ri.maxFuelConversion * 10000)*.01
    fuelColor = colors.red
    if fuelPercent >= 70 then fuelColor = colors.green end
    if fuelPercent < 70 and fuelPercent > 30 then fuelColor = colors.orange end
    f.draw_text_lr(mon, 2, 17, 1, "Fuel ", pad(tostring(fuelPercent),10," ") .. "%", colors.white, fuelColor, colors.black)
    f.progress_bar(mon, 2, 18, mon.X-2, fuelPercent, 100, fuelColor, colors.gray)
    f.draw_text_lr(mon, 2, 19, 1, "Action ", pad(action,20," "), colors.gray, colors.gray, colors.black)
    -- actual reactor interaction
    --
    if emergencyCharge == true then
      reactor.chargeReactor()
    end
    -- are we charging? open the floodgates
    if ri.status == "warming_up" then
      influx.setSignalLowFlow(900000)
      emergencyCharge = false
    end
    -- are we stopping from a shutdown and our temp is better? activate
    if emergencyTemp == true and ri.status == "stopping" and ri.temperature < safeTemperature then
      reactor.activateReactor()
      emergencyTemp = false
    end
    -- are we charged? lets activate
    if ri.status == "warming_up" and activateOnCharged == 1 then
      reactor.activateReactor()
    end
    -- are we on? regulate the input fludgate to our target field strength
    -- or set it to our saved setting since we are on manual
    if ri.status == "running" then
		autoInFlux = ri.fieldDrainRate / (1 - (targetStrength/100) )
		autoOutFlux = ri.generationRate / (ri.temperature / targetTemperature)
		print("Target Input Gate: ".. autoInFlux)
		print("Target Output Gate: ".. autoOutFlux)
		influx.setSignalLowFlow(autoInFlux)
		outflux.setSignalLowFlow(autoOutFlux)
		save_config()
    end
    -- safeguards
    --
    -- out of fuel, kill it
    if fuelPercent <= 10 then
      reactor.stopReactor()
      action = "Fuel below 10%, refuel"
    end
    -- field strength is too dangerous, kill and it try and charge it before it blows
    if fieldPercent <= lowestFieldPercent and ri.status == "running" then
      action = "Field Str < " ..lowestFieldPercent.."%"
      reactor.stopReactor()
      reactor.chargeReactor()
      emergencyCharge = true
    end
    -- temperature too high, kill it and activate it when its cool
    if ri.temperature > maxTemperature then
      reactor.stopReactor()
      action = "Temp > " .. maxTemperature
      emergencyTemp = true
    end
    sleep(0.1)
  end
end
	function round2(num)
		return SecondsToClock(tonumber(string.format("%." .. 0 .. "f", num)))
	end
	function SecondsToClock(time)
	  local time = tonumber(time)

	  if time <= 0 then
		return "00:00:00";
	  else
		  local days = math.floor(time/86400)
		  local remaining = time % 86400
		  local hours = math.floor(remaining/3600)
		  remaining = remaining % 3600
		  local minutes = math.floor(remaining/60)
		  remaining = remaining % 60
		  local seconds = remaining
		  if (hours < 10) then
			hours = "0" .. tostring(hours)
		  end
		  if (minutes < 10) then
			minutes = "0" .. tostring(minutes)
		  end
		  if (seconds < 10) then
			seconds = "0" .. tostring(seconds)
		  end
		return days.."d "..hours..":"..minutes..":"..seconds
	  end
	end

function patch()
  local installURL = "https://raw.githubusercontent.com/Erani0/drmon/full-auto/install.lua"
  install = http.get(installURL)
  installFile = install.readAll()
  local file = fs.open("startup", "w")
  file.write(installFile)
  file.close()
end

function wireless()
  modem = "none"
  local list = peripheral.getNames()
  for i = 1, #list do
    check = peripheral.getMethods(list[i])
    for a = 1, #check do
      if check[a] == "isWireless" then
        test = peripheral.wrap(list[i])
        if test.isWireless() then
          modem = list[i]
        end
      end
    end
  end
  if modem ~= "none" then
    while true do
      if not rednet.isOpen(modem) then
          rednet.open(modem)
      end
      id,message = rednet.receive()
      if message == "reboot" then
        os.reboot()
      end
      if message == "shutdown" then
        reactor.stopReactor()
      end
      if message == "startup" then
        reactor.chargeReactor()
        reactor.activateReactor()
      end
      if message == "checkin" then
        rednet.send(id, "hello")
      end
      if message == "status" then
        rednet.send(id,ri)
      end
      if message == "patch" then
        patch()
        os.reboot()
      end
      if message == "identify" then
        if identify == true then
          monitor.setBackgroundColor(colors.lightBlue)
          monitor.clear()
          identify = false
        else
          monitor.setBackgroundColor(colors.black)
          monitor.clear()
          identify = true
        end
      end
    end
  end
end

if not pcall(load_config) then
  save_config()
end

monitor = peripheral.wrap(monName)
influx = peripheral.wrap(igateName)
outflux = peripheral.wrap(ogateName)
reactor = peripheral.wrap(reactorSide)

influx.setSignalLowFlow(iFlow)
outflux.setSignalLowFlow(oFlow)

monX, monY = monitor.getSize()
mon = {}
mon.monitor,mon.X, mon.Y = monitor, monX, monY
monitor.setBackgroundColor(colors.black)
monitor.clear()

parallel.waitForAll(update, wireless)
