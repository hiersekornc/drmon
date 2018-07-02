local pylon = "back"
local monitor = "left"

function format_int(number)
  if number == nil then number = 0 end
  local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
  int = int:reverse():gsub("(%d%d%d)", "%1,")
  return minus .. int:reverse():gsub("^,", "") .. fraction
end

function update()

  while true do
    bat = peripheral.wrap(pylon)
    mon = peripheral.wrap(monitor)

    max = bat.getMaxEnergyStored()
    current = bat.getEnergyStored()
    rate = bat.getTransferPerTick()

    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.green)
    mon.setCursorPos(2,4)
    mon.write("Max Capacity: ")
    mon.setTextColor(colors.white)
    mon.setCursorPos(2,5)
    mon.write(format_int(max))
    mon.setTextColor(colors.green)
    mon.setCursorPos(2,6)
    mon.write("Capacity: ")
    mon.setTextColor(colors.white)
    mon.setCursorPos(2,7)
    mon.write(format_int(current))
    mon.setTextColor(colors.green)
    mon.setCursorPos(2,8)
    mon.write("Rate Change: ")
    mon.setTextColor(colors.white)
    mon.setCursorPos(2,9)
    mon.write(format_int(rate))
    sleep(1)
  end
end

update()
