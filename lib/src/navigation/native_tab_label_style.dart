import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Platform-neutral typography preferences for native tab labels.
///
/// When [fontFamily] is provided on iOS, it must be the PostScript name of a
/// font available in the host application bundle. The native system font is
/// used when that font cannot be loaded.
@immutable
final class NativeTabBarLabelStyle {
  const NativeTabBarLabelStyle({
    this.fontSize = 10,
    this.fontWeight = FontWeight.w400,
    this.verticalOffset = 0,
    this.fontFamily,
    this.color,
  }) : assert(fontSize > 0);

  /// Label size in logical points.
  final double fontSize;

  /// Label weight. UIKit maps this to the closest native system weight.
  final FontWeight fontWeight;

  /// Vertical label offset in logical points.
  ///
  /// A positive value moves a tab label down; a negative value moves it up.
  /// This is applied to tab labels on iOS and is ignored for badge text.
  final double verticalOffset;

  /// Optional Flutter font family / iOS PostScript font name.
  final String? fontFamily;

  /// Optional text color. This overrides the tab bar's general tint color for
  /// the label or badge using this style.
  final Color? color;

  @internal
  Map<String, Object?> toMap() => <String, Object?>{
        'fontSize': fontSize,
        'fontWeight': fontWeight.value,
        if (verticalOffset != 0) 'verticalOffset': verticalOffset,
        if (fontFamily != null) 'fontFamily': fontFamily,
        if (color != null) 'color': color!.toARGB32(),
      };

  @override
  bool operator ==(Object other) =>
      other is NativeTabBarLabelStyle &&
      other.fontSize == fontSize &&
      other.fontWeight == fontWeight &&
      other.verticalOffset == verticalOffset &&
      other.fontFamily == fontFamily &&
      other.color == color;

  @override
  int get hashCode =>
      Object.hash(fontSize, fontWeight, verticalOffset, fontFamily, color);
}
