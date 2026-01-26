--pipi1
if not (getrawmetatable and setreadonly and getnamecallmethod and checkcaller and newcclosure and writefile and readfile and isfile) then
    game:GetService("Players").LocalPlayer:Kick("EXECUTOR NOT SUPPORTED PLEASE USE A SUPPORTED EXECUTOR!")
    return
end

if game.PlaceId ~= 17282336195 and game.PlaceId ~= 17400753636 then
    game:GetService("Players").LocalPlayer:Kick("GAME NOT SUPPORTED!")
    return
end

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua'))()

local script_version = "V0.11"

local Window = Rayfield:CreateWindow({
   Name = "LixHub - Anime Guardians",
   Icon = 0,
   LoadingTitle = "Loading for Anime Guardians",
   LoadingSubtitle = script_version,
   ShowText = "LixHub",
   Theme = {
    TextColor = Color3.fromRGB(240, 240, 240),

    Background = Color3.fromRGB(25, 25, 25),
    Topbar = Color3.fromRGB(34, 34, 34),
    Shadow = Color3.fromRGB(20, 20, 20),

    NotificationBackground = Color3.fromRGB(20, 20, 20),
    NotificationActionsBackground = Color3.fromRGB(230, 230, 230),

    TabBackground = Color3.fromRGB(80, 80, 80),
    TabStroke = Color3.fromRGB(85, 85, 85),
    TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
    TabTextColor = Color3.fromRGB(240, 240, 240),
    SelectedTabTextColor = Color3.fromRGB(50, 50, 50),

    ElementBackground = Color3.fromRGB(35, 35, 35),
    ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
    SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
    ElementStroke = Color3.fromRGB(50, 50, 50),
    SecondaryElementStroke = Color3.fromRGB(40, 40, 40),
            
    SliderBackground = Color3.fromRGB(50, 138, 220),
    SliderProgress = Color3.fromRGB(50, 138, 220),
    SliderStroke = Color3.fromRGB(58, 163, 255),

    ToggleBackground = Color3.fromRGB(30, 30, 30),
    ToggleEnabled = Color3.fromRGB(0, 146, 214),
    ToggleDisabled = Color3.fromRGB(100, 100, 100),
    ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
    ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
    ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
    ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),

    DropdownSelected = Color3.fromRGB(102, 102, 102),
    DropdownUnselected = Color3.fromRGB(30, 30, 30),

    InputBackground = Color3.fromRGB(30, 30, 30),
    InputStroke = Color3.fromRGB(65, 65, 65),
    PlaceholderColor = Color3.fromRGB(178, 178, 178)
},

   ToggleUIKeybind = "K",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = "LixHub",
      FileName = "Lixhub_AG"
   },

   Discord = {
      Enabled = true, 
      Invite = "cYKnXE2Nf8",
      RememberJoins = true
   },

   KeySystem = true,
   KeySettings = {
      Title = "LixHub - Anime Guardians - Free",
      Subtitle = "LixHub - Key System",
      Note = "Free key available in the discord https://discord.gg/cYKnXE2Nf8",
      FileName = "LixHub_Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"0xLIXHUB"},
   }
})

local Services = {
    HttpService = game:GetService("HttpService"),
    Players = game:GetService("Players"),
    TeleportService = game:GetService("TeleportService"),
    Lighting = game:GetService("Lighting"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    VIRTUAL_USER = game:GetService("VirtualUser"),
}

local stageRewards = require(Services.ReplicatedStorage.Module.StageRewards)
local LocalPlayer = Services.Players.LocalPlayer

local capturedRewards = {}

local pendingUpgrades = {}
local lastUseTime = {}
local UPGRADE_VALIDATION_TIMEOUT = 1.5

local webhookDebounce = false
local WEBHOOK_DEBOUNCE_TIME = 3

local Config = {
   difficulties = {"Normal", "Nightmare"},
}

local Config = {
    DISCORD_USER_ID = nil
}

local State = {
   AutoJoinStory = nil,
   StoryStageSelected = nil,
   StoryActSelected = nil,
   StoryDifficultySelected = nil,
   AutoJoinRaid = nil,
   RaidStageSelected = nil,
   RaidActSelected = nil,
   AutoJoinLimitedEvent = nil,
   AutoJoinLimitedEventSelected = {},

   enableLimitFPS = false,
   SelectedFPS = 60,

   AntiAfkKickEnabled = false,

   deleteEntities = false,

   enableBlackScreen = false,

   AutoJoinGate = nil,

   enableAutoExecute = false,

   AutoJoinWorldlines = nil,
   AutoJoinWorldlinesSelected = nil,

   AutoJoinEvent = nil,
   AutoJoinEventSelected = nil,

   AutoJoinPortal = nil,
   AutoJoinPortalSelected = nil,

   AutoJoinChallenge = nil,

   AutoJoinTower = nil,
   AutoJoinTowerSelected = nil,

   AutoVoteRetry = false,
   AutoVoteNext = false,

   isGameRunning = false,

   SendStageCompletedWebhook = false,

   startingInventory = {},

   streamerModeEnabled = nil,

   enableLowPerformanceMode = nil,

   AutoPurchaseBlackMarket = nil,
   AutoPurchaseBlackMarketSelected = nil,

   AutoCollectChests = nil,

    gameStartRealTime = nil,
    gameEndRealTime = nil,
    actualClearTime = nil,
    IgnoreTiming = nil,
    AutoSkipWaves = false,
    AutoSkipUntilWave = 0,
    AutoSellFarmEnabled = false,
    AutoSellFarmWave = 0,
    AutoSellEnabled = false,
    AutoSellWave = 0,
    AutoUseAbility = false,
    SelectedUnitAbilities = {},
    AutoUseAbilitySukuna = false,
    SelectedSukunaSkills = {},
    ReplaceDeletedUnits = false,
    BlockBossDamage = false,

    AutoStartGame = false,
    AutoPurchaseGriffith = false,
    AutoPurchaseGriffithSelected = {},
    AutoPurchaseRagna = false,
    AutoPurchaseRagnaSelected = {},
    AutoJoinDelay = 0,
    SelectedUnitsForAbility = {},
    SelectedAbilitiesToUse = {}
}

local abilityQueue = {}
local abilityQueueThread = nil

local AutoJoinState = {
    isProcessing = false,
    currentAction = nil,
    lastActionTime = 0,
    actionCooldown = 2
}

local trackedUnits = {} 

local macro = {}
local macroManager = {}
local currentMacroName = ""
local recordingHasStarted = false
local isAutoLoopEnabled = false

local playbackUnitMapping = {} -- Maps placement order to actual unit name
local recordingSpawnIdToPlacement = {} -- Maps spawn ID to placement ID during recording
local recordingPlacementCounter = {} -- Counts placements per unit type
local placementExecutionLock = false -- Prevent race conditions
local playbackLoopRunning = false

local gameInProgress = false

local gameStartTime = 0

local isRecording = false
local isPlaybacking = false
local isRecordingLoopRunning = false
local currentWave = 0
local detailedStatusLabel = nil

local ValidWebhook = nil

local LobbyTab = Window:CreateTab("Lobby", "tv")
local JoinerTab = Window:CreateTab("Joiner", "plug-zap")
local GameTab = Window:CreateTab("Game", "gamepad-2")
local MacroTab = Window:CreateTab("Macro", "tv")
local WebhookTab = Window:CreateTab("Webhook", "bluetooth")

local MacroStatusLabel = MacroTab:CreateLabel("Macro Status: Ready")

CodeButton = LobbyTab:CreateButton({
    Name = "Redeem All Codes",
    Callback = function()
        for _, stringValue in ipairs(Services.Players.LocalPlayer.Code:GetChildren()) do
	    if stringValue:IsA("Folder") and stringValue.Name ~= "Rewards" then
	            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("Codes"):InvokeServer(stringValue.Name)
                Rayfield:Notify({Title = "Redeem All Codes",Content = "Redeeming: "..stringValue.Name,Duration = 0.5,Image = "Info",})
                task.wait(0.1)
            end
        end
    end,
})

 Toggle = LobbyTab:CreateToggle({
    Name = "Auto Execute Script",
    CurrentValue = false,
    Flag = "enableAutoExecute",
    Info = "This auto executes and persists through teleports until you disable it or leave the game. ONLY USE 1 AUTOEXECUTE!",
    TextScaled = false,
    Callback = function(Value)
        State.enableAutoExecute = Value
        if State.enableAutoExecute then
            if queue_on_teleport then
                queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/Lixtron/Hub/refs/heads/main/loader"))()')
            else
                warn("queue_on_teleport not supported by this executor")
            end
        else
            if queue_on_teleport then
                queue_on_teleport("") -- Empty string clears queue in most executors
            end
        end
    end,
})

 Button = LobbyTab:CreateButton({
        Name = "Return to lobby",
        Callback = function()
            Services.TeleportService:Teleport(17282336195, Services.Players.LocalPlayer)
        end,
    })

    Section = LobbyTab:CreateSection("Auto Purchase")

    local Toggle = LobbyTab:CreateToggle({
    Name = "Auto Purchase Griffith Shop",
    CurrentValue = false,
    Flag = "AutoPurchaseGriffith",
    Callback = function(Value)
        State.AutoPurchaseGriffith = Value
    end,
})

 Dropdown = LobbyTab:CreateDropdown({
    Name = "Select Griffith Item",
    Options = {
        "Capsule Fortune Potion",
        "Festival Coin Potion",
        "Blessed Luck Potion",
        "Event Discount Potion",
        "Guts",
        "Dragonslayer",
        "Artifacts Trait Reroll",
        "SuperStatReroll",
        "StatReroll"
    },
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "GriffithItemSelector",
    Callback = function(Options)
        State.AutoPurchaseGriffithSelected = Options
    end,
})

 Toggle = LobbyTab:CreateToggle({
    Name = "Auto Purchase Ragna Shop",
    CurrentValue = false,
    Flag = "AutoPurchaseRagna",
    Info = "Automatically purchases selected items from Ragna Shop",
    Callback = function(Value)
        State.AutoPurchaseRagna = Value
    end,
})

 Dropdown = LobbyTab:CreateDropdown({
    Name = "Select Ragna Item",
    Options = {
        "Artifacts Trait Reroll",
        "Ragna Capsule",
        "Dango",
        "Mystic Coins",
        "Fullsteak",
        "Ramen",
        "TraitReroll",
        "Night Market Coins"
    },
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "RagnaItemSelector",
    Callback = function(Options)
        State.AutoPurchaseRagnaSelected = Options
    end,
})

local griffithItemMap = {
    ["Capsule Fortune Potion"] = 1000,
    ["Festival Coin Potion"] = 1000,
    ["Blessed Luck Potion"] = 1000,
    ["Event Discount Potion"] = 1000,
    ["Guts"] = 100,
    ["Dragonslayer"] = 25,
    ["Artifacts Trait Reroll"] = 10,
    ["SuperStatReroll"] = 10,
    ["StatReroll"] = 10,
}

local ragnaItemMap = {
    ["Artifacts Trait Reroll"] = 5,
    ["Ragna Capsule"] = 5,
    ["Dango"] = 1,
    ["Mystic Coins"] = 5,
    ["Fullsteak"] = 2,
    ["Ramen"] = 2,
    ["TraitReroll"] = 5,
    ["Night Market Coins"] = 50,
}

local function purchaseFromGriffithShop(itemName)
    local actualCost = griffithItemMap[itemName]
    if not actualCost then return nil end
    
    local beherit = game:GetService("Players").LocalPlayer:FindFirstChild("ItemsInventory") and game:GetService("Players").LocalPlayer.ItemsInventory:FindFirstChild("Beherit")
    if not beherit or not beherit:FindFirstChild("Amount") then return nil end
    
    return Services.ReplicatedStorage:WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("EventShop"):InvokeServer(math.floor(beherit.Amount.Value / actualCost), itemName, "Behelit")
end

local function purchaseFromRagnaShop(itemName)
    local actualCost = ragnaItemMap[itemName]
    if not actualCost then return nil end
    
    local dragonpoints = game:GetService("Players").LocalPlayer:FindFirstChild("ItemsInventory") and game:GetService("Players").LocalPlayer.ItemsInventory:FindFirstChild("Dragonpoints")
    if not dragonpoints or not dragonpoints:FindFirstChild("Amount") then return nil end
    
    return Services.ReplicatedStorage:WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("EventShop"):InvokeServer(math.floor(dragonpoints.Amount.Value / actualCost), itemName, "RagnaShop")
end

    local function isInLobby()
    return workspace:FindFirstChild("RoomCreation") ~= nil
end

local function checkGriffithShop()
    if not State.AutoPurchaseGriffith then return end
    if not State.AutoPurchaseGriffithSelected or #State.AutoPurchaseGriffithSelected == 0 then return end
    if not isInLobby() then return end
    
    for _, itemName in ipairs(State.AutoPurchaseGriffithSelected) do
        purchaseFromGriffithShop(itemName)
        task.wait(3)
    end
end

local function checkRagnaShop()
    if not State.AutoPurchaseRagna then return end
    if not State.AutoPurchaseRagnaSelected or #State.AutoPurchaseRagnaSelected == 0 then return end
    if not isInLobby() then return end
    
    for _, itemName in ipairs(State.AutoPurchaseRagnaSelected) do
        purchaseFromRagnaShop(itemName)
        task.wait(3)
    end
end

task.spawn(function()
    while true do
        if State.AutoPurchaseGriffith and State.AutoPurchaseGriffithSelected then
            checkGriffithShop()
        end
        if State.AutoPurchaseRagna and State.AutoPurchaseRagnaSelected then
            checkRagnaShop()
        end
        task.wait(1)
    end
end)

local function getPlayerUnitsFolder()
    local unitServer = Services.Workspace:FindFirstChild("Ground") 
        and Services.Workspace.Ground:FindFirstChild("unitServer")
    
    if not unitServer then
        warn("unitServer not found!")
        return nil
    end
    
    local playerUnitsFolder = unitServer:FindFirstChild(tostring(Services.Players.LocalPlayer.Name).." (UNIT)")
    if not playerUnitsFolder then
        warn("Player units folder not found!")
        return nil
    end
    
    return playerUnitsFolder
end

local function updateDetailedStatus(message)
    if detailedStatusLabel then
        detailedStatusLabel:Set("Macro Details: " .. message)
    end
    print("Macro Status: " .. message)
end

        local function notify(title, content, duration)
        Rayfield:Notify({
            Title = title or "Notice",
            Content = content or "No message.",
            Duration = duration or 5,
            Image = "info",
        })
    end

local function purchaseFromBlackMarket(unitName)
    local args = {
        1,
        unitName,
        "NightMarket"
    }
    
    local success, result = pcall(function()
        return Services.ReplicatedStorage:WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("EventShop"):InvokeServer(unpack(args))
    end)
    
    if success then
        print("Successfully purchased:", unitName)
    else
        warn("Failed to purchase:", unitName, "Error:", result)
    end
end

local function checkBlackMarket()
    if not State.AutoPurchaseBlackMarket or not State.AutoPurchaseBlackMarketSelected or State.AutoPurchaseBlackMarketSelected == "" then
        return
    end
    if not workspace:FindFirstChild("RoomCreation") ~= nil then return end
    
    local blackMarket = LocalPlayer:FindFirstChild("BlackMarket")
    if not blackMarket then
        return
    end
    
    local market = blackMarket:FindFirstChild("Market")
    if not market then
        return
    end
    
    for _, child in pairs(market:GetChildren()) do
        if child:IsA("Folder") and child.Name == State.AutoPurchaseBlackMarketSelected then
            print("Found target unit in black market:", child.Name)
            purchaseFromBlackMarket(child.Name)
            break
        end
    end
end

local function enableBlackScreen()
    local existingGui = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("BlackScreenGui")
    
    if State.enableBlackScreen then
        if existingGui then return end
        
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "BlackScreenGui"
        screenGui.Parent = Services.Players.LocalPlayer.PlayerGui
        screenGui.IgnoreGuiInset = true
        screenGui.DisplayOrder = math.huge

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 36)
        frame.Position = UDim2.new(0, 0, 0, -36)
        frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
        frame.BorderSizePixel = 0
        frame.Parent = screenGui
        frame.ZIndex = 999999

        local toggleButtonFrame = Instance.new("Frame")
        toggleButtonFrame.Size = UDim2.new(0, 170,0, 44)
        toggleButtonFrame.Position = UDim2.new(0.5, -60, 1, -60)
        toggleButtonFrame.BackgroundColor3 = Color3.fromRGB(57, 57, 57)
        toggleButtonFrame.BackgroundTransparency = 0.5
        toggleButtonFrame.Parent = screenGui
        toggleButtonFrame.ZIndex = 1000000

        local toggleButtonFrameUICorner =  Instance.new("UICorner")
        toggleButtonFrameUICorner.CornerRadius = UDim.new(1,0)
        toggleButtonFrameUICorner.Parent = toggleButtonFrame

        local toggleButtonFrameTitle = Instance.new("TextLabel")
        toggleButtonFrameTitle.ZIndex = math.huge
        toggleButtonFrameTitle.AnchorPoint = Vector2.new(0.5,0.5)
        toggleButtonFrameTitle.BackgroundTransparency = 1
        toggleButtonFrameTitle.Position = UDim2.new(0.5,0,0.5,0)
        toggleButtonFrameTitle.Size = UDim2.new(1,0,1,0)
        toggleButtonFrameTitle.Text = "Toggle Screen"
        toggleButtonFrameTitle.TextSize = 15
        toggleButtonFrameTitle.TextColor3 = Color3.fromRGB(255,255,255)
        toggleButtonFrameTitle.Parent = toggleButtonFrame

        local toggleButtonFrameTitleStroke = Instance.new("UIStroke")
        toggleButtonFrameTitleStroke.Parent = toggleButtonFrameTitle

        local toggleButtonFrameButton = Instance.new("TextButton")
        toggleButtonFrameButton.AnchorPoint = Vector2.new(0.5,0.5)
        toggleButtonFrameButton.BackgroundTransparency = 1
        toggleButtonFrameButton.Size = UDim2.new(1,0,1,0)
        toggleButtonFrameButton.Position = UDim2.new(0.5,0,0.5,0)
        toggleButtonFrameButton.Text = ""
        toggleButtonFrameButton.ZIndex = math.huge
        toggleButtonFrameButton.Parent = toggleButtonFrame

        toggleButtonFrameButton.MouseButton1Click:Connect(function()
            frame.Visible = not frame.Visible
        end)
    else
        if existingGui then
            existingGui:Destroy()
        end
    end
end

local function getUnitAbilitiesList()
    local SkillsModule = Services.ReplicatedStorage:WaitForChild("Module"):WaitForChild("Skills")
    local SkillsData = require(SkillsModule)
    
    local abilitiesList = {}
    
    for unitName, skillData in pairs(SkillsData) do
        -- Skip units with multiple skills
        if not (skillData.Skill1 and skillData.Skill2) then
            table.insert(abilitiesList, {
                display = unitName,
                unitName = unitName,
                abilityName = nil,
                cooldown = skillData.Cooldown
            })
        end
    end
    
    -- Sort alphabetically by display name
    table.sort(abilitiesList, function(a, b)
        return a.display < b.display
    end)
    
    return abilitiesList
end

local function findAndUseUnitAbility(unitBaseName, abilityName)
    if isInLobby() then return false end
    
    local ground = Services.Workspace:FindFirstChild("Ground")
    if not ground then return false end
    
    local unitClient = ground:FindFirstChild("unitClient")
    if not unitClient then return false end
    
    -- Search for the unit in unitClient
    for _, unit in pairs(unitClient:GetChildren()) do
        if unit:IsA("Model") then
            -- Check if this unit matches the base name
            local unitName = unit.Name
            local baseUnitName = unitName:match("^(.+)%s+%d+$") or unitName
            
            if baseUnitName == unitBaseName then
                -- Found matching unit, try to use ability
                local args = {"SkillsButton", unit.Name}
                
                -- Add ability name if specified (for multi-skill units)
                if abilityName and abilityName ~= "" then
                    table.insert(args, abilityName)
                end
                
                local success, result = pcall(function()
                    return game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
                        :WaitForChild("Events"):WaitForChild("Skills"):InvokeServer(unpack(args))
                end)
                
                if success and result then
                    local abilityText = abilityName and (" - " .. abilityName) or ""
                    print(string.format("✓ Used ability on %s%s", unitBaseName, abilityText))
                    return true
                end
            end
        end
    end
    
    return false
end

local function updateFPSLimit()
    if State.enableLimitFPS and State.SelectedFPS > 0 then
        setfpscap(State.SelectedFPS)
    else
        setfpscap(0) -- 0 = unlimited
    end
end

local function enableLowPerformanceMode()
    if State.enableLowPerformanceMode then
        Services.Lighting.Brightness = 1
        Services.Lighting.GlobalShadows = false
        Services.Lighting.Technology = Enum.Technology.Compatibility
        Services.Lighting.ShadowSoftness = 0
        Services.Lighting.EnvironmentDiffuseScale = 0
        Services.Lighting.EnvironmentSpecularScale = 0

        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
        end
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                if obj.Transparency < 1 then
                    obj.Transparency = 1
                end
            end
        end
        
        for _, gui in pairs(Services.Players.LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()) do
            if gui:IsA("UIGradient") or gui:IsA("UIStroke") or gui:IsA("DropShadowEffect") then
                gui.Enabled = false
            end
        end
        
        for _, obj in pairs(Services.Lighting:GetChildren()) do
            if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or
            obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") then
                obj.Enabled = false
            end
        end
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Data"):WaitForChild("Settings"):FireServer("Update",{Value = "ON",Setting = "Low Mode"})
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Data"):WaitForChild("Settings"):FireServer("Update",{Value = "OFF",Setting = "Visual Effects"})
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Data"):WaitForChild("Settings"):FireServer("Update",{Value = "OFF",Setting = "Damage Indicator"})
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Data"):WaitForChild("Settings"):FireServer("Update",{Value = "ON",Setting = "Hide Other's Units In Lobby"})
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Data"):WaitForChild("Settings"):FireServer("Update",{Value = "ON",Setting = "InvisibleEnemy"})
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Data"):WaitForChild("Settings"):FireServer("Update",{Value = "OFF",Setting = "Global Message"})
    else
        Services.Lighting.Brightness = 1.51
        Services.Lighting.GlobalShadows = true
        Services.Lighting.Technology = Enum.Technology.Future
        Services.Lighting.ShadowSoftness = 0
        Services.Lighting.EnvironmentDiffuseScale = 1
        Services.Lighting.EnvironmentSpecularScale = 1

        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = true
            end
        end
        for _, obj in pairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 0
            end
        end
        
        for _, gui in pairs(Services.Players.LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()) do
            if gui:IsA("UIGradient") or gui:IsA("UIStroke") or gui:IsA("DropShadowEffect") then
                gui.Enabled = true
            end
        end
        
        for _, obj in pairs(Services.Lighting:GetChildren()) do
            if obj:IsA("BloomEffect") or obj:IsA("ColorCorrectionEffect") or
            obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") then
                obj.Enabled = true
            end
        end
    end
