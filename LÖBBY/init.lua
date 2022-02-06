local PATH = (...)

print("path",PATH)

return setmetatable({
	alreadyCalled = false, -- Has the table been called using the metamethod. Shouldn't be called more than once
	VERSION = "0.0.2", -- BETA Release

	onConnectedToLobby = function(lobby)--This function is a signal/event/callback. Set by the developer

	end,

},

{--Metatable 
	__call = function (self,sockServer_Client,defaultStatesList) -- sockServer_Client is either the server or client table
		assert(not self.alreadyCalled,"You can't call library more than once")

		self.sock = sockServer_Client


		if sockServer_Client.sendToAllBut then --If sockServer_Client is a server table
			for key,v in pairs(require (PATH..".server")) do
				print("key",key)
				self[key] = v -- Adds each item individually
			end

			sockServer_Client:on("LÖBBY-EVENT",function(data,client)--Event reciever/listener
				print("EVENTRECV")
				lobby = self.clientList[client]
				if lobby.statesList[data.nameOfEvent] then --If event exists on the server gamestate
					lobby.statesList[data.nameOfEvent](sockServer_Client,data,client,self.cli)--Calls the event
				else print("LÖBBY: Couldn't find event:"..data.nameOfEvent,lobby.statesList[data.nameOfEvent])--Warns the developer if event doesn't exist
				end
			end)

		elseif not sockServer_Client.sendToAllBut then --if sockServer_Client is a client table
			for key,v in pairs(require (PATH..".client")) do
				print("client",key)
				print("ft")
				self[key] = v -- Adds each item individually
			end

			sockServer_Client:on("LÖBBY-EVENT",function(data)--Event reciever/listener
				print("EVENTRECV")
				if self.statesList[data.nameOfEvent] then --If event exists on the client gamestate
					self.statesList[data.nameOfEvent](sockServer_Client,data)--Calls the event
				else print("LÖBBY: Couldn't find event:"..data.nameOfEvent)--Warns the developer if event doesn't exist
				end
			end)

			sockServer_Client:on("connectToLobby",function(data) -- Called when the server connects client to lobby
				--Not sure why this function works lol, might break
				print(self.alreadyCalled,self,self.vaer)
				self.lobby = data

				self.onConnectedToLobby(self.lobby)

			end)
		end
		self.alreadyCalled = true
	end,

	__tostring = function (self)
		return "LÖBBY"
	end

})
