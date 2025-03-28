local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Blox Fruits Script",
    LoadingTitle = "Blox Fruits Script",
    LoadingSubtitle = "by !..Ricky",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BloxFruitsScript",
        FileName = "Config"
    },
    KeySystem = false
})

local FarmTab = Window:CreateTab("Farm", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

local ESPEnabled = {
    Player = false,
    DevilFruit = false,
    Berry = false,
    Flower = false,
    Island = false
}

local ESPObjects = {}
local IslandMarkers = {}
local ESPLoopRunning = false -- Prevent multiple loops

local AutoFarmEnabled = false

-- Function to get the nearest enemy
local function GetNearestEnemy()
    local nearestEnemy = nil
    local shortestDistance = math.huge
    local player = game.Players.LocalPlayer

    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart

        for _, npc in pairs(game.Workspace.Enemies:GetChildren()) do
            if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                local distance = (rootPart.Position - npc.HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestEnemy = npc
                end
            end
        end
    end

    return nearestEnemy
end

-- Function to move to a position
local function MoveToPosition(position)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 5, 0)) -- Slightly above to avoid getting stuck
    end
end

-- Function to auto farm enemies
local function AutoFarmLoop()
    while AutoFarmEnabled do
        local enemy = GetNearestEnemy()

        if enemy then
            MoveToPosition(enemy.HumanoidRootPart.Position)
            task.wait(0.5) -- Wait before attacking

            -- Attack enemy
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton1(Vector2.new()) -- Simulates left-click attack
        end

        task.wait(1) -- Adjust for better performance
    end
end

-- Toggle for Auto Farm
FarmTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        AutoFarmEnabled = Value
        if Value then
            AutoFarmLoop()
        end
    end
})

-- First Sea Island Positions
local FirstSeaIslands = {
    ["Starter Island (Pirates)"] = Vector3.new(-1149, 5, 3826),
    ["Starter Island (Marines)"] = Vector3.new(-1123, 5, 3855),
    ["Jungle"] = Vector3.new(-1339, 11, 354),
    ["Pirate Village"] = Vector3.new(-1140, 5, 1325),
    ["Desert"] = Vector3.new(978, 13, 4310),
    ["Frozen Village"] = Vector3.new(1214, 7, -1210),
    ["Marine Fortress"] = Vector3.new(-4550, 210, 4190),
    ["Skylands"] = Vector3.new(-4850, 900, -250),
    ["Prison"] = Vector3.new(4850, 5, 790),
    ["Colosseum"] = Vector3.new(-1425, 7, -3015),
    ["Magma Village"] = Vector3.new(-5230, 6, 1300),
    ["Underwater City"] = Vector3.new(61164, -1000, 1819),
    ["Fountain City"] = Vector3.new(5500, 5, 4500)
}

-- Function to teleport player
local function TeleportToIsland(island)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        if FirstSeaIslands[island] then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(FirstSeaIslands[island] + Vector3.new(0, 5, 0)) -- Teleports slightly above to avoid getting stuck
        else
            print("⚠ Island not found!")
        end
    end
end

-- Add dropdown to Misc Tab
MiscTab:CreateDropdown({
    Name = "Teleport to Island (First Sea)",
    Options = table.keys(FirstSeaIslands),
    CurrentOption = "Starter Island (Pirates)",
    Flag = "TeleportIsland",
    Callback = function(SelectedIsland)
        TeleportToIsland(SelectedIsland)
    end
})

local function CreateESP(object, color, labelText)
    if not object or ESPObjects[object] then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextSize = 14
    label.Font = Enum.Font.SourceSansBold
    label.Text = labelText
    label.Parent = billboard

    billboard.Parent = object
    ESPObjects[object] = billboard
end

-- Function to clear all ESP objects properly
local function ClearAllESP()
    for obj, esp in pairs(ESPObjects) do
        if esp then
            esp:Destroy()
        end
    end
    ESPObjects = {} -- Reset table to prevent reusing old objects

    -- Clear Island Markers too
    for _, marker in pairs(IslandMarkers) do
        if marker then
            marker:Destroy()
        end
    end
    IslandMarkers = {} -- Reset island markers
end