end

    local Toggle = LobbyTab:CreateToggle({
    Name = "Snipe Unit From Black Market",
    CurrentValue = false,
    Flag = "AutoPurchaseBlackMarket",
    Callback = function(Value)
        State.AutoPurchaseBlackMarket = Value
    end,
    })

    local Input = LobbyTab:CreateInput({
    Name = "Input Unit Name (Black Market)",
    CurrentValue = "",
    PlaceholderText = "Input Unit Name...",
    RemoveTextAfterFocusLost = false,
    Flag = "BlackMarketInput",
    Callback = function(Text)
        local CleanedText = Text:gsub("^%s+", ""):gsub("%s+$", "")
        print(CleanedText)
        State.AutoPurchaseBlackMarketSelected = CleanedText
    end,
})

task.spawn(function()
    while true do
        if State.AutoPurchaseBlackMarket and State.AutoPurchaseBlackMarketSelected then
        checkBlackMarket()
        end
        task.wait(0.1)
    end
end)

    AutoJoinDelaySlider = JoinerTab:CreateSlider({
    Name = "Auto Join Delay",
    Range = {0, 60},
    Increment = 1,
    Suffix = " seconds",
    CurrentValue = 0,
    Flag = "AutoJoinDelay",
    Callback = function(Value)
        State.AutoJoinDelay = Value
    end,
})

     JoinerSection = JoinerTab:CreateSection("📖 Story Joiner 📖")


     AutoJoinStoryToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Story",
    CurrentValue = false,
    Flag = "AutoJoinStory",
    Callback = function(Value)
        State.AutoJoinStory = Value
    end,
    })

    local StoryStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Story Stage",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryStageSelector",
    Callback = function(Option)
        State.StoryStageSelected = Option[1]
    end,
})

     ChapterDropdown869 = JoinerTab:CreateDropdown({
    Name = "Select Story Act",
    Options = {"Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6","Infinity"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryActSelector",
    Callback = function(Option)
    if Option[1] == "Infinity" then
        State.StoryActSelected = "Infinity"
    else
        local num = Option[1]:match("%d+")
        State.StoryActSelected = num
        end
    end,
})

     ChapterDropdown = JoinerTab:CreateDropdown({
    Name = "Select Story Difficulty",
    Options = {"Normal","Nightmare"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryDifficultySelector",
    Callback = function(Option)
        State.StoryDifficultySelected = Option[1]
    end,
    })

     JoinerSection00 = JoinerTab:CreateSection("⚔️ Raid Joiner ⚔️")

     AutoJoinRaidToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Raid",
    CurrentValue = false,
    Flag = "AutoJoinRaid",
    Callback = function(Value)
        State.AutoJoinRaid = Value
    end,
    })

    local StageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Raid Stage",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "RaidStageSelector",
    Callback = function(Option)
        State.RaidStageSelected = Option[1]
    end,
})

     JoinerSection00 = JoinerTab:CreateSection("🏆 Challenge Joiner 🏆")

     AutoJoinChallengeToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Challenge",
    CurrentValue = false,
    Flag = "AutoJoinChallenge",
    Callback = function(Value)
        State.AutoJoinChallenge = Value
    end,
    })

     JoinerSection00 = JoinerTab:CreateSection("🌀 Portal Joiner 🌀")

     AutoJoinPortalToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Portal",
    CurrentValue = false,
    Flag = "AutoJoinPortal",
    Callback = function(Value)
        State.AutoJoinPortal = Value
    end,
    })

     local PortalStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Portal to join",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "AutoJoinPortalSelector",
    Callback = function(Options)
        State.AutoJoinPortalSelected = Options[1]
    end,
})

     JoinerSection00 = JoinerTab:CreateSection("👹 Event Joiner 👹")

     AutoJoinEventToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Event",
    CurrentValue = false,
    Flag = "AutoJoinEvent",
    Callback = function(Value)
        State.AutoJoinEvent = Value
    end,
    })

      EventStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Event to join",
    Options = {"Johny Joestar (JojoEvent)","Mushroom Rush (Mushroom)","Verdant Shroud (Mushroom2)","Frontline Command Post (Ragna)","Summer Beach (Summer)","Shibuya Event (Shibuya)"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "AutoJoinEventSelector",
    Callback = function(Options)
        local extracted = string.match(Options[1], "%((.-)%)")
        State.AutoJoinEventSelected = extracted
    end,
})

     AutoJoinLimitedEventToggle = JoinerTab:CreateToggle({
    Name = "Auto Join CSM Event",
    CurrentValue = false,
    Flag = "AutoJoinEvent",
    Callback = function(Value)
        State.AutoJoinLimitedEvent = Value
    end,
    })

 EventLimitedStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select CSM Event Difficulty",
    Options = {"Easy", "Hard", "Hell"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "AutoJoinLimitedEventSelector",
    Callback = function(selected)
        if selected[1] == "Easy" then
            State.AutoJoinLimitedEventSelected = "Easy_Hell"
        elseif selected[1] == "Hard" then
            State.AutoJoinLimitedEventSelected = "Hard_Hell"
        elseif selected[1] == "Hell" then
            State.AutoJoinLimitedEventSelected = "Hell_Devil"
        end
    end,
})

     JoinerSection00 = JoinerTab:CreateSection("🏆 Worldline Joiner 🏆")

     AutoJoinWorldlineToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Worldlines",
    CurrentValue = false,
    Flag = "AutoJoinWorldlines",
    Callback = function(Value)
        State.AutoJoinWorldlines = Value
    end,
    })

      WorldlineStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Worldline to join",
    Options = {"Double Dungeon (doubledungeon)","Double Dungeon 2 (doubledungeon2)","Lingxian Academy (lingxianacademy)","Lingxian Yard (lingxianyard)"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "AutoJoinWorldlinesSelector",
    Callback = function(Options)
        local extracted = string.match(Options[1], "%((.-)%)")
        State.AutoJoinWorldlinesSelected = extracted
    end,
})

     JoinerSection00 = JoinerTab:CreateSection("🪜 Tower Joiner 🪜")

     AutoJoinTowerToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Tower",
    CurrentValue = false,
    Flag = "AutoJoinTower",
    Callback = function(Value)
        State.AutoJoinTower = Value
    end,
    })

      AutoJoinTowerStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Tower to join",
    Options = {"Cursed Place","The Lost Ancient World"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "AutoJoinTowerSelector",
    Callback = function(Options)
        State.AutoJoinTowerSelected = Options[1]
    end,
}) 

     JoinerSection00 = JoinerTab:CreateSection("🚪 Gate Joiner 🚪")

     AutoJoinGateToggle = JoinerTab:CreateToggle({
    Name = "Auto Join Gate",
    CurrentValue = false,
    Flag = "AutoJoinGate",
    Callback = function(Value)
        State.AutoJoinGate = Value
    end,
    })

local GameSection = GameTab:CreateSection("👥 Player 👥")

local Toggle = GameTab:CreateToggle({
    Name = "Black Screen",
    CurrentValue = false,
    Flag = "enableBlackScreen",
    Callback = function(Value)
        State.enableBlackScreen = Value
        enableBlackScreen()
    end,
})

    local Slider = GameTab:CreateSlider({
   Name = "Max Camera Zoom Distance",
   Range = {5, 100},
   Increment = 1,
   Suffix = "",
   CurrentValue = 35,
   Flag = "CameraZoomDistanceSelector",
   Callback = function(Value)
        Services.Players.LocalPlayer.CameraMaxZoomDistance = Value
   end,
})

    local Toggle = GameTab:CreateToggle({
    Name = "Anti AFK (No kick message)",
    CurrentValue = false,
    Flag = "AntiAfkKickToggle",
    Info = "Prevents roblox kick message.",
    TextScaled = false,
    Callback = function(Value)
        State.AntiAfkKickEnabled = Value
    end,
})

task.spawn(function()
    Services.Players.LocalPlayer.Idled:Connect(function()
        if State.AntiAfkKickEnabled then
            Services.VIRTUAL_USER:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            Services.VIRTUAL_USER:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end
    end)
end)

local Toggle = GameTab:CreateToggle({
    Name = "Streamer Mode (hide name/level/title)",
    CurrentValue = false,
    Flag = "StreamerMode",
    Callback = function(Value)
        State.streamerModeEnabled = Value
    end,
})

local Toggle = GameTab:CreateToggle({
    Name = "Low Performance Mode",
    CurrentValue = false,
    Flag = "LowPerformanceMode",
    Callback = function(Value)
        State.enableLowPerformanceMode = Value
        enableLowPerformanceMode()
    end,
})

if State.enableLowPerformanceMode then
    enableLowPerformanceMode()
end

 Toggle = GameTab:CreateToggle({
    Name = "Limit FPS",
    CurrentValue = false,
    Flag = "enableLimitFPS",
    Callback = function(Value)
        State.enableLimitFPS = Value
        updateFPSLimit()
    end,
})

 Slider = GameTab:CreateSlider({
   Name = "Limit FPS To",
   Range = {0, 240},
   Increment = 1,
   Suffix = " FPS",
   CurrentValue = 60,
   Flag = "FPSSelector",
   Callback = function(Value)
        State.SelectedFPS = Value
        updateFPSLimit()
   end,
})

local GameSection = GameTab:CreateSection("🎮 Game 🎮")

local Toggle = GameTab:CreateToggle({
    Name = "Delete Enemies",
    CurrentValue = false,
    Flag = "enableDeleteEnemies",
    Info = "Removes Enemy Models.",
    TextScaled = false,
    Callback = function(Value)
        State.deleteEntities = Value
        
        if Value then
            task.spawn(function()
                local agentFolder = workspace:FindFirstChild("Ground")
                if agentFolder then
                    local agentSubFolder = agentFolder:FindFirstChild("enemyClient")
                    if agentSubFolder then
                        -- Delete existing models first
                        for _, model in pairs(agentSubFolder:GetChildren()) do
                            if model and model.Parent then
                                model:Destroy()
                            end
                        end
                        
                        State.childAddedConnection = agentSubFolder.ChildAdded:Connect(function(child)
                            if State.deleteEntities and child then
                                child:Destroy()
                            end
                        end)
                    end
                end
            end)
        else
            if State.childAddedConnection then
                State.childAddedConnection:Disconnect()
                State.childAddedConnection = nil
            end
        end
    end,
})

local Toggle = GameTab:CreateToggle({
    Name = "Auto Start Game",
    CurrentValue = false,
    Flag = "AutoStartGame",
    Callback = function(Value)
        State.AutoStartGame = Value
        if Value then
            if Services.Players.LocalPlayer.PlayerGui.GameEvent.VoteSkip.Visible == true and string.lower(Services.Players.LocalPlayer.PlayerGui.GameEvent.VoteSkip.Button.Inset.textname.Text):match("start") then
                local connections = getconnections(Services.Players.LocalPlayer.PlayerGui.GameEvent.VoteSkip.Button.Button.MouseButton1Click)
                for _, connection in ipairs(connections) do
                connection:Fire()
                end
            end
        end
    end,
})

task.spawn(function()
        while true do
    if State.AutoStartGame then
        if Services.Players.LocalPlayer.PlayerGui.GameEvent.VoteSkip.Visible == true and string.lower(Services.Players.LocalPlayer.PlayerGui.GameEvent.VoteSkip.Button.Inset.textname.Text):match("start") then
            pcall(function()
                task.wait(2)
                local connections = getconnections(Services.Players.LocalPlayer.PlayerGui.GameEvent.VoteSkip.Button.Button.MouseButton1Click)
                for _, connection in ipairs(connections) do
                connection:Fire()
                end
            end)
        end
    end
    task.wait(1)
end
end)

local Toggle = GameTab:CreateToggle({
    Name = "Auto Vote Retry",
    CurrentValue = false,
    Flag = "AutoVoteRetry",
    Callback = function(Value)
        State.AutoVoteRetry = Value
        if Value then
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("Control"):FireServer("RetryVote")
        end
    end,
})

local Toggle2 = GameTab:CreateToggle({
    Name = "Auto Vote Next",
    CurrentValue = false,
    Flag = "AutoVoteNext", 
    Callback = function(Value)
        State.AutoVoteNext = Value
        if Value then
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("Control"):FireServer("Next Stage Vote")
        end
    end,
})

local Toggle2 = GameTab:CreateToggle({
    Name = "Auto Vote Lobby",
    CurrentValue = false,
    Flag = "AutoVoteLobby",
    Callback = function(Value)
        State.AutoVoteLobby = Value
    end,
})

    Toggle = GameTab:CreateToggle({
    Name = "Auto Skip Waves",
    CurrentValue = false,
    Flag = "AutoSkipWaves",
    Callback = function(Value)
            State.AutoSkipWaves = Value
            if Services.Players.LocalPlayer.PlayerGui.GUI.SkipwaveFrame.Visible == true then
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("Vote"):FireServer("Vote2")
            end
    end,
    })

    Slider = GameTab:CreateSlider({
    Name = "Auto Skip Until Wave",
    Range = {0, 200},
    Increment = 1,
    Suffix = "wave",
    CurrentValue = 0,
    Flag = "Slider1",
    Info = "0 = disable",
    Callback = function(Value)
        State.AutoSkipUntilWave = Value
    end,
    })
        task.spawn(function()
        while true do
            task.wait(1)
            if State.AutoSkipWaves then
                local waveNum = Services.Workspace.GameSettings.Wave.Value
                local skipLimit = State.AutoSkipUntilWave
                if skipLimit == 0 then
                    local voteSkip = Services.Players.LocalPlayer.PlayerGui.GUI.SkipwaveFrame
                    if voteSkip and voteSkip.Visible then
                        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("Vote"):FireServer("Vote2")
                    end
                elseif waveNum <= skipLimit then
                    local voteSkip = Services.Players.LocalPlayer.PlayerGui.GUI.SkipwaveFrame
                    if voteSkip and voteSkip.Visible then
                        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("Vote"):FireServer("Vote2")
                    end
                end
            end
        end
    end)

--[[local function tryPickCard()
    -- Don't pick cards during retry
    if State.AutoPickCard and State.AutoPickCardSelected ~= nil and not isRetryInProgress then
        if Services.Workspace.GameSettings.GameStarted.Value == false then
            local mode = Services.Workspace.GameSettings.StagesChallenge.Mode.Value
            if mode == nil or mode == "" then
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("StageChallenge"):FireServer(State.AutoPickCardSelected)
                end)
            end
        end
    end
end--]]

local Toggle = GameTab:CreateToggle({
    Name = "Auto Pick Card",
    CurrentValue = false,
    Flag = "AutoPickCard",
    Callback = function(Value)
        State.AutoPickCard = Value
       -- if Value then
         --   tryPickCard()
       -- end
    end,
})

local Dropdown = GameTab:CreateDropdown({
   Name = "Select Difficulty Card (Host Only)",
   Options = {"Normal","Fast Wave","Super Faster Wave"},
   CurrentOption = {},
   MultipleOptions = false,
   Flag = "AutoPickCardSelection",
   Callback = function(Option)
        State.AutoPickCardSelected = Option[1]
   end,
})

local Toggle = GameTab:CreateToggle({
    Name = "Block Boss Damage to Units",
    CurrentValue = false,
    Flag = "BlockBossDamage",
    Callback = function(Value)
        State.BlockBossDamage = Value
    end,
})

local Toggle = GameTab:CreateToggle({
    Name = "Auto Collect Chests (Jojo Event)",
    CurrentValue = false,
    Flag = "AutoCollectChests",
    Callback = function(Value)
        State.AutoCollectChests = Value
    end,
})

GameTab:CreateSection("Auto Ability")

local function getUnitsWithAbilities()
    local SkillsModule = Services.ReplicatedStorage:WaitForChild("Module"):WaitForChild("Skills")
    local SkillsData = require(SkillsModule)
    
    local unitsWithAbilities = {}
    local unitSet = {} -- To avoid duplicates
    
    for unitName, skillData in pairs(SkillsData) do
        if not unitSet[unitName] then
            table.insert(unitsWithAbilities, unitName)
            unitSet[unitName] = true
        end
    end
    
    -- Sort alphabetically
    table.sort(unitsWithAbilities)
    
    return unitsWithAbilities
end

local function getAbilitiesForSelectedUnits()
    if not State.SelectedUnitsForAbility or #State.SelectedUnitsForAbility == 0 then
        return {}
    end
    
    local SkillsModule = Services.ReplicatedStorage:WaitForChild("Module"):WaitForChild("Skills")
    local SkillsData = require(SkillsModule)
    
    local abilities = {}
    local abilitySet = {} -- To avoid duplicates
    
    for _, unitName in ipairs(State.SelectedUnitsForAbility) do
        local skillData = SkillsData[unitName]
        if skillData then
            -- Check for Skill1 and Skill2 (multi-skill units)
            if skillData.Skill1 and type(skillData.Skill1) == "string" then
                local abilityName = skillData.Skill1
                if not abilitySet[abilityName] then
                    table.insert(abilities, abilityName)
                    abilitySet[abilityName] = true
                end
            end
            if skillData.Skill2 and type(skillData.Skill2) == "string" then
                local abilityName = skillData.Skill2
                if not abilitySet[abilityName] then
                    table.insert(abilities, abilityName)
                    abilitySet[abilityName] = true
                end
            end
            -- For single-skill units, use "Default Ability"
            if not skillData.Skill1 and not skillData.Skill2 then
                if not abilitySet["Default Ability"] then
                    table.insert(abilities, "Default Ability")
                    abilitySet["Default Ability"] = true
                end
            end
        end
    end
    
    -- Sort alphabetically - but verify all entries are strings first
    local validAbilities = {}
    for _, ability in ipairs(abilities) do
        if type(ability) == "string" then
            table.insert(validAbilities, ability)
        end
    end
    
    table.sort(validAbilities)
    
    return validAbilities
end

local AutoUseAbilityToggle = GameTab:CreateToggle({
    Name = "Auto Use Ability",
    CurrentValue = false,
    Flag = "AutoUseAbility",
    Info = "Automatically uses selected abilities for selected units",
    Callback = function(Value)
        State.AutoUseAbility = Value
        if Value then
            local unitCount = State.SelectedUnitsForAbility and #State.SelectedUnitsForAbility or 0
            local abilityCount = State.SelectedAbilitiesToUse and #State.SelectedAbilitiesToUse or 0
            notify("Auto Ability", string.format("Enabled: %d units, %d abilities", unitCount, abilityCount))
        end
    end,
})

local UnitDropdown = GameTab:CreateDropdown({
    Name = "Select Units",
    Options = {},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "UnitAbilitySelector",
    Info = "Select which units to use abilities on",
    Callback = function(Options)
        State.SelectedUnitsForAbility = Options
        
        -- Update abilities dropdown based on selected units
        local availableAbilities = getAbilitiesForSelectedUnits()
        --AbilityDropdown:Refresh(availableAbilities)
        
        -- Clear selected abilities if they're no longer valid
        if State.SelectedAbilitiesToUse then
            local validAbilities = {}
            for _, ability in ipairs(State.SelectedAbilitiesToUse) do
                for _, available in ipairs(availableAbilities) do
                    if ability == available then
                        table.insert(validAbilities, ability)
                        break
                    end
                end
            end
            State.SelectedAbilitiesToUse = validAbilities
        end
    end,
})

local AbilityDropdown = GameTab:CreateDropdown({
    Name = "Select Abilities",
    Options = {},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "AbilitySelector",
    Info = "Select which abilities to use automatically",
    Callback = function(Options)
        State.SelectedAbilitiesToUse = Options
    end,
})

GameTab:CreateSection("Auto Ability - Sukuna")

local AutoUseAbilityToggleSukuna = GameTab:CreateToggle({
    Name = "Auto Use Sukuna Ability",
    CurrentValue = false,
    Flag = "AutoUseAbilitySukuna",
    Callback = function(Value)
        State.AutoUseAbilitySukuna = Value
    end,
})

