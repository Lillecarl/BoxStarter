@echo off

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

echo Disabling hibernation
powercfg -h off
echo Disabling sleepmode AC timer
powercfg -x standby-timeout-ac 0
echo Setting ExecutionPolicy
@powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Force"
echo Installing Chocolatey
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
choco feature enable -n allowGlobalConfirmation
echo Installing BoxStarter
cinst Boxstarter
echo Running BoxStarter
@powershell -NoProfile -ExecutionPolicy Bypass -Command "Import-Module Boxstarter.Chocolatey;$boxcred = Get-Credential; Install-BoxstarterPackage -Credential $boxcred -PackageName https://raw.githubusercontent.com/Lillecarl/BoxStarter/master/boxstarter"
