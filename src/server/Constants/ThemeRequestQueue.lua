local ThemeRequestQueue = {}

ThemeRequestQueue.queue = {}

function ThemeRequestQueue:AddQueue(player, themeName)
    table.insert(self.queue, {Player = player, Theme = themeName})
end

function ThemeRequestQueue:GetNextTheme()
    if #self.queue > 0 then
        return table.remove(self.queue, 1)
    end
    return nil
end

return ThemeRequestQueue