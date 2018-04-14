#Load the config file
$ConfigFile = "D:\dropbox\guildlua\config_Lua.xml"
[xml]$Config = Get-Content $ConfigFile
$DBSub = $Config.settings.baseconfig.workingdir + '\' + $Config.settings.baseconfig.databasefolder + '\'
$RPSub = $Config.settings.baseconfig.workingdir + '\' + $Config.settings.reporting.reportfolder + '\'
$name = "Zaldre"
$raidDays = $Config.settings.reporting.Raiddays.Split(",") 

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

while ($now -le $date){

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
$parse =  [datetime]$entry | select -ExpandProperty dayofweek
if ($Raiddays -like $parse) { $entry }

}

