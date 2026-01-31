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

    -- Remove old icon if exists
    local oldIcon = billboard:FindFirstChild("VendingIcon")
    if oldIcon then oldIcon:Destroy() end


    -- Add new icon
    if logo then
        local icon = Instance.new("ImageLabel")
        icon.Name = "VendingIcon"
        icon.Image = logo
        icon.Size = UDim2.new(0, 64, 0, 64)
        icon.AnchorPoint = Vector2.new(0.5, 0)
        icon.Position = UDim2.new(0.5, 0, -0.8, 0)
        icon.BackgroundTransparency = 1
        icon.Parent = billboard
    end
end

UpdateBillboardEvent.OnClientEvent:Connect(function(vendingId, logo)
    addVendingIcon(logo)
end)