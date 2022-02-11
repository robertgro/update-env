@echo off
::https://stackoverflow.com/questions/3827567/how-to-get-the-path-of-the-batch-script-in-windows
cd %~dp0
call update-env.cmd %COMPUTERNAME% >>update-env.log 2>>&1
::https://superuser.com/questions/338277/windows-cmd-batch-start-and-output-redirection
::https://stackoverflow.com/questions/4798879/how-do-i-run-a-batch-script-from-within-a-batch-script/4798965
del /q *.exe *.msi >nul 2>&1
call scp-remote.cmd