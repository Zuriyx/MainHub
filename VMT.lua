--[[
*Important*
ts is free source and i use Ai to fix sum bugs bcs im too lazy to do myself
features:
 > Fflag Executor, Save flags system, Public flags lib.
 > Shiftlock image lib.
 > Free Gamepasses: Double Page, Extra Slots, Search Bar, Get All Emotes (Limited, Free, Kill), Get All Cosmetics, Titles, Auras.
 > Utility: Legit Supa Tech, Kyoto Macro (bug), DashPath, Side Dash Assist, Auto Block.
 > Hit Effects

Just enjoy ts script ur free to use anything here to use in u scripts.
]]
--niga

--other
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local isPC = UserInputService.KeyboardEnabled

local cloneref = cloneref or clonereference or function(instance) return instance end
--Load WindUi thing
local UiLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
--First sum important stuff
--Camlock + Silent Aim
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local BASE_IMAGE_ID = "rbxassetid://125095856996538"
local PRESSED_IMAGE_ID = "rbxassetid://135803444128533"

local Settings = {
    Enabled = false,
    Draggable = false,
    TargetPart = "HumanoidRootPart",
    Mode = "Camlock",
    MaxDistance = 200
}

local targetLocked = nil
local dragging = false
local dragStart, startPos

local camGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
camGui.ResetOnSpawn = false

local movableButton = Instance.new("ImageButton")
movableButton.Size = UDim2.new(0, 60, 0, 60)
movableButton.BackgroundTransparency = 1
movableButton.Image = BASE_IMAGE_ID
movableButton.Parent = camGui
movableButton.Position = UDim2.new(0.7, 0, 0.6, 0)
movableButton.Visible = false

movableButton.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and Settings.Draggable then
        dragging = true
        dragStart = input.Position
        startPos = movableButton.Position
        movableButton.Image = PRESSED_IMAGE_ID
    end
end)

movableButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        movableButton.Image = BASE_IMAGE_ID
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        movableButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

movableButton.MouseButton1Click:Connect(function()
    Settings.Enabled = not Settings.Enabled
end)

local function getClosestTarget()
    local closest = nil
    local shortest = tonumber(Settings.MaxDistance) or math.huge
    local myChar = LocalPlayer.Character
    local cam = workspace.CurrentCamera
    
    if not cam then return nil end

    local targetStr = Settings.TargetPart
    if type(targetStr) ~= "string" or targetStr == "" then
        targetStr = "HumanoidRootPart"
    end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local part = plr.Character:FindFirstChild(targetStr)
            local hum = plr.Character:FindFirstChild("Humanoid")
            if part and hum and hum.Health > 0 then
                local dist = (part.Position - cam.CFrame.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = part
                end
            end
        end
    end

    local liveFolder = workspace:FindFirstChild("Live")
    if liveFolder then
        for _, dummy in pairs(liveFolder:GetChildren()) do
            if dummy:IsA("Model") and dummy ~= myChar and not Players:GetPlayerFromCharacter(dummy) then
                local part = dummy:FindFirstChild(targetStr)
                local hum = dummy:FindFirstChild("Humanoid")
                if part and hum and hum.Health > 0 then
                    local dist = (part.Position - cam.CFrame.Position).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = part
                    end
                end
            end
        end
    end

    return closest
end

RunService.RenderStepped:Connect(function()
    if not Settings.Enabled then
        targetLocked = nil
        return
    end

    local targetStr = Settings.TargetPart
    if type(targetStr) ~= "string" or targetStr == "" then
        targetStr = "HumanoidRootPart"
    end

    local currentTargetValid = false
    if targetLocked and targetLocked.Parent then
        local humanoid = targetLocked.Parent:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 and targetLocked.Parent:FindFirstChild(targetStr) == targetLocked then
            currentTargetValid = true
        end
    end

    if not currentTargetValid then
        targetLocked = getClosestTarget()
    end

    local cam = workspace.CurrentCamera
    if targetLocked and cam then
        if Settings.Mode == "Camlock" then
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, targetLocked.Position)
        elseif Settings.Mode == "Silent Aim" then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos = targetLocked.Position
                hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(pos.X, hrp.Position.Y, pos.Z))
            end
        end
    end
end)
--Aba + EmoteD
Players = game:GetService("Players")
RunService = game:GetService("RunService")
UIS = game:GetService("UserInputService")
TweenService = game:GetService("TweenService")
Workspace = game:GetService("Workspace")
VirtualInputManager = game:GetService("VirtualInputManager")

LocalPlayer = Players.LocalPlayer
Camera = Workspace.CurrentCamera

M1_IDLE = "rbxassetid://95534553319958"
M1_PRESS = "rbxassetid://98264188479023"
EMOTE_IDLE = "rbxassetid://83007856881977"
EMOTE_PRESS = "rbxassetid://92438163139266"

isActionActive = false
loadedAnims = {}

Settings = {
    AbaDraggable = false,
    AbaRotation = false,
    EmoteDraggable = false
}

function getCharacterAndHumanoid()
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    return Character, Humanoid
end

function stopAllAnimations()
    local _, humanoid = getCharacterAndHumanoid()
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if animator then
        pcall(function()
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end)
    end
end

function playAnimation(animationId)
    local _, humanoid = getCharacterAndHumanoid()
    if humanoid then
        local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
        local animation = loadedAnims[animationId] or Instance.new("Animation")
        if not loadedAnims[animationId] then
            animation.AnimationId = "rbxassetid://" .. tostring(animationId)
            loadedAnims[animationId] = animation
        end
        local success, track = pcall(function() return animator:LoadAnimation(animation) end)
        if success and track then
            track.Priority = Enum.AnimationPriority.Action
            track:Play()
            pcall(function() track:AdjustSpeed(1.2) end)
        end
    end
end

function turnCamera(degrees)
    if not isActionActive then
        isActionActive = true
        local character, _ = getCharacterAndHumanoid()
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function()
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(degrees), 0)
                local cameraPosition = Camera and Camera.CFrame.Position or hrp.Position + Vector3.new(0, 5, 0)
                local cameraY = cameraPosition.Y
                local offsetVector = cameraPosition - hrp.Position
                local horizontalOffset = Vector3.new(offsetVector.X, 0, offsetVector.Z)
                local rotatedOffset = CFrame.fromAxisAngle(Vector3.yAxis, math.rad(degrees)) * horizontalOffset
                local newCameraLookAt = hrp.Position + rotatedOffset
                if Camera and Camera:IsA("Camera") then
                    Camera.CFrame = CFrame.lookAt(Vector3.new(newCameraLookAt.X, cameraY, newCameraLookAt.Z), hrp.Position)
                end
            end)
        end
        isActionActive = false
    end
end

function tweenMove(direction, distance, duration)
    if not isActionActive then
        isActionActive = true
        local character, _ = getCharacterAndHumanoid()
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                CFrame = hrp.CFrame * CFrame.new(direction * distance, 0, 0)
            })
            pcall(function() 
                tween:Play() 
                tween.Completed:Wait() 
                tween:Destroy() 
            end)
        end
        isActionActive = false
    end
end

function applyBodyVelocity(directionX, distanceMultiplier, verticalForce, maxSpeed, duration)
    if not isActionActive then
        isActionActive = true
        local character, _ = getCharacterAndHumanoid()
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bodyVelocity = Instance.new("BodyVelocity")
            local velocityVector = hrp.CFrame.RightVector * directionX * distanceMultiplier + Vector3.new(0, verticalForce, 0)
            if velocityVector.Magnitude == 0 then velocityVector = Vector3.new(0, 1, 0) end
            bodyVelocity.Velocity = velocityVector.Unit * maxSpeed
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVelocity.Parent = hrp
            task.delay(duration, function() pcall(function() bodyVelocity:Destroy() end) end)
        end
        isActionActive = false
    end
end

function M1_RESET_FUNCTION()
    stopAllAnimations()
    pcall(function() playAnimation(10480793962) end)
    pcall(function() tweenMove(1, 26, 0.22) end)
    
    if Settings.AbaRotation then
        pcall(function() turnCamera(70) end)
    end
    
    task.wait(0.003)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    end)
end

function EMOTE_DASH_FUNCTION()
    stopAllAnimations()
    pcall(function() playAnimation(10480793962) end)
    pcall(function() turnCamera(90) end)
    pcall(function() applyBodyVelocity(1, 38, 8, 95, 0.27) end)
end

ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "TechButtonsGui"
ScreenGui.ResetOnSpawn = false

m1Button = Instance.new("ImageButton", ScreenGui)
m1Button.Size = UDim2.new(0, 60, 0, 60)
m1Button.Position = UDim2.new(0.7, 0, 0.6, 0)
m1Button.BackgroundTransparency = 1
m1Button.Image = M1_IDLE
m1Button.Visible = false

emoteButton = Instance.new("ImageButton", ScreenGui)
emoteButton.Size = UDim2.new(0, 60, 0, 60)
emoteButton.Position = UDim2.new(0.85, 0, 0.6, 0)
emoteButton.BackgroundTransparency = 1
emoteButton.Image = EMOTE_IDLE
emoteButton.Visible = false

function makeButtonDraggable(btn, settingKey)
    local dragToggle = false
    local dragStart = nil
    local startPos = nil

    btn.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and Settings[settingKey] then
            dragToggle = true
            dragStart = input.Position
            startPos = btn.Position
        end
    end)
    
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = false
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeButtonDraggable(m1Button, "AbaDraggable")
makeButtonDraggable(emoteButton, "EmoteDraggable")

m1Button.MouseButton1Down:Connect(function() m1Button.Image = M1_PRESS end)
m1Button.MouseButton1Up:Connect(function() m1Button.Image = M1_IDLE end)
m1Button.MouseLeave:Connect(function() m1Button.Image = M1_IDLE end)
m1Button.MouseButton1Click:Connect(function() pcall(M1_RESET_FUNCTION) end)

emoteButton.MouseButton1Down:Connect(function() emoteButton.Image = EMOTE_PRESS end)
emoteButton.MouseButton1Up:Connect(function() emoteButton.Image = EMOTE_IDLE end)
emoteButton.MouseLeave:Connect(function() emoteButton.Image = EMOTE_IDLE end)
emoteButton.MouseButton1Click:Connect(function() pcall(EMOTE_DASH_FUNCTION) end)
--Lethal
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local animId = "rbxassetid://12296113986"
local isEnabled = false
local connection = nil

local function doJump()
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.AssemblyLinearVelocity = Vector3.new(0, 64, 0)
end

local function getNearest()
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local target = nil
    local dist = math.huge
    
    local liveFolder = workspace:FindFirstChild("Live")
    if liveFolder then
        local dummy = liveFolder:FindFirstChild("Weakest Dummy")
        if dummy and dummy:FindFirstChild("HumanoidRootPart") then
            local d = (hrp.Position - dummy.HumanoidRootPart.Position).Magnitude
            if d < dist then
                target = dummy
                dist = d
            end
        end
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                target = p
                dist = d
            end
        end
    end
    
    return target
end

local function aimAssist()
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    hum.AutoRotate = false
    
    local rotConn
    rotConn = hum:GetPropertyChangedSignal("AutoRotate"):Connect(function()
        if hum.AutoRotate then
            hum.AutoRotate = false
        end
    end)
    
    local target = getNearest()
    if not target then
        rotConn:Disconnect()
        return
    end
    
    local startT = tick()
    local rsConn
    
    rsConn = RunService.RenderStepped:Connect(function()
        if tick() - startT > 0.38 then
            rsConn:Disconnect()
            rotConn:Disconnect()
            hum.AutoRotate = true
            return
        end
        
        local thrp = target:FindFirstChild("HumanoidRootPart") or (target.Character and target.Character:FindFirstChild("HumanoidRootPart"))
        if thrp then
            local pred = thrp.Position + thrp.AssemblyLinearVelocity * 0.15
            hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(pred.X, hrp.Position.Y, pred.Z))
        end
    end)
end

local function disableFeature()
    isEnabled = false
    if connection then
        connection:Disconnect()
        connection = nil
    end
end

local function enableFeature()
    isEnabled = true
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    
    connection = hum.AnimationPlayed:Connect(function(animTrack)
        if animTrack.Animation and animTrack.Animation.AnimationId == animId then
            task.wait(1.7)
            doJump()
            aimAssist()
            local comms = lp.Character:WaitForChild("Communicate")
            if comms then
                comms:FireServer({
                    Dash = Enum.KeyCode.W,
                    Key = Enum.KeyCode.Q,
                    Goal = "KeyPress",
                })
            end
        end
    end)
end
--Supa
Players = game:GetService("Players")
RunService = game:GetService("RunService")

LocalPlayer = Players.LocalPlayer
supaEnabled = false
legitHeightEnabled = false
lockTiltEnabled = false
cancelOnEvasiveEnabled = false
shakeEnabled = true
onCooldown = false
cooldownTime = 4
yOffset = 2.2
lookOffset = 0.3

connections = {}
char = nil
hum = nil
hrp = nil

