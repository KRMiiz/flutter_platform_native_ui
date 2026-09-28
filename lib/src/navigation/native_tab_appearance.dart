import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'native_tab_label_style.dart';

/// Optional appearance preferences for [NativeTabBar].
///
/// Leaving a property null lets the operating system choose its native value,
/// including new visual treatments introduced by future OS releases.
@immutable
final class NativeTabBarAppearance {
  const NativeTabBarAppearance({
    this.selectedColor,
    this.unselectedColor,
    this.backgroundColor,
    this.labelStyle,
    this.selectedLabelStyle,
    this.badgeStyle,
    this.selectedBadgeStyle,
  });

  /// The tint used by the selected item.
  final Color? selectedColor;

  /// The tint used by unselected items.
  final Color? unselectedColor;

  /// An optional opaque tab bar background color.
  final Color? backgroundColor;

  /// Typography for unselected labels. Null preserves the platform default.
  final NativeTabBarLabelStyle? labelStyle;

  /// Typography for selected labels. Defaults to [labelStyle] when null.
  final NativeTabBarLabelStyle? selectedLabelStyle;

  /// Typography for badges on unselected items.
  final NativeTabBarLabelStyle? badgeStyle;

  /// Typography for badges on selected items. Defaults to [badgeStyle].
  final NativeTabBarLabelStyle? selectedBadgeStyle;

  @internal
  Map<String, Object?> toMap() => <String, Object?>{
        if (selectedColor != null) 'selectedColor': selectedColor!.toARGB32(),
        if (unselectedColor != null)
          'unselectedColor': unselectedColor!.toARGB32(),
        if (backgroundColor != null)
          'backgroundColor': backgroundColor!.toARGB32(),
        if (labelStyle != null) 'labelStyle': labelStyle!.toMap(),
        if (selectedLabelStyle != null)
          'selectedLabelStyle': selectedLabelStyle!.toMap(),
        if (badgeStyle != null) 'badgeStyle': badgeStyle!.toMap(),
        if (selectedBadgeStyle != null)
          'selectedBadgeStyle': selectedBadgeStyle!.toMap(),
      };

  @override
  bool operator ==(Object other) =>
      other is NativeTabBarAppearance &&
      other.selectedColor == selectedColor &&
      other.unselectedColor == unselectedColor &&
      other.backgroundColor == backgroundColor &&
      other.labelStyle == labelStyle &&
      other.selectedLabelStyle == selectedLabelStyle &&
      other.badgeStyle == badgeStyle &&
      other.selectedBadgeStyle == selectedBadgeStyle;

  @override
  int get hashCode => Object.hash(
        selectedColor,
        unselectedColor,
        backgroundColor,
        labelStyle,
        selectedLabelStyle,
        badgeStyle,
        selectedBadgeStyle,
      );
}
