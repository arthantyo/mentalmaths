local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- local VendingMachinePurchaseEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("VendingMachinePurchaseEvent")
local ModalEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ModalEvent")
local VendingMachinePurchaseEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("VendingMachinePurchaseEvent")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("VendingMachineGui")
local frame = gui:WaitForChild("Modal")
local close = frame:WaitForChild("CloseButton")

local detailFolder = frame:WaitForChild("Detail")
local titleLabel = detailFolder:WaitForChild("ChoiceTitle")
local descLabel = detailFolder:WaitForChild("ChoiceDesc")
local logoImage = detailFolder:WaitForChild("ChoiceLogo")
local purchaseButton = detailFolder:WaitForChild("PurchaseButton")

local scrollingFrame = frame:WaitForChild("ScrollingFrame")
local itemFrames = scrollingFrame:GetChildren()

-- Get item data from shared ProductConstants
local ProductConstants = require(ReplicatedStorage:WaitForChild("Constants"):WaitForChild("ItemConstants"))
local itemData = ProductConstants
local frameToData = {}
for i, itemFrame in ipairs(itemFrames) do
    if itemFrame:IsA("ImageLabel") then
        if itemData[i] then
            frameToData[itemFrame] = itemData[i]
            -- Optionally, update the frame's UI with the data
            if itemFrame:FindFirstChild("Title") then
                itemFrame.Title.Text = itemData[i].title
            end
            if itemFrame:FindFirstChild("Desc") then
                itemFrame.Desc.Text = itemData[i].desc
            end

            if itemFrame:FindFirstChild("Logo") then
                itemFrame.Logo.Image = itemData[i].logo
            end
            
            itemFrame:SetAttribute("Price", itemData[i].price)
            itemFrame.Visible = true
        else
            itemFrame.Visible = false
        end
    end
end

local function setDetailVisible(visible)
    for _, child in ipairs(detailFolder:GetChildren()) do
        if child:IsA("GuiObject") then
            child.Visible = visible
        end
    end
end

local function highlightChoice(selected)
    for _, itemFrame in ipairs(itemFrames) do
        if itemFrame:IsA("ImageLabel") then
            if itemFrame == selected then
                itemFrame.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
                itemFrame.BorderSizePixel = 4
            else
                itemFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                itemFrame.BorderSizePixel = 3
            end
        end
    end
end

gui.ResetOnSpawn = false
gui.Enabled = false
frame.Visible = false
setDetailVisible(false)
highlightChoice(nil)
purchaseButton.Active = false
purchaseButton.AutoButtonColor = false
purchaseButton.BackgroundColor3 = Color3.fromRGB(150,150,150)
local selectedChoice = nil

-- modal open/close
ModalEvent.OnClientEvent:Connect(function(action, modalType)
    if modalType ~= "vendingmachine" then return end
    if action == "open" then
        gui.Enabled = true
        frame.Visible = true
    elseif action == "close" then
        frame.Visible = false
        gui.Enabled = false
        setDetailVisible(false)
        highlightChoice(nil)
        selectedChoice = nil
        purchaseButton.Active = false
        purchaseButton.AutoButtonColor = false
        purchaseButton.BackgroundColor3 = Color3.fromRGB(150,150,150)
    end
end)

-- clicking an item
local function onChoiceClicked(choiceFrame)
    local data = frameToData[choiceFrame]
    if not data then return end

    selectedChoice = choiceFrame

    titleLabel.Text = data.title
    descLabel.Text = data.desc
    purchaseButton.Text = "Purchase ("..data.price.." Coins)"
    logoImage.Image = data.logo

    setDetailVisible(true)
    highlightChoice(choiceFrame)

    purchaseButton.Active = true
    purchaseButton.AutoButtonColor = true
    purchaseButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
end

for _, itemFrame in ipairs(itemFrames) do
    if itemFrame:IsA("ImageLabel") then
        itemFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                onChoiceClicked(itemFrame)
            end
        end)
    end
end
-- closing modal
close.MouseButton1Click:Connect(function()
    frame.Visible = false
    gui.Enabled = false
    setDetailVisible(false)
    highlightChoice(nil)
    selectedChoice = nil
    purchaseButton.Active = false
    purchaseButton.AutoButtonColor = false
    purchaseButton.BackgroundColor3 = Color3.fromRGB(150,150,150)
end)

-- purchase button clicked
purchaseButton.MouseButton1Click:Connect(function()
    if not selectedChoice then return end
    local data = frameToData[selectedChoice]
    if not data then return end

    VendingMachinePurchaseEvent:FireServer(data.id)
end)