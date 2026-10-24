$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ProjectDir = "C:\mihrab"
if (-not (Test-Path "$ProjectDir\pubspec.yaml")) {
    $ProjectDir = $PSScriptRoot
}

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  تحديث وإصلاح مشروع مِحْراب في: $ProjectDir" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# 1. نسخ ملفات res/raw و keep.xml و assets/audio
$RawDest = Join-Path $ProjectDir "android\app\src\main\res\raw"
New-Item -ItemType Directory -Force -Path $RawDest | Out-Null
Copy-Item -Force "$PSScriptRoot\android\app\src\main\res\raw\*" $RawDest

$AudioDest = Join-Path $ProjectDir "assets\audio"
New-Item -ItemType Directory -Force -Path $AudioDest | Out-Null
Copy-Item -Force "$PSScriptRoot\assets\audio\*" $AudioDest
Write-Host "[1/6] تم نسخ ملفات الصوت المصححة وملف res/raw/athan.mp3 و keep.xml بنجاح." -ForegroundColor Green

# 2. تصحيح روابط القراء الـ 12 في quran_audio_reciters_service.dart
$RecitersFile = Join-Path $ProjectDir "lib\services\quran_audio_reciters_service.dart"
if (Test-Path $RecitersFile) {
    $content = Get-Content $RecitersFile -Raw -Encoding UTF8
    $replacements = @{
        "https://cdn.mp3quran.net/audio/abdelaziz-sheim/r1"     = "https://server10.mp3quran.net/sheim"
        "https://cdn.mp3quran.net/audio/abdulbasit-abdulsamad/r3" = "https://server7.mp3quran.net/basit"
        "https://cdn.mp3quran.net/audio/abubakr-shatri/r1"      = "https://server11.mp3quran.net/shatri"
        "https://cdn.mp3quran.net/audio/ali-hudhaifi/r1"        = "https://server9.mp3quran.net/hthfi"
        "https://cdn.mp3quran.net/audio/islam-sobhi/r1"         = "https://server14.mp3quran.net/islam/Rewayat-Hafs-A-n-Assem"
        "https://cdn.mp3quran.net/audio/laayoun-kouchi/r1"      = "https://server11.mp3quran.net/koshi"
        "https://cdn.mp3quran.net/audio/maher-muaiqly/r1"       = "https://server12.mp3quran.net/maher"
        "https://cdn.mp3quran.net/audio/mahmoud-husary/r3"      = "https://server13.mp3quran.net/husr"
        "https://cdn.mp3quran.net/audio/muhammad-minshawi/r1"   = "https://server10.mp3quran.net/minsh"
        "https://cdn.mp3quran.net/audio/omar-kazabri/r1"        = "https://server9.mp3quran.net/omar_warsh"
        "https://cdn.mp3quran.net/audio/saad-ghamdi/r1"         = "https://server7.mp3quran.net/s_gmd"
        "https://cdn.mp3quran.net/audio/yassen-jazairi/r1"      = "https://server11.mp3quran.net/qari"
    }
    foreach ($k in $replacements.Keys) {
        $content = $content.Replace($k, $replacements[$k])
    }
    Set-Content -Path $RecitersFile -Value $content -Encoding UTF8
    Write-Host "[2/6] تم تصحيح روابط القراء الـ 12 الافتراضيين في quran_audio_reciters_service.dart." -ForegroundColor Green
}

# 3. تصحيح روابط الأذان الـ 7 ومسار AssetSource في adhan_audio_service.dart و verse_audio_service.dart
$AdhanFile = Join-Path $ProjectDir "lib\services\adhan_audio_service.dart"
if (Test-Path $AdhanFile) {
    $content = Get-Content $AdhanFile -Raw -Encoding UTF8
    $adhanReplacements = @{
        "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Abu_Dhabi_-_Sheikh_Zayed_Mosque.mp3" = "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Dubai_UAE_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%AF%D8%A8%D9%8A_%D8%A7%D9%84%D8%A5%D9%85%D8%A7%D8%B1%D8%A7%D8%AA).mp3"
        "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Syria_-_Umayyad_Mosque.mp3"          = "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Syria_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%B3%D9%88%D8%B1%D9%8A%D8%A7).mp3"
        "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Algeria_-_Tlemcen.mp3"               = "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Riad_Al_Djazairi_-_Algeria_(%D8%B1%D9%8A%D8%A7%D8%B6_%D8%A7%D9%84%D8%AC%D8%B2%D8%A7%D8%A6%D8%B1%D9%8A_-_%D8%A7%D9%84%D8%AC%D8%B2%D8%A7%D8%A6%D8%B1).mp3"
        "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Turkey_-_Blue_Mosque.mp3"            = "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Turkey_1_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%AA%D8%B1%D9%83%D9%8A%D8%A7).mp3"
        "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Tunisia_-_Ez-Zitouna_Mosque.mp3"     = "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Tunisia_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%AA%D9%88%D9%86%D8%B3).mp3"
        "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Morocco_-_Al_Qarawiyyin.mp3"         = "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Kamal_Muhammad_Al_Marush_2_-_Morocco_(%D9%83%D9%85%D8%A7%D9%84_%D9%85%D8%AD%D9%85%D8%AF_%D8%A7%D9%84%D9%85%D8%B1%D8%B9%D9%88%D8%B4_-_%D8%A7%D9%84%D9%85%D8%BA%D8%B1%D8%A8).mp3"
        "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Algeria_-_Constantine.mp3"           = "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Haj_Sulaiman_Mukhtar_-_Algeria_(%D8%AD%D8%A7%D8%AC_%D8%B3%D9%84%D9%8A%D9%85%D8%A7%D9%86_%D9%85%D8%AE%D8%AA%D8%A7%D8%B1_-_%D8%A7%D9%84%D8%AC%D8%B2%D8%A7%D8%A6%D8%B1).mp3"
        "AssetSource('assets/audio/"                                                                  = "AssetSource('audio/"
        'AssetSource("assets/audio/'                                                                  = 'AssetSource("audio/'
    }
    foreach ($k in $adhanReplacements.Keys) {
        $content = $content.Replace($k, $adhanReplacements[$k])
    }
    Set-Content -Path $AdhanFile -Value $content -Encoding UTF8
    Write-Host "[3/6] تم تصحيح روابط الأذان ومسار AssetSource في adhan_audio_service.dart." -ForegroundColor Green
}

