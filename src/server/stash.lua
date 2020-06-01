Citizen.CreateThread(function()
    TriggerEvent('esx_inventory:RegisterInventory', {
        name = 'stash',
        label = _U('stash'),
        slots = 650,
        maxWeight = Config.StashMaxWeight
    })
end)
