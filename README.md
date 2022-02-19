
<img src="Lobby Logo.png"
     alt="Gradient Lua Logo"
     height="100"
     style="float: left; margin-right: 10px; margin: auto;" /> 


<img src="Untitled.png"
     alt="Desgined For Lua and LOVE2D"
     width="300"
     height="100"
     style="float: left; margin-right: 10px;" /> 
     
Easily add lobbies (each individually game server) with this extension for ENet and sock.lua.


 To load the library do:
```lua

LOBBY = require "LÖBBY"
```
To finish setting up, setup your sock.lua server/client
```lua
sock = require "sock" --Not included in LÖBBY library

--if script is client
client = sock.newClient("localhost",port) 
--else if script is server
server = sock.newServer

LOBBY(client) 
--or
LOBBY(server)
```

More documentation: [Wiki](https://github.com/Ballance100/lobby/wiki)



