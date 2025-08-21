local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configuration
local WEBHOOK_URL = "https://discord.com/api/webhooks/1407420078936555661/7E-51z4CbFv_fRRfda_uuFAasZg9jbqBH1cDD0ODA9VFD7EFx0lui781-WzkDFMNAi-V" -- Replace with your actual webhook URL
local CHECK_INTERVAL = 0.1 -- Check every 0.1 seconds
local ITEM_LOAD_DELAY = 4 -- Wait for all items to load
local WEBHOOK_COOLDOWN = 10 -- Seconds between allowed webhook sends

-- Items you want to be pinged for
local WATCHLIST = {
    "True Hogyoku",
    "Skill Box",
    "Hogyoku Fragment",
    "Cybernetic Box",
    "Skill Box Chooser"
}

-- Variables
local isMonitoring = false
local connection
local lastTextScrollerCount = 0
local lastWebhookTime = 0

-- Function: check if a text matches watchlist
local function hasWatchedItem(textLabels)
    for _, text in ipairs(textLabels) do
        for _, item in ipairs(WATCHLIST) do
            if string.find(string.lower(text), string.lower(item)) then
                return true
            end
        end
    end
    return false
end

-- Function: send webhook with ALL items, ping only if watchlist item found
local function sendWebhook(textLabels)
    if WEBHOOK_URL == "YOUR_WEBHOOK_URL_HERE" then
        warn("⚠️ WEBHOOK_URL not set! Please replace it with your actual webhook")
        return
    end

    local currentTime = tick()
    if currentTime - lastWebhookTime < WEBHOOK_COOLDOWN then
        print("⏳ Webhook on cooldown")
        return
    end

    -- Check if any watched items are present
    local shouldPing = hasWatchedItem(textLabels)

    print("🔄 Sending webhook with", #textLabels, "items | Ping:", shouldPing)

    local description, fields = "", {}
    for i, text in ipairs(textLabels) do
        description = description .. text .. "\n"
        if i <= 25 then
            table.insert(fields, {
                name = "Item " .. i,
                value = text,
                inline = true
            })
        end
    end

    if #description > 4000 then
        description = string.sub(description, 1, 4000) .. "..."
    end

    local data = {
        content = shouldPing and "@everyone 🎉 **Watched Item Detected!**" or nil,
        username = "Item Detector",
        embeds = {{
            title = shouldPing and "📜 Watched Item(s) Found!" or "📜 Items Detected",
            description = description,
            fields = fields,
            color = shouldPing and 16711680 or 65280, -- Red if ping, green otherwise
            footer = { text = "Player: " .. player.Name .. " | Game: " .. game.PlaceId },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
        }}
    }

    local jsonData = HttpService:JSONEncode(data)
    local success, response = pcall(function()
        return request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = jsonData
        })
    end)

    if success and response.Success then
        print("✅ Webhook sent successfully!")
        lastWebhookTime = currentTime
    else
        warn("❌ Failed to send webhook")
    end
end

-- Function: get text from TextScroller
local function getTextScrollerContent(textScroller)
    local textLabels = {}
    for _, child in pairs(textScroller:GetChildren()) do
        if child:IsA("TextLabel") and child.Text and child.Text ~= "" then
            table.insert(textLabels, child.Text)
            print("📝 Found text:", child.Text)
        end
    end
    return textLabels
end

-- Function: check for TextScroller
local function checkForTextScroller()
    local screenEffects = playerGui:FindFirstChild("ScreenEffects")
    if not screenEffects then return false end

    local textScrollers = {}
    for _, child in pairs(screenEffects:GetChildren()) do
        if child.Name == "TextScroller" then
            table.insert(textScrollers, child)
        end
    end

    if #textScrollers > lastTextScrollerCount then
        print("🎉 New TextScroller detected!")
        local newestTextScroller = textScrollers[#textScrollers]

        spawn(function()
            wait(ITEM_LOAD_DELAY)
            local textContent = getTextScrollerContent(newestTextScroller)
            if #textContent > 0 then
                sendWebhook(textContent)
            end
        end)

        lastTextScrollerCount = #textScrollers
        return true
    end

    lastTextScrollerCount = #textScrollers
    return false
end

-- Start monitoring
local function startMonitoring()
    if isMonitoring then
        print("⚠️ Already monitoring")
        return
    end

    isMonitoring = true
    print("🚀 Starting TextScroller monitoring...")

    local screenEffects = playerGui:FindFirstChild("ScreenEffects")
    if screenEffects then
        local currentScrollers = 0
        for _, child in pairs(screenEffects:GetChildren()) do
            if child.Name == "TextScroller" then
                currentScrollers = currentScrollers + 1
            end
        end
        lastTextScrollerCount = currentScrollers
    else
        lastTextScrollerCount = 0
    end

    connection = RunService.Heartbeat:Connect(function()
        wait(CHECK_INTERVAL)
        checkForTextScroller()
    end)

    print("✅ Monitoring started! Use stopTextScrollerMonitoring() to stop")
end

-- Stop monitoring
local function stopMonitoring()
    if connection then
        connection:Disconnect()
        connection = nil
        isMonitoring = false
        print("🛑 Monitoring stopped")
    else
        print("⚠️ No monitoring active")
    end
end

-- Manual check
local function checkNow()
    print("🔍 Manual check...")
    local found = checkForTextScroller()
    if not found then print("📭 No new TextScrollers found") end
end

-- Bypass cooldown
local function bypassCooldown()
    lastWebhookTime = 0
    print("🔓 Webhook cooldown bypassed")
end

-- Expose functions
getgenv().startTextScrollerMonitoring = startMonitoring
getgenv().stopTextScrollerMonitoring = stopMonitoring
getgenv().checkTextScrollerNow = checkNow
getgenv().bypassWebhookCooldown = bypassCooldown

-- Auto-start
wait(1)
startMonitoring()
