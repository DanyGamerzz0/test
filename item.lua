local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for Player_Data and Items to load
local playerData = ReplicatedStorage:WaitForChild("Player_Data"):WaitForChild(player.Name)
local itemsFolder = playerData:WaitForChild("Items")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ItemListGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
screenGui.DisplayOrder = 2147483647

-- Create draggable frame
local frame = Instance.new("Frame")
frame.Name = "ItemListFrame"
frame.Size = UDim2.new(0, 350, 0, 450)
frame.Position = UDim2.new(0.5, -175, 0.5, -225)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Add rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- Add a toggle arrow
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 30, 0, 30)
toggleButton.Position = UDim2.new(1, -35, 0, 5)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.Text = "▲"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 16
toggleButton.ZIndex = 10
toggleButton.AutoButtonColor = true
toggleButton.Parent = frame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleButton

-- Add a close X button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -70, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 100, 100)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.ZIndex = 10
closeButton.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local minimized = false

-- Add a title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "📦 Your Items"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.BorderSizePixel = 0
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 6)
titleCorner.Parent = title

-- Add search bar
local searchBox = Instance.new("TextBox")
searchBox.PlaceholderText = "Search items..."
searchBox.Text = ""
searchBox.Size = UDim2.new(1, -20, 0, 30)
searchBox.Position = UDim2.new(0, 10, 0, 45)
searchBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.TextSize = 16
searchBox.Font = Enum.Font.Gotham
searchBox.ClearTextOnFocus = false
searchBox.BorderSizePixel = 0
searchBox.Parent = frame

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 6)
searchCorner.Parent = searchBox

-- Create scrolling frame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ItemScrollFrame"
scrollFrame.Size = UDim2.new(1, 0, 1, -90)
scrollFrame.Position = UDim2.new(0, 0, 0, 80)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
scrollFrame.Parent = frame

-- Add UIListLayout to scrolling frame (once only)
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.Name
layout.Parent = scrollFrame

-- Function to populate items
local function updateItemList(filterText)
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    for _, item in ipairs(itemsFolder:GetChildren()) do
        if not filterText or string.find(string.lower(item.Name), string.lower(filterText)) then
            local itemLabel = Instance.new("TextLabel")
            itemLabel.Size = UDim2.new(1, -10, 0, 30)
            itemLabel.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            itemLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            itemLabel.Font = Enum.Font.Gotham
            itemLabel.TextSize = 16
            itemLabel.BorderSizePixel = 0

            local amount = item:FindFirstChild("Amount")
            local amountText = amount and tostring(amount.Value) or "?"
            itemLabel.Text = string.format("%s  × %s", item.Name, amountText)

            local labelCorner = Instance.new("UICorner")
            labelCorner.CornerRadius = UDim.new(0, 4)
            labelCorner.Parent = itemLabel

            itemLabel.Parent = scrollFrame
        end
    end
end

-- Debounced update
local debounceTime = 0.25
local lastUpdate = 0
local function debounceUpdate()
    local now = tick()
    if now - lastUpdate >= debounceTime then
        lastUpdate = now
        updateItemList(searchBox.Text)
    end
end

-- Connect search box
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    debounceUpdate()
end)

-- Auto-refresh when items change
itemsFolder.ChildAdded:Connect(debounceUpdate)
itemsFolder.ChildRemoved:Connect(debounceUpdate)

for _, item in ipairs(itemsFolder:GetChildren()) do
    if item:FindFirstChild("Amount") then
        item.Amount:GetPropertyChangedSignal("Value"):Connect(debounceUpdate)
    end
end

-- Minimize toggle (with tween)
local originalSize = frame.Size
local minimizedSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 50)

local function toggleMinimize()
    minimized = not minimized
    toggleButton.Text = minimized and "▼" or "▲"
    searchBox.Visible = not minimized
    scrollFrame.Visible = not minimized

    local goalSize = minimized and minimizedSize or originalSize
    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = goalSize
    }):Play()
end

toggleButton.MouseButton1Click:Connect(toggleMinimize)

-- Initial population
updateItemList("")
