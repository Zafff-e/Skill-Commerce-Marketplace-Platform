@echo off
echo ========================================================
echo   Kaarigor Frontend - Unified Production & Dev Server
echo ========================================================
echo.
echo Choose an option:
echo   [1] Start Unified Live Server (Both Customer + Provider at http://localhost:5173)
echo   [2] Start React Customer Portal Dev Server (http://localhost:5174)
echo   [3] Start Angular Provider Portal Dev Server (http://localhost:4200)
echo   [4] Build Everything
echo.
set /p opt="Enter choice (1-4, default 1): "
if "%opt%"=="" set opt=1

if "%opt%"=="1" (
    echo.
    echo Serving Unified Portals at http://localhost:5173...
    echo Customer App: http://localhost:5173/
    echo Provider App: http://localhost:5173/provider/
    echo.
    npx -y serve -s dist -l 5173
    goto end
)

if "%opt%"=="2" (
    echo.
    echo Starting React Customer Portal Dev Server...
    cd react-customer-portal
    node node_modules/vite/bin/vite.js --port 5174 --host
    goto end
)

if "%opt%"=="3" (
    echo.
    echo Starting Angular Provider Portal Dev Server...
    cd angular-provider-portal
    node node_modules/@angular/cli/bin/ng.js serve --port 4200 --host 0.0.0.0
    goto end
)

if "%opt%"=="4" (
    echo.
    echo Building React Customer Portal...
    cd react-customer-portal
    node node_modules/vite/bin/vite.js build
    cd ..
    echo.
    echo Building Angular Provider Portal...
    cd angular-provider-portal
    node node_modules/@angular/cli/bin/ng.js build
    cd ..
    xcopy /E /I /Y angular-provider-portal\dist\browser\* dist\provider\
    echo.
    echo Build complete!
    goto end
)

:end
pause

