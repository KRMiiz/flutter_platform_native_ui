# NativeTabBar specification

## Scope

This specification covers `NativeTabBar` only. “Navigation bar” in project
discussion refers to this bottom tab-selection component unless a future spec
defines another component.

## Public Dart API

The supported model consists of:

- `NativeTabBar`
  - `currentIndex`
  - `items`
  - `onTap`
  - optional `canSelect`
  - `appearance`
  - `height`
- `NativeTabItem`
  - `label`
  - `icon`
  - optional `selectedIcon`
  - optional `badge`
  - optional `accessibilityLabel`
- `NativeTabIcon.sfSymbol`
- `NativeTabIcon.asset`
- `NativeTabBarAppearance`
  - optional `selectedColor`
  - optional `unselectedColor`
  - optional `backgroundColor`
  - optional `labelStyle`
  - optional `selectedLabelStyle`
  - optional `badgeStyle`
  - optional `selectedBadgeStyle`
- `NativeTabBarLabelStyle`
  - `fontSize`
  - `fontWeight`
  - `verticalOffset`
  - optional `fontFamily`
  - optional `color`

Adding an icon source must be additive. Existing constructors and serialized
type identifiers must remain compatible unless a breaking release is planned.

## Behavioral requirements

### Selection

- `currentIndex` must be within `items`.
- A user tap emits `onTap(index)` exactly once.
- When `canSelect` returns false, the previous selected tab is restored after
  the tap and `onTap(index)` still reports the attempted selection.
- The plugin must not push, replace, or otherwise change application routes.
- Updating `currentIndex` updates the existing native selection.

### Items and badges

- The bar supports distinct unselected and selected icons.
- If `selectedIcon` is null, the regular icon is reused.
- A null badge hides the badge; a non-empty string displays it.
- Changes to items, labels, badges, or icons update the existing platform view.

### Icons

- SF Symbol names are passed to `UIImage(systemName:)` on iOS.
- Asset icons must be `.png` files; other formats produce a clear Dart error
  and are rejected by Swift defensively.
- PNG transparency must be preserved.
- `template` mode uses platform tint colors.
- `original` mode preserves embedded PNG colors.
- Package assets must use the optional `package` field and registrar package
  lookup.
- Use simple filenames such as `home.png` and `home_selected.png`.

### Appearance

- Null appearance values mean “use platform defaults.”
- The default iOS path must not assign a custom background appearance.
- Setting `backgroundColor` explicitly opts into an opaque background.
- No public property may represent Liquid Glass amount, blur radius, or a
  specific iOS design generation.
- Label typography applies to stacked, inline, and compact-inline UIKit item
  layouts so it remains consistent across iPhone and iPad.
- `verticalOffset` adjusts an iOS tab label's vertical position in every UIKit
  item layout; positive values move it down. Badge text retains its native
  position.
- Badge typography can be configured independently for normal and selected
  items and applies to every UIKit item layout.
- A style color overrides the general selected or unselected tint for that
  label or badge without changing the icon tint.
- A custom iOS `fontFamily` is interpreted as a bundled font's PostScript name;
  UIKit falls back to its system font when the font is unavailable.

### Accessibility

- UIKit remains responsible for native tab accessibility behavior.
- `NativeTabItem.accessibilityLabel` overrides the tab's spoken label.
- Without an override, the visible label is the accessibility label.
- Light/dark mode, Reduce Transparency, increased contrast, and VoiceOver must
  not be disabled or visually counterfeited by the plugin.

### Layout

- Flutter controls the widget's allocated height.
- The host application is responsible for placing the widget with the desired
  safe-area behavior.
- Swift pins `UITabBar` to all edges of the platform-view container.

## Wire protocol

Initial state and `update` calls use this conceptual shape:

```text
{
  currentIndex: int,
  items: [
    {
      label: string,
      icon: icon,
      selectedIcon?: icon,
      badge?: string,
      accessibilityLabel?: string
    }
  ],
  appearance: {
    selectedColor?: ARGB int,
    unselectedColor?: ARGB int,
    backgroundColor?: ARGB int
    labelStyle?: labelStyle,
    selectedLabelStyle?: labelStyle,
    badgeStyle?: labelStyle,
    selectedBadgeStyle?: labelStyle
  }
}

labelStyle = {
  fontSize: number,
  fontWeight: 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900,
  verticalOffset?: number,
  fontFamily?: string,
  color?: ARGB int
}

icon = {
  type: "sfSymbol",
  name: string,
  accessibilityLabel?: string
}
or {
  type: "asset",
  asset: string,
  package?: string,
  renderingMode: "template" | "original",
  size: number,
  accessibilityLabel?: string
}
```

Unknown method calls and unknown icon types must not crash the Flutter engine.

## Acceptance criteria

- iOS uses an actual `UITabBar`, not a Flutter visual reproduction.
- Initial items and selection render correctly.
- Tapping every item returns the correct index.
- Index, badge, icon, and appearance updates do not intentionally recreate the
  native view.
- Selected and unselected PNGs display correctly in original mode.
- Template PNGs follow selected and unselected tint colors.
- A non-PNG asset fails clearly.
- Leaving background color null preserves system-native appearance.
- Analyzer, Dart tests, and iOS simulator build pass.

## Out of scope

- Owning routes or page content.
- `go_router` integration code.
- Custom Liquid Glass reproduction or intensity controls.
- Buttons, sheets, top navigation bars, toolbars, or other native components.
- Android and other non-iOS platforms.
- SVG, JPEG, WebP, animated images, or remote icon URLs.