local AbilityDropdownSukuna = GameTab:CreateDropdown({
    Name = "Select Sukuna Skill",
    Options = {"Domain","Mahoraga"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "UnitAbilitySelectorSukuna",
    Callback = function(Options)
        State.SelectedSukunaSkills = Options
    end,
})

task.spawn(function()
    task.wait(1) -- Wait for modules to load
    
    local abilitiesList = getUnitAbilitiesList()
    local displayNames = {}
    
    for _, abilityData in ipairs(abilitiesList) do
        table.insert(displayNames, abilityData.display)
    end
    
    AbilityDropdown:Refresh(displayNames)
    print("Loaded " .. #displayNames .. " unit abilities into dropdown")
end)

GameTab:CreateSection("Auto Sell")

AutoSellToggle = GameTab:CreateToggle({
        Name = "Auto Sell All Units",
        CurrentValue = false,
        Flag = "AutoSellEnabled",
        Info = "Automatically sell all your units when the specified wave is reached",
        Callback = function(Value)
            State.AutoSellEnabled = Value
            if Value then
                notify("Auto Sell", string.format("Enabled - will sell all units on wave %d", State.AutoSellWave))
            else
                notify("Auto Sell", "Disabled")
            end
        end,
    })

     AutoSellSlider = GameTab:CreateSlider({
        Name = "Sell on Wave",
        Range = {1, 50},
        Increment = 1,
        Suffix = "",
        CurrentValue = 10,
        Flag = "AutoSellWave",
        Info = "Wave number to automatically sell all units",
        Callback = function(Value)
            State.AutoSellWave = Value
            if State.AutoSellEnabled then
                notify("Auto Sell", string.format("Updated - will sell all units on wave %d", Value))
            end
        end,
    })

     AutoSellFarmToggle = GameTab:CreateToggle({
        Name = "Auto Sell Farm Units",
        CurrentValue = false,
        Flag = "AutoSellFarmEnabled",
        Info = "Automatically sell all farm units (that are sellable) when the specified wave is reached",
        Callback = function(Value)
            State.AutoSellFarmEnabled = Value
            if Value then
                notify("Auto Sell Farm", string.format("Enabled - will sell farm units on wave %d", State.AutoSellFarmWave))
            else
                notify("Auto Sell Farm", "Disabled")
            end
        end,
    })

     AutoSellFarmSlider = GameTab:CreateSlider({
        Name = "Sell Farm Units on Wave",
        Range = {1, 50},
        Increment = 1,
        Suffix = "",
        CurrentValue = 15,
        Flag = "AutoSellFarmWave",
        Info = "Wave number to automatically sell all farm units",
        Callback = function(Value)
            State.AutoSellFarmWave = Value
            if State.AutoSellFarmEnabled then
                notify("Auto Sell Farm", string.format("Updated - will sell farm units on wave %d", Value))
            end
        end,
    })

    local function sellAllPlayerUnits()
    if not State.AutoSellEnabled then return end
    
    local playerUnitsFolder = getPlayerUnitsFolder()
    
    if not playerUnitsFolder then
        print("No player units folder found")
        return
    end
    
    local soldCount = 0
    local unitsToSell = {}
    
    -- Collect all units (excluding PLACEMENTFOLDER)
    for _, unit in pairs(playerUnitsFolder:GetChildren()) do
        if unit.Name ~= "PLACEMENTFOLDER" then
            table.insert(unitsToSell, unit)
        end
    end
    
    -- Sell each unit
    for _, unit in pairs(unitsToSell) do
        local success = pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
                :WaitForChild("Events"):WaitForChild("ManageUnits")
                :InvokeServer("Selling", unit.Name)
        end)
        
        if success then
            soldCount = soldCount + 1
            print("Sold unit:", unit.Name)
        else
            warn("Failed to sell unit:", unit.Name)
        end
        
        task.wait(0.1) -- Small delay to prevent overwhelming the server
    end
    
    if soldCount > 0 then
        notify("Auto Sell", string.format("Sold %d units on wave %d", soldCount, State.AutoSellWave))
        print(string.format("Auto-sold %d units on wave %d", soldCount, State.AutoSellWave))
    end
end

    local function sellAllFarmUnits()
    if not State.AutoSellFarmEnabled then return end
    
    local playerUnitsFolder = getPlayerUnitsFolder()
    
    if not playerUnitsFolder then
        print("No player units folder found")
        return
    end
    
    local soldCount = 0
    local farmUnitsToSell = {}
    
    -- Collect all farm units
    for _, unit in pairs(playerUnitsFolder:GetChildren()) do
        if unit.Name ~= "PLACEMENTFOLDER" then
            -- Check if unit has PlaceType and if it's "Farm"
            local placeType = unit:FindFirstChild("PlaceType")
            if placeType and placeType:IsA("StringValue") and placeType.Value == "Farm" then
                table.insert(farmUnitsToSell, unit)
                print("Found farm unit:", unit.Name)
            end
        end
    end
    
    -- Sell each farm unit
    for _, unit in pairs(farmUnitsToSell) do
        local success = pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
                :WaitForChild("Events"):WaitForChild("ManageUnits")
                :InvokeServer("Selling", unit.Name)
        end)
        
        if success then
            soldCount = soldCount + 1
            print("Sold farm unit:", unit.Name)
        else
            warn("Failed to sell farm unit:", unit.Name)
        end
        
        task.wait(0.1) -- Small delay to prevent overwhelming the server
    end
    
    if soldCount > 0 then
        notify("Auto Sell Farm", string.format("Sold %d farm units on wave %d", soldCount, State.AutoSellFarmWave))
        print(string.format("Auto-sold %d farm units on wave %d", soldCount, State.AutoSellFarmWave))
    else
        print("No farm units found to sell on wave", State.AutoSellFarmWave)
    end
end

        local function monitorWavesForAutoSell()
        if not Services.Workspace.GameSettings.Wave then
            Services.Workspace.GameSettings:WaitForChild("Wave")
        end
        
        local waveNum = Services.Workspace.GameSettings.Wave
        local lastProcessedWave = 0
        
        waveNum.Changed:Connect(function(newWave)
            if State.AutoSellEnabled and newWave == State.AutoSellWave and newWave ~= lastProcessedWave then
                lastProcessedWave = newWave
                print("Auto-sell triggered on wave", newWave)
                
                -- Small delay to ensure wave has properly started
                task.wait(0.5)
                sellAllPlayerUnits()
            end
        end)
        
        -- Check initial wave value
        local currentWave = waveNum.Value
        if State.AutoSellEnabled and currentWave == State.AutoSellWave and currentWave ~= lastProcessedWave then
            lastProcessedWave = currentWave
            task.wait(0.5)
            sellAllPlayerUnits()
        end
    end

    local function monitorWavesForAutoSellFarm()
        if not Services.Workspace.GameSettings.Wave then
            Services.Workspace.GameSettings:WaitForChild("Wave")
        end
        
        local waveNum = Services.Workspace.GameSettings.Wave
        local lastProcessedFarmWave = 0
        
        waveNum.Changed:Connect(function(newWave)
            if State.AutoSellFarmEnabled and newWave == State.AutoSellFarmWave and newWave ~= lastProcessedFarmWave then
                lastProcessedFarmWave = newWave
                print("Auto-sell farm units triggered on wave", newWave)
                
                -- Small delay to ensure wave has properly started
                task.wait(0.5)
                sellAllFarmUnits()
            end
        end)
        
        -- Check initial wave value
        local currentWave = waveNum.Value
        if State.AutoSellFarmEnabled and currentWave == State.AutoSellFarmWave and currentWave ~= lastProcessedFarmWave then
            lastProcessedFarmWave = currentWave
            task.wait(0.5)
            sellAllFarmUnits()
        end
    end

