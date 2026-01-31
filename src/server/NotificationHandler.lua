local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NotificationEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("NotificationEvent")

local NotificationHandler = {}

-- Optional backgroundColor parameter (Color3) supported
function NotificationHandler.Notify(player, header, description, duration, backgroundColor)
    NotificationEvent:FireClient(player, header, description, duration, backgroundColor)
    -- Play notification sound for the player
    if player and player.Character then
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://111598601002139"
        sound.Volume = 1
        sound.Parent = workspace
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 3)
    end
end

function NotificationHandler.NotifyAll(header, description, duration, backgroundColor)
    NotificationEvent:FireAllClients(header, description, duration, backgroundColor)
    -- Play notification sound for all players
    local Players = game:GetService("Players")
    for _, player in ipairs(Players:GetPlayers()) do
        if player and player.Character then
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://111598601002139"
            sound.Volume = 1
            sound.Parent = workspace
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 3)
        end
    end
end

return NotificationHandler