function clearConnections()
    for _, conn in pairs(connections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    table.clear(connections)
end

function getClosest()
    if not hrp then return nil end
    target = nil
    minDist = 20
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj ~= char then
            s, dist = pcall(function()
                return (hrp.Position - obj.HumanoidRootPart.Position).Magnitude
            end)
            if s and dist and dist < minDist then
                target = obj
                minDist = dist
            end
        end
    end
    return target
end

function fireCommunicateMoves()
    pcall(function()
        if char and char:FindFirstChild("Communicate") then
            char.Communicate:FireServer({Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress"})
        end
    end)
    pcall(function()
        bv = nil
        for _, inst in pairs(getnilinstances()) do
            if inst.ClassName == "BodyVelocity" and inst.Name == "moveme" then
                bv = inst
                break
            end
        end
        if char and char:FindFirstChild("Communicate") then
            char.Communicate:FireServer({Goal = "delete bv", BV = bv})
        end
    end)
end

function executeSupaTech()
    if not char or not hum or not hrp then return end
    target = getClosest()
    if not target then return end
    targetHrp = target:FindFirstChild("HumanoidRootPart")
    if not targetHrp then return end
    
    oldStats = {}
    pcall(function()
        oldStats.WalkSpeed = hum.WalkSpeed
        oldStats.JumpPower = hum.JumpPower
        oldStats.PlatformStand = hum.PlatformStand
        pcall(function() oldStats.AutoRotate = hum.AutoRotate end)
    end)
    
    loopConn = nil
    function restoreStats()
        if loopConn and loopConn.Disconnect then
            pcall(function() loopConn:Disconnect() end)
        end
        pcall(function()
            if hum then
                hum.WalkSpeed = oldStats.WalkSpeed or 16
                hum.JumpPower = oldStats.JumpPower or 50
                hum.PlatformStand = oldStats.PlatformStand or false
                if oldStats.AutoRotate ~= nil then
                    pcall(function() hum.AutoRotate = oldStats.AutoRotate end)
                end
            end
            if hrp then
                hrp.Velocity = Vector3.zero
                hrp.RotVelocity = Vector3.zero
            end
        end)
    end
    
    pcall(function()
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        hum.PlatformStand = true
        pcall(function() hum.AutoRotate = false end)
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
    end)
    
    for _, obj in pairs(char:GetDescendants()) do
        if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") or obj:IsA("VectorForce") or obj:IsA("AlignPosition") or obj:IsA("AlignOrientation") or obj:IsA("LinearVelocity") or obj:IsA("AngularVelocity") then
            pcall(function() obj:Destroy() end)
        end
    end
    
    loopConn = RunService.Heartbeat:Connect(function()
        if hrp then
            pcall(function()
                hrp.Velocity = Vector3.zero
                hrp.RotVelocity = Vector3.zero
            end)
        end
        if hum then
            pcall(function() hum.WalkSpeed = 0 end)
        end
    end)
    
    pcall(fireCommunicateMoves)
    task.wait(0.2)
    
    pcall(function()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Physics) end
    end)
    
    tiltAngle = lockTiltEnabled and 0 or math.rad(60)
    
    if hrp then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(tiltAngle, 0, 0)
    end
    
    duration = lockTiltEnabled and 0.6 or 0.2
    startTime = tick()
    cframeConn = nil
    
    cancelCurrentTech = false
    targetAnimConn = nil
    targetAnimatorConn = nil
    initialTargetY = targetHrp.Position.Y
    
    if cancelOnEvasiveEnabled then
        targetHum = target:FindFirstChild("Humanoid")
        if targetHum then
            function onTargetAnim(animTrack)
                if animTrack and animTrack.Animation then
                    id = tostring(animTrack.Animation.AnimationId or "")
                    if string.find(id, "10480796021", 1, true) or string.find(id, "10491993682", 1, true) or string.find(id, "10470389827", 1, true) then
                        cancelCurrentTech = true
                    end
                end
            end
            targetAnimConn = targetHum.AnimationPlayed:Connect(onTargetAnim)
            targetAnimator = targetHum:FindFirstChildOfClass("Animator")
            if targetAnimator then
                targetAnimatorConn = targetAnimator.AnimationPlayed:Connect(onTargetAnim)
            end
        end
    end
    
    cframeConn = RunService.Heartbeat:Connect(function()
        elapsed = tick() - startTime
        
        if legitHeightEnabled and (targetHrp.Position.Y - initialTargetY > 14) then
            cancelCurrentTech = true
        end
        
        if cancelCurrentTech then
            if cframeConn and cframeConn.Disconnect then
                pcall(function() cframeConn:Disconnect() end)
            end
            return
        end
        
        if duration > elapsed then
            s, cframeCalc = pcall(function()
                pos = (targetHrp.Position - targetHrp.CFrame.LookVector * lookOffset) + Vector3.new(0, yOffset, 0)
                baseCFrame = CFrame.new(pos)
                timeRemaining = duration - elapsed
                zAngle = 0
                
                if shakeEnabled and timeRemaining > 0.055 then
                    zAngle = math.sin(tick() * 110) * 0.35
                end
                
                return baseCFrame * CFrame.Angles(tiltAngle, zAngle, 0)
            end)
            if s and cframeCalc and hrp then
                pcall(function() hrp.CFrame = cframeCalc end)
            end
        else
            if cframeConn and cframeConn.Disconnect then
                pcall(function() cframeConn:Disconnect() end)
            end
        end
    end)
    
    repeat task.wait() until duration <= (tick() - startTime) or cancelCurrentTech
    
    if targetAnimConn then pcall(function() targetAnimConn:Disconnect() end) end
    if targetAnimatorConn then pcall(function() targetAnimatorConn:Disconnect() end) end
    
    pcall(function()
        if hrp then
            endX = lockTiltEnabled and 0 or math.rad(5)
            endY = lockTiltEnabled and 0 or math.rad(-25)
            endZ = lockTiltEnabled and 0 or math.rad(-15)
            hrp.CFrame = hrp.CFrame * CFrame.Angles(endX, endY, endZ)
        end
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
    restoreStats()
end

function checkSupaCooldown()
    if not supaEnabled or onCooldown then return end
    onCooldown = true
    task.spawn(function() pcall(executeSupaTech) end)
    task.wait(cooldownTime)
    onCooldown = false
end

function onAnimationPlayed(animTrack)
    if animTrack and animTrack.Animation then
        id = tostring(animTrack.Animation.AnimationId or "")
        if string.find(id, "10503381238", 1, true) or string.find(id, "13379003796", 1, true) then
            task.delay(0.3, checkSupaCooldown)
        end
    end
end

function setupCharacter(newChar)
    clearConnections()
    char = newChar
    hum = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
    
    s, conn = pcall(function()
        return hum.AnimationPlayed:Connect(onAnimationPlayed)
    end)
    if s and conn then table.insert(connections, conn) end
    
    animator = hum:FindFirstChildOfClass("Animator")
    if animator then
        s2, conn2 = pcall(function()
            return animator.AnimationPlayed:Connect(onAnimationPlayed)
        end)
        if s2 and conn2 then table.insert(connections, conn2) end
    end
end

if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(setupCharacter)

--Kyoto
local UserInputService, VirtualInputManager, TweenService, Players = game:GetService("UserInputService"), game:GetService("VirtualInputManager"), game:GetService("TweenService"), game:GetService("Players")

local LocalPlayer, isRunning, sideDashDelay, lethalDelay, isButtonDraggable = Players.LocalPlayer, false, 2.27, 0, false

local function fireCommunicate(args)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Communicate") then
        char.Communicate:FireServer(unpack(args))
    end
end

local function simulateKey(state, keycode)
    VirtualInputManager:SendKeyEvent(state, keycode, false, game)
end

local function adjustRotation()
    local cam, char = workspace.CurrentCamera, LocalPlayer.Character
    cam.CFrame = cam.CFrame * CFrame.Angles(0, math.rad(90), 0)
    
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(90), 0)
    end
end

local function shiftCamera(amount)
    local cam = workspace.CurrentCamera
    local newPos = cam.CFrame.Position + cam.CFrame.RightVector * amount
    cam.CFrame = CFrame.new(newPos, newPos + cam.CFrame.LookVector)
end

local function runKyotoMacro()
    if isRunning then return end
    isRunning = true
    
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    
    local flowingWater = (backpack and backpack:FindFirstChild("Flowing Water")) or (char and char:FindFirstChild("Flowing Water"))
    local lethalWhirlwind = (backpack and backpack:FindFirstChild("Lethal Whirlwind Stream")) or (char and char:FindFirstChild("Lethal Whirlwind Stream"))
    
    if flowingWater then
        fireCommunicate({{Tool = flowingWater, Goal = "Console Move"}})
    end
    
    task.wait(sideDashDelay)
    
    adjustRotation()
    simulateKey(true, Enum.KeyCode.D)
    simulateKey(false, Enum.KeyCode.Q)
    simulateKey(true, Enum.KeyCode.Q)
    simulateKey(false, Enum.KeyCode.D)
    
    shiftCamera(10)
    
    if lethalDelay > 0 then
        task.wait(lethalDelay)
    end
    
    if lethalWhirlwind then
        fireCommunicate({{Tool = lethalWhirlwind, Goal = "Console Move"}})
        task.wait(1)
        fireCommunicate({{Goal = "Auto Use End", Tool = lethalWhirlwind}})
    end
    
    isRunning = false
end

local kButtonGui, kFrame, kCorner, kStroke, kButtonText = Instance.new("ScreenGui"), Instance.new("Frame"), Instance.new("UICorner"), Instance.new("UIStroke"), Instance.new("TextButton")

kButtonGui.Name = "KyotoButtonGui"
kButtonGui.ResetOnSpawn = false
kButtonGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
kButtonGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
kButtonGui.Enabled = false

kFrame.Size = UDim2.new(0, 50, 0, 50)
kFrame.Position = UDim2.new(0.5, -25, 0.5, -25)
kFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
kFrame.BorderSizePixel = 0
kFrame.Active = true
kFrame.Parent = kButtonGui

kCorner.CornerRadius = UDim.new(0.2, 0)
kCorner.Parent = kFrame

kStroke.Color = Color3.fromRGB(50, 50, 60)
kStroke.Thickness = 2
kStroke.Parent = kFrame

kButtonText.Size = UDim2.new(1, 0, 1, 0)
kButtonText.BackgroundTransparency = 1
kButtonText.Text = "K"
kButtonText.TextColor3 = Color3.fromRGB(255, 50, 50)
kButtonText.Font = Enum.Font.GothamBold
kButtonText.TextSize = 24
kButtonText.Parent = kFrame

local dragging, dragInput, dragStart, startPos

kButtonText.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        TweenService:Create(kFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 45, 0, 45)}):Play()
        
        if isButtonDraggable then
            dragging = true
            dragStart = input.Position
            startPos = kFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end
end)

kButtonText.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        TweenService:Create(kFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 50, 0, 50)}):Play()
    end
end)

kButtonText.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging and isButtonDraggable then
        local delta = input.Position - dragStart
        kFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

kButtonText.MouseButton1Click:Connect(runKyotoMacro)
--Autoblock
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local AutoBlockData = {
    isEnabled = false,
    autoM1AfterBlock = false,
    connection = nil,
    lastDetected = {},
    lastVelocity = {},
    lastPredict = {},
    normalRange = 15,
    predictThreshold = 35,
    predictCooldown = 0.01,
    detectIDs = {
        ["10469493270"]=true,["10469630950"]=true,["10469639222"]=true,["10469643643"]=true,
        ["13532562418"]=true,["13532600125"]=true,["13532604085"]=true,["13294471966"]=true,
        ["13491635433"]=true,["13296577783"]=true,["13295919399"]=true,["13295936866"]=true,
        ["13370310513"]=true,["13390230973"]=true,["13378751717"]=true,["13378708199"]=true,
        ["14004222985"]=true,["13997092940"]=true,["14001963401"]=true,["14136436157"]=true,
        ["15271263467"]=true,["15240216931"]=true,["15240176873"]=true,["15162694192"]=true,
        ["16515503507"]=true,["16515520431"]=true,["16515448089"]=true,["16552234590"]=true,
        ["17889458563"]=true,["17889461810"]=true,["17889471098"]=true,["17889290569"]=true,
        ["123005629431309"]=true,["100059874351664"]=true,["104895379416342"]=true,["134775406437626"]=true,
        ["15259161390"]=true
    }
}

local function blockAction(distance, delayTime)
    local char = LocalPlayer.Character
    if not char then return end
    local communicate = char:FindFirstChild("Communicate")
    if not communicate then return end

    communicate:FireServer({Goal = "KeyPress", Key = Enum.KeyCode.F})
    task.wait(delayTime)
    communicate:FireServer({Goal = "KeyRelease", Key = Enum.KeyCode.F})

    if AutoBlockData.autoM1AfterBlock and distance <= AutoBlockData.normalRange then
        communicate:FireServer({Goal = "LeftClick", Mobile = true})
        task.wait(0.3)
        communicate:FireServer({Goal = "LeftClickRelease", Mobile = true})
    end
end

local function spamReleases()
    local char = LocalPlayer.Character
    if not char then return end
    local communicate = char:FindFirstChild("Communicate")
    if not communicate then return end

    for i = 1, 5 do
        communicate:FireServer({Goal = "KeyRelease", Key = Enum.KeyCode.F})
        communicate:FireServer({Goal = "LeftClickRelease", Mobile = true})
        task.wait(0.01)
    end
end

local function predictIncoming(model, distance)
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local char = LocalPlayer.Character
    if not hrp or not char or not char:FindFirstChild("HumanoidRootPart") then return false end

    local now = tick()
    if AutoBlockData.lastPredict[model] and now - AutoBlockData.lastPredict[model] < AutoBlockData.predictCooldown then
        return false
    end

    local lastV = AutoBlockData.lastVelocity[model]
    local currentV = hrp.Velocity.Magnitude
    AutoBlockData.lastVelocity[model] = currentV

    if lastV and (currentV - lastV) >= AutoBlockData.predictThreshold then
        AutoBlockData.lastPredict[model] = now
        return true
    end

    local dot = hrp.CFrame.LookVector:Dot((char.HumanoidRootPart.Position - hrp.Position).Unit)
    if dot > 0.75 and distance <= 55 then
        AutoBlockData.lastPredict[model] = now
        return true
    end

    return false
end

local function stopDetection()
    if AutoBlockData.connection then
        AutoBlockData.connection:Disconnect()
        AutoBlockData.connection = nil
    end
end

local function startDetection()
    stopDetection()
    AutoBlockData.connection = RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local rootPos = char.HumanoidRootPart.Position
        local liveFolder = workspace:FindFirstChild("Live")
        if not liveFolder then return end

        for _, model in pairs(liveFolder:GetChildren()) do
            if model:IsA("Model") and model ~= char then
                local humanoid = model:FindFirstChildOfClass("Humanoid")
                local hrp = model:FindFirstChild("HumanoidRootPart")
                
                if humanoid and hrp then
                    local animator = humanoid:FindFirstChild("Animator")
                    if animator then
                        local distance = (hrp.Position - rootPos).Magnitude
                        local tracks = animator:GetPlayingAnimationTracks()
                        local foundAnim = false
                        
                        for _, track in pairs(tracks) do
                            if track.Animation and track.Animation.AnimationId then
                                local animId = track.Animation.AnimationId:match("%d+")
                                if animId then
                                    local predicted = predictIncoming(model, distance)
                                    if AutoBlockData.detectIDs[animId] and distance <= AutoBlockData.normalRange and (track.TimePosition <= 0.08 or predicted) then
                                        task.spawn(function()
                                            blockAction(distance, 0.2)
                                        end)
                                        foundAnim = true
                                        break
                                    end
                                end
                            end
                        end

                        if not foundAnim and AutoBlockData.lastDetected[model] then
                            task.spawn(spamReleases)
                            AutoBlockData.lastDetected[model] = nil
                        elseif foundAnim then
                            AutoBlockData.lastDetected[model] = true
                        end
                    end
                end
            end
        end
    end)
end
--Side Dash Assist
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local enabled = false

