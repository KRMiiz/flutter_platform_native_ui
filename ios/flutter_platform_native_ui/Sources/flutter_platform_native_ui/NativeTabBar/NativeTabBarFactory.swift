import Flutter
import UIKit

typealias AssetKeyResolver = (_ asset: String, _ package: String?) -> String

final class NativeTabBarFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger
  private let assetKeyResolver: AssetKeyResolver

  init(messenger: FlutterBinaryMessenger, assetKeyResolver: @escaping AssetKeyResolver) {
    self.messenger = messenger
    self.assetKeyResolver = assetKeyResolver
    super.init()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    NativeTabBarView(
      frame: frame,
      viewId: viewId,
      arguments: args,
      messenger: messenger,
      assetKeyResolver: assetKeyResolver
    )
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}
