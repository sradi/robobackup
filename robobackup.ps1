function printBackupJob($Job) {
	echo "$($Job.JobName)	$($Job.Id)"
}

function killBackupJobs($Processes) {
	foreach ($proc in $Processes) {
		kill $proc.Id
	}
}

function rollLogfile($Path, $MaxFilesToKeep) {
}

function startBackupJob($Name, $Source, $Target, $ExcludedFiles, $ExcludedDirectories) {
	$OutFile = "$($LogBasePath)\robobackup_$($Name).out"
	$ErrFile = "$($LogBasePath)\robobackup_$($Name).err"
	$TargetDir = "$($Target)\$Name" -replace "\\\\", "\"
	$RobocopyOptions = @"
$Source $TargetDir /E /MON:1 /MOT:$SyncInterval /ZB /FFT /R:100 /W:30 /XF $ExcludedFiles /XD $ExcludedDirectories
"@
	$Proc = Start-Process -FilePath robocopy.exe -ArgumentList $RobocopyOptions -NoNewWindow -PassThru -RedirectStandardOutput $OutFile -RedirectStandardError $ErrFile
	$Proc | Add-Member -MemberType NoteProperty -Name JobName -Value $Name
	return $Proc
}

$LogBasePath = 'D:\temp\robobackup'
If (!(Test-Path $LogBasePath)){ New-Item -ItemType Directory $LogBasePath }
$MaxFilesToKeep = 5
$SyncInterval = 30
$BackupJobsConfiguration = "$((Get-ChildItem Env:USERPROFILE).Value)/.robobackup-jobs.csv"

$BackupJobs = Import-Csv -Path $BackupJobsConfiguration
$BackupJobProcesses = @()

foreach ($Job in $BackupJobs) {
	$JobObject = startBackupJob `
		-Name $Job.Name `
		-Source $Job.Source `
		-Target $Job.Target `
		-ExcludedFiles $Job.ExcludedFiles `
		-ExcludedDirectories $Job.ExcludedDirectories
	
	printBackupJob($JobObject)
	$BackupJobProcesses += $JobObject
}

write-host "Robobackup-Jobs erfolgreich gestartet. Strg+C für Abbruch."
# Warte auf "kill"
try
{
    while($true)
    {
        Start-Sleep -Seconds 30
    }
}
finally
{
    write-host "Beende Robobackup-Jobs..."
	killBackupJobs $BackupJobProcesses
	write-host "Beendet."
}