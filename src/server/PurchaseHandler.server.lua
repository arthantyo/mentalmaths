local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerScriptService = game:GetService("ServerScriptService")


local ProductConstants = require(ServerScriptService.Constants.ProductConstants)
local vendingMachineProducts = ProductConstants.VendingMachineProducts
local mathReactorProducts = ProductConstants.MathReactorProducts

local ThemeRequestQueue = require(ServerScriptService.Constants.ThemeRequestQueue)
local NotificationHandler = require(ServerScriptService.NotificationHandler)
local Players = game:GetService("Players")
-- RemoteEvents in ReplicatedStorage
local MathReactorPurchaseEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("MathReactorPurchaseEvent")
local VendingMachinePurchaseEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("VendingMachinePurchaseEvent")
local UpdateBillboardEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpdateBillboardEvent")

local ItemConstants = require(ReplicatedStorage:WaitForChild("Constants"):WaitForChild("ItemConstants"))

-- store
local PlayerPowerStore = require(ServerScriptService.PlayerPowerStore)


-- map choices to Developer Product IDs


local productIdToThemeId = {}
for theme, id in pairs(mathReactorProducts) do
    productIdToThemeId[id] = theme
end

local productIdToVendingId = {}
for vendingId, productId in pairs(vendingMachineProducts) do
    productIdToVendingId[productId] = vendingId
end




-- handle MathReactor purchases
MathReactorPurchaseEvent.OnServerEvent:Connect(function(player, themeId)
    local productId = mathReactorProducts[themeId]
    if not productId then return end

    MarketplaceService:PromptProductPurchase(player, productId)
end)

-- handle purchase completion
MarketplaceService.ProcessReceipt = function(receiptInfo)
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local themeId = productIdToThemeId[receiptInfo.ProductId]
    local vendingId = productIdToVendingId[receiptInfo.ProductId]

    if themeId then
        ThemeRequestQueue:AddQueue(player, themeId)
        NotificationHandler.Notify(player, "Theme Purchased!", "Request added to the queue.", 4)
        NotificationHandler.NotifyAll(
            "Theme Purchase!",
            player.Name .. " requested a queue!",
            4,
            Color3.fromRGB(110, 223, 118)
        )

        local kachingSound = Instance.new("Sound")
        kachingSound.SoundId = "rbxassetid://71356871159392"
        kachingSound.Volume = 1
        kachingSound.Parent = workspace
        kachingSound:Play()
        game:GetService("Debris"):AddItem(kachingSound, 3)
    elseif vendingId then
        -- Check if player already has this power
        if PlayerPowerStore:HasPower(player, vendingId) then
            NotificationHandler.Notify(
                player,
                "Already Owned!",
                "You already have: " .. vendingId:gsub("_", " "):gsub("^%l", string.upper),
                4
            )
            return Enum.ProductPurchaseDecision.PurchaseGranted
        end
        
        PlayerPowerStore:AddPower(player, vendingId)

        local logo = nil
        for _, data in pairs(ItemConstants or {}) do
            if data.id == vendingId then
                logo = data.logo
                break
            end
        end

        UpdateBillboardEvent:FireClient(player, vendingId, logo)
        NotificationHandler.Notify(
            player,
            "Purchase Successful!",
            "You bought: " .. vendingId:gsub("_", " "):gsub("^%l", string.upper) .. " (for next round)",
            4
        )

        local kachingSound = Instance.new("Sound")
        kachingSound.SoundId = "rbxassetid://71356871159392"
        kachingSound.Volume = 1
        kachingSound.Parent = workspace
        kachingSound:Play()
        game:GetService("Debris"):AddItem(kachingSound, 3)
    end

    return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- handle VendingMachine purchases
VendingMachinePurchaseEvent.OnServerEvent:Connect(function(player, choiceId)
    local productId = vendingMachineProducts[choiceId]
    if not productId then return end

    -- Check if player already has this power
    if PlayerPowerStore:HasPower(player, choiceId) then
        NotificationHandler.Notify(
            player,
            "Already Owned!",
            "You already have: " .. choiceId:gsub("_", " "):gsub("^%l", string.upper),
            4
        )
        return
    end

    MarketplaceService:PromptProductPurchase(player, vendingMachineProducts[choiceId])
end)