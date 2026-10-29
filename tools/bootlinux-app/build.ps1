$ErrorActionPreference = 'Stop'
$here = (Resolve-Path $PSScriptRoot).Path
$out = Join-Path $here 'out'
$sdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$bt = Join-Path $sdk 'build-tools\37.0.0'
$jar = Join-Path $sdk 'platforms\android-37.1\android.jar'

if (Test-Path $out) { Remove-Item -Recurse -Force $out }
New-Item -ItemType Directory -Force (Join-Path $out 'classes'), (Join-Path $out 'dex') | Out-Null

& (Join-Path $bt 'aapt2.exe') link -o (Join-Path $out 'unsigned.apk') -I $jar `
    --manifest (Join-Path $here 'AndroidManifest.xml') --min-sdk-version 21 --target-sdk-version 34

$srcFile = Join-Path $out 'sources.txt'
(Get-ChildItem -Recurse (Join-Path $here 'src') -Filter '*.java').FullName | Set-Content -Encoding ascii $srcFile
& javac --release 8 -nowarn -cp $jar -d (Join-Path $out 'classes') (Get-Content $srcFile)

$classesFile = Join-Path $out 'classes.txt'
(Get-ChildItem -Recurse (Join-Path $out 'classes') -Filter '*.class').FullName | Set-Content -Encoding ascii $classesFile
& (Join-Path $bt 'd8.bat') --lib $jar --min-api 21 --output (Join-Path $out 'dex') (Get-Content $classesFile)

$apk = Join-Path $out 'unsigned.apk'
$dex = Join-Path $out 'dex\classes.dex'
$zipCode = "import sys,zipfile; apk,dex=sys.argv[1:]; z=zipfile.ZipFile(apk,'a',zipfile.ZIP_DEFLATED); z.write(dex,'classes.dex'); z.close()"
python -c $zipCode $apk $dex
if ($LASTEXITCODE -ne 0) { throw 'failed to add classes.dex to APK' }

$aligned = Join-Path $out 'aligned.apk'
& (Join-Path $bt 'zipalign.exe') -f 4 $apk $aligned
$ks = Join-Path $here 'debug.keystore'
if (!(Test-Path $ks)) {
    & keytool -genkeypair -keystore $ks -alias debug -keyalg RSA -keysize 2048 -validity 10000 `
        -storepass android -keypass android -dname 'CN=Android Debug,O=Android,C=US'
}
$final = Join-Path $out 'bootlinux.apk'
& (Join-Path $bt 'apksigner.bat') sign --ks $ks --ks-pass pass:android --key-pass pass:android `
    --out $final $aligned
& (Join-Path $bt 'apksigner.bat') verify --verbose $final
Get-Item $final | Select-Object FullName, Length
