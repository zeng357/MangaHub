@echo off
setlocal
cd /d "%~dp0"

set "PY=python"
if exist "C:\Users\15916\AppData\Local\Programs\Python\Python310\python.exe" set "PY=C:\Users\15916\AppData\Local\Programs\Python\Python310\python.exe"

echo ================================================
echo  Manga Downloader - One-Click Launcher
echo  cwd: %CD%
echo ================================================
echo.

echo [1/3] Python used: %PY%
"%PY%" --version
if errorlevel 1 goto fail_nopy

echo.
echo [2/3] Checking system socket (network) ...
"%PY%" -c "import socket; s=socket.socket(); s.close(); print('SOCKET-CREATE-OK')"
if errorlevel 1 goto fail_socket
echo  Socket OK.

echo.
echo [2b] Checking required modules ...
"%PY%" -c "import aiohttp,aiofiles,execjs,requests_file,lxml,DrissionPage,Crypto; print('MODULES-OK')"
if errorlevel 1 goto fail_modules
echo  Modules OK.

echo.
echo [3/3] Starting GUI ...
echo  If the GUI opens, keep this console open. Close the GUI to quit.
echo  Errors (if any) are written to startup_error.txt
"%PY%" gui.py 2> "startup_error.txt"
if errorlevel 1 goto fail_gui

echo.
echo  GUI closed normally.
exit /b 0

:fail_nopy
echo.
echo  !! Python not found: %PY%
goto fail_end

:fail_socket
echo.
echo  !! SOCKET-CREATE-FAILED (WinError 10038)
echo  !! This machine cannot create sockets right now.
echo  !! Browser / download functions will NOT work in this state.
echo  !! Suggested: reboot the PC, or run as admin:
echo  !!     netsh winsock reset
echo  !! then reboot again.
goto fail_end

:fail_modules
echo.
echo  !! Some required Python modules are missing.
"%PY%" -c "import aiohttp" 2>&1 | findstr /C:"No module"
"%PY%" -c "import aiofiles" 2>&1 | findstr /C:"No module"
"%PY%" -c "import execjs" 2>&1 | findstr /C:"No module"
"%PY%" -c "import requests_file" 2>&1 | findstr /C:"No module"
"%PY%" -c "import lxml" 2>&1 | findstr /C:"No module"
"%PY%" -c "import DrissionPage" 2>&1 | findstr /C:"No module"
"%PY%" -c "import Crypto" 2>&1 | findstr /C:"No module"
goto fail_end

:fail_gui
echo.
echo  !! GUI exited with an error. Last lines of startup_error.txt:
type "startup_error.txt"
goto fail_end

:fail_end
echo.
echo ============ LAUNCH FAILED ============
echo  Please copy or screenshot all text above and send it to the assistant.
pause
exit /b 1