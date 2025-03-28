local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Blox Fruits Script (ONLY WORKING ON FIRST SEA)",
    LoadingTitle = "Blox Fruits Script",
    LoadingSubtitle = "by artist.ricky (!..Ricky)",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BloxFruitsScript",
        FileName = "Config"
    },
    KeySystem = false
})

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
local ESPLoopRunning = false

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
    ESPObjects = {}

    -- Clear Island Markers too
    for _, marker in pairs(IslandMarkers) do
        if marker then
            marker:Destroy()
        end
    end
    IslandMarkers = {}
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

-- ESP Toggles
ESPTab:CreateToggle({ Name = "Player ESP", CurrentValue = false, Flag = "PlayerESP", Callback = function(Value) ToggleESP("Player", Value) end })
ESPTab:CreateToggle({ Name = "Devil Fruit ESP", CurrentValue = false, Flag = "DevilFruitESP", Callback = function(Value) ToggleESP("DevilFruit", Value) end })
ESPTab:CreateToggle({ Name = "Berry ESP", CurrentValue = false, Flag = "BerryESP", Callback = function(Value) ToggleESP("Berry", Value) end })
ESPTab:CreateToggle({ Name = "Flower ESP", CurrentValue = false, Flag = "FlowerESP", Callback = function(Value) ToggleESP("Flower", Value) end })
ESPTab:CreateToggle({ Name = "Island ESP", CurrentValue = false, Flag = "IslandESP", Callback = function(Value) ToggleESP("Island", Value) end })

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
    print("⚠ No available low player servers found!")
end

-- Add buttons to Settings Tab
SettingsTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        ServerHop()
    end
})

SettingsTab:CreateButton({
    Name = "Server Hop (Low Players)",
    Callback = function()
        ServerHopLowest()
    end
})

Rayfield:LoadConfiguration()