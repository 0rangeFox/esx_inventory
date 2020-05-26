Citizen.CreateThread(function()
    for k, v in pairs(Config.VehicleLimit) do
        TriggerEvent('esx_inventory:RegisterInventory', {
            name = 'trunk-' .. string.upper(k),
            label = k,
            slots = v,
            maxweight = Config.VehicleWeight2[k]
        })
    end
    for k,v in pairs(Config.VehicleSlot) do
        TriggerEvent('esx_inventory:RegisterInventory', {
            name = 'trunk-' .. k,
            label = _U('trunk') .. k,
            slots = v,
            maxweight = Config.VehicleWeight[k]
        })
    end
end)
