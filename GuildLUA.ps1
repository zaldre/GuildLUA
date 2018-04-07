#TEST

PARAM(
    [switch]$db,
    [string]$character,
    [string]$raid,
    [string]$lastloot,
    [string]$itemsearch,
    [string]$filename,
    [int]$quantity
)

<#
KNOWN BUGS/NEEDS IMPLEMENTATION
GUILDLUA.PS1

Rewrite raidfunction, Doesn't work with new DB type.
Build attendance tracker. Calculate raid days based on times, Allow for blacklist/ignorelist. Allow linkage between 1 Main > Many alt
Check if SHIVTR API supports events signups based on main name
Implement raid hours (Same as raid days but for hours)
Include as part of this detection for periods that span over night (i.e. in my case where the raids sometimes go past midnight) Try and build this into the same report if possible.
Add help data
Regex date match for -raid parameter


CONFIGGUI.PS1

Configuration GUI    : Change LUA file to WoW folder selection box
                     : Tickbox (Only report raid days and times)
                     : TIME CONFIG : Enable tickbox for convert to server time
                     : ID LOOKUP PREFIX
                     : Help section - Explanation of Working Directory
                     : Even out spacing between the options - Misaligned
                     : add trigger for report raid times only - needs to grey out all unneeded boxes



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
#Load the config file
$ConfigFile = "D:\dropbox\guildlua\config_Lua.xml"
[xml]$Config = Get-Content $ConfigFile
$freshrun = "yes"

#Pre-Requisite checks for existing data. Creates directories if they do not exist

$DBSub = $Config.settings.baseconfig.workingdir + '\' + $Config.settings.baseconfig.databasefolder + '\'
$RPSub = $Config.settings.baseconfig.workingdir + '\' + $Config.settings.reporting.reportfolder + '\'




#Function declaration

function checkLastLoot($lootName) {
    return $lootarray | ? {($_.name -eq $lootname) -and ($_.priority -ge $config.settings.reporting.qualityfilter)} | sort-object date | Select-Object -Last $quantity
}
   
function RaidFunction($Raidentry) {

   
    #Begin processing of ALL raid reports
    if ($Raidentry -eq '*') {
        $joinImport = import-csv ($dbsub + 'join.csv') | sort-object -Property $datestamp -Descending
        $leaveImport = import-csv ($dbsub + 'leave.csv') | sort-object -Property $datestamp -Descending
        $lootImport = import-csv ($dbsub + 'loot.csv') | sort-object -Property $datestamp -Descending

        #3 Arrays for holding stuff
        $joinArray = New-Object System.Collections.ArrayList($null)
        $leaveArray = New-Object System.Collections.ArrayList($null)
        $lootArray = New-Object System.Collections.ArrayList($null)

        #Now we have everything sorted by date, lets pump everything into arraylists and initiate the swap when the date changes
        foreach ($join in $joinimport) { 
            if (($join.datestamp -ne $datestamp) -and ($datestamp)) {
                $raidreportfilename = $raidreportfolder + 'RaidReport_' + $datestamp + '.csv'
                $joinArray | export-csv $raidreportfilename -NoTypeInformation
                $joinArray = New-Object System.Collections.ArrayList($null)
            }
            [void]$joinarray.Add($join)
            $datestamp = $join.datestamp 
        }
    }
    #Begin processing of individual raid reports
    else {
        $raidreportfilename = $raidreportfolder + 'RaidReport_' + $raidentry + '.csv'
        $raidstore = New-Object System.Collections.ArrayList($null)
        $joinImport = import-csv ($dbsub + 'join.csv') | ? {$_.date -like $raidentry}
        $leaveImport = import-csv ($dbsub + 'leave.csv') | ? {$_.date -like $raidentry}
        $lootImport = import-csv ($dbsub + 'loot.csv') | ? {$_.date -like $raidentry}
        $namearray = New-Object System.Collections.ArrayList($null)
        $namearray = $namearray | select -Unique
        try {
            $joinimport | % { [void]$namearray.Add($_.name) }
            $leaveimport| % { [void]$namearray.Add($_.name) }
            $lootimport| % { [void]$namearray.Add($_.name) }
        } 
        catch { }
        foreach ($name in $namearray) { 
            $lootlist = $null
            $joinimport | ? {$_.name -eq "$name"} | sort-object -Property join | select-Object join -first 1
            $leavetime = $leaveimport | ? {$_.name -eq "$name"} | sort-object -property leave | select-Object leave -last 1
            $lootCollection = $lootimport | ? {$_.name -eq "$name"} | ? {$_.priority -ge $Config.settings.reporting.qualityfilter}
            foreach ($loot in $lootcollection) {
                if ($lootlist -eq $null) { $lootlist = $loot.item } else { $lootlist = $lootlist + ";" + $loot.item }
                if ($URLlist -eq $null) { $URLlist = $loot.URL } else { $URLlist = $URLlist + ";" + $loot.URL }
            }
            if (!$leavetime.leave) { $perPersonLeave = "NO DATA" } else { $perPersonLeave = $leavetime.leave }
            if (!$jointime.join) { $perPersonjoin = "NO DATA" }  Else { $perPersonJoin = $jointime.join }
            $obj = [pscustomobject][ordered]@{
                Name  = $name
                Join  = $perPersonJoin
                Leave = $perPersonLeave
                Loot  = $lootlist
                URL   = $URLList
            }
            $lootlist = $null
            $urllist = $null
            [void]$raidstore.Add($obj)

        }
        if (!$raidstore) { Throw "Error: No data found for that raid, Correct Syntax: YYYY-MM-DD"} 
        else { $raidstore | export-csv $raidreportfilename }
    }
}


