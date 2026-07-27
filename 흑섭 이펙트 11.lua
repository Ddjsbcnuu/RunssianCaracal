local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local debris = game:GetService("Debris")
local tweenService = game:GetService("TweenService")
local plr = players.LocalPlayer
local cam = workspace.CurrentCamera

local flingT = false
local strengthV = 750

local EFFECT_MODEL_ID = "rbxassetid://86007736370622"
local SOUND_ID = "rbxassetid://119862187200315"

local EFFECT_SCALE = 30
local SOUND_VOLUME = 0.5

local STAY_TIME = 0.24
local FADE_TIME = 0.24
uis.InputBegan:Connect(function(inp, gameProcessed)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        lastLeftClickTime = tick()
    end
end)

local EffectTemplate = nil

task.spawn(function()
    local success, result = pcall(function()
        return game:GetObjects(EFFECT_MODEL_ID)[1]
    end)
    if success and result then
        EffectTemplate = result
        
        local allObjects = EffectTemplate:GetDescendants()
        table.insert(allObjects, EffectTemplate)

        for _, v in ipairs(allObjects) do
            if v:IsA("BasePart") then
                v.Anchored = true
                v.CanCollide = false
                v.CanTouch = false
                v.CanQuery = false
                v.Massless = true
            elseif v:IsA("Script") or v:IsA("LocalScript") then
                v:Destroy() 
            end
        end
    else
        warn("Nigga")
    end
end)

task.spawn(function()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "Nigga",
        LoadingTitle = "Nigga",
        LoadingSubtitle = "Nigga",
        ConfigurationSaving = { Enabled = false }
    })

    local Tab = Window:CreateTab("Nigga", 4483362458)

    Tab:CreateToggle({
        Name = "Nigga",
        CurrentValue = false,
        Flag = "ThrowToggle",
        Callback = function(Value)
            flingT = Value
        end,
    })

    Tab:CreateInput({
        Name = "Nigga",
        CurrentValue = "750",
        PlaceholderText = "Nigga",
        RemoveTextAfterFocusLost = false,
        Callback = function(Value)
            local num = tonumber(Value)
            if num then
                strengthV = num
            end
        end,
    })
end)

