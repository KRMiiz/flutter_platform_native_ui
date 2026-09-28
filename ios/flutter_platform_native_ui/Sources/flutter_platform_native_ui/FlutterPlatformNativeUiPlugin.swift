import Flutter
import UIKit

public class FlutterPlatformNativeUiPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let factory = NativeTabBarFactory(
      messenger: registrar.messenger(),
      assetKeyResolver: { asset, package in
        if let package {
          return registrar.lookupKey(forAsset: asset, fromPackage: package)
        }
        return registrar.lookupKey(forAsset: asset)
      }
    )
    registrar.register(factory, withId: "dev.flutterplatformnativeui/native_tab_bar")
  }
}
