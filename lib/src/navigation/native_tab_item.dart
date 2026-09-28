import 'package:flutter/foundation.dart';

import 'native_tab_icon.dart';

/// A tab displayed by [NativeTabBar].
@immutable
final class NativeTabItem {
  const NativeTabItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
    this.accessibilityLabel,
  })  : assert(label != ''),
        assert(badge == null || badge != '');

  /// The visible tab label.
  final String label;

  /// The icon shown while the tab is not selected.
  final NativeTabIcon icon;

  /// An optional icon shown while selected. Defaults to [icon].
  final NativeTabIcon? selectedIcon;

  /// Optional badge text. Set to null to hide the badge.
  final String? badge;

  /// Overrides the combined label used by assistive technologies.
  final String? accessibilityLabel;

  @internal
  Map<String, Object?> toMap() => <String, Object?>{
        'label': label,
        'icon': icon.toMap(),
        if (selectedIcon != null) 'selectedIcon': selectedIcon!.toMap(),
        if (badge != null) 'badge': badge,
        if (accessibilityLabel != null)
          'accessibilityLabel': accessibilityLabel,
      };

  @override
  bool operator ==(Object other) =>
      other is NativeTabItem &&
      other.label == label &&
      other.icon == icon &&
      other.selectedIcon == selectedIcon &&
      other.badge == badge &&
      other.accessibilityLabel == accessibilityLabel;

  @override
  int get hashCode =>
      Object.hash(label, icon, selectedIcon, badge, accessibilityLabel);
}
