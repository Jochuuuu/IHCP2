local VRService = game:GetService("VRService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

VRService.AvatarGestures = true

local LocalPlayer = game.Players.LocalPlayer
local RemoteEvent = ReplicatedStorage:WaitForChild("MoveObjectEvent")

-- Which hand to use ("RightHand" or "LeftHand")
local HAND = Enum.UserCFrame.RightHand

-- Distance threshold for grabbing
local GRAB_DISTANCE = 2

-- Update rate configuration
local UPDATE_RATE = 0.2 -- Actualizar cada 0.2 segundos (5 veces por segundo)

-- Track currently grabbed part
local grabbedPart = nil
local updateTimer = 0
local GrabParts = Workspace:WaitForChild("GrabParts") -- AGREGAR ESTA LÍNEA

-- Helper to get hand world position
local function getHandPosition()
	local camera = Workspace.CurrentCamera
	local handCFrame = camera.CFrame * VRService:GetUserCFrame(HAND)
	return handCFrame.Position
end

-- Find nearest unanchored part within GRAB_DISTANCE
local function findNearbyPart()
	local handPos = getHandPosition()
	local closestPart = nil
	local closestDist = GRAB_DISTANCE
	for _, obj in GrabParts:GetChildren() do
		if obj:IsA("BasePart") and not obj.Anchored then
			local dist = (obj.Position - handPos).Magnitude
			if dist < closestDist then
				closestDist = dist
				closestPart = obj
			end
		end
	end
	return closestPart
end

-- Helper to set grab gesture
local function setGrabGesture(enabled)
	-- Only works if AvatarGestures is true
	VRService:SetAvatarGestureEnabled(Enum.VRAvatarGesture.Grab, enabled)
end

-- Listen for grip button to grab/release
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.ButtonR2 then -- Right grip button
		if not grabbedPart then
			local part = findNearbyPart()
			if part then
				grabbedPart = part
				setGrabGesture(true) -- Enable grab gesture

				-- Notificar al servidor que empezamos a agarrar
				RemoteEvent:FireServer("Grab", grabbedPart)
			end
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, processed)
	if input.KeyCode == Enum.KeyCode.ButtonR2 then
		if grabbedPart then
			-- Enviar posición final al servidor
			RemoteEvent:FireServer("Release", grabbedPart, grabbedPart.CFrame)
		end
		grabbedPart = nil
		updateTimer = 0
		setGrabGesture(false) -- Disable grab gesture
	end
end)

-- Update grabbed part position to follow hand
RunService.RenderStepped:Connect(function(deltaTime)
	if grabbedPart then
		updateTimer += deltaTime

		local handPos = getHandPosition()
		local newCFrame = CFrame.new(handPos)

		-- Mover localmente (el cliente ve el movimiento inmediato)
		grabbedPart.CFrame = newCFrame

		-- Enviar actualización al servidor periódicamente
		if updateTimer >= UPDATE_RATE then
			RemoteEvent:FireServer("Update", grabbedPart, newCFrame)
			updateTimer = 0
		end
	end
end)

print("VR Grab system initialized")
print("Update Rate:", UPDATE_RATE, "seconds")

--[[

local VRService = game:GetService("VRService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

VRService.AvatarGestures = true

local LocalPlayer = game.Players.LocalPlayer

-- Which hand to use ("RightHand" or "LeftHand")
local HAND = Enum.UserCFrame.RightHand

-- Distance threshold for grabbing
local GRAB_DISTANCE = 2

-- Track currently grabbed part
local grabbedPart = nil

-- Helper to get hand world position
local function getHandPosition()
	local camera = Workspace.CurrentCamera
	local handCFrame = camera.CFrame * VRService:GetUserCFrame(HAND)
	return handCFrame.Position
end

-- Find nearest unanchored part within GRAB_DISTANCE
local function findNearbyPart()
	local handPos = getHandPosition()
	local closestPart = nil
	local closestDist = GRAB_DISTANCE
	for _, obj in Workspace:GetChildren() do
		if obj:IsA("BasePart") and not obj.Anchored then
			local dist = (obj.Position - handPos).Magnitude
			if dist < closestDist then
				closestDist = dist
				closestPart = obj
			end
		end
	end
	return closestPart
end

-- Helper to set grab gesture
local function setGrabGesture(enabled)
	-- Only works if AvatarGestures is true
	VRService:SetAvatarGestureEnabled(Enum.VRAvatarGesture.Grab, enabled)
end

-- Listen for grip button to grab/release
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.ButtonR2 then -- Right grip button
		if not grabbedPart then
			local part = findNearbyPart()
			if part then
				grabbedPart = part
				setGrabGesture(true) -- Enable grab gesture
			end
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, processed)
	if input.KeyCode == Enum.KeyCode.ButtonR2 then
		grabbedPart = nil
		setGrabGesture(false) -- Disable grab gesture
	end
end)

-- Update grabbed part position to follow hand
game:GetService("RunService").RenderStepped:Connect(function()
	if grabbedPart then
		local handPos = getHandPosition()
		grabbedPart.CFrame = CFrame.new(handPos)
	end
end)



]]
