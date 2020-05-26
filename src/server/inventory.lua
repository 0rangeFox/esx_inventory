local openInventory = {}
loadedInventories = {}

RegisterServerEvent('esx_inventory:openInventory')
AddEventHandler('esx_inventory:openInventory', function(inventory)
    if openInventory[inventory.owner] == nil then
        openInventory[inventory.owner] = {}
    end
    openInventory[inventory.owner][source] = true
end)

RegisterServerEvent('esx_inventory:closeInventory')
AddEventHandler('esx_inventory:closeInventory', function(inventory)
    if openInventory[inventory.owner] == nil then
        openInventory[inventory.owner] = {}
    end
    if openInventory[inventory.owner][source] then
        openInventory[inventory.owner][source] = nil
    end
end)

function closeAllOpenInventoriesForSource(source)
    for k, inv in pairs(openInventory) do
        openInventory[k][source] = nil
    end
end

RegisterServerEvent('esx_inventory:refreshInventory')
AddEventHandler('esx_inventory:refreshInventory', function(owner)
    if openInventory[owner] == nil then
        openInventory[owner] = {}
    end

    for k, v in pairs(openInventory[owner]) do
        TriggerClientEvent('esx_inventory:refreshInventory', k)
    end
end)

function dumpInventory(inventory)
    for k, v in pairs(inventory) do
        print(k .. ' ' .. v.name)
    end
end

RegisterServerEvent("esx_inventory:MoveToEmpty")
AddEventHandler("esx_inventory:MoveToEmpty", function(data)
    local source = source
    handleWeaponRemoval(data, source)
    if data.originOwner == data.destinationOwner and data.originTier.name == data.destinationTier.name then
        local originInvHandler = InvType[data.originTier.name]
        originInvHandler.applyToInventory(data.originOwner, function(inventory)
            inventory[tostring(data.destinationSlot)] = inventory[tostring(data.originSlot)]
            inventory[tostring(data.originSlot)] = nil
            TriggerEvent('esx_inventory:refreshInventory', data.originOwner)
        end)
    else
        local originInvHandler = InvType[data.originTier.name]
        local destinationInvHandler = InvType[data.destinationTier.name]
        if data.originTier.name == 'shop' then
            local player = ESX.GetPlayerFromIdentifier(data.destinationOwner)
            if player.getMoney() >= data.originItem.price * data.originItem.qty then
                local deletemoney = data.originItem.price * data.originItem.qty
                player.removeInventoryItem("cash", deletemoney)
                --player.removeMoney(data.originItem.price * data.originItem.qty)       
            else
                TriggerClientEvent('esx_inventory:refreshInventory', source)
                TriggerClientEvent('esx_inventory:refreshInventory', data.target)
            end
        end

        if data.destinationTier.name == 'shop' then
            TriggerEvent('esx_inventory:refreshInventory', data.originOwner)
            TriggerEvent('esx_inventory:refreshInventory', data.destinationOwner)
            return
        end

        originInvHandler.applyToInventory(data.originOwner, function(originInventory)
            destinationInvHandler.applyToInventory(data.destinationOwner, function(destinationInventory)
                destinationInventory[tostring(data.destinationSlot)] = originInventory[tostring(data.originSlot)]
                originInventory[tostring(data.originSlot)] = nil

                if data.originTier.name == 'player' then
                    data.originItem.block = true
                    local ownerPlayer = ESX.GetPlayerFromIdentifier(data.originOwner)
                    TriggerEvent('esx_inventory:notifyImpendingRemoval', data.originItem, data.originItem.qty, ownerPlayer.source)
                    ownerPlayer.removeInventoryItem(data.originItem.id, data.originItem.qty)
                end

                if data.destinationTier.name == 'player' then
                    data.originItem.block = true
                    local destinationPlayer = ESX.GetPlayerFromIdentifier(data.destinationOwner)
                    TriggerEvent('esx_inventory:notifyImpendingAddition', data.originItem, data.originItem.qty, destinationPlayer.source)
                    destinationPlayer.addInventoryItem(data.originItem.id, data.originItem.qty)
                end
                TriggerEvent('esx_inventory:refreshInventory', data.originOwner)
                TriggerEvent('esx_inventory:refreshInventory', data.destinationOwner)
            end)
        end)
    end
end)

