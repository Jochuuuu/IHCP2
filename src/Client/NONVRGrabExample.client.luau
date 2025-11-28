local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local RemoteEvent = ReplicatedStorage:WaitForChild("MoveObjectEvent")

-- Configuración
local GRAB_DISTANCE = 5
local HOLD_DISTANCE = 1.85
local UPDATE_RATE = 0.2 -- Actualizar cada 0.2 segundos (5 veces por segundo)

-- Variables de estado
local grabbedPart = nil
local isGrabbing = false
local updateTimer = 0

-- Carpeta de objetos agarrables
local GrabPartsFolder = Workspace:WaitForChild("GrabParts")

-- Helper: Obtener posición y dirección de la cámara
local function getCameraRay()
	local camera = Workspace.CurrentCamera
	return camera.CFrame.Position, camera.CFrame.LookVector
end

-- Verificar si un objeto está en GrabParts
local function isGrabbable(part)
	if not part or not part:IsA("BasePart") or part.Anchored then
		return false
	end

	-- Verificar que esté dentro de GrabParts
	return part:IsDescendantOf(GrabPartsFolder)
end

-- Encontrar parte por raycast
local function findNearbyPart()
	local origin, direction = getCameraRay()
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.IgnoreWater = true

	local raycastResult = Workspace:Raycast(origin, direction * GRAB_DISTANCE, raycastParams)

	if raycastResult and raycastResult.Instance then
		local hitPart = raycastResult.Instance
		-- Verificar que sea agarrable
		if isGrabbable(hitPart) then
			return hitPart, raycastResult.Position
		end
	end
	return nil, nil
end

-- Input: Mouse button para agarrar
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if not grabbedPart then
			local part, hitPos = findNearbyPart()
			if part then
				grabbedPart = part
				isGrabbing = true
				part:SetAttribute("Grabbing", true)  -- Marcar como agarrado

				-- Notificar al servidor que empezamos a agarrar
				RemoteEvent:FireServer("Grab", grabbedPart)
			end
		end
	end
end)

-- Input: Soltar con mouse button
UserInputService.InputEnded:Connect(function(input, processed)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if grabbedPart then
			-- Enviar posición final al servidor
			grabbedPart:SetAttribute("Grabbing", false)  -- Marcar como soltado
			RemoteEvent:FireServer("Release", grabbedPart, grabbedPart.CFrame)
		end
		grabbedPart = nil
		isGrabbing = false
		updateTimer = 0
	end
end)

-- Actualizar posición del objeto (con updates periódicos al servidor)
RunService.RenderStepped:Connect(function(deltaTime)
	if grabbedPart and isGrabbing then
		updateTimer += deltaTime

		-- Seguir el mouse a distancia específica
		local origin, direction = getCameraRay()
		local targetPos = origin + direction * HOLD_DISTANCE
		local newCFrame = CFrame.new(targetPos)

		-- Mover localmente (el cliente ve el movimiento inmediato)
		grabbedPart.CFrame = newCFrame

		-- Enviar actualización al servidor periódicamente
		if updateTimer >= UPDATE_RATE then
			RemoteEvent:FireServer("Update", grabbedPart, newCFrame)
			updateTimer = 0
		end
	end
end)

print("Grab system initialized (Non-VR only)")
print("Grab Distance:", GRAB_DISTANCE, "studs")
print("Hold Distance:", HOLD_DISTANCE, "studs")
print("Update Rate:", UPDATE_RATE, "seconds")