RegisterNetEvent('esx_inventory:useAmmoItem')
AddEventHandler('esx_inventory:useAmmoItem', function(itemAmmo)
    local playerPed = GetPlayerPed(-1)
    local currentWeapon = GetSelectedPedWeapon(playerPed)
    local weapon
    if currentWeapon ~= nil then
        for _, vWeapon in pairs(itemAmmo.weapons) do
            if currentWeapon == GetHashKey(vWeapon) then
                weapon = vWeapon
                break   
            end
        end

        if weapon ~= nil then
            local pedAmmo = GetAmmoInPedWeapon(playerPed, weapon)
            local newAmmo = pedAmmo + itemAmmo.count

            ClearPedTasks(playerPed)

            local found, maxAmmo = GetMaxAmmo(playerPed, weapon)
            if newAmmo < maxAmmo then
                TaskReloadWeapon(playerPed)
                TriggerServerEvent('esx_inventory:updateAmmoCount', weapon, newAmmo)
                SetPedAmmo(playerPed, weapon, newAmmo)
                TriggerServerEvent('esx_inventory:removeAmmoItem', itemAmmo)
                ESX.ShowNotification('Reloaded')
                --exports['mythic_notify']:SendAlert('success', 'Reloaded')
            else
                ESX.ShowNotification('Max ammo')
                --exports['mythic_notify']:SendAlert('error', 'Max Ammo')
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local currentWeapon = GetSelectedPedWeapon(GetPlayerPed(-1)) -- Morpheause show ammo fix
        DisplayAmmoThisFrame(currentWeapon)
    end
end)
