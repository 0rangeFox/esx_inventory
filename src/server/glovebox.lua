Citizen.CreateThread(function()
    TriggerEvent('esx_inventory:RegisterInventory', {
        name = 'glovebox',
        label = _U('glove'),
        slots = 15,
        maxweight = Config.GloveboxMaxWeight
    })
end)
