#CONFIG LOAD
$ConfigFile = "C:\dropbox\guild\config_Lua.xml"
[xml]$Config = Get-Content $ConfigFile

#Function to open folder
Function FolderOpen($initialDirectory) {
    Add-Type -AssemblyName System.Windows.Forms
    $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog #-property @{ Selectpath = $config.settings.baseconfig.workingdir }
    [void]$FolderBrowser.ShowDialog()
    return $FolderBrowser.SelectedPath
    
}


#Function to open file
Function FileOpen ($FileOpenFilter, $InitialDirectory) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialdirectory
    $fileopenfilter = '*.' + $fileopenfilter
    $OpenFileDialog.filter = "$filteropenfilter | $fileopenfilter"
    $OpenFileDialog.ShowDialog() | Out-Null
    return $OpenFileDialog.filename
}


#Main Config Form
Add-Type -AssemblyName System.Windows.Forms

$configGUI = New-Object system.Windows.Forms.Form
$configGUI.Text = "Configuration Settings"
$configGUI.TopMost = $false
$configGUI.Width = 525
$configGUI.Height = 450

#Base Config Label
$BaseConfigLabel = New-Object system.windows.Forms.Label
$BaseConfigLabel.Text = "Base Config"
$BaseConfigLabel.AutoSize = $true
$BaseConfigLabel.Width = 25
$BaseConfigLabel.Height = 10
$BaseConfigLabel.location = new-object system.drawing.point(9, 6)
$BaseConfigLabel.Font = "Microsoft Sans Serif,12,style=Bold"
$configGUI.controls.Add($BaseConfigLabel)

#Working Directory
$workingdirLabel = New-Object system.windows.Forms.Label
$workingdirLabel.Text = "Working Directory"
$workingdirLabel.Width = 150
$workingdirLabel.Height = 20
$workingdirLabel.location = new-object system.drawing.point(14, 30)
$workingdirLabel.Font = "Microsoft Sans Serif,10"
$configgui.controls.Add($workingdirLabel)

$workingdirBox = New-Object system.windows.Forms.TextBox
$workingdirBox.Width = 150
$workingdirBox.Height = 20
$workingdirBox.Text = $config.settings.baseconfig.workingdir
$workingdirBox.location = new-object system.drawing.point(14, 53)
$workingdirBox.Font = "Microsoft Sans Serif,10"
$configGUI.controls.Add($workingdirBox)

$workingdirBrowse = New-Object system.windows.Forms.Button
$workingdirBrowse.Text = "browse"
$workingdirBrowse.Width = 50
$workingdirBrowse.Height = 20
$workingdirBrowse.location = new-object system.drawing.point(170, 53)
$workingdirBrowse.Font = "Microsoft Sans Serif,8"
$workingdirBrowse.Add_Click( {
        $workingDirOpen = FolderOpen -initialdirectory $config.settings.baseconfig.workingdir
        $Config.settings.baseconfig.workingdir = $workingdirOpen
        write-host $config
        $workingdirBox.Text = $workingdirOpen
        $workingdirBox.Refresh() 
        $Config.Save($ConfigFile)
    })
$configGui.controls.Add($workingdirBrowse)

#Report Folder
$ReportFolderLabel = New-Object system.windows.Forms.Label
$ReportFolderLabel.Text = "Report Folder"
$ReportFolderlabel.Width = 150
$ReportFolderLabel.Height = 20
$ReportFolderLabel.location = new-object system.drawing.point(14, 80)
$ReportFolderLabel.Font = "Microsoft Sans Serif,10"
$configgui.controls.Add($ReportFolderLabel)


$ReportFolderBox = New-Object system.windows.Forms.TextBox
$ReportFolderBox.Width = 150
$ReportFolderBox.Height = 20
$ReportFolderBox.Text = $config.settings.reporting.reportfolder
$ReportFolderBox.location = new-object system.drawing.point(15, 101)
$ReportFolderBox.Font = "Microsoft Sans Serif,10"
$configGUI.controls.Add($ReportFolderBox)