RegisterServerEvent("esx_inventory:SwapItems")
AddEventHandler("esx_inventory:SwapItems", function(data)
    local source = source

    handleWeaponRemoval(data, source)
    if data.originTier.name == 'shop' then
        TriggerEvent('esx_inventory:refreshInventory', data.originOwner)
        TriggerEvent('esx_inventory:refreshInventory', data.destinationOwner)
        return
    end

    if data.destinationTier.name == 'shop' then
        TriggerEvent('esx_inventory:refreshInventory', data.originOwner)
        TriggerEvent('esx_inventory:refreshInventory', data.destinationOwner)
        return
    end

    if data.originOwner == data.destinationOwner and data.originTier.name == data.destinationTier.name then
        local originInvHandler = InvType[data.originTier.name]
        originInvHandler.applyToInventory(data.originOwner, function(inventory)
            local tempItem = inventory[tostring(data.originSlot)]
            inventory[tostring(data.originSlot)] = inventory[tostring(data.destinationSlot)]
            inventory[tostring(data.destinationSlot)] = tempItem
            TriggerEvent('esx_inventory:refreshInventory', data.originOwner)
        end)
    else
        local originInvHandler = InvType[data.originTier.name]
        local destinationInvHandler = InvType[data.destinationTier.name]
        originInvHandler.applyToInventory(data.originOwner, function(originInventory)
            destinationInvHandler.applyToInventory(data.destinationOwner, function(destinationInventory)
                local tempItem = originInventory[tostring(data.originSlot)]
                originInventory[tostring(data.originSlot)] = destinationInventory[tostring(data.destinationSlot)]
                destinationInventory[tostring(data.destinationSlot)] = tempItem

                if data.originTier.name == 'player' then
                    data.originItem.block = true
                    data.destinationItem.block = true
                    local originPlayer = ESX.GetPlayerFromIdentifier(data.originOwner)
                    TriggerEvent('esx_inventory:notifyImpendingAddition', data.originItem, data.originItem.qty, originPlayer.source)
                    TriggerEvent('esx_inventory:notifyImpendingRemoval', data.destinationItem, data.destinationItem.qty, originPlayer.source)
                    originPlayer.addInventoryItem(data.originItem.id, data.originItem.qty)
                    originPlayer.removeInventoryItem(data.destinationItem.id, data.destinationItem.qty)
                end

                if data.destinationTier.name == 'player' then
                    data.originItem.block = true
                    data.destinationItem.block = true
                    local destinationPlayer = ESX.GetPlayerFromIdentifier(data.destinationOwner)
                    TriggerEvent('esx_inventory:notifyImpendingRemoval', data.originItem, data.originItem.qty, destinationPlayer.source)
                    TriggerEvent('esx_inventory:notifyImpendingAddition', data.destinationItem, data.destinationItem.qty, destinationPlayer.source)
                    destinationPlayer.removeInventoryItem(data.originItem.id, data.originItem.qty)
                    destinationPlayer.addInventoryItem(data.destinationItem.id, data.destinationItem.qty)
                end

                TriggerEvent('esx_inventory:refreshInventory', data.originOwner)
                TriggerEvent('esx_inventory:refreshInventory', data.destinationOwner)
            end)
        end)
    end
end)

