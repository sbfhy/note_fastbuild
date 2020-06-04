@echo off & color 0A
rem 在这里设置的环境变量只在bat脚本内有效
set FASTBUILD_BROKERAGE_PATH=\\192.168.2.202\share_fastbuild
tasklist | find /i "FBuildWorker.exe.copy" || start /min "" FBuildWorker.exe -cpus=5 -mode=idle