-- drmon installation script
--
--

local libURL = "https://raw.githubusercontent.com/aedan/drmon/master/lib/f.lua"
local startupURL = "https://raw.githubusercontent.com/aedan/drmon/master/drmon.lua"
local batURL = "https://raw.githubusercontent.com/aedan/drmon/master/bat.lua"
local lib, startup, bat
local libFile, startupFile, batFile

fs.makeDir("lib")

lib = http.get(libURL)
libFile = lib.readAll()

local file1 = fs.open("lib/f", "w")
file1.write(libFile)
file1.close()

startup = http.get(startupURL)
startupFile = startup.readAll()

local file2 = fs.open("startup", "w")
file2.write(startupFile)
file2.close()

bat = http.get(batURL)
batFile = bat.readAll()

local file3 = fs.open("bat", "w")
file3.write(batFile)
file3.close()
