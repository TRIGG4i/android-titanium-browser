#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

VERSION="$(grep -m1 -oE '[0-9]+(\.[0-9]+){3}' "$SCRIPT_DIR/vanadium/args.gn")"
CHROMIUM_SOURCE="https://chromium.googlesource.com/chromium/src.git"
CHROMIUM_DIR="$SCRIPT_DIR/chromium"
SOURCE_DIR="$CHROMIUM_DIR/src"
PATCH_WORK_DIR="$CHROMIUM_DIR/vanadium-patches"
ARTIFACT_DIR="$SCRIPT_DIR/artifacts"
EXPECTED_VANADIUM_COMMIT="13c840a88df07096553710c9459b3e2ecd278235"

export VERSION CHROMIUM_SOURCE DEBIAN_FRONTEND=noninteractive

if [[ -z "$VERSION" ]]; then
    echo "Unable to determine Chromium version from vanadium/args.gn" >&2
    exit 1
fi

actual_vanadium_commit="$(git -C "$SCRIPT_DIR/vanadium" rev-parse HEAD)"
if [[ "$actual_vanadium_commit" != "$EXPECTED_VANADIUM_COMMIT" ]]; then
    echo "Vanadium commit mismatch: expected $EXPECTED_VANADIUM_COMMIT, got $actual_vanadium_commit" >&2
    exit 1
fi

sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    ca-certificates curl file git imagemagick libgcc-s1:i386 librsvg2-bin \
    lsb-release python3 python3-pillow

if [[ ! -d "$SCRIPT_DIR/depot_tools/.git" ]]; then
    git clone --depth 1 https://chromium.googlesource.com/chromium/tools/depot_tools.git \
        "$SCRIPT_DIR/depot_tools"
fi
export PATH="$SCRIPT_DIR/depot_tools:$PATH"

mkdir -p "$SOURCE_DIR" "$ARTIFACT_DIR"
cd "$SOURCE_DIR"

if [[ ! -d .git ]]; then
    git init
    git remote add origin "$CHROMIUM_SOURCE"
fi
git fetch --depth 1 origin "refs/tags/$VERSION:refs/tags/$VERSION"
git checkout --detach --force "refs/tags/$VERSION"
cp "$SCRIPT_DIR/.gclient" "$CHROMIUM_DIR/.gclient"

# Work from an ephemeral copy so the pinned Vanadium submodule stays pristine.
rm -rf -- "$PATCH_WORK_DIR"
cp -a "$SCRIPT_DIR/vanadium/patches" "$PATCH_WORK_DIR"

remove_patch_pattern() {
    find "$PATCH_WORK_DIR" -maxdepth 1 -type f -name "$1" -print -delete
}

# Chromium public APK does not use the Trichrome, language-pack, component,
# PDF or desktop toolbar patches removed by the upstream Titanium build.
remove_patch_pattern '*trichrome-apk-build-targets.patch'
remove_patch_pattern '*trichrome-browser-apk-targets.patch'
remove_patch_pattern '*detailed-language*.patch'
remove_patch_pattern '*supported-language*.patch'
remove_patch_pattern '*component-updates.patch'
remove_patch_pattern '*pdf*.patch'
remove_patch_pattern '*PDF*.patch'
remove_patch_pattern '*for-content-public*.patch'
remove_patch_pattern '*toolbar-button*.patch'

replace "$PATCH_WORK_DIR" "VANADIUM" "TITANIUM"
replace "$PATCH_WORK_DIR" "Vanadium" "Titanium"
replace "$PATCH_WORK_DIR" "vanadium" "titanium"
git am --whitespace=nowarn --keep-non-patch "$PATCH_WORK_DIR"/*.patch

gclient sync -D --no-history --nohooks
gclient runhooks
./build/install-build-deps.sh --no-prompt

source "$SCRIPT_DIR/patch.sh"
cp "$SCRIPT_DIR/args.gn" out/Default/args.gn
gn gen out/Default

# The final source build intentionally produces one target and one ABI only.
autoninja -C out/Default chrome_public_apk

mapfile -t apk_candidates < <(find out/Default/apks -maxdepth 1 -type f -name 'ChromePublic*.apk' -print)
if [[ "${#apk_candidates[@]}" -ne 1 ]]; then
    printf 'Expected exactly one ChromePublic APK, found %s\n' "${#apk_candidates[@]}" >&2
    printf '%s\n' "${apk_candidates[@]:-}" >&2
    exit 1
fi

output_apk="$ARTIFACT_DIR/Titanium-Browser-Personal-source-arm64-v8a.apk"
cp "${apk_candidates[0]}" "$output_apk"

repo_commit="$(git -C "$SCRIPT_DIR" rev-parse HEAD)"
cat > "$ARTIFACT_DIR/SOURCE_BUILD_METADATA.txt" <<EOF
repository_commit=$repo_commit
chromium_version=$VERSION
vanadium_commit=$actual_vanadium_commit
target_cpu=arm64
target=chrome_public_apk
package=com.trigg4i.titanium.personal
EOF

echo "Source APK created at $output_apk"
