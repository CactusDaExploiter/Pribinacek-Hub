-- Load Venyx UI Library
local Venyx = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Venyx-UI-Library/main/source2.lua"))()
local UI = Venyx.new({ title = "Pribinacek Hub | Forsaken" })

-- Pages
local MainPage = UI:addPage({ title = "ESP" })
local ESPSection = MainPage:addSection({ title = "ESP Settings" })
local ColorSection = MainPage:addSection({ title = "ESP Colors" })

-- Services
local Workspace = game:GetService("Workspace")
local PlayersFolder = Workspace:WaitForChild("Players")

-- Settings
local settings = {
    SurvivorESP = false,
    KillerESP = false,
    GeneratorESP = false,
    ItemESP = false,
    SurvivorColor = Color3.fromRGB(0, 255, 0),
    KillerColor = Color3.fromRGB(255, 0, 0),
    GeneratorColor = Color3.fromRGB(255, 255, 0),
    ItemColor = Color3.fromRGB(0, 255, 255)
}

local highlights = {}

-- Helper to create highlight
local function highlightObject(obj, color)
    if obj:IsA("Model") or obj:IsA("BasePart") then
        local highlight = Instance.new("Highlight")
        highlight.Adornee = obj
        highlight.FillColor = color
        highlight.OutlineColor = Color3.new(0,0,0)
        highlight.Parent = obj
        table.insert(highlights, highlight)
    end
end

-- Update all highlights
local function updateHighlights()
    -- Clear old
    for _, h in ipairs(highlights) do
        h:Destroy()
    end
    highlights = {}

    -- Survivors
    if settings.SurvivorESP then
        local folder = PlayersFolder:FindFirstChild("Survivors")
        if folder then
            for _, model in ipairs(folder:GetChildren()) do
                highlightObject(model, settings.SurvivorColor)
            end
        end
    end

    -- Killers
    if settings.KillerESP then
        local folder = PlayersFolder:FindFirstChild("Killers")
        if folder then
            for _, model in ipairs(folder:GetChildren()) do
                highlightObject(model, settings.KillerColor)
            end
        end
    end

    -- Generators
    if settings.GeneratorESP then
        local generators = Workspace:FindFirstChild("Map")
        if generators then
            local genFolder = generators:FindFirstChild("Ingame")
            if genFolder then
                local mapFolder = genFolder:FindFirstChild("Map")
                if mapFolder then
                    for _, gen in ipairs(mapFolder:GetChildren()) do
                        if gen.Name:lower():find("generator") then
                            highlightObject(gen, settings.GeneratorColor)
                        end
                    end
                end
            end
        end
    end

    -- Items (BloxyCola / MedKit)
    if settings.ItemESP then
        for _, itemName in ipairs({"BloxyCola", "MedKit"}) do
            local item = Workspace:FindFirstChild(itemName)
            if item then
                highlightObject(item, settings.ItemColor)
            end
        end
    end
end

-- Listen for new items or generators
Workspace.ChildAdded:Connect(function(obj)
    updateHighlights()
end)

-- UI Toggles
ESPSection:addToggle({ title = "Survivor ESP", callback = function(v)
    settings.SurvivorESP = v
    updateHighlights()
end})

ESPSection:addToggle({ title = "Killer ESP", callback = function(v)
    settings.KillerESP = v
    updateHighlights()
end})

ESPSection:addToggle({ title = "Generator ESP", callback = function(v)
    settings.GeneratorESP = v
    updateHighlights()
end})

ESPSection:addToggle({ title = "Item ESP", callback = function(v)
    settings.ItemESP = v
    updateHighlights()
end})

-- UI Color Pickers
ColorSection:addColorPicker({ title = "Survivor Color", default = settings.SurvivorColor, callback = function(c)
    settings.SurvivorColor = c
    if settings.SurvivorESP then updateHighlights() end
end})

ColorSection:addColorPicker({ title = "Killer Color", default = settings.KillerColor, callback = function(c)
    settings.KillerColor = c
    if settings.KillerESP then updateHighlights() end
end})

ColorSection:addColorPicker({ title = "Generator Color", default = settings.GeneratorColor, callback = function(c)
    settings.GeneratorColor = c
    if settings.GeneratorESP then updateHighlights() end
end})

ColorSection:addColorPicker({ title = "Item Color", default = settings.ItemColor, callback = function(c)
    settings.ItemColor = c
    if settings.ItemESP then updateHighlights() end
end})

-- Select default page
UI:SelectPage({ page = UI.pages[1], toggle = true })
