global function loggerSettings_Init

const array<string> boolSettings = [ "No", "Yes" ]
const array<string> timezones = [
    "GMT-12", "GMT-11", "GMT-10", "GMT-9", "GMT-8", "GMT-7", "GMT-6",
    "GMT-5", "GMT-4", "GMT-3", "GMT-2", "GMT-1", "GMT", "GMT+1",
    "GMT+2", "GMT+3", "GMT+4", "GMT+5", "GMT+6", "GMT+7", "GMT+8",
    "GMT+9", "GMT+10", "GMT+11", "GMT+12", "GMT+13", "GMT+14"
]

void function loggerSettings_Init(){
    ModSettings_AddModTitle(    "^FFFFFF00Chatlogger" )

    #if HAS_TOOLS
    ModSettings_AddModCategory( " > Download dependency" )
        ModSettings_AddButton( "[ drachenfruchl.tools ]", void function():(){ LaunchExternalWebBrowser( "https://github.com/drachenfruchl/tools", WEBBROWSER_FLAG_FORCEEXTERNAL ) } )
    #endif

    ModSettings_AddModCategory( " > Settings" )
    AddConVarSettingEnum(       "cv_logger_logToIndividualMapFiles",   "Create log for individual maps",                   boolSettings )
    AddConVarSettingEnum(       "cv_logger_logToFullFile",             "Save messages to full file",                       boolSettings )
    AddConVarSettingEnum(       "cv_logger_clearFullFileOnLaunch",     "Clear full file on launch",                        boolSettings )
    AddConVarSettingEnum(       "cv_logger_timezone",                  "Timezone",                                         timezones )
    AddConVarSettingEnum(       "cv_logger_localizeMapName",           "Localize mapname",                                 boolSettings )
    AddConVarSettingEnum(       "cv_logger_useMatchTime",              "Display time into match instead of current time",  boolSettings )


    AddConVarSettingEnum(       "cv_logger_doMessageTimestampPrefix",  "Prefix logged messages with a timestamp",          boolSettings )
    AddConVarSettingEnum(       "cv_logger_appendGamemodeToFilename",  "Display gamemode in filename",                     boolSettings )
}