-- ZGV335Probe is intentionally passive.  It never accepts quests, selects
-- gossip, changes talents, sends addon messages, configures secure actions, or
-- invokes protected actions.  It records capability existence and safe events.

local ADDON_NAME = "ZGV335Probe"
local SCHEMA = 1
local MAX_SESSIONS = 10
local MAX_STRING = 96

local Probe = {}
ZGV335Probe = Probe

local eventFrame = CreateFrame("Frame")
local session
local eventsEnabled = true
local widgetObjects = {}

local SAFE_EVENTS = {
    "PLAYER_LOGIN",
    "PLAYER_ENTERING_WORLD",
    "PLAYER_LOGOUT",
    "PLAYER_REGEN_DISABLED",
    "PLAYER_REGEN_ENABLED",
    "UI_SCALE_CHANGED",
    "DISPLAY_SIZE_CHANGED",
    "ZONE_CHANGED_NEW_AREA",
    "PLAYER_LEVEL_UP",
    "QUEST_LOG_UPDATE",
    "QUEST_QUERY_COMPLETE",
    "QUEST_ACCEPTED",
    "QUEST_COMPLETE",
    "QUEST_FINISHED",
    "GOSSIP_SHOW",
    "GOSSIP_CLOSED",
    "TAXIMAP_OPENED",
    "TAXIMAP_CLOSED",
    "BAG_UPDATE",
    "BANKFRAME_OPENED",
    "BANKFRAME_CLOSED",
    "MERCHANT_SHOW",
    "MERCHANT_CLOSED",
    "AUCTION_HOUSE_SHOW",
    "AUCTION_HOUSE_CLOSED",
    "SKILL_LINES_CHANGED",
    "CHARACTER_POINTS_CHANGED",
    "PLAYER_TALENT_UPDATE",
    "GLYPH_ADDED",
    "GLYPH_REMOVED",
    "ADDON_ACTION_BLOCKED",
    "ADDON_ACTION_FORBIDDEN",
}

local API_PATHS = {
    -- Client and lifecycle
    "GetBuildInfo", "GetLocale", "GetTime", "time", "date", "InCombatLockdown",
    "IsAddOnLoaded", "LoadAddOn", "GetAddOnMetadata", "GetNumAddOns",
    -- Quest and gossip
    "QueryQuestsCompleted", "GetQuestsCompleted", "GetQuestLogTitle",
    "GetNumQuestLogEntries", "GetQuestLogQuestText", "GetQuestLogLeaderBoard",
    "GetQuestLogCompletionText", "GetQuestReward", "GetNumQuestChoices",
    "GetQuestItemInfo", "AcceptQuest", "CompleteQuest", "SelectGossipOption",
    "GetGossipOptions", "GetGossipAvailableQuests", "GetGossipActiveQuests",
    "GetQuestID", "GetCurrencyInfo", "GetCurrencyListInfo",
    "C_QuestLog", "C_GossipInfo",
    -- Map, taxi, travel
    "SetMapToCurrentZone", "GetCurrentMapContinent", "GetCurrentMapZone",
    "GetCurrentMapAreaID", "GetCurrentMapDungeonLevel", "SetMapByID",
    "SetMapZoom", "SetDungeonMapLevel", "GetPlayerMapPosition", "GetMapInfo",
    "NumTaxiNodes", "TaxiNodeName", "TaxiNodePosition", "TaxiNodeType", "TakeTaxiNode",
    "C_Map", "C_TaxiMap",
    -- Items, containers, tooltips, spells, professions
    "GetItemInfo", "GetItemInfoInstant", "GetContainerNumSlots", "GetContainerItemInfo",
    "GetContainerItemLink", "GetInventoryItemLink", "GetSpellInfo", "GetSpellLink",
    "GetNumSkillLines", "GetSkillLineInfo", "GetTradeSkillInfo", "GetTradeSkillItemLink",
    "C_Item", "C_Container", "C_Spell", "C_TradeSkillUI", "C_TooltipInfo",
    -- Talents and glyphs
    "GetNumTalentTabs", "GetTalentTabInfo", "GetNumTalents", "GetTalentInfo",
    "LearnTalent", "GetActiveTalentGroup", "SetActiveTalentGroup", "GetNumGlyphSockets",
    "GetGlyphSocketInfo", "GetGlyphLink", "GetTalentPrereqs", "C_ClassTalents",
    -- Auction, chat, timers, UI
    "GetNumAuctionItems", "GetAuctionItemInfo", "GetAuctionItemLink", "QueryAuctionItems",
    "CanSendAuctionQuery", "SendAddonMessage", "RegisterAddonMessagePrefix",
    "C_ChatInfo", "C_AuctionHouse", "C_Timer", "CreateFramePool", "CreateTexturePool",
    "Mixin", "CreateFromMixins", "GetMouseFocus", "GetMouseFoci", "SetPortraitToTexture",
    "CooldownFrame_Set", "CooldownFrame_SetTimer", "GetPetActionInfo", "GetPetActionCooldown",
}

