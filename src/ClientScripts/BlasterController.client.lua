local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local userInputService = game:GetService("UserInputService")
local laserRenderer = require(player.PlayerScripts:WaitForChild("LaserRenderer"))
local DebounceModule = require(game.ReplicatedStorage.ReplicatedModules.DebounceModule)
local contextActionService = game:GetService("ContextActionService")

local Blaster = script.Parent
local Bullets = Blaster:WaitForChild("Bullets")
local cooldown = .5
local lastIteration = 0

maxMouseDistance = 1000
maxLaserDistance = 500

local ReloadAction = "reloadWeapon"
local reloadAnimation = Blaster:WaitForChild("ReloadAnimation")
reloadAnimation.AnimationId = "rbxassetid://14373884395"

local function reload(char, animation)
	-- create a function to be binded to 
	local humanoid = char:WaitForChild("Humanoid")
	if humanoid then 
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if animator then
			-- Unique syntax to run the animation
			local animationTrack = animator:LoadAnimation(animation)
			animationTrack:Play()
			Bullets.Value = 6
			return animationTrack
		end
	end
end

local function onAction(actionName, inputState)
	
	-- call the reload function
	if actionName == ReloadAction and inputState == Enum.UserInputState.Begin then
		reload(character, reloadAnimation)
		Blaster.TextureId = "rbxassetid://6593020923"
		wait(2)
		Blaster.TextureId = "rbxassetid://92628145"
	end
end

local function onEquipped()
	contextActionService:BindAction(ReloadAction, onAction, true, Enum.KeyCode.R)
	Blaster.Handle:FindFirstChild("Equipped"):Play()
end

local function unEquipped()
	contextActionService:UnbindAction(ReloadAction)
end

local function GetWorldMousePosition()
	local mouseLocation = userInputService:GetMouseLocation()

	-- still a bit confusing
	local screenToWorldRay = workspace.CurrentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local directionVector = screenToWorldRay.Direction * maxMouseDistance

	local raycastResult = workspace:Raycast(screenToWorldRay.Origin, directionVector)

	if raycastResult then  
		return raycastResult.Position
	else
		return screenToWorldRay.Origin + screenToWorldRay.Direction
	end
end

local function fireWeapon()
	local mouseLocation = GetWorldMousePosition()

	-- the problem is somewhere here.
	local targetLocation = (mouseLocation - Blaster.Handle.Position).Unit
	local directionVector = targetLocation * maxLaserDistance

	local weaponRaycastParams = RaycastParams.new()
	weaponRaycastParams.FilterDescendantsInstances = {player.Character}
	local weaponRaycastResult = workspace:Raycast(Blaster.Handle.Position, directionVector, weaponRaycastParams)

	local hitPosition
	if weaponRaycastResult then
		hitPosition = weaponRaycastResult.Position

		-- If a humanoid is found in the model then it's likely a player's character
		local characterModel = weaponRaycastResult.Instance:FindFirstAncestorOfClass("Model")
		if characterModel then
			local humanoid = characterModel:FindFirstChild("Humanoid")
			if humanoid then
				print("Player hit")
				game.ReplicatedStorage.BlasterEvents.DamageCharacter:FireServer(characterModel, hitPosition)
			end
		end

	else
		hitPosition = Blaster.Handle.Position + directionVector
	end

	-- create a laser on the player's client, as well as on everyone else's client
	game.ReplicatedStorage.BlasterEvents.LaserFired:FireServer(hitPosition)
	laserRenderer.createLaser(Blaster.Handle, hitPosition)
end

local function OnActivation()
	if DebounceModule.Debounce(lastIteration,cooldown) then
		if Bullets.Value > 0 then
			fireWeapon()
			lastIteration = tick()
			Bullets.Value = Bullets.Value - 1
		else
			print("Out of Bullets")
		end
	end
end

Blaster.Equipped:Connect(onEquipped)
Blaster.Unequipped:Connect(unEquipped)
Blaster.Activated:Connect(OnActivation)

