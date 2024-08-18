local laserRenderer = {}

local shotDuration = 0.15

function laserRenderer.createLaser(toolHandle, endPosition)
	local startPosition = toolHandle.Position
	local laserDistance = (endPosition - startPosition).magnitude
	
	-- getting the midpoint of a cframe
	local laserCFrame = CFrame.lookAt(startPosition, endPosition) * CFrame.new(0, 0, -laserDistance / 2)
	
	-- Create the laser and it's properties 
	local laserPart = Instance.new("Part")
	laserPart.Size = Vector3.new(0.2,0.2,laserDistance)
	laserPart.CFrame = laserCFrame
	laserPart.Anchored = true
	laserPart.CanCollide = false
	laserPart.Parent = workspace
	
	game.Debris:AddItem(laserPart, shotDuration)
	
	-- play the weapon's shooting sound for everyone in the server
	local shootingSound = toolHandle:FindFirstChild("Activated")
	if shootingSound then
		shootingSound:Play()
	end
end

return laserRenderer
