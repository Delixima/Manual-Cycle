-- ManualCycle : indicateur "(1/2)" dans External Item Descriptions
-- Utilise l'API publique d'EID (features/eid_api.lua) :
--   EID:addDescriptionModifier(modifierName, condition(descObj) -> bool, callback(descObj) -> descObj)
--   EID:appendToDescription(descObj, appendString)
-- addDescriptionModifier remplace un modificateur du meme nom : l'appeler plusieurs fois est sans risque.

local EIDCompat = {}

local MODIFIER_NAME = "ManualCycle"

function EIDCompat.Register(Cycle, Config)
    if type(EID) ~= "table" or type(EID.addDescriptionModifier) ~= "function" then
        return false
    end

    local function condition(descObj)
        if not Config.Values.Enabled then return false end
        local entity = descObj and descObj.Entity
        if not entity or entity.Type ~= EntityType.ENTITY_PICKUP or entity.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then
            return false
        end
        local pickup = entity:ToPickup()
        return pickup ~= nil and Cycle.GetPosition(pickup) ~= nil
    end

    local function callback(descObj)
        local pickup = descObj.Entity:ToPickup()
        local idx, total = Cycle.GetPosition(pickup)
        if not idx then return descObj end
        local line = "#{{Blank}} {{ColorYellow}}(" .. idx .. "/" .. total .. "){{CR}}"
        local keys = Config.BindingsText()
        if keys and Config.Lang then
            line = line .. " " .. Config.Lang.EIDText(keys)
        end
        EID:appendToDescription(descObj, line)
        return descObj
    end

    EID:addDescriptionModifier(MODIFIER_NAME, condition, callback)
    return true
end

return EIDCompat
