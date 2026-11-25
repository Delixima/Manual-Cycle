-- ManualCycle : traductions
--
-- Langue : celle d'External Item Descriptions (EID:getLanguage()) si EID est installe,
-- sinon celle du jeu (Options.Language), sinon l'anglais. Codes de langue identiques a EID.
--
-- * La ligne affichee dans EID existe dans les 20 langues d'EID (EID a ses propres polices).
-- * Les textes de Mod Config Menu sont en ASCII : la police de MCM n'affiche pas les accents,
--   le cyrillique ni les ideogrammes. Les langues non latines utilisent donc l'anglais dans MCM.

local Lang = {}

Lang.DEFAULT = "en_us"

-- Options.Language du jeu -> code EID (meme table que EID.LanguageMap)
local GAME_LANGUAGE_MAP = {
    jp = "ja_jp", es = "spa", de = "de", fr = "fr", ru = "ru", kr = "ko_kr", zh = "zh_cn",
}

---------------------------------------------------------------------------
-- Ligne EID : "{keys}" est remplace par les touches (ex. "C" ou "C / RT")
---------------------------------------------------------------------------
Lang.EIDLine = {
    en_us = "{keys}: Next Item",
    fr    = "{keys} : Objet suivant",
    pt    = "{keys}: Próximo item",
    pt_br = "{keys}: Próximo item",
    ru    = "{keys}: Следующий предмет",
    spa   = "{keys}: Siguiente objeto",
    it    = "{keys}: Oggetto successivo",
    bul   = "{keys}: Следващ предмет",
    pl    = "{keys}: Następny przedmiot",
    de    = "{keys}: Nächster Gegenstand",
    tr_tr = "{keys}: Sonraki eşya",
    ko_kr = "{keys}: 다음 아이템",
    zh_cn = "{keys}：下一个道具",
    ja_jp = "{keys}：次のアイテム",
    cs_cz = "{keys}: Další předmět",
    nl_nl = "{keys}: Volgend voorwerp",
    uk_ua = "{keys}: Наступний предмет",
    el_gr = "{keys}: Επόμενο αντικείμενο",
    ro_ro = "{keys}: Obiectul următor",
    vi    = "{keys}: Vật phẩm tiếp theo",
}

-- Ordre et noms (ASCII, pour la police de MCM) du reglage "Langue"
Lang.Order = {
    "auto", "en_us", "fr", "spa", "it", "de", "pt", "pt_br", "pl", "cs_cz", "ro_ro", "tr_tr", "nl_nl",
    "ru", "uk_ua", "bul", "el_gr", "ja_jp", "ko_kr", "zh_cn", "vi",
}
Lang.Names = {
    en_us = "English", fr = "Francais", spa = "Espanol", it = "Italiano", de = "Deutsch",
    pt = "Portugues", pt_br = "Portugues (BR)", pl = "Polski", cs_cz = "Cestina", ro_ro = "Romana",
    tr_tr = "Turkce", nl_nl = "Nederlands", ru = "Russian", uk_ua = "Ukrainian", bul = "Bulgarian",
    el_gr = "Greek", ja_jp = "Japanese", ko_kr = "Korean", zh_cn = "Chinese", vi = "Tieng Viet",
}

