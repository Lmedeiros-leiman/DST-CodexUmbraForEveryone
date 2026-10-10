-- Lua 5.1 harness for Codex Umbra for Everyone.
-- Run from the mod root: lua5.1 test/test_addon.lua
-- The integration part loads the base mod from ../DST-WortoxShenanigans when
-- that checkout exists next to this one.

local mod_root = arg[0]:match("^(.*)/test/test_addon%.lua$")
if mod_root == nil or mod_root == "" then
    mod_root = "."
end
local base_root = mod_root .. "/../DST-WortoxShenanigans"

local count, failures = 0, 0

local function assert_eq(actual, expected, label)
    count = count + 1
    if actual ~= expected then
        failures = failures + 1
        io.stderr:write(string.format("FAIL: %s (expected %s, got %s)\n", label, tostring(expected), tostring(actual)))
    end
end

local function assert_true(value, label)
    assert_eq(value == true and true or false, true, label)
end

local CHARACTERS = { "GENERIC", "WILLOW", "WOLFGANG", "WENDY", "WX78", "WICKERBOTTOM", "WOODIE", "WES",
    "WAXWELL", "WATHGRITHR", "WEBBER", "WINONA", "WARLY", "WORTOX", "WORMWOOD", "WURT", "WALTER", "WANDA" }

local function new_strings()
    local characters = {}
    for _, name in ipairs(CHARACTERS) do
        -- Vanilla shape: a WAXWELLJOURNAL table with a GENERIC line; CASTAOE
        -- missing for some characters, which the add-on must create.
        characters[name] = { DESCRIBE = { WAXWELLJOURNAL = { GENERIC = "vanilla " .. name } }, ACTIONFAIL = {} }
    end
    characters.WORTOX.ACTIONFAIL.CASTAOE = {}
    characters.WORTOX.DESCRIBE.WAXWELLJOURNAL = {}
    return { CHARACTERS = characters }
end

local function new_global(ismastersim, locale)
    local G = {
        TheWorld = { ismastersim = ismastersim },
        STRINGS = new_strings(),
        rawget = rawget,
        printed = {},
    }
    G.print = function(text) table.insert(G.printed, text) end
    if locale ~= nil then
        G.LOC = { GetLocaleCode = function() return locale end }
    end
    return G
end

-- Loads a mod's modmain into its own env, sharing GLOBAL like DST does.
local function load_env(root, G, config, extra)
    local env = {
        MODROOT = root .. "/",
        GLOBAL = G,
        pairs = pairs, ipairs = ipairs, math = math, table = table, type = type,
        string = string, tostring = tostring, require = require,
        print = function(...) G.print(table.concat({ ... }, " ")) end,
        postinits = {}, player_postinits = {}, sg_postinits = {},
    }
    env.env = env
    env.GetModConfigData = function(name) return (config or {})[name] end
    env.AddPrefabPostInit = function(prefab, fn) table.insert(env.postinits, { prefab = prefab, fn = fn }) end
    env.AddPlayerPostInit = function(fn) table.insert(env.player_postinits, fn) end
    env.AddStategraphPostInit = function(name, fn) table.insert(env.sg_postinits, { name = name, fn = fn }) end
    env.modimport = function(name)
        local chunk = assert(loadfile(env.MODROOT .. name))
        setfenv(chunk, env)
        chunk()
    end
    for k, v in pairs(extra or {}) do
        env[k] = v
    end
    local chunk = assert(loadfile(root .. "/modmain.lua"))
    setfenv(chunk, env)
    chunk()
    return env
end

local function load_addon(G, config)
    return load_env(mod_root, G, config)
end

-- Minimal player entity with tags, events and a skill tree.
local function new_player(prefab)
    local inst = { prefab = prefab, tags = {}, components = {}, listeners = {} }
    function inst:AddTag(t) self.tags[t] = true end
    function inst:RemoveTag(t) self.tags[t] = nil end
    function inst:HasTag(t) return self.tags[t] == true end
    function inst:ListenForEvent(e, fn, src)
        local target = src or self
        target.listeners[e] = target.listeners[e] or {}
        table.insert(target.listeners[e], fn)
    end
    function inst:PushEvent(e, data)
        for _, fn in ipairs(self.listeners[e] or {}) do fn(self, data) end
    end
    inst.components.skilltreeupdater = { active = {} }
    function inst.components.skilltreeupdater:IsActivated(skill) return self.active[skill] == true end
    return inst
end

local function fake_api(G)
    local api = { version = 1, TINT_NONE = 0, TINT_GESTALT = 5, TINT_VOID_VIOLET = 10, enabled = {} }
    function api.EnableShadowCaster(inst, config)
        table.insert(api.enabled, { inst = inst, config = config })
    end
    G.CodexUmbraForWortox = api
    return api
