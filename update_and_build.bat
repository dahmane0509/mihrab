@echo off
chcp 65001 >nul
title تحديث وبناء تطبيق محراب - Mihrab App Updater

echo ========================================================
echo   1. جاري تطبيق الإصلاحات البرمجية والصوتية على C:\mihrab
echo ========================================================
powershell -ExecutionPolicy Bypass -File "%~dp0apply_fixes.ps1"
if %errorlevel% neq 0 (
    echo حدث خطأ أثناء تطبيق الإصلاحات!
    pause
    exit /b %errorlevel%
)

cd /d C:\mihrab

echo.
echo ========================================================
echo   2. جاري تنظيف المشروع وبناء ملف الـ APK الجديد (Release)
echo ========================================================
call flutter clean
call flutter pub get
call flutter build apk --release

echo.
echo ========================================================
echo   3. جاري رفع التحديثات إلى منصة GitHub (dahmane0509/mihrab)
echo ========================================================
git status
git add .
git commit -m "Release v1.0.1: Fix Adhan notifications (res/raw/athan), Quran reciters URLs, audio assets, and live radio"
git tag -f v1.0.1
git push origin main --tags

echo.
echo ========================================================
echo   تم الانتهاء بنجاح!
echo   ملف التطبيق الجديد جاهز في المسار:
echo   C:\mihrab\build\app\outputs\flutter-apk\app-release.apk
echo ========================================================
explorer "C:\mihrab\build\app\outputs\flutter-apk"
pause
