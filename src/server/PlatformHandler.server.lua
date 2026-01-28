local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnswerEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AnswerEvent")
local platformsFolder = workspace:WaitForChild("Arena"):WaitForChild("MathPlatforms")

local GROWTH = 4
local TWEEN_TIME = 0.5
local DAMAGE = 20

-- Cache original platform sizes
local original = {}
for _, part in ipairs(platformsFolder:GetChildren()) do
	original[part.Name] = { Size = part.Size, Position = part.Position }
end

AnswerEvent.OnServerEvent:Connect(function(player, isCorrect)
	if not player:GetAttribute("InRound") then return end

	local platformName = player:GetAttribute("PlatformName")
	if not platformName then return end

	local part = platformsFolder:FindFirstChild(platformName)
	if not part then return end

	local oldSize = part.Size
	local bottomY = part.Position.Y - (oldSize.Y / 2)

	local newSize
	if isCorrect then
		newSize = oldSize + Vector3.new(GROWTH, GROWTH, 0)
	else
		local min = original[part.Name].Size
		newSize = Vector3.new(
			math.max(oldSize.X - GROWTH, min.X),
			math.max(oldSize.Y - GROWTH, min.Y),
			oldSize.Z
		)

		-- DAMAGE PLAYER HERE
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid:TakeDamage(DAMAGE)
			end
		end
	end



	local newPos = Vector3.new(
		part.Position.X,
		bottomY + newSize.Y / 2,
		part.Position.Z
	)

	TweenService:Create(
		part,
		TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ Size = newSize, Position = newPos }
	):Play()
end)