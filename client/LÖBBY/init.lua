local PATH = (...)

print("path",PATH)

return setmetatable({
	alreadyCalled = false -- Has the table been called using the metamethod. Shouldn't be called more than once
},

{--Metatable
	__call = function (self,sockServer_Client) -- sockServer_Client is either the server or client table
		assert(not self.alreadyCalled,"You can't call library more than once")

		self.sock = sockServer_Client


		if sockServer_Client.sendToAllBut then --If sockServer_Client is a server table
			for key,v in pairs(require (PATH..".server")) do
				print("key",key)
				self[key] = v -- Adds each item individually
			end

		elseif not sockServer_Client.sendToAllBut then --if sockServer_Client is a client table
			for key,v in pairs(require (PATH..".client")) do
				print("client",key)
				print("ft")
				self[key] = v -- Adds each item individually
			end

			sockServer_Client:on("connectToLobby",function(data) -- Called when the server connects client to lobby
				self.lobbyID = data.lobbyID
			end)
		end
		self.alreadyCalled = true
	end,

	__tostring = function (self)
		return "LÖBBY"
	end

})