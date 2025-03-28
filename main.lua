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
    ["Starter Island"] = Vector3.new(-500, 50, 200),
    ["Marine Fortress"] = Vector3.new(-1600, 50, 800),
    ["Jungle"] = Vector3.new(-1100, 30, -500),
    ["Pirate Village"] = Vector3.new(-1100, 50, 1200),
    ["Desert"] = Vector3.new(400, 30, -1600),
    ["Middle Town"] = Vector3.new(0, 50, 0),
    ["Frozen Village"] = Vector3.new(1100, 50, -1200),
    ["Underwater City"] = Vector3.new(2200, -200, -2000),
    ["Sky Islands"] = Vector3.new(0, 500, 0),
    ["Colosseum"] = Vector3.new(-1600, 50, -1000),
    ["Magma Village"] = Vector3.new(-900, 50, 2000),
    ["Fountain City"] = Vector3.new(2300, 50, 800)
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

local function UpdateESP()
    if ESPLoopRunning then return end
    ESPLoopRunning = true

    while next(ESPEnabled) do
        task.wait(2)

        -- Clear invalid ESP objects
        for obj, esp in pairs(ESPObjects) do
            if not obj or not obj.Parent then
                esp:Destroy()
                ESPObjects[obj] = nil
            end
        end

        -- Player ESP
        if ESPEnabled.Player then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if hrp and humanoid then
                        local distance = math.floor((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                        CreateESP(hrp, Color3.fromRGB(255, 255, 255), string.format("%s\nHP: %d/%d\nDist: %d", player.Name, humanoid.Health, humanoid.MaxHealth, distance))
                    end
                end
            end
        end

        -- Devil Fruit ESP
        if ESPEnabled.DevilFruit then
            for _, fruit in pairs(game.Workspace:GetChildren()) do
                if fruit:IsA("Model") and fruit:FindFirstChild("Handle") and fruit.Name:lower():find("fruit") then
                    CreateESP(fruit.Handle, Color3.fromRGB(255, 165, 0), "🍏 Devil Fruit")
                end
            end
        end

        -- Berry ESP
        if ESPEnabled.Berry then
            for _, berry in pairs(game.Workspace:GetChildren()) do
                if berry:IsA("Model") and berry:FindFirstChild("PrimaryPart") and berry.Name:lower():find("berry") then
                    CreateESP(berry.PrimaryPart, Color3.fromRGB(0, 255, 0), "💰 Berry")
                end
            end
        end

        -- Flower ESP
        if ESPEnabled.Flower then
            for _, flower in pairs(game.Workspace:GetChildren()) do
                if flower:IsA("Model") and flower:FindFirstChild("PrimaryPart") and flower.Name:lower():find("flower") then
                    CreateESP(flower.PrimaryPart, Color3.fromRGB(255, 0, 255), "🌸 Flower")
                end
            end
        end

        -- Island ESP
        if ESPEnabled.Island then
            for _, marker in pairs(IslandMarkers) do
                marker:Destroy()
            end
            IslandMarkers = {}

            for island, pos in pairs(FirstSeaIslands) do
                local marker = Instance.new("Part")
                marker.Size = Vector3.new(5, 5, 5)
                marker.Position = pos
                marker.Anchored = true
                marker.Transparency = 1
                marker.Parent = game.Workspace
                
                table.insert(IslandMarkers, marker)
                CreateESP(marker, Color3.fromRGB(255, 255, 255), "🏝 " .. island)
            end
        end
    end

    ESPLoopRunning = false
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

Rayfield:LoadConfiguration()