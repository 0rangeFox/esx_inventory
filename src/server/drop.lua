local drops = {}

function createPickUp(name, count, coords, cb)
    local itemLabel = ESX.GetItemLabel(name)
    local pickupLabel = ('~y~%s~s~ [~b~%s~s~]'):format(itemLabel, count)
    cb(ESX.CreatePickup('item_standard', name, count, pickupLabel, coords))
end

Citizen.CreateThread(function()
    TriggerEvent('esx_inventory:RegisterInventory', {
        name = 'drop',
        label = _U('drop'),
        slots = 50,
        maxWeight = 1000
    })
end)

MySQL.ready(function()
    if Config.DeleteDropsOnStart then
        MySQL.Async.execute('DELETE FROM inventories WHERE type=@type', {
            ['@type'] = 'drop'
        })
    else
        MySQL.Async.fetchAll('SELECT owner FROM inventories WHERE type=@type', {
            ['@type'] = 'drop'
        }, function(results)
            for k, result in pairs(results) do
                loadInventory(result.owner, 'drop', function(inventory)
                    local dropCoords = getCoordsFromOwner(result.owner)
                    if Config.Drops.Markers then
                        drops[result.owner] = inventory
                    end
                    if Config.Drops.Pickups then
                        for kInv, v in pairs(inventory) do
                            createPickUp(v.name, v.count, dropCoords, function(pickupId)
                                inventory[kInv].pickupId = pickupId
                                loadedInventories['drop'][result.owner][kInv] = inventory[kInv]
                            end)
                        end
                    end
                end)
            end
        end)
    end
end)

AddEventHandler('esx:playerLoaded', function(playerId)
    Citizen.Wait(1000)
    TriggerClientEvent('esx_inventory:updateDrops', playerId, drops)
end)

RegisterServerEvent('esx_inventory:modifiedInventory')
AddEventHandler('esx_inventory:modifiedInventory', function(identifier, type, data)
    if type == 'drop' then
        print('Drop | esx_inventory:modifiedInventory | Data received: ' .. json.encode(data))

        if data then
            if Config.Drops.Markers then
                drops[identifier] = data
                TriggerClientEvent('esx_inventory:updateDrops', -1, drops)
            end
            if Config.Drops.Pickups then
                local dropCoords = getCoordsFromOwner(identifier)
                for k, v in pairs(data) do
                    if not v.pickupId then
                        createPickUp(v.name, v.count, dropCoords, function(pickupId)
                            loadedInventories[type][identifier][k].pickupId = pickupId
                            TriggerEvent('esx_inventory:refreshInventory', identifier)
                        end)
                    end
                end
            end
        end
    end
end)

RegisterServerEvent('esx_inventory:savedInventory')
AddEventHandler('esx_inventory:savedInventory', function(identifier, type, data)
    if type == 'drop' then
        print('Drop | esx_inventory:savedInventory | ' .. json.encode(data))

        if data then
            if Config.Drops.Markers then
                drops[identifier] = data
                TriggerClientEvent('esx_inventory:updateDrops', -1, drops)
            end
        end
    end
end)

RegisterServerEvent('esx_inventory:createdInventory')
AddEventHandler('esx_inventory:createdInventory', function(identifier, type, data)
    if type == 'drop' then
        print('Drop | esx_inventory:createdInventory | ' .. json.encode(data))

        if data then
            if Config.Drops.Markers then
                drops[identifier] = data
                TriggerClientEvent('esx_inventory:updateDrops', -1, drops)
            end
        end
    end
end)

RegisterServerEvent('esx_inventory:deletedInventory')
AddEventHandler('esx_inventory:deletedInventory', function(identifier, type)
    if type == 'drop' then
        print('Drop | esx_inventory:deletedInventory')

        if Config.Drops.Markers then
            drops[identifier] = nil
            TriggerClientEvent('esx_inventory:updateDrops', -1, drops)
        end
    end
end)
