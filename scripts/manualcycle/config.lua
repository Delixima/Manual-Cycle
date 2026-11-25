-- ManualCycle : reglages + integration Mod Config Menu Pure
local Config = {}

Config.MOD_NAME = "ManualCycle"

-- Module de traduction, injecte par main.lua (Config.Lang = Lang)
Config.Lang = nil

Config.Defaults = {
    Enabled          = true,
    KeyboardKey      = Keyboard.KEY_C, -- 67
    ControllerButton = -1,             -- -1 = aucun bouton manette
    TaintedIsaac     = true,           -- gerer aussi les piedestaux de Tainted Isaac
    CoopShared       = false,          -- true : la touche agit sur le piedestal le plus proche de n'importe quel joueur
    Radius           = 80,             -- rayon de detection (unites)
    Effects          = true,           -- son + flash au changement
    Language         = "auto",         -- "auto" ou un code de langue EID (voir lang.lua)
}

Config.Values = {}
for k, v in pairs(Config.Defaults) do Config.Values[k] = v end

-- Applique une table de reglages chargee depuis le disque (en ignorant les cles inconnues / mal typees)
function Config.Apply(saved)
    if type(saved) ~= "table" then return end
    for k, default in pairs(Config.Defaults) do
        if type(saved[k]) == type(default) then
            Config.Values[k] = saved[k]
        end
    end
end

function Config.Serialize()
    local t = {}
    for k in pairs(Config.Defaults) do t[k] = Config.Values[k] end
    return t
end

local function T(key)
    if Config.Lang then return Config.Lang.Get(key) end
    return key
end

---------------------------------------------------------------------------
-- Noms des touches
---------------------------------------------------------------------------
local function keyboardName(key)
    if key == nil or key < 0 then return T("none") end
    if InputHelper and InputHelper.KeyboardToString and InputHelper.KeyboardToString[key] then
        return InputHelper.KeyboardToString[key]
    end
    -- Sans InputHelper, on affiche la lettre pour A-Z (codes 65-90 de l'enum Keyboard)
    if key >= 65 and key <= 90 then return string.char(key) end
    return tostring(key)
end

local function controllerName(button)
    if button == nil or button < 0 then return T("none") end
    if InputHelper and InputHelper.ControllerToString and InputHelper.ControllerToString[button] then
        return InputHelper.ControllerToString[button]
    end
    return tostring(button)
end

Config.KeyboardName = keyboardName
Config.ControllerName = controllerName

-- Texte court des touches actives, ex. "C" ou "C / RT" (nil si aucune touche)
function Config.BindingsText()
    local parts = {}
    local key = Config.Values.KeyboardKey
    if key and key >= 0 then parts[#parts + 1] = keyboardName(key) end
    local button = Config.Values.ControllerButton
    if button and button >= 0 then parts[#parts + 1] = controllerName(button) end
    if #parts == 0 then return nil end
    return table.concat(parts, " / ")
end

---------------------------------------------------------------------------
-- Mod Config Menu
-- Display, Info et Popup sont des fonctions : le texte suit la langue courante
-- (MCM accepte une fonction pour Info, cf. MCM.ConvertDisplayToTextTable).
---------------------------------------------------------------------------
local function onOff(b) return b and T("yes") or T("no") end

local function info(key)
    return function() return T(key) end
end

-- onChange : callback appele apres chaque modification (sauvegarde)
function Config.SetupMCM(onChange)
    if not ModConfigMenu then return false end

    local cat = Config.MOD_NAME
    local OT = ModConfigMenu.OptionType

    if ModConfigMenu.RemoveCategory then
        ModConfigMenu.RemoveCategory(cat) -- evite les doublons apres un "luamod"
    end

    local function changed() if onChange then onChange() end end

    local function addBool(field, labelKey, infoKey)
        ModConfigMenu.AddSetting(cat, "General", {
            Type = OT.BOOLEAN,
            CurrentSetting = function() return Config.Values[field] end,
            Display = function() return T(labelKey) .. ": " .. onOff(Config.Values[field]) end,
            OnChange = function(b) Config.Values[field] = b; changed() end,
            Info = info(infoKey),
        })
    end

    addBool("Enabled", "enabled", "info_enabled")
    addBool("TaintedIsaac", "tainted", "info_tainted")
    addBool("CoopShared", "coop", "info_coop")

    ModConfigMenu.AddSetting(cat, "General", {
        Type = OT.NUMBER,
        CurrentSetting = function() return Config.Values.Radius end,
        Minimum = 40,
        Maximum = 200,
        ModifyBy = 10,
        Display = function() return T("radius") .. ": " .. Config.Values.Radius end,
        OnChange = function(n) Config.Values.Radius = n; changed() end,
        Info = info("info_radius"),
    })

    addBool("Effects", "effects", "info_effects")

    -- Langue : index dans Lang.Order (1 = auto)
    local L = Config.Lang
    if L and L.Order then
        local function langIndex()
            for i, code in ipairs(L.Order) do
                if code == Config.Values.Language then return i end
            end
            return 1
        end
        ModConfigMenu.AddSetting(cat, "General", {
            Type = OT.NUMBER,
            CurrentSetting = langIndex,
            Minimum = 1,
            Maximum = #L.Order,
            Display = function() return T("language") .. ": " .. L.DisplayName(Config.Values.Language) end,
            OnChange = function(n)
                Config.Values.Language = L.Order[n] or "auto"
                changed()
            end,
            Info = info("info_language"),
        })
    end

    local popupGfx = ModConfigMenu.PopupGfx and ModConfigMenu.PopupGfx.WIDE_SMALL or nil

    local function keybindPopup(current, nameFn, pressKey, clearKey)
        return function()
            local cur = current()
            local keep = ""
            if cur and cur > -1 then
                keep = string.format(T("popup_current"), nameFn(cur)) .. "$newline$newline"
            end
            return T(pressKey) .. "$newline$newline" .. keep .. T(clearKey)
        end
    end

    ModConfigMenu.AddSetting(cat, "Keybinds", {
        Type = OT.KEYBIND_KEYBOARD,
        CurrentSetting = function() return Config.Values.KeyboardKey end,
        Display = function() return T("keyboard") .. ": " .. keyboardName(Config.Values.KeyboardKey) end,
        OnChange = function(key)
            Config.Values.KeyboardKey = key or -1
            changed()
        end,
        PopupGfx = popupGfx,
        PopupWidth = 280,
        Popup = keybindPopup(function() return Config.Values.KeyboardKey end, keyboardName, "popup_kb", "popup_kb_clear"),
        Info = info("info_keyboard"),
    })

    ModConfigMenu.AddSetting(cat, "Keybinds", {
        Type = OT.KEYBIND_CONTROLLER,
        CurrentSetting = function() return Config.Values.ControllerButton end,
        Display = function() return T("controller") .. ": " .. controllerName(Config.Values.ControllerButton) end,
        OnChange = function(button)
            Config.Values.ControllerButton = button or -1
            changed()
        end,
        PopupGfx = popupGfx,
        PopupWidth = 280,
        Popup = keybindPopup(function() return Config.Values.ControllerButton end, controllerName, "popup_ctrl", "popup_ctrl_clear"),
        Info = info("info_controller"),
    })

    return true
end

return Config
