ESX, ESXLoaded, isInInventory, isDead = nil, false, false, false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(100)
    end

    ESX.PlayerData = ESX.GetPlayerData()
    ESXLoaded = true
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    TriggerEvent('esx_inventory:refreshInventory')
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

AddEventHandler('esx:onPlayerSpawn', function()
    isDead = false
end)

function OnPlayerDeath()
    isDead = true
    closeInventory()
end

local dropSecondaryInventory = {
    type = 'drop',
    owner = 'x123y123z123'
}

RegisterNUICallback('NUIFocusOff', function(data)
    closeInventory()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if IsControlJustReleased(0, Config.OpenControl) then
            if IsInputDisabled(0) and not isDead then
                local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
                local _, floorZ = GetGroundZFor_3dCoord(x, y, z)
                dropSecondaryInventory.owner = getOwnerFromCoords(vector3(x, y, floorZ))
                openInventory(dropSecondaryInventory)
            end
        end
    end
end)

AddEventHandler('esx:onPlayerDeath', function(data)
    OnPlayerDeath()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        closeInventory()
    end
end)




