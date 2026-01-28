local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

-- RemoteEvents in ReplicatedStorage
local MathReactorPurchaseEvent =ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("MathReactorPurchaseEvent")
--local VendingMachinePurchaseEvent = ReplicatedStorage:WaitForChild("VendingMachinePurchaseEvent")

-- map choices to Developer Product IDs
local mathReactorProducts = {
	Choice1 = 3523889485, -- replace with your MathReactor Dev Product IDs
	Choice2 = 3523889752,
	Choice3 = 3523890377,
	Choice4 = 3523890517,
}

--local vendingMachineProducts = {
--	ChoiceA = 56789012, -- replace with your VendingMachine Dev Product IDs
--	ChoiceB = 67890123,
--	ChoiceC = 78901234,
--}

-- handle MathReactor purchases
MathReactorPurchaseEvent.OnServerEvent:Connect(function(player, choiceName)
	local productId = mathReactorProducts[choiceName]
	if not productId then return end

	MarketplaceService:PromptProductPurchase(player, productId)
end)

-- handle VendingMachine purchases
-- VendingMachinePurchaseEvent.OnServerEvent:Connect(function(player, choiceName)
-- 	local productId = vendingMachineProducts[choiceName]
-- 	if not productId then return end

-- 	MarketplaceService:PromptProductPurchase(player, productId)
-- end)
