return setmetatable({
	listOfLobbies = setmetatable({indexMap={}},--[[indexMap is used to make indexing more efficiant.
	Servers are stored directly in the table and indexed with a number. the indexMaps stay in the "indexMap" table--]]
	{
		__newindex = function(self,key,value)
			if value ~= nil then -- Adding Item
				rawset(self,key,value)
				self.indexMap[value] = #self
			else --Removing Item
				local index = self.indexMap[key]
				self.indexMap[value] = nil
				table.remove(self,index)
			end
		end
	}),

	clientList = setmetatable({indexMap = {}}, { --[[ client indexMap works like
	"key = client" value = "lobby client is connected to". Used to find out what lobby the client is connected to--]]
				__newindex = function (self,key,value)
					--[[if value ~= nil then -- Adding Item
						rawset(self,key,value)
						self.indexMap[value] = #self
					else --Removing Item
						local index = self.indexMap[key]
						self.indexMap[value] = nil
						table.remove(self,index)
					end--]]
				end,
				
				__call = function(self,client,lobby)--self is the clients table
					print("Setting Client")
					rawset(self,#self+1,client)
					self.indexMap[client] = lobby
				
				end}),

	addClient = function (self,client,lobby)
		lobby.connectedClients[#lobby.connectedClients+1] = client
		self.clientList(client,lobby)
		if lobby.statesList.update ~= nil then print(2) lobby.statesList.playerConnected(client,lobby.varList,lobby,self.sock) end
	end,

	settings = {	},

	update = function(self,dt)
		for i,v in ipairs(self.listOfLobbies) do
			v.statesList.update(dt,v.varList,v,self.sock)
		end
	end,

	--[[on = function(self,name,func) -- replacement for lobby/client:on(). Not currently used

	end]]

	recievedItem = function(self,name,data,client) --Adds item to "receivedItems" table in the approiate lobby. self is the reference to the module table
		print(self.clientList.indexMap[client])
		local clientsLobby = self.clientList.indexMap[client] -- Checks what lobby the client is connected to
		print("recievedItem")
		if clientsLobby.statesList.events[name] then clientsLobby.statesList.events[name]() end --[[ Calls a statesList event ]]
	end,

	createLobby = function(self,statesList,clients) --Creates

		if statesList == nil then error([[
			You need to include the states list when creating a lobby

			Look closely at this error message to find out what line the problem is at.
		]]) end

		self.listOfLobbies[#self.listOfLobbies+1] = {
			sockServer = self.sock,
			receivedItems = {}, -- list of all the things been sent to lobby since last state:update()
			statesList = statesList,
			varList = {},
			connectedClients = {},
			destroy = function(self)
				if self.statesList.leaving and self.statesList.shuttingDown == false then 
					self.statesList.leaving(self.varList,self,self.sockServer)
				elseif self.statesList.shuttingDown then 
					self.statesList.shuttingDown(self.varList,self,self.sockServer) 
				end
				self = nil
			end,

			switchState = function(self,newState)
				self.statesList:leaving()
				self.statesList = newState
				self.statesList:entering()
			end,

			getState = function(self)
				return self.statesList
			end
		}

		local lbby = self.listOfLobbies[#self.listOfLobbies]
		if lbby.statesList.entering then
			print(8) 
			lbby.statesList.entering(lbby.varList,lbby,self.sock)
		 end

		for index,currentClient in ipairs(clients) do 

			self:addClient(currentClient, self.listOfLobbies[#self.listOfLobbies])
		end


		return lbby
	end,
},

{--Metatable
	__call = function (self,sockServer_Client) -- sockServer_Client is either the server or client table
		self.sock = sockServer_Client
	end,

	__tostring = function (self)
		return "LÖBBY"
	end

})
