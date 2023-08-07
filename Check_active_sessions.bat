@ECHO OFF
REM CALLING SEQUENCE: command[nrpe_nt_check_users]=c:nrpe_ntpluginscheck_user_count.bat warninglevel criticallevel


SETLOCAL ENABLEDELAYEDEXPANSION
SET /a COUNT=0
SET /a WARNING=%1
SET /a CRITICAL=%2
SET CURRENTUSERS=


REM PULL THE NAMES FROM THE QUERY AND APPEND THEM TO THE LIST
FOR /F "TOKENS=1,2,3 DELIMS= " %%I IN ('query session ^| find "rdp-tcp#"') DO (
REM ECHO %%I %%J %%K
SET /a COUNT+=1
IF !COUNT! == 1 (
SET CURRENTUSERS=%%J
) ELSE (
SET CURRENTUSERS=!CURRENTUSERS!,%%J
)
)


REM INTOK = 0
REM INTWARNING = 1
REM INTCRITICAL = 2
REM INTERROR = 3
REM INTUNKNOWN = 3


IF %COUNT% GTR %CRITICAL% (
ECHO Critical! Number of active sessions = %COUNT%, Critical level is: %CRITICAL%^|'Active Users='%COUNT%;%WARNING%;%CRITICAL%

EXIT 2
)
IF %COUNT% GTR %WARNING% (
ECHO Warning! Number of active sessions = %COUNT%, Warning level is: %WARNING%^|'Active Users='%COUNT%;%WARNING%;%CRITICAL%

EXIT 1
)

ECHO Active sessions: %COUNT%, Warning: %WARNING%, Critical: %CRITICAL%, Users: %CURRENTUSERS%^|'Active Users='%COUNT%;%WARNING%;%CRITICAL%

EXIT 0