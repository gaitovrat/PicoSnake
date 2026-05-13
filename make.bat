@echo off
setlocal enabledelayedexpansion

set "CART_DIR=%USERPROFILE%\AppData\Roaming\pico-8\carts"
set "CART_FILE=!CART_DIR!\snake.p8"

if "%1"=="" goto install
if /i "%1"=="install" goto install
if /i "%1"=="clean" goto clean
echo Usage: make.bat [install^|clean]
exit /b 1

:install
if not exist "!CART_DIR!" mkdir "!CART_DIR!"
echo Copying %CD%\snake.p8 to !CART_FILE!
copy /Y "%CD%\snake.p8" "!CART_FILE!"
goto end

:clean
if exist "!CART_FILE!" (
    echo Removing cart...
    del "!CART_FILE!"
) else (
    echo Cart file not found, nothing to clean.
)
goto end

:end
endlocal
