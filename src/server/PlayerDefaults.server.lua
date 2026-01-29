local Players = game:GetService("Players")

-- default settings
local ServerScriptService = game:GetService("ServerScriptService")
local GameConstants = require(ServerScriptService.Constants.GameConstants)

-- function to apply settings for a player's character
local function applySettings(player)
	-- camera zoom
	player.CameraMinZoomDistance = GameConstants.PLAYER_DEFAULT_MIN_ZOOM
	player.CameraMaxZoomDistance = GameConstants.PLAYER_DEFAULT_MAX_ZOOM

	-- walkspeed
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		humanoid.WalkSpeed = GameConstants.PLAYER_DEFAULT_WALKSPEED
		humanoid.JumpPower = GameConstants.PLAYER_DEFAULT_JUMPPOWER
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
		humanoid.WalkSpeed = GameConstants.PLAYER_DEFAULT_WALKSPEED
	end)
end)

-- optional: apply to players already in game (if server script is added mid-game)
for _, player in ipairs(Players:GetPlayers()) do
	applySettings(player)
end
