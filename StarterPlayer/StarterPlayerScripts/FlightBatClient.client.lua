local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("FlightBatRemote")
local flying = false
local autoBat = false
local flightConnection
local batConnection

local function getHumanoid()
    local character = player.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function sendFlightDirection()
    local camera = workspace.CurrentCamera
    local humanoid = getHumanoid()
    if not camera or not humanoid then return end

    local direction = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.yAxis end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.yAxis end

    remote:FireServer("FlightDirection", direction.Magnitude > 1 and direction.Unit or direction)
end

local function setFlying(enabled)
    flying = enabled
    remote:FireServer("ToggleFlight")
    if flightConnection then
        flightConnection:Disconnect()
        flightConnection = nil
    end
    if flying then
        flightConnection = RunService.RenderStepped:Connect(sendFlightDirection)
    end
end

local function setAutoBat(enabled)
    autoBat = enabled
    if batConnection then
        batConnection:Disconnect()
        batConnection = nil
    end
    if autoBat then
        batConnection = RunService.Heartbeat:Connect(function()
            remote:FireServer("AutoBat")
        end)
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F then
        setFlying(not flying)
    elseif input.KeyCode == Enum.KeyCode.G then
        setAutoBat(not autoBat)
    end
end)

player.CharacterRemoving:Connect(function()
    flying = false
    autoBat = false
    if flightConnection then flightConnection:Disconnect(); flightConnection = nil end
    if batConnection then batConnection:Disconnect(); batConnection = nil end
end)
