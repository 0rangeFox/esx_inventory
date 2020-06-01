Citizen.CreateThread(function()
    TriggerEvent('esx_inventory:RegisterInventory', {
        name = 'glovebox',
        label = _U('glove'),
        slots = 15,
        maxWeight = Config.GloveboxMaxWeight
    })
end)