RegisterServerEvent("esx_inventory:CombineStack")
AddEventHandler("esx_inventory:CombineStack", function(data)
    local source = source

    handleWeaponRemoval(data, source)
    if data.originTier.name == 'shop' then
        local player = ESX.GetPlayerFromIdentifier(data.destinationOwner)
        if player.getMoney() >= data.originItem.price * data.originQty then
            --player.removeMoney(data.originItem.price * data.originQty)
            local deletemoney = data.originItem.price * data.originQty
            player.removeInventoryItem("cash", deletemoney)
        else
            TriggerClientEvent('esx_inventory:refreshInventory', source)
            TriggerClientEvent('esx_inventory:refreshInventory', data.target)
            return
        end
    end

    if data.destinationTier.name == 'shop' then
        TriggerEvent('esx_inventory:refreshInventory', data.originOwner)
        TriggerEvent('esx_inventory:refreshInventory', data.destinationOwner)
        return
    end

    if data.originOwner == data.destinationOwner and data.originTier.name == data.destinationTier.name then
        local originInvHandler = InvType[data.originTier.name]
        originInvHandler.applyToInventory(data.originOwner, function(inventory)
            inventory[tostring(data.originSlot)] = nil
            inventory[tostring(data.destinationSlot)].count = data.destinationQty
            TriggerEvent('esx_inventory:refreshInventory', data.originOwner)
        end)
    else
        local originInvHandler = InvType[data.originTier.name]
        local destinationInvHandler = InvType[data.destinationTier.name]
        originInvHandler.applyToInventory(data.originOwner, function(originInventory)
            destinationInvHandler.applyToInventory(data.destinationOwner, function(destinationInventory)
                originInventory[tostring(data.originSlot)] = nil
                destinationInventory[tostring(data.destinationSlot)].count = data.destinationQty

                if data.originTier.name == 'player' then
                    data.originItem.block = true
                    local originPlayer = ESX.GetPlayerFromIdentifier(data.originOwner)
                    TriggerEvent('esx_inventory:notifyImpendingRemoval', data.originItem, data.originItem.qty, originPlayer.source)
                    originPlayer.removeInventoryItem(data.originItem.id, data.originItem.qty)
                end

                if data.destinationTier.name == 'player' then
                    data.originItem.block = true
                    local destinationPlayer = ESX.GetPlayerFromIdentifier(data.destinationOwner)
                    TriggerEvent('esx_inventory:notifyImpendingAddition', data.originItem, data.originItem.qty, destinationPlayer.source)
                    destinationPlayer.addInventoryItem(data.originItem.id, data.originItem.qty)
                end

                TriggerEvent('esx_inventory:refreshInventory', data.originOwner)
                TriggerEvent('esx_inventory:refreshInventory', data.destinationOwner)
            end)
        end)
    end
end)

RegisterServerEvent("esx_inventory:TopoffStack")
AddEventHandler("esx_inventory:TopoffStack", function(data)
    local source = source

    handleWeaponRemoval(data, source)
    if data.originTier.name == 'shop' then
        local player = ESX.GetPlayerFromIdentifier(data.destinationOwner)
        if player.getMoney() >= data.originItem.price * data.originQty then
            --player.removeMoney(data.originItem.price * data.originQty)
            local deletemoney = data.originItem.price * data.originQty
            player.removeInventoryItem("cash", deletemoney)

        else
            TriggerClientEvent('esx_inventory:refreshInventory', source)
            TriggerClientEvent('esx_inventory:refreshInventory', data.target)
            return
        end
    end

    if data.destinationTier.name == 'shop' then
        TriggerEvent('esx_inventory:refreshInventory', data.originOwner)
        TriggerEvent('esx_inventory:refreshInventory', data.destinationOwner)
        return
    end

    if data.originOwner == data.destinationOwner and data.originTier.name == data.destinationTier.name then
        local originInvHandler = InvType[data.originTier.name]
        originInvHandler.applyToInventory(data.originOwner, function(inventory)
            inventory[tostring(data.originSlot)].count = data.originItem.qty
            inventory[tostring(data.destinationSlot)].count = data.destinationItem.qty
            TriggerEvent('esx_inventory:refreshInventory', data.originOwner)
        end)
    else
        local originInvHandler = InvType[data.originTier.name]
        local destinationInvHandler = InvType[data.destinationTier.name]
        originInvHandler.applyToInventory(data.originOwner, function(originInventory)
            destinationInvHandler.applyToInventory(data.destinationOwner, function(destinationInventory)
                originInventory[tostring(data.originSlot)].count = data.originItem.qty
                destinationInventory[tostring(data.destinationSlot)].count = data.destinationItem.qty

                if data.originTier.name == 'player' then
                    data.originItem.block = true
                    local originPlayer = ESX.GetPlayerFromIdentifier(data.originOwner)
                    TriggerEvent('esx_inventory:notifyImpendingRemoval', data.originItem, data.originItem.qty, originPlayer.source)
                    originPlayer.removeInventoryItem(data.originItem.id, data.originItem.qty)
                end

                if data.destinationTier.name == 'player' then
                    data.originItem.block = true
                    local destinationPlayer = ESX.GetPlayerFromIdentifier(data.destinationOwner)
                    TriggerEvent('esx_inventory:notifyImpendingAddition', data.originItem, data.originItem.qty, destinationPlayer.source)
                    destinationPlayer.addInventoryItem(data.originItem.id, data.originItem.qty)
                end

                TriggerEvent('esx_inventory:refreshInventory', data.originOwner)
                TriggerEvent('esx_inventory:refreshInventory', data.destinationOwner)
            end)
        end)
    end
end)

