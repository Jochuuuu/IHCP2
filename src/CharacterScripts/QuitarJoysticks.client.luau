local starterGui = game:GetService("StarterGui")

-- Intenta ocultar los controladores cada 0.5 segundos hasta que funcione
local success = false
while not success do
	local result = pcall(function()
		starterGui:SetCore("VRLaserPointerMode", 0)
		starterGui:SetCore("VREnableControllerModels", false)
	end)

	if result then
		success = true
		print("Controladores VR ocultados exitosamente")
	else
		wait(0.5)
	end
end