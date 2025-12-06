local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StartEvent = ReplicatedStorage:WaitForChild("START")
local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer

local startedgame = ReplicatedStorage:WaitForChild("STARTEDGAME")

local main = script.Parent
local db = true
script.Parent.Visible = not (startedgame.Value)

local function desparecer_opciones()
	for i,v in pairs(main.Botones:GetChildren()) do
		if v:IsA("TextButton") then
			v:TweenPosition(UDim2.new(v.Position.X.Scale,0,
				v.Position.Y.Scale + 1.,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.45,true)
		end
	end
	task.wait(.45)

	main.Botones:TweenPosition(UDim2.new(-1,0,
		.7,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.35,true)
 	task.wait(.45)

	main.TextLabel:TweenPosition(UDim2.new(0.5,0,
		-.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.35,true)


end


local function aparecer_opciones()
	for i,v in pairs(main.Botones:GetChildren()) do
		if v:IsA("TextButton") then
			v:TweenPosition(UDim2.new(v.Position.X.Scale,0,
				v.Position.Y.Scale - 1.,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.45,true)
		end
	end
	task.wait(.45)

	main.Botones:TweenPosition(UDim2.new(.5,0,
		.7,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.35,true)

	task.wait(.45)

	main.TextLabel:TweenPosition(UDim2.new(0.5,0,
		.231,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.35,true)


end


local function desaparecer()



	desparecer_opciones()


	task.wait(.35)


	script.Parent.Visible = false

 end

startedgame.Changed:Connect(function()
	script.Parent.Visible = not (startedgame.Value)
end)

 




local inicio = script.Parent.Botones:FindFirstChild("Inicio")
local guia = script.Parent.Botones:FindFirstChild("Guia")

local tutoframe = script.Parent.Tuto

local function guiasalir()
	tutoframe.Opciones:TweenPosition(UDim2.new(-.35,0,.5,0),
		Enum.EasingDirection.In,Enum.EasingStyle.Linear,.29)

	tutoframe.Main:TweenPosition(UDim2.new(1.7,0,.5,0),
		Enum.EasingDirection.In,Enum.EasingStyle.Linear,.29)

	tutoframe.Salir:TweenPosition(UDim2.new(-1,0,0,0),
		Enum.EasingDirection.In,Enum.EasingStyle.Linear,.29)
	
	 
	
end

guiasalir()


 
guia.Activated:Connect(function()
	if not db then return end
	db = false
	if (startedgame.Value == true) then return end
	desparecer_opciones()
	task.wait(.35)

	tutoframe.Opciones:TweenPosition(UDim2.new(.02,0,.5,0),
		Enum.EasingDirection.In,Enum.EasingStyle.Linear,.29)

	tutoframe.Main:TweenPosition(UDim2.new(1.7,0,.5,0),
		Enum.EasingDirection.In,Enum.EasingStyle.Linear,.29)



	tutoframe.Salir:TweenPosition(UDim2.new(.002,0,0,0),
		Enum.EasingDirection.In,Enum.EasingStyle.Linear,.29)

	task.wait(.3)
	db = true 
end)

tutoframe.Salir.Activated:Connect(function()
	if not db then return end
	db = false
	if (startedgame.Value == true) then return end

	guiasalir()

	task.wait(.3)
	aparecer_opciones()

	task.wait()

	db = true
end)

local opcionestuto = tutoframe.Opciones
local lastframe  = nil

for _,v in pairs(opcionestuto:GetChildren()) do
	if v:IsA("TextButton") then

		local mombre = v.Name 

		v.Activated:Connect(function()
			if not db then return end
			db = false 

			tutoframe.Main:TweenPosition(UDim2.new(1.7,0,.5,0),
				Enum.EasingDirection.In,Enum.EasingStyle.Linear,.1)
			task.wait(.1)
			
			if lastframe then lastframe.Visible = false end 
			lastframe = tutoframe.Main:FindFirstChild(mombre)
			lastframe.Visible = true
			tutoframe.Main.Titulo.Text = v.Text
			
			
			tutoframe.Main:TweenPosition(UDim2.new(0.6,0,.5,0),
				Enum.EasingDirection.In,Enum.EasingStyle.Linear,.1)

			task.wait(.1)
			db = true

		end)

	end
end


inicio.Activated:Connect(function()
	if not db then return end
	if (startedgame.Value == true) then return end
	db = false
	desaparecer()
	StartEvent:FireServer()

end)
 desparecer_opciones()
 task.wait(.35)
 aparecer_opciones()
 
 
 