local function spawnBlackFlash(targetPosition, aimDirection)
    local soundPart = Instance.new("Part")
    soundPart.Name = "AudioSpeaker"
    soundPart.Transparency = 1
    soundPart.Anchored = true
    soundPart.CanCollide = false
    soundPart.CanTouch = false
    soundPart.CanQuery = false
    soundPart.Size = Vector3.new(0.1, 0.1, 0.1)
    soundPart.Position = targetPosition
    soundPart.Parent = workspace

    local hitSound = Instance.new("Sound")
    hitSound.Name = "BlackFlashHitSound"
    hitSound.SoundId = SOUND_ID
    hitSound.Volume = SOUND_VOLUME
    hitSound.RollOffMaxDistance = 1500 
    hitSound.RollOffMinDistance = 15
    hitSound.Parent = soundPart
    hitSound:Play()

    debris:AddItem(soundPart, 6)

    if not EffectTemplate then return end 

    local effectClone = EffectTemplate:Clone()

    if effectClone:IsA("Model") then
        effectClone:ScaleTo(EFFECT_SCALE)
    end

    local flatAim = Vector3.new(aimDirection.X, 0, aimDirection.Z)
    if flatAim.Magnitude > 0 then
        flatAim = flatAim.Unit
    else
        flatAim = Vector3.new(0, 0, -1)
    end

    local finalCFrame = CFrame.lookAt(targetPosition, targetPosition + flatAim)

    if effectClone:IsA("Model") then
        if not effectClone.PrimaryPart then
            local pp = Instance.new("Part")
            pp.Name = "CorePivot"
            pp.Transparency = 1
            pp.Anchored = true
            pp.CanCollide = false
            pp.Size = Vector3.new(0.1, 0.1, 0.1)
            pp.CFrame = effectClone:GetBoundingBox()
            pp.Parent = effectClone
            effectClone.PrimaryPart = pp
        end
        effectClone:PivotTo(finalCFrame)
    elseif effectClone:IsA("BasePart") then
        effectClone.CFrame = finalCFrame
    end

    effectClone.Parent = workspace

    task.spawn(function()
        task.wait(STAY_TIME) 
        
        if effectClone and effectClone.Parent then
            local fadeInfo = TweenInfo.new(FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            local allParts = effectClone:GetDescendants()
            table.insert(allParts, effectClone)
            
            for _, v in ipairs(allParts) do
                if v:IsA("BasePart") or v:IsA("Decal") then
                    tweenService:Create(v, fadeInfo, {Transparency = 1}):Play()
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                    v.Enabled = false
                elseif v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
                    tweenService:Create(v, fadeInfo, {Brightness = 0}):Play()
                end
            end
            
            debris:AddItem(effectClone, FADE_TIME + 1.0)
        end
    end)
end

function flingF()
    workspace.ChildAdded:Connect(function(model)
        if model.Name == "GrabParts" then
            local part_to_impulse = nil
            local targetName = "Unknown"
            local wasGrabbedByMe = false

            if uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or (tick() - lastLeftClickTime <= 1.5) then
                wasGrabbedByMe = true
            end

            task.spawn(function()
                for i = 1, 20 do
                    if not model.Parent then break end
                    local grabPart = model:FindFirstChild("GrabPart")
                    if grabPart then
                        local weld = grabPart:FindFirstChildOfClass("WeldConstraint")
                        if weld and weld.Part1 then
                            part_to_impulse = weld.Part1
                            local targetModel = part_to_impulse.Parent
                            targetName = targetModel and targetModel.Name or part_to_impulse.Name
                            break
                        end
                    end
                    task.wait()
                end
            end)

            task.spawn(function()
                while model.Parent do
                    if part_to_impulse and not wasGrabbedByMe then
                        local targetModel = part_to_impulse.Parent
                        local partOwner = targetModel and targetModel:FindFirstChild("PartOwner", true)
                        if partOwner and partOwner:IsA("StringValue") and partOwner.Value == plr.Name then
                            wasGrabbedByMe = true
                            break
                        end
                    end
                    task.wait(0.05)
                end
            end)
            model:GetPropertyChangedSignal("Parent"):Connect(function()
                if not model.Parent then
                    if not part_to_impulse then
                        local grabPart = model:FindFirstChild("GrabPart")
                        local weld = grabPart and grabPart:FindFirstChildOfClass("WeldConstraint")
                        if weld and weld.Part1 then
                            part_to_impulse = weld.Part1
                            local targetModel = part_to_impulse.Parent
                            targetName = targetModel and targetModel.Name or part_to_impulse.Name
                        end
                    end

                    if part_to_impulse then
                        local exactAirPosition = part_to_impulse.Position
                        
                        if flingT then
                            local connection
                            connection = uis.InputBegan:Connect(function(inp, char)
                                if inp.UserInputType == Enum.UserInputType.MouseButton2 then
                                    connection:Disconnect()
                                    local velocityObj = Instance.new("BodyVelocity")
                                    velocityObj.Parent = part_to_impulse
                                    velocityObj.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                    
                                    local flingDirection = cam.CFrame.lookVector
                                    velocityObj.Velocity = flingDirection * strengthV
                                    
                                    task.spawn(function()
                                        task.wait(0.1)
                                        if velocityObj.Parent then velocityObj:Destroy() end
                                    end)

                                    if wasGrabbedByMe then
                                        task.spawn(function()
                                            spawnBlackFlash(exactAirPosition, flingDirection)
                                        end)
                                        
                                        print("======================================")
                                        print("Nigga")
                                        print("Nigga: " .. targetName)
                                        print("======================================")
                                        
                                        wasGrabbedByMe = false
                                    end
                                end
                            end)

                            task.delay(1.5, function()
                                if connection then connection:Disconnect() end
                            end)
                        end
                    end
                end
            end)
        end
    end)
end

flingF()