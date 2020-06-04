@echo off & color 0A
set varDate=%date:~0,10%
set logPath="..\exe\log\fbuild%varDate:/=%.log"
echo.  | tee -n %logPath%
echo %date:~0,10% %time:~0,-3% ------------------------------------------------------------------------------ | tee -a %logPath%
call ".\fbuild_gameserver.bat" | tee -a %logPath%
:: start notepad .\exe\log\fbuild.log