#Database Folder

$databasefolderLabel = New-Object system.windows.Forms.Label
$databasefolderLabel.Text = "Database Folder"
$databasefolderLabel.Width = 150
$databasefolderLabel.Height = 20
$databasefolderLabel.location = new-object system.drawing.point(14, 135)
$databasefolderLabel.Font = "Microsoft Sans Serif,10"
$configgui.controls.Add($databasefolderLabel)

$databasefolderBox = New-Object system.windows.Forms.TextBox
$databasefolderBox.Width = 150
$databasefolderBox.Height = 20
$databasefolderBox.Text = $config.settings.baseconfig.databasefolder
$databasefolderBox.location = new-object system.drawing.point(15, 156)
$databasefolderBox.Font = "Microsoft Sans Serif,10"
$configGUI.controls.Add($databasefolderBox)

#Logfile


$logfileLabel = New-Object system.windows.Forms.Label
$logfileLabel.Text = "Log File"
$logfileLabel.Width = 150
$logfileLabel.Height = 20
$logfileLabel.location = new-object system.drawing.point(14, 185)
$logfileLabel.Font = "Microsoft Sans Serif,10"
$configgui.controls.Add($logfileLabel)


$logfileBox = New-Object system.windows.Forms.TextBox
$logfileBox.Width = 150
$logfileBox.Height = 20
$logfilebox.Text = $config.settings.baseconfig.logfile
$logfileBox.location = new-object system.drawing.point(15, 205)
$logfileBox.Font = "Microsoft Sans Serif,10"
$configGUI.controls.Add($logfileBox)

#LUA File selection
$LuaFileLabel = New-Object system.windows.Forms.Label
$LuaFileLabel.Text = "CT RaidTracker LUA File"
$LuaFileLabel.Width = 200
$LuaFileLabel.Height = 20
$LuaFileLabel.location = new-object system.drawing.point(14, 235)
$LuaFileLabel.Font = "Microsoft Sans Serif,10"
$configgui.controls.Add($LuaFileLabel)

$LuaFileBox = New-Object system.windows.Forms.TextBox
$LuaFileBox.Width = 150
$LuaFileBox.Height = 20
$LuaFilebox.Text = $config.settings.baseconfig.luafile
$LuaFileBox.location = new-object system.drawing.point(15, 255)
$LuaFileBox.Font = "Microsoft Sans Serif,10"
$configGUI.controls.Add($LuaFileBox)

$LuaFileBrowse = New-Object system.windows.Forms.Button
$LuaFileBrowse.Text = "browse"
$LuaFileBrowse.Width = 50
$LuaFileBrowse.Height = 20
$LuaFileBrowse.location = new-object system.drawing.point(170, 255)
$LuaFileBrowse.Font = "Microsoft Sans Serif,8"
$LuaFileBrowse.Add_Click( {
        $LUAFileOpen = FileOpen -initialdirectory $config.settings.baseconfig.workingdir -fileopenfilter 'lua'  
        $Config.settings.baseconfig.luafile = $LUAFileOpen
        $LuaFileBox.Text = $LUAFileOpen
        $LuaFileBox.Refresh()
        $Config.Save($ConfigFile)
    })
$configGui.controls.Add($LuaFileBrowse)

#Timezone Settings - Config Gui

$timezoneLabel = New-Object system.windows.Forms.Label
$timezoneLabel.Text = "Server Timezone"
$timezoneLabel.Width = 150
$timezoneLabel.Height = 20
$timezoneLabel.location = new-object system.drawing.point(14, 285)
$timezoneLabel.Font = "Microsoft Sans Serif,10"
$configgui.controls.Add($timezoneLabel)

