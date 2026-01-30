local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NotificationEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("NotificationEvent")

local NotificationHandler = {}

-- Optional backgroundColor parameter (Color3) supported
function NotificationHandler.Notify(player, header, description, duration, backgroundColor)
    NotificationEvent:FireClient(player, header, description, duration, backgroundColor)
end

function NotificationHandler.NotifyAll(header, description, duration, backgroundColor)
    NotificationEvent:FireAllClients(header, description, duration, backgroundColor)
end

return NotificationHandler