local function collectChest(chest)
    if isInLobby() then return end
    if not State.AutoCollectChests then return end
    
    -- Get player's current character and root part
    local currentChar = Services.Players.LocalPlayer.Character
    if not currentChar then return end
    
    local currentRoot = currentChar:FindFirstChild("HumanoidRootPart")
    if not currentRoot then return end
    
    -- Find the ProximityPrompt in the chest
    local prompt = chest:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then
        -- Check if it's in a child of the chest
        for _, child in pairs(chest:GetDescendants()) do
            if child:IsA("ProximityPrompt") then
                prompt = child
                break
            end
        end
    end
    
    if not prompt then 
        print("No ProximityPrompt found in chest:", chest.Name)
        return 
    end
    
    -- Store original position
    local originalPosition = currentRoot.CFrame
    
    -- Teleport to chest
    currentRoot.CFrame = chest.CFrame + Vector3.new(0, 5, 0) -- Teleport slightly above chest
    
    -- Wait a brief moment for teleportation
    task.wait(0.1)
    
    -- Keep trying to collect until chest disappears or we timeout
    local maxAttempts = 20  -- Maximum number of attempts
    local attempts = 0
    local attemptDelay = 0.2  -- Delay between attempts
    
    print("Starting chest collection for:", chest.Name)
    
    while chest.Parent and attempts < maxAttempts do
        attempts = attempts + 1
        
        -- Try to fire the proximity prompt
        local success, err = pcall(function()
            prompt:InputHoldBegin()
            task.wait(0.1)
            prompt:InputHoldEnd()
        end)
        
        if not success then
            -- If the prompt method fails, try the player-specific method
            pcall(function()
                prompt:InputHoldBegin(Services.Players.LocalPlayer)
                task.wait(0.1)
                prompt:InputHoldEnd(Services.Players.LocalPlayer)
            end)
        end
        
        print(string.format("Chest collection attempt %d/%d for %s", attempts, maxAttempts, chest.Name))
        
        -- Wait a moment to see if chest disappears
        task.wait(attemptDelay)
        
        -- Check if chest still exists
        if not chest.Parent then
            print("Chest successfully collected after", attempts, "attempts")
            break
        end
        
        -- If chest still exists after several attempts, try repositioning
        if attempts % 5 == 0 then
            -- Try a slightly different position
            local offset = Vector3.new(math.random(-2, 2), 5, math.random(-2, 2))
            currentRoot.CFrame = chest.CFrame + offset
            task.wait(0.1)
        end
    end
    
    if chest.Parent then
        print("Warning: Chest", chest.Name, "still exists after", attempts, "attempts")
    end
    
    -- Optional: Return to original position (comment out if you don't want this)
     currentRoot.CFrame = originalPosition
end

local function onChildAdded(child)
    if isInLobby() then return end
    if State.AutoCollectChests then
        -- Small delay to ensure chest is fully loaded
        task.wait(0.1)
        collectChest(child)
    end
end

local function collectExistingChests()
    if isInLobby() then return end
    local chestFolder = Services.Workspace:FindFirstChild("ChestSpawned")
    if not chestFolder then return end
    
    for _, chest in pairs(chestFolder:GetChildren()) do
        if State.AutoCollectChests then
            collectChest(chest)
            task.wait(0.1) -- Small delay between chests
        else
            break -- Stop if toggle was turned off
        end
    end
end

local function setupChestDetection()
    if isInLobby() then return end
    local chestFolder = Services.Workspace:FindFirstChild("ChestSpawned")
    
    if not chestFolder then
        -- Wait for ChestSpawned folder to exist using while loop
        task.spawn(function()
            while not Services.Workspace:FindFirstChild("ChestSpawned") do
                task.wait(0.1)
            end
            setupChestDetection()
        end)
        return
    end
    
    -- Connect to new chests being added
    chestFolder.ChildAdded:Connect(onChildAdded)
    
    -- Monitor toggle state and collect existing chests when enabled
    task.spawn(function()
        local lastToggleState = State.AutoCollectChests
        while true do
            task.wait(0.1)
            
            if State.AutoCollectChests and not lastToggleState then
                -- Toggle was just turned on, collect existing chests
                task.spawn(collectExistingChests)
            end
            
            lastToggleState = State.AutoCollectChests
        end
    end)
end

setupChestDetection()

    local function getCurrentWave()
        return Services.Workspace.GameSettings:FindFirstChild("Wave").Value or 0
    end

local function getUnitDisplayName(unit)
    if not unit then return nil end
    return unit:GetAttribute("original_name")
end

local function getUnitSpawnId(unit)
    if not unit then return nil end
    local spawnId = unit.Name:match("%s(%d+)$")
    return spawnId and tonumber(spawnId) or nil
end

local function takeUnitsSnapshot()
    local snapshot = {}
    local playerUnitsFolder = getPlayerUnitsFolder()
    
    if not playerUnitsFolder then 
        return snapshot 
    end
    
    for _, unit in pairs(playerUnitsFolder:GetChildren()) do
        local displayName = getUnitDisplayName(unit)
        local spawnId = getUnitSpawnId(unit)
        
        if displayName and spawnId then
            table.insert(snapshot, {
                instance = unit,
                name = unit.Name,
                displayName = displayName,
                spawnId = spawnId,
                position = unit:FindFirstChild("HumanoidRootPart") and unit.HumanoidRootPart.Position or nil
            })
        end
    end
    
    return snapshot
end

local function findNewlyPlacedUnit(beforeSnapshot, afterSnapshot)
    local beforeSpawnIds = {}
    for _, unitData in pairs(beforeSnapshot) do
        beforeSpawnIds[unitData.spawnId] = true
    end
    
    for _, unitData in pairs(afterSnapshot) do
        if not beforeSpawnIds[unitData.spawnId] then
            return unitData.instance, unitData.displayName, unitData.spawnId
        end
    end
    
    return nil, nil, nil
end

local function getDisplayNameFromUnit(unitString)
    -- "Shigeru (Gachi Fighter) #1" -> "Shigeru (Gachi Fighter)"
    return unitString:match("^(.+)%s#%d+$") or unitString
end

local function getPlacementNumber(unitString)
    -- "Shigeru (Gachi Fighter) #1" -> 1
    return tonumber(unitString:match("#(%d+)$"))
end

local function getBaseUnitName(fullName)
    -- "Shigeru (Gachi Fighter) 1" -> "Shigeru (Gachi Fighter)"
    return fullName:match("^(.+)%s+%d+$") or fullName
end

local function findLatestSpawnedUnit(unitDisplayName, targetCFrame, strictTolerance)
    strictTolerance = strictTolerance or 8
    local playerUnitsFolder = getPlayerUnitsFolder()
    if not playerUnitsFolder then
        warn("Player units folder not found")
        return nil
    end
    
    local baseUnitName = getBaseUnitName(unitDisplayName)
    print(string.format("🔍 Searching for: %s (base: %s)", unitDisplayName, baseUnitName))
    
    -- Build set of already tracked spawn IDs FOR THIS SPECIFIC UNIT TYPE
    local alreadyTrackedForThisUnit = {}
    for spawnId, placementId in pairs(recordingSpawnIdToPlacement) do
        -- Extract unit type from placement ID (e.g., "Judar (Era) #1" -> "Judar (Era)")
        local trackedUnitType = placementId:match("^(.+)%s#%d+$")
        if trackedUnitType == baseUnitName then
            alreadyTrackedForThisUnit[tonumber(spawnId)] = true
        end
    end
    
    print(string.format("Already tracked spawn IDs for %s: %d", baseUnitName, table.maxn(alreadyTrackedForThisUnit)))
    
    -- Collect untracked units of matching type
    local candidates = {}
    local scannedCount = 0
    local matchedTypeCount = 0
    
    for _, unit in pairs(playerUnitsFolder:GetChildren()) do
        scannedCount = scannedCount + 1
        local unitBaseName = getBaseUnitName(unit.Name)
        
        -- Debug: Show what we're comparing
        if scannedCount <= 5 then
            print(string.format("Comparing: '%s' vs '%s'", unitBaseName, baseUnitName))
        end
        
        if unitBaseName == baseUnitName then
            matchedTypeCount = matchedTypeCount + 1
            local spawnId = getUnitSpawnId(unit)
            
            print(string.format("  → Matched type! Unit: %s, SpawnID: %s, Already tracked: %s", 
                unit.Name, tostring(spawnId), tostring(alreadyTrackedForThisUnit[spawnId] or false)))
            
            if spawnId and not alreadyTrackedForThisUnit[spawnId] then
                local originCFrame = unit:GetAttribute("origin")
                local hrp = originCFrame.Position
                if hrp then
                    local distance = (hrp - targetCFrame.Position).Magnitude
                    
                    print(string.format("  → Distance: %.2f studs (tolerance: %.2f)", distance, strictTolerance))
                    
                    if distance <= strictTolerance then
                        table.insert(candidates, {
                            unit = unit,
                            name = unit.Name,
                            distance = distance,
                            spawnId = spawnId,
                            position = hrp
                        })
                        print(string.format("  ✓ Added as candidate!"))
                    end
                end
            end
        end
    end
    
    print(string.format("Scan results: %d total units, %d matched type, %d candidates within range", 
        scannedCount, matchedTypeCount, #candidates))
    
    if #candidates == 0 then
        print("❌ No candidates found!")
        return nil
    end
    
    -- Sort by distance (closest first)
    table.sort(candidates, function(a, b) return a.distance < b.distance end)
    
    local best = candidates[1]
    print(string.format("✓ Found unit: %s at %.2f studs (ID: %d)", 
        best.name, best.distance, best.spawnId))
    
    return best.name
end

local function StreamerMode()
    local player = game:GetService("Players").LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local head = char:WaitForChild("Head", 5)
    if not head then return end

    local billboard = head:FindFirstChild("GUI")
        and head.GUI:FindFirstChild("GUI")
        and head.GUI.GUI:FindFirstChild("Frame")

    if not billboard then
        warn("No billboard found")
        return
    end

    -- Try both possible paths for originalNumbers
    local mainGui = player:WaitForChild("PlayerGui"):WaitForChild("Main")

    local levelFrame = mainGui:FindFirstChild("LevelFrame") or
        (mainGui:FindFirstChild("UnitBar") and mainGui.UnitBar:FindFirstChild("LevelFrame"))

    if not levelFrame then
        warn("No LevelFrame found")
        return
    end

    local frame = levelFrame:FindFirstChild("Frame")
    if not frame then
        warn("No Frame found inside LevelFrame")
        return
    end

    local originalNumbers = frame:FindFirstChild("texts")
    if not originalNumbers then
        warn("No originalNumbers (texts) found")
        return
    end

    -- Check for or create streamerLabel in the same Frame
    local streamerLabel = frame:FindFirstChild("Numbers_Streamer")
    if not streamerLabel then
        streamerLabel = originalNumbers:Clone()
        streamerLabel.Name = "Numbers_Streamer"
        streamerLabel.Text = "Level 999 - Protected by Lixhub"
        streamerLabel.Visible = false
        streamerLabel.Parent = frame
    end

    -- Apply streamer mode
    if State.streamerModeEnabled then
        local playerName = billboard:FindFirstChild("PlayerName")
        local title = billboard:FindFirstChild("Title")

        if playerName then playerName.Text = "🔥 PROTECTED BY LIXHUB 🔥" end
        if title then title.Text = "LIXHUB USER" end

        originalNumbers.Visible = false
        streamerLabel.Visible = true
    else
        local playerName = billboard:FindFirstChild("PlayerName")
        local title = billboard:FindFirstChild("Title")

        if playerName then
            playerName.Text = "Lv. " .. player:WaitForChild("Data").Levels.Value ..
                " | " .. tostring(player.Name)
        end
        if title then
            title.Text = player:WaitForChild("Data").Title.Value
        end

        originalNumbers.Visible = true
        streamerLabel.Visible = false
    end
end

        task.spawn(function()
            while true do
                task.wait(0.1)
                StreamerMode()
            end
        end)

local function clearSpawnIdMappings()
    playbackUnitMapping = {}
    trackedUnits = {}
    recordingPlacementCounter = {}
    placementExecutionLock = false
    print("✓ Cleared all tracking data")
end

local function startRecordingNow()
    if gameStartTime == 0 then
        gameStartTime = tick()
        print("Set game start time for recording:", gameStartTime)
    end
    
    recordingHasStarted = true
    clearSpawnIdMappings()
    table.clear(macro)
    trackedUnits = {}
    
    MacroStatusLabel:Set("Status: Recording active!")
    print("Recording started")
end

local function getMacroFilename(name)
        if type(name) == "table" then
            name = name[1] or ""
        end
        
        -- Ensure name is a string
        if type(name) ~= "string" or name == "" then
            warn("getMacroFilename: Invalid name provided:", name)
            return nil
        end
        
        return "LixHub/Macros/AG/" .. name .. ".json"
    end

local function saveMacroToFile(name)
    local data = macroManager[name]
    if not data then return end

    local json = Services.HttpService:JSONEncode(data)
    writefile(getMacroFilename(name), json)
end

local function setupGameTimeTracking()
    if isInLobby() then return end
    local waveNum = Services.Workspace.GameSettings.Wave
    
waveNum.Changed:Connect(function(newWave)
    if newWave >= 1 and not gameInProgress then
        gameInProgress = true
        gameStartTime = tick()
        
        -- Auto-start recording if enabled
        if isRecording and not recordingHasStarted then
            startRecordingNow()
        end
        
    elseif newWave == 0 and gameInProgress then
        gameInProgress = false
        
        -- Auto-stop recording
        if isRecording and recordingHasStarted then
            recordingHasStarted = false
            
            if currentMacroName and #macro > 0 then
                macroManager[currentMacroName] = macro
                saveMacroToFile(currentMacroName)
                Rayfield:Notify({
                    Title = "Recording Auto-Saved",
                    Content = string.format("%s (%d actions)", currentMacroName, #macro),
                    Duration = 3
                })
            end
        end
    end
end)
    
    -- Check current wave on startup
    if waveNum.Value >= 1 then
        gameInProgress = true
        gameStartTime = tick()
        print("Joined mid-game, tracking time from now")
    end
end

local function startGameTracking()
    if gameInProgress then return end
    
    gameInProgress = true
    gameStartTime = tick()
    
    -- Auto-start recording if enabled
    if isRecording and not recordingHasStarted then
        recordingHasStarted = true
        clearSpawnIdMappings()
        table.clear(macro)
        MacroStatusLabel:Set("Status: Recording active!")
        notify("Recording Started", "Game started - recording active.")
        print("Recording auto-started with game")
    end
    
    --State.startingInventory = snapshotInventory()
    
    print("Game tracking started - ready for macro playback/recording")
end

local function stopGameTracking()
    if not gameInProgress then return end
    
    print("Game ended - stopping tracking")
    
    -- Auto-stop recording if it was running
    if isRecording and recordingHasStarted then
        recordingHasStarted = false
        isRecording = false
        
        if RecordToggle then
            RecordToggle:Set(false)
        end
        
        Rayfield:Notify({
            Title = "Recording Stopped",
            Content = "Game ended, recording saved.",
            Duration = 3
        })
        
        if currentMacroName and #macro > 0 then
            macroManager[currentMacroName] = macro
            saveMacroToFile(currentMacroName)
            print(string.format("Auto-saved recording: %s with %d actions", currentMacroName, #macro))
        end
    end
    
    gameInProgress = false
    gameStartTime = 0
    
    print("Game tracking stopped")
end

local function getPlayerUnitsFolder()
    local unitServer = Services.Workspace:FindFirstChild("Ground") 
        and Services.Workspace.Ground:FindFirstChild("unitServer")
    
    if not unitServer then
        warn("unitServer not found!")
        return nil
    end
    
    local playerUnitsFolder = unitServer:FindFirstChild(tostring(Services.Players.LocalPlayer.Name).." (UNIT)")
    if not playerUnitsFolder then
        warn("Player units folder not found!")
        return nil
    end
    
    return playerUnitsFolder
end

local function getUnitUUIDFromInventory(displayName)
    local unitsInventory = Services.Players.LocalPlayer:FindFirstChild("UnitsInventory")
    if not unitsInventory then return nil end
    
    for _, folder in pairs(unitsInventory:GetChildren()) do
        if folder:IsA("Folder") then
            local unitValue = folder:FindFirstChild("Unit")
            if unitValue and unitValue.Value == displayName then
                return folder.Name -- This is the UUID
            end
        end
    end
    return nil
end

local function getEquippedUnitUUID(displayName)
    local unitsInventory = Services.Players.LocalPlayer:FindFirstChild("UnitsInventory")
    if not unitsInventory then return nil end
    
    for _, folder in pairs(unitsInventory:GetChildren()) do
        if folder:IsA("Folder") then
            local unitValue = folder:FindFirstChild("Unit")
            local dataSetting = folder:FindFirstChild("data") and folder.data:FindFirstChild("setting")
            local equipValue = dataSetting and dataSetting:FindFirstChild("equip")
            
            if unitValue and unitValue.Value == displayName and 
               equipValue and equipValue.Value == "t" then
                return folder.Name -- UUID
            end
        end
    end
    return nil
end

local function findUnitByPosition(unitDisplayName, targetPosition, tolerance)
    tolerance = tolerance or 5
    local playerUnitsFolder = getPlayerUnitsFolder()
    if not playerUnitsFolder then
        warn("Player units folder not found")
        return nil
    end
    
    local baseUnitName = getBaseUnitName(unitDisplayName)
    print(string.format("🔍 Looking for %s near (%.1f, %.1f, %.1f)", 
        baseUnitName, targetPosition.X, targetPosition.Y, targetPosition.Z))
    
    local bestMatch = nil
    local bestDistance = math.huge
    
    for _, unit in pairs(playerUnitsFolder:GetChildren()) do
        if unit.Name == "PLACEMENTFOLDER" then continue end

        local unitBaseName = getBaseUnitName(unit.Name)
        
        if unitBaseName == baseUnitName then
            -- Check if already tracked
            if trackedUnits[unit.Name] then
                continue -- Skip already tracked units
            end
            
            local originAttr = unit:GetAttribute("origin")
            if originAttr then
                local originPos = originAttr.Position
                local distance = (originPos - targetPosition).Magnitude
                
                print(string.format("  → Checking %s: distance = %.2f studs", unit.Name, distance))
                
                if distance <= tolerance and distance < bestDistance then
                    bestMatch = unit.Name
                    bestDistance = distance
                end
            end
        end
    end
    
    if bestMatch then
        print(string.format("✓ Found match: %s (%.2f studs away)", bestMatch, bestDistance))
    else
        print("❌ No matching unit found within tolerance")
    end
    
    return bestMatch
end

local function getUnitCostFromUI(unitSlotNumber)
    local unitFrame = Services.Players.LocalPlayer.PlayerGui.Main.UnitBar.UnitsFrame.UnitsSlot:FindFirstChild("unit"..unitSlotNumber)
    
    if not unitFrame or unitFrame.unit.Value == "" then
        return nil
    end
    
    local unitName = unitFrame.unit.Value
    
    -- Find the Frame child with the unit name (not the StringValue)
    local unitDisplay = nil
    for _, child in pairs(unitFrame:GetChildren()) do
        if child.Name == unitName and child:IsA("Frame") then
            unitDisplay = child
            break
        end
    end
    
    if unitDisplay then
        local yenLabel = unitDisplay:FindFirstChild("yen")
        if yenLabel and yenLabel.Text then
            local cost = tonumber(yenLabel.Text:match("%d+"))
            return cost, unitName
        end
    end
    
    return nil
end

local function processPlacementAction(actionInfo)
    local args = actionInfo.args
    local unitDisplayName = args[1][1]
    local cframe = args[1][2]
    local rotation = args[1][3]
    local uuid = args[2] -- The UUID from the placement
    
    print(string.format("📝 Recording placement: %s at position (%.1f, %.1f, %.1f)", 
        unitDisplayName, cframe.Position.X, cframe.Position.Y, cframe.Position.Z))
    
    -- Wait a bit for unit to spawn
    task.wait(0.5)
    
    -- Find the unit by position
    local actualUnitName = findUnitByPosition(unitDisplayName, cframe.Position, 5)
    
    if not actualUnitName then
        warn("❌ RECORDING FAILED: Could not find unit at position:", unitDisplayName)
        return
    end
    
    -- Get placement cost from UI by finding which slot this UUID belongs to
    local placementCost = nil
    
        -- Find which slot number this unit is equipped in
        for slotNum = 1, 6 do
            local packageSlot = Services.Players.LocalPlayer.UnitPackage:FindFirstChild(tostring(slotNum))
            print("comparing "..packageSlot.Unit.Value.." with "..unitDisplayName)
            if packageSlot and packageSlot.Unit.Value == unitDisplayName then
                print("comparing success!")
                -- Found the slot, now get cost from UI
                local cost, _ = getUnitCostFromUI(slotNum)
                if cost then
                    placementCost = cost
                    print(string.format("✓ Found placement cost from UI slot %d: %d", slotNum, cost))
                end
                break
            end
    end
    
    if not placementCost then
        warn("❌ Could not determine placement cost from UI for:", unitDisplayName)
    end
    
    -- Increment placement counter for this unit type
    recordingPlacementCounter[unitDisplayName] = (recordingPlacementCounter[unitDisplayName] or 0) + 1
    local placementNumber = recordingPlacementCounter[unitDisplayName]
    local placementId = string.format("%s #%d", unitDisplayName, placementNumber)
    
    -- Record to macro
    local gameRelativeTime = actionInfo.timestamp - gameStartTime
    
    local placementRecord = {
        Type = "spawn_unit",
        Unit = placementId,
        Time = string.format("%.2f", gameRelativeTime),
        Position = {cframe.Position.X, cframe.Position.Y, cframe.Position.Z},
        Rotation = rotation,
        PlacementCost = placementCost
    }
    
    table.insert(macro, placementRecord)
    
    -- Map actual unit name to placement ID for upgrade/sell tracking
    trackedUnits[actualUnitName] = placementId
    
    print(string.format("✓ Recorded: %s → Server: %s (Cost: %d)", 
        placementId, actualUnitName, placementCost or 0))
end

local function executePlacementAction(action, actionIndex, totalActions)
    -- Prevent simultaneous placements
    while placementExecutionLock do
        task.wait(0.1)
    end
    placementExecutionLock = true
    
    print("=== EXECUTING PLACEMENT ===")
    print("Action Unit:", action.Unit)
    
    -- Extract placement order and display name
    local placementOrder = getPlacementNumber(action.Unit)
    local displayName = getDisplayNameFromUnit(action.Unit)
    
    if not placementOrder then
        warn("❌ Invalid placement order from:", action.Unit)
        placementExecutionLock = false
        return false
    end
    
    print("Placement Order:", placementOrder)
    print("Display Name:", displayName)
    
    -- Get UUID for equipped unit
    local uuid = getEquippedUnitUUID(displayName)
    
    if not uuid then
        warn("❌ Unit not equipped:", displayName)
        updateDetailedStatus(string.format("(%d/%d) ERROR: %s not equipped!", actionIndex, totalActions, displayName))
        placementExecutionLock = false
        return false
    end
    
    -- Reconstruct CFrame
    local pos = action.Position
    local cframe = CFrame.new(pos[1], pos[2], pos[3])
    
    local args = {
        {
            displayName,
            cframe,
            action.Rotation or 0
        },
        uuid
    }
    
    updateDetailedStatus(string.format("(%d/%d) Placing %s...", actionIndex, totalActions, action.Unit))
    
    -- Send placement request
    local success = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
            :WaitForChild("Events"):WaitForChild("spawnunit"):InvokeServer(unpack(args))
    end)
    
    if not success then 
        warn("❌ Failed to call spawnunit remote")
        placementExecutionLock = false
        return false 
    end
    
    -- Wait for unit to spawn and verify
    local placedUnitName = nil
    local maxWaitAttempts = 15
    
    for waitAttempt = 1, maxWaitAttempts do
        task.wait(0.5)
        
        placedUnitName = findLatestSpawnedUnit(displayName, cframe, 8)
        
        if placedUnitName then
            print(string.format("✅ Unit spawned after %.1fs", waitAttempt * 0.5))
            break
        end
        
        if waitAttempt < maxWaitAttempts then
            print(string.format("⏳ Waiting for spawn... (attempt %d/%d)", waitAttempt, maxWaitAttempts))
        end
    end
    
    if placedUnitName then
        -- ✅ CRITICAL FIX: Use full placement ID (e.g., "Ai #1") as key, not just the number
        playbackUnitMapping[action.Unit] = placedUnitName  -- Changed from [placementOrder]
        print(string.format("✓ MAPPED: %s → %s", action.Unit, placedUnitName))
        updateDetailedStatus(string.format("(%d/%d) Placed %s successfully", actionIndex, totalActions, action.Unit))
        placementExecutionLock = false
        return true
    end
    
    warn(string.format("❌ Failed to detect unit after %.1fs", maxWaitAttempts * 0.5))
    updateDetailedStatus(string.format("(%d/%d) FAILED to place %s", actionIndex, totalActions, action.Unit))
    placementExecutionLock = false
    return false
end

    local function getUnitUpgradeLevel(unit)
        --print(unit.Name)
        if Services.Workspace.Ground.unitServer:FindFirstChild(tostring(Services.Players.LocalPlayer.Name).." (UNIT)"):FindFirstChild(unit).Upgrade then
            return Services.Workspace.Ground.unitServer:FindFirstChild(tostring(Services.Players.LocalPlayer.Name).." (UNIT)"):FindFirstChild(unit).Upgrade.Value
        end
        return 0
    end

local mt = getrawmetatable(game)
setreadonly(mt, false)

-- Save the true original __namecall once
local originalNamecall = mt.__namecall

-- === General hook: placements, upgrades, sells, skips ===
local generalHook = newcclosure(function(self, ...)
    local args = { ... }
    local method = getnamecallmethod()

    if State.BlockBossDamage and method == "InvokeServer" and self.Name == "Damages" and args[1] == "BossDamage" then
        print("Blocked Boss Damage")
        return nil
    end

    if not checkcaller() then
        task.spawn(function()
            -- spawnunit
            if isRecording and method == "InvokeServer" and self.Name == "spawnunit" then
                local timestamp = tick()
                processPlacementAction({
                    args = args,
                    timestamp = timestamp
                })

            -- skip wave
            elseif isRecording and method == "FireServer" and self.Name == "Vote" and args[1] == "Vote2" then
                local timestamp = tick()
                local gameRelativeTime = timestamp - gameStartTime
                table.insert(macro, {
                    Type = "skip_wave",
                    Time = string.format("%.2f", gameRelativeTime)
                })
                print(string.format("Recorded skip wave at %.2fs", gameRelativeTime))

            -- sell unit
            elseif isRecording and method == "InvokeServer" and self.Name == "ManageUnits" and args[1] == "Selling" then
                local unitName = args[2]
                local timestamp = tick()
                local placementId = trackedUnits[unitName]
                if placementId then
                    local gameRelativeTime = timestamp - gameStartTime
                    table.insert(macro, {
                        Type = "sell_unit_ingame",
                        Unit = placementId,
                        Time = string.format("%.2f", gameRelativeTime)
                    })
                    print(string.format("Recorded sell: %s", placementId))
                    trackedUnits[unitName] = nil
                end

            -- upgrade unit
            elseif isRecording and method == "InvokeServer" and self.Name == "ManageUnits" and args[1] == "Upgrade" then
                local unitName = args[2]
                local timestamp = tick()
                local placementId = trackedUnits[unitName]
                if placementId then
                    local currentLevel = getUnitUpgradeLevel(unitName)
                    table.insert(pendingUpgrades, {
                        serverUnitName = unitName,
                        placementId = placementId,
                        startLevel = currentLevel,
                        expectedEndLevel = currentLevel + 1,
                        timestamp = timestamp,
                        validated = false
                    })
                    print(string.format("⏳ Upgrade remote fired: %s (L%d->L%d expected)", placementId, currentLevel, currentLevel + 1))
                else
                    warn(string.format("Could not find placement ID for upgrade remote: %s", unitName))
                end
            end
        end)
    end

    return originalNamecall(self, ...)
end)

-- === Ability-only hook ===
local abilityHook = newcclosure(function(self, ...)
    local args = { ... }
    local method = getnamecallmethod()

    if not checkcaller() and isRecording and method == "InvokeServer" and self.Name == "Skills" and args[1] == "SkillsButton" then
        -- Call the wrapped hook chain (so other remotes still flow)
        local result = generalHook(self, ...)

        -- Only record if the server approved
        if not result then
            print("❌ Not Valid Ability")
            return result
        end

        task.spawn(function()
            local unitNameInClient = args[2]
            local abilityName = args[3]
            local timestamp = tick()
            local baseUnitName = unitNameInClient:match("^(.+)%s+%d+$") or unitNameInClient

            -- Find placement ID
            local placementId
            for serverUnitName, trackingId in pairs(trackedUnits) do
                local serverBaseName = serverUnitName:match("^(.+)%s+%d+$") or serverUnitName
                if serverBaseName == baseUnitName then
                    placementId = trackingId
                    break
                end
            end

            if placementId then
                local gameRelativeTime = timestamp - gameStartTime
                local abilityAction = {
                    Type = "use_ability",
                    Unit = placementId,
                    Time = string.format("%.2f", gameRelativeTime)
                }

                if abilityName and abilityName ~= "" then
                    abilityAction.AbilityName = abilityName
                    print(string.format("✅ Valid ability: %s - %s (%.2fs)", placementId, abilityName, gameRelativeTime))
                else
                    print(string.format("✅ Valid ability: %s (%.2fs)", placementId, gameRelativeTime))
                end

                table.insert(macro, abilityAction)
            else
                warn(string.format("⚠️ Could not find placement ID for ability use: %s", unitNameInClient))
            end
        end)

        return result
    end

    -- For everything else, pass to the general hook
    return generalHook(self, ...)
end)

-- Apply the outermost (ability) hook
mt.__namecall = abilityHook
setreadonly(mt, true)

local RunService = game:GetService("RunService")
RunService.Heartbeat:Connect(function()
    if not isRecording or not recordingHasStarted then return end

    local playerUnitsFolder = getPlayerUnitsFolder()
    if not playerUnitsFolder then return end

    for _, unit in pairs(playerUnitsFolder:GetChildren()) do
        if unit.Name == "PLACEMENTFOLDER" then continue end
        local unitName = unit.Name  -- Server name like "Senko 1"
        local currentLevel = getUnitUpgradeLevel(unitName)
        local placementId = trackedUnits[unitName]
        
        if placementId then
            -- Initialize tracking if new unit
            if not unit:GetAttribute("TrackedLevel") then
                unit:SetAttribute("TrackedLevel", currentLevel)
            end
            
            local lastLevel = unit:GetAttribute("TrackedLevel")
            
            -- Check for level increase
            if currentLevel > lastLevel then
                -- Find matching pending upgrade to validate
                local foundPending = nil
                for i = #pendingUpgrades, 1, -1 do
                    local pending = pendingUpgrades[i]
                    
                    if pending.serverUnitName == unitName and 
                       not pending.validated and
                       pending.startLevel == lastLevel then
                        foundPending = pending
                        break
                    end
                end
                
                if foundPending then
                    -- VALIDATED! Level change matches pending remote
                    local gameRelativeTime = foundPending.timestamp - gameStartTime
                    local upgradeAmount = currentLevel - foundPending.startLevel
                    
                    local record = {
                        Type = "upgrade_unit_ingame",
                        Unit = foundPending.placementId,
                        Time = string.format("%.2f", gameRelativeTime)
                    }
                    
                    if upgradeAmount > 1 then
                        record.Amount = upgradeAmount
                    end
                    
                    table.insert(macro, record)
                    
                    print(string.format("✅ Validated & recorded: %s (L%d->L%d)",
                        foundPending.placementId, foundPending.startLevel, currentLevel))
                    
                    foundPending.validated = true
                else
                    -- Level changed but no matching remote = auto-upgrade
                    print(string.format("🚫 Level change without remote: %s (L%d->L%d) - likely auto-upgrade",
                        placementId, lastLevel, currentLevel))
                end
                
                -- Update tracked level
                unit:SetAttribute("TrackedLevel", currentLevel)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        
        if isRecording and recordingHasStarted then
            local currentTime = tick()
            
            -- Remove expired pending upgrades that were never validated
            for i = #pendingUpgrades, 1, -1 do
                local pending = pendingUpgrades[i]
                local age = currentTime - pending.timestamp
                
                if not pending.validated and age > UPGRADE_VALIDATION_TIMEOUT then
                    print(string.format("🚫 Expired unvalidated upgrade: %s (L%d->L%d) - likely auto-upgrade",
                        pending.placementId, pending.startLevel, pending.endLevel))
                    table.remove(pendingUpgrades, i)
                end
            end
        else
            -- Clear pending upgrades when not recording
            if #pendingUpgrades > 0 then
                pendingUpgrades = {}
            end
        end
    end
end)

local function onWaveChanged()
    local newWave = getCurrentWave()
    if newWave ~= currentWave then
        currentWave = newWave
        print(string.format("Wave %d started", currentWave))
    end
end

local function getUnitMaxUpgradeLevel(unitName)
    local playerUnitsFolder = getPlayerUnitsFolder()
    if not playerUnitsFolder then
        return nil
    end
    
    local unit = playerUnitsFolder:FindFirstChild(unitName)
    if not unit then
        return nil
    end
    
    local maxUpgradeValue = unit:FindFirstChild("MaxUpgrade")
    if maxUpgradeValue and maxUpgradeValue:IsA("NumberValue") then
        return maxUpgradeValue.Value
    end
    
    return nil
end

local function getPlayerMoney()
    return tonumber(Services.Players.LocalPlayer.GameData.Yen.Value) or 0
end

local function getModuleUpgradeCosts(unitName, startLevel, upgradeAmount)
    local totalCost = 0
    
    -- Get the unit from unitServer to access runtime PriceUpgrade
    local unitServer = Services.Workspace:FindFirstChild("Ground") 
        and Services.Workspace.Ground:FindFirstChild("unitServer")
    
    if not unitServer then
        warn("unitServer not found!")
        return nil
    end
    
    local unit = unitServer[tostring(Services.Players.LocalPlayer).." (UNIT)"]:FindFirstChild(unitName)
    if not unit then
        warn("Unit not found:", unitName)
        return nil
    end
    
    local runtimePriceUpgrade = nil
    for _, child in pairs(unit:GetDescendants()) do
        if child.Name == "PriceUpgrade" and child:IsA("NumberValue") then
            runtimePriceUpgrade = child.Value
            break
        end
    end
    
    if not runtimePriceUpgrade then
        warn("PriceUpgrade not found in unitServer for:", unitName)
        return nil
    end
    
    -- Get module data for levels 2+
    local moduleName = getBaseUnitName(unitName)
    
    local unitsSettings = Services.ReplicatedStorage:FindFirstChild("PlayMode")
    if not unitsSettings then
        warn("PlayMode not found in ReplicatedStorage")
        return nil
    end
    
    local modulesFolder = unitsSettings:FindFirstChild("Modules")
    if not modulesFolder then
        warn("Modules folder not found")
        return nil
    end
    
    local unitsSettingsFolder = modulesFolder:FindFirstChild("UnitsSettings")
    if not unitsSettingsFolder then
        warn("UnitsSettings folder not found")
        return nil
    end
    
    local unitModule = unitsSettingsFolder:FindFirstChild(moduleName)
    if not unitModule then
        warn(string.format("Unit module '%s' not found", moduleName))
        return nil
    end
    
    local success, moduleData = pcall(function()
        return require(unitModule)
    end)
    
    if not success then
        warn(string.format("Failed to require module for %s: %s", moduleName, tostring(moduleData)))
        return nil
    end
    
    local settings = moduleData.settings and moduleData.settings() or nil
    if not settings or not settings.Upgrading then
        warn(string.format("No Upgrading data found in module for %s", moduleName))
        return nil
    end
    
    local upgradeData = settings.Upgrading
    
    -- Calculate cost for each upgrade level
    for i = 1, upgradeAmount do
        local targetLevel = startLevel + i
        
        if targetLevel == 1 then
            -- Level 1: Use runtime PriceUpgrade from unitServer
            totalCost = totalCost + runtimePriceUpgrade
            print(string.format("  Level 1 cost (runtime): %d", runtimePriceUpgrade))
        else
            -- Level 2+: Use module data (module is 1-indexed, so level 2 is at index 1)
            local moduleIndex = targetLevel - 1
            if upgradeData[moduleIndex] and upgradeData[moduleIndex].PriceUpgrade then
                totalCost = totalCost + upgradeData[moduleIndex].PriceUpgrade
                print(string.format("  Level %d cost (module): %d", targetLevel, upgradeData[moduleIndex].PriceUpgrade))
            else
                warn(string.format("No upgrade cost found for level %d (module index %d)", targetLevel, moduleIndex))
                break
            end
        end
    end
    
    return totalCost
end

local function waitForSufficientMoneyForPlacement(unitName, placementCost, actionDescription)
    if not placementCost then
        warn("No placement cost provided for:", unitName)
        return true
    end
    
    local currentMoney = getPlayerMoney()
    
    if currentMoney >= placementCost then
        return true
    end
    
    MacroStatusLabel:Set(string.format("Status: Waiting for money (%d/%d) - Place %s", 
        currentMoney, placementCost, unitName))
    
    print(string.format("Need %d more coins to place %s (Cost: %d)", 
        placementCost - currentMoney, unitName, placementCost))
    
    while getPlayerMoney() < placementCost and isPlaybacking do
        task.wait(0.5)
        local newMoney = getPlayerMoney()
        if newMoney ~= currentMoney then
            currentMoney = newMoney
            MacroStatusLabel:Set(string.format("Status: Waiting for money (%d/%d) - Place %s", 
                currentMoney, placementCost, unitName))
        end
    end
    
    if not isPlaybacking then
        return false
    end
    
    print(string.format("Ready to place %s!", unitName))
    return true
end

local function waitForSufficientMoneyForUpgrades(unitName, upgradeAmount, actionDescription)
    upgradeAmount = upgradeAmount or 1
    
    local currentLevel = getUnitUpgradeLevel(unitName)
    local maxLevel = getUnitMaxUpgradeLevel(unitName)
    
    if not currentLevel or not maxLevel then
        warn("Could not get upgrade levels for:", unitName)
        return false
    end
    
    if currentLevel >= maxLevel then
        print(string.format("Unit %s already at max level (%d/%d)", unitName, currentLevel, maxLevel))
        return true
    end
    
    -- Use hybrid calculation (runtime for level 1, module for 2+)
    local totalCost = getModuleUpgradeCosts(unitName, currentLevel, upgradeAmount)
    
    if not totalCost then
        warn(string.format("Failed to calculate upgrade costs for %s", unitName))
        return false
    end
    
    print(string.format("Calculated upgrade cost for %s: %d (x%d upgrades from L%d)", 
        unitName, totalCost, upgradeAmount, currentLevel))
    
    local currentMoney = getPlayerMoney()
    
    if currentMoney >= totalCost then
        return true
    end
    
    MacroStatusLabel:Set(string.format("Status: Waiting for money (%d/%d) - %s", 
        currentMoney, totalCost, actionDescription))
    
    print(string.format("Need %d more coins for %s", totalCost - currentMoney, actionDescription))
    
    while getPlayerMoney() < totalCost and isPlaybacking do
        task.wait(0.5)
        local newMoney = getPlayerMoney()
        if newMoney ~= currentMoney then
            currentMoney = newMoney
            MacroStatusLabel:Set(string.format("Status: Waiting for money (%d/%d) - %s", 
                currentMoney, totalCost, actionDescription))
        end
    end
    
    if not isPlaybacking then
        return false
    end
    
    print(string.format("Ready to upgrade %s!", unitName))
    return true
end

local function executeUnitUpgrade(actionData)
    local unitPlacementId = actionData.Unit  -- e.g., "Ai #1", "Senko #2"
    local upgradeAmount = actionData.Amount or 1  -- Default to 1 if nil
    
    print(string.format("=== EXECUTING UPGRADE ==="))
    print(string.format("Target Unit: %s, Amount: %d", unitPlacementId or "nil", upgradeAmount))
    
    if not unitPlacementId then
        warn("❌ Invalid placement ID for upgrade")
        return false
    end
    
    -- Look up the actual unit name from playback mapping
    local currentUnitName = playbackUnitMapping[unitPlacementId]
    print(string.format("Mapped Unit: %s", currentUnitName or "nil"))
    
    if not currentUnitName then
        warn(string.format("❌ No mapping found for %s", unitPlacementId))
        print("Current mappings:")
        for k, v in pairs(playbackUnitMapping) do
            print(string.format("  %s → %s", k, v))
        end
        return false
    end
    
    -- Verify unit still exists
    local playerUnitsFolder = getPlayerUnitsFolder()
    if not playerUnitsFolder then
        warn("❌ Player units folder not found")
        return false
    end
    
    local unitExists = playerUnitsFolder:FindFirstChild(currentUnitName)
    if not unitExists then
        warn(string.format("❌ Unit %s no longer exists", currentUnitName))
        return false
    end
    
    print(string.format("⬆️ Upgrading %s: %s (x%d levels)", unitPlacementId, currentUnitName, upgradeAmount))
    
    -- Check upgrade levels
    local currentUpgradeLevel = getUnitUpgradeLevel(currentUnitName)
    local maxUpgradeLevel = getUnitMaxUpgradeLevel(currentUnitName)
    
    if not currentUpgradeLevel or not maxUpgradeLevel then
        warn(string.format("❌ Could not determine upgrade levels for %s", currentUnitName))
        return false
    end
    
    if currentUpgradeLevel >= maxUpgradeLevel then
        print(string.format("ℹ️ Unit %s already at max (%d/%d)", currentUnitName, currentUpgradeLevel, maxUpgradeLevel))
        return true
    end
    
    -- Wait for money if needed
    if not waitForSufficientMoneyForUpgrades(currentUnitName, upgradeAmount, 
        string.format("upgrade %s x%d", currentUnitName, upgradeAmount)) then
        return false
    end

    local targetLevel = currentUpgradeLevel + upgradeAmount
    
    -- Perform upgrade
    local success, err = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
            :WaitForChild("Events"):WaitForChild("ManageUnits")
            :InvokeServer("Upgrade", currentUnitName, targetLevel)
    end)
    
    if success then
        task.wait(0.5)
        local newLevel = getUnitUpgradeLevel(currentUnitName)
        
        if newLevel and newLevel > currentUpgradeLevel then
            print(string.format("✓ Upgraded %s (%d→%d)", unitPlacementId, currentUpgradeLevel, newLevel))
            updateDetailedStatus(string.format("✓ Upgraded %s (%d→%d)", unitPlacementId, currentUpgradeLevel, newLevel))
            return true
        end
    else
        warn(string.format("❌ pcall failed: %s", tostring(err)))
    end
    
    warn(string.format("❌ Failed to upgrade %s", unitPlacementId))
    return false
end

local function executeUnitSell(actionData)
    local unitPlacementId = actionData.Unit  -- e.g., "Ai #1"
    
    print(string.format("=== EXECUTING SELL ==="))
    print(string.format("Target Unit: %s", unitPlacementId))
    
    if not unitPlacementId then
        warn("❌ Invalid placement ID for sell")
        return false
    end
    
    -- Look up the actual unit name from mapping
    local currentUnitName = playbackUnitMapping[unitPlacementId]  -- Changed lookup
    print(string.format("Mapped Unit: %s", currentUnitName or "nil"))
    
    if not currentUnitName then
        warn(string.format("❌ No mapping found for %s", unitPlacementId))
        return false
    end
    
    print(string.format("💰 Selling %s: %s", unitPlacementId, currentUnitName))
    
    local success, err = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
            :WaitForChild("Events"):WaitForChild("ManageUnits")
            :InvokeServer("Selling", currentUnitName)
    end)
    
    if success then
        task.wait(0.5)
        
        local playerUnitsFolder = getPlayerUnitsFolder()
        if playerUnitsFolder and not playerUnitsFolder:FindFirstChild(currentUnitName) then
            print(string.format("✓ Successfully sold %s", unitPlacementId))
            updateDetailedStatus(string.format("✓ Successfully sold %s", unitPlacementId))
            playbackUnitMapping[unitPlacementId] = nil  -- Remove from mapping
            return true
        end
    end
    
    warn(string.format("❌ Failed to sell %s", unitPlacementId))
    return false
end

local function executeSkipWave()
    print("⏩ Executing skip wave")
    
    local success, err = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
            :WaitForChild("Events"):WaitForChild("Vote")
            :FireServer("Vote2")
    end)
    
    if success then
        print("✓ Skip wave vote sent")
        updateDetailedStatus("⏩ Skip wave vote sent")
        return true
    else
        warn("❌ Failed to skip wave:", err)
        return false
    end
end

local function executeUnitAbility(actionData)
    local unitPlacementId = actionData.Unit  -- e.g., "Ai #1"
    local abilityName = actionData.AbilityName  -- Optional: e.g., "Mahoraga"
    
    print(string.format("=== EXECUTING ABILITY ==="))
    print(string.format("Target Unit: %s", unitPlacementId))
    if abilityName then
        print(string.format("Ability Name: %s", abilityName))
    end
    
    if not unitPlacementId then
        warn("❌ Invalid placement ID for ability")
        return false
    end
    
    -- Look up the actual unit name from mapping
    local currentUnitName = playbackUnitMapping[unitPlacementId]
    print(string.format("Mapped Unit: %s", currentUnitName or "nil"))
    
    if not currentUnitName then
        warn(string.format("❌ No mapping found for %s", unitPlacementId))
        return false
    end
    
    local abilityText = abilityName and string.format(" (%s)", abilityName) or ""
    print(string.format("⚡ Using ability on %s: %s%s", unitPlacementId, currentUnitName, abilityText))
    
    -- Try to find the unit in unitClient
    local ground = Services.Workspace:FindFirstChild("Ground")
    if not ground then
        warn("❌ Ground folder not found")
        return false
    end
    
    local unitClient = ground:FindFirstChild("unitClient")
    if not unitClient then
        warn("❌ unitClient folder not found")
        return false
    end
    
    -- Look for the unit in unitClient
    for _, unit in pairs(unitClient:GetChildren()) do
        if unit:IsA("Model") and unit.Name:find(currentUnitName, 1, true) then
            local success, err = pcall(function()
                local args = {"SkillsButton", unit.Name}
                
                -- Add ability name if present
                if abilityName and abilityName ~= "" then
                    table.insert(args, abilityName)
                end
                
                game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
                    :WaitForChild("Events"):WaitForChild("Skills"):InvokeServer(unpack(args))
            end)
            
            if success then
                print(string.format("✓ Successfully used ability on %s%s", unitPlacementId, abilityText))
                updateDetailedStatus(string.format("⚡ Used ability on %s%s", unitPlacementId, abilityText))
                return true
            else
                warn("❌ Failed to invoke ability:", err)
            end
        end
    end
    
    warn(string.format("❌ Unit not found in unitClient: %s", currentUnitName))
    return false
end

    detailedStatusLabel = MacroTab:CreateLabel("Macro Details: Ready")

    local Divider = MacroTab:CreateDivider()

local MacroDropdown = MacroTab:CreateDropdown({
        Name = "Select Macro",
        Options = {},
        CurrentOption = currentMacroName,
        MultipleOptions = false,
        Flag = "MacroDropdown",
        Callback = function(selected)
            local selectedName
            if type(selected) == "table" then
                selectedName = selected[1]
            else
                selectedName = selected
            end

            print("User selected macro:", selectedName)
            currentMacroName = selectedName
            if selectedName and macroManager[selectedName] then
                macro = macroManager[selectedName]
                print("Selected macro '" .. selectedName .. "' with " .. #macro .. " actions.")
            else
                print("Invalid selection or macro doesn't exist:", selectedName)
            end
        end,
    })

        local function ensureMacroFolders()
        if not isfolder("LixHub") then
            makefolder("LixHub")
        end
        if not isfolder("LixHub/Macros") then
            makefolder("LixHub/Macros")
        end
        if not isfolder("LixHub/Macros/AG") then
            makefolder("LixHub/Macros/AG")
        end
    end

local function refreshMacroDropdown()
        local options = {}

        for name in pairs(macroManager) do
            table.insert(options, name)
        end

        table.sort(options)

        if type(currentMacroName) == "table" then
            currentMacroName = currentMacroName[1] or ""
        end

        if not currentMacroName or currentMacroName == "" then
            currentMacroName = options[1]
        end

        if currentMacroName and macroManager[currentMacroName] then
            macro = macroManager[currentMacroName]
        end

        MacroDropdown:Refresh(options, currentMacroName)
        print("Refreshed dropdown with " .. #options .. " macros")
    end

local function exportMacroToClipboard(macroName, format)
    if not macroName or macroName == "" then
        Rayfield:Notify({
            Title = "Export Error",
            Content = "No macro selected for export.",
            Duration = 3
        })
        return false
    end
    
    local macroData = macroManager[macroName]
    if not macroData or #macroData == 0 then
        Rayfield:Notify({
            Title = "Export Error", 
            Content = "Macro '" .. macroName .. "' is empty or doesn't exist.",
            Duration = 3
        })
        return false
    end
    
    -- Direct JSON encoding - macro data is already in the correct format
    local jsonData = Services.HttpService:JSONEncode(macroData)
    
    -- Copy to clipboard
    if setclipboard then
        setclipboard(jsonData)
        Rayfield:Notify({
            Title = "Export Success",
            Content = "Macro JSON copied to clipboard (" .. #macroData .. " actions)",
            Duration = 3
        })
    else
        Rayfield:Notify({
            Title = "Export Info",
            Content = "Clipboard not supported. JSON printed to console.",
            Duration = 3
        })
        print("=== MACRO EXPORT ===")
        print(jsonData)
        print("=== END EXPORT ===")
    end
    
    return true
end

local function importMacroFromContent(jsonContent, targetMacroName)
    if not jsonContent or jsonContent:match("^%s*$") then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "No JSON content provided.",
            Duration = 3
        })
        return false
    end
    
    if not targetMacroName or targetMacroName == "" then
        Rayfield:Notify({
            Title = "Import Error", 
            Content = "No target macro name specified.",
            Duration = 3
        })
        return false
    end
    
    -- Check if target macro already exists and has data
    if macroManager[targetMacroName] and #macroManager[targetMacroName] > 0 then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "Target macro '" .. targetMacroName .. "' already contains data. Use an empty macro name.",
            Duration = 4
        })
        return false
    end
    
    -- Try to parse the JSON
    local importData
    local success, result = pcall(function()
        return Services.HttpService:JSONDecode(jsonContent)
    end)
    
    if not success then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "Invalid JSON format. Please check your pasted content.",
            Duration = 4
        })
        print("JSON Parse Error:", result)
        return false
    end
    
    importData = result
    
    -- Handle both direct array format and wrapped format
    local deserializedActions
    if type(importData) == "table" then
        if importData.actions and type(importData.actions) == "table" then
            deserializedActions = importData.actions
        elseif #importData > 0 then
            deserializedActions = importData
        else
            Rayfield:Notify({
                Title = "Import Error",
                Content = "Invalid macro format - no actions found.",
                Duration = 4
            })
            return false
        end
    else
        Rayfield:Notify({
            Title = "Import Error",
            Content = "Invalid macro data structure.",
            Duration = 4
        })
        return false
    end
    
    if #deserializedActions == 0 then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "Macro contains no actions.",
            Duration = 3
        })
        return false
    end
    
    -- Import the macro (already in correct format, no conversion needed)
    macroManager[targetMacroName] = deserializedActions
    
    -- Save to file
    local saveSuccess, saveErr = pcall(function()
        ensureMacroFolders()
        saveMacroToFile(targetMacroName)
    end)
    
    if not saveSuccess then
        warn("Failed to save imported macro to file:", saveErr)
    end
    
    refreshMacroDropdown()
    
    Rayfield:Notify({
        Title = "Import Success! 🎉",
        Content = string.format("Imported '%s' with %d actions", targetMacroName, #deserializedActions),
        Duration = 5
    })
    
    print(string.format("✅ Successfully imported macro '%s' with %d actions", targetMacroName, #deserializedActions))
    return true
end

local function importMacroFromURL(url, targetMacroName)
    if not url or url == "" then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "No URL provided for import.",
            Duration = 3
        })
        return false
    end
    
    if not targetMacroName or targetMacroName == "" then
        Rayfield:Notify({
            Title = "Import Error", 
            Content = "No target macro name specified.",
            Duration = 3
        })
        return false
    end
    
    -- Check if target macro already exists and has data
    if macroManager[targetMacroName] and #macroManager[targetMacroName] > 0 then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "Target macro '" .. targetMacroName .. "' already contains data. Use an empty macro.",
            Duration = 4
        })
        return false
    end
    
    Rayfield:Notify({
        Title = "Importing...",
        Content = "Downloading macro from URL...",
        Duration = 2
    })
    
    -- Try to fetch the URL content
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if not success then
        Rayfield:Notify({
            Title = "Import Error",
            Content = "Failed to download from URL: " .. tostring(result),
            Duration = 4
        })
        return false
    end
    
    -- Use the existing importMacroFromContent function
    return importMacroFromContent(result, targetMacroName)
