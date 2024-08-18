local Players = game:GetService("Players")
local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local DebounceModule = require(game.ReplicatedStorage.Shared.DebounceModule)
local AbilityRunning = false
local Mouse = player:GetMouse()

maxMouseDistance = 100
maxLaserDistance = 50

local playerPart = Instance.new("Part", workspace)
playerPart.Name = player.Name.."_Part"
playerPart.Anchored = true
playerPart.CanCollide = false
playerPart.CastShadow = false
playerPart.Size = Vector3.one
playerPart.Transparency = 0

-- tick values 
local TimeOfPreviousFire = 0
local TimeOfPreviousRock = 0
local TimeOfPreviousLeap = 0

local function GetWorldMousePosition()
	local mouseLocation = userInputService:GetMouseLocation()

	local screenToWorldRay = workspace.CurrentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local directionVector = screenToWorldRay.Direction * maxMouseDistance
	
	local RaycastParams = RaycastParams.new()
	RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
	RaycastParams.FilterDescendantsInstances = {player.Character}

	local raycastResult = workspace:Raycast(screenToWorldRay.Origin, directionVector)

	return playerPart.Position
end

local function fireRay()
	local mouseLocation = GetWorldMousePosition()
    local playerHead = player.Character.Head

	local targetLocation = (mouseLocation - playerHead.Position).Unit
	local directionVector = targetLocation * maxLaserDistance

	local abilityRaycastParams = RaycastParams.new()
	abilityRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
	abilityRaycastParams.FilterDescendantsInstances = {player.Character}
	
	
	local abilityRaycastResult = workspace:Raycast(playerHead.Position, playerPart.Position, abilityRaycastParams)

	local hitPosition
	if abilityRaycastResult then
		hitPosition = abilityRaycastResult.Position

		-- some tracer statements
		if abilityRaycastResult.Instance then
			local item = abilityRaycastResult.Instance
			print("abilityRaycast Instance:" .. item.Name)
		end

	else
		hitPosition = playerHead.Position + directionVector
	end
    game.ReplicatedStorage.AbilityFolder.RockThrowFolder.RockThrow:FireServer(hitPosition)

    -- ??
    Mouse.Move:Connect(function()
        if playerPart ~= nil then
            playerPart.Position = playerHead.Position + (Mouse.Hit.Position - playerHead.Position).Unit * 200
        end
    end)

end

local function FireAbility(AbilityName)
    
    assert(typeof(AbilityName) == "string", "Pass a string value")

    if AbilityName == "FireBreath" then
        
        local CastingTime = 7.5 -- is there a better way to implement this casting time? -- Could I pass it as a parameter? 
        local AbilityCooldown = 10 + CastingTime
        -- eliminating ability cooldown for testing
        if DebounceModule.Debounce(TimeOfPreviousFire, 0) and DebounceModule.NoAbilityRunning(AbilityRunning) then
           
            -- if the conditions are fulfilled, cast the ability, start a cooldown,
            -- and make sure other abilities cannot be cast for "CastingTime" seconds
            AbilityRunning = not AbilityRunning
            TimeOfPreviousFire = tick()
            game.ReplicatedStorage.AbilityFolder.FireBreathFolder.FireBreath:FireServer()
            wait(CastingTime)
            AbilityRunning = not AbilityRunning

        end
    elseif AbilityName == "RockThrow" then
        
        local CastingTime = 2 
        -- local AbilityCooldown = 5 + CastingTime
        local AbilityCooldown = 0
        if DebounceModule.Debounce(TimeOfPreviousRock, AbilityCooldown) and DebounceModule.NoAbilityRunning(AbilityRunning) then
            
            AbilityRunning = not AbilityRunning
            TimeOfPreviousRock = tick()
            GetWorldMousePosition()
            fireRay()
            task.wait(CastingTime)
            AbilityRunning = not AbilityRunning

        end
    elseif AbilityName == "MonsterLeap" then
        
        local CastingTime = 2
        local AbilityCooldown = 5 + CastingTime
        if DebounceModule.Debounce(TimeOfPreviousLeap, AbilityCooldown) and DebounceModule.NoAbilityRunning(AbilityRunning) then
            
            AbilityRunning = not AbilityRunning
            TimeOfPreviousLeap = tick()
            game.ReplicatedStorage.AbilityFolder.LeapFolder.Leap:FireServer()
            wait(CastingTime)
            AbilityRunning = not AbilityRunning 

        end
    elseif AbilityName == "Attack1" then
        local Attack1Animation = Players.LocalPlayer.Character.AnimSaves:WaitForChild("Attack 1")
        Attack1Animation.AnimationId = "rbxassetid://15413449566"
        local humanoid = Players.LocalPlayer.Character:WaitForChild("Humanoid")

        if humanoid then 
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if animator then
                -- Unique syntax to run the animation
                local animationTrack = animator:LoadAnimation(Attack1Animation)
                animationTrack:Play()
                return animationTrack
            end
        end

    end
end

userInputService.InputBegan:Connect(function(input,gpe)
    -- detect client input
	if input.KeyCode == Enum.KeyCode.Three then
		FireAbility("RockThrow")
    elseif input.KeyCode == Enum.KeyCode.Four then
        FireAbility("FireBreath")
    elseif input.KeyCode == Enum.KeyCode.Space then
        FireAbility("MonsterLeap")
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then 
        -- FireAbility("Attack1")
	end
end)
