
#Pre-Requisite checks for existing data. Creates directories if they do not exist
$DBSub = $Config.settings.baseconfig.workingdir + '\' + $Config.settings.baseconfig.databasefolder + '\'
$RPSub = $Config.settings.baseconfig.workingdir + '\' + $Config.settings.reporting.reportfolder + '\'
$CharacterReportFolder = $RPSub + 'Character\'
$RaidReportFolder = $RPSub + 'Raids\'
if ((test-path $Config.settings.baseconfig.workingdir) -eq $false) { mkdir $Config.settings.baseconfig.workingdir }
if ((test-path $DBSub) -eq $false) { mkdir $DBSub }
if ((test-path $RPSub) -eq $false) { mkdir $RPSub }
$IDLookupPrefix = 'https://classicdb.ch/?item=' #Used in loot output, PREFIX + ITEMID = URL
$joinfile = $dbsub + 'join.csv'
$leavefile = $dbsub + 'leave.csv'
$lootfile = $dbsub + 'loot.csv'
$files = $joinfile, $leavefile, $lootfile

#DB STUFF

#Finding which files are to be used. If no -filename parameter, Search the WoW directory.


#END DB STUFF


#Date/Time in LUA file is always in US format, This variable makes sure we are always able to intepret these entries as datetime objects irrespective of region
$US = New-Object system.globalization.cultureinfo("en-US")

#Checking if we have a blacklist file, If so it is imported.
if (test-path ($Dbsub + 'blacklist.Txt')) { $blacklist = get-content ($DBsub + 'blacklist.txt') }




#Functions

