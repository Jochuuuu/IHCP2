local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Structures = ReplicatedStorage:WaitForChild("Structures")
local StartEvent = ReplicatedStorage:WaitForChild("START")
local GameModule = require(script.Parent.Game)
local Eventos = ReplicatedStorage:WaitForChild("Eventos")

local GuideEvent = Eventos:WaitForChild("Guide")

  local gameStarted = ReplicatedStorage:WaitForChild("STARTEDGAME")
local currentGame = GameModule.new()

StartEvent.OnServerEvent:Connect(function(player)
	if gameStarted.Value then
		warn("Game already started!")
		return
	end

	local workers = game.Players:GetPlayers()
	currentGame.workers = workers
	currentGame:start()
	gameStarted.Value = true

end)

GuideEvent.OnServerEvent:Connect(function(player, datos)
 

	if datos.mode == "ENTREGAR" then
		currentGame:EntregarCliente(player, datos)
	end
end)


-- Agregar/remover workers dinámicamente
game.Players.PlayerAdded:Connect(function(player)
	if currentGame and gameStarted.Value then
		currentGame:addWorker(player)
	end
end)

game.Players.PlayerRemoving:Connect(function(player)
	if currentGame and gameStarted.Value then
		currentGame:removeWorker(player)
	end
end)