param([String]$BackupJobsConfigFile = "$((Get-ChildItem Env:USERPROFILE).Value)/.robobackup-jobs.csv")

If (!(Test-Path $BackupJobsConfigFile)){
	write-host "No configuration file '$($BackupJobsConfigFile)' found."
	exit 1
}
$BackupJobs = Import-Csv -Path $BackupJobsConfigFile

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
$Source $TargetDir /MIR /MON:1 /MOT:$SyncInterval /ZB /FFT /NP /R:10 /W:6 /XJD /XF $ExcludedFiles /XD $ExcludedDirectories
"@
	$Proc = Start-Process -FilePath robocopy.exe -ArgumentList $RobocopyOptions -NoNewWindow -PassThru -RedirectStandardOutput $OutFile -RedirectStandardError $ErrFile
	$Proc | Add-Member -MemberType NoteProperty -Name JobName -Value $Name
	return $Proc
}

$LogBasePath = 'D:\temp\robobackup'
If (!(Test-Path $LogBasePath)){ New-Item -ItemType Directory $LogBasePath }
$MaxFilesToKeep = 5
$SyncInterval = 30

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