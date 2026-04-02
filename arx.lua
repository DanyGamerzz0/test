local Services = {
    HttpService = game:GetService("HttpService"),
    Players = game:GetService("Players"),
    TeleportService = game:GetService("TeleportService"),
    Lighting = game:GetService("Lighting"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    VIRTUAL_USER = game:GetService("VirtualUser"),
}

local Remotes = {}
do
    local RS = Services.ReplicatedStorage
    Remotes.GameEnd = RS:WaitForChild("Remote"):WaitForChild("Client"):WaitForChild("UI"):WaitForChild("GameEndedUI")
    Remotes.Code = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Lobby"):WaitForChild("Code")
    Remotes.StartGame = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("OnGame"):WaitForChild("Voting"):WaitForChild("VotePlaying")
    Remotes.Merchant = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("Merchant")
    Remotes.RaidMerchant = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("Raid_Shop")
    Remotes.RaidMerchantCSW = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("RaidCSW_Shop")
    Remotes.RiftMerchant = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("RiftStormExchange")
    Remotes.SwarmMerchant = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("FallShopExchange")
    Remotes.PlayEvent = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event")
    Remotes.SettingEvent = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Settings"):WaitForChild("Setting_Event")
    Remotes.RetryEvent = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("OnGame"):WaitForChild("Voting"):WaitForChild("VoteRetry")
    Remotes.GameEndedUI = RS:WaitForChild("Remote"):WaitForChild("Client"):WaitForChild("UI"):WaitForChild("GameEndedUI")
    Remotes.UpgradeUnit = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("Upgrade")
    Remotes.NextEvent = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("OnGame"):WaitForChild("Voting"):WaitForChild("VoteNext")
    Remotes.SelectWay = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("SelectWay")
    Remotes.SellRemote = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("Sell")
    Remotes.ApplyCurseRemote = RS:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gambling"):WaitForChild("ApplyCurse")
end

local GameObjects = {
    challengeFolder = Services.ReplicatedStorage:WaitForChild("Gameplay"):WaitForChild("Game"):WaitForChild("Challenge"),
    AFKChamberUI = Services.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("AFKChamber"),
    STAGE_MODULES_FOLDER = Services.ReplicatedStorage.Shared.Info.GameWorld.Levels,
}
GameObjects.GetData = require(Services.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GetData"))
GameObjects.getUnitFolder = GameObjects.GetData.GetUnitFolder
GameObjects.itemsFolder = GameObjects.challengeFolder:WaitForChild("Items")
local GearData = require(Services.ReplicatedStorage.Shared.Info.CraftingRecipes.Gears)

local Config = {
    DISCORD_USER_ID = "",
    chapters = {"Chapter1", "Chapter2", "Chapter3", "Chapter4", "Chapter5", "Chapter6", "Chapter7", "Chapter8", "Chapter9", "Chapter10"},
    difficulties = {"Normal", "Hard", "Nightmare"},
    UPGRADE_COOLDOWN = 0.5,
    maxRetryAttempts = 20,
    unitLevelCaps = {9, 9, 9, 9, 9, 9},
    unitDeployLevelCaps = {0, 0, 0, 0, 0, 0},
    unitReDeployLevel = {9, 9, 9, 9, 9, 9},
    oldbartext = Services.Players.LocalPlayer.PlayerGui.HUD.ExpBar.Numbers.Text,
}

local State = {
    enableBlackScreen = false,
    enableAutoExecute = false,
    autoReconnectEnabled = false,
    enableAutoSummon = false,
    deleteEntities = false,
    AutoFarmEnabled = false,
    currentFarmingStage = false,
    AutoOpenBorosEnabled = false,
    AutoSwarmEventEnabled = false,
    SendFinishedFarmingGearWebhook = false,
    SendFinishedTraitRerollingWebhook = false,
    autoAdventureModeEnabled = false,
    currentWave = 0,
    lastProcessedWave = 0,
    isMonitoring = false,
    selectedGears = {},
    craftAmounts = {},
    currentlyFarming = false,
    farmingQueue = {},
    playerInventory = {},
    totalMaterialsNeeded = {},
    stageAnalysis = {},
    AutoSummonBannerSelected = nil,
    AutoRerollEnabled = false,
    selectedTraits = {},
    rollOnlyDoubleTraits = false,
    pendingChallengeReturn = false,
    AutoFailSafeEnabled = false,
    autoPlayDelayActive = false,
    AutoPlayDelayNumber = 0,
    AutoFailSafeNumber = 0,
    hasSentWebhook = false,
    portalUsed = false,
    isAutoJoining = false,
    hasNewRewards = false,
    gameRunning = false,
    hasGameEnded = false,
    retryAttempted = false,
    NextAttempted = false,
    stageStartTime = nil,
    skipCooldownSlots = {},
    lastDeploymentTimes = {},
    startingInventory = {},
    unitNameSet = {},
    selectedPortals = {},
    selectedRaidStages = {},
    AutoSellUnitChoice = {},
    AutoDungeonDifficultySelector = "",
    DelayAutoUltimate = 0,
    autoBossEventEnabled = false,
    autoJoinRaid = false,
    autoJoinEnabled = false,
    autoStartEnabled = false,
    autoRetryEnabled = false,
    autoReturnEnabled = false,
    autoDisableEndUI = false,
    autoNextEnabled = false,
    autoChallengeEnabled = false,
    autoPortalEnabled = false,
    autoClaimBP = false,
    AutoClaimQuests = false,
    AutoClaimMilestones = false,
    AutoPurchaseMerchant = false,
    AutoPurchaseSwarmEvent = false,
    challengeAutoReturnEnabled = false,
    autoInfinityCastleEnabled = false,
    autoUpgradeEnabled = false,
    autoAfkTeleportEnabled = false,
    AutoUltimateEnabled = false,
    AutoSellRarities = false,
    DisableSummonUI = false,
    streamerModeEnabled = false,
    enableLowPerformanceMode = false,
    SendStageCompletedWebhook = false,
    AntiAfkEnabled = false,
    AntiAfkKickEnabled = false,
    autoDungeonEnabled = false,
    AutoSelectSpeed = false,
    AutoReDeployEnabled = false,
    SelectedSpeedValue = {},
    currentSlot = 1,
    slotLastFailTime = {},
    slotExists = {},
    matchResult = "Unknown",
    storedChallengeSerial = nil,
    selectedWorld = nil,
    selectedChapter = nil,
    selectedDifficulty = nil,
    infinityCastleTask = nil,
    currentPath = nil,
    upgradeMethod = "Left to right until max",
    upgradeTask = nil,
    ultimateTask = nil,
    currentUpgradeSlot = 1,
    currentRetryAttempt = 0,
    selectedChallengeWorlds = {},
    autoJoinInfinityCastleEnabled = false,
    SelectedRaritiesToSell = {},
    enableDeleteMap = false,
    autoPlayEnabled = false,
    autoCalamityEnabled = false,
    autoBountyHuntInvasionEnabled = false,
    autoBossAttackEnabled = false,
    RestartGameOnWave = 0,
    EndGameOnWave = 0,
}

local Data = {
    selectedRawStages = {},
    MerchantPurchaseTable = {},
    SwarmEventPurchaseTable = {},
    rangerStages = {},
    wantedRewards = {},
    capturedRewards = {},
    availableStories = {},
    availableRangerStages = {},
    availableRaids = {},
    storyData = {},
    raidData = {},
    worldDisplayNameMap = {},
    selectedChallengeWorlds = {},
}

local autoSummonActive = false
local initialUnits = {}
local summonTask = nil

local script_version = "V0.2"

local ValidWebhook

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/DanyGamerzz0/Rayfield-Custom/refs/heads/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "LixHub - Anime Rangers X",
   Icon = 0,
   LoadingTitle = "Loading for Anime Rangers X",
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
      FileName = "Lixhub_ARX"
   },
   Discord = {
      Enabled = true,
      Invite = "cYKnXE2Nf8",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "LixHub - ARX - Free",
      Subtitle = "LixHub - Key System",
      Note = "Free key available in the discord https://discord.gg/cYKnXE2Nf8",
      FileName = "LixHub_Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"0xLIXHUB"}
   }
})

--// TABS //--

local LobbyTab = Window:CreateTab("Lobby", "tv")
local ShopTab = Window:CreateTab("Shop", "shopping-cart")
local JoinerTab = Window:CreateTab("Joiner", "plug-zap")
local GameTab = Window:CreateTab("Game", "gamepad-2")
local AutoPlayTab = Window:CreateTab("AutoPlay", "joystick")
local WebhookTab = Window:CreateTab("Webhook", "bluetooth")

--// FUNCTIONS //--

local function notify(title, content, duration)
    Rayfield:Notify({
        Title = title or "Notice",
        Content = content or "No message.",
        Duration = duration or 5,
        Image = "info",
    })
end

local function isInLobby()
    return workspace:FindFirstChild("Lobby") ~= nil
end

local function enableDeleteMap()
    if isInLobby() then return end
    if State.enableDeleteMap then
        if Services.Workspace:FindFirstChild("Building"):FindFirstChild("Map") then
            Services.Workspace:FindFirstChild("Building"):FindFirstChild("Map"):Destroy()
            Services.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
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
        toggleButtonFrame.Size = UDim2.new(0, 170, 0, 44)
        toggleButtonFrame.Position = UDim2.new(0.5, -60, 1, -60)
        toggleButtonFrame.BackgroundColor3 = Color3.fromRGB(57, 57, 57)
        toggleButtonFrame.BackgroundTransparency = 0.5
        toggleButtonFrame.Parent = screenGui
        toggleButtonFrame.ZIndex = 1000000

        local toggleButtonFrameUICorner = Instance.new("UICorner")
        toggleButtonFrameUICorner.CornerRadius = UDim.new(1, 0)
        toggleButtonFrameUICorner.Parent = toggleButtonFrame

        local toggleButtonFrameTitle = Instance.new("TextLabel")
        toggleButtonFrameTitle.ZIndex = math.huge
        toggleButtonFrameTitle.AnchorPoint = Vector2.new(0.5, 0.5)
        toggleButtonFrameTitle.BackgroundTransparency = 1
        toggleButtonFrameTitle.Position = UDim2.new(0.5, 0, 0.5, 0)
        toggleButtonFrameTitle.Size = UDim2.new(1, 0, 1, 0)
        toggleButtonFrameTitle.Text = "Toggle Screen"
        toggleButtonFrameTitle.TextSize = 15
        toggleButtonFrameTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButtonFrameTitle.Parent = toggleButtonFrame

        local toggleButtonFrameTitleStroke = Instance.new("UIStroke")
        toggleButtonFrameTitleStroke.Parent = toggleButtonFrameTitle

        local toggleButtonFrameButton = Instance.new("TextButton")
        toggleButtonFrameButton.AnchorPoint = Vector2.new(0.5, 0.5)
        toggleButtonFrameButton.BackgroundTransparency = 1
        toggleButtonFrameButton.Size = UDim2.new(1, 0, 1, 0)
        toggleButtonFrameButton.Position = UDim2.new(0.5, 0, 0.5, 0)
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
        Remotes.SettingEvent:FireServer(unpack({"Abilities VFX", false}))
        Remotes.SettingEvent:FireServer(unpack({"Hide Cosmetic", true}))
        Remotes.SettingEvent:FireServer(unpack({"Low Graphic Quality", true}))
        Remotes.SettingEvent:FireServer(unpack({"HeadBar", false}))
        Remotes.SettingEvent:FireServer(unpack({"Display Players Units", false}))
        Remotes.SettingEvent:FireServer(unpack({"DisibleGachaChat", true}))
        Remotes.SettingEvent:FireServer(unpack({"DisibleDamageText", true}))
        Services.Players.LocalPlayer.PlayerGui.HUD.InGame.Main.BOTTOM.Visible = false
        Services.Players.LocalPlayer.PlayerGui.Notification.Enabled = false
    else
        Services.Players.LocalPlayer.PlayerGui.HUD.InGame.Main.BOTTOM.Visible = true
        Services.Players.LocalPlayer.PlayerGui.Notification.Enabled = true
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

local function GetAllLevelModules()
    local success, modules = pcall(function()
        local levelsFolder = Services.ReplicatedStorage.Shared.Info.GameWorld.Levels
        local levelModules = {}

        for _, moduleScript in pairs(levelsFolder:GetChildren()) do
            if moduleScript:IsA("ModuleScript") then
                local ok, moduleData = pcall(function()
                    return require(moduleScript)
                end)

                if ok and moduleData then
                    levelModules[moduleScript.Name] = moduleData
                else
                    warn("Failed to require:", moduleScript.Name)
                end
            end
        end

        return levelModules
    end)

    return success and modules or {}
end

local function GetAllGearNames()
    local gearNames = {}
    for gearName, _ in pairs(GearData) do
        table.insert(gearNames, gearName)
    end
    table.sort(gearNames)
    return gearNames
end

local function GetPlayerInventory()
    local success, inventory = pcall(function()
        local playerData = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name]
        local items = playerData:FindFirstChild("Items")

        if not items then
            return {}
        end

        local currentInventory = {}
        for _, item in pairs(items:GetChildren()) do
            if item:IsA("Folder") then
                currentInventory[item.Name] = item.Amount.Value
            end
        end
        return currentInventory
    end)
    return success and inventory or {}
end

local function CalculateTotalMaterialsNeeded()
    local totalNeeded = {}

    for gearName, amount in pairs(State.craftAmounts) do
        if amount > 0 and GearData[gearName] then
            local requirements = GearData[gearName].Requirement
            for materialName, requiredAmount in pairs(requirements) do
                totalNeeded[materialName] = (totalNeeded[materialName] or 0) + (requiredAmount * amount)
            end
        end
    end

    State.totalMaterialsNeeded = totalNeeded
    return totalNeeded
end

local function normalizeName(name)
    return string.lower((name or ""):gsub("^%s*(.-)%s*$", "%1"))
end

local function FindMaterialSource(materialName)
    local allLevels = GetAllLevelModules()
    local sources = {}
    local searchName = normalizeName(materialName)

    for moduleName, moduleData in pairs(allLevels) do
        for worldName, worldData in pairs(moduleData) do
            for chapterName, chapterData in pairs(worldData) do
                if type(chapterData) == "table" and chapterData.Items then
                    for _, itemDrop in pairs(chapterData.Items) do
                        if normalizeName(itemDrop.Name) == searchName then
                            table.insert(sources, {
                                module = moduleName,
                                world = worldName,
                                chapter = chapterName,
                                chapterName = chapterData.Name or chapterName or "UnknownChapter",
                                readableName = chapterData.Name or chapterName,
                                dropRate = itemDrop.DropRate,
                                minDrop = itemDrop.MinDrop,
                                maxDrop = itemDrop.MaxDrop,
                                fullPath = string.format(
                                    "%s -> %s",
                                    moduleName,
                                    chapterData.Name or chapterName
                                )
                            })
                        end
                    end
                end
            end
        end
    end

    return sources
end