#Generate an array full of the loot listings for quicker searching
function genLootArray {
    $global:lootarray = import-csv ($dbsub + "loot.csv")
}

#Function to search for characters in that array
function characterSearch($charname) {
    if (!(test-path $CharacterReportFolder)) { mkdir $CharacterReportFolder }
    if (!$lootarray) {
        genLootArray
    }
    $comma = ','
    #Multiple character search using comma separation
    if ($charname -match $comma) { 
        $characterList = $character.split(',')
        foreach ($C in $characterList) {
            characterSearch -charname $C
        }
    
    }

    #All character search
    if ($charname -eq '*') {
        "Generating character reports for all users in the database. This may take some time."
        $chararray = New-Object System.Collections.ArrayList($null)
        $lootarray = $LootArray | sort-object -Property Name
        foreach ($entry in $lootarray) {
            if (($entry.name -ne $lastname) -and ($lastname -ne $null)) {
                $CharacterReport = $CharacterReportFolder + $lastname + "_loot.csv"
                $charArray | Select * -ExcludeProperty Mode | export-csv $CharacterReport -NoTypeInformation
                $chararray = New-Object System.Collections.ArrayList($null)
            }
            if ($entry.priority -ge $config.settings.reporting.qualityfilter) { [void]$charArray.Add($entry) }
            $lastname = $entry.name
        }
    }


    #Single character search
    if (($charname -notlike "*,*") -and ($charname -ne '*')) {
        $CharacterReport = $CharacterReportFolder + $charname + "_loot.csv"
        $dateNow = get-date 
        $filteredLootArray = $LootArray | ? {$_.name -eq $Charname}
        $characterStore = foreach ($loot in $filteredLootArray) {
            if ($loot.priority -ge $Config.settings.reporting.qualityfilter) { $loot }
        }
        $characterstore | export-csv $characterreport -notypeinformation
    }
}



#Function for logging
function Write-Log {
    $currenttime = get-date -Format "[yyyy-MM-dd] H:mm:ss"
    $string = $currenttime + " " + $args
    $string | out-file $Config.settings.baseconfig.logfile -append
    write-host $string
}

#END FUNCTION DECLARATION


#Pre-Requisite checks for existing data. Creates directories if they do not exist

$DBSub = $Config.settings.baseconfig.workingdir + '\' + $Config.settings.baseconfig.databasefolder + '\'
$RPSub = $Config.settings.baseconfig.workingdir + '\' + $Config.settings.reporting.reportfolder + '\'
$CharacterReportFolder = $RPSub + 'Character\'
$RaidReportFolder = $RPSub + 'Raids\'
if ((test-path $Config.settings.baseconfig.workingdir) -eq $false) { mkdir $Config.settings.baseconfig.workingdir }
if ((test-path $DBSub) -eq $false) { mkdir $DBSub }
if ((test-path $RPSub) -eq $false) { mkdir $RPSub }

#Master sheet files
$MasterSheetDir = $Config.settings.baseconfig.workingdir + '\' + $config.settings.reporting.reportfolder + '\' + "MasterSheet\"
$LootMasterSheet = $mastersheetDir + "LootMasterSheet.CSV"
$RaidMasterSheet = $mastersheetDir + "RaidMasterSheet.csv"
if (!(test-path $MasterSheetDir)) { mkdir $mastersheetdir }
$IDLookupPrefix = 'https://classicdb.ch/?item=' #Used in loot output, PREFIX + ITEMID = URL

#END CONFIGURABLE SECTION

#Loading function module

#Import-module ($Config.settings.baseconfig.workingdir + '\' + "Function.psm1")



#Making sure an appropriate version of powershell is installed
if ($PSVersionTable.psversion.major -le "4") { 
    'ERROR: Your version of Powershell is out of date and is incompatible with this script.'
    'Please visit https://www.microsoft.com/en-us/download/details.aspx?id=54616 and install Windows Management Framework Version 5 or higher in order to proceed'
    exit 
}

