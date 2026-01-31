local DataStoreService = game:GetService("DataStoreService")
local statsStore = DataStoreService:GetDataStore("PlayerStats")

game.Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player


    local iq = Instance.new("IntValue")
    iq.Name = "IQ"
    iq.Parent = leaderstats

    local level = Instance.new("IntValue")
    level.Name = "Level"
    level.Parent = leaderstats

    -- Load stats
    local key = "player_" .. player.UserId
    local success, data = pcall(function()
        return statsStore:GetAsync(key)
    end)
    if success and data then
        iq.Value = data.IQ or 0
        level.Value = data.Level or 1
    else
        iq.Value = 0
        level.Value = 1
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local key = "player_" .. player.UserId
        local data = {
            IQ = leaderstats.IQ.Value,
            Level = leaderstats.Level.Value
        }
        pcall(function()
            statsStore:SetAsync(key, data)
        end)
    end
end)