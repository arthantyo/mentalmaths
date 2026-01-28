local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Server values
local RoundTimer = ReplicatedStorage:WaitForChild("RoundTimer")
local RoundState = ReplicatedStorage:WaitForChild("RoundState")

-- UI
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = playerGui:WaitForChild("TopGui")
local countdownLabel = gui:WaitForChild("Countdown")
local statusLabel = gui:WaitForChild("LoopStatus")
local descriptionLabel = gui:WaitForChild("Description") -- NEW

-- Helper to format timer nicely (optional)
local function formatTime(seconds)
	return tostring(seconds)
	-- If you want minutes:seconds: return string.format("%02d:%02d", math.floor(seconds/60), seconds%60)
end

-- Update countdown text
local function updateTimer()
	if RoundTimer.Value then
		countdownLabel.Text = formatTime(RoundTimer.Value)
	end
end

-- Update status text
local function updateStatus()
	local state = RoundState.Value

	if state == "Intermission" then
		statusLabel.Text = "Intermission"
		countdownLabel.Visible = true
		descriptionLabel.Text = "Sit back and relax!"

	elseif state == "InRound" then
		statusLabel.Text = "Game In Progress"
		countdownLabel.Visible = true
		descriptionLabel.Text = "Theme: Default" -- placeholder, can update dynamically

	elseif state == "RoundEnd" then
		statusLabel.Text = "Round Ending"
		countdownLabel.Visible = false
		descriptionLabel.Text = "Removing parts..."

	else
		statusLabel.Text = state
		countdownLabel.Visible = true
		descriptionLabel.Text = "" -- fallback
	end
end

-- Initial update
updateTimer()
updateStatus()

-- Listen for changes
RoundTimer.Changed:Connect(updateTimer)
RoundState.Changed:Connect(updateStatus)