$US = New-Object system.globalization.cultureinfo("en-US") #Times are saved in US format in the LUA file. This variable helps us convert that





#START DATABASE GENERATION OF LUA TO CSV

if ($DB) {
    #Finding which files are to be used. If no -filename parameter, Search the WoW directory.
    if (!$Filename) { 
        "No filename specified. Searching WoW directory for suitable files"
        $WTFAccount = "\WTF\ACCOUNT\"
        try { $DBFilesList = ls ($config.settings.baseconfig.wowfolder + $WTFAccount + '\*\SavedVariables\CT_Raidtracker.lua') }
        catch { throw "Error: No files found. Check the wow folder location in the config and try again" ; exit }
        $count = $dbfileslist.count ; "Found $count files"
    }
    else {
        #Sanity check for existence of filename
        $fullpathfilename = (pwd).path + '\' + $filename
        if ((test-path $filename) -eq $false) { $Check1 = $false } else { $DBFilesList = ls $filename }
        if ((test-path $fullpathfilename) -eq $false) { $check2 = $false } else { $DBFilesList = ls $fullpathfilename }
        if (($check1 -eq $false) -and ($check2 -eq $false)) {  write-host "ERROR: NO FILE FOUND BY THE NAME OF $filename" ; exit } 
        #
    }
    #Freshrun - Make sure we operate with a clean database.
    if ($freshrun -eq "yes") { "Freshrun mode selected, Deleting old database files" ; rm $DBSub\*.csv } #This deletes information about ALL previous runs. Set $Freshrun to = no if you don't want this to happen.
    $mode = $null
    [int]$int = 0




    #Declaring object types
    $player = '				["player"]'
    $time = '				["time"]'
    $item = '				["item"]'
    $name = '					["name"]'
    $colorhex = '					["c"]'
    $count = '					["count"]'
    $ID = '					["id"]'
    $final = '			},'

    #Declaring objs for holding the data
    $store = @{}



    #Generating database begins
    "Beginning generation of database. This may take a few minutes..."

    #Beginning loop through files
    $store = foreach ($DBFile in $DBFilesList) {
        $import = cat $Dbfile
        foreach ($entry in $import) { 
            $obj = @()
            $int++ #Counter

            #Determining which block we are processing. Leave, Loot or Join
            if ($entry -eq '		["Leave"] = {') { $mode = "leave"}
            if ($entry -eq '		["Join"] = {') { $mode = "join" }
            if ($entry -eq '		["Loot"] = {') { $mode = "loot" }



            #Parsing individual results
            $Raw = $entry.Split('=')
            $CurrentItem = $Raw[0]
            $Value = $raw[1]
            $value = $value -replace '"', ""
            $value = $value -replace ',', ""


            #Player object begin
            if ($CurrentItem -match [Regex]::Escape($Player)) { 
                $itemmode = "Player"
                $currentPlayer = $raw[1]
                $currentplayer = $currentplayer.Replace('"', '') #Trimming quotation marks
                $currentplayer = $currentplayer.Replace(',', '') #Trimming commas
                $currentplayer = $currentplayer.Trim()           #Trimming whitespace
            }
            #URL processing
            if ($CurrentItem -match [Regex]::Escape($ID)) { 
            
                $URL = $IDLookupPrefix + "$value"
                $url = $url.Replace(" ", "") 
                $Url = $url.Split(':')
                $url = $url[0] + ':' + $url[1]
                #$url
            }
        
            #Quantity processing
            if ($CurrentItem -match [Regex]::Escape($count)) {  $quantity = $value } #$CurrentItem }
        
            #Name of items
            if ($CurrentItem -match [Regex]::Escape($name)) { $itemName = $value } #$CurrentItem }
        
            #Color processing
            if ($CurrentItem -match [Regex]::Escape($colorhex)) {
                $colorvalue = $value.Trim()
                if ($colorvalue -eq "ff9d9d9d") { $coloringame = "Grey" ; $colorpriority = "0"}
                if ($colorvalue -eq "ffffffff") { $coloringame = "White" ; $colorpriority = "1"}
                if ($colorvalue -eq "ff1eff00") { $coloringame = "Green" ; $colorpriority = "2"}
                if ($colorvalue -eq "ff0070dd") { $coloringame = "Blue" ; $colorpriority = "3"}
                if ($colorvalue -eq "ffa335ee") { $coloringame = "Epic" ; $colorpriority = "4" }
                if ($colorvalue -eq "ffff8000") { $coloringame = "Legendary" ; $colorpriority = "5" }
            }


            #Time processing
            if ($CurrentItem -match [Regex]::Escape($time)) {
                if (!$mode) { write-log "Error. Mode unknown on line" $int ; break }

                #Gathering date and time information
                $RawDate = $value -split "\s+"
                #Converting the raw data into a Powershell DATETIME object.
                [datetime]$date = $Rawdate[1] + " " + $rawdate[2]
                #The dates are stored in US format, So let's make sure thats taken into consideration before we start changing things.
                $USFormat = get-date $Date -format ($US.DateTimeFormat.FullDateTimePattern) 
                if ($config.settings.reporting.convServerTime -eq $true) {
                    $ConvertedDate = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($USFormat, [System.TimeZoneInfo]::Local.Id, $Config.settings.baseconfig.timezoneid)
                    $datestamp = get-date $ConvertedDate -format "yyyy.MM.dd"
                    $Timestamp = get-date $ConvertedDate -Format "HH:mm:ss"
                }
                
                else {
                    $datestamp = get-date $USFormat -format "yyyy.MM.dd"
                    $Timestamp = get-date $USformat -Format "HH:mm:ss"
                }
                
            }
            #Conversion finished, Lets now store the date and time in individual variables for ease of access.
            
            #Final block - Write the objects out
            if ($CurrentItem -match [Regex]::Escape($final) -and ($currentitem.length -eq $final.length)) {
                if ($mode -eq "leave") { 
                    $obj = [pscustomobject][ordered]@{
                        Name  = $currentplayer
                        Leave = $timestamp
                        Date  = $datestamp
                        Mode  = $mode
                    }
                    #Passing object to the pipeline to store in $store
                    $obj
                    #Blanking to ensure that data is fresh each loop
                    $obj = $null
                    $currentplayer = $null
                    $timestamp = $null
                }
        
                if ($mode -eq "join") {
                    $obj = [pscustomobject][ordered]@{
                        Name = $currentplayer
                        Join = $timestamp
                        Date = $datestamp
                        Mode = $mode
                    }
                    #Passing object to the pipeline to store in $store
                    $obj
                    #Blanking to ensure that data is fresh each loop
                    $obj = $null
                    $currentplayer = $null
                    $timestamp = $null
                }
        
                if ($mode -eq "loot") {
                    $obj = [pscustomobject][ordered]@{
                        Name     = $currentplayer
                        Item     = $itemName.SubString(1)
                        Color    = $colorvalue
                        Quantity = $quantity
                        Quality  = $coloringame
                        Priority = $colorpriority
                        URL      = $URL
                        Date     = $datestamp 
                        Mode     = $mode
                    }
                    #Passing object to the pipeline to store in $store
                    $obj
                    #Blanking to ensure that data is fresh each loop
                    $obj = $null
                    $currentplayer = $null
                    $itemName = $null
                    $colorvalue = $null
                    $quantity = $null
                    $coloringame = $null
                    $colorpriority = $null
                }
            }
        }
   
    }
    $joinexportfile = $DBSub + 'join.csv'
    $leaveexportfile = $DBSub + 'leave.csv'
    $lootexportfile = $DBSub + 'loot.csv'
    $joinArr = New-Object System.Collections.ArrayList($null)
    $leaveArr = New-Object System.Collections.ArrayList($null)
    $lootArr = New-Object System.Collections.ArrayList($null)
    foreach ($entry in $store) { 
        switch ($entry.mode) {
            join {[void]$joinArr.Add($entry) }
            leave {[void]$leaveArr.Add($entry)}
            loot {[void]$lootArr.Add($entry)}
        }
    }
    $lootarr | export-csv $lootexportfile -NoTypeInformation
    $joinarr | export-csv $joinexportfile -NoTypeInformation
    $leavearr | export-csv $leaveexportfile -NoTypeInformation
    #Making sure we refresh the loot array after a database refresh
    if ($lootarray) { genlootarray }
    write-host "Database generation complete."
}

#END GENERATION OF DB FUNCTION


#Character search

#Looking for -Character flag.
if ($Character) {
    charactersearch -charname "$character"
}


#Looking for -Raid flag

if ($raid) {
    raidfunction -Raidentry $raid
}
#END RAID REPORT


#LAST LOOT

if ($lastloot) { 
    if (!$lootarray) { genlootarray }
    if (!$quantity) { [int]$quantity = "1" }
    if (($lastloot -ne "Healers") -and ($lastloot -ne "Tanks") -and ($lastloot -ne "DPS")) { $LLNames = $lastloot -Split ',' }
    if ($lastloot -eq "healers") { $LLNames = cat D:\dropbox\guild\HealerList.txt }
        
    foreach ($entry in $llnames) {     
        checklastloot $entry            
    }
}

#ITEM SEARCH

if ($itemsearch) {
    if (!$lootarray) { genLootArray }
    foreach ($entry in $lootarray) {
        if ($entry.item -like $itemsearch) { $entry }
    }
}