local FRAME_METHODS = {
    "SetSize", "GetSize", "SetShown", "IsShown", "SetBackdrop", "SetBackdropColor",
    "SetClampedToScreen", "SetMovable", "RegisterForDrag", "SetScript", "HookScript",
    "SetAttribute", "GetAttribute", "IsProtected", "SetFrameStrata", "SetFrameLevel",
    "SetEnabled", "Enable", "Disable", "IsEnabled",
}

local TEXTURE_METHODS = {
    "SetTexture", "GetTexture", "SetTexCoord", "SetVertexColor", "SetBlendMode",
    "SetColorTexture", "SetAtlas", "SetRotation", "SetMask", "AddMaskTexture",
    "SetHorizTile", "SetVertTile", "SetNonBlocking", "SetDesaturated",
}

local FONTSTRING_METHODS = {
    "SetText", "GetText", "SetFont", "GetFont", "SetJustifyH", "SetJustifyV",
    "SetWordWrap", "SetNonSpaceWrap", "SetMaxLines", "SetFormattedText",
}

local TOOLTIP_METHODS = {
    "SetHyperlink", "SetBagItem", "SetInventoryItem", "SetQuestItem", "SetQuestLogItem",
    "SetUnit", "NumLines", "GetItem", "GetSpell", "SetOwner",
}

local function Now()
    local epoch = type(time) == "function" and time() or 0
    local uptime = type(GetTime) == "function" and GetTime() or 0
    return epoch, uptime
end

local function SafeString(value)
    value = tostring(value or "")
    value = string.gsub(value, "[\r\n\t]", " ")
    if string.len(value) > MAX_STRING then
        value = string.sub(value, 1, MAX_STRING) .. "..."
    end
    return value
end

local function SafeArgument(value)
    local valueType = type(value)
    if valueType == "nil" then return nil end
    if valueType == "number" or valueType == "boolean" then return value end
    if valueType == "string" then return SafeString(value) end
    return "<" .. valueType .. ">"
end

local function Resolve(path)
    local value = _G
    for component in string.gmatch(path, "[^%.]+") do
        if type(value) ~= "table" then return nil end
        value = value[component]
        if value == nil then return nil end
    end
    return value
end

local function MethodTypes(object, names)
    local result = {}
    for index = 1, #names do
        local name = names[index]
        local ok, value = pcall(function() return object[name] end)
        result[name] = ok and type(value) or "error"
    end
    return result
end

