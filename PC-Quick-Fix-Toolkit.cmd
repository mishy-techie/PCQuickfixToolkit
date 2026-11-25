@echo off
rem ======================================================================
rem  PC Quick Fix Toolkit v1.0
rem  What it does: one-click automatic fix, internet repair, temp file
rem  cleanup, PC health report, Windows file repair, printer fix, and
rem  Windows Update reset. Results are explained in plain English.
rem  Safe: never deletes personal files, asks before bigger actions,
rem  and creates a System Restore point before repairs.
rem  Switches: /auto /report /flushdns /cleantemp /fixprinter
rem            /resetupdate /help
rem ======================================================================
setlocal EnableExtensions
title PC Quick Fix Toolkit
set "VERSION=1.0"
set "SELF=%~f0"
set "LOG=%USERPROFILE%\Desktop\PC-Toolkit-Log.txt"
set "REPORT=%USERPROFILE%\Desktop\PC-Report.txt"
set "SUM=%TEMP%\pcqf-summary.txt"
set "GLANCE=%TEMP%\pcqf-glance.txt"

rem ---- Command-line switches (for IT pros) ----
if /i "%~1"=="/auto"        goto :cli_auto
if /i "%~1"=="/report"      goto :cli_report
if /i "%~1"=="/flushdns"    goto :cli_dns
if /i "%~1"=="/cleantemp"   goto :cli_clean
if /i "%~1"=="/fixprinter"  goto :cli_printer
if /i "%~1"=="/resetupdate" goto :cli_update
if /i "%~1"=="/help"        goto :help
if "%~1"=="/?"              goto :help

:menu
cls
echo ==============================================
echo        PC QUICK FIX TOOLKIT  v%VERSION%
echo ==============================================
echo.
echo   1. Fix my PC automatically (recommended)
echo   2. Fix internet problems
echo   3. Free up space (clear temporary files)
echo   4. Create a PC health report
echo   5. Check and repair Windows files
echo   6. Fix printer problems (stuck print jobs)
echo   7. Reset Windows Update
echo   8. Exit
echo.
choice /c 12345678 /n /m "Press a number (1-8): "
if errorlevel 8 goto :quit
if errorlevel 7 goto :winupdate
if errorlevel 6 goto :printer
if errorlevel 5 goto :sfc
if errorlevel 4 goto :health
if errorlevel 3 goto :cleanup
if errorlevel 2 goto :internet
if errorlevel 1 goto :auto
goto :menu

rem ---------------------------------------------------------------
:auto
cls
echo --- FIX MY PC (AUTOMATIC) ---
echo.
echo I will check the most common problems and fix the safe ones.
echo Nothing personal is deleted. This takes about a minute.
echo.
set "ADMINMSG=For the best results this should run as administrator."
call :require_admin
set "ADMINMSG="
echo.
call :auto_core
echo.
echo ==============================================
echo   WHAT I DID AND FOUND
echo ==============================================
type "%SUM%"
echo.
echo ==============================================
echo   HOW YOUR PC LOOKS NOW
echo ==============================================
type "%GLANCE%"
echo.
echo For a deeper check of Windows system files, use option 5.
echo.
pause
goto :menu

rem ---------------------------------------------------------------
:internet
cls
echo --- FIX INTERNET PROBLEMS ---
echo.
echo Checking your connection...
call :ping_test
call :net_verdict
if "%ONLINE%%DNSOK%"=="11" goto :internet_ok
echo.
echo Refreshing the DNS cache (the list your PC uses to find websites)...
ipconfig /flushdns >nul 2>&1
call :log "Flushed DNS"
call :ping_test
call :net_verdict
if "%ONLINE%%DNSOK%"=="11" goto :internet_fixed
echo.
if "%ONLINE%"=="0" echo First check that Wi-Fi is on or the cable is plugged in, and restart your router.
echo A deeper network reset can also help. It needs administrator
echo permission and a restart afterwards.
choice /c YN /m "Do the deeper reset now"
if errorlevel 2 goto :internet_end
call :require_admin
if errorlevel 1 goto :menu
call :restore_point
echo Resetting network settings...
netsh winsock reset >nul 2>&1
netsh int ip reset >nul 2>&1
ipconfig /release >nul 2>&1
ipconfig /renew >nul 2>&1
call :log "Network reset performed"
echo.
echo Done. Please RESTART your PC, then test your internet again.
goto :internet_end
:internet_ok
echo.
echo Nothing to fix - your internet is working.
echo If only one website fails, try restarting your browser.
goto :internet_end
:internet_fixed
echo.
echo Fixed! Refreshing the DNS cache solved the problem.
:internet_end
echo.
pause
goto :menu

