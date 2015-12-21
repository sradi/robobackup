# Wenn dieses Skript nicht ausgeführt werden kann, liegt es möglicherweise der restriktiven Default-Konfiguration unter Windows.
# Folgendes Kommando ausführen: Set-ExecutionPolicy RemoteSigned

function printBackupJob($Job) {
	echo "$($Job.JobName)	$($Job.Id)"
}

function killBackupJobs($Processes) {
}

function rollLogfile($Path, $MaxFilesToKeep) {
}

function startBackupJob($Name, $Source, $Target, $ExcludedFiles, $ExcludedDirectories) {
	$OutFile = "$($LogBasePath)\robobackup_$($Name).out"
	$ErrFile = "$($LogBasePath)\robobackup_$($Name).err"
	$RobocopyOptions = @"
$Source $Target /E /MON:1 /MOT:$SyncInterval /ZB /FFT /R:100 /W:30 /XF $ExcludedFiles /XD $ExcludedDirectories
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

foreach ($Job in $BackupJobs) {
	$JobObject = startBackupJob `
		-Name $Job.Name `
		-Source $Job.Source `
		-Target $Job.Target `
		-ExcludedFiles $Job.ExcludedFiles `
		-ExcludedDirectories $Job.ExcludedDirectories
	
	printBackupJob($JobObject)
}