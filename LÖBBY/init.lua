local PATH = (...)

print("path",PATH)

return setmetatable({
	alreadyCalled = false, -- Has the table been called using the metamethod. Shouldn't be called more than once
	VERSION = "0.0.3", -- BETA Release

	onConnectedToLobby = function(lobby)--This function is a signal/event/callback. Set by the developer

	end,
	lag = false ,-- Should the library add an artificial lag to aid testing
	extraPingOut = 0, -- How much upload ping it should add
	extraPingIn = 0, --How much download ping it should add

	setLag = function(self,avgPingIn,avgPingOut)
		if avgPingIn ~= 0 or avgPingOut ~= 0 then self.lag = true else self.lag = false end
		self.extraPingIn = avgPingIn -- Artificial Ping
		self.extraPingOut = avgPingOut
	end,

	tableOfWaitingReqs = {
		replicatedVariables = {},
		events = {},
	},--if lag == true then Events and replicated variables are stored here and, after a delay, willl be sent

},

{--Metatable 
	__call = function (self,sockServer_Client,defaultStatesList) -- sockServer_Client is either the server or client table
		assert(not self.alreadyCalled,"You can't call library more than once")

		self.sock = sockServer_Client
		self.timer = require (PATH..".timer")
		self.deepCopy = require(PATH..".deepCopy") -- Sued for deep copying tables

		if sockServer_Client.sendToAllBut then --If sockServer_Client is a server table
			self.defaultStatesList = defaultStatesList

			for key,v in pairs(require (PATH..".server")) do--Adds all items from client.lua file to this one.makes sure server values arent added

				self[key] = v -- Adds each item individually
			end

			sockServer_Client:on("LÖBBY-EVENT",function(data,client)--Event reciever/listener
				

				local lobby = self.clientList.indexMap[client]
				if lobby == nil then print("LÖBBY: Client fired an event, however they wearn't connected to any lobby") end

				if lobby ~= nil then
					if lobby.statesList.events[data.nameOfEvent] then --If event exists on the server gamestate
						lobby.statesList.events[data.nameOfEvent](self.varList,data,client,lobby,sockServer_Client)--Calls the event
					else print("LÖBBY: Couldn't find event:"..data.nameOfEvent)--Warns the developer if event doesn't exist
					end
				end
			end)

			--CLIENT
		elseif not sockServer_Client.sendToAllBut then --if sockServer_Client is a client table
			if defaultStatesList == nil then error("LÖBBY-ERROR: You need to add a gamestate list for the client") end

			for key,v in pairs(require (PATH..".client")) do--Adds all items from client.lua file to this one.makes sure server values arent added
				self[key] = v -- Adds each item individually
			end

			self.statesList = defaultStatesList
			for k,y in pairs(self.defaultGamestateFunctions) do
				if not self.statesList[k] then self.statesList[k] = y end
			end

			sockServer_Client:on("LÖBBY-EVENT",function(data)--Event reciever/listener
				if self.statesList.events[data.nameOfEvent] then --If event exists on the client gamestate
					self.statesList.events[data.nameOfEvent](sockServer_Client,data)--Calls the event
				else print("LÖBBY: Couldn't find event:"..data.nameOfEvent)--Warns the developer if event doesn't exist
				end
			end)

			sockServer_Client:on("LÖBBY-connectedToLobby",function(data) -- Called when the server connects client to lobby
				--Not sure why this function works lol, might break
				
				self.lobby = data
				self.replicatedVariables = data.replicatedVariables
				if self.onConnectedToLobby then self.onConnectedToLobby(self.lobby) end

			end)

			sockServer_Client:on("LÖBBY-ReplicatedVariables",function(data)
				if self.statesList.replicatedVariablesUpdate then self.statesList.replicatedVariablesUpdate(self.lobby,data)
				else
					 error("You neec to have a replicatedVariablesUpdate function in gamestates")
				end
			end)
		end
		self.alreadyCalled = true
	end,

	__tostring = function (self)
		return "LÖBBY"
	end

})