rem ---------------------------------------------------------------
:cleanup
cls
echo --- FREE UP SPACE ---
echo.
echo This only clears temporary files. Your documents, photos
echo and other personal files are never touched.
echo.
call :getfree
set "BEFORE=%FREE%"
echo Free space on your system drive now: %BEFORE% GB
echo.
choice /c YN /m "Clear temporary files"
if errorlevel 2 goto :menu
echo.
echo Cleaning, please wait...
call :cleantemp
call :getfree
echo.
echo Free space before: %BEFORE% GB
echo Free space after:  %FREE% GB
echo.
echo Done. Temporary files are cleared.
echo.
pause
goto :menu

rem ---------------------------------------------------------------
:health
cls
echo --- PC HEALTH REPORT ---
echo.
echo Collecting information, please wait...
call :do_report
echo.
echo HOW YOUR PC LOOKS:
type "%GLANCE%"
echo.
echo A full report was saved to your Desktop:
echo %REPORT%
echo You can send this file to your IT person.
echo.
start "" notepad "%REPORT%"
pause
goto :menu

rem ---------------------------------------------------------------
:sfc
cls
echo --- CHECK AND REPAIR WINDOWS FILES ---
echo.
echo This scans Windows system files and repairs any damage.
echo It can take 10 to 20 minutes. Please do not close the window.
echo.
choice /c YN /m "Start the scan"
if errorlevel 2 goto :menu
call :require_admin
if errorlevel 1 goto :menu
call :restore_point
call :log "Started SFC scan"
echo.
sfc /scannow
call :log "SFC scan finished"
echo.
echo ----------------------------------------------
echo What the result above means:
echo  - "did not find any integrity violations": your Windows files are healthy.
echo  - "found corrupt files and successfully repaired them": fixed. Restart your PC.
echo  - "found corrupt files but was unable to fix some": restart, run this
echo    again, and if it still fails send a health report to your IT person.
echo ----------------------------------------------
echo.
pause
goto :menu

rem ---------------------------------------------------------------
:printer
cls
echo --- FIX PRINTER PROBLEMS ---
echo.
echo Use this when documents are stuck in the print queue or
echo the printer will not respond.
echo.
echo This cancels ALL documents currently waiting to print.
echo.
choice /c YN /m "Continue"
if errorlevel 2 goto :menu
call :require_admin
if errorlevel 1 goto :menu
call :fix_printer
echo.
echo Done. The print queue is cleared and the print service restarted.
echo Now try printing again. If it still fails, restart the printer.
echo.
pause
goto :menu

rem ---------------------------------------------------------------
:winupdate
cls
echo --- RESET WINDOWS UPDATE ---
echo.
echo Use this when Windows Update is stuck, fails, or shows errors.
echo It resets the update components. Your files and settings are safe.
echo It can take a minute or two, and you must restart afterwards.
echo.
choice /c YN /m "Continue"
if errorlevel 2 goto :menu
call :require_admin
if errorlevel 1 goto :menu
call :restore_point
echo.
echo Resetting Windows Update, please wait...
call :reset_update
echo.
echo Done. Please RESTART your PC, then open Windows Update
echo and click "Check for updates".
echo.
pause
goto :menu

rem ---------------------------------------------------------------
:quit
endlocal
exit /b 0

rem ======================= Command-line modes =======================
:cli_auto
call :auto_core
type "%SUM%"
echo.
type "%GLANCE%"
exit /b 0

:cli_report
call :do_report
echo Report saved to %REPORT%
exit /b 0

:cli_dns
ipconfig /flushdns
call :log "Flushed DNS (switch)"
exit /b 0

:cli_printer
call :isadmin
if not "%ISADMIN%"=="1" (echo This switch needs an elevated Command Prompt. & exit /b 1)
call :fix_printer
echo Print queue cleared.
exit /b 0

:cli_update
call :isadmin
if not "%ISADMIN%"=="1" (echo This switch needs an elevated Command Prompt. & exit /b 1)
call :reset_update
echo Windows Update reset. Restart the PC.
exit /b 0

:cli_clean
call :cleantemp
echo Temporary files cleared.
exit /b 0

:help
echo.
echo PC Quick Fix Toolkit v%VERSION%
echo.
echo Usage:  PC-Quick-Fix-Toolkit.cmd [switch]
echo.
echo   (no switch)  Open the menu
echo   /auto        Check and fix common problems automatically
echo   /report      Save a PC health report to the Desktop
echo   /flushdns    Flush the DNS cache
echo   /cleantemp   Clear temporary files
echo   /fixprinter  Clear print queue and restart spooler (admin)
echo   /resetupdate Reset Windows Update components (admin)
echo   /help        Show this help
echo.
exit /b 0

rem ======================= Helper routines ==========================
:log
>>"%LOG%" echo %date% %time% - %~1
exit /b 0

