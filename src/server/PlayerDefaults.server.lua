local Players = game:GetService("Players")

-- default settings
local DEFAULT_MIN_ZOOM = 10
local DEFAULT_MAX_ZOOM = 25
local DEFAULT_WALKSPEED = 40 

-- function to apply settings for a player's character
local function applySettings(player)
	-- camera zoom
	player.CameraMinZoomDistance = DEFAULT_MIN_ZOOM
	player.CameraMaxZoomDistance = DEFAULT_MAX_ZOOM

	-- walkspeed
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		humanoid.WalkSpeed = DEFAULT_WALKSPEED
	end
end

-- when a player joins
Players.PlayerAdded:Connect(function(player)
	-- apply immediately (for CameraMinZoomDistance/Max)
	applySettings(player)

	-- apply again whenever character respawns
	player.CharacterAdded:Connect(function(char)
		-- wait a tiny bit for Humanoid to exist
		local humanoid = char:WaitForChild("Humanoid")
		humanoid.WalkSpeed = DEFAULT_WALKSPEED
	end)
end)

-- optional: apply to players already in game (if server script is added mid-game)
for _, player in ipairs(Players:GetPlayers()) do
	applySettings(player)
end
