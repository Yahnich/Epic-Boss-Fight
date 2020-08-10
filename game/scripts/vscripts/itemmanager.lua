if ItemManager == nil then
	print ( 'creating skill selection manager' )
	ItemManager = {}
	ItemManager.__index = ItemManager
end

function ItemManager:new( o )
	o = o or {}
	setmetatable( o, ItemManager )
	
	return o
end

function ItemManager:StartItemManager()
	ItemManager = self
	if IsServer() then
		CustomGameEventManager:RegisterListener('bh_request_rune_data', Context_Wrap( ItemManager, 'ProcessRuneInformation'))
		CustomGameEventManager:RegisterListener('bh_request_all_rune_data', Context_Wrap( ItemManager, 'ProcessAllRunesInformation'))
		CustomGameEventManager:RegisterListener('bh_enter_rune_slot_request', Context_Wrap( ItemManager, 'TryEnterRuneInSlot'))
	end

	print( "rune manager initialized", IsServer() )
end

function ItemManager:ProcessRuneInformation(userid, event)
	local player = PlayerResource:GetPlayer( event.PlayerID )
	local unit = EntIndexToHScript( event.entindex )
	local info = {}
	if event.inventory then
		local item = unit:GetItemInSlot( event.inventory )
		info = {itemData = item.itemData, item = item:GetName()}
	elseif event.item then
		local itemData = {}
		local slotCount = 0
		if GameRules.AbilityKV[event.item] then
			slotCount = GameRules.AbilityKV[event.item]["AvailableRuneSlots"] or 0
		end
		for i = 1, slotCount do
			itemData[i] = {}
		end
		info = {itemData = itemData, item = event.item}
	end
	if player then
		CustomGameEventManager:Send_ServerToPlayer(player, "bh_response_rune_data", info )
	end
end

function ItemManager:ProcessAllRunesInformation(userid, event)
	local player = PlayerResource:GetPlayer( event.PlayerID )
	local unit = EntIndexToHScript( event.entindex )
	local item = unit:GetItemInSlot( event.inventory )
	if item.IsRuneStone and item:IsRuneStone() then
		local info = {}
		info.itemData = {}
		info.unit = event.entindex
		info.runeType = item:GetName()
		info.runeInventory = item:GetItemSlot()
		for i = 0, 5 do
			local invItem = unit:GetItemInSlot( i )
			if invItem then
				info.itemData[i] = invItem.itemData
			end
		end
		if player then
			CustomGameEventManager:Send_ServerToPlayer(player, "bh_response_all_rune_data", info )
		end
	end
end

function ItemManager:TryEnterRuneInSlot(userid, event)
	local player = PlayerResource:GetPlayer( event.PlayerID )
	local unit = EntIndexToHScript( event.entindex )
	local item = unit:GetItemInSlot( tonumber(event.inventorySlot) )
	local runeEnt = unit:GetItemInSlot( tonumber(event.runeInventorySlot) )
	local runeSlot = event.runeItemSlot
	
	local priorLevel = 0
	if item then
		local ItemCatch = function( ... )
				local itemmodifier = unit:FindModifierByNameAndAbility( item:GetIntrinsicModifierName(), item )
				if item:GetRuneSlots() < 1 then return end
				item.itemData = item.itemData or {}
				local totalSlots = item:GetRuneSlots()
				local freeSlots = item:GetAvailableRuneSlots()
				local slotIndex = runeSlot
				local lastRune = item:GetRuneSlot(slotIndex)
				
				if lastRune and lastRune.rune_type then
					if lastRune.rune_type == runeEnt:GetName() then -- upgrade rune
						priorLevel = item.itemData[slotIndex].rune_level
					else -- replace rune
						unit:AddItemByName( lastRune.rune_type )
						for funcName, result in pairs( lastRune.funcs ) do
							itemmodifier[funcName] = function() return nil end
						end
						item.itemData[slotIndex] = {}
					end
				end
				
				item.itemData[slotIndex] = item.itemData[slotIndex] or {}
				item.itemData[slotIndex].rune_level = priorLevel
				item.itemData[slotIndex].rune_type = runeEnt:GetName()
				item.itemData[slotIndex].funcs = item.itemData[slotIndex].funcs or {}
				runeEnt:RuneProcessing( item, itemmodifier, slotIndex )
				
				local funcs = {}
				for slot, rune in pairs( item.itemData ) do
					if rune and rune.funcs then
						for func, result in pairs( rune.funcs ) do
							funcs[func] = ( funcs[func] or 0 ) + result
						end
					end
				end
				for func, result in pairs( funcs ) do
					itemmodifier[func] = function() return result end
				end
				itemmodifier:ForceRefresh()
				unit:CalculateStatBonus()
				-- unit:AddNewModifier( unit, item, item:GetIntrinsicModifierName(), {} )
				
				local charges = runeEnt:GetCurrentCharges()
				if charges > 1 then
					runeEnt:SetCurrentCharges( charges - 1 )
				else
					runeEnt:Destroy()
				end
			end
		status, err, ret = xpcall(ItemCatch, debug.traceback, self, userid, event )
		if not status  and not self.gameHasBeenBroken then
			SendErrorReport(err, self)
		end
	end
end