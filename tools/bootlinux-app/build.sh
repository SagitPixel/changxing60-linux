#!/bin/sh
# 构建 tools/bootlinux-app —— 不依赖 Gradle，只用 SDK 里的 build-tools 和 javac。
#
#   sh tools/bootlinux-app/build.sh
#
# 产物：tools/bootlinux-app/out/bootlinux.apk
#
# 注意：build-tools 和 javac 都是 Windows 程序，Git Bash 的 /d/... 路径它们不认，
# 所以每个路径都过一遍 cygpath -w。
set -eu

w() { cygpath -w "$1" 2>/dev/null || printf '%s' "$1"; }

HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$HERE/out

SDK=${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$LOCALAPPDATA/Android/Sdk}}
BT=$(ls -d "$SDK"/build-tools/*/ 2>/dev/null | sort -V | tail -1)
BT=${BT%/}
JAR=$(ls "$SDK"/platforms/android-*/android.jar 2>/dev/null | sort -V | tail -1)

[ -n "$BT" ]  || { echo "找不到 build-tools，设 ANDROID_HOME 指向 SDK" >&2; exit 1; }
[ -n "$JAR" ] || { echo "找不到 platforms/android-*/android.jar" >&2; exit 1; }

# Windows 上这些是 .exe / .bat，Git Bash 里 d8 那个 Unix 壳脚本跑不起来。
pick() { for c in "$1.exe" "$1.bat" "$1"; do [ -f "$c" ] && { echo "$c"; return; }; done; }
AAPT2=$(pick "$BT/aapt2"); D8=$(pick "$BT/d8")
ALIGN=$(pick "$BT/zipalign"); SIGN=$(pick "$BT/apksigner")

echo "build-tools: $(basename "$BT")"
echo "android.jar: $(basename "$(dirname "$JAR")")"

rm -rf "$OUT"
mkdir -p "$OUT/classes" "$OUT/dex"

# 1. 清单 -> 未签名 APK。这个应用没有 res/，aapt2 只负责编译清单。
"$AAPT2" link \
    -o "$(w "$OUT/unsigned.apk")" \
    -I "$(w "$JAR")" \
    --manifest "$(w "$HERE/AndroidManifest.xml")" \
    --min-sdk-version 21 \
    --target-sdk-version 34

# 2. javac -> .class（release 8，Android 要的字节码版本）
find "$HERE/src" -name '*.java' | while read -r f; do w "$f"; done > "$OUT/sources.txt"
javac --release 8 -nowarn -cp "$(w "$JAR")" \
    -d "$(w "$OUT/classes")" "@$(w "$OUT/sources.txt")"

# 3. .class -> classes.dex
find "$OUT/classes" -name '*.class' | while read -r f; do w "$f"; done > "$OUT/classes.txt"
"$D8" --lib "$(w "$JAR")" --min-api 21 --output "$(w "$OUT/dex")" "@$(w "$OUT/classes.txt")"

# 4. dex 塞进 APK 根目录（Windows 的 Git Bash 没带 zip，用 python 的 zipfile）
python - "$(w "$OUT/unsigned.apk")" "$(w "$OUT/dex/classes.dex")" <<'PY'
import sys, zipfile
apk, dex = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(apk, "a", zipfile.ZIP_DEFLATED) as z:
    z.write(dex, "classes.dex")
PY

# 5. 对齐 + 签名（调试自签证书，装机够用）
[ -f "$HERE/debug.keystore" ] || keytool -genkeypair -keystore "$(w "$HERE/debug.keystore")" \
    -alias debug -keyalg RSA -keysize 2048 -validity 10000 \
    -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US" 2>/dev/null

"$ALIGN" -f 4 "$(w "$OUT/unsigned.apk")" "$(w "$OUT/aligned.apk")"
"$SIGN" sign --ks "$(w "$HERE/debug.keystore")" --ks-pass pass:android \
    --key-pass pass:android --out "$(w "$OUT/bootlinux.apk")" "$(w "$OUT/aligned.apk")"

rm -f "$OUT/unsigned.apk" "$OUT/aligned.apk" "$OUT/sources.txt" "$OUT/classes.txt"
rm -rf "$OUT/classes" "$OUT/dex"

echo
echo "OK  $OUT/bootlinux.apk  ($(wc -c < "$OUT/bootlinux.apk") 字节)"
echo "装：adb install -r tools/bootlinux-app/out/bootlinux.apk"
