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
local KitsuneTab = Window:CreateTab("Kitsune", 4483362458)

-- Kitsune Island Detection
local KitsuneIslandPosition = nil

local function FindKitsuneIsland()
    for _, obj in ipairs(game.Workspace:GetChildren()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            if obj.Name:lower():find("kitsune") then -- Detects objects with "Kitsune" in name
                KitsuneIslandPosition = obj.Position or obj:GetPivot().Position
                print("🔥 Kitsune Island found at:", KitsuneIslandPosition)
                return true
            end
        end
    end
    return false
end

-- Kitsune Island ESP
local function ToggleKitsuneIslandESP(enabled)
    if not KitsuneIslandPosition then FindKitsuneIsland() end
    if not KitsuneIslandPosition then
        Rayfield:Notify("⚠ Kitsune Island not found in this server!")
        return
    end

    if enabled then
        local marker = Instance.new("Part")
        marker.Size = Vector3.new(5, 5, 5)
        marker.Position = KitsuneIslandPosition
        marker.Anchored = true
        marker.Transparency = 1
        marker.CanCollide = false
        marker.Parent = game.Workspace

        local billboard = Instance.new("BillboardGui", marker)
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true

        local label = Instance.new("TextLabel", billboard)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 69, 0)
        label.TextSize = 14
        label.Font = Enum.Font.SourceSansBold
        label.Text = "🔥 Kitsune Island"
        label.Parent = billboard
    end
end

KitsuneTab:CreateToggle({
    Name = "Kitsune Island ESP",
    CurrentValue = false,
    Flag = "KitsuneIslandESP",
    Callback = ToggleKitsuneIslandESP
})

-- Teleport to Kitsune Island
KitsuneTab:CreateButton({
    Name = "Teleport to Kitsune Island",
    Callback = function()
        if not KitsuneIslandPosition then FindKitsuneIsland() end
        if not KitsuneIslandPosition then
            Rayfield:Notify("⚠ Kitsune Island not found in this server!")
            return
        end

        local player = game.Players.LocalPlayer
        if player and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = CFrame.new(KitsuneIslandPosition)
            end
        end
    end
})

-- Kitsune Island Hop (Finds a new server if Kitsune Island is missing)
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local function GetServerList()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    return success and response.data or nil
end

local function KitsuneIslandHop()
    while true do
        if FindKitsuneIsland() then
            Rayfield:Notify("🔥 Kitsune Island Found!")
            break
        else
            local servers = GetServerList()
            if servers then
                for _, server in ipairs(servers) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                        return
                    end
                end
            end
        end
        task.wait(5) -- Wait before checking another server
    end
end

KitsuneTab:CreateButton({
    Name = "Kitsune Island Hop",
    Callback = function()
        coroutine.wrap(KitsuneIslandHop)()
    end
})

-- Auto Collect Aure Amber (Example Script)
local AutoCollectEnabled = false

local function AutoCollectAureAmber()
    while AutoCollectEnabled do
        for _, amber in ipairs(game.Workspace:GetChildren()) do
            if amber:IsA("Model") and amber:FindFirstChild("Handle") and amber.Name:lower():find("aure amber") then
                local player = game.Players.LocalPlayer
                if player and player.Character then
                    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        amber.Handle.CFrame = rootPart.CFrame + Vector3.new(0, 3, 0)
                    end
                end
            end
        end
        task.wait(1)
    end
end

KitsuneTab:CreateToggle({
    Name = "Auto Collect Aure Amber",
    CurrentValue = false,
    Flag = "AutoCollectAureAmber",
    Callback = function(Value)
        AutoCollectEnabled = Value
        if Value then
            coroutine.wrap(AutoCollectAureAmber)()
        end
    end
})

-- Server Hop Button
SettingsTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
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
})

Rayfield:LoadConfiguration()