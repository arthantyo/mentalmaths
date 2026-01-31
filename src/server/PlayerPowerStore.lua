-- PlayerPowerStore.lua
local PlayerPowerStore = {}

function PlayerPowerStore:AddPower(player, powerId)
    PlayerPowerStore[player.UserId] = PlayerPowerStore[player.UserId] or {}
    PlayerPowerStore[player.UserId][powerId] = true
end

function PlayerPowerStore:HasPower(player, powerId)
    return PlayerPowerStore[player.UserId] and PlayerPowerStore[player.UserId][powerId]
end

function PlayerPowerStore:GetPowers(player)
    return PlayerPowerStore[player.UserId] or {}
end

function PlayerPowerStore:ClearPowers(player)
    PlayerPowerStore[player.UserId] = {}
end

return PlayerPowerStore