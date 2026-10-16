@echo off
chcp 65001 >nul
title تفريغ خلفية الصور بالذكاء الاصطناعي - محراب

set PYTHON_EXE=%LOCALAPPDATA%\Programs\Python\Python312\python.exe

if "%~1"=="" (
    echo [!] لم يتم تمرير ملف. اسحب وأفلت أي صورة فوق هذا الملف لتفريغها.
    echo.
    echo [*] جاري تشغيل الأداة على الصورة المرفوعة...
    "%PYTHON_EXE%" "%~dp0remove_person_bg.py"
) else (
    echo [*] جاري معالجة الصورة: %~1
    "%PYTHON_EXE%" "%~dp0remove_person_bg.py" "%~1" "%~dpn1_transparent.png" "%~dpn1_transparent_cropped.png"
)

echo.
pause
