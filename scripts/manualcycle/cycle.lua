-- ManualCycle : logique des piedestaux (API Lua vanilla uniquement, sans REPENTOGON)
--
-- L'API vanilla ne permet pas de lire la liste de cycle d'un piedestal. Comme External Item
-- Descriptions sans REPENTOGON, on l'apprend en observant : a chaque update on note le SubType.
-- Quand le piedestal revient sur un objet deja vu, le cycle est complet : on le fige.
--
-- Phases d'un piedestal :
--   "watch"    : un seul objet vu pour l'instant (piedestal normal ou cycle pas encore commence)
--   "learning" : le piedestal a change d'objet, on accumule la liste
--   "locked"   : liste complete, le piedestal est fige ; tout changement natif est annule
--   "ignored"  : cycle laisse natif (option Tainted Isaac desactivee)
--
-- API utilisee (wofsauge.github.io/IsaacDocs/rep/EntityPickup.html) :
--   void EntityPickup:Morph(EntityType, Variant, SubType, KeepPrice, KeepSeed, IgnoreModifiers)

local Config -- injecte par Cycle.Init

local Cycle = {}

-- key -> entry ; key = "<index de salle>_<InitSeed>_<case de la salle>"
Cycle.Pedestals = {}
Cycle.LevelKey = nil
Cycle.Dirty = false

-- Frame jusqu'a laquelle un changement vers un objet inconnu est considere comme un reroll (D6...)
local rerollGraceUntil = -1
local REROLL_GRACE_FRAMES = 3

local game = Game()
local sfx = SFXManager()

function Cycle.Init(config)
    Config = config
end

local function frame()
    return game:GetFrameCount()
end

-- Cle : salle + InitSeed + case de la salle. La case distingue deux piedestaux qui partagent
-- un InitSeed (copies de Diplopia, cf. EID qui ajoute Entity.Index pour la meme raison).
-- Index n'est pas utilise ici car il change a chaque visite de la salle, la case non.
local function pedestalKey(pickup)
    return tostring(game:GetLevel():GetCurrentRoomIndex()) .. "_" .. tostring(pickup.InitSeed)
        .. "_" .. tostring(game:GetRoom():GetGridIndex(pickup.Position))
end

local function indexOf(list, value)
    for i = 1, #list do
        if list[i] == value then return i end
    end
    return nil
end

local function forEachPlayer(fn)
    for i = 0, game:GetNumPlayers() - 1 do
        local p = Isaac.GetPlayer(i)
        if p and fn(p) then return true end
    end
    return false
end

-- Heuristique : Tainted Isaac cycle entre 2 objets, Glitched Crown entre 5.
local function looksLikeTaintedIsaacCycle(list)
    local hasTaintedIsaac = forEachPlayer(function(p)
        return p:GetPlayerType() == PlayerType.PLAYER_ISAAC_B
    end)
    if not hasTaintedIsaac then return false end
    local hasCrown = forEachPlayer(function(p)
        return p:HasCollectible(CollectibleType.COLLECTIBLE_GLITCHED_CROWN)
    end)
    if not hasCrown then return true end
    return #list <= 2
end

-- Room:GetType() == RoomType.ROOM_DICE (enum verifie si present, au cas ou)
local function inDiceRoom()
    if not RoomType or not RoomType.ROOM_DICE then return false end
    return game:GetRoom():GetType() == RoomType.ROOM_DICE
end

local function newEntry(subType)
    return { phase = "watch", items = { subType }, index = 1, last = subType }
end

-- Met le piedestal sur un objet sans relancer de reroll ni de modificateur (Tainted Isaac, etc.)
local function setItem(pickup, entry, id)
    local optionsIndex = pickup.OptionsPickupIndex
    local shopItemId = pickup.ShopItemId
    local touched = pickup.Touched
    pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, id, true, true, true)
    pickup.OptionsPickupIndex = optionsIndex
    pickup.ShopItemId = shopItemId
    pickup.Touched = touched
    -- Morph remet FrameCount a 0, et EID ignore les entites a la frame 0 (main.lua, ligne 1460),
    -- sauf si elles portent ce marqueur. Sans lui, la description clignote a chaque Morph.
    local data = pickup:GetData()
    if type(data) == "table" then
        data.EID_DescribeOnFirstFrame = true
    end
    entry.last = id
end

