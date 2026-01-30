local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local NotificationEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("NotificationEvent")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local notificationGui = playerGui:WaitForChild("NotificationGui")
local template = notificationGui:WaitForChild("Template")

local activeNotifications = {}

local function updateNotificationPositions()
    local yOffset = 0
    for i = 1, #activeNotifications do
        local notif = activeNotifications[i]
        notif.Position = UDim2.new(template.Position.X.Scale, template.Position.X.Offset, template.Position.Y.Scale, template.Position.Y.Offset + yOffset)
        yOffset = yOffset - notif.Size.Y.Offset - 20
    end
end

local function showNotification(headerText, descriptionText, duration, backgroundColor)
    duration = duration or 3

    -- Clone the template
    local notif = template:Clone()
    local header = notif:WaitForChild("Header")
    local desc = notif:WaitForChild("Description")
    notif.Parent = notificationGui
    notif.Visible = true
    header.Text = headerText
    desc.Text = descriptionText

    -- Optional background color
    if backgroundColor then
        notif.BackgroundColor3 = backgroundColor
    end

    -- Insert into active notifications and update positions
    table.insert(activeNotifications, notif)
    updateNotificationPositions()

    -- TweenService for fade in/out
    local TweenService = game:GetService("TweenService")
    notif.BackgroundTransparency = 1
    notif.Header.TextTransparency = 1
    notif.Description.TextTransparency = 1

    local fadeIn = TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 0})
    local fadeInHeader = TweenService:Create(notif.Header, TweenInfo.new(0.3), {TextTransparency = 0})
    local fadeInDesc = TweenService:Create(notif.Description, TweenInfo.new(0.3), {TextTransparency = 0})
    fadeIn:Play()
    fadeInHeader:Play()
    fadeInDesc:Play()

    -- Fade out after duration
    task.delay(duration, function()
        local fadeOut = TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 1})
        local fadeOutHeader = TweenService:Create(notif.Header, TweenInfo.new(0.3), {TextTransparency = 1})
        local fadeOutDesc = TweenService:Create(notif.Description, TweenInfo.new(0.3), {TextTransparency = 1})
        fadeOut:Play()
        fadeOutHeader:Play()
        fadeOutDesc:Play()
        fadeOut.Completed:Wait()
        -- Remove from active notifications and update positions
        for i, n in ipairs(activeNotifications) do
            if n == notif then
                table.remove(activeNotifications, i)
                break
            end
        end
        notif:Destroy()
        updateNotificationPositions()
    end)
end

NotificationEvent.OnClientEvent:Connect(showNotification)