if game.PlaceId ~= 301549746 then
    game.Players.LocalPlayer:Kick("Not Supported Game.")
    return
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "$oulity Hub 👻 | Counter Blox " ,
    SubTitle = "Made by dausita",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Aqua",
    MinimizeKey = Enum.KeyCode.RightShift
})

local Tabs = {
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "" }),
    Miscellanaous = Window:AddTab({ Title = "Miscellanaous", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:SetFolder("LemoniumHub")
InterfaceManager:SetFolder("LemoniumHub")

SaveManager:IgnoreThemeSettings()

Fluent:Notify({
    Title = "Notification",
    Content = "Thank You For Using This Script",
    Duration = 5
})

-- Aimbot Variables
_G.AimbotEnabled = false
_G.TeamCheck = true 
_G.AimPart = "Head"
_G.Sensitivity = 0.4 
_G.CircleRadius = 80

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Holding = false

local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = _G.CircleRadius
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = false  
FOVCircle.Transparency = 0.7
FOVCircle.Thickness = 1

local function GetClosestPlayer()
    local MaximumDistance = _G.CircleRadius
    local Target = nil

    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            if _G.TeamCheck and v.Team == LocalPlayer.Team then
                continue 
            end

            local ScreenPoint, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            if OnScreen then
                local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude

                if VectorDistance < MaximumDistance then
                    MaximumDistance = VectorDistance
                    Target = v
                end
            end
        end
    end

    return Target
end

UserInputService.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        Holding = false
    end
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()

    if Holding and _G.AimbotEnabled then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild(_G.AimPart) then
            local TargetPos = Target.Character[_G.AimPart].Position
            local CameraPos = Camera.CFrame.Position
            local Direction = (TargetPos - CameraPos).unit

            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(CameraPos, CameraPos + Direction), _G.Sensitivity)
        end
    end
end)

local AimbotToggle = Tabs.Aimbot:AddToggle("AimbotToggle", {
    Title = "Enable Aimbot",
    Default = false,
    Callback = function(state)
        _G.AimbotEnabled = state
        FOVCircle.Visible = state  -- Aimbot açıldığında FOV görünsün
    end
})

-- ESP Fonksiyonları
local HighlightInstances = {}

local function highlightCharacter(character, player)
    if not character or character:FindFirstChild("Highlight") then return end

    if player.Team and player.Team == Players.LocalPlayer.Team then return end

    local highlight = Instance.new("Highlight")
    highlight.Parent = character
    highlight.FillColor = Color3.fromRGB(128, 0, 128)  
    highlight.OutlineColor = Color3.fromRGB(128, 0, 128) 
    highlight.FillTransparency = 0.5 
    highlight.OutlineTransparency = 0 

    table.insert(HighlightInstances, highlight)
end

local function removeHighlights()
    for _, highlight in pairs(HighlightInstances) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    HighlightInstances = {}
end

local function onCharacterAdded(character, player)
    if _G.ESPToggle then
        highlightCharacter(character, player)
    end

    character:FindFirstChildOfClass("Humanoid").Died:Connect(function()
        player.CharacterAdded:Wait() 
        if _G.ESPToggle then
            highlightCharacter(player.Character, player) 
        end
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then 
        if player.Character then 
            onCharacterAdded(player.Character, player)
        end
        player.CharacterAdded:Connect(function(character)
            onCharacterAdded(character, player)
        end)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= Players.LocalPlayer then 
        player.CharacterAdded:Connect(function(character)
            onCharacterAdded(character, player)
        end)
    end
end)

-- ESP Toggle
local ESPToggle = Tabs.ESP:AddToggle("ESPToggle", {
    Title = "Enable ESP",
    Default = false,
    Callback = function(state)
        _G.ESPToggle = state
        if state then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and player.Character then
                    highlightCharacter(player.Character, player)
                end
            end
        else
            removeHighlights()
        end
    end
})

Tabs.Miscellanaous:AddSlider("fovChanger", 
{
    Title = "FOV Changer",  
    Description = "Changes your field of view",
    Default = 70,
    Min = 0,
    Max = 120,
    Rounding = 1,
    Callback = function(Value)
        _G.FovValue = Value  
        game.Workspace.CurrentCamera.FieldOfView = _G.FovValue
    end
})

local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
    if _G.FovValue then
        game.Workspace.CurrentCamera.FieldOfView = _G.FovValue  
    end
end)

Tabs.Miscellanaous:AddButton({
    Title = "Infinite Yield", 
    Description = "Opens Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end
})

Tabs.Miscellanaous:AddButton({
    Title = "Dark Dex",  
    Description = "Opens the Dark Dex",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end
})

Tabs.Settings:AddButton({
    Title = "Save Config", 
    Description = "Save your current settings to a config file",
    Callback = function()
        SaveManager:SaveConfig("MyConfig")
        print("Config saved as MyConfig.")
    end
})

Tabs.Settings:AddButton({
    Title = "Load Config", 
    Description = "Load settings from a saved config file",
    Callback = function()
        SaveManager:LoadConfig("MyConfig")
        print("Config loaded from MyConfig.")
    end
})

SaveManager:LoadAutoloadConfig()
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
