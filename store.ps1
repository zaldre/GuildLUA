#$raidJoinCSV = import-csv ($DBSub + "join.csv") | ?{$_.name -eq "$name" -and $blacklist -notcontains $_.date } #| select-object -Property date -Unique  | sort-object -Property date
$raidLeaveCSV = import-csv ($DBSub + "leave.csv") | ?{$_.name -eq "$name" -and $blacklist -notcontains $_.date} #| select-object -Property date -Unique | sort-object -Property date

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