local REACH, AUTO_DIST = 0, 50
local BASE_SPEED, CLOSE_SPEED, CLOSE_DIST = 120, 130, 15
local DURATION, FAR_DURATION, CLOSE_DURATION = 0.23, 0.29, 0.23
local POST_LOOK, BASE_PREDICT, SIDE_BOOST, CAMERA_SMOOTH = 0.32, 0.155, 0.1, 0.091
local TOTAL_MAX_DISTANCE, DASH_DISTANCE = 26, 10
local HARD_SPEED_CAP, SOFT_BRAKE_MARGIN, SMOOTH_STOP_RATE = 130, 5.5, 45
local FAR_APPROACH_DIST, FAR_SIDE_OFFSET = 20, 5.8
local ORBIT_DISTANCE, ORBIT_FORCE = 26, 2.5
local HOVER_HEIGHT, HOVER_PULL, MAX_Y_VEL, GRAVITY_STRENGTH = 3.5, 18, 13, 28
local SLIDE_MIN_SPEED, SLIDE_STOP_SPEED, SLIDE_ROTATE_FORCE, SLIDE_SIDE_CURVE, SLIDE_BRAKE = 45, 1.5, 0.98, 0.75, 65
local CLICK_DISTANCE, CLICK_DELAY, VEL_HISTORY_SIZE = 28, 0.17, 10
local ACCEL_PREDICT_SCALE, JERK_ANGLE_THRESHOLD, JERK_PREDICT_BOOST, JERK_LERP_BOOST = 0.085, 0.55, 1.55, 18
local ANTI_LOSS_MIN_SPEED, INERTIA_COMP_SCALE, MICRO_CORR_JERK_OFFSET = 2.0, 0.18, 0.55
local NEAR_LERP_BOOST, FAR_LERP_BASE = 32, 9
local TEMPO_DECEL_THRESHOLD, TEMPO_DECEL_PREDICT, BACK_PREDICT_BOOST = 0.35, 0.6, 1.4
local SIDE_DASH_ORBIT_BOOST, HOOKDASH_STAB_ALPHA = 1.35, 0.82
local ANIM_LEFT, ANIM_RIGHT = "rbxassetid://10480793962", "rbxassetid://10480796021"

