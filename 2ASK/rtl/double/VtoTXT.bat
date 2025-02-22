@echo off
setlocal enabledelayedexpansion

echo 正在转换 .v 文件为 .txt ...
for %%f in (*.v) do (
    set "filename=%%~nf"
    ren "%%f" "!filename!.txt"
)

echo 转换完成！
echo.
dir /b *.txt
echo.
pause