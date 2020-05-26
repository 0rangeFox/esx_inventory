local drops = {}

Citizen.CreateThread(function()
    TriggerEvent('esx_inventory:RegisterInventory', {
        name = 'drop',
        label = _U('drop'),
        slots = 50,
        maxweight = 1000
    })
end)

MySQL.ready(function()
    if Config.DeleteDropsOnStart then
        MySQL.Async.execute('DELETE FROM inventories WHERE type = \'drop\'')
    end
end)

function updateDrops()
    MySQL.Async.fetchAll('SELECT * FROM inventories WHERE type = \'drop\'', {}, function(results)
        drops = {}
        for k, v in pairs(results) do
            drops[v.owner] = json.decode(v.data)
        end
        TriggerClientEvent('esx_inventory:updateDrops', -1, drops)
    end)
end

Citizen.CreateThread(function()
    Citizen.Wait(5000)
    updateDrops()
end)

AddEventHandler('esx:playerLoaded', function(data)
    Citizen.Wait(0)
    updateDrops()
end)

RegisterServerEvent('esx_inventory:modifiedInventory')
AddEventHandler('esx_inventory:modifiedInventory', function(identifier, type, data)
    if type == 'drop' then
        drops[identifier] = data
        TriggerClientEvent('esx_inventory:updateDrops', -1, drops)
    end
end)

RegisterServerEvent('esx_inventory:savedInventory')
AddEventHandler('esx_inventory:savedInventory', function(identifier, type, data)
    if type == 'drop' then
        drops[identifier] = data
        TriggerClientEvent('esx_inventory:updateDrops', -1, drops)
    end
end)

RegisterServerEvent('esx_inventory:createdInventory')
AddEventHandler('esx_inventory:createdInventory', function(identifier, type, data)
    if type == 'drop' then
        drops[identifier] = data
        TriggerClientEvent('esx_inventory:updateDrops', -1, drops)
    end
end)

RegisterServerEvent('esx_inventory:deletedInventory')
AddEventHandler('esx_inventory:deletedInventory', function(identifier, type)
    if type == 'drop' then
        drops[identifier] = nil
        TriggerClientEvent('esx_inventory:updateDrops', -1, drops)
    end
end)
