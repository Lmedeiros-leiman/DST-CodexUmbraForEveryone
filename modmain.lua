-- Codex Umbra for Everyone
-- Add-on for Codex Umbra for Wortox: every character can craft and use the
-- Codex Umbra like Maxwell. The base mod's engine does the work through its
-- CodexUmbraForWortox API; this mod picks who, the colours and the lines.

modimport("codex_everyone_lines.lua")
local LINES = codex_everyone_lines

-- Maxwell already has the Codex; Wortox is handled by the base mod. Every
-- other player prefab, modded characters included, gets the hook.
local EXCLUDED = { waxwell = true, wortox = true }

-- Examine statuses for shadows summoned through this add-on. The base mod's
-- Wortox shadows use WORTOX_MINE / WORTOX_OTHER.
local MINE, OTHER = "CODEX_MINE", "CODEX_OTHER"

-- The base mod may load after this one or be off; look the API up when it
-- is needed, with rawget so strict.lua never throws.
local function GetApi()
    return GLOBAL.rawget(GLOBAL, "CodexUmbraForWortox")
end

---------------------------------------------------------------------------
-- Lines
---------------------------------------------------------------------------

-- Same rules as the base mod: the "language" option can force one, "auto"
-- uses the server's game language, anything unknown falls back to English.
-- Speech is resolved on the server, so every player hears that language.
local LANGUAGE_ALIASES = { zhr = "zh" }
local function GetLanguage()
    local forced = GetModConfigData("language")
    if forced ~= nil and LINES.languages[forced] then
        return forced
    end
    local code = GLOBAL.LOC ~= nil and GLOBAL.LOC.GetLocaleCode() or "en"
    code = LANGUAGE_ALIASES[code] or code
    return LINES.languages[code] and code or "en"
end
local language = GetLanguage()

-- Speech tables are keyed by upper-case prefab, except Wilson's lines, which
-- are the GENERIC table every character falls back to.
local function SpeechTable(prefab)
    local key = prefab == "wilson" and "GENERIC" or string.upper(prefab)
    return GLOBAL.STRINGS.CHARACTERS[key]
end

local function Sub(parent, key)
    if type(parent[key]) ~= "table" then
        parent[key] = { GENERIC = parent[key] }
    end
    return parent[key]
end

local function SetLines(prefab, lines)
    local speech = SpeechTable(prefab)
    if speech == nil then
        return
    end
    local describe = Sub(speech, "DESCRIBE")
    if lines.codex ~= nil then
        Sub(describe, "WAXWELLJOURNAL").GENERIC = lines.codex
    end
    if lines.codex_needsfuel ~= nil then
        Sub(describe, "WAXWELLJOURNAL").NEEDSFUEL = lines.codex_needsfuel
    end
    if lines.no_max_sanity ~= nil then
        Sub(Sub(speech, "ACTIONFAIL"), "CASTAOE").NO_MAX_SANITY = lines.no_max_sanity
    end
    if lines.shadow_mine ~= nil then
        Sub(describe, "SHADOWWAXWELL")[MINE] = lines.shadow_mine
    end
    if lines.shadow_other ~= nil then
        Sub(describe, "SHADOWWAXWELL")[OTHER] = lines.shadow_other
    end
end

for prefab, by_language in pairs(LINES.characters) do
    SetLines(prefab, by_language[language] or by_language.en)
end

---------------------------------------------------------------------------
-- Casters
---------------------------------------------------------------------------

-- Allegiance colours: most skill trees tag the player when an allegiance is
-- chosen; the skill names cover characters that only use the skill.
local function HasAllegiance(inst, kind)
    if inst:HasTag("player_" .. kind .. "_aligned") then
        return true
    end
    local skills = inst.components.skilltreeupdater
    return skills ~= nil and skills:IsActivated(inst.prefab .. "_allegiance_" .. kind) == true
end

local function AllegianceTint(inst)
    local api = GetApi()
    if HasAllegiance(inst, "lunar") then
        return api.TINT_GESTALT
    elseif HasAllegiance(inst, "shadow") then
        return api.TINT_VOID_VIOLET
    end
    return api.TINT_NONE
end

local CASTER = { tint = AllegianceTint, mine = MINE, other = OTHER }

local warned = false
AddPlayerPostInit(function(inst)
    if EXCLUDED[inst.prefab] then
        return
    end
    local api = GetApi()
    if api == nil then
        if not warned then
            warned = true
            print("[Codex Umbra for Everyone] Codex Umbra for Wortox (with its Codex Umbra option) is required; characters keep the vanilla Codex.")
        end
        return
    end
    api.EnableShadowCaster(inst, CASTER)
end)
