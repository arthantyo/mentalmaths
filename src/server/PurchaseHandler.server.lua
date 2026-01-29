local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerScriptService = game:GetService("ServerScriptService")

local ThemeRequestQueue = require(ServerScriptService.Constants.ThemeRequestQueue)

-- RemoteEvents in ReplicatedStorage
local MathReactorPurchaseEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("MathReactorPurchaseEvent")
--local VendingMachinePurchaseEvent = ReplicatedStorage:WaitForChild("VendingMachinePurchaseEvent")

-- map choices to Developer Product IDs
local mathReactorProducts = {
    SUBTRACTION_AND_ADDITION = 3523889485,
    MULTIPLICATION_AND_DIVISION = 3523889752,
    MIXED = 3523890377,
    FRACTION = 3523890517,
}

--local vendingMachineProducts = {
--	ChoiceA = 56789012, -- replace with your VendingMachine Dev Product IDs
--	ChoiceB = 67890123,
--	ChoiceC = 78901234,
--}



-- handle MathReactor purchases
MathReactorPurchaseEvent.OnServerEvent:Connect(function(player, themeId)
    local productId = mathReactorProducts[themeId]
    if not productId then return end

    MarketplaceService:PromptProductPurchase(player, productId)
    ThemeRequestQueue:AddQueue(player, themeId)
end)

-- handle VendingMachine purchases
-- VendingMachinePurchaseEvent.OnServerEvent:Connect(function(player, choiceName)
-- 	local productId = vendingMachineProducts[choiceName]
-- 	if not productId then return end

-- 	MarketplaceService:PromptProductPurchase(player, productId)
-- end)
