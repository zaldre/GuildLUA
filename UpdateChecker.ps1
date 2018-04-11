#Version check function
$ErrorActionPreference = "stop"
$ConfigFile = "config_Lua.xml"
[xml]$Config = Get-Content $ConfigFile
$UpdateServers = "192.168.1.251:22499", "pwsh.fleisk.com:22499"
$DBSub = $Config.settings.baseconfig.workingdir + '\' + $Config.settings.baseconfig.databasefolder + '\'

$remoteVersionFile = "GuildLUA/db/versionnumber.txt"
$localVersionFile = ($dbsub + "versionnumber.txt")
$localversion = Get-Content $localVersionFile
function CheckForUpdates {
    $datestamp = get-date -Format "yyyy-MM-dd H:mm:ss"
    [xml]$Config = Get-Content $ConfigFile
    $lastcheck = get-date -format "yyyy-MM-dd H:mm:ss" $config.settings.updates.lastcheck
    $timeBetween = New-TimeSpan $lastcheck $datestamp
    if ($timebetween.days -lt 7) {
        $daysbetween = [string]$timebetween.days
        "You have not checked for updates in $daysbetween days, Checking now."
    

    $count = 0
    while (!$latestVersion) {
        $checkLatestUpdateFile = ('http://' + $UpdateServers[$count] + '/' + $remoteVersionFIle)
        $serverVersion = Invoke-WebRequest -uri $checkLatestUpdateFile  -method get
        if (!$localversion) { throw "Error: No version file could be located in the database folder. Please ensure an entry exists and has a decimal placed version number. If you are unsure, Visit https://github.com/zapoklu/GuildLUA and download the latest version." }
       
        if ($localVersion -lt $serverVersion) {
            "DO A BUNCH OF UPDATE STUFF HERE"
            $serverversion.content | Out-file $localversionFIle
            $latestversion = $true

        }
        if ($localversion -eq $serverVersion) {
            "You are already running the latest version."
            $latestversion = $true
        }
       
        $count++
        if ($count -eq $updateservers.count) { 
            throw "Failed to contact any update servers successfully. Please check your network connection and try again in a few minutes"
            $latestVersion = "FailedCheck"
        }


    
    }

}
}
checkforupdates