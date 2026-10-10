-- English by default. The game sets `locale` for modinfo: "pt" is Portuguese
-- (Brazil), "zh" Simplified Chinese on Steam, "zhr" the same language on the
-- WeGame (Rail) release and "ru" Russian.
local ALIASES = { zhr = "zh" }
local function T(texts)
    return texts[locale] or texts[ALIASES[locale]] or texts.en
end

-- Workshop item of Codex Umbra for Wortox.
local BASE_MOD_WORKSHOP = "workshop-3816756986"

name = T{
    en = "Codex Umbra for Everyone",
    pt = "Codex Umbra para Todos",
    zh = "人人可用的暗影秘典",
    ru = "Кодекс Умбра для всех",
}
description = T{
    en = [[Add-on for Codex Umbra for Wortox: every character can craft and use Maxwell's Codex Umbra.

Same rules as Maxwell: shadow workers and protectors, shadow trap and pillars, nightmare fuel per spell and a max sanity penalty per shadow. Shadows are silhouettes of their caster, coloured by allegiance (none: Maxwell's black, Lunar: glowing gestalt cyan, Shadow: void violet), and every character has their own lines about the book and the shadows. Maxwell plays as in the base game; Wortox keeps the base mod's features.

Requires Codex Umbra for Wortox with its Codex Umbra option on.]],
    pt = [[Complemento do Codex Umbra para o Wortox: todos os personagens podem criar e usar o Codex Umbra do Maxwell.

Mesmas regras do Maxwell: servos e duelistas das sombras, armadilha e prisão sombrias, combustível de pesadelo por feitiço e penalidade de sanidade máxima por sombra. As sombras são silhuetas de quem as invoca, coloridas pela aliança (nenhuma: preto do Maxwell, Lunar: ciano brilhante de gestalt, Sombra: violeta do vazio), e cada personagem tem falas próprias sobre o livro e as sombras. O Maxwell continua como no jogo base; o Wortox mantém os recursos do mod base.

Requer o Codex Umbra para o Wortox com a opção Codex Umbra ativada.]],
    zh = [[沃拓克斯的暗影秘典的扩展：所有角色都可以制作并使用麦斯威尔的暗影秘典。

规则与麦斯威尔相同：暗影仆人和暗影角斗士、暗影陷阱和暗影囚牢，每次施法消耗噩梦燃料，每个暗影傀儡降低理智上限。暗影是施法者的剪影，颜色取决于阵营（无阵营：麦斯威尔的黑色，月亮：发光的虚影青色，暗影：虚空紫），每个角色对暗影秘典和暗影都有专属台词。麦斯威尔与原版相同；沃拓克斯保留基础模组的功能。

需要沃拓克斯的暗影秘典，并开启其暗影秘典选项。]],
    ru = [[Дополнение к «Кодекс Умбра для Вортокса»: все персонажи могут создавать и использовать Кодекс Умбра Максвелла.

Правила те же, что у Максвелла: теневые слуги и партнёры, теневые уловка и клетка, топливо кошмара за заклинание и штраф к максимальному рассудку за каждую тень. Тени — силуэты призвавшего, окрашенные по союзу (нет: чёрный, как у Максвелла, лунный: светящийся голубой, как у гештальта, теневой: фиолетовый цвет пустоты), и у каждого персонажа свои реплики о книге и тенях. Максвелл играет как в оригинале; Вортокс сохраняет возможности базового мода.

Требуется «Кодекс Умбра для Вортокса» с включённой настройкой «Кодекс Умбра».]],
}
author = "Leonardo"
version = "0.1.0"

forumthread = ""

api_version = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false

all_clients_require_mod = true
client_only_mod = false

icon = "modicon.tex"
icon_atlas = "modicon.xml"

server_filter_tags =
{
    "character",
    "maxwell",
}

-- Matched by workshop id, then by the local folder name (false) or the
-- displayed mod name (true), so local copies of the base mod count too.
mod_dependencies =
{
    {
        workshop = BASE_MOD_WORKSHOP,
        ["wortox_shenanigans"] = false,
        ["Codex Umbra for Wortox"] = true,
    },
}

configuration_options =
{
    {
        name = "language",
        label = T{ en = "Language", pt = "Idioma", zh = "语言", ru = "Язык" },
        hover = T{
            en = "Language of the characters' Codex lines in the world. Auto follows the server's language.",
            pt = "Idioma das falas dos personagens sobre o Codex no mundo. Automático segue o idioma do servidor.",
            zh = "世界中角色关于暗影秘典台词的语言。自动会跟随服务器的语言。",
            ru = "Язык реплик персонажей о Кодексе в мире. «Авто» следует языку сервера.",
        },
        options =
        {
            { description = T{ en = "Auto", pt = "Automático", zh = "自动", ru = "Авто" }, data = "auto" },
            { description = "English", data = "en" },
            { description = "Português", data = "pt" },
            { description = "简体中文", data = "zh" },
            { description = "Русский", data = "ru" },
        },
        default = "auto",
    },
}
