local isInventoryOpen = false
local haveBag = false

local selectedEq = 0 --debug

Citizen.CreateThread(function()
    SetNuiFocus(false, false)                                   --for debug
    SendNUIMessage({
        type = 2                                                --hide inventory on init (for debug)
    })
    TriggerServerEvent("redemrp_inventory:playerJoined")        --Init player inventory on server side (probably event will be changed)
while true do
Wait(1)
    if IsControlJustReleased(0, 0x41AC83D1) then --LOOT2
     isInventoryOpen = not isInventoryOpen

     if isInventoryOpen then
        --TriggerServerEvent("redemrp_inventory:itemsList", 1, -1) open only player inventory
        TriggerServerEvent("redemrp_inventory:itemsList", 1, selectedEq) -- open player inventory and smth like chest with id = selectedEq (id is assigned on server side)
        SetNuiFocus(true, true)
     else
        SendNUIMessage({
            type = 2                                            --hide inventory
        })
        SetNuiFocus(false, false)
     end
       
    end
end

end)

RegisterNetEvent("redemrp_inventory:itemsList")
AddEventHandler("redemrp_inventory:itemsList", function(eventType, data, right, secondInventoryId)
    print('veta')
        SendNUIMessage({
            type = eventType,                           -- show/hide inventory HUD
            showLeft = true,                            --show player inventory
            showMiddle = haveBag,                       -- not yet
            showRight = right,                          --show other inventory 
            items = data,                               --items list
            secondInventory = secondInventoryId           --server side id of second inventory
        })

end)

RegisterNUICallback('sendItems', function(data)
    TriggerServerEvent("redemrp_inventory:update", data) -- send items back to the server with assigned inventory to it
end)

RegisterNUICallback('close', function()                  --unfocus HUD
    SetNuiFocus(false, false)  
    isInventoryOpen = false
end)


RegisterCommand('addItem', function(source, args, rawCommand)
    TriggerServerEvent('temp:addItem', args[1], args[2]) --AddItem <id> <quantity> --this command is temporary (for testing) add will be deleted
end)

RegisterCommand('changeEq', function(source, args, rawCommand)
   selectedEq = tonumber(args[1])
end)

--DEBUG

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} \n'
    else
       return tostring(o)
    end
 end