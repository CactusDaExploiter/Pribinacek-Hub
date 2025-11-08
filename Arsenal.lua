-- Venyx Hub | Arsenal (Fixed)
-- NOTE: This script assumes an exploit environment (Drawing, VirtualUser, etc.).
-- Use at your own risk.

-- Load Venyx UI Library
local Venyx = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Venyx-UI-Library/main/source2.lua"))()
local UI = Venyx.new({ title = "Pribinacek | Arsenal" })

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local VirtualUser = game:GetService("VirtualUser")

-- ================== CONFIG ==================
local FovColor = Color3.fromRGB(255,255,255) -- default FOV circle color

-- ================== ESP SETTINGS ==================
local espSettings = {
    BoxESP = false,
    SkeletonESP = false,
    Tracers = false,
    BoxColor = Color3.fromRGB(255,255,255),
    SkeletonColor = Color3.fromRGB(255,255,255),
    TracerColor = Color3.fromRGB(255,255,255),
    TeamCheck = true
}

-- Containers
local Boxes, Skeletons, Tracers = {}, {}, {}

-- Drawing helper
local function createDrawing(type, props)
    local obj = Drawing.new(type)
    for k,v in pairs(props) do obj[k] = v end
    return obj
end

local function clearESP(player)
    if Boxes[player] then Boxes[player]:Remove() Boxes[player] = nil end
    if Skeletons[player] then for _,line in pairs(Skeletons[player]) do line:Remove() end Skeletons[player] = nil end
    if Tracers[player] then Tracers[player]:Remove() Tracers[player] = nil end
end
Players.PlayerRemoving:Connect(clearESP)

-- ================== RENDER LOOP (ESP) ==================
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local char = player.Character
            local humanoid = char:FindFirstChild("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            if humanoid.Health > 0 and hrp and head then
                local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.4,0))
                    local footPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
                    local height = math.abs(headPos.Y - footPos.Y)
                    local width = height / 2
                    local alpha = math.clamp(1 - (hrpPos.Z / 200), 0.2, 1)

                    -- Box ESP
                    if espSettings.BoxESP then
                        if not Boxes[player] then
                            Boxes[player] = createDrawing("Square", {Thickness=2,Filled=false,Visible=true,Color=espSettings.BoxColor,Transparency=alpha})
                        end
                        local box = Boxes[player]
                        box.Size = Vector2.new(width,height)
                        box.Position = Vector2.new(hrpPos.X - width/2, headPos.Y)
                        box.Transparency = alpha
                        box.Color = espSettings.BoxColor
                        box.Visible = true
                    elseif Boxes[player] then Boxes[player].Visible = false end

                    -- Skeleton ESP
                    if espSettings.SkeletonESP then
                        if not Skeletons[player] then Skeletons[player] = {} end
                        local lines = Skeletons[player]
                        local function connect(p1,p2,index)
                            local a,b = char:FindFirstChild(p1), char:FindFirstChild(p2)
                            if not (a and b) then return end
                            local aV, aOn = Camera:WorldToViewportPoint(a.Position)
                            local bV, bOn = Camera:WorldToViewportPoint(b.Position)
                            if aOn and bOn then
                                if not lines[index] then lines[index] = createDrawing("Line",{Thickness=2}) end
                                local ln = lines[index]
                                ln.From = Vector2.new(aV.X,aV.Y)
                                ln.To = Vector2.new(bV.X,bV.Y)
                                ln.Color = espSettings.SkeletonColor
                                ln.Transparency = alpha
                                ln.Visible = true
                            elseif lines[index] then
                                lines[index].Visible = false
                            end
                        end

                        if humanoid.RigType == Enum.HumanoidRigType.R15 then
                            local i=1
                            connect("Head","UpperTorso",i);i+=1
                            connect("UpperTorso","LowerTorso",i);i+=1
                            connect("LowerTorso","LeftUpperLeg",i);i+=1
                            connect("LeftUpperLeg","LeftLowerLeg",i);i+=1
                            connect("LeftLowerLeg","LeftFoot",i);i+=1
                            connect("LowerTorso","RightUpperLeg",i);i+=1
                            connect("RightUpperLeg","RightLowerLeg",i);i+=1
                            connect("RightLowerLeg","RightFoot",i);i+=1
                            connect("UpperTorso","LeftUpperArm",i);i+=1
                            connect("LeftUpperArm","LeftLowerArm",i);i+=1
                            connect("LeftLowerArm","LeftHand",i);i+=1
                            connect("UpperTorso","RightUpperArm",i);i+=1
                            connect("RightUpperArm","RightLowerArm",i);i+=1
                            connect("RightLowerArm","RightHand",i)
                        else
                            local i=1
                            connect("Head","Torso",i);i+=1
                            connect("Torso","Left Arm",i);i+=1
                            connect("Torso","Right Arm",i);i+=1
                            connect("Torso","Left Leg",i);i+=1
                            connect("Torso","Right Leg",i)
                        end
                    elseif Skeletons[player] then
                        for _,line in pairs(Skeletons[player]) do line.Visible=false end
                    end
                else
                    clearESP(player)
                end
            else
                clearESP(player)
            end
        else
            clearESP(player)
        end
    end
