
This is an adapted version of drmon written by acidjazz. It has been modified to work with 1.12.2 and has some added features
![](examples/2.jpg)
> *status*: currently in development


# drmon
monitor and failsafe automation for your draconic reactor

# Bat
Monitor for Draconic Storage

# Pocket
Remote access to reactor controls and monitoring

### what is this
This is a set of computercraft LUA scripts that monitors everything about a draconic reactors and storage, with a couple features to help keep it from exploding
NB: This is for Minecraft 1.12.2. You will need to answer some questions on console during install


### tutorial
1.7.10 you can find a very well made youtube tutorial on how to set this up [here](https://www.youtube.com/watch?v=8rBhQP1xqEU) , thank you [The MindCrafters](https://www.youtube.com/channel/UCf2wEy4_BbYpAQcgvN26OaQ)

I have not created a tutorial for 1.12.2 yet.

### features
* uses a 3x3 advanced computer touchscreen monitor to interact with your reactor
* automated regulation of the input gate for the targeted field strength of 50%
* immediate shutdown and charge upon your field strength going below 20%
  * reactor will activate upon a successful charge
* immediate shutdown when your temperature goes above 8000C
  * reactor will activate upon temperature cooling down to 3000C
* easily tweak your output flux gate via touchscreen buttons
  * +/-100k, 10k, and 1k increments
* monitor storage cell capacity on 3x3 screen connected the same way as reactor monitoring
* remote monitoring is available via ender modems(optional)
  * Remote monitoring can monitor multiple reactors at once.
  * Allows for remote status, shutdown, startup of reactors and patching

### requirements
* one fully setup draconic reactor with fuel
* 1 advanced computer
* 9 advanced monitors
* 4 wired modems, wireless will not work
* a bunch of network cable
* 1 ender modem (Optional)

### installation
* One of the reactor stabilizers needs to touch a side of the advanced computer
* The flux gates and monitors need to be connected by modem
 * connect a modem to your input flux gate (the one connected to your reactor energy injector)
  * Take note of the name when you turn the modem on
 * connect a modem to your output flux gate
 * connect a modem to your advanced computer
 * setup yoru monitors to be a 3x3 and connect a modem to anywhere but the front
 * run network cable to all 4 modems
* install this code via running the install script using these commands :

```
> pastebin get zrAq98B5 startup
> startup

> On Advanced ender pocket computer (Optional)
> pastebin get PUWxdYWY startup
> startup
```
* you should see stats in your term, and on your monitor

### upgrading to the latest version
* right click your computer
* hold ctrl+t until you get a `>`

```
> reboot
```

### known issues
* there is a problem with **skyfactory 2.5** and **pastebin**, see workarounds [here](https://github.com/acidjazz/drmon/issues/9#issuecomment-277910288)