---------------------------------------------------------------------------
-- Textes Mod Config Menu (ASCII uniquement)
---------------------------------------------------------------------------
Lang.MCM = {
    en_us = {
        enabled = "Mod enabled", tainted = "Tainted Isaac pedestals", coop = "Shared co-op",
        radius = "Radius", effects = "Sound and effect", keyboard = "Keyboard", controller = "Controller",
        yes = "Yes", no = "No", none = "None",
        info_enabled = "Off: pedestals cycle normally.",
        info_tainted = "Yes: Tainted Isaac pedestals also use manual cycling.",
        info_coop = "Yes: the key affects the pedestal closest to any player.",
        info_radius = "Max distance between the player and the pedestal.",
        info_effects = "Plays a sound and a flash when the item changes.",
        info_keyboard = "Keyboard key to cycle the nearby pedestal.",
        info_controller = "Controller button to cycle the nearby pedestal.",
        popup_kb = "Press a key on your keyboard.",
        popup_ctrl = "Press a button on your controller.",
        popup_current = "Current: \"%s\". Press it to keep it.",
        popup_kb_clear = "ESCAPE to cancel and clear.",
        popup_ctrl_clear = "BACK to cancel and clear.",
        language = "Language", auto = "Auto",
        info_language = "Auto: follows EID, otherwise the game.",
    },
    fr = {
        enabled = "Mod active", tainted = "Piedestaux Tainted Isaac", coop = "Coop partage",
        radius = "Rayon", effects = "Son et effet", keyboard = "Clavier", controller = "Manette",
        yes = "Oui", no = "Non", none = "Aucun",
        info_enabled = "Desactive : les piedestaux cyclent normalement.",
        info_tainted = "Oui : les piedestaux de Tainted Isaac passent aussi en cycle manuel.",
        info_coop = "Oui : la touche agit sur le piedestal le plus proche de n'importe quel joueur.",
        info_radius = "Distance max entre le joueur et le piedestal.",
        info_effects = "Joue un son et un flash au changement d'objet.",
        info_keyboard = "Touche clavier pour cycler le piedestal proche.",
        info_controller = "Bouton manette pour cycler le piedestal proche.",
        popup_kb = "Appuyez sur une touche du clavier.",
        popup_ctrl = "Appuyez sur un bouton de la manette.",
        popup_current = "Actuellement : \"%s\". Appuyez dessus pour le garder.",
        popup_kb_clear = "ECHAP pour annuler et effacer.",
        popup_ctrl_clear = "BACK pour annuler et effacer.",
        language = "Langue", auto = "Auto",
        info_language = "Auto : suit EID, sinon le jeu.",
    },
    spa = {
        enabled = "Mod activado", tainted = "Pedestales de Tainted Isaac", coop = "Coop compartido",
        radius = "Radio", effects = "Sonido y efecto", keyboard = "Teclado", controller = "Mando",
        yes = "Si", no = "No", none = "Ninguno",
        info_enabled = "Desactivado: los pedestales ciclan normalmente.",
        info_tainted = "Si: los pedestales de Tainted Isaac tambien usan el ciclo manual.",
        info_coop = "Si: la tecla afecta al pedestal mas cercano a cualquier jugador.",
        info_radius = "Distancia maxima entre el jugador y el pedestal.",
        info_effects = "Reproduce un sonido y un destello al cambiar de objeto.",
        info_keyboard = "Tecla del teclado para ciclar el pedestal cercano.",
        info_controller = "Boton del mando para ciclar el pedestal cercano.",
        popup_kb = "Pulsa una tecla del teclado.",
        popup_ctrl = "Pulsa un boton del mando.",
        popup_current = "Actual: \"%s\". Pulsalo para mantenerlo.",
        popup_kb_clear = "ESCAPE para cancelar y borrar.",
        popup_ctrl_clear = "BACK para cancelar y borrar.",
        language = "Idioma", auto = "Auto",
        info_language = "Auto: sigue a EID, si no el juego.",
    },
    it = {
        enabled = "Mod attiva", tainted = "Piedistalli di Tainted Isaac", coop = "Coop condivisa",
        radius = "Raggio", effects = "Suono ed effetto", keyboard = "Tastiera", controller = "Controller",
        yes = "Si", no = "No", none = "Nessuno",
        info_enabled = "Disattivata: i piedistalli ciclano normalmente.",
        info_tainted = "Si: anche i piedistalli di Tainted Isaac usano il ciclo manuale.",
        info_coop = "Si: il tasto agisce sul piedistallo piu vicino a qualsiasi giocatore.",
        info_radius = "Distanza massima tra giocatore e piedistallo.",
        info_effects = "Riproduce un suono e un lampo al cambio di oggetto.",
        info_keyboard = "Tasto della tastiera per ciclare il piedistallo vicino.",
        info_controller = "Pulsante del controller per ciclare il piedistallo vicino.",
        popup_kb = "Premi un tasto della tastiera.",
        popup_ctrl = "Premi un pulsante del controller.",
        popup_current = "Attuale: \"%s\". Premilo per mantenerlo.",
        popup_kb_clear = "ESC per annullare e cancellare.",
        popup_ctrl_clear = "BACK per annullare e cancellare.",
        language = "Lingua", auto = "Auto",
        info_language = "Auto: segue EID, altrimenti il gioco.",
    },
    de = {
        enabled = "Mod aktiv", tainted = "Tainted-Isaac-Podeste", coop = "Geteilter Koop",
        radius = "Radius", effects = "Sound und Effekt", keyboard = "Tastatur", controller = "Controller",
        yes = "Ja", no = "Nein", none = "Keine",
        info_enabled = "Aus: Podeste wechseln normal.",
        info_tainted = "Ja: auch Tainted-Isaac-Podeste werden manuell gewechselt.",
        info_coop = "Ja: die Taste wirkt auf das Podest, das einem beliebigen Spieler am naechsten ist.",
        info_radius = "Maximaler Abstand zwischen Spieler und Podest.",
        info_effects = "Spielt einen Sound und einen Blitz beim Gegenstandswechsel.",
        info_keyboard = "Tastaturtaste, um das nahe Podest zu wechseln.",
        info_controller = "Controllertaste, um das nahe Podest zu wechseln.",
        popup_kb = "Druecke eine Taste auf der Tastatur.",
        popup_ctrl = "Druecke eine Taste auf dem Controller.",
        popup_current = "Aktuell: \"%s\". Druecke sie, um sie zu behalten.",
        popup_kb_clear = "ESC zum Abbrechen und Loeschen.",
        popup_ctrl_clear = "BACK zum Abbrechen und Loeschen.",
        language = "Sprache", auto = "Auto",
        info_language = "Auto: folgt EID, sonst dem Spiel.",
    },
    pt = {
        enabled = "Mod ativado", tainted = "Pedestais de Tainted Isaac", coop = "Coop partilhado",
        radius = "Raio", effects = "Som e efeito", keyboard = "Teclado", controller = "Comando",
        yes = "Sim", no = "Nao", none = "Nenhum",
        info_enabled = "Desativado: os pedestais alternam normalmente.",
        info_tainted = "Sim: os pedestais de Tainted Isaac tambem usam o ciclo manual.",
        info_coop = "Sim: a tecla afeta o pedestal mais proximo de qualquer jogador.",
        info_radius = "Distancia maxima entre o jogador e o pedestal.",
        info_effects = "Toca um som e um flash ao mudar de item.",
        info_keyboard = "Tecla do teclado para alternar o pedestal proximo.",
        info_controller = "Botao do comando para alternar o pedestal proximo.",
        popup_kb = "Prima uma tecla do teclado.",
        popup_ctrl = "Prima um botao do comando.",
        popup_current = "Atual: \"%s\". Prima-a para manter.",
        popup_kb_clear = "ESC para cancelar e limpar.",
        popup_ctrl_clear = "BACK para cancelar e limpar.",
        language = "Idioma", auto = "Auto",
        info_language = "Auto: segue o EID, senao o jogo.",
    },
    pt_br = {
        enabled = "Mod ativado", tainted = "Pedestais do Tainted Isaac", coop = "Coop compartilhado",
        radius = "Raio", effects = "Som e efeito", keyboard = "Teclado", controller = "Controle",
        yes = "Sim", no = "Nao", none = "Nenhum",
        info_enabled = "Desativado: os pedestais alternam normalmente.",
        info_tainted = "Sim: os pedestais do Tainted Isaac tambem usam o ciclo manual.",
        info_coop = "Sim: a tecla afeta o pedestal mais proximo de qualquer jogador.",
        info_radius = "Distancia maxima entre o jogador e o pedestal.",
        info_effects = "Toca um som e um brilho ao trocar de item.",
        info_keyboard = "Tecla do teclado para alternar o pedestal proximo.",
        info_controller = "Botao do controle para alternar o pedestal proximo.",
        popup_kb = "Aperte uma tecla do teclado.",
        popup_ctrl = "Aperte um botao do controle.",
        popup_current = "Atual: \"%s\". Aperte para manter.",
        popup_kb_clear = "ESC para cancelar e limpar.",
        popup_ctrl_clear = "BACK para cancelar e limpar.",
        language = "Idioma", auto = "Auto",
        info_language = "Auto: segue o EID, senao o jogo.",
    },
    pl = {
        enabled = "Mod wlaczony", tainted = "Piedestaly Tainted Isaaca", coop = "Wspolny co-op",
        radius = "Zasieg", effects = "Dzwiek i efekt", keyboard = "Klawiatura", controller = "Kontroler",
        yes = "Tak", no = "Nie", none = "Brak",
        info_enabled = "Wylaczony: piedestaly zmieniaja sie normalnie.",
        info_tainted = "Tak: piedestaly Tainted Isaaca tez zmienia sie recznie.",
        info_coop = "Tak: klawisz dziala na piedestal najblizszy dowolnemu graczowi.",
        info_radius = "Maksymalna odleglosc miedzy graczem a piedestalem.",
        info_effects = "Odtwarza dzwiek i blysk przy zmianie przedmiotu.",
        info_keyboard = "Klawisz do zmiany pobliskiego piedestalu.",
        info_controller = "Przycisk kontrolera do zmiany pobliskiego piedestalu.",
        popup_kb = "Nacisnij klawisz na klawiaturze.",
        popup_ctrl = "Nacisnij przycisk na kontrolerze.",
        popup_current = "Obecnie: \"%s\". Nacisnij go, aby zachowac.",
        popup_kb_clear = "ESC, aby anulowac i wyczyscic.",
        popup_ctrl_clear = "BACK, aby anulowac i wyczyscic.",
        language = "Jezyk", auto = "Auto",
        info_language = "Auto: wedlug EID, inaczej wedlug gry.",
    },
    cs_cz = {
        enabled = "Mod zapnut", tainted = "Podstavce Tainted Isaaca", coop = "Sdileny co-op",
        radius = "Dosah", effects = "Zvuk a efekt", keyboard = "Klavesnice", controller = "Ovladac",
        yes = "Ano", no = "Ne", none = "Zadne",
        info_enabled = "Vypnuto: podstavce se meni normalne.",
        info_tainted = "Ano: i podstavce Tainted Isaaca se meni rucne.",
        info_coop = "Ano: klavesa ovlivni podstavec nejblize kteremukoli hraci.",
        info_radius = "Maximalni vzdalenost mezi hracem a podstavcem.",
        info_effects = "Prehraje zvuk a zablesk pri zmene predmetu.",
        info_keyboard = "Klavesa pro zmenu blizkeho podstavce.",
        info_controller = "Tlacitko ovladace pro zmenu blizkeho podstavce.",
        popup_kb = "Stiskni klavesu na klavesnici.",
        popup_ctrl = "Stiskni tlacitko na ovladaci.",
        popup_current = "Aktualne: \"%s\". Stiskni ji pro ponechani.",
        popup_kb_clear = "ESC pro zruseni a vymazani.",
        popup_ctrl_clear = "BACK pro zruseni a vymazani.",
        language = "Jazyk", auto = "Auto",
        info_language = "Auto: podle EID, jinak podle hry.",
    },
    ro_ro = {
        enabled = "Mod activat", tainted = "Piedestale Tainted Isaac", coop = "Co-op comun",
        radius = "Raza", effects = "Sunet si efect", keyboard = "Tastatura", controller = "Controller",
        yes = "Da", no = "Nu", none = "Niciunul",
        info_enabled = "Dezactivat: piedestalele se schimba normal.",
        info_tainted = "Da: si piedestalele lui Tainted Isaac se schimba manual.",
        info_coop = "Da: tasta afecteaza piedestalul cel mai apropiat de orice jucator.",
        info_radius = "Distanta maxima dintre jucator si piedestal.",
        info_effects = "Reda un sunet si un flash la schimbarea obiectului.",
        info_keyboard = "Tasta pentru a schimba piedestalul apropiat.",
        info_controller = "Butonul controllerului pentru a schimba piedestalul apropiat.",
        popup_kb = "Apasa o tasta de pe tastatura.",
        popup_ctrl = "Apasa un buton de pe controller.",
        popup_current = "Actual: \"%s\". Apasa-l pentru a-l pastra.",
        popup_kb_clear = "ESC pentru anulare si stergere.",
        popup_ctrl_clear = "BACK pentru anulare si stergere.",
        language = "Limba", auto = "Auto",
        info_language = "Auto: urmeaza EID, altfel jocul.",
    },
    tr_tr = {
        enabled = "Mod etkin", tainted = "Tainted Isaac kaideleri", coop = "Ortak co-op",
        radius = "Menzil", effects = "Ses ve efekt", keyboard = "Klavye", controller = "Kumanda",
        yes = "Evet", no = "Hayir", none = "Yok",
        info_enabled = "Kapali: kaideler normal sekilde degisir.",
        info_tainted = "Evet: Tainted Isaac kaideleri de elle degistirilir.",
        info_coop = "Evet: tus herhangi bir oyuncuya en yakin kaideyi etkiler.",
        info_radius = "Oyuncu ile kaide arasindaki en fazla mesafe.",
        info_effects = "Esya degisince ses ve parlama oynatir.",
        info_keyboard = "Yakindaki kaideyi degistirmek icin klavye tusu.",
        info_controller = "Yakindaki kaideyi degistirmek icin kumanda tusu.",
        popup_kb = "Klavyede bir tusa bas.",
        popup_ctrl = "Kumandada bir tusa bas.",
        popup_current = "Su an: \"%s\". Korumak icin ona bas.",
        popup_kb_clear = "Iptal ve temizlemek icin ESC.",
        popup_ctrl_clear = "Iptal ve temizlemek icin BACK.",
        language = "Dil", auto = "Otomatik",
        info_language = "Otomatik: EID'yi, yoksa oyunu izler.",
    },
    nl_nl = {
        enabled = "Mod ingeschakeld", tainted = "Tainted Isaac-sokkels", coop = "Gedeelde co-op",
        radius = "Bereik", effects = "Geluid en effect", keyboard = "Toetsenbord", controller = "Controller",
        yes = "Ja", no = "Nee", none = "Geen",
        info_enabled = "Uit: sokkels wisselen normaal.",
        info_tainted = "Ja: ook Tainted Isaac-sokkels wisselen handmatig.",
        info_coop = "Ja: de toets werkt op de sokkel die het dichtst bij een speler staat.",
        info_radius = "Maximale afstand tussen speler en sokkel.",
        info_effects = "Speelt een geluid en een flits bij het wisselen.",
        info_keyboard = "Toets om de nabije sokkel te wisselen.",
        info_controller = "Controllerknop om de nabije sokkel te wisselen.",
        popup_kb = "Druk op een toets van het toetsenbord.",
        popup_ctrl = "Druk op een knop van de controller.",
        popup_current = "Huidig: \"%s\". Druk erop om te behouden.",
        popup_kb_clear = "ESC om te annuleren en te wissen.",
        popup_ctrl_clear = "BACK om te annuleren en te wissen.",
        language = "Taal", auto = "Auto",
        info_language = "Auto: volgt EID, anders het spel.",
    },
}

