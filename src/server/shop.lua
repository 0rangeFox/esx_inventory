Citizen.CreateThread(function()
    TriggerEvent('esx_inventory:RegisterInventory', {
        name = 'shop',
        label = _U('shop'),
        slots = 50,
        maxweight = 100000,
        getInventory = function(identifier, cb)
            getShopInventory(identifier, cb)
        end,
        saveInventory = function(identifier, inventory)

        end,
        applyToInventory = function(identifier, f)
            getShopInventory(identifier, f)
        end,
        getDisplayInventory = function(identifier, cb, source)
            getShopDisplayInventory(identifier, cb, source)
        end
    })
end)

function getShopInventory(identifier, cb)
    local shop = Config.Shops[identifier]
    local items = {}

    for k, v in pairs(shop.items) do
        v.usable = false
        items[tostring(k)] = v
    end

    cb(items)
end

function getShopDisplayInventory(identifier, cb, source)
    local player = ESX.GetPlayerFromId(source)
    InvType['shop'].getInventory(identifier, function(inventory)
        local itemsObject = {}

        for k, v in pairs(inventory) do
            local esxItem = player.getInventoryItem(v.name)
            local item = createDisplayItem(v, esxItem, tonumber(k), v.price)
            local addItem = true
            if v.grade ~= nil then
                if player.job.grade < v.grade then
                    addItem = false
                end
            end
            
            if Config.CheckLicense and v.license ~= nil then
                -- { name = "ammos_pistol", price = 100, count = 1, license = "weaponlicenseone" },
                if player.getInventoryItem(v.license).count <= 0 then
                    addItem = false
                end
            end

            if addItem then
                table.insert(itemsObject, item)
            end
        end

        local inv = {
            invId = identifier,
            invTier = InvType['shop'],
            inventory = itemsObject,
            cash = 0,
            black_money = 0
        }
        cb(inv)
    end)
end