local function lock(pickup, entry)
    entry.phase = "locked"
    entry.index = indexOf(entry.items, pickup.SubType) or 1
    -- Re-Morph sur l'objet actuel en ignorant les modificateurs : arrete le cycle natif quand le moteur le permet.
    -- Sinon, la phase "locked" annule chaque changement natif dans la meme frame (pas de clignotement).
    setItem(pickup, entry, entry.items[entry.index])
    Cycle.Dirty = true
end

---------------------------------------------------------------------------
-- Appele depuis MC_USE_ITEM / MC_USE_CARD : un reroll peut suivre
---------------------------------------------------------------------------
function Cycle.NotifyPossibleReroll()
    rerollGraceUntil = frame() + REROLL_GRACE_FRAMES
end

---------------------------------------------------------------------------
-- MC_POST_PICKUP_UPDATE (PICKUP_COLLECTIBLE)
---------------------------------------------------------------------------
function Cycle.OnPickupUpdate(pickup)
    local key = pedestalKey(pickup)
    local entry = Cycle.Pedestals[key]
    local subType = pickup.SubType

    -- Objet pris (piedestal vide) : on nettoie
    if subType == CollectibleType.COLLECTIBLE_NULL then
        if entry then
            if entry.phase == "locked" then Cycle.Dirty = true end
            Cycle.Pedestals[key] = nil
        end
        return
    end

    if not entry then
        Cycle.Pedestals[key] = newEntry(subType)
        return
    end

    if subType == entry.last then return end

    local known = indexOf(entry.items, subType)
    -- Objet inconnu = reroll si un actif/une carte vient d'etre utilise, ou dans une Dice Room
    -- (le de du sol reroll les piedestaux sans passer par MC_USE_ITEM / MC_USE_CARD)
    local rerolled = (not known) and (frame() <= rerollGraceUntil or inDiceRoom())

    if rerolled then
        -- D6 / Spindown / carte... : on repart de zero sur le nouvel objet
        if entry.phase == "locked" then Cycle.Dirty = true end
        Cycle.Pedestals[key] = newEntry(subType)
        return
    end

    if entry.phase == "locked" then
        -- Cycle natif qui continue (ou recree au retour dans la salle) : on remet l'objet choisi
        setItem(pickup, entry, entry.items[entry.index])
        return
    end

    if entry.phase == "ignored" then
        entry.last = subType
        if not known then entry.items[#entry.items + 1] = subType end
        return
    end

    -- "watch" ou "learning"
    if known then
        -- Retour sur un objet deja vu : le cycle est complet
        entry.last = subType
        if #entry.items >= 2 then
            if not Config.Values.TaintedIsaac and looksLikeTaintedIsaacCycle(entry.items) then
                entry.phase = "ignored"
            else
                lock(pickup, entry)
            end
        end
    else
        entry.items[#entry.items + 1] = subType
        entry.last = subType
        entry.phase = "learning"
    end
end

---------------------------------------------------------------------------
-- Changement d'objet manuel
---------------------------------------------------------------------------
local function playFeedback(pickup)
    if not Config.Values.Effects then return end
    sfx:Play(SoundEffect.SOUND_MENU_SCROLL, 1, 0, false, 1.2)
    -- Color(R, G, B, A, RO, GO, BO) ; SetColor(Color, Duration, Priority, Fadeout, Share)
    pickup:SetColor(Color(1, 1, 1, 1, 0.6, 0.6, 0.6), 8, 1, true, false)
end

function Cycle.Advance(pickup)
    local entry = Cycle.Pedestals[pedestalKey(pickup)]
    if not entry or entry.phase ~= "locked" or #entry.items < 2 then return false end

    local nextIndex = (entry.index % #entry.items) + 1
    entry.index = nextIndex
    setItem(pickup, entry, entry.items[nextIndex])
    pickup.Touched = false

    Cycle.Dirty = true
    playFeedback(pickup)
    return true
end

local function isCyclable(pickup)
    if pickup.SubType == CollectibleType.COLLECTIBLE_NULL then return false end
    local entry = Cycle.Pedestals[pedestalKey(pickup)]
    return entry ~= nil and entry.phase == "locked" and #entry.items >= 2
end

-- Position dans la liste pour un piedestal fige : index, total (nil sinon)
function Cycle.GetPosition(pickup)
    if not pickup or not isCyclable(pickup) then return nil end
    local entry = Cycle.Pedestals[pedestalKey(pickup)]
    local idx = indexOf(entry.items, pickup.SubType) or entry.index
    return idx, #entry.items
end

-- Piedestal fige le plus proche d'une des positions donnees, dans le rayon
function Cycle.FindNearest(positions)
    local radius = Config.Values.Radius
    local best, bestDist = nil, radius + 0.001
    local list = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, false, false)
    for _, ent in ipairs(list) do
        local pickup = ent:ToPickup()
        if pickup and not pickup:IsDead() and isCyclable(pickup) then
            for _, pos in ipairs(positions) do
                local d = (pickup.Position - pos):Length()
                if d < bestDist then
                    best, bestDist = pickup, d
                end
            end
        end
    end
    return best
end

---------------------------------------------------------------------------
-- Compatibilite External Item Descriptions
-- Sans REPENTOGON, EID construit sa liste "Glitched Crown" en observant les piedestaux et
-- oublie un objet non vu depuis 120 updates (features/eid_modifiers.lua). Un piedestal fige
-- n'affiche plus qu'un objet, donc on rafraichit nous-memes sa table globale avec notre liste.
---------------------------------------------------------------------------
function Cycle.SyncEID()
    if type(EID) ~= "table" or type(EID.GlitchedCrownCheck) ~= "table" or type(EID.GameUpdateCount) ~= "number" then
        return
    end
    local roomIndex = game:GetLevel():GetCurrentRoomIndex()
    local list = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, false, false)
    for _, ent in ipairs(list) do
        local pickup = ent:ToPickup()
        if pickup and isCyclable(pickup) then
            local entry = Cycle.Pedestals[pedestalKey(pickup)]
            EID.GlitchedCrownCheck[roomIndex] = EID.GlitchedCrownCheck[roomIndex] or {}
            local eidKey = pickup.InitSeed .. pickup.Index -- meme cle que EID
            local seen = EID.GlitchedCrownCheck[roomIndex][eidKey] or {}
            EID.GlitchedCrownCheck[roomIndex][eidKey] = seen
            for i, id in ipairs(entry.items) do
                -- [1] = ordre d'affichage (on impose celui de notre liste), [2] = derniere fois vu
                seen[id] = { i, EID.GameUpdateCount }
            end
            -- Retire ce que EID aurait note et qui n'est pas dans notre liste
            for id in pairs(seen) do
                if not indexOf(entry.items, id) then seen[id] = nil end
            end
        end
    end
end

---------------------------------------------------------------------------
-- Etat de run (sauvegarde / chargement)
---------------------------------------------------------------------------
function Cycle.ComputeLevelKey()
    local level = game:GetLevel()
    return tostring(level:GetStage()) .. ":" .. tostring(level:GetStageType()) .. ":" .. tostring(game:GetSeeds():GetStartSeed())
end

-- Ne garde que les piedestaux figes (le reste se reconstruit en observant)
local function pruneUnlocked()
    for k, e in pairs(Cycle.Pedestals) do
        if e.phase ~= "locked" then Cycle.Pedestals[k] = nil end
    end
end

function Cycle.Reset()
    Cycle.Pedestals = {}
    Cycle.LevelKey = Cycle.ComputeLevelKey()
    Cycle.Dirty = true
end

function Cycle.OnNewLevel()
    local lk = Cycle.ComputeLevelKey()
    if lk ~= Cycle.LevelKey then
        Cycle.Pedestals = {}
        Cycle.Dirty = true
    end
    Cycle.LevelKey = lk
end

function Cycle.OnNewRoom()
    rerollGraceUntil = -1
    pruneUnlocked()
end

function Cycle.Serialize()
    local peds = {}
    for k, e in pairs(Cycle.Pedestals) do
        if e.phase == "locked" then
            peds[k] = { items = e.items, index = e.index }
        end
    end
    return { levelKey = Cycle.LevelKey, pedestals = peds }
end

function Cycle.Deserialize(data)
    Cycle.Pedestals = {}
    if type(data) ~= "table" then return end
    if type(data.levelKey) == "string" then Cycle.LevelKey = data.levelKey end
    if type(data.pedestals) ~= "table" then return end
    for k, e in pairs(data.pedestals) do
        if type(e) == "table" and type(e.items) == "table" then
            local items = {}
            for _, id in ipairs(e.items) do
                id = tonumber(id)
                if id and id > 0 and not indexOf(items, id) then items[#items + 1] = id end
            end
            if #items >= 2 then
                local idx = tonumber(e.index) or 1
                if idx < 1 or idx > #items then idx = 1 end
                -- last = -1 : au premier update, le piedestal est remis sur l'objet choisi
                Cycle.Pedestals[tostring(k)] = { phase = "locked", items = items, index = idx, last = -1 }
            end
        end
    end
end

return Cycle
