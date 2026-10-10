# DST Codex Umbra for Everyone

[English](#english) · [Português](#português) · [简体中文](#简体中文) · [Русский](#русский)

## English

An add-on for [Codex Umbra for Wortox](https://github.com/Lmedeiros-leiman/DST-CodexUmbraForWortox) that lets every Don't Starve Together character craft and use Maxwell's Codex Umbra.

- **Same rules as Maxwell:** shadow workers and protectors, shadow trap and pillars, nightmare fuel per spell, a max sanity penalty per shadow, and cleanup when the caster dies, becomes a ghost, swaps character or travels between the surface and the caves.
- **Shadows are silhouettes of their caster**, coloured by allegiance: none keeps Maxwell's black, Lunar glows gestalt cyan, Shadow turns void violet. Characters with their own pets (Walter, Wormwood, WX-78) keep them; shadows use separate pet limits.
- **Every character has their own lines** about the book, the empty book, the "my mind can't take more" failure, their own shadow and someone else's shadow, in English, Portuguese (Brazil), Simplified Chinese and Russian. See [LINES.md](LINES.md) for the full table.
- **Maxwell** plays exactly as in the base game. **Wortox** keeps the base mod's skill-tree colours, lines and panflute troupe. **Wes** uses the book in silence. Modded characters get the book too, but are not guaranteed to work.
- **Language** option: Auto (server language), English, Português, 简体中文, Русский.

**Requires** Codex Umbra for Wortox **0.2.0 or newer** with its Codex Umbra option on. Older versions lack the API this add-on uses; the server log then says so and characters keep the vanilla Codex.

## Português

Complemento do [Codex Umbra para o Wortox](https://github.com/Lmedeiros-leiman/DST-CodexUmbraForWortox) que deixa todos os personagens de Don't Starve Together criarem e usarem o Codex Umbra do Maxwell.

- **Mesmas regras do Maxwell:** servos e duelistas das sombras, armadilha e prisão sombrias, combustível de pesadelo por feitiço, penalidade de sanidade máxima por sombra, e as sombras somem quando quem as invocou morre, vira fantasma, troca de personagem ou viaja entre a superfície e as cavernas.
- **As sombras são silhuetas de quem as invoca**, coloridas pela aliança: nenhuma mantém o preto do Maxwell, Lunar brilha em ciano de gestalt, Sombra fica violeta do vazio. Personagens com bichinhos próprios (Walter, Wormwood, WX-78) continuam com eles; as sombras usam limites separados.
- **Cada personagem tem falas próprias** sobre o livro, o livro vazio, a falha de "minha mente não aguenta mais", a própria sombra e a sombra de outro jogador, em inglês, português (Brasil), chinês simplificado e russo. A tabela completa está em [LINES.md](LINES.md).
- O **Maxwell** continua como no jogo base. O **Wortox** mantém as cores, falas e a trupe da flauta do mod base. O **Wes** usa o livro em silêncio. Personagens de mods também recebem o livro, sem garantia de funcionar.
- Opção **Idioma**: Automático (idioma do servidor), English, Português, 简体中文, Русский.

**Requer** o Codex Umbra para o Wortox **0.2.0 ou mais novo** com a opção Codex Umbra ativada.

## 简体中文

[沃拓克斯的暗影秘典](https://github.com/Lmedeiros-leiman/DST-CodexUmbraForWortox)的扩展，让《饥荒联机版》的所有角色都能制作并使用麦斯威尔的暗影秘典。

- **规则与麦斯威尔相同：**暗影仆人和暗影角斗士、暗影陷阱和暗影囚牢，施法消耗噩梦燃料，每个暗影傀儡降低理智上限。
- **暗影是施法者的剪影**，颜色取决于阵营：无阵营为麦斯威尔的黑色，月亮为发光的虚影青色，暗影为虚空紫。
- **每个角色都有专属台词**，支持英语、巴西葡萄牙语、简体中文和俄语。完整表格见 [LINES.md](LINES.md)。
- 麦斯威尔与原版相同；沃拓克斯保留基础模组的功能；韦斯默默使用这本书。

**需要**沃拓克斯的暗影秘典 **0.2.0 或更新版本**，并开启其暗影秘典选项。

## Русский

Дополнение к [«Кодекс Умбра для Вортокса»](https://github.com/Lmedeiros-leiman/DST-CodexUmbraForWortox): все персонажи Don't Starve Together могут создавать и использовать Кодекс Умбра Максвелла.

- **Правила те же, что у Максвелла:** теневые слуги и партнёры, теневые уловка и клетка, топливо кошмара за заклинание, штраф к максимальному рассудку за каждую тень.
- **Тени — силуэты призвавшего**, окрашенные по союзу: нет — чёрный, как у Максвелла, лунный — светящийся голубой, как у гештальта, теневой — фиолетовый цвет пустоты.
- **У каждого персонажа свои реплики** на английском, португальском (Бразилия), упрощённом китайском и русском. Полная таблица — в [LINES.md](LINES.md).
- Максвелл играет как в оригинале; Вортокс сохраняет возможности базового мода; Уэс пользуется книгой молча.

**Требуется** «Кодекс Умбра для Вортокса» **версии 0.2.0 или новее** с включённой настройкой «Кодекс Умбра».

## Development

```bash
lua5.1 test/test_addon.lua            # also runs an integration test against ../DST-WortoxShenanigans
python3 -I tools/build_lines.py drafts codex_everyone_lines.lua LINES.md
```

`codex_everyone_lines.lua` and `LINES.md` are generated from the drafts in `drafts/` (one JSON file per character with the lines in four languages and literal English meanings).

## Credits

Don't Starve Together, its characters and the Codex Umbra belong to Klei Entertainment. The mod icon is assembled from game art. This is an unofficial fan mod, not made or endorsed by Klei.