local function AddNote(note)
    if not session then return end
    session.notes[#session.notes + 1] = SafeString(note)
end

local function CaptureBuild()
    local version, build, buildDate, interface = GetBuildInfo()
    local epoch, uptime = Now()
    session.build = {
        version = version,
        build = build,
        build_date = buildDate,
        interface = interface,
        locale = type(GetLocale) == "function" and GetLocale() or nil,
        captured_epoch = epoch,
        captured_uptime = uptime,
    }
    local _, classToken = UnitClass("player")
    session.character = {
        faction = type(UnitFactionGroup) == "function" and UnitFactionGroup("player") or nil,
        class = classToken,
        level = type(UnitLevel) == "function" and UnitLevel("player") or nil,
    }
    session.display = {
        width = type(GetScreenWidth) == "function" and GetScreenWidth() or nil,
        height = type(GetScreenHeight) == "function" and GetScreenHeight() or nil,
        ui_scale = UIParent and UIParent.GetEffectiveScale and UIParent:GetEffectiveScale() or nil,
    }
end

local function CaptureAPIs()
    local api = {}
    for index = 1, #API_PATHS do
        local path = API_PATHS[index]
        api[path] = type(Resolve(path))
    end
    session.api = api
end

local function CaptureWidgets()
    local result = {}
    local frame = widgetObjects.frame
    if not frame then
        frame = CreateFrame("Frame", nil, UIParent)
        frame:Hide()
        widgetObjects.frame = frame
    end
    result.frame = MethodTypes(frame, FRAME_METHODS)

    local button = widgetObjects.button
    if not button then
        button = CreateFrame("Button", nil, UIParent)
        button:Hide()
        widgetObjects.button = button
    end
    result.button = MethodTypes(button, FRAME_METHODS)

    local texture = widgetObjects.texture
    if not texture then
        texture = frame:CreateTexture(nil, "ARTWORK")
        widgetObjects.texture = texture
    end
    result.texture = MethodTypes(texture, TEXTURE_METHODS)

    local fontString = widgetObjects.fontString
    if not fontString then
        fontString = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        widgetObjects.fontString = fontString
    end
    result.font_string = MethodTypes(fontString, FONTSTRING_METHODS)

    local tooltip = _G.ZGV335ProbeTooltip
    if not tooltip then
        tooltip = CreateFrame("GameTooltip", "ZGV335ProbeTooltip", UIParent, "GameTooltipTemplate")
    end
    tooltip:Hide()
    result.game_tooltip = MethodTypes(tooltip, TOOLTIP_METHODS)

    if widgetObjects.modernFrame then
        result.backdrop_template_create = true
    else
        local modernOK, modernFrame = pcall(CreateFrame, "Frame", nil, UIParent, "BackdropTemplate")
        result.backdrop_template_create = modernOK
        if modernOK and modernFrame then
            modernFrame:Hide()
            widgetObjects.modernFrame = modernFrame
        end
    end

    if type(InCombatLockdown) == "function" and InCombatLockdown() then
        result.secure_action_button = "skipped-in-combat"
    else
        local secureButton = widgetObjects.secureButton
        local secureOK = secureButton and true or false
        if not secureButton then
            secureOK, secureButton = pcall(CreateFrame, "Button", nil, UIParent, "SecureActionButtonTemplate")
            if secureOK and secureButton then widgetObjects.secureButton = secureButton end
        end
        result.secure_action_button = secureOK and "created-passively" or "create-error"
        if secureOK and secureButton then
            secureButton:Hide()
            if secureButton.IsProtected then
                local protectedOK, isProtected = pcall(secureButton.IsProtected, secureButton)
                result.secure_button_is_protected = protectedOK and isProtected or "query-error"
            end
        end
    end
    session.widgets = result
end

local function CaptureTextures()
    local frame = widgetObjects.frame
    if not frame then
        frame = CreateFrame("Frame", nil, UIParent)
        frame:Hide()
        widgetObjects.frame = frame
    end
    local texture = widgetObjects.texture
    if not texture then
        texture = frame:CreateTexture(nil, "ARTWORK")
        widgetObjects.texture = texture
    end
    local result = {}

    local setOK, setResult = pcall(texture.SetTexture, texture, "Interface\\Icons\\INV_Misc_QuestionMark")
    result.builtin_texture_set = setOK
    result.builtin_texture_return_type = type(setResult)
    if texture.GetTexture then
        local getOK, value = pcall(texture.GetTexture, texture)
        result.get_texture = getOK and SafeString(value) or "error"
    end
    result.texcoord_four = pcall(texture.SetTexCoord, texture, 0, 1, 0, 1)
    result.texcoord_eight = pcall(texture.SetTexCoord, texture, 0, 0, 0, 1, 1, 0, 1, 1)
    if texture.SetColorTexture then
        result.color_texture = pcall(texture.SetColorTexture, texture, 1, 1, 1, 1)
    else
        result.color_texture = false
    end
    if texture.SetRotation then
        result.rotation = pcall(texture.SetRotation, texture, 0.5)
    else
        result.rotation = false
    end
    result.note = "Format dimensions and POT/NPOT are checked offline by tools/validate_addons.py."
    session.textures = result
end

local function FrameState(frame)
    if not frame then return { present = false } end
    local result = { present = true, shown = frame.IsShown and frame:IsShown() or nil }
    if frame.GetWidth then result.width = frame:GetWidth() end
    if frame.GetHeight then result.height = frame:GetHeight() end
    if frame.GetScale then result.scale = frame:GetScale() end
    if frame.GetLeft then result.left = frame:GetLeft() end
    if frame.GetTop then result.top = frame:GetTop() end
    return result
end

local function CaptureReleaseState()
    local result = {
        windows = {
            quest = FrameState(_G.QuestFrame), gossip = FrameState(_G.GossipFrame), auction = FrameState(_G.AuctionFrame),
            talent = FrameState(_G.PlayerTalentFrame), trainer = FrameState(_G.ClassTrainerFrame), trade_skill = FrameState(_G.TradeSkillFrame),
        },
        trainer_services = type(GetNumTrainerServices) == "function" and GetNumTrainerServices() or nil,
        talent_tabs = type(GetNumTalentTabs) == "function" and GetNumTalentTabs() or nil,
        skill_lines = type(GetNumSkillLines) == "function" and GetNumSkillLines() or nil,
    }
    local questie = _G.Questie
    result.questie = {
        loaded = questie ~= nil or (type(IsAddOnLoaded) == "function" and (IsAddOnLoaded("Questie-335") or IsAddOnLoaded("Questie"))),
        autoaccept = questie and questie.db and questie.db.profile and questie.db.profile.autoaccept or false,
        autocomplete = questie and questie.db and questie.db.profile and questie.db.profile.autocomplete or false,
    }
    local zgv = _G.ZygorGuidesViewer
    if type(zgv) == "table" then
        result.zgv = { loaded = true, viewer = FrameState(zgv.UI and zgv.UI.frame), arrow = FrameState(zgv.UI and (zgv.UI.arrow or zgv.UI.arrowFrame)) }
        local runtime = zgv.Runtime
        if runtime and runtime.currentGuide then
            result.zgv.guide = { id = runtime.currentGuide.id, title = SafeString(runtime.currentGuide.title), step = runtime.currentStep }
        end
        local navigation = zgv.Navigation
        if navigation and navigation.GetArrowState then
            local ok, state = pcall(navigation.GetArrowState, navigation)
            if ok and type(state) == "table" then
                result.zgv.navigation = { status = state.status, direction = state.direction, relative = state.relative, distance = state.distance, route_index = state.routeIndex }
            else result.zgv.navigation = { status = "unavailable" } end
        end
        local sync = zgv.Sync
        if sync then
            result.zgv.sync = { protocol = sync.protocol, role = sync.Role and sync:Role() or nil, peers = sync.GetPeers and #sync:GetPeers() or nil }
        end
    else result.zgv = { loaded = false } end
    session.release_state = result
end

local function RegisterSafeEvents()
    session.event_registration = session.event_registration or {}
    for index = 1, #SAFE_EVENTS do
        local event = SAFE_EVENTS[index]
        local ok, value = pcall(eventFrame.RegisterEvent, eventFrame, event)
        session.event_registration[event] = ok and (value == false and "rejected" or "registered") or "error"
    end
end

local function UnregisterSafeEvents()
    for index = 1, #SAFE_EVENTS do
        pcall(eventFrame.UnregisterEvent, eventFrame, SAFE_EVENTS[index])
    end
end

local function RecordEvent(event, ...)
    if not session then return end
    local epoch, uptime = Now()
    local record = session.events[event]
    if not record then
        record = { count = 0 }
        session.events[event] = record
    end
    record.count = record.count + 1
    record.last_epoch = epoch
    record.last_uptime = uptime

    local argumentCount = select("#", ...)
    local types = {}
    local values = {}
    for index = 1, argumentCount do
        local value = select(index, ...)
        types[index] = type(value)
        values[index] = SafeArgument(value)
    end
    local sample = { count = argumentCount, types = types, values = values }
    if not record.first then record.first = sample end
    record.last = sample
end

local function NewSession(reason)
    ZGV335ProbeDB = ZGV335ProbeDB or {}
    if ZGV335ProbeDB.schema ~= SCHEMA then
        ZGV335ProbeDB = { schema = SCHEMA, sessions = {} }
    end
    ZGV335ProbeDB.sessions = ZGV335ProbeDB.sessions or {}
    while #ZGV335ProbeDB.sessions >= MAX_SESSIONS do
        table.remove(ZGV335ProbeDB.sessions, 1)
    end
    local epoch, uptime = Now()
    session = {
        schema = SCHEMA,
        reason = reason or "load",
        started_epoch = epoch,
        started_uptime = uptime,
        api = {},
        events = {},
        notes = {},
    }
    ZGV335ProbeDB.sessions[#ZGV335ProbeDB.sessions + 1] = session
    ZGV335ProbeDB.latest = #ZGV335ProbeDB.sessions
end

function Probe:Snapshot(reason)
    if not session then NewSession(reason or "manual") end
    CaptureBuild()
    CaptureAPIs()
    CaptureWidgets()
    CaptureTextures()
    CaptureReleaseState()
    local epoch, uptime = Now()
    session.snapshot_epoch = epoch
    session.snapshot_uptime = uptime
    session.snapshot_reason = reason or "manual"
    return session
end

function Probe:CaptureScenario(name)
    name = SafeString(name or "unspecified")
    self:Snapshot("scenario:" .. name)
    session.captures = session.captures or {}
    local epoch, uptime = Now()
    session.captures[#session.captures + 1] = { name = name, epoch = epoch, uptime = uptime, release_state = session.release_state }
    while #session.captures > 40 do table.remove(session.captures, 1) end
    return session.release_state
end

local function CountCapabilities()
    local present, absent = 0, 0
    if session and session.api then
        for _, valueType in pairs(session.api) do
            if valueType == "nil" then absent = absent + 1 else present = present + 1 end
        end
    end
    return present, absent
end

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00ZGV335Probe:|r " .. message)
end

local function ShowSummary()
    if not session then
        Print("No session has been initialized.")
        return
    end
    local present, absent = CountCapabilities()
    local eventKinds, eventCount = 0, 0
    for _, record in pairs(session.events) do
        eventKinds = eventKinds + 1
        eventCount = eventCount + (record.count or 0)
    end
    local build = session.build or {}
    Print(string.format("client=%s build=%s interface=%s APIs=%d present/%d absent events=%d across %d kinds",
        tostring(build.version), tostring(build.build), tostring(build.interface), present, absent, eventCount, eventKinds))
    Print("SavedVariables: WTF/Account/<account>/SavedVariables/ZGV335Probe.lua")
end

local function SlashCommand(input)
    local command = string.lower(string.match(input or "", "^%s*(%S+)") or "show")
    if command == "snapshot" then
        Probe:Snapshot("slash-command")
        Print("Capability snapshot refreshed.")
        ShowSummary()
    elseif command == "clear" then
        ZGV335ProbeDB = { schema = SCHEMA, sessions = {} }
        NewSession("cleared")
        Probe:Snapshot("clear")
        Print("Stored probe sessions cleared; a new snapshot was recorded.")
    elseif command == "events" then
        local mode = string.lower(string.match(input or "", "^%s*%S+%s+(%S+)") or "")
        if mode == "off" then
            eventsEnabled = false
            UnregisterSafeEvents()
            Print("Safe event recording disabled for this login.")
        elseif mode == "on" then
            eventsEnabled = true
            RegisterSafeEvents()
            Print("Safe event recording enabled.")
        else
            Print("Usage: /zgvprobe events on|off")
        end
    elseif command == "note" then
        local note = string.match(input or "", "^%s*%S+%s+(.+)$")
        if note then AddNote(note); Print("Note recorded.") else Print("Usage: /zgvprobe note <text>") end
    elseif command == "capture" then
        local name = string.match(input or "", "^%s*%S+%s+(.+)$")
        if name then Probe:CaptureScenario(name); Print("Release scenario capture recorded: " .. SafeString(name))
        else Print("Usage: /zgvprobe capture <scenario-name>") end
    elseif command == "help" then
        Print("Commands: show, snapshot, capture <scenario>, clear, events on|off, note <text>, help")
    else
        ShowSummary()
    end
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon ~= ADDON_NAME then return end
        NewSession("addon-loaded")
        CaptureBuild()
        RegisterSafeEvents()
        Probe:Snapshot("addon-loaded")
        RecordEvent(event, ...)
        SLASH_ZGV335PROBE1 = "/zgvprobe"
        SlashCmdList.ZGV335PROBE = SlashCommand
        return
    end
    if eventsEnabled then RecordEvent(event, ...) end
end)
