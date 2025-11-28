local PhysicsService = game:GetService("PhysicsService")


local function setModelToNPC(model)
	--ensureNPCGroup()
	for i, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(descendant, "NPC")
		end
	end
end


local module = {}

function module.random()
	
	local replicated = game:GetService("ReplicatedStorage")
	local avatares = replicated:FindFirstChild("Avatares"):GetChildren()
	
	local clon = avatares[math.random(1,#avatares)]:Clone()

setModelToNPC(clon)
	
	return clon
	
	
end


return module
