ESX.RegisterServerCallback('esx_inventory:UseItemFromSlot', function(source, cb, slot)
    local player = ESX.GetPlayerFromId(source)
    InvType['player'].getInventory(player.identifier, function(inventory)
        if inventory[tostring(slot)] then
            local esxItem = player.getInventoryItem(inventory[tostring(slot)].name)
            if esxItem.usable then
                cb(createDisplayItem(inventory[tostring(slot)], esxItem, slot))
                return
            end
        end
        cb(nil)
    end)
end)

ESX.RegisterServerCallback('esx_inventory:GetItemsInSlotsDisplay', function(source, cb)
    local player = ESX.GetPlayerFromId(source)
    InvType['player'].getInventory(player.identifier, function(inventory)
        local slotItems = {}
        for i = 1, 5, 1 do
            local item = inventory[tostring(i)]
            if item then
                local esxItem = player.getInventoryItem(item.name)
                slotItems[i] = {
                    itemId = item.name,
                    label = esxItem.label,
                    qty = item.count,
                    slot = i
                }
            else
                slotItems[i] = nil
            end
        end
        cb(slotItems)
    end)
end)