RegisterServerEvent("esx_inventory:EmptySplitStack")
AddEventHandler("esx_inventory:EmptySplitStack", function(data)
    handleWeaponRemoval(data, source)
    if data.originTier.name == 'shop' then
        local player = ESX.GetPlayerFromIdentifier(data.destinationOwner)
        if player.getMoney() >= data.originItem.price * data.moveQty then
            --player.removeMoney(data.originItem.price * data.moveQty)
            local deletemoney = data.originItem.price * data.moveQty
            player.removeInventoryItem("cash", deletemoney)
        else
            TriggerClientEvent('esx_inventory:refreshInventory', source)
            TriggerClientEvent('esx_inventory:refreshInventory', data.target)
            return
        end
    end

    if data.destinationTier.name == 'shop' then
        TriggerEvent('esx_inventory:refreshInventory', data.originOwner)
        TriggerEvent('esx_inventory:refreshInventory', data.destinationOwner)
        return
    end

    local source = source
    if data.originOwner == data.destinationOwner and data.originTier.name == data.destinationTier.name then
        local originInvHandler = InvType[data.originTier.name]

        originInvHandler.applyToInventory(data.originOwner, function(inventory)
            inventory[tostring(data.originSlot)].count = inventory[tostring(data.originSlot)].count - data.moveQty
            local item = inventory[tostring(data.originSlot)]
            inventory[tostring(data.destinationSlot)] = {
                name = item.name,
                count = data.moveQty
            }
            TriggerEvent('esx_inventory:refreshInventory', data.originOwner)
        end)
    else
        local originInvHandler = InvType[data.originTier.name]
        local destinationInvHandler = InvType[data.destinationTier.name]
        originInvHandler.applyToInventory(data.originOwner, function(originInventory)
            destinationInvHandler.applyToInventory(data.destinationOwner, function(destinationInventory)
                originInventory[tostring(data.originSlot)].count = originInventory[tostring(data.originSlot)].count - data.moveQty
                local item = originInventory[tostring(data.originSlot)]
                destinationInventory[tostring(data.destinationSlot)] = {
                    name = item.name,
                    count = data.moveQty
                }

                if data.originTier.name == 'player' then
                    local originPlayer = ESX.GetPlayerFromIdentifier(data.originOwner)
                    data.originItem.block = true
                    TriggerEvent('esx_inventory:notifyImpendingRemoval', data.originItem, data.moveQty, originPlayer.source)
                    originPlayer.removeInventoryItem(data.originItem.id, data.moveQty)
                end

                if data.destinationTier.name == 'player' then
                    local destinationPlayer = ESX.GetPlayerFromIdentifier(data.destinationOwner)
                    data.originItem.block = true
                    TriggerEvent('esx_inventory:notifyImpendingAddition', data.originItem, data.moveQty, destinationPlayer.source)
                    destinationPlayer.addInventoryItem(data.originItem.id, data.moveQty)
                end
                TriggerEvent('esx_inventory:refreshInventory', data.originOwner)
                TriggerEvent('esx_inventory:refreshInventory', data.destinationOwner)
            end)
        end)
    end
end)

