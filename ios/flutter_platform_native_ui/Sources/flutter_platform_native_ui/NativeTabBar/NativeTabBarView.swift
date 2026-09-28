import Flutter
import UIKit

final class NativeTabBarView: NSObject, FlutterPlatformView, UITabBarDelegate {
  private let containerView: UIView
  private let tabBar: UITabBar
  private let channel: FlutterMethodChannel
  private let assetKeyResolver: AssetKeyResolver
  private let defaultStandardAppearance: UITabBarAppearance
  private let defaultScrollEdgeAppearance: UITabBarAppearance?

  init(
    frame: CGRect,
    viewId: Int64,
    arguments: Any?,
    messenger: FlutterBinaryMessenger,
    assetKeyResolver: @escaping AssetKeyResolver
  ) {
    containerView = UIView(frame: frame)
    tabBar = UITabBar(frame: frame)
    channel = FlutterMethodChannel(
      name: "dev.flutterplatformnativeui/native_tab_bar/\(viewId)",
      binaryMessenger: messenger
    )
    self.assetKeyResolver = assetKeyResolver
    defaultStandardAppearance = tabBar.standardAppearance.copy() as! UITabBarAppearance
    if #available(iOS 15.0, *) {
      defaultScrollEdgeAppearance = tabBar.scrollEdgeAppearance?.copy() as? UITabBarAppearance
    } else {
      defaultScrollEdgeAppearance = nil
    }
    super.init()

