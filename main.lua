-- ManualCycle : les piedestaux a cycle automatique ne cyclent plus que sur appui d'une touche.
local VERSION = "1.2.2" -- a garder identique a <version> dans metadata.xml
local mod = RegisterMod("ManualCycle", 1)
local json = require("json")
local game = Game()

local function loadModule(path)
    if include then
        return include(path)
    end
    return require(path)
end

local Config = loadModule("scripts.manualcycle.config")
local Cycle = loadModule("scripts.manualcycle.cycle")
local EIDCompat = loadModule("scripts.manualcycle.eid")
Config.Lang = loadModule("scripts.manualcycle.lang")
Config.Lang.GetSetting = function() return Config.Values.Language end
Cycle.Init(Config)

-- EID peut etre charge avant ou apres ce mod : on s'enregistre maintenant et au debut de chaque run
EIDCompat.Register(Cycle, Config)

---------------------------------------------------------------------------
-- Sauvegarde (reglages + etat de la run) via Isaac.SaveModData / LoadModData
---------------------------------------------------------------------------
local function readSave()
    if not Isaac.HasModData(mod) then return nil end
    local raw = Isaac.LoadModData(mod)
    if type(raw) ~= "string" or raw == "" then return nil end
    local ok, data = pcall(json.decode, raw)
    if ok and type(data) == "table" then return data end
    return nil
end

-- Vrai une fois l'etat de la run charge (GAME_STARTED ou luamod en cours de run).
-- Au continue, le jeu declenche NEW_LEVEL et NEW_ROOM avant GAME_STARTED : tant que l'etat
-- n'est pas charge, on reecrit la partie "run" telle qu'elle est sur le disque au lieu de l'ecraser.
local runLoaded = false

local function writeSave()
    local run
    if runLoaded then
        run = Cycle.Serialize()
    else
        local old = readSave()
        run = old and old.run or nil
    end
    local ok, raw = pcall(json.encode, {
        version = 1,
        settings = Config.Serialize(),
        run = run,
    })
    if ok then
        Isaac.SaveModData(mod, raw)
        Cycle.Dirty = false
    end
end

do
    local data = readSave()
    if data then
        Config.Apply(data.settings)
        -- Rechargement du mod en cours de run (commande luamod) : on reprend l'etat sauvegarde
        if game:GetFrameCount() > 0 then
            Cycle.Deserialize(data.run)
            runLoaded = true
        end
    end
end

Config.SetupMCM(writeSave)

---------------------------------------------------------------------------
-- Entrees : lues au rendu (Triggered = 1 frame de rendu), traitees a l'update
---------------------------------------------------------------------------
local pendingPresses = {} -- liste de { positions = {Vector...} }

local function isMenuOpen()
    return ModConfigMenu ~= nil and ModConfigMenu.IsVisible == true
end

local function allPlayerPositions()
    local positions = {}
    for i = 0, game:GetNumPlayers() - 1 do
        local p = Isaac.GetPlayer(i)
        if p and not p:IsCoopGhost() then
            positions[#positions + 1] = p.Position
        end
    end
    return positions
end

-- Regroupe les joueurs par manette (Jacob & Esau, etc. partagent un index)
local function playersByController()
    local groups, order = {}, {}
    for i = 0, game:GetNumPlayers() - 1 do
        local p = Isaac.GetPlayer(i)
        if p and not p:IsCoopGhost() then
            local idx = p.ControllerIndex
            if not groups[idx] then
                groups[idx] = {}
                order[#order + 1] = idx
            end
            local g = groups[idx]
            g[#g + 1] = p.Position
        end
    end
    return groups, order
end

local function keyboardTriggered(key)
    if key == nil or key < 0 then return false end
    -- Index clavier : 0 avant Repentance+ 1.9.7.19, -2 ensuite
    return Input.IsButtonTriggered(key, 0) or Input.IsButtonTriggered(key, -2)
end

function mod:OnRender()
    if not Config.Values.Enabled then return end
    if game:IsPaused() or isMenuOpen() then return end

    local cfg = Config.Values
    local groups, order = playersByController()

    -- Clavier : rattache au joueur 1 (ou a tous en coop partage)
    if keyboardTriggered(cfg.KeyboardKey) then
        local positions
        if cfg.CoopShared then
            positions = allPlayerPositions()
        else
            local p1 = Isaac.GetPlayer(0)
            positions = p1 and (groups[p1.ControllerIndex] or { p1.Position }) or {}
        end
        pendingPresses[#pendingPresses + 1] = { positions = positions }
    end

    -- Manette : chaque joueur avec sa propre manette
    if cfg.ControllerButton ~= nil and cfg.ControllerButton >= 0 then
        for _, idx in ipairs(order) do
            if Input.IsButtonTriggered(cfg.ControllerButton, idx) then
                local positions = cfg.CoopShared and allPlayerPositions() or groups[idx]
                pendingPresses[#pendingPresses + 1] = { positions = positions }
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.OnRender)

function mod:OnUpdate()
    if Config.Values.Enabled then Cycle.SyncEID() end
    if #pendingPresses == 0 then return end
    local presses = pendingPresses
    pendingPresses = {}
    if not Config.Values.Enabled then return end

    -- Un piedestal ne change qu'une fois par frame, meme si plusieurs joueurs appuient
    local handled = {}
    for _, press in ipairs(presses) do
        local pickup = Cycle.FindNearest(press.positions)
        if pickup then
            local h = GetPtrHash(pickup)
            if not handled[h] then
                handled[h] = true
                Cycle.Advance(pickup)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.OnUpdate)

---------------------------------------------------------------------------
-- Piedestaux
---------------------------------------------------------------------------
function mod:OnPickupUpdate(pickup)
    if not Config.Values.Enabled then return end
    Cycle.OnPickupUpdate(pickup)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.OnPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE)

-- Un actif ou une carte peut rerouler les piedestaux (D6, Spindown Dice, Dice Shard...) :
-- pendant quelques frames, un changement vers un objet inconnu est accepte comme un reroll.
function mod:OnUseItem()
    Cycle.NotifyPossibleReroll()
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.OnUseItem)

function mod:OnUseCard()
    Cycle.NotifyPossibleReroll()
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.OnUseCard)

---------------------------------------------------------------------------
-- Run / etage / salle
---------------------------------------------------------------------------
function mod:OnGameStarted(isContinued)
    pendingPresses = {}
    EIDCompat.Register(Cycle, Config)
    if isContinued then
        local data = readSave()
        Cycle.Deserialize(data and data.run or nil)
        -- Si la sauvegarde ne correspond pas a l'etage actuel, on repart de zero
        -- (les piedestaux encore cycliques seront reconstruits a la volee)
        if Cycle.LevelKey ~= Cycle.ComputeLevelKey() then
            Cycle.Reset()
        end
    else
        Cycle.Reset()
    end
    runLoaded = true
    writeSave()
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.OnGameStarted)

function mod:OnNewLevel()
    Cycle.OnNewLevel()
    writeSave()
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.OnNewLevel)

function mod:OnNewRoom()
    pendingPresses = {}
    Cycle.OnNewRoom()
    if Cycle.Dirty then writeSave() end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.OnNewRoom)

function mod:OnGameExit(shouldSave)
    if shouldSave then
        writeSave()
    else
        Cycle.Pedestals = {}
        writeSave()
    end
    -- Retour au menu : la prochaine run doit d'abord recharger son etat (cf. runLoaded)
    runLoaded = false
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.OnGameExit)

Isaac.DebugString("[ManualCycle] loaded (v" .. VERSION .. ", vanilla API).")
