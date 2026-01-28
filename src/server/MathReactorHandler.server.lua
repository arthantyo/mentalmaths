local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModalEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ModalEvent")
local mathReactor = workspace:WaitForChild("MathReactor")
local part = mathReactor:WaitForChild("MathReactorScanner")


-- [player] = number of touching body parts
local touchCount = {}

local function getPlayerFromHit(hit)
	local character = hit.Parent
	if not character then return nil end
	return Players:GetPlayerFromCharacter(character)
end

part.Touched:Connect(function(hit)
	local player = getPlayerFromHit(hit)
	if not player then return end

	touchCount[player] = (touchCount[player] or 0) + 1

	-- first touch → open
	if touchCount[player] == 1 then
		ModalEvent:FireClient(player, "open")
	end
end)

part.TouchEnded:Connect(function(hit)
	local player = getPlayerFromHit(hit)
	if not player then return end

	if not touchCount[player] then return end
	touchCount[player] -= 1

	-- all parts left → close
	if touchCount[player] <= 0 then
		touchCount[player] = nil
		ModalEvent:FireClient(player, "close")
	end
end)

Players.PlayerRemoving:Connect(function(player)
	touchCount[player] = nil
end)
