local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UpdateBillboardEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpdateBillboardEvent")

local function addVendingIcon(logo)
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local head = character:FindFirstChild("Head")
    if not head then return end

    -- Wait up to 3 seconds for the BillboardGui to appear
    local billboard
    for i = 1, 30 do
        billboard = head:FindFirstChild("NameAndLevel")
        if billboard then break end
        task.wait(0.1)
    end
    if not billboard then return end

    -- Add new icon
    if logo then
        -- Count existing icons to position the new one
        local existingIcons = {}
        for _, child in ipairs(billboard:GetChildren()) do
            if child.Name == "VendingIcon" then
                table.insert(existingIcons, child)
            end
        end
        
        local iconCount = #existingIcons
        local iconSize = 64
        local iconSpacing = -30  -- Negative spacing to overlap icons slightly
        
        -- Calculate total width and starting offset
        local totalWidth = (iconCount + 1) * iconSize + iconCount * iconSpacing
        local startOffset = -totalWidth / 2 + iconSize / 2
        
        -- Reposition existing icons
        for i, existingIcon in ipairs(existingIcons) do
            local xOffset = startOffset + (i - 1) * (iconSize + iconSpacing)
            existingIcon.Position = UDim2.new(0.5, xOffset, -0.8, 0)
        end
        
        -- Add new icon at the end
        local icon = Instance.new("ImageLabel")
        icon.Name = "VendingIcon"
        icon.Image = logo
        icon.Size = UDim2.new(0, iconSize, 0, iconSize)
        icon.AnchorPoint = Vector2.new(0.5, 0)
        local xOffset = startOffset + iconCount * (iconSize + iconSpacing)
        icon.Position = UDim2.new(0.5, xOffset, -0.8, 0)
        icon.BackgroundTransparency = 1
        icon.Parent = billboard
    end
end

UpdateBillboardEvent.OnClientEvent:Connect(function(vendingId, logo)
    addVendingIcon(logo)
end)