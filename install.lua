-- drmon installation script
--
--

local libURL = "https://raw.githubusercontent.com/aedan/drmon/master/lib/f.lua"
local reactorURL = "https://raw.githubusercontent.com/aedan/drmon/master/drmon.lua"
local batURL = "https://raw.githubusercontent.com/aedan/drmon/master/bat.lua"
local lib, reactor, bat, libFile, reactorFile, batFile, selected, monType, flowIn, FlowOut, rSide, monitor, first, second
local version = "4.0"

fs.makeDir("lib")

lib = http.get(libURL)
libFile = lib.readAll()

local file1 = fs.open("lib/f", "w")
file1.write(libFile)
file1.close()

reactor = http.get(reactorURL)
reactorFile = reactor.readAll()

local file2 = fs.open("reactor", "w")
file2.write(reactorFile)
file2.close()

bat = http.get(batURL)
batFile = bat.readAll()

local file3 = fs.open("bat", "w")
file3.write(batFile)
file3.close()

selected = 1

function save_config()
  sw = fs.open("config.txt", "w")
  sw.writeLine(version)
  sw.writeLine(monType)
  sw.writeLine(rSide)
  sw.writeLine(flowIn)
  sw.writeLine(flowOut)
  sw.writeLine(monitor)
  sw.writeLine("0")
  sw.writeLine("900000")
  sw.writeLine("1")
  sw.writeLine("0")
  sw.close()
end

function load_config()
  sr = fs.open("config.txt", "r")
  version = sr.readLine()
  monType = sr.readLine()
  sr.close()
end

local function bwOc(c,bw)
  return term.isColor() and c or bw
end

function detect()
  first = ""
  second = ""
  local p = peripheral.getNames()
  if table.getn(p) == 0 then
    term.clear()
    term.write("No devices detected")
    exit()
  end
  for i = 1, #p do
    if string.find(p[i],"monitor") then
      monitor = p[i]
    end
    if string.find(p[i],"flux") then
      if string.find(first,"flux") then
	second=p[i]
      else
	first=p[i]
      end
    end
    if p[i] == "back" or p[i] == "left" or p[i] == "right" or p[i] == "up" or p[i] == "down" then
      subp = peripheral.getMethods(p[i])
      if #subp > 0 then
	for a = 1, #subp do
	  if string.find(subp[a], "Reactor") then 
	    rSide = p[i]
	  end
	end
      end
    end
  end
end

local function typeMenu()
  width,height=term.getSize()
  term.setBackgroundColor(colors.black)
  term.setTextColor(bwOc(colors.red,colors.white))
  term.clear()

  local cx,cy=math.floor(width/2),math.floor(height/2)

  term.setCursorPos(cx-6,cy-3)
  term.write("Initial Setup")
  term.setCursorPos(1,cy-1)
  term.write("What monitor are you configuring?")

  term.setCursorPos(3,cy+1)
  if selected==1 then
    term.setTextColor(bwOc(colors.blue,colors.black))
    term.setBackgroundColor(bwOc(colors.lightGray,colors.white))
  else
    term.setTextColor(bwOc(colors.lightBlue,colors.white))
    term.setBackgroundColor(colors.black)
  end
  term.write("Reactor")

  term.setCursorPos(3,cy+3)
  if selected==2 then
    term.setTextColor(bwOc(colors.blue,colors.black))
    term.setBackgroundColor(bwOc(colors.lightGray,colors.white))
  else
    term.setTextColor(bwOc(colors.lightBlue,colors.white))
    term.setBackgroundColor(colors.black)
  end
  term.write("Battery")
end

local function flowMenu()
  local cx,cy=math.floor(width/2),math.floor(height/2)
  width,height=term.getSize()
  term.setBackgroundColor(colors.black)
  term.setTextColor(bwOc(colors.red,colors.white))
  term.clear()
  term.setCursorPos(cx-6,cy-3)
  term.write("Initial Setup")
  term.setCursorPos(1,cy-1)
  term.write("Which flux gate is the input gate?")

  term.setCursorPos(3,cy+1)
  if selected==1 then
    term.setTextColor(bwOc(colors.blue,colors.black))
    term.setBackgroundColor(bwOc(colors.lightGray,colors.white))
  else
    term.setTextColor(bwOc(colors.lightBlue,colors.white))
    term.setBackgroundColor(colors.black)
  end
  term.write(first)

  term.setCursorPos(3,cy+3)
  if selected==2 then
    term.setTextColor(bwOc(colors.blue,colors.black))
    term.setBackgroundColor(bwOc(colors.lightGray,colors.white))
  else
    term.setTextColor(bwOc(colors.lightBlue,colors.white))
    term.setBackgroundColor(colors.black)
  end
  term.write(second)
end

local function runMenu()
  typeMenu()
  while true do
    local event={os.pullEvent()}
    if event[1]=="key" then
      local key=event[2]
      if key==keys.up or key==keys.w then
        selected=selected-1
        if selected==0 then
          selected=2
        end
        typeMenu()
      elseif key==keys.down or key==keys.s then
        selected=selected%2+1
        typeMenu()
      elseif key==keys.enter or key==keys.space then
        break
      end
    end
  end
  if selected==2 then
    monType = "bat"
  else
    monType = "reactor"
  end
  if monType == "reactor" then
    flowMenu()
    while true do
      local event={os.pullEvent()}
      if event[1]=="key" then
        local key=event[2]
        if key==keys.up or key==keys.w then
          selected=selected-1
          if selected==0 then
            selected=2
          end
          flowMenu()
        elseif key==keys.down or key==keys.s then
          selected=selected%2+1
          flowMenu()
        elseif key==keys.enter or key==keys.space then
          break
        end
      end
    end
    if selected == 2 then
      flowIn = second
      flowOut = first
    else
      flowIn = first
      flowOut = second
    end
  end
end

if fs.exists("config.txt") == false then
  detect()
  runMenu()
  save_config()
else
  load_config()
  if version ~= "4.0" then
    version = "4.0"
    detect()
    runMenu()
    save_config()
  end
end

require(monType)
