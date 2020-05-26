secondInventory = nil

RegisterNUICallback('MoveToEmpty', function(data, cb)
    TriggerServerEvent('esx_inventory:MoveToEmpty', data)
    TriggerEvent('esx_inventory:MoveToEmpty', data)
    cb('OK')
end)

RegisterNUICallback('EmptySplitStack', function(data, cb)
    TriggerServerEvent('esx_inventory:EmptySplitStack', data)
    TriggerEvent('esx_inventory:EmptySplitStack', data)
    cb('OK')
end)

RegisterNUICallback('SplitStack', function(data, cb)
    TriggerServerEvent('esx_inventory:SplitStack', data)
    TriggerEvent('esx_inventory:SplitStack', data)
    cb('OK')
end)

RegisterNUICallback('CombineStack', function(data, cb)
    TriggerServerEvent('esx_inventory:CombineStack', data)
    TriggerEvent('esx_inventory:CombineStack', data)
    cb('OK')
end)

RegisterNUICallback('TopoffStack', function(data, cb)
    TriggerServerEvent('esx_inventory:TopoffStack', data)
    TriggerEvent('esx_inventory:TopoffStack', data)
    cb('OK')
end)

RegisterNUICallback('SwapItems', function(data, cb)
    TriggerServerEvent('esx_inventory:SwapItems', data)
    TriggerEvent('esx_inventory:SwapItems', data)
    cb('OK')
end)

RegisterNUICallback('WeightError', function()
    exports['mythic_notify']:DoHudText('error', 'Yeterli alan yok!!')
end)
RegisterNUICallback('MoneyError', function()
    exports['mythic_notify']:DoHudText('error', 'Yetersiz Bakiye !!')
end)

RegisterNetEvent('esx_inventory:refreshInventory')
AddEventHandler('esx_inventory:refreshInventory', function()
    Citizen.Wait(250)
    refreshPlayerInventory()
    if secondInventory ~= nil then
        refreshSecondaryInventory()
    end
    SendNUIMessage({
        action = "unlock"
    })
end)

function refreshPlayerInventory()
    ESX.TriggerServerCallback('esx_inventory:getPlayerInventory', function(data)
        SendNUIMessage({
            action = "setItems",
            itemList = data.inventory,
            invOwner = data.invId,
            invTier = data.invTier,
            money = {
                cash = data.cash,
                bank = data.bank,
                black_money = data.black_money
            }
        })

        TriggerServerEvent('esx_inventory:openInventory', {
            type = 'player',
            owner = ESX.GetPlayerData().identifier
        })
    end, 'player', ESX.GetPlayerData().identifier)
end

function refreshSecondaryInventory()
    ESX.TriggerServerCallback('esx_inventory:canOpenInventory', function(canOpen)
        if canOpen or secondInventory.type == 'shop' then
            ESX.TriggerServerCallback('esx_inventory:getSecondaryInventory', function(data)
                SendNUIMessage({
                    action = "setSecondInventoryItems",
                    itemList = data.inventory,
                    invOwner = data.invId,
                    invTier = data.invTier,
                    money = {
                        cash = data.cash,
                        black_money = data.black_money
                    }
                })

                SendNUIMessage({
                    action = "show",
                    type = 'secondary'
                })
                TriggerServerEvent('esx_inventory:openInventory', secondInventory)
            end, secondInventory.type, secondInventory.owner)
        else
            SendNUIMessage({
                action = "hide",
                type = 'secondary'
            })
        end
    end, secondInventory.type, secondInventory.owner)
end

function closeInventory()
    isInInventory = false
    SendNUIMessage({ action = "hide", type = 'primary' })
    SetNuiFocus(false, false)
    TriggerServerEvent('esx_inventory:closeInventory', {
        type = 'player',
        owner = ESX.GetPlayerData().identifier
    })
    if secondInventory ~= nil then
        TriggerServerEvent('esx_inventory:closeInventory', secondInventory)
    end
end

RegisterNetEvent('esx_inventory:openInventory')
AddEventHandler('esx_inventory:openInventory', function(sI)
    openInventory(sI)
end)

function openInventory(_secondInventory)
    isInInventory = true
    refreshPlayerInventory()
    SendNUIMessage({
        action = "display",
        type = "normal"
    })
    if _secondInventory ~= nil then
        secondInventory = _secondInventory
        refreshSecondaryInventory()
        SendNUIMessage({
            action = "display",
            type = 'secondary'
        })
    end
    SetNuiFocus(true, true)
end

RegisterNetEvent("esx_inventory:MoveToEmpty")
AddEventHandler("esx_inventory:MoveToEmpty", function(data)
    playPickupOrDropAnimation(data)
    playStealOrSearchAnimation(data)
end)

RegisterNetEvent("esx_inventory:EmptySplitStack")
AddEventHandler("esx_inventory:EmptySplitStack", function(data)
    playPickupOrDropAnimation(data)
    playStealOrSearchAnimation(data)
end)

RegisterNetEvent("esx_inventory:TopoffStack")
AddEventHandler("esx_inventory:TopoffStack", function(data)
    playPickupOrDropAnimation(data)
    playStealOrSearchAnimation(data)
end)

RegisterNetEvent("esx_inventory:SplitStack")
AddEventHandler("esx_inventory:SplitStack", function(data)
    playPickupOrDropAnimation(data)
    playStealOrSearchAnimation(data)
end)

RegisterNetEvent("esx_inventory:CombineStack")
AddEventHandler("esx_inventory:CombineStack", function(data)
    playPickupOrDropAnimation(data)
    playStealOrSearchAnimation(data)
end)

RegisterNetEvent("esx_inventory:SwapItems")
AddEventHandler("esx_inventory:SwapItems", function(data)
    playPickupOrDropAnimation(data)
    playStealOrSearchAnimation(data)
end)

function playPickupOrDropAnimation(data)
    if data.originTier.name == 'drop' or data.destinationTier.name == 'drop' then
        local playerPed = GetPlayerPed(-1)
        if not IsEntityPlayingAnim(playerPed, 'random@domestic', 'pickup_low', 3) then
            ESX.Streaming.RequestAnimDict('random@domestic', function()
                TaskPlayAnim(playerPed, 'random@domestic', 'pickup_low', 8.0, -8, -1, 48, 0, 0, 0, 0)
            end)
        end
    end
end

function playStealOrSearchAnimation(data)
    if data.originTier.name == 'player' and data.destinationTier.name == 'player' then
        local playerPed = GetPlayerPed(-1)
        if not IsEntityPlayingAnim(playerPed, 'random@mugging4', 'agitated_loop_a', 3) then
            ESX.Streaming.RequestAnimDict('random@mugging4', function()
                --- TaskPlayAnim(playerPed, 'random@mugging4', 'agitated_loop_a', 8.0, -8, -1, 48, 0, 0, 0, 0)
            end)
        end
    end
end
