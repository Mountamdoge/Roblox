local PS = game:GetService("Players")
local Player = PS.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RS = game:GetService("ReplicatedStorage")
local CE = RS:WaitForChild("CharacterEvents")
local R = game:GetService("RunService")
local BeingHeld = Player:WaitForChild("IsHeld")
local PlayerScripts = Player:WaitForChild("PlayerScripts")
 
--[[ Remotes ]]
local StruggleEvent = CE:WaitForChild("Struggle")
 
--[[ Anti-Explosion ]]
workspace.DescendantAdded:Connect(function(v)
if v:IsA("Explosion") then
v.BlastPressure = 0
end
end)
 
--[[ Anti-grab ]]
 
BeingHeld.Changed:Connect(function(C)
    if C == true then
        local char = Player.Character
 
        if BeingHeld.Value == true then
            local Event;
            Event = R.RenderStepped:Connect(function()
                if BeingHeld.Value == true then
                    char["HumanoidRootPart"].AssemblyLinearVelocity = Vector3.new()
                    StruggleEvent:FireServer(Player)
                elseif BeingHeld.Value == false then
                    Event:Disconnect()
                end
            end)
        end
    end
end)
 
local function reconnect()
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:FindFirstChildWhichIsA("Humanoid") or Character:WaitForChild("Humanoid")
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
 
    HumanoidRootPart:WaitForChild("FirePlayerPart"):Remove()
 
    Humanoid.Changed:Connect(function(C)
        if C == "Sit" and Humanoid.Sit == true then
            if Humanoid.SeatPart ~= nil and tostring(Humanoid.SeatPart.Parent) == "CreatureBlobman" then
            elseif Humanoid.SeatPart == nil then
            Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            Humanoid.Sit = false
            end
        end
    end)
end
 
reconnect()
 
Player.CharacterAdded:Connect(reconnect)

local bodyvel_Name = "FlingVelocity"
local userinputs = game:GetService("UserInputService")
local w = game:GetService("Workspace")
local r = game:GetService("RunService")
local d = game:GetService("Debris")
local strength = 400
 
w.ChildAdded:Connect(function(model)
    if model.Name == "GrabParts" then
        local part_to_impulse = model["GrabPart"]["WeldConstraint"].Part1
 
        if part_to_impulse then
            print("Part found!")
 
            local inputObj
            local velocityObj = Instance.new("BodyVelocity", part_to_impulse)
            
            model:GetPropertyChangedSignal("Parent"):Connect(function()
                if not model.Parent then
                    if userinputs:GetLastInputType() == Enum.UserInputType.MouseButton2 then
                        print("Launched!")
                        velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        velocityObj.Velocity = workspace.CurrentCamera.CFrame.lookVector * strength
                        d:AddItem(velocityObj, 1)
                    elseif userinputs:GetLastInputType() == Enum.UserInputType.MouseButton1 then
                        velocityObj:Destroy()
                        print("Cancel Launch!")
                    else
                        velocityObj:Destroy()
                        print("No two keys pressed!")
                    end
                end
            end)
        end
    end
end)
