-- QueueSystem.lua
local QueueSystem = {}
QueueSystem.__index = QueueSystem

function QueueSystem.new(slotsFolder)
	local self = setmetatable({}, QueueSystem)

	self.slotsFolder = slotsFolder
	self.slots = {} -- Array que guarda los CLIENTS en cada posición
	self.slotParts = {} -- Array ordenado de las Parts de slots

	-- Cargar y ordenar los slots
	self:LoadSlots()

	-- Inicializar todos los slots como vacíos
	for i = 1, #self.slotParts do
		self.slots[i] = nil
	end

	print("✅ Sistema de cola de espera iniciado con " .. #self.slotParts .. " slots")

	return self
end

-- Carga y ordena los slots del folder
function QueueSystem:LoadSlots()
	local slotsList = {}

	-- Recopilar todos los slots
	for _, part in pairs(self.slotsFolder:GetChildren()) do
		if part:IsA("BasePart") then
			local slotNumber = tonumber(part.Name)
			if slotNumber then
				table.insert(slotsList, {number = slotNumber, part = part})
			end
		end
	end

	-- Ordenar por número
	table.sort(slotsList, function(a, b)
		return a.number < b.number
	end)

	-- Guardar en el array ordenado
	for _, slotData in ipairs(slotsList) do
		table.insert(self.slotParts, slotData.part)

		-- Configurar apariencia inicial
		slotData.part.BrickColor = BrickColor.new("Bright green")
		slotData.part.Material = Enum.Material.Neon
		slotData.part.Transparency = 0.99
	end

	if #self.slotParts == 0 then
		error("❌ No se encontraron slots en el folder! Asegúrate de que se llamen con números (1, 2, 3, etc)")
	end
end

-- Añade un CLIENT a la cola (no crea NPCs, solo los posiciona)
function QueueSystem:AddClient(client)
	-- Buscar el primer slot vacío
	local slotIndex = self:GetFirstEmptySlot()

	if not slotIndex then
	--	warn("⚠️ La sala de espera está llena!")
		return false
	end

	-- Obtener el slot donde va a posicionarse
	local slotPart = self.slotParts[slotIndex]

	-- ⭐ POSICIONAR EL CHAR DEL CLIENT EN EL SLOT
	local char = client.char
	local spawnPos = slotPart.Position

	if char.PrimaryPart then
		char:SetPrimaryPartCFrame(CFrame.new(spawnPos + Vector3.new(0,3,0 )))
	elseif char:FindFirstChild("HumanoidRootPart") then
		char.HumanoidRootPart.CFrame = CFrame.new(spawnPos + Vector3.new(0,3,0))
	end

	-- Cambiar color del slot para indicar que está ocupado
	slotPart.BrickColor = BrickColor.new("Really red")
	slotPart.Transparency = 0.99

	-- Guardar el CLIENT en el slot
	self.slots[slotIndex] = client

--	print("✅ Cliente '" .. char.Name .. "' en slot " .. slotIndex .. " de sala de espera")

	return true
end

-- Encuentra el primer slot vacío
function QueueSystem:GetFirstEmptySlot()
	for i = 1, #self.slotParts do
		if self.slots[i] == nil then
			return i
		end
	end
	return nil
end

-- Verifica si la cola está llena
function QueueSystem:IsFull()
	return self:GetFirstEmptySlot() == nil
end

-- Mueve un CLIENT a su slot
function QueueSystem:MoveClientToSlot(client, slotIndex)
	local slotPart = self.slotParts[slotIndex]
	if not slotPart then
		warn("⚠️ Slot " .. slotIndex .. " no existe!")
		return
	end

	local targetPos = slotPart.Position
	local char = client.char
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local rootPart = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart

	if humanoid and rootPart then
		-- Cambiar color del slot para indicar que está ocupado
		slotPart.BrickColor = BrickColor.new("Really red")
		slotPart.Transparency = 0.99

		humanoid:MoveTo(targetPos)

		-- Esperar a que llegue (asyncrónicamente)
		task.spawn(function()
			local timeout = 10
			local startTime = tick()

			while (rootPart.Position - targetPos).Magnitude > 2 do
				if tick() - startTime > timeout then
					--warn("⚠️ Cliente " .. char.Name .. " tardó mucho en llegar al slot " .. slotIndex)
					break
				end
				task.wait(0.1)
			end

		--	print("✅ " .. char.Name .. " llegó al slot " .. slotIndex)
		end)
	end
end

-- Obtiene el primer CLIENT de la cola (sin removerlo)
function QueueSystem:GetFirstClient()
	return self.slots[1]
end

-- Remueve el primer CLIENT y avanza la cola
function QueueSystem:RemoveFirst()
	if not self.slots[1] then
		warn("⚠️ No hay nadie en la sala de espera!")
		return nil
	end

	local firstClient = self.slots[1]

	--print("📋 Cliente " .. firstClient.char.Name .. " sale de sala de espera...")

	-- Avanzar la cola
	self:AdvanceQueue()

	return firstClient
end

-- Avanza toda la cola (el primero ya fue removido)
function QueueSystem:AdvanceQueue()
	--print("📋 Avanzando cola en sala de espera...")

	-- Crear un array temporal para reorganizar
	local tempSlots = {}

	-- Recopilar todos los CLIENTS que quedan (del 2 en adelante)
	for i = 2, #self.slotParts do
		if self.slots[i] ~= nil then
			table.insert(tempSlots, self.slots[i])
		end
	end

	-- Limpiar todos los slots
	for i = 1, #self.slotParts do
		self.slots[i] = nil

		-- Resetear colores
		if self.slotParts[i] then
			self.slotParts[i].BrickColor = BrickColor.new("Bright green")
			self.slotParts[i].Transparency = 0.99
		end
	end

	-- Reasignar CLIENTS a nuevos slots (todos avanzan una posición)
	for newIndex, client in ipairs(tempSlots) do
		self.slots[newIndex] = client

		-- Mover al nuevo slot
		self:MoveClientToSlot(client, newIndex)
	end

	--print("✅ Cola avanzada. Clientes en sala de espera: " .. #tempSlots)
end

-- Obtiene cuántos CLIENTS hay en la cola
function QueueSystem:GetQueueCount()
	local count = 0
	for i = 1, #self.slotParts do
		if self.slots[i] ~= nil then
			count = count + 1
		end
	end
	return count
end

-- Obtiene el máximo de slots
function QueueSystem:GetMaxSlots()
	return #self.slotParts
end

return QueueSystem