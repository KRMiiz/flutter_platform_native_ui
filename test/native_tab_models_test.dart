import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_platform_native_ui/flutter_platform_native_ui.dart';

void main() {
  test('asset icon preserves extensible source metadata', () {
    const NativeTabIcon icon = NativeTabIcon.asset(
      'icons/home.png',
      package: 'design_system',
      renderingMode: NativeTabIconRenderingMode.original,
      size: 28,
      accessibilityLabel: 'Home artwork',
    );
    expect(icon, isA<NativeTabAssetIcon>());
    expect((icon as NativeTabAssetIcon).toMap(), <String, Object?>{
      'type': 'asset',
      'asset': 'icons/home.png',
      'package': 'design_system',
      'renderingMode': 'original',
      'size': 28.0,
      'accessibilityLabel': 'Home artwork',
    });
  });

  test('asset icon rejects non-PNG files', () {
    const NativeTabIcon icon = NativeTabIcon.asset('icons/home.svg');
    expect(() => icon.toMap(), throwsArgumentError);
  });

  test('tab item serializes selected icon, badge, and accessibility label', () {
    const NativeTabItem item = NativeTabItem(
      label: 'Coupon',
      icon: NativeTabIcon.sfSymbol('ticket'),
      selectedIcon: NativeTabIcon.sfSymbol('ticket.fill'),
      badge: '3',
      accessibilityLabel: 'Coupons, 3 available',
    );
    expect(item.toMap(), <String, Object?>{
      'label': 'Coupon',
      'icon': <String, Object?>{'type': 'sfSymbol', 'name': 'ticket'},
      'selectedIcon': <String, Object?>{
        'type': 'sfSymbol',
        'name': 'ticket.fill',
      },
      'badge': '3',
      'accessibilityLabel': 'Coupons, 3 available',
    });
  });

  test('appearance serializes ARGB colors', () {
    const NativeTabBarAppearance appearance = NativeTabBarAppearance(
      selectedColor: Color(0xff123456),
      backgroundColor: Color(0x80112233),
    );
    expect(appearance.toMap(), <String, Object?>{
      'selectedColor': 0xff123456,
      'backgroundColor': 0x80112233,
    });
  });

  test('appearance serializes normal and selected label typography', () {
    const NativeTabBarAppearance appearance = NativeTabBarAppearance(
      labelStyle: NativeTabBarLabelStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        verticalOffset: 1,
        color: Color(0xff123456),
      ),
      selectedLabelStyle: NativeTabBarLabelStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        verticalOffset: 2,
        fontFamily: 'Prompt-Bold',
      ),
      badgeStyle: NativeTabBarLabelStyle(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        color: Color(0xffffffff),
      ),
      selectedBadgeStyle: NativeTabBarLabelStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    );

    expect(appearance.toMap(), <String, Object?>{
      'labelStyle': <String, Object?>{
        'fontSize': 11.0,
        'fontWeight': 500,
        'verticalOffset': 1.0,
        'color': 0xff123456,
      },
      'selectedLabelStyle': <String, Object?>{
        'fontSize': 12.0,
        'fontWeight': 700,
        'verticalOffset': 2.0,
        'fontFamily': 'Prompt-Bold',
      },
      'badgeStyle': <String, Object?>{
        'fontSize': 9.0,
        'fontWeight': 600,
        'color': 0xffffffff,
      },
      'selectedBadgeStyle': <String, Object?>{
        'fontSize': 10.0,
        'fontWeight': 700,
      },
    });
  });
}
