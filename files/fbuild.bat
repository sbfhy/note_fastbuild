echo off & color 0A
cd idipserver
fbuild.exe -config idipserver.bff -dist
cd ../
cd dbserver
fbuild.exe -config dbserver.bff -dist
cd ../
cd gateserver
fbuild.exe -config gateserver.bff -dist
cd ../
cd audioserver
fbuild.exe -config audioserver.bff -dist
cd ../
cd controlserver
fbuild.exe -config controlserver.bff -dist
cd ../
cd gameserver
fbuild.exe -config gameserver.bff -dist
cd ../
cd masterserver
fbuild.exe -config masterserver.bff -dist
cd ../
pause