end)

-- ================== UI ==================
-- ESP Page
local ESPPage = UI:addPage({title="ESP", icon=5012544693})
local ESPSection = ESPPage:addSection({title="Features"})
local ColorSection = ESPPage:addSection({title="Colors"})

ESPSection:addToggle({title="Box ESP", callback=function(v) espSettings.BoxESP=v end})
ESPSection:addToggle({title="Skeleton ESP", callback=function(v) espSettings.SkeletonESP=v end})
ESPSection:addToggle({title="Team Check", callback=function(v) espSettings.TeamCheck=v end})

ColorSection:addColorPicker({title="Box Color", default=espSettings.BoxColor, callback=function(c) espSettings.BoxColor=c end})
ColorSection:addColorPicker({title="Skeleton Color", default=espSettings.SkeletonColor, callback=function(c) espSettings.SkeletonColor=c end})

-- Combat Page
local CombatPage = UI:addPage({title="Combat", icon=5012544693})
local CombatSection = CombatPage:addSection({title="Combat"})

-- Combat Settings
local combatSettings = {
    Aimbot = false,
    FOV = 100,
    Triggerbot = false,
    TeamCheck = true,
    Smoothness = 30, -- 0 = instant, 100 = slowest (UI shows 0..100)
}

-- FOV Circle (Drawing)
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Color = FovColor
fovCircle.Filled = false
fovCircle.Visible = false
fovCircle.Transparency = 1

-- Helper: get closest target (screen-space distance to screen center)
local function getClosestTarget()
    local closest = nil
    local shortest = combatSettings.FOV
    local viewportSize = Camera.ViewportSize
    local centerPos = Vector2.new(viewportSize.X/2, viewportSize.Y/2)
    for _,player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("HumanoidRootPart") then
            if (not combatSettings.TeamCheck) or (player.Team ~= LocalPlayer.Team) then
                local head = player.Character.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - centerPos).Magnitude
                    if dist < shortest then
                        closest = player
                        shortest = dist
                    end
                end
            end
        end
    end
    return closest
end

-- Aim at target using camera CFrame (smoothness applied)
local function aimAtTarget(headPart, smoothnessPercent)
    if not headPart then return end
    local targetPos = headPart.Position
    local cam = Camera
    local current = cam.CFrame
    local targetCFrame = CFrame.new(current.Position, targetPos)

    -- Convert percent (0..100) to normalized value 0..1
    -- 0% => instant (alpha = 1), 100% => slowest (alpha small)
    local p = math.clamp(smoothnessPercent or 0, 0, 100) / 100
    local alpha = 1 - p      -- alpha in [0,1] (1 = instant, 0 = no movement)
    alpha = math.clamp(alpha, 0.01, 1) -- avoid zero / no-change
    cam.CFrame = current:Lerp(targetCFrame, alpha)
end

-- Combat Render
RunService.RenderStepped:Connect(function()
    -- Update FOV circle at screen center
    local viewportSize = Camera.ViewportSize
    local centerPos = Vector2.new(viewportSize.X/2, viewportSize.Y/2)
    fovCircle.Position = centerPos
    fovCircle.Radius = combatSettings.FOV
    fovCircle.Visible = combatSettings.Aimbot
    fovCircle.Color = FovColor

    local targetPlayer = getClosestTarget()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        local head = targetPlayer.Character.Head
        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if onScreen then
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - centerPos).Magnitude

            -- Aimbot (camera-based)
            if combatSettings.Aimbot and dist <= combatSettings.FOV then
                aimAtTarget(head, combatSettings.Smoothness)
            end

            -- Triggerbot: actually clicks the mouse via VirtualUser when the head is under the crosshair (small tolerance)
            if combatSettings.Triggerbot and dist <= 5 then
                -- Do a quick click
                VirtualUser:Button1Down(Vector2.new(0,0))
                task.wait(0.03)
                VirtualUser:Button1Up(Vector2.new(0,0))
            end
        end
    end
end)

-- Combat UI controls
CombatSection:addToggle({title="Aimbot", callback=function(v) combatSettings.Aimbot=v fovCircle.Visible=v end})
CombatSection:addSlider({title="FOV", min=50, max=500, default=100, callback=function(v) combatSettings.FOV=v fovCircle.Radius=v end})
CombatSection:addSlider({title="Smoothness (0 = instant, 100 = slow)", min=0, max=100, default=combatSettings.Smoothness, precise=true, callback=function(v) combatSettings.Smoothness=v end})
CombatSection:addToggle({title="Triggerbot", callback=function(v) combatSettings.Triggerbot=v end})
CombatSection:addToggle({title="Team Check", callback=function(v) combatSettings.TeamCheck=v espSettings.TeamCheck=v end})

CombatSection:addColorPicker({
    title = "FOV Color",
    default = FovColor,
    callback = function(c)
        FovColor = c
        fovCircle.Color = c
    end
})

-- Select first page
UI:SelectPage({page=UI.pages[1], toggle=true})
