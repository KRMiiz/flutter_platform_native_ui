import 'package:flutter/foundation.dart';

/// How an asset icon participates in native tinting.
enum NativeTabIconRenderingMode {
  /// Treat non-transparent pixels as a mask and apply the tab bar tint.
  template,

  /// Preserve the colors embedded in the image.
  original,
}

/// A description of an icon displayed by the native iOS tab bar.
@immutable
sealed class NativeTabIcon {
  const NativeTabIcon._();

  /// Uses an iOS SF Symbol.
  const factory NativeTabIcon.sfSymbol(
    String name, {
    String? accessibilityLabel,
  }) = NativeTabSfSymbolIcon;

  /// Uses an asset declared by the host Flutter application.
  ///
  /// [package] can identify an asset supplied by another Flutter package.
  /// Only PNG assets are supported.
  const factory NativeTabIcon.asset(
    String asset, {
    String? package,
    NativeTabIconRenderingMode renderingMode,
    double size,
    String? accessibilityLabel,
  }) = NativeTabAssetIcon;

  /// An accessible description for the icon, if it conveys information that
  /// is not already present in the tab label.
  String? get accessibilityLabel;

  @internal
  Map<String, Object?> toMap();
}

/// An SF Symbols icon description.
@immutable
final class NativeTabSfSymbolIcon extends NativeTabIcon {
  const NativeTabSfSymbolIcon(this.name, {this.accessibilityLabel}) : super._();

  /// The SF Symbols name, for example `person` or `house.fill`.
  final String name;

  @override
  final String? accessibilityLabel;

  @override
  Map<String, Object?> toMap() => <String, Object?>{
        'type': 'sfSymbol',
        'name': name,
        if (accessibilityLabel != null)
          'accessibilityLabel': accessibilityLabel,
      };

  @override
  bool operator ==(Object other) =>
      other is NativeTabSfSymbolIcon &&
      other.name == name &&
      other.accessibilityLabel == accessibilityLabel;

  @override
  int get hashCode => Object.hash(name, accessibilityLabel);
}

/// A Flutter asset icon description.
@immutable
final class NativeTabAssetIcon extends NativeTabIcon {
  const NativeTabAssetIcon(
    this.asset, {
    this.package,
    this.renderingMode = NativeTabIconRenderingMode.template,
    this.size = 24,
    this.accessibilityLabel,
  })  : assert(asset != ''),
        assert(size > 0),
        super._();

  /// The key declared in the host application's `pubspec.yaml`.
  final String asset;

  /// The package containing the asset, or null for a host-app asset.
  final String? package;

  /// Whether UIKit should tint the icon or preserve its original colors.
  final NativeTabIconRenderingMode renderingMode;

  /// The target logical display size.
  final double size;

  @override
  final String? accessibilityLabel;

  @override
  Map<String, Object?> toMap() {
    if (!asset.toLowerCase().endsWith('.png')) {
      throw ArgumentError.value(
        asset,
        'asset',
        'Only PNG assets are supported',
      );
    }
    return <String, Object?>{
      'type': 'asset',
      'asset': asset,
      if (package != null) 'package': package,
      'renderingMode': renderingMode.name,
      'size': size,
      if (accessibilityLabel != null) 'accessibilityLabel': accessibilityLabel,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is NativeTabAssetIcon &&
      other.asset == asset &&
      other.package == package &&
      other.renderingMode == renderingMode &&
      other.size == size &&
      other.accessibilityLabel == accessibilityLabel;

  @override
  int get hashCode =>
      Object.hash(asset, package, renderingMode, size, accessibilityLabel);
}
