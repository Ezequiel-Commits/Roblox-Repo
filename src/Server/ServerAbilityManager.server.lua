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
		linearVelocity.VectorVelocity = Vector3.new(rand.NextInteger(rand, -2,2),rand.NextInteger(rand, -2,2),-30)
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

local function RockThrowFunc(player)

	local character = player.Character or player.CharacterAdded:wait()
	local head = character.Head

	ChangePlayerMovement(player, 5)

	local rockStart = replicatedStorage.AbilityFolder.RockThrowFolder.rockStart:Clone()
	rockStart.Parent = game.Workspace
	local rockEnd = replicatedStorage.AbilityFolder.RockThrowFolder.rockEnd:Clone()
	rockEnd.Parent = game.Workspace
	
	local offset1 = Vector3.new(-1,3,0)
	rockStart:PivotTo(head.CFrame * CFrame.new(offset1))
	
	local offset2 = Vector3.new(-1,3,-30)
	rockEnd:PivotTo(head.CFrame * CFrame.new(offset2))
	
	local position1 = rockStart.Position
	local position2 = rockEnd.Position
	local direction = position2 - position1
	print(position1, position2)
	print(direction)

	
	local duration = math.log(1.001 + direction.Magnitude * 0.01)
	local force = direction / duration + Vector3.new(0, game.Workspace.Gravity * duration * 0.5, 0)
	
	local rock = replicatedStorage.AbilityFolder.RockThrowFolder.Rock.Part:Clone()
	rock.Parent = game.Workspace
	rock.Position = position1
	rock:ApplyImpulse(force * rock.AssemblyMass)
	
	rock.Touched:Connect(function(otherPart)
		
		print(otherPart)
		DamageFunc(otherPart, rock, 30)
		if not otherPart:IsDescendantOf(character) then
			rock:Destroy()
			rock = nil
		end
		
	end)
	
	
	Debris:AddItem(rockStart, 7.5)
	Debris:AddItem(rockEnd, 7.5)
	Debris:AddItem(rock, 7.5)
	ChangePlayerMovement(player, 16)
end

local function BezierFunc(player)
	local character = player.character or player.characterAdded:wait()
	local HumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local workspace = game.Workspace

	local Point0 = Instance.new("Part")
	local Point1 = Instance.new("Part")
	local Point2 = Instance.new("Part")
	local Point3 = Instance.new("Part")

	Point0.Name = "p0"
	Point1.Name = "p1"
	Point2.Name = "p2"
	Point3.Name = "p3"

	Point0.Parent = workspace
	Point1.Parent = workspace
	Point2.Parent = workspace
	Point3.Parent = workspace

	Point0.Transparency = 1
	Point1.Transparency = 1
	Point2.Transparency = 1
	Point3.Transparency = 1

	-- find the numbers that work for the rock throw functin
	local Point0Position  = Vector3.new(0,0, -2*2)
	local Point1Position  = Vector3.new(0,8*2, -8.5*2)
	local Point2Position  = Vector3.new(0,8*2, -16*2)
	local Point3Position  = Vector3.new(0,0, -23.5*2)

	-- the points lag begind the player a bit; how could I fix this? 
	Point0.CFrame = CFrame.new(HumanoidRootPart.CFrame * Point0Position)
	Point1.CFrame = CFrame.new(HumanoidRootPart.CFrame * Point1Position)
	Point2.CFrame = CFrame.new(HumanoidRootPart.CFrame * Point2Position)
	Point3.CFrame = CFrame.new(HumanoidRootPart.CFrame * Point3Position)

	Debris:AddItem(Point0, 2)
	Debris:AddItem(Point1, 2)
	Debris:AddItem(Point2, 2)
	Debris:AddItem(Point3, 2)

	-- create the bezier curve
	local p0pos = workspace.p0.Position
	local p1pos = workspace.p1.Position
	local p2pos = workspace.p2.Position
	local p3pos = workspace.p3.Position

	local markerTemplate = Instance.new("Part")
	markerTemplate.Parent = game.ServerStorage

	local curve = Bezier.newCurve(20, p0pos, p1pos, p2pos, p3pos)

	for t = 0, 1, 0.1 do
		-- create a for loop with "t" to visualze the bezier curve and tween the player 

		local marker = markerTemplate:Clone()
		
		marker.Position = curve:CalcT(t)
		marker.Parent = workspace
		marker.Transparency = 1
	end
end

replicatedStorage.AbilityFolder.FireBreathFolder.FireBreath.OnServerEvent:Connect(FireBreathFunc)
replicatedStorage.AbilityFolder.RockThrowFolder.RockThrow.OnServerEvent:Connect(RockThrowFunc)