$TimeZoneBox = New-Object system.windows.Forms.TextBox
$TimeZoneBox.Width = 150
$TimeZoneBox.Height = 20
$timezonebox.Text = $config.settings.baseconfig.timezoneID
$TimeZoneBox.location = new-object system.drawing.point(15, 305)
$TimeZoneBox.Font = "Microsoft Sans Serif,10"
$configGUI.controls.Add($TimeZoneBox)

$timezoneBrowse = New-Object system.windows.Forms.Button
$timezoneBrowse.Text = "browse"
$timezoneBrowse.Width = 50
$timezoneBrowse.Height = 20
$timezoneBrowse.location = new-object system.drawing.point(170, 305)
$timezoneBrowse.Font = "Microsoft Sans Serif,8"
$timezoneBrowse.Add_Click( {
        [void]$TZForm.ShowDialog()
    })


#BEGIN TIMEZONE SELECTION DIALOG BOX
$TZarray = New-Object System.Collections.ArrayList 
$TZData = [System.TimeZoneInfo]::GetSystemTimeZones()
$TZData | % { $TZArray.Add($_) |out-null }

$TZForm = New-Object system.Windows.Forms.Form
$TZForm.Text = "Timezone Settings"
$TZForm.TopMost = $true
$TZForm.Width = 320
$TZForm.Height = 350

$TZBox = New-Object system.windows.Forms.ListBox
$TZBox.Text = "listBox"
$TZBox.Width = 300
$TZBox.Height = 300
$TZBox.location = new-object system.drawing.point(1, 1)
$TZBox.DataSource = $TZarray
$TZForm.controls.Add($TZBox)

$TZbuttonOK = New-Object system.windows.Forms.Button
$TZbuttonOK.Text = "OK"
$TZbuttonOK.Width = 60
$TZbuttonOK.Height = 20
$TZbuttonOK.location = new-object system.drawing.point(1, 290)
$TZbuttonOK.Font = "Microsoft Sans Serif,10"
$TZbuttonOK.Add_Click( {
        $TZSelect = $TZBox.SelectedItem
        $NewTimeZone = $TZdata | ? {$_.displayname -eq $TZSelect}
        $Config.settings.baseconfig.timezoneID = $NewTimeZone.ID
        $TZform.Close()
        $TimeZoneBox.Text = $NewTimeZone.ID
        $TimeZoneBox.Refresh()
        $Config.Save($ConfigFile)
    })
$TZForm.controls.Add($TZbuttonOK)

$TZbuttonCancel = New-Object system.windows.Forms.Button
$TZbuttonCancel.Text = "Cancel"
$TZbuttonCancel.Width = 60
$TZbuttonCancel.Height = 20
$TZbuttonCancel.location = new-object system.drawing.point(200, 290)
$TZbuttonCancel.Font = "Microsoft Sans Serif,10"
$TZbuttonCancel.Add_Click( {
        $TZform.Close()
    })
$TZForm.controls.Add($TZbuttonCancel)
$configGui.controls.Add($timezoneBrowse)

#END BASE CONFIG

#START REPORTING CONFIG

#Report Config Label
$ReportConfigLabel = New-Object system.windows.Forms.Label
$ReportConfigLabel.Text = "Report Config"
$ReportConfigLabel.AutoSize = $true
$ReportConfigLabel.Width = 25
$ReportConfigLabel.Height = 10
$ReportConfigLabel.location = new-object system.drawing.point(300, 6)
$ReportConfigLabel.Font = "Microsoft Sans Serif,12,style=Bold"
$configGUI.controls.Add($ReportConfigLabel)

#Quality Filter
$qualityfilterLabel = New-Object system.windows.Forms.Label
$qualityfilterLabel.Text = "Quality Filter"
$qualityfilterLabel.Width = 150
$qualityfilterLabel.Height = 20
$qualityfilterLabel.location = new-object system.drawing.point(305, 30)
$qualityfilterLabel.Font = "Microsoft Sans Serif,10"
$configgui.controls.Add($qualityfilterLabel)

