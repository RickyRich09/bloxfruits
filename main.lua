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

-- Function to hop to a new server
local function HopToServer()
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId
    local AllServers = {}  -- Store all server ids to hop

    local function GetServers()
        local success, result = pcall(function()
            return game:GetService("HttpService"):GetAsync("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public")
        end)

        if success and result then
            local servers = game:GetService("HttpService"):JSONDecode(result).data
            for _, server in ipairs(servers) do
                if server.id then
                    table.insert(AllServers, server.id)
                end
            end
        end
    end

    -- Get available servers
    GetServers()

    -- Hop to a random server
    if #AllServers > 0 then
        local selectedServer = AllServers[math.random(1, #AllServers)]
        TeleportService:TeleportToPlaceInstance(PlaceId, selectedServer)
    else
        print("⚠ No servers found to hop to!")
    end
end

-- Function to hop to a new server after fruit detection
local function FruitServerHop()
    -- Wait until fruits are detected (or any event is triggered to check for fruits)
    while true do
        local fruitsFound = false
        for _, fruit in pairs(game.Workspace:GetChildren()) do
            if fruit:IsA("Model") and fruit.Name:lower():find("fruit") then
                fruitsFound = true
                break
            end
        end

        -- If fruits are found, hop to a new server
        if fruitsFound then
            print("Fruit found! Hopping to a new server...")
            HopToServer()
            break
        end

        task.wait(5)  -- Check for fruits every 5 seconds
    end
end

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

-- Island dropdown setup
local IslandsList = {}
for island, _ in pairs(FirstSeaIslands) do
    table.insert(IslandsList, island)
end

-- Function to teleport to selected island
local function TeleportToIsland(islandName)
    local targetPosition = FirstSeaIslands[islandName]
    if targetPosition then
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Teleport player to the island's position
            character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
            print("Teleporting to " .. islandName)
        else
            print("⚠ Unable to teleport. Character not found!")
        end
    else
        print("⚠ Island not found!")
    end
end

-- Create Dropdown and Button for Island Teleportation in Misc Tab
MiscTab:CreateDropdown({
    Name = "Select Island",
    Options = IslandsList,
    CurrentOption = "Starter Island (Pirates)",  -- Default option
    Flag = "IslandSelection",
    Callback = function(selectedIsland)
        print("Selected Island: " .. selectedIsland)
        -- Teleport to the selected island
        TeleportToIsland(selectedIsland)
    end
})

MiscTab:CreateButton({
    Name = "Teleport to Selected Island",
    Callback = function()
        local selectedIsland = Rayfield:GetOption("IslandSelection")
        if selectedIsland then
            TeleportToIsland(selectedIsland)
        else
            print("⚠ Please select an island from the dropdown!")
        end
    end
})

-- Add server hop features in Misc tab
SettingsTab:CreateButton({
    Name = "Normal Server Hop",
    Callback = function()
        print("Hopping to a new server...")
        HopToServer()
    end
})

SettingsTab:CreateButton({
    Name = "Fruit Server Hop",
    Callback = function()
        print("Starting Fruit Server Hop...")
        FruitServerHop()
    end
})

Rayfield:LoadConfiguration()