    containerView.backgroundColor = .clear
    tabBar.translatesAutoresizingMaskIntoConstraints = false
    tabBar.delegate = self
    containerView.addSubview(tabBar)
    NSLayoutConstraint.activate([
      tabBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      tabBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      tabBar.topAnchor.constraint(equalTo: containerView.topAnchor),
      tabBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
    ])

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "disposed", message: "Native tab bar was disposed", details: nil))
        return
      }
      switch call.method {
      case "update":
        self.apply(state: call.arguments)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    apply(state: arguments)
  }

  deinit {
    channel.setMethodCallHandler(nil)
  }

  func view() -> UIView { containerView }

  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    guard let index = tabBar.items?.firstIndex(of: item) else { return }
    channel.invokeMethod("onTap", arguments: index)
  }

  private func apply(state rawState: Any?) {
    guard let state = rawState as? [String: Any] else { return }
    let rawItems = state["items"] as? [[String: Any]] ?? []
    tabBar.items = rawItems.enumerated().map { index, item in
      makeTabBarItem(item, tag: index)
    }

    let selectedIndex = (state["currentIndex"] as? NSNumber)?.intValue ?? 0
    if let items = tabBar.items, items.indices.contains(selectedIndex) {
      tabBar.selectedItem = items[selectedIndex]
    }

    let appearance = state["appearance"] as? [String: Any] ?? [:]
    apply(appearance: appearance)
    applyItemTitleOffsets(appearance: appearance)
  }

  private func makeTabBarItem(_ data: [String: Any], tag: Int) -> UITabBarItem {
    let title = data["label"] as? String
    let baseImage = image(from: data["icon"] as? [String: Any])
    let selectedImage = image(from: data["selectedIcon"] as? [String: Any]) ?? baseImage
    let item = UITabBarItem(title: title, image: baseImage, selectedImage: selectedImage)
    item.tag = tag
    item.badgeValue = data["badge"] as? String
    item.accessibilityLabel = data["accessibilityLabel"] as? String ?? title
    return item
  }

  private func image(from data: [String: Any]?) -> UIImage? {
    guard let data, let type = data["type"] as? String else { return nil }
    switch type {
    case "sfSymbol":
      guard let name = data["name"] as? String else { return nil }
      return UIImage(systemName: name)
    case "asset":
      return assetImage(from: data)
    default:
      return nil
    }
  }

  private func assetImage(from description: [String: Any]) -> UIImage? {
    guard
      let asset = description["asset"] as? String,
      asset.lowercased().hasSuffix(".png")
    else { return nil }
    let package = description["package"] as? String
    let key = assetKeyResolver(asset, package)
    guard
      let path = Bundle.main.path(forResource: key, ofType: nil),
      let source = UIImage(contentsOfFile: path)
    else { return nil }

    let pointSize = CGFloat((description["size"] as? NSNumber)?.doubleValue ?? 24)
    let targetSize = CGSize(width: pointSize, height: pointSize)
    let format = UIGraphicsImageRendererFormat.default()
    format.opaque = false
    format.scale = UIScreen.main.scale
    let rendered = UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
      let sourceSize = source.size
      guard sourceSize.width > 0, sourceSize.height > 0 else { return }
      let scale = min(targetSize.width / sourceSize.width, targetSize.height / sourceSize.height)
      let fitted = CGSize(width: sourceSize.width * scale, height: sourceSize.height * scale)
      let origin = CGPoint(
        x: (targetSize.width - fitted.width) / 2,
        y: (targetSize.height - fitted.height) / 2
      )
      source.draw(in: CGRect(origin: origin, size: fitted))
    }

    let mode = description["renderingMode"] as? String
    return rendered.withRenderingMode(mode == "original" ? .alwaysOriginal : .alwaysTemplate)
  }

  private func apply(appearance: [String: Any]) {
    tabBar.tintColor = color(from: appearance["selectedColor"])
    tabBar.unselectedItemTintColor = color(from: appearance["unselectedColor"])

    let backgroundColor = color(from: appearance["backgroundColor"])
    let labelStyle = appearance["labelStyle"] as? [String: Any]
    let selectedLabelStyle = appearance["selectedLabelStyle"] as? [String: Any]
    let badgeStyle = appearance["badgeStyle"] as? [String: Any]
    let selectedBadgeStyle = appearance["selectedBadgeStyle"] as? [String: Any]
    guard backgroundColor != nil || labelStyle != nil || selectedLabelStyle != nil ||
          badgeStyle != nil || selectedBadgeStyle != nil else {
      tabBar.standardAppearance = defaultStandardAppearance.copy() as! UITabBarAppearance
      if #available(iOS 15.0, *) {
        tabBar.scrollEdgeAppearance = defaultScrollEdgeAppearance?.copy() as? UITabBarAppearance
      }
      return
    }

    let nativeAppearance = defaultStandardAppearance.copy() as! UITabBarAppearance
    if let backgroundColor {
      nativeAppearance.configureWithOpaqueBackground()
      nativeAppearance.backgroundColor = backgroundColor
    }
    apply(
      labelStyle: labelStyle,
      selectedLabelStyle: selectedLabelStyle,
      badgeStyle: badgeStyle,
      selectedBadgeStyle: selectedBadgeStyle,
      to: nativeAppearance.stackedLayoutAppearance
    )
    apply(
      labelStyle: labelStyle,
      selectedLabelStyle: selectedLabelStyle,
      badgeStyle: badgeStyle,
      selectedBadgeStyle: selectedBadgeStyle,
      to: nativeAppearance.inlineLayoutAppearance
    )
    apply(
      labelStyle: labelStyle,
      selectedLabelStyle: selectedLabelStyle,
      badgeStyle: badgeStyle,
      selectedBadgeStyle: selectedBadgeStyle,
      to: nativeAppearance.compactInlineLayoutAppearance
    )
    tabBar.standardAppearance = nativeAppearance
    if #available(iOS 15.0, *) {
      tabBar.scrollEdgeAppearance = nativeAppearance
    }
  }

  private func apply(
    labelStyle: [String: Any]?,
    selectedLabelStyle: [String: Any]?,
    badgeStyle: [String: Any]?,
    selectedBadgeStyle: [String: Any]?,
    to itemAppearance: UITabBarItemAppearance
  ) {
    itemAppearance.normal.titleTextAttributes.merge(
      textAttributes(from: labelStyle),
      uniquingKeysWith: { _, new in new }
    )
    itemAppearance.selected.titleTextAttributes.merge(
      textAttributes(from: selectedLabelStyle ?? labelStyle),
      uniquingKeysWith: { _, new in new }
    )
    if let offset = verticalOffset(from: labelStyle) {
      itemAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: offset)
    }
    if let offset = verticalOffset(from: selectedLabelStyle ?? labelStyle) {
      itemAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: offset)
    }
    itemAppearance.normal.badgeTextAttributes.merge(
      textAttributes(from: badgeStyle),
      uniquingKeysWith: { _, new in new }
    )
    itemAppearance.selected.badgeTextAttributes.merge(
      textAttributes(from: selectedBadgeStyle ?? badgeStyle),
      uniquingKeysWith: { _, new in new }
    )
  }

  /// Assigning the offset to each live item keeps it effective on tab bar
  /// presentations where UIKit does not honor the appearance-proxy value.
  private func applyItemTitleOffsets(appearance: [String: Any]) {
    let labelStyle = appearance["labelStyle"] as? [String: Any]
    let selectedLabelStyle = appearance["selectedLabelStyle"] as? [String: Any]
    let offset = verticalOffset(from: labelStyle) ??
      verticalOffset(from: selectedLabelStyle) ?? 0
    for item in tabBar.items ?? [] {
      item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: offset)
    }
  }

  private func verticalOffset(from style: [String: Any]?) -> CGFloat? {
    guard let value = style?["verticalOffset"] as? NSNumber else { return nil }
    return CGFloat(value.doubleValue)
  }

  private func textAttributes(from style: [String: Any]?) -> [NSAttributedString.Key: Any] {
    guard let style else { return [:] }
    var attributes: [NSAttributedString.Key: Any] = [:]
    if let font = font(from: style) {
      attributes[.font] = font
    }
    if let textColor = color(from: style["color"]) {
      attributes[.foregroundColor] = textColor
    }
    return attributes
  }

  private func font(from style: [String: Any]?) -> UIFont? {
    guard let style else { return nil }
    let size = CGFloat((style["fontSize"] as? NSNumber)?.doubleValue ?? 10)
    if let family = style["fontFamily"] as? String,
       let customFont = UIFont(name: family, size: size) {
      return customFont
    }
    let numericWeight = (style["fontWeight"] as? NSNumber)?.intValue ?? 400
    let weight: UIFont.Weight
    switch numericWeight {
    case ...150: weight = .ultraLight
    case ...250: weight = .thin
    case ...350: weight = .light
    case ...450: weight = .regular
    case ...550: weight = .medium
    case ...650: weight = .semibold
    case ...750: weight = .bold
    case ...850: weight = .heavy
    default: weight = .black
    }
    return UIFont.systemFont(ofSize: size, weight: weight)
  }

  private func color(from value: Any?) -> UIColor? {
    guard let argb = value as? NSNumber else { return nil }
    let bits = argb.uint32Value
    return UIColor(
      red: CGFloat((bits >> 16) & 0xff) / 255,
      green: CGFloat((bits >> 8) & 0xff) / 255,
      blue: CGFloat(bits & 0xff) / 255,
      alpha: CGFloat((bits >> 24) & 0xff) / 255
    )
  }
}
