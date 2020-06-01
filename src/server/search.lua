ESX.RegisterCommand('search', 'user', function(xPlayer, args, showError)
    TriggerClientEvent('esx_inventory:search', xPlayer.source)
end, false, {help = _U('search')})

ESX.RegisterCommand('steal', 'user', function(xPlayer, args, showError)
    TriggerClientEvent('esx_inventory:steal', xPlayer.source)
end, false, {help = _U('steal')})

ESX.RegisterServerCallback('esx_inventory:getIdentifier', function(source, cb, serverid)
    cb(ESX.GetPlayerFromId(source).identifier)
end)
