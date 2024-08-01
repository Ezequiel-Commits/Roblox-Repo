--[[local replicatedStorage = game.ReplicatedStorage
local TopStatus = replicatedStorage:FindFirstChild("TimeStatus")

TopStatus:GetPropertyChangedSignal("Value"):Connect(function()
    
    -- modularize this script by moving it out of the gui 
    script.Parent.TimeStatus.Text = TopStatus.Value
    
end)]]