end

---------------------------------------------------------------------------
-- Lines data
---------------------------------------------------------------------------
do
    local env = load_addon(new_global(true))
    local data = env.codex_everyone_lines
    local full = { "codex", "codex_needsfuel", "no_max_sanity", "shadow_mine", "shadow_other" }
    local expected = { "wilson", "willow", "wolfgang", "wendy", "wx78", "wickerbottom", "woodie", "wathgrithr",
        "webber", "winona", "warly", "wormwood", "wurt", "walter", "wanda" }
    for _, prefab in ipairs(expected) do
        for _, lang in ipairs({ "en", "pt", "zh", "ru" }) do
            local lines = data.characters[prefab] and data.characters[prefab][lang] or {}
            for _, key in ipairs(full) do
                assert_true(type(lines[key]) == "string" and #lines[key] > 0, prefab .. "/" .. lang .. "/" .. key .. " is written")
            end
        end
    end
    for _, prefab in ipairs({ "waxwell", "wortox" }) do
        for _, lang in ipairs({ "en", "pt", "zh", "ru" }) do
            local lines = data.characters[prefab][lang]
            assert_true(type(lines.shadow_other) == "string", prefab .. "/" .. lang .. " has its other-shadow line")
            assert_eq(lines.codex, nil, prefab .. "/" .. lang .. " keeps its own Codex lines")
        end
    end
    assert_eq(data.characters.wes, nil, "Wes stays silent (mime)")
end

---------------------------------------------------------------------------
-- Strings land in each character's speech table
---------------------------------------------------------------------------
do
    local G = new_global(true, "en")
    local env = load_addon(G)
    local chars = G.STRINGS.CHARACTERS
    local data = env.codex_everyone_lines.characters

    assert_eq(chars.GENERIC.DESCRIBE.WAXWELLJOURNAL.GENERIC, data.wilson.en.codex, "Wilson's lines live in GENERIC")
    assert_eq(chars.WOLFGANG.DESCRIBE.WAXWELLJOURNAL.GENERIC, data.wolfgang.en.codex, "Wolfgang's Codex line replaces vanilla")
    assert_eq(chars.WOLFGANG.DESCRIBE.WAXWELLJOURNAL.NEEDSFUEL, data.wolfgang.en.codex_needsfuel, "Wolfgang's fuel line")
    assert_eq(chars.WOLFGANG.ACTIONFAIL.CASTAOE.NO_MAX_SANITY, data.wolfgang.en.no_max_sanity, "CASTAOE is created for the failure line")
    assert_eq(chars.WX78.DESCRIBE.SHADOWWAXWELL.CODEX_MINE, data.wx78.en.shadow_mine, "own-shadow line under CODEX_MINE")
    assert_eq(chars.WX78.DESCRIBE.SHADOWWAXWELL.CODEX_OTHER, data.wx78.en.shadow_other, "other-shadow line under CODEX_OTHER")
    assert_eq(chars.WATHGRITHR.DESCRIBE.SHADOWWAXWELL.CODEX_MINE, data.wathgrithr.en.shadow_mine, "Wigfrid uses WATHGRITHR")

    assert_eq(chars.WAXWELL.DESCRIBE.WAXWELLJOURNAL.GENERIC, "vanilla WAXWELL", "Maxwell keeps his vanilla Codex line")
    assert_eq(chars.WAXWELL.DESCRIBE.SHADOWWAXWELL.CODEX_OTHER, data.waxwell.en.shadow_other, "Maxwell comments on others' shadows")
    assert_eq(chars.WORTOX.DESCRIBE.SHADOWWAXWELL.CODEX_OTHER, data.wortox.en.shadow_other, "Wortox comments on mortals' shadows")
    assert_eq(chars.WORTOX.DESCRIBE.WAXWELLJOURNAL.GENERIC, nil, "Wortox's Codex line is left to the base mod")
    assert_eq(chars.WES.DESCRIBE.SHADOWWAXWELL, nil, "Wes gets no lines")
end

-- Language selection mirrors the base mod.
do
    local function codex_line(locale, forced)
        local G = new_global(true, locale)
        load_addon(G, { language = forced })
        return G.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.WAXWELLJOURNAL.GENERIC
    end
    local data = load_addon(new_global(true)).codex_everyone_lines.characters.wolfgang
    assert_eq(codex_line("pt"), data.pt.codex, "Portuguese server gets Portuguese")
    assert_eq(codex_line("zh"), data.zh.codex, "Chinese server gets Chinese")
    assert_eq(codex_line("zhr"), data.zh.codex, "WeGame Chinese gets Chinese")
    assert_eq(codex_line("ru"), data.ru.codex, "Russian server gets Russian")
    assert_eq(codex_line("fr"), data.en.codex, "other languages fall back to English")
    assert_eq(codex_line(nil), data.en.codex, "no locale is English")
    assert_eq(codex_line("en", "ru"), data.ru.codex, "the option forces Russian")
    assert_eq(codex_line("pt", "auto"), data.pt.codex, "auto follows the server")
    assert_eq(codex_line("pt", "klingon"), data.pt.codex, "unknown option values fall back to auto")
end

---------------------------------------------------------------------------
-- Casters
---------------------------------------------------------------------------
do
    local G = new_global(true)
    local api = fake_api(G)
    local env = load_addon(G)
    local postinit = env.player_postinits[1]
    assert_true(postinit ~= nil, "a player post init is registered")

    for _, prefab in ipairs({ "waxwell", "wortox" }) do
        postinit(new_player(prefab))
    end
    assert_eq(#api.enabled, 0, "Maxwell and Wortox are not hooked by the add-on")

    local wilson, wes, modded = new_player("wilson"), new_player("wes"), new_player("modded_hero")
    postinit(wilson)
    postinit(wes)
    postinit(modded)
    assert_eq(#api.enabled, 3, "every other player prefab is hooked, modded ones included")
    local config = api.enabled[1].config
    assert_eq(config.mine, "CODEX_MINE", "own shadows use CODEX_MINE")
    assert_eq(config.other, "CODEX_OTHER", "other viewers use CODEX_OTHER")

    assert_eq(config.tint(wilson), 0, "no allegiance keeps Maxwell's black")
    wilson:AddTag("player_lunar_aligned")
    assert_eq(config.tint(wilson), 5, "the lunar tag gives gestalt cyan")
    wilson:RemoveTag("player_lunar_aligned")
    wilson:AddTag("player_shadow_aligned")
    assert_eq(config.tint(wilson), 10, "the shadow tag gives void violet")
    local skilled = new_player("wormwood")
    skilled.components.skilltreeupdater.active.wormwood_allegiance_lunar = true
    assert_eq(config.tint(skilled), 5, "an allegiance skill without the tag still counts")
end

-- Without the base mod nothing breaks and the server log says why, once.
do
    local G = new_global(true)
    local env = load_addon(G)
    env.player_postinits[1](new_player("wilson"))
    env.player_postinits[1](new_player("willow"))
    local warnings = 0
    for _, text in ipairs(G.printed) do
        if text:find("Codex Umbra for Wortox", 1, true) then
            warnings = warnings + 1
        end
    end
    assert_eq(warnings, 1, "a missing base mod is reported once")
    assert_eq(G.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.WAXWELLJOURNAL.GENERIC ~= "vanilla WOLFGANG", true,
        "lines still load without the base mod")
end

---------------------------------------------------------------------------
-- modinfo
---------------------------------------------------------------------------
do
    local function modinfo_for(locale)
        local env = { locale = locale }
        local chunk = assert(loadfile(mod_root .. "/modinfo.lua"))
        setfenv(chunk, env)
        chunk()
        return env
    end
    local en, pt, zh, zhr, ru = modinfo_for("en"), modinfo_for("pt"), modinfo_for("zh"), modinfo_for("zhr"), modinfo_for("ru")
    assert_eq(en.name, "Codex Umbra for Everyone", "English name")
    assert_eq(pt.name, "Codex Umbra para Todos", "Portuguese name")
    assert_eq(zh.name, "人人可用的暗影秘典", "Chinese name")
    assert_eq(zhr.name, zh.name, "WeGame Chinese name")
    assert_eq(ru.name, "Кодекс Умбра для всех", "Russian name")
    assert_eq(modinfo_for("fr").name, en.name, "other languages fall back to English")
    local dep = en.mod_dependencies and en.mod_dependencies[1] or {}
    assert_eq(dep.wortox_shenanigans, false, "depends on the base mod's local folder")
    assert_eq(dep["Codex Umbra for Wortox"], true, "depends on the base mod's name")
    assert_eq(dep.workshop, "workshop-3816756986", "depends on the published Workshop item")
    assert_eq(en.all_clients_require_mod, true, "every client needs the add-on")
end

---------------------------------------------------------------------------
-- Integration with the real base mod
---------------------------------------------------------------------------
local base_main = io.open(base_root .. "/modmain.lua")
if base_main == nil then
    print("SKIP: base mod not found at " .. base_root)
else
    base_main:close()
    local G = new_global(true, "en")
    G.global = function() end
    G.net_smallbyte = function()
        local v = { current = 0 }
        function v:set(x) self.current = x end
        function v:value() return self.current end
        return v
    end
    G.TUNING = { SHADOWWAXWELL_SANITY_PENALTY = { SHADOWWORKER = .15, SHADOWPROTECTOR = .15 } }
    G.STRINGS.CHARACTERS.WORTOX.DESCRIBE.WAXWELLJOURNAL = {}
    local base = load_env(base_root, G, {})
    local addon = load_addon(G)
    assert_true(type(rawget(G, "CodexUmbraForWortox")) == "table", "the base mod publishes its API")

    local function find_postinit(env, prefab)
        for _, p in ipairs(env.postinits) do
            if p.prefab == prefab then return p.fn end
        end
    end

    -- A server-side Willow with a vanilla pet leash (critter) and sanity.
    local willow = new_player("willow")
    willow.components.health = { IsDead = function() return false end }
    willow.components.sanity = { penalties = {} }
    function willow.components.sanity:AddSanityPenalty(pet, v) self.penalties[pet] = v end
    function willow.components.sanity:RemoveSanityPenalty(pet) self.penalties[pet] = nil end
    local petleash = { pets = {}, maxpets = 1 }
    function petleash:GetMaxPets() return self.maxpets end
    function petleash:SetMaxPets(v) self.maxpets = v end
    function petleash:SetMaxPetsForPrefab(p, v) self.perprefab = self.perprefab or {}; self.perprefab[p] = v end
    function petleash:SetOnSpawnFn(fn) self.onspawnfn = fn end
    function petleash:SetOnDespawnFn(fn) self.ondespawnfn = fn end
    function petleash:GetPets() return self.pets end
    petleash.onspawnfn = function() willow.critter_spawned = true end
    petleash.ondespawnfn = function() end
    willow.components.petleash = petleash

    addon.player_postinits[1](willow)
    assert_true(willow:HasTag("shadowmagic"), "Willow can craft and read the Codex")
    assert_eq(petleash.perprefab and petleash.perprefab.shadowworker, 6, "Willow gets the shadow pet limits")
    assert_eq(petleash.maxpets, 1, "Willow's shared pet pool is untouched")

    local critter = new_player("critter_kitten")
    petleash.onspawnfn(willow, critter)
    assert_true(willow.critter_spawned, "Willow's vanilla pet callback still runs")

    local shadow = new_player("shadowworker")
    shadow:AddTag("shadowminion")
    shadow.components.skinner = { CopySkinsFromPlayer = function(self, p) self.copied = p end }
    shadow.components.follower = { GetLeader = function() return willow end }
    shadow.AnimState = {
        SetMultColour = function() end, SetAddColour = function(self) self.tinted = true end,
        SetLightOverride = function() end, SetBloomEffectHandle = function() end, ClearBloomEffectHandle = function() end,
    }
    function shadow:AddComponent(name) self.components[name] = {} end
    find_postinit(base, "shadowworker")(shadow)
    petleash.onspawnfn(willow, shadow)
    assert_eq(willow.components.sanity.penalties[shadow], .15, "Willow pays Maxwell's sanity cost")
    assert_eq(shadow.components.skinner.copied, willow, "the shadow wears Willow's skin")
    assert_eq(shadow.AnimState.tinted, nil, "no allegiance keeps Maxwell's black")
    local status = shadow.components.inspectable.getstatus
    assert_eq(status(shadow, willow), "CODEX_MINE", "Willow sees her own shadow line")
    assert_eq(status(shadow, new_player("wilson")), "CODEX_OTHER", "others see their other-shadow line")
    assert_eq(G.STRINGS.CHARACTERS.WILLOW.DESCRIBE.SHADOWWAXWELL.CODEX_MINE,
        addon.codex_everyone_lines.characters.willow.en.shadow_mine, "that status maps to Willow's line")

    -- Base and add-on lines share SHADOWWAXWELL tables without clobbering.
    assert_true(G.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.SHADOWWAXWELL.WORTOX_OTHER ~= nil, "Maxwell keeps his Wortox line")
    assert_true(G.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.SHADOWWAXWELL.CODEX_OTHER ~= nil, "and gains his everyone line")

    local wortox = new_player("wortox")
    addon.player_postinits[1](wortox)
    assert_eq(wortox._codexumbra, nil, "the add-on leaves Wortox to the base mod")
end

if failures > 0 then
    io.stderr:write(string.format("%d/%d tests failed\n", failures, count))
    os.exit(1)
end
print(string.format("%d/%d tests passed", count, count))
