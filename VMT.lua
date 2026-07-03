local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local isPC = UserInputService.KeyboardEnabled

local cloneref = cloneref or clonereference or function(instance) return instance end
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

WindUI:SetFont("rbxassetid://12187371840")

local Window = WindUI:CreateWindow({
    Title = "VMT hub",
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

Window:EditOpenButton({
    Title = "VMT hub",
    Icon = "",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("222222"), Color3.fromHex("555555")),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true
})

local discordIconPath = "VMT_DiscordIcon.png"
if not (isfile and isfile(discordIconPath)) then
    if writefile then
        local suc, res = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/github/explore/4b17bd9c0a6b7c5264b361bb54e47767357dd145/topics/discord/discord.png")
        if suc then writefile(discordIconPath, res) end
    end
end
local discordImg = (isfile and isfile(discordIconPath) and getcustomasset) and getcustomasset(discordIconPath) or "rbxassetid://106831036033040"

local InfoTab = Window:Tab({ Title = "Info", Icon = "info" })

InfoTab:Paragraph({
    Title = "Support us!!!",
    Desc = "Join our Discord server to support my small community",
    Image = discordImg,
    ImageSize = 64,
    Buttons = {
        {
            Title = "Copy Discord link",
            Callback = function()
                if setclipboard then
                    setclipboard("https://discord.gg/ZXSuYC3upG")
                end
            end
        }
    }
})

local FFlagTab = Window:Tab({ Title = "Fflag executor", Icon = "code" })
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
    Title = "Repository Flags",
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

local HttpService = game:GetService("HttpService")

local ModifierTab = Window:Tab({ Title = "Shiftlock Modifier", Icon = "mouse-pointer" })
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

local GamepassTab = Window:Tab({ Title = "Free Gamepasses", Icon = "person-standing" })
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
})

GamepassSection:Button({
    Title = "Unlock All Tittles, Cosmetics & Auras.",
    Callback = function()
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
})

