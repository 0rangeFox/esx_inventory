ESX = nil
InvType = {
    ['unknown'] = { slots = 1, label = 'Unknown' },
}

RegisterServerEvent('esx_inventory:RegisterInventory')
AddEventHandler('esx_inventory:RegisterInventory', function(inventory)
    if inventory.name == nil then
        return
    end
    
    if inventory.slots == nil then
        inventory.slots = 5
    end

    if inventory.getInventory == nil then
        inventory.getInventory = function(identifier, cb)
            getInventory(identifier, inventory.name, cb)
        end
    end

    if inventory.applyToInventory == nil then
        inventory.applyToInventory = function(identifier, invFunction)
            applyToInventory(identifier, inventory.name, invFunction)
        end
    end

    if inventory.saveInventory == nil then
        inventory.saveInventory = function(identifier, toSave)
            if table.length(toSave) > 0 then
                saveInventory(identifier, inventory.name, toSave)
            else
                deleteInventory(identifier, inventory.name)
            end
        end
    end

    if inventory.getDisplayInventory == nil then
        inventory.getDisplayInventory = function(identifier, cb, source)
            getDisplayInventory(identifier, inventory.name, cb, source)
        end
    end

    InvType[inventory.name] = inventory
    loadedInventories[inventory.name] = {}
end)

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

ESX.RegisterServerCallback('esx_inventory:doesInvTypeExists', function(source, cb, type)
    cb(InvType[type] ~= nil)
end)

ESX.RegisterCommand({'cli', 'closeInv', 'closeInventory'}, 'user', function(xPlayer, args, showError)
    TriggerClientEvent('esx_inventory:closeInventory', xPlayer.source)
end, false, {help = _U('closeInventory')})

ESX.RegisterCommand({'ensureInv', 'ensureInventory'}, 'admin', function(xPlayer, args, showError)
    local xPlayerUpdated = xPlayer
    if args.playerId and tonumber(args.playerId) then
        xPlayerUpdated = ESX.GetPlayerFromId(args.playerId)
    end

    MySQL.Async.fetchAll('DELETE FROM inventories WHERE data = @data AND owner = @owner', {['@data'] = 'null', ['@owner'] = xPlayerUpdated.identifier })
    ensureInventories(xPlayerUpdated)
end, false, {help = _U('ensureInventory'), validate = false, arguments = {
    {name = 'playerId', help = _U('commandgeneric_playerid'), type = 'any'}
}})

function ensureInventories(xPlayer)
    ensurePlayerInventory(xPlayer)
    TriggerClientEvent('esx_inventory:refreshInventory', xPlayer.source)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        saveInventories()
    end
end)

AddEventHandler('esx:playerLoaded', function(data)
    local xPlayer = ESX.GetPlayerFromId(data)
    ensurePlayerInventory(xPlayer)
end)

Citizen.CreateThread(function()
    local players = ESX.GetPlayers()
    for k, v in ipairs(players) do
        ensurePlayerInventory(ESX.GetPlayerFromId(v))
    end
end)

AddEventHandler('esx:playerDropped', function(source)
    local player = ESX.GetPlayerFromId(source)
    saveInventory(player.identifier, 'player')
    closeAllOpenInventoriesForSource(source)
end)
