local tab =  {
	lobby = nil, -- When user is connected to a lobby, info about said lobby will be stored here

	statesList = nil,

	replicatedVariables = {},


	update = function(self)

	end,

	fire = function(self,nameOfEvent,data)--Fires an event on the server
		if data == nil then data = {} end
		data.nameOfEvent = nameOfEvent
		self.sock:send("LÖBBY-EVENT",data)
	end
}

tab.replicatedStorage = tab.replicatedVariables


return tab