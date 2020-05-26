RegisterCommand('search', function(source, args, raw)
    TriggerClientEvent('esx_inventory:search', source)
end)

RegisterCommand('steal', function(source, args, raw)
    TriggerClientEvent('esx_inventory:steal', source)
end)

ESX.RegisterServerCallback('esx_inventory:getIdentifier', function(source, cb, serverid)
    cb(ESX.GetPlayerFromId(source).identifier)
end)