local isDashing, debounce, activeTrack = false, false, nil
local currentAnimConnection, currentRotateConnection
local activeDashId, lastAnimTime, lastAnimId = 0, 0, ""
local velocityHistories = {}
local function getPingAdaptive()
    local rawMs = 0
    pcall(function()
        rawMs = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    local level = math.clamp((rawMs - 75) / 25, 0, 4)
    return {
        pingSec = math.clamp(rawMs / 1000, 0, 0.22),
        clickDelay = CLICK_DELAY * math.max(1 - level * 0.18, 0.25),
        predictMult = 1 + level * 0.18,
        orbitForce = ORBIT_FORCE + level * 0.15,
        sideBoost = SIDE_BOOST + level * 0.04,
    }
end

local function breakShiftLock()
    pcall(function()
        UIS.MouseBehavior = Enum.MouseBehavior.Default
    end)
end

local function isDisabled(humanoid)
    if not humanoid then return true end
    local state = humanoid:GetState()
    if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Dead then return true end
    if humanoid.Health <= 0 or humanoid.PlatformStand or humanoid.Sit then return true end
    return false
end

local function pushVelocity(hrp, vel)
    if not velocityHistories[hrp] then
        velocityHistories[hrp] = {}
    end
    local hist = velocityHistories[hrp]
    table.insert(hist, { vel = vel, t = tick() })
    while #hist > VEL_HISTORY_SIZE do
        table.remove(hist, 1)
    end
end

local function getAcceleration(hrp)
    local hist = velocityHistories[hrp]
    if not hist or #hist < 2 then return Vector3.zero end
    local newest = hist[#hist]
    local oldest = hist[1]
    local dt = newest.t - oldest.t
    if dt < 0.001 then return Vector3.zero end
    local dv = newest.vel - oldest.vel
    return Vector3.new(dv.X / dt, 0, dv.Z / dt)
end

local function isJerkDetected(hrp)
    local hist = velocityHistories[hrp]
    if not hist or #hist < 2 then return false end
    local prev = Vector3.new(hist[#hist-1].vel.X, 0, hist[#hist-1].vel.Z)
    local curr = Vector3.new(hist[#hist].vel.X, 0, hist[#hist].vel.Z)
    if prev.Magnitude < 1 or curr.Magnitude < 1 then return false end
    return prev.Unit:Dot(curr.Unit) < JERK_ANGLE_THRESHOLD
end

local function isDecelDetected(hrp)
    local hist = velocityHistories[hrp]
    if not hist or #hist < 3 then return false end
    local prev = hist[#hist-2].vel
    local curr = hist[#hist].vel
    local prevM = Vector3.new(prev.X, 0, prev.Z).Magnitude
    local currM = Vector3.new(curr.X, 0, curr.Z).Magnitude
    if prevM < 1 then return false end
    return (currM / prevM) < TEMPO_DECEL_THRESHOLD
end

local function isBackDash(hrp, myHrp)
    local hist = velocityHistories[hrp]
    if not hist or #hist < 1 then return false end
    local toTarget = hrp.Position - myHrp.Position
    local flat = Vector3.new(toTarget.X, 0, toTarget.Z)
    if flat.Magnitude < 0.1 then return false end
    local vel = hist[#hist].vel
    if vel.Magnitude < 2 then return false end
    return flat.Unit:Dot(vel.Unit) > 0.45
end

local function isSideDash(hrp, myHrp)
    local hist = velocityHistories[hrp]
    if not hist or #hist < 1 then return false end
    local toTarget = hrp.Position - myHrp.Position
    local flat = Vector3.new(toTarget.X, 0, toTarget.Z)
    if flat.Magnitude < 0.1 then return false end
    local vel = hist[#hist].vel
    if vel.Magnitude < 3 then return false end
    local absDot = math.abs(flat.Unit:Dot(vel.Unit))
    return absDot < 0.35
end

local function predictPosition(hrp, basePredictTime, myHrp)
    local vel = hrp.AssemblyLinearVelocity
    local flatV = Vector3.new(vel.X, 0, vel.Z)

    pushVelocity(hrp, flatV)

    local accel = getAcceleration(hrp)
    local jerk = isJerkDetected(hrp)
    local decel = isDecelDetected(hrp)
    local backDash = myHrp and isBackDash(hrp, myHrp)
    local sideDash = myHrp and isSideDash(hrp, myHrp)

    local predictT = basePredictTime

    if jerk then predictT = predictT * JERK_PREDICT_BOOST end
    if decel then predictT = predictT * TEMPO_DECEL_PREDICT end
    if backDash then predictT = predictT * BACK_PREDICT_BOOST end

    local predicted = hrp.Position + flatV * predictT + accel * (ACCEL_PREDICT_SCALE * predictT * predictT)

    if flatV.Magnitude < ANTI_LOSS_MIN_SPEED then
        predicted = predicted:Lerp(hrp.Position, 0.7)
    end

    return Vector3.new(predicted.X, hrp.Position.Y, predicted.Z), jerk, sideDash, backDash
end

local function getNearest()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local nearest, best = nil, AUTO_DIST
    local pa = getPingAdaptive()
    local ping = pa.pingSec

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local ehrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChild("Humanoid")

            if ehrp and hum and hum.Health > 0 then
                local predicted, _ = predictPosition(ehrp, BASE_PREDICT * pa.predictMult + ping + 0.05, hrp)
                local dist = (Vector3.new(predicted.X, 0, predicted.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude

                if dist < best then
                    best = dist
                    nearest = ehrp
                end
            end
        end
    end

    if workspace:FindFirstChild("Live") then
        local dummy = workspace.Live:FindFirstChild("Weakest Dummy")
        if dummy and dummy:FindFirstChild("HumanoidRootPart") then
            local dhrp = dummy.HumanoidRootPart
            local predicted, _ = predictPosition(dhrp, BASE_PREDICT * pa.predictMult + ping + 0.05, hrp)
            local dist = (Vector3.new(predicted.X, 0, predicted.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude
            if dist < best then
                best = dist
                nearest = dhrp
            end
        end
    end

    return nearest
end

local function smoothCameraLook(target)
    if not Camera or not target then return end
    local camPos = Camera.CFrame.Position
    local targetPos = Vector3.new(target.Position.X, math.min(target.Position.Y, camPos.Y), target.Position.Z)
    local direction = targetPos - camPos
    if direction.Magnitude <= 0.001 then return end
    local blended = Camera.CFrame.LookVector:Lerp(direction.Unit, CAMERA_SMOOTH)
    Camera.CFrame = CFrame.lookAt(camPos, camPos + blended)
end

local function faceTowardEnemy(hrp, target, goRight)
    local toEnemy = target.Position - hrp.Position
    local flat = Vector3.new(toEnemy.X, 0, toEnemy.Z)
    if flat.Magnitude <= 0.01 then return end

    local forward = flat.Unit
    local right = Vector3.new(-forward.Z, 0, forward.X)
    local lookDir = goRight and (forward + right * 0.85).Unit or (forward - right * 0.85).Unit

    hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + lookDir)
end

local function getGroundY(hrp, char)
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {char}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local res = workspace:Raycast(hrp.Position, Vector3.new(0, -15, 0), rp)
    return res and res.Position.Y or nil
end

local function calcSafeYVelocity(hrp, char, currentYVel)
    local groundY = getGroundY(hrp, char)
    if groundY then
        local diff = (groundY + HOVER_HEIGHT) - hrp.Position.Y
        if diff < 0 then
            return math.clamp(diff * HOVER_PULL, -MAX_Y_VEL, 0)
        else
            return math.clamp(diff * 20, 0, MAX_Y_VEL)
        end
    end
    return math.clamp(currentYVel - GRAVITY_STRENGTH * 0.016, -MAX_Y_VEL, 2)
end

local function getDynamicSpeed(dist, progress)
    local alpha = dist <= CLOSE_DIST and 0 or math.clamp((dist - CLOSE_DIST) / 10, 0, 1)
    local speed = CLOSE_SPEED + (BASE_SPEED - CLOSE_SPEED) * alpha
    local rampUp = math.clamp(progress / 0.08, 0, 1)
    rampUp = rampUp * rampUp * (3 - 2 * rampUp)
    local slowStart = 0.82
    local smoothSlow = (1 - math.clamp((progress - slowStart) / (1 - slowStart), 0, 1)) ^ 0.72

    speed = speed * rampUp * (0.18 + smoothSlow * 0.82)
    return speed
end

local function softBrakeMultiplier(remainBudget)
    if remainBudget >= SOFT_BRAKE_MARGIN then return 1.0 end
    if remainBudget <= 0 then return 0.0 end
    local t = remainBudget / SOFT_BRAKE_MARGIN
    return t * t
end

local function doClick(char)
    local args = {{ Goal = "LeftClick", Mobile = true }}
    char:WaitForChild("Communicate"):FireServer(unpack(args))
    local releaseArgs = {{ Goal = "LeftClickRelease", Mobile = true }}
    char:WaitForChild("Communicate"):FireServer(unpack(releaseArgs))
end

local function executeDash(goRight, track)
    if not enabled or isDashing or debounce then return end

    local char = LP.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum or isDisabled(hum) then return end

    local target = getNearest()
    if not target then return end

    local startTargetDistance = (Vector3.new(target.Position.X, 0, target.Position.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude
    local currentDuration = startTargetDistance > 23 and FAR_DURATION or CLOSE_DURATION

    activeDashId += 1
    local dashId = activeDashId

    isDashing = true
    debounce = true
    hum.AutoRotate = false
    breakShiftLock()

    local startPos = hrp.Position
    local att = Instance.new("Attachment", hrp)
    local lv = Instance.new("LinearVelocity")
    lv.Attachment0 = att
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.MaxForce = math.huge
    lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    lv.Parent = hrp

    local clicked, clickStarted = false, false

    local function totalDistance() return (hrp.Position - startPos).Magnitude end

    local function cleanup()
        if dashId ~= activeDashId then return end
        activeDashId += 1
        pcall(function() lv:Destroy() end)
        pcall(function() att:Destroy() end)
        if hum.Parent then hum.AutoRotate = true end
        isDashing = false
        task.delay(0.08, function()
            if dashId + 1 == activeDashId then debounce = false end
        end)
    end

    local function shouldCancel()
        if dashId ~= activeDashId or not char.Parent or not hrp.Parent or not hum.Parent or isDisabled(hum) then return true end
        return false
    end

    local sideSign = goRight and -1 or 1
    local velocity = Vector3.zero
    local trackedPrediction = target.Position
    local smoothYVel = hrp.AssemblyLinearVelocity.Y
    local prevDesiredDir = Vector3.zero
    local conn

    conn = RunService.RenderStepped:Connect(function(dt)
        if shouldCancel() then
            conn:Disconnect()
            cleanup()
            return
        end

        if totalDistance() >= TOTAL_MAX_DISTANCE then
            velocity = velocity:Lerp(Vector3.zero, math.clamp(dt * SMOOTH_STOP_RATE, 0, 1))
            lv.VectorVelocity = Vector3.new(velocity.X, smoothYVel, velocity.Z)
            conn:Disconnect()
            cleanup()
            return
        end

        hum.AutoRotate = false
        breakShiftLock()
        smoothCameraLook(target)

        local traveled = (hrp.Position - startPos).Magnitude
        if traveled >= DASH_DISTANCE then
            conn:Disconnect()
            return
        end

        local progress = math.clamp(traveled / DASH_DISTANCE, 0, 1)
        local pa = getPingAdaptive()
        local rawPredicted, jerk, sideDash, backDash = predictPosition(target, BASE_PREDICT * pa.predictMult + pa.pingSec, hrp)
        local distToCurrent = (trackedPrediction - hrp.Position).Magnitude
        local lerpSpeed = (jerk or sideDash) and JERK_LERP_BOOST or (distToCurrent < 8.0 and NEAR_LERP_BOOST or FAR_LERP_BASE)

        trackedPrediction = trackedPrediction:Lerp(rawPredicted, math.clamp(dt * lerpSpeed, 0, 1))

        local delta = trackedPrediction - hrp.Position
        local flat = Vector3.new(delta.X, 0, delta.Z)
        local dist = flat.Magnitude

        if dist <= 0.01 then return end

        if dist <= CLICK_DISTANCE and not clickStarted then
            clickStarted = true
            local dynamicClickDelay = dist < 17 and 0.1 or 0.2
            task.delay(dynamicClickDelay, function()
                if clicked or shouldCancel() then return end
                local pa2 = getPingAdaptive()
                local latestPredicted, _ = predictPosition(target, BASE_PREDICT * pa2.predictMult + pa2.pingSec, hrp)
                local latestDist = (Vector3.new(latestPredicted.X, 0, latestPredicted.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude

                if latestDist <= CLICK_DISTANCE then
                    clicked = true
                    doClick(char)
                end
            end)
        end

        local dir = flat.Unit
        local side = Vector3.new(-dir.Z, 0, dir.X) * sideSign
        local microCorr = jerk and (side * MICRO_CORR_JERK_OFFSET) or Vector3.zero
        local orbitForceMult = sideDash and SIDE_DASH_ORBIT_BOOST or 1.0
        local orbitAlpha = dist <= ORBIT_DISTANCE and (1 - math.clamp(dist / ORBIT_DISTANCE, 0, 1)) or 0
        local orbitSide = side * ((REACH + 2.2) * orbitAlpha * pa.orbitForce * orbitForceMult)
        local offset = side * (REACH + pa.sideBoost + math.clamp(dist / 11, 0, 1.1)) + orbitSide
        local backOffset = math.clamp(dist * 0.16, 0.7, 2)

        if orbitAlpha > 0.15 then backOffset *= (1 - orbitAlpha * 0.85) end

        if dist > FAR_APPROACH_DIST then
            local farAlpha = math.clamp((dist - FAR_APPROACH_DIST) / 8, 0, 1)
            local farOffset = side * (FAR_SIDE_OFFSET * farAlpha)
            backOffset = backOffset * (1 - farAlpha * 0.7)
            offset = offset + farOffset
        end

        local finalXZ = trackedPrediction + offset - dir * backOffset + microCorr
        local final = Vector3.new(finalXZ.X, hrp.Position.Y, finalXZ.Z)
        local move = final - hrp.Position
        local moveFlat = Vector3.new(move.X, 0, move.Z)

        if moveFlat.Magnitude > 0.01 then
            local speed = getDynamicSpeed(dist, progress)
            local remain = DASH_DISTANCE - traveled
            local adaptiveCap = math.clamp((remain ^ 0.94) * 10.8, 86, BASE_SPEED + 18)
            
            speed = math.min(speed, adaptiveCap)
            speed = speed * softBrakeMultiplier(TOTAL_MAX_DISTANCE - totalDistance())
            speed = math.min(speed, HARD_SPEED_CAP)

            local desiredDir = moveFlat.Unit
            if prevDesiredDir.Magnitude > 0.01 then
                desiredDir = prevDesiredDir:Lerp(desiredDir, HOOKDASH_STAB_ALPHA)
                if desiredDir.Magnitude > 0.001 then desiredDir = desiredDir.Unit end
            end
            prevDesiredDir = desiredDir

            local myVel = hrp.AssemblyLinearVelocity
            local myFlat = Vector3.new(myVel.X, 0, myVel.Z)
            local inertiaComp = Vector3.zero
            
            if myFlat.Magnitude > 5 then
                local inertiaErr = desiredDir - myFlat.Unit * myFlat:Dot(desiredDir) / (desiredDir.Magnitude * myFlat.Magnitude + 0.001)
                inertiaComp = Vector3.new(inertiaErr.X, 0, inertiaErr.Z) * INERTIA_COMP_SCALE
            end

            local finalDesired = desiredDir + inertiaComp
            if finalDesired.Magnitude > 0.001 then finalDesired = finalDesired.Unit end

            local desired = finalDesired * speed
            local velLerpAlpha = jerk and (dt * 28) or (dt * (21 - progress * 7))
            
            velocity = velocity:Lerp(Vector3.new(desired.X, 0, desired.Z), math.clamp(velLerpAlpha, 0, 1))

            local velMag = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
            if velMag > HARD_SPEED_CAP then
                local scale = HARD_SPEED_CAP / velMag
                velocity = Vector3.new(velocity.X * scale, velocity.Y, velocity.Z * scale)
            end

            local safeY = calcSafeYVelocity(hrp, char, smoothYVel)
            smoothYVel = smoothYVel + (safeY - smoothYVel) * math.clamp(dt * 14, 0, 1)
            smoothYVel = math.clamp(smoothYVel, -MAX_Y_VEL, MAX_Y_VEL)

            lv.VectorVelocity = Vector3.new(velocity.X, smoothYVel, velocity.Z)
            faceTowardEnemy(hrp, target, goRight)
        end
    end)

    task.delay(currentDuration, function()
        if conn then conn:Disconnect() end

        local lookEnd = tick() + POST_LOOK
        local lookConn

        lookConn = RunService.RenderStepped:Connect(function()
            if shouldCancel() or tick() >= lookEnd then
                lookConn:Disconnect()
                return
            end
            smoothCameraLook(target)
        end)

        if not hrp.Parent then
            cleanup()
            return
        end

        local slideDir = Vector3.new(velocity.X, 0, velocity.Z)
        if slideDir.Magnitude > 0.01 then
            slideDir = slideDir.Unit
        else
            cleanup()
            return
        end

        local slideMag = velocity.Magnitude
        local slideVelXZ = Vector3.new(velocity.X, 0, velocity.Z)
        local slowConn

        slowConn = RunService.RenderStepped:Connect(function(dt)
            if shouldCancel() or totalDistance() >= TOTAL_MAX_DISTANCE or (track and not track.IsPlaying) then
                slideVelXZ = slideVelXZ:Lerp(Vector3.zero, math.clamp(dt * SMOOTH_STOP_RATE, 0, 1))
                lv.VectorVelocity = Vector3.new(slideVelXZ.X, smoothYVel, slideVelXZ.Z)
                if slideVelXZ.Magnitude < 1 or shouldCancel() then
                    lv.VectorVelocity = Vector3.new(0, smoothYVel, 0)
                    slowConn:Disconnect()
                    cleanup()
                end
                return
            end

            hum.AutoRotate = false
            breakShiftLock()
            smoothCameraLook(target)

            local pa = getPingAdaptive()
            local predicted, _, sideDash2, _ = predictPosition(target, BASE_PREDICT * pa.predictMult + pa.pingSec, hrp)
            local delta = predicted - hrp.Position
            local flat = Vector3.new(delta.X, 0, delta.Z)

            if flat.Magnitude > 0.01 then
                local dir = flat.Unit
                local side = Vector3.new(-dir.Z, 0, dir.X) * sideSign
                local slideRotForce = sideDash2 and (SLIDE_ROTATE_FORCE * 14) or (SLIDE_ROTATE_FORCE * 10)
                local curve = (dir + side * SLIDE_SIDE_CURVE).Unit
                
                slideDir = slideDir:Lerp(curve, math.clamp(dt * slideRotForce, 0, 1))
                faceTowardEnemy(hrp, target, goRight)
            end

            slideMag = math.max(slideMag - SLIDE_BRAKE * dt, SLIDE_MIN_SPEED)
            local effectiveMag = math.min(slideMag * softBrakeMultiplier(TOTAL_MAX_DISTANCE - totalDistance()), HARD_SPEED_CAP)
            
            slideVelXZ = slideVelXZ:Lerp(Vector3.new(slideDir.X * effectiveMag, 0, slideDir.Z * effectiveMag), math.clamp(dt * 14, 0, 1))

            if effectiveMag <= SLIDE_STOP_SPEED or slideMag <= SLIDE_STOP_SPEED then
                slideVelXZ = slideVelXZ:Lerp(Vector3.zero, math.clamp(dt * SMOOTH_STOP_RATE, 0, 1))
                lv.VectorVelocity = Vector3.new(slideVelXZ.X, smoothYVel, slideVelXZ.Z)
                if slideVelXZ.Magnitude < 0.8 then
                    lv.VectorVelocity = Vector3.new(0, smoothYVel, 0)
                    slowConn:Disconnect()
                    cleanup()
                end
                return
            end

            local safeY = calcSafeYVelocity(hrp, char, smoothYVel)
            smoothYVel = smoothYVel + (safeY - smoothYVel) * math.clamp(dt * 14, 0, 1)
            smoothYVel = math.clamp(smoothYVel, -MAX_Y_VEL, MAX_Y_VEL)

            lv.VectorVelocity = Vector3.new(slideVelXZ.X, smoothYVel, slideVelXZ.Z)
        end)
    end)
end

local function setupCharacter(char)
    if currentAnimConnection then currentAnimConnection:Disconnect() end
    if currentRotateConnection then currentRotateConnection:Disconnect() end

    local hum = char:WaitForChild("Humanoid", 10)
    if not hum then return end

    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator", hum)
    end

    currentRotateConnection = hum:GetPropertyChangedSignal("AutoRotate"):Connect(function()
        if isDashing and hum.AutoRotate then
            hum.AutoRotate = false
        end
    end)

    currentAnimConnection = animator.AnimationPlayed:Connect(function(track)
        local anim = track.Animation
        if not anim then return end

        local id = anim.AnimationId
        local now = tick()

        if id == lastAnimId and now - lastAnimTime < 0.2 then return end

        lastAnimId = id
        lastAnimTime = now

        if id == ANIM_LEFT then
            executeDash(false, track)
        elseif id == ANIM_RIGHT then
            executeDash(true, track)
        end
    end)
end

if LP.Character then
    task.spawn(function()
        setupCharacter(LP.Character)
    end)
end

LP.CharacterAdded:Connect(function(char)
    isDashing, debounce, activeTrack = false, false, nil
    activeDashId += 1
    velocityHistories = {}

    task.wait(1)
    setupCharacter(char)
end)
--Headless
local P_ = game:GetService("Players")
local T_ = game:GetService("TweenService")
local R_ = game:GetService("RunService")
local A_ = game:GetService("AvatarEditorService")
local LP = P_.LocalPlayer

local track_, h_conn, w_conn, char_conn
local weight_ = Instance.new("NumberValue")
getgenv().ZuriFreeze = false

local function stop_effect()
    getgenv().ZuriFreeze = false
    if h_conn then h_conn:Disconnect(); h_conn = nil end
    if w_conn then w_conn:Disconnect(); w_conn = nil end
    if track_ then 
        track_:Stop()
        track_:Destroy()
        track_ = nil 
    end
end

local function apply_effect(char)
    if not getgenv().ZuriFreeze then return end
    local hum = char:WaitForChild("Humanoid", 10)
    if not hum then return end
    
    if hum.RigType ~= Enum.HumanoidRigType.R6 then
        pcall(function() A_:PromptSaveAvatar(hum:GetAppliedDescription(), Enum.HumanoidRigType.R6) end)
        return
    end

    for _, v in pairs(hum:GetPlayingAnimationTracks()) do
        v:Stop(0)
        v:Destroy()
    end

    local a_ = Instance.new("Animation")
    a_.AnimationId = "rbxassetid://68433924"
    track_ = hum:LoadAnimation(a_)
    track_.Priority = Enum.AnimationPriority.Action4
    track_:Play(0, 0, 0)
    track_:AdjustSpeed(0)
    track_:AdjustWeight(0, 0)
    weight_.Value = 0

    T_:Create(weight_, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Value = 1}):Play()

    w_conn = weight_.Changed:Connect(function()
        if track_ and track_.Parent then
            pcall(function() track_:AdjustWeight(weight_.Value, 0.08) end)
        end
    end)

    h_conn = R_.Heartbeat:Connect(function()
        if not track_ or not track_.Parent or not getgenv().ZuriFreeze then return end
        track_:Play(0, 0, 0)
        track_:AdjustSpeed(0)
        track_:AdjustWeight(1, 0)
        for _, v in pairs(hum:GetPlayingAnimationTracks()) do
            if v ~= track_ and v.Priority.Value < Enum.AnimationPriority.Action4.Value then
                v:Stop(0)
            end
        end
    end)

    track_.Stopped:Connect(function()
        if getgenv().ZuriFreeze and char.Parent and track_ then
            task.defer(function()
                track_:Play(0, 0, 0)
                track_:AdjustSpeed(0)
                track_:AdjustWeight(1, 0)
            end)
        end
    end)
end
--Other
local function GetAllEmotesShit()
    local allowLimited = true
local allowKill = true
local allowVfx = true

local Var1 = game.Players.LocalPlayer
local Var2 = game:GetService("ReplicatedStorage")
local Var3 = require(Var2:WaitForChild("Emotes"))
local Var4 = require(Var2.Emotes:WaitForChild("VFX"))

local Var5 = Var3:Play(Var1.Character, nil, true, nil, true)

if Var5["BigSlash"] then
    Var5["World Cutting Slash"] = Var5["BigSlash"]
    Var5["BigSlash"] = nil
end

local Var6 = {}
for Var7, _ in pairs(Var5) do
    table.insert(Var6, Var7)
end

local realEmotesRaw = Var1:GetAttribute("Emotes") or "[]"
local ownedEmotes = game:GetService("HttpService"):JSONDecode(realEmotesRaw)
local ownedMap = {}
for _, name in ipairs(ownedEmotes) do
    ownedMap[name] = true
end

local unownedEmotes = {}
for _, name in ipairs(Var6) do
    if not ownedMap[name] then
        table.insert(unownedEmotes, name)
    end
end

local Var8 = nil
local Var9 = false
local Var10 = {}

local function Var11()
    if not Var9 then return end
    Var9 = false
    
    local Var12 = Var1.Character
    local Var13 = Var12 and Var12:FindFirstChildOfClass("Humanoid")
    if Var13 then
        Var13.WalkSpeed = 16
        Var13.JumpPower = 50
    end
    if Var12 then Var12:SetAttribute("ForcedCFrame", nil) end
    
    for _, Var14 in pairs(Var10) do
        if typeof(Var14) == "Instance" and Var14.Parent then 
            Var14:Destroy() 
        elseif typeof(Var14) == "RBXScriptConnection" then
            Var14:Disconnect()
        end
    end
    Var10 = {}
    
    if Var8 then Var8:Stop() Var8:Destroy() Var8 = nil end
end

local function Var15(Var16)
    local Var17 = Var1.Character
    local Var18 = Var17 and Var17:FindFirstChildOfClass("Humanoid")
    if not Var18 then return end
    
    local Var19 = Var5[Var16]
    if not Var19 then return end

    if not allowKill and Var19.KillEmote then
        return
    end
    
    if not allowLimited and (Var19.IsLimited or Var19.GamepassId or Var19.LimitedAura) then
        return
    end

    Var11()
    Var9 = true
    Var18.WalkSpeed = 0
    Var18.JumpPower = 0

    local Var20 = {}
    local Var21 = {interrupted = false}
    local Var22 = Instance.new("Folder")

    local Var23 = Instance.new("Animation")
    Var23.AnimationId = "rbxassetid://" .. (Var19.Animation or "")
    Var8 = Var18:LoadAnimation(Var23)
    
    local Var24 = Var16:lower()
    Var8.Looped = Var19.Looped or Var24:find("idle") or Var24:find("loop") or Var24:find("pose") or Var24:find("rest") or false
    Var8:Play()
    
    task.spawn(function()
        while Var9 and task.wait() do
            if Var18.MoveDirection.Magnitude > 0 or Var17:GetAttribute("Dashing") or Var17:GetAttribute("Dash") then
                Var21.interrupted = true
                Var11()
                break
            end
        end
    end)

    if Var19.Startup then
        task.spawn(function()
            pcall(function() Var19.Startup(Var10, Var8, Var20, Var19, Var21, Var22) end)
        end)
    end
    
    if allowVfx then
        task.spawn(function()
            pcall(function()
                local Var25 = Instance.new("Accessory", Var17)
                Var25.Name = "LocalVFX"
                table.insert(Var10, Var25)
                
                local Var26 = (Var16 == "World Cutting Slash" and "HugeSlash" or Var16)
                local Var27 = Var2.Emotes.VFX
                local Var28 = Var27:FindFirstChild("RealAssets") and Var27.RealAssets:FindFirstChild(Var26) 
                              or Var27:FindFirstChild("VfxMods") and Var27.VfxMods:FindFirstChild(Var26) 
                              or Var27
                
                Var4:MainFunction({
                    Character = Var17,
                    vfxName = Var26,
                    SpecificModule = Var28,
                    AnimSent = tonumber(Var19.Animation),
                    RealBind = Var25,
                    CanRotate = true,
                    DirectData = Var19
                })
            end)
        end)
    end

    if Var19.Keyframes then
        for Var29, Var30 in pairs(Var19.Keyframes) do
            local Var31 = Var8:GetMarkerReachedSignal(Var29):Connect(function()
                if Var9 and not Var21.interrupted then
                    task.spawn(function()
                        pcall(function() Var30(Var20, Var10, Var8, Var21) end)
                    end)
                end
            end)
            table.insert(Var10, Var31)
        end
    end

    if Var19.Sounds then
        for Var32, Var33 in pairs(Var19.Sounds) do
            task.delay(tonumber(Var32) or 0, function()
                if Var9 and not Var21.interrupted then
                    local Var34 = Instance.new("Sound")
                    Var34.SoundId = Var33.SoundId
                    Var34.Volume = Var33.Volume or 1
                    Var34.Looped = Var33.Looped or false
                    Var34.Parent = Var33.ParentTorso and Var17:FindFirstChild("Torso") or Var17.PrimaryPart
                    Var34:Play()
                    table.insert(Var10, Var34)
                    if not Var34.Looped then game.Debris:AddItem(Var34, Var34.TimeLength + 2) end
                end
            end)
        end
    end

    local Var35
    Var35 = Var8.Stopped:Connect(function()
        if Var9 and not Var8.Looped then Var11() end
    end)
    table.insert(Var10, Var35)
end

game:GetService("UserInputService").JumpRequest:Connect(function()
    if Var9 then Var11() end
end)

task.spawn(function()
    while task.wait(0.2) do
        local Var36 = Var1.PlayerGui:FindFirstChild("Emotes")
        if not Var36 then continue end
        local Var37 = Var36:FindFirstChild("ImageLabel")
        if not Var37 then continue end

        for Var38 = 1, 8 do
            local Var39 = Var37:FindFirstChild(tostring(Var38))
            local Var40 = Var39 and Var39:FindFirstChild("Button")
            
            if Var40 and not Var40:GetAttribute("HookedUp") then
                Var40:SetAttribute("HookedUp", true)
                Var40.InputBegan:Connect(function(Var41)
                    if Var41.UserInputType == Enum.UserInputType.MouseButton1 or Var41.UserInputType == Enum.UserInputType.Touch then
                        local Var42 = Var39:GetAttribute("Emote")
                        if Var42 then Var15(Var42) end
                    end
                end)
            end
        end
    end
end)

task.spawn(function()
    local EmotesGui = Var1.PlayerGui:WaitForChild("Emotes", 15)
    if not EmotesGui then return end
    local LocalScript = EmotesGui:WaitForChild("LocalScript", 5)
    if not LocalScript then return end
    local MainContainer = LocalScript:WaitForChild("ScrollingFrame", 5)
    if not MainContainer then return end
    local RealScroll = MainContainer:WaitForChild("ScrollingFrame", 5)
    if not RealScroll then return end
    local TemplateButton = LocalScript:WaitForChild("TextButton", 5)
    if not TemplateButton then return end

    local UnownedContainer = MainContainer:Clone()
    UnownedContainer.Name = "UnownedMainContainer"
    UnownedContainer.Parent = MainContainer.Parent
    
    local origPos = MainContainer.Position
    local origSize = MainContainer.Size
    
    UnownedContainer.Position = UDim2.new(
        origPos.X.Scale + origSize.X.Scale + 0.02, 
        origPos.X.Offset + origSize.X.Offset + 10, 
        origPos.Y.Scale, 
        origPos.Y.Offset
    )
    
    MainContainer:GetPropertyChangedSignal("Parent"):Connect(function()
        UnownedContainer.Parent = MainContainer.Parent
    end)
    MainContainer:GetPropertyChangedSignal("Visible"):Connect(function()
        UnownedContainer.Visible = MainContainer.Visible
    end)
    UnownedContainer.Visible = MainContainer.Visible

    local UnownedScroll = UnownedContainer:WaitForChild("ScrollingFrame", 5)
    if not UnownedScroll then return end
    
    for _, child in ipairs(UnownedScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _, emoteName in ipairs(unownedEmotes) do
        local btn = TemplateButton:Clone()
        btn.Text = emoteName
        btn.Name = emoteName .. "em"
        btn.Visible = true
        btn.Parent = UnownedScroll

        btn.MouseButton1Click:Connect(function()
            local slotNum = tonumber(MainContainer:GetAttribute("Number") or 1)
            
            MainContainer.Parent = LocalScript
            UnownedContainer.Parent = LocalScript
            
            local ImageLabel = EmotesGui:WaitForChild("ImageLabel")
            for i = 1, 8 do
                local slotFrame = ImageLabel:FindFirstChild(tostring(i))
                if slotFrame then
                    slotFrame.Visible = true
                end
            end

            pcall(function()
                shared.sfx({
                    SoundId = "rbxassetid://6493287948",
                    Volume = 0.65,
                    Parent = workspace
                }):Play()
            end)

            local slotFrame = ImageLabel:FindFirstChild(tostring(slotNum))
            if slotFrame then
                slotFrame:SetAttribute("Emote", emoteName)
                
                local nameLabel = slotFrame:FindFirstChild("EmoteName")
                if nameLabel then
                    nameLabel.Text = emoteName
                end
                
                local propertyLabel = slotFrame:FindFirstChild("EmoteProperty")
                if propertyLabel then
                    propertyLabel.Text = "Unowned (Mod)"
                    propertyLabel.Visible = true
                end
            end

            pcall(function()
                Var1.Character.Communicate:FireServer({
                    Goal = "EmoteLoadout",
                    Emote = emoteName,
                    Loadout = slotNum
                })
            end)
        end)
    end

    local ListLayout = UnownedScroll:FindFirstChildOfClass("UIListLayout")
    if ListLayout then
        UnownedScroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            UnownedScroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
        end)
    end

    local UnownedSearch = UnownedContainer:WaitForChild("Framechh", 5)
    if UnownedSearch then
        local UnownedTextBox = UnownedSearch:WaitForChild("TextBox", 5)
        if UnownedTextBox then
            UnownedTextBox.Text = ""
            UnownedTextBox:GetPropertyChangedSignal("Text"):Connect(function()
                local Text = string.lower(UnownedTextBox.Text)
                local len = string.len(Text)
                
                for _, v in pairs(UnownedScroll:GetChildren()) do
                    if v:IsA("TextButton") then
                        local isMatch = false
                        local btnName = string.lower(v.Name)
                        
                        if string.sub(btnName, 1, len) == Text then
                            isMatch = true
                        end
                        
                        local words = v.Name:split(" ")
                        if #words > 1 then
                            for _, word in pairs(words) do
                                if string.sub(string.lower(word), 1, len) == Text then
                                    isMatch = true
                                    break
                                end
                            end
                        end
                        v.Visible = isMatch
                    end
                end
            end)
        end
    end
end)
end

local function GetAllCosmeticShit()
    local Var1 = game.Players.LocalPlayer
local Var2 = require(game.ReplicatedStorage.Info)

local Var3 = Var1.PlayerGui:FindFirstChild("Cosmetics", true)
if Var3 then
    Var3 = Var3:FindFirstChild("Frame")
end

if not Var3 then 
    return 
end

local Var4 = Var3:WaitForChild("AccessoriesSF")
local Var5 = Var3:WaitForChild("AurasSF")
local Var6 = Var4:WaitForChild("Frame")
local Var7 = Var3:WaitForChild("TitlesSF"):WaitForChild("Frame")

Var7.Parent = script
Var6.Parent = script

Var1:WaitForChild("LoadedData")
task.wait()
Var1:WaitForChild("GamepassesLoaded", 5)

if not Var1:GetAttribute("AllowedTitles") then
    local Var_t = tick()
    repeat
        task.wait()
    until tick() - Var_t > 5 or Var1:GetAttribute("AllowedTitles")
end

local Var8 = Var2.CosmeticProducts

function shared.cosgui()
    local Var_u = Var3.Parent
    if not Var_u.Enabled then
        local Var_g = Var1.PlayerGui:GetChildren()
        Var1.Character.Communicate:FireServer({
            Goal = "Delete Guis",
            guis = Var_g,
            caller = Var3
        })
        for _, v in pairs(Var_g) do
            if v.Name == "Cape Customization" or v.Name == "Awakening Outfit" or v.Name == "Kill Sound" then
                game:GetService("Debris"):AddItem(v, 0)
            end
            if (v.Name == "Emotes" or v.Name == "Gifting") and v ~= Var3.Parent then
                local Var_n = v:FindFirstChild("ImageLabel") or v:FindFirstChild("Frame")
                if Var_n then
                    Var_n.Visible = true
                    Var_n.Visible = false
                end
            end
        end
    end
    Var_u.Enabled = not Var_u.Enabled
end

local Var9 = table.clone(Var2.Cosmetics)
local Var10 = {}

local function Var_setup(Var_n, Var_d)
    local Var_s = "<font color=\"rgb(%s, %s, %s)\">%s</font>"
    game:GetService("TweenService"):Create(Var_n.ImageLabel, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        ImageColor3 = Color3.new(1, 1, 1)
    }):Play()

    local Var_st = string.format(Var_s, 143, 204, 140, "%s")

    if Var1.Character and Var1.Character:GetAttribute("WC_" .. string.gsub(Var_d[1], " ", "")) then
        game:GetService("TweenService"):Create(Var_n.ImageLabel, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
            ImageColor3 = Color3.new(1, 1, 1)
        }):Play()
    else
        game:GetService("TweenService"):Create(Var_n.ImageLabel, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
            ImageColor3 = Color3.new(0.35, 0.35, 0.35)
        }):Play()
    end

    Var_n.ImageLabel.Image = Var_d[3] or "rbxassetid://16523852699"
    Var_n.Info.Info.Text = string.format(Var_st, "UNLOCKED")
end

for _, v in pairs(Var9) do
    local Var_c = Var6:Clone()
    table.insert(Var10, { Var_c, v })
    Var_setup(Var_c, v)
    Var_c.Info.Text = string.format("<font size=\"30\">%s</font>", v[1])

    Var_c.ImageButton.MouseButton1Click:Connect(function()
        if Var1.Character and Var1.Character:FindFirstChild("Communicate") then
            shared.sfx({SoundId = "rbxassetid://6895079853", Volume = 0.5, Parent = workspace}):Play()
            Var1.Character.Communicate:FireServer({
                Goal = "Wear Cosmetic",
                cosmetic = v[1]
            })
        end
    end)
    Var_c.Parent = v[4] == "cosmetic" and Var4 or Var5
end

local function Var_ref()
    for _, v in pairs(Var10) do Var_setup(v[1], v[2]) end
end

Var1:GetAttributeChangedSignal("TotalKillsFrb"):Connect(Var_ref)
Var1:GetAttributeChangedSignal("Update"):Connect(Var_ref)
Var1:GetAttributeChangedSignal("HandlerLoaded"):Connect(Var_ref)
Var1:GetAttributeChangedSignal("CosmeticGamepass"):Connect(Var_ref)

for _, v in pairs(Var3:GetChildren()) do
    if v:IsA("ScrollingFrame") then
        local Var_l = v:FindFirstChildOfClass("UIGridLayout") or v:FindFirstChildOfClass("UIListLayout")
        v.CanvasSize = UDim2.new(0, 0, 0, Var_l.AbsoluteContentSize.Y)
        Var_l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            v.CanvasSize = UDim2.new(0, 0, 0, Var_l.AbsoluteContentSize.Y)
        end)
    end
    if v:IsA("TextButton") then
        v.MouseButton1Click:Connect(function()
            local Var_sub = string.sub(v.Text, 2, #v.Text):lower()
            local Var_trg = Var3:FindFirstChild(string.sub(v.Text, 1, 1):upper() .. Var_sub .. "SF")
            for _, o in pairs(Var3:GetChildren()) do
                if o:IsA("ScrollingFrame") and o ~= Var_trg then o.Visible = false end
            end
            if Var_trg and not Var_trg.Visible then
                Var_trg.Visible = true
                shared.sfx({SoundId = "rbxassetid://15675032796", Volume = 0.5, Parent = workspace}):Play()
            end
        end)
    end
end

local function Var_tit()
    local Var_ts = Var3:FindFirstChild("TitlesSF")
    if not Var_ts then return end
    for _, e in pairs(Var_ts:GetChildren()) do
        if not (e:IsA("UIGridLayout") or e:IsA("UIListLayout")) then e:Destroy() end
    end
    for _, p in pairs(Var8) do if p.button then p.button.Visible = true end end

    local Var_un = {}
    if Var2.TitleDescriptions then
        for n, _ in pairs(Var2.TitleDescriptions) do Var_un[n] = true end
    end

    for n, _ in pairs(Var_un) do
        local Var_nt = Var7:Clone()
        Var_nt.UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(125, 255, 129))})
        Var_nt.Title.Text = n
        Var_nt.Description.Text = Var2.TitleDescriptions[n] or "Special Title"
        Var_nt.Parent = Var_ts

        Var_nt.Button.MouseButton1Click:Connect(function()
            shared.sfx({SoundId = "rbxassetid://552900451", Volume = 0.5, Parent = workspace}):Play()
            local Var_curr = game:GetService("HttpService"):JSONDecode(Var1:GetAttribute("AllowedTitles") or "{}")
            Var_curr[n] = not Var_curr[n]
            
            local Var_pld = {}
            for k, st in pairs(Var_curr) do if st then Var_pld[k] = true end end
            
            Var1.Character.Communicate:FireServer({Goal = "Update Titles", Title = game:GetService("HttpService"):JSONEncode(Var_pld)})
        end)
    end
end

Var1:GetAttributeChangedSignal("StoredTitles"):Connect(Var_tit)
Var_tit()

local Var_blk = Var3:FindFirstChild("Bulk") or Var3.Parent:FindFirstChild("Bulk")
if Var_blk then
    local Var_btn = Var_blk.ImageButton
    Var_btn.Name = "GP"
    Var_btn.Parent = script
    for _, p in pairs(Var8) do
        local Var_inf = game:GetService("MarketplaceService"):GetProductInfo(p.id, Enum.InfoType.Product)
        local Var_nb = Var_btn:Clone()
        Var_nb.Visible = false
        Var_nb.Parent = Var_blk
        Var_nb.Spin.Text = string.format("<font size=\"45\">%s SPINS</font>\n<font size=\"35\">%s ROBUX</font>", p.count, Var_inf.PriceInRobux)
        Var_nb.MouseButton1Click:Connect(function()
            Var1.Character.Communicate:FireServer({Goal = "Prompt Cosmetic", Id = p.id})
        end)
        p.button = Var_nb
    end
end
end
--ArcadeFont
UiLib:SetFont("rbxassetid://12187371840")
--MainWin
local MainWindow = UiLib:CreateWindow({
    Title = "VMT hub 1.3",
    Desc = "Made by Zuri",
    Icon = "",
    Theme = "Violet",
    Colors = {
        Background = Color3.fromHex("#000000"),
        Panel = Color3.fromHex("#111111"),
        Text = Color3.fromHex("#FFFFFF"),
        Accent = Color3.fromHex("#555555"),
        Outline = Color3.fromHex("#222222")
    }
})
--Mobile Opem button
MainWindow:EditOpenButton({
    Title = "VMT hub",
    Icon = "",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("222222"), Color3.fromHex("555555")),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true
})
--DiscordTab
local discordIconPath = "VMT_DiscordIcon.png"
if not (isfile and isfile(discordIconPath)) then
    if writefile then
        local suc, res = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/github/explore/4b17bd9c0a6b7c5264b361bb54e47767357dd145/topics/discord/discord.png")
        if suc then writefile(discordIconPath, res) end
    end
end
local discordImg = (isfile and isfile(discordIconPath) and getcustomasset) and getcustomasset(discordIconPath) or "rbxassetid://106831036033040"

local InfoTab = MainWindow:Tab({ Title = "Info", Icon = "info" })

InfoTab:Paragraph({
    Title = "Support us!!!",
    Desc = "Join our Discord server to support my small community",
    Image = discordImg,
    ImageSize = 64,
    Buttons = {
        {
            Title = "Copy Discord link", --Plz join to my discord bro
            Callback = function()
                if setclipboard then
                    setclipboard("https://discord.gg/ZXSuYC3upG")
                end
            end
        }
    }
})
--fflagtab
local FFlagTab = MainWindow:Tab({ Title = "Fflag executor", Icon = "code" })
local SystemSection = FFlagTab:Section({ Title = "System" })

local exeMode = "Json"
SystemSection:Dropdown({
    Title = "Mode",
    Values = {"Json", "RAW/URL"},
    Value = "Json",
    Callback = function(v) exeMode = v end
})

local flagName = ""
SystemSection:Input({
    Title = "Set name",
    Callback = function(v) flagName = v end
})

local flagInput = ""
SystemSection:Input({
    Title = "Input FFlag Data",
    Type = "Textarea",
    Callback = function(v) flagInput = v end
})

local function setFlg(flgNam, flgVal)
    local clnNam = flgNam:gsub("^DFFlag", ""):gsub("^FFlag", ""):gsub("^DFInt", ""):gsub("^FInt", ""):gsub("^DFString", ""):gsub("^FString", "")
    pcall(function() setfflag(tostring(clnNam), tostring(flgVal)) end)
end

local function lodFlg(jsnDat)
    local suc, dec = pcall(HttpService.JSONDecode, HttpService, jsnDat)
    if not suc then return end
    for n, v in pairs(dec) do
        setFlg(n, v)
    end
end

SystemSection:Button({
    Title = "Execute",
    Callback = function()
        if exeMode == "Json" then
            lodFlg(flagInput)
        elseif exeMode == "RAW/URL" then
            local suc, res = pcall(game.HttpGet, game, flagInput)
            if suc then lodFlg(res) end
        end
    end
})

local savePath = "VMTHub_SavedFlags.json"
local savedFlags = {}

if isfile and isfile(savePath) then
    local suc, data = pcall(function() return HttpService:JSONDecode(readfile(savePath)) end)
    if suc and type(data) == "table" then
        savedFlags = data
    end
end

local function saveToDisk()
    if writefile then
        writefile(savePath, HttpService:JSONEncode(savedFlags))
    end
end

local SavedSection = FFlagTab:Section({ Title = "Saved fflags" })
local selectedSaved = "None"

local savedDropdown = SavedSection:Dropdown({
    Title = "Select saved",
    Values = {"None"},
    Value = "None",
    Callback = function(v) selectedSaved = v end
})

local function refreshSavedDropdown()
    local list = {"None"}
    for k, _ in pairs(savedFlags) do
        table.insert(list, k)
    end
    savedDropdown:Refresh(list)
end

refreshSavedDropdown()

SystemSection:Button({
    Title = "Save",
    Callback = function()
        if flagName ~= "" and flagInput ~= "" then
            savedFlags[flagName] = { Type = exeMode, Data = flagInput }
            saveToDisk()
            refreshSavedDropdown()
        end
    end
})

SavedSection:Button({
    Title = "Execute",
    Callback = function()
        if selectedSaved ~= "None" and savedFlags[selectedSaved] then
            local fData = savedFlags[selectedSaved]
            if fData.Type == "Json" then
                lodFlg(fData.Data)
            elseif fData.Type == "RAW/URL" then
                local suc, res = pcall(game.HttpGet, game, fData.Data)
                if suc then lodFlg(res) end
            end
        end
    end
})

local GlobalSection = FFlagTab:Section({ Title = "Global fflags" })
local globalFlagsList = {"None"}
local globalFlagsData = {}
local selectedGlobal = "None"

local globalDropdown = GlobalSection:Dropdown({
    Title = "Community Flags",
    Values = globalFlagsList,
    Value = "None",
    Callback = function(v) selectedGlobal = v end
})

task.spawn(function()
    local suc, res = pcall(game.HttpGet, game, "https://api.github.com/repos/Zuriyx/Global-fflags/contents/")
    if suc then
        local suc2, dec = pcall(HttpService.JSONDecode, HttpService, res)
        if suc2 and type(dec) == "table" then
            for _, file in ipairs(dec) do
                if file.type == "file" and (file.name:sub(-5) == ".json" or file.name:sub(-4) == ".txt") then
                    local name = file.name:gsub("%.json$", ""):gsub("%.txt$", "")
                    table.insert(globalFlagsList, name)
                    globalFlagsData[name] = file.download_url
                end
            end
            globalDropdown:Refresh(globalFlagsList)
        end
    end
end)

GlobalSection:Button({
    Title = "Execute Global",
    Callback = function()
        if selectedGlobal ~= "None" and globalFlagsData[selectedGlobal] then
            local url = globalFlagsData[selectedGlobal]
            local suc, res = pcall(game.HttpGet, game, url)
            if suc then
                lodFlg(res)
            end
        end
    end
})
--Shiflocktab
local ModifierTab = MainWindow:Tab({ Title = "Shiftlock Modifier", Icon = "mouse-pointer" })
local ConfigSection = ModifierTab:Section({ Title = "Configuration" })

local player = game:GetService("Players").LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local shiftlock = gui:WaitForChild("MobileShiftlockCursor", 5)
local cursor = shiftlock and shiftlock:FindFirstChild("CursorImage")
local originalImage = cursor and cursor.Image or "rbxassetid://15444391295"
local finalImage = ""
local isOverriding = false

if cursor then
    cursor:GetPropertyChangedSignal("Image"):Connect(function()
        if isOverriding and cursor.Image ~= finalImage then
            cursor.Image = finalImage
        end
    end)
end

local function applyShiftlock(imgUrl, assetName)
    if not cursor then return end
    isOverriding = true
    if imgUrl:match("^http") then
        if isfile and isfile(assetName) then
            finalImage = getcustomasset(assetName)
        else
            local suc, imgData = pcall(game.HttpGet, game, imgUrl)
            if suc and writefile and isfile then
                writefile(assetName, imgData)
                finalImage = getcustomasset(assetName)
            else
                finalImage = imgUrl
            end
        end
    else
        finalImage = imgUrl
    end
    cursor.Image = finalImage
end

ConfigSection:Button({
    Title = "Reset",
    Callback = function()
        isOverriding = false
        if cursor then
            cursor.Image = originalImage
        end
    end
})

local repoFiles = {}
local loading = false
local loadIndex = 1

local function fetchRepoFiles()
    if #repoFiles > 0 or loading then return true end
    loading = true
    local suc, res = pcall(game.HttpGet, game, "https://api.github.com/repos/Zuriyx/Shiftlock/contents/")
    loading = false
    if suc then
        local suc2, dec = pcall(HttpService.JSONDecode, HttpService, res)
        if suc2 and type(dec) == "table" then
            for _, file in ipairs(dec) do
                if file.type == "file" and (file.name:sub(-4) == ".png" or file.name:sub(-4) == ".jpg" or file.name:sub(-5) == ".jpeg") then
                    table.insert(repoFiles, file)
                end
            end
            return true
        end
    end
    return false
end

ConfigSection:Button({
    Title = "Load Library (5 images)",
    Callback = function()
        task.spawn(function()
            local ready = fetchRepoFiles()
            if not ready or #repoFiles == 0 then return end
            
            local max = math.min(loadIndex + 4, #repoFiles)
            for i = loadIndex, max do
                local file = repoFiles[i]
                local name = file.name:gsub("%.png$", ""):gsub("%.jpg$", ""):gsub("%.jpeg$", "")
                local url = file.download_url
                local assetName = "sl_" .. file.name
                local dateStr = os.date("%Y-%m-%d")
                
                local localImg = url
                if isfile and writefile and getcustomasset then
                    if not isfile(assetName) then
                        pcall(function() writefile(assetName, game:HttpGet(url)) end)
                    end
                    if isfile(assetName) then
                        localImg = getcustomasset(assetName)
                    end
                end

                ConfigSection:Paragraph({
                    Title = name,
                    Desc = "Date: " .. dateStr,
                    Image = localImg,
                    ImageSize = 64,
                    Buttons = {
                        {
                            Title = "Set Shiftlock",
                            Callback = function()
                                applyShiftlock(url, assetName)
                            end
                        }
                    }
                })
            end
            
            loadIndex = max + 1
            if loadIndex > #repoFiles then
                loadIndex = 1
            end
        end)
    end
})
--FreeStufftab
local GamepassTab = MainWindow:Tab({ Title = "Free Gamepasses", Icon = "person-standing" })
local GamepassSection = GamepassTab:Section({ Title = "Unlock Gamepasses" })

GamepassSection:Button({
    Title = "Unlock VIP Server Owner",
    Callback = function()
        workspace:SetAttribute("VIPServer", tostring(game.Players.LocalPlayer.UserId))
        workspace:SetAttribute("VIPServerOwner", game.Players.LocalPlayer.Name)
    end
})

GamepassSection:Button({
    Title = "Unlock Extra Slots",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        game:GetService("RunService").RenderStepped:Connect(function()
            if player then
                player:SetAttribute("ExtraSlots", true)
            end
        end)
    end
})

GamepassSection:Button({
    Title = "Unlock Emote Search Bar",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        game:GetService("RunService").RenderStepped:Connect(function()
            if player then
                player:SetAttribute("EmoteSearchBar", true)
            end
        end)
    end
})

GamepassSection:Button({
    Title = "Unlock Extra Emote Pages",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        game:GetService("RunService").RenderStepped:Connect(function()
            if player then
                player:SetAttribute("EmotePages", true)
            end
        end)
    end
})

local GamepassSection = GamepassTab:Section({ Title = "Unlock Cosmetics" })

GamepassSection:Button({
    Title = "Unlock All Emotes (V2)",
    Callback = function()
        GetAllEmotesShit()
    end
})

GamepassSection:Button({
    Title = "Unlock All Tittles, Cosmetics & Auras.",
    Callback = function()
        GetAllCosmeticShit()
    end
})
--Techs stuff
MainWindow:Section({
    Title = "Local Techs"
})
--Supa
local LocalTechsTab = MainWindow:Tab({ Title = "Legit Supa (Beta)", Icon = "cpu" })

local SupaSection = LocalTechsTab:Section({ Title = "Supa Tech V2" })

local supaToggle = SupaSection:Toggle({
    Title = "Enable Supa Tech",
    Value = false,
    Callback = function(state)
        supaEnabled = state
    end
})

SupaSection:Keybind({
    Title = "Toggle Keybind",
    Value = "None",
    Callback = function()
        supaEnabled = not supaEnabled
        supaToggle:Set(supaEnabled)
    end
})

SupaSection:Toggle({
    Title = "Legit height",
    Desc = "If the player levels up more than required, the tech is canceled.",
    Value = false,
    Callback = function(state)
        legitHeightEnabled = state
    end
})

SupaSection:Toggle({
    Title = "Lock player tilt",
    Value = false,
    Callback = function(state)
        lockTiltEnabled = state
    end
})

SupaSection:Toggle({
    Title = "Shake Player",
    Value = true,
    Callback = function(state)
        shakeEnabled = state
    end
})

SupaSection:Toggle({
    Title = "Cancel tech if evasive is used",
    Value = false,
    Callback = function(state)
        cancelOnEvasiveEnabled = state
    end
})

--Kyoto
local LocalTechs1Tab = MainWindow:Tab({ Title = "Legit Kyoto Macro (Beta)", Icon = "cpu" })
local MainSection = LocalTechs1Tab:Section({ Title = "Legit Kyoto Macro (Beta)" })

MainSection:Toggle({
    Title = "Show Button (Mobile Only)",
    Value = false,
    Callback = function(state)
        kButtonGui.Enabled = state
    end
})

MainSection:Toggle({
    Title = "Draggable (Mobile Only)",
    Value = false,
    Callback = function(state)
        isButtonDraggable = state
    end
})

MainSection:Keybind({
    Title = "Macro Keybind (PC Only)",
    Value = "None",
    Callback = function()
        runKyotoMacro()
    end
})

local SettingsSection = LocalTechs1Tab:Section({ Title = "Settings" })

SettingsSection:Input({
    Title = "Side Dash Delay",
    Value = tostring(sideDashDelay),
    Callback = function(val)
        local num = tonumber(val)
        if num then
            sideDashDelay = num
        end
    end
})

SettingsSection:Input({
    Title = "Lethal Whirlwind Stream Delay",
    Value = tostring(lethalDelay),
    Callback = function(val)
        local num = tonumber(val)
        if num then
            lethalDelay = num
        end
    end
})
--Lethal
local LethalTab = MainWindow:Tab({
    Title = "Lethal Tech",
    Icon = "cpu"
})

LethalTab:Toggle({
    Title = "Lethal Dash",
    Default = false,
    Callback = function(state)
        isEnabled = state
        if isEnabled then
            enableFeature()
        else
            disableFeature()
        end
    end
})

LethalTab:Keybind({
    Title = "Toggle Keybind",
    Key = "F",
    Callback = function()
        isEnabled = not isEnabled
        if isEnabled then
            enableFeature()
        else
            disableFeature()
        end
    end
})

lp.CharacterAdded:Connect(function()
    disableFeature()
end)
--Aba
local AbaTab = MainWindow:Tab({ Title = "Aba Tech", Icon = "cpu" })

AbaTab:Toggle({
    Title = "Show Button",
    Value = false,
    Callback = function(v) m1Button.Visible = v end
})

AbaTab:Toggle({
    Title = "Draggable Button",
    Value = false,
    Callback = function(v) Settings.AbaDraggable = v end
})

AbaTab:Toggle({
    Title = "Enable Rotation",
    Value = false,
    Callback = function(v) Settings.AbaRotation = v end
})

AbaTab:Keybind({
    Title = "Activate Aba Tech",
    Key = "None",
    Callback = function() pcall(M1_RESET_FUNCTION) end
})
--Emordash
local EmoteTab = MainWindow:Tab({ Title = "Emote Dash", Icon = "zap" })

EmoteTab:Toggle({
    Title = "Show Button",
    Value = false,
    Callback = function(v) emoteButton.Visible = v end
})

EmoteTab:Toggle({
    Title = "Draggable Button",
    Value = false,
    Callback = function(v) Settings.EmoteDraggable = v end
})

EmoteTab:Keybind({
    Title = "Activate Emote Dash",
    Key = "None",
    Callback = function() pcall(EMOTE_DASH_FUNCTION) end
})

local LocalTechs3Tab = MainWindow:Tab({
    Title = "Coming Soon",
    Icon = "cpu",
    Locked = "true",
})

MainWindow:Section({ Title = "Utility" })

local DashTab = MainWindow:Tab({ Title = "Side Dash", Icon = "zap" })
local UtilitySection = DashTab:Section({ Title = "Side Dash Assist (Beta)" })

UtilitySection:Toggle({
    Title = "Side Dash Assist",
    Value = false,
    Callback = function(state)
        enabled = state
    end
})

local OtherSideDash = DashTab:Section({ Title = "Side Dash Assist (Individual scripts)" })

OtherSideDash:Button({
    Title = "Side Dash Assist V2 (Merebennie)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Zuriyx/Techs/refs/heads/main/Side-Dash-Assist-V2.txt"))()
    end
})

OtherSideDash:Button({
    Title = "Side Dash Assist V3 (Merebennie)",
    Callback = function()
        loadstring(game:HttpGet("https://api.getpolsec.com/scripts/hosted/23bcf4264b586dc93b16a9b054eddae259938b7421ac5096353079b2e9d74e24.lua"))()
    end
})
--
local LocksTab = MainWindow:Tab({
    Title = "Camlock / Silent Aim",
    Icon = "target"
})

LocksTab:Dropdown({
    Title = "Mode",
    Values = {"Camlock", "Silent Aim"},
    Default = "Camlock",
    Callback = function(v)
        Settings.Mode = v
        targetLocked = nil
    end
})

LocksTab:Dropdown({
    Title = "Target Part",
    Values = {"HumanoidRootPart", "Head", "Torso"},
    Default = "HumanoidRootPart",
    Callback = function(v)
        Settings.TargetPart = v
        targetLocked = nil
    end
})

LocksTab:Toggle({
    Title = "Show Button",
    Value = false,
    Callback = function(v)
        movableButton.Visible = v
    end
})

LocksTab:Toggle({
    Title = "Draggable Button",
    Value = false,
    Callback = function(v)
        Settings.Draggable = v
    end
})

LocksTab:Keybind({
    Title = "PC Toggle Keybind",
    Key = "E",
    Callback = function()
        Settings.Enabled = not Settings.Enabled
    end
})

--AutoBlocktab
local ABT = MainWindow:Tab({ Title = "Auto Block (Beta)", Icon = "shield" })
local ABM = ABT:Section({ Title = "Auto Block" })
local ABC = ABT:Section({ Title = "Configuration" })

ABM:Toggle({
    Title = "Enable Auto Block",
    Value = false,
    Callback = function(state)
        AutoBlockData.isEnabled = state
        if AutoBlockData.isEnabled then
            startDetection()
        else
            stopDetection()
        end
    end
})

ABM:Toggle({
    Title = "Auto M1 After Block",
    Value = false,
    Callback = function(state)
        AutoBlockData.autoM1AfterBlock = state
    end
})

ABC:Input({
    Title = "Normal Block Range",
    Placeholder = tostring(AutoBlockData.normalRange),
    Callback = function(text)
        local num = tonumber(text)
        if num then
            AutoBlockData.normalRange = num
        end
    end
})

ABC:Input({
    Title = "Prediction Sensitivity",
    Placeholder = tostring(AutoBlockData.predictThreshold),
    Callback = function(text)
        local num = tonumber(text)
        if num then
            AutoBlockData.predictThreshold = num
        end
    end
})

ABC:Input({
    Title = "Prediction Cooldown",
    Placeholder = tostring(AutoBlockData.predictCooldown),
    Callback = function(text)
        local num = tonumber(text)
        if num then
            AutoBlockData.predictCooldown = num
        end
    end
})
--VFxstuff
local Efc = MainWindow:Section({
    Title = "Effects and more"
})

local P = game:GetService("Players")
local LP = P.LocalPlayer
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local Cons = {}

local EffectsTab = MainWindow:Tab({ Title = "Visual", Icon = "sparkles" })

EffectsTab:Dropdown({
    Title = "Select Effect",
    Values = {"None", "Killua", "Itadori", "Fire", "Gojo"},
    Value = "None",
    Callback = function(val)
        for _, c in pairs(Cons) do c:Disconnect() end
        table.clear(Cons)
        
        if val == "None" then return end
        
        local soundData = {
            [2] = {{id = "13064223399", volume = 2}},
            [3] = {{id = "13064223291", volume = 2}},
            [4] = {{id = "13064223483", volume = 2}},
            [5] = {{id = "13064442279", volume = 2}, {id = "12244488581", volume = 2}, {id = "17173355584", volume = 0.5}, {id = "17173354974", volume = 0.5}}
        }

        local function PlaySound(id, vol)
            local s = Instance.new("Sound", LP:WaitForChild("PlayerGui"))
            s.SoundId, s.Volume = "rbxassetid://"..id, vol
            s:Play()
            Debris:AddItem(s, 2)
        end

        local function setupEffect(char)
            if val == "Gojo" then
                local hum = char:WaitForChild("Humanoid")
                table.insert(Cons, hum.AnimationPlayed:Connect(function(anim)
                    if tostring(anim.Animation.AnimationId):find("86505219150915") then
                        local s1, s2, s3 = Instance.new("Sound", workspace), Instance.new("Sound", workspace), Instance.new("Sound", workspace)
                        s1.SoundId, s1.Volume = "rbxassetid://117787451950766", 2; s1:Play(); Debris:AddItem(s1, 8)
                        task.delay(0.01, function() s2.SoundId, s2.Volume = "rbxassetid://97998065677521", 1.85; s2:Play(); Debris:AddItem(s2, 8) end)
                        task.delay(2.29, function() s3.SoundId, s3.Volume, s3.Looped = "rbxassetid://99535007576182", 2, true; s3:Play() end)
                        
                        task.delay(0.1, function()
                            local pb = Instance.new("Folder", char); pb.Name = "PrideBind"; pb:SetAttribute("EmoteProperty", true)
                            pcall(function() require(RepS.Emotes.VFX):MainFunction({ Character = char, vfxName = "Boss Raid", SpecificModule = RepS.Emotes.VFX, AnimSent = 86505219150915, RealBind = pb }) end)
                        end)
                        
                        task.spawn(function()
                            while anim.IsPlaying do
                                if anim.TimePosition >= anim.Length - 0.1 then anim:AdjustSpeed(0); anim.TimePosition = anim.Length - 0.01; break end
                                task.wait()
                            end
                        end)
                        
                        local runCon
                        runCon = hum.Running:Connect(function(spd)
                            if spd > 0.1 then
                                anim:Stop(0.2)
                                local emote = RepS.Emotes:FindFirstChild("TheStrongestEmote")
                                if emote then
                                    for _, part in ipairs(emote:GetChildren()) do
                                        if part.Name:match("Hand") or part.Name:match("Arm") then
                                            local charPart = char:FindFirstChild(part.Name)
                                            if charPart and charPart:IsA("BasePart") then
                                                local f = Instance.new("Folder", char); f.Name = "Strongest_"..part.Name
                                                for _, obj in ipairs(part:GetChildren()) do
                                                    local clone = obj:Clone()
                                                    if clone:IsA("BasePart") or clone:IsA("Model") then
                                                        clone.Parent = f
                                                        local p0 = clone:IsA("Model") and (clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")) or clone
                                                        if p0 then
                                                            local w = Instance.new("Weld", p0); w.Part0, w.Part1, w.C0 = charPart, p0, CFrame.new()
                                                            for _, d in ipairs(clone:GetDescendants()) do
                                                                if d:IsA("BasePart") then d.CanCollide, d.CanTouch, d.CanQuery, d.Massless, d.Anchored = false, false, false, true, false end
                                                                if d:IsA("ParticleEmitter") then d.Enabled = true; d:Emit(50) end
                                                            end
                                                            if clone:IsA("BasePart") then clone.CanCollide, clone.CanTouch, clone.CanQuery, clone.Massless, clone.Anchored = false, false, false, true, false end
                                                        end
                                                    elseif clone:IsA("ParticleEmitter") or clone:IsA("Attachment") then
                                                        clone.Parent = charPart
                                                        if clone:IsA("ParticleEmitter") then clone.Enabled = true; clone:Emit(50) end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                if runCon then runCon:Disconnect() end
                            end
                        end)
                    end
                end))
                return
            end

            table.insert(Cons, char:GetAttributeChangedSignal("LastM1Hitted"):Connect(function()
                local combo = tonumber(char:GetAttribute("Combo")) or 2
                if soundData[combo] then for _, s in ipairs(soundData[combo]) do PlaySound(s.id, s.volume); task.wait(0.05) end end
                
                local attVal = char:GetAttribute("LastM1Hitted")
                if not attVal then return end
                local tName = attVal:match("([^;]+)")
                local tModel = P:FindFirstChild(tName) and P[tName].Character or (workspace:FindFirstChild("Live") and workspace.Live:FindFirstChild(tName))
                if not tModel then
                    for _, d in ipairs(workspace:GetDescendants()) do
                        if d:IsA("Model") and d.Name == tName and d:FindFirstChild("Humanoid") then tModel = d; break end
                    end
                end
                
                if tModel then
                    local tRoot = tModel:FindFirstChild("HumanoidRootPart") or tModel:FindFirstChild("Torso")
                    local lHand, rHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm"), char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
                    local tAtt, e1, e2, e3 = nil, nil, nil, nil

                    if tRoot then
                        tAtt = Instance.new("Attachment", tRoot)
                        Debris:AddItem(tAtt, 1)

                        if val == "Killua" then
                            e1 = Instance.new("ParticleEmitter", tAtt)
                            e1.Name, e1.Texture, e1.Color = "Dusty Impact", "rbxassetid://10198439352", ColorSequence.new(Color3.new(0.455,0.573,1))
                            e1.Size, e1.Transparency, e1.ZOffset, e1.EmissionDirection = NumberSequence.new(2.599), NumberSequence.new(0), 2, Enum.NormalId.Top
                            e1.Lifetime, e1.Rate, e1.Speed, e1.Rotation = NumberRange.new(0.1), 10, NumberRange.new(0.026), NumberRange.new(-360, 360)
                            e1.SpreadAngle, e1.LockedToPart, e1.Orientation = Vector2.new(-360, 360), true, Enum.ParticleOrientation.VelocityPerpendicular
                            e1.Shape, e1.ShapeInOut, e1.ShapeStyle = Enum.ParticleEmitterShape.Box, Enum.ParticleEmitterShapeInOut.Outward, Enum.ParticleEmitterShapeStyle.Volume
                            e1.FlipbookMode, e1.FlipbookFramerate, e1.FlipbookLayout = Enum.ParticleFlipbookMode.OneShot, NumberRange.new(1), Enum.ParticleFlipbookLayout.Grid4x4
                            e1.Brightness = 5
                            e1:Emit(50)
                        elseif val == "Itadori" and combo == 5 then
                            e1 = Instance.new("ParticleEmitter", tAtt)
                            e1.Name, e1.Texture, e1.Color = "Lightning", "rbxassetid://16836633376", ColorSequence.new(Color3.new(1,0,0))
                            e1.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.056,5.437,4.188),NumberSequenceKeypoint.new(0.133,7.812,5.031),NumberSequenceKeypoint.new(0.362,9.125,4.639),NumberSequenceKeypoint.new(1,10,4.472)})
                            e1.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.661,0),NumberSequenceKeypoint.new(1,1)})
                            e1.ZOffset, e1.EmissionDirection, e1.Lifetime, e1.Rate = 2, Enum.NormalId.Top, NumberRange.new(0.7), 100
                            e1.Speed, e1.Rotation, e1.SpreadAngle, e1.Drag, e1.LockedToPart = NumberRange.new(0.001,10), NumberRange.new(0,360), Vector2.new(360,360), 3, true
                            e1.Orientation, e1.Shape, e1.ShapeInOut = Enum.ParticleOrientation.VelocityPerpendicular, Enum.ParticleEmitterShape.Box, Enum.ParticleEmitterShapeInOut.Outward
                            e1.ShapeStyle, e1.FlipbookMode, e1.FlipbookFramerate = Enum.ParticleEmitterShapeStyle.Volume, Enum.ParticleFlipbookMode.OneShot, NumberRange.new(20,40)
                            e1.FlipbookLayout, e1.Brightness = Enum.ParticleFlipbookLayout.Grid4x4, 5
                            e1:Emit(50)
                            
                            e2 = Instance.new("ParticleEmitter", tAtt)
                            e2.Name, e2.Texture, e2.Color = "Sparks2", "rbxassetid://17547405831", ColorSequence.new(Color3.new(1,0,0))
                            e2.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,2,1),NumberSequenceKeypoint.new(1,0,0)})
                            e2.EmissionDirection, e2.Lifetime, e2.Rate, e2.Speed = Enum.NormalId.Front, NumberRange.new(0.7), 400, NumberRange.new(20,150)
                            e2.Rotation, e2.RotSpeed, e2.SpreadAngle, e2.Acceleration = NumberRange.new(0,360), NumberRange.new(-300,300), Vector2.new(360,360), Vector3.new(0,5,0)
                            e2.Drag, e2.Orientation, e2.Shape, e2.ShapeInOut = 7, Enum.ParticleOrientation.VelocityParallel, Enum.ParticleEmitterShape.Box, Enum.ParticleEmitterShapeInOut.Outward
                            e2.ShapeStyle, e2.Brightness = Enum.ParticleEmitterShapeStyle.Volume, 15
                            e2:Emit(50)
                            
                            e3 = Instance.new("ParticleEmitter", tAtt)
                            e3.Name, e3.Texture, e3.Color = "Sparks", "rbxassetid://15407518755", ColorSequence.new(Color3.new(1,0,0))
                            e3.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,2,1),NumberSequenceKeypoint.new(1,0,0)})
                            e3.EmissionDirection, e3.Lifetime, e3.Rate, e3.Speed = Enum.NormalId.Front, NumberRange.new(0.7), 100, NumberRange.new(80,150)
                            e3.Rotation, e3.SpreadAngle, e3.Drag, e3.Orientation = NumberRange.new(90,90), Vector2.new(360,360), 10, Enum.ParticleOrientation.VelocityParallel
                            e3.Squash = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.3,3,0),NumberSequenceKeypoint.new(1,0,0)})
                            e3.Shape, e3.ShapeInOut, e3.ShapeStyle = Enum.ParticleEmitterShape.Box, Enum.ParticleEmitterShapeInOut.Outward, Enum.ParticleEmitterShapeStyle.Volume
                            e3.FlipbookMode, e3.Brightness = Enum.ParticleFlipbookMode.Loop, 15
                            e3:Emit(50)
                            
                            local e4 = Instance.new("ParticleEmitter", tAtt)
                            e4.Name, e4.Texture, e4.Color, e4.Size = "Wind2", "rbxassetid://1053548563", ColorSequence.new(Color3.new(1,0,0)), NumberSequence.new(80)
                            e4.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})
                            e4.EmissionDirection, e4.Lifetime, e4.Rate, e4.Speed = Enum.NormalId.Top, NumberRange.new(0.7), 100, NumberRange.new(0.01)
                            e4.Rotation, e4.SpreadAngle, e4.LightEmission, e4.Orientation = NumberRange.new(-360,360), Vector2.new(360,360), 1, Enum.ParticleOrientation.VelocityPerpendicular
                            e4.Squash = NumberSequence.new({NumberSequenceKeypoint.new(0,-3,0),NumberSequenceKeypoint.new(1,0,0)})
                            e4.Shape, e4.ShapeInOut, e4.ShapeStyle = Enum.ParticleEmitterShape.Box, Enum.ParticleEmitterShapeInOut.Outward, Enum.ParticleEmitterShapeStyle.Volume
                            e4.FlipbookMode, e4.Brightness = Enum.ParticleFlipbookMode.Loop, 3
                            e4:Emit(50)
                        elseif val == "Fire" then
                            e1 = Instance.new("ParticleEmitter", tAtt)
                            e1.Name, e1.Texture, e1.Color = "impact2", "rbxassetid://16892247104", ColorSequence.new(Color3.new(1,0.34,0.20))
                            e1.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.5,15),NumberSequenceKeypoint.new(1,15)})
                            e1.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(0.6,0.8),NumberSequenceKeypoint.new(1,1)})
                            e1.Lifetime, e1.Rate, e1.Speed, e1.Rotation = NumberRange.new(0.3), 0, NumberRange.new(0.002), NumberRange.new(-360,360)
                            e1.SpreadAngle, e1.LightEmission, e1.Orientation = Vector2.new(360,360), 1, Enum.ParticleOrientation.VelocityPerpendicular
                            e1.FlipbookMode, e1.FlipbookFramerate, e1.Brightness = Enum.ParticleFlipbookMode.Loop, NumberRange.new(1), 3
                            e1:Emit(50)
                        end
                    end
                    
                    for _, arm in pairs({lHand, rHand}) do
                        if arm then
                            local att = Instance.new("Attachment", arm)
                            att.CFrame = arm.Name:match("Arm") and CFrame.new(0, -1, 0) or CFrame.new(0, -0.6, 0)
                            Debris:AddItem(att, 1.5)
                            
                            if val == "Killua" then
                                e2 = Instance.new("ParticleEmitter", att)
                                e2.Name, e2.Texture, e2.Color = "Circular Smack", "rbxassetid://18140248952", ColorSequence.new(Color3.new(0.455,0.573,1))
                                e2.Size, e2.Transparency, e2.ZOffset, e2.EmissionDirection = NumberSequence.new(1.2), NumberSequence.new(0), 2, Enum.NormalId.Top
                                e2.Lifetime, e2.Rate, e2.Speed, e2.Rotation = NumberRange.new(0.1, 0.2), 10, NumberRange.new(0.026), NumberRange.new(-360, 360)
                                e2.SpreadAngle, e2.LockedToPart, e2.Orientation = Vector2.new(-360, 360), true, Enum.ParticleOrientation.VelocityPerpendicular
                                e2.Shape, e2.ShapeInOut, e2.ShapeStyle = Enum.ParticleEmitterShape.Box, Enum.ParticleEmitterShapeInOut.Outward, Enum.ParticleEmitterShapeStyle.Volume
                                e2.FlipbookMode, e2.FlipbookFramerate, e2.FlipbookLayout = Enum.ParticleFlipbookMode.OneShot, NumberRange.new(1), Enum.ParticleFlipbookLayout.Grid4x4
                                e2.Brightness = 5
                                e2:Emit(50)
                                
                                e3 = Instance.new("ParticleEmitter", att)
                                e3.Name, e3.Texture, e3.Color = "Shockreal", "rbxassetid://124692159307028", ColorSequence.new(Color3.new(0.224,0.302,1))
                                e3.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0.1,0),NumberSequenceKeypoint.new(0.106,1.08,0.2),NumberSequenceKeypoint.new(1,1.85,0)})
                                e3.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.065,0),NumberSequenceKeypoint.new(0.43,0.07),NumberSequenceKeypoint.new(0.663,0.118),NumberSequenceKeypoint.new(0.83,0.177),NumberSequenceKeypoint.new(1,1)})
                                e3.ZOffset, e3.EmissionDirection, e3.Lifetime, e3.Rate = 2, Enum.NormalId.Front, NumberRange.new(0.244,0.274), 7.29
                                e3.Speed, e3.Rotation, e3.RotSpeed, e3.SpreadAngle = NumberRange.new(0.0002), NumberRange.new(-360,360), NumberRange.new(-145.8,145.8), Vector2.new(40,40)
                                e3.Drag, e3.LockedToPart, e3.Orientation, e3.Shape = 0.729, true, Enum.ParticleOrientation.FacingCamera, Enum.ParticleEmitterShape.Box
                                e3.ShapeInOut, e3.ShapeStyle, e3.FlipbookMode = Enum.ParticleEmitterShapeInOut.Outward, Enum.ParticleEmitterShapeStyle.Volume, Enum.ParticleFlipbookMode.OneShot
                                e3.FlipbookFramerate, e3.FlipbookLayout, e3.Brightness = NumberRange.new(0.729), Enum.ParticleFlipbookLayout.Grid4x4, 15
                                e3:Emit(50)
                            elseif val == "Itadori" then
                                e2 = Instance.new("ParticleEmitter", att)
                                e2.Name, e2.Texture, e2.Color = "Shockreal", "rbxassetid://124692159307028", ColorSequence.new(Color3.new(0.224,0.302,1))
                                e2.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0.05,0),NumberSequenceKeypoint.new(0.106,0.54,0.1),NumberSequenceKeypoint.new(1,0.92,0)})
                                e2.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.065,0),NumberSequenceKeypoint.new(0.43,0.07),NumberSequenceKeypoint.new(0.663,0.118),NumberSequenceKeypoint.new(0.83,0.177),NumberSequenceKeypoint.new(1,1)})
                                e2.ZOffset, e2.EmissionDirection, e2.Lifetime, e2.Rate = 2, Enum.NormalId.Front, NumberRange.new(0.244,0.274), 7.29
                                e2.Speed, e2.Rotation, e2.RotSpeed, e2.SpreadAngle = NumberRange.new(0.0002), NumberRange.new(-360,360), NumberRange.new(-145.8,145.8), Vector2.new(40,40)
                                e2.Drag, e2.LockedToPart, e2.Orientation, e2.Shape = 0.729, true, Enum.ParticleOrientation.FacingCamera, Enum.ParticleEmitterShape.Box
                                e2.ShapeInOut, e2.ShapeStyle, e2.FlipbookMode = Enum.ParticleEmitterShapeInOut.Outward, Enum.ParticleEmitterShapeStyle.Volume, Enum.ParticleFlipbookMode.OneShot
                                e2.FlipbookFramerate, e2.FlipbookLayout, e2.Brightness = NumberRange.new(0.729), Enum.ParticleFlipbookLayout.Grid4x4, 15
                                e2:Emit(50)
                                
                                e3 = Instance.new("ParticleEmitter", att)
                                e3.Name, e3.Texture, e3.Color = "Aura", "rbxassetid://9285330517", ColorSequence.new(Color3.new(0.337,0.714,1))
                                e3.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,2.4,0.4),NumberSequenceKeypoint.new(0.36,0.8,0.3),NumberSequenceKeypoint.new(0.706,0.6,0.2),NumberSequenceKeypoint.new(0.868,0.4,0.1),NumberSequenceKeypoint.new(1,0.25,0)})
                                e3.ZOffset, e3.EmissionDirection, e3.Lifetime, e3.Rate = 1, Enum.NormalId.Top, NumberRange.new(0.1,0.2), 35
                                e3.Speed, e3.Rotation, e3.Acceleration, e3.LockedToPart = NumberRange.new(0, 5), NumberRange.new(-360,360), Vector3.new(0, 2, 0), true
                                e3.Orientation, e3.Shape, e3.ShapeInOut, e3.ShapeStyle = Enum.ParticleOrientation.FacingCamera, Enum.ParticleEmitterShape.Box, Enum.ParticleEmitterShapeInOut.Outward, Enum.ParticleEmitterShapeStyle.Volume
                                e3.FlipbookMode, e3.FlipbookFramerate, e3.FlipbookLayout, e3.Brightness = Enum.ParticleFlipbookMode.OneShot, NumberRange.new(1), Enum.ParticleFlipbookLayout.Grid4x4, 4
                                e3:Emit(50)
                            elseif val == "Fire" then
                                e2 = Instance.new("ParticleEmitter", att)
                                e2.Name, e2.Texture = "Flames", "rbxassetid://15269497616"
                                e2.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,0.498)),ColorSequenceKeypoint.new(0.15,Color3.new(1,0.333,0)),ColorSequenceKeypoint.new(0.5,Color3.new(1,0,0)),ColorSequenceKeypoint.new(1,Color3.new(1,0,0))})
                                e2.Size, e2.Transparency = NumberSequence.new(1), NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.1,0),NumberSequenceKeypoint.new(1,0)})
                                e2.ZOffset, e2.EmissionDirection, e2.Lifetime, e2.Rate = 1, Enum.NormalId.Top, NumberRange.new(0.5,1), 0
                                e2.Speed, e2.Rotation, e2.RotSpeed, e2.SpreadAngle = NumberRange.new(0), NumberRange.new(-360,360), NumberRange.new(-100,100), Vector2.new(0,0)
                                e2.Acceleration, e2.Drag, e2.LockedToPart, e2.LightEmission = Vector3.new(0,15,0), 5, true, 0.5
                                e2.Orientation, e2.Shape, e2.ShapeInOut, e2.ShapeStyle = Enum.ParticleOrientation.FacingCamera, Enum.ParticleEmitterShape.Box, Enum.ParticleEmitterShapeInOut.Outward, Enum.ParticleEmitterShapeStyle.Volume
                                e2.FlipbookMode, e2.FlipbookFramerate, e2.FlipbookLayout, e2.Brightness = Enum.ParticleFlipbookMode.OneShot, NumberRange.new(1), Enum.ParticleFlipbookLayout.Grid4x4, 5
                                e2:Emit(50)
                            end
                        end
                    end
                end
            end))
        end

        if LP.Character then setupEffect(LP.Character) end
        table.insert(Cons, LP.CharacterAdded:Connect(setupEffect))
    end
})

EffectsTab:Toggle({
    Title = "Headless FE (R6)",
    Value = false,
    Callback = function(state)
        getgenv().ZuriFreeze = state
        
        if state then
            if not getgenv().ZuriNotified then
                getgenv().ZuriNotified = true
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Zuri Headless R6",
                    Text = "Active. For best results, use a small head accessory.",
                    Duration = 10,
                    Icon = "rbxassetid://6031075931"
                })
            end

            if LP.Character then 
                task.spawn(function() apply_effect(LP.Character) end) 
            end
            
            char_conn = LP.CharacterAdded:Connect(function(char)
                task.delay(2.2, function()
                    if char and char.Parent then apply_effect(char) end
                end)
            end)
        else
            stop_effect()
            if char_conn then char_conn:Disconnect(); char_conn = nil end
        end
    end
})