Window:Section({
    Title = "Local Techs"
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local supaEnabled = false
local onCooldown = false
local cooldownTime = 4
local yOffset = 2.2
local lookOffset = 0.3

local connections = {}
local char, hum, hrp

local function clearConnections()
    for _, conn in pairs(connections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    table.clear(connections)
end

local function getClosest()
    if not hrp then return nil end
    local target = nil
    local minDist = 20
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj ~= char then
            local s, dist = pcall(function()
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

local function fireCommunicateMoves()
    pcall(function()
        if char and char:FindFirstChild("Communicate") then
            char.Communicate:FireServer({Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress"})
        end
    end)
    pcall(function()
        local bv = nil
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

local function executeSupaTech()
    if not char or not hum or not hrp then return end
    local target = getClosest()
    if not target then return end
    local targetHrp = target:FindFirstChild("HumanoidRootPart")
    if not targetHrp then return end
    
    local oldStats = {}
    pcall(function()
        oldStats.WalkSpeed = hum.WalkSpeed
        oldStats.JumpPower = hum.JumpPower
        oldStats.PlatformStand = hum.PlatformStand
        pcall(function() oldStats.AutoRotate = hum.AutoRotate end)
    end)
    
    local loopConn = nil
    local function restoreStats()
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
    
    if hrp then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(60), 0, 0)
    end
    
    local duration = 0.2
    local startTime = tick()
    local cframeConn = nil
    
    cframeConn = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - startTime
        if duration > elapsed then
            local s, cframeCalc = pcall(function()
                local pos = (targetHrp.Position - targetHrp.CFrame.LookVector * lookOffset) + Vector3.new(0, yOffset, 0)
                local baseCFrame = CFrame.new(pos)
                local timeRemaining = duration - elapsed
                local zAngle = 0
                if timeRemaining > 0.055 then
                    zAngle = math.sin(tick() * 110) * 0.35
                end
                return baseCFrame * CFrame.Angles(math.rad(60), zAngle, 0)
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
    
    repeat task.wait() until duration <= (tick() - startTime)
    
    pcall(function()
        if hrp then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(5), math.rad(-25), math.rad(-15))
        end
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
    restoreStats()
end

local function checkSupaCooldown()
    if not supaEnabled or onCooldown then return end
    onCooldown = true
    task.spawn(function() pcall(executeSupaTech) end)
    task.wait(cooldownTime)
    onCooldown = false
end

local function onAnimationPlayed(animTrack)
    if animTrack and animTrack.Animation then
        local id = tostring(animTrack.Animation.AnimationId or "")
        if string.find(id, "10503381238", 1, true) or string.find(id, "13379003796", 1, true) then
            task.delay(0.3, checkSupaCooldown)
        end
    end
end

local function setupCharacter(newChar)
    clearConnections()
    char = newChar
    hum = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
    
    local s, conn = pcall(function()
        return hum.AnimationPlayed:Connect(onAnimationPlayed)
    end)
    if s and conn then table.insert(connections, conn) end
    
    local animator = hum:FindFirstChildOfClass("Animator")
    if animator then
        local s2, conn2 = pcall(function()
            return animator.AnimationPlayed:Connect(onAnimationPlayed)
        end)
        if s2 and conn2 then table.insert(connections, conn2) end
    end
end

LocalPlayer.CharacterAdded:Connect(setupCharacter)
if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end

local LocalTechsTab = Window:Tab({ Title = "Legit Supa (Beta)", Icon = "cpu" })

local SupaSection = LocalTechsTab:Section({ Title = "Supa Tech" })

local supaToggle = MainSection:Toggle({
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

local LocalTechs1Tab = Window:Tab({ Title = "Legit Kyoto Macro (Beta)", Icon = "cpu" })
local KyotSection = LocalTechs1Tab:Section({ Title = "Legit Kyoto Macro (Beta)" })

KyotSection:Toggle({
    Title = "Show Button (Mobile Only)",
    Value = false,
    Callback = function(state)
        kButtonGui.Enabled = state
    end
})

KyotSection:Toggle({
    Title = "Draggable (Mobile Only)",
    Value = false,
    Callback = function(state)
        isButtonDraggable = state
    end
})

KyotSection:Keybind({
    Title = "Macro Keybind (PC Only)",
    Value = "None",
    Callback = function()
        runKyotoMacro()
    end
})

local SettingsKyotSection = LocalTechs1Tab:Section({ Title = "Settings" })

SettingsKyotSection:Input({
    Title = "Side Dash Delay",
    Value = tostring(sideDashDelay),
    Callback = function(val)
        local num = tonumber(val)
        if num then
            sideDashDelay = num
        end
    end
})

SettingsKyotSection:Input({
    Title = "Lethal Whirlwind Stream Delay",
    Value = tostring(lethalDelay),
    Callback = function(val)
        local num = tonumber(val)
        if num then
            lethalDelay = num
        end
    end
})


local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local twistedEnabled = false

local LocalTechs2Tab = Window:Tab({ Title = "Legit Basic Twisted", Icon = "cpu" })

local TechSection = LocalTechs2Tab:Section({ 
    Title = "Twisted Tech" 
})

local twistedToggle = TechSection:Toggle({
    Title = "Enable Twisted Tech",
    Value = false,
    Callback = function(state)
        twistedEnabled = state
    end
})

TechSection:Keybind({
    Title = "Toggle Keybind",
    Value = "None",
    Callback = function()
        twistedEnabled = not twistedEnabled
        twistedToggle:Set(twistedEnabled)
    end
})

local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.AnimationPlayed:Connect(function(track)
            local id = tostring(track.Animation.AnimationId):gsub("rbxassetid://", "")
            if twistedEnabled and id == "13294471966" then
                task.wait(0.3)
                local communicate = character:WaitForChild("Communicate", 5)
                if communicate then
                    communicate:FireServer({
                        Dash = Enum.KeyCode.W,
                        Key = Enum.KeyCode.Q,
                        Goal = "KeyPress"
                    })
                end
            end
        end)
    end
end

if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(setupCharacter)

local LocalTechs3Tab = Window:Tab({
    Title = "Coming Soon",
    Icon = "cpu",
    Locked = "true",
})