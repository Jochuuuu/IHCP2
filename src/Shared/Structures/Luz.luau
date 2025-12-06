
local LuzPart = {}
LuzPart.__index = LuzPart

function LuzPart.new(part,encendido)
	assert(part and part:IsA("BasePart"), "Debes pasar una Part válida")

	local self = setmetatable({}, LuzPart)

	self.Part = part
	self.Attachment = part:FindFirstChild("Attachment")
	self.Beam = self.Part and self.Part:FindFirstChildWhichIsA("Beam")
	self.SurfaceLight = part:FindFirstChildWhichIsA("SurfaceLight")
	self.PointLight = part:FindFirstChildWhichIsA("PointLight")
 	-- Estado interno
	if encendido then
		self:Encender()
	else 
		self:Apagar()
	end

	return self
end

function LuzPart:Encender()
	self.Encendido = true
	self.Part.Color = Color3.fromRGB(255, 255, 255)
self.Part.Transparency = 0.9
	
	if self.SurfaceLight then
		self.SurfaceLight.Enabled = true
	end
	
	if self.PointLight then
		self.PointLight.Enabled = true
	end

	if self.Beam then
		self.Beam.Enabled = true
	end
end

function LuzPart:Apagar()
	self.Encendido = false
	self.Part.Color = Color3.fromRGB(0,0,0)
	self.Part.Transparency = 1

	if self.SurfaceLight then
		self.SurfaceLight.Enabled = false
	end

	if self.PointLight then
		self.PointLight.Enabled = false
	end


	if self.Beam then
		self.Beam.Enabled = false
	end
end

function LuzPart:Toggle()
	if self.Encendido then
		self:Apagar()
	else
		self:Encender()
	end
end

return LuzPart
