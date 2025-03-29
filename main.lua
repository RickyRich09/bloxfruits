local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Blox Fruits Script",
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

-- ESP State Management
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
    ["Fountain City"] = Vector3.new(5500, 5, 4500),
    ["Middle Town"] = Vector3.new(1200, 10, 3800)
}

--- ESP Creation & Management
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

--- Clear All ESP Objects
local function ClearAllESP()
    for obj, esp in pairs(ESPObjects) do
        if esp then esp:Destroy() end
    end
    ESPObjects = {}

    -- Clear Island Markers
    for _, marker in pairs(IslandMarkers) do
        if marker then marker:Destroy() end
    end
    IslandMarkers = {}
end

--- Main ESP Update Loop
local function UpdateESP()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- Player ESP
    if ESPEnabled.Player then
        for _, targetPlayer in ipairs(game.Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character then
                local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
                if targetRoot and humanoid then
                    local distance = math.floor((rootPart.Position - targetRoot.Position).Magnitude)
                    CreateESP(targetRoot, Color3.fromRGB(255, 255, 255), 
                        string.format("%s\nHP: %d/%d\nDist: %d", targetPlayer.Name, humanoid.Health, humanoid.MaxHealth, distance))
                end
            end
        end
    end

    -- Devil Fruit ESP
    if ESPEnabled.DevilFruit then
        for _, fruit in ipairs(game.Workspace:GetChildren()) do
            if fruit:IsA("Model") and fruit:FindFirstChild("Handle") and fruit.Name:lower():find("fruit") then
                local distance = math.floor((rootPart.Position - fruit.Handle.Position).Magnitude)
                CreateESP(fruit.Handle, Color3.fromRGB(255, 255, 255), string.format("🍏 %s\nDist: %d", fruit.Name, distance))
            end
        end
    end

    -- Berry ESP
    if ESPEnabled.Berry then
        for _, berry in ipairs(game.Workspace:GetChildren()) do
            if berry:IsA("Model") and berry.PrimaryPart and berry.Name:lower():find("berry") then
                local distance = math.floor((rootPart.Position - berry.PrimaryPart.Position).Magnitude)
                CreateESP(berry.PrimaryPart, Color3.fromRGB(255, 255, 255), string.format("💰 %s\nDist: %d", berry.Name, distance))
            end
        end
    end

    -- Flower ESP
    if ESPEnabled.Flower then
        for _, flower in ipairs(game.Workspace:GetChildren()) do
            if flower:IsA("Model") and flower.PrimaryPart and flower.Name:lower():find("flower") then
                local distance = math.floor((rootPart.Position - flower.PrimaryPart.Position).Magnitude)
                CreateESP(flower.PrimaryPart, Color3.fromRGB(255, 255, 255), string.format("🌸 %s\nDist: %d", flower.Name, distance))
            end
        end
    end

    -- Island ESP
    if ESPEnabled.Island then
        for islandName, islandPos in pairs(FirstSeaIslands) do
            local distance = math.floor((rootPart.Position - islandPos).Magnitude)
            local marker = Instance.new("Part")
            marker.Size = Vector3.new(5, 5, 5)
            marker.Position = islandPos
            marker.Anchored = true
            marker.Transparency = 1
            marker.CanCollide = false
            marker.Parent = game.Workspace
            table.insert(IslandMarkers, marker)
            CreateESP(marker, Color3.fromRGB(255, 255, 255), string.format("🏝 %s\nDist: %d", islandName, distance))
        end
    end
end

--- Toggle ESP System
local function ToggleESP(espType, enabled)
    ESPEnabled[espType] = enabled

    -- Start/Stop ESP Loop
    local anyESPEnabled = false
    for _, v in pairs(ESPEnabled) do
        if v then
            anyESPEnabled = true
            break
        end
    end

    if anyESPEnabled and not ESPLoopRunning then
        ESPLoopRunning = true
        coroutine.wrap(function()
            while ESPLoopRunning do
                UpdateESP()
                task.wait(2)
            end
            ClearAllESP() -- Cleanup when loop stops
        end)()
    elseif not anyESPEnabled then
        ESPLoopRunning = false
    end
end

--- ESP Toggles
ESPTab:CreateToggle({ Name = "Player ESP", CurrentValue = false, Flag = "PlayerESP", Callback = function(Value) ToggleESP("Player", Value) end })
ESPTab:CreateToggle({ Name = "Devil Fruit ESP", CurrentValue = false, Flag = "DevilFruitESP", Callback = function(Value) ToggleESP("DevilFruit", Value) end })
ESPTab:CreateToggle({ Name = "Berry ESP", CurrentValue = false, Flag = "BerryESP", Callback = function(Value) ToggleESP("Berry", Value) end })
ESPTab:CreateToggle({ Name = "Flower ESP", CurrentValue = false, Flag = "FlowerESP", Callback = function(Value) ToggleESP("Flower", Value) end })
ESPTab:CreateToggle({ Name = "Island ESP", CurrentValue = false, Flag = "IslandESP", Callback = function(Value) ToggleESP("Island", Value) end })

--- Bring Devil Fruits (Misc)
local BringDevilFruitsEnabled = false
local function BringDevilFruits()
    while BringDevilFruitsEnabled do
        local player = game.Players.LocalPlayer
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            for _, fruit in ipairs(game.Workspace:GetChildren()) do
                if fruit:IsA("Model") and fruit:FindFirstChild("Handle") and fruit.Name:lower():find("fruit") then
                    fruit.Handle.CFrame = rootPart.CFrame + Vector3.new(0, 3, 0)
                end
            end
        end
        task.wait(1)
    end
end

MiscTab:CreateToggle({
    Name = "Bring Devil Fruits",
    CurrentValue = false,
    Flag = "BringDevilFruits",
    Callback = function(Value)
        BringDevilFruitsEnabled = Value
        if Value then
            coroutine.wrap(BringDevilFruits)()
        end
    end
})

--- Server Hopping (Settings)
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local function GetServerList()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    return success and response.data or nil
end

local function ServerHop()
    local servers = GetServerList()
    if servers then
        for _, server in ipairs(servers) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                return
            end
        end
    end
    Rayfield:Notify("⚠ No available servers found!")
end

SettingsTab:CreateButton({
    Name = "Server Hop",
    Callback = ServerHop
})

Rayfield:LoadConfiguration()