local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local remote = ReplicatedStorage:FindFirstChild("FlightBatRemote")
if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = "FlightBatRemote"
    remote.Parent = ReplicatedStorage
end

local MAX_FLIGHT_SPEED = 55
local BAT_RANGE = 12
local BAT_COOLDOWN = 0.45
local flightState = {}
local lastSwing = {}

local function getRoot(player)
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function stopFlight(player)
    flightState[player] = nil
    local root = getRoot(player)
    if root then
        local attachment = root:FindFirstChild("FlightAttachment")
        local velocity = root:FindFirstChild("FlightVelocity")
        if velocity then velocity:Destroy() end
        if attachment then attachment:Destroy() end
    end
end

local function startFlight(player)
    local root = getRoot(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then return end

    stopFlight(player)
    local attachment = Instance.new("Attachment")
    attachment.Name = "FlightAttachment"
    attachment.Parent = root

    local velocity = Instance.new("LinearVelocity")
    velocity.Name = "FlightVelocity"
    velocity.Attachment0 = attachment
    velocity.RelativeTo = Enum.ActuatorRelativeTo.World
    velocity.MaxForce = math.max(root.AssemblyMass * workspace.Gravity * 4, 10000)
    velocity.VectorVelocity = Vector3.zero
    velocity.Parent = root

    flightState[player] = {velocity = velocity}
    humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
end

remote.OnServerEvent:Connect(function(player, action, value)
    if action == "ToggleFlight" then
        if flightState[player] then
            stopFlight(player)
        else
            startFlight(player)
        end
    elseif action == "FlightDirection" then
        local state = flightState[player]
        if not state or typeof(value) ~= "Vector3" then return end
        if value.Magnitude > 1.01 then value = value.Unit end
        state.velocity.VectorVelocity = value * MAX_FLIGHT_SPEED
    elseif action == "AutoBat" then
        local now = os.clock()
        if now - (lastSwing[player] or 0) < BAT_COOLDOWN then return end
        lastSwing[player] = now

        local root = getRoot(player)
        local character = player.Character
        if not root or not character then return end
        local tool = character:FindFirstChild("Bat")
        if not tool or not tool:IsA("Tool") then return end

        local ball
        local nearestDistance = BAT_RANGE
        for _, candidate in workspace:GetDescendants() do
            if candidate:IsA("BasePart") and candidate.Name == "Ball" and not candidate.Anchored then
                local distance = (candidate.Position - root.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    ball = candidate
                end
            end
        end

        if ball then
            local direction = root.CFrame.LookVector
            local launch = (direction + Vector3.new(0, 0.55, 0)).Unit
            ball:ApplyImpulse(launch * ball.AssemblyMass * 95)
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    flightState[player] = nil
    lastSwing[player] = nil
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterRemoving:Connect(function()
        stopFlight(player)
    end)
end)

for _, player in Players:GetPlayers() do
    player.CharacterRemoving:Connect(function()
        stopFlight(player)
    end)
end