---------------------------------------------------------------------------
-- Langue choisie dans MCM ("auto" ou un code) ; branche par main.lua
Lang.GetSetting = function() return "auto" end

-- Langue automatique : celle d'EID, sinon celle du jeu, sinon l'anglais
local function eidLanguage()
    if type(EID) == "table" and type(EID.getLanguage) == "function" then
        local ok, code = pcall(EID.getLanguage, EID)
        if ok and type(code) == "string" then return code end
    end
    return nil
end

function Lang.Auto()
    local code = eidLanguage()
    if code then return code end
    if Options and type(Options.Language) == "string" and GAME_LANGUAGE_MAP[Options.Language] then
        return GAME_LANGUAGE_MAP[Options.Language]
    end
    return Lang.DEFAULT
end

function Lang.Current()
    local setting = Lang.GetSetting()
    if setting ~= "auto" and Lang.EIDLine[setting] then return setting end
    return Lang.Auto()
end

-- La police actuellement chargee par EID peut-elle afficher cette langue ?
-- Chaque pack de langue EID liste ses polices compatibles (EID.descriptions[code].fonts).
local function eidFontSupports(code)
    if type(EID) ~= "table" or type(EID.descriptions) ~= "table" or type(EID.Config) ~= "table" then
        return true
    end
    local pack = EID.descriptions[code]
    if type(pack) ~= "table" or type(pack.fonts) ~= "table" then return true end
    local current = EID.Config["FontType"] or "default"
    for _, font in ipairs(pack.fonts) do
        if type(font) == "table" and font.name == current then return true end
    end
    return false