RegisterServerEvent("esx_inventory:SplitStack")
AddEventHandler("esx_inventory:SplitStack", function(data)
    local source = source
    handleWeaponRemoval(data, source)

    if data.originTier.name == 'shop' then
        local player = ESX.GetPlayerFromIdentifier(data.destinationOwner)
        if player.getMoney() >= data.originItem.price * data.moveQty then
            --player.removeMoney(data.originItem.price * data.moveQty)
            local deletemoney = data.originItem.price * data.moveQty
            player.removeInventoryItem("cash", deletemoney)
        else
            TriggerClientEvent('esx_inventory:refreshInventory', source)
            TriggerClientEvent('esx_inventory:refreshInventory', data.target)
            return
        end
    end

    if data.destinationTier.name == 'shop' then
        TriggerEvent('esx_inventory:refreshInventory', data.originOwner)
        TriggerEvent('esx_inventory:refreshInventory', data.destinationOwner)
        return
    end

    if data.originOwner == data.destinationOwner and data.originTier.name == data.destinationTier.name then
        local originInvHandler = InvType[data.originTier.name]
        originInvHandler.applyToInventory(data.originOwner, function(inventory)
            inventory[tostring(data.originSlot)].count = inventory[tostring(data.originSlot)].count - data.moveQty
            inventory[tostring(data.destinationSlot)].count = inventory[tostring(data.destinationSlot)].count + data.moveQty
            TriggerEvent('esx_inventory:refreshInventory', data.originOwner)
        end)
    else
        local originInvHandler = InvType[data.originTier.name]
        local destinationInvHandler = InvType[data.destinationTier.name]
        originInvHandler.applyToInventory(data.originOwner, function(originInventory)
            destinationInvHandler.applyToInventory(data.destinationOwner, function(destinationInventory)
                originInventory[tostring(data.originSlot)].count = originInventory[tostring(data.originSlot)].count - data.moveQty
                destinationInventory[tostring(data.destinationSlot)].count = destinationInventory[tostring(data.destinationSlot)].count + data.moveQty

                if data.originTier.name == 'player' then
                    data.originItem.block = true
                    local originPlayer = ESX.GetPlayerFromIdentifier(data.originOwner)
                    TriggerEvent('esx_inventory:notifyImpendingRemoval', data.originItem, data.moveQty, originPlayer.source)
                    originPlayer.removeInventoryItem(data.originItem.id, data.moveQty)
                end

                if data.destinationTier.name == 'player' then
                    data.originItem.block = true
                    local destinationPlayer = ESX.GetPlayerFromIdentifier(data.destinationOwner)
                    TriggerEvent('esx_inventory:notifyImpendingAddition', data.originItem, data.moveQty, destinationPlayer.source)
                    destinationPlayer.addInventoryItem(data.originItem.id, data.moveQty)
                end
                TriggerEvent('esx_inventory:refreshInventory', data.originOwner)
                TriggerEvent('esx_inventory:refreshInventory', data.destinationOwner)
            end)
        end)
    end
end)

function debugData(data)
    for k, v in pairs(data) do
        print(k .. ' ' .. v)
    end
end

function removeItemFromSlot(inventory, slot, count)
    if inventory[tostring(slot)].count - count > 0 then
        inventory[tostring(slot)].count = inventory[tostring(slot)].count - count
        return
    else
        inventory[tostring(slot)] = nil
        return
    end
end

function removeItemFromInventory(item, count, inventory)
    for k, v in pairs(inventory) do
        if v.name == item.name then
            if v.count - count < 0 then
                local tempCount = inventory[k].count
                inventory[k] = nil
                count = count - tempCount
            elseif v.count - count > 0 then
                inventory[k].count = inventory[k].count - count
                return
            elseif v.count - count == 0 then
                inventory[k] = nil
                return
            else
                print('Missing Remove condition')
            end
        end
    end
