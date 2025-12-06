local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Structures = ReplicatedStorage:WaitForChild("Structures")
local queue = require(Structures:WaitForChild("Queue"))
local Client = require(Structures:WaitForChild("Client"))
local RandomSet = require(Structures:WaitForChild("RandomSet"))
local PathfindingModule = require(script.Parent.PathfindingModule)
local tw = game:GetService("TweenService")
local y_botones_ini,y_botones_fi = -2,5.5
local y_exclama_ini,y_exclama_fi = -1.23,6.167
local QueueSystem = require(script.QueueSystem)
local randomavatar = require(script.RandomAvatar)
local GameFolder = workspace:WaitForChild("Game")
local Eventos = ReplicatedStorage:WaitForChild("Eventos")
local GuideEvent = Eventos:WaitForChild("Guide")
local LuzPart =require(Structures:WaitForChild("Luz"))
local resumenpart = GameFolder:WaitForChild("Resumen")

local Game = {}
Game.__index = Game

function Game.new(workers)
	local self = setmetatable({}, Game)

	-- Array de workers (players)
	self.workers = workers or {}
 	self.currentDay = 1
	self.clientQueue = queue.new({ mode = "max" })
	self.clientCounter = 0
	self.set = RandomSet.new()
	self.luces = {}

	local lucesFolder = workspace:FindFirstChild("Luces")
	if lucesFolder then
		for _, part in pairs(lucesFolder:GetChildren()) do
			if part:IsA("BasePart") then
				table.insert(self.luces, LuzPart.new(part, true))  
			end
		end
  	end
	
	for i = 1, 7 do
		self.set:insert(i)
	end
	
	self.Modulos = {
		{},{},{}
	}
	
	resumenpart.Position = Vector3.new(-19.83, -5, 8.276)
	
	local grabfolder = workspace:FindFirstChild("GrabParts")
	
 
	-- Valores base (Día 1)
	self.baseClientSpawnInterval = 40  -- 20 segundos entre clientes
	self.baseDayDuration = 250         -- 5 minutos (300s)
	self.baseIntermissionTime = 50     -- 1 minuto

	-- Límites mínimos (no puede bajar más de esto)
	self.minClientSpawnInterval = 8   -- Mínimo 8 segundos entre clientes
	self.minDayDuration = 180          -- Mínimo 3 minutos
	self.minIntermissionTime = 30      -- Mínimo 30 segundos

	self.spawnIntervalDecrease = 2     -- Reduce 2 segundos por día
	self.dayDurationIncrease = 30      -- Aumenta 30 segundos por día

	-- Control del juego
	self.isRunning = false
	self.clientSpawnInterval = 40  -- Tiempo base entre clientes
	self.dayDuration = 250      -- 5 minutos por día
	self.intermissionTime = 50     -- 1 minuto de intermisión
	self.Intermission = true
	self.queueSystem= QueueSystem.new(workspace.Ticket.Paths)
	self.dayClientsSpawned = 0
	self.dayClientsAttended = 0
	
	self.dayChipsEntregados = 0
	self.dayInformesEntregados = 0
	self.dayDerivacionesEntregadas = 0
	
	return self
end


-- ✅ NUEVA FUNCIÓN: Calcular dificultad según el día
function Game:UpdateDifficultyForDay()
	-- Calcular nuevo intervalo de spawn (más rápido cada día)
	local newSpawnInterval = self.baseClientSpawnInterval - ((self.currentDay - 1) * self.spawnIntervalDecrease)
	self.clientSpawnInterval = math.max(newSpawnInterval, self.minClientSpawnInterval)

	-- Calcular nueva duración del día (más largo cada día)
	local newDayDuration = self.baseDayDuration + ((self.currentDay - 1) * self.dayDurationIncrease)
	self.dayDuration = math.max(newDayDuration, self.minDayDuration)

	-- Intermisión se mantiene constante (o puedes variarla también)
	-- self.intermissionTime = self.baseIntermissionTime

	print("🎚️  DIFICULTAD DÍA " .. self.currentDay)
	print("   ⏱️  Duración día: " .. self.dayDuration .. "s")
	print("   🔄 Spawn cada: " .. string.format("%.1f", self.clientSpawnInterval) .. "s")
	print("   📊 Clientes estimados: ~" .. math.floor(self.dayDuration / self.clientSpawnInterval))
