local id, message

function update(text)
  while true do 
    statusColor = colors.red
    if text == "running" then
      statusColor = colors.green
    elseif text == "offline" then
      statusColor = colors.gray
    elseif text == "warming_up" then
      statusColor = colors.orange
    end
    term.setTextColor(statusColor)
    print(text)
  end
end

function out()
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
      rednet.broadcast("status")
      sleep(10)
      term.clear()
    end
  end
end

function input()
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
      update(message.status)
    end
  end
end

parallel.waitForAll(out, input)

