# ManualCycle

*Français plus bas.*

A mod for **The Binding of Isaac: Repentance** (v1.7.9b and newer).

Cycling item pedestals (Glitched Crown, Tainted Isaac, Binge Eater, Soul of Isaac...) no longer change on their own. They stay on one item, and you press a key to switch to the next one.

## Requirements

- None. The mod only uses the official Lua API, so **REPENTOGON is not needed**.
- Optional: **Mod Config Menu Pure** to change the settings in game.
- Optional: **External Item Descriptions** (EID) for the item list and the `(1/2)` indicator.

## Installation

Copy the `ManualCycle` folder into the game's `mods` folder (`...\steamapps\common\The Binding of Isaac Rebirth\mods\`). Then make sure the mod is enabled in the **Mods** menu.

## How it works

The vanilla API cannot read a pedestal's cycle list, so the mod learns it by watching, the same way EID does without REPENTOGON:

1. It records the item shown on each pedestal on every update.
2. When the pedestal comes back to an item it has already seen, the cycle is complete and the mod freezes the pedestal.
3. If the game tries to cycle it again, the mod puts the chosen item back in the same frame, so nothing flickers.

The pedestal therefore cycles normally for one full round before it freezes. With Glitched Crown that is almost instant.

## Usage

- Stand near a frozen pedestal (80 units by default).
- Press **C** (default) or the controller button you set. The pedestal switches to the next item, then loops back to the first one.
- If several pedestals are in range, only the closest one changes.

## Features

- Uses `Morph(..., KeepPrice, KeepSeed, IgnoreModifiers)`, so the price, seed and option group are kept.
- Only pedestals that already cycle on their own are affected, including in shops and deal rooms.
- Picked-up items and rerolls (D6, Spindown Dice, cards, Dice Room floor...) are handled.
- State is kept for the whole floor and saved as JSON when you continue a run.
- Co-op:
  - The keyboard key is for player 1, and each controller works for its own player.
  - The optional **shared** mode targets the pedestal closest to any player.
- Sound and a short flash on each change (can be turned off).
- **EID**:
  - the Glitched Crown list stays complete on frozen pedestals;
  - each frozen pedestal shows a `(1/2) C: Next Item` line;
  - the description no longer flickers.
- **Languages**: the EID line uses EID's language, in all 20 EID languages. Mod Config Menu texts are translated into the Latin-alphabet languages (EN, FR, ES, IT, DE, PT, PT-BR, PL, CS, RO, TR, NL). MCM's font cannot display other alphabets, so the remaining languages use English there.

## Settings (Mod Config Menu → ManualCycle)

| Setting | Default |
|---|---|
| Mod enabled | Yes |
| Tainted Isaac pedestals | Yes |
| Shared co-op | No |
| Radius (40–200) | 80 |
| Sound and effect | Yes |
| Keyboard key | C |
| Controller button | None |
| Language | Auto (EID, then game) |

## Known limitations

- Each pedestal cycles for one round before it freezes.
- A reroll that comes from neither an active item, a card nor the Dice Room floor is undone on a pedestal that is already frozen (no such case is known).
- **Tainted Isaac pedestals = No** relies on a heuristic: a 2-item cycle is treated as Tainted Isaac's.
- No controller button is set by default.

## Contributing and license

Contributions are welcome: bug fixes, support for other game versions, new or corrected translations (see `scripts/manualcycle/lang.lua`), or anything else that improves the mod. Open an issue or a pull request on [the official repository](https://github.com/Delixima/Manual-Cycle).

ManualCycle is released under the [MIT License](LICENSE): you are free to use, modify, re-upload and reuse its code and translations in your own mods, as long as the license and copyright notice are kept. Credit is appreciated.

---

# ManualCycle (Français)

Mod pour **The Binding of Isaac: Repentance** (v1.7.9b et plus récent).

Les piédestaux à cycle automatique (Glitched Crown, Tainted Isaac, Binge Eater, Soul of Isaac...) ne changent plus d'objet tout seuls. Ils restent figés, et c'est vous qui passez à l'objet suivant avec une touche (**C** par défaut).

- **Prérequis :** aucun, le mod utilise uniquement l'API officielle (**pas besoin de REPENTOGON**).
- **Facultatif :** Mod Config Menu Pure et External Item Descriptions.
- **Installation :** copier le dossier `ManualCycle` dans le dossier `mods` du jeu, puis vérifier qu'il est activé dans le menu **Mods**.
- **Fonctionnement :** le mod observe chaque piédestal pendant un tour complet pour apprendre sa liste, puis le fige. Il remet l'objet choisi dans la même frame si le jeu essaie de le faire cycler, donc sans clignotement.
- **EID :**
  - la liste Glitched Crown reste complète ;
  - une ligne `(1/2) C : Objet suivant` s'affiche sur les piédestaux figés ;
  - la description ne clignote plus.
- **Langues :**
  - la ligne EID est disponible dans les 20 langues d'EID et suit la langue d'EID ;
  - les textes de Mod Config Menu sont traduits pour les langues à alphabet latin. Les autres langues restent en anglais dans MCM, dont la police n'affiche pas les autres alphabets.
- **Réglages, coop, sauvegarde et limites :** voir la partie anglaise ci-dessus.

- **Contributions et licence :** les corrections, le support d'autres versions du jeu et les traductions sont les bienvenus via le dépôt officiel (issue ou pull request). Le mod est sous [licence MIT](LICENSE) : chacun peut l'utiliser, le modifier, le republier et reprendre son code dans ses propres mods, en gardant la licence et la mention de copyright.

## Structure

```
ManualCycle/
  metadata.xml
  main.lua                        callbacks, input, save data
  scripts/manualcycle/config.lua  settings + Mod Config Menu
  scripts/manualcycle/cycle.lua   learning and freezing pedestals
  scripts/manualcycle/eid.lua     External Item Descriptions integration
  scripts/manualcycle/lang.lua    translations
  README.md
```
