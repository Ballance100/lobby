local tab =  {
	lobby = nil, -- When user is connected to a lobby, info about said lobby will be stored here

	statesList = nil,

	replicatedVariables = {},


	update = function(self,dt)
		if dt == nil then error("LÖBBY-ERROR: You need to pass dt to client:update") end
		self.timer.update(dt)
		if self.lobby ~= nil then --If connected to lobby
			if self.statesList.update then self.statesList:update(dt,self.lobby,self.sock) end
		end
	end,

	draw = function (self)
		if self.lobby ~= nil then --If connected to lobby
			if self.statesList.draw then self.statesList:draw(self.lobby,self.sock) end
		end
	end,

	fire = function(self,nameOfEvent,data)--Fires an event on the server
			if data == nil then data = {} end
			data.nameOfEvent = nameOfEvent
			local oldRepVars = self.deepCopy(data)
			if self.lag == false then	
				client:send("LÖBBY-EVENT",data)
			else self.timer.after(self.extraPingOut, function() 
				client:send("LÖBBY-EVENT",oldRepVars)

				end)
			end

	end,

	defaultGamestateFunctions = {
		replicatedVariablesUpdate = function(lobby,variableList)
			lobby.replicatedVariables = variableList
		end,
	},
}

tab.replicatedStorage = tab.replicatedVariables


return tab