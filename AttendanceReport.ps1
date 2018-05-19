#Load the config file
$ConfigFile = "D:\dropbox\guildlua\config_Lua.xml"
[xml]$Config = Get-Content $ConfigFile
$DBSub = $Config.settings.baseconfig.workingdir + '\' + $Config.settings.baseconfig.databasefolder + '\'
$RPSub = $Config.settings.baseconfig.workingdir + '\' + $Config.settings.reporting.reportfolder + '\'
$name = "Zaldre"
$raidDays = $Config.settings.reporting.Raiddays.Split(",") 


$blacklist = import-csv ($DBSub + "blacklist.csv") | Where-Object {$_.player -eq "*" -or $_.player -eq "$name"} | Select-Object -ExpandProperty Date


$raidJoinCSV = import-csv ($DBSub + "join.csv") | Where-Object{$_.name -eq "$name" -and $blacklist -notcontains $_.date } #| select-object -Property date -Unique  | sort-object -Property date
$raidLeaveCSV = import-csv ($DBSub + "leave.csv") | Where-Object{$_.name -eq "$name" -and $blacklist -notcontains $_.date} #| select-object -Property date -Unique | sort-object -Property date

$joinCount = New-Object System.Collections.ArrayList

foreach ($entry in $raidjoincsv) {
    [datetime]$joinproc = $entry.date.replace(',','/')
        if (($joincount -notcontains $entry.date) -and ($raiddays -contains $dateformatting.dayofweek) -and ($Config.settings.reporting.raidtimeonly -eq "true")) {
        }
}
$joincount | sort-object 

[datetime]$firstJoin = (($joincount | select-object -First 1).Replace(',','/'))
[datetime]$lastJoin = $joincount | select-object -last 1



$global:raidjoin = foreach ($entry in $raidjoincsv) {
    [datetime]$dateformatting = $entry.date.Replace('.', '/')
       if (($raiddays -contains $dateformatting.dayofweek) -and ($Config.settings.reporting.raidtimeonly -eq "true")) {
    $entry
    }
    if ($Config.settings.reporting.raidtimeonly -ne "true") { $entry }
}
$raidjoin
$FirstDate = $raidJoin | select-object -First 1 -ExpandProperty date
[datetime]$firstRaid = $firstdate.Replace('.','/')
[datetime]$latestRaid = $raidJoin | select-object -last 1 -ExpandProperty date


$weeksbetween = ((New-TimeSpan -Start $firstRaid -End $latestRaid | select -ExpandProperty Days) / 7)
$expectedRaids = [math]::Round($weeksbetween * $raidsPerWeek - $blacklist.count)
$totalRaids = ($raidJoin | Select-Object -Property date -Unique).Count




"Expected to attend $expectedraids"
"Has attended $totalraids"
#>
<#
#Calculating the number of raid days between their first day and now.
foreach ($entry in $raiddays) {
    $days += [System.DayOfWeek]::$entry
}
$now = (Get-Date).AddDays(-1)
$raidsBetween = 0
foreach ($entry in $raiddays) {
}


$date = Get-Date -Year 2015 -Month 8 -Day 28
$now = (Get-Date).AddDays(-1)

$workdays = 0

while ($now -le $date) {

    $now = $now.AddDays(1)

    if ($now.DayOfWeek -notin $we ) {
        $workdays++
    }

}



#Calculating which dates in the blacklist are on raid days
$blacklistfile = $DBsub + 'blacklist.txt'
if (!(test-path $blacklistfile)) { New-Item $blacklistfile -ItemType file }
$BlackListImport = cat $blacklistfile
$blacklist = foreach ($entry in $BlacklistImport) {
    $parse = [datetime]$entry | select -ExpandProperty dayofweek
    if ($Raiddays -like $parse) { $entry }

}

#>