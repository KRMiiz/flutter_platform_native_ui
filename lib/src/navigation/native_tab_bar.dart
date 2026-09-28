import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import 'native_tab_appearance.dart';
import 'native_tab_item.dart';

const String _viewType = 'dev.flutterplatformnativeui/native_tab_bar';
const String _channelPrefix = 'dev.flutterplatformnativeui/native_tab_bar';

/// A tab bar whose appearance is owned by the host platform.
///
/// This widget is available on iOS 15 and later. It reports selection only and
/// never performs application navigation itself.
class NativeTabBar extends StatefulWidget {
  const NativeTabBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.canSelect,
    this.appearance = const NativeTabBarAppearance(),
    this.height = 64,
  })  : assert(items.length >= 2),
        assert(currentIndex >= 0),
        assert(currentIndex < items.length),
        assert(height > 0);

  /// The index that the native tab bar displays as selected.
  final int currentIndex;

  /// The tabs displayed by the native tab bar. At least two are required.
  final List<NativeTabItem> items;

  /// Called with the index of a tab tapped by the user.
  final ValueChanged<int> onTap;

  /// Whether a tab may become selected. [onTap] is still reported when this
  /// returns false, so the host can show a login or eligibility flow.
  final bool Function(int index)? canSelect;
  /// Optional colors and typography applied to the native tab bar.
  final NativeTabBarAppearance appearance;

  /// The height allocated to the native tab bar, in logical pixels.
  final double height;

  @override
  State<NativeTabBar> createState() => _NativeTabBarState();
}

class _NativeTabBarState extends State<NativeTabBar> {
  MethodChannel? _channel;

  bool get _usesUIKit => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Map<String, Object?> get _state => <String, Object?>{
        'currentIndex': widget.currentIndex,
        'items':
            widget.items.map((NativeTabItem item) => item.toMap()).toList(),
        'appearance': widget.appearance.toMap(),
      };

  @override
  void didUpdateWidget(covariant NativeTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_usesUIKit || _channel == null) return;
    if (!listEquals(oldWidget.items, widget.items) ||
        oldWidget.currentIndex != widget.currentIndex ||
        oldWidget.appearance != widget.appearance) {
      _channel!.invokeMethod<void>('update', _state);
    }
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_usesUIKit) {
      throw UnsupportedError('NativeTabBar is supported on iOS only.');
    }
    return SizedBox(height: widget.height, child: _buildUIKitView());
  }

  Widget _buildUIKitView() {
    return UiKitView(
      viewType: _viewType,
      creationParams: _state,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: (int viewId) {
        final MethodChannel channel = MethodChannel('$_channelPrefix/$viewId');
        _channel = channel;
        channel.setMethodCallHandler((MethodCall call) async {
          if (call.method == 'onTap' && mounted) {
            final int index = call.arguments as int;
            if (index >= 0 && index < widget.items.length) {
              if (widget.canSelect?.call(index) == false) {
                widget.onTap(index);
                await channel.invokeMethod<void>('update', _state);
                return;
              }
              widget.onTap(index);
            }
          }
        });
      },
    );
  }
}
