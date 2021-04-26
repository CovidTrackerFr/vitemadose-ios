# Fixes binary framework bug, see:
# https://developer.apple.com/documentation/xcode-release-notes/xcode-12_4-release-notes#Swift-Packages
# https://github.com/firebase/firebase-ios-sdk/issues/6472
#

echo "Removing static frameworks from ${TARGET_NAME}.app"
find "${BUILT_PRODUCTS_DIR}/${TARGET_NAME}.app/" -name '*.framework' -print0 | while IFS= read -r -d '' fm; do
    name=$(basename "${fm}" .framework)
    target="${fm}/${name}"
    echo "Checking: ${fm}"
    if file "${target}" | grep -q "current ar archive"; then
        rm -rf "${fm}"
        echo "Removed static framework: ${fm}"
    fi
done