end

-- Langue de la ligne EID : la langue choisie, sauf si la police d'EID ne peut pas l'afficher
function Lang.EIDCurrent()
    local code = Lang.Current()
    if eidFontSupports(code) then return code end
    return eidLanguage() or Lang.DEFAULT
end

-- Nom affichable dans MCM ("Auto (Francais)" pour le mode automatique)
function Lang.DisplayName(code)
    if code == "auto" then
        return Lang.Get("auto") .. " (" .. (Lang.Names[Lang.Auto()] or Lang.Auto()) .. ")"
    end
    return Lang.Names[code] or code
end

-- Texte MCM dans la langue courante (anglais si la langue n'a pas de version ASCII)
function Lang.Get(key)
    local t = Lang.MCM[Lang.Current()] or Lang.MCM[Lang.DEFAULT]
    return t[key] or Lang.MCM[Lang.DEFAULT][key] or key
end

-- Ligne EID ; keys = texte des touches (ex. "C")
function Lang.EIDText(keys)
    local fmt = Lang.EIDLine[Lang.EIDCurrent()] or Lang.EIDLine[Lang.DEFAULT]
    -- fonction de remplacement : evite toute interpretation de "%" dans le nom de la touche
    return (fmt:gsub("{keys}", function() return keys end))
end

return Lang
