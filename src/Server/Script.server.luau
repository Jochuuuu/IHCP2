local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Crear RemoteEvent
local RemoteEvent = Instance.new("RemoteEvent")
RemoteEvent.Name = "MoveObjectEvent"
RemoteEvent.Parent = ReplicatedStorage

-- Carpeta de objetos agarrables
local GrabPartsFolder = Workspace:WaitForChild("GrabParts")

-- Tabla para trackear quién está agarrando qué
local grabbedObjects = {}

-- Validar que el objeto es agarrable
local function isGrabbable(part)
	if not part or not part:IsA("BasePart") or part.Anchored then
		return false
	end

	-- Verificar que esté dentro de GrabParts
	return part:IsDescendantOf(GrabPartsFolder)
end

-- Validar distancia (anti-exploit)
local function isValidDistance(player, part, maxDistance)
	local character = player.Character
	if not character or not character.PrimaryPart then
		return false
	end

	local distance = (part.Position - character.PrimaryPart.Position).Magnitude
	return distance <= maxDistance
end

RemoteEvent.OnServerEvent:Connect(function(player, action, part, newCFrame)
	-- Validación básica
	if not isGrabbable(part) then
		warn(player.Name, "tried to grab invalid object:", part)
		return
	end

	-- Anti-exploit: verificar distancia razonable
	if not isValidDistance(player, part, 50) then
		warn(player.Name, "object too far away")
		return
	end

	if action == "Grab" then
		-- Registrar que este jugador está agarrando el objeto
		if not grabbedObjects[part] then
			grabbedObjects[part] = player
			part:SetAttribute("Grabbing", true)  -- ← Confirmar en servidor
			print(player.Name, "grabbed", part.Name)
		else
			-- Otro jugador ya tiene este objeto
			warn(player.Name, "tried to grab", part.Name, "but", grabbedObjects[part].Name, "already has it")
		end

	elseif action == "Update" then
		-- Verificar que este jugador tiene ownership del objeto
		if grabbedObjects[part] == player then
			-- Actualizar posición en el servidor
			part.CFrame = newCFrame
			
			part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)  -- Detener velocidad lineal
			part.AssemblyAngularVelocity = Vector3.new(0, 0, 0) -- Detener rotación

			
		else
			warn(player.Name, "tried to update", part.Name, "but doesn't own it")
		end

	elseif action == "Release" then
		-- Liberar el objeto y actualizar posición final
		if grabbedObjects[part] == player then
			part.CFrame = newCFrame
			grabbedObjects[part] = nil
			part:SetAttribute("Grabbing", false)  -- ← Marcar como libre
		--	print(player.Name, "released", part.Name)
		else
			warn(player.Name, "tried to release", part.Name, "but doesn't own it")
		end
	end
end)

-- Limpiar referencias si un jugador se va
game.Players.PlayerRemoving:Connect(function(player)
	for part, owner in pairs(grabbedObjects) do
		if owner == player then
			grabbedObjects[part] = nil
			print("Cleared", part.Name, "from", player.Name, "who left")
		end
	end
end)
 