:isadmin
set "ISADMIN=0"
fltmc >nul 2>&1 && set "ISADMIN=1"
exit /b 0

:require_admin
call :isadmin
if "%ISADMIN%"=="1" exit /b 0
echo.
if defined ADMINMSG (echo %ADMINMSG%) else (echo This step needs administrator permission.)
choice /c YN /m "Restart this toolkit as administrator now"
if errorlevel 2 exit /b 1
powershell -NoProfile -Command "Start-Process -FilePath '%SELF%' -Verb RunAs"
exit

:restore_point
echo.
echo Creating a safety restore point so changes can be undone...
powershell -NoProfile -Command "try { Checkpoint-Computer -Description 'PC Quick Fix Toolkit' -RestorePointType MODIFY_SETTINGS -ErrorAction Stop -WarningAction Stop; exit 0 } catch { exit 1 }" >nul 2>&1
if errorlevel 1 goto :rp_fail
echo Restore point created. To undo later: open the Start menu, type
echo "Create a restore point", then choose System Restore.
call :log "Restore point created"
exit /b 0
:rp_fail
echo No new restore point was created. Windows allows only one per day
echo by default, or System Protection may be turned off. Continuing.
call :log "Restore point not created"
exit /b 0

:ping_test
set "ONLINE=0"
set "DNSOK=0"
ping -n 2 -w 2000 8.8.8.8 >nul 2>&1 && set "ONLINE=1"
powershell -NoProfile -Command "try { [void][System.Net.Dns]::GetHostAddresses('www.microsoft.com'); exit 0 } catch { exit 1 }" >nul 2>&1 && set "DNSOK=1"
if "%DNSOK%"=="1" set "ONLINE=1"
exit /b 0

:net_verdict
if "%ONLINE%%DNSOK%"=="11" echo   Result: Your internet is working.
if "%ONLINE%%DNSOK%"=="10" echo   Result: You are connected, but website names are not being found.
if "%ONLINE%"=="0" echo   Result: Your PC cannot reach the internet.
exit /b 0

:getfree
set "FREE=?"
for /f %%a in ('powershell -NoProfile -Command "[math]::Round((Get-PSDrive %SystemDrive:~0,1%).Free/1GB,2)"') do set "FREE=%%a"
exit /b 0

:cleantemp
call :log "Cleaning temp files"
del /f /s /q "%TEMP%\*" >nul 2>&1
for /d %%d in ("%TEMP%\*") do rd /s /q "%%d" >nul 2>&1
call :isadmin
if "%ISADMIN%"=="1" del /f /s /q "%SystemRoot%\Temp\*" >nul 2>&1
exit /b 0

:fix_printer
call :log "Fixing printer spooler"
net stop spooler /y >nul 2>&1
del /f /q "%SystemRoot%\System32\spool\PRINTERS\*" >nul 2>&1
net start spooler >nul 2>&1
exit /b 0

:reset_update
call :log "Resetting Windows Update"
net stop wuauserv /y >nul 2>&1
net stop bits /y >nul 2>&1
net stop cryptsvc /y >nul 2>&1
net stop msiserver /y >nul 2>&1
if exist "%SystemRoot%\SoftwareDistribution.old" rd /s /q "%SystemRoot%\SoftwareDistribution.old" >nul 2>&1
if exist "%SystemRoot%\System32\catroot2.old" rd /s /q "%SystemRoot%\System32\catroot2.old" >nul 2>&1
if exist "%SystemRoot%\SoftwareDistribution" ren "%SystemRoot%\SoftwareDistribution" SoftwareDistribution.old >nul 2>&1
if exist "%SystemRoot%\System32\catroot2" ren "%SystemRoot%\System32\catroot2" catroot2.old >nul 2>&1
net start cryptsvc >nul 2>&1
net start bits >nul 2>&1
net start wuauserv >nul 2>&1
net start msiserver >nul 2>&1
exit /b 0

rem ---- Plain-English "at a glance" verdicts (prints to screen) ----
:glance
call :ping_test
if "%ONLINE%%DNSOK%"=="11" (echo [OK] Internet is working.) else (echo [!] Internet problem detected. Use option 2 to fix it.)
powershell -NoProfile -Command "$free=(Get-PSDrive %SystemDrive:~0,1%).Free/1GB; if ($free -lt 10) {'[!] Disk space is LOW: only '+[math]::Round($free,1)+' GB free. Use option 3 to free up space.'} else {'[OK] Disk space is fine: '+[math]::Round($free,1)+' GB free.'}"
powershell -NoProfile -Command "$o=Get-CimInstance Win32_OperatingSystem; $f=$o.FreePhysicalMemory/$o.TotalVisibleMemorySize; if ($f -lt 0.1) {'[!] Memory is running low. Close unused programs or restart.'} else {'[OK] Memory is fine.'}; $h=[math]::Floor(((Get-Date)-$o.LastBootUpTime).TotalHours); if ($h -gt 168) {'[!] Not restarted for '+[math]::Floor($h/24)+' days. A restart often fixes slowness.'} else {'[OK] Last restart was '+$h+' hours ago.'}"
exit /b 0

