local Work = false
function Activated(whoWasThat)
	if Work == false then
		if whoWasThat.Parent:FindFirstChild("Humanoid")  then
			Work = true
			script.Parent.LED.BrickColor = BrickColor.new("Really red")
			script.Parent.Parent.OpenOutside.Value = true
			wait(1)
			script.Parent.LED.BrickColor = BrickColor.new("Lime green")	
			Work = false
	end
	end
end	
script.Parent.Sensor.Touched:connect(Activated)