#Selection box for QUality filter
if ($config.settings.reporting.qualityfilter -eq "0") { $QualityFilterSetting = "Grey" }
if ($config.settings.reporting.qualityfilter -eq "1") { $QualityFilterSetting = "White" }
if ($config.settings.reporting.qualityfilter -eq "2") { $QualityFilterSetting = "Uncommon" }
if ($config.settings.reporting.qualityfilter -eq "3") { $QualityFilterSetting = "Rare" }
if ($config.settings.reporting.qualityfilter -eq "4") { $QualityFilterSetting = "Epic" }

$QualityFilterList = @("Epic", "Rare", "Uncommon", "White", "Grey")
$QualityFiltercomboBox = New-Object system.windows.Forms.ComboBox
$QualityFiltercomboBox.Text = $QualityFilterSetting
$QualityFiltercomboBox.Width = 120
$QualityFiltercomboBox.Height = 20
$QualityFiltercomboBox.location = new-object system.drawing.point(305, 50)
$QualityFiltercomboBox.Font = "Microsoft Sans Serif,10"
foreach ($entry in $QualityFilterList) {
    $QualityFilterComboBox.Items.Add($entry)
}
$configGUI.controls.Add($QualityFiltercomboBox)


#Convert to server time?

$ConvertToServerTimeCheckbox = New-Object system.windows.Forms.CheckBox
$ConvertToServerTimeCheckbox.Text = "Convert to server time"
$ConvertToServerTimeCheckbox.AutoSize = $true
$ConvertToServerTimeCheckbox.Width = 95
$ConvertToServerTimeCheckbox.Height = 20
$ConvertToServerTimeCheckbox.location = new-object system.drawing.point(305, 300)
$ConvertToServerTimeCheckbox.Font = "Microsoft Sans Serif,8"
$configGUI.controls.Add($ConvertToServerTimeCheckbox)


#CHECKBOX


$ReportRaidDaysCheckbox = New-Object system.windows.Forms.CheckBox
$ReportRaidDaysCheckbox.Text = "Report raid days and times only"
$ReportRaidDaysCheckbox.AutoSize = $true
$ReportRaidDaysCheckbox.Width = 95
$ReportRaidDaysCheckbox.Height = 20
$ReportRaidDaysCheckbox.location = new-object system.drawing.point(305, 270)
$ReportRaidDaysCheckbox.Font = "Microsoft Sans Serif,8"
#Checking if this is enabled or disabled here

if ($config.settings.reporting.raidtimeonly -eq $true) {
    $ReportRaidDaysCheckbox.Checked = $true

}
else { }
$configGUI.controls.Add($ReportRaidDaysCheckbox)


#DaySelection

$dayselectionlabel = New-Object system.windows.Forms.Label
$dayselectionlabel.Text = "Raid Days"
$dayselectionlabel.Width = 150
$dayselectionlabel.Height = 20
$dayselectionlabel.location = new-object system.drawing.point(305, 80)
$dayselectionlabel.Font = "Microsoft Sans Serif,10"
$configgui.controls.Add($dayselectionlabel)

$dayselectionCheckedListbox = New-Object -TypeName System.Windows.Forms.CheckedListBox;
$dayselectionCheckedListbox.Width = 100;
$dayselectionCheckedListbox.Height = 100;

$dayselectionCheckedListbox.ClearSelected();
$MyArray = "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
$raiddays = $config.settings.reporting.raiddays.Split(",")
foreach ($Item in $MyArray) {
    # Check it ...
    $dayselectionCheckedListbox.Items.Add($item);
    foreach ($day in $raiddays) { if ($item -eq $day) { $dayselectionCheckedListbox.SetItemChecked($dayselectionCheckedListbox.Items.IndexOf($Item), $true); } }
}
$dayselectionCheckedListbox.location = new-object system.drawing.point(305, 100)
$ConfigGui.Controls.Add($dayselectionCheckedListbox);