-- Function to update ESP dynamically
local function UpdateESP()
    while ESPEnabled.Player or ESPEnabled.DevilFruit or ESPEnabled.Berry or ESPEnabled.Flower or ESPEnabled.Island do
        task.wait(2)

        -- Fix: Clear Old ESPs Before Updating
        ClearAllESP()

        local playerRoot = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        -- Player ESP (Now updates health correctly)
        if ESPEnabled.Player then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    local distance = math.floor((playerRoot.Position - player.Character.HumanoidRootPart.Position).Magnitude)

                    if not ESPObjects[player.Character.HumanoidRootPart] then
                        CreateESP(player.Character.HumanoidRootPart, Color3.fromRGB(255, 255, 255), "")
                    end

                    ESPObjects[player.Character.HumanoidRootPart].TextLabel.Text = string.format("%s\nHP: %d/%d\nDist: %d", player.Name, humanoid.Health, humanoid.MaxHealth, distance)
                end
            end
        end

        -- Devil Fruit ESP (Now shows name & distance)
        if ESPEnabled.DevilFruit then
            for _, fruit in pairs(game.Workspace:GetChildren()) do
                if fruit:IsA("Model") and fruit:FindFirstChild("Handle") and fruit.Name:lower():find("fruit") then
                    local distance = math.floor((playerRoot.Position - fruit.Handle.Position).Magnitude)
                    CreateESP(fruit.Handle, Color3.fromRGB(255, 255, 255), string.format("🍏 %s\nDist: %d", fruit.Name, distance))
                end
            end
        end

        -- Berry ESP (Now shows name & distance)
        if ESPEnabled.Berry then
            for _, berry in pairs(game.Workspace:GetChildren()) do
                if berry:IsA("Model") and berry.PrimaryPart then
                    local distance = math.floor((playerRoot.Position - berry.PrimaryPart.Position).Magnitude)
                    CreateESP(berry.PrimaryPart, Color3.fromRGB(255, 255, 255), string.format("💰 %s\nDist: %d", berry.Name, distance))
                end
            end
        end

        -- Flower ESP (Now shows name & distance)
        if ESPEnabled.Flower then
            for _, flower in pairs(game.Workspace:GetChildren()) do
                if flower:IsA("Model") and flower.PrimaryPart then
                    local distance = math.floor((playerRoot.Position - flower.PrimaryPart.Position).Magnitude)
                    CreateESP(flower.PrimaryPart, Color3.fromRGB(255, 255, 255), string.format("🌸 %s\nDist: %d", flower.Name, distance))
                end
            end
        end

        -- Island ESP (Now shows name & distance)
        if ESPEnabled.Island then
            for island, pos in pairs(FirstSeaIslands) do
                local distance = math.floor((playerRoot.Position - pos).Magnitude)

                local marker = Instance.new("Part")
                marker.Size = Vector3.new(5, 5, 5)
                marker.Position = pos
                marker.Anchored = true
                marker.Transparency = 1
                marker.Parent = game.Workspace
                
                table.insert(IslandMarkers, marker)
                CreateESP(marker, Color3.fromRGB(255, 255, 255), string.format("🏝 %s\nDist: %d", island, distance))
            end
        end
    end
end

local function ToggleESP(espType, enabled)
    ESPEnabled[espType] = enabled
    if enabled then
        UpdateESP()
    else
        for obj, esp in pairs(ESPObjects) do
            if esp then esp:Destroy() end
        end
        ESPObjects = {}

        if espType == "Island" then
            for _, marker in pairs(IslandMarkers) do
                marker:Destroy()
            end
            IslandMarkers = {}
        end
    end
end

-- Function to bring Devil Fruits
local BringDevilFruitsEnabled = false

local function BringDevilFruits()
    while BringDevilFruitsEnabled do
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart

            for _, fruit in pairs(game.Workspace:GetChildren()) do
                if fruit:IsA("Model") and fruit:FindFirstChild("Handle") and fruit.Name:lower():find("fruit") then
                    fruit.Handle.CFrame = rootPart.CFrame + Vector3.new(0, 3, 0)
                end
            end
        end
        task.wait(1)
    end
end

-- ESP Toggles
ESPTab:CreateToggle({ Name = "Player ESP", CurrentValue = false, Flag = "PlayerESP", Callback = function(Value) ToggleESP("Player", Value) end })
ESPTab:CreateToggle({ Name = "Devil Fruit ESP", CurrentValue = false, Flag = "DevilFruitESP", Callback = function(Value) ToggleESP("DevilFruit", Value) end })
ESPTab:CreateToggle({ Name = "Berry ESP", CurrentValue = false, Flag = "BerryESP", Callback = function(Value) ToggleESP("Berry", Value) end })
ESPTab:CreateToggle({ Name = "Flower ESP", CurrentValue = false, Flag = "FlowerESP", Callback = function(Value) ToggleESP("Flower", Value) end })
ESPTab:CreateToggle({ Name = "Island ESP", CurrentValue = false, Flag = "IslandESP", Callback = function(Value) ToggleESP("Island", Value) end })

-- Add Toggle to Misc Tab
MiscTab:CreateToggle({
    Name = "Bring Devil Fruits",
    CurrentValue = false,
    Flag = "BringDevilFruits",
    Callback = function(Value)
        BringDevilFruitsEnabled = Value
        if Value then
            BringDevilFruits()
        end
    end
})

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- Function to get a list of available servers
local function GetServerList()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if success and response and response.data then
        return response.data
    else
        return nil
    end
end

-- Function to hop to a random server
local function ServerHop()
    local servers = GetServerList()
    if servers then
        for _, server in pairs(servers) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                return
            end
        end
    end
    print("⚠ No available servers found!")
end

-- Function to hop to a server with the lowest players
local function ServerHopLowest()
    local servers = GetServerList()
    if servers then
        table.sort(servers, function(a, b) return a.playing < b.playing end) -- Sort by lowest players
        for _, server in pairs(servers) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                return
            end
        end
    end
    print("⚠ No available low-player servers found!")
end

-- Add buttons to Settings Tab
SettingsTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        ServerHop()
    end
})

SettingsTab:CreateButton({
    Name = "Server Hop (Lowest Players)",
    Callback = function()
        ServerHopLowest()
    end
})

Rayfield:LoadConfiguration()