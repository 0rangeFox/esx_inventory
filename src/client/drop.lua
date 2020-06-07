local serverDrops = {}
local drops = {}

Citizen.CreateThread(function()
    while not ESXLoaded do
        Citizen.Wait(10)
    end

    while true do
        Citizen.Wait(1000)
        local coords = GetEntityCoords(GetPlayerPed(-1))
        for itemKey, v in pairs(serverDrops) do
            local dropCoords = getCoordsFromOwner(itemKey)
            if GetDistanceBetweenCoords(dropCoords.x, dropCoords.y, dropCoords.z, coords.x, coords.y, coords.z, true) < 20 then
                if drops[itemKey] then
                    drops[itemKey].active = true
                else
                    drops[itemKey] = {
                        name = itemKey,
                        coords = dropCoords,
                        active = true
                    }
                end
            end
        end

        for k, v in pairs(drops) do
            if v.active then
                local x, y, z = table.unpack(v.coords)
                local marker = {
                    name = v.name .. '_drop',
                    type = 2,
                    coords = vector3(x, y, z + 1.0),
                    rotate = false,
                    colour = { r = 255, b = 255, g = 255 },
                    size = vector3(0.5, 0.5, 0.5),
                }

                drops[k].active = false
                ESX.UI.Markers.Register(marker)
            else
                drops[k] = nil
                ESX.UI.Markers.Unregister(v.name .. '_drop')
            end
        end
    end
end)

RegisterNetEvent('esx_inventory:updateDrops')
AddEventHandler('esx_inventory:updateDrops', function(newDrops)
    serverDrops = newDrops
end)