@echo off
Setlocal EnableDelayedExpansion
echo [%date%, %time%] Fetching requirements for app updates...
if not exist ".\cfg\update-env_%1.cfg" (
    type NUL > .\cfg\update-env_%1.cfg
)
for %%I in (.\cfg\update-env_%1.cfg) do (
    set size=%%~zI
    if not !size! gtr 0 goto :skip
)
for /f "tokens=1-6" %%G in (.\cfg\update-env_%1.cfg) do (
    echo Processing app "%%G"...
    %%G %%H >nul 2>&1
    if errorlevel 1 (
        echo "%%G" app not found
        echo update requires a valid cfg, path and installation of "%%G"
        echo opening "%%J" in your browser now
        start "" %%J
        echo.
    ) else (
        cscript //nologo update-env.vbs %%G %%H %%I %%J %%K %%L
        echo.
    )
)
goto :end
:skip
echo Skipping due to empty cfg
:end
endlocal
::DEBUG echo %%G %%H %%I %%J %%K %%L
::DEBUG cfg scheme args [app][versioncmd] [regexversionpattern] [downloadurl] [regexdownloaduripattern] [regexfilenamepattern]