rem ---- Automatic fix: does the work, writes results to %SUM% ----
:auto_core
type nul >"%SUM%"
call :log "Auto fix started"
echo [1/4] Checking your internet...
call :ping_test
if "%ONLINE%%DNSOK%"=="11" goto :ac_net_ok
ipconfig /flushdns >nul 2>&1
call :ping_test
if "%ONLINE%%DNSOK%"=="11" goto :ac_net_fixed
>>"%SUM%" echo [!] Internet is NOT working. Check Wi-Fi or the cable and restart your router. Then try option 2.
goto :ac_space
:ac_net_ok
>>"%SUM%" echo [OK] Internet is working.
goto :ac_space
:ac_net_fixed
>>"%SUM%" echo [FIXED] Website lookup was failing. Refreshing the DNS cache solved it.
:ac_space
echo [2/4] Clearing temporary files...
call :getfree
set "BEFORE=%FREE%"
call :cleantemp
call :getfree
>>"%SUM%" echo [DONE] Cleared temporary files. Free space: %BEFORE% GB before, %FREE% GB now.
echo [3/4] Checking the printing service...
sc query spooler | find "RUNNING" >nul 2>&1
if not errorlevel 1 goto :ac_prn_running
net start spooler >nul 2>&1
sc query spooler | find "RUNNING" >nul 2>&1
if not errorlevel 1 goto :ac_prn_fixed
>>"%SUM%" echo [!] The print service is not running and I could not start it. Run this toolkit as administrator and try again.
goto :ac_jobs
:ac_prn_fixed
>>"%SUM%" echo [FIXED] The print service had stopped. I started it again.
goto :ac_jobs
:ac_prn_running
>>"%SUM%" echo [OK] The print service is running.
:ac_jobs
set "JOBS=0"
for /f %%n in ('dir /b "%SystemRoot%\System32\spool\PRINTERS" 2^>nul ^| find /c /v ""') do set "JOBS=%%n"
if not "%JOBS%"=="0" >>"%SUM%" echo [!] %JOBS% print job files look stuck in the queue. Use option 6 to clear them.
echo [4/4] Checking your PC's health...
call :glance >"%GLANCE%"
call :log "Auto fix finished"
exit /b 0

rem ---- Health report ----
:do_report
call :log "Created health report"
call :glance >"%GLANCE%"
>"%REPORT%" echo ===== PC HEALTH REPORT =====
>>"%REPORT%" echo Created: %date% %time%
>>"%REPORT%" echo Computer: %COMPUTERNAME%
>>"%REPORT%" echo User: %USERNAME%
>>"%REPORT%" echo.
>>"%REPORT%" echo ----- At a glance -----
type "%GLANCE%" >>"%REPORT%"
>>"%REPORT%" echo.
>>"%REPORT%" echo ----- Windows and memory -----
powershell -NoProfile -Command "$o=Get-CimInstance Win32_OperatingSystem; 'Windows: '+$o.Caption+' (build '+$o.BuildNumber+')'; 'Last restart: '+$o.LastBootUpTime; 'Uptime (hours): '+[math]::Floor(((Get-Date)-$o.LastBootUpTime).TotalHours); 'RAM total (GB): '+[math]::Round($o.TotalVisibleMemorySize/1MB,1); 'RAM free (GB): '+[math]::Round($o.FreePhysicalMemory/1MB,1)" >>"%REPORT%" 2>&1
>>"%REPORT%" echo.
>>"%REPORT%" echo ----- Processor -----
powershell -NoProfile -Command "Get-CimInstance Win32_Processor | Select-Object -ExpandProperty Name" >>"%REPORT%" 2>&1
>>"%REPORT%" echo.
>>"%REPORT%" echo ----- Disk space -----
powershell -NoProfile -Command "Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object { $_.DeviceID+' '+[math]::Round($_.FreeSpace/1GB,1)+' GB free of '+[math]::Round($_.Size/1GB,1)+' GB' }" >>"%REPORT%" 2>&1
>>"%REPORT%" echo.
>>"%REPORT%" echo ----- Network -----
ipconfig /all | findstr /i /c:"Description" /c:"IPv4" /c:"Default Gateway" /c:"DNS Servers" >>"%REPORT%"
>>"%REPORT%" echo.
>>"%REPORT%" echo ===== END OF REPORT =====
exit /b 0
