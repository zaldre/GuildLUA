PARAM(
    [switch]$db,
    [string]$character,
    [string]$raid,
    [string]$lastloot,
    [string]$itemsearch,
    [string]$filename,
    [int]$quantity,
    [string]$attendance
)
$ErrorActionPreference = "stop"

$ConfigFile = "H:\GuildLUA\coddddnfig_Lua.xml"
if (($filename) -and (!$db)) { throw "Error: Filename parameter is used to specify an individual LUA file to populate the database. Only use this flag in conjunction with -db"}



#Making sure an appropriate version of powershell is installed
if ($PSVersionTable.psversion.major -le "4") { 
    'ERROR: Your version of Powershell is out of date and is incompatible with this script.'
    'Please visit https://www.microsoft.com/en-us/download/details.aspx?id=54616 and install Windows Management Framework Version 5 or higher in order to proceed'
    exit 
}

#Ensuring we have NuGet installed so we can update the script
if (((Get-PackageProvider) | Where-Object {$_.name -eq "NuGet"}) -eq $null)  {
    "Warning: NuGet is not currently installed. This is required to keep the script up to date, Attempting installation now. Please accept all prompts."
   try { 
       Install-PackageProvider -Name NuGet
    } 
catch { throw $error[0] }
}

#Configuration file logic.
#First, A static entry can be configured in the "ConfigFile" variable
#If this cannot be located, We look in the current working directory for the file.
#If this can't be found, the script then looks in the script directory
#Failing that, the script will stop.

$currentDir = Get-Location | Select-Object -ExpandProperty path
$scriptLoc = $PSScriptRoot
function Scan-Config {
    param([string]$conf)
    $tempConf = $conf + '\' + 'config_lua.xml'
    if (test-path $tempConf) { 
        write-host "Using configuration file $tempConf"
        [xml]$global:Config = Get-Content $tempCOnf

        #updating the settings if required.
        if ($Config.settings.baseconfig.workingdir -ne $conf) {
            write-host 'Updating the settings to use the current directory as the new working directory'
            $config.settings.baseconfig.workingdir = $conf.ToString()
            $config.save($tempconf)
        }
        return $tempConf
    }
}

#Initial check of config file location
if (!(test-path $configfile)) {
    try {
        $work = Scan-Config -conf $currentDir
        if ($work) { $configfile = $work }
        if ((test-path $configfile) -eq $false) {
            $work = Scan-Config -conf $scriptLoc
            if ($work) { $configfile = $work }
        }
    }
    catch { $error[0] } 
}

#Reloading config file in case there were changes above
[xml]$global:Config = Get-Content $ConfigFile

#Now that the config file is loaded, Let's load the functions module
try {
    #Unloading the existing copy of the module if its loaded - Used in DEV work.
    if (get-module | Where-Object {$_.name -eq "CTRT_Functions"}) { Remove-Module CTRT_Functions }
    Import-Module ($Config.settings.baseconfig.workingdir + '\' + "CTRT_Functions.psm1")
}
catch { 
    throw "ERROR: Unable to load the module 'CTRT_functions.psm1', please ensure this file exists in the working directory"
}


#Ensuring we have a compatible version of NuGet on this system. Should be in the 'supplemental' folder.
if (!(Test-Path ($config.settings.baseconfig.workingdir + '\supplemental\nuget.exe'))) {
    try {
    Invoke-WebRequest -Method Get -uri 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile ($config.settings.baseconfig.workingdir + '\supplemental\nuget.exe')
}
catch { throw "Unable to download version of NuGet required for this script. Please go to https://www.nuget.org/downloads and place the .exe file in the supplemental folder where the script is installed."}
}

#Update check
$updateFile = $Config.settings.baseconfig.workingdir + '\db\update.csv'
if (!(test-path $updatefile)) {
    Update-GuildLUA 
}
else {
$daysBetween = New-Timespan -end (Get-Date) -start (get-date (Import-Csv $updateFile | Select-Object -ExpandProperty Date))
if ($daysBetween.days -ge 7) { Update-GuildLUA }
}

#FLAGS SECTION START

if ($db) {
    #Calling GenDB Function
    if ($filename) { GenDB -filename $filename }
    else { GenDB }
} 


if ($raid) {
    raidfunction -raid $raid
}

if ($Character) {
    charactersearch -charname "$character"
}


if ($itemsearch) {
    if (!$lootarray) { genlootarray }
    foreach ($entry in $lootarray) {
        if ($entry.item -like $itemsearch) { $entry }
    }
}

if ($lastloot) {
    if (!$lootarray) { genlootarray ; $Lootarray = $lootarray | sort-object -Property date }
    if ($lastloot -like "*,*") { $looter = $lastloot.Split(",")}
    else { $Looter = $lastloot }
    foreach ($entry in $looter) { 
        if (!$quantity) { $quantity = 5 }
        $capture = $lootarray | Where-Object {$_.name -eq $entry -and ($_.priority -ge $config.settings.reporting.qualityfilter)} | Select-Object Item -Last $quantity
        $string = $null
        foreach ($listing in $capture) {
            if ($string -eq $null) { $string = $listing.item.ToSTring() }
            else { $string = $string + ', ' + $listing.item.ToSTring() }
        }
        if (!$string) { $string = "No results" }
        $string = $entry + ': ' + $string
        $string 
    }
}

if ($attendance) {
    AttendanceReport -name $attendance
}

#END FLAGS SECTION