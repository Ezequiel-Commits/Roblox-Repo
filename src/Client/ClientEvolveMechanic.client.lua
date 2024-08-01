local UserInputService = game:GetService("UserInputService")
local holdingV = false
local startTime = 0
local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer
local Label = Player.PlayerGui:WaitForChild("MainGui").EvolveCountDown
local Stage3Button = Label.Parent:WaitForChild("Stage3Button", 5)
local resetTimer = 0
local countdownInProgress = false
local PlayerScripts = Player:WaitForChild("PlayerScripts", 5)
local EvolveValue = PlayerScripts:WaitForChild("Evolved")

local Backpack = Player:WaitForChild("Backpack")
-- scaling the blaster isn't neccessary, though I could use the same logic to scale future abilities 
local Blaster = Backpack:WaitForChild("Blaster")

-- Creating a tween for a gui
local TweenService = game:GetService("TweenService")
local EvolveText = Label.Parent:WaitForChild("EvolveText")
local targetPosition = UDim2.new(0.353, 0, 0.3, 0)
local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tween = TweenService:Create(EvolveText, tweenInfo, {Position = targetPosition})

local function onInputEnded(input, player)
	-- a bit confusing
	if input.KeyCode == Enum.KeyCode.V then
		holdingV = false
		Label.Visible = false
		Label.TextColor3 = Color3.fromRGB(0, 0, 0)
		resetTimer = tick()
	end
end

local function Evolve()
	local character = Player.Character
	if character then
		-- check the stage of the player
		if EvolveValue.Value == 0 then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			humanoid.MaxHealth = 1000
			humanoid.Health = 700
			humanoid.WalkSpeed = 10
			for i = 1,2,0.1 do
				character:ScaleTo(i)
				Blaster:ScaleTo(i)
				wait(0.001)
			end
			EvolveText.Visible = true
			tween:Play()
			wait(2.5)
			EvolveText.Visible = false
			EvolveText.Position = UDim2.new(0.353,0,0,0)
			EvolveValue.Value = EvolveValue.Value + 1
			wait(1)
		elseif EvolveValue.Value == 1 then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			humanoid.MaxHealth = 2000
			humanoid.Health = 1400
			humanoid.WalkSpeed = 8
			for i = 2,4,0.2 do
				character:ScaleTo(i)
				Blaster:ScaleTo(i)
				wait(0.001)
			end
			EvolveText.TextColor3 = Color3.fromRGB(118, 39, 0)
			EvolveText.TextStrokeColor3 = Color3.fromRGB(213, 64, 0)
			EvolveText.Visible = true
			tween:Play()
			wait(2.5)
			EvolveText.Visible = false
			EvolveValue.Value = EvolveValue.Value + 1
			EvolveText.Position = UDim2.new(0.353,0,0,0)
			Stage3Button.Visible = true
			wait(2)
			script:Destroy()
		end
	end
end

local function CountDown()
	if countdownInProgress then
		return
	end

	Label.TextColor3 = Color3.fromRGB(0, 0, 0)

	countdownInProgress = true
	Label.Visible = true
	holdingV = true

	for i = 5, 1, -1 do
		Label.Text = tostring(i)
		wait(1)

		if not holdingV then
			break
		end
	end

	if holdingV then
		Evolve()
	end

	countdownInProgress = false
end

local function onInputBegan(input, player)
	if input.KeyCode == Enum.KeyCode.V then
		if not holdingV then
			CountDown()
		end
		resetTimer = 0
	end
end

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)

RunService.Heartbeat:Connect(function()
	if resetTimer ~= 0 and tick() - resetTimer >= 5 then
		holdingV = false
		resetTimer = 0
	end
end)