end


function Game:ApagarLuces()
	for _, luz in pairs(self.luces) do
		luz:Apagar()
	end
end

function Game:EncenderLuces()
	for _, luz in pairs(self.luces) do
		luz:Encender()
	end
end

function Game:ToggleLuces()
	for _, luz in pairs(self.luces) do
		luz:Toggle()
	end
end

function Game:GetAvalaibleModule(numbers)
	
	local puestos = {1,2,3}
	local resultados = {}
	
	local r
	while #puestos > 1 do
		r = math.random(1,#puestos)

		if 	self.Modulos[r][1] == nil    then
			
			table.insert(resultados,puestos[r])
			
			if #resultados >= numbers then
				
				break
			end
			
		else 
			table.remove(puestos,r)
		end
	end
	
	if numbers == 1 then return resultados[1] end
	
	return resultados
end


function Game:Takeseat(char,num)
	
	local encontrar_waypoints_manuales = workspace.PathsCon:FindFirstChild("Inicido-"..num)
	if not encontrar_waypoints_manuales then encontrar_waypoints_manuales = workspace.Plats:FindFirstChild("Seat"..num) end 
	PathfindingModule.MoveTo(char, encontrar_waypoints_manuales)

	
end



function Game:spawnClients()
	self.spawnClientsActive = true
	while self.isRunning and (not self.Intermission) do
		local spawnInterval = self:getClientSpawnInterval()

		if self.queueSystem:IsFull() then
 			task.wait(1)
			continue  
		end
		
		-- Crear y añadir cliente a la cola
		self.clientCounter = self.clientCounter + 1
		self.dayClientsSpawned = self.dayClientsSpawned + 1  

		local char = randomavatar.random() 
		char.Parent = workspace
		char.PrimaryPart.CFrame = workspace.npcspawn.CFrame

		local nose = Instance.new("BoolValue")
		nose.Name = "C-" .. self.clientCounter
 		local newClient = Client.new()
		newClient.char = char
		newClient.tag = nose
  
		--print("🧑 Cliente #" .. self.clientCounter .. " añadido a la cola")
		--print("📊 Clientes en cola: " .. self.clientQueue:size())
		

		self.queueSystem:AddClient(newClient)

	--print("🧑 Cliente #" .. self.clientCounter .. " añadido a sala de espera")
		--print("📊 Clientes esperando asiento: " .. self.queueSystem:GetQueueCount())
		
		
		self:PushNext()
		
		-- Esperar el intervalo antes del siguiente spawn
		task.wait(spawnInterval)
	end
	
end

function Game:StartSpawnClients()
	if self.spawnClientsActive then
		warn("Ya hay un sistema de spawn activo")
		return
	end

	print("▶️ Iniciando sistema de spawn de clientes...")
	self.clientSpawnThread = task.spawn(function()
		self:spawnClients()
	end)
end

function Game:StopSpawningClients()
	self.spawnClientsActive = false
	if self.clientSpawnThread then
		task.cancel(self.clientSpawnThread)
	end
end


local function tipoTexto(label,textoCompleto)
	for i = 1, #textoCompleto do
		label.Text = textoCompleto:sub(1, i)

		wait(.06)
	end
end

function Game:PushNext()
	
	if not self.set:isEmpty() then
		local newClient = self.queueSystem:GetFirstClient()
		if newClient then
			self.clientQueue:push(newClient)
			newClient.tag.Parent = game.ReplicatedStorage.Fila
 GameFolder.TicketMachine.Audio:Play()
			local random = self.set:popRandom()
			newClient.asiento = random
			self.queueSystem:RemoveFirst()
			spawn(function()
				self:Takeseat(newClient.char,random)
			end)

		end

	end
	
end

function Game:AtenderCliente(player,num)
	
	local cli = self.clientQueue:pop()
	--print("ahora es ", self.clientQueue)
--	print("cliente es ", cli, "?")

	local numero = cli.asiento 

	self.set:insert(numero)
	
	self:PushNext()

	
	local resultado,mensaje = PathfindingModule.MoveTo(cli.char, workspace.Plats:FindFirstChild(num),1)
	
	
	if resultado then
		
		cli:Wave()
		local clonchat = ReplicatedStorage.Chat:Clone()
		clonchat.text.GA.Text.Text = " "
		clonchat.CFrame = cli.char.Head.CFrame * CFrame.new(-.85,1.5,0)
		clonchat.Transparency = 1
		clonchat.Parent = workspace
		
		tw:Create(clonchat,TweenInfo.new(.2
			,Enum.EasingStyle.Linear),{Transparency = 0.6 }):Play()
		
		task.wait(.2)
		
		local opciones = {"CHIP","INFORME","DERIVACION"}
		local textolist =  {"Quiero un chip", "Quiero hacer un informe",
			"Ya tengo mi informe, ¿Con quién tengo que hablar?"

		}
		local opcion =  math.random(1,2)
		tipoTexto(clonchat.text.GA.Text,textolist[opcion])
		cli.chat = clonchat
 		GuideEvent:FireClient(player,"Options",
			{num,opciones[opcion],true,cli})
		
	--[[
	
	local errorb = GameFolder.Modulos["Modulo"..num].Error
		local activarb = GameFolder.Modulos["Modulo"..num].Activar

		local t_ = tw:Create(errorb,TweenInfo.new(.6
			,Enum.EasingStyle.Linear),{Position = Vector3.new(errorb.Position.X,y_botones_fi,errorb.Position.Z) })
		local t_2 = tw:Create(activarb,TweenInfo.new(.6
			,Enum.EasingStyle.Linear),{Position = Vector3.new(activarb.Position.X,y_botones_fi,activarb.Position.Z) })
		t_:Play()
		t_2:Play()
		
		
		local cdError = Instance.new("ClickDetector")
		cdError.Parent = errorb

		local cdActivar = Instance.new("ClickDetector")
		cdActivar.Parent = activarb
		
		local conexionError
		local conexionActivar
		
		
		local function limpiarClicks(bot)
			
			clonchat:Destroy()

			
			tw:Create(bot.SurfaceGui.Frame,TweenInfo.new(.2
				,Enum.EasingStyle.Linear),{Transparency = 1 }):Play()

			tw:Create(bot,TweenInfo.new(.2
				,Enum.EasingStyle.Linear),{Transparency = 0 }):Play()

			---------------------------------
			task.wait(.8)
			
			tw:Create(errorb,TweenInfo.new(.5
				,Enum.EasingStyle.Linear),{Position = Vector3.new(errorb.Position.X,
					y_botones_ini,errorb.Position.Z) }):Play()
			
			tw:Create(activarb,TweenInfo.new(.5
				,Enum.EasingStyle.Linear),{Position = Vector3.new(activarb.Position.X,
					y_botones_ini,activarb.Position.Z) }):Play()
			
			
			
			-----------------------------
			
			task.wait(.49)
			bot.SurfaceGui.Frame.Transparency = 0.3
			bot.Transparency = 1
			cli.tag:Destroy()
			

			self.Modulos[tonumber(num)] = {}
			cli.char:Destroy()
			
			

			self:PushNext()



			
			if conexionError then
				conexionError:Disconnect()
			end
			if conexionActivar then
				conexionActivar:Disconnect()
			end
			if cdError then
				cdError:Destroy()
			end
			if cdActivar then
				cdActivar:Destroy()
			end
			
			
			
		end
		
		conexionError = cdError.MouseClick:Connect(function(player)
  
			limpiarClicks(errorb)  
		end)

 		conexionActivar = cdActivar.MouseClick:Connect(function(player)
  
			limpiarClicks(activarb)  
		end)
		
		
		
		
	]]
		

		self.Modulos[tonumber(num)] = {player,cli,tick()}


		
		
		
		
	end
	


	
	return cli
	
end



 function Game:SendClientToExit(client, passDerivacion)
	task.spawn(function()
		if passDerivacion then
			PathfindingModule.MoveTo(client.char, workspace.Plats:FindFirstChild("Derivacion"))
			task.wait(1.5)
		end
		PathfindingModule.MoveTo(client.char, workspace.Plats:FindFirstChild("Salida"))
		task.wait(0.5)

		-- Destruir de forma segura
		if client.char and client.char.Parent then
			client.char:Destroy()
		end
	end)
end

function Game:EntregarCliente(player,datos)
	
	local num = datos.num
	local tipo = datos.tipo
	
	local cli = self.Modulos[tonumber(num)][2]
	
	self.dayClientsAttended = self.dayClientsAttended + 1  -- ✅ Solo día

	if tipo == "CHIP" then
		self.dayChipsEntregados = self.dayChipsEntregados + 1
	elseif tipo == "INFORME" then
		self.dayInformesEntregados = self.dayInformesEntregados + 1
	elseif tipo == "DERIVACION" then
		self.dayDerivacionesEntregadas = self.dayDerivacionesEntregadas + 1
	end
	
	if tipo == "DERIVACION" then
		cli.chat:Destroy()
		self:PushNext()
		cli.tag:Destroy()
		local tiempotomado = self.Modulos[tonumber(num)][3]
		local calificacion = cli:CalcularPuntuacion(tick()-tiempotomado)
		print("calificacion de",calificacion)
		GuideEvent:FireClient(player,"DETENER",{num,calificacion})


		self.Modulos[tonumber(num)] = {}

		self:SendClientToExit(cli, true)  -- true = pasó por derivación


		--PathfindingModule.MoveTo(cli.char, workspace.Plats:FindFirstChild("Derivacion"))
		--task.wait(1.5)
     	--PathfindingModule.MoveTo(cli.char, workspace.Plats:FindFirstChild("Salida"))
		--cli.char:Destroy()
		
		
		return
	end

	local HojaImpresa = ReplicatedStorage:FindFirstChild("HojaImpresa"):Clone()
	
	local foldermodulo =  GameFolder.Modulos["Modulo"..num]
	local placedocument = foldermodulo:FindFirstChild("PlaceDocument")
	local placechip = foldermodulo:FindFirstChild("PlaceChip")

	HojaImpresa.Parent = workspace.GrabParts
	HojaImpresa.CFrame = foldermodulo.Impresora.CFrame
	HojaImpresa.Sonido:Play()
	
	local y_inc = 1.15
	
	
	
	tw:Create(placedocument,TweenInfo.new(.4,Enum.EasingStyle.Linear),{CFrame =
		placedocument.CFrame * CFrame.new(0,y_inc,0)
	}):Play()
	
	
	local conexionplace
	local conexionchip
	local chippuesto = nil
	
	
	local function finish()
		if conexionplace then conexionplace:Disconnect() conexionplace = nil end
		if conexionchip then conexionchip:Disconnect() conexionchip = nil end

		
		local tiempotomado = self.Modulos[tonumber(num)][3]
		local calificacion = cli:CalcularPuntuacion(tick()-tiempotomado)
		GuideEvent:FireClient(player,"DETENER",{num,calificacion})
		print("calificacion de",calificacion)
		task.wait(.3)


		HojaImpresa.CanCollide = false
		
		tw:Create(HojaImpresa,TweenInfo.new(.4,Enum.EasingStyle.Linear),{CFrame =
			cli.char.PrimaryPart.CFrame , Size = HojaImpresa.Size * 0.6
		}):Play()
		if chippuesto then
			chippuesto.CanCollide = false

			tw:Create(chippuesto,TweenInfo.new(.4,Enum.EasingStyle.Linear),{CFrame =
				cli.char.PrimaryPart.CFrame 
			}):Play()
		end
		
		task.wait(.4)
		
		if chippuesto then chippuesto:Destroy() end
		if HojaImpresa then HojaImpresa:Destroy() end

		
		self.Modulos[tonumber(num)] = {}
		
		
		spawn(function()
			
			if tipo == "INFORME" then
				PathfindingModule.MoveTo(cli.char, workspace.Plats:FindFirstChild("Derivacion"))
				task.wait(1.5)
			end
			PathfindingModule.MoveTo(cli.char, workspace.Plats:FindFirstChild("Salida"))
			cli.char:Destroy()
			
		end)
		
		cli.chat:Destroy()
		cli.tag:Destroy()

		self:PushNext()
	end
	
	local activos = 0
	
	local function entregar_def()
		
		if conexionplace then conexionplace:Disconnect() conexionplace = nil end
		activos += 1
		HojaImpresa.Parent = workspace
		HojaImpresa.Anchored = true
		
		local cf_m = placedocument.CFrame
		--cf_m.Position = Vector3.new(placedocument.Position.X,y_final,placedocument.Position.Z)
		
		
		
		tw:Create(HojaImpresa,TweenInfo.new(1,Enum.EasingStyle.Linear),{
			CFrame = cf_m * CFrame.new(0,y_inc/8,0)	}):Play()
		
		tw:Create(placedocument,TweenInfo.new(.3,Enum.EasingStyle.Linear),{CFrame =
			cf_m * CFrame.new(0,-y_inc,0)
		}):Play()
		
		task.wait(1.4)
		
		task.wait()
		
		
		if tipo == "INFORME" then
			finish()
		elseif activos == 2 then
			finish()
		end
		
		
		
		
		
	end
	
	local function entregar_defchip(parte)
		chippuesto = parte

		if conexionchip then conexionchip:Disconnect() conexionchip = nil end
		activos += 1
		parte.Parent = workspace
		parte.Anchored = true

		local cf_m = placechip.CFrame
 
		

		tw:Create(parte,TweenInfo.new(1,Enum.EasingStyle.Linear),{
			CFrame =  cf_m * CFrame.new(0,y_inc/8,0)	}):Play()

		tw:Create(placechip,TweenInfo.new(.3,Enum.EasingStyle.Linear),{CFrame =
			cf_m * CFrame.new(0,-y_inc,0)
		}):Play()
		
		task.wait(1.4)

		task.wait()


		if activos == 2 then
			finish()
		end





	end
	
	local db = true
	
	conexionplace = placedocument.Touched:Connect(function(parte)
		if not db then return end 
		db = false
		if parte == HojaImpresa and not (HojaImpresa:GetAttribute("Grabbing")) then
			
			entregar_def()
		end
		db = true
	end)
	
 	
	if tipo == "CHIP" then
		
		tw:Create(placechip,TweenInfo.new(.4,Enum.EasingStyle.Linear),{CFrame =
			placechip.CFrame * CFrame.new(0,y_inc,0)
		}):Play()


		conexionchip = placechip.Touched:Connect(function(parte)
			if not db then return end 
			db = false
			if parte.Name == "CHIP" and not (parte:GetAttribute("Grabbing")) then
 
				entregar_defchip(parte)
			end
			db = true
		end)
		
	end

	
	
	
	
	
end

function Game:DayStart()
	print("Iniciando dia ",self.currentDay)
	self:UpdateDifficultyForDay()

	while self.isRunning do
		self.Intermission = false
		self.dayClientsSpawned = 0
		self.dayClientsAttended = 0
		
		self.dayChipsEntregados = 0
		self.dayInformesEntregados = 0
		self.dayDerivacionesEntregadas = 0
		
		local dayDuration = self:getDayDuration()
		local spawnInterval = self:getClientSpawnInterval()
		
		print("\n╔═══════════════════════════════════════╗")
		print("║         DÍA " .. self.currentDay .. " INICIADO           ║")
		print("╚═══════════════════════════════════════╝")
		print("⏱️  Duración: " .. dayDuration .. " segundos")
		print("🔄 Spawn cada: " .. string.format("%.1f", spawnInterval) .. " segundos")
		print("👷 Trabajadores: " .. #self.workers)
		
		
		local dayStartTime = tick()
		
		-- habria una funcion tipo task.spawn que genera clientes en un while 
		
		self:StartSpawnClients()
		
		while tick() - dayStartTime < dayDuration and self.isRunning do
			task.wait(1)
		end
		
		self:StopSpawningClients()
		local Lighting = game:GetService("Lighting")
		local originalBrightness = Lighting.Brightness
		local originalClockTime = Lighting.ClockTime

		print("🌙 Día terminado - Oscureciendo...")
		tw:Create(Lighting, TweenInfo.new(2), {
			Brightness = 0.5,
			ClockTime = 19  -- Atardecer
		}):Play()
		
		self:ClearRemainingClients()
		
 		local waitingForModules = true
		while waitingForModules do
			waitingForModules = false

			for i = 1, 3 do
				if self.Modulos[i][1] ~= nil then
					waitingForModules = true
					break
				end
			end

			if waitingForModules then
				task.wait(1)
			end
		end
		
		print("💡 Apagando luces...")
		self:ApagarLuces()

		tw:Create(Lighting, TweenInfo.new(2), {
			Brightness = 0,
			ClockTime = 0  -- Medianoche total
		}):Play()

		task.wait(2)
		
 		
		local efficiency = 0
		if self.dayClientsSpawned > 0 then
			efficiency = (self.dayClientsAttended / self.dayClientsSpawned) * 100
		end
		

		print("\n╔═══════════════════════════════════════╗")
		print("║      ESTADÍSTICAS DÍA " .. self.currentDay .. "           ║")
		print("╠═══════════════════════════════════════╣")
		print("║  👥 Clientes: " .. self.dayClientsSpawned)
		print("║  ✅ Atendidos: " .. self.dayClientsAttended)
		print("║  ❌ Perdidos: " .. (self.dayClientsSpawned - self.dayClientsAttended))
		print("║  📊 Eficiencia: " .. string.format("%.1f%%", efficiency))
		print("╠═══════════════════════════════════════╣")
		print("║  📱 CHIPs: " .. self.dayChipsEntregados)
		print("║  📄 INFORMEs: " .. self.dayInformesEntregados)
		print("║  ➡️  DERIVACIONEs: " .. self.dayDerivacionesEntregadas)
		print("╚═══════════════════════════════════════╝")

		
		local efficiency = 0
		
		if self.dayClientsSpawned > 0 then
			efficiency = (self.dayClientsAttended / self.dayClientsSpawned) * 100
		end

		print("\n╔═══════════════════════════════════════╗")
		print("║      ESTADÍSTICAS DÍA " .. self.currentDay .. "           ║")
		print("╠═══════════════════════════════════════╣")
		print("║  👥 Clientes: " .. self.dayClientsSpawned)
		print("║  ✅ Atendidos: " .. self.dayClientsAttended)
		print("║  ❌ Perdidos: " .. (self.dayClientsSpawned - self.dayClientsAttended))
		print("║  📊 Eficiencia: " .. string.format("%.1f%%", efficiency))
		print("╠═══════════════════════════════════════╣")
		print("║  📱 CHIPs: " .. self.dayChipsEntregados)
		print("║  📄 INFORMEs: " .. self.dayInformesEntregados)
		print("║  ➡️  DERIVACIONEs: " .. self.dayDerivacionesEntregadas)
		print("╚═══════════════════════════════════════╝")

 		local gui = resumenpart.Gui.Frame

 		local barraProgress = self.dayClientsAttended / math.max(self.dayClientsSpawned, 1)
		
		gui.TChips.Text = self.dayChipsEntregados .. " "
		gui.TInformes.Text = self.dayInformesEntregados .. " "
		gui.TDerivaciones.Text = self.dayDerivacionesEntregadas .. " "
		gui.TClientes.Text = 0 .. " / " .. 0



		tw:Create(resumenpart, TweenInfo.new(0.9, Enum.EasingStyle.Linear), {
			Position = Vector3.new(-19.83, 8, 8.276)
		}):Play()
		
		task.wait(0.9)  -- Esperar a que suba
		gui.Barra.BarraIn:TweenSize(
			UDim2.new(barraProgress, 0, 1, 0),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.9,
			true
		)
		gui.TClientes.Text = self.dayClientsAttended .. " / " .. self.dayClientsSpawned

		self.currentDay = self.currentDay + 1
		self.Intermission = true 

		-- INTERMISIÓN CON EFECTOS
		if self.Intermission then
			tw:Create(resumenpart, TweenInfo.new(0.9, Enum.EasingStyle.Linear), {
				Position = Vector3.new(-19.83, 8, 8.276)
			}):Play()
			
			self:RunIntermission()
			
			
		end
		
		-- detendria esa funcion task.spawn
		
	end
end

-- ✅ NUEVA FUNCIÓN: Limpiar clientes que quedaron sin atender
function Game:ClearRemainingClients()
	print("🧹 Limpiando clientes no atendidos...")

	-- Clientes en cola
	while not self.clientQueue:isEmpty() do
		local cli = self.clientQueue:pop()
		if cli and cli.char then
			if cli.tag then cli.tag:Destroy() end
			if cli.chat then cli.chat:Destroy() end
			self:SendClientToExit(cli, false)
		end
	end

	-- Clientes en sala de espera
	local remainingInQueue = self.queueSystem:GetQueueCount()
	for i = 1, remainingInQueue do
		local cli = self.queueSystem:GetFirstClient()
		if cli and cli.char then
			if cli.tag then cli.tag:Destroy() end
			self:SendClientToExit(cli, false)
			self.queueSystem:RemoveFirst()
		end
	end

	-- Limpiar asientos ocupados
	self.set = RandomSet.new()
	for i = 1, 7 do
		self.set:insert(i)
	end

	task.wait(3)  -- Dar tiempo a que salgan todos
	print("✅ Limpieza completada")
end

function Game:RunIntermission()
	local Lighting = game:GetService("Lighting")

	print("\n⏸️ INTERMISIÓN - " .. self.intermissionTime .. " segundos...")

	-- Mostrar mensaje de intermisión
	print("╔════════════════════════════════════╗")
	print("║     FIN DEL DÍA " .. (self.currentDay - 1) .. "              ║")
	print("║     PREPARANDO DÍA " .. self.currentDay .. "...        ║")
	print("╚════════════════════════════════════╝")

	local gui = resumenpart.Gui.Frame
	local intermissionStart = tick()
	local totalTime = self.intermissionTime - 2  -- Restar los 2 segundos finales

	-- ✅ Actualizar Time con countdown de intermisión
	while tick() - intermissionStart < totalTime do
		local timeLeft = totalTime - (tick() - intermissionStart)
		local minutes = math.floor(timeLeft / 60)
		local seconds = math.floor(timeLeft % 60)
		gui.Time.Text = string.format("%02d:%02d", minutes, seconds)

		-- Print cada 10 segundos
		if math.floor(timeLeft) % 10 == 0 and timeLeft > 0 then
			print("⏱️  Siguiente día en " .. math.floor(timeLeft) .. " segundos...")
		end

		task.wait(1)
	end

	-- Encender luces
	self:EncenderLuces()
	tw:Create(Lighting, TweenInfo.new(3), {
		Brightness = 1,
		ClockTime = 8  -- Mañana
	}):Play()

	gui.Time.Text = "00:00"

	task.wait(3)

	print("🌅 ¡DÍA " .. self.currentDay .. " COMIENZA!")
end


function Game:start()
	if self.isRunning then
		warn("El juego ya está corriendo")
		return
	end

	if #self.workers == 0 then
		warn("No hay trabajadores disponibles")
		return
	end

	self.isRunning = true
	self.Intermission = false
	print("=== JUEGO INICIADO ===")
	
	local db = true
	
	for _,v in pairs(GameFolder.Modulos:GetChildren()) do
		if v:IsA("Folder") then
			local numero = string.match(v.Name, "%d+$")
			local mb = v:FindFirstChild("MB")
			if not mb then continue end
			local click : ClickDetector = mb:FindFirstChild("ClickDetector")
			local Excl : BasePart = v:FindFirstChild("EXC")

			click.MouseClick:Connect(function(player)
				if self.Intermission then
 					return
				end
				if not db then return end 
				print("atendiendo pera")
				db = false 

				task.spawn(function()
					tw:Create(mb,TweenInfo.new(.25
						,Enum.EasingStyle.Bounce),{Color = Color3.fromRGB(105, 153, 255) }):Play()

					task.wait(.7)
					tw:Create(mb,TweenInfo.new(.3
						,Enum.EasingStyle.Bounce),{Color = Color3.fromRGB(252, 250, 255) }):Play()

				end)

				tw:Create(Excl,TweenInfo.new(.3
					,Enum.EasingStyle.Bounce),{Position = Vector3.new(Excl.Position.X,
						y_exclama_fi,Excl.Position.Z) }):Play()

				task.wait(1)


				tw:Create(Excl,TweenInfo.new(.2
					,Enum.EasingStyle.Linear),{Position = Vector3.new(Excl.Position.X,
						y_exclama_ini,Excl.Position.Z) }):Play()
 
				if self.Modulos[tonumber(numero)][1] == nil and (not self.clientQueue:isEmpty()) then
 					local cliente = self:AtenderCliente(player,numero)


				end

				db = true
			end)




		end
	end

	self:DayStart()
	
	

	
	
end

function Game:getDayDuration()
	return self.dayDuration
end

function Game:getClientSpawnInterval()
	return self.clientSpawnInterval
end


return Game