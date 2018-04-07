
$ConfigFile = "D:\dropbox\guildlua\config_Lua.xml"
[xml]$Config = Get-Content $ConfigFile
$freshrun = "yes"

#Pre-Requisite checks for existing data. Creates directories if they do not exist

$DBSub = $Config.settings.baseconfig.workingdir + '\' + $Config.settings.baseconfig.databasefolder + '\'
$RPSub = $Config.settings.baseconfig.workingdir + '\' + $Config.settings.reporting.reportfolder + '\'
<#Logic for raid function: 


Get joins, sort by date, add to array
Get leaves, same
Get loot, same
#>

function Create-RaidLists { 
    $script:joinlist = New-Object -TypeName System.Collections.ArrayList
    $script:leavelist = New-Object -TypeName System.Collections.ArrayList
    $script:lootlist = New-Object -TypeName System.Collections.ArrayList
    $script:namelist = New-Object -TypeName System.Collections.ArrayList

}
$joins = (import-csv ($dbsub + "join.csv")) | Sort-Object -Property date
$leaves = import-csv ($dbsub + "leave.csv")
$loots = import-csv ($dbsub + "loot.csv")

Create-RaidLists

foreach ($join in $joins) {
    #$join
#finding the block where the entry where the date changes to start processing each file
    if (($join.date -ne $lastdate) -and ($lastdate -ne $null)) {
        [void]$leavelist.Add(($leaves | ?{$_.date -eq $lastdate}))
        [void]$lootlist.Add(($loot | ?{$_.date -eq $lastdate}))

        #Now we have all the date related data stored, Lets generate each raid report based on who attended.
        $leavelist | %{ [void]$namelist.add($_.name) }
        $joinlist | %{ [void]$namelist.add($_.name) }
        $lootlist | %{ [void]$namelist.add($_.name) }

        $namelist = $namelist | select-object -unique
        
    }
    else { [void]$joinlist.add($join) ; $lastdate = $join.date}
}
$leavelist


<#
if ($_.date -ne $lastdate) { 
leavearray.add($Leaves | ?{$_.date -eq $lastdate})
lootarray.add($loot  | ?{$_.date -eq $lastdate})
$namearray = new arraylist
foreach ($Name in $arrays 1 2 3) { $namearray.ADd($name) }
}
select unique
csv name = lastdate

foreach ($name in $namearray) {

}


$lastdate = $_.date
}
#>