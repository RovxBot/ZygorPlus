-- Small, 3.3.5-safe locale facade. The original locale payload is bundled as
-- source material, but is intentionally not loaded because it assumes the 8.1
-- runtime. Missing strings always fall back to enUS.
local ZGV = ZygorGuidesViewer

local enUS = {
  ADDON_NAME = "Zygor Guides Viewer",
  NO_GUIDE = "Choose a guide to begin",
  GUIDE_MENU = "Guide Menu",
  SEARCH = "Search guides",
  FAVORITES = "Favorites",
  HISTORY = "History",
  ALL_GUIDES = "All Guides",
  PREVIOUS = "Previous step",
  NEXT = "Next step",
  OPTIONS = "Options",
  CLOSE = "Close",
  COMPLETE = "Complete",
  LOADING = "Loading guide content...",
  NO_RESULTS = "No matching guides",
  MIGRATION_DONE = "Legacy settings were imported without changing the old SavedVariables.",
  MIGRATION_PARTIAL = "Legacy settings were imported; some guide titles could not be mapped.",
  NO_TREND_DATA = "No trend data has been imported for this realm.",
  ROUTE_UNAVAILABLE = "No safe route is available for this destination.",
  GOSSIP_AMBIGUOUS = "More than one gossip option matches. Select it manually.",
  REWARD_CHOICE = "Choose a quest reward, then continue.",
  ERRORS = "Errors",
  COPY_HINT = "Press Ctrl+C to copy this report.",
}

local translations = {
  deDE = { NO_GUIDE="W\195\164hle einen Guide aus", SEARCH="Guides durchsuchen", FAVORITES="Favoriten", HISTORY="Verlauf", OPTIONS="Optionen", CLOSE="Schlie\195\159en" },
  esES = { NO_GUIDE="Elige una gu\195\173a para comenzar", SEARCH="Buscar gu\195\173as", FAVORITES="Favoritos", HISTORY="Historial", OPTIONS="Opciones", CLOSE="Cerrar" },
  esMX = { NO_GUIDE="Elige una gu\195\173a para comenzar", SEARCH="Buscar gu\195\173as", FAVORITES="Favoritos", HISTORY="Historial", OPTIONS="Opciones", CLOSE="Cerrar" },
  frFR = { NO_GUIDE="Choisissez un guide", SEARCH="Rechercher des guides", FAVORITES="Favoris", HISTORY="Historique", OPTIONS="Options", CLOSE="Fermer" },
  ptBR = { NO_GUIDE="Escolha um guia para come\195\167ar", SEARCH="Pesquisar guias", FAVORITES="Favoritos", HISTORY="Hist\195\179rico", OPTIONS="Op\195\167\195\181es", CLOSE="Fechar" },
  ruRU = { NO_GUIDE="\208\146\209\139\208\177\208\181\209\128\208\184\209\130\208\181 \209\128\209\131\208\186\208\190\208\178\208\190\208\180\209\129\209\130\208\178\208\190", SEARCH="\208\159\208\190\208\184\209\129\208\186", FAVORITES="\208\152\208\183\208\177\209\128\208\176\208\189\208\189\208\190\208\181", HISTORY="\208\152\209\129\209\130\208\190\209\128\208\184\209\143", OPTIONS="\208\157\208\176\209\129\209\130\209\128\208\190\208\185\208\186\208\184", CLOSE="\208\151\208\176\208\186\209\128\209\139\209\130\209\140" },
  koKR = { NO_GUIDE="\236\139\156\236\158\145\237\149\160 \234\176\128\236\157\180\235\147\156\235\165\188 \236\132\160\237\131\157\237\149\152\236\132\184\236\154\148", SEARCH="\234\176\128\236\157\180\235\147\156 \234\178\128\236\131\137", FAVORITES="\236\166\144\234\178\236\176\190\234\184\176", HISTORY="\234\184\176\235\161\157", OPTIONS="\236\132\164\236\160\149", CLOSE="\235\139\171\234\184\176" },
  zhCN = { NO_GUIDE="\233\128\137\230\139\169\228\184\128\228\184\170\230\140\135\229\141\151\228\187\165\229\188\128\229\167\139", SEARCH="\230\144\156\231\180\162\230\140\135\229\141\151", FAVORITES="\230\148\182\232\151\143", HISTORY="\229\142\134\229\143\178", OPTIONS="\233\128\137\233\161\185", CLOSE="\229\133\179\233\151\173" },
  zhTW = { NO_GUIDE="\233\129\184\230\147\135\228\184\128\229\128\139\230\140\135\229\141\151\228\187\165\233\150\139\229\167\139", SEARCH="\230\144\156\229\176\139\230\140\135\229\141\151", FAVORITES="\230\148\182\232\151\143", HISTORY="\230\173\183\229\143\178", OPTIONS="\233\129\184\233\160\133", CLOSE="\233\151\156\233\150\137" },
}

local locale = type(GetLocale)=="function" and GetLocale() or "enUS"
if locale == "enGB" then locale = "enUS" end
ZGV.L = setmetatable(translations[locale] or {}, { __index=enUS })
ZGV.Locale = locale

_G.BINDING_HEADER_ZYGOR_GUIDES = "Zygor Guides"
_G.BINDING_NAME_ZYGOR_TOGGLE = "Toggle guide viewer"
_G.BINDING_NAME_ZYGOR_NEXTSTEP = "Next guide step"
_G.BINDING_NAME_ZYGOR_PREVSTEP = "Previous guide step"
_G.BINDING_NAME_ZYGOR_MAGICKEY = "Use current guide action"
