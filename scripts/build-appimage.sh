#!/bin/bash
# Bouwt een AppImage uit de jpackage app-image (build/jpackage/Sparrow).
# Vereist: eerst ./gradlew jpackage (of jpackageImage) uitvoeren.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION=$(grep -m1 "^version = " build.gradle | sed "s/version = '\(.*\)'/\1/")
case "$(uname -m)" in
  x86_64)  ARCH=x86_64;  REL_ARCH=x86_64 ;;
  aarch64) ARCH=aarch64; REL_ARCH=aarch64 ;;
  *) echo "Niet-ondersteunde architectuur: $(uname -m)"; exit 1 ;;
esac

IMAGE_DIR="build/jpackage/Sparrow"
[ -x "$IMAGE_DIR/bin/Sparrow" ] || { echo "Geen app-image gevonden in $IMAGE_DIR — draai eerst ./gradlew jpackage"; exit 1; }

WORK="build/appimage"
APPDIR="$WORK/Sparrow.AppDir"
rm -rf "$WORK"
mkdir -p "$APPDIR/usr"
cp -a "$IMAGE_DIR"/. "$APPDIR/usr/"

cat > "$APPDIR/AppRun" <<'RUN'
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
exec "$HERE/usr/bin/Sparrow" "$@"
RUN
chmod +x "$APPDIR/AppRun"

cp src/main/deploy/package/linux/Sparrow.png "$APPDIR/sparrow.png"
cp src/main/deploy/package/linux/Sparrow.png "$APPDIR/.DirIcon"
sed -e 's|^Exec=.*|Exec=Sparrow %U|' -e 's|^Icon=.*|Icon=sparrow|' \
    src/main/deploy/package/linux/Sparrow.desktop > "$APPDIR/sparrow.desktop"

TOOL="$WORK/appimagetool-$ARCH.AppImage"
curl -fsSL -o "$TOOL" "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-$ARCH.AppImage"
chmod +x "$TOOL"

OUT="build/jpackage/Sparrow-${VERSION}-${REL_ARCH}.AppImage"
ARCH=$ARCH APPIMAGE_EXTRACT_AND_RUN=1 "$TOOL" --no-appstream "$APPDIR" "$OUT"
echo "AppImage klaar: $OUT"
