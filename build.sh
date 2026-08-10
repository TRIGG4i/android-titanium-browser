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
BUILD_SLICE_SECONDS="${BUILD_SLICE_SECONDS:-15600}"

export VERSION CHROMIUM_SOURCE DEBIAN_FRONTEND=noninteractive
export GIT_COMMITTER_NAME="Titanium Personal Builder"
export GIT_COMMITTER_EMAIL="titanium-personal-builder@users.noreply.github.com"

if [[ -z "$VERSION" ]]; then
    echo "Unable to determine Chromium version from vanadium/args.gn" >&2
    exit 1
fi

actual_vanadium_commit="$(git -C "$SCRIPT_DIR/vanadium" rev-parse HEAD)"
if [[ "$actual_vanadium_commit" != "$EXPECTED_VANADIUM_COMMIT" ]]; then
    echo "Vanadium commit mismatch: expected $EXPECTED_VANADIUM_COMMIT, got $actual_vanadium_commit" >&2
    exit 1
fi

# gclient hooks apply patches inside independent Git subprojects (for example
# V8), so the ephemeral runner needs a non-secret committer identity globally.
git config --global user.name "$GIT_COMMITTER_NAME"
git config --global user.email "$GIT_COMMITTER_EMAIL"

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
git config user.name "Titanium Personal Builder"
git config user.email "titanium-personal-builder@users.noreply.github.com"
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
mkdir -p out/Default
cp "$SCRIPT_DIR/args.gn" out/Default/args.gn

# Git checkouts receive fresh mtimes on every hosted runner.  A resumed Ninja
# output cache would otherwise look older than every source file and rebuild
# from zero.  Normalize source/input mtimes while deliberately leaving the
# cached output tree untouched.  Content hashes and GN inputs remain pinned.
find . -path './out' -prune -o -type f -exec touch -h -d '@946684800' {} +

# The fallback checkpoint predates the enhanced desktop profile. Make only the
# inputs changed by that profile newer than restored Ninja outputs so Chromium
# incrementally recompiles the affected browser/Blink/Java/resource graph.
enhanced_desktop_inputs=(
    chrome/android/java/res/values/ids.xml
    chrome/android/java/src/org/chromium/chrome/browser/app/ChromeActivity.java
    chrome/android/java/src/org/chromium/chrome/browser/app/appmenu/AppMenuPropertiesDelegateImpl.java
    chrome/android/java/src/org/chromium/chrome/browser/customtabs/CustomTabAppMenuPropertiesDelegate.java
    chrome/android/java/src/org/chromium/chrome/browser/tab/TabImpl.java
    chrome/android/java/src/org/chromium/chrome/browser/tabbed_mode/TabbedAppMenuPropertiesDelegate.java
    chrome/browser/android/content/content_utils.cc
    chrome/browser/android/content/java/src/org/chromium/chrome/browser/content/ContentUtils.java
    chrome/browser/content_settings/request_desktop_site_web_contents_observer_android.cc
    chrome/browser/preferences/android/java/src/org/chromium/chrome/browser/preferences/ChromePreferenceKeys.java
    chrome/browser/ui/android/desktop_site/java/src/org/chromium/chrome/browser/desktop_site/DesktopSiteUtils.java
    chrome/browser/ui/android/strings/android_chrome_strings.grd
    content/browser/web_contents/web_contents_impl.cc
    third_party/blink/renderer/core/frame/navigator.cc
)
for enhanced_desktop_input in "${enhanced_desktop_inputs[@]}"; do
    test -f "$enhanced_desktop_input"
    touch -h "$enhanced_desktop_input"
done

# A one-time cache migration may restore output produced before the personal
# launcher label changed. Source mtimes are normalized above, so explicitly
# make this content-bearing Android resource newer than any restored output.
# Touching only this file keeps the completed native Chromium objects reusable
# while forcing Ninja to regenerate the resource/package dependency chain.
android_branding_input='chrome/android/java/res_titanium_base/values/channel_constants.xml'
test -f "$android_branding_input"
touch -h "$android_branding_input"

gn gen out/Default

# A clean Chromium build is longer than GitHub's six-hour hosted-job limit.
# Stop cleanly before that hard limit so Actions can persist out/Default, then
# resume the same Ninja graph in the next hosted job.
set +e
# Do not use timeout's --foreground mode here. autoninja launches Siso as a
# child process; foreground mode only signalled the wrapper and let Siso keep
# the Actions step alive until GitHub's hard job timeout. The default process
# group mode interrupts the complete compiler tree and leaves time to cache it.
timeout --signal=INT --kill-after=120s \
    "${BUILD_SLICE_SECONDS}s" autoninja -C out/Default chrome_public_apk
compile_rc=$?
set -e

if [[ "$compile_rc" -ne 0 ]]; then
    if [[ "$compile_rc" -eq 124 || "$compile_rc" -eq 130 ||
          "$compile_rc" -eq 137 || "$compile_rc" -eq 143 ]]; then
        echo "Chromium build slice completed; out/Default is ready to resume"
        sync
        exit 75
    fi
    echo "Chromium build failed with exit code $compile_rc" >&2
    exit "$compile_rc"
fi

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
