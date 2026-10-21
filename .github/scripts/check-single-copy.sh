#!/bin/bash
# Counts the Mach-O images in an .app that define each class. Expects exactly 1 each, so exits non-zero
# when an SDK is linked twice (for example from both CocoaPods and Swift Package Manager).
# Usage: check-single-copy.sh path/to/App.app (an archived or Release .app; Debug builds keep app code in
# App.debug.dylib, which is not scanned)
set -u
APP="${1}"
bins=("${APP}/$(basename "${APP}" .app)")
while IFS= read -r fw; do
	bins+=("${fw}/$(basename "${fw}" .framework)")
done < <(find "${APP}/Frameworks" -maxdepth 1 -name '*.framework' 2>/dev/null || true)

defines_class() {
	local binary="${1}" cls="${2}" symbols objc
	symbols="$(nm -U "${binary}" 2>/dev/null || true)"
	objc="$(otool -oV "${binary}" 2>/dev/null || true)"
	grep -qE "_OBJC_CLASS_\\\$_${cls}\$" <<<"${symbols}" || grep -qE "^ +name +0x[0-9a-f]+ ${cls}\$" <<<"${objc}"
}

status=0
# Rokt (a Swift class) appears under its mangled symbol name.
for cls in _TtC11Rokt_Widget4Rokt RoktEmbeddedView RNRoktWidget RoktPlaceholderRegistry RoktNativeWidgetComponentView; do
	hits=()
	for b in "${bins[@]}"; do
		[[ -f ${b} ]] || continue
		if defines_class "${b}" "${cls}"; then hits+=("$(basename "${b}")"); fi
	done
	echo "${cls}: ${#hits[@]} [${hits[*]-}]"
	[[ ${#hits[@]} -eq 1 ]] || status=1
done
exit "${status}"
