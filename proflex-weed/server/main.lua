local ox_inventory = exports.ox_inventory


-- Functions
function AddItem(source, item, amount)
    if ox_inventory:CanCarryItem(source, item, amount) then
        return ox_inventory:AddItem(source, item, amount)
    else
        return false
    end
end

function RemoveItem(source, item, amount)
    ox_inventory:RemoveItem(source, item, amount)
end

--callbacks

lib.callback.register('Proflex:hasItem', function(source, item)
    local hasItem = exports.ox_inventory:Search(source, 'count', item)
    return hasItem
end)

lib.callback.register('proflex:server:weeditem', function(source)
    local source = source
    AddItem(source, Config.WeedItem, Config.WeedItemAmmount)
end)

lib.callback.register('proflex:server:dryweeditem', function(source)
    local source = source
        RemoveItem(source, 'drug_weed', Config.DryingWeedAmmount)
        AddItem(source, Config.Dryingitem, Config.DryingItemAmmount)
end)

lib.callback.register('proflex:server:cutupweeditem', function(source)
    local source = source
    RemoveItem(source, 'drug_weeddry', '2')
    AddItem(source, Config.CuttingUpitem, Config.CuttingUpItemAmmount)
end)

lib.callback.register('proflex:server:baggedweeditem', function(source)
    local source = source
    RemoveItem(source, 'drug_weedcutup', '2')
    AddItem(source, Config.Baggingitem, Config.BaggingItemAmmount)
end)