end

function addToInventory(item, type, inventory)
    local max = getItemsInfo(item.name, 'limit') or 2147483647
    if max == -1 then
        max = 2147483647
    end
    local toAdd = item.count
    toAdd = AttemptMerge(item, inventory, toAdd)
    while toAdd > 0 do
        if toAdd > 0 then
            toAdd = AddToEmpty(item, type, inventory, toAdd)
        else
            toAdd = 0
        end
    end
end

function AttemptMerge(item, inventory, count)
    local max = getItemsInfo(item.name, 'limit') or 2147483647
    if max == -1 then
        max = 2147483647
    end
    for k, v in pairs(inventory) do
        if v.name == item.name then
            if v.count + count > max then
                local tempCount = max - inventory[k].count
                inventory[tostring(k)].count = max
                count = count - tempCount
            elseif v.count + count <= max then
                inventory[tostring(k)].count = v.count + count
                return 0
            else
                print('Missing MERGE condition')
            end
        end
    end
    return count
end

function AddToEmpty(item, type, inventory, count)
    local max = getItemsInfo(item.name, 'limit') or 2147483647
    if max == -1 then
        max = 2147483647
    end
    for i = 1, InvType[type].slots, 1 do
        if inventory[tostring(i)] == nil then
            if count > max then
                inventory[tostring(i)] = item
                inventory[tostring(i)].count = max

                return count - max
            else
                inventory[tostring(i)] = item
                inventory[tostring(i)].count = count
                return 0
            end
        end
    end
    print('Inventory Overflow!')
    return 0
end

function createDisplayItem(item, esxItem, slot, price, type)
    local max = getItemsInfo(item.name, 'limit') or 2147483647
    if max == -1 then
        max = 2147483647
    end
    return {
        id = esxItem.name,
        itemId = esxItem.name,
        qty = item.count,
        slot = slot,
        label = esxItem.label,
        type = type or 'item',
        max = max,
        stackable = true,
        unique = esxItem.rare,
        usable = esxItem.usable,
        giveable = true,
        description = getItemsInfo(esxItem.name, 'description'),
        weight = getItemsInfo(esxItem.name, 'weight') or 0,
        metadata = {},
        staticMeta = {},
        canRemove = esxItem.canRemove,
        price = price or 0,
        needs = false,
        closeUi = getItemDataProperty(esxItem.name, 'closeOnUse'),
    }
end

function createItem(name, count)
    return { name = name, count = count }
end

ESX.RegisterServerCallback('esx_inventory:canOpenInventory', function(source, cb, type, identifier)
    cb(not (table.length(openInventory[identifier]) > 0) or openInventory[identifier][source])
end)

ESX.RegisterServerCallback('esx_inventory:getSecondaryInventory', function(source, cb, type, identifier)
    if InvType[type] == nil then
        print('ERROR FINDING INVENTORY TYPE:' .. type)
        return
    end
    InvType[type].getDisplayInventory(identifier, cb, source)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5 * 60 * 1000)
        saveInventories()
    end
end)

RegisterCommand('saveInventories', function(src, args, raw)
    if src == 0 then
        saveInventories()
    end
end)

function saveInventories()
    for type, inventories in pairs(loadedInventories) do
        for identifier, inventory in pairs(inventories) do
            if inventory ~= nil then
                if table.length(inventory) > 0 then
                    saveLoadedInventory(identifier, type, inventory)
                else
                    deleteInventory(identifier, type)
                end
            end
        end
    end
    RconPrint('[Disc-InventoryHud][SAVED] All Inventories' .. "\n")
end

function saveInventory(identifier, type)
    saveLoadedInventory(identifier, type, loadedInventories[type][identifier])
end

