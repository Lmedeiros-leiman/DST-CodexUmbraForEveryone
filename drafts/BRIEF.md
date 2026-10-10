# Brief: write one Don't Starve Together character's lines for "Codex Umbra for Everyone"

You are a game writer and localizer with a deep ear for Don't Starve Together's characters. You will write a handful of new lines for ONE character (named in your task message), in four languages, and they must sound like that character wrote them, not like a translation or a generic placeholder.

## The mod (why these lines exist)

"Codex Umbra for Wortox" (already published) lets Wortox use Maxwell's Codex Umbra. The new add-on, "Codex Umbra for Everyone", lets EVERY character craft and use the Codex Umbra exactly like Maxwell: it summons shadow servants (workers that chop/mine/dig, and protectors that fight), casts a shadow trap and shadow pillars, costs nightmare fuel per spell, and each summoned shadow lowers the caster's maximum sanity. Important flavour fact: the summoned shadows are silhouettes of the CASTER, wearing the caster's own skin. So when a character looks at their own shadow, they are looking at a shadowy copy of themselves. Shadows are tinted by the caster's allegiance (none: Maxwell's black, lunar: glowing gestalt cyan, shadow: dark void violet).

Until now, in the base game, only Maxwell could use the book, and most characters' existing lines about it assume they can't read or use it (e.g. Wolfgang: "Wolfgang is glad he cannot read!"). Those lines are being replaced because now they CAN use it.

## The lines you write (keys and the exact game moment)

| key | when it is said | notes |
|---|---|---|
| `codex` | The character examines the Codex Umbra (it has fuel). | They can now use it. React in character: delight, dread, curiosity, suspicion, pragmatism... |
| `codex_needsfuel` | The character examines the Codex when it is out of nightmare fuel. | Should make clear (in character) that it needs fuel / is empty / is dormant. |
| `no_max_sanity` | The character tries to summon another shadow, but their mind is already too burdened by the shadows they have out (max sanity penalty cap). | A failure line: "my mind can't take more". Must be understandable as "can't summon more right now". |
| `shadow_mine` | The character examines a shadow they summoned themselves (a shadowy copy of themselves). | The self-copy is great material. |
| `shadow_other` | The character examines a shadow summoned by another player (a shadowy copy of THAT player). | They don't know exactly whose; it's someone else's. |

Your task message may list only some of these keys (for characters who already have the others). Write exactly the keys you are given.

Length: like vanilla examine lines, usually 3 to 14 words in English, never more than two short sentences. Lines show in a speech bubble.

## Research (do this before writing; take your time)

The game's scripts come from `data/databundles/scripts.zip` in the Don't Starve Together install; extract them somewhere and treat them as read-only. Paths below are relative to its `scripts` folder.

1. Read the character's whole speech file `speech_<character>.lua` (for Wigfrid it is `speech_wathgrithr.lua`, WX-78 `speech_wx78.lua`, Maxwell `speech_waxwell.lua`). Absorb their vocabulary, sentence rhythm, verbal tics, recurring topics, how they talk about magic, shadows, books, Maxwell, sanity and insanity (search for `ANNOUNCE_SANITY`, `INSANE`, `SHADOW`, `WAXWELL`, `BOOK`, `NIGHTMARE`). Lines that say `only_used_by_...` or are commented `--fallback to speech_wilson.lua` are not theirs.
2. Read their character description, title and quote in `strings.lua` (`CHARACTER_TITLES`, `CHARACTER_QUOTES`, `CHARACTER_DESCRIPTIONS`, `CHARACTER_BIOS`) and skim their skill tree strings (`SKILLTREE.<CHARACTER>`) for personality and lore.
3. Study how the OFFICIAL translations render this character, in `languages/portuguese_br.po` (Brazilian Portuguese), `languages/chinese_s.po` (Simplified Chinese) and `languages/russian.po`. Entries look like:
   ```
   #. STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.WAXWELLJOURNAL.GENERIC
   msgctxt "STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.WAXWELLJOURNAL.GENERIC"
   msgid "Wolfgang is glad he cannot read!"
   msgstr "..."
   ```
   Grep for `STRINGS.CHARACTERS.<CHARACTER_IN_CAPS>.` and read a good sample (at least 30 lines per language, including their lines about books, shadows, Maxwell, and their most characteristic quirks). Note exactly how each language carries the character's tics: grammar quirks, catchphrases, onomatopoeia, capitalisation, pronouns, honorifics, how they say their companion's name, etc. Your translations must follow those conventions, not invent new ones.

## Writing rules (from the mod's author; these are firm)

- Natural speech first. Each line must sound like something this character would really say. No translationese, no stiff or literal phrasing.
- No forced rhymes. Rhyme only if this character naturally rhymes (in DST, essentially only Wortox does). Never twist word order or invent words to rhyme.
- No cute diminutives or word-forms used just for sound (the author rejected "pesadelinho/mortinho"-style tricks).
- Translations are adaptations: keep the same idea, joke and attitude as your English line, rewritten so a native speaker finds it natural and recognises the character's official voice in that language. If a joke does not survive, find the equivalent joke in that language rather than translating word for word.
- Stay inside the game world; no meta or modern references the character would not make.
- Do not contradict mechanics: they CAN use the book now; the shadows are copies of the caster; the failure line is about mental strain.

## Official glossary (use these exact names)

| English | Português (BR) | 简体中文 | Русский |
|---|---|---|---|
| Codex Umbra | Codex Umbra | 暗影秘典 | Кодекс Умбра («Кодекс Умбра») |
| Maxwell | Maxwell | 麦斯威尔 | Максвелл |
| Wortox | Wortox | 沃拓克斯 | Вортокс |
| shadow (the minion) | Sombra | 暗影傀儡 (generic: 暗影, 影子) | Тень |
| nightmare fuel | combustível de pesadelo | 噩梦燃料 | топливо кошмара |
| sanity | sanidade | 理智 | рассудок |
| shadow worker / protector | Servo Umbral / Duelista das sombras | 暗影仆人 / 暗影角斗士 | Теневой слуга / Теневой партнер |

Check the .po files for any other term you use (character names, companions such as Abigail, Lucy, Woby, Bernie, Wolfgang's mightiness, etc.) and use the official rendering.

## Output

Write a single JSON file (UTF-8, valid JSON, no comments) to the path given in your task message, with this shape:

```json
{
  "character": "wolfgang",
  "lines": {
    "en": { "codex": "...", "codex_needsfuel": "...", "no_max_sanity": "...", "shadow_mine": "...", "shadow_other": "..." },
    "pt": { "...same keys..." },
    "zh": { "...same keys..." },
    "ru": { "...same keys..." }
  },
  "literal": {
    "pt": { "codex": "literal English meaning of the Portuguese line", "...": "..." },
    "zh": { "...": "..." },
    "ru": { "...": "..." }
  },
  "voice_notes": "3-6 sentences: what defines this character's voice, and how each official translation carries it (cite one or two official lines you modelled on).",
  "line_notes": { "codex": "why this line works for this character (one sentence)", "...": "..." }
}
```

Include only the keys your task message asks for, in every language. Validate the JSON before finishing (for example `python3 -c 'import json,sys; json.load(open(sys.argv[1]))' <file>`).

Do not edit any other file. Your final message should be short: the file path and the English lines.
