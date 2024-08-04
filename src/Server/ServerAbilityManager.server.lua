---@diagnostic disable: trailing-space
local replicatedStorage = game.ReplicatedStorage
Bezier = require(replicatedStorage.Shared.BezierModule)
local Debris = game:GetService("Debris")
local rand = Random.new()

local function ChangePlayerMovement(player, speed)
	-- given a player, number, and boolean, restrict the player's movement
	
	assert(typeof(speed) == "number","Pass a number")

	local character = player.character or player.CharacterAdded:wait()
	local humanoid = character:FindFirstChild("Humanoid")

	humanoid.WalkSpeed = speed

end

local function DamageFunc(part, Hitbox, damage)
	-- damage any other players who touch the ability

	if part.Parent and part.Parent:FindFirstChild("Humanoid") then
		part.Parent.Humanoid:TakeDamage(damage)
	end

end

local function FireBreathFunc(player)
	-- I'll attempt to fire multiple orbs in the orientation of the player instead,
	-- this will likely require raycasting
	-- I'll eventually need to disable the default roblox animations.
	ChangePlayerMovement(player, 5)

	local character = player.Character or player.CharacterAdded:wait()
	local head = character.Head
	local damage = 10

	for i = 1, 20, 1 do 
		local fireball = replicatedStorage.AbilityFolder.FireBreathFolder.Sphere:clone()
		fireball.Parent = game.Workspace
		fireball.Anchored = true
	
		local offset = Vector3.new(0,0,-5)
		fireball:PivotTo(head.CFrame * CFrame.new(offset))

		local linearVelocity = Instance.new("LinearVelocity", fireball)
		local attachment = Instance.new("Attachment", fireball)
		
		linearVelocity.Name = "Throw"
		linearVelocity.Attachment0 = attachment
		linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
		linearVelocity.MaxForce = 10000
		linearVelocity.VectorVelocity = Vector3.new(rand.NextInteger(rand, -1,1),rand.NextInteger(rand, -1,1),-30)
		fireball.Anchored = false

		fireball.Touched:Connect(function(otherPart)
			
			DamageFunc(otherPart, fireball, 5)
			if not otherPart:IsDescendantOf(character) then
				fireball:Destroy()
			end
		
		end)
		
		

		Debris:AddItem(fireball, 7.5)
		task.wait(0.25)
	end
	
	
	-- cleanup 
	ChangePlayerMovement(player, 16)
end

replicatedStorage.AbilityFolder.FireBreathFolder.FireBreath.OnServerEvent:Connect(FireBreathFunc)