function saveLoadedInventory(identifier, type, data)
    if table.length(data) > 0 then
        MySQL.Async.execute('UPDATE inventories SET data = @data WHERE owner = @owner AND type = @type', {
            ['@owner'] = identifier,
            ['@type'] = type,
            ['@data'] = json.encode(data)
        }, function(result)
            if result == 0 then
                createInventory(identifier, type, data)
            end
            loadedInventories[type][identifier] = nil
            TriggerEvent('esx_inventory:savedInventory', identifier, type, data)
        end)
    end
end

function createInventory(identifier, type, data)
    MySQL.Async.execute('INSERT INTO inventories (owner, type, data) VALUES (@owner, @type, @data)', {
        ['@owner'] = identifier,
        ['@type'] = type,
        ['@data'] = json.encode(data)
    }, function()
        TriggerEvent('esx_inventory:createdInventory', identifier, type, data)
    end)
end

function deleteInventory(identifier, type)
    MySQL.Async.execute('DELETE FROM inventories WHERE owner = @owner AND type = @type', {
        ['@owner'] = identifier,
        ['@type'] = type
    }, function()
        TriggerEvent('esx_inventory:deletedInventory', identifier, type)
    end)
end

function getDisplayInventory(identifier, type, cb, source)
    local player = ESX.GetPlayerFromId(source)
    InvType[type].getInventory(identifier, function(inventory)
        local itemsObject = {}

        for k, v in pairs(inventory) do
            if k ~= 'cash' and k ~= 'black_money' then
                local esxItem = player.getInventoryItem(v.name)
                local item = createDisplayItem(v, esxItem, tonumber(k))
                item.usable = false
                item.giveable = false
                item.canRemove = false
                table.insert(itemsObject, item)
            end
        end
        local inv
        if type == 'player' then
            local targetPlayer = ESX.GetPlayerFromIdentifier(identifier)
            inv = {
                invId = identifier,
                invTier = InvType[type],
                inventory = itemsObject,
                cash = targetPlayer.getMoney(),
                black_money = targetPlayer.getAccount('black_money').money
            }
        else
            inv = {
                invId = identifier,
                invTier = InvType[type],
                inventory = itemsObject,
                cash = inventory['cash'] or 0,
                black_money = inventory['black_money'] or 0
            }
        end
        cb(inv)
    end)
end

function getInventory(identifier, type, cb)
    if loadedInventories[type][identifier] ~= nil then
        cb(loadedInventories[type][identifier])
    else
        loadInventory(identifier, type, cb)
    end
end

function applyToInventory(identifier, type, f)
    if loadedInventories[type][identifier] ~= nil then
        f(loadedInventories[type][identifier])
    else
        loadInventory(identifier, type, function()
            applyToInventory(identifier, type, f)
        end)
    end
    if loadedInventories[type][identifier] and table.length(loadedInventories[type][identifier]) > 0 then
        TriggerEvent('esx_inventory:modifiedInventory', identifier, type, loadedInventories[type][identifier])
    else
        TriggerEvent('esx_inventory:modifiedInventory', identifier, type, nil)
    end
end

function loadInventory(identifier, type, cb)
    MySQL.Async.fetchAll('SELECT data FROM inventories WHERE owner = @owner and type = @type', {
        ['@owner'] = identifier,
        ['@type'] = type
    }, function(result)
        if #result == 0 then
            loadedInventories[type][identifier] = {}
            cb({})
            return
        end
        inventory = json.decode(result[1].data)
        loadedInventories[type][identifier] = inventory
        cb(inventory)
        TriggerEvent('esx_inventory:loadedInventory', identifier, type, inventory)
    end)
end

function handleWeaponRemoval(data, source)
    if isWeapon(data.originItem.id) then
        if data.originOwner == data.destinationOwner and data.originTier.name == data.destinationTier.name then
            if data.destinationSlot > 5 then
                TriggerClientEvent('esx_inventory:removeCurrentWeapon', source)
            end
        else
            TriggerClientEvent('esx_inventory:removeCurrentWeapon', source)
        end
    end
end

function handleGiveWeaponRemoval(data, source)
    if isWeapon(data.originItem.id) then
        TriggerClientEvent('esx_inventory:removeCurrentWeapon', source)
    end
end