#Generate an array full of the loot listings for quicker searching
function genLootArray {
    $script:lootarray = import-csv ($DBSub + '\' + 'loot.csv')
}
function Update-ConfigFile($property, $value) {
    $config.settings. + $property = $value
}
function RaidFunction {
    param([string]$raid)
    $raidDays = $Config.settings.reporting.Raiddays.Split(",") 
    $raidStart = $config.settings.reporting.monitoredtimestart
    $raidDuration = $config.settings.reporting.monitoredDuration

    Write-host "Generating raid specific reports. Please wait"
    
    $collection = New-Object System.Collections.ArrayList
    $rjoinCSVimport = import-csv $joinfile
    $rleaveCSVimport = import-csv $leavefile
    $rlootCSVimport = import-csv $lootfile   
    
    $RaidReportFolder = $RPSub + 'Raids\'
    if ((test-path $RaidReportFolder) -ne $true) { mkdir $RaidReportFolder }
    if ($raid -eq '*') {
        $filelist = $files | Foreach-Object { 
            $import = import-csv $_ 
            foreach ($item in $import) { 
                switch ($item.mode) {
                    leave { $time = $item.leave }
                    join { $time = $item.join }
                    loot { $time = $item.loot }
                }
                [datetime]$dateformatting = $item.date.Replace('.', '/')
                if (($Raiddays -like $dateformatting.dayofweek) -and ($Config.settings.reporting.raidtimeonly -eq $true) -and ($blacklist -notcontains $item.date)) { 
                    $item.date
                }
                elseif (($Config.settings.reporting.raidtimeonly -ne $true) -and ($blacklist -notcontains $item.date)) {  $item.date }
            }
        }
        $collection = $filelist | select-object -unique
    }
    else { $collection = $raid }
        
    #Ok, Now we've determined the results we're looking for. Lets start the processing.
    foreach ($raidentry in $collection) {
        #Output File Name
        $raidreportfilename = $raidreportfolder + 'RaidReport_' + $raidentry + '.csv'
        #Go through Join.csv, Find all entries, Parse through unique
        #Add Leave.CSV, Find all entries, Filter unique in addition to join (Just in case someone joined while you were DC'd)
        #Filter all results, Find last leave and last join for that user in a loop
        #Repeat for loot, Semicolon separate all loot items
        #Add URL for loot items
    
        $namearray = New-Object System.Collections.ArrayList($null)
        $sortJoins = $rjoinCSVimport | Where-Object {$_.date -eq $raidentry}
        $sortLeaves = $rleaveCSVimport | Where-Object {$_.date -eq $raidentry}
        $sortLoot = $rlootCSVimport | Where-Object {$_.date -eq $raidentry}
    
                
        $sortjoins | Foreach-Object { [void]$namearray.Add($_.name) }
        $sortleaves | Foreach-Object { [void]$namearray.Add($_.name) }
        $sortloot | Foreach-Object { [void]$namearray.Add($_.name) }
            
        $namearray = $namearray | Select-Object -Unique
       
        $store = foreach ($name in $namearray) { 
            #Finding the loot results for each person in the raid
            $lootCollection = $sortloot | Where-Object {$_.name -eq "$name"} | Where-Object {$_.priority -ge $Config.settings.reporting.qualityfilter}
            foreach ($loot in $lootcollection) {
                if ($lootlist -eq $null) { $lootlist = $loot.item } else { $lootlist = $lootlist + ";" + $loot.item }
                if ($URLlist -eq $null) { $URLlist = $loot.URL } else { $URLlist = $URLlist + ";" + $loot.URL }
            }

            #Finding join and leave time - If not data present, NO DATA is filled in the spot
            $JoinTime = $sortjoins | Where-Object {$_.name -eq "$name"} | sort-object -Property join | select-Object join -first 1
            $leavetime = $sortleaves | Where-Object {$_.name -eq "$name"} | sort-object -property leave | select-Object leave -last 1
           
            if (!$leavetime.leave) { $perPersonLeave = "NO DATA" } else { $perPersonLeave = $leavetime.leave }
            if (!$jointime.join) { $perPersonjoin = "NO DATA" }  Else { $perPersonJoin = $jointime.join }
            
               $obj = [pscustomobject][ordered]@{
                Name  = $name
                Join  = $perPersonJoin
                Leave = $perPersonLeave
                Loot  = $lootlist
                URL   = $URLList
            
            }
            $obj
            $lootlist = $null
            $urllist = $null
        }
        $store | export-csv $raidreportfilename -NoTypeInformation
    }
}
#Function for logging
function Write-Log {
    $currenttime = get-date -Format "[yyyy-MM-dd] H:mm:ss"
    $string = $currenttime + " " + $args
    $string | out-file $Config.settings.baseconfig.logfile -append
    write-host $string
}

Function GenDB {
    param([string]$filename)

    if (!$filename) { 
        "No filename specified. Searching WoW directory for CT_Raidtracker LUA files"
        $WTFAccount = "\WTF\ACCOUNT\"
        try { $DBFilesList = Get-Childitem ($config.settings.baseconfig.wowfolder + $WTFAccount + '\*\SavedVariables\CT_Raidtracker.lua') }
        catch { throw "Error: No files found. Check the wow folder location in the config and try again" ; exit }
        $count = $dbfileslist.count ; "Found $count files"
    }
    else {
        #Sanity check for existence of filename
        $fullpathfilename = (Get-Location).path + '\' + $filename
        if ((test-path $filename) -eq $false) { $Check1 = $false } else { $DBFilesList = Get-ChildItem $filename }
        if ((test-path $fullpathfilename) -eq $false) { $check2 = $false } else { $DBFilesList = Get-ChildItem $fullpathfilename }
        if (($check1 -eq $false) -and ($check2 -eq $false)) {  "ERROR: NO FILE FOUND BY THE NAME OF $filename" ; exit } 
    }
    #Declaring object types
    $player = '				["player"]'
    $time = '				["time"]'
    $name = '					["name"]'
    $colorhex = '					["c"]'
    $count = '					["count"]'
    $ID = '					["id"]'
    $final = '			},'
    $mode = $null
    $int = 0
    
    

    #Declaring objs for holding the data
    $store = @{}

    #Generating database begins
    "Generating database, This may take a few minutes"
    #Beginning loop through files
    $store = foreach ($DBFile in $DBFilesList) {
        $import = Get-Content $Dbfile
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
                    $ConvertedDate = Convert-DateTime $USformat 
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
                        Loot     = $timestamp
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
    $lootarr | export-csv $lootfile -NoTypeInformation
    $joinarr | export-csv $joinfile -NoTypeInformation
    $leavearr | export-csv $leavefile -NoTypeInformation
    "Database generation complete."
}

function Convert-DateTime($date) {
    $ConvertedDate = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($date, [System.TimeZoneInfo]::Local.Id, $Config.settings.baseconfig.timezoneid)
  return $ConvertedDate
}


#Function to search characters in DB
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
        $lootarray = $LootArray | Where-Object {$blacklist -notcontains $_.date} | sort-object -Property Name
        foreach ($entry in $lootarray) {
            if (($entry.name -ne $lastname) -and ($lastname -ne $null)) {
                $CharacterReport = $CharacterReportFolder + $lastname + "_loot.csv"
                $holdMe = $charArray | Select-Object * -ExcludeProperty Mode 
                if ($holdme.count -gt 0) { $holdme | export-csv $CharacterReport -NoTypeInformation }
                $chararray = New-Object System.Collections.ArrayList($null)
            }
            if ($entry.priority -ge $config.settings.reporting.qualityfilter) { [void]$charArray.Add($entry) }
            $lastname = $entry.name
        }
    }


    #Single character search
    if (($charname -notlike "*,*") -and ($charname -ne '*')) {
        $CharacterReport = $CharacterReportFolder + $charname + "_loot.csv"
        $filteredLootArray = $LootArray | Where-Object {$_.name -eq $Charname -and $blacklist -notcontains $_.date}
        $characterStore = foreach ($loot in $filteredLootArray) {
            if ($loot.priority -ge $Config.settings.reporting.qualityfilter) { $loot }
        }
        if ($characterstore.count -gt 0) { $characterStore | export-csv $characterreport -notypeinformation }
    }
}




#END FUNCTION DECLARATION