end

local function loadMacroFromFile(name)
    local filePath = getMacroFilename(name)
    if not isfile(filePath) then return end

    local json = readfile(filePath)
    local data = Services.HttpService:JSONDecode(json)
    
    -- No deserialization needed!
    macroManager[name] = data
    return data
end

    local function deleteMacroFile(name)
        if isfile(getMacroFilename(name)) then
            delfile(getMacroFilename(name))
        end
        macroManager[name] = nil
    end

    local function loadAllMacros()
        macroManager = {}
        for _, file in ipairs(listfiles("LixHub/Macros/AG/")) do
            if file:match("%.json$") then
                local name = file:match("([^/\\]+)%.json$")
                loadMacroFromFile(name)
            end
        end
    end

    local function waitForGameStart_Playback()
        if isInLobby() then return end
    local waveNum = Services.Workspace:WaitForChild("GameSettings"):WaitForChild("Wave")

    -- wait for game to end (if currently in one)
    while waveNum.Value > 0 do
        task.wait(1)
    end

    -- wait for next game to start
    while waveNum.Value < 1 do
        task.wait(1)
    end

    print("Playback started - wave " .. waveNum.Value)
end


local function waitForGameStart()
    local gameStarted = Services.Workspace.GameSettings.GameStarted.Value
    
    -- If game is currently running, wait for it to end first
    if gameStarted then
        MacroStatusLabel:Set("Status: Waiting for current game to end...")
        Rayfield:Notify({
            Title = "Waiting for Current Game",
            Content = "Waiting for current game to end...",
            Duration = 2,
            Image = 4483362458
        })
        
        -- Wait for current game to end
        repeat 
            task.wait(0.1) 
        until Services.Workspace.GameSettings.GameStarted.Value == false
        
        MacroStatusLabel:Set("Status: Game ended, waiting for next game...")
        Rayfield:Notify({
            Title = "Game Ended",
            Content = "Current game ended, waiting for next game...",
            Duration = 2,
            Image = 4483362458
        })
    else
        MacroStatusLabel:Set("Status: Waiting for next game to start...")
        Rayfield:Notify({
            Title = "Waiting for Game",
            Content = "Waiting for next game to start...",
            Duration = 2,
            Image = 4483362458
        })
    end

    -- Now wait for the next game to start
    repeat 
        task.wait(0.1) 
    until Services.Workspace.GameSettings.GameStarted.Value == true

    MacroStatusLabel:Set("Status: Game started! Initializing macro...")
    return Services.Workspace.GameSettings.GameStarted.Value
end

