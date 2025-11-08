-- Load Venyx UI Library
local Venyx = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Venyx-UI-Library/main/source2.lua"))()
local UI = Venyx.new({ title = "Pribinacek Hub | Emergency Hamburg" })

-- Pages
local VisualsPage = UI:addPage({ title = "Visuals"}) 
local ESPSection = VisualsPage:addSection({ title = "ESP Features" })
local ColorSection = VisualsPage:addSection({ title = "ESP Colors" })

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Settings
local espSettings = {
    BoxESP = false,
    SkeletonESP = false,
    Tracers = false,
    BoxColor = Color3.fromRGB(255, 255, 255),
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 255, 255)
}

-- Containers
local Boxes, Skeletons, Tracers = {}, {}, {}

-- Drawing helper
local function createDrawing(type, props)
    local obj = Drawing.new(type)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

-- Cleanup function
local function clearESP(player)
    if Boxes[player] then Boxes[player]:Remove() Boxes[player] = nil end
    if Skeletons[player] then
        for _, line in pairs(Skeletons[player]) do line:Remove() end
        Skeletons[player] = nil
    end
    if Tracers[player] then Tracers[player]:Remove() Tracers[player] = nil end
end

Players.PlayerRemoving:Connect(clearESP)

-- Render loop for ESP
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local char, humanoid = player.Character, player.Character:FindFirstChild("Humanoid")
            local hrp, head = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Head")
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
                            Boxes[player] = createDrawing("Square",{Thickness=2,Filled=false,Visible=true,Color=espSettings.BoxColor})
                        end
                        local box = Boxes[player]
                        box.Size = Vector2.new(width,height)
                        box.Position = Vector2.new(hrpPos.X-width/2,headPos.Y)
                        box.Color = espSettings.BoxColor
                        box.Transparency = alpha
                        box.Visible = true
                    elseif Boxes[player] then
                        Boxes[player].Visible = false
                    end

                    -- Skeleton ESP
                    if espSettings.SkeletonESP then
                        if not Skeletons[player] then Skeletons[player] = {} end
                        local rig = humanoid.RigType
                        local lines = Skeletons[player]
                        local function connect(p1,p2,index)
                            local a,b = char:FindFirstChild(p1), char:FindFirstChild(p2)
                            if not (a and b) then return end
                            local aV,v1 = Camera:WorldToViewportPoint(a.Position)
                            local bV,v2 = Camera:WorldToViewportPoint(b.Position)
                            if v1 and v2 then
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

                        if rig == Enum.HumanoidRigType.R15 then
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

                    -- Tracers
                    if espSettings.Tracers then
                        if not Tracers[player] then
                            Tracers[player] = createDrawing("Line",{Thickness=1.5,Color=espSettings.TracerColor})
                        end
                        local tr = Tracers[player]
                        tr.From = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y-10)
                        tr.To = Vector2.new(hrpPos.X,hrpPos.Y)
                        tr.Color = espSettings.TracerColor
                        tr.Transparency = alpha
                        tr.Visible = true
                    elseif Tracers[player] then
                        Tracers[player].Visible = false
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

-- UI Controls
ESPSection:addToggle({ title = "Box ESP", callback = function(v) espSettings.BoxESP=v end })
ESPSection:addToggle({ title = "Skeleton ESP", callback = function(v) espSettings.SkeletonESP=v end })
ESPSection:addToggle({ title = "Tracers", callback = function(v) espSettings.Tracers=v end })

ColorSection:addColorPicker({ title = "Box Color", default = espSettings.BoxColor, callback = function(c) espSettings.BoxColor=c end })
ColorSection:addColorPicker({ title = "Skeleton Color", default = espSettings.SkeletonColor, callback = function(c) espSettings.SkeletonColor=c end })
ColorSection:addColorPicker({ title = "Tracer Color", default = espSettings.TracerColor, callback = function(c) espSettings.TracerColor=c end })

UI:SelectPage({ page = UI.pages[1], toggle = true })
