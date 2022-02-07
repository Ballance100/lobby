return {

	defaultStatesList = nil,
	--SERVER SIDE
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
		if lobby.statesList.update ~= nil then lobby.statesList.playerConnected(client,lobby.varList,lobby,self.sock) end
	end,

	settings = {	},

	update = function(self,dt)
		for i,v in ipairs(self.listOfLobbies) do
			v.statesList.update(dt,v.varList,v,self.sock)
			local tab = 
				self.sock:send()

		end
	end,

	recievedItem = function(self,name,data,client) --Adds item to "receivedItems" table in the approiate lobby. self is the reference to the module table

		local clientsLobby = self.clientList.indexMap[client] -- Checks what lobby the client is connected to
		print("recievedItem")
		if clientsLobby.statesList.events[name] then clientsLobby.statesList.events[name](
			self.varList,
			data,
			client,
			clientsLobby,
			self.sock
		) end --[[ Calls a statesList event ]]
	end,

	createLobby = function(self,statesList,clients,configs) --Creates

		if not configs then configs = {} end

		if statesList == nil then error([[
			You need to include the states list when creating a lobby
			Look closely at this error message to find out what line the problem is at.
		]]) end

		self.listOfLobbies[#self.listOfLobbies+1] = {
			sockServer = self.sock,
			lobbyLibrary = self,
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

			--STATES
			switchState = function(self,newState)
				self.statesList:leaving()
				self.statesList = newState
				self.statesList:entering()
			end,

			getState = function(self)
				return self.statesList
			end,

			--EVENTS
			fire = function (self, nameOfEvent, data, clientList)
				if not clientList then clientList = self.connectedClients end

				if data == nil then data = {} end
				data.nameOfEvent = nameOfEvent
				print(self.sockServer)
				for i,v in ipairs(clientList) do v:send("LÖBBY-EVENT",data) end
				
			end,

			--CLIENT
			addClient = function(self,client)
				self.connectedClients[#self.connectedClients+1] = client
				self.lobbyLibrary.clientList(client,self)
			if self.statesList.update ~= nil then  self.statesList.playerConnected(client,self.varList,self,self.sock) end
				self.sock:send("LÖBBY-connectedToLobby",{
					lobbyID = self.lobbyID,
					userData = {} -- Comming soon (hopefully)
				})
			end,

			--replicatedVariables
			replicatedVariables = {toBeSent = {}},
--toBeSent is a dictionary list of all the variables that need updating(unsequenced variables always get sent)
			createReplicatedVariableClass = function (self,name,RepVarTable)
				local finalTable = setmetatable({},{
					__index = function (self,key)
						return rawget(self,key[1])--key[2] is the type of variable, ie. reliable or unsequenced
					end,
					__newindex = function (repVarTable,key,value)
						if repVarTable[key] == nil then print(
							"LÖBBY: Adding variables:https://github.com/Ballance100/lobby/wiki/Replicated-Variables#adding-new-variables")--Warns
							error("You can't add variables to replicated variables like this. Tutorial on last console message")
						end

						if value == nil then print("https://github.com/Ballance100/lobby/wiki/Replicated-Variables#removing-variables")
							error("You can't add variables to replicated variables like this. Tutorial on last console message")
						end

						if repVarTable[2] == "reliable" then self.replicatedVariables.toBeSent[key] = value end

						rawset(repVarTable,key[1],value)

					end
				
				})
				finalTable.lobby = self
				for i,v in pairs(RepVarTable.reliable) do
					rawset(finalTable,i,{v,"reliable"})
					self.replicatedVariables.toBeSent[i] = v
				end
				for i,v in ipairs(RepVarTable.unsequenced) do
					rawset(finalTable,i,{v,"unsequenced"})
					self.replicatedVariables.toBeSent[i] = v
				end

				self.replicatedVariables[name] = finalTable
			end

		}

		local lbby = self.listOfLobbies[#self.listOfLobbies]-- shortcut
		lbby.replicatedStorage = lbby.replicatedVariables
		lbby.createRepVarClass = lbby.createReplicatedVariableClass

		--If config.lobbyID ~= nil then set lobby ID to config.lobbyID. If lobbyID hasnt been specified, just set to os.clock()
		if configs.lobbyID then lbby.lobbyID = configs.lobbyID else lbby.lobbyID = os.clock() end

		if lbby.statesList.entering then
 
			lbby.statesList.entering(lbby.varList,lbby,self.sock)
		 end

		for index,currentClient in ipairs(clients) do 

			self:addClient(currentClient, self.listOfLobbies[#self.listOfLobbies])
		end


		return lbby
	end,


} 
