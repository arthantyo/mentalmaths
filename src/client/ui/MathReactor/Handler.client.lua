local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ThemeConstants = require(ReplicatedStorage:WaitForChild("Constants"):WaitForChild("ThemeConstants"))

-- Event
local MathReactorPurchaseEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("MathReactorPurchaseEvent")
local ModalEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ModalEvent")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("MathReactorGui")
local frame = gui:WaitForChild("Modal")
local close = frame:WaitForChild("CloseButton")



-- detail Folder
local detailFolder = frame.Detail
local titleLabel = detailFolder.ChoiceTitle
local descLabel = detailFolder.ChoiceDesc
local purchaseButton = detailFolder.PurchaseButton

-- choice buttons
local choices = {
	frame.Choice1,
	frame.Choice2,
	frame.Choice3,
	frame.Choice4,
}

-- data for each choice
local themeList = {
    ThemeConstants.Themes.SUBTRACTION_AND_ADDITION,
    ThemeConstants.Themes.MULTIPLICATION_AND_DIVISION,
    ThemeConstants.Themes.MIXED,
    ThemeConstants.Themes.FRACTION,
}

local choiceData = {}
for i, button in ipairs(choices) do
    local theme = themeList[i]
    if theme then
        choiceData[button] = {
            title = theme.DisplayName,
            desc = theme.Description,
            price = 600, -- Example: price increases per theme, adjust as needed
            id = theme.Id,
        }
    end
end


-- helper to show/hide folder children
local function setDetailVisible(visible)
	for _, child in ipairs(detailFolder:GetChildren()) do
		if child:IsA("GuiObject") then
			child.Visible = visible
		end
	end
end

-- highlight selected choice
local function highlightChoice(selected)
	for _, button in ipairs(choices) do
		if button == selected then
			button.BorderSizePixel = 4
		else
			button.BorderSizePixel = 3
		end
	end
end

-- default state
gui.ResetOnSpawn = false
gui.Enabled = false
frame.Visible = false
setDetailVisible(false)
highlightChoice(nil)
purchaseButton.Active = false
purchaseButton.AutoButtonColor = false
purchaseButton.BackgroundColor3 = Color3.fromRGB(150,150,150) -- greyed out
local selectedChoice = nil -- track currently selected

-- modal open/close
ModalEvent.OnClientEvent:Connect(function(action, modalType)
	-- Only handle if this is the MathReactor modal
	if modalType ~= nil and modalType ~= "mathreactor" then return end
	if action == "open" then
		gui.Enabled = true
		frame.Visible = true
	elseif action == "close" then
		frame.Visible = false
		gui.Enabled = false
		setDetailVisible(false)
		highlightChoice(nil)
		selectedChoice = nil
		-- reset purchase button
		purchaseButton.Active = false
		purchaseButton.AutoButtonColor = false
		purchaseButton.BackgroundColor3 = Color3.fromRGB(150,150,150)
	end
end)

-- clicking a choice
local function onChoiceClicked(choiceButton)
	local data = choiceData[choiceButton]
	if not data then return end

	selectedChoice = choiceButton

	-- update detail info
	titleLabel.Text = data.title
	descLabel.Text = data.desc
	purchaseButton.Text = "Purchase ("..data.price.." Robux)"

	setDetailVisible(true)
	highlightChoice(choiceButton)

	-- enable purchase button
	purchaseButton.Active = true
	purchaseButton.AutoButtonColor = true
	purchaseButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255) -- match highlight
end

for _, button in ipairs(choices) do
	button.MouseButton1Click:Connect(function()
		onChoiceClicked(button)
	end)
end

-- closing modal
close.MouseButton1Click:Connect(function()
	frame.Visible = false
	gui.Enabled = false
	setDetailVisible(false)
	highlightChoice(nil)
	selectedChoice = nil
	-- reset purchase button
	purchaseButton.Active = false
	purchaseButton.AutoButtonColor = false
	purchaseButton.BackgroundColor3 = Color3.fromRGB(150,150,150)
end)

-- purchase button clicked
purchaseButton.MouseButton1Click:Connect(function()
	if not selectedChoice then return end
	local choiceName = selectedChoice.Name

	-- Fire MathReactor purchase event only
	-- In Handler.client.lua, change:
	MathReactorPurchaseEvent:FireServer(choiceData[selectedChoice].id)
end)