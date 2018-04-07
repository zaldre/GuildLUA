#Looking for -Raid flag

if ($raid) {
    raidfunction -Raidentry $raid
}
function checkLastLoot($lootName) {
    return $lootarray | ? {($_.name -eq $lootname) -and ($_.priority -ge $config.settings.reporting.qualityfilter)} | sort-object date | Select-Object -Last $quantity
}
   
function RaidFunction($Raidentry) {

   
    #Begin processing of ALL raid reports
    if ($Raidentry -eq '*') {
        $joinImport = (import-csv ($dbsub + 'join.csv')) | Sort-Object -Property date -Descending
        $leaveImport = (import-csv ($dbsub + 'leave.csv')) | Sort-Object -Property date -Descending
        $lootImport = (import-csv ($dbsub + 'loot.csv')) | Sort-Object -Property date -Descending
        "uyo"
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
        if (!$raidstore) { Throw "Error: No data found for that raid, Correct Syntax: YYYY-MM-DD" } 
        else { $raidstore | export-csv $raidreportfilename }
    }
}