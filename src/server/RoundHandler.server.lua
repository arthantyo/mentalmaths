local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

-- Theme Queue Module
local ThemeRequestQueue = require(ServerScriptService.Constants.ThemeRequestQueue)

-- Game Constants Module 
local GameConstants = require(ServerScriptService.Constants.GameConstants)
local ThemeConstants = require(ReplicatedStorage.Constants.ThemeConstants)

local arena = workspace:WaitForChild("Arena")
local mathPlatformsFolder = arena:WaitForChild("MathPlatforms")

local spawnLocation = workspace:WaitForChild("SpawnLocation") -- Replace "Spawn" with your actual spawn part name

-- RemoteEvents
local RemoveMathGuiEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoveMathGuiEvent")
local ThemeChangedEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ThemeChangedEvent")

local RunService = game:GetService("RunService")
local lava = arena:WaitForChild("Lava") -- your lava part
local originalLavaPos = lava.Position


-- TODO:
-- there should be diff round themes!
-- -> user can pick their mental themes
-- there should be power ups for users to buy! such as invisble fo round:
-- -> 2x height growth
-- -> fire resistance
-- -> health
-- -> buy slow lava raise (for whole server)

-- keeps track of initial platform dimensions
local originalPlatforms = {}

for _, platform in ipairs(mathPlatformsFolder:GetChildren()) do
	originalPlatforms[platform.Name] = {
		Size = platform.Size,
		Position = platform.Position,
	}
end



local availablePlatforms = {}
local platformParts = mathPlatformsFolder:GetChildren()

table.sort(platformParts, function(a, b)
	-- extract the number from "PartX"
	local numA = tonumber(a.Name:match("Part(%d+)")) or 0
	local numB = tonumber(b.Name:match("Part(%d+)")) or 0
	return numA < numB
end)

for _, part in ipairs(platformParts) do
	table.insert(availablePlatforms, part.Name)
end

-- Values
local RoundState = Instance.new("StringValue")
RoundState.Name = "RoundState"
RoundState.Value = "Intermission"
RoundState.Parent = ReplicatedStorage

local RoundTimer = Instance.new("IntValue")
RoundTimer.Name = "RoundTimer"
RoundTimer.Value = 0
RoundTimer.Parent = ReplicatedStorage

-- Track active players
local activePlayers = {}

-- Assign platforms
local function assignPlatforms()
	activePlayers = {}

	for i, player in ipairs(Players:GetPlayers()) do
		local platformName = table.remove(availablePlatforms, 1)
		player:SetAttribute("PlatformName", platformName)
		player:SetAttribute("InRound", true)
		table.insert(activePlayers, player)

		print("assigned", platformName,player)

		-- TELEPORT PLAYER ONTO PLATFORM
		local platform = mathPlatformsFolder:FindFirstChild(platformName)
		if platform and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = player.Character.HumanoidRootPart



			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

			local LOCKED_WALKSPEED = 0
			local LOCKED_JUMPPOWER = 0

			-- inside assignPlatforms
			if humanoid then
				humanoid.WalkSpeed = LOCKED_WALKSPEED
				humanoid.JumpPower = LOCKED_JUMPPOWER
			end


			hrp.Anchored = true
			hrp.CFrame = CFrame.new(
				platform.Position.X,
				platform.Position.Y + platform.Size.Y/2 + hrp.Size.Y/2,
				platform.Position.Z
			)

			hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			task.wait(0.2) -- wait a frame
			hrp.Anchored = false
			-- Places player right on top of the platform
		end
	end
end


local function restoreMovement(player)
	if player.Character then
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = GameConstants.PLAYER_DEFAULT_WALKSPEED
			humanoid.JumpPower = GameConstants.PLAYER_DEFAULT_JUMPPOWER
		end
	end
end


-- Clear players
local function clearPlayers()
	for _, player in ipairs(Players:GetPlayers()) do
		player:SetAttribute("PlatformName", nil)
		player:SetAttribute("InRound", false)

		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = player.Character.HumanoidRootPart
			hrp.CFrame = CFrame.new(spawnLocation.Position + Vector3.new(0, hrp.Size.Y/2, 0))
		end

		restoreMovement(player)
	end
end



