local pocketUrl = "https://raw.githubusercontent.com/aedan/drmon/master/pocket.lua"

pocket = http.get(pocketUrl)
pocketFile = pocket.readAll()
local file = fs.open("pocket", "w")
file.write(pocketFile)
file.close()

require("pocket")
