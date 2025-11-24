@echo off
cd /d "%~dp0"
echo Seeding database with sample videos...
npx ts-node src/seed.ts
pause
