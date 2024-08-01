local dataStoreService = game:GetService("DataStoreService")
local dataStore = dataStoreService:GetDataStore("Tags")

game.Players.PlayerAdded:Connect(function(player)
    local data
	
	local success, errormsg = pcall(function() 
		data = dataStore:GetAsync(player.UserId)
        print(data:GetChildren())
	end)

    if data ~= nil then 
        local Tag = Instance.new("StringValue")
	    Tag.Name = data.TagName
	    Tag.Parent = player
    end
end)