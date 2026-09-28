# NativeTabBar architecture

## Purpose

`NativeTabBar` provides a Flutter API backed by UIKit on iOS. The component is
a tab selection control, not a navigation controller.

```text
Application state and router
            │
            │ currentIndex, items, onTap
            ▼
      NativeTabBar (Dart)
       │
       ▼
   UiKitView (iOS)
       │
 creation params + per-view MethodChannel
       │
       ▼
 NativeTabBarView (Swift)
       │
       ▼
  UIKit UITabBar
```

## Why a platform view

A platform channel alone can call native code but cannot place a UIKit control
inside Flutter's layout. `UiKitView` gives Flutter a widget-sized surface backed
by a real `UIView`. That allows UIKit to render `UITabBar` using the current
system design, including accessibility and system material behavior.

Pigeon is not necessary for the current small message surface. Creation and
update payloads contain only standard-codec maps, lists, numbers, strings, and
null. Reconsider typed messaging if the protocol grows substantially.

## Lifecycle and communication

1. Dart builds `UiKitView` with initial tab state in `creationParams`.
2. `NativeTabBarFactory` creates one `NativeTabBarView` for the platform-view ID.
3. Swift constructs and retains one `UITabBar` for that native view.
4. Dart and Swift open a channel named
   `dev.flutterplatformnativeui/native_tab_bar/<viewId>`.
5. Widget updates invoke `update` on that channel.
6. Native selection invokes `onTap` with the selected integer index.
7. Both sides remove their channel handlers when disposed.

Normal state updates must mutate the existing platform view. Flutter may still
recreate it when the widget is removed from the tree or its identity changes.

## State ownership

The host application owns the selected index and navigation state:

```text
native tap → onTap(index) → host router/state → currentIndex → native update
```

The native control may show immediate UIKit selection feedback, but Flutter's
`currentIndex` remains the authoritative application state. The plugin has no
dependency on `go_router`.

## Asset flow

`NativeTabIcon.asset` accepts PNG only. Dart sends the logical Flutter asset
key and optional package name. During plugin registration, Swift receives an
asset-key resolver backed by `FlutterPluginRegistrar.lookupKeyForAsset`. The
resolved path is loaded from `Bundle.main` into `UIImage`, resized onto a
transparent screen-scale canvas, and passed to `UITabBarItem`.

Template mode lets UIKit tint non-transparent pixels. Original mode preserves
the PNG colors. Asset filenames should use lowercase ASCII letters, digits,
underscores, hyphens, and `/`; spaces and URL-sensitive punctuation are not
supported project conventions.

## Appearance ownership

When appearance values are null, UIKit defaults remain in control. This is what
allows supported iOS releases and accessibility settings to select the native
material. If the caller provides `backgroundColor`, Swift intentionally creates
an opaque `UITabBarAppearance`; the system glass background is no longer used.

The Dart API must express generic intent such as selected color, unselected
color, and background color. It must not expose OS-version-specific visual
implementation details.

## Platform boundaries

- iOS 15 and later: `UiKitView` containing `UITabBar`.
- Other platforms are not supported.
- Flutter owns application content and routing.
- Platform-specific code remains under its platform directory.
