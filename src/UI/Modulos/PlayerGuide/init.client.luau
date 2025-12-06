local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Eventos = ReplicatedStorage:WaitForChild("Eventos")
local GuideEvent = Eventos:WaitForChild("Guide")

local PathVisualizer = require(ReplicatedStorage:WaitForChild("PathVisualizer"))
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local GameFolder = workspace:WaitForChild("Game")
local RunService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local SonidosFolder = script.Parent:WaitForChild("Sonidos")


 
local function tipeoTexto(label,textoCompleto)
	for i = 1, #textoCompleto do
		label.Text = textoCompleto:sub(1, i)

		wait(.015)
	end
end

local arrivalConnection

-- CRONOMETRO --
local tiempoTotal = 0
local conteoAct = nil
---------------------------------------------------

local function DetenerCronometro()
	if conteoAct then
		conteoAct:Disconnect()
		conteoAct = nil
	end
end




local function FormatoTiempo(segundos)
	local mins = math.floor(segundos / 60)
	local secs = math.floor(segundos % 60)
	return string.format("%02d:%02d", mins, secs)
end

local function IniciarCronometro(TEXTO)
	if conteoAct then return end  

	tiempoTotal = 0

	conteoAct = RunService.Heartbeat:Connect(function(dt)
		tiempoTotal += dt
		TEXTO.Text = FormatoTiempo(tiempoTotal)
	end)
end


local function JoinGuia(gui,board,tipo)
	gui.Enabled = true
	gui.Adornee = board
	gui.Frame.Texto.Text = " "
	TweenService:Create(gui.Frame,TweenInfo.new(.5,Enum.EasingStyle.Linear),
		{Position = UDim2.new(0.5, 0,.5, 0)}):Play()
	
	if tipo == "Desplazar" then
		tipeoTexto(gui.Frame.Texto,"Desplaza los datos del cliente al informe en el  campo correspondiente.")
	else 
		tipeoTexto(gui.Frame.Texto,"Recoger documentos y/o chips atras y entregar en el modulo")
	end
 	
end


local function EndGuia(gui,board,tipo)
	gui.Enabled = false
	gui.Adornee =  nil

	TweenService:Create(gui.Frame,TweenInfo.new(.5,Enum.EasingStyle.Linear),
		{Position = UDim2.new(0.5, 0,1.5, 0)}):Play()


 

end
---------------------------------------------------


