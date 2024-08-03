local Player = game.Players.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")
local EvolveValue = PlayerScripts:WaitForChild("Evolved")
local PlayerGui = Player:WaitForChild("PlayerGui")
local Stage3Button = PlayerGui:WaitForChild("MainGui").Stage3Button
local MainGui = Stage3Button.Parent
local TweenService = game:GetService("TweenService")
local EvolveText = MainGui:WaitForChild("EvolveText")
local targetPosition = UDim2.new(0.353, 0, 0.3, 0)
local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tween = TweenService:Create(EvolveText, tweenInfo, {Position = targetPosition})

Stage3Button.MouseButton1Click:Connect(function() 
	EvolveText.Text = "Buildings are now vulnerable"
	EvolveText.TextColor3 = Color3.fromRGB(85, 0, 0)
	EvolveText.Visible = true
	tween:Play()
	EvolveValue.Value = 3
	task.wait(3)
	EvolveText.Visible = false
	Stage3Button.Visible = false
end)

EvolveValue.Changed:Connect(function()
	-- I don't understand this function. 
	local TheStageValue = EvolveValue.Value
	if TheStageValue == 3 then
		for _, child in ipairs(workspace:GetDescendants()) do
			if child:IsA("StringValue") and child.Name == "Vulnerability" then
				child.Value = "true"
				child.Parent.Name = "Vulnerable"
			end
		end
	end
end)