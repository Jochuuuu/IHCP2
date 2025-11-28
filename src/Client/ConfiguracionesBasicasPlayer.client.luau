-- Example code for a LocalScript
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
 

delay(5,function()
	
	local configf = workspace:WaitForChild("GameConfigParts")
	local barreraslcoal = configf:WaitForChild("BarrerasLocal")
	local barriersnpc = workspace:WaitForChild("Barriers")
	local plats = workspace:WaitForChild("Plats")

	for _,p in pairs(barreraslcoal:GetChildren()) do
		if p:IsA("BasePart") then
			p.CanCollide = true
		end
	end
	
	for _,p in pairs(barriersnpc:GetDescendants()) do
		if p:IsA("BasePart") then
			p.CanCollide = false
		end
	end
	
	for _,p in pairs(plats:GetChildren()) do
		if p:IsA("Seat") then
			p.CanTouch = false
		end
	end



end)
 