$VerseFile = Join-Path $ProjectDir "lib\services\verse_audio_service.dart"
if (Test-Path $VerseFile) {
    $content = Get-Content $VerseFile -Raw -Encoding UTF8
    $content = $content.Replace("AssetSource('assets/audio/", "AssetSource('audio/").Replace('AssetSource("assets/audio/', 'AssetSource("audio/')
    Set-Content -Path $VerseFile -Value $content -Encoding UTF8
}

# 4. تصحيح روابط البث المباشر للراديو في live_broadcast_screen.dart
$LiveFile = Join-Path $ProjectDir "lib\screens\live_broadcast_screen.dart"
if (Test-Path $LiveFile) {
    $content = Get-Content $LiveFile -Raw -Encoding UTF8
    $content = $content.Replace("https://my.radioalgerie.dz/coran", "https://qurango.net/radio/salma")
    $content = $content.Replace("https://mp3quran.net/ar/radio", "https://qurango.net/radio/mix")
    Set-Content -Path $LiveFile -Value $content -Encoding UTF8
    Write-Host "[4/6] تم تصحيح روابط البث الإذاعي في live_broadcast_screen.dart." -ForegroundColor Green
}

# 5. تحديث AndroidManifest.xml (تفعيل extractNativeLibs="true" وإضافة mailto و geo)
$ManifestFile = Join-Path $ProjectDir "android\app\src\main\AndroidManifest.xml"
if (Test-Path $ManifestFile) {
    $mContent = Get-Content $ManifestFile -Raw -Encoding UTF8
    if ($mContent -notmatch 'extractNativeLibs') {
        $mContent = $mContent.Replace('<application', '<application android:extractNativeLibs="true"')
    } else {
        $mContent = $mContent.Replace('android:extractNativeLibs="false"', 'android:extractNativeLibs="true"')
    }
    Set-Content -Path $ManifestFile -Value $mContent -Encoding UTF8
    Write-Host "[5/6] تم تحديث AndroidManifest.xml (extractNativeLibs=true)." -ForegroundColor Green
}

# 6. رفع رقم الإصدار في pubspec.yaml إلى 1.0.1+2 ليتعرف عليه نظام التحديثات في GitHub
$PubspecFile = Join-Path $ProjectDir "pubspec.yaml"
if (Test-Path $PubspecFile) {
    $pContent = Get-Content $PubspecFile -Raw -Encoding UTF8
    $pContent = $pContent -replace "version:\s*1\.0\.0\+1", "version: 1.0.1+2"
    Set-Content -Path $PubspecFile -Value $pContent -Encoding UTF8
    Write-Host "[6/6] تم تحديث رقم الإصدار في pubspec.yaml إلى 1.0.1+2." -ForegroundColor Green
}


# 7. تصحيح اسم حساب GitHub في app_update_service.dart من amir0509 إلى dahmane0509
$UpdateFile = Join-Path $ProjectDir "lib\services\app_update_service.dart"
if (Test-Path $UpdateFile) {
    $uContent = Get-Content $UpdateFile -Raw -Encoding UTF8
    $uContent = $uContent.Replace("amir0509/mihrab", "dahmane0509/mihrab")
    Set-Content -Path $UpdateFile -Value $uContent -Encoding UTF8
    Write-Host "[7/7] تم تصحيح رابط مستودع GitHub إلى dahmane0509/mihrab في app_update_service.dart." -ForegroundColor Green
}

Write-Host "`nاكتمل تطبيق جميع الإصلاحات بنجاح!" -ForegroundColor Yellow