#TimeSelection


$timeselectionlabel = New-Object system.windows.Forms.Label
$timeselectionlabel.Text = "Raid Times"
$timeselectionlabel.Width = 80
$timeselectionlabel.Height = 20
$timeselectionlabel.location = new-object system.drawing.point(305, 200)
$timeselectionlabel.Font = "Microsoft Sans Serif,10"
$configgui.controls.Add($timeselectionlabel)


# StartTimeLabel
$starttimelabel = New-Object system.windows.Forms.Label
$starttimelabel.Text = "Start"
$starttimelabel.Width = 50
$starttimelabel.Height = 20
$starttimelabel.location = new-object system.drawing.point(305, 220)
$starttimelabel.Font = "Microsoft Sans Serif,8"
$configgui.controls.Add($starttimelabel)



#StartTimePicker
$minTimePicker = New-Object System.Windows.Forms.DateTimePicker
$minTimePicker.Location = “305, 240”
$minTimePicker.Width = “50”
$minTimePicker.Format = [windows.forms.datetimepickerFormat]::custom
$minTimePicker.CustomFormat = “HH:mm”
$minTimePicker.ShowUpDown = $TRUE
$mintimepicker.text = $Config.settings.reporting.monitoredTimestart
$ConfigGUi.Controls.Add($minTimePicker)

# EndLabel
$endtimelabel = New-Object system.windows.Forms.Label
$endtimelabel.Text = "End"
$endtimelabel.Width = 50
$endtimelabel.Height = 20
$endtimelabel.location = new-object system.drawing.point(375, 220)
$endtimelabel.Font = "Microsoft Sans Serif,8"
$configgui.controls.Add($endtimelabel)

# MaxTimePicker
$maxTimePicker = New-Object System.Windows.Forms.DateTimePicker
$maxTimePicker.Location = “375, 240”
$maxTimePicker.Width = “50”
$maxTimePicker.Format = [windows.forms.datetimepickerFormat]::custom
$maxTimePicker.CustomFormat = “HH:mm”
$maxTimePicker.ShowUpDown = $TRUE
$maxtimepicker.text = $Config.settings.reporting.monitoredTimeend
$ConfigGUi.Controls.Add($maxTimePicker)

#Show the gui
[void]$configGUI.ShowDialog()
$configGUI.Dispose()



#After the GUI has closed, We ensure that editable text fields are saved back to the config file.

$config.settings.reporting.reportfolder = $ReportFolderBox.Text
$config.settings.baseconfig.databasefolder = $DatabaseFolderBox.Text
$config.settings.baseconfig.logfile = $logFileBox.Text

#QUality filter writeback
if ($QualityFilterComboBox.SelectedItem -eq "Grey") { $config.settings.reporting.qualityfilter = "0" }
if ($QualityFilterComboBox.SelectedItem -eq "White") {$config.settings.reporting.qualityfilter = "1" }
if ($QualityFilterComboBox.SelectedItem -eq "Green") {$config.settings.reporting.qualityfilter = "2" }
if ($QualityFilterComboBox.SelectedItem -eq "Rare") {$config.settings.reporting.qualityfilter = "3" }
if ($QualityFilterComboBox.SelectedItem -eq "Epic") {$config.settings.reporting.qualityfilter = "4" }

#Writing back raid days
$daylist = $null
$dayselectioncheckedlistbox.CheckedItems | % { if ($daylist -eq $null) { $daylist = [string]$_ } else { $daylist = $daylist + "," + [string]$_ } }
$config.settings.reporting.raiddays = $Daylist


#writing back raid times

$Config.settings.reporting.monitoredTimestart = $mintimepicker.text
$Config.settings.reporting.monitoredTimeend = $maxtimepicker.text



#Saving the config file as our last order of business
$config.save($ConfigFile)
#END OF CONFIG GUI