------------------------------------------------------------------
-- Modules
------------------------------------------------------------------

---@class Config
local Config = ECSLoader:CreateModule("Config")
local _Config = Config.private

---@type GearInfos
local GearInfos = ECSLoader:ImportModule("GearInfos")
---@type Stats
local Stats = ECSLoader:ImportModule("Stats")
---@type i18n
local i18n = ECSLoader:ImportModule("i18n")

------------------------------------------------------------------
-- Configuration Frame
------------------------------------------------------------------

local AceGUI = LibStub("AceGUI-3.0")

-- Forward declaration
local _CreateGUI, _GeneralTab, _StatsTab

function Config:CreateWindow()
    local optionsGUI = _CreateGUI()
    LibStub("AceConfigECS-3.0"):RegisterOptionsTable("ECS", optionsGUI)
    ECS.configFrame = LibStub("AceConfigDialogECS-3.0"):AddToBlizOptions("ECS", "Extended Character Stats");

    local configFrame = AceGUI:Create("Frame");
    LibStub("AceConfigDialogECS-3.0"):SetDefaultSize("ECS", 440, 590)
    LibStub("AceConfigDialogECS-3.0"):Open("ECS", configFrame)
    configFrame:Hide();

    ECSConfigFrame = configFrame.frame;
    table.insert(UISpecialFrames, "ECSConfigFrame");
end

_CreateGUI = function()
    return {
        name = "Extended Character Stats",
        handler = ECS,
        type = "group",
        childGroups = "tab",
        args = {
            general_tab = _GeneralTab(),
            stats_tab = _StatsTab(),
        }
    }
end

_GeneralTab = function()
    return {
        name = function() return i18n("GENERAL") end,
        type = "group",
        order = 1,
        args = {
            generalHeader = {
                type = "header",
                order = 1,
                name = function() return i18n("GENERAL_SETTINGS") end,
            },
            showQualityColors = {
                type = "toggle",
                order = 1.1,
                name = function() return i18n("SHOW_ITEM_QUALITY_COLORS") end,
                desc = function() return i18n("SHOW_ITEM_QUALITY_COLORS_DESC") end,
                width = "full",
                get = function () return ExtendedCharacterStats.general.showQualityColors; end,
                set = function (info, value)
                    GearInfos:ToggleColorFrames(value)
                    ExtendedCharacterStats.general.showQualityColors = value
                end,
            },
            headerFontSize = {
                type = "range",
                order = 1.2,
                name = function() return i18n("HEADER_FONT_SIZE") end,
                desc = function() return i18n("HEADER_FONT_SIZE_DESC") end,
                width = "double",
                min = 8,
                max = 18,
                step = 1,
                get = function() return ExtendedCharacterStats.general.headerFontSize; end,
                set = function (_, value)
                    ExtendedCharacterStats.general.headerFontSize = value
                    Stats:RebuildStatInfos()
                end,
            },
            statFontSize = {
                type = "range",
                order = 1.3,
                name = function() return i18n("STAT_FONT_SIZE") end,
                desc = function() return i18n("STAT_FONT_SIZE_DESC") end,
                width = "double",
                min = 8,
                max = 18,
                step = 1,
                get = function() return ExtendedCharacterStats.general.statFontSize; end,
                set = function (_, value)
                    ExtendedCharacterStats.general.statFontSize = value
                    Stats:RebuildStatInfos()
                end,
            },
            windowWidth = {
                type = "range",
                order = 1.3,
                name = function() return i18n("WINDOW_WIDTH") end,
                desc = function() return i18n("WINDOW_WIDTH_DESC") end,
                width = "double",
                min = 12,
                max = 25,
                step = 0.5,
                get = function() return ExtendedCharacterStats.general.window.width / 10; end,
                set = function (_, value)
                    ExtendedCharacterStats.general.window.width = value * 10
                    Stats:UpdateWindowSize()
                end,
            },
            language = {
                type = "select",
                order = 3.1,
                values = {
                    ["auto"] = "Auto",
                    ["enUS"] = "English",
                    -- ["esES"] = "Español",
                    -- ["esMX"] = "Español (México)",
                    -- ["ptBR"] = "Português",
                    ["frFR"] = "Français",
                    ["deDE"] = "Deutsch",
                    -- ["ruRU"] = "русский",
                    -- ["zhCN"] = "简体中文",
                    -- ["zhTW"] = "正體中文",
                    -- ["koKR"] = "한국어",
                },
                style = "dropdown",
                name = function() return i18n("SELECT_LANGUAGE") end,
                get = function()
                    if (not ExtendedCharacterStats.general.langugage) then
                        return "auto"
                    else
                        return ExtendedCharacterStats.general.langugage;
                    end
                end,
                set = function(_, lang)
                    ExtendedCharacterStats.general.langugage = lang
                    if lang == "auto" then
                        i18n:LoadLanguageData()
                    else
                        i18n:SetLanguage(lang)
                    end
                    Stats:RebuildStatInfos()
                    Stats:UpdateSettingsButtonText()
                end,
            },
        }
    }
end

_StatsTab = function ()
    return {
        name = function() return i18n("STATS") end,
        type = "group",
        order = 2,
        args = {
            statsHeader = {
                type = "header",
                order = 1,
                name = function() return i18n("STATS_SETTINGS") end,
            },
            meleeGroup = _Config:LoadMeleeSection(),
            rangeGroup = _Config:LoadRangeSection(),
            defenseGroup = _Config:LoadDefenseSection(),
            mp5Group = _Config:LoadManaSection(),
            spellGroup = _Config:LoadSpellSection(),
            spellBonusGroup = _Config:SpellBonusSection(),
        }
    }
end

-- Open the configuration window
function Config:ToggleWindow()
    if (not ECSConfigFrame:IsShown()) then
        ECSConfigFrame:Show()
    else
        ECSConfigFrame:Hide()
    end
end
