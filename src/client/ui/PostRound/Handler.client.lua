local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PostRoundEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PostRoundEvent")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local postRoundGui = playerGui:WaitForChild("PostRoundGui")
local modal = postRoundGui:WaitForChild("Modal")
local closeButton = modal:WaitForChild("CloseButton")

-- Frames for each placement
local firstFrame = modal:WaitForChild("First")
local secondFrame = modal:WaitForChild("Second")
local thirdFrame = modal:WaitForChild("Third")

local placementFrames = {
	[1] = firstFrame,
	[2] = secondFrame,
	[3] = thirdFrame
}

-- Function to get thumbnail URL for a user
local function getThumbnailUrl(userId)
	return "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(userId) .. "&width=420&height=420&format=png"
end

-- Function to update a placement frame with player data
local function updatePlacementFrame(frame, userId, playerName)
	if not frame then return end
	
	-- Find the ImageFrame and ImageLabel inside
	local imageFrame = frame:FindFirstChild("ImageFrame")
	if imageFrame then
		local imageLabel = imageFrame:FindFirstChild("ImageLabel")
		if imageLabel then
			imageLabel.Image = getThumbnailUrl(userId)
		end
	end
	
	-- Find the TextLabel for player name
	local textLabel = frame:FindFirstChild("TextLabel")
	if textLabel then
		textLabel.Text = playerName
	end
	
	frame.Visible = true
end

-- Function to hide all placement frames
local function hideAllFrames()
	for _, frame in pairs(placementFrames) do
		frame.Visible = false
	end
end

-- Function to show the post-round modal
local function showPostRoundModal(top3Data)
	-- Hide all frames initially
	hideAllFrames()
	
	-- Update frames with player data
	for _, playerData in ipairs(top3Data) do
		local place = playerData.Place
		local userId = playerData.UserId
		local name = playerData.Name
		
		updatePlacementFrame(placementFrames[place], userId, name)
	end
	
	-- Show the modal
	postRoundGui.Enabled = true
end

-- Close button handler
closeButton.MouseButton1Click:Connect(function()
	postRoundGui.Enabled = false
	hideAllFrames()
end)

-- Listen for PostRoundEvent
PostRoundEvent.OnClientEvent:Connect(function(top3Data)
	showPostRoundModal(top3Data)
end)

-- Hide modal initially
postRoundGui.Enabled = false
hideAllFrames()
