Citizen.CreateThread(function()
    Citizen.Wait(0)

    for _, itemAmmo in pairs(Config.Ammo) do
        ESX.RegisterUsableItem(itemAmmo.name, function(source)
            TriggerClientEvent('esx_inventory:useAmmoItem', source, itemAmmo)
        end)
    end
end)

RegisterServerEvent('esx_inventory:removeAmmoItem')
AddEventHandler('esx_inventory:removeAmmoItem', function(ammo)
    local player = ESX.GetPlayerFromId(source)
    player.removeInventoryItem(ammo.name, 1)
end)