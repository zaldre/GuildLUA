$blacklistfile = $DBsub + 'blacklist.txt'
if (!(test-path $blacklistfile)) { New-Item $blacklistfile -ItemType file }
$BlackList = cat $blacklistfile


$raidJoinCSV = import-csv ($DBSub + "join.csv") | ?{$_.name -eq "$name" -and $blacklist -notcontains $_.date } | sort-object -Property date
$raidLeaveCSV = import-csv ($DBSub + "leave.csv") | ?{$_.name -eq "$name" -and $blacklist -notcontains $_.date} | sort-object -Property date

$global:raidjoin = foreach ($entry in $raidjoincsv) {
    #$entry.date
    [datetime]$dateformatting = $entry.date.Replace('.', '/')
    $dateformatting.dayofweek
       if (($raiddays -contains $dateformatting.dayofweek) -and ($Config.settings.reporting.raidtimeonly -eq "true")) {
    $entry
    }
    if ($Config.settings.reporting.raidtimeonly -ne "true") { $entry }
}
$raidjoin | export-csv test.csv
[datetime]$firstRaid = $raidJoin | select-object -First 1 | select -ExpandProperty date
[datetime]$latestRaid = $raidJoin | select-object -last 1 | select -ExpandProperty date


$weeksbetween = ((New-TimeSpan -Start $firstRaid -End $latestRaid | select -ExpandProperty Days) / 7)
$expectedRaids = [math]::Round($weeksbetween * $raidsPerWeek - $blacklist.count)
$totalRaids = ($raidJoin | Select-Object -Property date -Unique).Count




"Expected to attend $expectedraids"
"Has attended $totalraids"
