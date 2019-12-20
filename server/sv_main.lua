inventory = {}
inventoryId = 0


Citizen.CreateThread(function()
    print("===========================================================================")
    print("WARNING! This is as stable as me after bottle of vodka!")
    print("There is still a ton of things that need do be written or even rewriten...")
    print("===========================================================================")

    --TEMP
    local chest1 = addPickup({{name="I'm a pen", description = "I'm killing machine", weight = 6, amount = 8, metainfo = "{}", imgsrc="items/wide-blade-knife.png", box=2}}) -- create "CHEST" (return chest id)
    local chest2 = addPickup({{name="pillow", description = "", weight = 550, amount = 1, metainfo = "{}", imgsrc="items/aguila-machete.png", box=2}, {name="bread", description = "you can eat me", weight = 200, amount = 8, metainfo = "{}", imgsrc="items/semi-auto-shotgun.png", box=2}}) -- create "CHEST" 
    --END TEMP

while false do 
    Wait(3600) -- there will be autosave thread
end
end)



RegisterServerEvent("redemrp_inventory:playerJoined")           --load user inventory to server ram
AddEventHandler("redemrp_inventory:playerJoined", function() 
local _source = source                                          

    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        
        local identifier = user.getIdentifier()                 --get player identifier
        local characterid = user.getSessionVar("charid")        --get player character that is in use
        for i,k in pairs(inventory) do
            if k.identifier == identifier then                  --if is in ram already then return
                return
            end
        end
        MySQL.Async.fetchAll('SELECT name, description, weight, amount, metainfo, imgsrc from character_inventory INNER JOIN items ON items.itemid = character_inventory.itemid WHERE `identifier`=@identifier AND `characterid`=@characterid;', {identifier = identifier, characterid = characterid}, function(result)
            table.insert(inventory,  {identifier = identifier, characterid = characterid, items = result}) -- save player inventory to server ram           
        end)
        

    end)
end)


RegisterServerEvent("redemrp_inventory:itemsList")                    --get user items from server ram
AddEventHandler("redemrp_inventory:itemsList", function(eventType, secondInventory, bag) 
    local _source = source
    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        for i,k in pairs(inventory) do
            if k.identifier == identifier then
                if secondInventory == -1 then
                    TriggerClientEvent("redemrp_inventory:itemsList", _source, eventType, k.items, nil)
                    return
                else
                    for j,n in pairs(inventory) do
                        if n.identifier == secondInventory then
                            local allItems = k.items
                            for g,v in pairs(n.items) do table.insert(allItems, v) end
                            TriggerClientEvent("redemrp_inventory:itemsList", _source, eventType, allItems, true, secondInventory)
                            return
                        end
                    end
                end
            end
        end
    end)
end)


RegisterServerEvent("redemrp_inventory:update")                    --update user inventory
AddEventHandler("redemrp_inventory:update", function(data) 
    local _source = source                                          

    TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
        local identifier = user.getIdentifier()
        local characterid = user.getSessionVar("charid")
        
        for i,k in pairs(inventory) do
            if k.identifier == identifier and k.characterid == characterid then
                --check items                 
                --IN NEAREST FUTURE
                --srutututu checking if is it duplicated
                local secondInventoryId
                for j,p in pairs(inventory) do
                    if p.identifier == data.id then
                        secondInventoryId = j
                        break
                    end
                end

                k.items = {} --remove old one
                local secondInventory = {}  --buf for updated second inventory

                local bufL = {} --not used yet
                local bufM = {}
                local bufR = {}

                for j,v in pairs(data.objects) do
                    if v.box == 0 then              --player eq
                        table.insert(k.items, v)    --for now
                    elseif v.box == 1 then          --player bag
                        --not yet
                    elseif v.box == 2 then          -- other eq
                        table.insert( secondInventory, v)
                    end
                end
                inventory[secondInventoryId].items = {}
                inventory[secondInventoryId].items = secondInventory
                return
            end
        end


    end)
end)


AddEventHandler("redemrp_inventory:addItem", function(identifier, item, quantity) 

    for i,k in pairs(inventory) do
        if k.identifier == identifier then
            MySQL.Async.fetchAll('SELECT name, description, weight, imgsrc from items WHERE `itemid`=@item', {item = item}, function(result)
                if result ~= nil then
                result['amount'] = quantity
                table.insert(k.items,  result) -- add items to eq     
                print(result[1].name .. ' was added to player inventory') --debug
                end
            end)

        end
    end
end)


--FOR NOW

function addPickup( items )
    table.insert(inventory,  {identifier = inventoryId, characterid = -1, items = items})
    inventoryId = inventoryId + 1
    return (inventoryId - 1)
end


RegisterServerEvent("temp:addItem")                    --update user inventory
AddEventHandler("temp:addItem", function(item, quantity) 
local _source = source
TriggerEvent('redemrp:getPlayerFromId', _source, function(user)
    local identifier = user.getIdentifier()
    TriggerEvent("redemrp_inventory:addItem", identifier, item, quantity)
end)
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