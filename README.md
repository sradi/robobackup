# robobackup
Powershell script for automatic background file backups on Windows.

This script can be configured to mirror a list of directories to backup destinations.
The script starts a robocopy process for each directory, that should be synced.
Each robocopy process keeps running in background and syncs changes from the source directory to the destination every 30 minutes.

## Configuation
- Create a CSV file (comma separated values)
- add a row with the titles Name,Source,Target,ExcludedFiles,ExcludedDirectories
- add a row for each directory, you would like to backup

... robocopy /FFT: Dann werden Dateien nicht ständig fehlerhaft als "geändert" erkannt


...damit dieses Skript Netzlaufwerke sehen kann, muss in der Registry...

...wenn dieses Skript nicht ausgeführt werden kann, liegt es möglicherweise der restriktiven Default-Konfiguration unter Windows.
Folgendes Kommando ausführen: Set-ExecutionPolicy RemoteSigned

## Todo
- Parametriesierbar, ob "mirror" /MIR oder "extend" /E backup
- optionaler Parameter für eigenen Pfad zur Joblisten-Datei
- Prozess-Status (exitcode) nach Job-Start prüfen und ggf. Warnung ausgeben
