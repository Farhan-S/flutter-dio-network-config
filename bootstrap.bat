@echo off
echo 📦 Getting dependencies for all packages...
echo.

REM Get dependencies for all packages in packages folder
for /d %%D in (packages\*) do (
    if exist "%%D\pubspec.yaml" (
        echo   ▸ %%~nxD
        cd "%%D"
        dart pub get >nul 2>&1
        if errorlevel 1 (
            echo     ✗ Failed to install dependencies
        ) else (
            echo     ✓ Dependencies installed
        )
        cd ..\..
    )
)

REM Get dependencies for CLI
if exist "cli\pubspec.yaml" (
    echo   ▸ cli
    cd cli
    dart pub get >nul 2>&1
    if errorlevel 1 (
        echo     ✗ Failed to install dependencies
    ) else (
        echo     ✓ Dependencies installed
    )
    cd ..
)

echo.
echo ✨ All packages bootstrapped successfully!
