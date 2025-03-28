local ValidKeys = {
    "KEY1",  -- Add your first key here
    "KEY2",  -- Add your second key here
    "KEY3"   -- Add more keys as needed
}

local KeyEntered = false
local Attempts = 0  -- Track the number of attempts

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Key Entry Window
local KeyWindow = Rayfield:CreateWindow({
    Name = "Blox Fruits Script - Key System",
    LoadingTitle = "Key Verification",
    LoadingSubtitle = "Enter a valid key to proceed",
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false
})

local KeyTab = KeyWindow:CreateTab("Key System", 4483362458)

KeyTab:CreateInput({
    Name = "Enter Key",
    PlaceholderText = "Enter the script key...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Input)
        -- Check if the entered key is in the list of valid keys
        if table.find(ValidKeys, Input) then
            KeyEntered = true
            KeyWindow:Destroy()
            LoadMainScript()
        else
            Attempts = Attempts + 1
            if Attempts >= 3 then
                Rayfield:Notify({
                    Title = "Access Denied",
                    Content = "You have exceeded the maximum attempts. Please try again later.",
                    Duration = 5
                })
                KeyWindow:Destroy()  -- Close the script
            else
                Rayfield:Notify({
                    Title = "Invalid Key",
                    Content = "The key you entered is incorrect! Attempt " .. Attempts .. " of 3.",
                    Duration = 3
                })
            end
        end
    end
})

-- Main Script
function LoadMainScript()
    local Window = Rayfield:CreateWindow({
        Name = "Blox Fruits Script",
        LoadingTitle = "Blox Fruits Script",
        LoadingSubtitle = "by !..Ricky",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "BloxFruitsScript",
            FileName = "Config"
        }
    })

    -- Tabs
    local FarmTab = Window:CreateTab("Farm", 4483362458)
    local ESPTab = Window:CreateTab("ESP", 4483362458)
    local MiscTab = Window:CreateTab("Misc", 4483362458)
    local SettingsTab = Window:CreateTab("Settings", 4483362458)

    -- Variables
    local AutoFarmEnabled = false
    local BringDevilFruitsEnabled = false
    local ESPEnabled = {
        Player = false,
        DevilFruit = false,
        Berry = false,
        Flower = false,
        Island = false
    }
    local ESPObjects = {}
    local IslandMarkers = {}

    -- Function to get nearest enemy
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

    -- Function to move to position
    local function MoveToPosition(position)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
        end
    end

    -- Auto Farm Loop
    local function AutoFarmLoop()
        while AutoFarmEnabled do
            local enemy = GetNearestEnemy()
            if enemy then
                MoveToPosition(enemy.HumanoidRootPart.Position)
                task.wait(0.5)
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):ClickButton1(Vector2.new())
            end
            task.wait(1)
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

    -- Function to bring Devil Fruits
    local function BringDevilFruits()
        while BringDevilFruitsEnabled do
            for _, fruit in pairs(game.Workspace:GetChildren()) do
                if fruit:IsA("Model") and fruit:FindFirstChild("Handle") and fruit.Name:lower():find("fruit") then
                    fruit.Handle.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                end
            end
            task.wait(1)
        end
    end

    -- Toggle for Devil Fruits
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

    -- ESP Creation Function
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

    -- Function to clear all ESP objects
    local function ClearAllESP()
        for obj, esp in pairs(ESPObjects) do
            if esp then
                esp:Destroy()
            end
        end
        ESPObjects = {}

        for _, marker in pairs(IslandMarkers) do
            if marker then
                marker:Destroy()
            end
        end
        IslandMarkers = {}
    end

    -- Function to update ESP
    local function UpdateESP()
        while ESPEnabled.Player or ESPEnabled.DevilFruit or ESPEnabled.Berry or ESPEnabled.Flower or ESPEnabled.Island do
            task.wait(2)

            ClearAllESP()

            local playerRoot = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            -- Player ESP
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

            -- Devil Fruit ESP
            if ESPEnabled.DevilFruit then
                for _, fruit in pairs(game.Workspace:GetChildren()) do
                    if fruit:IsA("Model") and fruit:FindFirstChild("Handle") and fruit.Name:lower():find("fruit") then
                        local distance = math.floor((playerRoot.Position - fruit.Handle.Position).Magnitude)
                        CreateESP(fruit.Handle, Color3.fromRGB(255, 255, 255), string.format("🍏 %s\nDist: %d", fruit.Name, distance))
                    end
                end
            end

            -- Berry ESP
            if ESPEnabled.Berry then
                for _, berry in pairs(game.Workspace:GetChildren()) do
                    if berry:IsA("Model") and berry.PrimaryPart then
                        local distance = math.floor((playerRoot.Position - berry.PrimaryPart.Position).Magnitude)
                        CreateESP(berry.PrimaryPart, Color3.fromRGB(255, 255, 255), string.format("💰 %s\nDist: %d", berry.Name, distance))
                    end
                end
            end

            -- Flower ESP
            if ESPEnabled.Flower then
                for _, flower in pairs(game.Workspace:GetChildren()) do
                    if flower:IsA("Model") and flower.PrimaryPart then
                        local distance = math.floor((playerRoot.Position - flower.PrimaryPart.Position).Magnitude)
                        CreateESP(flower.PrimaryPart, Color3.fromRGB(255, 255, 255), string.format("🌸 %s\nDist: %d", flower.Name, distance))
                    end
                end
            end

            -- Island ESP
            if ESPEnabled.Island then
                for _, island in pairs(game.Workspace:GetChildren()) do
                    if island:IsA("Model") and island:FindFirstChild("PrimaryPart") then
                        local distance = math.floor((playerRoot.Position - island.PrimaryPart.Position).Magnitude)
                        if not IslandMarkers[island] then
                            local marker = Instance.new("Part")
                            marker.Size = Vector3.new(1, 1, 1)
                            marker.Position = island.PrimaryPart.Position + Vector3.new(0, 10, 0)
                            marker.Anchored = true
                            marker.CanCollide = false
                            marker.Color = Color3.fromRGB(255, 255, 255)
                            marker.Parent = game.Workspace
                            IslandMarkers[island] = marker
                        end
                    end
                end
            end
        end
    end

    -- ESP Toggles
    ESPTab:CreateToggle({
        Name = "Player ESP",
        CurrentValue = false,
        Flag = "PlayerESP",
        Callback = function(Value)
            ESPEnabled.Player = Value
            UpdateESP()
        end
    })

    ESPTab:CreateToggle({
        Name = "Devil Fruit ESP",
        CurrentValue = false,
        Flag = "DevilFruitESP",
        Callback = function(Value)
            ESPEnabled.DevilFruit = Value
            UpdateESP()
        end
    })

    ESPTab:CreateToggle({
        Name = "Berry ESP",
        CurrentValue = false,
        Flag = "BerryESP",
        Callback = function(Value)
            ESPEnabled.Berry = Value
            UpdateESP()
        end
    })

    ESPTab:CreateToggle({
        Name = "Flower ESP",
        CurrentValue = false,
        Flag = "FlowerESP",
        Callback = function(Value)
            ESPEnabled.Flower = Value
            UpdateESP()
        end
    })

    ESPTab:CreateToggle({
        Name = "Island ESP",
        CurrentValue = false,
        Flag = "IslandESP",
        Callback = function(Value)
            ESPEnabled.Island = Value
            UpdateESP()
        end
    })

    -- Settings Tab
    SettingsTab:CreateButton({
        Name = "Clear ESP",
        Callback = function()
            ClearAllESP()
        end
    })

    Rayfield:LoadConfiguration()
end