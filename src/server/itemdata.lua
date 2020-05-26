local itemData = {}
local itemsinfo = {}

Citizen.CreateThread(function()
    Citizen.Wait(0)
    itemData = {}
    MySQL.Async.fetchAll('SELECT * FROM inventories_itemdata', {}, function(results)
        for k, v in pairs(results) do
            itemData[v.name] = v
        end
    end)
end)

function getItemDataProperty(name, property)
    if itemData[name] and itemData[name][property] then
        return itemData[name][property]
    else
        return nil
    end
end

Citizen.CreateThread(function()
    Citizen.Wait(0)
    MySQL.Async.fetchAll('SELECT * FROM items', {}, function(results)
        for k, v in pairs(results) do
            itemsinfo[v.name] = v
        end
    end)
end)

function getItemsInfo(name, property)
    if itemsinfo[name] and itemsinfo[name][property] then
        return itemsinfo[name][property]
    else
        return nil
    end
end