local function AnalyzeRequiredStages()
    if #State.selectedGears == 0 then
        notify("Stage Analysis", "No gears selected!")
        return
    end

    print("=== STAGE ANALYSIS FOR SELECTED GEARS ===")

    local totalNeeded = CalculateTotalMaterialsNeeded()
    local inventory = GetPlayerInventory()

    local stagesToPlay = {}
    local materialSources = {}

    print("\nMaterials needed:")
    for materialName, needed in pairs(totalNeeded) do
        local current = inventory[materialName] or 0
        local deficit = math.max(0, needed - current)

        print(string.format("  %s: %d needed, %d current, %d deficit",
            materialName, needed, current, deficit))

        if deficit > 0 then
            local sources = FindMaterialSource(materialName)

            if #sources > 0 then
                materialSources[materialName] = sources
                print(string.format("    Sources found for %s:", materialName))

                for i, source in ipairs(sources) do
                    local avgDrop = (source.minDrop + source.maxDrop) / 2
                    local dropChance = source.dropRate / 100
                    local expectedPerRun = avgDrop * dropChance
                    local estimatedRuns = math.ceil(deficit / expectedPerRun)

                    print(string.format("      %d. %s (%.1f%% drop, avg %.1f per drop, ~%d runs needed)",
                        i, source.fullPath, source.dropRate, avgDrop, estimatedRuns))

                    local stageKey = source.fullPath
                    if not stagesToPlay[stageKey] then
                        stagesToPlay[stageKey] = {
                            module = source.module,
                            world = source.world,
                            chapter = source.chapter,
                            materials = {},
                            totalEstimatedRuns = 0
                        }
                    end

                    stagesToPlay[stageKey].materials[materialName] = {
                        needed = deficit,
                        estimatedRuns = estimatedRuns,
                        dropRate = source.dropRate,
                        avgDrop = avgDrop
                    }

                    stagesToPlay[stageKey].totalEstimatedRuns = math.max(
                        stagesToPlay[stageKey].totalEstimatedRuns,
                        estimatedRuns
                    )
                end
            else
                print(string.format("    No sources found for %s!", materialName))
            end
        else
            print(string.format("    Have enough %s!", materialName))
        end
    end

    print("\n=== STAGES TO PLAY ===")
    if next(stagesToPlay) == nil then
        print("No stages need to be played! You have all required materials.")
    else
        local stageList = {}
        for stageName, stageInfo in pairs(stagesToPlay) do
            table.insert(stageList, {
                name = stageName,
                info = stageInfo
            })
        end

        table.sort(stageList, function(a, b)
            return a.info.totalEstimatedRuns < b.info.totalEstimatedRuns
        end)

        for i, stage in ipairs(stageList) do
            print(string.format("%d. %s (~%d runs)",
                i, stage.name, stage.info.totalEstimatedRuns))

            for materialName, matInfo in pairs(stage.info.materials) do
                print(string.format("    - %s: need %d (%.1f%% drop, ~%d runs)",
                    materialName, matInfo.needed, matInfo.dropRate, matInfo.estimatedRuns))
            end
        end

        print(string.format("\nSUMMARY: Need to play %d different stages", #stageList))

        print("\nGEAR BREAKDOWN:")
        for _, gearName in ipairs(State.selectedGears) do
            local amount = State.craftAmounts[gearName] or 1
            if amount > 0 then
                print(string.format("  %s x%d:", gearName, amount))
                local requirements = GearData[gearName].Requirement
                for materialName, requiredPerCraft in pairs(requirements) do
                    local totalRequired = requiredPerCraft * amount
                    print(string.format("    - %s: %d (%d per craft)",
                        materialName, totalRequired, requiredPerCraft))
                end
            end
        end
    end

    print("=== END STAGE ANALYSIS ===\n")

    State.stageAnalysis = {
        stagesToPlay = stagesToPlay,
        materialSources = materialSources,
        totalMaterialsNeeded = totalNeeded
    }

    local stageCount = 0
    for _ in pairs(stagesToPlay) do
        stageCount = stageCount + 1
    end

    notify("Stage Analysis", string.format("Analysis complete! Need to play %d stages. Check console for details.", stageCount))
end

local function fetchStoryData()
    Data.storyData = {}

    for _, moduleScript in ipairs(Services.ReplicatedStorage.Shared.Info.GameWorld:WaitForChild("World"):GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            local success, data = pcall(function()
                return require(moduleScript)
            end)

            if success and typeof(data) == "table" then
                for key, storyTable in pairs(data) do
                    if typeof(storyTable) == "table" and storyTable.StoryAble == true then
                        if storyTable.Name and storyTable.Ani_Names then
                            table.insert(Data.storyData, {
                                SeriesName = storyTable.Name,
                                InternalName = storyTable.Ani_Names,
                                ModuleName = moduleScript.Name,
                                Key = key
                            })
                        end
                    end
                end
            else
                print("Error loading " .. moduleScript.Name)
            end
        end
    end

    return Data.storyData
end

local function fetchRaidData()
    Data.raidData = {}

    for _, moduleScript in ipairs(Services.ReplicatedStorage.Shared.Info.GameWorld:WaitForChild("World"):GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            local success, data = pcall(function()
                return require(moduleScript)
            end)

            if success and typeof(data) == "table" then
                for key, raidTable in pairs(data) do
                    if typeof(raidTable) == "table" and raidTable.IsRaid == true then
                        if raidTable.Name and raidTable.Levels then
                            local displayStages = {}
                            local internalMap = {}

                            for index, stage in ipairs(raidTable.Levels) do
                                if stage.id then
                                    local displayName = string.format("%s - Chapter %d", raidTable.Name, index)
                                    table.insert(displayStages, displayName)
                                    internalMap[displayName] = stage.id
                                end
                            end

                            table.insert(Data.raidData, {
                                SeriesName = raidTable.Name,
                                DisplayStages = displayStages,
                                InternalStages = internalMap,
                                ModuleName = moduleScript.Name,
                                Key = key
                            })
                        end
                    end
                end
            else
                print("Error loading " .. moduleScript.Name)
            end
        end
    end
    return Data.raidData
end

local function fetchRangerStageData(storyData)
    local worldPriority = {
        ["OnePiece"] = 1,
        ["Namek"] = 2,
        ["DemonSlayer"] = 3,
        ["Naruto"] = 4,
        ["OPM"] = 5,
        ["TokyoGhoul"] = 6,
        ["JojoPart1"] = 7,
        ["SoulSociety"] = 8,
    }

    local worldDisplayNames = {}
    for _, story in ipairs(storyData) do
        worldDisplayNames[story.ModuleName] = story.SeriesName
    end

    local worldStages = {}

    for _, moduleScript in ipairs(Services.ReplicatedStorage.Shared.Info.GameWorld:WaitForChild("Levels"):GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            local success, data = pcall(function()
                return require(moduleScript)
            end)

            if success and typeof(data) == "table" then
                for seriesName, chapters in pairs(data) do
                    if typeof(chapters) == "table" then
                        for chapterKey, chapterData in pairs(chapters) do
                            if typeof(chapterData) == "table" and chapterData.Wave then
                                if string.find(chapterData.Wave, "RangerStage") then
                                    local worldName = chapterData.World or "UnknownWorld"
                                    worldStages[worldName] = worldStages[worldName] or {}
                                    local displayWorldName = worldDisplayNames[worldName] or worldName

                                    table.insert(worldStages[worldName], {
                                        Series = seriesName,
                                        Chapter = chapterKey,
                                        Wave = chapterData.Wave,
                                        LayoutOrder = chapterData.LayoutOrder or math.huge,
                                        DisplayName = displayWorldName .. " - " .. (chapterData.Wave:match("RangerStage(%d+)") or chapterData.Wave)
                                    })
                                end
                            end
                        end
                    end
                end
            else
                warn("Error loading module: " .. moduleScript.Name)
            end
        end
    end

    local worldOrder = {}
    local rangerStages = {}

    for worldName, stages in pairs(worldStages) do
        table.sort(stages, function(a, b)
            return a.LayoutOrder < b.LayoutOrder
        end)

        local priority = worldPriority[worldName] or 1e6
        table.insert(worldOrder, {World = worldName, Priority = priority, Stages = stages})
    end

    table.sort(worldOrder, function(a, b)
        return a.Priority < b.Priority
    end)

    for _, worldInfo in ipairs(worldOrder) do
        local worldName = worldInfo.World
        for _, stage in ipairs(worldInfo.Stages) do
            table.insert(rangerStages, {
                RawName = stage.Wave,
                DisplayName = stage.DisplayName,
                World = worldName,
                Series = stage.Series,
                Chapter = stage.Chapter,
                LayoutOrder = stage.LayoutOrder
            })
        end
    end

    return rangerStages
end

local function getUnitNameFromSlot(slotNumber)
    local success, unitInstance = pcall(function()
        return Services.Players.LocalPlayer.PlayerGui.UnitsLoadout.Main["UnitLoadout" .. slotNumber].Frame.UnitFrame.Info.Folder.Value
    end)

    if success and unitInstance then
        return typeof(unitInstance) == "Instance" and unitInstance.Name or tostring(unitInstance)
    end

    return nil
end

local function getOrderedUnits()
    local units = {}
    for i = 1, 6 do
        local success, unitName = pcall(function()
            local loadout = Services.Players.LocalPlayer.PlayerGui.UnitsLoadout.Main["UnitLoadout" .. i]
            local unitFolder = loadout.Frame.UnitFrame.Info.Folder.Value
            return unitFolder and unitFolder.Name or nil
        end)

        if success and unitName then
            table.insert(units, string.format("%d - %s", i, unitName))
        else
            table.insert(units, string.format("%d Empty", i))
        end
    end
    return table.concat(units, "\n")
end

local function sendWebhook(messageType, rewards, clearTime, matchResult, gearData)
    if not ValidWebhook then return end

    local data
    if messageType == "test" then
        data = {
            username = "LixHub Bot",
            content = string.format("<@%s>", Config.DISCORD_USER_ID or "000000000000000000"),
            embeds = {{
                title = "LixHub Notification",
                description = "Test webhook sent successfully",
                color = 0x5865F2,
                footer = { text = "LixHub" },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
    elseif messageType == "gear" then
        local plrlevel = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.Level.Value or ""
        local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")

        local materialsSummary = {}
        local inventory = GetPlayerInventory()

        for materialName, needed in pairs(gearData.materialsNeeded) do
            local current = inventory[materialName] or 0
            table.insert(materialsSummary, string.format("- %s: %d/%d", materialName, current, needed))
        end

        local gearList = {}
        for gearName, amount in pairs(gearData.craftAmounts) do
            if amount > 0 then
                table.insert(gearList, string.format("- %s: %dx", gearName, amount))
            end
        end

        local pingText = string.format("<@%s> GEAR MATERIALS READY!", Config.DISCORD_USER_ID)

        data = {
            username = "LixHub",
            content = pingText,
            embeds = {{
                title = "Gear Farm Complete",
                description = pingText .. "\nAll materials have been farmed successfully!",
                color = 0x00FF00,
                fields = {
                    { name = "Player", value = "||" .. Services.Players.LocalPlayer.Name .. " [" .. plrlevel .. "]||", inline = true },
                    { name = "Gears Ready to Craft", value = table.concat(gearList, "\n"), inline = false },
                    { name = "Materials Collected", value = table.concat(materialsSummary, "\n"), inline = false },
                },
                footer = { text = "LixHub - discord.gg/cYKnXE2Nf8"},
                timestamp = timestamp
            }}
        }
    elseif messageType == "stage" then
        local RewardsUI = Services.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("HUD"):WaitForChild("InGame"):WaitForChild("Main"):WaitForChild("GameInfo")
        local stageName = RewardsUI and RewardsUI:FindFirstChild("Stage") and RewardsUI.Stage.Label.Text or "Unknown Stage"
        local gameMode = RewardsUI and RewardsUI:FindFirstChild("Gamemode") and RewardsUI.Gamemode.Label.Text or "Unknown Time"
        local isWin = matchResult == "Victory"
        local plrlevel = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.Level.Value or ""

        local rewardsText = rewards
        local detectedUnits = {}
        local shouldPing = false

        if #detectedUnits > 1 then return end

        local pingText = shouldPing and string.format("<@%s> SECRET UNIT OBTAINED!", Config.DISCORD_USER_ID) or ""

        local stageResult = stageName .. " (" .. gameMode .. ")" .. " - " .. matchResult
        local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")

        local orderedUnits = getOrderedUnits()

        data = {
            username = "LixHub",
            content = shouldPing and pingText or nil,
            embeds = {{
                title = shouldPing and "Unit Drop!" or "Stage Finished",
                description = shouldPing and (pingText .. "\n" .. stageResult) or stageResult,
                color = shouldPing and 0xFFD700 or (isWin and 0x57F287 or 0xED4245),
                fields = {
                    { name = "Player", value = "||" .. Services.Players.LocalPlayer.Name .. " [" .. plrlevel .. "]||", inline = true },
                    { name = isWin and "Won in:" or "Lost after:", value = clearTime, inline = true },
                    { name = "Rewards", value = rewardsText, inline = false },
                    { name = "Units Loadout", value = orderedUnits, inline = false },
                    shouldPing and { name = "Units Obtained", value = table.concat(detectedUnits, ", "), inline = false } or nil,
                },
                footer = { text = "discord.gg/cYKnXE2Nf8" },
                timestamp = timestamp
            }}
        }

        local filteredFields = {}
        for _, field in ipairs(data.embeds[1].fields) do if field then table.insert(filteredFields, field) end end
        data.embeds[1].fields = filteredFields
    else
        return
    end

    local payload = Services.HttpService:JSONEncode(data)
    local requestFunc = (syn and syn.request) or (http and http.request) or request

    if requestFunc then
        local success, result = pcall(function()
            return requestFunc({
                Url = ValidWebhook,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = payload
            })
        end)

        if success then
            notify("Webhook", "Webhook sent successfully.", 2)
        else
            warn("Webhook failed to send: " .. tostring(result))
            notify("Webhook Error", tostring(result))
        end
    else
        warn("No compatible HTTP request method found.")
        notify("Webhook Error", "No HTTP request method available.")
    end
end

local function getBestPath()
    local function countPartsOnPath(folder, pathFolder)
        local count = 0
        for _, part in ipairs(folder:GetChildren()) do
            if part:IsA("BasePart") and part:FindFirstChildOfClass("Humanoid") then
                local distToStart = (part.Position - pathFolder["1"].Position).Magnitude
                local distToEnd = (part.Position - pathFolder["2"].Position).Magnitude
                local totalDist = (pathFolder["1"].Position - pathFolder["2"].Position).Magnitude
                if distToStart + distToEnd <= totalDist + 15 then
                    count = count + 1
                end
            end
        end
        return count
    end

    local bestPath, lowestUnits = nil, math.huge
    for i = 1, 3 do
        local pathName = "P" .. i
        local pathFolder = Services.Workspace:WaitForChild("WayPoint"):FindFirstChild(pathName)
        if pathFolder then
            local unitCount = countPartsOnPath(Services.Workspace.Agent.UnitT, pathFolder)
            local enemyCount = countPartsOnPath(Services.Workspace.Agent.EnemyT, pathFolder)
            if enemyCount > 0 and unitCount < lowestUnits then
                lowestUnits = unitCount
                bestPath = i
            end
        end
    end
    return bestPath
end

local function startInfinityCastleLogic()
    if State.infinityCastleTask then task.cancel(State.infinityCastleTask) end
    State.infinityCastleTask = task.spawn(function()
        while State.autoInfinityCastleEnabled do
            local success, error = pcall(function()
                local bestPath = getBestPath()
                if bestPath and bestPath ~= State.currentPath then
                    notify("Switching to path: ", bestPath)
                    State.currentPath = bestPath
                    Remotes.SelectWay:FireServer(bestPath)
                end
            end)
            if not success then warn("Infinity Castle error:", error) end
            task.wait(2.5)
        end
    end)
end

local function stopInfinityCastleLogic()
    if State.infinityCastleTask then
        task.cancel(State.infinityCastleTask)
        State.infinityCastleTask = nil
    end
    State.currentPath = nil
end

local function isWantedChallengeRewardPresent()
    for _, reward in ipairs(Data.wantedRewards) do
        local value = GameObjects.itemsFolder:FindFirstChild(reward)
        if value and value:IsA("BoolValue") then
            return true, reward
        end
    end
    return false, nil
end

local function openBorosCapsules(amount)
    if amount <= 0 then return end

    local success, err = pcall(function()
        local playerData = Services.ReplicatedStorage:WaitForChild("Player_Data"):WaitForChild(Services.Players.LocalPlayer.Name)
        local borosCapsule = playerData:WaitForChild("Items"):WaitForChild("Borus Capsule")

        local args = {
            borosCapsule,
            {
                SummonAmount = amount
            }
        }

        Services.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Lobby"):WaitForChild("ItemUse"):FireServer(unpack(args))

        notify("Auto Boros", string.format("Opened %d Boros Capsule%s!", amount, amount == 1 and "" or "s"))
    end)

    if not success then
        warn("[AUTO BOROS] Failed to open capsules:", err)
    end
end

local function startAutoBorosCapsule()
    task.spawn(function()
        local success, err = pcall(function()
            local playerData = Services.ReplicatedStorage:WaitForChild("Player_Data"):WaitForChild(Services.Players.LocalPlayer.Name)
            local borosCapsule = playerData:WaitForChild("Items"):WaitForChild("Borus Capsule")
            local amountValue = borosCapsule:WaitForChild("Amount")

            while State.AutoOpenBorosEnabled do
                task.wait(1)

                if not State.AutoOpenBorosEnabled then
                    break
                end

                if amountValue.Value > 0 then
                    openBorosCapsules(amountValue.Value)
                end
            end
        end)

        if not success then
            notify("Auto Boros", "Failed to start auto Boros capsule!")
        end
    end)
end

local function getPlayerCurrency()
    local playerData = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data
    if not playerData then return {} end

    local currencies = {}

    local GoldValue = playerData:FindFirstChild("Gold")
    if GoldValue then currencies["Gold"] = GoldValue.Value end

    local gemsValue = playerData:FindFirstChild("Gem")
    if gemsValue then currencies["Gem"] = gemsValue.Value end

    local raidValue = playerData:FindFirstChild("Raid Currency")
    if raidValue then currencies["Raid Currency"] = raidValue.Value end

    local SwarmEventValue = playerData:FindFirstChild("Fall Currency")
    if SwarmEventValue then currencies["Fall Currency"] = SwarmEventValue.Value end

    return currencies
end

local function canAffordItem(itemFolder)
    local priceValue = itemFolder:FindFirstChild("CurrencyAmount")
    local currencyTypeValue = itemFolder:FindFirstChild("CurrencyType")
    if not priceValue or not currencyTypeValue then return false end

    local playerCurrencies = getPlayerCurrency()

    return playerCurrencies[currencyTypeValue.Value] and playerCurrencies[currencyTypeValue.Value] >= priceValue.Value
end

local function purchaseItem(itemName, quantity, folderName)
    quantity = quantity or 1
    pcall(function()
        if folderName == "Merchant" then
            Remotes.Merchant:FireServer(itemName, quantity)
        end
        if folderName == "Fall_Shop" then
            Remotes.SwarmMerchant:FireServer(itemName, quantity)
        end
    end)
end

local didNotify = false

local function autoPurchaseItems(isEnabled, purchaseTable, folderName, shopDisplayName)
    if not isEnabled then return end
    if not purchaseTable or #purchaseTable == 0 then return end

    local playerData = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name]
    if not playerData then return end

    local shopFolder = playerData:FindFirstChild(folderName)
    if not shopFolder then return end

    for _, selectedItem in pairs(purchaseTable) do
        local itemFolder = shopFolder:FindFirstChild(selectedItem)
        if itemFolder then
            if canAffordItem(itemFolder) then
                local availableQuantity = itemFolder:FindFirstChild("Quantity") and itemFolder:FindFirstChild("Quantity").Value or 1
                local currentQuantity = itemFolder:FindFirstChild("BuyAmount") and itemFolder:FindFirstChild("BuyAmount").Value or 0

                if currentQuantity <= 0 then
                    purchaseItem(selectedItem, availableQuantity, folderName)
                    notify("Auto Purchase " .. shopDisplayName, "Purchased: " .. selectedItem)
                    task.wait(0.5)
                end
            else
                if didNotify == false then
                    didNotify = true
                    notify("Auto Purchase " .. shopDisplayName, "Can't afford: " .. selectedItem)
                    task.delay(20, function()
                        didNotify = false
                    end)
                end
            end
        end
    end
end

local function autoJoinRangerStage(stageName)
    if not isInLobby() then
        print("Not in lobby, cannot join ranger stage")
        return
    end

    print("Joining ranger stage:", stageName)

    Remotes.PlayEvent:FireServer("Create")
    task.wait(0.3)

    Remotes.PlayEvent:FireServer("Change-Mode", { Mode = "Ranger Stage" })
    task.wait(0.3)

    local world = stageName:match("^(.-)_RangerStage")
    if not world then
        warn("Couldn't extract world from:", stageName)
        return
    end

    Remotes.PlayEvent:FireServer("Change-World", { World = world })
    task.wait(0.3)

    Remotes.PlayEvent:FireServer("Change-Chapter", { Chapter = stageName })
    task.wait(0.3)

    Remotes.PlayEvent:FireServer("Submit")
    task.wait(0.3)

    Remotes.PlayEvent:FireServer("Start")

    print("Ranger stage join sequence completed for:", stageName)
end

local autoJoinState = {
    isProcessing = false,
    currentAction = nil,
    lastActionTime = 0,
    actionCooldown = 2
}

local function canPerformAction()
    return tick() - autoJoinState.lastActionTime >= autoJoinState.actionCooldown
end

local function setProcessingState(action)
    autoJoinState.isProcessing = true
    autoJoinState.currentAction = action
    autoJoinState.lastActionTime = tick()
    notify("Processing: ", action)
end

local function clearProcessingState()
    autoJoinState.isProcessing = false
    autoJoinState.currentAction = nil
end

local function getInternalWorldName(displayName)
    for _, story in ipairs(Data.availableStories) do
        if story.SeriesName == displayName then
            return story.ModuleName
        end
    end
    return nil
end

local function equipTeamSlot(teamSlot)
    if not teamSlot or teamSlot < 1 or teamSlot > 5 then
        warn("Invalid team slot:", teamSlot)
        return false
    end

    local success = pcall(function()
        local args = {
            "Equip",
            "Slot" .. teamSlot
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Teams"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
    end)

    if success then
        print("Equipped team slot:", teamSlot)
        return true
    else
        warn("Failed to equip team slot:", teamSlot)
        return false
    end
end

local function getTeamSlotForMode(mode)
    if not State.autoTeamSlotPicker then return nil end

    if State.modeTeamSelector1 and table.find(State.modeTeamSelector1, mode) then
        return 1
    elseif State.modeTeamSelector2 and table.find(State.modeTeamSelector2, mode) then
        return 2
    elseif State.modeTeamSelector3 and table.find(State.modeTeamSelector3, mode) then
        return 3
    elseif State.modeTeamSelector4 and table.find(State.modeTeamSelector4, mode) then
        return 4
    elseif State.modeTeamSelector5 and table.find(State.modeTeamSelector5, mode) then
        return 5
    end

    return nil
end

local function handleTeamEquipping(mode)
    local teamSlot = getTeamSlotForMode(mode)
    if teamSlot then
        print("Equipping team slot", teamSlot, "for mode:", mode)
        equipTeamSlot(teamSlot)
        task.wait(0.5)
    end
end

local function StartAutoFarmGear()
    if not isInLobby() then
        notify("Auto Gear Farm", "Must be in lobby to use auto gear farm!")
        return
    end

    if #State.selectedGears == 0 then
        notify("Auto Gear Farm", "Please select at least 1 gear to farm!")
        return
    end

    State.currentlyFarming = true
    State.AutoFarmEnabled = true

    AnalyzeRequiredStages()

    notify("Auto Gear Farm", "Auto farming started! Check console for stage analysis.")
end

local function saveFarmingState(stageName)
    local success, err = pcall(function()
        writefile("farming_state.json", game:GetService("HttpService"):JSONEncode({
            currentFarmingStage = stageName,
            timestamp = tick()
        }))
    end)
    if not success then
        warn("Failed to save farming state:", err)
    end
end

local function loadFarmingState()
    local success, result = pcall(function()
        if isfile("farming_state.json") then
            local data = game:GetService("HttpService"):JSONDecode(readfile("farming_state.json"))
            return data.currentFarmingStage
        end
        return nil
    end)

    if success then
        return result
    else
        warn("Failed to load farming state:", result)
        return nil
    end
end

if not State.currentFarmingStage then
    State.currentFarmingStage = loadFarmingState()
end

local function clearFarmingState()
    local success, err = pcall(function()
        if isfile("farming_state.json") then
            delfile("farming_state.json")
        end
    end)
    if not success then
        warn("Failed to clear farming state:", err)
    end
end

local function checkMaterialsInStage()
    State.currentlyFarming = State.AutoFarmEnabled

    if not State.currentlyFarming or not State.AutoFarmEnabled then
        return
    end

    if isInLobby() then
        return
    end

    if not State.currentFarmingStage then
        State.currentFarmingStage = loadFarmingState()
    end

    local totalNeeded = CalculateTotalMaterialsNeeded()
    local inventory = GetPlayerInventory()

    for materialName, needed in pairs(totalNeeded) do
        local current = inventory[materialName] or 0
        local deficit = needed - current

        if deficit > 0 then
            local sources = FindMaterialSource(materialName)

            for _, source in ipairs(sources) do
                local rangerStageName = string.format("%s_RangerStage%s",
                    source.module, source.chapter:match("%d+") or "1")

                if rangerStageName == State.currentFarmingStage then
                    return
                end
            end
        end
    end

    notify("Auto Gear Farm", "Got enough materials from current stage! Returning to lobby...")

    wait(3)

    clearFarmingState()
    game:GetService("TeleportService"):Teleport(111446873000464, game.Players.LocalPlayer)
end

local function checkMaterialFarming()
    if not State.currentlyFarming or not State.AutoFarmEnabled then
        return
    end

    if not isInLobby() then
        return
    end

    if autoJoinState.isProcessing then
        return
    end

    local totalNeeded = CalculateTotalMaterialsNeeded()
    local inventory = GetPlayerInventory()
    local materialToFarm = nil

    for materialName, needed in pairs(totalNeeded) do
        local current = inventory[materialName] or 0
        local deficit = needed - current

        if deficit > 0 then
            local sources = FindMaterialSource(materialName)
            if #sources > 0 then
                table.sort(sources, function(a, b)
                    local effA = (a.dropRate / 100) * ((a.minDrop + a.maxDrop) / 2)
                    local effB = (b.dropRate / 100) * ((b.minDrop + b.maxDrop) / 2)
                    return effA > effB
                end)

                local bestSource = sources[1]
                materialToFarm = {
                    name = materialName,
                    needed = deficit,
                    source = bestSource
                }
                break
            end
        end
    end

    if materialToFarm then
        local rangerStageName = string.format("%s_RangerStage%s",
            materialToFarm.source.module,
            materialToFarm.source.chapter:match("%d+") or "1")

        notify("Auto Gear Farm", string.format("Farming %d %s from %s",
            materialToFarm.needed, materialToFarm.name, rangerStageName))

        State.currentFarmingStage = rangerStageName
        saveFarmingState(rangerStageName)

        setProcessingState("Auto Material Farm")
        handleTeamEquipping("Ranger")
        task.wait(0.5)
        autoJoinRangerStage(rangerStageName)
        task.delay(5, clearProcessingState)
    else
        notify("Auto Gear Farm", "All materials farmed! Stopping auto farm.")
        State.currentlyFarming = false
        State.AutoFarmEnabled = false
        clearFarmingState()

        if State.SendFinishedFarmingGearWebhook then
            local gearData = {
                materialsNeeded = totalNeeded,
                craftAmounts = State.craftAmounts
            }
            sendWebhook("gear", nil, nil, nil, gearData)
        end

        print("=== MATERIAL FARMING COMPLETE ===")
        local finalInventory = GetPlayerInventory()
        for materialName, needed in pairs(totalNeeded) do
            local current = finalInventory[materialName] or 0
            print(string.format("%s: %d/%d %s",
                materialName, current, needed,
                current >= needed and "OK" or "MISSING"))
        end
        print("=== END ===")
    end
end

local function StopAutoFarmGear()
    State.AutoFarmEnabled = false
    State.currentlyFarming = false
    clearProcessingState()
    notify("Auto Gear Farm", "Material farming stopped!")
end

local function getHighestNumberFromNames(parent)
    local highestNumber = -math.huge

    for _, obj in ipairs(parent:GetChildren()) do
        if obj:IsA("StringValue") then
            local num = tonumber(obj.Name)
            if num and num > highestNumber then
                highestNumber = num
            end
        end
    end

    if highestNumber == -math.huge then
        return nil
    end

    return highestNumber
end

local function checkAndExecuteHighestPriority()
    if not isInLobby() then
        checkMaterialsInStage()
        return
    end
    if autoJoinState.isProcessing then return end
    if not canPerformAction() then return end

    checkMaterialFarming()

    -- Priority 1: Challenge Auto Join
    if State.autoChallengeEnabled then
        local skipChallenge = false
        if #Data.selectedChallengeWorlds > 0 then
            local ignoredInternalNames = {}
            for _, displayName in pairs(Data.selectedChallengeWorlds) do
                local internalName = getInternalWorldName(displayName)
                if internalName then
                    table.insert(ignoredInternalNames, internalName)
                end
            end

            for _, ignoredInternal in pairs(ignoredInternalNames) do
                if ignoredInternal == Services.ReplicatedStorage.Gameplay.Game.Challenge.World.Value then
                    skipChallenge = true
                    break
                end
            end
        end
        if not skipChallenge then
            local foundRewardOK, foundReward = isWantedChallengeRewardPresent()
            if foundRewardOK then
                setProcessingState("Challenge Auto Join")
                print("Found wanted reward '" .. foundReward .. "' -> creating challenge room")

                handleTeamEquipping("Challenge")

                notify("Challenge Mode", string.format("Found %s, joining challenge...", foundReward))
                Remotes.PlayEvent:FireServer("Create", { CreateChallengeRoom = true })
                Remotes.PlayEvent:FireServer("Start")
                task.delay(5, clearProcessingState)
                return
            end
        end
    end

    -- Priority 2: Portal Auto Join
    if State.autoPortalEnabled and not State.portalUsed and State.selectedPortals and #State.selectedPortals > 0 then
        local success, result = pcall(function()
            local inventoryFrame = Services.Players.LocalPlayer:FindFirstChild("PlayerGui").Items.Main.Base.Space:FindFirstChild("Scrolling")
            if not inventoryFrame then return nil end
            for _, item in ipairs(inventoryFrame:GetChildren()) do
                if (item.Name:lower():find("portal") or item.Name:lower():find("tier")) and table.find(State.selectedPortals, item.Name) then
                    return item.Name
                end
            end
        end)

        if success and result then
            setProcessingState("Portal Auto Join")

            local portalInstance = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Items:FindFirstChild(result)
            if portalInstance then
                handleTeamEquipping("Portal")

                Services.ReplicatedStorage.Remote.Server.Lobby.ItemUse:FireServer(portalInstance)
                State.portalUsed = true
                notify("Portal Joiner", "Using portal: " .. result)

                task.wait(1)

                print("Starting portal match...")
                Services.ReplicatedStorage.Remote.Server.Lobby.PortalEvent:FireServer("Start")

                task.delay(5, clearProcessingState)
                return
            else
                notify("Portal Joiner", "Portal not found: " .. result)
                clearProcessingState()
                State.portalUsed = false
            end
        end
    end

    -- Priority 3: Boss Event Auto Join
    if State.autoBossEventEnabled then
        setProcessingState("Boss Event Auto Join")
        handleTeamEquipping("Boss Event")
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer("Boss-Event", {Difficulty = "Nightmare"})
        task.delay(5, clearProcessingState)
        return
    end

    -- Priority 4: Raid Auto Join
    if State.autoJoinRaid then
        if State.selectedRaidStages and #State.selectedRaidStages > 0 then
            setProcessingState("Raid Auto Join")

            handleTeamEquipping("Raid")

            local fullName = tostring(State.selectedRaidStages[1])
            local mapName = string.match(fullName, "^(.-)_")
            print(mapName)

            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer("Create")
            task.wait(0.2)
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer("Change-Mode", {Mode = "Raids Stage"})
            task.wait(0.2)
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer("Change-World", {World = mapName})
            task.wait(0.2)
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer("Change-Chapter", {Chapter = State.selectedRaidStages[1]})
            task.wait(0.2)
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer("Submit")
            task.wait(0.2)
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer("Start")
            task.delay(5, clearProcessingState)
            return
        end
    end

    if State.autoCalamityEnabled then
    setProcessingState("Calamity Auto Join")
    handleTeamEquipping("Calamity")
    Remotes.PlayEvent:FireServer("Create")
    task.wait(0.2)
    Remotes.PlayEvent:FireServer("Change-Mode", { Mode = "Calamity" })
    task.wait(0.2)
    Remotes.PlayEvent:FireServer("Change-World", { World = "Calamity" })
    task.wait(0.2)
    Remotes.PlayEvent:FireServer("Change-Chapter", { Chapter = "Calamity_Chapter1" })
    task.wait(0.2)
    Remotes.PlayEvent:FireServer("Submit")
    task.wait(0.2)
    Remotes.PlayEvent:FireServer("Start")
    task.delay(5, clearProcessingState)
    return
end

    if State.autoBossAttackEnabled then
    setProcessingState("Boss Attack Auto Join")
    handleTeamEquipping("BossAttack")
    Remotes.PlayEvent:FireServer("Boss-Attack-2.5")
    task.delay(5, clearProcessingState)
    return
end

    if State.autoBountyHuntInvasionEnabled then
    setProcessingState("Bounty Hunt Invasion Auto Join")
    handleTeamEquipping("BountyHuntInvasion")
    Remotes.PlayEvent:FireServer("Create")
    task.wait(0.2)
    Remotes.PlayEvent:FireServer("Change-Mode", { Mode = "Calamity" })
    task.wait(0.2)
    Remotes.PlayEvent:FireServer("Change-World", { World = "Invasion" })
    task.wait(0.2)
    Remotes.PlayEvent:FireServer("Change-Chapter", { Chapter = "Invasion_Chapter1" })
    task.wait(0.2)
    Remotes.PlayEvent:FireServer("Submit")
    task.wait(0.2)
    Remotes.PlayEvent:FireServer("Start")
    task.delay(5, clearProcessingState)
    return
end

    -- Priority 5: Ranger Stage Auto Join
    if State.isAutoJoining and Data.selectedRawStages and #Data.selectedRawStages > 0 then
        local selectedStageSet = {}
        for _, raw in ipairs(Data.selectedRawStages) do
            selectedStageSet[raw] = true
        end

        local prioritizedStageList = {}
        for _, stage in ipairs(Data.availableRangerStages) do
            if selectedStageSet[stage.RawName] then
                table.insert(prioritizedStageList, stage.RawName)
            end
        end

        if #prioritizedStageList > 0 then
            local stageName = prioritizedStageList[1]
            setProcessingState("Ranger Stage Auto Join")

            handleTeamEquipping("Ranger")

            print("Attempting to join Ranger Stage:", stageName)
            autoJoinRangerStage(stageName)
            task.delay(5, clearProcessingState)
            return
        end
    end

    if State.autoJoinInfinityCastleEnabled then
        setProcessingState("Infinity Castle Auto Join")

        handleTeamEquipping("InfCastle")

        local CastleFloor = getHighestNumberFromNames(Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].InfinityCastleRewards)

        Remotes.PlayEvent:FireServer("Infinity-Castle", {Floor = CastleFloor + 1})
        task.delay(5, clearProcessingState)
        return
    end

    if State.autoDungeonEnabled and State.AutoDungeonDifficultySelector and State.AutoDungeonDifficultySelector ~= "" then
        setProcessingState("Dungeon Auto Join")

        handleTeamEquipping("Dungeon")
        local args = {"Dungeon", {Difficulty = State.AutoDungeonDifficultySelector[1]}}
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("PlayRoom"):WaitForChild("Event"):FireServer(unpack(args))

        task.delay(5, clearProcessingState)
        return
    end

    -- Priority 6: Story Auto Join
    if State.autoJoinEnabled and State.selectedWorld and State.selectedChapter and State.selectedDifficulty then
        setProcessingState("Story Auto Join")

        local internalWorldName = getInternalWorldName(State.selectedWorld)
        if internalWorldName then
            print("Joining Story:", State.selectedWorld, "/", State.selectedChapter, "/", State.selectedDifficulty)

            handleTeamEquipping("Story")

            local combinedWorld = internalWorldName .. "_" .. State.selectedChapter:gsub(" ", "")

            local function sendPlayRoomEvent(action, data)
                Remotes.PlayEvent:FireServer(action, data)
                task.wait(0.25)
            end

            sendPlayRoomEvent("Create")
            sendPlayRoomEvent("Change-World", { World = tostring(internalWorldName) })
            sendPlayRoomEvent("Change-Chapter", { Chapter = tostring(combinedWorld) })
            sendPlayRoomEvent("Change-Difficulty", { Difficulty = tostring(State.selectedDifficulty) })
            sendPlayRoomEvent("Submit")
            sendPlayRoomEvent("Start")

            task.delay(5, clearProcessingState)
            return
        else
            warn("[Story Auto Join] Invalid selection.")
            notify("Story Join", "Selected World/Chapter/Difficulty is invalid.")
            clearProcessingState()
        end
    end
end

local function getCurrentUpgradeLevel(unitName)
    if not unitName then return 0 end

    local success, upgradeLevel = pcall(function()
        local upgradeText = Services.Players.LocalPlayer.PlayerGui.HUD.InGame.UnitsManager.Main.Main.ScrollingFrame[unitName].UpgradeText.Text

        if string.find(upgradeText:upper(), "MAX") then
            return "MAX"
        end

        local level = string.match(upgradeText, "Upgrade:</font>%s*(%d+)")
        return tonumber(level) or 0
    end)

    if success then
        return upgradeLevel
    else
        return 0
    end
end

local function getUpgradeCost(unitName)
    if not unitName then return 9999 end

    local success, cost = pcall(function()
        local costText = Services.Players.LocalPlayer.PlayerGui.HUD.InGame.UnitsManager.Main.Main.ScrollingFrame[unitName].CostText.Text
        local costValue = string.match(costText, "Cost:</font>%s*([%d,]+)")
        if costValue then
            costValue = costValue:gsub(",", "")
            return tonumber(costValue) or 9999
        end
    end)

    return success and cost or 9999
end

local function getDeploymentCost(unitName)
    if not unitName then return 5000 end

    local success, costText = pcall(function()
        return Services.Players.LocalPlayer.PlayerGui.HUD.InGame.UnitsManager.Main.Main.ScrollingFrame[unitName].Unit.Frame.UnitFrame.Info.Cost.Text
    end)

    if success and costText then
        local numericCost = tonumber(costText:match("%d+"))
        if numericCost then
            return numericCost
        else
            return 9999
        end
    else
        return 9999
    end
end

local function getCurrentMoney()
    local success, money = pcall(function()
        return Services.Players.LocalPlayer.Yen.Value
    end)

    return (success and money) or 0
end

local function upgradeUnit(unitName)
    if not unitName then return false end

    local unitNameStr = typeof(unitName) == "Instance" and unitName.Name or tostring(unitName)

    local success = pcall(function()
        local args = { Services.Players.LocalPlayer.UnitsFolder:WaitForChild(unitNameStr) }
        Remotes.UpgradeUnit:FireServer(unpack(args))
    end)

    if success then
        return true
    else
        return false
    end
end

local function hasEnoughMoney(slotNumber)
    local currentMoney = getCurrentMoney()
    local unitName = getUnitNameFromSlot(slotNumber)
    local unitNameStr = typeof(unitName) == "Instance" and unitName.Name or tostring(unitName)
    local unitCost = getDeploymentCost(unitNameStr)

    return currentMoney >= unitCost
end

local function leftToRightUpgrade()
    while State.autoUpgradeEnabled and State.gameRunning do
        local unitName = getUnitNameFromSlot(State.currentUpgradeSlot)
        local unitNameStr = unitName and (typeof(unitName) == "Instance" and unitName.Name or tostring(unitName)) or "nil"
        local maxLevel = Config.unitLevelCaps[tonumber(State.currentUpgradeSlot)] or 9

        if unitName and unitNameStr ~= "" and unitNameStr ~= "nil" then
            local currentLevel = getCurrentUpgradeLevel(unitNameStr)

            if currentLevel == "MAX" or tonumber(currentLevel) >= maxLevel then
                State.currentUpgradeSlot = State.currentUpgradeSlot + 1
                if State.currentUpgradeSlot > 6 then
                    State.currentUpgradeSlot = 1
                end
            else
                local currentMoney = getCurrentMoney()
                local upgradeCost = getUpgradeCost(unitNameStr)

                if currentMoney >= upgradeCost then
                    if upgradeUnit(unitNameStr) then
                        task.wait(Config.UPGRADE_COOLDOWN)
                    else
                        warn("Failed to upgrade, will retry")
                        task.wait(1)
                    end
                end
            end
        else
            State.currentUpgradeSlot = State.currentUpgradeSlot + 1
            if State.currentUpgradeSlot > 6 then
                State.currentUpgradeSlot = 1
            end
        end

        task.wait(0.5)
    end

    print("Upgrade cycle ended")
end

local function startAutoUpgrade()
    if isInLobby() then
        print("Cannot start auto-upgrade while in lobby.")
        return
    end

    if State.upgradeTask then
        task.cancel(State.upgradeTask)
        State.upgradeTask = nil
    end

    State.upgradeTask = task.spawn(function()
        while State.autoUpgradeEnabled do
            if State.gameRunning then
                local success, err = pcall(function()
                    if State.upgradeMethod == "Left to right until max" then
                        leftToRightUpgrade()
                    end
                end)

                if not success then
                    warn("Auto upgrade error:", err)
                end
            end

            task.wait(1)
        end
    end)
end

local function stopAutoUpgrade()
    if State.upgradeTask then
        task.cancel(State.upgradeTask)
        State.upgradeTask = nil
    end
end

local function resetUpgradeOrder()
    State.currentUpgradeSlot = 1
    print("Reset upgrade order to slot 1")
end

local function isTargetAlive(targetValue)
    if not targetValue or not targetValue.Name then
        return false
    end
    local success, result = pcall(function()
        local agentFolder = Services.Workspace:WaitForChild("Agent", 5)
        if not agentFolder then return false end

        local enemyFolder = agentFolder:FindFirstChild("EnemyT")
        if not enemyFolder then return false end

        local enemy = enemyFolder:FindFirstChild(targetValue.Name)
        return enemy ~= nil
    end)

    return success and result
end

local function getUnitsWithUltimates()
    local unitsWithUltimates = {}

    local success, result = pcall(function()
        local agentFolder = Services.Workspace:WaitForChild("Agent", 5)
        if not agentFolder then return {} end

        local unitFolder = agentFolder:WaitForChild("UnitT", 5)
        if not unitFolder then return {} end

        for _, part in pairs(unitFolder:GetChildren()) do
            if part:IsA("BasePart") or part:IsA("Part") then
                local infoFolder = part:FindFirstChild("Info")
                if infoFolder then
                    local activeAbility = infoFolder:FindFirstChild("ActiveAbility")
                    local targetObject = infoFolder:FindFirstChild("TargetObject")
                    local ownerValue = infoFolder:FindFirstChild("Owner")

                    if activeAbility and activeAbility:IsA("StringValue") and targetObject and targetObject:IsA("ObjectValue") and ownerValue and ownerValue:IsA("StringValue") then
                        if activeAbility.Value ~= "" and targetObject.Value ~= nil and ownerValue.Value == Services.Players.LocalPlayer.Name then
                            if isTargetAlive(targetObject.Value) then
                                table.insert(unitsWithUltimates, {
                                    part = part,
                                    abilityName = activeAbility.Value
                                })
                            end
                        end
                    end
                end
            end
        end

        return unitsWithUltimates
    end)

    if success then
        return result
    else
        warn("Error getting units with ultimates:", result)
        return {}
    end
end

local function fireUltimateForUnit(unitData)
    local success = pcall(function()
        Services.ReplicatedStorage.Remote.Server.Units.Ultimate:FireServer(unitData.part)
    end)

    if not success then
        warn("Failed to fire ultimate for unit:", unitData.part.Name)
    end
end

local function autoUltimateLoop()
    if isInLobby() then return end
    while State.AutoUltimateEnabled do
        local unitsWithUltimates = getUnitsWithUltimates()
        if #unitsWithUltimates > 0 then
            for _, unitData in pairs(unitsWithUltimates) do
                if not State.AutoUltimateEnabled then break end
                if State.DelayAutoUltimate > 0 then
                    task.wait(State.DelayAutoUltimate)
                end
                fireUltimateForUnit(unitData)
                task.wait(0.1)
            end
        end
        task.wait(1)
    end
    print("Auto Ultimate loop stopped")
end

local function checkSlotExists(slotNumber)
    local slotPath = game.Players.LocalPlayer.PlayerGui.UnitsLoadout.Main["UnitLoadout" .. slotNumber]
    if slotPath and slotPath.Frame.UnitFrame and slotPath.Frame.UnitFrame.Info.Folder.Value ~= nil then
        State.slotExists[slotNumber] = true
        return true
    else
        State.slotExists[slotNumber] = false
        return false
    end
end

local function isSlotOnCooldown(slotNumber)
    local cooldownPath = game.Players.LocalPlayer.PlayerGui.UnitsLoadout.Main["UnitLoadout" .. slotNumber].Frame:FindFirstChild("CD_FRAME")
    return cooldownPath and cooldownPath.Visible or false
end

local function shouldSkipSlotTemporarily(slotNumber)
    local lastAttempt = State.lastDeploymentTimes[slotNumber]
    if lastAttempt and (tick() - lastAttempt) < 3 then
        return true
    end
    return false
end

local function IsUnitLevelReached(slotNumber)
    local unitName = getUnitNameFromSlot(slotNumber)
    local unitNameStr = unitName and (typeof(unitName) == "Instance" and unitName.Name or tostring(unitName)) or "nil"
    local currentUnitLevel = getCurrentUpgradeLevel(unitNameStr)
    if currentUnitLevel == "MAX" then
        return false
    end
    if currentUnitLevel < Config.unitDeployLevelCaps[slotNumber] then
        return true
    end
end

local function getNextReadySlot()
    local checkedSlots = 0

    while checkedSlots < 6 do
        task.wait(0.05)
        local slotToCheck = State.currentSlot

        local shouldSkip = false

        if not checkSlotExists(slotToCheck) then
            shouldSkip = true
        elseif isSlotOnCooldown(slotToCheck) then
            shouldSkip = true
        elseif not hasEnoughMoney(slotToCheck) then
            shouldSkip = true
        elseif shouldSkipSlotTemporarily(slotToCheck) then
            shouldSkip = true
        elseif IsUnitLevelReached(slotToCheck) then
            shouldSkip = true
        end

        if shouldSkip then
            State.currentSlot = (State.currentSlot % 6) + 1
            checkedSlots = checkedSlots + 1
        else
            return slotToCheck
        end
    end
    return nil
end

local function deployUnit(slotNumber)
    if not checkSlotExists(slotNumber) then
        return false, "Slot doesn't exist"
    end

    if isSlotOnCooldown(slotNumber) then
        return false, "Unit is on cooldown"
    end

    if not hasEnoughMoney(slotNumber) then
        return false, "Not enough money"
    end

    if IsUnitLevelReached(slotNumber) then
        return false, "Unit can't be deployed yet because of level"
    end

    local unitFolder = game.Players.LocalPlayer.PlayerGui.UnitsLoadout.Main["UnitLoadout" .. slotNumber].Frame.UnitFrame.Info.Folder.Value

    if not unitFolder then
        return false, "Unit folder not found"
    end

    local success, errorMessage = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("Deployment"):FireServer(unitFolder)
    end)

    if success then
        State.lastDeploymentTimes[slotNumber] = nil
        return true, "Success"
    else
        print("Failed to deploy unit from slot " .. slotNumber .. ": " .. tostring(errorMessage))
        State.lastDeploymentTimes[slotNumber] = tick()
        return false, "Deployment failed"
    end
end

local function autoPlayLoop()
    task.spawn(function()
        while State.autoPlayEnabled do
            if State.gameRunning and State.AutoPlayDelayNumber > 0 and not State.autoPlayDelayActive then
                State.autoPlayDelayActive = true
                notify("Auto Play Delay", "Waiting " .. State.AutoPlayDelayNumber .. " seconds before starting deployment...", 5)

                task.wait(State.AutoPlayDelayNumber)

                notify("Auto Play Delay", "Delay finished, starting deployment...", 5)
            end

            if State.gameRunning and (State.AutoPlayDelayNumber == 0 or State.autoPlayDelayActive) then
                local slotToDeploy = getNextReadySlot()

                if slotToDeploy then
                    local success, message = deployUnit(slotToDeploy)

                    if success then
                        State.currentSlot = (slotToDeploy % 6) + 1
                    elseif not success and message == "Not enough money" then
                        State.currentSlot = (slotToDeploy % 6)
                    else
                        State.currentSlot = (slotToDeploy % 6) + 1
                        print("Failed to deploy from slot " .. slotToDeploy .. " (" .. message .. "), trying next slot")
                    end
                end
            end

            task.wait(0.1)
        end
    end)
end

local function startAutoPlay()
    if isInLobby() then
        print("Cannot start autoplay: Player is in lobby")
        return
    end

    print("Starting autoplay system...")

    if Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.AutoPlay.Value == true then
        Services.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("AutoPlay"):FireServer()
    end
    State.currentSlot = 1
    State.lastDeploymentTimes = {}
    State.slotExists = {}
    State.autoPlayDelayActive = false

    for i = 1, 6 do
        checkSlotExists(i)
        print("Slot " .. i .. " exists: " .. tostring(State.slotExists[i]))
    end

    autoPlayLoop()
end

local function StreamerMode()
    local head = Services.Players.LocalPlayer.Character:WaitForChild("Head", 5)
    if not head then return end

    local billboard = head:FindFirstChild("PlayerHeadGui")
    if not billboard then return end

    local originalNumbers = Services.Players.LocalPlayer.PlayerGui:WaitForChild("HUD"):WaitForChild("ExpBar"):FindFirstChild("Numbers")
    if not originalNumbers then return end

    local streamerLabel = Services.Players.LocalPlayer.PlayerGui:WaitForChild("HUD"):WaitForChild("ExpBar"):FindFirstChild("Numbers_Streamer")
    if not streamerLabel then
        streamerLabel = originalNumbers:Clone()
        streamerLabel.Name = "Numbers_Streamer"
        streamerLabel.Text = "Level 999 - Protected by Lixhub"
        streamerLabel.Visible = false
        streamerLabel.Parent = originalNumbers.Parent
    end

    if State.streamerModeEnabled then
        billboard:FindFirstChild("PlayerName").Text = "Protected By LixHub"
        billboard:FindFirstChild("Level").Text = "Level 999"
        billboard:FindFirstChild("Title").Text = "Lixhub User"

        originalNumbers.Visible = false
        streamerLabel.Visible = true
    else
        billboard:FindFirstChild("PlayerName").Text = tostring(Services.Players.LocalPlayer.Name)
        billboard:FindFirstChild("Level").Text = "Level " .. Services.ReplicatedStorage:WaitForChild("Player_Data")[Services.Players.LocalPlayer.Name].Data.Level.Value
        billboard:FindFirstChild("Title").Text = Services.ReplicatedStorage:WaitForChild("Player_Data")[Services.Players.LocalPlayer.Name].Data.Title.Value

        originalNumbers.Visible = true
        streamerLabel.Visible = false
    end
end

local failsafeRunning = false

local function startFailsafeAfterGameEnd()
    if failsafeRunning then
        warn("Failsafe is already running. Skipping new start.")
        return
    end
    failsafeRunning = true

    task.spawn(function()
        local waitTime = tonumber(State.AutoFailSafeNumber) or 300
        notify("Failsafe", "Failsafe started, Waiting " .. waitTime .. " seconds or until game starts...", 5)

        local startTime = tick()
        while tick() - startTime < waitTime do
            if State.gameRunning then
                notify("Failsafe", "New game started during wait. Cancelling failsafe.", 3)
                failsafeRunning = false
                return
            end
            task.wait(1)
        end

        if not State.gameRunning then
            notify("Failsafe", "Teleporting to lobby...", 3)
            Services.TeleportService:Teleport(111446873000464, Services.Players.LocalPlayer)
        else
            print("Game started right at the end of wait. No recovery needed.")
        end

        failsafeRunning = false
    end)
end

local function startRetryLoop()
    State.retryAttempted = true
    task.spawn(function()
        while State.retryAttempted and State.autoRetryEnabled do
            Remotes.RetryEvent:FireServer()
            task.wait(0.5)
        end
    end)
end

local function stopRetryLoop()
    State.retryAttempted = false
end

local function startNextLoop()
    State.NextAttempted = true

    task.spawn(function()
        while State.NextAttempted and State.autoNextEnabled do
            Remotes.NextEvent:FireServer()
            task.wait(0.5)
        end
    end)
end

local function stopNextLoop()
    State.NextAttempted = false
end

local function getunitRarity(unit)
    local success, result = pcall(function()
        local gui = Services.Players.LocalPlayer.PlayerGui.Collection.Main.Base.Space.Unit[unit.Name].Frame.UnitFrame
        for _, rarity in ipairs({ "Ranger", "Secret", "Mythic", "Legendary", "Epic", "Rare" }) do
            if gui:FindFirstChild(rarity) then return rarity end
        end
    end)
    return success and result or nil
end

local function isUnitShiny(unit)
    local success, result = pcall(function()
        if string.find(unit.Name:lower(), "shiny") then
            return true
        end
        local gui = Services.Players.LocalPlayer.PlayerGui.Collection.Main.Base.Space.Unit[unit.Name]
        if gui and string.find(gui.Name:lower(), "shiny") then
            return true
        end
        return false
    end)
    return success and result or false
end

local function shouldSellUnit(unit, selectedRarities)
    local rarity = getunitRarity(unit)
    local isShiny = isUnitShiny(unit)

    local hasShinySelected = table.find(selectedRarities, "Shiny")
    local hasRaritySelected = table.find(selectedRarities, rarity)

    if not hasRaritySelected then
        return false
    end
    if hasShinySelected then
        return true
    else
        return not isShiny
    end
end

local function deleteUnit(unitName)
    if not unitName then return false end

    local success, result = pcall(function()
        for _, part in pairs(Services.Workspace.Agent.UnitT:GetChildren()) do
            if part:IsA("Part") then
                local info = part:FindFirstChild("Info")
                if info then
                    local unitNameValue = info:FindFirstChild("UnitName")
                    if unitNameValue and unitNameValue.Value == unitName then
                        local args = {part, nil}
                        game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Units"):WaitForChild("DeleteUnit"):FireServer(unpack(args))
                        return true
                    end
                end
            end
        end
        return false
    end)

    if success and result then
        print("Successfully deleted unit: " .. unitName)
        return true
    else
        return false
    end
end

local lastCheckedLevels = {}
local processedUnits = {}

local function checkAndRefreshUnits()
    for slot = 1, 6 do
        local unitName = getUnitNameFromSlot(slot)

        if unitName then
            local currentLevel = getCurrentUpgradeLevel(unitName)
            local targetLevel = Config.unitReDeployLevel[slot]

            if targetLevel ~= 0 then
                local slotKey = "slot_" .. slot

                if not processedUnits[slotKey] and lastCheckedLevels[slotKey] ~= currentLevel then
                    lastCheckedLevels[slotKey] = currentLevel

                    if currentLevel == "MAX" and targetLevel <= 9 then
                        print("Slot " .. slot .. " (" .. unitName .. ") reached MAX level, deleting...")
                        deleteUnit(unitName)
                        processedUnits[slotKey] = true
                    elseif type(currentLevel) == "number" and currentLevel >= targetLevel then
                        print("Slot " .. slot .. " (" .. unitName .. ") reached level " .. currentLevel .. ", deleting...")
                        deleteUnit(unitName)
                        processedUnits[slotKey] = true
                    end
                end
            end
        else
            lastCheckedLevels["slot_" .. slot] = nil
        end
    end
end

local function autoSellUnitLoop()
    if State.AutoSellUnitChoice[1] and State.AutoSellUnitChoice[1] ~= "No Unit" then
        local slotNumber = tonumber(State.AutoSellUnitChoice[1]:match("Unit(%d)"))
        if slotNumber then
            local unitName = getUnitNameFromSlot(slotNumber)
            if unitName then
                if not isSlotOnCooldown(slotNumber) then
                    deleteUnit(unitName)
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        if State.AutoSellUnitChoice[1] ~= "No Unit" and not isInLobby() then
            autoSellUnitLoop()
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if State.AutoReDeployEnabled and not isInLobby() then
            checkAndRefreshUnits()
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)

        if State.AutoSellRarities and typeof(State.SelectedRaritiesToSell) == "table" then
            local data = GameObjects.GetData.GetData(Services.Players.LocalPlayer)
            local collection = data.Collection:GetChildren()

            for _, unit in ipairs(collection) do
                if shouldSellUnit(unit, State.SelectedRaritiesToSell) then
                    local realUnitFolder = GameObjects.getUnitFolder(Services.Players.LocalPlayer, unit)
                    if realUnitFolder then
                        local lockedFlag = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Collection[unit.Name].Lock
                        if lockedFlag.Value == false then
                            local args = {{ realUnitFolder, nil }}
                            Remotes.SellRemote:FireServer(unpack(args))
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    print("Fetching story data...")
    Data.availableStories = fetchStoryData()

    print("Fetching ranger stage data...")
    Data.availableRangerStages = fetchRangerStageData(Data.availableStories)

    print("Fetching raid data...")
    Data.availableRaids = fetchRaidData()

    print("Data fetching complete!")
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        checkAndExecuteHighestPriority()
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        StreamerMode()
    end
end)

task.spawn(function()
    while true do
        wait(0.1)
        if State.autoDisableEndUI and not isInLobby() then
            for _, child in ipairs(Services.Players.LocalPlayer.PlayerGui:GetChildren()) do
                if child.Name == "GameEndedAnimationUI" then
                    child.Enabled = false
                end
            end
            for _, child in ipairs(Services.Players.LocalPlayer.PlayerGui:GetChildren()) do
                if child.Name == "RewardsUI" then
                    child.Enabled = false
                end
            end
            for _, child in ipairs(Services.Players.LocalPlayer.PlayerGui:GetChildren()) do
                if child.Name == "Visual" then
                    child.Enabled = false
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(2)
        if State.autoAfkTeleportEnabled and isInLobby() and GameObjects.AFKChamberUI.Enabled == false then
            print("Teleporting to AFK world...")
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Lobby"):WaitForChild("AFKWorldTeleport"):FireServer()
        end
    end
end)

task.spawn(function()
    while true do
        if State.AutoPurchaseMerchant and #Data.MerchantPurchaseTable > 0 then
            autoPurchaseItems(State.AutoPurchaseMerchant, Data.MerchantPurchaseTable, "Merchant", "Merchant")
        end
        if State.AutoPurchaseSwarmEvent and #Data.SwarmEventPurchaseTable > 0 then
            autoPurchaseItems(State.AutoPurchaseSwarmEvent, Data.SwarmEventPurchaseTable, "Fall_Shop", "Swarm Event Shop")
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        task.wait(3)
        if State.autoClaimBP then
            Services.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Events"):WaitForChild("ClaimBp"):FireServer("Claim All")
        end
        if State.AutoClaimQuests then
            Services.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("QuestEvent"):FireServer("ClaimAll")
        end
        if State.AutoClaimMilestones then
            local playerlevel = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.Level.Value
            Services.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gameplay"):WaitForChild("LevelMilestone"):FireServer(tonumber(playerlevel))
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)

        if State.autoStartEnabled then
            local voteVisible = false

            pcall(function()
                voteVisible = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
                    :WaitForChild("HUD")
                    :WaitForChild("InGame")
                    :WaitForChild("VotePlaying").Visible
            end)

            if voteVisible then
                print("Vote screen is visible, sending start signal...")
                Remotes.StartGame:FireServer()
                task.wait(3)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)

        if State.RestartGameOnWave > 0 and State.gameRunning and not isInLobby() then
            local success, currentWave = pcall(function()
                return game:GetService("ReplicatedStorage").Values.Waves.CurrentWave.Value
            end)

            if success and currentWave and currentWave >= State.RestartGameOnWave then
                print("Wave limit reached (" .. currentWave .. "), restarting game...")
                notify("Wave Restart", "Wave " .. currentWave .. " reached! Restarting...", 3)

                -- Treat it like a game end
                State.gameRunning = false
                State.hasGameEnded = true
                State.autoPlayDelayActive = false

                -- Send webhook if enabled
                if State.SendStageCompletedWebhook and not State.hasSentWebhook then
                    State.hasSentWebhook = true
                    local clearTimeStr = "Unknown"
                    if State.stageStartTime then
                        local dt = math.floor(tick() - State.stageStartTime)
                        clearTimeStr = string.format("%d:%02d", dt // 60, dt % 60)
                    end
                    State.matchResult = "Wave Restart"
                end

                -- Reset upgrade/redeploy tracking
                resetUpgradeOrder()
                lastCheckedLevels = {}
                processedUnits = {}
                game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("OnGame"):WaitForChild("RestartMatch"):FireServer()
            end
        end
    end
end)

--// BUTTONS //--

local function redeemallcodes()
    notify("Code Redemption", "Starting code redemption...", 3)

    local success, error = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Lixtron/Hub/refs/heads/main/Codes_ARX.lua"))()
    end)

    if not success then
        notify("Error", "Failed to load code script", 5)
        warn("Failed to load script: " .. tostring(error))
    end
end

local function updateFPSLimit()
    if State.enableLimitFPS and State.SelectedFPS > 0 then
        setfpscap(State.SelectedFPS)
    else
        setfpscap(0)
    end
end

local function getCurrentGems()
    local leaderstats = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data
    if leaderstats then
        local gems = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data.Gem
        if gems then
            return gems.Value
        end
    end
    return 0
end

local function showUnitInventory()
    local playerGui = Services.Players.LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        local unitInventory = playerGui:FindFirstChild("Collection")
        if unitInventory then
            unitInventory.Enabled = true
            unitInventory.Main.Visible = true
            task.wait(0.5)
            return true
        end
    end
    return false
end

local function takeUnitSnapshot()
    local units = {}
    local playerGui = Services.Players.LocalPlayer:FindFirstChild("PlayerGui")

    if playerGui then
        local unitInventory = playerGui:FindFirstChild("Collection").Main.Base.Space.Unit
        if unitInventory then
            for _, unitFrame in pairs(unitInventory:GetDescendants()) do
                if unitFrame:IsA("TextButton") then
                    local unitName = unitFrame.Name
                    if unitName then
                        local name = unitName
                        units[name] = (units[name] or 0) + 1
                    end
                end
            end
        end
    end
    return units
end

local function compareUnits(before, after)
    local newUnits = {}

    for unitName, afterCount in pairs(after) do
        local beforeCount = before[unitName] or 0
        local difference = afterCount - beforeCount

        if difference > 0 then
            newUnits[unitName] = difference
        end
    end

    return newUnits
end

local function sendSummaryWebhook(newUnits, totalGems)
    local webhookUrl = ValidWebhook

    if not webhookUrl or webhookUrl == "YOUR_WEBHOOK_URL_HERE" then
        print("No webhook URL configured")
        return
    end

    local embed = {
        title = "Auto Summon Results",
        color = 3447003,
        fields = {
            {
                name = "Gems Spent",
                value = totalGems,
                inline = false
            }
        },
        footer = {
            text = "discord.gg/cYKnXE2Nf8"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }

    for unitName, count in pairs(newUnits) do
        table.insert(embed.fields, {
            name = unitName,
            value = "x" .. count,
            inline = true
        })
    end

    if #embed.fields == 1 then
        embed.description = "No new units obtained this session."
    end

    local data = {
        embeds = {embed}
    }

    local success, result = pcall(function()
        if syn and syn.request then
            return syn.request({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = Services.HttpService:JSONEncode(data)
            })
        elseif request then
            return request({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = Services.HttpService:JSONEncode(data)
            })
        elseif http_request then
            return http_request({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = Services.HttpService:JSONEncode(data)
            })
        else
            error("No HTTP request function available")
        end
    end)

    if success then
        print("Webhook sent successfully!")
    else
        print("Failed to send webhook:", result)
    end
end

local function doSummon()
    local args

    if State.AutoSummonBannerSelected == "Divine" then
        args = {
            "10x",
            "Divine",
            {}
        }
    else
        args = {
            "10x",
            State.AutoSummonBannerSelected,
            {}
        }
    end

    pcall(function()
        Services.ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Server"):WaitForChild("Gambling"):WaitForChild("UnitsGacha"):FireServer(unpack(args))
    end)
end

local function getCurrentDivineFlowers()
    local success, flowers = pcall(function()
        return Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Data["Magic Flower"].Value
    end)
    return success and flowers or 0
end

local function startAutoSummon()
    if not isInLobby() then return end
    if autoSummonActive then return end
    if not State.enableAutoSummon then return end
    if not State.AutoSummonBannerSelected then return end

    autoSummonActive = true
    print("Starting Auto Summon...")
    notify("Auto Summon", "Starting Auto Summon...")

    if not showUnitInventory() then
        print("Failed to show unit inventory")
        autoSummonActive = false
        return
    end

    initialUnits = takeUnitSnapshot()
    print("Initial units snapshot taken")

    local initialCurrency
    if State.AutoSummonBannerSelected == "Divine" then
        initialCurrency = getCurrentDivineFlowers()
        Services.Players.LocalPlayer:SetAttribute("InitialDivineFlowers", initialCurrency)
    else
        initialCurrency = getCurrentGems()
        Services.Players.LocalPlayer:SetAttribute("InitialGems", initialCurrency)
    end

    local uiTask = task.spawn(function()
        while autoSummonActive do
            local playerGui = Services.Players.LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                local collection = playerGui:FindFirstChild("Collection")
                if collection and collection.Main then
                    collection.Main.Visible = true
                    collection.Enabled = true
                end
            end
            task.wait(0.1)
        end
    end)

    summonTask = task.spawn(function()
        while autoSummonActive do
            local currentCurrency, requiredAmount, currencyName

            if State.AutoSummonBannerSelected == "Divine" then
                currentCurrency = getCurrentDivineFlowers()
                requiredAmount = 1500
                currencyName = "Divine Flowers"
            else
                currentCurrency = getCurrentGems()
                requiredAmount = 500
                currencyName = "gems"
            end

            if currentCurrency < requiredAmount then
                print("Not enough " .. currencyName .. "! Stopping auto summon...")
                notify("Auto Summon", "Not enough " .. currencyName .. "! Stopping auto summon...")
                Services.Players.LocalPlayer.PlayerGui.HUD.Enabled = true
                break
            end

            doSummon()
            print("Summoned! " .. currencyName .. " remaining:", currentCurrency)

            task.wait(3)
        end

        local finalCurrency, currencySpent
        if State.AutoSummonBannerSelected == "Divine" then
            finalCurrency = getCurrentDivineFlowers()
            currencySpent = (Services.Players.LocalPlayer:GetAttribute("InitialDivineFlowers") or getCurrentDivineFlowers()) - finalCurrency
        else
            finalCurrency = getCurrentGems()
            currencySpent = (Services.Players.LocalPlayer:GetAttribute("InitialGems") or getCurrentGems()) - finalCurrency
        end

        task.wait(1)
        local finalUnits = takeUnitSnapshot()
        local newUnits = compareUnits(initialUnits, finalUnits)

        local hasNewUnits = false
        for _, count in pairs(newUnits) do
            if count > 0 then
                hasNewUnits = true
                break
            end
        end

        if hasNewUnits then
            sendSummaryWebhook(newUnits, currencySpent)
            print("Summary sent to webhook!")
        else
            print("No new units obtained")
        end

        autoSummonActive = false
        print("Auto Summon stopped")
    end)
end

local function stopAutoSummon()
    if not autoSummonActive then return end

    autoSummonActive = false
    if summonTask then
        task.cancel(summonTask)
        summonTask = nil
        Services.Players.LocalPlayer.PlayerGui.HUD.Enabled = true
    end

    task.spawn(function()
        local finalGems = getCurrentGems()
        local gemsSpent = (Services.Players.LocalPlayer:GetAttribute("InitialGems") or getCurrentGems()) - finalGems

        task.wait(1)
        local finalUnits = takeUnitSnapshot()
        local newUnits = compareUnits(initialUnits, finalUnits)

        local hasNewUnits = false
        for _, count in pairs(newUnits) do
            if count > 0 then
                hasNewUnits = true
                break
            end
        end

        if hasNewUnits then
            sendSummaryWebhook(newUnits, gemsSpent)
            print("Summary sent to webhook!")
        else
            print("No new units obtained")
        end
    end)

    print("Auto Summon manually stopped")
end

--// UI //--

LobbyTab:CreateSection("Lobby")

LobbyTab:CreateButton({
    Name = "Redeem All Codes",
    Callback = function()
        redeemallcodes()
    end,
})

LobbyTab:CreateToggle({
    Name = "Auto Summon",
    CurrentValue = false,
    Flag = "enableAutoSummon",
    Info = "Will start summoning on selected banner. If your UI bugs after using this simply rejoin.",
    TextScaled = true,
    Callback = function(Value)
        State.enableAutoSummon = Value
        if Value then
            startAutoSummon()
        else
            stopAutoSummon()
        end
    end,
})

LobbyTab:CreateDropdown({
    Name = "Auto Summon Banner",
    Options = {"Standard", "Rateup"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "AutoSummonBannerSelection",
    Callback = function(Options)
        State.AutoSummonBannerSelected = Options[1]
    end,
})

LobbyTab:CreateSection("Auto Gear Farm")

local AutoFarmToggle = LobbyTab:CreateToggle({
    Name = "Auto Gear Farm",
    CurrentValue = State.AutoFarmEnabled,
    Flag = "AutoGearFarmEnabled",
    Info = "Joins the required ranger stages and farms. You have to manually craft the gears, this just collects the materials!",
    TextScaled = false,
    Callback = function(Value)
        State.AutoFarmEnabled = Value
        State.currentlyFarming = Value
    end,
})

local GearSelectorDropdown = LobbyTab:CreateDropdown({
    Name = "Select Gears",
    Options = GetAllGearNames(),
    CurrentOption = GetAllGearNames()[1],
    MultipleOptions = true,
    Flag = "GearSelector",
    Callback = function(Options)
        State.selectedGears = Options

        local craftAmount = State.globalCraftAmount or 1
        State.craftAmounts = {}
        for _, gearName in ipairs(Options) do
            State.craftAmounts[gearName] = craftAmount
        end

        if State.AutoFarmEnabled and #Options == 0 then
            State.AutoFarmEnabled = false
            AutoFarmToggle:Set(false)
            notify("Auto Gear Farm", "Auto farm disabled - need at least 1 gear selected!")
        end
    end,
})

LobbyTab:CreateSlider({
    Name = "Craft Amount",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = 1,
    Flag = "GlobalCraftAmount",
    Info = "Amount to craft for ALL selected gears",
    Callback = function(Value)
        State.globalCraftAmount = Value

        for _, gearName in ipairs(State.selectedGears or {}) do
            State.craftAmounts[gearName] = Value
        end

        if #(State.selectedGears or {}) > 0 then
            notify("Auto Gear Farm", string.format("Set craft amount to %d for all selected gears", Value))
        end
    end,
})

LobbyTab:CreateButton({
    Name = "Show Required Materials",
    Callback = function()
        if #State.selectedGears == 0 then
            notify("Required Materials", "No gears selected!")
            return
        end

        local totalNeeded = CalculateTotalMaterialsNeeded()
        local inventory = GetPlayerInventory()

        local materialsList = {}
        for materialName, needed in pairs(totalNeeded) do
            local current = inventory[materialName] or 0
            local status = current >= needed and "OK" or "MISSING"
            table.insert(materialsList, string.format("%s %s: %d/%d", status, materialName, current, needed))
        end

        if #materialsList > 0 then
            notify("Required Materials", table.concat(materialsList, "\n"))
        else
            notify("Required Materials", "No materials needed!")
        end
    end,
})

LobbyTab:CreateButton({
    Name = "Show Craft Amounts",
    Callback = function()
        local amounts = {}
        for gearName, amount in pairs(State.craftAmounts) do
            if amount > 0 then
                table.insert(amounts, string.format("%s: %dx", gearName, amount))
            end
        end

        if #amounts > 0 then
            notify("Craft Amounts", table.concat(amounts, "\n"))
        else
            notify("Craft Amounts", "No craft amounts set!")
        end
    end,
})

LobbyTab:CreateButton({
    Name = "Reset All Gear Settings",
    Callback = function()
        State.selectedGears = {}
        State.craftAmounts = {}
        State.totalMaterialsNeeded = {}
        State.globalCraftAmount = 1
        GearSelectorDropdown:Set({})
        notify("Auto Gear Farm", "All gear settings cleared!")
    end,
})

LobbyTab:CreateSection("Claimers")

LobbyTab:CreateToggle({
    Name = "Auto Claim Battlepass",
    CurrentValue = false,
    Flag = "AutoClaimBattlepass",
    Callback = function(Value)
        State.autoClaimBP = Value
    end,
})

LobbyTab:CreateToggle({
    Name = "Auto Claim Quests",
    CurrentValue = false,
    Flag = "AutoClaimQuests",
    Callback = function(Value)
        State.AutoClaimQuests = Value
    end,
})

LobbyTab:CreateToggle({
    Name = "Auto Claim Level Milestones",
    CurrentValue = false,
    Flag = "AutoClaimMilestones",
    Callback = function(Value)
        State.AutoClaimMilestones = Value
    end,
})

LobbyTab:CreateSection("AFK Chamber")

LobbyTab:CreateToggle({
    Name = "Auto Teleport to AFK Chamber",
    CurrentValue = false,
    Flag = "AutoAfkTeleportToggle",
    Callback = function(Value)
        State.autoAfkTeleportEnabled = Value
    end,
})

LobbyTab:CreateToggle({
    Name = "Anti Teleport to AFK Chamber",
    CurrentValue = false,
    Flag = "AntiAfkToggle",
    Info = "This also disables ARX auto rejoin.",
    TextScaled = false,
    Callback = function(Value)
        State.AntiAfkEnabled = Value
    end,
})

task.spawn(function()
    while true do
        if State.AntiAfkEnabled then
            Services.Workspace:WaitForChild(Services.Players.LocalPlayer.Name):FindFirstChild("AFK").Disabled = true
        else
            Services.Workspace:WaitForChild(Services.Players.LocalPlayer.Name):FindFirstChild("AFK").Disabled = false
        end
        task.wait(5)
    end
end)

LobbyTab:CreateSection("Misc")

LobbyTab:CreateButton({
    Name = "Return to Lobby",
    Callback = function()
        notify("Return to Lobby", "Returning to lobby!")
        Services.TeleportService:Teleport(111446873000464, Services.Players.LocalPlayer)
    end,
})

LobbyTab:CreateToggle({
    Name = "Auto Execute Script",
    CurrentValue = false,
    Flag = "enableAutoExecute",
    Info = "This auto executes and persists through teleports until you disable it or leave the game.",
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
                queue_on_teleport("")
            end
        end
    end,
})

LobbyTab:CreateToggle({
    Name = "Auto Reconnect When Disconnected",
    CurrentValue = false,
    Flag = "AutoReconnectToggle",
    Info = "Automatically tries to reconnect when you get kicked or disconnected.",
    TextScaled = false,
    Callback = function(Value)
        State.autoReconnectEnabled = Value
    end,
})

local function setupAutoReconnect()
    local TeleportService = game:GetService("TeleportService")
    local GuiService = game:GetService("GuiService")

    local isReconnecting = false
    local maxRetries = 10
    local retryDelay = 3

    local function attemptReconnect()
        if not State.autoReconnectEnabled or State.intentionalTeleport or isReconnecting then return end

        isReconnecting = true

        for attempt = 1, maxRetries do
            notify("Auto Reconnect", string.format("Reconnecting... (Attempt %d/%d)", attempt, maxRetries), 3)

            local success = false

            if not success then
                success = pcall(function()
                    TeleportService:Teleport(111446873000464, Services.Players.LocalPlayer)
                end)
            end

            if success then
                notify("Auto Reconnect", "Teleport initiated, waiting...", 2)
                task.wait(5)

                if attempt < maxRetries then
                    notify("Auto Reconnect", "Teleport failed, retrying...", 2)
                    task.wait(retryDelay)
                end
            else
                if attempt < maxRetries then
                    notify("Auto Reconnect", string.format("Failed! Retrying in %d seconds...", retryDelay), retryDelay)
                    task.wait(retryDelay)
                else
                    notify("Auto Reconnect", "Max retries reached. Please reconnect manually.", 5)
                end
            end
        end

        isReconnecting = false
    end

    local lastErrorMessage = ""

    task.spawn(function()
        while task.wait(0.5) do
            if not State.autoReconnectEnabled or State.intentionalTeleport then continue end

            local success, errorMessage = pcall(function()
                return GuiService:GetErrorMessage()
            end)

            if success and errorMessage and errorMessage ~= "" and errorMessage ~= lastErrorMessage then
                lastErrorMessage = errorMessage

                local lowerMsg = errorMessage:lower()
                if lowerMsg:find("kick") or
                   lowerMsg:find("disconnect") or
                   lowerMsg:find("banned") or
                   lowerMsg:find("removed") or
                   lowerMsg:find("lost connection") or
                   lowerMsg:find("error code") then

                    notify("Auto Reconnect", "Disconnect detected! Starting reconnection...", 2)
                    task.wait(1)
                    attemptReconnect()
                end
            end
        end
    end)
end

setupAutoReconnect()

LobbyTab:CreateToggle({
    Name = "Auto Sell Rarities",
    CurrentValue = false,
    Flag = "AutoSellRarities",
    Callback = function(Value)
        State.AutoSellRarities = Value
    end,
})

LobbyTab:CreateDropdown({
    Name = "Select Rarities To Sell",
    Options = {"Rare", "Epic", "Legendary", "Shiny"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "RaritySellerSelector",
    Info = "This won't touch locked units of any type.",
    Callback = function(Options)
        State.SelectedRaritiesToSell = Options
    end,
})

--// SHOP TAB //--

ShopTab:CreateSection("Merchant")

ShopTab:CreateToggle({
    Name = "Auto Purchase Merchant Items",
    CurrentValue = false,
    Flag = "AutoPurchaseMerchant",
    Callback = function(Value)
        State.AutoPurchaseMerchant = Value
    end,
})

ShopTab:CreateDropdown({
    Name = "Select Items To Purchase (Merchant)",
    Options = {"Dr. Megga Punk", "Cursed Finger", "Perfect Stats Key", "Stats Key", "Trait Reroll", "Ranger Crystal", "Soul Fragments", "Stat Boosters"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "MerchantPurchaseSelector",
    Callback = function(Options)
        Data.MerchantPurchaseTable = Options
    end,
})

--// JOINER TAB //--

JoinerTab:CreateSection("Story Joiner")

JoinerTab:CreateToggle({
    Name = "Auto Join Story",
    CurrentValue = false,
    Flag = "AutoStoryToggle",
    Callback = function(Value)
        State.autoJoinEnabled = Value
    end,
})

local StageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Story Stage",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryStageSelector",
    Callback = function(Option)
        State.selectedWorld = Option[1]
    end,
})

JoinerTab:CreateDropdown({
    Name = "Select Stage Chapter",
    Options = Config.chapters,
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryChapterSelector",
    Callback = function(Option)
        State.selectedChapter = Option[1]
    end,
})

JoinerTab:CreateDropdown({
    Name = "Select Stage Difficulty",
    Options = Config.difficulties,
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "StoryDifficultySelector",
    Callback = function(Option)
        State.selectedDifficulty = Option[1]
    end,
})

JoinerTab:CreateSection("Ranger Stage Joiner")

JoinerTab:CreateToggle({
    Name = "Auto Join Ranger Stage",
    CurrentValue = false,
    Flag = "AutoRangerStageToggle",
    Callback = function(Value)
        State.isAutoJoining = Value
    end,
})

local RangerStageDropdown = JoinerTab:CreateDropdown({
    Name = "Select Ranger Stage To Join",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "RangerStageSelector",
    Callback = function(Options)
        Data.selectedRawStages = {}

        for _, selectedDisplay in ipairs(Options) do
            for _, stage in ipairs(Data.availableRangerStages) do
                if stage.DisplayName == selectedDisplay then
                    table.insert(Data.selectedRawStages, stage.RawName)
                    break
                end
            end
        end
    end,
})

task.spawn(function()
    while #Data.availableRangerStages == 0 do
        task.wait(0.5)
    end

    local rangerDisplayNames = {}
    for _, stage in ipairs(Data.availableRangerStages) do
        table.insert(rangerDisplayNames, stage.DisplayName)
    end

    RangerStageDropdown:Refresh(rangerDisplayNames)
    print("Ranger stage dropdown updated with", #rangerDisplayNames, "options")
end)

JoinerTab:CreateSection("Raid Joiner")

JoinerTab:CreateToggle({
    Name = "Auto Join Raid",
    CurrentValue = false,
    Flag = "AutoRaidToggle",
    Callback = function(Value)
        State.autoJoinRaid = Value
    end,
})

local RaidSelectorDropdown = JoinerTab:CreateDropdown({
    Name = "Select Raid Stage To Join",
    Options = {},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "RaidSelector",
    Callback = function(Option)
        State.selectedRaidStages = {}

        local selectedOption
        if type(Option) == "table" then
            selectedOption = Option[1]
        else
            selectedOption = Option
        end

        for _, raid in ipairs(Data.raidData) do
            if raid.InternalStages[selectedOption] then
                table.insert(State.selectedRaidStages, raid.InternalStages[selectedOption])
                break
            end
        end
    end,
})

task.spawn(function()
    while #Data.raidData == 0 do
        task.wait(0.5)
    end

    local raidStageDisplayNames = {}
    for _, raid in ipairs(Data.raidData) do
        for _, displayName in ipairs(raid.DisplayStages) do
            table.insert(raidStageDisplayNames, displayName)
        end
    end

    RaidSelectorDropdown:Refresh(raidStageDisplayNames)
    print("Raid dropdown updated with", #raidStageDisplayNames, "options")
end)

JoinerTab:CreateSection("Challenge Joiner")

local rewardNames = {}
for _, reward in ipairs(GameObjects.itemsFolder:GetChildren()) do
    if reward:IsA("BoolValue") then
        table.insert(rewardNames, reward.Name)
    end
end

local rewardText = #rewardNames > 0 and table.concat(rewardNames, ", ") or "None"
JoinerTab:CreateLabel("Current Challenge Rewards: " .. rewardText, "gift")

JoinerTab:CreateToggle({
    Name = "Auto Join Challenge",
    CurrentValue = false,
    Flag = "AutoChallengeToggle",
    Callback = function(Value)
        State.autoChallengeEnabled = Value
    end,
})

local IgnoreChallengeDropdown = JoinerTab:CreateDropdown({
    Name = "Ignore Challenge Worlds",
    Options = {},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "IgnoreChallengeWorld",
    Callback = function(Options)
        Data.selectedChallengeWorlds = Options
    end,
})

task.spawn(function()
    while #Data.availableStories == 0 do
        task.wait(0.5)
    end

    local storyNames = {}
    for _, story in ipairs(Data.availableStories) do
        table.insert(storyNames, story.SeriesName)
    end

    StageDropdown:Refresh(storyNames)
    IgnoreChallengeDropdown:Refresh(storyNames)
    print("Story dropdown(s) updated with", #storyNames, "options")
end)

JoinerTab:CreateDropdown({
    Name = "Select Challenge Rewards",
    Options = {"Dr. Megga Punk", "Ranger Crystal", "Stats Key", "Perfect Stats Key", "Trait Reroll", "Cursed Finger"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "ChallengeRewardSelector",
    Callback = function(options)
        Data.wantedRewards = options
    end,
})

JoinerTab:CreateToggle({
    Name = "Return to Lobby on New Challenge",
    CurrentValue = false,
    Flag = "AutoReturnChallengeToggle",
    Callback = function(Value)
        State.challengeAutoReturnEnabled = Value
    end,
})

JoinerTab:CreateSection("Portal Joiner")

JoinerTab:CreateToggle({
    Name = "Auto Join Portals",
    CurrentValue = false,
    Flag = "AutoPortalToggle",
    Callback = function(Value)
        State.autoPortalEnabled = Value
        if State.autoPortalEnabled then
            State.portalUsed = false
        end
    end,
})

local PortalSelectorDropdown = JoinerTab:CreateDropdown({
    Name = "Select Portal(s) to Join",
    Options = {},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "PortalSelector",
    Callback = function(Options)
        State.selectedPortals = Options
    end,
})

task.spawn(function()
    local portalNames = {}

    local inventory = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name].Items
    if inventory then
        for _, item in ipairs(inventory:GetChildren()) do
            if item:IsA("Folder") and (item.Name:lower():find("portal") or item.Name:lower():find("tier")) and item:FindFirstChild("Amount").Value > 0 then
                table.insert(portalNames, item.Name)
            end
        end
    end
    PortalSelectorDropdown:Refresh(portalNames)
end)

JoinerTab:CreateSection("Dungeons")

JoinerTab:CreateToggle({
    Name = "Auto Join Dungeon",
    CurrentValue = false,
    Flag = "AutoDungeonToggle",
    Callback = function(Value)
        State.autoDungeonEnabled = Value
    end,
})

JoinerTab:CreateDropdown({
    Name = "Select Dungeon Difficulty",
    Options = {"Easy", "Normal", "Hell"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "AutoDungeonDifficultySelector",
    Callback = function(Option)
        State.AutoDungeonDifficultySelector = Option
    end,
})

JoinerTab:CreateSection("Calamity Joiner")

JoinerTab:CreateToggle({
    Name = "Auto Join Calamity",
    CurrentValue = false,
    Flag = "AutoCalamityToggle",
    Callback = function(Value)
        State.autoCalamityEnabled = Value
    end,
})

JoinerTab:CreateSection("Invasion Joiner")

JoinerTab:CreateToggle({
    Name = "Auto Join Bounty Hunt Invasion",
    CurrentValue = false,
    Flag = "AutoBountyHuntInvasionToggle",
    Callback = function(Value)
        State.autoBountyHuntInvasionEnabled = Value
    end,
})

JoinerTab:CreateSection("Boss Attack Joiner")

JoinerTab:CreateToggle({
    Name = "Auto Join Boss Attack",
    CurrentValue = false,
    Flag = "AutoBossAttackToggle",
    Callback = function(Value)
        State.autoBossAttackEnabled = Value
    end,
})

--// GAME TAB //--

GameTab:CreateSection("Player")

GameTab:CreateSlider({
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

GameTab:CreateToggle({
    Name = "Anti AFK (No kick message)",
    CurrentValue = false,
    Flag = "AntiAfkKickToggle",
    Info = "Prevents Roblox kick message.",
    TextScaled = false,
    Callback = function(Value)
        State.AntiAfkKickEnabled = Value
    end,
})

task.spawn(function()
    Services.Players.LocalPlayer.Idled:Connect(function()
        if State.AntiAfkKickEnabled then
            Services.VIRTUAL_USER:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            Services.VIRTUAL_USER:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end
    end)
end)

GameTab:CreateToggle({
    Name = "Low Performance Mode",
    CurrentValue = false,
    Flag = "enableLowPerformanceMode",
    Callback = function(Value)
        State.enableLowPerformanceMode = Value
        enableLowPerformanceMode()
    end,
})

GameTab:CreateToggle({
    Name = "Black Screen",
    CurrentValue = false,
    Flag = "enableBlackScreen",
    Callback = function(Value)
        State.enableBlackScreen = Value
        enableBlackScreen()
    end,
})

GameTab:CreateToggle({
    Name = "Delete Map",
    CurrentValue = false,
    Flag = "enableDeleteMap",
    Info = "Rejoin to disable.",
    TextScaled = false,
    Callback = function(Value)
        State.enableDeleteMap = Value
        enableDeleteMap()
    end,
})

GameTab:CreateToggle({
    Name = "Delete Enemies/Units",
    CurrentValue = false,
    Flag = "enableDeleteEnemies",
    Info = "Removes Unit/Enemy Models.",
    TextScaled = false,
    Callback = function(Value)
        State.deleteEntities = Value

        if Value then
            task.spawn(function()
                local agentFolder = workspace:FindFirstChild("Agent")
                if agentFolder then
                    local agentSubFolder = agentFolder:FindFirstChild("Agent")
                    if agentSubFolder then
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

GameTab:CreateToggle({
    Name = "Limit FPS",
    CurrentValue = false,
    Flag = "enableLimitFPS",
    Callback = function(Value)
        State.enableLimitFPS = Value
        updateFPSLimit()
    end,
})

GameTab:CreateSlider({
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

GameTab:CreateToggle({
    Name = "Streamer Mode (hide name/level/title)",
    CurrentValue = false,
    Flag = "streamerModeEnabled",
    Callback = function(Value)
        State.streamerModeEnabled = Value
    end,
})

if State.enableLowPerformanceMode then
    enableLowPerformanceMode()
end

if State.enableDeleteMap then
    enableDeleteMap()
end

GameTab:CreateSection("Game")

GameTab:CreateDropdown({
    Name = "AutoSell Unit",
    Options = {"No Unit", "Unit1", "Unit2", "Unit3", "Unit4", "Unit5", "Unit6"},
    CurrentOption = {"No Unit"},
    MultipleOptions = false,
    Info = "Will remove the unit as soon as cooldown is over.",
    TextScaled = false,
    Flag = "AutoSellUnitDropdown",
    Callback = function(Option)
        State.AutoSellUnitChoice = Option
    end,
})

GameTab:CreateToggle({
    Name = "Auto 1x/2x/3x Speed",
    CurrentValue = false,
    Flag = "AutoSpeedToggle",
    Callback = function(Value)
        State.AutoSelectSpeed = Value
    end,
})

GameTab:CreateDropdown({
    Name = "Select Auto Speed Value",
    Options = {"1x", "2x", "3x"},
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "AutoSpeedSelector",
    Callback = function(Options)
        State.SelectedSpeedValue = Options
    end,
})

task.spawn(function()
    while true do
        if State.AutoSelectSpeed and State.SelectedSpeedValue then
            local raw = State.SelectedSpeedValue
            local value = type(raw) == "table" and raw[1] or raw
            local clean = tostring(value):gsub("[^%d]", "")
            local speedNum = tonumber(clean)
            if speedNum then
                game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("SpeedGamepass"):FireServer(speedNum)
            end
        end
        task.wait(1)
    end
end)

GameTab:CreateToggle({
    Name = "Auto Start Game",
    CurrentValue = false,
    Flag = "AutoStartToggle",
    Callback = function(Value)
        State.autoStartEnabled = Value
    end,
})

GameTab:CreateToggle({
    Name = "Auto Vote Next",
    CurrentValue = false,
    Flag = "AutoNextToggle",
    Callback = function(Value)
        State.autoNextEnabled = Value
        if State.autoNextEnabled then
            game:GetService("ReplicatedStorage"):WaitForChild("Remote")
                :WaitForChild("Server")
                :WaitForChild("OnGame")
                :WaitForChild("Voting")
                :WaitForChild("VoteNext"):FireServer()
        end
    end,
})

GameTab:CreateToggle({
    Name = "Auto Vote Retry",
    CurrentValue = false,
    Flag = "AutoRetryToggle",
    Callback = function(Value)
        State.autoRetryEnabled = Value
        if State.autoRetryEnabled then
            game:GetService("ReplicatedStorage"):WaitForChild("Remote")
                :WaitForChild("Server")
                :WaitForChild("OnGame")
                :WaitForChild("Voting")
                :WaitForChild("VoteRetry"):FireServer()
        end
    end,
})

GameTab:CreateToggle({
    Name = "Auto Teleport to Lobby",
    CurrentValue = false,
    Flag = "AutoLobbyToggle",
    Callback = function(Value)
        State.autoReturnEnabled = Value
        if State.hasGameEnded and State.autoReturnEnabled then
            Services.TeleportService:Teleport(111446873000464, Services.Players.LocalPlayer)
        end
    end,
})

GameTab:CreateToggle({
    Name = "Disable Reward Screen UI",
    CurrentValue = false,
    Flag = "AutoDisableEndUI",
    Callback = function(Value)
        State.autoDisableEndUI = Value
    end,
})

GameTab:CreateToggle({
    Name = "Enable Game Failsafe",
    CurrentValue = false,
    Flag = "AutoFailSafeEnabled",
    Info = "Will teleport to lobby after x amount of seconds of game inactivity.",
    TextScaled = false,
    Callback = function(Value)
        State.AutoFailSafeEnabled = Value
    end,
})

GameTab:CreateSlider({
    Name = "Start Failsafe After",
    Range = {1, 3600},
    Increment = 1,
    Suffix = "seconds",
    CurrentValue = 300,
    Flag = "FailsafeSlider",
    Callback = function(Value)
        State.AutoFailSafeNumber = Value
    end,
})

GameTab:CreateSlider({
    Name = "Restart Match On Wave",
    Range = {0, 300},
    Increment = 1,
    Suffix = "wave",
    CurrentValue = 0,
    Flag = "RestartMatchOnWaveSlider",
    Info = "0 = disable",
    Callback = function(Value)
        State.RestartGameOnWave = Value
    end,
})

GameTab:CreateSlider({
    Name = "End Match On Wave",
    Range = {0, 300},
    Increment = 1,
    Suffix = "wave",
    CurrentValue = 0,
    Flag = "EndMatchOnWaveSlider",
    Info = "0 = disable",
    Callback = function(Value)
        State.EndGameOnWave = Value
    end,
})

--// AUTO PLAY TAB //--

AutoPlayTab:CreateSection("Auto Team Selector")

AutoPlayTab:CreateToggle({
    Name = "Enable team for mode",
    CurrentValue = false,
    Flag = "AutoTeamModeSlotEnabler",
    Callback = function(Value)
        State.autoTeamSlotPicker = Value
    end,
})

AutoPlayTab:CreateDropdown({
    Name = "Select mode for team 1",
    Options = {"Story", "Challenge", "Ranger", "Raid", "Boss Event", "Portal", "InfCastle", "Dungeon"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "ModeTeamSelector1",
    Callback = function(Options)
        State.modeTeamSelector1 = Options
    end,
})

AutoPlayTab:CreateDropdown({
    Name = "Select mode for team 2",
    Options = {"Story", "Challenge", "Ranger", "Raid", "Boss Event", "Portal", "InfCastle", "Dungeon"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "ModeTeamSelector2",
    Callback = function(Options)
        State.modeTeamSelector2 = Options
    end,
})

AutoPlayTab:CreateDropdown({
    Name = "Select mode for team 3",
    Options = {"Story", "Challenge", "Ranger", "Raid", "Boss Event", "Portal", "InfCastle", "Dungeon"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "ModeTeamSelector3",
    Callback = function(Options)
        State.modeTeamSelector3 = Options
    end,
})

AutoPlayTab:CreateDropdown({
    Name = "Select mode for team 4",
    Options = {"Story", "Challenge", "Ranger", "Raid", "Boss Event", "Portal", "InfCastle", "Dungeon"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "ModeTeamSelector4",
    Callback = function(Options)
        State.modeTeamSelector4 = Options
    end,
})

AutoPlayTab:CreateDropdown({
    Name = "Select mode for team 5",
    Options = {"Story", "Challenge", "Ranger", "Raid", "Boss Event", "Portal", "InfCastle", "Dungeon"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "ModeTeamSelector5",
    Callback = function(Options)
        State.modeTeamSelector5 = Options
    end,
})

AutoPlayTab:CreateSection("Auto Play")

AutoPlayTab:CreateToggle({
    Name = "Auto Play",
    CurrentValue = false,
    Flag = "AutoPlayToggle",
    Callback = function(Value)
        State.autoPlayEnabled = Value
        if State.autoPlayEnabled then
            startAutoPlay()
        end
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Delay Auto Play By",
    Range = {0, 300},
    Increment = 1,
    Suffix = "seconds",
    CurrentValue = 0,
    Flag = "AutoPlayDelaySlider",
    Callback = function(Value)
        State.AutoPlayDelayNumber = Value
    end,
})

AutoPlayTab:CreateSection("Auto Ultimate")

AutoPlayTab:CreateToggle({
    Name = "Auto Use Ultimates",
    CurrentValue = false,
    Flag = "AutoUltimate",
    Callback = function(Value)
        State.AutoUltimateEnabled = Value
        if Value then
            task.spawn(autoUltimateLoop)
        end
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Delay Ultimate Usage By",
    Range = {0, 100},
    Increment = 1,
    Suffix = "seconds",
    CurrentValue = 0,
    Flag = "DelayAutoUltimateSlider",
    Callback = function(Value)
        State.DelayAutoUltimate = Value
    end,
})

AutoPlayTab:CreateSection("Auto Upgrade")

AutoPlayTab:CreateToggle({
    Name = "Auto Upgrade Units",
    CurrentValue = false,
    Flag = "AutoUpgradeToggle",
    Callback = function(Value)
        State.autoUpgradeEnabled = Value
        if State.autoUpgradeEnabled then
            resetUpgradeOrder()
            startAutoUpgrade()
        else
            stopAutoUpgrade()
        end
    end,
})

AutoPlayTab:CreateDropdown({
    Name = "Select Upgrade Method",
    Options = {"Left to right until max"},
    CurrentOption = {"Left to right until max"},
    MultipleOptions = false,
    Flag = "UpgradeMethodSelector",
    Callback = function(Options)
        State.upgradeMethod = Options[1] or "Left to right until max"
        if State.autoUpgradeEnabled then
            stopAutoUpgrade()
            resetUpgradeOrder()
            task.wait(0.5)
            startAutoUpgrade()
        end
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Unit 1 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit1LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[1] = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Dont Deploy Unit 1 Until Level",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit1DeployCap",
    Callback = function(Value)
        Config.unitDeployLevelCaps[1] = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Unit 2 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit2LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[2] = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Dont Deploy Unit 2 Until Level",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit2DeployCap",
    Callback = function(Value)
        Config.unitDeployLevelCaps[2] = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Unit 3 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit3LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[3] = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Dont Deploy Unit 3 Until Level",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit3DeployCap",
    Callback = function(Value)
        Config.unitDeployLevelCaps[3] = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Unit 4 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit4LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[4] = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Dont Deploy Unit 4 Until Level",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit4DeployCap",
    Callback = function(Value)
        Config.unitDeployLevelCaps[4] = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Unit 5 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit5LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[5] = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Dont Deploy Unit 5 Until Level",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit5DeployCap",
    Callback = function(Value)
        Config.unitDeployLevelCaps[5] = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Unit 6 Level Cap",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 9,
    Flag = "Unit6LevelCap",
    Callback = function(Value)
        Config.unitLevelCaps[6] = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Dont Deploy Unit 6 Until Level",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit6DeployCap",
    Callback = function(Value)
        Config.unitDeployLevelCaps[6] = Value
    end,
})

AutoPlayTab:CreateSection("Auto Delete Units")

AutoPlayTab:CreateToggle({
    Name = "Auto Delete Units On Level",
    CurrentValue = false,
    Flag = "AutoReDeployToggle",
    Info = "Level 0 = disable",
    TextScaled = false,
    Callback = function(Value)
        State.AutoReDeployEnabled = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Sell Unit 1 After It Reaches",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit1ReDeployLevel",
    Callback = function(Value)
        Config.unitReDeployLevel[1] = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Sell Unit 2 After It Reaches",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit2ReDeployLevel",
    Callback = function(Value)
        Config.unitReDeployLevel[2] = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Sell Unit 3 After It Reaches",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit3ReDeployLevel",
    Callback = function(Value)
        Config.unitReDeployLevel[3] = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Sell Unit 4 After It Reaches",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit4ReDeployLevel",
    Callback = function(Value)
        Config.unitReDeployLevel[4] = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Sell Unit 5 After It Reaches",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit5ReDeployLevel",
    Callback = function(Value)
        Config.unitReDeployLevel[5] = Value
    end,
})

AutoPlayTab:CreateSlider({
    Name = "Sell Unit 6 After It Reaches",
    Range = {0, 9},
    Increment = 1,
    Suffix = " Level",
    CurrentValue = 0,
    Flag = "Unit6ReDeployLevel",
    Callback = function(Value)
        Config.unitReDeployLevel[6] = Value
    end,
})

--// WEBHOOK TAB //--

local Label5 = WebhookTab:CreateLabel("Awaiting Webhook Input...", "cable")

WebhookTab:CreateInput({
    Name = "Input Webhook",
    CurrentValue = "",
    PlaceholderText = "Input Webhook...",
    RemoveTextAfterFocusLost = false,
    Flag = "WebhookInput",
    Callback = function(Text)
        local trimmed = Text:match("^%s*(.-)%s*$")

        if trimmed == "" then
            ValidWebhook = nil
            Label5:Set("Awaiting Webhook Input...")
            return
        end

        local valid = trimmed:match("^https://discord%.com/api/webhooks/%d+/.+$")

        if valid then
            ValidWebhook = trimmed
            Label5:Set("Webhook URL set!")
        else
            ValidWebhook = nil
            Label5:Set("Invalid Webhook URL. Ensure it starts with 'https://discord.com/api/webhooks/'")
        end
    end,
})

WebhookTab:CreateInput({
    Name = "Input Discord ID (mention on rare drops)",
    CurrentValue = "",
    PlaceholderText = "Input Discord ID...",
    RemoveTextAfterFocusLost = false,
    Flag = "WebhookInputUserID",
    Callback = function(Text)
        Config.DISCORD_USER_ID = tostring(Text):match("^%s*(.-)%s*$")
    end,
})

WebhookTab:CreateButton({
    Name = "Test Webhook",
    Callback = function()
        if ValidWebhook then
            sendWebhook("test")
        end
    end,
})

WebhookTab:CreateToggle({
    Name = "Send On Stage Finished",
    CurrentValue = false,
    Flag = "sendWebhookWhenStageCompleted",
    Callback = function(Value)
        State.SendStageCompletedWebhook = Value
    end,
})

WebhookTab:CreateToggle({
    Name = "Send On Auto Gear Farming Finished",
    CurrentValue = false,
    Flag = "sendWebhookWhenFinishedFarmingGear",
    Callback = function(Value)
        State.SendFinishedFarmingGearWebhook = Value
    end,
})

--// EVENTS //--

game.ReplicatedStorage.Remote.Replicate.OnClientEvent:Connect(function(...)
    local args = {...}
    if table.find(args, "Game_Start") then
        State.gameRunning = true
        resetUpgradeOrder()
        stopRetryLoop()
        stopNextLoop()

        lastCheckedLevels = {}
        processedUnits = {}

        State.retryAttempted = false
        State.NextAttempted = false
        State.hasGameEnded = false
        State.hasSentWebhook = false
        State.stageStartTime = tick()
        print("Stage started at", State.stageStartTime)
    end
end)

local rewardBuffer = {}
local rewardBufferTimer = nil

local function getItemTotal(itemName)
    local playerData = Services.ReplicatedStorage.Player_Data[Services.Players.LocalPlayer.Name]

    local dataChild = playerData.Data:FindFirstChild(itemName)
    if dataChild and (dataChild:IsA("NumberValue") or dataChild:IsA("IntValue")) then
        return dataChild.Value
    end

    local itemFolder = playerData.Items:FindFirstChild(itemName)
    if itemFolder then
        local amount = itemFolder:FindFirstChild("Amount")
        if amount then return amount.Value end
    end

    return nil
end

local function buildRewardLines()
    local lines = {}

    for _, entry in ipairs(rewardBuffer) do
        if entry.rewardType == "Rewards - Items" then
            for _, item in ipairs(entry.items) do
                local ok, name = pcall(function() return item.Name end)
                if not ok or not name then continue end

                local amountChild = item:FindFirstChild("Amount")
                local amount = amountChild and amountChild.Value or 0
                if amount <= 0 then continue end

                local total = getItemTotal(name)
                local totalText = total and string.format(" [%d total]", total) or ""

                table.insert(lines, string.format("+ %d %s%s", amount, name, totalText))
            end
        end
    end

    return #lines > 0 and table.concat(lines, "\n") or "_No rewards detected_"
end

Remotes.GameEndedUI.OnClientEvent:Connect(function(eventType, data)
    -- Win/loss detection (keeps existing behavior)
    if eventType == "GameEnded_TextAnimation" then
        if typeof(data) == "string" then
            local l = data:lower()
            if l:find("won") or l:find("win") then
                State.matchResult = "Victory"
            elseif l:find("defeat") or l:find("lost") then
                State.matchResult = "Defeat"
            else
                State.matchResult = "Unknown"
            end
            print("Match result detected:", State.matchResult)
        end
        return
    end

    -- Reward buffering
    if eventType == "Rewards - Items" and typeof(data) == "table" then
        table.insert(rewardBuffer, {
            rewardType = eventType,
            items = data
        })

        -- Cancel existing timer and reset it so we
        -- wait for all reward events to fire before sending
        if rewardBufferTimer then task.cancel(rewardBufferTimer) end
        rewardBufferTimer = task.delay(2, function()
            if not State.SendStageCompletedWebhook then
                rewardBuffer = {}
                return
            end
            sendWebhook("stage", buildRewardLines())
            rewardBuffer = {}
            rewardBufferTimer = nil
        end)
    end
end)

Services.ReplicatedStorage.Remote.Client.UI.Challenge_Updated.OnClientEvent:Connect(function()
    if State.challengeAutoReturnEnabled and not isInLobby() then
        State.pendingChallengeReturn = true
    end
end)

Remotes.GameEnd.OnClientEvent:Connect(function()
    State.hasGameEnded = true
    State.gameRunning = false
    if State.AutoFailSafeEnabled == true then
        startFailsafeAfterGameEnd()
    end
    resetUpgradeOrder()

    task.wait(0.5)
    local clearTimeStr = "Unknown"
    if State.stageStartTime then
        local dt = math.floor(tick() - State.stageStartTime)
        clearTimeStr = string.format("%d:%02d", dt // 60, dt % 60)
    end

    if State.SendStageCompletedWebhook then
    end

    State.autoPlayDelayActive = false
    State.actionTaken = false

    if State.pendingChallengeReturn and not State.actionTaken then
        notify("Challenge Return", "New challenge detected - returning to lobby")
        State.pendingChallengeReturn = false
        State.actionTaken = true
        task.delay(2, function()
            Services.TeleportService:Teleport(111446873000464, Services.Players.LocalPlayer)
        end)
        return
    end

    local TIMEOUT = 10

    local function waitForGameRunning(timeout)
        local elapsed = 0
        while elapsed < timeout do
            if State.gameRunning then
                return true
            end
            task.wait(1)
            elapsed = elapsed + 1
        end
        return false
    end

    local actions = {
        {
            enabled = State.autoRetryEnabled,
            func = function()
                print("Starting Auto Retry...")
                startRetryLoop()
            end
        },
        {
            enabled = State.autoNextEnabled,
            func = function()
                print("Starting Auto Next...")
                startNextLoop()
            end
        },
        {
            enabled = State.autoReturnEnabled,
            func = function()
                print("Teleporting to Lobby...")
                task.delay(2, function()
                    Services.TeleportService:Teleport(111446873000464, Services.Players.LocalPlayer)
                end)
            end,
            skipCheck = true
        }
    }

    task.spawn(function()
        for _, action in ipairs(actions) do
            if action.enabled then
                action.func()
                if not action.skipCheck then
                    local success = waitForGameRunning(TIMEOUT)
                    if success then
                        print("Game restarted successfully.")
                        return
                    else
                        print("Action failed to restart game, moving to next...")
                    end
                end
            end
        end
        print("All actions tried.")
    end)
end)

Rayfield:LoadConfiguration()
Rayfield:SetVisibility(false)

Rayfield:TopNotify({
    Title = "UI is hidden",
    Content = "The UI has automatically closed. Press the 'Show' button to enable visibility.",
    Image = "eye-off",
    IconColor = Color3.fromRGB(100, 150, 255),
    Duration = 5
})
