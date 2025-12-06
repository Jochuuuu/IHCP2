local Timer = 1
local Open = false
local StopAndReopen = false
local DoorPos = 0
local DoorSpeed = 0.1
local DL = script.Parent.DoorLeft:GetChildren()
local DR = script.Parent.DoorRight:GetChildren()
function DoorOpen()
	if Open == false and not StopAndReopen then
		Open = true
		StopAndReopen = true
		for i=DoorPos, 25 do
			if script.Parent.Stop.Value == true then repeat wait() until script.Parent.Stop.Value == false end
			DoorPos = DoorPos + 1	
			for L=1, #DL do
			DL[L].CFrame = DL[L].CFrame * CFrame.new(0.15,0,0)
			end
			for R=1, #DR do
			DR[R].CFrame = DR[R].CFrame * CFrame.new(-0.15,0,0)
			end
		wait()
		end
		if script.Parent.Mode.Value == 1 then repeat wait() until script.Parent.Mode.Value ~= 1 end
		wait(Timer)
		StopAndReopen = false
		Open = false	
		for i=0, 25 do
			if script.Parent.Stop.Value == true then repeat wait() until script.Parent.Stop.Value == false end
			if StopAndReopen then script.Parent.OpenInside.Value = true 	return end
			DoorPos = DoorPos - 1
			for L=1, #DL do
			DL[L].CFrame = DL[L].CFrame * CFrame.new(-0.15,0,0)
			end
			for R=1, #DR do
			DR[R].CFrame = DR[R].CFrame * CFrame.new(0.15,0,0)
			end	
		wait()
		end
	

	end
end

script.Parent.Mode.Changed:connect(function()
	if script.Parent.Mode.Value == 1 then
	DoorOpen()
	end
end)

script.Parent.Open.Changed:connect(function() 
	if script.Parent.Open.Value == true then
		script.Parent.Open.Value = false
		DoorOpen() 
	end 
end)	

script.Parent.OpenOutside.Changed:connect(function() 
	if script.Parent.OpenOutside.Value == true then
		script.Parent.OpenOutside.Value = false
		if script.Parent.Mode.Value == 0 then
		DoorOpen() 
		end
	end 
end)


script.Parent.OpenInside.Changed:connect(function() 
	if script.Parent.OpenInside.Value == true then
		script.Parent.OpenInside.Value = false
		if script.Parent.Mode.Value == 0 or script.Parent.Mode.Value == 3 then
		DoorOpen() 
		end
	end 
end)