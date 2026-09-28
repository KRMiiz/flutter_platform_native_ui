# flutter_platform_native_ui

`flutter_platform_native_ui` provides iOS-native UI components for Flutter. The first
component is `NativeTabBar`, backed by a real UIKit `UITabBar` on iOS 15 and
later.

Project guidance for this component is maintained in:

- [Architecture](https://github.com/KRMiiz/flutter_platform_native_ui/blob/main/doc/native-tab-bar/architecture.md)
- [Specification](https://github.com/KRMiiz/flutter_platform_native_ui/blob/main/doc/native-tab-bar/spec.md)
- [Decision record](https://github.com/KRMiiz/flutter_platform_native_ui/blob/main/doc/native-tab-bar/decisions.md)

## Architecture

On iOS, `NativeTabBar` embeds one `UITabBar` through `UiKitView`. Initial state
is passed as platform-view creation parameters and later item, selection,
badge, icon, and tint changes use a per-view `MethodChannel`. The native view is
therefore not recreated during ordinary widget updates. UIKit owns rendering,
accessibility, light/dark adaptation, and the current system appearance. No
Flutter blur or imitation of an iOS visual style is used.

The package supports iOS only. The component only calls `onTap`; navigation
remains the host application's responsibility, so it works with `go_router`
and `StatefulShellRoute.indexedStack` without coupling to either.

## Usage

```dart
NativeTabBar(
  currentIndex: currentIndex,
  items: const [
    NativeTabItem(
      label: 'Home',
      icon: NativeTabIcon.sfSymbol('house'),
      selectedIcon: NativeTabIcon.sfSymbol('house.fill'),
    ),
    NativeTabItem(
      label: 'Account',
      icon: NativeTabIcon.sfSymbol('person'),
    ),
  ],
  onTap: (index) => setState(() => currentIndex = index),
)
```

Use `canSelect` when a tab requires a host-controlled eligibility check. The
tap is still reported through `onTap` when it returns `false`.

Declare application assets in the host app's `pubspec.yaml`, as usual. Use the
optional `package` argument for assets shipped by another package.

## Asset handling on iOS

The plugin accepts PNG assets only. It calls Flutter's `lookupKeyForAsset`
registrar API instead of assuming an on-disk path, then loads the resolved PNG
from the application bundle. Use transparent PNGs with enough source
resolution for the requested logical `size` (24 points by default).
`template` rendering (the default) applies the native tab tint, while
`original` preserves source colors.

Leaving `NativeTabBarAppearance` values null is recommended when the goal is
the system-native look. Custom background colors intentionally replace the
system-provided background material.

See `example/` for a minimal iOS integration.
