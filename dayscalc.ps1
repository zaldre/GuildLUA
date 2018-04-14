#calculate work days
#Need to know the number of working days left until a specific date?

$we = [System.DayOfWeek]::Saturday, [System.DayOfWeek]::Sunday

$date = Get-Date -Year 2015 -Month 8 -Day 28
$now = (Get-Date).AddDays(-1)

$workdays = 0

while ($now -le $date){

$now = $now.AddDays(1)

if ($now.DayOfWeek -notin $we ) {
$workdays++
}

}
$workdays