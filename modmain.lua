-- Codex Umbra for Everyone
-- Add-on for Codex Umbra for Wortox: every character can craft and use the
-- Codex Umbra like Maxwell. The base mod's engine does the work through its
-- CodexUmbraForWortox API; this mod picks who, the colours and the lines.

modimport("codex_everyone_lines.lua")
local LINES = codex_everyone_lines

-- Maxwell already has the Codex; Wortox is handled by the base mod. Every
-- other player prefab, modded characters included, gets the hook.
local EXCLUDED = { waxwell = true, wortox = true }

-- Host options: one switch per vanilla character ("allow_<prefab>") and one
-- for every modded character ("allow_modded"). All default to allowed.
local VANILLA = {
    wilson = true, willow = true, wolfgang = true, wendy = true, wx78 = true, wickerbottom = true,
    woodie = true, wes = true, waxwell = true, wathgrithr = true, webber = true, winona = true,
    warly = true, wortox = true, wormwood = true, wurt = true, walter = true, wanda = true,
}

local function IsAllowed(prefab)
    local option = VANILLA[prefab] and "allow_" .. prefab or "allow_modded"
    return GetModConfigData(option) ~= false
end

-- Examine statuses for shadows summoned through this add-on. The base mod's
-- Wortox shadows use WORTOX_MINE / WORTOX_OTHER.
local MINE, OTHER = "CODEX_MINE", "CODEX_OTHER"

-- Someone else's shadow gets a status from its owner's gender (DST's
-- CHARACTER_GENDERS, which modded characters register into), so a line can
-- say "more of him" or "more of her". Plural, neutral and unknown use OTHER.
-- Each status maps to an optional per-gender line, else shadow_other.
local GENDER_STATUS = { MALE = "CODEX_OTHER_MALE", FEMALE = "CODEX_OTHER_FEMALE", ROBOT = "CODEX_OTHER_ROBOT" }
local STATUS_LINE = {
    CODEX_OTHER_MALE = "shadow_other_male",
    CODEX_OTHER_FEMALE = "shadow_other_female",
    CODEX_OTHER_ROBOT = "shadow_other_robot",
}

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
        local shadow = Sub(describe, "SHADOWWAXWELL")
        shadow[OTHER] = lines.shadow_other
        for status, key in pairs(STATUS_LINE) do
            shadow[status] = lines[key] or lines.shadow_other
        end
    end
end

-- Allowed characters get their Codex lines. Banned ones keep their vanilla
-- Codex lines, which fit again (most say they can't use the book); Maxwell
-- and Wortox have a codex_banned line instead. Everyone keeps the line for
-- examining someone else's shadow.
for prefab, by_language in pairs(LINES.characters) do
    local lines = by_language[language] or by_language.en
    local shown = {
        shadow_other = lines.shadow_other,
        shadow_other_male = lines.shadow_other_male,
        shadow_other_female = lines.shadow_other_female,
        shadow_other_robot = lines.shadow_other_robot,
    }
    if IsAllowed(prefab) then
        shown.codex = lines.codex
        shown.codex_needsfuel = lines.codex_needsfuel
        shown.no_max_sanity = lines.no_max_sanity
        shown.shadow_mine = lines.shadow_mine
    else
        shown.codex = lines.codex_banned
    end
    SetLines(prefab, shown)
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

-- Characters whose shadows always take one allegiance colour, whatever
-- their skill tree says. Wormwood is a lunar plant creature.
local FIXED_ALLEGIANCE = { wormwood = "lunar" }

local function AllegianceTint(inst)
    local api = GetApi()
    local fixed = FIXED_ALLEGIANCE[inst.prefab]
    if fixed == "lunar" then
        return api.TINT_GESTALT
    elseif fixed == "shadow" then
        return api.TINT_VOID_VIOLET
    end
    if HasAllegiance(inst, "lunar") then
        return api.TINT_GESTALT
    elseif HasAllegiance(inst, "shadow") then
        return api.TINT_VOID_VIOLET
    end
    return api.TINT_NONE
end

local function OtherStatus(pet, viewer, leader)
    local gender = leader ~= nil and GLOBAL.GetGenderStrings(leader.prefab) or nil
    return GENDER_STATUS[gender] or OTHER
end

local CASTER = { tint = AllegianceTint, mine = MINE, other = OtherStatus }

-- Version 2 lets config.other be a function (Codex Umbra for Wortox 0.2.0).
local API_VERSION = 2

-- Runs a frame after spawning, once every mod's post init is done (the base
-- mod adds the tag to Wortox), on both sides so crafting and the spellbook
-- agree. Without the tag the Codex can be neither crafted nor opened.
local function RemoveShadowMagic(inst)
    inst:RemoveTag("shadowmagic")
end

local warned = false
AddPlayerPostInit(function(inst)
    if not IsAllowed(inst.prefab) then
        inst:DoTaskInTime(0, RemoveShadowMagic)
        return
    end
    if EXCLUDED[inst.prefab] then
        return
    end
    local api = GetApi()
    if api == nil or (api.version or 1) < API_VERSION then
        if not warned then
            warned = true
            print("[Codex Umbra for Everyone] Codex Umbra for Wortox 0.2.0 or newer (with its Codex Umbra option) is required; characters keep the vanilla Codex.")
        end
        return
    end
    api.EnableShadowCaster(inst, CASTER)
end)
