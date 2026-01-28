local Players = game:GetService("Players")

local function createLevelDisplay(player)
	local character = player.Character or player.CharacterAdded:Wait()
	local head = character:WaitForChild("Head")

	-- BillboardGui
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NameAndLevel"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 140, 0, 60)
	billboard.StudsOffset = Vector3.new(0, 2.6, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	-- LEVEL CONTAINER
	local levelFrame = Instance.new("Frame")
	levelFrame.Size = UDim2.new(1, 0, 0.45, 0)
	levelFrame.BackgroundTransparency = 1
	levelFrame.Parent = billboard

	-- GLOW TEXT (behind)
	local glowText = Instance.new("TextLabel")
	glowText.Size = UDim2.new(1, 0, 1, 0)
	glowText.BackgroundTransparency = 1
	glowText.Text = "Level 1"
	glowText.TextColor3 = Color3.fromRGB(255, 255, 255)
	glowText.TextTransparency = 0.5
	glowText.Font = Enum.Font.PatrickHand
	glowText.TextScaled = true
	glowText.ZIndex = 1
	glowText.Parent = levelFrame

	-- MAIN TEXT (front)
	local mainText = Instance.new("TextLabel")
	mainText.Size = UDim2.new(1, 0, 1, 0)
	mainText.BackgroundTransparency = 1
	mainText.Text = "Level 1"
	mainText.TextColor3 = Color3.fromRGB(255, 255, 255)
	mainText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	mainText.TextStrokeTransparency = 0
	mainText.Font = Enum.Font.PatrickHand
	mainText.TextScaled = true
	mainText.ZIndex = 2
	mainText.Parent = levelFrame



	-- NAME (BOTTOM)
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.55, 0)
	nameLabel.Position = UDim2.new(0, 0, 0.45, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.DisplayName or player.Name
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Font = Enum.Font.PatrickHand
	nameLabel.TextScaled = true
	nameLabel.Parent = billboard
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)

		local humanoid = character:WaitForChild("Humanoid")
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

		createLevelDisplay(player)

		humanoid.Died:Connect(function()
	
			player:SetAttribute("InRound", false)
		end)

	end)
end)

