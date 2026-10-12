@echo off
title Quivo Support Ticket Reader & Console
echo ====================================================
echo   INICIANDO QUIVO SUPPORT TICKET READER
echo ====================================================
echo.
echo 1. Comprobando Node.js...
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [!] Node.js no encontrado. Abriendo pagina directamente en el navegador...
    start "" "index.html"
    pause
    exit /b
)

echo [OK] Node.js detectado.
echo 2. Iniciando servidor local en el puerto 4000...
echo.
start "" "http://localhost:4000"
node server.js
pause
