RegisterNetEvent('esx_inventory:useAmmoItem')
AddEventHandler('esx_inventory:useAmmoItem', function(ammo)
    local playerPed = GetPlayerPed(-1)
    local weapon

    local found, currentWeapon = GetCurrentPedWeapon(playerPed, true)
    if found then
        for _, v in pairs(ammo.weapons) do
            if currentWeapon == v then
                weapon = v
                break
            end
        end
        if weapon ~= nil then
            local pedAmmo = GetAmmoInPedWeapon(playerPed, weapon)
            local newAmmo = pedAmmo + ammo.count
            ClearPedTasks(playerPed)
            local found, maxAmmo = GetMaxAmmo(playerPed, weapon)
            if newAmmo < maxAmmo then
                TaskReloadWeapon(playerPed)
                if Config.EnableInventoryHUD then
                    TriggerServerEvent('esx_inventory:updateAmmoCount', weapon, newAmmo)
                end
                SetPedAmmo(playerPed, weapon, newAmmo)
                TriggerServerEvent('esx_inventory:removeAmmoItem', ammo)
                exports['mythic_notify']:SendAlert('success', 'Reloaded')
            else
                exports['mythic_notify']:SendAlert('error', 'Max Ammo')
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local currentWeapon = GetSelectedPedWeapon(GetPlayerPed(-1)) --morpheause show ammo fix
        DisplayAmmoThisFrame(currentWeapon)
    end
end)
