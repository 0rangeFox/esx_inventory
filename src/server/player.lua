local impendingRemovals = {}
local impendingAdditions = {}

ESX.RegisterServerCallback('esx_inventory:getPlayerInventory', function(source, cb)
    getPlayerDisplayInventory(ESX.GetPlayerFromId(source).identifier, cb)
end)

ESX.RegisterServerCallback('esx_inventory:takePlayerItem', function(source, cb, item, count)
    local player = ESX.GetPlayerFromId(source)
    local invItem = player.getInventoryItem(item)

    if invItem.count - count < 0 then
        cb(false)
    else
        player.removeInventoryItem(item, count)
        cb(true)
    end
end)

Citizen.CreateThread(function()
    TriggerEvent('esx_inventory:RegisterInventory', {
        name = 'player',
        label = _U('player'),
        slots = 50,
        maxWeight = Config.PlayerMaxWeight,
        getInventory = function(identifier, cb)
            getInventory(identifier, 'player', cb)
        end,
        saveInventory = function(identifier, inventory)
            saveInventory(identifier, 'player', inventory)
        end
    })
end)

function getPlayerDisplayInventory(identifier, cb)
    local player = ESX.GetPlayerFromIdentifier(identifier)
    getInventory(identifier, 'player', function(inventory)
        local itemsObject = {}

        for k, v in pairs(inventory) do
            local esxItem = player.getInventoryItem(v.name)
            local item = createDisplayItem(v, esxItem, tonumber(k))
            table.insert(itemsObject, item)
        end

        local inv = {
            invId = identifier,
            invTier = InvType['player'],
            inventory = itemsObject,
            cash = player.getAccount('money').money,
            bank = player.getAccount('bank').money,
            black_money = player.getAccount('black_money').money,
        }

        cb(inv)
    end)
end

function ensurePlayerInventory(xPlayer)
    deleteInventory(xPlayer.identifier, 'player')
    Citizen.Wait(1000)

    loadInventory(xPlayer.identifier, 'player', function()
        applyToInventory(xPlayer.identifier, 'player', function(inventory)
            for _, esxItem in pairs(xPlayer.getInventory()) do
                if esxItem.count > 0 then
                    local item = createItem(esxItem.name, esxItem.count)
                    addToInventory(item, 'player', inventory)
                end
            end
            TriggerClientEvent('esx_inventory:refreshInventory', xPlayer.source)
        end)
    end)
end

RegisterServerEvent('esx_inventory:notifyImpendingRemoval')
AddEventHandler('esx_inventory:notifyImpendingRemoval', function(item, count, playerSource)
    local _source = playerSource or source
    if impendingRemovals[_source] == nil then
        impendingRemovals[_source] = {}
    end

    item.count = count
    local k = #impendingRemovals + 1
    impendingRemovals[_source][k] = item

    Citizen.CreateThread(function()
        Citizen.Wait(100)
        impendingRemovals[k] = nil
    end)
end)

RegisterServerEvent('esx_inventory:notifyImpendingAddition')
AddEventHandler('esx_inventory:notifyImpendingAddition', function(item, count, playerSource)
    local _source = playerSource or source
    if impendingAdditions[_source] == nil then
        impendingAdditions[_source] = {}
    end

    item.count = count
    local k = #impendingAdditions + 1
    impendingAdditions[_source][k] = item

    Citizen.CreateThread(function()
        Citizen.Wait(100)
        impendingAdditions[k] = nil
    end)
end)

AddEventHandler('esx:onRemoveInventoryItem', function(source, item, count)
    local player = ESX.GetPlayerFromId(source)

    TriggerClientEvent('esx_inventory:showItemUse', source, {
        {
            id = item.name,
            label = item.label,
            qty = count,
            msg = _U('removed')
        }
    })

    applyToInventory(player.identifier, 'player', function(inventory)
        if impendingRemovals[source] then
            for k, removingItem in pairs(impendingRemovals[source]) do
                if removingItem.id == item.name and removingItem.count == count then
                    if removingItem.block then
                        impendingRemovals[source][k] = nil
                    else
                        removeItemFromSlot(inventory, removingItem.slot, count)
                        impendingRemovals[source][k] = nil
                        TriggerClientEvent('esx_inventory:refreshInventory', source)
                    end
                    return
                end
            end
        end
        removeItemFromInventory(item, count, inventory)
        TriggerClientEvent('esx_inventory:refreshInventory', source)
    end)
end)

AddEventHandler('esx:onAddInventoryItem', function(source, esxItem, count)
    local player = ESX.GetPlayerFromId(source)

    TriggerClientEvent('esx_inventory:showItemUse', source, {
        {
            id = esxItem.name,
            label = esxItem.label,
            qty = count,
            msg = _U('added')
        }
    })

    applyToInventory(player.identifier, 'player', function(inventory)
        if impendingAdditions[source] then
            for k, addingItem in pairs(impendingAdditions[source]) do
                if addingItem.id == esxItem.name and addingItem.count == count then
                    if addingItem.block then
                        impendingAdditions[source][k] = nil
                        return
                    end
                end
            end
        end
        local item = createItem(esxItem.name, count)
        addToInventory(item, 'player', inventory)
        TriggerClientEvent('esx_inventory:refreshInventory', source)
    end)
end)