local cronometro = script.Parent:WaitForChild("Cronometro"):WaitForChild("Main")

 GuideEvent.OnClientEvent:Connect(function(mode,values)
	
 	
	if mode == "Module" then
		
		local textomodulo = script.Parent.TextoModulo
		textomodulo.TextTransparency = 0
		local anima = TweenService:Create(textomodulo,TweenInfo.new(
			0.4,Enum.EasingStyle.Bounce),{Position = UDim2.new(.5,0,.2,0)})
		
		-- objeto , ( tiempo, estilo  ) , propiedades
		
		anima:Play()
		
		
		anima = TweenService:Create(textomodulo,TweenInfo.new(
			0.4,Enum.EasingStyle.Linear),{Position = UDim2.new(.5,0,1.2,0),TextTransparency = 1})

		
		task.wait(.1)
		
		
		
		
		
		local targetPart = GameFolder:WaitForChild("Modulos")["Modulo"..values].Main
		local startPart = Player.Character and Player.Character.PrimaryPart
		
		
		PathVisualizer.ShowPath(startPart, targetPart)
		
		if arrivalConnection then
			arrivalConnection:Disconnect()
			arrivalConnection = nil
		end

		local THRESHOLD = 1.5
		
		
		arrivalConnection = RunService.RenderStepped:Connect(function()
			local char = Player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart") or char and char.PrimaryPart

			if not root then
				return
			end

			local dist = (root.Position - targetPart.Position).Magnitude

			if dist <= THRESHOLD then
				-- Jugador ya está cerca → limpiamos el camino
				PathVisualizer.Clear()

				-- Desconectar para no seguir revisando
				arrivalConnection:Disconnect()
				arrivalConnection = nil
				anima:Play()
			end
		end)
		
		
		pcall(function()
			task.delay(5, function()
				
				if arrivalConnection then
					arrivalConnection:Disconnect()
					arrivalConnection = nil
					anima:Play()
				end
				
				PathVisualizer.Clear()
			end)
		end)
	elseif mode == "DETENER" then
		
		DetenerCronometro()
		local BoardsFolder = script.Parent:WaitForChild("Boards")
		local modulo_number,puntos = values[1],values[2]

		local OpcionesGUI = BoardsFolder:FindFirstChild("Opciones")
		local GuiaGUI = BoardsFolder:FindFirstChild("Guia")
		local Module = GameFolder:WaitForChild("Modulos")["Modulo"..modulo_number] 
		local OptionsBoard = Module:WaitForChild("BoardOpciones")
		EndGuia(GuiaGUI,OptionsBoard,"ATRAS")


		task.spawn(function()
			task.wait(.5)
			cronometro.Parent.Adornee = nil

		end)
		local BoardsFolder = script.Parent:WaitForChild("Boards")
		local Module = GameFolder:WaitForChild("Modulos")["Modulo"..modulo_number] 

		local PuntuacionGUI = BoardsFolder:FindFirstChild("Puntuacion")

		
		for i = 1,5 do
			local frame :ImageLabel = PuntuacionGUI.Main:FindFirstChild(tostring(i))
			frame.Position = UDim2.new(.2*(i-1),0,1,0)
			frame.Size = UDim2.new(.18/10,0,1/18,0)
			local gradient = frame.Gradiente
			gradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 150, 150)),      -- Amarillo izquierda
				ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))     -- Gris derecha
			}
			
		end
		PuntuacionGUI.Adornee = Module.HojaP
		PuntuacionGUI.Puntuacion.Text = puntos .. " / 5" 

		for i = 1,5 do
			local frame :ImageLabel = PuntuacionGUI.Main:FindFirstChild(tostring(i))
			local gradient = frame.Gradiente
			local porcentajeEstrella = 0

			if puntos >= i then
				porcentajeEstrella = 1.0
			elseif puntos > (i - 1) then
				porcentajeEstrella = puntos - (i - 1)
			else
				porcentajeEstrella = 0
			end
			
			if porcentajeEstrella == 0 then
				gradient.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 150, 150)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))
				}
			elseif porcentajeEstrella == 1.0 then
				gradient.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
				}
			else
				gradient.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),                    -- Amarillo inicio
					ColorSequenceKeypoint.new(porcentajeEstrella, Color3.fromRGB(255, 255, 0)),   -- Amarillo hasta el %
					ColorSequenceKeypoint.new(porcentajeEstrella, Color3.fromRGB(150, 150, 150)), -- Gris desde el %
					ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))                   -- Gris final
				}
			end 
			
			TweenService:Create(frame,TweenInfo.new(.18,Enum.EasingStyle.Bounce),
				{Position =UDim2.new(.2*(i-1),0,0,0), Size =  UDim2.new(.18,0,1,0) }):Play()
			
			task.wait(.185)
			
			delay(2.3-(.19*(i-1)),function()
				TweenService:Create(frame,TweenInfo.new(.11,Enum.EasingStyle.Linear),
					{Position =UDim2.new(.2*(i-1),0,1,0) , Size =  UDim2.new(.18/10,0,1/18,0) }):Play()
			end)
			
		end
		
		task.wait(2.5)
		
		PuntuacionGUI.Adornee = nil

		
		
		
		
		
		

		
		
	elseif mode == "Options" then
		-- values = [modulo_number, opcion_cliente,open]
 
		local modulo_number,opcion_cliente,open,datos = values[1],values[2],values[3],values[4]
		
		local size_original = UDim2.new(0,205,0,268)
		local size_final = UDim2.new(0,205/13,0,268/13)
		
		
		local opciones_pos_inicio = UDim2.new()

		local Module = GameFolder:WaitForChild("Modulos")["Modulo"..modulo_number] 
		local OptionsBoard = Module:WaitForChild("BoardOpciones")
 		local BoardsFolder = script.Parent:WaitForChild("Boards")

		local OpcionesGUI = BoardsFolder:FindFirstChild("Opciones")
		local GuiaGUI = BoardsFolder:FindFirstChild("Guia")

		
	
		cronometro.Parent.Adornee = nil

		DetenerCronometro()
		
		
		OpcionesGUI.Enabled = false
		
		
		TweenService:Create(cronometro,TweenInfo.new(.4,Enum.EasingStyle.Linear),
			{Position = UDim2.new(0.5,0,-0.4,0)} ):Play()
		
		if not open then return end
		
		
		
		local hoja = script.HojaP:Clone()
		hoja.Parent = BoardsFolder
		
		OpcionesGUI.Frame.Position = UDim2.new(.5,0,1.5,0)

		OpcionesGUI.Enabled = true
		
		
		OpcionesGUI.Adornee = OptionsBoard
		
		
	 	TweenService:Create(OpcionesGUI.Frame,TweenInfo.new(.5,Enum.EasingStyle.Linear),
		 	{Position = UDim2.new(0.5, 0,.5, 0)}):Play()
		
		
		
		local conexionInforme
		local conexionChip
		cronometro.Parent.Adornee = Module.Timer

		IniciarCronometro(cronometro.TIME)

		TweenService:Create(cronometro,TweenInfo.new(.3,Enum.EasingStyle.Linear),
			{Position = UDim2.new(0.5,0,0.5,0)} ):Play()
		
		
 		
		local function MakeINFORME()
			
			 
			--uis.MouseBehavior = Enum.MouseBehavior.Default
			
			
			
			


			TweenService:Create(OpcionesGUI.Frame,TweenInfo.new(.5,Enum.EasingStyle.Linear),
				{Position = UDim2.new(0.5, 0,1.5, 0)}):Play()
			
			local HojaInforme = hoja.Hoja
			
			if conexionInforme then
				conexionInforme:Disconnect()
			end
			
			if conexionChip then
				conexionChip:Disconnect()
			end
			
			if opcion_cliente == "DERIVACION" then
				GuideEvent:FireServer({
					mode = "ENTREGAR",
					num = modulo_number,
					tipo = opcion_cliente,
				})
 
				
				
				return
			end
			
			spawn(function()
				JoinGuia(GuiaGUI,OptionsBoard,"Desplazar")

			end)
			
			
			--hoja.Position = UDim2.new(0.475, 0,1.315, 0)
			hoja.Enabled = true
			hoja.Adornee = Module.HojaP
			--TweenService:Create(hoja,TweenInfo.new(.3,Enum.EasingStyle.Bounce),
				--{Position = UDim2.new(0.475, 0,.515, 0)}):Play()
			
		 

			task.wait(.3)
			
			
			local tipo_opciones  = { 
				CHIP = { fragmentos = {"DNI","Cliente","Plan","Numero"},
					     valores =  {datos.dni,datos.name,"PostPago",datos.tel} }, 
				
				INFORME = { fragmentos = { "DNI","Cliente","Descripcion","Problema","Numero"},  
							  valores =  {datos.dni,datos.name, "--- - - - - ----- - --- -- -" 
									,datos.problema,datos.tel} }, 
				
			}
			
			local fragmentos = tipo_opciones[opcion_cliente].fragmentos
			local valores =tipo_opciones[opcion_cliente].valores
			
			local matcheados = 0
			
			local collisionframe = hoja.Collision

			for index,value in pairs(fragmentos) do
				local fragmento = hoja[value]
				fragmento.Texto.Text = " "
				fragmento.Visible = true
				
				HojaInforme[value].Visible = true
				HojaInforme[value].BackgroundTransparency = 0.35
				
				pcall(function()
					for _,t in pairs(HojaInforme[value]:GetChildren()) do
						t.TextColor3 = Color3.fromRGB(43, 57, 255)
						t.TextTransparency = 0.5
					end
				end)
				
				
				spawn(function()
					SonidosFolder.Escribir:Play()

					tipeoTexto(fragmento.Texto,valores[index])
					SonidosFolder.Escribir:Stop() 

				end)
				
				local DragD = fragmento.DragD

				DragD.DragEnd:Connect(function()
					local dragPos = fragmento.AbsolutePosition
					local dragSize = fragmento.AbsoluteSize
					
					local subFrame = HojaInforme[value]
					
					local collisionPos = subFrame.AbsolutePosition
					local collisionSize = subFrame.AbsoluteSize
					local dragCenterX = dragPos.X + (dragSize.X / 2)
					local dragCenterY = dragPos.Y + (dragSize.Y / 2)
					
					if dragCenterX >= collisionPos.X and dragCenterX <= collisionPos.X + collisionSize.X and
						dragCenterY >= collisionPos.Y and dragCenterY <= collisionPos.Y + collisionSize.Y then
						--print("Está dentro del rango!")
						fragmento:Destroy()
						
						HojaInforme[value].Texto.Text = " "

						
						HojaInforme[value].Visible = true
						HojaInforme[value].BackgroundTransparency = 1

						pcall(function()
							for _,t in pairs(HojaInforme[value]:GetChildren()) do
								t.TextColor3 = Color3.fromRGB(0, 0, 0)
								t.TextTransparency = 0
							end
						end)


						matcheados = matcheados + 1
						
						SonidosFolder.Escribir:Play()
						tipeoTexto(HojaInforme[value].Texto,valores[index])
						SonidosFolder.Escribir:Stop() 
						
						if matcheados == #(tipo_opciones[opcion_cliente].fragmentos) then
							hoja.ENTREGAR.Position = UDim2.new(.87,0,1.4,0)
							hoja.ENTREGAR.Visible = true
							
							TweenService:Create(hoja.ENTREGAR,TweenInfo.new(.2
								,Enum.EasingStyle.Linear),{Position = 
									UDim2.new(.435,0,0.92,0) }):Play()
							
						end
						
					else
						pcall(function()
							SonidosFolder.Error:Play()
							spawn(function()
								fragmento.BackgroundColor3 = Color3.fromRGB(255, 117, 117)
								task.wait(.085)
								if  (fragmento.BackgroundColor3 == Color3.fromRGB(255, 117, 117)) then
									fragmento.BackgroundColor3 = Color3.fromRGB(116, 116, 116)
								end
								
							end)
						end)
					end
					
				end)
				
			end

		 
			hoja.ENTREGAR.Activated:Connect(function()
				EndGuia(GuiaGUI,OptionsBoard,"Desplazar")

				 delay(0.6,function()
					JoinGuia(GuiaGUI,OptionsBoard,"ATRAS")

				 end)
				
				
				hoja.ENTREGAR:Destroy()
				
				
				TweenService:Create(hoja.Datos,TweenInfo.new(.5,Enum.EasingStyle.Linear),
					{Position = UDim2.new(-.6, 0,.5, 0)}):Play()
				
				task.wait(.5)
				
			 
				
				TweenService:Create(hoja.Hoja,TweenInfo.new(.5,Enum.EasingStyle.Bounce),
					{Position = UDim2.new(.5, 0,.5, 0)}):Play()
				TweenService:Create(hoja.HojaStroke,TweenInfo.new(.5,Enum.EasingStyle.Bounce),
					{Position = UDim2.new(.5, 0,.5, 0)}):Play()
				task.wait(.5)
				
				TweenService:Create(hoja.Hoja,TweenInfo.new(.6,Enum.EasingStyle.Bounce),
					{Size = UDim2.new(.5/15, 0,.5/15, 0)}):Play()
				TweenService:Create(hoja.HojaStroke,TweenInfo.new(.6,Enum.EasingStyle.Bounce),
					{Size = UDim2.new(.5/15, 0,.5/15, 0)}):Play()
				task.wait(.6)
				
				hoja:Destroy()
				
				GuideEvent:FireServer({
					mode = "ENTREGAR",
					num = modulo_number,
					tipo = opcion_cliente,
				})
				
				 
			end)
			 
			
			
			
			
			
			
			
			
			
		end
		
		local db = true 
		--uis.MouseBehavior = Enum.MouseBehavior.Default
		local function ejecutar(boton)
			db = false 
			if boton.Name == opcion_cliente then
				
					
				 
					MakeINFORME()
				 
			else 
				SonidosFolder.Error:Play()
				task.wait()
				db = true
			end
		end
		
 		
		conexionInforme = OpcionesGUI.Frame.CHIP.Activated:Connect(function(player)
			if not db then return end 
			ejecutar(OpcionesGUI.Frame.CHIP) 
		end)

		conexionChip = OpcionesGUI.Frame.INFORME.Activated:Connect(function(player)
			if not db then return end 

			ejecutar(OpcionesGUI.Frame.INFORME) 
		end)
		
		conexionChip = OpcionesGUI.Frame.DERIVACION.Activated:Connect(function(player)
			if not db then return end 

			ejecutar(OpcionesGUI.Frame.DERIVACION) 
		end)
		
		
		
		
			
	end
	
end)


