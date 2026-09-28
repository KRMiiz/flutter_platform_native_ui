# NativeTabBar decision record

## D1 — Use a platform view on iOS

**Decision:** Host UIKit `UITabBar` through `UiKitView`.

**Reason:** The operating system must render its real tab-bar appearance. A
method channel without a platform view cannot insert UIKit into Flutter layout,
and a Flutter recreation would not be the native control.

**Tradeoff:** Platform views add lifecycle, composition, and cross-language
maintenance overhead.

## D2 — Use a per-view MethodChannel

**Decision:** Create one channel per platform-view ID.

**Reason:** Multiple `NativeTabBar` instances can coexist without shared state,
and ordinary state changes can update the existing native view.

**Tradeoff:** Dart and Swift must keep their standard-codec wire schema aligned.

## D3 — Navigation belongs to the host

**Decision:** Emit only `onTap(index)`.

**Reason:** The component must work with `go_router`, indexed shell routes, and
other state-management choices without coupling to any of them.

## D4 — PNG assets only

**Decision:** Support PNG assets and SF Symbols; reject SVG and other raster
formats.

**Reason:** `UIImage` loads PNG reliably without an SVG parser, asynchronous
rasterization, or extra native dependencies. The public asset constructor can
support more sources in a future additive release.

**Tradeoff:** Consumers must provide sufficiently high-resolution PNGs and
cannot use resolution-independent SVGs in this milestone.

## D5 — Preserve system appearance by default

**Decision:** Do not configure a custom native background unless the caller
provides `backgroundColor`.

**Reason:** Standard UIKit controls automatically adapt to supported OS design,
light/dark mode, and accessibility preferences.

**Tradeoff:** Exact visuals can differ between iOS releases and devices.

## D6 — Fail explicitly outside iOS

**Decision:** Throw `UnsupportedError` when `NativeTabBar` is built outside
iOS.

**Reason:** The package promises a real native control. Silently substituting a
different Flutter widget would obscure the platform boundary and produce
different behavior.

**Tradeoff:** Cross-platform applications must choose an alternative widget on
non-iOS platforms.

## D7 — Expose generic label typography

**Decision:** Allow normal and selected label and badge styles to specify point
size, weight, and optional font family and color.

**Reason:** Typography is application intent and is not tied to a particular
iOS visual generation. UIKit applies it through `UITabBarAppearance` for every
supported item layout.

**Tradeoff:** Flutter font family names and iOS PostScript names are not always
identical. Missing native fonts fall back to the system font.
