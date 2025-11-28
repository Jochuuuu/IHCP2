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
	
	for i = 1, 7 do
		self.set:insert(i)
	end
	
	self.Modulos = {
		{},{},{}
	}
	
	
	local grabfolder = workspace:FindFirstChild("GrabParts")
	
 

	-- Control del juego
	self.isRunning = false
	self.clientSpawnInterval = 15
	self.dayDuration = 60 
	self.Intermission = true
	self.queueSystem= QueueSystem.new(workspace.Ticket.Paths)

	return self
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
	
	PathfindingModule.MoveTo(char, workspace.Plats:FindFirstChild("Seat"..num))

	
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





function Game:EntregarCliente(player,datos)
	
	local num = datos.num
	local tipo = datos.tipo
	
	local cli = self.Modulos[tonumber(num)][2]
	

	if tipo == "DERIVACION" then
		cli.chat:Destroy()
		self:PushNext()
		cli.tag:Destroy()
		local tiempotomado = self.Modulos[tonumber(num)][3]
		local calificacion = cli:CalcularPuntuacion(tick()-tiempotomado)
		print("calificacion de",calificacion)
		GuideEvent:FireClient(player,"DETENER",{num,calificacion})


		self.Modulos[tonumber(num)] = {}

		PathfindingModule.MoveTo(cli.char, workspace.Plats:FindFirstChild("Derivacion"))
		task.wait(1.5)
     	PathfindingModule.MoveTo(cli.char, workspace.Plats:FindFirstChild("Salida"))
		cli.char:Destroy()
		
		
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
	
	while self.isRunning do
		self.Intermission = false
		
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
		
		print("Dia termiando !!!")
		self.currentDay = self.currentDay + 1
		self.Intermission = true 
		if self.Intermission then
			print("\n⏸️ Intermisión de 10 segundos...")
			task.wait(10)
		end
		
		-- detendria esa funcion task.spawn
		
	end
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