 
local PathfindingService = game:GetService("PathfindingService")
local workspace = game.Workspace

local PathVisualizer = {}

local WAYPOINT_FOLDER_NAME = "DebugWaypoints"

local function clearWaypoints()
	local folder = workspace:FindFirstChild(WAYPOINT_FOLDER_NAME)
	if folder then
		folder:Destroy()
	end
end

local function getWaypointFolder()
	local folder = workspace:FindFirstChild(WAYPOINT_FOLDER_NAME)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = WAYPOINT_FOLDER_NAME
		folder.Parent = workspace
	end
	return folder
end

local function createWaypoint(position, index)
	local folder = getWaypointFolder()

	local part = Instance.new("Part")
	part.Name = "WP_" .. index
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(0.8, 0.8, 0.8)
	part.Shape = Enum.PartType.Ball
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(85, 111, 255) -- verde
	part.Position = position + Vector3.new(0, 1.5, 0)
	part.Parent = folder
end

-- 🔹 Función pública del módulo
function PathVisualizer.ShowPath(startPart, endPart, agentConfig)
	clearWaypoints()

	if not startPart or not endPart then
		warn("Falta startPart o endPart.")
		return
	end

	if not startPart.Position or not endPart.Position then
		warn("startPart o endPart no son partes válidas.")
		return
	end

	-- Config del agente (puedes pasar una tabla opcional)
	agentConfig = agentConfig or {
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		Costs = {
			Blacklisted = math.huge  
		}
	}
	
	local blacklistModel = workspace:WaitForChild("Dec"):WaitForChild("Automatic glass door")
	if blacklistModel then
		local modifier = blacklistModel:FindFirstChildOfClass("PathfindingModifier")
		if not modifier then
			modifier = Instance.new("PathfindingModifier")
			modifier.Parent = blacklistModel
		end
		modifier.Label = "Blacklisted"
	end
	
	local path = PathfindingService:CreatePath(agentConfig)

	path:ComputeAsync(startPart.Position, endPart.Position)

	if path.Status ~= Enum.PathStatus.Success then
		warn("No se pudo calcular el path. Status:", path.Status)
		return
	end

	local waypoints = path:GetWaypoints()
	for i, waypoint in ipairs(waypoints) do
		createWaypoint(waypoint.Position, i)
	end
end

-- Opcional: si quieres limpiar desde fuera
function PathVisualizer.Clear()
	clearWaypoints()
end

return PathVisualizer