local function resetPlatforms()
	for _, platform in ipairs(mathPlatformsFolder:GetChildren()) do
		local data = originalPlatforms[platform.Name]
		if data and platform.Parent then
			-- Instant tween to reset size and position
			local tween = TweenService:Create(
				platform,
				TweenInfo.new(0),  -- 0 seconds = instant
				{
					Size = data.Size,
					Position = data.Position
				}
			)
			tween:Play()
			tween.Completed:Wait()

			-- Optional: reset mesh scale if needed
			if platform:IsA("MeshPart") then
				local mesh = platform:FindFirstChildOfClass("SpecialMesh")
				if mesh then
					mesh.Scale = Vector3.new(1, 1, 1)
				end
			end
		end
	end
end


local function resetAvailablePlatforms()
	availablePlatforms = {}
	for _, part in ipairs(platformParts) do
		table.insert(availablePlatforms, part.Name)
	end
end


-- MAIN LOOP
task.spawn(function()
	while true do
		-- INTERMISSION
		lava.Position = originalLavaPos
		RoundState.Value = "Intermission"
		for i = GameConstants.INTERMISSION_TIME, 0, -1 do
			RoundTimer.Value = i
			task.wait(1)
		end

		-- PROCESS THEME REQUEST QUEUE
		local nextTheme = ThemeRequestQueue:GetNextTheme()
		local themeData

		if nextTheme then
			-- Handle the next theme (e.g., apply it to the round)
			print("Next theme chosen by ", nextTheme.Player.Name, "is", nextTheme.Theme)

			
			themeData = ThemeConstants.Themes[nextTheme.Theme]
		else
            -- Pick a random theme if queue is empty
            local allThemes = ThemeConstants.AllThemes
            local randomTheme = allThemes[math.random(1, #allThemes)]
            themeData = randomTheme
            print("No theme in queue, picked random theme:", themeData.DisplayName)
        end


		if themeData then
            ThemeChangedEvent:FireAllClients(themeData.DisplayName, themeData.Description)
        end

		-- START ROUND
		assignPlatforms()
		RoundState.Value = "InRound"
		for i = GameConstants.ROUND_TIME, 0, -1 do
			RoundTimer.Value = i
			task.wait(1)
		end

		-- END ROUND
		RoundState.Value = "RoundEnd"
		resetPlatforms()
		clearPlayers()
		resetAvailablePlatforms() 
		task.wait(5)
	end
end)



-- Coroutine to damage players who touch lava
task.spawn(function()
	while true do
		if RoundState.Value == "InRound" then

			for _, player in ipairs(Players:GetPlayers()) do
				if player:GetAttribute("InRound") and player.Character then
					local hrp = player.Character:FindFirstChild("HumanoidRootPart")
					local humanoid = player.Character:FindFirstChild("Humanoid")

					if hrp and humanoid and humanoid.Health > 0 then
						-- Calculate lava bounds
						local lavaCFrame = lava.CFrame
						local lavaSize = lava.Size
						local lavaMin = lavaCFrame.Position - lavaSize/2
						local lavaMax = lavaCFrame.Position + lavaSize/2

						-- Calculate player bounds (HRP size)
						local hrpSize = hrp.Size
						local pPos = hrp.Position
						local playerMin = pPos - hrpSize/2
						local playerMax = pPos + hrpSize/2

						-- Check if bounding boxes overlap (AABB collision)
						if playerMax.X >= lavaMin.X and playerMin.X <= lavaMax.X
							and playerMax.Y >= lavaMin.Y and playerMin.Y <= lavaMax.Y
							and playerMax.Z >= lavaMin.Z and playerMin.Z <= lavaMax.Z then
							humanoid:TakeDamage(GameConstants.LAVA_DAMAGE)
						end
					end
				end
			end



		end
		task.wait(GameConstants.LAVA_CHECK_RATE)
	end
end)



RunService.Heartbeat:Connect(function(dt)
	if RoundState.Value == "InRound" then
		-- Move the lava up smoothly
		lava.Position = lava.Position + Vector3.new(0, GameConstants.LAVA_SPEED * dt, 0)
	end
end)



Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("InRound", false)

	player.CharacterAdded:Connect(function(character)

		local humanoid = character:WaitForChild("Humanoid")
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None


		humanoid.Died:Connect(function()
			RemoveMathGuiEvent:FireClient(player)

			restoreMovement(player)
			player:SetAttribute("InRound", false)
		end)

	end)
end)