MacroInput = MacroTab:CreateInput({
        Name = "Create Macro",
        CurrentValue = "",
        PlaceholderText = "Enter macro name...",
        RemoveTextAfterFocusLost = true,
        Callback = function(text)
            local cleanedName = text:gsub("[<>:\"/\\|?*]", ""):gsub("^%s+", ""):gsub("%s+$", "")
            
            if cleanedName ~= "" then
                if macroManager[cleanedName] then
                    notify(nil,"Error: Macro '" .. cleanedName .. "' already exists.")
                    return
                end

                macroManager[cleanedName] = {}
                saveMacroToFile(cleanedName)
                refreshMacroDropdown()
                
                notify(nil,"Success: Created macro '" .. cleanedName .. "'.")
            elseif text ~= "" then
                notify(nil,"Error: Invalid macro name. Avoid special characters.")
            end
        end,
    })

    RefreshMacroListButton = MacroTab:CreateButton({
        Name = "Refresh Macro List",
        Callback = function()
            loadAllMacros()
            refreshMacroDropdown()
            notify(nil,"Success: Macro list refreshed.")
        end,
    })

    DeleteSelectedMacroButton = MacroTab:CreateButton({
        Name = "Delete Selected Macro",
        Callback = function()
            if not currentMacroName or currentMacroName == "" then
                notify(nil,"Error: No macro selected.")
                return
            end

            deleteMacroFile(currentMacroName)
            notify(nil,"Deleted: Deleted macro '" .. currentMacroName .. "'.")

            macroManager[currentMacroName] = nil
            macro = {}
            refreshMacroDropdown()
        end,
    })

    local function stopRecording()
        isRecording = false
        recordingHasStarted = false
        print(string.format("Stopped recording. Recorded %d actions", #macro))
        notify("Macro Recorder","Stopped recording! Saved "..#macro.." actions.")
        
        if currentMacroName and currentMacroName ~= "" then
            macroManager[currentMacroName] = macro
            saveMacroToFile(currentMacroName)
        end
        
        return macro
    end

local RecordToggle = MacroTab:CreateToggle({
    Name = "Record Macro",
    CurrentValue = false,
    Flag = "RecordMacro",
    Callback = function(Value)
        isRecording = Value

        if Value then
            -- Start recording immediately if in game, or when game starts
            if not isInLobby() and gameInProgress then
                recordingHasStarted = true
                isRecordingLoopRunning = true
                startRecordingNow() -- Your existing function
                MacroStatusLabel:Set("Status: Recording active!")
                notify("Recording Started", "Macro recording is now active.")
            else
                recordingHasStarted = false
                MacroStatusLabel:Set("Status: Recording enabled - will start when game begins")
                notify("Recording Ready", "Recording will start when you enter a game.")
            end
        elseif not Value then
            if isRecordingLoopRunning then
                notify("Recording Stopped", "Recording manually stopped.")
            end
            isRecordingLoopRunning = false
            stopRecording() -- Your existing function
            MacroStatusLabel:Set("Status: Recording stopped")
        end
    end
})

local function scheduleAbility(action, scheduledTime, actionIndex, totalActions)
    table.insert(abilityQueue, {
        action = action,
        scheduledTime = scheduledTime,
        actionIndex = actionIndex,
        totalActions = totalActions
    })
    print(string.format("⏰ Scheduled ability for %s at %.2fs", action.Unit, scheduledTime))
end

local function scheduleWaveSkip(action, scheduledTime, actionIndex, totalActions)
    table.insert(abilityQueue, {
        action = action,
        scheduledTime = scheduledTime,
        actionIndex = actionIndex,
        totalActions = totalActions,
        isWaveSkip = true  -- Flag to identify wave skips
    })
    print(string.format("⏰ Scheduled wave skip at %.2fs", scheduledTime))
end

local function processAbilityQueue(playbackStartTime)
    while isPlaybacking and gameInProgress do
        local currentTime = tick() - playbackStartTime
        
        -- Check for abilities/wave skips that should fire now
        for i = #abilityQueue, 1, -1 do
            local queuedItem = abilityQueue[i]
            
            if currentTime >= queuedItem.scheduledTime then
                if queuedItem.isWaveSkip then
                    -- Execute wave skip
                    MacroStatusLabel:Set(string.format("Status: (%d/%d) Skipping wave", 
                        queuedItem.actionIndex, queuedItem.totalActions))
                    executeSkipWave()
                    print(string.format("✅ Fired wave skip at %.2fs", currentTime))
                else
                    -- Execute ability
                    MacroStatusLabel:Set(string.format("Status: (%d/%d) Using ability on %s", 
                        queuedItem.actionIndex, queuedItem.totalActions, queuedItem.action.Unit))
                    executeUnitAbility(queuedItem.action)
                    print(string.format("✅ Fired ability for %s at %.2fs", queuedItem.action.Unit, currentTime))
                end
                
                -- Remove from queue
                table.remove(abilityQueue, i)
            end
        end
        
        task.wait(0.1)
    end
end

local function monitorAndReplaceDeletedUnits()
    if not State.ReplaceDeletedUnits then return end
    
    print("🛡️ Unit replacement monitor started")
    
    while State.ReplaceDeletedUnits and isPlaybacking and gameInProgress do
        task.wait(1) -- Check every second
        
        local playerUnitsFolder = getPlayerUnitsFolder()
        if not playerUnitsFolder then 
            task.wait(1)
            continue 
        end
        
        -- Check each tracked placement
        for placementId, serverUnitName in pairs(playbackUnitMapping) do
            -- If unit no longer exists in the game
            if not playerUnitsFolder:FindFirstChild(serverUnitName) then
                print(string.format("⚠️ DELETED UNIT DETECTED: %s (was: %s)", placementId, serverUnitName))
                
                -- Find the original placement action in macro
                local placementAction = nil
                local upgradeActions = {}
                
                for _, action in ipairs(macro) do
                    if action.Unit == placementId then
                        if action.Type == "spawn_unit" then
                            placementAction = action
                        elseif action.Type == "upgrade_unit_ingame" then
                            table.insert(upgradeActions, action)
                        end
                    end
                end
                
                if placementAction then
                    print(string.format("🔄 Re-placing deleted unit: %s", placementId))
                    updateDetailedStatus(string.format("Replacing %s...", placementId))
                    
                    -- Remove old mapping (it's dead anyway)
                    playbackUnitMapping[placementId] = nil
                    
                    -- Wait for sufficient money if needed
                    if placementAction.PlacementCost then
                        if not waitForSufficientMoneyForPlacement(placementAction.Unit, placementAction.PlacementCost, placementAction.Unit) then
                            warn("Failed to get enough money for replacement:", placementAction.Unit)
                            continue
                        end
                    end
                    
                    -- Re-execute placement
                    local success = executePlacementAction(placementAction, 0, 0)
                    
                    if success then
                        print(string.format("✅ Successfully replaced: %s", placementId))
                        
                        -- Re-apply upgrades if any existed
                        if #upgradeActions > 0 then
                            print(string.format("⬆️ Re-applying %d upgrades to %s", #upgradeActions, placementId))
                            task.wait(0.5) -- Let placement settle
                            
                            for _, upgradeAction in ipairs(upgradeActions) do
                                local upgradeSuccess = executeUnitUpgrade(upgradeAction)
                                if upgradeSuccess then
                                    print(string.format("✅ Upgrade restored for %s", placementId))
                                    task.wait(0.3) -- Small delay between upgrades
                                else
                                    warn(string.format("❌ Failed to restore upgrade for %s", placementId))
                                end
                            end
                        end
                        
                        updateDetailedStatus(string.format("✅ Replaced %s", placementId))
                    else
                        warn(string.format("❌ Failed to replace: %s", placementId))
                        updateDetailedStatus(string.format("❌ Failed to replace %s", placementId))
                    end
                    
                    task.wait(1) -- Cooldown between replacements to avoid spam
                else
                    warn(string.format("❌ No placement action found for: %s", placementId))
                end
            end
        end
    end
    
    print("🛡️ Unit replacement monitor stopped")
end

local function playMacroOnce()
    if not macro or #macro == 0 then
        print("No macro data to play")
        return false
    end
    
    MacroStatusLabel:Set("Status: Executing macro...")
    
    -- CRITICAL: Clear mappings at start
    clearSpawnIdMappings()
    
    -- Clear ability queue
    abilityQueue = {}
    
    local playbackStartTime = gameStartTime
    if playbackStartTime == 0 then
        playbackStartTime = tick()
        print("No game start time, using current time")
    end
    
    -- Start ability queue processor
    if abilityQueueThread then
        task.cancel(abilityQueueThread)
    end
    abilityQueueThread = task.spawn(processAbilityQueue, playbackStartTime)

    task.spawn(monitorAndReplaceDeletedUnits)
    
    for actionIndex, action in ipairs(macro) do
        if not isPlaybacking or not gameInProgress then
            print("Playback stopped")
            if abilityQueueThread then
                task.cancel(abilityQueueThread)
            end
            return false
        end
        
        local actionTime = tonumber(action.Time) or 0
        local currentTime = tick() - playbackStartTime
        
        -- Handle abilities - schedule them instead of executing immediately
        if action.Type == "use_ability" then
            if State.IgnoreTiming then
                -- Schedule ability for its correct timing
                scheduleAbility(action, actionTime, actionIndex, #macro)
            else
                -- Normal timing behavior
                if currentTime < actionTime then
                    local waitTime = actionTime - currentTime
                    MacroStatusLabel:Set(string.format("Status: (%d/%d) Waiting %.1fs for ability...", actionIndex, #macro, waitTime))
                    
                    local waitStart = tick()
                    while (tick() - waitStart) < waitTime and isPlaybacking and gameInProgress do
                        task.wait(0.1)
                    end
                end
                
                MacroStatusLabel:Set(string.format("Status: (%d/%d) Using ability on %s", actionIndex, #macro, action.Unit))
                executeUnitAbility(action)
            end
            
            task.wait(0.1)
            continue
        end
        
        -- Handle wave skips - schedule them when IgnoreTiming is enabled
        if action.Type == "skip_wave" then
            if State.IgnoreTiming then
                -- Schedule wave skip for its correct timing
                scheduleWaveSkip(action, actionTime, actionIndex, #macro)
            else
                -- Normal timing behavior
                if currentTime < actionTime then
                    local waitTime = actionTime - currentTime
                    MacroStatusLabel:Set(string.format("Status: (%d/%d) Waiting %.1fs for wave skip...", actionIndex, #macro, waitTime))
                    
                    local waitStart = tick()
                    while (tick() - waitStart) < waitTime and isPlaybacking and gameInProgress do
                        task.wait(0.1)
                    end
                end
                
                MacroStatusLabel:Set(string.format("Status: (%d/%d) Skipping wave", actionIndex, #macro))
                executeSkipWave()
            end
            
            task.wait(0.1)
            continue
        end
        
        -- For non-ability/non-wave-skip actions, respect timing unless IgnoreTiming is enabled
        if not State.IgnoreTiming then
            if currentTime < actionTime then
                local waitTime = actionTime - currentTime
                MacroStatusLabel:Set(string.format("Status: (%d/%d) Waiting %.1fs...", actionIndex, #macro, waitTime))
                
                local waitStart = tick()
                while (tick() - waitStart) < waitTime and isPlaybacking and gameInProgress do
                    task.wait(0.1)
                end
            end
        end
        
        if not isPlaybacking or not gameInProgress then break end
        
        if action.Type == "spawn_unit" then
            if action.PlacementCost then
                if not waitForSufficientMoneyForPlacement(action.Unit, action.PlacementCost, action.Unit) then
                    warn("Failed to get enough money for placement:", action.Unit)
                    if abilityQueueThread then
                        task.cancel(abilityQueueThread)
                    end
                    return false
                end
            end
            
            MacroStatusLabel:Set(string.format("Status: (%d/%d) Placing %s", actionIndex, #macro, action.Unit))
            
            local success = executePlacementAction(action, actionIndex, #macro)
            
            if not success then
                print("Failed to place:", action.Unit)
            end
            
            task.wait(0.3)
            
        elseif action.Type == "upgrade_unit_ingame" then
            MacroStatusLabel:Set(string.format("Status: (%d/%d) Upgrading %s", actionIndex, #macro, action.Unit))
            
            local placementNum = getPlacementNumber(action.Unit)
            local unitType = getDisplayNameFromUnit(action.Unit)
            
            if placementNum and unitType then
                executeUnitUpgrade(action)
            else
                warn("Invalid upgrade action format:", action.Unit)
            end
            
        elseif action.Type == "sell_unit_ingame" then
            MacroStatusLabel:Set(string.format("Status: (%d/%d) Selling %s", actionIndex, #macro, action.Unit))
            
            local placementNum = getPlacementNumber(action.Unit)
            local unitType = getDisplayNameFromUnit(action.Unit)
            
            if placementNum and unitType then
                executeUnitSell(action)
            end
        end
        
        task.wait(0.1)
    end
    
    -- Wait for any remaining abilities/wave skips in queue
    if #abilityQueue > 0 then
        MacroStatusLabel:Set(string.format("Status: Waiting for %d scheduled actions...", #abilityQueue))
        print(string.format("Waiting for %d remaining queued actions...", #abilityQueue))
        
        while #abilityQueue > 0 and isPlaybacking and gameInProgress do
            task.wait(0.5)
        end
    end
    
    if abilityQueueThread then
        task.cancel(abilityQueueThread)
    end
    
    MacroStatusLabel:Set("Status: Macro completed")
    print("Macro playback finished")
    return true
end

local function autoPlaybackLoop()
    -- Prevent multiple loops from running
    if playbackLoopRunning then
        warn("⚠️ Playback loop already running! Ignoring duplicate start.")
        return
    end
    
    playbackLoopRunning = true
    print("=== PLAYBACK LOOP STARTED ===")
    
    while isAutoLoopEnabled do
        MacroStatusLabel:Set("Status: Waiting for next game...")
        updateDetailedStatus("Waiting for next game...")
        
        waitForGameStart_Playback()
        
        if not isAutoLoopEnabled then 
            print("Playback disabled, stopping loop")
            break 
        end
        
        if not currentMacroName or currentMacroName == "" then
            MacroStatusLabel:Set("Status: Error - No macro selected!")
            updateDetailedStatus("Error - No macro selected!")
            notify(nil, "Playback Error: No macro selected for playback.")
            break
        end
        
        local loadedMacro = loadMacroFromFile(currentMacroName)
        if not loadedMacro or #loadedMacro == 0 then
            MacroStatusLabel:Set("Status: Error - Failed to load macro!")
            updateDetailedStatus("Error - Failed to load macro!")
            notify(nil, "Playback Error: Failed to load macro: " .. tostring(currentMacroName))
            break
        end
        
        macro = loadedMacro
        isPlaybacking = true
        
        -- CRITICAL: Reset unit mappings at start of each playback
        clearSpawnIdMappings()
        
        MacroStatusLabel:Set("Status: Playing macro...")
        updateDetailedStatus("Loading macro: " .. currentMacroName)
        notify(nil, "Playback Started: " .. currentMacroName .. " (" .. #macro .. " actions)")
        
        local completed = playMacroOnce()
        
        isPlaybacking = false
        
        if completed then
            MacroStatusLabel:Set("Status: Macro completed - waiting for next game...")
            updateDetailedStatus("Macro completed - waiting for next game...")
            notify(nil, "Playback Complete: Waiting for next game to start...")
        else
            MacroStatusLabel:Set("Status: Macro interrupted - waiting for next game...")
            updateDetailedStatus("Macro interrupted - waiting for next game...")
            notify(nil, "Playback Interrupted: Game ended, waiting for next game...")
        end
        
        -- Clear mappings again after game ends
        clearSpawnIdMappings()
        
        task.wait(1)
    end
    
    MacroStatusLabel:Set("Status: Playback stopped")
    updateDetailedStatus("Playback stopped")
    isPlaybacking = false
    playbackLoopRunning = false
    print("=== PLAYBACK LOOP ENDED ===")
end


local PlayToggle = MacroTab:CreateToggle({
    Name = "Playback Macro",
    CurrentValue = false,
    Flag = "PlayBackMacro",
    Callback = function(Value)
        isAutoLoopEnabled = Value
        isPlaybacking = Value
        
        if Value then
            if isInLobby() then return end
            
            -- Check if already running
            if playbackLoopRunning then
                Rayfield:Notify({
                    Title = "Warning",
                    Content = "Playback already running!",
                    Duration = 3
                })
                return
            end
            
            -- Ensure we have a valid macro name
            if type(currentMacroName) == "table" then
                currentMacroName = currentMacroName[1] or ""
            end
            
            if not currentMacroName or currentMacroName == "" then
                -- Try to get first available macro if none selected
                local firstMacro = next(macroManager)
                if firstMacro then
                    currentMacroName = firstMacro
                    print("No macro selected, using first available:", currentMacroName)
                else
                    Rayfield:Notify({
                        Title = "Error",
                        Content = "No macro selected and none available",
                        Duration = 3
                    })
                    isAutoLoopEnabled = false
                    isPlaybacking = false
                    PlayToggle:Set(false)
                    return
                end
            end
            
            -- Try to load from manager first, then from file
            local loadedMacro = macroManager[currentMacroName] or loadMacroFromFile(currentMacroName)
            
            if loadedMacro and #loadedMacro > 0 then
                macro = loadedMacro
                macroManager[currentMacroName] = loadedMacro -- Ensure it's in manager
                MacroStatusLabel:Set("Status: Playback enabled - waiting for game")
                notify("Playback Enabled", "Macro will play once per game.")
                
                -- Start the loop
                task.spawn(autoPlaybackLoop)
                
                print("Started playback:", currentMacroName, "with", #macro, "actions")
            else
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Failed to load macro or macro is empty",
                    Duration = 3
                })
                isAutoLoopEnabled = false
                isPlaybacking = false
                PlayToggle:Set(false)
            end
        else
            MacroStatusLabel:Set("Status: Playback disabled")
            isPlaybacking = false
            isAutoLoopEnabled = false
            playbackLoopRunning = false
            notify("Playback Disabled", "Macro playback stopped.")
        end
    end
})

local IgnoreTimingToggle = MacroTab:CreateToggle({
    Name = "Ignore Timing",
    CurrentValue = false,
    Flag = "IgnoreTiming",
    Info = "Skip timing waits and execute actions immediately. Will not ignore timing for abilities/wave skips",
    Callback = function(Value)
        State.IgnoreTiming = Value
    end,
})

local ReplaceDeletedUnitsToggle = MacroTab:CreateToggle({
    Name = "Replace Deleted Units",
    CurrentValue = false,
    Flag = "ReplaceDeletedUnits",
    Info = "Automatically replaces units that get deleted by bosses (Usable for world boss event)",
    Callback = function(Value)
        State.ReplaceDeletedUnits = Value
        if Value then
            updateDetailedStatus("Unit replacement enabled")
        else
            updateDetailedStatus("Unit replacement disabled")
        end
    end,
})

local Divider = MacroTab:CreateDivider()

local ImportInput = MacroTab:CreateInput({
    Name = "Import Macro (URL or JSON)",
    CurrentValue = "",
    PlaceholderText = "Paste URL or JSON content here...",
    RemoveTextAfterFocusLost = true,
    Callback = function(text)
        if not text or text:match("^%s*$") then
            return
        end
        
        local macroName = nil
        
        -- Detect if it's a URL or JSON content
        if text:match("^https?://") then
            -- Extract filename from URL for macro name (handle query parameters)
            local fileName = text:match("/([^/?]+)%.json") or text:match("/([^/?]+)$")
            if fileName then
                macroName = fileName:gsub("%.json.*$", "") -- Remove .json and anything after it
            else
                macroName = "ImportedMacro_" .. os.time()
            end
            print("Importing from URL, macro name:", macroName)
        else
            -- For JSON content, use default name
            macroName = "ImportedMacro_" .. os.time()
            print("Importing from JSON content, macro name:", macroName)
        end
        
        -- Clean macro name (remove invalid characters)
        macroName = macroName:gsub("[<>:\"/\\|?*]", ""):gsub("^%s+", ""):gsub("%s+$", "")
        
        -- Ensure name isn't empty
        if macroName == "" then
            macroName = "ImportedMacro_" .. os.time()
        end
        
        -- Check if macro already exists
        if macroManager[macroName] then
            Rayfield:Notify({
                Title = "Import Cancelled",
                Content = "'" .. macroName .. "' already exists.",
                Duration = 3
            })
            return
        end
        
        -- Import the macro
        if text:match("^https?://") then
            importMacroFromURL(text, macroName)
        else
            importMacroFromContent(text, macroName)
        end
    end,
})

local ExportButton = MacroTab:CreateButton({
    Name = "Copy Macro JSON",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            Rayfield:Notify({
                Title = "Export Error",
                Content = "No macro selected for export.",
                Duration = 3
            })
            return
        end
        exportMacroToClipboard(currentMacroName, "compact")
    end,
})

local SendWebhookButton = MacroTab:CreateButton({
    Name = "Send Macro via Webhook",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            Rayfield:Notify({
                Title = "Webhook Error",
                Content = "No macro selected.",
                Duration = 3
            })
            return
        end
        
        if not ValidWebhook then
            Rayfield:Notify({
                Title = "Webhook Error",
                Content = "No webhook URL configured.",
                Duration = 3
            })
            return
        end
        
        local macroData = macroManager[currentMacroName]
        if not macroData or #macroData == 0 then
            Rayfield:Notify({
                Title = "Webhook Error",
                Content = "Selected macro is empty.",
                Duration = 3
            })
            return
        end
        
        -- Extract unique units from macro
        local unitsUsed = {}
        local unitCounts = {}
        local actionCounts = {
            spawn_unit = 0,
            upgrade_unit_ingame = 0,
            sell_unit_ingame = 0,
            skip_wave = 0,
            use_ability = 0
        }
        
        for _, action in ipairs(macroData) do
            -- Count action types
            if actionCounts[action.Type] then
                actionCounts[action.Type] = actionCounts[action.Type] + 1
            end
            
            -- Extract units from spawn actions
            if action.Type == "spawn_unit" and action.Unit then
                local unitName = action.Unit
                
                -- Extract base unit name (remove instance number like "#1", "#2")
                local baseUnitName = unitName:match("^(.+) #%d+$") or unitName
                
                if not unitsUsed[baseUnitName] then
                    unitsUsed[baseUnitName] = true
                    unitCounts[baseUnitName] = 0
                end
                unitCounts[baseUnitName] = unitCounts[baseUnitName] + 1
            end
        end
        
        -- Create units list for webhook message
        local unitsText = ""
        if next(unitCounts) then
            local unitsList = {}
            for unitName, count in pairs(unitCounts) do
                table.insert(unitsList, unitName)
            end
            table.sort(unitsList)
            unitsText = table.concat(unitsList, ", ")
        else
            unitsText = "No units found"
        end
        
        -- Create the JSON data
        local jsonData = Services.HttpService:JSONEncode(macroData)
        local fileName = currentMacroName .. ".json"
        
        -- Create multipart form data for file upload
        local boundary = "----WebKitFormBoundary" .. tostring(tick())
        local body = ""
        
        -- Add payload_json field with enhanced message
        body = body .. "--" .. boundary .. "\r\n"
        body = body .. "Content-Disposition: form-data; name=\"payload_json\"\r\n"
        body = body .. "Content-Type: application/json\r\n\r\n"
        body = body .. Services.HttpService:JSONEncode({
            embeds = {{
                title = "📁 Macro Shared: " .. currentMacroName,
                color = 0x5865F2,
                fields = {
                    {
                        name = "📊 Action Summary",
                        value = string.format("**Total Actions:** %d\n🏗️ **Placements:** %d\n⬆️ **Upgrades:** %d\n💸 **Sells:** %d\n⚡ **Abilities:** %d\n⏩ **Wave Skips:** %d",
                            #macroData,
                            actionCounts.spawn_unit,
                            actionCounts.upgrade_unit_ingame, 
                            actionCounts.sell_unit_ingame,
                            actionCounts.use_ability,
                            actionCounts.skip_wave
                        ),
                        inline = false
                    },
                    {
                        name = "🎯 Units Used",
                        value = unitsText,
                        inline = false
                    },
                },
                footer = {
                    text = "LixHub"
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }) .. "\r\n"
        
        -- Add file field
        body = body .. "--" .. boundary .. "\r\n"
        body = body .. "Content-Disposition: form-data; name=\"files[0]\"; filename=\"" .. fileName .. "\"\r\n"
        body = body .. "Content-Type: application/json\r\n\r\n"
        body = body .. jsonData .. "\r\n"
        
        -- End boundary
        body = body .. "--" .. boundary .. "--\r\n"
        
        -- Try multiple request functions
        local requestFunc = (syn and syn.request) or 
                        (http and http.request) or 
                        (http_request) or 
                        request
        
        if not requestFunc then
            Rayfield:Notify({
                Title = "Webhook Error",
                Content = "No HTTP request function available.",
                Duration = 3
            })
            return
        end
        
        local success, result = pcall(function()
            return requestFunc({
                Url = ValidWebhook,
                Method = "POST",
                Headers = { 
                    ["Content-Type"] = "multipart/form-data; boundary=" .. boundary,
                    ["User-Agent"] = "LixHub-Webhook/1.0"
                },
                Body = body
            })
        end)
        
        if success and result then
            if result.Success and result.StatusCode and result.StatusCode >= 200 and result.StatusCode < 300 then
                Rayfield:Notify({
                    Title = "Webhook Success", 
                    Content = string.format("Macro '%s' sent successfully!", currentMacroName),
                    Duration = 5
                })
            else
                local errorMsg = "HTTP Error " .. tostring(result.StatusCode or "unknown")
                Rayfield:Notify({
                    Title = "Webhook Error",
                    Content = errorMsg,
                    Duration = 5
                })
                print("Webhook failed - StatusCode:", result.StatusCode)
                if result.Body then
                    print("Response body:", result.Body)
                end
            end
        else
            local errorMsg = "Failed to send request"
            if result then
                errorMsg = errorMsg .. ": " .. tostring(result)
            end
            
            Rayfield:Notify({
                Title = "Webhook Error",
                Content = errorMsg,
                Duration = 3
            })
            print("Request failed:", result)
        end
    end,
})

local CheckUnitsButton = MacroTab:CreateButton({
    Name = "Check Macro Units",
    Callback = function()
        if not currentMacroName or currentMacroName == "" then
            Rayfield:Notify({
                Title = "Error",
                Content = "No macro selected.",
                Duration = 3
            })
            return
        end
        
        local macroData = macroManager[currentMacroName]
        if not macroData or #macroData == 0 then
            Rayfield:Notify({
                Title = "Error",
                Content = "Selected macro is empty.",
                Duration = 3
            })
            return
        end
        
        -- Extract unique units from macro (using Type field for AG format)
        local units = {}
        local unitCounts = {}
        
        for _, action in ipairs(macroData) do
            if action.Type == "spawn_unit" and action.Unit then
                local unitName = action.Unit
                
                -- Extract base unit name (remove instance number like "#1", "#2")
                local baseUnitName = unitName:match("^(.+) #%d+$") or unitName
                
                if not units[baseUnitName] then
                    units[baseUnitName] = true
                    unitCounts[baseUnitName] = 0
                end
                unitCounts[baseUnitName] = unitCounts[baseUnitName] + 1
            end
        end
        
        -- Create display text
        local unitList = {}
        for unitName, count in pairs(unitCounts) do
            table.insert(unitList, unitName)
        end
        
        if #unitList > 0 then
            table.sort(unitList)
            local displayText = table.concat(unitList, "\n")
            
            Rayfield:Notify({
                Title = "Macro Units (" .. #unitList .. " types)",
                Content = displayText,
                Duration = 8
            })
        else
            Rayfield:Notify({
                Title = "No Units Found",
                Content = "This macro contains no unit placements.",
                Duration = 3
            })
        end
    end,
})

Input = WebhookTab:CreateInput({
    Name = "Input Webhook",
    CurrentValue = "",
    PlaceholderText = "Input Webhook...",
    RemoveTextAfterFocusLost = false,
    Flag = "WebhookInput",
    Callback = function(Text)
        local trimmed = Text:match("^%s*(.-)%s*$")

        if trimmed == "" then
            ValidWebhook = nil
            return
        end

        local valid = trimmed:match("^https://")

        if valid then
            ValidWebhook = trimmed
        else
            ValidWebhook = nil
        end
    end,
})

 Input = WebhookTab:CreateInput({
    Name = "Input Discord ID (mention rares)",
    CurrentValue = "",
    PlaceholderText = "Input Discord ID...",
    RemoveTextAfterFocusLost = false,
    Flag = "WebhookInputUserID",
    Callback = function(Text)
        Config.DISCORD_USER_ID = tostring(Text):match("^%s*(.-)%s*$")
    end,
})



     Toggle = WebhookTab:CreateToggle({
    Name = "Send On Stage Finished",
    CurrentValue = false,
    Flag = "SendWebhookOnStageFinished",
    Callback = function(Value)
        State.SendStageCompletedWebhook = Value
    end,
    })

local STAGE_PRIORITY = {
    "Lawless City",
    "Temple",
    "Orc Castle",
    "Kingdom of Wandenreich",
    "Namakora Village",
    "Central Command",
    "The Crimson Eclipse",
    "Hidden Leaf Village",
}

local excludedStages = {
    ["Easter Event"] = true,
    ["Moonbase Sci-Fi"] = true,
    ["Nazarick Mausoleum"] = true,
    ["Hell Devil"] = true,
    ["Lingxian Academy"] = true,
    ["Lingxian Yard"] = true,
}

local STORY_STAGE_PRIORITY = {
    "Large Village",
    "Hollow Land",
    "Monster City",
    "Academy Demon",
}

local function notify(title, content, duration)
        Rayfield:Notify({
            Title = title or "Notice",
            Content = content or "No message.",
            Duration = duration or 5,
            Image = "info",
    })
end

local function canPerformAction()
    return tick() - AutoJoinState.lastActionTime >= AutoJoinState.actionCooldown
end

local function setProcessingState(action)
    AutoJoinState.isProcessing = true
    AutoJoinState.currentAction = action
    AutoJoinState.lastActionTime = tick()

    if action == "Story Auto Join" then
        notify("Auto Joiner: ", string.format(
            "Joining %s - %s [%s]",
            State.StoryStageSelected or "?",
            State.StoryActSelected or "?",
            State.StoryDifficultySelected or "?"
        ))
    end
end

local function clearProcessingState()
    AutoJoinState.isProcessing = false
    AutoJoinState.currentAction = nil
end

local function checkAndJoinGate()
    if not State.AutoJoinGate then return end
    if not isInLobby() then return end
    
    -- Check if GateOpening attribute is true
    local gateOpening = Services.Workspace:GetAttribute("GateOpening")
    if not gateOpening then return end
    
    setProcessingState("Auto Join Gate")
    
    -- Find the gate spawn point
    local gateSpawnPoint = Services.Workspace:FindFirstChild("Gatespawnpoint")
    if not gateSpawnPoint then
        warn("Gatespawnpoint not found in workspace")
        task.delay(5, clearProcessingState)
        return
    end
    
    local spawnPoint1 = gateSpawnPoint:FindFirstChild("1")
    if not spawnPoint1 then
        warn("Spawn point '1' not found in Gatespawnpoint")
        task.delay(5, clearProcessingState)
        return
    end
    
    local player = Services.Players.LocalPlayer
    
    -- Teleport player to the spawn point
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = spawnPoint1.CFrame
        
        -- Wait a moment for teleportation to complete
        task.wait(0.5)
        
        -- Look for proximity prompt in the area
        local proximityPrompt = nil
        
        -- Check if the spawn point itself has a proximity prompt
        proximityPrompt = Services.Workspace:WaitForChild("CreatingRoom"):WaitForChild("Server"):WaitForChild("PortalPart"):FindFirstChildOfClass("ProximityPrompt")
        
        -- If not found on spawn point, check nearby parts
        if not proximityPrompt then
            local function findNearbyParts(parent)
                for _, child in pairs(parent:GetChildren()) do
                    if child:IsA("BasePart") then
                        local distance = (child.Position - spawnPoint1.Position).Magnitude
                        if distance <= 20 then -- Within 20 studs
                            local prompt = child:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then
                                proximityPrompt = prompt
                                break
                            end
                        end
                    end
                    findNearbyParts(child)
                    if proximityPrompt then break end
                end
            end
            findNearbyParts(Services.Workspace)
        end
        
        -- Use the proximity prompt if found
        if proximityPrompt then
            proximityPrompt:InputHoldBegin()
            task.wait(0.1)
            proximityPrompt:InputHoldEnd()
            print("Gate joined successfully!")
            notify("Auto Joiner", "Gate joined successfully!")
        else
            warn("No proximity prompt found near the gate spawn point")
            notify("Auto Joiner", "No proximity prompt found at gate")
        end
    else
        warn("Player character or HumanoidRootPart not found")
    end
    
    task.delay(5, clearProcessingState)
end

local function checkAndExecuteHighestPriority()
    if not isInLobby() then return end
    if AutoJoinState.isProcessing then return end
    if not canPerformAction() then return end

    if State.AutoJoinDelay and State.AutoJoinDelay > 0 then
        task.wait(State.AutoJoinDelay)
    end

    --GATES
    if State.AutoJoinGate then
        checkAndJoinGate()
        return
    end

    --CHALLENGE
    if State.AutoJoinChallenge then
            setProcessingState("Auto Join Challenge")

            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Challenge",{})
            task.wait(1)
            local portalpart = Services.Workspace:WaitForChild("CreatingRoom"):FindFirstChild(tostring(Services.Players.LocalPlayer.Name)):FindFirstChild("PortalPart")
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Create",{portalpart:GetAttribute("Stages"),portalpart:GetAttribute("Act"),"Challenge"})


            task.delay(5, clearProcessingState)
            return
    end

    if State.AutoJoinLimitedEvent and State.AutoJoinLimitedEventSelected then
        setProcessingState("Auto Join Event")

        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("RoomFunction"):InvokeServer("host",{friendOnly = false,stage = State.AutoJoinEventSelected})
        task.wait(1)
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("RoomFunction"):InvokeServer("start")

            task.delay(5, clearProcessingState)
        return
    end

    --TOWER ADVENTURES
    if State.AutoJoinTower and State.AutoJoinTowerSelected then
        setProcessingState("Auto Join Tower")

        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Tower Adventures",{State.AutoJoinTowerSelected,Services.Players.LocalPlayer.Stages[State.AutoJoinTowerSelected].Floor.Value,"Tower Adventures"})
        task.wait(1)
        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Create",{State.AutoJoinTowerSelected,Services.Players.LocalPlayer.Stages[State.AutoJoinTowerSelected].Floor.Value,"Tower Adventures"})

        task.delay(5, clearProcessingState)
        return
    end

    if State.AutoJoinEvent and State.AutoJoinEventSelected then
        setProcessingState("Auto Join Event")

        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("RoomFunction"):InvokeServer("host",{friendOnly = false,stage = State.AutoJoinEventSelected})
        task.wait(1)
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("RoomFunction"):InvokeServer("start")

            task.delay(5, clearProcessingState)
            return
    end

    if State.AutoJoinWorldlines and State.AutoJoinWorldlinesSelected then
        setProcessingState("Auto Join Worldlines")

        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("RoomFunction"):InvokeServer("host",{friendOnly = false,stage = State.AutoJoinWorldlinesSelected})
        task.wait(1)
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("RoomFunction"):InvokeServer("start")

            task.delay(5, clearProcessingState)
            return
    end

    if State.AutoJoinPortal and State.AutoJoinPortalSelected then
            setProcessingState("Auto Join Portal")
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer(tostring(State.AutoJoinPortalSelected).." (Portal)",{})
            task.wait(1)
            local portalpart = Services.Workspace:WaitForChild("CreatingRoom"):FindFirstChild(tostring(Services.Players.LocalPlayer.Name)):FindFirstChild("PortalPart")
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Create",{portalpart:GetAttribute("Stages"),portalpart:GetAttribute("Act"),portalpart:GetAttribute("Difficulty")})
            task.delay(5, clearProcessingState)
            return
    end

    --RAID
    if State.AutoJoinRaid and State.RaidStageSelected ~= nil then
            setProcessingState("Auto Join Raid")

            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Raid",{State.RaidStageSelected,"1","Raid"})
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Create",{State.RaidStageSelected,"1","Boss Rush"})

            task.delay(5, clearProcessingState)
            return
    end

    -- STORY
    if State.AutoJoinStory and State.StoryStageSelected ~= nil and State.StoryActSelected ~= nil and State.StoryDifficultySelected ~= nil then
        setProcessingState("Auto Join Story")

        print(State.AutoJoinStory)
        print(State.StoryStageSelected)
        print(State.StoryActSelected)
        print(State.StoryDifficultySelected)

            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Story",{State.StoryStageSelected,State.StoryActSelected,State.StoryDifficultySelected})
            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode"):WaitForChild("Events"):WaitForChild("CreatingPortal"):InvokeServer("Create",{State.StoryStageSelected,State.StoryActSelected,State.StoryDifficultySelected})

            task.delay(5, clearProcessingState)
            return
        end
    end

local function extractModuleStages()
    local moduleStages = {}
    
    for categoryName, categoryData in pairs(stageRewards) do
        if categoryName ~= "Story" and categoryName ~= "Infinity" then -- Skip Story and Infinity as they don't have named stages
            if type(categoryData) == "table" then
                -- Handle regular categories
                for stageName, stageData in pairs(categoryData) do
                    if stageName ~= "Rewards" and stageName ~= "ChanceRewards" and stageName ~= "FirstRewards" and stageName ~= "FloorRewards" then
                        if type(stageData) == "table" and (stageData.Rewards or stageData.ChanceRewards or stageData.FloorRewards or next(stageData)) then
                            moduleStages[stageName] = categoryName
                        end
                    end
                end
                
                -- Handle nested categories (like Darkness Gate)
                for subCategoryName, subCategoryData in pairs(categoryData) do
                    if type(subCategoryData) == "table" and not subCategoryData.Amount and not subCategoryData.Percents then
                        for nestedStageName, nestedStageData in pairs(subCategoryData) do
                            if nestedStageName ~= "Rewards" and nestedStageName ~= "ChanceRewards" and nestedStageName ~= "FirstRewards" and nestedStageName ~= "FloorRewards" then
                                if type(nestedStageData) == "table" and (nestedStageData.Rewards or nestedStageData.ChanceRewards or nestedStageData.FloorRewards or next(nestedStageData)) then
                                    moduleStages[nestedStageName] = categoryName .. " -> " .. subCategoryName
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return moduleStages
end

local function getPlayerStages()
    local playerStages = {}
    
    if LocalPlayer.Stages then
        for _, stageObject in pairs(LocalPlayer.Stages:GetChildren()) do
            playerStages[stageObject.Name] = true
        end
    else
        warn("LocalPlayer.Stages folder not found!")
        return {}
    end
    
    return playerStages
end

-- Function to find story stages
local function findStoryStages()
    local moduleStages = extractModuleStages()
    local playerStages = getPlayerStages()
    
    if next(playerStages) == nil then
        warn("No stages found in LocalPlayer.Stages folder!")
        return {}
    end
    
    local storyStages = {}
    
    -- Compare player stages with module stages
    for stageName, _ in pairs(playerStages) do
        if not moduleStages[stageName] and not excludedStages[stageName] then
            table.insert(storyStages, stageName)
        end
    end
    
    return storyStages
end

local function loadRaidStages()
    local allRaidStages = {}
    local orderedStages = {}
    local unlistedStages = {}
    
    -- Check if Raid category exists
    if stageRewards.Raid and type(stageRewards.Raid) == "table" then
        -- First, collect all valid raid stage names
        for stageName, stageData in pairs(stageRewards.Raid) do
            -- Make sure it's a valid stage (has rewards or chance rewards)
            if type(stageData) == "table" and (stageData.Rewards or stageData.ChanceRewards) then
                allRaidStages[stageName] = true
            end
        end
        
        -- Add stages in priority order (if they exist)
        for _, stageName in ipairs(STAGE_PRIORITY) do
            if allRaidStages[stageName] then
                table.insert(orderedStages, stageName)
                allRaidStages[stageName] = nil -- Remove from remaining stages
            end
        end
        
        -- Add any remaining stages alphabetically at the bottom
        for stageName, _ in pairs(allRaidStages) do
            table.insert(unlistedStages, stageName)
        end
        table.sort(unlistedStages) -- Sort alphabetically
        
        -- Combine ordered stages with unlisted stages
        local raidStages = {}
        for _, stageName in ipairs(orderedStages) do
            table.insert(raidStages, stageName)
        end
        for _, stageName in ipairs(unlistedStages) do
            table.insert(raidStages, stageName)
        end
        
        -- Set the dropdown options
        StageDropdown:Refresh(raidStages)
        
        print("Loaded " .. #raidStages .. " Raid stages into dropdown:")
        print("Priority ordered stages:")
        for i, stageName in ipairs(orderedStages) do
            print("  " .. i .. ". " .. stageName .. " (priority)")
        end
        if #unlistedStages > 0 then
            print("Unlisted stages (alphabetical):")
            for i, stageName in ipairs(unlistedStages) do
                print("  " .. (#orderedStages + i) .. ". " .. stageName .. " (unlisted)")
            end
        end 
    else
        warn("Raid category not found in StageRewards module!")
    end
end

local function loadStoryStages()
    print("=== STORY STAGE LOADER ===")
    print("Loading story stages into dropdown...")
    
    local allStoryStages = findStoryStages()

    if not allStoryStages or type(allStoryStages) ~= "table" then
        print("No story stages found or invalid data returned!")
        StoryStageDropdown:Refresh({})
        return
    end

    local orderedStages = {}
    local unlistedStages = {}
    local storyStageSet = {}
    
    -- Convert to set for quick lookup
    for _, stageName in ipairs(allStoryStages) do
        storyStageSet[stageName] = true
    end
    
    -- Add stages in priority order (if they exist)
    for _, stageName in ipairs(STORY_STAGE_PRIORITY) do
        if storyStageSet[stageName] then
            table.insert(orderedStages, stageName)
            storyStageSet[stageName] = nil -- Remove from remaining stages
        end
    end
    
    -- Add any remaining stages alphabetically at the bottom
    for stageName, _ in pairs(storyStageSet) do
        table.insert(unlistedStages, stageName)
    end
    table.sort(unlistedStages) -- Sort alphabetically
    
    -- Combine ordered stages with unlisted stages
    local finalStoryStages = {}
    for _, stageName in ipairs(orderedStages) do
        table.insert(finalStoryStages, stageName)
    end
    for _, stageName in ipairs(unlistedStages) do
        table.insert(finalStoryStages, stageName)
    end
    
    if #finalStoryStages > 0 then
        -- Set the dropdown options
        StoryStageDropdown:Refresh(finalStoryStages)
        
        print("Loaded " .. #finalStoryStages .. " Story stages into dropdown:")
        if #orderedStages > 0 then
            print("Priority ordered stages:")
            for i, stageName in ipairs(orderedStages) do
                print("  " .. i .. ". " .. stageName .. " (priority)")
            end
        end
        if #unlistedStages > 0 then
            print("Unlisted stages (alphabetical):")
            for i, stageName in ipairs(unlistedStages) do
                print("  " .. (#orderedStages + i) .. ". " .. stageName .. " (unlisted)")
            end
        end
    else
        print("No story stages found!")
        warn("Could not find any story stages. Make sure LocalPlayer.Stages exists and contains story stages.")
    end
end

local function loadPortalStages()
    local allPortalStages = {}
    local orderedStages = {}
    local unlistedStages = {}
    local playerInventory = Services.Players.LocalPlayer:FindFirstChild("ItemsInventory")
    
    -- Check if Portals category exists
    if stageRewards.Portals and type(stageRewards.Portals) == "table" then
        -- First, collect all valid portal stage names that the player has in inventory
        for stageName, stageData in pairs(stageRewards.Portals) do
            -- Make sure it's a valid stage (has rewards or chance rewards)
            if type(stageData) == "table" and (stageData.Rewards or stageData.ChanceRewards) then
                -- Check if player has the portal in their inventory
                local portalItemName = stageName .. " (Portal)"
                if playerInventory:FindFirstChild(portalItemName) then
                    allPortalStages[stageName] = true
                end
            end
        end
        
        -- Add stages in priority order (if they exist and player has them)
        if STAGE_PRIORITY then -- Check if STAGE_PRIORITY exists
            for _, stageName in ipairs(STAGE_PRIORITY) do
                if allPortalStages[stageName] then
                    table.insert(orderedStages, stageName)
                    allPortalStages[stageName] = nil -- Remove from remaining stages
                end
            end
        end
        
        -- Add any remaining stages alphabetically at the bottom
        for stageName, _ in pairs(allPortalStages) do
            table.insert(unlistedStages, stageName)
        end
        table.sort(unlistedStages) -- Sort alphabetically
        
        -- Combine ordered stages with unlisted stages
        local portalStages = {}
        for _, stageName in ipairs(orderedStages) do
            table.insert(portalStages, stageName)
        end
        for _, stageName in ipairs(unlistedStages) do
            table.insert(portalStages, stageName)
        end
        
        -- Set the dropdown options
        PortalStageDropdown:Refresh(portalStages)
        
        print("Loaded " .. #portalStages .. " Portal stages into dropdown:")
        print("Priority ordered stages:")
        for i, stageName in ipairs(orderedStages) do
            print("  " .. i .. ". " .. stageName .. " (priority)")
        end
        if #unlistedStages > 0 then
            print("Unlisted stages (alphabetical):")
            for i, stageName in ipairs(unlistedStages) do
                print("  " .. (#orderedStages + i) .. ". " .. stageName .. " (unlisted)")
            end
        end
        
        -- If no portals found in inventory
        if #portalStages == 0 then
            print("No portal items found in player's inventory!")
        end
    else
        warn("Portals category not found in StageRewards module!")
    end
end

local function snapshotInventory()
    local snapshot = {}
    State.unitNameSet = {}

    snapshot.Gold = Services.Players.LocalPlayer.Data.Coins.Value
    snapshot.Gem = Services.Players.LocalPlayer.Data.Tokens.Value
    snapshot.TraitReroll = Services.Players.LocalPlayer.Data.Reroll_Tokens.Value
    snapshot.Cog = Services.Players.LocalPlayer.Data.Cog.Value
    snapshot.Heart = Services.Players.LocalPlayer.Data.Heart.Value
    snapshot.Honey = Services.Players.LocalPlayer.Data.Honey.Value
    snapshot.MagicBall = Services.Players.LocalPlayer.Data.MagicBall.Value
    snapshot.MoonNight = Services.Players.LocalPlayer.Data.MoonNight.Value
    snapshot.Mushroom = Services.Players.LocalPlayer.Data.Mushroom.Value
    snapshot.Snowflake = Services.Players.LocalPlayer.Data.Snowflake.Value
    snapshot.StatReroll = Services.Players.LocalPlayer.Data.StatReroll.Value
    snapshot.SuperStatReroll = Services.Players.LocalPlayer.Data.SuperStatReroll.Value

    local itemInventory = Services.Players.LocalPlayer:WaitForChild("ItemsInventory")
    local unitInventory = Services.Players.LocalPlayer:WaitForChild("UnitsInventory")

    for _, item in pairs(itemInventory:GetChildren()) do
        if item:IsA("Folder") then
            snapshot[item.Name] = tonumber(item.Amount.Value)
        end
    end

    local unitCounts = {}
    for _, unit in pairs(unitInventory:GetChildren()) do
        if unit:IsA("Folder") then
            unitCounts[unit.Unit.Value] = (unitCounts[unit.Unit.Value] or 0) + 1
            State.unitNameSet[unit.Unit.Value] = true
        end
    end

    for unitName, count in pairs(unitCounts) do
        snapshot[unitName] = count
    end

    return snapshot
end

local function compareInventories(startInv, endInv)
    local gained = {}
    for itemName, endValue in pairs(endInv) do
        local startValue = startInv[itemName] or 0
        if endValue > startValue then
            local isUnit = State.unitNameSet[itemName] == true
            table.insert(gained, { name = itemName, amount = endValue - startValue, isUnit = isUnit })
        end
    end
    return gained
end

local function isUnitReward(rewardName)
    local unitsSettings = Services.ReplicatedStorage:FindFirstChild("PlayMode")
    if not unitsSettings then return false end
    
    local modules = unitsSettings:FindFirstChild("Modules")
    if not modules then return false end
    
    local unitsSettingsFolder = modules:FindFirstChild("UnitsSettings")
    if not unitsSettingsFolder then return false end
    
    -- Check if a ModuleScript with this reward name exists
    local unitModule = unitsSettingsFolder:FindFirstChild(rewardName)
    return unitModule ~= nil and unitModule:IsA("ModuleScript")
end

local function buildRewardsText()
    if not capturedRewards or #capturedRewards == 0 then
        return "_No rewards found after match_", {}, {}
    end
    
    local lines = {}
    local detectedRewards = {}
    local detectedUnits = {}
    
    for _, rewardData in ipairs(capturedRewards) do
        local itemName = rewardData[1]
        local amount = rewardData[2]
        
        print(itemName .. " - " .. amount)
        
        detectedRewards[itemName] = amount
        
        -- Check if this reward is a unit by searching in UnitsSettings
        if isUnitReward(itemName) then
            -- It's a unit!
            table.insert(detectedUnits, itemName)
            table.insert(lines, string.format("🌟 %s x%d", itemName, amount))
        else
            -- Standard reward
            local totalText = ""
            
            -- Get current total from player data
            if itemName == "Coins" or itemName == "Gold" then
                totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Coins.Value)
                table.insert(lines, string.format("+ %d %s%s", amount, itemName, totalText))
            elseif itemName == "Gems" then
                totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Tokens.Value)
                table.insert(lines, string.format("+ %d %s%s", amount, itemName, totalText))
            elseif itemName == "TraitReroll" then
                totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Reroll_Tokens.Value)
                table.insert(lines, string.format("+ %d %s%s", amount, itemName, totalText))
            elseif itemName == "Cog" then
                totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Cog.Value)
                table.insert(lines, string.format("+ %d %s%s", amount, itemName, totalText))
            elseif itemName == "Heart" then
                totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Heart.Value)
                table.insert(lines, string.format("+ %d %s%s", amount, itemName, totalText))
            elseif itemName == "Honey" then
                totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Honey.Value)
                table.insert(lines, string.format("+ %d %s%s", amount, itemName, totalText))
            elseif itemName == "MagicBall" then
                totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.MagicBall.Value)
                table.insert(lines, string.format("+ %d %s%s", amount, itemName, totalText))
            elseif itemName == "MoonNight" then
                totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.MoonNight.Value)
                table.insert(lines, string.format("+ %d %s%s", amount, itemName, totalText))
            elseif itemName == "Mushroom" then
                totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Mushroom.Value)
                table.insert(lines, string.format("+ %d %s%s", amount, itemName, totalText))
            elseif itemName == "Snowflake" then
                totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.Snowflake.Value)
                table.insert(lines, string.format("+ %d %s%s", amount, itemName, totalText))
            elseif itemName == "StatReroll" then
                totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.StatReroll.Value)
                table.insert(lines, string.format("+ %d %s%s", amount, itemName, totalText))
            elseif itemName == "SuperStatReroll" then
                totalText = string.format(" [%d total]", Services.Players.LocalPlayer.Data.SuperStatReroll.Value)
                table.insert(lines, string.format("+ %d %s%s", amount, itemName, totalText))
            else
                -- Other items (portals, generic items, etc.)
                local itemObj = Services.Players.LocalPlayer:WaitForChild("ItemsInventory"):FindFirstChild(itemName)
                local totalAmount = itemObj and itemObj:FindFirstChild("Amount") and itemObj.Amount.Value or nil
                totalText = totalAmount and string.format(" [%d total]", totalAmount) or ""
                table.insert(lines, string.format("+ %d %s%s", amount, itemName, totalText))
            end
        end
    end
    
    local rewardsText = table.concat(lines, "\n")
    notify("Gained rewards:", rewardsText, 2)
    return rewardsText, detectedRewards, detectedUnits
end

local function calculateActualClearTime()
    print(State.gameStartRealTime)
    print(State.gameEndRealTime)
    if State.gameStartRealTime and State.gameEndRealTime then
        State.actualClearTime = State.gameEndRealTime - State.gameStartRealTime
        print(string.format("Clear time: %.2f seconds", State.actualClearTime))
        return State.actualClearTime
    end
    return nil
end

local function sendWebhook(messageType, rewards, clearTime, matchResult)
    if not ValidWebhook then 
        warn("❌ No webhook URL configured")
        return 
    end

    print("🔔 Preparing webhook:", messageType)
    
    local data
    if messageType == "test" then
        data = {
            username = "LixHub Bot",
            content = string.format("<@%s>", Config.DISCORD_USER_ID or "000000000000000000"),
            embeds = {{
                title = "📢 LixHub Notification",
                description = "🧪 Test webhook sent successfully",
                color = 0x5865F2,
                footer = { text = "LixHub Auto Logger" },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
    elseif messageType == "stage" then
        local RewardsUI = Services.Workspace.GameSettings
        local stageName = RewardsUI and RewardsUI:FindFirstChild("Stages") and RewardsUI.Stages.Value or "Unknown Stage"
        local gameMode = RewardsUI and RewardsUI:FindFirstChild("Act") and RewardsUI.Act.Value or "Unknown Act"
        local gameDif = RewardsUI and RewardsUI:FindFirstChild("Difficulty") and RewardsUI.Difficulty.Value or "Unknown Difficulty"
        
        local baseHealth = Services.Workspace.GameSettings:FindFirstChild("Base")
        local isWin = baseHealth and baseHealth:FindFirstChild("Health") and baseHealth.Health.Value > 0 or false
        local resultText = isWin and "Victory" or "Defeat"
        
        local plrlevel = Services.Players.LocalPlayer:FindFirstChild("Data") and Services.Players.LocalPlayer.Data:FindFirstChild("Levels") and Services.Players.LocalPlayer.Data.Levels.Value or "?"
        
        local actualClearTime = calculateActualClearTime()
        local formattedTime = "N/A"

        if actualClearTime then
            local hours = math.floor(actualClearTime / 3600)
            local minutes = math.floor((actualClearTime % 3600) / 60)
            local seconds = math.floor(actualClearTime % 60)
            formattedTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        end

        print("📊 Building rewards text...")
        local rewardsText, detectedRewards, detectedUnits = buildRewardsText()
        print("✅ Rewards text built. Units detected:", #detectedUnits)
        
        local shouldPing = #detectedUnits > 0

        if #detectedUnits > 1 then 
            print("⚠️ Multiple units detected, skipping webhook")
            return 
        end

        local pingText = shouldPing and string.format("<@%s> 🎉 **SECRET UNIT OBTAINED!** 🎉", Config.DISCORD_USER_ID or "000000000000000000") or ""

        local stageResult = stageName.." - Act "..gameMode .. " - " .. gameDif .. " - " .. resultText
        local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")

        data = {
            username = "LixHub Bot",
            content = shouldPing and pingText or "",
            embeds = {{
                title = shouldPing and "🌟 UNIT DROP! 🌟" or "🎯 Stage Finished!",
                description = shouldPing and (pingText .. "\n" .. stageResult) or stageResult,
                color = shouldPing and 0xFFD700 or (isWin and 0x57F287 or 0xED4245),
                fields = {
                    { name = "👤 Player", value = "||" .. tostring(Services.Players.LocalPlayer.Name) .. " [" .. tostring(plrlevel) .. "]||", inline = true },
                    { name = isWin and "✅ Won in:" or "❌ Lost after:", value = formattedTime, inline = true },
                    { name = "🏆 Rewards", value = rewardsText, inline = false },
                    shouldPing and { name = "🌟 Units Obtained", value = table.concat(detectedUnits, ", "), inline = false } or nil,
                    { name = "📈 Script Version", value = script_version, inline = true },
                },
                footer = { text = "discord.gg/cYKnXE2Nf8" },
                timestamp = timestamp
            }}
        }

        -- Filter out nil fields
        local filteredFields = {}
        for _, field in ipairs(data.embeds[1].fields) do 
            if field then 
                table.insert(filteredFields, field) 
            end 
        end
        data.embeds[1].fields = filteredFields
    else
        warn("❌ Unknown message type:", messageType)
        return
    end

    print("🔄 Encoding payload...")
    local payload = Services.HttpService:JSONEncode(data)
    print("✅ Payload encoded (" .. #payload .. " bytes)")
    
    -- Try multiple request functions
    local requestFunc = request or 
                       (syn and syn.request) or 
                       (http and http.request) or 
                       http_request

    if not requestFunc then
        warn("❌ No HTTP request function available!")
        notify("Webhook Error", "No HTTP request method available.")
        return
    end
    
    print("📤 Sending webhook request...")
    local success, result = pcall(function()
        return requestFunc({
            Url = ValidWebhook,
            Method = "POST",
            Headers = { 
                ["Content-Type"] = "application/json"
            },
            Body = payload
        })
    end)

    if success and result then
        print("📥 Response received:")
        print("  StatusCode:", result.StatusCode)
        print("  Success:", result.Success)
        
        if result.Success or (result.StatusCode >= 200 and result.StatusCode < 300) then
            print("✅ Webhook sent successfully!")
            notify("Webhook", "Webhook sent successfully.", 2)
        else
            warn("❌ Webhook failed with status:", result.StatusCode)
            if result.Body then
                warn("Response body:", result.Body)
            end
            notify("Webhook Error", "HTTP " .. tostring(result.StatusCode))
        end
    else
        warn("❌ Webhook request failed:", tostring(result))
        notify("Webhook Error", tostring(result))
    end
end

local function onGameStart()
    gameInProgress = true
    gameStartTime = tick()
    State.gameStartRealTime = tick()
    capturedRewards = nil
    lastUseTime = {}

    -- STOP ANY ONGOING PLAYBACK AND LET THE LOOP RESTART IT
    if isPlaybacking then
        print("Game ended - stopping current playback")
        isPlaybacking = false
        
        -- Cancel ability queue
        if abilityQueueThread then
            task.cancel(abilityQueueThread)
            abilityQueueThread = nil
        end
        
        -- Clear ability queue
        abilityQueue = {}
        
        -- Clear unit mappings
        clearSpawnIdMappings()
    end
    
    -- Auto-start recording if enabled
    if isRecording and not recordingHasStarted then
        recordingHasStarted = true
        clearSpawnIdMappings()
        table.clear(macro)
        MacroStatusLabel:Set("Status: Recording active!")
        notify("Recording Started", "Game started - recording active.")
    end
    
    print("Game started, tracking initialized")
end

-- Update your wave monitoring to call onGameStart
if not isInLobby() then
Services.Workspace.GameSettings.Wave.Changed:Connect(function(newWave)
    if newWave >= 1 and not gameInProgress then
        startGameTracking()
    elseif newWave == 0 and gameInProgress then
        stopGameTracking()
    end
end)
end

local function checkInitialGameState()
    local waveNum = Services.Workspace.GameSettings.Wave
    if waveNum and waveNum.Value >= 1 then
        print("Joined mid-game at wave", waveNum.Value)
        startGameTracking()
    end
end

local function checkGameStarted()
    if isInLobby() then return end
    local gameStarted = Services.Workspace.GameSettings.GameStarted.Value
    if gameStarted then
        onGameStart()
    end
end

      TestWebhookButton = WebhookTab:CreateButton({
    Name = "Test webhook",
    Callback = function()
        if ValidWebhook then
            sendWebhook("test")
        end
    end,
    })

loadRaidStages()
loadStoryStages()
loadPortalStages()
if not isInLobby() then
checkGameStarted()
end

task.spawn(function()
    while true do
    task.wait(0.5)
    checkAndExecuteHighestPriority()
    end
end)

if not isInLobby() then
    Services.ReplicatedStorage:WaitForChild("EndGame").OnClientEvent:Connect(function(player, result, rewards)

        if webhookDebounce then
            print("⚠️ Webhook debounced - ignoring duplicate EndGame event")
            return
        end
        
        webhookDebounce = true

        stopGameTracking()

        State.gameEndRealTime = tick()
        
        -- Capture rewards and result FIRST
        capturedRewards = rewards or {} -- Array of {rewardName, amount}
        
        print("=== REWARDS CAPTURED ===")
        print("Result:", result)
        print("Rewards:")
        if rewards and type(rewards) == "table" then
        for _, reward in ipairs(rewards) do
            print(string.format("  %s: %d", reward[1], reward[2]))
        end
    else
        print("  No rewards received")
    end
        print("========================")
        
        if isRecording and recordingHasStarted then
            isRecording = false
            recordingHasStarted = false
            RecordToggle:Set(false)
            
            Rayfield:Notify({
                Title = "Recording Stopped",
                Content = "Game ended, recording saved.",
                Duration = 6
            })
            
            if currentMacroName then
                macroManager[currentMacroName] = macro
                saveMacroToFile(currentMacroName)
            end
        end
        
        State.isGameRunning = false
        
        -- Send webhook with captured data
        if State.SendStageCompletedWebhook then
            sendWebhook("stage")
        end

         task.delay(WEBHOOK_DEBOUNCE_TIME, function()
            webhookDebounce = false
        end)
        
        -- Handle auto voting logic with priority system
        task.spawn(function()
            task.wait(3) -- Small delay to ensure game state is stable
            
            local MAX_RETRIES = 5
            local RETRY_DELAY = 2
            
            -- Priority 1: Auto Next (highest priority) - only for victories
            if State.AutoVoteNext and result == "VICTORY" then
                print("Auto Next enabled and game won - Voting for next stage...")
                
                for attempt = 1, MAX_RETRIES do
                    local success, err = pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
                            :WaitForChild("Events"):WaitForChild("Control"):FireServer("Next Stage Vote")
                    end)
                    
                    if success then
                        print(string.format("✓ Successfully voted for next stage (attempt %d/%d)", attempt, MAX_RETRIES))
                        Rayfield:Notify({
                            Title = "Auto Vote",
                            Content = "Voted for next stage",
                            Duration = 3
                        })
                        return
                    else
                        warn(string.format("❌ Failed to vote for next stage (attempt %d/%d): %s", attempt, MAX_RETRIES, tostring(err)))
                        
                        if attempt < MAX_RETRIES then
                            print(string.format("⏳ Retrying in %d seconds...", RETRY_DELAY))
                            task.wait(RETRY_DELAY)
                        else
                            Rayfield:Notify({
                                Title = "Auto Vote Failed",
                                Content = "Failed to vote for next stage after " .. MAX_RETRIES .. " attempts",
                                Duration = 5
                            })
                        end
                    end
                end
                return
            end

            -- Priority 2: Auto Retry (medium priority)
            if State.AutoVoteRetry then
                print("Auto Retry enabled - Voting to replay...")
                
                for attempt = 1, MAX_RETRIES do
                    local success, err = pcall(function()
                        for i, connection in pairs(getconnections(game:GetService("Players").LocalPlayer.PlayerGui.EndGUI.Main.Stage.Button.Retry.Button.MouseButton1Click)) do
                        connection:Enable()
                        connection:Fire()
                        end
                    end)
                    
                    if success then
                        print(string.format("✓ Successfully voted for retry (attempt %d/%d)", attempt, MAX_RETRIES))
                        Rayfield:Notify({
                            Title = "Auto Vote",
                            Content = "Voted to retry the stage",
                            Duration = 3
                        })
                        return
                    else
                        warn(string.format("❌ Failed to vote for retry (attempt %d/%d): %s", attempt, MAX_RETRIES, tostring(err)))
                        
                        if attempt < MAX_RETRIES then
                            print(string.format("⏳ Retrying in %d seconds...", RETRY_DELAY))
                            task.wait(RETRY_DELAY)
                        else
                            Rayfield:Notify({
                                Title = "Auto Vote Failed",
                                Content = "Failed to vote for retry after " .. MAX_RETRIES .. " attempts",
                                Duration = 5
                            })
                        end
                    end
                end
                return
            end
            
            -- Priority 3: Auto Lobby (lowest priority)
            if State.AutoVoteLobby then
                print("Auto Lobby enabled - Returning to lobby...")
                task.wait(1)
                
                for attempt = 1, MAX_RETRIES do
                    local success, err = pcall(function()
                        Services.TeleportService:Teleport(17282336195, LocalPlayer)
                    end)
                    
                    if success then
                        print(string.format("✓ Successfully returned to lobby (attempt %d/%d)", attempt, MAX_RETRIES))
                        Rayfield:Notify({
                            Title = "Auto Vote",
                            Content = "Returned to lobby",
                            Duration = 3
                        })
                        return
                    else
                        warn(string.format("❌ Failed to return to lobby (attempt %d/%d): %s", attempt, MAX_RETRIES, tostring(err)))
                        
                        if attempt < MAX_RETRIES then
                            print(string.format("⏳ Retrying in %d seconds...", RETRY_DELAY))
                            task.wait(RETRY_DELAY)
                        else
                            Rayfield:Notify({
                                Title = "Auto Vote Failed",
                                Content = "Failed to return to lobby after " .. MAX_RETRIES .. " attempts",
                                Duration = 5
                            })
                        end
                    end
                end
            end
        end)
    end)
end

task.spawn(function()
    task.wait(1)
    
    local unitsWithAbilities = getUnitsWithAbilities()
    UnitDropdown:Refresh(unitsWithAbilities)
    print("Loaded " .. #unitsWithAbilities .. " units with abilities into dropdown")
end)


task.spawn(function()
    local ABILITY_CHECK_INTERVAL = 0.5
    
    while true do
        task.wait(ABILITY_CHECK_INTERVAL)
        
        if State.AutoUseAbility and not isInLobby() then
            if State.SelectedUnitsForAbility and #State.SelectedUnitsForAbility > 0 and
               State.SelectedAbilitiesToUse and #State.SelectedAbilitiesToUse > 0 then
                
                local SkillsModule = Services.ReplicatedStorage:WaitForChild("Module"):WaitForChild("Skills")
                local SkillsData = require(SkillsModule)
                
                for _, unitName in ipairs(State.SelectedUnitsForAbility) do
                    local skillData = SkillsData[unitName]
                    if skillData then
                        for _, abilityName in ipairs(State.SelectedAbilitiesToUse) do
                            -- Handle multi-skill units
                            if skillData.Skill1 or skillData.Skill2 then
                                if abilityName == skillData.Skill1 or abilityName == skillData.Skill2 then
                                    local success = findAndUseUnitAbility(unitName, abilityName)
                                    if success then
                                        print(string.format("✓ Auto-used: %s - %s", unitName, abilityName))
                                    end
                                end
                            -- Handle single-skill units
                            elseif abilityName == "Default Ability" then
                                local success = findAndUseUnitAbility(unitName, nil)
                                if success then
                                    print(string.format("✓ Auto-used: %s", unitName))
                                end
                            end
                            
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
        
        -- Keep Sukuna abilities section as-is since it's separate
        if State.AutoUseAbilitySukuna and not isInLobby() then
            if State.SelectedSukunaSkills and #State.SelectedSukunaSkills > 0 then
                for _, skillName in ipairs(State.SelectedSukunaSkills) do
                    local success = findAndUseUnitAbility("Sukuna", skillName)
                    
                    if success then
                        print(string.format("✓ Auto-used Sukuna: %s", skillName))
                    end
                    
                    task.wait(0.1)
                end
            end
        end
    end
end)

local function monitorStagesChallengeGUI()
    if isInLobby() then return end
    local playerGui = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
    local stagesChallenge = playerGui:WaitForChild("StagesChallenge")
    
    -- Check if GUI is already enabled when script starts
    if stagesChallenge.Enabled and State.AutoPickCard and State.AutoPickCardSelected then
        print("StagesChallenge GUI already open, picking card")
        task.wait(0.1)
        
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
                :WaitForChild("Events"):WaitForChild("StageChallenge")
                :FireServer(State.AutoPickCardSelected)
        end)
    end
    
    -- Monitor for future changes
    stagesChallenge:GetPropertyChangedSignal("Enabled"):Connect(function()
        if stagesChallenge.Enabled and State.AutoPickCard and State.AutoPickCardSelected then
            print("StagesChallenge GUI opened, picking card")
            task.wait(0.1)
            
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("PlayMode")
                    :WaitForChild("Events"):WaitForChild("StageChallenge")
                    :FireServer(State.AutoPickCardSelected)
            end)
        end
    end)
end

-- Initialize the GUI monitor

if not isInLobby() then
    Services.Workspace.GameSettings.GameStarted.Changed:Connect(checkGameStarted)
end

ensureMacroFolders()
loadAllMacros()
setupGameTimeTracking()
if not isInLobby() then 
checkInitialGameState()
end
    if not isInLobby() then 
        task.spawn(monitorWavesForAutoSell)
        task.spawn(monitorWavesForAutoSellFarm)
    end

Rayfield:LoadConfiguration()
Rayfield:SetVisibility(false)

Rayfield:TopNotify({
    Title = "UI is hidden",
    Content = "The UI has automatically closed. If you want to enable visibility, click the 'Show' button.",
    Image = "eye-off", -- Lucide icon name
    IconColor = Color3.fromRGB(100, 150, 255),
    Duration = 5
})

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RayfieldToggle"
screenGui.Parent = Services.Players.LocalPlayer.PlayerGui
screenGui.ResetOnSpawn = false

-- Create the circular image button
local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "ToggleButton"
toggleButton.Parent = screenGui
toggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
toggleButton.BorderSizePixel = 0
toggleButton.Position = UDim2.new(0, 50, 0, 50)
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Image = "rbxassetid://139436994731049" -- Put your logo image ID here like "rbxassetid://123456789"
toggleButton.ScaleType = Enum.ScaleType.Fit

-- Make it circular
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = toggleButton

-- Rayfield visibility state
local rayfieldVisible = true

-- Toggle function
local function toggleRayfield()
    rayfieldVisible = not rayfieldVisible
    
    if Rayfield then
        Rayfield:SetVisibility(rayfieldVisible)
    end
end

-- Dragging variables
local dragging = false
local dragStart = nil
local startPos = nil

-- Mouse input handling
toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = toggleButton.Position
        
        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                connection:Disconnect()
            end
        end)
    end
end)

toggleButton.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        toggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Click to toggle
local clickStartPos = nil
toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        clickStartPos = input.Position
    end
end)

toggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if clickStartPos then
            local deltaMove = input.Position - clickStartPos
            local moveDistance = math.sqrt(deltaMove.X^2 + deltaMove.Y^2)
            
            if moveDistance < 10 then
                toggleRayfield()
            end
        end
    end
end)

task.spawn(function()
    task.wait(1)
    monitorStagesChallengeGUI()
end)

-- Restore macro selection and playback state after config loads
task.spawn(function()
    task.wait(2)
    
    local savedMacroName = Rayfield.Flags["MacroDropdown"]
    if type(savedMacroName) == "table" then
        savedMacroName = savedMacroName[1]
    end
    
    if savedMacroName and savedMacroName ~= "" and type(savedMacroName) == "string" then
        currentMacroName = savedMacroName
        local loadedMacro = loadMacroFromFile(currentMacroName)
        if loadedMacro then
            macro = loadedMacro
            macroManager[currentMacroName] = loadedMacro
            print("Successfully loaded saved macro:", currentMacroName, "with", #macro, "actions")
        end
    end
    
    refreshMacroDropdown()
    
    -- Restore playback if it was enabled
local savedPlaybackState = Rayfield.Flags["PlayBackMacro"]
    if savedPlaybackState == true and currentMacroName and currentMacroName ~= "" and macro and #macro > 0 then
        -- Double check we're not already running
        if not playbackLoopRunning then
            isAutoLoopEnabled = true
            
            task.spawn(autoPlaybackLoop)
            MacroStatusLabel:Set("Status: Playback restored - waiting for game")
            
            Rayfield:Notify({
                Title = "Playback Restored",
                Content = string.format("Auto-playing: %s", currentMacroName),
                Duration = 3
            })
            
            print(string.format("Playback restored: %s (%d actions)", currentMacroName, #macro))
        else
            print("Playback loop already running, skipping restore")
        end
    end
end)
