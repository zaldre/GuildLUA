PARAM(
    [switch]$db,
    [string]$character,
    [string]$raid,
    [string]$lastloot,
    [string]$itemsearch,
    [string]$filename,
    [int]$quantity
)
$ConfigFile = "H:\GuildLUA\coddddnfig_Lua.xml"
if (($filename) -and (!$db)) { throw "Error: Filename parameter is used to specify an individual LUA file to populate the database. Only use this flag in conjunction with -db"}


<#
KNOWN BUGS/NEEDS IMPLEMENTATION
GUILDLUA.PS1

Build attendance tracker. Calculate raid days based on times > Allow linkage between 1 Main > Many alt
Change blacklist to CSV for config, Have entries that have types i.e. Event,Loot,Player
Add date to raid report, add to master sheet in foreach loop using $store then only filter on date
Version number + update checker (NuGet)
Add help data
Filter based on Time as well as date (partially implemented)
Implement functionality for raids that span over night (Past midnight)


GUI STUFF
CONFIGGUI.PS1

Configuration GUI    : Change LUA file to WoW folder selection box
                     : Tickbox (Only report raid days and times)
                     : TIME CONFIG : Enable tickbox for convert to server time
                     : ID LOOKUP PREFIX
                     : Help section - Explanation of Working Directory
                     : Even out spacing between the options - Misaligned
                     : add trigger for report raid times only - needs to grey out all unneeded boxes
                     : Add autoregen db option to GUI          


MAINGUI.PS1
Reporting GUI        : Character search (Accompanying text indicating * option)
                     : Raid Search (Accompanying text indicating * option)
                     : Item Search (Accompanying text indicating * option)
                     : Last Loot (Accompanying text indicating * option)
                     : Generate DB (Single filename selection option)
                     : Help
                     : Introduction
#>
$ErrorActionPreference = "stop"

#Making sure an appropriate version of powershell is installed
if ($PSVersionTable.psversion.major -le "4") { 
    'ERROR: Your version of Powershell is out of date and is incompatible with this script.'
    'Please visit https://www.microsoft.com/en-us/download/details.aspx?id=54616 and install Windows Management Framework Version 5 or higher in order to proceed'
    exit 
}

#Configuration file logic.
#First, A static entry can be configured in the "ConfigFile" variable
#If this cannot be located, We look in the current working directory for the file.
#If this can't be found, the script then looks in the script directory
#Failing that, the script will stop.

$currentDir = Get-Location | select-object -ExpandProperty path
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
            $config.save($ConfigFile)
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

}

#END FLAGS SECTION