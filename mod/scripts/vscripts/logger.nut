untyped
global function logger_Init

#if HAS_TOOLS
LogoData LD = {
    logo =
    [
        ".__",
        "|  |   ____   ____   ____   ___________",
        "|  |  /  _ \\ / ___\\ / ___\\_/ __ \\_  __ \\",
        "|  |_(  <_> ) /_/  > /_/  >  ___/|  | \\/",
        "|____/\\____/\\___  /\\___  / \\___  >__|",
        "           /_____//_____/      \\/"
    ]
    color_start = < 255, 0, 110 >
    color_end   = < 131, 56, 236 >
}
#endif

struct{
    string path_fullFile = "fullFile.txt"
    string path_mapFile = ""

    array<int> timezoneOffsets = [
        -12, -11, -10, -9, -8, -7, -6,
        -5, -4, -3, -2, -1, 0, 1,
        2, 3, 4, 5, 6, 7, 8,
        9, 10, 11, 12, 13, 14
    ]

    int timeZone = 14

    bool appendedFilenameToFullfile = false
    bool useMatchTime               = false
    bool doMessageTimestampPrefix   = true
    bool appendGamemodeToFilename   = false
}file

void function logger_Init(){
    #if !HAS_TOOLS
        throw( "[LOGGER] No tools found! Install @ https://github.com/drachenfruchl/tools" )
        return
    #endif

    if( !GetConVarBool( "cv_logger_hasClearedFullFile" ) && GetConVarBool( "cv_logger_clearFullFileOnLaunch" ) ){
        NSSaveFile( file.path_fullFile, "" )
        SetConVarBool( "cv_logger_hasClearedFullFile", true )
    }

    file.timeZone                   = file.timezoneOffsets[ GetConVarInt( "cv_logger_timezone" ) ]
    file.useMatchTime               = GetConVarBool( "cv_logger_useMatchTime" )
    file.doMessageTimestampPrefix   = GetConVarBool( "cv_logger_doMessageTimestampPrefix" )
    file.appendGamemodeToFilename   = GetConVarBool( "cv_logger_appendGamemodeToFilename" )

    dtool_printLogo( LD )

    thread main()
}

void function main(){
    while( !IsPrivateMatch() && GetGameState() == -1 )
        wait 0.5

    file.path_mapFile = buildMapFilePath()
    AddCallback_OnReceivedSayTextMessage( chathook )
}

string function buildMapFilePath(){
    string  mapName         = GetMapName()

    if( GetConVarBool( "cv_logger_localizeMapName" ) )
        mapName = Localize( GetMapDisplayName( mapName ) )

    table   dateParts       = dtool_getCurrentDate()
    table   timeParts       = dtool_getCurrentTime( file.timeZone )

    string  gamemode        = GameRules_GetGameMode()

    string filepath = format(
        "[%s][%s]%s %s.txt",
        format(
            "%i.%i.%i",
            dateParts.day,
            dateParts.month,
            dateParts.year
        ),
        format(
            "%02ih%02i",
            timeParts.hour,
            timeParts.minute
        ),
        ( !IsLobby() && file.appendGamemodeToFilename ? format( "[%s]", gamemode ) : "" ),
        mapName
    )

    return filepath
}

void function appendMessage( string filepath, string message ){
    void functionref( string ) onSuccess = void function( string content ) : ( filepath, message ){
        NSSaveFile( filepath, content + message + "\n" )
    }
    NSLoadFile( filepath, onSuccess )
}

ClClient_MessageStruct function chathook( ClClient_MessageStruct message ){
    bool    useMatchTime    = GetConVarBool( "cv_logger_useMatchTime" )
    table   timeParts       = dtool_getCurrentTime( file.timeZone )

    message.message     = dtool_sanitizeMessage( message.message )
    message.playerName  = dtool_stripWhitespaces( message.playerName )

    string msg = format(
        "%s%s%s: %s",
        ( file.doMessageTimestampPrefix ?
            ( file.useMatchTime ?
                format(
                    "[%.0fs]\t",
                    Time()
                ) :
                format(
                    "[%02i:%02i:%02i]",
                    timeParts.hour,
                    timeParts.minute,
                    timeParts.second
                )
            ) + " " : ""
        ),
        ( message.isTeam ? "(TEAM) " : "" ),
        message.playerName,
        message.message
    )

    if( !file.appendedFilenameToFullfile ){
        if( GetConVarBool( "cv_logger_logToFullFile" ) )
            msg = "\n> " + file.path_mapFile + "\n" + msg

        file.appendedFilenameToFullfile = true
    }

    if( GetConVarBool( "cv_logger_logToFullFile" ) )
        appendMessage( file.path_fullFile, msg )

    if( GetConVarBool( "cv_logger_logToIndividualMapFiles" ) )
        appendMessage( file.path_mapFile, msg )

    return message
}