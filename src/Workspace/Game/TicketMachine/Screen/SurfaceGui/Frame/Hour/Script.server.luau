local Player = game:GetService("Players").PlayerAdded:Wait()

local ScreenGUI = Instance.new("ScreenGui")
ScreenGUI.Parent = Player.PlayerGui
ScreenGUI.IgnoreGuiInset = true

while wait() do
	local Frame = Instance.new("Frame")
	Frame.Parent = ScreenGUI
	Frame.Position = UDim2.fromOffset(math.random(0,1600), math.random(0,1000))
	Frame.BackgroundColor3 = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
	Frame.Size = UDim2.fromOffset(4, 4)
	Frame.BorderSizePixel = 0
	Frame.Transparency = 1
	Frame.Name = ""
	local Part = Instance.new("Part")
	Part.Parent = game:GetService("Workspace")
	Part.Position = Vector3.new(math.random(0,1000), 69, math.random(0,1000))
	Part.Size = Vector3.new(1,1,1)
	Part.Transparency = 1
	Part.Anchored = true
end